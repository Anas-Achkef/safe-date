insert into engine_params (key, value, description) values
  ('refus_reproposition_jours', 60, 'Delai avant qu''un profil refuse puisse etre repropose'),
  ('rayon_mobilite_partagee',    1, 'Si 1, la distance acceptable est la somme des rayons des deux utilisateurs (mobilite simultanee)')
on conflict (key) do nothing;

-- Feed de l'onglet "Partir en Date" : profils recommandes a un utilisateur.
create or replace function compat_candidates(p_user uuid, p_limit integer default 20)
returns table (
  candidate_id uuid,
  taux         numeric,
  score_ab     numeric,
  score_ba     numeric,
  distance_m   double precision,
  disponible   boolean,
  floute       boolean
)
language sql stable as $$
with prm as (
  select max(value) filter (where key = 'seuil_premium')             as seuil_premium,
         max(value) filter (where key = 'refus_reproposition_jours') as refus_jours,
         max(value) filter (where key = 'rayon_mobilite_partagee')   as mobilite
  from engine_params
),
moi as (select * from profiles where id = p_user),
candidats as (
  select c.id,
         st_distance(m.last_location, c.last_location) as dist,
         (c.always_available
          or exists (select 1 from availability_windows w
                     where w.user_id = c.id and now() between w.debut and w.fin)) as dispo
  from profiles c cross join moi m cross join prm
  where c.id <> p_user
    and c.is_active
    and c.is_verified
    -- tranches d'age respectees dans les deux sens
    and extract(year from age(c.birth_date)) between m.age_min and m.age_max
    and extract(year from age(m.birth_date)) between c.age_min and c.age_max
    -- portee geographique
    and (m.last_location is null or c.last_location is null
         or st_dwithin(m.last_location, c.last_location,
              1000 * (m.search_radius_km + case when prm.mobilite = 1 then c.search_radius_km else 0 end)))
    -- blocages dans un sens ou dans l'autre
    and not exists (select 1 from blocks b
                    where (b.blocker_id = p_user and b.blocked_id = c.id)
                       or (b.blocker_id = c.id and b.blocked_id = p_user))
    -- profil ecarte recemment
    and not exists (select 1 from swipe_decisions s
                    where s.user_id = p_user and s.target_id = c.id
                      and s.decision = false
                      and s.created_at > now() - (prm.refus_jours || ' days')::interval)
    -- indisponible pendant tout le cycle d'un rendez-vous
    and not exists (select 1 from dates d
                    where (d.user_a = c.id or d.user_b = c.id)
                      and d.status in ('en_preparation','confirme','en_cours'))
    -- dette impayee : compte bloque
    and not exists (select 1 from outstanding_debts o
                    where o.user_id = c.id and o.settled_at is null)
)
select c.id, s.taux, s.score_ab, s.score_ba, c.dist, c.dispo,
       (s.taux >= prm.seuil_premium and not moi.is_premium)
from candidats c
cross join moi
cross join prm
cross join lateral compat_mutual(p_user, c.id) s
where s.taux is not null
  and not s.exclu
order by c.dispo desc, s.taux desc, c.dist asc nulls last
limit p_limit;
$$;

comment on function compat_candidates is 'Profils recommandes dans l''onglet Partir en Date. Les profils au-dela de seuil_premium sont marques comme floutes pour les utilisateurs non abonnes. La portee geographique tient compte de la mobilite des deux utilisateurs.';;
