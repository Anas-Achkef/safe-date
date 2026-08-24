update private.phrase_patterns set pattern =
  'J''ai les cheveux bruns.||J''ai les cheveux blonds.||J''ai les cheveux roux.||J''ai les cheveux noirs.||J''ai les cheveux gris ou blancs.||J''ai une couleur de cheveux artificielle.'
where criterion_key = 'chev_couleur_moi';

update private.phrase_patterns set pattern =
  'Je préfère parler en vrai plutôt qu''à distance.||Je préfère les messages et les textos.||Je préfère les appels fréquents.'
where criterion_key = 'com_canal_moi';

update private.phrase_patterns set pattern =
  'Je n''ai aucune pilosité corporelle ou je suis épilé(e).||J''ai une pilosité corporelle faible.||J''ai une pilosité corporelle marquée.'
where criterion_key = 'pil_corps_moi';

update private.phrase_patterns set pattern =
  'Je me maquille de façon naturelle ou rarement.||Je me maquille légèrement.||Je me maquille de façon prononcée.||Cette question ne s''applique pas à moi.'
where criterion_key = 'style_maquillage_moi';;
