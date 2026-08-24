-- Dernieres reformulations demandees par le client cote "ce que je suis".

update criterion_options set label = 'Cuisiner'
  where criterion_key = 'loisir_passion_moi' and idx = 0;

update criterion_options set label = 'Autres sports aquatiques'
  where criterion_key = 'sport_eau_moi' and idx = 2;

update criterion_options set label = 'Je préfère rester à la maison ou dans des lieux que je maîtrise'
  where criterion_key = 'voyage_aime_moi' and idx = 1;

update criterion_options set label = 'Préfère être casanier ou dans des lieux qu''il/elle maîtrise'
  where criterion_key = 'voyage_aime_rech' and idx = 1;

update criteria set question = 'Exigence de l''exclusivité / fidélité envers l''autre :'
  where key = 'val_fidelite_rech';

-- Les vecteurs de profil sont un cache denormalise des reponses et des poids.
-- Toute evolution du referentiel les rend obsoletes : on force leur
-- recalcul en les invalidant.
update profile_vectors set refreshed_at = '1970-01-01'::timestamptz;;
