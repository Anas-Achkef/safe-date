-- =====================================================================
-- 003 — Abonnements
--
-- PROPOSITION. Ne pas appliquer depuis une session d'assistance.
--
-- Le schéma porte DÉJÀ `profiles.is_premium`, et `profile_header()` l'expose
-- sous le nom `est_premium`. L'application lit donc l'état d'abonnement pour
-- de bon, aujourd'hui, sans aucune migration.
--
-- Ce qui manque n'est pas l'état, c'est ce qui le justifie : quelle formule,
-- jusqu'à quand, contre quel reçu. Sans cette trace, on ne sait ni relancer un
-- abonnement expiré, ni répondre à une réclamation, ni prouver un achat.
--
-- ⚠ `is_premium` ne doit JAMAIS être écrit par le client. Sur téléphone, un
-- abonnement numérique passe obligatoirement par les achats intégrés d'Apple
-- et de Google ; la seule preuve recevable est leur reçu, vérifié côté
-- serveur. Une fonction publique qui basculerait ce booléen rendrait
-- l'abonnement gratuit pour qui sait lire un binaire.
-- =====================================================================

create table if not exists public.subscriptions (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references public.profiles (id) on delete cascade,
  -- Identifiant de produit tel que déclaré dans App Store Connect et la Play
  -- Console. Le prix n'est pas stocké : il appartient aux boutiques, et deux
  -- sources de prix qui divergent, c'est un litige.
  formule        text not null,
  plateforme     text not null check (plateforme in ('apple', 'google', 'web')),
  -- Identifiant de transaction original, pour rapprocher les renouvellements.
  transaction_id text not null,
  commence_le    timestamptz not null,
  expire_le      timestamptz not null,
  annule_le      timestamptz,
  cree_le        timestamptz not null default now(),

  -- Un même reçu ne doit pas produire deux abonnements.
  constraint subscriptions_transaction_unique unique (plateforme, transaction_id)
);

-- Retrouver l'abonnement courant d'un utilisateur sans balayer la table.
-- Aucun `now()` dans le prédicat : Postgres l'interdit dans un index, la
-- fonction ne serait pas immuable. Le filtre temporel reste dans la requête.
create index if not exists subscriptions_user_expire_idx
  on public.subscriptions (user_id, expire_le desc);

alter table public.subscriptions enable row level security;

-- Lecture de son propre abonnement, et rien d'autre. Aucune politique
-- d'écriture : seul le service de validation des reçus écrit ici, avec un
-- rôle qui contourne la RLS côté serveur.
create policy subscriptions_lecture_propre
  on public.subscriptions
  for select
  to authenticated
  using (user_id = auth.uid());


-- ---------------------------------------------------------------------
-- mon_abonnement()
--
-- Complète `profile_header().est_premium` avec la formule et l'échéance,
-- pour que l'écran puisse dire « renouvellement le 3 octobre » au lieu d'un
-- simple « actif ».
-- ---------------------------------------------------------------------
create or replace function public.mon_abonnement()
returns table (
  actif      boolean,
  formule    text,
  expire_le  timestamptz
)
language sql
stable
security invoker
set search_path = public
as $$
  select
    s.expire_le > now() and s.annule_le is null,
    s.formule,
    s.expire_le
  from public.subscriptions as s
  where s.user_id = auth.uid()
  order by s.expire_le desc
  limit 1;
$$;

revoke all on function public.mon_abonnement() from public;
grant execute on function public.mon_abonnement() to authenticated;
