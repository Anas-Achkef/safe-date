-- =========================================================
-- M9.4 - Couverture, exploration et exploitation
-- =========================================================

insert into public.engine_params (key, value, description) values
  ('expl_taux_initial',      0.85, 'Part d''exploration chez un utilisateur dont on ne sait rien.'),
  ('expl_taux_plancher',     0.20, 'Part d''exploration conservee meme chez un utilisateur tres bien connu. Ne descend jamais a zero : sans exploration, le moteur cesse de verifier ses propres hypotheses.'),
  ('expl_maturite_swipes',    500, 'Nombre de swipes d''apprentissage au terme duquel la part d''exploration atteint son plancher.'),
  ('expl_confiance_acquise', 0.80, 'Confiance au-dela de laquelle un critere est considere comme suffisamment documente.'),
  ('expl_proba_retest',      0.05, 'Probabilite de reexposer un critere deja bien connu. Une preference forte peut evoluer : ne plus jamais la tester reviendrait a la figer.'),
  ('expl_plancher_attendu',  0.15, 'Acceptation attendue en dessous de laquelle un profil cesse d''etre propose a un utilisateur mature.')
on conflict (key) do nothing;

create or replace function private.couverture_criteres(u uuid)
returns table (criterion_key text, grp public.score_group, libelle text,
               observations integer, confiance numeric, documente boolean)
language sql stable set search_path = public, private as $$
  select c.key, cp.grp, c.question,
         coalesce(p.observations, 0),
         coalesce(p.confiance, 0),
         coalesce(p.confiance, 0) >= private.engine_param('expl_confiance_acquise')
  from public.criteria c
  join public.criterion_pairs cp on cp.pair_key = c.pair_key
  left join public.user_criterion_profile p on p.user_id = u and p.criterion_key = c.key
  where c.direction = 'self'
    and (private.engine_param('appr_criteres_sensibles') >= 1 or c.sensitive_category is null)
  order by coalesce(p.observations, 0) asc, cp.grp;
$$;

comment on function private.couverture_criteres is
  'Etat de connaissance critere par critere. Comparer un critere a deux mille observations avec un critere a trois n''a aucun sens : c''est cette lecture qui permet d''eviter cette faute.';

create or replace function private.taux_exploration(u uuid)
returns numeric
language sql stable set search_path = public, private as $$
  select round(greatest(
    private.engine_param('expl_taux_plancher'),
    private.engine_param('expl_taux_initial')
    - (private.engine_param('expl_taux_initial') - private.engine_param('expl_taux_plancher'))
      * least(1.0, (select count(*) from public.swipe_decisions
                    where user_id = u and contexte = 'mieux_me_connaitre')::numeric
                   / nullif(private.engine_param('expl_maturite_swipes'), 0))
  ), 3);
$$;

comment on function private.taux_exploration is
  'Decroit avec l''experience mais ne s''annule jamais. Un moteur qui cesse d''explorer ne verifie plus si l''utilisateur aime reellement ce qu''on lui montre, ou si on ne lui a simplement montre que cela.';

create or replace function private.evaluer_candidats(u uuid, p_ids uuid[])
returns table (profil_id uuid, besoin numeric, attendu numeric, inedit numeric)
language sql stable set search_path = public, private as $$
  with sensible as (select private.engine_param('appr_criteres_sensibles') >= 1 as ok),
  reps as (
    select pa.user_id as cible, pa.criterion_key, o.idx as option_idx
    from public.profile_answers pa
    join public.criteria c on c.key = pa.criterion_key and c.direction = 'self'
    cross join lateral unnest(pa.option_idx) as o(idx)
    cross join sensible s
    where pa.user_id = any (p_ids) and (s.ok or c.sensitive_category is null)
  )
  select r.cible,
         round(avg(1 - coalesce(pr.confiance, 0)), 4),
         round(coalesce(
           sum(coalesce(os.poids_oui / nullif(os.poids, 0), 0.5)
               * coalesce(pr.importance, 0) * coalesce(pr.confiance, 0))
           / nullif(sum(coalesce(pr.importance, 0) * coalesce(pr.confiance, 0)), 0),
           0.5), 4),
         round(avg(case when coalesce(os.observations, 0) = 0 then 1 else 0 end), 4)
  from reps r
  left join public.user_criterion_profile pr
         on pr.user_id = u and pr.criterion_key = r.criterion_key
  left join public.user_option_stats os
         on os.user_id = u and os.criterion_key = r.criterion_key and os.option_idx = r.option_idx
  group by r.cible;
$$;

comment on function private.evaluer_candidats is
  'besoin mesure l''ignorance du moteur, attendu la probabilite d''acceptation. Le premier sert l''exploration, le second l''exploitation. attendu vaut 0,5 par defaut : sans connaissance, aucune prediction n''est faite.';

create function private.fil_apprentissage(u uuid, p_taille integer default 20)
returns table (profil_id uuid, prenom text, age integer,
               photo_principale text, profil_verifie boolean,
               besoin numeric, attendu numeric, motif text)
language plpgsql set search_path = public, private as $$
declare
  v_eps      numeric := private.taux_exploration(u);
  v_plancher numeric := private.engine_param('expl_plancher_attendu');
  v_retest   numeric := private.engine_param('expl_proba_retest');
  v_mature   boolean := v_eps <= private.engine_param('expl_taux_plancher') + 0.001;
  v_pool     uuid[];
begin
  select array_agg(x.id) into v_pool
  from (
    select c.id
    from public.profiles c
    where c.id <> u and c.is_active
      and exists (select 1 from public.profile_vectors v where v.user_id = c.id)
      and not public.are_blocked(u, c.id)
      and not exists (
        select 1 from public.swipe_decisions s
        where s.user_id = u and s.target_id = c.id and s.contexte = 'mieux_me_connaitre')
    order by random()
    limit greatest(p_taille * 10, 200)
  ) x;

  if v_pool is null then return; end if;

  return query
  select p.id, p.prenom, h.age, h.photo_principale, h.profil_verifie,
         e.besoin, e.attendu,
         case when e.inedit > 0.3 then 'criteres inedits'
              when e.besoin  > 0.6 then 'critere mal connu'
              when e.attendu > 0.7 then 'forte affinite attendue'
              else 'equilibrage' end
  from private.evaluer_candidats(u, v_pool) e
  join public.profiles p on p.id = e.profil_id
  cross join lateral private.profile_header(p.id) h
  where not (v_mature and e.attendu < v_plancher and random() > v_retest)
  order by v_eps * (e.besoin + e.inedit) / 2
         + (1 - v_eps) * e.attendu
         + random() * 0.12
         desc
  limit p_taille;
end $$;

comment on function private.fil_apprentissage is
  'Ni distance, ni type de rencontre, ni disponibilite : un profil est retenu pour ce qu''il apprend au moteur, pas parce qu''on pourrait le rencontrer. L''ordre combine exploration et exploitation selon la maturite de l''utilisateur, avec une part d''aleatoire qui empeche d''en deviner la regle.';

create function public.fil_apprentissage(taille integer default 20)
returns table (profil_id uuid, prenom text, age integer,
               photo_principale text, profil_verifie boolean,
               besoin numeric, attendu numeric, motif text)
language plpgsql security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.fil_apprentissage(auth.uid(), taille);
end $$;

create or replace function public.couverture_criteres()
returns table (criterion_key text, grp public.score_group, libelle text,
               observations integer, confiance numeric, documente boolean)
language plpgsql stable security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.couverture_criteres(auth.uid());
end $$;

revoke all on function public.fil_apprentissage(integer) from public;
revoke all on function public.couverture_criteres() from public;
grant execute on function public.fil_apprentissage(integer) to authenticated;
grant execute on function public.couverture_criteres() to authenticated;;
