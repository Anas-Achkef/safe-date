-- =========================================================
-- M9.2 - Contexte comportemental du swipe
-- Un swipe n'est pas une donnee isolee. Ce qui compte n'est
-- pas seulement la decision, mais comment elle a ete prise :
-- quel ecran, combien de temps, combien de fois, dans quel
-- ordre, avec quels retours.
-- =========================================================

alter table public.swipe_decisions
  add column if not exists duree_totale_ms   integer,
  add column if not exists ordre_consultation public.score_group[],
  add column if not exists retours           smallint not null default 0,
  add column if not exists criteres_exposes  text[],
  add column if not exists criteres_consultes text[],
  add column if not exists attention_physique numeric(4,3),
  add column if not exists attention_mode_vie numeric(4,3),
  add column if not exists attention_valeurs  numeric(4,3),
  add column if not exists fiabilite_attention numeric(4,3),
  add column if not exists snapshot          jsonb;

comment on column public.swipe_decisions.ordre_consultation is
  'Ordre reel de consultation des sections. Aller droit aux valeurs et ne jamais revenir a la photo ne dit pas la meme chose que l''inverse.';
comment on column public.swipe_decisions.criteres_exposes is
  'Criteres reellement affiches sur le profil au moment du swipe. Un critere absent ne peut pas avoir influence la decision.';
comment on column public.swipe_decisions.criteres_consultes is
  'Sous-ensemble reellement consulte. Etre visible n''est pas etre regarde : c''est toute la difference entre exposition et attention.';
comment on column public.swipe_decisions.fiabilite_attention is
  'Confiance accordee a la repartition d''attention. Un profil balaye en deux secondes produit une repartition sans valeur, meme si elle est calculable.';
comment on column public.swipe_decisions.snapshot is
  'Etat du profil au moment du swipe. Sans cela, un profil modifie ensuite rendrait la decision passee inexplicable.';

-- ---------------------------------------------------------
-- Detail par section
-- ---------------------------------------------------------
create table if not exists public.swipe_ecrans (
  swipe_id      bigint not null references public.swipe_decisions(id) on delete cascade,
  ecran         public.score_group not null,
  duree_ms      integer not null default 0,
  consultations smallint not null default 1,
  primary key (swipe_id, ecran),
  constraint swipe_ecrans_duree_positive check (duree_ms >= 0),
  constraint swipe_ecrans_consultations_positives check (consultations >= 0)
);

alter table public.swipe_ecrans enable row level security;

comment on table public.swipe_ecrans is
  'Une ligne par section consultee lors d''un swipe. Aucune policy : la lecture passe par les fonctions private.';

-- ---------------------------------------------------------
-- Repartition de l'attention
-- ---------------------------------------------------------
insert into public.engine_params (key, value, description) values
  ('attention_duree_fiable_ms', 8000, 'Duree totale de consultation a partir de laquelle la repartition d''attention est jugee pleinement fiable, en millisecondes.'),
  ('attention_poids_retour',     0.35, 'Bonus applique par consultation supplementaire d''une meme section. Revenir sur un ecran est un signal d''attention plus fort qu''y rester passivement.')
on conflict (key) do nothing;

create or replace function private.calculer_attention(p_swipe bigint)
returns void
language plpgsql set search_path = public, private as $$
declare
  v_tot   numeric;
  v_duree integer;
  v_seuil numeric := private.engine_param('attention_duree_fiable_ms');
  v_bonus numeric := private.engine_param('attention_poids_retour');
begin
  -- Le poids d'une section combine le temps passe et le nombre de retours
  with pesee as (
    select ecran,
           duree_ms::numeric * (1 + v_bonus * greatest(consultations - 1, 0)) as poids
    from public.swipe_ecrans where swipe_id = p_swipe
  ),
  total as (select nullif(sum(poids), 0) as s from pesee)
  select coalesce(sum(duree_ms), 0) into v_duree
  from public.swipe_ecrans where swipe_id = p_swipe;

  select sum(duree_ms::numeric * (1 + v_bonus * greatest(consultations - 1, 0)))
    into v_tot
  from public.swipe_ecrans where swipe_id = p_swipe;

  if v_tot is null or v_tot = 0 then
    update public.swipe_decisions
       set attention_physique = null, attention_mode_vie = null,
           attention_valeurs = null, fiabilite_attention = 0
     where id = p_swipe;
    return;
  end if;

  update public.swipe_decisions d set
    attention_physique = coalesce((
      select round(sum(e.duree_ms * (1 + v_bonus * greatest(e.consultations - 1, 0))) / v_tot, 3)
      from public.swipe_ecrans e where e.swipe_id = p_swipe and e.ecran = 'physique'), 0),
    attention_mode_vie = coalesce((
      select round(sum(e.duree_ms * (1 + v_bonus * greatest(e.consultations - 1, 0))) / v_tot, 3)
      from public.swipe_ecrans e where e.swipe_id = p_swipe and e.ecran = 'mode_vie'), 0),
    attention_valeurs = coalesce((
      select round(sum(e.duree_ms * (1 + v_bonus * greatest(e.consultations - 1, 0))) / v_tot, 3)
      from public.swipe_ecrans e where e.swipe_id = p_swipe and e.ecran = 'valeurs'), 0),
    -- Un profil balaye trop vite ne permet aucune lecture d'attention
    fiabilite_attention = round(least(v_duree::numeric / v_seuil, 1), 3),
    duree_totale_ms = coalesce(d.duree_totale_ms, v_duree)
  where d.id = p_swipe;
end $$;

comment on function private.calculer_attention is
  'Produit une repartition d''attention, jamais une preference. Elle indique ou l''utilisateur a concentre son regard avant de decider, et sert uniquement a ponderer le signal. Elle est assortie d''une fiabilite : trente secondes sur une photo ne prouvent pas un gout, et deux secondes ne prouvent rien du tout.';

-- ---------------------------------------------------------
-- Enregistrement complet
-- ---------------------------------------------------------
create or replace function private.enregistrer_swipe(
  u uuid, cible uuid, p_garde boolean,
  p_contexte public.swipe_contexte default 'partir_en_date',
  p_fort boolean default false, p_ecran text default null, p_duree integer default null,
  p_ecrans jsonb default null,          -- [{"ecran":"physique","duree_ms":30000,"consultations":3}, ...]
  p_ordre public.score_group[] default null,
  p_retours smallint default 0,
  p_exposes text[] default null,
  p_consultes text[] default null
) returns uuid
language plpgsql set search_path = public, private as $$
declare v_id bigint; v_focus uuid;
begin
  if u = cible then
    raise exception 'Cible invalide' using errcode = 'check_violation';
  end if;

  insert into public.swipe_decisions
    (user_id, target_id, decision, contexte, signal_fort, ecran, duree_ms,
     duree_totale_ms, ordre_consultation, retours, criteres_exposes, criteres_consultes,
     snapshot)
  values
    (u, cible, p_garde, p_contexte, p_fort, p_ecran, p_duree,
     p_duree, p_ordre, coalesce(p_retours, 0), p_exposes, p_consultes,
     jsonb_build_object(
       'age',        (select h.age from private.profile_header(cible) h),
       'verifie',    (select h.profil_verifie from private.profile_header(cible) h),
       'vecteur_le', (select v.refreshed_at from public.profile_vectors v where v.user_id = cible)))
  returning id into v_id;

  if p_ecrans is not null then
    insert into public.swipe_ecrans (swipe_id, ecran, duree_ms, consultations)
    select v_id,
           (e->>'ecran')::public.score_group,
           coalesce((e->>'duree_ms')::int, 0),
           coalesce((e->>'consultations')::smallint, 1)
    from jsonb_array_elements(p_ecrans) e
    on conflict (swipe_id, ecran) do update
      set duree_ms      = public.swipe_ecrans.duree_ms + excluded.duree_ms,
          consultations = public.swipe_ecrans.consultations + excluded.consultations;

    perform private.calculer_attention(v_id);
  end if;

  if p_contexte = 'mieux_me_connaitre' then
    return private.declencher_focus(u);
  end if;

  if not p_garde then
    perform private.exclure(u, cible, u, 'refus_conversation', interval '30 days');
  end if;
  return null;
end $$;

-- ---------------------------------------------------------
-- Wrapper public
-- ---------------------------------------------------------
create or replace function public.enregistrer_swipe(
  cible uuid, garder boolean,
  contexte public.swipe_contexte default 'partir_en_date',
  signal_fort boolean default false,
  ecran text default null,
  duree_ms integer default null,
  ecrans jsonb default null,
  ordre_consultation public.score_group[] default null,
  retours smallint default 0,
  criteres_exposes text[] default null,
  criteres_consultes text[] default null
) returns uuid
language plpgsql security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return private.enregistrer_swipe(auth.uid(), cible, garder, contexte, signal_fort,
    ecran, duree_ms, ecrans, ordre_consultation, retours, criteres_exposes, criteres_consultes);
end $$;

revoke all on function public.enregistrer_swipe(uuid, boolean, public.swipe_contexte, boolean, text, integer, jsonb, public.score_group[], smallint, text[], text[]) from public;
grant execute on function public.enregistrer_swipe(uuid, boolean, public.swipe_contexte, boolean, text, integer, jsonb, public.score_group[], smallint, text[], text[]) to authenticated;

-- Lecture du contexte d'un swipe, pour le moteur et le support
create or replace function private.contexte_swipe(p_swipe bigint)
returns jsonb
language sql stable set search_path = public, private as $$
  select jsonb_build_object(
    'decision',   d.decision,
    'contexte',   d.contexte,
    'ecran_final', d.ecran,
    'duree_totale_ms', d.duree_totale_ms,
    'ordre',      d.ordre_consultation,
    'retours',    d.retours,
    'attention',  jsonb_build_object(
                    'physique',  d.attention_physique,
                    'mode_vie',  d.attention_mode_vie,
                    'valeurs',   d.attention_valeurs,
                    'fiabilite', d.fiabilite_attention),
    'sections',   (select jsonb_agg(jsonb_build_object(
                     'ecran', e.ecran, 'duree_ms', e.duree_ms, 'consultations', e.consultations)
                     order by e.ecran)
                   from public.swipe_ecrans e where e.swipe_id = d.id),
    'exposes',    to_jsonb(d.criteres_exposes),
    'consultes',  to_jsonb(d.criteres_consultes),
    'snapshot',   d.snapshot)
  from public.swipe_decisions d where d.id = p_swipe;
$$;;
