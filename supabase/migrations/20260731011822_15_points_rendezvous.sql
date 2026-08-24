create extension if not exists postgis;
insert into engine_params (key, value, description) values
  ('point_rdv_dist_min',60,'Distance minimale entre un point de rendez-vous et l''etablissement, en metres'),
  ('point_rdv_dist_max',100,'Distance maximale entre un point de rendez-vous et l''etablissement, en metres'),
  ('point_rdv_ecart_min',100,'Distance minimale entre les deux points de rendez-vous, en metres'),
  ('point_rdv_tentatives',400,'Nombre de candidats tires avant echec declare'),
  ('arrivee_tolerance_min',10,'Tolerance d''arrivee en minutes'),
  ('revelation_rayon_m',25,'Rayon dans lequel l''utilisateur est repute arrive a son point')
on conflict (key) do nothing;
alter table partners add column location geography(point, 4326);
create table partner_safe_zones (
  id uuid primary key default gen_random_uuid(),
  partner_id uuid not null references partners(id) on delete cascade,
  label text not null, zone geography(polygon, 4326) not null,
  validated boolean not null default false, created_at timestamptz not null default now());
create index on partner_safe_zones using gist (zone);
create index on partner_safe_zones (partner_id) where validated;
create or replace function trg_zone_utile() returns trigger language plpgsql as $$
declare loc geography; d_min numeric; d_max numeric; couronne geography;
begin
  select location into loc from partners where id = new.partner_id;
  if loc is null then
    raise exception 'L''établissement n''a pas de localisation enregistrée' using errcode='check_violation';
  end if;
  d_min := private.engine_param('point_rdv_dist_min');
  d_max := private.engine_param('point_rdv_dist_max');
  couronne := ST_Difference(ST_Buffer(loc,d_max)::geometry, ST_Buffer(loc,d_min)::geometry)::geography;
  if not ST_Intersects(new.zone, couronne) then
    raise exception 'Cette zone ne recoupe pas la couronne de % à % mètres autour de l''établissement.', d_min, d_max
      using errcode='check_violation';
  end if;
  return new;
end $$;
create trigger safe_zones_utile before insert or update of zone on partner_safe_zones
for each row execute function trg_zone_utile();
create type date_status as enum ('en_preparation','confirme','en_cours','termine','annule');
create table dates (
  id uuid primary key default gen_random_uuid(),
  user_a uuid not null references profiles(id) on delete cascade,
  user_b uuid not null references profiles(id) on delete cascade,
  partner_id uuid not null references partners(id),
  creneau_debut timestamptz not null,
  status date_status not null default 'en_preparation',
  created_at timestamptz not null default now(), check (user_a <> user_b));
create table date_meeting_points (
  date_id uuid not null references dates(id) on delete cascade,
  user_id uuid not null references profiles(id) on delete cascade,
  point geography(point, 4326) not null, arrivee_at timestamptz not null,
  expires_at timestamptz not null, revealed_at timestamptz,
  primary key (date_id, user_id));
create index on date_meeting_points using gist (point);
create or replace function private.generate_meeting_points(d_id uuid, arrivee timestamptz default null)
returns table (utilisateur uuid, lat double precision, lon double precision, ecart_m numeric)
language plpgsql as $$
declare d dates; loc geography; d_min numeric; d_max numeric; ecart_min numeric; n_tir int;
  zones geometry; p1 geography; p2 geography; ecart numeric; t_arrivee timestamptz;
begin
  select * into d from dates where id = d_id;
  if d is null then raise exception 'Rendez-vous introuvable'; end if;
  select location into loc from partners where id = d.partner_id;
  if loc is null then
    raise exception 'L''établissement n''a pas de localisation enregistrée' using errcode='check_violation';
  end if;
  d_min := private.engine_param('point_rdv_dist_min');
  d_max := private.engine_param('point_rdv_dist_max');
  ecart_min := private.engine_param('point_rdv_ecart_min');
  n_tir := private.engine_param('point_rdv_tentatives');
  select ST_Union(zone::geometry) into zones
  from partner_safe_zones where partner_id = d.partner_id and validated;
  if zones is null then
    raise exception 'Aucune zone praticable validée pour cet établissement.' using errcode='no_data_found';
  end if;
  with cand as (select (ST_Dump(ST_GeneratePoints(zones, n_tir))).geom::geography as p),
  valides as (select p, ST_Distance(p, loc) as r from cand where ST_Distance(p, loc) between d_min and d_max),
  couples as (select a.p as pa, b.p as pb, ST_Distance(a.p,b.p) as e
    from valides a join valides b on a.p::text < b.p::text
    where ST_Distance(a.p,b.p) >= ecart_min order by e desc limit 1)
  select pa, pb, e into p1, p2, ecart from couples;
  if p1 is null then
    raise exception 'Aucun couple de points conforme après % tirages. Zones trop étroites pour respecter la couronne %–% m et l''écart de % m.',
      n_tir, d_min, d_max, ecart_min using errcode='no_data_found';
  end if;
  t_arrivee := coalesce(arrivee, d.creneau_debut);
  insert into date_meeting_points (date_id, user_id, point, arrivee_at, expires_at)
  values (d_id, d.user_a, p1, t_arrivee, t_arrivee + interval '3 hours'),
         (d_id, d.user_b, p2, t_arrivee, t_arrivee + interval '3 hours')
  on conflict (date_id, user_id) do update set point=excluded.point, arrivee_at=excluded.arrivee_at,
    expires_at=excluded.expires_at, revealed_at=null;
  update dates set status='confirme' where id = d_id;
  return query select m.user_id, ST_Y(m.point::geometry), ST_X(m.point::geometry), ecart
  from date_meeting_points m where m.date_id = d_id;
end $$;
create or replace function diagnostic_zones(p_id uuid)
returns table (zones_validees int, points_possibles int, couple_possible boolean, ecart_max_m numeric)
language plpgsql as $$
declare loc geography; zones geometry; d_min numeric; d_max numeric; ecart_min numeric;
begin
  select location into loc from partners where id = p_id;
  d_min := private.engine_param('point_rdv_dist_min');
  d_max := private.engine_param('point_rdv_dist_max');
  ecart_min := private.engine_param('point_rdv_ecart_min');
  select ST_Union(zone::geometry) into zones from partner_safe_zones where partner_id=p_id and validated;
  if loc is null or zones is null then return query select 0,0,false,0::numeric; return; end if;
  return query
  with cand as (select (ST_Dump(ST_GeneratePoints(zones,400))).geom::geography as p),
  valides as (select p from cand where ST_Distance(p,loc) between d_min and d_max),
  meilleurs as (select max(ST_Distance(a.p,b.p)) as e from valides a join valides b on a.p::text < b.p::text)
  select (select count(*)::int from partner_safe_zones where partner_id=p_id and validated),
    (select count(*)::int from valides),
    coalesce((select e from meilleurs),0) >= ecart_min,
    round(coalesce((select e from meilleurs),0)::numeric,1);
end $$;
create or replace function private.reveal_establishment(d_id uuid, u uuid, position_actuelle geography)
returns table (nom text, adresse text, code_postal text, ville text)
language plpgsql as $$
declare mp date_meeting_points; rayon numeric; dist numeric;
begin
  select * into mp from date_meeting_points where date_id = d_id and user_id = u;
  if mp is null then raise exception 'Aucun point de rendez-vous attribué' using errcode='no_data_found'; end if;
  if now() > mp.expires_at then raise exception 'Ce point de rendez-vous a expiré' using errcode='check_violation'; end if;
  rayon := private.engine_param('revelation_rayon_m');
  dist := ST_Distance(position_actuelle, mp.point);
  if dist > rayon then
    raise exception 'Vous êtes encore à % mètres de votre point de rendez-vous.', round(dist)
      using errcode='check_violation';
  end if;
  update date_meeting_points set revealed_at = coalesce(revealed_at, now())
   where date_id = d_id and user_id = u;
  update dates set status='en_cours' where id = d_id and status='confirme';
  return query select p.nom_commercial, p.adresse, p.code_postal, p.ville
  from dates d join partners p on p.id = d.partner_id where d.id = d_id;
end $$;
create or replace function expirer_points_rendezvous() returns int language sql as $$
  with sup as (delete from date_meeting_points m using dates d
    where d.id = m.date_id and (d.status in ('termine','annule') or now() > m.expires_at) returning 1)
  select count(*)::int from sup;
$$;
alter table date_meeting_points enable row level security;
alter table dates enable row level security;
create policy p_mp_self on date_meeting_points for select using (user_id = auth.uid());
create policy p_dates_self on dates for select using (user_a = auth.uid() or user_b = auth.uid());
create or replace function reveal_establishment(d_id uuid, position_actuelle geography)
returns table (nom text, adresse text, code_postal text, ville text)
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  return query select * from private.reveal_establishment(d_id, auth.uid(), position_actuelle);
end $$;;
