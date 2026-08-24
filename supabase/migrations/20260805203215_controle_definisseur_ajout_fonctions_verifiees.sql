-- creer_demande(cible) et repondre_demande(demande, reponse) prennent un uuid
-- mais n'agissent jamais au nom d'un tiers :
--   - l'acteur est toujours auth.uid(), jamais un parametre ;
--   - repondre_demande refuse si auth.uid() n'est pas le destinataire ;
--   - les messages d'erreur sont volontairement uniformes (« Profil
--     indisponible », « Demande introuvable ») pour qu'un appelant ne
--     puisse pas enumerer les profils ni deviner l'existence d'une demande.
-- Elles rejoignent donc la liste des exceptions verifiees.

create or replace view private.v_fonctions_definisseur_exposees as
  select p.proname as fonction,
         pg_get_function_identity_arguments(p.oid) as arguments,
         case when p.prosecdef then 'CRITIQUE — droits définisseur'
              else 'À VÉRIFIER — droits appelant' end as gravite
  from pg_proc p
  join pg_namespace ns on ns.oid = p.pronamespace
  where ns.nspname = 'public'
    and p.prorettype <> 'trigger'::regtype::oid
    and ('uuid'::regtype::oid = any (p.proargtypes::oid[]))
    and pg_get_function_identity_arguments(p.oid) !~ '^(p_id |p )?uuid$'
    and p.proname <> all (array[
      'check_partner_eligibility','partner_activation_checklist','activate_partner',
      'partner_progress','diagnostic_zones','menu_label_conflit','are_blocked',
      'has_consent','set_primary_photo','reveal_establishment','compat_score',
      'creer_demande','repondre_demande'
    ]::name[])
  order by p.proname;;
