alter table profiles add column if not exists prenom text;

update profiles set prenom = 'Camille' where id = 'd0000000-0000-4000-8000-000000000001';
update profiles set prenom = 'Théo'    where id = 'd0000000-0000-4000-8000-000000000002';
update profiles set prenom = 'Inès'    where id = 'd0000000-0000-4000-8000-000000000003';
update profiles set prenom = 'Alex'    where id = 'd0000000-0000-4000-8000-00000000000a';

create or replace function private.candidate_highlights(u uuid, autre uuid, n int default 3)
returns table (question text, reponse text, grp score_group)
language sql stable security definer set search_path = public, pg_temp as $$
  select c.question, o.label, p.grp
  from criterion_pairs p
  join criteria c on c.key = p.self_key
  join profile_answers a on a.user_id = autre and a.criterion_key = p.self_key
  join criterion_options o on o.criterion_key = p.self_key and o.idx = a.option_idx[1]
  join profile_vectors va on va.user_id = u
  join profile_vectors vb on vb.user_id = autre
  where not p.is_absolute
    and c.sensitive_category is null
    and va.pref_mask[p.slot+1] is not null
    and vb.self_mask[p.slot+1] is not null
    and (vb.self_mask[p.slot+1] & va.pref_mask[p.slot+1]) <> 0
    and va.weight_mul[p.slot+1] > 0
  order by va.weight_mul[p.slot+1] desc, c.ord
  limit n;
$$;
revoke all on function private.candidate_highlights(uuid, uuid, int) from public;

create or replace function private.candidate_cards(u uuid)
returns table (
  candidate_id uuid, prenom text, age int, photo text, verifie boolean,
  score_global numeric, score_physique numeric, score_valeurs numeric,
  score_mode_vie numeric, score_aller numeric, score_retour numeric,
  criteres_evalues int, filtres_ok boolean, affichable boolean,
  au_dela_du_seuil boolean, highlights jsonb)
language sql stable security definer set search_path = public, pg_temp as $$
  select
    p.id, p.prenom,
    extract(year from age(current_date, p.birth_date))::int,
    (select ph.storage_path from user_photos ph
      where ph.user_id = p.id and ph.is_primary and ph.moderation <> 'rejetee'),
    p.is_verified,
    s.score_global, s.score_physique, s.score_valeurs, s.score_mode_vie,
    s.score_a_vers_b, s.score_b_vers_a, s.criteres_evalues,
    s.filtres_ok, s.affichable,
    coalesce(s.score_global, 0) >= private.engine_param('seuil_premium'),
    coalesce((select jsonb_agg(jsonb_build_object('question', h.question,
                                                  'reponse', h.reponse,
                                                  'groupe', h.grp))
              from private.candidate_highlights(u, p.id, 3) h), '[]'::jsonb)
  from private.eligible_candidates(u) c
  join profiles p on p.id = c.candidate_id
  cross join lateral private.compat_score(u, p.id) s
  order by s.score_global desc nulls last;
$$;
revoke all on function private.candidate_cards(uuid) from public;

create or replace function candidate_cards()
returns table (
  candidate_id uuid, prenom text, age int, photo text, verifie boolean,
  score_global numeric, score_physique numeric, score_valeurs numeric,
  score_mode_vie numeric, score_aller numeric, score_retour numeric,
  criteres_evalues int, filtres_ok boolean, affichable boolean,
  au_dela_du_seuil boolean, highlights jsonb)
language plpgsql stable security definer set search_path = public, pg_temp as $$
declare premium boolean; voile boolean;
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  select coalesce(is_premium,false) into premium from profiles where id = auth.uid();

  return query
  select k.candidate_id,
    case when k.au_dela_du_seuil and not premium then null else k.prenom end,
    k.age,
    case when k.au_dela_du_seuil and not premium then null else k.photo end,
    k.verifie,
    case when k.au_dela_du_seuil and not premium then null else k.score_global end,
    case when k.au_dela_du_seuil and not premium then null else k.score_physique end,
    case when k.au_dela_du_seuil and not premium then null else k.score_valeurs end,
    case when k.au_dela_du_seuil and not premium then null else k.score_mode_vie end,
    case when k.au_dela_du_seuil and not premium then null else k.score_aller end,
    case when k.au_dela_du_seuil and not premium then null else k.score_retour end,
    k.criteres_evalues, k.filtres_ok, k.affichable, k.au_dela_du_seuil,
    case when k.au_dela_du_seuil and not premium then '[]'::jsonb else k.highlights end
  from private.candidate_cards(auth.uid()) k;
end $$;

comment on function candidate_cards is
  'Point d''entree unique de l''ecran Decouverte. Rejoue le filtre d''eligibilite '
  'plutot que de faire confiance a l''appelant. Au-dela du seuil premium, le '
  'prenom, la photo et les scores sont mis a NULL cote serveur : l''identite ne '
  'quitte pas la base tant que l''abonnement n''est pas actif. Le voile n''est '
  'donc pas contournable en inspectant la reponse reseau.';;
