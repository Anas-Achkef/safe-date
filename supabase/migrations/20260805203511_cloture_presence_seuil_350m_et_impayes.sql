-- Un reversement peut exister sans paiement utilisateur : c'est le cas
-- de la garantie versee a l'etablissement en cas d'impaye.
alter table partner_settlements alter column payment_id drop not null;
alter table partner_settlements add column garantie boolean not null default false;
comment on column partner_settlements.garantie is
  'Reversement effectue par Safe Date en garantie d''une consommation impayee. L''etablissement est regle, Safe Date se retourne ensuite vers l''utilisateur.';

-- ---------- Presence et activation du Mode Rendez-vous ----------

create or replace function private.maj_presence(u uuid, d_id uuid, position_actuelle geography)
returns boolean language plpgsql as $fn$
declare v_dist double precision; v_rayon numeric; d dates; v_deux boolean;
begin
  select * into d from dates where id = d_id and (user_a = u or user_b = u);
  if d is null then
    raise exception 'Rendez-vous introuvable' using errcode = 'no_data_found';
  end if;

  select st_distance(position_actuelle, p.location) into v_dist
    from partners p where p.id = d.partner_id;
  v_rayon := private.engine_param('revelation_rayon_m');

  insert into date_presence (date_id, user_id, arrived_at, confirmed_at, distance_m)
  values (d_id, u,
          case when v_dist <= v_rayon then now() end,
          case when v_dist <= v_rayon then now() end,
          v_dist::integer)
  on conflict (date_id, user_id) do update set
    distance_m   = excluded.distance_m,
    arrived_at   = coalesce(date_presence.arrived_at, excluded.arrived_at),
    confirmed_at = coalesce(date_presence.confirmed_at, excluded.confirmed_at);

  -- Le rendez-vous commence quand les deux utilisateurs sont confirmes
  -- sur place. C'est ce qui bascule l'interface en Mode Rendez-vous.
  select count(*) filter (where confirmed_at is not null) = 2
    into v_deux from date_presence where date_id = d_id;

  if v_deux and d.status = 'confirme' then
    update dates set status = 'en_cours', mode_rdv_active_at = now() where id = d_id;
  end if;

  return v_deux;
end $fn$;

-- ---------- Seuil des 350 metres ----------

create or replace function private.distance_utilisateurs(d_id uuid)
returns double precision language sql stable as $fn$
  select st_distance(a.last_location, b.last_location)
  from dates d
  join profiles a on a.id = d.user_a
  join profiles b on b.id = d.user_b
  where d.id = d_id;
$fn$;

create or replace function private.evaluations_disponibles(d_id uuid)
returns boolean language sql stable as $fn$
  select coalesce(private.distance_utilisateurs(d_id)
                  >= private.engine_param('distance_evaluation_m'), false);
$fn$;
comment on function private.evaluations_disponibles is
  'Les evaluations ne sont proposees qu''une fois les deux utilisateurs suffisamment eloignes, afin que chacun reponde librement, sans influence ni gene.';

-- ---------- Fin et cloture ----------

create or replace function private.terminer_date(u uuid, d_id uuid)
returns integer language plpgsql as $fn$
declare v_reste integer;
begin
  if not exists (select 1 from dates where id = d_id and (user_a = u or user_b = u)) then
    raise exception 'Rendez-vous introuvable' using errcode = 'no_data_found';
  end if;
  v_reste := private.reste_a_payer(d_id);
  update dates set ended_at = now(), ended_by = u
   where id = d_id and closed_at is null;
  return v_reste;
end $fn$;
comment on function private.terminer_date is
  'Signale la fin du rendez-vous et renvoie le solde restant. Tant que la cloture n''a pas commence, l''action reste reversible.';

create or replace function private.reprendre_date(u uuid, d_id uuid)
returns void language plpgsql as $fn$
begin
  update dates set ended_at = null, ended_by = null
   where id = d_id and (user_a = u or user_b = u) and closed_at is null;
  if not found then
    raise exception 'Ce rendez-vous ne peut plus être repris' using errcode = 'check_violation';
  end if;
end $fn$;

create or replace function private.cloturer_date(d_id uuid)
returns jsonb language plpgsql as $fn$
declare
  d dates; v_reste integer; v_partis boolean; v_dette uuid;
  v_taux numeric; r record;
begin
  select * into d from dates where id = d_id;
  if d is null then
    raise exception 'Rendez-vous introuvable' using errcode = 'no_data_found';
  end if;
  if d.closed_at is not null then
    return jsonb_build_object('deja_cloture', true);
  end if;
  if d.ended_at is null then
    return jsonb_build_object('cloture', false, 'motif', 'rendez-vous non terminé');
  end if;

  select count(*) filter (where left_at is not null) = 2
    into v_partis from date_presence where date_id = d_id;
  if not coalesce(v_partis, false) then
    return jsonb_build_object('cloture', false, 'motif', 'les deux utilisateurs n''ont pas quitté l''établissement');
  end if;

  v_reste := private.reste_a_payer(d_id);
  v_taux  := private.commission_taux(d.partner_id);

  -- Tolerance zero sur les impayes, mais l'etablissement est garanti :
  -- Safe Date le regle, puis se retourne vers l'utilisateur.
  if v_reste > 0 then
    for r in
      select a.user_id, a.montant_cents
             - coalesce((select sum(p.amount_cents) from payments p
                         where p.date_id = d_id and p.kind = 'paiement'
                           and p.status = 'capture'
                           and (p.payer_id = a.user_id or p.mode = 'integral')), 0) as du
      from private.addition(d_id) a
    loop
      if r.du > 0 then
        insert into outstanding_debts (user_id, date_id, partner_id, amount_cents)
        values (r.user_id, d_id, d.partner_id, r.du)
        returning id into v_dette;
      end if;
    end loop;

    insert into partner_settlements (payment_id, partner_id, gross_cents,
                                     commission_cents, net_cents, garantie)
    values (null, d.partner_id, v_reste, round(v_reste * v_taux),
            v_reste - round(v_reste * v_taux), true);
  end if;

  update dates set closed_at = now(), status = 'termine' where id = d_id;

  return jsonb_build_object(
    'cloture', true,
    'impaye_cents', v_reste,
    'evaluations_disponibles', private.evaluations_disponibles(d_id));
end $fn$;

-- ---------- Eligibilite : retrait pendant le rendez-vous et impayes ----------
-- Le cahier des charges prevoit que les profils soient retires des espaces
-- de decouverte pendant toute la preparation et le deroulement du
-- rendez-vous, et qu'un compte avec impaye soit bloque.

create or replace function private.eligible_candidates(u uuid)
returns table (candidate_id uuid)
language sql stable security definer set search_path to 'public','pg_temp' as $fn$
  select p.id from profiles p
  where p.id <> u and p.is_active and p.is_verified and not are_blocked(u, p.id)
    and not exists (select 1 from reports r
                    where r.reported_id = p.id and r.status in ('nouveau','en_cours'))
    and not exists (select 1 from dates d
                    where (d.user_a = p.id or d.user_b = p.id)
                      and d.status in ('en_preparation','confirme','en_cours'))
    and not private.compte_bloque(p.id)
    and not exists (select 1 from dates d
                    where (d.user_a = u or d.user_b = u)
                      and d.status in ('en_preparation','confirme','en_cours'));
$fn$;;
