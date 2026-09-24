-- ---------------------------------------------------------------------------
-- Réciprocité d'un intérêt
--
-- Proposition. Rien n'est appliqué depuis une session : c'est le responsable
-- du projet qui relit et exécute.
--
-- Le besoin : après un « Ça m'intéresse », l'écran de découverte doit savoir
-- si la personne visée s'était déjà prononcée favorablement. Si oui, les deux
-- se sont choisies et l'application montre l'écran « Coup de cœur réciproque ».
--
-- Pourquoi une fonction et pas une lecture directe : `swipe_decisions` est
-- écrivable par son propriétaire, mais sa policy de lecture ne laisse voir que
-- ses propres lignes — et c'est bien ainsi. Savoir qu'une personne s'est
-- prononcée sur vous ne doit pas se déduire d'une lecture de table : la
-- réponse ne doit sortir que lorsque la réciprocité est **acquise des deux
-- côtés**, sans quoi on pourrait sonder qui vous a aimé sans jamais répondre.
--
-- La fonction ne prend donc pas d'identifiant d'utilisateur : l'appelant est
-- lu dans `auth.uid()`, conformément à la règle du projet.
-- ---------------------------------------------------------------------------

create or replace function public.reciprocite_avec(cible uuid)
returns table (reciproque boolean)
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    -- Le sens aller : je me suis prononcé favorablement sur la cible.
    select 1
      from swipe_decisions moi
     where moi.user_id   = auth.uid()
       and moi.target_id = cible
       and moi.decision
  )
  and exists (
    -- Le sens retour : la cible s'était prononcée favorablement sur moi.
    select 1
      from swipe_decisions elle
     where elle.user_id   = cible
       and elle.target_id = auth.uid()
       and elle.decision
  ) as reciproque;
$$;

-- `security definer` est nécessaire — la seconde sous-requête lit les lignes
-- d'autrui — et sans danger ici : la fonction ne rend qu'un booléen, et
-- seulement quand les deux sens existent. Elle ne peut donc pas servir à
-- découvrir un intérêt à sens unique.

revoke all on function public.reciprocite_avec(uuid) from public;
grant execute on function public.reciprocite_avec(uuid) to authenticated;

-- Index de couverture : la fonction interroge toujours le couple
-- (user_id, target_id). `now()` n'apparaît nulle part — un prédicat qui en
-- contiendrait rendrait l'index non déterministe.
create index if not exists swipe_decisions_couple_favorable_idx
  on public.swipe_decisions (user_id, target_id)
  where decision;
