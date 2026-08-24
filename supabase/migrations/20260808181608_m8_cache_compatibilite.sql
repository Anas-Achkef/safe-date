-- =========================================================
-- M8 - Cache de compatibilite pre-calcule
-- private.compat_score parcourt les 133 paires de criteres
-- pour chaque couple : inexploitable en lecture de fil.
-- On materialise, on invalide sur changement de vecteur.
-- =========================================================

create table if not exists private.compat_cache (
  user_lo          uuid not null references public.profiles(id) on delete cascade,
  user_hi          uuid not null references public.profiles(id) on delete cascade,
  filtres_ok       boolean not null,
  score_global     numeric,
  score_physique   numeric,
  score_valeurs    numeric,
  score_mode_vie   numeric,
  score_lo_hi      numeric,
  score_hi_lo      numeric,
  criteres_evalues integer,
  affichable       boolean not null,
  vectors_stamp    timestamptz not null,
  computed_at      timestamptz not null default now(),
  primary key (user_lo, user_hi),
  constraint compat_cache_paire_ordonnee check (user_lo < user_hi)
);

alter table private.compat_cache enable row level security;

create index if not exists compat_cache_lo_score
  on private.compat_cache (user_lo, score_global desc) where affichable;
create index if not exists compat_cache_hi_score
  on private.compat_cache (user_hi, score_global desc) where affichable;

comment on table private.compat_cache is
  'Scores de compatibilite materialises, une ligne par couple ordonne. vectors_stamp porte la date du plus recent des deux vecteurs au moment du calcul : une ligne est perimee des qu''un des deux profils evolue. Aucune policy : lecture reservee aux fonctions SECURITY DEFINER.';
comment on column private.compat_cache.score_lo_hi is
  'Score directionnel de user_lo vers user_hi. Le sens compte : la compatibilite n''est pas symetrique.';

-- ---------------------------------------------------------
-- Lecture avec recalcul paresseux
-- ---------------------------------------------------------
create or replace function private.compat_cached(a uuid, b uuid)
returns private.compat_cache
language plpgsql set search_path = public, private as $$
declare
  v_lo    uuid := least(a, b);
  v_hi    uuid := greatest(a, b);
  v_stamp timestamptz;
  c       private.compat_cache;
  s       record;
begin
  select greatest(va.refreshed_at, vb.refreshed_at) into v_stamp
  from profile_vectors va, profile_vectors vb
  where va.user_id = v_lo and vb.user_id = v_hi;

  if v_stamp is null then
    return null;   -- au moins un profil n'a pas encore de vecteur
  end if;

  select * into c from private.compat_cache
   where user_lo = v_lo and user_hi = v_hi and vectors_stamp >= v_stamp;
  if found then
    return c;
  end if;

  select * into s from private.compat_score(v_lo, v_hi);

  insert into private.compat_cache as t
    (user_lo, user_hi, filtres_ok, score_global, score_physique, score_valeurs,
     score_mode_vie, score_lo_hi, score_hi_lo, criteres_evalues, affichable,
     vectors_stamp, computed_at)
  values
    (v_lo, v_hi, s.filtres_ok, s.score_global, s.score_physique, s.score_valeurs,
     s.score_mode_vie, s.score_a_vers_b, s.score_b_vers_a, s.criteres_evalues,
     s.affichable, v_stamp, now())
  on conflict (user_lo, user_hi) do update set
    filtres_ok       = excluded.filtres_ok,
    score_global     = excluded.score_global,
    score_physique   = excluded.score_physique,
    score_valeurs    = excluded.score_valeurs,
    score_mode_vie   = excluded.score_mode_vie,
    score_lo_hi      = excluded.score_lo_hi,
    score_hi_lo      = excluded.score_hi_lo,
    criteres_evalues = excluded.criteres_evalues,
    affichable       = excluded.affichable,
    vectors_stamp    = excluded.vectors_stamp,
    computed_at      = now()
  returning t.* into c;

  return c;
end $$;

comment on function private.compat_cached is
  'Recalcul paresseux : la ligne n''est recalculee que si l''un des deux vecteurs a change depuis le dernier calcul. Retourne null si un des profils n''a pas encore de vecteur.';

-- Score oriente : ce que voit l'observateur u a propos de la cible
create or replace function private.compat_pour(u uuid, cible uuid)
returns table (score numeric, filtres_ok boolean, affichable boolean,
               score_physique numeric, score_valeurs numeric, score_mode_vie numeric)
language sql set search_path = public, private as $$
  select c.score_global, c.filtres_ok, c.affichable,
         c.score_physique, c.score_valeurs, c.score_mode_vie
  from private.compat_cached(u, cible) c
  where c.user_lo is not null;
$$;

-- ---------------------------------------------------------
-- Invalidation
-- ---------------------------------------------------------
create or replace function private.invalider_compat(u uuid)
returns integer
language plpgsql as $$
declare n integer;
begin
  delete from private.compat_cache where user_lo = u or user_hi = u;
  get diagnostics n = row_count;
  return n;
end $$;

create or replace function private.trg_invalider_compat()
returns trigger
language plpgsql as $$
begin
  perform private.invalider_compat(new.user_id);
  return new;
end $$;

drop trigger if exists trg_profile_vectors_invalide_compat on public.profile_vectors;
create trigger trg_profile_vectors_invalide_compat
  after insert or update on public.profile_vectors
  for each row execute function private.trg_invalider_compat();

comment on function private.invalider_compat is
  'Purge toutes les paires impliquant un utilisateur. Declenchee automatiquement des que son vecteur de profil est recalcule : le cache ne peut pas servir un score perime.';

-- ---------------------------------------------------------
-- Rechauffage par lots (appele par le cron)
-- ---------------------------------------------------------
create or replace function private.rechauffer_compat(p_lot integer default 200)
returns integer
language plpgsql set search_path = public, private as $$
declare n integer := 0; r record;
begin
  for r in
    select va.user_id as a, vb.user_id as b
    from profile_vectors va
    join profile_vectors vb on vb.user_id > va.user_id
    join public.profiles pa on pa.id = va.user_id and pa.is_active
    join public.profiles pb on pb.id = vb.user_id and pb.is_active
    left join private.compat_cache c
      on c.user_lo = va.user_id and c.user_hi = vb.user_id
     and c.vectors_stamp >= greatest(va.refreshed_at, vb.refreshed_at)
    where c.user_lo is null
    limit p_lot
  loop
    perform private.compat_cached(r.a, r.b);
    n := n + 1;
  end loop;
  return n;
end $$;

comment on function private.rechauffer_compat is
  'Calcule par lots bornes les paires manquantes ou perimees, pour que la lecture du fil trouve toujours un score deja pret.';

select cron.schedule(
  'safedate-compat-warm',
  '*/5 * * * *',
  $cron$select private.rechauffer_compat(200);$cron$
);;
