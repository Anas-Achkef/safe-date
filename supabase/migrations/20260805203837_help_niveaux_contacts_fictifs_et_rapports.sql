-- Une analyse de securite peut rester ouverte apres l'incident : tant
-- qu'elle n'est pas close, aucun profil de remplacement n'est propose.
alter table help_requests add column analyse_terminee_at timestamptz;
alter table help_requests add column mesure_prise text;

-- Contacts fictifs predefinis par Safe Date, pour garantir une
-- presentation coherente et credible.
insert into fake_contacts (genre, prenom, message_template) values
('homme','Julien','Salut ! Désolé de te déranger mais j''ai vraiment besoin de toi. Est-ce que tu peux me rejoindre rapidement ? C''est urgent. Je t''ai envoyé ma position.'),
('homme','Maxime','Salut ! Désolé de te déranger mais j''ai vraiment besoin de toi. Est-ce que tu peux me rejoindre rapidement ? C''est urgent. Je t''ai envoyé ma position.'),
('femme','Sarah','Salut ! Désolée de te déranger mais j''ai vraiment besoin de toi. Est-ce que tu peux me rejoindre rapidement ? C''est urgent. Je t''ai envoyé ma position.'),
('femme','Camille','Salut ! Désolée de te déranger mais j''ai vraiment besoin de toi. Est-ce que tu peux me rejoindre rapidement ? C''est urgent. Je t''ai envoyé ma position.');

-- Le contact affiche reprend le genre de l'utilisateur : un homme voit
-- un contact masculin, une femme un contact feminin.
create or replace function private.contact_fictif(u uuid)
returns uuid language sql stable as $fn$
  select f.id from fake_contacts f
  where f.active
    and f.genre = coalesce((
      select case when a.option_idx[1] = 0 then 'homme'
                  when a.option_idx[1] = 1 then 'femme' end
      from profile_answers a where a.user_id = u and a.criterion_key = 'genre_moi'), 'femme')
  order by random() limit 1;
$fn$;

-- ---------- Declenchement ----------

create or replace function private.declencher_help(u uuid, d_id uuid, niveau help_level)
returns jsonb language plpgsql as $fn$
declare d dates; v_id uuid; v_contact uuid; v_msg text; v_prenom text;
begin
  select * into d from dates where id = d_id and (user_a = u or user_b = u);
  if d is null then
    raise exception 'Rendez-vous introuvable' using errcode = 'no_data_found';
  end if;

  if niveau = 'discret' then
    v_contact := private.contact_fictif(u);
    select prenom, message_template into v_prenom, v_msg
      from fake_contacts where id = v_contact;
  end if;

  insert into help_requests (date_id, user_id, level, fake_contact_id, partner_notified_at)
  values (d_id, u, niveau, v_contact,
          case when niveau in ('etablissement','angela','urgence') then now() end)
  returning id into v_id;

  -- L'autre utilisateur n'est jamais informe, et l'etablissement ne
  -- recoit jamais la nature exacte de la demande.
  return jsonb_build_object(
    'demande_id', v_id,
    'niveau', niveau,
    'contact_fictif', case when v_contact is not null
                      then jsonb_build_object('prenom', v_prenom, 'message', v_msg) end,
    'etablissement_notifie', niveau in ('etablissement','angela','urgence'),
    'partenaire_informe', false);
end $fn$;

comment on function private.declencher_help is
  'Quatre niveaux : assistance discrete (contact fictif), demande a l''etablissement, mot-cle Angela, urgence. L''autre utilisateur n''en est jamais informe.';

-- ---------- Rapport confidentiel de l'utilisateur ----------

create or replace function private.rapport_help_utilisateur(
  u uuid, help_id uuid, p_raison text, p_recit text default null,
  p_comportement text default null, p_ressenti text default null,
  p_complement text default null)
returns void language plpgsql as $fn$
declare h help_requests;
begin
  select * into h from help_requests where id = help_id and user_id = u;
  if h is null then
    raise exception 'Demande introuvable' using errcode = 'no_data_found';
  end if;
  if not private.evaluations_disponibles(h.date_id) then
    raise exception 'Formulaire disponible une fois éloigné de l''établissement'
      using errcode = 'check_violation';
  end if;

  insert into help_user_reports (help_request_id, user_id, raison, recit,
                                 comportement, ressenti, complement)
  values (help_id, u, p_raison, p_recit, p_comportement, p_ressenti, p_complement)
  on conflict (help_request_id) do update set
    raison = excluded.raison, recit = excluded.recit,
    comportement = excluded.comportement, ressenti = excluded.ressenti,
    complement = excluded.complement, submitted_at = now();
end $fn$;

-- ---------- Rapport obligatoire du personnel ----------

create or replace function private.rapport_help_personnel(
  p_help uuid, p_staff text, p_table text, p_circonstances text,
  p_faits text, p_actions text, p_depart_accompagne boolean,
  p_secours boolean, p_dangerosite smallint, p_observations text default null)
returns uuid language plpgsql as $fn$
declare v_partner uuid; v_id uuid;
begin
  select d.partner_id into v_partner
    from help_requests h join dates d on d.id = h.date_id where h.id = p_help;
  if v_partner is null then
    raise exception 'Demande introuvable' using errcode = 'no_data_found';
  end if;
  if p_dangerosite not between 1 and 5 then
    raise exception 'La note de dangerosité doit être comprise entre 1 et 5'
      using errcode = 'check_violation';
  end if;

  insert into help_staff_reports (help_request_id, partner_id, staff_identifiant,
    table_number, circonstances, faits, actions, depart_accompagne,
    secours_appeles, dangerosite, observations)
  values (p_help, v_partner, p_staff, p_table, p_circonstances, p_faits,
          p_actions, p_depart_accompagne, p_secours, p_dangerosite, p_observations)
  returning id into v_id;
  return v_id;
end $fn$;

comment on function private.rapport_help_personnel is
  'Rapport d''intervention obligatoire au titre du contrat de partenariat. Le personnel relate des faits objectifs ; la note de dangerosite reste strictement confidentielle et n''est jamais communiquee aux utilisateurs.';

-- ---------- Signalements repetes ----------

create or replace view private.v_utilisateurs_signales_multi as
  select d.user_a as user_id, count(*) as interventions,
         max(r.dangerosite) as dangerosite_max,
         count(distinct r.partner_id) as etablissements
  from help_staff_reports r
  join help_requests h on h.id = r.help_request_id
  join dates d on d.id = h.date_id
  where d.user_a <> h.user_id
  group by d.user_a
  having count(distinct r.partner_id) > 1
  union all
  select d.user_b, count(*), max(r.dangerosite), count(distinct r.partner_id)
  from help_staff_reports r
  join help_requests h on h.id = r.help_request_id
  join dates d on d.id = h.date_id
  where d.user_b <> h.user_id
  group by d.user_b
  having count(distinct r.partner_id) > 1;

comment on view private.v_utilisateurs_signales_multi is
  'Utilisateurs concernes par des interventions dans plusieurs etablissements distincts. Declenche une analyse renforcee du compte.';;
