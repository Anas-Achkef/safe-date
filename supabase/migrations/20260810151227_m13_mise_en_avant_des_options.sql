-- =========================================================
-- M13 - Ce qu'un profil met en avant
--
-- Le moteur choisit les criteres pour leur valeur d'apprentissage.
-- Livre a lui-meme, il expose donc en priorite ce qu'il connait le
-- moins — et se trouve mettre en avant « j'ai peur des animaux »
-- ou « je bois regulierement » parce que ces reponses sont rares.
--
-- Statistiquement correct, humainement brutal : sur un profil de
-- rencontre, personne ne se presente par ses points faibles.
--
-- On ne masque pas pour autant : effacer ces reponses reviendrait a
-- presenter quelqu'un comme n'ayant pas d'avis, ce qui est un
-- mensonge par omission. On les depriorise fortement : elles restent
-- affichables, elles ne peuvent plus dominer un profil.
-- =========================================================

alter table public.criterion_options
  add column if not exists mise_en_avant boolean not null default true;

comment on column public.criterion_options.mise_en_avant is
  'Faux pour les reponses qu''un profil ne met pas spontanement en avant : aveux, phobies, exces, rejets. L''option reste affichable mais son interet d''apprentissage est fortement reduit, de sorte qu''elle n''apparait que faute de mieux. Champ editorial, a relire par le client.';

insert into public.engine_params (key, value, description) values
  ('present_penalite_aveu', 0.15, 'Coefficient applique a l''interet d''apprentissage d''une option non mise en avant. Proche de zero : elle ne passe qu''en dernier recours.')
on conflict (key) do nothing;

-- Premiere passe, volontairement etroite : uniquement les formulations
-- ou le caractere devalorisant ne se discute pas. Le reste releve d'un
-- arbitrage editorial et n'est pas decide ici.
update public.criterion_options o
   set mise_en_avant = false
  from public.criteria c
  join public.criterion_pairs cp on cp.pair_key = c.pair_key
 where c.key = o.criterion_key
   and c.direction = 'self'
   and cp.grp <> 'physique'
   and (
        o.label ilike '%peur d%'
     or o.label ilike '%déteste%'
     or o.label ilike '%je hais%'
     or o.label ilike '%ne supporte pas%'
     or o.label ilike '%trop %'
     or o.label ilike '%excessi%'
     or o.label ilike '%addict%'
     or o.label ilike '%dépendan%'
     or o.label ilike '%jaloux%'
     or o.label ilike '%colèr%'
     or o.label ilike '%agressi%'
     or o.label ilike '%menteur%'
     or o.label ilike '%infidèl%'
   );

-- ---------------------------------------------------------
-- La selection tient compte de ce que le profil met en avant
-- ---------------------------------------------------------
create or replace function private.interet_criteres(u uuid, cible uuid)
returns table (criterion_key text, pair_key text, grp public.score_group,
               phrase text, interet numeric)
language sql stable set search_path = public, private as $$
  select c.key, cp.pair_key, cp.grp, ps.phrase,
         round(
           (
             -- Ce que le moteur ignore encore pese le plus
             (1 - coalesce(pr.confiance, 0)) * 0.6
             -- Une option jamais rencontree apporte une information neuve
             + (case when coalesce(os.observations, 0) = 0 then 1 else 0 end) * 0.25
             -- A ignorance egale, un critere structurant passe devant
             + coalesce(cp.base_weight, 0)
               / nullif((select max(base_weight) from public.criterion_pairs), 0) * 0.15
           )
           -- Une reponse qu'on ne met pas en avant ne passe qu'a defaut
           * case when av.tout_en_avant then 1
                  else private.engine_param('present_penalite_aveu') end
         , 4)
  from public.profile_answers pa
  join public.criteria c on c.key = pa.criterion_key and c.direction = 'self'
  join public.criterion_pairs cp on cp.pair_key = c.pair_key
  left join lateral private.profile_sections(cible) ps on ps.pair_key = cp.pair_key
  left join public.user_criterion_profile pr on pr.user_id = u and pr.criterion_key = c.key
  left join lateral (
    select min(coalesce(s.observations, 0)) as observations
    from unnest(pa.option_idx) o(idx)
    left join public.user_option_stats s
           on s.user_id = u and s.criterion_key = c.key and s.option_idx = o.idx
  ) os on true
  -- Une reponse multiple ne compte comme mise en avant que si toutes
  -- ses options le sont : une seule suffit a rendre la phrase penible.
  cross join lateral (
    select coalesce(bool_and(co.mise_en_avant), true) as tout_en_avant
    from unnest(pa.option_idx) o(idx)
    left join public.criterion_options co
           on co.criterion_key = c.key and co.idx = o.idx
  ) av
  where pa.user_id = cible
    and cp.affichable_apprentissage
    and cp.grp <> 'physique'
    and ps.phrase is not null;
$$;

comment on function private.interet_criteres is
  'Classe les criteres d''un profil selon ce qu''ils apprendraient a cet observateur precis, tempere par ce que le profil met spontanement en avant. La selection n''est jamais aleatoire et differe d''un observateur a l''autre.';;
