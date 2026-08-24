-- =========================================================
-- M8 - Distinction cadrage / dealbreaker
-- Les filtres absolus ne sont pas de meme nature :
--  - cadrage      : retire du fil (genre, orientation)
--  - dealbreaker  : profil visible, bouton desactive
-- =========================================================

alter table public.criterion_pairs
  add column if not exists filtre_cadrage boolean not null default false;

comment on column public.criterion_pairs.filtre_cadrage is
  'Parmi les criteres absolus, distingue le cadrage du dealbreaker. Le cadrage retire le profil du fil : personne ne veut faire defiler des profils du genre qu''il ne cherche pas. Le dealbreaker laisse le profil visible mais desactive la proposition de conversation. Reversible sans migration : il suffit de basculer ce booleen.';

update public.criterion_pairs
   set filtre_cadrage = true
 where pair_key in ('genre','db_sex_or');

-- ---------------------------------------------------------
-- Verdict de cadrage : le profil doit-il apparaitre du tout ?
-- ---------------------------------------------------------
create or replace function private.cadrage_ok(a uuid, b uuid)
returns boolean
language sql stable set search_path = public, private as $$
  with va as (select * from profile_vectors where user_id = a),
       vb as (select * from profile_vectors where user_id = b)
  select coalesce(bool_and(
    case
      when va.pref_mask[p.slot+1] is not null and vb.self_mask[p.slot+1] is not null
           and (vb.self_mask[p.slot+1] & va.pref_mask[p.slot+1]) = 0 then false
      when vb.pref_mask[p.slot+1] is not null and va.self_mask[p.slot+1] is not null
           and (va.self_mask[p.slot+1] & vb.pref_mask[p.slot+1]) = 0 then false
      else true
    end), true)
  from criterion_pairs p, va, vb
  where p.is_absolute and p.filtre_cadrage;
$$;

comment on function private.cadrage_ok is
  'Vrai si les deux profils sont mutuellement dans le cadre de recherche de l''autre. Faux retire le profil du fil, sans notification ni trace visible.';

-- ---------------------------------------------------------
-- Motifs de dealbreaker, pour expliquer un bouton grise
-- sans rien reveler du profil cible
-- ---------------------------------------------------------
create or replace function private.dealbreakers_bloquants(a uuid, b uuid)
returns text[]
language sql stable set search_path = public, private as $$
  with va as (select * from profile_vectors where user_id = a),
       vb as (select * from profile_vectors where user_id = b)
  select coalesce(array_agg(p.pair_key order by p.pair_key), '{}')
  from criterion_pairs p, va, vb
  where p.is_absolute and not p.filtre_cadrage
    and (
      (va.pref_mask[p.slot+1] is not null and vb.self_mask[p.slot+1] is not null
       and (vb.self_mask[p.slot+1] & va.pref_mask[p.slot+1]) = 0)
      or
      (vb.pref_mask[p.slot+1] is not null and va.self_mask[p.slot+1] is not null
       and (va.self_mask[p.slot+1] & vb.pref_mask[p.slot+1]) = 0)
    );
$$;

comment on function private.dealbreakers_bloquants is
  'Reserve a l''usage interne et au support. Ne jamais renvoyer tel quel a l''emetteur : la liste des criteres bloquants permettrait de reconstituer les reponses du profil cible.';;
