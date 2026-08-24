-- =====================================================================
--  Prom'us — Jeux de vecteurs de test du moteur de compatibilité
--  Lot 03 du devis 2026-PROMUS-01 : « livré avec des vecteurs de test
--  vérifiables : vous pouvez auditer le moteur, il n'est pas une boîte noire ».
--
--  Chaque cas énonce un résultat attendu. Le script échoue bruyamment si
--  le moteur s'en écarte : à rejouer après toute modification des
--  pondérations ou de la table de correspondance.
--
--  Les cas ci-dessous n'utilisent que les 43 paires déjà mappées. Ils
--  seront étendus aux 133 paires dès la restitution de la grille de
--  correspondance par le client.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
--  Profils de test
-- ---------------------------------------------------------------------
insert into auth.users (id) values
  ('00000000-0000-0000-0000-00000000000a'),
  ('00000000-0000-0000-0000-00000000000b'),
  ('00000000-0000-0000-0000-00000000000c'),
  ('00000000-0000-0000-0000-00000000000d');

insert into profiles (id, birth_date) values
  ('00000000-0000-0000-0000-00000000000a', '1995-03-12'),
  ('00000000-0000-0000-0000-00000000000b', '1994-07-30'),
  ('00000000-0000-0000-0000-00000000000c', '1992-01-05'),
  ('00000000-0000-0000-0000-00000000000d', '1998-11-20');

-- ---------------------------------------------------------------------
--  Générateur de réponses
--  mode 'miroir'   : A est X et cherche X  → A et B se correspondent
--  mode 'oppose'   : la préférence vise systématiquement une autre option
--  mode 'indiff'   : toutes les préférences sont « Peu importe »
-- ---------------------------------------------------------------------
create or replace function seed_test_profile(u uuid, mode text, self_idx int)
returns void language plpgsql as $$
declare p record; n_self int; n_pref int; pref_idx int;
begin
  for p in select * from criterion_pairs where match_type = 'aligne' order by slot loop
    select count(*) into n_self from criterion_options where criterion_key = p.self_key;
    select count(*) into n_pref from criterion_options where criterion_key = p.pref_key;

    insert into profile_answers (user_id, criterion_key, option_idx)
    values (u, p.self_key, array[least(self_idx, n_self - 1)]);

    pref_idx := case
      when mode = 'indiff' then
        coalesce((select idx from criterion_options
                  where criterion_key = p.pref_key and is_neutral limit 1), 0)
      when mode = 'oppose' then (least(self_idx, n_self - 1) + 1) % n_self
      else least(self_idx, n_self - 1)
    end;

    insert into profile_answers (user_id, criterion_key, option_idx)
    values (u, p.pref_key, array[pref_idx]);
  end loop;
end $$;

select seed_test_profile('00000000-0000-0000-0000-00000000000a', 'miroir', 0);
select seed_test_profile('00000000-0000-0000-0000-00000000000b', 'miroir', 0);
select seed_test_profile('00000000-0000-0000-0000-00000000000c', 'oppose', 0);
select seed_test_profile('00000000-0000-0000-0000-00000000000d', 'indiff', 1);

-- ---------------------------------------------------------------------
--  Assertions
-- ---------------------------------------------------------------------
do $$
declare r record; msg text;
begin
  -- CAS 1 — Deux profils identiques qui se cherchent l'un l'autre.
  -- Attendu : filtres franchis, score global 100, les deux sens à 100.
  select * into r from private.compat_score(
    '00000000-0000-0000-0000-00000000000a', '00000000-0000-0000-0000-00000000000b');
  if not r.filtres_ok or r.score_global <> 100 or r.score_a_vers_b <> 100 then
    raise exception 'CAS 1 ÉCHEC : filtres=% global=% a→b=%',
      r.filtres_ok, r.score_global, r.score_a_vers_b;
  end if;
  raise notice 'CAS 1 OK  — jumeaux : global=% (% critères)', r.score_global, r.criteres_evalues;

  -- CAS 2 — Asymétrie réelle. Le profil C est identique à A sur ce qu'il EST,
  -- mais toutes ses préférences visent une autre option. Attendu : le sens
  -- A→C vaut 100 (A trouve chez C ce qu'il cherche), le sens C→A vaut 0
  -- (C ne trouve pas chez A ce qu'il cherche), et les filtres absolus
  -- écartent le couple. C'est le cas qui prouve que la bidirectionnalité
  -- est réellement calculée, et non simulée par un score unique.
  select * into r from private.compat_score(
    '00000000-0000-0000-0000-00000000000a', '00000000-0000-0000-0000-00000000000c');
  if r.filtres_ok then
    raise exception 'CAS 2 ÉCHEC : les filtres absolus auraient dû écarter le couple';
  end if;
  if r.score_a_vers_b <> 100 or r.score_b_vers_a <> 0 then
    raise exception 'CAS 2 ÉCHEC : asymétrie attendue 100/0, obtenue %/%',
      r.score_a_vers_b, r.score_b_vers_a;
  end if;
  if r.score_global <> 50 then
    raise exception 'CAS 2 ÉCHEC : la moyenne des deux sens devrait valoir 50, obtenue %',
      r.score_global;
  end if;
  raise notice 'CAS 2 OK  — asymétrie : a→c=% c→a=% global=% filtres=%',
    r.score_a_vers_b, r.score_b_vers_a, r.score_global, r.filtres_ok;

  -- CAS 3 — Symétrie. Le score global ne doit pas dépendre de l'ordre
  -- des arguments : c'est la moyenne des deux sens.
  select * into r from private.compat_score(
    '00000000-0000-0000-0000-00000000000c', '00000000-0000-0000-0000-00000000000a');
  if r.score_global <> (select score_global from private.compat_score(
       '00000000-0000-0000-0000-00000000000a', '00000000-0000-0000-0000-00000000000c')) then
    raise exception 'CAS 3 ÉCHEC : le score global n''est pas symétrique';
  end if;
  raise notice 'CAS 3 OK  — symétrie du score global vérifiée';

  -- CAS 4 — Neutralisation. Le profil D répond « Peu importe » partout où
  -- l'option existe. Attendu : ces critères quittent le dénominateur sans
  -- pénaliser personne, et le sens D→A vaut 100 sur les critères restants.
  -- Ce cas est celui qui a mis en évidence, à la première exécution, une
  -- déflation du score global lorsqu'un sous-score entier est indéterminé.
  select * into r from private.compat_score(
    '00000000-0000-0000-0000-00000000000d', '00000000-0000-0000-0000-00000000000a');
  if r.score_a_vers_b is distinct from 100 then
    raise exception 'CAS 4 ÉCHEC : un critère neutralisé ne doit ni compter ni pénaliser ; sens d→a attendu 100, obtenu %',
      r.score_a_vers_b;
  end if;
  raise notice 'CAS 4 OK  — neutralisation : d→a=% a→d=% global=%',
    r.score_a_vers_b, r.score_b_vers_a, r.score_global;

  -- CAS 5 — Démarrage à froid. Un profil sans aucune réponse ne doit
  -- jamais être affiché, quel que soit le score calculable.
  insert into auth.users (id) values ('00000000-0000-0000-0000-00000000000e');
  insert into profiles (id, birth_date) values
    ('00000000-0000-0000-0000-00000000000e', '1990-01-01');
  insert into profile_vectors (user_id, self_mask, pref_mask, weight_mul)
  values ('00000000-0000-0000-0000-00000000000e',
          array_fill(null::int, array[133]),
          array_fill(null::int, array[133]),
          array_fill(1.0::numeric, array[133]));
  select * into r from private.compat_score(
    '00000000-0000-0000-0000-00000000000e', '00000000-0000-0000-0000-00000000000a');
  if r.affichable then
    raise exception 'CAS 5 ÉCHEC : un profil vide ne doit pas être affichable';
  end if;
  raise notice 'CAS 5 OK  — démarrage à froid : affichable=% (% critères)',
    r.affichable, r.criteres_evalues;

  raise notice '--------------------------------------------------';
  raise notice 'TOUS LES CAS SONT PASSÉS';
end $$;

rollback;  -- le jeu de test ne laisse aucune trace en base

-- L'éditeur Supabase n'affiche pas les « raise notice ». Un échec lève une
-- exception, donc visible ; cette ligne rend la réussite visible aussi.
select 'TOUS LES CAS SONT PASSÉS' as resultat;
