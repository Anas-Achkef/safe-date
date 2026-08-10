--
-- PostgreSQL database dump
--

\restrict 9ouVU5pfwuQXK32u74taG1qPWpjxh9cfoTNKepfhuNjsRipLigfMeLIbhZdbl28

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.10 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: private; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA private;


--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: chat_request_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.chat_request_status AS ENUM (
    'en_attente',
    'acceptee',
    'refusee',
    'reportee',
    'expiree'
);


--
-- Name: collection_moment; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.collection_moment AS ENUM (
    'onboarding',
    'quiz',
    'backend'
);


--
-- Name: conversation_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.conversation_status AS ENUM (
    'prete',
    'active',
    'verrouillee',
    'cloturee'
);


--
-- Name: criterion_direction; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.criterion_direction AS ENUM (
    'self',
    'pref'
);


--
-- Name: date_intent; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.date_intent AS ENUM (
    'oui',
    'non',
    'plus_tard'
);


--
-- Name: date_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.date_status AS ENUM (
    'en_preparation',
    'confirme',
    'en_cours',
    'termine',
    'annule'
);


--
-- Name: exclusion_reason; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.exclusion_reason AS ENUM (
    'refus_conversation',
    'blocage',
    'signalement',
    'moderation'
);


--
-- Name: focus_context; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.focus_context AS ENUM (
    'swipe',
    'profil',
    'conversation',
    'decision_date',
    'etablissement',
    'erreur_prediction',
    'question_intermediaire'
);


--
-- Name: help_level; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.help_level AS ENUM (
    'discret',
    'etablissement',
    'angela',
    'urgence'
);


--
-- Name: invoice_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.invoice_type AS ENUM (
    'detaillee',
    'simplifiee'
);


--
-- Name: match_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.match_type AS ENUM (
    'aligne',
    'mapping',
    'importance',
    'repoussoir',
    'echelle'
);


--
-- Name: message_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.message_kind AS ENUM (
    'texte',
    'vocal',
    'photo'
);


--
-- Name: moderation_action; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.moderation_action AS ENUM (
    'rappel_regles',
    'avertissement',
    'suspension_temporaire',
    'bannissement',
    'classe_sans_suite'
);


--
-- Name: moderation_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.moderation_status AS ENUM (
    'en_attente',
    'approuvee',
    'rejetee'
);


--
-- Name: order_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.order_status AS ENUM (
    'brouillon',
    'transmise',
    'acceptee',
    'servie',
    'annulee'
);


--
-- Name: partner_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.partner_status AS ENUM (
    'brouillon',
    'en_verification',
    'rejete',
    'actif',
    'suspendu'
);


--
-- Name: payment_kind; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.payment_kind AS ENUM (
    'preautorisation',
    'paiement',
    'remboursement'
);


--
-- Name: payment_mode; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.payment_mode AS ENUM (
    'individuel',
    'integral',
    'especes'
);


--
-- Name: payment_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.payment_status AS ENUM (
    'en_attente',
    'autorise',
    'capture',
    'echoue',
    'annule',
    'rembourse'
);


--
-- Name: photo_source; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.photo_source AS ENUM (
    'google_reference',
    'import_partenaire'
);


--
-- Name: relative_op; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.relative_op AS ENUM (
    'sup',
    'sup_egal',
    'inf',
    'inf_egal',
    'egal'
);


--
-- Name: rencontre_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.rencontre_type AS ENUM (
    'amour',
    'amitie',
    'fun'
);


--
-- Name: report_reason; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.report_reason AS ENUM (
    'faux_profil',
    'harcelement',
    'contenu_sexuel',
    'mineur',
    'violence',
    'arnaque',
    'comportement_rendez_vous',
    'autre'
);


--
-- Name: report_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.report_status AS ENUM (
    'nouveau',
    'en_cours',
    'traite',
    'rejete'
);


--
-- Name: review_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.review_status AS ENUM (
    'propose',
    'plus_tard',
    'passe',
    'soumis'
);


--
-- Name: score_group; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.score_group AS ENUM (
    'physique',
    'valeurs',
    'mode_vie'
);


--
-- Name: sensitive_category; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.sensitive_category AS ENUM (
    'origine_ethnique',
    'convictions_religieuses',
    'opinions_politiques',
    'orientation_sexuelle',
    'sante',
    'biometrie',
    'geolocalisation',
    'identite_genre'
);


--
-- Name: surprise_response; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.surprise_response AS ENUM (
    'accepte',
    'indispo_jour',
    'indispo_semaine',
    'refus'
);


--
-- Name: swipe_contexte; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.swipe_contexte AS ENUM (
    'mieux_me_connaitre',
    'partir_en_date'
);


--
-- Name: unit_system; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.unit_system AS ENUM (
    'metrique',
    'imperial'
);


--
-- Name: venue_proposal_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.venue_proposal_status AS ENUM (
    'en_cours',
    'acceptee',
    'refusee',
    'epuisee'
);


--
-- Name: verif_channel; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.verif_channel AS ENUM (
    'email',
    'sms'
);


--
-- Name: verification_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.verification_status AS ENUM (
    'en_attente',
    'validee',
    'refusee',
    'expiree'
);


--
-- Name: activate_user(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.activate_user(u uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare manquantes text;
begin
  select string_agg(condition,' · ' order by rang) into manquantes
  from private.user_activation_checklist(u) where not coalesce(satisfaite,false);
  if manquantes is not null then
    raise exception 'Activation impossible, conditions non remplies : %', manquantes
      using errcode = 'check_violation';
  end if;
  update profiles set is_active = true where id = u;
  insert into user_step_completions (user_id, step) values (u,8) on conflict do nothing;
end $$;


--
-- Name: addition(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.addition(d_id uuid) RETURNS TABLE(user_id uuid, articles integer, montant_cents integer, regle boolean)
    LANGUAGE sql STABLE
    AS $$
  select o.user_id,
         coalesce(sum(i.quantity), 0)::integer,
         coalesce(sum(i.line_total_cents), 0)::integer,
         coalesce(sum(i.line_total_cents), 0)
           <= coalesce((select sum(p.amount_cents) from payments p
                        where p.date_id = d_id and p.kind = 'paiement'
                          and p.status = 'capture'
                          and (p.payer_id = o.user_id or p.mode = 'integral')), 0)
  from orders o
  left join order_items i on i.order_id = o.id
  where o.date_id = d_id and o.status <> 'annulee'
  group by o.user_id;
$$;


--
-- Name: addition_totale(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.addition_totale(d_id uuid) RETURNS integer
    LANGUAGE sql STABLE
    AS $$
  select coalesce(sum(montant_cents), 0)::integer from private.addition(d_id);
$$;


--
-- Name: ajouter_consommation(uuid, uuid, uuid, smallint, jsonb); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.ajouter_consommation(u uuid, d_id uuid, item uuid, qte smallint DEFAULT 1, opts jsonb DEFAULT '{}'::jsonb) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
declare v_order uuid; v_partner uuid; v_item partner_menu_items;
begin
  select partner_id into v_partner from dates
   where id = d_id and (user_a = u or user_b = u) and status = 'en_cours';
  if v_partner is null then
    raise exception 'Rendez-vous introuvable ou Mode Rendez-vous inactif' using errcode = 'no_data_found';
  end if;

  select * into v_item from partner_menu_items where id = item and partner_id = v_partner;
  if v_item is null then
    raise exception 'Produit introuvable dans le menu de cet établissement' using errcode = 'no_data_found';
  end if;
  if not v_item.is_available then
    raise exception 'Ce produit est momentanément indisponible' using errcode = 'check_violation';
  end if;

  select id into v_order from orders
   where date_id = d_id and user_id = u and status = 'brouillon' limit 1;
  if v_order is null then
    insert into orders (date_id, user_id, partner_id) values (d_id, u, v_partner)
    returning id into v_order;
  end if;

  -- Le libelle et le prix sont figes : le partenaire peut modifier son
  -- menu a tout moment, une commande passee ne doit jamais bouger.
  insert into order_items (order_id, menu_item_id, label_snapshot, unit_price_cents, quantity, options)
  values (v_order, item, v_item.label, v_item.price_cents, qte, opts);

  return v_order;
end $$;


--
-- Name: answer_progress(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.answer_progress(u uuid) RETURNS TABLE(onboarding_repondus integer, onboarding_total integer, quiz_repondus integer, quiz_total integer, paires_completes integer, criteres_evaluables integer)
    LANGUAGE sql STABLE
    AS $$
  select
    (select count(*)::int from profile_answers a join criteria c on c.key = a.criterion_key
      where a.user_id = u and c.moment = 'onboarding'),
    (select count(*)::int from criteria where moment = 'onboarding'),
    (select count(*)::int from profile_answers a join criteria c on c.key = a.criterion_key
      where a.user_id = u and c.moment = 'quiz'),
    (select count(*)::int from criteria where moment = 'quiz'),
    (select count(*)::int from criterion_pairs p
      where exists (select 1 from profile_answers where user_id = u and criterion_key = p.self_key)
        and exists (select 1 from profile_answers where user_id = u and criterion_key = p.pref_key)),
    (select count(*)::int from profile_answers where user_id = u);
$$;


--
-- Name: apply_learning(uuid, uuid, boolean, numeric, public.score_group[]); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.apply_learning(u uuid, cible uuid, accepte boolean, coef numeric, groupes public.score_group[] DEFAULT NULL::public.score_group[]) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
  v_am    numeric := private.engine_param('apprentissage_accept_match');
  v_an    numeric := private.engine_param('apprentissage_accept_nomatch');
  v_rn    numeric := private.engine_param('apprentissage_refus_nomatch');
  v_rm    numeric := private.engine_param('apprentissage_refus_match');
  v_min   numeric := private.engine_param('apprentissage_mul_min');
  v_max   numeric := private.engine_param('apprentissage_mul_max');
  v_ampl  numeric := private.engine_param('apprentissage_amplitude');
  v_seuil numeric := private.engine_param('seuil_declassement');
  v_delta numeric := private.engine_param('apprentissage_seuil_refresh');
  v_fiab  numeric;
  v_eff   numeric;
  v_bouge boolean := false;
begin
  if u is null or cible is null or coef is null or coef = 0 then
    return;
  end if;

  -- Une decision ne pese qu'a hauteur de ce qu'elle revele.
  v_fiab := private.learning_reliability(u);
  v_eff  := coef * v_fiab;

  -- Les paires eliminatoires ne s'apprennent pas.
  insert into user_criterion_learning (user_id, pair_key, confirmations, contradictions, observations)
  select u, e.pair_key,
         v_eff * case when     accepte and     e.m then v_am
                      when not accepte and not e.m then v_rn
                      else 0 end,
         v_eff * case when     accepte and not e.m then v_an
                      when not accepte and     e.m then v_rm
                      else 0 end,
         1
  from (
    select p.pair_key, p.grp,
           (vb.self_mask[p.slot+1] & va.pref_mask[p.slot+1]) <> 0 as m
    from criterion_pairs p
    cross join (select * from profile_vectors where user_id = u)     va
    cross join (select * from profile_vectors where user_id = cible) vb
    where not p.is_absolute
      and va.pref_mask[p.slot+1] is not null
      and vb.self_mask[p.slot+1] is not null
      and va.weight_mul[p.slot+1] > 0
  ) e
  where groupes is null or e.grp = any(groupes)
  on conflict (user_id, pair_key) do update set
    confirmations  = user_criterion_learning.confirmations  + excluded.confirmations,
    contradictions = user_criterion_learning.contradictions + excluded.contradictions,
    observations   = user_criterion_learning.observations   + 1,
    updated_at     = now();

  select bool_or(abs(x.nouveau - x.learned_mul) >= v_delta) into v_bouge
  from (
    select l.learned_mul,
           greatest(v_min, least(v_max,
             1 + (l.confirmations - l.contradictions) / nullif(v_seuil, 0) * v_ampl)) as nouveau
    from user_criterion_learning l where l.user_id = u
  ) x;

  update user_criterion_learning l
     set learned_mul = greatest(v_min, least(v_max,
           1 + (l.confirmations - l.contradictions) / nullif(v_seuil, 0) * v_ampl))
   where l.user_id = u;

  if coalesce(v_bouge, false) then
    perform private.refresh_profile_vectors(u);
  end if;
end $$;


--
-- Name: FUNCTION apply_learning(u uuid, cible uuid, accepte boolean, coef numeric, groupes public.score_group[]); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.apply_learning(u uuid, cible uuid, accepte boolean, coef numeric, groupes public.score_group[]) IS 'Enregistre une decision et reevalue le poids appris des criteres concernes. Accepter malgre un critere non satisfait est le signal le plus fort ; refuser un profil qui satisfaisait le critere ne dit presque rien. groupes restreint l''apprentissage a certaines dimensions, ce qui permet d''exploiter separement les trois notes post-rendez-vous.';


--
-- Name: apprentissage_apres_swipe(uuid, bigint); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.apprentissage_apres_swipe(u uuid, p_swipe bigint DEFAULT NULL::bigint) RETURNS uuid
    LANGUAGE plpgsql
    SET search_path TO 'public', 'private'
    AS $$
declare v_id uuid;
begin
  v_id := private.declencher_question(u, p_swipe);
  if v_id is not null then return v_id; end if;
  return private.declencher_focus(u);
end $$;


--
-- Name: FUNCTION apprentissage_apres_swipe(u uuid, p_swipe bigint); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.apprentissage_apres_swipe(u uuid, p_swipe bigint) IS 'Une seule sollicitation a la fois. La question intermediaire passe avant le Focus de serie : elle comble un manque identifie, le second explore une intuition.';


--
-- Name: attraction_vs_reussite(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.attraction_vs_reussite(u uuid) RETURNS TABLE(criterion_key text, option_idx smallint, libelle text, attraction numeric, satisfaction numeric, rencontres integer, pouvoir_predictif numeric, verdict text)
    LANGUAGE sql STABLE
    SET search_path TO 'public', 'private'
    AS $$
  select s.criterion_key, s.option_idx, o.label,
         round(case when s.poids > 0 then s.poids_oui / s.poids end, 4),
         e.satisfaction_moy, coalesce(e.rencontres, 0), e.pouvoir_predictif,
         case
           when e.rencontres is null or e.rencontres = 0 then 'jamais eprouve'
           when e.confiance < 0.35                       then 'trop peu de rencontres'
           when s.poids_oui / nullif(s.poids, 0) >= 0.65 and e.pouvoir_predictif <= -0.03
             then 'attire mais ne tient pas ses promesses'
           when s.poids_oui / nullif(s.poids, 0) <= 0.40 and e.pouvoir_predictif >= 0.03
             then 'sous-estime : fonctionne mieux que prevu'
           when e.pouvoir_predictif >= 0.03              then 'confirme par le vecu'
           else 'sans effet mesurable'
         end
  from public.user_option_stats s
  left join public.user_option_outcome e
         on e.user_id = s.user_id and e.criterion_key = s.criterion_key
        and e.option_idx = s.option_idx
  left join public.criterion_options o
         on o.criterion_key = s.criterion_key and o.idx = s.option_idx
  where s.user_id = u
  order by coalesce(abs(e.pouvoir_predictif), 0) desc, s.observations desc;
$$;


--
-- Name: FUNCTION attraction_vs_reussite(u uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.attraction_vs_reussite(u uuid) IS 'Confronte ce qui donne envie de dire oui a ce qui produit reellement de bons moments. Les deux verdicts les plus precieux sont les dissonances : une option tres attirante sans effet reel, et une option negligee qui fonctionne.';


--
-- Name: boite_reception(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.boite_reception(u uuid) RETURNS TABLE(demande_id uuid, emetteur uuid, prenom text, age integer, photo_principale text, profil_verifie boolean, type_rencontre public.rencontre_type, compat_rate numeric, ecran_ordre public.score_group[], ecran_vignette public.score_group, distance text, statut public.chat_request_status, secondes_restantes integer, reportable boolean)
    LANGUAGE sql STABLE
    SET search_path TO 'public', 'private'
    AS $$
  select
    r.id,
    r.from_user,
    p.prenom,
    h.age,
    h.photo_principale,
    h.profil_verifie,
    r.type_rencontre,
    r.compat_rate,
    r.ecran_ordre,
    r.ecran_ordre[1],
    private.distance_palier(u, r.from_user),
    private.statut_effectif(r),
    case
      when private.statut_effectif(r) not in ('en_attente','reportee') then 0
      when r.expires_at is null then null            -- pas encore ouverte : chrono non demarre
      else greatest(0, extract(epoch from r.expires_at - now()))::int
    end,
    (r.postpone_count = 0)
  from public.chat_requests r
  join public.profiles p on p.id = r.from_user
  cross join lateral private.profile_header(r.from_user) h
  where r.to_user = u
    and (
      private.statut_effectif(r) in ('en_attente','reportee')
      or (r.status = 'expiree' and r.responded_at > now() - interval '1 hour')
    )
    and not private.est_exclu(u, r.from_user)
  order by
    (private.statut_effectif(r) in ('en_attente','reportee')) desc,
    r.compat_rate desc nulls last,
    r.created_at desc
  limit 20;
$$;


--
-- Name: FUNCTION boite_reception(u uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.boite_reception(u uuid) IS 'ecran_vignette est le premier des trois ecrans choisi par l''emetteur : c''est ce qu''il a decide de mettre en avant. secondes_restantes est nul tant que la demande n''a pas ete ouverte. Les demandes expirees depuis moins d''une heure restent listees pour permettre l''affichage floute, mais leur statut effectif interdit toute action.';


--
-- Name: cadence_questions(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.cadence_questions(u uuid) RETURNS integer
    LANGUAGE sql STABLE
    SET search_path TO 'public', 'private'
    AS $$
  select greatest(
    private.engine_param('quest_cadence_min'),
    round(private.engine_param('quest_cadence_min')
      + (private.engine_param('quest_cadence_max') - private.engine_param('quest_cadence_min'))
        * coalesce((select avg(confiance) from public.user_criterion_profile where user_id = u), 0))
  )::int;
$$;


--
-- Name: FUNCTION cadence_questions(u uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.cadence_questions(u uuid) IS 'Huit profils quand tout reste a apprendre, jusqu''a trente quand le profil est documente. La cadence suit l''etat des connaissances.';


--
-- Name: cadrage_ok(uuid, uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.cadrage_ok(a uuid, b uuid) RETURNS boolean
    LANGUAGE sql STABLE
    SET search_path TO 'public', 'private'
    AS $$
  with va as (select * from profile_vectors where user_id = a),
       vb as (select * from profile_vectors where user_id = b)
  select coalesce(bool_and(
    case
      when va.pref_mask[p.slot+1] is not null and vb.self_mask[p.slot+1] is not null
           and (vb.self_mask[p.slot+1] & va.pref_mask[p.slot+1]) = 0 then false
      when vb.pref_mask[p.slot+1] is not null and va.self_mask[p.slot+1] is not null
           and (va.self_mask[p.slot+1] & vb.pref_mask[p.slot+1]) = 0 then false
      else true
    end), true)
  from criterion_pairs p, va, vb
  where p.is_absolute and p.filtre_cadrage;
$$;


--
-- Name: FUNCTION cadrage_ok(a uuid, b uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.cadrage_ok(a uuid, b uuid) IS 'Vrai si les deux profils sont mutuellement dans le cadre de recherche de l''autre. Faux retire le profil du fil, sans notification ni trace visible.';


--
-- Name: calculer_attention(bigint); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.calculer_attention(p_swipe bigint) RETURNS void
    LANGUAGE plpgsql
    SET search_path TO 'public', 'private'
    AS $$
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


--
-- Name: FUNCTION calculer_attention(p_swipe bigint); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.calculer_attention(p_swipe bigint) IS 'Produit une repartition d''attention, jamais une preference. Elle indique ou l''utilisateur a concentre son regard avant de decider, et sert uniquement a ponderer le signal. Elle est assortie d''une fiabilite : trente secondes sur une photo ne prouvent pas un gout, et deux secondes ne prouvent rien du tout.';


--
-- Name: candidate_cards(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.candidate_cards(u uuid) RETURNS TABLE(candidate_id uuid, prenom text, age integer, photo text, verifie boolean, score_global numeric, score_physique numeric, score_valeurs numeric, score_mode_vie numeric, score_aller numeric, score_retour numeric, criteres_evalues integer, filtres_ok boolean, affichable boolean, au_dela_du_seuil boolean, highlights jsonb)
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
  select
    p.id, p.prenom,
    extract(year from age(current_date, p.birth_date))::int,
    (select ph.storage_path from user_photos ph
      where ph.user_id = p.id and ph.is_primary and ph.moderation <> 'rejetee'),
    p.is_verified,
    s.score_global, s.score_physique, s.score_valeurs, s.score_mode_vie,
    s.score_a_vers_b, s.score_b_vers_a, s.criteres_evalues,
    s.filtres_ok, s.affichable,
    coalesce(s.score_global, 0) >= private.engine_param('seuil_premium'),
    coalesce((select jsonb_agg(jsonb_build_object('question', h.question,
                                                  'reponse', h.reponse,
                                                  'groupe', h.grp))
              from private.candidate_highlights(u, p.id, 3) h), '[]'::jsonb)
  from private.eligible_candidates(u) c
  join profiles p on p.id = c.candidate_id
  cross join lateral private.compat_score(u, p.id) s
  order by s.score_global desc nulls last;
$$;


--
-- Name: candidate_highlights(uuid, uuid, integer); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.candidate_highlights(u uuid, autre uuid, n integer DEFAULT 3) RETURNS TABLE(question text, reponse text, grp public.score_group)
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
  select c.question, o.label, p.grp
  from criterion_pairs p
  join criteria c on c.key = p.self_key
  join profile_answers a on a.user_id = autre and a.criterion_key = p.self_key
  join criterion_options o on o.criterion_key = p.self_key and o.idx = a.option_idx[1]
  join profile_vectors va on va.user_id = u
  join profile_vectors vb on vb.user_id = autre
  left join private.criterion_stats st on st.criterion_key = p.self_key
  where not p.is_absolute
    and c.sensitive_category is null
    and va.pref_mask[p.slot+1] is not null
    and vb.self_mask[p.slot+1] is not null
    and (vb.self_mask[p.slot+1] & va.pref_mask[p.slot+1]) <> 0
    and va.weight_mul[p.slot+1] > 0
  order by
    case p.grp when 'valeurs' then 0 when 'mode_vie' then 1 else 2 end,
    va.weight_mul[p.slot+1] desc,
    coalesce(st.entropie, 1.0) desc,
    c.ord
  limit n;
$$;


--
-- Name: cles_presentation(bigint); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.cles_presentation(p_presentation bigint) RETURNS text[]
    LANGUAGE sql STABLE
    SET search_path TO 'public', 'private'
    AS $$
  select array_agg(item->>'cle')
  from public.profile_presentations p,
       lateral jsonb_each(p.criteres) e,
       lateral jsonb_array_elements(e.value) item
  where p.id = p_presentation;
$$;


--
-- Name: cloturer_date(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.cloturer_date(d_id uuid) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
declare
  d dates; v_reste integer; v_partis boolean; v_dette uuid;
  v_taux numeric; r record;
begin
  select * into d from dates where id = d_id;
  if d is null then
    raise exception 'Rendez-vous introuvable' using errcode = 'no_data_found';
  end if;
  if d.closed_at is not null then
    return jsonb_build_object('deja_cloture', true);
  end if;
  if d.ended_at is null then
    return jsonb_build_object('cloture', false, 'motif', 'rendez-vous non terminé');
  end if;

  select count(*) filter (where left_at is not null) = 2
    into v_partis from date_presence where date_id = d_id;
  if not coalesce(v_partis, false) then
    return jsonb_build_object('cloture', false, 'motif', 'les deux utilisateurs n''ont pas quitté l''établissement');
  end if;

  v_reste := private.reste_a_payer(d_id);
  v_taux  := private.commission_taux(d.partner_id);

  -- Tolerance zero sur les impayes, mais l'etablissement est garanti :
  -- Safe Date le regle, puis se retourne vers l'utilisateur.
  if v_reste > 0 then
    for r in
      select a.user_id, a.montant_cents
             - coalesce((select sum(p.amount_cents) from payments p
                         where p.date_id = d_id and p.kind = 'paiement'
                           and p.status = 'capture'
                           and (p.payer_id = a.user_id or p.mode = 'integral')), 0) as du
      from private.addition(d_id) a
    loop
      if r.du > 0 then
        insert into outstanding_debts (user_id, date_id, partner_id, amount_cents)
        values (r.user_id, d_id, d.partner_id, r.du)
        returning id into v_dette;
      end if;
    end loop;

    insert into partner_settlements (payment_id, partner_id, gross_cents,
                                     commission_cents, net_cents, garantie)
    values (null, d.partner_id, v_reste, round(v_reste * v_taux),
            v_reste - round(v_reste * v_taux), true);
  end if;

  update dates set closed_at = now(), status = 'termine' where id = d_id;

  return jsonb_build_object(
    'cloture', true,
    'impaye_cents', v_reste,
    'evaluations_disponibles', private.evaluations_disponibles(d_id));
end $$;


--
-- Name: cloturer_session(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.cloturer_session(u uuid) RETURNS TABLE(message text, niveau numeric, niveau_hier numeric, progression numeric, profils_vus integer, illimite boolean)
    LANGUAGE plpgsql
    SET search_path TO 'public', 'private'
    AS $$
declare
  v_niveau numeric := private.niveau_connaissance(u);
  v_hier   numeric;
begin
  select h.niveau into v_hier
  from public.user_knowledge_history h
  where h.user_id = u and h.jour < current_date
  order by h.jour desc limit 1;

  insert into public.user_knowledge_history (user_id, jour, niveau)
  values (u, current_date, v_niveau)
  on conflict (user_id, jour) do update set niveau = excluded.niveau;

  return query
  select (select m.message from public.session_messages m where m.actif order by random() limit 1),
         v_niveau, v_hier,
         case when v_hier is not null then round(v_niveau - v_hier, 4) end,
         (select s.profils_vus from private.etat_session(u) s),
         (select s.illimite from private.etat_session(u) s);
end $$;


--
-- Name: FUNCTION cloturer_session(u uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.cloturer_session(u uuid) IS 'Cloture positivement la session. Le message varie d''une fois sur l''autre pour ne pas devenir mecanique, et la progression est donnee par rapport au dernier releve, pas depuis le debut.';


--
-- Name: commission_taux(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.commission_taux(p uuid) RETURNS numeric
    LANGUAGE sql STABLE
    AS $$ select coalesce((select commission_taux from partners where id = p),
                     private.engine_param('commission_taux_defaut')); $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: compat_cache; Type: TABLE; Schema: private; Owner: -
--

CREATE TABLE private.compat_cache (
    user_lo uuid NOT NULL,
    user_hi uuid NOT NULL,
    filtres_ok boolean NOT NULL,
    score_global numeric,
    score_physique numeric,
    score_valeurs numeric,
    score_mode_vie numeric,
    score_lo_hi numeric,
    score_hi_lo numeric,
    criteres_evalues integer,
    affichable boolean NOT NULL,
    vectors_stamp timestamp with time zone NOT NULL,
    computed_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT compat_cache_paire_ordonnee CHECK ((user_lo < user_hi))
);


--
-- Name: TABLE compat_cache; Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON TABLE private.compat_cache IS 'Scores de compatibilite materialises, une ligne par couple ordonne. vectors_stamp porte la date du plus recent des deux vecteurs au moment du calcul : une ligne est perimee des qu''un des deux profils evolue. Aucune policy : lecture reservee aux fonctions SECURITY DEFINER.';


--
-- Name: COLUMN compat_cache.score_lo_hi; Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON COLUMN private.compat_cache.score_lo_hi IS 'Score directionnel de user_lo vers user_hi. Le sens compte : la compatibilite n''est pas symetrique.';


--
-- Name: compat_cached(uuid, uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.compat_cached(a uuid, b uuid) RETURNS private.compat_cache
    LANGUAGE plpgsql
    SET search_path TO 'public', 'private'
    AS $$
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


--
-- Name: FUNCTION compat_cached(a uuid, b uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.compat_cached(a uuid, b uuid) IS 'Recalcul paresseux : la ligne n''est recalculee que si l''un des deux vecteurs a change depuis le dernier calcul. Retourne null si un des profils n''a pas encore de vecteur.';


--
-- Name: compat_pour(uuid, uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.compat_pour(u uuid, cible uuid) RETURNS TABLE(score numeric, filtres_ok boolean, affichable boolean, score_physique numeric, score_valeurs numeric, score_mode_vie numeric)
    LANGUAGE sql
    SET search_path TO 'public', 'private'
    AS $$
  select c.score_global, c.filtres_ok, c.affichable,
         c.score_physique, c.score_valeurs, c.score_mode_vie
  from private.compat_cached(u, cible) c
  where c.user_lo is not null;
$$;


--
-- Name: compat_score(uuid, uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.compat_score(u_a uuid, u_b uuid) RETURNS TABLE(filtres_ok boolean, score_global numeric, score_physique numeric, score_valeurs numeric, score_mode_vie numeric, score_a_vers_b numeric, score_b_vers_a numeric, criteres_evalues integer, affichable boolean)
    LANGUAGE sql STABLE
    AS $$
with va as (select * from profile_vectors where user_id = u_a),
vb as (select * from profile_vectors where user_id = u_b),
ev as (select p.grp, p.is_absolute, p.base_weight,
    (va.pref_mask[p.slot+1] is not null and vb.self_mask[p.slot+1] is not null) as ab_eval,
    ((vb.self_mask[p.slot+1] & va.pref_mask[p.slot+1]) <> 0) as ab_match,
    p.base_weight * va.weight_mul[p.slot+1] as ab_w,
    (vb.pref_mask[p.slot+1] is not null and va.self_mask[p.slot+1] is not null) as ba_eval,
    ((va.self_mask[p.slot+1] & vb.pref_mask[p.slot+1]) <> 0) as ba_match,
    p.base_weight * vb.weight_mul[p.slot+1] as ba_w
  from criterion_pairs p, va, vb),
filtres as (select bool_and(case when not is_absolute then true
    when ab_eval and not ab_match then false
    when ba_eval and not ba_match then false else true end) as ok from ev),
grp as (select grp,
    sum(ab_w) filter (where ab_eval and ab_w > 0) as den_ab,
    sum(ab_w) filter (where ab_eval and ab_match and ab_w > 0) as num_ab,
    sum(ba_w) filter (where ba_eval and ba_w > 0) as den_ba,
    sum(ba_w) filter (where ba_eval and ba_match and ba_w > 0) as num_ba,
    count(*) filter (where (ab_eval or ba_eval) and not is_absolute) as n
  from ev where not is_absolute group by grp),
dir as (select grp, n, 100 * coalesce(num_ab, 0) / nullif(den_ab, 0) as s_ab,
    100 * coalesce(num_ba, 0) / nullif(den_ba, 0) as s_ba from grp),
final as (select grp, n, round((coalesce(s_ab, s_ba) + coalesce(s_ba, s_ab)) / 2, 1) as s,
    s_ab, s_ba from dir),
pond as (select
    sum(f.s * pp.value) filter (where f.s is not null)
      / nullif(sum(pp.value) filter (where f.s is not null), 0) as global,
    sum(f.s_ab * pp.value) filter (where f.s_ab is not null)
      / nullif(sum(pp.value) filter (where f.s_ab is not null), 0) as g_ab,
    sum(f.s_ba * pp.value) filter (where f.s_ba is not null)
      / nullif(sum(pp.value) filter (where f.s_ba is not null), 0) as g_ba,
    sum(f.n)::int as n_tot
  from final f join private.engine_params_all() pp on pp.key = 'poids_' || f.grp::text)
select filtres.ok, round(pond.global, 1),
  (select s from final where grp = 'physique'),
  (select s from final where grp = 'valeurs'),
  (select s from final where grp = 'mode_vie'),
  round(pond.g_ab, 1), round(pond.g_ba, 1), pond.n_tot,
  filtres.ok and pond.g_ab is not null and pond.g_ba is not null
    and pond.g_ab >= private.engine_param('plancher_directionnel')
    and pond.g_ba >= private.engine_param('plancher_directionnel')
    and pond.n_tot >= private.engine_param('min_criteres_affiches')
from filtres, pond;
$$;


--
-- Name: complete_questionnaire_step(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.complete_questionnaire_step(u uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare manquants text; reste int;
begin
  select string_agg(categorie::text, ', ' order by categorie) into manquants
  from private.consentements_requis_questionnaire(u) where not accorde;
  if manquants is not null then
    raise exception 'Questionnaire incomplet : consentement manquant pour %.', manquants
      using errcode = 'check_violation';
  end if;
  select onboarding_total - onboarding_repondus into reste from private.answer_progress(u);
  if reste > 0 then
    raise exception 'Questionnaire incomplet : % critère(s) obligatoire(s) restant(s)', reste
      using errcode = 'check_violation';
  end if;
  insert into user_step_completions (user_id, step) values (u,5) on conflict do nothing;
end $$;


--
-- Name: compte_bloque(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.compte_bloque(u uuid) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  select exists (select 1 from outstanding_debts o
                 where o.user_id = u and o.settled_at is null);
$$;


--
-- Name: FUNCTION compte_bloque(u uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.compte_bloque(u uuid) IS 'Tant qu''une consommation reste impayee, l''acces a l''application est bloque par un ecran de regularisation.';


--
-- Name: consentements_requis_questionnaire(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.consentements_requis_questionnaire(u uuid) RETURNS TABLE(categorie public.sensitive_category, criteres integer, accorde boolean)
    LANGUAGE sql STABLE
    AS $$
  select c.sensitive_category, count(*)::int, has_consent(u, c.sensitive_category)
  from criteria c where c.moment = 'onboarding' and c.sensitive_category is not null
  group by c.sensitive_category order by 1;
$$;


--
-- Name: consolider_experience(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.consolider_experience(u uuid) RETURNS integer
    LANGUAGE plpgsql
    SET search_path TO 'public', 'private'
    AS $$
declare
  v_max numeric := private.engine_param('exp_echelle_max');
  v_k   numeric := private.engine_param('exp_lissage');
  v_ref numeric;
  n integer;
begin
  create temp table if not exists _vecu (
    date_id uuid, partenaire uuid, satisfaction numeric, poursuite boolean
  ) on commit drop;
  delete from _vecu;

  insert into _vecu
  select d.id,
         case when d.user_a = u then d.user_b else d.user_a end,
         least(1, greatest(0,
           (coalesce(r.attirance, 0) + coalesce(r.valeurs, 0) + coalesce(r.mode_vie, 0))
           / nullif(3 * v_max, 0))),
         coalesce(f.decision = 'oui', false)
  from public.dates d
  join public.date_reviews r on r.date_id = d.id and r.user_id = u
  left join public.date_followups f on f.date_id = d.id and f.user_id = u
  where (d.user_a = u or d.user_b = u) and d.status = 'termine';

  select avg(satisfaction) into v_ref from _vecu;
  if v_ref is null then return 0; end if;

  with porte as (
    select v.satisfaction, v.poursuite, pa.criterion_key, o.idx as option_idx
    from _vecu v
    join public.profile_answers pa on pa.user_id = v.partenaire
    join public.criteria c on c.key = pa.criterion_key and c.direction = 'self'
    cross join lateral unnest(pa.option_idx) as o(idx)
    where (private.engine_param('appr_criteres_sensibles') >= 1 or c.sensitive_category is null)
  ),
  agg as (
    select criterion_key, option_idx,
           count(*)::int as rencontres,
           avg(satisfaction) as satisfaction_moy,
           count(*) filter (where poursuite)::int as poursuites,
           avg(case when poursuite then 1 else 0 end) as taux_poursuite
    from porte group by criterion_key, option_idx
  )
  insert into public.user_option_outcome as t
    (user_id, criterion_key, option_idx, rencontres, satisfaction_moy,
     poursuites, taux_poursuite, pouvoir_predictif, confiance, updated_at)
  select u, criterion_key, option_idx, rencontres,
         round(satisfaction_moy, 4), poursuites, round(taux_poursuite, 4),
         round((satisfaction_moy - v_ref) * (rencontres / (rencontres + v_k)), 4),
         round(rencontres / (rencontres + v_k), 4), now()
  from agg
  on conflict (user_id, criterion_key, option_idx) do update set
    rencontres = excluded.rencontres, satisfaction_moy = excluded.satisfaction_moy,
    poursuites = excluded.poursuites, taux_poursuite = excluded.taux_poursuite,
    pouvoir_predictif = excluded.pouvoir_predictif, confiance = excluded.confiance,
    updated_at = now();

  get diagnostics n = row_count;
  return n;
end $$;


--
-- Name: FUNCTION consolider_experience(u uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.consolider_experience(u uuid) IS 'Le retour post-rendez-vous ne modifie jamais la preference generale : il alimente une couche distincte. Une option peut rester tres attirante tout en cessant d''etre recommandee, sans que l''utilisateur ait a se dedire.';


--
-- Name: consolider_ponderations(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.consolider_ponderations(u uuid) RETURNS integer
    LANGUAGE plpgsql
    SET search_path TO 'public', 'private'
    AS $$
declare
  v_k numeric := private.engine_param('pond_lissage');
  n   integer;
begin
  with observe as (
    -- Ou l'attention s'est reellement portee, par type de recherche.
    -- Seuls les swipes dont la lecture d'attention est fiable comptent.
    select d.type_rencontre,
           sum(d.attention_physique * d.fiabilite_attention) as ph,
           sum(d.attention_mode_vie * d.fiabilite_attention) as mv,
           sum(d.attention_valeurs  * d.fiabilite_attention) as va,
           sum(d.fiabilite_attention)                        as masse,
           count(*)::int                                     as obs
    from public.swipe_decisions d
    where d.user_id = u
      and d.contexte = 'partir_en_date'
      and d.type_rencontre is not null
      and d.fiabilite_attention is not null
      and d.fiabilite_attention > 0
    group by d.type_rencontre
  ),
  melange as (
    select r.type_rencontre,
           coalesce(o.obs, 0) as obs,
           -- Poids de l'apprentissage face aux valeurs de reference
           coalesce(o.obs, 0) / (coalesce(o.obs, 0) + v_k) as alpha,
           r.poids_physique as d_ph, r.poids_mode_vie as d_mv, r.poids_valeurs as d_va,
           case when coalesce(o.masse, 0) > 0 then o.ph / o.masse end as a_ph,
           case when coalesce(o.masse, 0) > 0 then o.mv / o.masse end as a_mv,
           case when coalesce(o.masse, 0) > 0 then o.va / o.masse end as a_va,
           r.seuil_exigence
    from public.context_weight_defaults r
    left join observe o on o.type_rencontre = r.type_rencontre
  ),
  brut as (
    select type_rencontre, obs, seuil_exigence,
           (1 - alpha) * d_ph + alpha * coalesce(a_ph, d_ph) as ph,
           (1 - alpha) * d_mv + alpha * coalesce(a_mv, d_mv) as mv,
           (1 - alpha) * d_va + alpha * coalesce(a_va, d_va) as va,
           alpha
    from melange
  )
  insert into public.user_context_weights as w
    (user_id, type_rencontre, poids_physique, poids_mode_vie, poids_valeurs,
     seuil_exigence, observations, confiance, updated_at)
  select u, type_rencontre,
         round(ph / (ph + mv + va), 3),
         round(mv / (ph + mv + va), 3),
         round(va / (ph + mv + va), 3),
         seuil_exigence, obs, round(alpha, 3), now()
  from brut
  where ph + mv + va > 0
  on conflict (user_id, type_rencontre) do update set
    poids_physique = excluded.poids_physique,
    poids_mode_vie = excluded.poids_mode_vie,
    poids_valeurs  = excluded.poids_valeurs,
    observations   = excluded.observations,
    confiance      = excluded.confiance,
    updated_at     = now();

  get diagnostics n = row_count;
  return n;
end $$;


--
-- Name: FUNCTION consolider_ponderations(u uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.consolider_ponderations(u uuid) IS 'Les ponderations apprises ne remplacent jamais brutalement les valeurs de reference : elles les recouvrent progressivement, a mesure que les observations s''accumulent. Le seuil d''exigence n''est pas touche ici, il releve d''un reglage et non de l''attention.';


--
-- Name: consolider_preferences(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.consolider_preferences(u uuid) RETURNS integer
    LANGUAGE plpgsql
    SET search_path TO 'public', 'private'
    AS $$
declare
  v_fenetre int := private.engine_param('appr_fenetre_recente')::int;
  v_k       numeric := private.engine_param('appr_lissage_confiance');
  v_minobs  int := private.engine_param('appr_min_obs_option')::int;
  v_seuil   numeric := private.engine_param('appr_seuil_derive');
  v_sensibles boolean := private.engine_param('appr_criteres_sensibles') >= 1;
  n integer;
begin
  with base as (
    select d.id, d.decision, d.contexte, d.target_id,
           d.attention_physique, d.attention_mode_vie, d.attention_valeurs,
           d.fiabilite_attention, d.criteres_exposes, d.created_at,
           row_number() over (order by d.created_at desc) as rang
    from public.swipe_decisions d
    where d.user_id = u
  ),
  obs as (
    select b.id, b.decision, b.rang, b.created_at,
           pa.criterion_key, o.idx as option_idx, cp.grp,
           case when b.contexte = 'partir_en_date'
                then private.engine_param('poids_swipe_rencontre')
                else private.engine_param('poids_swipe_apprentissage') end
           *
           greatest(0.1, least(2.5,
             case
               when b.fiabilite_attention is null or b.fiabilite_attention = 0 then 1.0
               else (1 - b.fiabilite_attention)
                    + b.fiabilite_attention * 3 * coalesce(
                        case cp.grp
                          when 'physique' then b.attention_physique
                          when 'mode_vie' then b.attention_mode_vie
                          when 'valeurs'  then b.attention_valeurs
                        end, 0.3333)
             end)) as poids
    from base b
    join public.profile_answers pa on pa.user_id = b.target_id
    join public.criteria c   on c.key = pa.criterion_key and c.direction = 'self'
    join public.criterion_pairs cp on cp.pair_key = c.pair_key
    cross join lateral unnest(pa.option_idx) as o(idx)
    where (v_sensibles or c.sensitive_category is null)
      and (b.criteres_exposes is null or pa.criterion_key = any (b.criteres_exposes))
  ),
  cumul as (
    select criterion_key, option_idx,
           count(*)::int                                       as observations,
           count(*) filter (where decision)::int               as oui,
           coalesce(sum(poids), 0)                             as poids,
           -- Une option jamais acceptee doit valoir zero, pas nul :
           -- c'est le cas d'un critere fortement discriminant.
           coalesce(sum(poids) filter (where decision), 0)     as poids_oui,
           count(*) filter (where rang <= v_fenetre)::int      as obs_recentes,
           count(*) filter (where rang <= v_fenetre and decision)::int as oui_recents,
           max(created_at)                                     as derniere_vue
    from obs group by criterion_key, option_idx
  )
  insert into public.user_option_stats as t
    (user_id, criterion_key, option_idx, observations, oui, poids, poids_oui,
     obs_recentes, oui_recents, derniere_vue, updated_at)
  select u, criterion_key, option_idx, observations, oui, poids, poids_oui,
         obs_recentes, oui_recents, derniere_vue, now()
  from cumul
  on conflict (user_id, criterion_key, option_idx) do update set
    observations = excluded.observations, oui = excluded.oui,
    poids = excluded.poids, poids_oui = excluded.poids_oui,
    obs_recentes = excluded.obs_recentes, oui_recents = excluded.oui_recents,
    derniere_vue = excluded.derniere_vue, updated_at = now();

  with s as (
    select os.criterion_key, os.option_idx, os.observations, os.poids, os.poids_oui,
           os.obs_recentes, os.oui_recents,
           case when os.poids > 0 then os.poids_oui / os.poids end as taux_opt
    from public.user_option_stats os where os.user_id = u
  ),
  glob as (
    select criterion_key,
           sum(observations)::int as observations,
           case when sum(poids) > 0 then sum(poids_oui) / sum(poids) end as taux_oui,
           case when sum(obs_recentes) > 0
                then sum(oui_recents)::numeric / sum(obs_recentes) end as taux_recent
    from s group by criterion_key
  ),
  ecart as (
    select s.criterion_key,
           least(1, 2 * sum(abs(s.taux_opt - g.taux_oui) * s.poids)
                       / nullif(sum(s.poids), 0)) as importance
    from s join glob g on g.criterion_key = s.criterion_key
    where s.observations >= v_minobs and s.taux_opt is not null and g.taux_oui is not null
    group by s.criterion_key
  )
  insert into public.user_criterion_profile as p
    (user_id, criterion_key, grp, observations, taux_oui, taux_recent,
     importance, confiance, derive, updated_at)
  select u, g.criterion_key, cp.grp, g.observations,
         round(g.taux_oui, 4), round(g.taux_recent, 4),
         round(coalesce(e.importance, 0), 4),
         round(g.observations / (g.observations + v_k), 4),
         coalesce(abs(g.taux_recent - g.taux_oui) >= v_seuil, false),
         now()
  from glob g
  left join ecart e on e.criterion_key = g.criterion_key
  left join public.criteria c on c.key = g.criterion_key
  left join public.criterion_pairs cp on cp.pair_key = c.pair_key
  on conflict (user_id, criterion_key) do update set
    grp = excluded.grp, observations = excluded.observations,
    taux_oui = excluded.taux_oui, taux_recent = excluded.taux_recent,
    importance = excluded.importance, confiance = excluded.confiance,
    derive = excluded.derive, updated_at = now();

  get diagnostics n = row_count;
  return n;
end $$;


--
-- Name: FUNCTION consolider_preferences(u uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.consolider_preferences(u uuid) IS 'Recalcul complet et idempotent pour un utilisateur. L''importance mesure la variation du taux d''acceptation entre les options d''un meme critere, pas le taux lui-meme : quatre-vingt-dix pour cent de oui sur toutes les options signifie que le critere ne discrimine rien.';


--
-- Name: consolider_utilisateur(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.consolider_utilisateur(u uuid) RETURNS jsonb
    LANGUAGE plpgsql
    SET search_path TO 'public', 'private'
    AS $$
begin
  return jsonb_build_object(
    'criteres',     private.consolider_preferences(u),
    'ponderations', private.consolider_ponderations(u),
    'experience',   private.consolider_experience(u),
    'consolide_a',  now());
end $$;


--
-- Name: contact_fictif(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.contact_fictif(u uuid) RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select f.id from fake_contacts f
  where f.active
    and f.genre = coalesce((
      select case when a.option_idx[1] = 0 then 'homme'
                  when a.option_idx[1] = 1 then 'femme' end
      from profile_answers a where a.user_id = u and a.criterion_key = 'genre_moi'), 'femme')
  order by random() limit 1;
$$;


--
-- Name: contexte_swipe(bigint); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.contexte_swipe(p_swipe bigint) RETURNS jsonb
    LANGUAGE sql STABLE
    SET search_path TO 'public', 'private'
    AS $$
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
$$;


--
-- Name: couverture_criteres(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.couverture_criteres(u uuid) RETURNS TABLE(criterion_key text, grp public.score_group, libelle text, observations integer, confiance numeric, documente boolean)
    LANGUAGE sql STABLE
    SET search_path TO 'public', 'private'
    AS $$
  select c.key, cp.grp, c.question,
         coalesce(p.observations, 0),
         coalesce(p.confiance, 0),
         coalesce(p.confiance, 0) >= private.engine_param('expl_confiance_acquise')
  from public.criteria c
  join public.criterion_pairs cp on cp.pair_key = c.pair_key
  left join public.user_criterion_profile p on p.user_id = u and p.criterion_key = c.key
  where c.direction = 'self'
    and (private.engine_param('appr_criteres_sensibles') >= 1 or c.sensitive_category is null)
  order by coalesce(p.observations, 0) asc, cp.grp;
$$;


--
-- Name: FUNCTION couverture_criteres(u uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.couverture_criteres(u uuid) IS 'Etat de connaissance critere par critere. Comparer un critere a deux mille observations avec un critere a trois n''a aucun sens : c''est cette lecture qui permet d''eviter cette faute.';


--
-- Name: creer_demande(uuid, uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.creer_demande(u uuid, cible uuid) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
declare v_id uuid; v_quota integer; v_taux numeric;
begin
  if u = cible then
    raise exception 'Impossible de s''adresser une demande à soi-même' using errcode = 'check_violation';
  end if;
  if private.compte_bloque(u) then
    raise exception 'Régularisation requise avant toute nouvelle action' using errcode = 'check_violation';
  end if;
  if not exists (select 1 from profiles p where p.id = cible and p.is_active and p.is_verified) then
    raise exception 'Profil indisponible' using errcode = 'no_data_found';
  end if;
  if are_blocked(u, cible) then
    raise exception 'Profil indisponible' using errcode = 'no_data_found';
  end if;
  if exists (select 1 from chat_requests r
             where r.from_user = u and r.to_user = cible
               and r.status = 'en_attente' and r.expires_at > now()) then
    raise exception 'Une demande est déjà en attente auprès de cette personne' using errcode = 'unique_violation';
  end if;

  v_quota := private.quota_restant(u);
  if v_quota is not null and v_quota <= 0 then
    raise exception 'Limite quotidienne de nouvelles discussions atteinte' using errcode = 'check_violation';
  end if;

  select s.score_global into v_taux from private.compat_score(u, cible) s;

  insert into chat_requests (from_user, to_user, compat_rate, expires_at)
  values (u, cible, v_taux,
          now() + (private.engine_param('demande_expiration_s') || ' seconds')::interval)
  returning id into v_id;
  return v_id;
end $$;


--
-- Name: critere_a_isoler(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.critere_a_isoler(u uuid) RETURNS text
    LANGUAGE sql STABLE
    SET search_path TO 'public', 'private'
    AS $$
  select c.key
  from public.criteria c
  join public.criterion_pairs cp on cp.pair_key = c.pair_key
  left join public.user_criterion_profile p on p.user_id = u and p.criterion_key = c.key
  where c.direction = 'self'
    and cp.affichable_apprentissage
    and (private.engine_param('appr_criteres_sensibles') >= 1 or c.sensitive_category is null)
    and coalesce(p.confiance, 0) < private.engine_param('contraste_conf_max')
    -- Il faut au moins deux valeurs distinctes dans le vivier pour contraster
    and (select count(distinct o.idx) from public.profile_answers pa,
                lateral unnest(pa.option_idx) o(idx)
          where pa.criterion_key = c.key) >= 2
  order by (1 - coalesce(p.confiance, 0)) * coalesce(cp.base_weight, 1) desc, random()
  limit 1;
$$;


--
-- Name: FUNCTION critere_a_isoler(u uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.critere_a_isoler(u uuid) IS 'Retient le critere le plus mal connu parmi les plus structurants, a condition que le vivier contienne au moins deux valeurs differentes : sans variation, aucun contraste n''est possible.';


--
-- Name: dealbreakers_bloquants(uuid, uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.dealbreakers_bloquants(a uuid, b uuid) RETURNS text[]
    LANGUAGE sql STABLE
    SET search_path TO 'public', 'private'
    AS $$
  with va as (select * from profile_vectors where user_id = a),
       vb as (select * from profile_vectors where user_id = b)
  select coalesce(array_agg(p.pair_key order by p.pair_key), '{}')
  from criterion_pairs p, va, vb
  where p.is_absolute and not p.filtre_cadrage
    and (
      (va.pref_mask[p.slot+1] is not null and vb.self_mask[p.slot+1] is not null
       and (vb.self_mask[p.slot+1] & va.pref_mask[p.slot+1]) = 0)
      or
      (vb.pref_mask[p.slot+1] is not null and va.self_mask[p.slot+1] is not null
       and (va.self_mask[p.slot+1] & vb.pref_mask[p.slot+1]) = 0)
    );
$$;


--
-- Name: FUNCTION dealbreakers_bloquants(a uuid, b uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.dealbreakers_bloquants(a uuid, b uuid) IS 'Reserve a l''usage interne et au support. Ne jamais renvoyer tel quel a l''emetteur : la liste des criteres bloquants permettrait de reconstituer les reponses du profil cible.';


--
-- Name: decider_poursuite(uuid, uuid, public.date_intent); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.decider_poursuite(u uuid, d_id uuid, p_decision public.date_intent) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
declare
  d dates; v_autre uuid; v_autre_dec date_intent; v_conv uuid; v_help boolean;
begin
  select * into d from dates where id = d_id and (user_a = u or user_b = u);
  if d is null then
    raise exception 'Rendez-vous introuvable' using errcode = 'no_data_found';
  end if;
  if not private.evaluations_disponibles(d_id) then
    raise exception 'Décision disponible une fois les deux utilisateurs éloignés'
      using errcode = 'check_violation';
  end if;

  v_autre := case when d.user_a = u then d.user_b else d.user_a end;

  -- Apres un recours au bouton Help, la poursuite n'est jamais proposee
  -- et la conversation est definitivement close.
  select exists (select 1 from help_requests h where h.date_id = d_id) into v_help;
  if v_help then
    update conversations set status = 'cloturee' where id = d.conversation_id;
    return jsonb_build_object('issue', 'securite',
      'message', 'Conversation close pour raisons de sécurité.');
  end if;

  insert into date_followups (date_id, user_id, decision)
  values (d_id, u, p_decision)
  on conflict (date_id, user_id) do update set
    decision = excluded.decision, decided_at = now();

  select decision into v_autre_dec from date_followups
   where date_id = d_id and user_id = v_autre;

  -- Tant que les deux reponses ne sont pas enregistrees, rien n'est revele.
  if v_autre_dec is null or p_decision = 'plus_tard' or v_autre_dec = 'plus_tard' then
    return jsonb_build_object('issue', 'en_attente');
  end if;

  if p_decision = 'oui' and v_autre_dec = 'oui' then
    update conversations
       set status = 'active', locked_at = null, illimitee = true
     where id = d.conversation_id
    returning id into v_conv;
    return jsonb_build_object('issue', 'reciproque', 'conversation', v_conv);
  end if;

  -- Reponses divergentes : on ne revele jamais qui a decline.
  update conversations set status = 'cloturee' where id = d.conversation_id;
  return jsonb_build_object('issue', 'terminee',
    'notifier_en_differe', case when p_decision = 'oui' then u
                                when v_autre_dec = 'oui' then v_autre end);
end $$;


--
-- Name: FUNCTION decider_poursuite(u uuid, d_id uuid, p_decision public.date_intent); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.decider_poursuite(u uuid, d_id uuid, p_decision public.date_intent) IS 'Le choix de l''autre n''est jamais revele avant que les deux reponses soient enregistrees, et en cas de divergence on ne revele jamais lequel des deux a decline. notifier_en_differe designe l''utilisateur a prevenir quelques instants plus tard en messagerie.';


--
-- Name: declencher_focus(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.declencher_focus(u uuid) RETURNS uuid
    LANGUAGE plpgsql
    SET search_path TO 'public', 'private'
    AS $$
declare v_cand record; v_cle text; v_question text; v_id uuid;
begin
  if exists (select 1 from public.focus_compatibilite
             where user_id = u and answered_at is null) then return null; end if;
  if exists (select 1 from public.focus_compatibilite
             where user_id = u
               and created_at > now() - (private.engine_param('focus_cooldown_h') || ' hours')::interval)
  then return null; end if;

  select * into v_cand from private.focus_candidat(u);
  if not found then return null; end if;

  -- Cinq refus consecutifs sont un declencheur potentiel, pas une regle.
  if random() > private.engine_param('focus_proba_serie') then return null; end if;

  select c.key, c.question into v_cle, v_question
  from public.criteria c where c.pair_key = v_cand.pair_key and c.direction = 'pref' limit 1;
  if v_cle is null then return null; end if;

  insert into public.focus_compatibilite (user_id, context, criterion_key, sens, question)
  values (u, 'swipe', v_cle, v_cand.sens, v_question)
  returning id into v_id;
  return v_id;
end $$;


--
-- Name: FUNCTION declencher_focus(u uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.declencher_focus(u uuid) IS 'Une seule question en attente a la fois, et un delai minimal entre deux. Sans ces deux garde-fous, un utilisateur difficile serait interroge en continu et abandonnerait.';


--
-- Name: declencher_focus_erreur(uuid, bigint); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.declencher_focus_erreur(u uuid, p_swipe bigint) RETURNS uuid
    LANGUAGE plpgsql
    SET search_path TO 'public', 'private'
    AS $$
declare d public.swipe_decisions; v_id uuid;
begin
  select * into d from public.swipe_decisions where id = p_swipe;
  if d.erreur_prediction is null
     or d.erreur_prediction < private.engine_param('focus_seuil_erreur') then return null; end if;

  if exists (select 1 from public.focus_compatibilite
             where user_id = u and answered_at is null) then return null; end if;

  if exists (select 1 from public.focus_compatibilite
             where user_id = u
               and created_at > now() - (private.engine_param('focus_cooldown_h') || ' hours')::interval)
  then return null; end if;

  if random() > private.engine_param('focus_proba_erreur') then return null; end if;

  insert into public.focus_compatibilite
    (user_id, context, target_user_id, swipe_id, sens, question, options)
  values (u, 'erreur_prediction', d.target_id, p_swipe, d.decision,
          case when d.decision
               then 'Qu''est-ce qui t''a particulièrement attiré dans ce profil ?'
               else 'Qu''est-ce qui correspondait le moins à tes goûts ?' end,
          '[{"cle":"physique","label":"Son apparence"},
            {"cle":"mode_vie","label":"Son mode de vie"},
            {"cle":"valeurs","label":"Ses valeurs"},
            {"cle":"personnalite","label":"Sa personnalité"},
            {"cle":"indefini","label":"Difficile à dire"}]'::jsonb)
  returning id into v_id;
  return v_id;
end $$;


--
-- Name: FUNCTION declencher_focus_erreur(u uuid, p_swipe bigint); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.declencher_focus_erreur(u uuid, p_swipe bigint) IS 'Declenche apres un ecart marque entre prediction et comportement. La question porte sur la categorie qui a emporte la decision, pas sur un critere precis : quand le modele se trompe, il ignore justement lequel interroger.';


--
-- Name: declencher_help(uuid, uuid, public.help_level); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.declencher_help(u uuid, d_id uuid, niveau public.help_level) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
declare d dates; v_id uuid; v_contact uuid; v_msg text; v_prenom text;
begin
  select * into d from dates where id = d_id and (user_a = u or user_b = u);
  if d is null then
    raise exception 'Rendez-vous introuvable' using errcode = 'no_data_found';
  end if;

  if niveau = 'discret' then
    v_contact := private.contact_fictif(u);
    select prenom, message_template into v_prenom, v_msg
      from fake_contacts where id = v_contact;
  end if;

  insert into help_requests (date_id, user_id, level, fake_contact_id, partner_notified_at)
  values (d_id, u, niveau, v_contact,
          case when niveau in ('etablissement','angela','urgence') then now() end)
  returning id into v_id;

  -- L'autre utilisateur n'est jamais informe, et l'etablissement ne
  -- recoit jamais la nature exacte de la demande.
  return jsonb_build_object(
    'demande_id', v_id,
    'niveau', niveau,
    'contact_fictif', case when v_contact is not null
                      then jsonb_build_object('prenom', v_prenom, 'message', v_msg) end,
    'etablissement_notifie', niveau in ('etablissement','angela','urgence'),
    'partenaire_informe', false);
end $$;


--
-- Name: FUNCTION declencher_help(u uuid, d_id uuid, niveau public.help_level); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.declencher_help(u uuid, d_id uuid, niveau public.help_level) IS 'Quatre niveaux : assistance discrete (contact fictif), demande a l''etablissement, mot-cle Angela, urgence. L''autre utilisateur n''en est jamais informe.';


--
-- Name: declencher_question(uuid, bigint); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.declencher_question(u uuid, p_swipe bigint DEFAULT NULL::bigint) RETURNS uuid
    LANGUAGE plpgsql
    SET search_path TO 'public', 'private'
    AS $$
declare v_depuis int; v_dernier bigint; v_cand record; v_id uuid;
begin
  if exists (select 1 from public.focus_compatibilite
             where user_id = u and answered_at is null) then return null; end if;

  -- On compte des profils, pas des secondes : l'horodatage est constant
  -- a l'interieur d'une transaction et ne peut pas servir de compteur.
  select coalesce(max(swipe_id), 0) into v_dernier
  from public.focus_compatibilite
  where user_id = u and context = 'question_intermediaire';

  select count(*) into v_depuis
  from public.swipe_decisions s
  where s.user_id = u and s.contexte = 'mieux_me_connaitre' and s.id > v_dernier;

  if v_depuis < private.cadence_questions(u) then return null; end if;
  if random() > private.engine_param('quest_proba') then return null; end if;

  select * into v_cand from private.question_candidate(u);
  if not found then return null; end if;

  insert into public.focus_compatibilite (user_id, context, criterion_key, question, swipe_id)
  values (u, 'question_intermediaire', v_cand.criterion_key, v_cand.question, p_swipe)
  returning id into v_id;
  return v_id;
end $$;


--
-- Name: FUNCTION declencher_question(u uuid, p_swipe bigint); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.declencher_question(u uuid, p_swipe bigint) IS 'La cadence se mesure en profils vus depuis la derniere question, reperes par identifiant. Compter sur l''horodatage serait incorrect : plusieurs swipes d''une meme transaction partagent la meme heure.';


--
-- Name: derive_priorities(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.derive_priorities(u uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
  with declare_poids as (select cp.pair_key,
      coalesce(min(m.weight_multiplier),1.0) as poids_declare,
      coalesce(max(s.entropie),1.0) as entropie
    from criterion_pairs cp
    join profile_answers pa on pa.user_id=u and pa.criterion_key=cp.pref_key
    left join option_mappings m on m.pair_key=cp.pair_key and m.pref_idx = any(pa.option_idx)
    left join private.criterion_stats s on s.criterion_key=cp.pref_key
    group by cp.pair_key),
  classe as (select pair_key,
      row_number() over (order by poids_declare desc, entropie desc, pair_key)::smallint as rang
    from declare_poids
    where pair_key not in (select pair_key from user_criterion_priorities where user_id=u and manuel))
  insert into user_criterion_priorities (user_id, pair_key, rang, manuel)
  select u, pair_key,
    (rang + (select count(*) from user_criterion_priorities where user_id=u and manuel))::smallint, false
  from classe
  on conflict (user_id, pair_key) do update set rang = excluded.rang
    where not user_criterion_priorities.manuel;
  perform private.refresh_profile_vectors(u);
end $$;


--
-- Name: distance_palier(uuid, uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.distance_palier(a uuid, b uuid) RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select case
    when pa.last_location is null or pb.last_location is null then null
    when d <   1000 then 'moins de 1 km'
    when d <   5000 then '1 a 5 km'
    when d <  10000 then '5 a 10 km'
    when d <  25000 then '10 a 25 km'
    when d <  50000 then '25 a 50 km'
    else 'plus de 50 km'
  end
  from profiles pa, profiles pb,
       lateral (select st_distance(pa.last_location, pb.last_location) as d) x
  where pa.id = a and pb.id = b;
$$;


--
-- Name: FUNCTION distance_palier(a uuid, b uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.distance_palier(a uuid, b uuid) IS 'Ne publie jamais la distance exacte. Un palier suffit a situer l''autre sans permettre de le localiser par recoupement.';


--
-- Name: distance_utilisateurs(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.distance_utilisateurs(d_id uuid) RETURNS double precision
    LANGUAGE sql STABLE
    AS $$
  select st_distance(a.last_location, b.last_location)
  from dates d
  join profiles a on a.id = d.user_a
  join profiles b on b.id = d.user_b
  where d.id = d_id;
$$;


--
-- Name: eligible_candidates(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.eligible_candidates(u uuid) RETURNS TABLE(candidate_id uuid)
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
  select p.id from profiles p
  where p.id <> u and p.is_active and p.is_verified and not are_blocked(u, p.id)
    and not exists (select 1 from reports r
                    where r.reported_id = p.id and r.status in ('nouveau','en_cours'))
    and not exists (select 1 from dates d
                    where (d.user_a = p.id or d.user_b = p.id)
                      and d.status in ('en_preparation','confirme','en_cours'))
    and not private.compte_bloque(p.id)
    and not exists (select 1 from dates d
                    where (d.user_a = u or d.user_b = u)
                      and d.status in ('en_preparation','confirme','en_cours'));
$$;


--
-- Name: engine_param(text); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.engine_param(k text) RETURNS numeric
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$ select value from engine_params where key = k $$;


--
-- Name: engine_params_all(); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.engine_params_all() RETURNS TABLE(key text, value numeric)
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$ select key, value from engine_params $$;


--
-- Name: enregistrer_swipe(uuid, uuid, boolean, public.swipe_contexte, boolean, text, integer, jsonb, public.score_group[], integer, text[], text[], public.rencontre_type, bigint); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.enregistrer_swipe(u uuid, cible uuid, p_garde boolean, p_contexte public.swipe_contexte DEFAULT 'partir_en_date'::public.swipe_contexte, p_fort boolean DEFAULT false, p_ecran text DEFAULT NULL::text, p_duree integer DEFAULT NULL::integer, p_ecrans jsonb DEFAULT NULL::jsonb, p_ordre public.score_group[] DEFAULT NULL::public.score_group[], p_retours integer DEFAULT 0, p_exposes text[] DEFAULT NULL::text[], p_consultes text[] DEFAULT NULL::text[], p_type public.rencontre_type DEFAULT NULL::public.rencontre_type, p_presentation bigint DEFAULT NULL::bigint) RETURNS uuid
    LANGUAGE plpgsql
    SET search_path TO 'public', 'private'
    AS $$
declare
  v_id bigint; v_score numeric; v_seuil numeric; v_err numeric;
  v_pres public.profile_presentations;
  v_vues public.score_group[]; v_ignore public.score_group[];
  v_exposes text[] := p_exposes;
begin
  if u = cible then
    raise exception 'Cible invalide' using errcode = 'check_violation';
  end if;

  if p_presentation is not null then
    select * into v_pres from public.profile_presentations
     where id = p_presentation and observer_id = u and target_id = cible;
    if v_pres.id is null then
      raise exception 'Présentation introuvable' using errcode = 'no_data_found';
    end if;
    v_exposes := private.cles_presentation(p_presentation);
  end if;

  if p_contexte = 'partir_en_date' and p_type is not null then
    select s.score, s.seuil into v_score, v_seuil
    from private.score_contextuel(u, cible, p_type) s;
    if v_score is not null then
      v_err := greatest(0, least(1,
        round(abs((case when p_garde then 1 else 0 end) - v_score / 100.0), 4)));
    end if;
  end if;

  insert into public.swipe_decisions
    (user_id, target_id, decision, contexte, type_rencontre, signal_fort, ecran, duree_ms,
     duree_totale_ms, ordre_consultation, retours, criteres_exposes, criteres_consultes,
     score_predit, seuil_predit, erreur_prediction, presentation_id, snapshot)
  values
    (u, cible, p_garde, p_contexte, p_type, p_fort, p_ecran, p_duree,
     p_duree, p_ordre, coalesce(p_retours, 0)::smallint, v_exposes, p_consultes,
     v_score, v_seuil, v_err, p_presentation,
     jsonb_build_object(
       'age',         (select h.age from private.profile_header(cible) h),
       'verifie',     (select h.profil_verifie from private.profile_header(cible) h),
       'ordre_servi', v_pres.ordre_pages,
       'vecteur_le',  (select v.refreshed_at from public.profile_vectors v where v.user_id = cible)))
  returning id into v_id;

  if p_ecrans is not null then
    insert into public.swipe_ecrans (swipe_id, ecran, duree_ms, consultations)
    select v_id, (e->>'ecran')::public.score_group,
           coalesce((e->>'duree_ms')::int, 0), coalesce((e->>'consultations')::smallint, 1)
    from jsonb_array_elements(p_ecrans) e
    on conflict (swipe_id, ecran) do update
      set duree_ms      = public.swipe_ecrans.duree_ms + excluded.duree_ms,
          consultations = public.swipe_ecrans.consultations + excluded.consultations;
    perform private.calculer_attention(v_id);

    select array_agg(ecran) into v_vues
    from public.swipe_ecrans where swipe_id = v_id and duree_ms > 0;

    if v_pres.ordre_pages is not null then
      select array_agg(g) into v_ignore from unnest(v_pres.ordre_pages) g
      where v_vues is null or not (g = any (v_vues));
    end if;

    update public.swipe_decisions
       set pages_ignorees  = case when v_pres.ordre_pages is not null
                                  then coalesce(v_ignore, '{}'::public.score_group[]) end,
           vitesse_ms_page = case when coalesce(cardinality(v_vues), 0) > 0
                                  then (select sum(duree_ms) / cardinality(v_vues)
                                        from public.swipe_ecrans where swipe_id = v_id) end
     where id = v_id;
  end if;

  if p_contexte = 'mieux_me_connaitre' then
    return private.apprentissage_apres_swipe(u, v_id);
  end if;

  if not p_garde then
    perform private.exclure(u, cible, u, 'refus_conversation', interval '30 days');
  end if;

  return private.declencher_focus_erreur(u, v_id);
end $$;


--
-- Name: FUNCTION enregistrer_swipe(u uuid, cible uuid, p_garde boolean, p_contexte public.swipe_contexte, p_fort boolean, p_ecran text, p_duree integer, p_ecrans jsonb, p_ordre public.score_group[], p_retours integer, p_exposes text[], p_consultes text[], p_type public.rencontre_type, p_presentation bigint); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.enregistrer_swipe(u uuid, cible uuid, p_garde boolean, p_contexte public.swipe_contexte, p_fort boolean, p_ecran text, p_duree integer, p_ecrans jsonb, p_ordre public.score_group[], p_retours integer, p_exposes text[], p_consultes text[], p_type public.rencontre_type, p_presentation bigint) IS 'Quand une presentation est fournie, elle fait foi sur ce qui a ete montre : les criteres exposes en sont deduits et les pages servies mais jamais ouvertes sont calculees par difference avec les pages effectivement consultees.';


--
-- Name: envoyer_message(uuid, uuid, public.message_kind, text, text, integer); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.envoyer_message(u uuid, conv uuid, p_kind public.message_kind DEFAULT 'texte'::public.message_kind, p_body text DEFAULT NULL::text, p_media text DEFAULT NULL::text, p_duree integer DEFAULT NULL::integer) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
declare c conversations; v_motif text; v_id uuid;
begin
  select * into c from conversations where id = conv and (user_a = u or user_b = u);
  if c is null then
    raise exception 'Conversation introuvable' using errcode = 'no_data_found';
  end if;
  if c.status <> 'active' then
    raise exception 'Cette conversation est verrouillée' using errcode = 'check_violation';
  end if;
  if not c.illimitee and c.ends_at <= now() then
    raise exception 'Le temps imparti est écoulé' using errcode = 'check_violation';
  end if;

  -- La photographie n'est autorisee qu'apres un rendez-vous, lorsque les
  -- deux utilisateurs ont souhaite poursuivre la discussion.
  if p_kind = 'photo' and not c.illimitee then
    raise exception 'L''envoi de photographies n''est pas autorisé avant le rendez-vous'
      using errcode = 'check_violation';
  end if;

  -- Avant le rendez-vous, rien ne doit permettre de quitter l'ecosysteme.
  if not c.illimitee and p_kind = 'texte' then
    v_motif := private.motif_interdit(p_body);
    if v_motif is not null then
      raise exception 'Message refusé : partage d''un(e) % non autorisé avant le rendez-vous', v_motif
        using errcode = 'check_violation';
    end if;
  end if;

  insert into messages (conversation_id, sender_id, kind, body, audio_path, duration_ms)
  values (conv, u, p_kind, p_body, coalesce(p_media, null), p_duree)
  returning id into v_id;
  return v_id;
end $$;


--
-- Name: envoyer_messages_plateforme(); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.envoyer_messages_plateforme() RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare n integer;
begin
  update platform_messages set envoye_at = now()
   where envoye_at is null and a_envoyer_a <= now();
  get diagnostics n = row_count;
  return n;
end $$;


--
-- Name: escalade_recommandee(uuid, public.report_reason); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.escalade_recommandee(u uuid, p_motif public.report_reason DEFAULT NULL::public.report_reason) RETURNS public.moderation_action
    LANGUAGE plpgsql STABLE
    AS $$
declare n integer; v_grave boolean;
begin
  select count(*) into n from moderation_actions m
   where m.user_id = u and m.action <> 'classe_sans_suite';

  -- Certains motifs ne se graduent pas : ils appellent une mesure
  -- immediate, quel que soit l'historique.
  v_grave := p_motif in ('mineur','violence');
  if v_grave then
    return 'bannissement';
  end if;

  return case
    when n >= private.engine_param('moderation_seuil_bannissement')  then 'bannissement'
    when n >= private.engine_param('moderation_seuil_suspension')    then 'suspension_temporaire'
    when n >= private.engine_param('moderation_seuil_avertissement') then 'avertissement'
    else 'rappel_regles'
  end::moderation_action;
end $$;


--
-- Name: FUNCTION escalade_recommandee(u uuid, p_motif public.report_reason); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.escalade_recommandee(u uuid, p_motif public.report_reason) IS 'Mesure proposee au moderateur. La suspicion de minorite ou de violence court-circuite la graduation et appelle une mesure immediate.';


--
-- Name: est_exclu(uuid, uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.est_exclu(a uuid, b uuid) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'private'
    AS $$
  select exists (
    select 1 from public.profile_exclusions e
    where e.user_lo = least(a,b)
      and e.user_hi = greatest(a,b)
      and (e.expires_at is null or e.expires_at > now())
  );
$$;


--
-- Name: etat_conversation(uuid, uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.etat_conversation(u uuid, p_conv uuid) RETURNS TABLE(statut public.conversation_status, autre uuid, prenom_autre text, autre_en_ligne boolean, secondes_restantes integer, message text)
    LANGUAGE sql STABLE
    SET search_path TO 'public', 'private'
    AS $$
  with c as (select * from public.conversations where id = p_conv and (user_a = u or user_b = u)),
       a as (select case when c.user_a = u then c.user_b else c.user_a end as autre from c)
  select c.status, a.autre, p.prenom,
         coalesce(p.last_seen_at > now() - (private.engine_param('presence_fraicheur_s') || ' seconds')::interval, false),
         case when c.status = 'active' and c.ends_at is not null
              then greatest(0, extract(epoch from c.ends_at - now()))::int end,
         case
           when c.status = 'prete'
                and coalesce(p.last_seen_at > now() - (private.engine_param('presence_fraicheur_s') || ' seconds')::interval, false)
             then p.prenom || ' est de nouveau en ligne. Votre conversation est prête à commencer.'
           when c.status = 'prete'
             then 'Votre conversation est prête. Nous attendons que vous soyez tous les deux disponibles.'
           when c.status = 'active'      then 'Conversation en cours.'
           when c.status = 'verrouillee' then 'Le temps est écoulé.'
           else 'Conversation close.'
         end
  from c, a
  join public.profiles p on p.id = a.autre;
$$;


--
-- Name: FUNCTION etat_conversation(u uuid, p_conv uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.etat_conversation(u uuid, p_conv uuid) IS 'Le message distingue les deux situations d''attente : l''autre est hors ligne, ou l''autre vient de revenir. La seconde appelle une notification, pas la premiere.';


--
-- Name: etat_session(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.etat_session(u uuid) RETURNS TABLE(profils_vus integer, quota integer, restants integer, illimite boolean, niveau numeric)
    LANGUAGE sql STABLE
    SET search_path TO 'public', 'private'
    AS $$
  with prem as (select coalesce(is_premium, false) as p from public.profiles where id = u),
       q as (select private.engine_param('session_quota_gratuit')::int as v),
       vus as (
         select count(*)::int as n from public.swipe_decisions
         where user_id = u and contexte = 'mieux_me_connaitre'
           and created_at >= date_trunc('day', now())
       )
  select vus.n, q.v,
         case when prem.p or q.v = 0 then null else greatest(0, q.v - vus.n) end,
         (prem.p or q.v = 0),
         private.niveau_connaissance(u)
  from prem, q, vus;
$$;


--
-- Name: evaluations_disponibles(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.evaluations_disponibles(d_id uuid) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  select coalesce(private.distance_utilisateurs(d_id)
                  >= private.engine_param('distance_evaluation_m'), false);
$$;


--
-- Name: FUNCTION evaluations_disponibles(d_id uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.evaluations_disponibles(d_id uuid) IS 'Les evaluations ne sont proposees qu''une fois les deux utilisateurs suffisamment eloignes, afin que chacun reponde librement, sans influence ni gene.';


--
-- Name: evaluer_candidats(uuid, uuid[]); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.evaluer_candidats(u uuid, p_ids uuid[]) RETURNS TABLE(profil_id uuid, besoin numeric, attendu numeric, inedit numeric)
    LANGUAGE sql STABLE
    SET search_path TO 'public', 'private'
    AS $$
  with sensible as (select private.engine_param('appr_criteres_sensibles') >= 1 as ok),
  reps as (
    select pa.user_id as cible, pa.criterion_key, o.idx as option_idx
    from public.profile_answers pa
    join public.criteria c on c.key = pa.criterion_key and c.direction = 'self'
    cross join lateral unnest(pa.option_idx) as o(idx)
    cross join sensible s
    where pa.user_id = any (p_ids) and (s.ok or c.sensitive_category is null)
  )
  select r.cible,
         round(avg(1 - coalesce(pr.confiance, 0)), 4),
         round(coalesce(
           sum(coalesce(os.poids_oui / nullif(os.poids, 0), 0.5)
               * coalesce(pr.importance, 0) * coalesce(pr.confiance, 0))
           / nullif(sum(coalesce(pr.importance, 0) * coalesce(pr.confiance, 0)), 0),
           0.5), 4),
         round(avg(case when coalesce(os.observations, 0) = 0 then 1 else 0 end), 4)
  from reps r
  left join public.user_criterion_profile pr
         on pr.user_id = u and pr.criterion_key = r.criterion_key
  left join public.user_option_stats os
         on os.user_id = u and os.criterion_key = r.criterion_key and os.option_idx = r.option_idx
  group by r.cible;
$$;


--
-- Name: FUNCTION evaluer_candidats(u uuid, p_ids uuid[]); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.evaluer_candidats(u uuid, p_ids uuid[]) IS 'besoin mesure l''ignorance du moteur, attendu la probabilite d''acceptation. Le premier sert l''exploration, le second l''exploitation. attendu vaut 0,5 par defaut : sans connaissance, aucune prediction n''est faite.';


--
-- Name: evaluer_etablissement(uuid, uuid, smallint, smallint, smallint, numeric, text, boolean); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.evaluer_etablissement(u uuid, d_id uuid, p_produits smallint, p_rapport_qp smallint, p_service smallint, p_globale numeric DEFAULT NULL::numeric, p_commentaire text DEFAULT NULL::text, p_publier_google boolean DEFAULT false) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
declare v_partner uuid; v_moyenne numeric;
begin
  select partner_id into v_partner from dates
   where id = d_id and (user_a = u or user_b = u);
  if v_partner is null then
    raise exception 'Rendez-vous introuvable' using errcode = 'no_data_found';
  end if;

  -- Moyenne proposee automatiquement, mais l'utilisateur garde le dernier mot.
  v_moyenne := round((p_produits + p_rapport_qp + p_service)::numeric / 3, 2);

  insert into venue_reviews (date_id, user_id, partner_id, note_produits,
    note_rapport_qp, note_service, note_globale, commentaire,
    publier_google, status, submitted_at)
  values (d_id, u, v_partner, p_produits, p_rapport_qp, p_service,
          coalesce(p_globale, v_moyenne), p_commentaire,
          p_publier_google, 'soumis', now())
  on conflict (date_id, user_id) do update set
    note_produits = excluded.note_produits, note_rapport_qp = excluded.note_rapport_qp,
    note_service = excluded.note_service, note_globale = excluded.note_globale,
    commentaire = excluded.commentaire, publier_google = excluded.publier_google,
    status = 'soumis', submitted_at = now();

  return coalesce(p_globale, v_moyenne);
end $$;


--
-- Name: evaluer_rencontre(uuid, uuid, smallint, smallint, smallint, text); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.evaluer_rencontre(u uuid, d_id uuid, p_attirance smallint, p_valeurs smallint, p_mode_vie smallint, p_commentaire text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
  if not exists (select 1 from dates where id = d_id and (user_a = u or user_b = u)) then
    raise exception 'Rendez-vous introuvable' using errcode = 'no_data_found';
  end if;
  if not private.evaluations_disponibles(d_id) then
    raise exception 'Évaluation disponible une fois les deux utilisateurs éloignés'
      using errcode = 'check_violation';
  end if;

  insert into date_reviews (date_id, user_id, attirance, valeurs, mode_vie, commentaire)
  values (d_id, u, p_attirance, p_valeurs, p_mode_vie, p_commentaire)
  on conflict (date_id, user_id) do update set
    attirance = excluded.attirance, valeurs = excluded.valeurs,
    mode_vie = excluded.mode_vie, commentaire = excluded.commentaire;
end $$;


--
-- Name: FUNCTION evaluer_rencontre(u uuid, d_id uuid, p_attirance smallint, p_valeurs smallint, p_mode_vie smallint, p_commentaire text); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.evaluer_rencontre(u uuid, d_id uuid, p_attirance smallint, p_valeurs smallint, p_mode_vie smallint, p_commentaire text) IS 'Strictement confidentiel : jamais communique au partenaire. Le declencheur date_reviews_apprentissage exploite les trois notes, chacune sur sa dimension.';


--
-- Name: exclure(uuid, uuid, uuid, public.exclusion_reason, interval, uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.exclure(a uuid, b uuid, p_initiator uuid, p_reason public.exclusion_reason, p_duree interval DEFAULT NULL::interval, p_request uuid DEFAULT NULL::uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'private'
    AS $$
declare
  v_exp timestamptz := case when p_duree is null then null else now() + p_duree end;
begin
  insert into public.profile_exclusions
    (user_lo, user_hi, initiator, reason, source_request_id, expires_at)
  values
    (least(a,b), greatest(a,b), p_initiator, p_reason, p_request, v_exp)
  on conflict (user_lo, user_hi) do update set
    expires_at = case
      when profile_exclusions.expires_at is null or excluded.expires_at is null then null
      else greatest(profile_exclusions.expires_at, excluded.expires_at)
    end,
    reason            = excluded.reason,
    initiator         = excluded.initiator,
    source_request_id = coalesce(excluded.source_request_id, profile_exclusions.source_request_id);
end;
$$;


--
-- Name: FUNCTION exclure(a uuid, b uuid, p_initiator uuid, p_reason public.exclusion_reason, p_duree interval, p_request uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.exclure(a uuid, b uuid, p_initiator uuid, p_reason public.exclusion_reason, p_duree interval, p_request uuid) IS 'Pose ou prolonge une exclusion. Une exclusion existante n''est jamais raccourcie : on conserve toujours la date la plus lointaine, et une exclusion permanente absorbe toute exclusion temporaire.';


--
-- Name: execute_account_deletion(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.execute_account_deletion(u uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  delete from profile_answers where user_id = u;
  delete from profile_vectors where user_id = u;
  delete from identity_verifications where user_id = u;
  delete from blocks where blocker_id = u or blocked_id = u;
  update reports set details = null where reporter_id = u;
  delete from consents where user_id = u;
  delete from profiles where id = u;
  delete from auth.users where id = u;
  update deletion_requests set executed_at = now() where user_id = u;
end $$;


--
-- Name: expirer_demandes(); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.expirer_demandes() RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare n integer;
begin
  update chat_requests
     set status = 'expiree', responded_at = now()
   where status in ('en_attente','reportee')
     and (
       (opened_at is not null and expires_at <= now())   -- delai de reponse ecoule
       or (opened_at is null and stale_at <= now())      -- jamais ouverte, peremption
     );
  get diagnostics n = row_count;
  return n;
end $$;


--
-- Name: FUNCTION expirer_demandes(); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.expirer_demandes() IS 'Couvre les deux echeances : le delai de reponse (compte a rebours demarre a l''ouverture) et la peremption d''une demande jamais ouverte.';


--
-- Name: fil_apprentissage(uuid, integer); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.fil_apprentissage(u uuid, p_taille integer DEFAULT 20) RETURNS TABLE(presentation_id bigint, profil_id uuid, prenom text, age integer, photo_principale text, profil_verifie boolean, ordre_pages public.score_group[], criteres jsonb, besoin numeric, attendu numeric, motif text)
    LANGUAGE plpgsql
    SET search_path TO 'public', 'private'
    AS $$
declare
  v_eps      numeric := private.taux_exploration(u);
  v_plancher numeric := private.engine_param('expl_plancher_attendu');
  v_retest   numeric := private.engine_param('expl_proba_retest');
  v_mature   boolean := v_eps <= private.engine_param('expl_taux_plancher') + 0.001;
  v_reste    integer;
  v_pool     uuid[];
  v_crit     text;
  v_serie    uuid;
  r          record;
  v_pid      bigint;
  v_n        int := 0;
begin
  select s.restants into v_reste from private.etat_session(u) s;
  if v_reste is not null then
    if v_reste <= 0 then return; end if;
    p_taille := least(p_taille, v_reste);
  end if;

  -- Serie contrastive : une experience plutot qu'une simple selection
  if random() < private.engine_param('contraste_proba') then
    v_crit := private.critere_a_isoler(u);
    if v_crit is not null then
      v_serie := gen_random_uuid();
      for r in
        select sc.profil_id as id, p.prenom, h.age, h.photo_principale, h.profil_verifie
        from private.serie_contrastive(u, v_crit,
               least(p_taille, private.engine_param('contraste_taille')::int)) sc
        join public.profiles p on p.id = sc.profil_id
        cross join lateral private.profile_header(p.id) h
      loop
        v_pid := private.preparer_presentation(u, r.id, 'mieux_me_connaitre');
        update public.profile_presentations
           set critere_isole = v_crit, serie_id = v_serie where id = v_pid;
        v_n := v_n + 1;
        return query
          select v_pid, r.id, r.prenom, r.age, r.photo_principale, r.profil_verifie,
                 pp.ordre_pages, pp.criteres, null::numeric, null::numeric,
                 'isolation d''un critère'
          from public.profile_presentations pp where pp.id = v_pid;
      end loop;
      if v_n > 0 then return; end if;
    end if;
  end if;

  select array_agg(x.id) into v_pool
  from (
    select c.id from public.profiles c
    where c.id <> u and c.is_active
      and exists (select 1 from public.profile_vectors v where v.user_id = c.id)
      and not public.are_blocked(u, c.id)
      and not exists (select 1 from public.swipe_decisions s
                      where s.user_id = u and s.target_id = c.id
                        and s.contexte = 'mieux_me_connaitre')
    order by random() limit greatest(p_taille * 10, 200)
  ) x;

  if v_pool is null then return; end if;

  for r in
    select p.id, p.prenom, h.age, h.photo_principale, h.profil_verifie,
           e.besoin, e.attendu, e.inedit
    from private.evaluer_candidats(u, v_pool) e
    join public.profiles p on p.id = e.profil_id
    cross join lateral private.profile_header(p.id) h
    where not (v_mature and e.attendu < v_plancher and random() > v_retest)
    order by v_eps * (e.besoin + e.inedit) / 2 + (1 - v_eps) * e.attendu + random() * 0.12 desc
    limit p_taille
  loop
    v_pid := private.preparer_presentation(u, r.id, 'mieux_me_connaitre');
    return query
      select v_pid, r.id, r.prenom, r.age, r.photo_principale, r.profil_verifie,
             pp.ordre_pages, pp.criteres, r.besoin, r.attendu,
             case when r.inedit > 0.3 then 'criteres inedits'
                  when r.besoin  > 0.6 then 'critere mal connu'
                  when r.attendu > 0.7 then 'forte affinite attendue'
                  else 'equilibrage' end
      from public.profile_presentations pp where pp.id = v_pid;
  end loop;
end $$;


--
-- Name: FUNCTION fil_apprentissage(u uuid, p_taille integer); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.fil_apprentissage(u uuid, p_taille integer) IS 'Ni distance, ni type de rencontre, ni disponibilite : un profil est retenu pour ce qu''il apprend au moteur. Chaque profil servi produit une presentation, dont l''ordre des pages varie a dessein.';


--
-- Name: fil_profils(uuid, numeric, uuid, integer); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.fil_profils(u uuid, p_apres numeric DEFAULT NULL::numeric, p_apres_id uuid DEFAULT NULL::uuid, p_taille integer DEFAULT NULL::integer) RETURNS TABLE(profil_id uuid, prenom text, age integer, photo_principale text, profil_verifie boolean, est_premium boolean, compat_rate numeric, score_physique numeric, score_valeurs numeric, score_mode_vie numeric, distance text, proposable boolean, motif text)
    LANGUAGE plpgsql
    SET search_path TO 'public', 'private'
    AS $$
declare v_taille integer := coalesce(p_taille, private.engine_param('fil_page_taille')::int);
begin
  -- Le cache doit etre chaud pour la page demandee
  perform private.compat_cached(u, c.id)
  from public.profiles c
  where c.id <> u and c.is_active
    and exists (select 1 from profile_vectors v where v.user_id = c.id)
  limit 200;

  return query
  select
    c.id, c.prenom, h.age, h.photo_principale, h.profil_verifie, h.est_premium,
    k.score_global, k.score_physique, k.score_valeurs, k.score_mode_vie,
    private.distance_palier(u, c.id),
    pp.autorise,
    case when pp.autorise then null else pp.motif end
  from public.profiles c
  cross join lateral private.compat_cached(u, c.id) k
  cross join lateral private.profile_header(c.id) h
  cross join lateral private.peut_proposer(u, c.id) pp
  where c.id <> u
    and c.is_active
    and k.user_lo is not null
    and private.cadrage_ok(u, c.id)              -- cadrage : retire du fil
    and not private.est_exclu(u, c.id)           -- refus, blocage, signalement
    and not public.are_blocked(u, c.id)
    and (p_apres is null
         or (k.score_global, c.id) < (p_apres, p_apres_id))
  order by k.score_global desc, c.id desc
  limit v_taille;
end $$;


--
-- Name: FUNCTION fil_profils(u uuid, p_apres numeric, p_apres_id uuid, p_taille integer); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.fil_profils(u uuid, p_apres numeric, p_apres_id uuid, p_taille integer) IS 'Aucun filtrage sur les dealbreakers : le profil reste visible avec proposable a faux, conformement au principe "on voit tous les profils". Seuls le cadrage et les exclusions retirent reellement du fil. Le curseur porte sur le couple (score, id) et reste stable meme si de nouveaux profils sont crees pendant le defilement, contrairement a un OFFSET.';


--
-- Name: focus_candidat(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.focus_candidat(u uuid) RETURNS TABLE(pair_key text, commun integer, effectif integer, sens boolean)
    LANGUAGE sql STABLE
    SET search_path TO 'public', 'private'
    AS $$
  with depuis as (
    select coalesce(max(created_at), '-infinity'::timestamptz) as t
    from public.focus_compatibilite where user_id = u and context = 'swipe'
  ),
  recents as (
    select s.target_id, s.decision,
           row_number() over (order by s.created_at desc) as rn
    from public.swipe_decisions s, depuis
    where s.user_id = u and s.contexte = 'mieux_me_connaitre' and s.created_at > depuis.t
  ),
  tete as (select decision from recents where rn = 1),
  rupture as (
    select coalesce(min(r.rn), 2147483647) as rn
    from recents r, tete where r.decision <> tete.decision
  ),
  serie as (
    select r.target_id, r.decision from recents r, rupture where r.rn < rupture.rn
  ),
  taille as (select count(*)::int as n, bool_and(decision) as sens from serie),
  moi as (select * from public.profile_vectors where user_id = u),
  agg as (
    select p.pair_key, p.slot, p.base_weight,
           bit_and(v.self_mask[p.slot + 1]) as commun,
           count(v.self_mask[p.slot + 1])::int as repondus
    from public.criterion_pairs p
    cross join serie s
    join public.profile_vectors v on v.user_id = s.target_id
    where not exists (
      select 1 from public.criteria c
      where c.pair_key = p.pair_key and c.sensitive_category is not null
    )
    group by p.pair_key, p.slot, p.base_weight
  )
  select a.pair_key, a.commun, a.repondus, t.sens
  from agg a, moi, taille t
  where a.commun is not null and a.commun <> 0
    and a.repondus = t.n
    and t.n >= case when t.sens
                    then private.engine_param('focus_seuil_oui')
                    else private.engine_param('focus_seuil_croix') end
    and moi.pref_mask[a.slot + 1] is null
  order by a.base_weight desc, a.pair_key
  limit 1;
$$;


--
-- Name: FUNCTION focus_candidat(u uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.focus_candidat(u uuid) IS 'Analyse la derniere serie homogene de swipes d''apprentissage, dans les deux sens. N''etudier que les refus serait incomplet : comprendre pourquoi un utilisateur accepte vaut autant. Le critere retenu doit etre commun a toute la serie et non renseigne par l''utilisateur. Les criteres sensibles sont exclus par construction.';


--
-- Name: focus_en_attente(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.focus_en_attente(u uuid) RETURNS TABLE(focus_id uuid, contexte public.focus_context, criterion_key text, direction text, question text, intitule text, multi boolean, options jsonb)
    LANGUAGE sql STABLE
    SET search_path TO 'public', 'private'
    AS $$
  select f.id, f.context, f.criterion_key, c.direction::text, f.question,
         case
           when f.context = 'question_intermediaire' and c.direction = 'self'
             then 'Parlons un peu de vous'
           when f.context = 'question_intermediaire'
             then 'Et chez les autres ?'
           when f.sens then 'Qu''est-ce qui t''a particulièrement attiré ?'
           else 'Qu''est-ce qui te plaît moins ?'
         end,
         coalesce(c.multi_select, false),
         coalesce(f.options,
           (select jsonb_agg(jsonb_build_object('idx', o.idx, 'label', o.label) order by o.idx)
              from public.criterion_options o where o.criterion_key = c.key))
  from public.focus_compatibilite f
  left join public.criteria c on c.key = f.criterion_key
  where f.user_id = u and f.answered_at is null
  order by f.created_at limit 1;
$$;


--
-- Name: generate_meeting_points(uuid, timestamp with time zone); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.generate_meeting_points(d_id uuid, arrivee timestamp with time zone DEFAULT NULL::timestamp with time zone) RETURNS TABLE(utilisateur uuid, lat double precision, lon double precision, ecart_m numeric)
    LANGUAGE plpgsql
    AS $$
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


--
-- Name: generate_phrasings(text); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.generate_phrasings(p_locale text DEFAULT 'fr'::text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare n integer;
begin
  insert into criterion_option_phrasings (criterion_key, idx, locale, phrase)
  select o.criterion_key, o.idx, p_locale,
         case t.mode
           when 'sub' then replace(t.pattern, '{}', private.label_inline(o.label))
           when 'idx' then (string_to_array(t.pattern, '||'))[o.idx + 1]
         end
  from criterion_options o
  join private.phrase_patterns t
    on t.criterion_key = o.criterion_key and t.locale = p_locale
  where case t.mode
          when 'idx' then (string_to_array(t.pattern, '||'))[o.idx + 1] is not null
          else true
        end
  on conflict (criterion_key, idx, locale) do update set phrase = excluded.phrase;
  get diagnostics n = row_count;
  return n;
end $$;


--
-- Name: interet_criteres(uuid, uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.interet_criteres(u uuid, cible uuid) RETURNS TABLE(criterion_key text, pair_key text, grp public.score_group, phrase text, interet numeric)
    LANGUAGE sql STABLE
    SET search_path TO 'public', 'private'
    AS $$
  select c.key, cp.pair_key, cp.grp,
         ps.phrase,
         round(
           -- Ce que le moteur ignore encore pese le plus
           (1 - coalesce(pr.confiance, 0)) * 0.6
           -- Une option jamais rencontree apporte une information neuve
           + (case when coalesce(os.observations, 0) = 0 then 1 else 0 end) * 0.25
           -- A ignorance egale, un critere structurant passe devant
           + coalesce(cp.base_weight, 0) / nullif((select max(base_weight) from public.criterion_pairs), 0) * 0.15
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
  where pa.user_id = cible
    and cp.affichable_apprentissage          -- rubriques interdites en apprentissage
    and cp.grp <> 'physique'                 -- le physique se lit sur la photo
    and ps.phrase is not null;               -- rien a montrer sans phrase naturelle
$$;


--
-- Name: FUNCTION interet_criteres(u uuid, cible uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.interet_criteres(u uuid, cible uuid) IS 'Classe les criteres d''un profil selon ce qu''ils apprendraient a cet observateur precis. La selection n''est jamais aleatoire et n''est jamais la meme d''un observateur a l''autre.';


--
-- Name: invalider_compat(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.invalider_compat(u uuid) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare n integer;
begin
  delete from private.compat_cache where user_lo = u or user_hi = u;
  get diagnostics n = row_count;
  return n;
end $$;


--
-- Name: FUNCTION invalider_compat(u uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.invalider_compat(u uuid) IS 'Purge toutes les paires impliquant un utilisateur. Declenchee automatiquement des que son vecteur de profil est recalcule : le cache ne peut pas servir un score perime.';


--
-- Name: label_inline(text); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.label_inline(l text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare part text; sortie text[] := '{}';
begin
  foreach part in array string_to_array(l, '/') loop
    part := btrim(part);
    if part <> upper(part) then
      part := lower(left(part, 1)) || substr(part, 2);
    end if;
    sortie := sortie || part;
  end loop;
  return array_to_string(sortie, ' ou ');
end $$;


--
-- Name: learned_coef(uuid, text); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.learned_coef(u uuid, pk text) RETURNS numeric
    LANGUAGE sql STABLE
    AS $$
  select coalesce((select l.learned_mul from user_criterion_learning l
                   where l.user_id = u and l.pair_key = pk), 1.0);
$$;


--
-- Name: FUNCTION learned_coef(u uuid, pk text); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.learned_coef(u uuid, pk text) IS 'Multiplicateur appris pour un critere donne. Vaut 1 tant qu''aucune decision n''a ete observee.';


--
-- Name: learning_profile(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.learning_profile(u uuid) RETURNS TABLE(pair_key text, grp public.score_group, question text, learned_mul numeric, observations integer, tendance text)
    LANGUAGE sql STABLE
    AS $$
  select l.pair_key, p.grp, c.question, l.learned_mul, l.observations,
         case when l.learned_mul >= 1.20 then 'compte plus que declare'
              when l.learned_mul <= 0.80 then 'compte moins que declare'
              else 'conforme au declare' end
  from user_criterion_learning l
  join criterion_pairs p on p.pair_key = l.pair_key
  join criteria c on c.key = p.pref_key
  where l.user_id = u
  order by abs(l.learned_mul - 1) desc, l.observations desc;
$$;


--
-- Name: learning_reliability(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.learning_reliability(u uuid) RETURNS numeric
    LANGUAGE sql STABLE
    AS $$
  with d as (
    select count(*) filter (where decision)::numeric as oui,
           count(*)::numeric                         as tot
    from swipe_decisions where user_id = u
  ),
  p as (select case when tot = 0 then null else oui / tot end as p, tot from d)
  select case
           when p.p is null or p.tot < 3 then 1.0
           when p.p <= 0 or p.p >= 1     then private.engine_param('apprentissage_fiabilite_min')
           else greatest(
                  private.engine_param('apprentissage_fiabilite_min'),
                  round((-(p.p * log(2, p.p) + (1 - p.p) * log(2, 1 - p.p)))::numeric, 4))
         end
  from p;
$$;


--
-- Name: FUNCTION learning_reliability(u uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.learning_reliability(u uuid) IS 'Entropie binaire des decisions de swipe de l''utilisateur, bornee par un plancher. Vaut 1 pour un comportement equilibre, tombe au plancher pour un comportement unanime. En dessous de trois decisions, on ne penalise pas : il n''y a simplement rien a mesurer.';


--
-- Name: lever_suspensions(); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.lever_suspensions() RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare n integer;
begin
  with levees as (
    update moderation_actions m
       set leve_at = now()
     where m.action = 'suspension_temporaire'
       and m.leve_at is null and m.expires_at <= now()
    returning m.user_id
  )
  update profiles p set is_active = true
   where p.id in (select user_id from levees)
     and not exists (select 1 from moderation_actions m2
                     where m2.user_id = p.id and m2.action = 'bannissement');
  get diagnostics n = row_count;
  return n;
end $$;


--
-- Name: maintenance_periodique(); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.maintenance_periodique() RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
begin
  return jsonb_build_object(
    'demandes_expirees',          private.expirer_demandes(),
    'conversations_verrouillees', private.verrouiller_conversations(),
    'cooldowns_purges',           private.purger_cooldowns(),
    'exclusions_purgees',         private.purger_exclusions(),
    'points_rdv_expires',         (select expirer_points_rendezvous()),
    'suspensions_levees',         private.lever_suspensions(),
    'messages_envoyes',           private.envoyer_messages_plateforme(),
    'execute_a',                  now());
end $$;


--
-- Name: maj_presence(uuid, uuid, public.geography); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.maj_presence(u uuid, d_id uuid, position_actuelle public.geography) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare v_dist double precision; v_rayon numeric; d dates; v_deux boolean;
begin
  select * into d from dates where id = d_id and (user_a = u or user_b = u);
  if d is null then
    raise exception 'Rendez-vous introuvable' using errcode = 'no_data_found';
  end if;

  select st_distance(position_actuelle, p.location) into v_dist
    from partners p where p.id = d.partner_id;
  v_rayon := private.engine_param('revelation_rayon_m');

  insert into date_presence (date_id, user_id, arrived_at, confirmed_at, distance_m)
  values (d_id, u,
          case when v_dist <= v_rayon then now() end,
          case when v_dist <= v_rayon then now() end,
          v_dist::integer)
  on conflict (date_id, user_id) do update set
    distance_m   = excluded.distance_m,
    arrived_at   = coalesce(date_presence.arrived_at, excluded.arrived_at),
    confirmed_at = coalesce(date_presence.confirmed_at, excluded.confirmed_at);

  -- Le rendez-vous commence quand les deux utilisateurs sont confirmes
  -- sur place. C'est ce qui bascule l'interface en Mode Rendez-vous.
  select count(*) filter (where confirmed_at is not null) = 2
    into v_deux from date_presence where date_id = d_id;

  if v_deux and d.status = 'confirme' then
    update dates set status = 'en_cours', mode_rdv_active_at = now() where id = d_id;
  end if;

  return v_deux;
end $$;


--
-- Name: motif_interdit(text); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.motif_interdit(t text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
  select case
    when t is null then null
    when t ~* '(https?://|www\.[a-z0-9-]+\.[a-z]{2,})'          then 'lien internet'
    when t ~* '[[:alnum:]._%+-]+@[[:alnum:].-]+\.[a-z]{2,}'      then 'adresse électronique'
    when regexp_replace(t, '[^0-9]', '', 'g') ~ '[0-9]{9,}'      then 'numéro de téléphone'
    when t ~* '(instagram|snapchat|snap( |-)?code|whatsapp|telegram|tiktok|facebook|messenger)'
                                                                 then 'réseau social'
    when t ~* '(^|[^[:alnum:]])@[[:alnum:]._]{3,}'               then 'identifiant de réseau social'
    else null
  end;
$$;


--
-- Name: FUNCTION motif_interdit(t text); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.motif_interdit(t text) IS 'Controle serveur des regles de communication d''avant rendez-vous. Le filtrage cote application ne suffit pas : il peut etre contourne.';


--
-- Name: next_questions(uuid, integer); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.next_questions(u uuid, n integer DEFAULT 3) RETURNS TABLE(criterion_key text, question text, moment public.collection_moment, grp public.score_group, priorite numeric, motif text)
    LANGUAGE sql STABLE
    AS $$
with autorises as (select c.* from criteria c
  where c.sensitive_category is null or has_consent(u, c.sensitive_category)),
restants as (select a.* from autorises a
  where not exists (select 1 from profile_answers pa
    where pa.user_id = u and pa.criterion_key = a.key)),
deficit as (select p.grp,
  1.0 + (count(*) filter (where not (
    exists (select 1 from profile_answers where user_id = u and criterion_key = p.self_key)
    and exists (select 1 from profile_answers where user_id = u and criterion_key = p.pref_key)
  )))::numeric / nullif(count(*), 0) as coef
  from criterion_pairs p group by p.grp),
demi_paires as (
  select p.self_key as k, p.pair_key from criterion_pairs p
  where exists (select 1 from profile_answers where user_id = u and criterion_key = p.pref_key)
  union all
  select p.pref_key, p.pair_key from criterion_pairs p
  where exists (select 1 from profile_answers where user_id = u and criterion_key = p.self_key)),
verrou as (select exists (select 1 from criteria c where c.moment = 'onboarding'
    and not exists (select 1 from profile_answers pa
      where pa.user_id = u and pa.criterion_key = c.key)) as inscription_incomplete)
select r.key, r.question, r.moment, p.grp,
  round(coalesce(s.entropie, 1.0) * (case when dp.k is not null then 2.0 else 1.0 end)
    * coalesce(d.coef, 1.0), 3) as priorite,
  case when r.moment = 'onboarding' then 'Critère obligatoire'
       when dp.k is not null then 'Complète une paire déjà entamée'
       when coalesce(s.entropie, 1.0) >= 0.9 then 'Critère fortement discriminant'
       else 'Comble le sous-score le moins documenté' end as motif
from restants r
join criterion_pairs p on p.self_key = r.key or p.pref_key = r.key
cross join verrou v
left join private.criterion_stats s on s.criterion_key = r.key
left join demi_paires dp on dp.k = r.key
left join deficit d on d.grp = p.grp
where r.moment <> 'backend'
  and (not v.inscription_incomplete or r.moment = 'onboarding')
order by (r.moment = 'onboarding') desc,
  case when r.moment = 'onboarding' then r.ord end asc, priorite desc, r.ord asc
limit n;
$$;


--
-- Name: niveau_connaissance(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.niveau_connaissance(u uuid) RETURNS numeric
    LANGUAGE sql STABLE
    SET search_path TO 'public', 'private'
    AS $$
  -- Moyenne des confiances sur TOUS les criteres, y compris ceux
  -- jamais observes : ne compter que les criteres connus donnerait
  -- cent pour cent des la premiere reponse.
  select round(coalesce(
    sum(coalesce(case when coalesce(p.derive, false)
                      then p.confiance * 0.5   -- une derive detectee fait reculer la confiance
                      else p.confiance end, 0) * cp.base_weight)
    / nullif(sum(cp.base_weight), 0), 0), 4)
  from public.criteria c
  join public.criterion_pairs cp on cp.pair_key = c.pair_key
  left join public.user_criterion_profile p on p.user_id = u and p.criterion_key = c.key
  where c.direction = 'self'
    and (private.engine_param('appr_criteres_sensibles') >= 1 or c.sensitive_category is null);
$$;


--
-- Name: FUNCTION niveau_connaissance(u uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.niveau_connaissance(u uuid) IS 'Confiance globale ponderee par l''importance des criteres, calculee sur l''ensemble du referentiel. Une derive detectee reduit de moitie la confiance du critere concerne : l''indicateur peut donc baisser, ce qui signifie que le moteur doit reverifier, pas qu''il a perdu des donnees.';


--
-- Name: numero_facture(); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.numero_facture() RETURNS text
    LANGUAGE sql
    AS $$ select 'SD-' || to_char(now(), 'YYYY') || '-' ||
            lpad(nextval('invoice_number_seq')::text, 6, '0'); $$;


--
-- Name: onglet_autre(uuid, uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.onglet_autre(u uuid, autre uuid) RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select jsonb_build_object(
    'prenom', p.prenom,
    'age', extract(year from age(current_date, p.birth_date))::int,
    'verifie', p.is_verified,
    'photos', coalesce((select jsonb_agg(ph.storage_path order by ph.position)
                        from user_photos ph
                        where ph.user_id = p.id and ph.moderation = 'approuvee'), '[]'::jsonb),
    'a_propos', coalesce((select jsonb_agg(ph.phrase)
                          from profile_answers a
                          join criterion_pairs cp on cp.self_key = a.criterion_key
                          join criteria c on c.key = a.criterion_key
                          join criterion_option_phrasings ph
                            on ph.criterion_key = a.criterion_key and ph.idx = a.option_idx[1]
                          where a.user_id = p.id
                            and c.sensitive_category is null
                            and not cp.is_absolute), '[]'::jsonb))
  from profiles p where p.id = autre;
$$;


--
-- Name: FUNCTION onglet_autre(u uuid, autre uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.onglet_autre(u uuid, autre uuid) IS 'Profil public du partenaire. Les criteres sensibles et les paires eliminatoires sont exclus, et les points communs identifies par le moteur ne sont jamais reveles ici : ils doivent se decouvrir au fil de l''echange.';


--
-- Name: ouvrir_demande(uuid, uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.ouvrir_demande(u uuid, demande uuid) RETURNS public.chat_request_status
    LANGUAGE plpgsql
    SET search_path TO 'public', 'private'
    AS $$
declare r public.chat_requests;
begin
  select * into r from public.chat_requests where id = demande for update;
  if r is null or r.to_user <> u then
    raise exception 'Demande introuvable' using errcode = 'no_data_found';
  end if;

  if r.status in ('en_attente','reportee') and private.statut_effectif(r) = 'expiree' then
    update public.chat_requests set status = 'expiree' where id = demande;
    return 'expiree';
  end if;

  if r.opened_at is null and r.status = 'en_attente' then
    update public.chat_requests
       set opened_at  = now(),
           expires_at = now() + (private.engine_param('demande_delai_reponse_min') || ' minutes')::interval
     where id = demande;
  end if;

  return r.status;
end $$;


--
-- Name: FUNCTION ouvrir_demande(u uuid, demande uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.ouvrir_demande(u uuid, demande uuid) IS 'Demarre le compte a rebours de 30 minutes. Idempotente : une demande deja ouverte n''est pas reinitialisee.';


--
-- Name: ouvrir_parcours_surprise(uuid, uuid, timestamp with time zone); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.ouvrir_parcours_surprise(u uuid, prop uuid, creneau timestamp with time zone) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
declare s surprise_proposals; v_conv uuid; v_req uuid;
begin
  select * into s from surprise_proposals where id = prop
     and (from_user = u or to_user = u) and response = 'accepte';
  if s is null then
    raise exception 'Proposition introuvable ou non acceptée' using errcode = 'no_data_found';
  end if;

  -- Une nouvelle conversation illimitee sert de support au parcours :
  -- les deux se connaissent deja, il n'y a plus de compte a rebours.
  insert into chat_requests (from_user, to_user, status, responded_at)
  values (s.from_user, s.to_user, 'acceptee', now()) returning id into v_req;

  insert into conversations (request_id, user_a, user_b, ends_at, illimitee)
  values (v_req, s.from_user, s.to_user, creneau, true) returning id into v_conv;

  insert into dates (user_a, user_b, partner_id, conversation_id, creneau_debut, status)
  select s.from_user, s.to_user, null, v_conv, creneau, 'en_preparation'
  where false;

  return v_conv;
end $$;


--
-- Name: FUNCTION ouvrir_parcours_surprise(u uuid, prop uuid, creneau timestamp with time zone); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.ouvrir_parcours_surprise(u uuid, prop uuid, creneau timestamp with time zone) IS 'Ouvre le parcours d''organisation apres acceptation. La selection de l''etablissement reprend le meme mecanisme que pour un premier rendez-vous, en privilegiant un lieu different de ceux deja visites ensemble.';


--
-- Name: peut_proposer(uuid, uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.peut_proposer(u uuid, cible uuid) RETURNS TABLE(autorise boolean, motif text)
    LANGUAGE plpgsql STABLE
    SET search_path TO 'public', 'private'
    AS $$
declare
  v_cible      public.profiles;
  v_compat     record;
  v_dernier    timestamptz;
  v_tentatives int;
  v_file       int;
begin
  if u = cible then
    return query select false, 'cible_invalide'; return;
  end if;

  select * into v_cible from public.profiles where id = cible;
  if not found or not v_cible.is_active then
    return query select false, 'indisponible'; return;
  end if;

  if private.est_exclu(u, cible) or public.are_blocked(u, cible) then
    return query select false, 'indisponible'; return;
  end if;

  if exists (select 1 from public.chat_requests
             where from_user = u and to_user = cible
               and status in ('en_attente','reportee')) then
    return query select false, 'demande_deja_en_cours'; return;
  end if;

  select max(created_at) into v_dernier
  from public.chat_requests where from_user = u and to_user = cible;

  if v_dernier is not null
     and v_dernier + (private.engine_param('demande_cooldown_relance_h') || ' hours')::interval > now() then
    return query select false, 'trop_tot'; return;
  end if;

  select count(*) into v_tentatives
  from public.chat_requests
  where from_user = u and to_user = cible
    and created_at > now() - (private.engine_param('demande_fenetre_tentatives_j') || ' days')::interval;

  if v_tentatives >= private.engine_param('demande_max_tentatives') then
    return query select false, 'plafond_atteint'; return;
  end if;

  select count(*) into v_file
  from public.chat_requests r
  where r.to_user = cible
    and private.statut_effectif(r) in ('en_attente','reportee');

  if v_file >= private.engine_param('demande_file_active_max') then
    return query select false, 'indisponible'; return;
  end if;

  select * into v_compat from private.compat_score(u, cible);
  if not v_compat.filtres_ok then
    return query select false, 'incompatibilite_absolue'; return;
  end if;

  return query select true, null::text;
end $$;


--
-- Name: FUNCTION peut_proposer(u uuid, cible uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.peut_proposer(u uuid, cible uuid) IS 'Motifs volontairement generiques. indisponible couvre le blocage, l''exclusion, la desactivation et la saturation de file : l''emetteur ne peut pas deduire lequel s''applique, ni rien apprendre du profil cible.';


--
-- Name: peut_reproposer(uuid, uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.peut_reproposer(u uuid, cible uuid) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  select not exists (select 1 from surprise_cooldowns c
                     where c.from_user = u and c.to_user = cible
                       and c.blocked_until > now());
$$;


--
-- Name: poids_signal(smallint); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.poids_signal(p_niveau smallint) RETURNS numeric
    LANGUAGE sql STABLE
    SET search_path TO 'public', 'private'
    AS $$
  select case p_niveau
    when 1 then private.engine_param('sig_niveau1_appr')
    when 2 then private.engine_param('sig_niveau2_date')
    when 3 then private.engine_param('sig_niveau3_vecu')
    when 4 then private.engine_param('sig_niveau4_suite')
    when 5 then private.engine_param('sig_niveau5_nouveau')
    else 1.0 end;
$$;


--
-- Name: FUNCTION poids_signal(p_niveau smallint); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.poids_signal(p_niveau smallint) IS 'Hierarchie des signaux : une intention pese moins qu''une decision, qui pese moins qu''une experience vecue, qui pese moins qu''une suite donnee a cette experience.';


--
-- Name: user_context_weights; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_context_weights (
    user_id uuid NOT NULL,
    type_rencontre public.rencontre_type NOT NULL,
    poids_physique numeric(4,3) NOT NULL,
    poids_mode_vie numeric(4,3) NOT NULL,
    poids_valeurs numeric(4,3) NOT NULL,
    seuil_exigence numeric(4,3) NOT NULL,
    observations integer DEFAULT 0 NOT NULL,
    confiance numeric(4,3) DEFAULT 0 NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE user_context_weights; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.user_context_weights IS 'Une meme personne peut etre tres exigeante sur le physique pour l''amour et beaucoup plus tolerante pour l''amitie. Les donnees generales restent communes, seules les ponderations sont separees.';


--
-- Name: ponderations(uuid, public.rencontre_type); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.ponderations(u uuid, p_type public.rencontre_type) RETURNS public.user_context_weights
    LANGUAGE sql STABLE
    SET search_path TO 'public', 'private'
    AS $$
  select coalesce(
    (select w from public.user_context_weights w
      where w.user_id = u and w.type_rencontre = p_type),
    (select row(u, d.type_rencontre, d.poids_physique, d.poids_mode_vie,
                d.poids_valeurs, d.seuil_exigence, 0, 0, now())::public.user_context_weights
       from public.context_weight_defaults d where d.type_rencontre = p_type));
$$;


--
-- Name: preautoriser(uuid, uuid, integer); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.preautoriser(u uuid, d_id uuid, montant integer) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
declare v_partner uuid; v_id uuid;
begin
  select partner_id into v_partner from dates
   where id = d_id and (user_a = u or user_b = u);
  if v_partner is null then
    raise exception 'Rendez-vous introuvable' using errcode = 'no_data_found';
  end if;
  if not exists (select 1 from user_payment_methods where user_id = u) then
    raise exception 'Aucun moyen de paiement enregistré' using errcode = 'check_violation';
  end if;

  insert into payments (date_id, payer_id, partner_id, kind, amount_cents, status)
  values (d_id, u, v_partner, 'preautorisation', montant, 'autorise')
  returning id into v_id;
  return v_id;
end $$;


--
-- Name: FUNCTION preautoriser(u uuid, d_id uuid, montant integer); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.preautoriser(u uuid, d_id uuid, montant integer) IS 'Empreinte bancaire, sans debit. Garantit que les consommations pourront etre reglees, tout en laissant le choix du mode de reglement final.';


--
-- Name: preparer_presentation(uuid, uuid, public.swipe_contexte); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.preparer_presentation(u uuid, cible uuid, p_contexte public.swipe_contexte DEFAULT 'mieux_me_connaitre'::public.swipe_contexte) RETURNS bigint
    LANGUAGE plpgsql
    SET search_path TO 'public', 'private'
    AS $$
declare
  v_ordre public.score_group[];
  v_min   int := private.engine_param('present_criteres_min')::int;
  v_max   int := private.engine_param('present_criteres_max')::int;
  v_part  numeric := private.engine_param('present_part_valeurs');
  v_n     int;
  v_nv    int;
  v_crit  jsonb;
  v_id    bigint;
begin
  select array_agg(g order by random()) into v_ordre
  from unnest(array['physique','valeurs','mode_vie']::public.score_group[]) g;

  -- Le nombre exact depend de ce qui reste a apprendre : un profil
  -- mal connu justifie d'en montrer davantage.
  select least(v_max, greatest(v_min,
           round(v_min + (v_max - v_min) * coalesce(avg(interet), 0.5))::int))
    into v_n
  from private.interet_criteres(u, cible);

  v_nv := round(v_n * v_part);

  with classe as (
    select ic.*, row_number() over (partition by ic.grp order by ic.interet desc, random()) as rang
    from private.interet_criteres(u, cible) ic
  ),
  retenus as (
    select * from classe
    where (grp = 'valeurs'  and rang <= v_nv)
       or (grp = 'mode_vie' and rang <= v_n - v_nv)
  )
  select coalesce(jsonb_object_agg(grp, items), '{}'::jsonb) into v_crit
  from (
    select grp::text as grp,
           jsonb_agg(jsonb_build_object('cle', criterion_key, 'phrase', phrase)
                     order by interet desc) as items
    from retenus group by grp
  ) x;

  insert into public.profile_presentations (observer_id, target_id, contexte, ordre_pages, criteres)
  values (u, cible, p_contexte, v_ordre, v_crit)
  returning id into v_id;

  return v_id;
end $$;


--
-- Name: FUNCTION preparer_presentation(u uuid, cible uuid, p_contexte public.swipe_contexte); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.preparer_presentation(u uuid, cible uuid, p_contexte public.swipe_contexte) IS 'Fige avant affichage l''ordre des pages et les criteres retenus. Les rubriques exclues de l''apprentissage ne sont jamais servies ici, meme si le profil les renseigne.';


--
-- Name: profil_preferences(uuid, numeric); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.profil_preferences(u uuid, p_min_conf numeric DEFAULT 0) RETURNS TABLE(criterion_key text, libelle text, grp public.score_group, observations integer, taux_oui numeric, importance numeric, confiance numeric, derive boolean)
    LANGUAGE sql STABLE
    SET search_path TO 'public', 'private'
    AS $$
  select p.criterion_key, c.question, p.grp, p.observations,
         p.taux_oui, p.importance, p.confiance, p.derive
  from public.user_criterion_profile p
  left join public.criteria c on c.key = p.criterion_key
  where p.user_id = u and p.confiance >= p_min_conf
  order by p.importance desc nulls last, p.observations desc;
$$;


--
-- Name: profile_header(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.profile_header(u uuid) RETURNS TABLE(age integer, photo_principale text, profil_verifie boolean, connaissance numeric, est_premium boolean)
    LANGUAGE sql STABLE
    AS $$
  select extract(year from age(current_date, e.birth_date))::int,
    (select storage_path from user_photos where user_id=u and is_primary),
    exists (select 1 from user_verification_codes where user_id=u and verified_at is not null)
      and exists (select 1 from identity_verifications where user_id=u and status='validee' and comparison_ok),
    private.profile_knowledge(u), e.is_premium
  from profiles e where e.id = u;
$$;


--
-- Name: profile_knowledge(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.profile_knowledge(u uuid) RETURNS numeric
    LANGUAGE sql STABLE
    AS $$
  with p as (select private.engine_param('connaissance_part_paires') as w_paires,
      private.engine_param('connaissance_part_entropie') as w_entropie,
      private.engine_param('connaissance_part_interactions') as w_inter,
      private.engine_param('connaissance_swipes_cible') as cible),
  paires as (select
      avg(case when a_self and a_pref then 1.0 when a_self or a_pref then 0.5 else 0.0 end) as couverture,
      sum(case when a_self and a_pref then poids else 0 end) / nullif(sum(poids),0) as couverture_ponderee
    from (select
        exists (select 1 from profile_answers where user_id=u and criterion_key=cp.self_key) as a_self,
        exists (select 1 from profile_answers where user_id=u and criterion_key=cp.pref_key) as a_pref,
        greatest(coalesce(s1.entropie,1.0),0.05) as poids
      from criterion_pairs cp
      left join private.criterion_stats s1 on s1.criterion_key = cp.self_key
      where cp.self_key in (select key from criteria where moment <> 'backend')) t),
  inter as (select least(1.0, count(*)::numeric / (select cible from p)) as taux
    from swipe_decisions where user_id = u)
  select round(100 * (p.w_paires * coalesce(paires.couverture,0)
    + p.w_entropie * coalesce(paires.couverture_ponderee,0)
    + p.w_inter * coalesce(inter.taux,0)), 0)
  from p, paires, inter;
$$;


--
-- Name: profile_sections(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.profile_sections(u uuid) RETURNS TABLE(section public.score_group, ord smallint, pair_key text, phrase text)
    LANGUAGE sql STABLE
    AS $$
  select cp.grp, c.ord, cp.pair_key,
    coalesce(render_measure(o.value_min,o.value_max,o.unit,
      (select systeme_unites from profiles where id=u)), ph.phrase)
  from criterion_pairs cp
  join criteria c on c.key = cp.self_key
  join profile_answers pa on pa.user_id=u and pa.criterion_key=cp.self_key
  join criterion_options o on o.criterion_key=cp.self_key and o.idx=pa.option_idx[1]
  left join criterion_option_phrasings ph on ph.criterion_key=cp.self_key and ph.idx=pa.option_idx[1]
    and ph.locale = coalesce((select langue from profiles where id=u),'fr')
  where c.moment <> 'backend' order by cp.grp, c.ord;
$$;


--
-- Name: proposer_conversation(uuid, uuid, public.rencontre_type, public.score_group[]); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.proposer_conversation(u uuid, cible uuid, p_type public.rencontre_type, ordre public.score_group[] DEFAULT ARRAY['physique'::public.score_group, 'valeurs'::public.score_group, 'mode_vie'::public.score_group]) RETURNS uuid
    LANGUAGE plpgsql
    SET search_path TO 'public', 'private'
    AS $$
declare
  v_check      record;
  v_compat     record;
  v_intentions public.rencontre_type[];
  v_id         uuid;
begin
  select * into v_check from private.peut_proposer(u, cible);
  if not v_check.autorise then
    raise exception 'Demande impossible (%)', v_check.motif using errcode = 'check_violation';
  end if;

  select intentions into v_intentions from public.profiles where id = cible;
  if not (p_type = any (v_intentions)) then
    raise exception 'Demande impossible (incompatibilite_absolue)' using errcode = 'check_violation';
  end if;

  if cardinality(ordre) <> 3
     or cardinality(array(select distinct unnest(ordre))) <> 3 then
    raise exception 'Ordre des ecrans invalide' using errcode = 'check_violation';
  end if;

  select * into v_compat from private.compat_score(u, cible);

  insert into public.chat_requests
    (from_user, to_user, type_rencontre, compat_rate, ecran_ordre, stale_at)
  values
    (u, cible, p_type, v_compat.score_global, ordre,
     now() + (private.engine_param('demande_peremption_h') || ' hours')::interval)
  returning id into v_id;

  return v_id;
end $$;


--
-- Name: FUNCTION proposer_conversation(u uuid, cible uuid, p_type public.rencontre_type, ordre public.score_group[]); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.proposer_conversation(u uuid, cible uuid, p_type public.rencontre_type, ordre public.score_group[]) IS 'expires_at reste nul a l''envoi : le delai de reponse ne demarre qu''a la premiere ouverture par le destinataire. Seul stale_at court des l''emission. Le type de rencontre est valide serveur contre les intentions declarees du destinataire, avec un motif indistinguable de l''incompatibilite absolue.';


--
-- Name: proximite_disponible(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.proximite_disponible(u uuid) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$ select has_consent(u,'geolocalisation'); $$;


--
-- Name: purger_cooldowns(); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.purger_cooldowns() RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare n integer;
begin
  delete from surprise_cooldowns where blocked_until <= now();
  get diagnostics n = row_count;
  return n;
end $$;


--
-- Name: purger_exclusions(); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.purger_exclusions() RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare n integer;
begin
  delete from profile_exclusions
   where expires_at is not null and expires_at <= now();
  get diagnostics n = row_count;
  return n;
end $$;


--
-- Name: FUNCTION purger_exclusions(); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.purger_exclusions() IS 'Supprime les exclusions arrivees a echeance. Les exclusions permanentes (expires_at nul) ne sont jamais purgees.';


--
-- Name: qualite_moteur(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.qualite_moteur(u uuid DEFAULT NULL::uuid) RETURNS TABLE(type_rencontre public.rencontre_type, predictions integer, erreur_moyenne numeric, faux_positifs integer, faux_negatifs integer, justes integer, taux_justesse numeric)
    LANGUAGE sql STABLE
    SET search_path TO 'public', 'private'
    AS $$
  select d.type_rencontre, count(*)::int,
         round(avg(d.erreur_prediction), 4),
         count(*) filter (where d.score_predit >= d.seuil_predit * 100 and not d.decision)::int,
         count(*) filter (where d.score_predit <  d.seuil_predit * 100 and     d.decision)::int,
         count(*) filter (where (d.score_predit >= d.seuil_predit * 100) = d.decision)::int,
         round(count(*) filter (where (d.score_predit >= d.seuil_predit * 100) = d.decision)::numeric
               / nullif(count(*), 0), 4)
  from public.swipe_decisions d
  where d.contexte = 'partir_en_date' and d.score_predit is not null
    and (u is null or d.user_id = u)
  group by d.type_rencontre;
$$;


--
-- Name: FUNCTION qualite_moteur(u uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.qualite_moteur(u uuid) IS 'Mesure si le moteur s''ameliore reellement. Un faux positif est une rencontre annoncee compatible puis refusee ; un faux negatif une compatibilite sous-estimee et pourtant acceptee. Les seconds coutent plus cher : ce sont des occasions jamais proposees.';


--
-- Name: question_candidate(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.question_candidate(u uuid) RETURNS TABLE(criterion_key text, direction text, question text, multi boolean, priorite numeric)
    LANGUAGE sql STABLE
    SET search_path TO 'public', 'private'
    AS $$
  select c.key, c.direction::text, c.question, c.multi_select,
         round(
           (case when pa.user_id is null then 1 else 0 end) * 0.45
           + (case when pa.user_id is null and autre.user_id is not null then 1 else 0 end) * 0.25
           + (case when coalesce(pr.derive, false) then 1 else 0 end) * 0.20
           + coalesce(cp.base_weight, 0) / nullif((select max(base_weight) from public.criterion_pairs), 0) * 0.10
         , 4) as priorite
  from public.criteria c
  join public.criterion_pairs cp on cp.pair_key = c.pair_key
  left join public.profile_answers pa on pa.user_id = u and pa.criterion_key = c.key
  left join public.criteria autre_c
         on autre_c.pair_key = c.pair_key and autre_c.direction <> c.direction
  left join public.profile_answers autre
         on autre.user_id = u and autre.criterion_key = autre_c.key
  left join public.user_criterion_profile pr on pr.user_id = u and pr.criterion_key = c.key
  where (private.engine_param('appr_criteres_sensibles') >= 1 or c.sensitive_category is null)
    and (pa.user_id is null or coalesce(pr.derive, false))
  order by priorite desc, random()
  limit 1;
$$;


--
-- Name: FUNCTION question_candidate(u uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.question_candidate(u uuid) IS 'Choisit entre une question sur l''utilisateur et une question sur ses preferences. Le complement d''un critere renseigne dans un seul sens est privilegie : savoir qu''une personne ne fume pas ne dit rien de ce qu''elle accepte chez l''autre.';


--
-- Name: quota_atteint(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.quota_atteint(u uuid) RETURNS boolean
    LANGUAGE sql STABLE
    SET search_path TO 'public', 'private'
    AS $$
  select not s.illimite and coalesce(s.restants, 1) <= 0
  from private.etat_session(u) s;
$$;


--
-- Name: quota_restant(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.quota_restant(u uuid) RETURNS integer
    LANGUAGE sql STABLE
    AS $$
  select case
           when (select is_premium from profiles where id = u) then null
           else greatest(0, private.engine_param('discussions_gratuit_par_jour')::int
                            - (select count(*)::int from chat_requests
                               where from_user = u
                                 and created_at >= date_trunc('day', now())))
         end;
$$;


--
-- Name: FUNCTION quota_restant(u uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.quota_restant(u uuid) IS 'Nombre de nouvelles discussions encore ouvrables aujourd''hui. NULL pour un abonne : aucune limitation.';


--
-- Name: rapport_help_personnel(uuid, text, text, text, text, text, boolean, boolean, smallint, text); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.rapport_help_personnel(p_help uuid, p_staff text, p_table text, p_circonstances text, p_faits text, p_actions text, p_depart_accompagne boolean, p_secours boolean, p_dangerosite smallint, p_observations text DEFAULT NULL::text) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
declare v_partner uuid; v_id uuid;
begin
  select d.partner_id into v_partner
    from help_requests h join dates d on d.id = h.date_id where h.id = p_help;
  if v_partner is null then
    raise exception 'Demande introuvable' using errcode = 'no_data_found';
  end if;
  if p_dangerosite not between 1 and 5 then
    raise exception 'La note de dangerosité doit être comprise entre 1 et 5'
      using errcode = 'check_violation';
  end if;

  insert into help_staff_reports (help_request_id, partner_id, staff_identifiant,
    table_number, circonstances, faits, actions, depart_accompagne,
    secours_appeles, dangerosite, observations)
  values (p_help, v_partner, p_staff, p_table, p_circonstances, p_faits,
          p_actions, p_depart_accompagne, p_secours, p_dangerosite, p_observations)
  returning id into v_id;
  return v_id;
end $$;


--
-- Name: FUNCTION rapport_help_personnel(p_help uuid, p_staff text, p_table text, p_circonstances text, p_faits text, p_actions text, p_depart_accompagne boolean, p_secours boolean, p_dangerosite smallint, p_observations text); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.rapport_help_personnel(p_help uuid, p_staff text, p_table text, p_circonstances text, p_faits text, p_actions text, p_depart_accompagne boolean, p_secours boolean, p_dangerosite smallint, p_observations text) IS 'Rapport d''intervention obligatoire au titre du contrat de partenariat. Le personnel relate des faits objectifs ; la note de dangerosite reste strictement confidentielle et n''est jamais communiquee aux utilisateurs.';


--
-- Name: rapport_help_utilisateur(uuid, uuid, text, text, text, text, text); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.rapport_help_utilisateur(u uuid, help_id uuid, p_raison text, p_recit text DEFAULT NULL::text, p_comportement text DEFAULT NULL::text, p_ressenti text DEFAULT NULL::text, p_complement text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare h help_requests;
begin
  select * into h from help_requests where id = help_id and user_id = u;
  if h is null then
    raise exception 'Demande introuvable' using errcode = 'no_data_found';
  end if;
  if not private.evaluations_disponibles(h.date_id) then
    raise exception 'Formulaire disponible une fois éloigné de l''établissement'
      using errcode = 'check_violation';
  end if;

  insert into help_user_reports (help_request_id, user_id, raison, recit,
                                 comportement, ressenti, complement)
  values (help_id, u, p_raison, p_recit, p_comportement, p_ressenti, p_complement)
  on conflict (help_request_id) do update set
    raison = excluded.raison, recit = excluded.recit,
    comportement = excluded.comportement, ressenti = excluded.ressenti,
    complement = excluded.complement, submitted_at = now();
end $$;


--
-- Name: rechauffer_compat(integer); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.rechauffer_compat(p_lot integer DEFAULT 200) RETURNS integer
    LANGUAGE plpgsql
    SET search_path TO 'public', 'private'
    AS $$
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


--
-- Name: FUNCTION rechauffer_compat(p_lot integer); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.rechauffer_compat(p_lot integer) IS 'Calcule par lots bornes les paires manquantes ou perimees, pour que la lecture du fil trouve toujours un score deja pret.';


--
-- Name: record_biometric_check(uuid, text, text, boolean, boolean, numeric, uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.record_biometric_check(u uuid, p_provider text, p_ref text, p_liveness boolean, p_comparison boolean, p_score numeric, p_photo uuid) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare ok boolean;
begin
  if not has_consent(u, 'biometrie') then
    raise exception 'Consentement biométrique manquant. Il doit être recueilli avant la capture du selfie.'
      using errcode = 'check_violation';
  end if;
  ok := coalesce(p_liveness,false) and coalesce(p_comparison,false);
  insert into identity_verifications (user_id, provider, provider_ref, status, liveness_ok,
    comparison_ok, comparison_score, photo_id, checked_at)
  values (u, p_provider, p_ref, (case when ok then 'validee' else 'refusee' end)::verification_status,
    p_liveness, p_comparison, p_score, p_photo, now());
  if ok then
    update profiles set is_verified = true where id = u;
    insert into user_step_completions (user_id, step) values (u,7) on conflict do nothing;
  end if;
  return ok;
end $$;


--
-- Name: refresh_criterion_stats(); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.refresh_criterion_stats() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  refresh materialized view private.criterion_stats;
end $$;


--
-- Name: FUNCTION refresh_criterion_stats(); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.refresh_criterion_stats() IS 'A planifier (quotidien suffit). Tant que la vue n''est pas rafraichie sur un volume reel, criterion_stats.entropie reste uniforme et les tris par entropie de next_questions, derive_priorities et candidate_highlights sont inertes.';


--
-- Name: refresh_profile_vectors(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.refresh_profile_vectors(u uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
declare v_self int[] := array_fill(null::int, array[133]);
  v_pref int[] := array_fill(null::int, array[133]);
  v_wm numeric[] := array_fill(1.0::numeric, array[133]);
  n_self smallint := 0; n_pref smallint := 0; r record; a_correspondance boolean;
begin
  for r in select p.slot, a.option_idx from criterion_pairs p
    join profile_answers a on a.criterion_key = p.self_key and a.user_id = u
  loop
    v_self[r.slot+1] := (select coalesce(sum(1 << i),0)::int from unnest(r.option_idx) as i);
    n_self := n_self + 1;
  end loop;

  for r in select p.slot, p.pair_key, p.match_type, a.option_idx, s.option_idx as my_own_idx,
      pr.rang as rang_priorite
    from criterion_pairs p
    join profile_answers a on a.criterion_key = p.pref_key and a.user_id = u
    left join profile_answers s on s.criterion_key = p.self_key and s.user_id = u
    left join user_criterion_priorities pr on pr.user_id = u and pr.pair_key = p.pair_key
  loop
    -- Une correspondance ABSENTE et une correspondance VIDE ne veulent pas
    -- dire la même chose. Absente : le client n'a pas encore tranché, le
    -- critère doit sortir du calcul. Vide : le client a dit « aucune option
    -- ne convient », c'est un vrai désaccord.
    a_correspondance := exists (select 1 from option_mappings m
      where m.pair_key = r.pair_key and m.pref_idx = any(r.option_idx));

    if not a_correspondance then
      v_pref[r.slot+1] := null;
    elsif r.match_type = 'echelle' then
      v_pref[r.slot+1] := (select coalesce(sum(1 << g.i),0)::int
        from option_mappings m cross join generate_series(0,14) as g(i)
        where m.pair_key = r.pair_key and m.pref_idx = r.option_idx[1]
          and r.my_own_idx is not null and m.tolerance is not null
          and abs(g.i - r.my_own_idx[1]) <= m.tolerance);
    else
      v_pref[r.slot+1] := (select coalesce(sum(distinct 1 << acc),0)::int
        from option_mappings m, unnest(m.accepted_self_idx) as acc
        where m.pair_key = r.pair_key and m.pref_idx = any(r.option_idx));
    end if;

    -- Poids effectif : declare par le client x priorite de l'utilisateur
    -- x ce que ses decisions reelles ont appris sur ce critere.
    v_wm[r.slot+1] := coalesce((select min(m.weight_multiplier) from option_mappings m
        where m.pair_key = r.pair_key and m.pref_idx = any(r.option_idx)),1.0)
      * priorite_coef(r.rang_priorite)
      * private.learned_coef(u, r.pair_key);

    if a_correspondance then n_pref := n_pref + 1; end if;
  end loop;

  insert into profile_vectors (user_id, self_mask, pref_mask, weight_mul, answered_self, answered_pref, refreshed_at)
  values (u, v_self, v_pref, v_wm, n_self, n_pref, now())
  on conflict (user_id) do update set self_mask=excluded.self_mask, pref_mask=excluded.pref_mask,
    weight_mul=excluded.weight_mul, answered_self=excluded.answered_self,
    answered_pref=excluded.answered_pref, refreshed_at=now();
end $$;


--
-- Name: regler(uuid, uuid, public.payment_mode, integer, boolean); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.regler(u uuid, d_id uuid, p_mode public.payment_mode DEFAULT 'individuel'::public.payment_mode, pourboire integer DEFAULT 0, facture_simplifiee boolean DEFAULT false) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
declare
  v_partner uuid; v_montant integer; v_pay uuid; v_inv uuid;
  v_taux numeric; v_tva numeric; v_commission integer; v_reportee integer := 0;
  v_ht integer; v_tva_cents integer; v_couverts smallint;
begin
  select partner_id into v_partner from dates
   where id = d_id and (user_a = u or user_b = u);
  if v_partner is null then
    raise exception 'Rendez-vous introuvable' using errcode = 'no_data_found';
  end if;

  if p_mode = 'integral' then
    v_montant := private.reste_a_payer(d_id);
  else
    v_montant := coalesce((select montant_cents from private.addition(d_id) a
                           where a.user_id = u), 0)
               - coalesce((select sum(p.amount_cents) from payments p
                           where p.date_id = d_id and p.payer_id = u
                             and p.kind = 'paiement' and p.status = 'capture'), 0);
  end if;

  if v_montant <= 0 then
    raise exception 'Aucun montant à régler' using errcode = 'check_violation';
  end if;

  insert into payments (date_id, payer_id, partner_id, kind, mode,
                        amount_cents, tip_cents, status, captured_at)
  values (d_id, u, v_partner, 'paiement', p_mode,
          v_montant, greatest(pourboire, 0), 'capture', now())
  returning id into v_pay;

  -- Prise en charge integrale : les empreintes de l'autre utilisateur
  -- sont liberees pour eviter double paiement et frais inutiles.
  if p_mode = 'integral' then
    update payments set status = 'annule'
     where date_id = d_id and kind = 'preautorisation'
       and status = 'autorise' and payer_id <> u;
  end if;
  update payments set status = 'annule'
   where date_id = d_id and kind = 'preautorisation'
     and status = 'autorise' and payer_id = u;

  -- Reversement. En especes, la commission n'est pas prelevable :
  -- elle est reportee sur un paiement numerique ulterieur.
  v_taux := private.commission_taux(v_partner);
  if p_mode = 'especes' then
    v_commission := 0;
    v_reportee   := round(v_montant * v_taux);
  else
    v_commission := round(v_montant * v_taux);
  end if;

  insert into partner_settlements (payment_id, partner_id, gross_cents,
                                   commission_cents, net_cents, tip_cents,
                                   commission_reportee_cents)
  values (v_pay, v_partner, v_montant, v_commission,
          v_montant - v_commission + greatest(pourboire, 0),
          greatest(pourboire, 0), v_reportee);

  -- Facture
  v_tva := private.engine_param('tva_taux_defaut');
  v_ht  := round(v_montant / (1 + v_tva));
  v_tva_cents := v_montant - v_ht;
  select count(distinct o.user_id)::smallint into v_couverts
    from orders o where o.date_id = d_id and o.status <> 'annulee';

  insert into invoices (date_id, payment_id, partner_id, user_id, number, type,
                        paid_at, covers, subtotal_ht_cents, vat_cents,
                        total_ttc_cents, tip_cents)
  values (d_id, v_pay, v_partner, u, private.numero_facture(),
          case when facture_simplifiee then 'simplifiee' else 'detaillee' end::invoice_type,
          now(), v_couverts, v_ht, v_tva_cents, v_montant, greatest(pourboire, 0))
  returning id into v_inv;

  if not facture_simplifiee then
    insert into invoice_lines (invoice_id, label, quantity, unit_price_cents, vat_rate, total_cents)
    select v_inv, i.label_snapshot, i.quantity, i.unit_price_cents,
           v_tva * 100, i.line_total_cents
    from order_items i
    join orders o on o.id = i.order_id
    where o.date_id = d_id and o.status <> 'annulee'
      and (p_mode = 'integral' or o.user_id = u);
  end if;

  return v_inv;
end $$;


--
-- Name: FUNCTION regler(u uuid, d_id uuid, p_mode public.payment_mode, pourboire integer, facture_simplifiee boolean); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.regler(u uuid, d_id uuid, p_mode public.payment_mode, pourboire integer, facture_simplifiee boolean) IS 'Reglement des consommations. Le mode integral solde la totalite du rendez-vous et libere les empreintes de l''autre utilisateur. Le mode especes est trace pour la coherence des factures, la commission etant reportee.';


--
-- Name: rejoindre_conversation(uuid, uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.rejoindre_conversation(u uuid, p_conv uuid) RETURNS TABLE(statut public.conversation_status, demarree boolean, attend_qui uuid, decompte_s integer, secondes_restantes integer)
    LANGUAGE plpgsql
    SET search_path TO 'public', 'private'
    AS $$
declare
  c        public.conversations;
  v_frais  interval := (private.engine_param('presence_fraicheur_s') || ' seconds')::interval;
  v_autre  uuid;
  v_pres_a timestamptz;
  v_pres_b timestamptz;
begin
  select * into c from public.conversations where id = p_conv for update;
  if c.id is null or (c.user_a <> u and c.user_b <> u) then
    raise exception 'Conversation introuvable' using errcode = 'no_data_found';
  end if;

  if c.status in ('verrouillee','cloturee') then
    return query select c.status, false, null::uuid, 0, 0; return;
  end if;

  -- On note la presence de l'appelant
  if c.user_a = u then
    update public.conversations set presence_a_at = now() where id = p_conv;
  else
    update public.conversations set presence_b_at = now() where id = p_conv;
  end if;

  select presence_a_at, presence_b_at into v_pres_a, v_pres_b
  from public.conversations where id = p_conv;

  -- Deja demarree : on rend simplement le temps restant
  if c.status = 'active' then
    return query select 'active'::public.conversation_status, false, null::uuid,
                        0, greatest(0, extract(epoch from c.ends_at - now()))::int;
    return;
  end if;

  v_autre := case when c.user_a = u then c.user_b else c.user_a end;

  -- Presence conjointe : le chronometre part enfin
  if v_pres_a is not null and v_pres_b is not null
     and v_pres_a > now() - v_frais and v_pres_b > now() - v_frais then
    update public.conversations
       set status     = 'active',
           started_at = now() + (private.engine_param('conversation_decompte_s') || ' seconds')::interval,
           ends_at    = now() + (private.engine_param('conversation_decompte_s') || ' seconds')::interval
                        + (private.engine_param('conversation_duree_s') || ' seconds')::interval
     where id = p_conv;

    return query select 'active'::public.conversation_status, true, null::uuid,
                        private.engine_param('conversation_decompte_s')::int,
                        private.engine_param('conversation_duree_s')::int;
    return;
  end if;

  -- Sinon on attend l'autre, sans que rien ne s'ecoule
  return query select 'prete'::public.conversation_status, false, v_autre, 0, null::int;
end $$;


--
-- Name: FUNCTION rejoindre_conversation(u uuid, p_conv uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.rejoindre_conversation(u uuid, p_conv uuid) IS 'Le demarrage n''est jamais decide par une acceptation mais par une presence conjointe et fraiche. Tant qu''un seul est la, aucune seconde n''est consommee.';


--
-- Name: reorder_priorities(uuid, text[]); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.reorder_priorities(u uuid, ordre text[]) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare max_visible int; i int;
begin
  if not (select is_premium from profiles where id = u) then
    raise exception 'La réorganisation des priorités de compatibilité est réservée aux abonnés Premium'
      using errcode = 'insufficient_privilege';
  end if;
  max_visible := private.engine_param('priorites_visibles_premium');
  if array_length(ordre,1) > max_visible then
    raise exception 'Au plus % priorités peuvent être réorganisées', max_visible using errcode='check_violation';
  end if;
  update user_criterion_priorities set rang = rang + array_length(ordre,1), manuel = false
   where user_id = u and pair_key <> all(ordre);
  for i in 1 .. array_length(ordre,1) loop
    insert into user_criterion_priorities (user_id, pair_key, rang, manuel)
    values (u, ordre[i], i::smallint, true)
    on conflict (user_id, pair_key) do update set rang = excluded.rang, manuel = true;
  end loop;
  perform private.refresh_profile_vectors(u);
end $$;


--
-- Name: repondre_demande(uuid, uuid, public.date_intent); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.repondre_demande(u uuid, demande uuid, reponse public.date_intent) RETURNS uuid
    LANGUAGE plpgsql
    SET search_path TO 'public', 'private'
    AS $$
declare r public.chat_requests; v_conv uuid;
begin
  select * into r from public.chat_requests where id = demande for update;
  if r is null or r.to_user <> u then
    raise exception 'Demande introuvable' using errcode = 'no_data_found';
  end if;

  if r.status not in ('en_attente','reportee') then
    raise exception 'Cette demande a déjà été traitée' using errcode = 'check_violation';
  end if;

  if private.statut_effectif(r) = 'expiree' then
    update public.chat_requests set status = 'expiree', responded_at = now() where id = demande;
    raise exception 'Cette demande a expiré' using errcode = 'check_violation';
  end if;

  if reponse = 'plus_tard' then
    if r.postpone_count >= 1 then
      raise exception 'Cette demande a déjà été reportée' using errcode = 'check_violation';
    end if;
    update public.chat_requests
       set status = 'reportee', postponed_at = now(), postpone_count = postpone_count + 1,
           opened_at = coalesce(opened_at, now()),
           expires_at = coalesce(expires_at, now())
                        + (private.engine_param('demande_sursis_report_h') || ' hours')::interval
     where id = demande;
    return null;
  end if;

  if reponse = 'non' then
    update public.chat_requests set status = 'refusee', responded_at = now() where id = demande;
    perform private.exclure(r.from_user, r.to_user, u, 'refus_conversation',
      (private.engine_param('demande_exclusion_refus_mois') || ' months')::interval, r.id);
    return null;
  end if;

  update public.chat_requests set status = 'acceptee', responded_at = now() where id = demande;

  -- Conversation creee mais a l'arret : ni started_at, ni ends_at
  insert into public.conversations (request_id, user_a, user_b, status, prete_at)
  values (demande, r.from_user, r.to_user, 'prete', now())
  returning id into v_conv;

  return v_conv;
end $$;


--
-- Name: FUNCTION repondre_demande(u uuid, demande uuid, reponse public.date_intent); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.repondre_demande(u uuid, demande uuid, reponse public.date_intent) IS 'Une acceptation cree la conversation mais ne la demarre pas. Le refus reste silencieux cote emetteur et pose une exclusion mutuelle.';


--
-- Name: repondre_focus(uuid, uuid, smallint[], text); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.repondre_focus(u uuid, p_focus uuid, p_options smallint[], p_categorie text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql
    SET search_path TO 'public', 'private'
    AS $$
declare f public.focus_compatibilite;
begin
  select * into f from public.focus_compatibilite
  where id = p_focus and user_id = u and answered_at is null;
  if f.id is null then
    raise exception 'Question introuvable' using errcode = 'no_data_found';
  end if;

  if (p_options is null or cardinality(p_options) = 0) and p_categorie is null then
    update public.focus_compatibilite set reponse = 'passe', answered_at = now() where id = p_focus;
    return;
  end if;

  -- Question de categorie : enregistree telle quelle, sans rien deduire du profil
  if f.criterion_key is null then
    update public.focus_compatibilite
       set reponse = p_categorie, answered_at = now() where id = p_focus;
    return;
  end if;

  insert into public.profile_answers (user_id, criterion_key, option_idx, answered_at)
  values (u, f.criterion_key, p_options, now())
  on conflict (user_id, criterion_key) do update
    set option_idx = excluded.option_idx, answered_at = now();

  update public.focus_compatibilite
     set reponse = p_options::text, answered_at = now() where id = p_focus;

  perform private.refresh_profile_vectors(u);
end $$;


--
-- Name: repondre_surprise(uuid, uuid, public.surprise_response); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.repondre_surprise(u uuid, prop uuid, p_reponse public.surprise_response) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
declare s surprise_proposals; v_fin timestamptz;
begin
  select * into s from surprise_proposals where id = prop and to_user = u;
  if s is null then
    raise exception 'Proposition introuvable' using errcode = 'no_data_found';
  end if;
  if s.response is not null then
    raise exception 'Cette proposition a déjà reçu une réponse' using errcode = 'check_violation';
  end if;

  -- Le declencheur surprise_proposals_cooldown pose le blocage adapte.
  update surprise_proposals set response = p_reponse, responded_at = now()
   where id = prop;

  select blocked_until into v_fin from surprise_cooldowns
   where from_user = s.from_user and to_user = s.to_user;

  return jsonb_build_object(
    'reponse', p_reponse,
    'nouveau_parcours', p_reponse = 'accepte',
    'emetteur_bloque_jusquau', v_fin,
    'destinataire_peut_reprendre_initiative', true);
end $$;


--
-- Name: FUNCTION repondre_surprise(u uuid, prop uuid, p_reponse public.surprise_response); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.repondre_surprise(u uuid, prop uuid, p_reponse public.surprise_response) IS 'Le blocage anti-insistance ne vise que l''emetteur. Celui qui a decline conserve la possibilite de reproposer lui-meme a tout moment.';


--
-- Name: reporter_evaluation_etablissement(uuid, uuid, public.review_status); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.reporter_evaluation_etablissement(u uuid, d_id uuid, p_status public.review_status) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
  insert into venue_reviews (date_id, user_id, partner_id, status)
  select d_id, u, d.partner_id, p_status from dates d
   where d.id = d_id and (d.user_a = u or d.user_b = u)
  on conflict (date_id, user_id) do update set status = excluded.status;
end $$;


--
-- Name: FUNCTION reporter_evaluation_etablissement(u uuid, d_id uuid, p_status public.review_status); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.reporter_evaluation_etablissement(u uuid, d_id uuid, p_status public.review_status) IS 'Choix « Plus tard » ou « Passer ». Passer n''entraine aucune relance ; plus tard autorise un unique rappel en messagerie.';


--
-- Name: reprendre_date(uuid, uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.reprendre_date(u uuid, d_id uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
  update dates set ended_at = null, ended_by = null
   where id = d_id and (user_a = u or user_b = u) and closed_at is null;
  if not found then
    raise exception 'Ce rendez-vous ne peut plus être repris' using errcode = 'check_violation';
  end if;
end $$;


--
-- Name: reproposer_date_surprise(uuid, uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.reproposer_date_surprise(u uuid, cible uuid) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
declare v_id uuid; v_date uuid;
begin
  if private.compte_bloque(u) then
    raise exception 'Régularisation requise avant toute nouvelle action' using errcode = 'check_violation';
  end if;
  if not private.peut_reproposer(u, cible) then
    raise exception 'Vous ne pouvez pas reproposer de Date Surprise à cette personne pour le moment'
      using errcode = 'check_violation';
  end if;

  -- La reproposition suppose une rencontre precedente cloturee.
  select d.id into v_date from dates d
   where ((d.user_a = u and d.user_b = cible) or (d.user_a = cible and d.user_b = u))
     and d.closed_at is not null
   order by d.closed_at desc limit 1;
  if v_date is null then
    raise exception 'Aucun rendez-vous précédent avec cette personne' using errcode = 'no_data_found';
  end if;

  -- Un recours au bouton Help ferme definitivement la relation.
  if exists (select 1 from help_requests h where h.date_id = v_date) then
    raise exception 'Cette relation ne peut pas être relancée' using errcode = 'check_violation';
  end if;

  if exists (select 1 from surprise_proposals s
             where s.from_user = u and s.to_user = cible and s.response is null) then
    raise exception 'Une proposition est déjà en attente' using errcode = 'unique_violation';
  end if;

  insert into surprise_proposals (from_user, to_user, previous_date_id)
  values (u, cible, v_date) returning id into v_id;
  return v_id;
end $$;


--
-- Name: request_account_deletion(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.request_account_deletion(u uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  insert into deletion_requests (user_id) values (u)
  on conflict (user_id) do update set requested_at = now(),
    execute_after = now() + interval '7 days', cancelled_at = null;
  update profiles set is_active = false where id = u;
end $$;


--
-- Name: reste_a_payer(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.reste_a_payer(d_id uuid) RETURNS integer
    LANGUAGE sql STABLE
    AS $$
  select greatest(0,
    private.addition_totale(d_id)
    - coalesce((select sum(p.amount_cents) from payments p
                where p.date_id = d_id and p.kind = 'paiement' and p.status = 'capture'), 0));
$$;


--
-- Name: FUNCTION reste_a_payer(d_id uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.reste_a_payer(d_id uuid) IS 'Solde restant sur le rendez-vous. Conditionne la cloture : un rendez-vous ne peut pas etre cloture tant qu''il est superieur a zero.';


--
-- Name: resultat_serie(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.resultat_serie(p_serie uuid) RETURNS TABLE(critere text, option_idx smallint, libelle text, presentes integer, decides integer, acceptes integer, taux numeric)
    LANGUAGE sql STABLE
    SET search_path TO 'public', 'private'
    AS $$
  select pp.critere_isole, o.idx, co.label,
         count(*)::int,
         count(sd.id)::int,
         count(*) filter (where sd.decision)::int,
         round(count(*) filter (where sd.decision)::numeric / nullif(count(sd.id), 0), 4)
  from public.profile_presentations pp
  join public.profile_answers pa
    on pa.user_id = pp.target_id and pa.criterion_key = pp.critere_isole
  cross join lateral unnest(pa.option_idx) o(idx)
  left join public.criterion_options co
    on co.criterion_key = pp.critere_isole and co.idx = o.idx
  left join public.swipe_decisions sd on sd.presentation_id = pp.id
  where pp.serie_id = p_serie
  group by pp.critere_isole, o.idx, co.label
  order by o.idx;
$$;


--
-- Name: FUNCTION resultat_serie(p_serie uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.resultat_serie(p_serie uuid) IS 'Compare les decisions au sein d''une meme serie. Les profils ne differant que sur le critere isole, l''ecart de taux d''acceptation lui est directement imputable.';


--
-- Name: reveal_establishment(uuid, uuid, public.geography); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.reveal_establishment(d_id uuid, u uuid, position_actuelle public.geography) RETURNS TABLE(nom text, adresse text, code_postal text, ville text)
    LANGUAGE plpgsql
    AS $$
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


--
-- Name: score_contextuel(uuid, uuid, public.rencontre_type); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.score_contextuel(u uuid, cible uuid, p_type public.rencontre_type) RETURNS TABLE(score numeric, atteint_seuil boolean, seuil numeric, poids_physique numeric, poids_mode_vie numeric, poids_valeurs numeric)
    LANGUAGE sql STABLE
    SET search_path TO 'public', 'private'
    AS $$
  with w as (select * from private.ponderations(u, p_type)),
       c as (select * from private.compat_cached(u, cible))
  select round(
           (coalesce(c.score_physique, 0) * w.poids_physique
          + coalesce(c.score_mode_vie, 0) * w.poids_mode_vie
          + coalesce(c.score_valeurs,  0) * w.poids_valeurs)
         , 2),
         round(
           (coalesce(c.score_physique, 0) * w.poids_physique
          + coalesce(c.score_mode_vie, 0) * w.poids_mode_vie
          + coalesce(c.score_valeurs,  0) * w.poids_valeurs)
         , 4) >= w.seuil_exigence * 100,
         w.seuil_exigence, w.poids_physique, w.poids_mode_vie, w.poids_valeurs
  from w, c where c.user_lo is not null;
$$;


--
-- Name: FUNCTION score_contextuel(u uuid, cible uuid, p_type public.rencontre_type); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.score_contextuel(u uuid, cible uuid, p_type public.rencontre_type) IS 'Recombine les scores par categorie deja calcules avec les ponderations du contexte recherche. Un meme couple obtient donc trois scores differents selon qu''on cherche l''amour, l''amitie ou une rencontre sans lendemain.';


--
-- Name: serie_contrastive(uuid, text, integer); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.serie_contrastive(u uuid, p_critere text, p_taille integer DEFAULT 4) RETURNS TABLE(profil_id uuid, option_idx smallint, ressemblance integer)
    LANGUAGE sql STABLE
    SET search_path TO 'public', 'private'
    AS $$
  with vivier as (
    select c.id
    from public.profiles c
    where c.id <> u and c.is_active
      and not public.are_blocked(u, c.id)
      and not exists (select 1 from public.swipe_decisions s
                      where s.user_id = u and s.target_id = c.id
                        and s.contexte = 'mieux_me_connaitre')
      and exists (select 1 from public.profile_answers pa
                  where pa.user_id = c.id and pa.criterion_key = p_critere)
  ),
  porteurs as (
    select v.id, o.idx
    from vivier v
    join public.profile_answers pa on pa.user_id = v.id and pa.criterion_key = p_critere
    cross join lateral unnest(pa.option_idx) o(idx)
  ),
  -- Un profil sert de reference : les autres sont choisis pour lui ressembler
  pivot as (select id, idx from porteurs order by random() limit 1),
  scores as (
    select p.id, p.idx,
           (select count(*)::int
              from public.profile_answers a
              join public.profile_answers b
                on b.criterion_key = a.criterion_key and b.option_idx && a.option_idx
             where a.user_id = (select id from pivot)
               and b.user_id = p.id
               and a.criterion_key <> p_critere) as ressemblance
    from porteurs p
  ),
  -- Le plus ressemblant pour chaque valeur du critere etudie
  meilleur as (
    select distinct on (idx) id, idx, ressemblance
    from scores order by idx, ressemblance desc, random()
  )
  select id, idx, ressemblance from meilleur
  order by ressemblance desc
  limit p_taille;
$$;


--
-- Name: FUNCTION serie_contrastive(u uuid, p_critere text, p_taille integer); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.serie_contrastive(u uuid, p_critere text, p_taille integer) IS 'Tire un profil de reference au hasard, puis retient pour chaque valeur du critere etudie le profil qui lui ressemble le plus par ailleurs. Les decisions de l''utilisateur deviennent alors attribuables a ce seul critere.';


--
-- Name: set_geolocation_choice(uuid, boolean, boolean, text, text); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.set_geolocation_choice(u uuid, autorise boolean, precise boolean, p_code text, p_version text) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
  if autorise then
    insert into consents (user_id, category, policy_code, policy_version)
    values (u,'geolocalisation',p_code,p_version);
    update profiles set geoloc_precise = precise where id = u;
  else
    update consents set withdrawn_at = now()
     where user_id = u and category = 'geolocalisation' and withdrawn_at is null;
    update profiles set geoloc_precise = null where id = u;
  end if;
  insert into user_step_completions (user_id, step) values (u,9) on conflict do nothing;
end $$;


--
-- Name: set_primary_photo(uuid, uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.set_primary_photo(u uuid, p uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
  update user_photos set is_primary = false where user_id = u and is_primary;
  update user_photos set is_primary = true where user_id = u and id = p;
  if not found then raise exception 'Photo introuvable pour cet utilisateur' using errcode='no_data_found'; end if;
end $$;


--
-- Name: signaler_presence(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.signaler_presence(u uuid) RETURNS integer
    LANGUAGE plpgsql
    SET search_path TO 'public', 'private'
    AS $$
declare n integer;
begin
  update public.profiles set last_seen_at = now() where id = u;

  -- Conversations pretes dont l'autre attend : de quoi le prevenir
  select count(*) into n
  from public.conversations c
  where c.status = 'prete' and (c.user_a = u or c.user_b = u);
  return n;
end $$;


--
-- Name: FUNCTION signaler_presence(u uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.signaler_presence(u uuid) IS 'Le retour en ligne d''un utilisateur est ce qui permet de prevenir celui qui attend. Sans ce signal, la salle d''attente resterait muette.';


--
-- Name: chat_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chat_requests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    from_user uuid NOT NULL,
    to_user uuid NOT NULL,
    compat_rate numeric(5,2),
    status public.chat_request_status DEFAULT 'en_attente'::public.chat_request_status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone,
    responded_at timestamp with time zone,
    type_rencontre public.rencontre_type DEFAULT 'amour'::public.rencontre_type NOT NULL,
    opened_at timestamp with time zone,
    stale_at timestamp with time zone DEFAULT (now() + '24:00:00'::interval) NOT NULL,
    postponed_at timestamp with time zone,
    postpone_count smallint DEFAULT 0 NOT NULL,
    ecran_ordre public.score_group[] DEFAULT ARRAY['physique'::public.score_group, 'valeurs'::public.score_group, 'mode_vie'::public.score_group] NOT NULL,
    CONSTRAINT chat_request_pas_soi_meme CHECK ((from_user <> to_user)),
    CONSTRAINT chat_requests_ecran_ordre_complet CHECK ((cardinality(ecran_ordre) = 3)),
    CONSTRAINT chat_requests_ouverture_coherente CHECK ((num_nulls(opened_at, expires_at) <> 1)),
    CONSTRAINT chat_requests_postpone_max CHECK (((postpone_count >= 0) AND (postpone_count <= 1)))
);


--
-- Name: TABLE chat_requests; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.chat_requests IS 'Demande d''ouverture de discussion. Delai de reponse de 30 minutes, au-dela la demande expire et est consideree comme ignoree.';


--
-- Name: COLUMN chat_requests.opened_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.chat_requests.opened_at IS 'Premiere ouverture par le destinataire. Le delai de 30 minutes ne demarre qu''ici : une demande jamais ouverte ne peut pas expirer par simple ecoulement du temps.';


--
-- Name: COLUMN chat_requests.stale_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.chat_requests.stale_at IS 'Peremption d''une demande jamais ouverte (24h). Evite l''accumulation indefinie de demandes en attente.';


--
-- Name: COLUMN chat_requests.postpone_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.chat_requests.postpone_count IS 'Nombre de reports. Limite a 1 : le report gele le compte a rebours et accorde un sursis unique.';


--
-- Name: COLUMN chat_requests.ecran_ordre; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.chat_requests.ecran_ordre IS 'Ordre des trois ecrans du profil fige au moment de l''envoi. L''emetteur ne peut pas modifier ce qu''il met en avant pendant qu''une demande est en vol.';


--
-- Name: statut_effectif(public.chat_requests); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.statut_effectif(r public.chat_requests) RETURNS public.chat_request_status
    LANGUAGE sql STABLE
    AS $$
  select case
    when r.status not in ('en_attente','reportee') then r.status
    when r.opened_at is null and r.stale_at  <= now() then 'expiree'::public.chat_request_status
    when r.opened_at is not null and r.expires_at <= now() then 'expiree'::public.chat_request_status
    else r.status
  end;
$$;


--
-- Name: FUNCTION statut_effectif(r public.chat_requests); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.statut_effectif(r public.chat_requests) IS 'Statut recalcule a la lecture. Le floutage cote application est purement cosmetique : seule cette fonction fait foi.';


--
-- Name: submit_answer(uuid, text, smallint[]); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.submit_answer(u uuid, k text, idx smallint[]) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
declare n_opt int; multi boolean;
begin
  select count(*), bool_or(c.multi_select) into n_opt, multi
  from criterion_options o join criteria c on c.key = o.criterion_key
  where o.criterion_key = k;
  if n_opt = 0 then
    raise exception 'Critère inconnu : %', k using errcode = 'foreign_key_violation';
  end if;
  if array_length(idx, 1) is null or array_length(idx, 1) = 0 then
    raise exception 'Réponse vide pour le critère %', k using errcode = 'check_violation';
  end if;
  if not multi and array_length(idx, 1) > 1 then
    raise exception 'Le critère % n''accepte qu''une seule réponse', k using errcode = 'check_violation';
  end if;
  if exists (select 1 from unnest(idx) as i where i < 0 or i >= n_opt) then
    raise exception 'Option hors bornes pour le critère % (0 à %)', k, n_opt - 1 using errcode = 'check_violation';
  end if;
  insert into profile_answers (user_id, criterion_key, option_idx) values (u, k, idx)
  on conflict (user_id, criterion_key) do update
    set option_idx = excluded.option_idx, answered_at = now();
end $$;


--
-- Name: taux_exploration(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.taux_exploration(u uuid) RETURNS numeric
    LANGUAGE sql STABLE
    SET search_path TO 'public', 'private'
    AS $$
  select round(greatest(
    private.engine_param('expl_taux_plancher'),
    private.engine_param('expl_taux_initial')
    - (private.engine_param('expl_taux_initial') - private.engine_param('expl_taux_plancher'))
      * least(1.0, (select count(*) from public.swipe_decisions
                    where user_id = u and contexte = 'mieux_me_connaitre')::numeric
                   / nullif(private.engine_param('expl_maturite_swipes'), 0))
  ), 3);
$$;


--
-- Name: FUNCTION taux_exploration(u uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.taux_exploration(u uuid) IS 'Decroit avec l''experience mais ne s''annule jamais. Un moteur qui cesse d''explorer ne verifie plus si l''utilisateur aime reellement ce qu''on lui montre, ou si on ne lui a simplement montre que cela.';


--
-- Name: terminer_date(uuid, uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.terminer_date(u uuid, d_id uuid) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare v_reste integer;
begin
  if not exists (select 1 from dates where id = d_id and (user_a = u or user_b = u)) then
    raise exception 'Rendez-vous introuvable' using errcode = 'no_data_found';
  end if;
  v_reste := private.reste_a_payer(d_id);
  update dates set ended_at = now(), ended_by = u
   where id = d_id and closed_at is null;
  return v_reste;
end $$;


--
-- Name: FUNCTION terminer_date(u uuid, d_id uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.terminer_date(u uuid, d_id uuid) IS 'Signale la fin du rendez-vous et renvoie le solde restant. Tant que la cloture n''a pas commence, l''action reste reversible.';


--
-- Name: traiter_signalement(uuid, public.moderation_action, text, uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.traiter_signalement(p_report uuid, p_action public.moderation_action, p_motif text DEFAULT NULL::text, p_moderateur uuid DEFAULT NULL::uuid) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
declare r reports; v_id uuid; v_expire timestamptz; v_delai numeric;
begin
  select * into r from reports where id = p_report;
  if r is null then
    raise exception 'Signalement introuvable' using errcode = 'no_data_found';
  end if;
  if r.status = 'traite' then
    raise exception 'Ce signalement a déjà été traité' using errcode = 'check_violation';
  end if;

  if p_action = 'suspension_temporaire' then
    v_expire := now() + (private.engine_param('moderation_suspension_jours') || ' days')::interval;
  end if;

  insert into moderation_actions (user_id, report_id, action, motif, decided_by, expires_at)
  values (r.reported_id, p_report, p_action, p_motif, p_moderateur, v_expire)
  returning id into v_id;

  -- Effet sur le compte
  if p_action in ('suspension_temporaire','bannissement') then
    update profiles set is_active = false where id = r.reported_id;
  end if;

  update reports
     set status  = case when p_action = 'classe_sans_suite' then 'rejete' else 'traite' end::report_status,
         handled_at = now(), handled_by = p_moderateur, outcome = p_action::text
   where id = p_report;

  -- Message a l'utilisateur. Le rappel des regles est differe de quelques
  -- heures : il ne doit pas se lire comme une reaction immediate a la
  -- conversation qui vient de se terminer.
  v_delai := private.engine_param('moderation_delai_rappel_h');

  if p_action = 'rappel_regles' then
    insert into platform_messages (user_id, code, titre, corps, a_envoyer_a)
    values (r.reported_id, 'rappel_regles', 'Rappel des règles de la communauté',
      'Nous avons reçu un signalement concernant l''une de vos dernières conversations. '
      || 'Après analyse, nous souhaitons vous rappeler que Safe Date repose sur le respect, '
      || 'la bienveillance et la sécurité de chacun. Nous vous invitons à adopter un '
      || 'comportement conforme à nos règles de la communauté. En cas de nouveaux '
      || 'signalements, votre compte pourra être suspendu ou définitivement banni.',
      now() + (v_delai || ' hours')::interval);

  elsif p_action = 'avertissement' then
    insert into platform_messages (user_id, code, titre, corps)
    values (r.reported_id, 'avertissement', 'Avertissement officiel',
      'Un nouveau signalement nous est parvenu à votre sujet. Il s''agit d''un '
      || 'avertissement officiel. Tout nouveau manquement entraînera la suspension '
      || 'de votre compte.');

  elsif p_action = 'suspension_temporaire' then
    insert into platform_messages (user_id, code, titre, corps)
    values (r.reported_id, 'suspension', 'Compte suspendu',
      'Votre compte est temporairement suspendu à la suite de signalements répétés. '
      || 'Il sera automatiquement réactivé à l''issue de cette période.');

  elsif p_action = 'bannissement' then
    insert into platform_messages (user_id, code, titre, corps)
    values (r.reported_id, 'bannissement', 'Compte fermé',
      'Votre compte a été fermé définitivement pour manquement grave à nos '
      || 'Conditions Générales d''Utilisation.');
  end if;

  return jsonb_build_object('mesure_id', v_id, 'action', p_action,
                            'expire_le', v_expire,
                            'compte_desactive', p_action in ('suspension_temporaire','bannissement'));
end $$;


--
-- Name: transmettre_commande(uuid, uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.transmettre_commande(u uuid, o_id uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare v orders;
begin
  select * into v from orders where id = o_id and user_id = u;
  if v is null then
    raise exception 'Commande introuvable' using errcode = 'no_data_found';
  end if;
  if v.status <> 'brouillon' then
    raise exception 'Cette commande a déjà été transmise' using errcode = 'check_violation';
  end if;
  if not exists (select 1 from order_items where order_id = o_id) then
    raise exception 'Commande vide' using errcode = 'check_violation';
  end if;
  update orders set status = 'transmise', sent_at = now() where id = o_id;
end $$;


--
-- Name: FUNCTION transmettre_commande(u uuid, o_id uuid); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.transmettre_commande(u uuid, o_id uuid) IS 'Chaque utilisateur commande quand il le souhaite : il n''est jamais necessaire que les deux valident simultanement.';


--
-- Name: trg_invalider_compat(); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.trg_invalider_compat() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  perform private.invalider_compat(new.user_id);
  return new;
end $$;


--
-- Name: user_activation_checklist(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.user_activation_checklist(u uuid) RETURNS TABLE(rang smallint, condition text, satisfaite boolean)
    LANGUAGE sql STABLE
    AS $$
  with e as (select * from profiles where id = u)
  select * from (values
    (1::smallint,'Langue sélectionnée',(select langue is not null from e)),
    (2,'Compte créé et vérifié',exists (select 1 from user_step_completions where user_id=u and step=3)),
    (3,'Adresse e-mail ou numéro de téléphone validé',exists (select 1 from user_verification_codes where user_id=u and verified_at is not null)),
    (4,'Pays sélectionné',(select pays is not null from e)),
    (5,'Questionnaire initial complété',exists (select 1 from user_step_completions where user_id=u and step=5)),
    (6,'Au moins une photo de profil téléchargée',(select count(*) >= 1 from user_photos where user_id=u and moderation <> 'rejetee')),
    (7,'Vérification biométrique validée',exists (select 1 from identity_verifications where user_id=u and status='validee')),
    (8,'Conditions générales d''utilisation acceptées',exists (select 1 from user_acceptances where user_id=u and policy_code='cgu')),
    (9,'Politique de confidentialité acceptée',exists (select 1 from user_acceptances where user_id=u and policy_code='confidentialite')),
    (10,'Consentement au traitement des données personnelles validé',exists (select 1 from user_acceptances where user_id=u and policy_code='donnees_personnelles')))
  as t(rang, condition, satisfaite);
$$;


--
-- Name: user_progress(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.user_progress(u uuid) RETURNS TABLE(etape_courante smallint, etapes_total smallint, secondes_restantes integer, compte_actif boolean)
    LANGUAGE sql STABLE
    AS $$
  select coalesce((select min(s.step) from user_steps s
      where not exists (select 1 from user_step_completions c where c.user_id=u and c.step=s.step)),
      (select max(step) from user_steps))::smallint,
    (select count(*) from user_steps)::smallint,
    (select coalesce(sum(s.est_seconds),0)::int from user_steps s
      where not exists (select 1 from user_step_completions c where c.user_id=u and c.step=s.step)),
    (select is_active and is_verified from profiles where id = u);
$$;


--
-- Name: verify_account_code(uuid, text); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.verify_account_code(u uuid, code text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare ok boolean; max_essais constant int := 5;
begin
  if (select attempts from user_verification_codes where user_id = u) >= max_essais then
    raise exception 'Nombre maximal de tentatives atteint, demandez un nouveau code'
      using errcode = 'check_violation';
  end if;
  update user_verification_codes
     set attempts = attempts + 1,
         verified_at = case when code_sha256 = encode(sha256(upper(trim(code))::bytea),'hex')
                              and now() < expires_at then now() else verified_at end
   where user_id = u returning verified_at is not null into ok;
  if coalesce(ok,false) then
    insert into user_step_completions (user_id, step) values (u,3) on conflict do nothing;
  end if;
  return coalesce(ok,false);
end $$;


--
-- Name: verify_postal_code(uuid, text); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.verify_postal_code(p uuid, code text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
declare ok boolean;
begin
  update partner_postal_verifications
     set attempts = attempts + 1,
         verified_at = case when code_sha256 = encode(sha256(upper(trim(code))::bytea),'hex')
                            then now() else verified_at end
   where partner_id = p returning verified_at is not null into ok;
  return coalesce(ok, false);
end $$;


--
-- Name: verrouiller_conversations(); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.verrouiller_conversations() RETURNS integer
    LANGUAGE plpgsql
    SET search_path TO 'public', 'private'
    AS $$
declare n integer; m integer;
begin
  update public.conversations
     set status = 'verrouillee', locked_at = now()
   where status = 'active' and not illimitee
     and ends_at is not null and ends_at <= now();
  get diagnostics n = row_count;

  -- Une conversation prete depuis trop longtemps n'aboutira pas
  update public.conversations
     set status = 'cloturee', locked_at = now()
   where status = 'prete'
     and prete_at <= now() - (private.engine_param('conversation_prete_peremption_h') || ' hours')::interval;
  get diagnostics m = row_count;

  return n + m;
end $$;


--
-- Name: FUNCTION verrouiller_conversations(); Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON FUNCTION private.verrouiller_conversations() IS 'Verrouillage simultane pour les deux utilisateurs a expiration du compte a rebours, afin de garantir une duree d''echange identique.';


--
-- Name: visible_priorities(uuid); Type: FUNCTION; Schema: private; Owner: -
--

CREATE FUNCTION private.visible_priorities(u uuid) RETURNS TABLE(rang smallint, pair_key text, phrase text, verrouille boolean)
    LANGUAGE sql STABLE
    AS $$
  with lim as (select case when (select is_premium from profiles where id=u)
      then private.engine_param('priorites_visibles_premium')
      else private.engine_param('priorites_visibles_gratuit') end as n)
  select p.rang, p.pair_key, ph.phrase, p.rang > (select n from lim) as verrouille
  from user_criterion_priorities p
  join criterion_pairs cp on cp.pair_key = p.pair_key
  left join profile_answers pa on pa.user_id=u and pa.criterion_key=cp.pref_key
  left join criterion_option_phrasings ph on ph.criterion_key=cp.pref_key and ph.idx=pa.option_idx[1]
    and ph.locale = coalesce((select langue from profiles where id=u),'fr')
  where p.user_id = u and p.rang <= private.engine_param('priorites_visibles_premium')
  order by p.rang;
$$;


--
-- Name: activate_partner(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.activate_partner(p uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare manquantes text;
begin
  select string_agg(condition,' · ' order by rang) into manquantes
  from partner_activation_checklist(p) where not coalesce(satisfaite,false);
  if manquantes is not null then
    raise exception 'Activation impossible, conditions non remplies : %', manquantes
      using errcode = 'check_violation';
  end if;
  update partners set status='actif', activated_at=now() where id = p;
  insert into partner_step_completions (partner_id, step) values (p,16) on conflict do nothing;
end $$;


--
-- Name: activate_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.activate_user() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  perform private.activate_user(auth.uid());
end $$;


--
-- Name: answer_progress(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.answer_progress() RETURNS TABLE(onboarding_repondus integer, onboarding_total integer, quiz_repondus integer, quiz_total integer, paires_completes integer, criteres_evaluables integer)
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.answer_progress(auth.uid());
end $$;


--
-- Name: are_blocked(uuid, uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.are_blocked(a uuid, b uuid) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  select exists (select 1 from blocks
    where (blocker_id = a and blocked_id = b) or (blocker_id = b and blocked_id = a));
$$;


--
-- Name: attraction_vs_reussite(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.attraction_vs_reussite() RETURNS TABLE(criterion_key text, option_idx smallint, libelle text, attraction numeric, satisfaction numeric, rencontres integer, pouvoir_predictif numeric, verdict text)
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.attraction_vs_reussite(auth.uid());
end $$;


--
-- Name: boite_reception(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.boite_reception() RETURNS TABLE(demande_id uuid, emetteur uuid, prenom text, age integer, photo_principale text, profil_verifie boolean, type_rencontre public.rencontre_type, compat_rate numeric, ecran_ordre public.score_group[], ecran_vignette public.score_group, distance text, statut public.chat_request_status, secondes_restantes integer, reportable boolean)
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.boite_reception(auth.uid());
end $$;


--
-- Name: candidate_cards(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.candidate_cards() RETURNS TABLE(candidate_id uuid, prenom text, age integer, photo text, verifie boolean, score_global numeric, score_physique numeric, score_valeurs numeric, score_mode_vie numeric, score_aller numeric, score_retour numeric, criteres_evalues integer, filtres_ok boolean, affichable boolean, au_dela_du_seuil boolean, highlights jsonb)
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
declare premium boolean; voile boolean;
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  select coalesce(is_premium,false) into premium from profiles where id = auth.uid();

  return query
  select k.candidate_id,
    case when k.au_dela_du_seuil and not premium then null else k.prenom end,
    k.age,
    case when k.au_dela_du_seuil and not premium then null else k.photo end,
    k.verifie,
    case when k.au_dela_du_seuil and not premium then null else k.score_global end,
    case when k.au_dela_du_seuil and not premium then null else k.score_physique end,
    case when k.au_dela_du_seuil and not premium then null else k.score_valeurs end,
    case when k.au_dela_du_seuil and not premium then null else k.score_mode_vie end,
    case when k.au_dela_du_seuil and not premium then null else k.score_aller end,
    case when k.au_dela_du_seuil and not premium then null else k.score_retour end,
    k.criteres_evalues, k.filtres_ok, k.affichable, k.au_dela_du_seuil,
    case when k.au_dela_du_seuil and not premium then '[]'::jsonb else k.highlights end
  from private.candidate_cards(auth.uid()) k;
end $$;


--
-- Name: FUNCTION candidate_cards(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.candidate_cards() IS 'Point d''entree unique de l''ecran Decouverte. Rejoue le filtre d''eligibilite plutot que de faire confiance a l''appelant. Au-dela du seuil premium, le prenom, la photo et les scores sont mis a NULL cote serveur : l''identite ne quitte pas la base tant que l''abonnement n''est pas actif. Le voile n''est donc pas contournable en inspectant la reponse reseau.';


--
-- Name: check_partner_eligibility(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_partner_eligibility(p uuid) RETURNS TABLE(eligible boolean, motif text)
    LANGUAGE plpgsql
    AS $$
declare e partners; note_min numeric; avis_min numeric; m text := null;
begin
  select * into e from partners where id = p;
  note_min := private.engine_param('partenaire_note_min');
  avis_min := private.engine_param('partenaire_avis_min');
  if e.google_place_id is null then m := 'Fiche Google Maps introuvable ou invalide';
  elsif e.google_note is null or e.google_note < note_min then
    m := format('Note Google de %s, minimum requis %s', coalesce(e.google_note::text,'inconnue'), note_min);
  elsif e.google_avis is null or e.google_avis < avis_min then
    m := format('%s avis Google, minimum requis %s', coalesce(e.google_avis::text,'0'), avis_min);
  end if;
  if m is not null then
    update partners set status = 'rejete', motif_rejet = m where id = p;
    return query select false, m;
  else
    insert into partner_step_completions (partner_id, step) values (p, 7) on conflict do nothing;
    return query select true, null::text;
  end if;
end $$;


--
-- Name: cloturer_session(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cloturer_session() RETURNS TABLE(message text, niveau numeric, niveau_hier numeric, progression numeric, profils_vus integer, illimite boolean)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.cloturer_session(auth.uid());
end $$;


--
-- Name: compat_score(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.compat_score(autre uuid) RETURNS TABLE(filtres_ok boolean, score_global numeric, score_physique numeric, score_valeurs numeric, score_mode_vie numeric, score_a_vers_b numeric, score_b_vers_a numeric, criteres_evalues integer, affichable boolean)
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  if not exists (select 1 from private.eligible_candidates(auth.uid()) where candidate_id = autre) then
    raise exception 'Ce profil ne fait pas partie de vos candidats' using errcode='insufficient_privilege';
  end if;
  return query select * from private.compat_score(auth.uid(), autre);
end $$;


--
-- Name: complete_questionnaire_step(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.complete_questionnaire_step() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  perform private.complete_questionnaire_step(auth.uid());
end $$;


--
-- Name: consentements_requis_questionnaire(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.consentements_requis_questionnaire() RETURNS TABLE(categorie public.sensitive_category, criteres integer, accorde boolean)
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  return query select * from private.consentements_requis_questionnaire(auth.uid());
end $$;


--
-- Name: couverture_criteres(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.couverture_criteres() RETURNS TABLE(criterion_key text, grp public.score_group, libelle text, observations integer, confiance numeric, documente boolean)
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.couverture_criteres(auth.uid());
end $$;


--
-- Name: creer_demande(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.creer_demande(cible uuid) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return private.creer_demande(auth.uid(), cible);
end $$;


--
-- Name: diagnostic_zones(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.diagnostic_zones(p_id uuid) RETURNS TABLE(zones_validees integer, points_possibles integer, couple_possible boolean, ecart_max_m numeric)
    LANGUAGE plpgsql
    AS $$
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


--
-- Name: eligible_candidates(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.eligible_candidates() RETURNS TABLE(candidate_id uuid)
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  return query select * from private.eligible_candidates(auth.uid());
end $$;


--
-- Name: enregistrer_swipe(uuid, boolean, public.swipe_contexte, boolean, text, integer, jsonb, public.score_group[], integer, text[], text[], public.rencontre_type, bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.enregistrer_swipe(cible uuid, garder boolean, contexte public.swipe_contexte DEFAULT 'partir_en_date'::public.swipe_contexte, signal_fort boolean DEFAULT false, ecran text DEFAULT NULL::text, duree_ms integer DEFAULT NULL::integer, ecrans jsonb DEFAULT NULL::jsonb, ordre_consultation public.score_group[] DEFAULT NULL::public.score_group[], retours integer DEFAULT 0, criteres_exposes text[] DEFAULT NULL::text[], criteres_consultes text[] DEFAULT NULL::text[], type_rencontre public.rencontre_type DEFAULT NULL::public.rencontre_type, presentation_id bigint DEFAULT NULL::bigint) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return private.enregistrer_swipe(auth.uid(), cible, garder, contexte, signal_fort,
    ecran, duree_ms, ecrans, ordre_consultation, retours, criteres_exposes,
    criteres_consultes, type_rencontre, presentation_id);
end $$;


--
-- Name: envoyer_message(uuid, public.message_kind, text, text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.envoyer_message(conv uuid, p_kind public.message_kind DEFAULT 'texte'::public.message_kind, p_body text DEFAULT NULL::text, p_media text DEFAULT NULL::text, p_duree integer DEFAULT NULL::integer) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return private.envoyer_message(auth.uid(), conv, p_kind, p_body, p_media, p_duree);
end $$;


--
-- Name: etat_conversation(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.etat_conversation(conversation uuid) RETURNS TABLE(statut public.conversation_status, autre uuid, prenom_autre text, autre_en_ligne boolean, secondes_restantes integer, message text)
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.etat_conversation(auth.uid(), conversation);
end $$;


--
-- Name: etat_session(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.etat_session() RETURNS TABLE(profils_vus integer, quota integer, restants integer, illimite boolean, niveau numeric)
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.etat_session(auth.uid());
end $$;


--
-- Name: expirer_points_rendezvous(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.expirer_points_rendezvous() RETURNS integer
    LANGUAGE sql
    AS $$
  with sup as (delete from date_meeting_points m using dates d
    where d.id = m.date_id and (d.status in ('termine','annule') or now() > m.expires_at) returning 1)
  select count(*)::int from sup;
$$;


--
-- Name: fil_apprentissage(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fil_apprentissage(taille integer DEFAULT 20) RETURNS TABLE(presentation_id bigint, profil_id uuid, prenom text, age integer, photo_principale text, profil_verifie boolean, ordre_pages public.score_group[], criteres jsonb, besoin numeric, attendu numeric, motif text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.fil_apprentissage(auth.uid(), taille);
end $$;


--
-- Name: fil_profils(numeric, uuid, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fil_profils(apres numeric DEFAULT NULL::numeric, apres_id uuid DEFAULT NULL::uuid, taille integer DEFAULT NULL::integer) RETURNS TABLE(profil_id uuid, prenom text, age integer, photo_principale text, profil_verifie boolean, est_premium boolean, compat_rate numeric, score_physique numeric, score_valeurs numeric, score_mode_vie numeric, distance text, proposable boolean, motif text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.fil_profils(auth.uid(), apres, apres_id, taille);
end $$;


--
-- Name: focus_en_attente(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.focus_en_attente() RETURNS TABLE(focus_id uuid, contexte public.focus_context, criterion_key text, direction text, question text, intitule text, multi boolean, options jsonb)
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.focus_en_attente(auth.uid());
end $$;


--
-- Name: has_consent(uuid, public.sensitive_category); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.has_consent(u uuid, c public.sensitive_category) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  select exists (select 1 from consents where user_id = u and category = c and withdrawn_at is null);
$$;


--
-- Name: learning_profile(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.learning_profile() RETURNS TABLE(pair_key text, grp public.score_group, question text, learned_mul numeric, observations integer, tendance text)
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.learning_profile(auth.uid());
end $$;


--
-- Name: mask_top_idx(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.mask_top_idx(m integer) RETURNS smallint
    LANGUAGE sql IMMUTABLE
    AS $$ select case when m is null or m = 0 then null
                else (length(to_bin(m)) - 1)::smallint end $$;


--
-- Name: FUNCTION mask_top_idx(m integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.mask_top_idx(m integer) IS 'Index de l''option depuis son masque. Exact pour les criteres a choix unique, renvoie le rang le plus eleve en choix multiple.';


--
-- Name: menu_label_conflit(uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.menu_label_conflit(p uuid, label text) RETURNS text
    LANGUAGE plpgsql STABLE
    AS $_$
declare e partners; l text; nom text; mot text;
begin
  select * into e from partners where id = p;
  l := lower(unaccent(label));
  foreach nom in array array[e.nom_commercial, e.raison_sociale] loop
    if nom is not null and length(trim(nom)) >= 3
       and position(lower(unaccent(trim(nom))) in l) > 0 then return trim(nom); end if;
  end loop;
  for mot in select distinct t.m from (
      select unnest(string_to_array(lower(unaccent(coalesce(e.nom_commercial,''))),' ')) as m
      union all
      select unnest(string_to_array(lower(unaccent(coalesce(e.raison_sociale,''))),' '))) t
    where length(t.m) >= 4 and not exists (select 1 from menu_stopwords s where s.mot = t.m)
  loop
    if l ~ ('\m' || regexp_replace(mot,'([.^$*+?()\[\]{}|\\])','\\\1','g') || '\M') then
      return mot;
    end if;
  end loop;
  return null;
end $_$;


--
-- Name: mes_ponderations(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.mes_ponderations() RETURNS TABLE(type_rencontre public.rencontre_type, poids_physique numeric, poids_mode_vie numeric, poids_valeurs numeric, seuil_exigence numeric, observations integer, confiance numeric)
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query
    select d.type_rencontre,
           coalesce(w.poids_physique, d.poids_physique),
           coalesce(w.poids_mode_vie, d.poids_mode_vie),
           coalesce(w.poids_valeurs,  d.poids_valeurs),
           coalesce(w.seuil_exigence, d.seuil_exigence),
           coalesce(w.observations, 0),
           coalesce(w.confiance, 0)
    from public.context_weight_defaults d
    left join public.user_context_weights w
           on w.user_id = auth.uid() and w.type_rencontre = d.type_rencontre
    order by d.type_rencontre;
end $$;


--
-- Name: next_questions(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.next_questions(n integer DEFAULT 3) RETURNS TABLE(criterion_key text, question text, moment public.collection_moment, grp public.score_group, priorite numeric, motif text)
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.next_questions(auth.uid(), n);
end $$;


--
-- Name: om_accepted_mask(smallint[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.om_accepted_mask(a smallint[]) RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $$ select coalesce((select bit_or(1 << x::int) from unnest(a) as x), 0) $$;


--
-- Name: ouvrir_demande(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.ouvrir_demande(demande uuid) RETURNS public.chat_request_status
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return private.ouvrir_demande(auth.uid(), demande);
end $$;


--
-- Name: partner_activation_checklist(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.partner_activation_checklist(p uuid) RETURNS TABLE(rang smallint, condition text, satisfaite boolean)
    LANGUAGE sql STABLE
    AS $$
  with e as (select * from partners where id = p)
  select * from (values
    (1::smallint,'Langue sélectionnée',(select langue is not null from e)),
    (2,'Compte créé et vérifié',exists (select 1 from partner_step_completions where partner_id=p and step=3)),
    (3,'Pays sélectionné',(select pays is not null from e)),
    (4,'Informations générales complétées',(select nom_commercial is not null and raison_sociale is not null
        and adresse is not null and telephone is not null and email is not null from e)),
    (5,'Documents administratifs validés',exists (select 1 from partner_documents where partner_id=p and status='validee')),
    (6,'Fiche Google Maps valide',(select google_place_id is not null from e)),
    (7,'Note Google supérieure ou égale au minimum requis',(select google_note >= private.engine_param('partenaire_note_min') from e)),
    (8,'Nombre d''avis Google suffisant',(select google_avis >= private.engine_param('partenaire_avis_min') from e)),
    (9,'Identité de l''établissement vérifiée',exists (select 1 from partner_step_completions where partner_id=p and step=8)),
    (10,'Vérification postale validée',exists (select 1 from partner_postal_verifications where partner_id=p and verified_at is not null)),
    (11,'Conditions générales d''utilisation acceptées',exists (select 1 from partner_acceptances where partner_id=p and policy_code='cgu')),
    (12,'Politique de confidentialité acceptée',exists (select 1 from partner_acceptances where partner_id=p and policy_code='confidentialite')),
    (13,'Consentement au traitement des données personnelles validé',exists (select 1 from partner_acceptances where partner_id=p and policy_code='donnees_personnelles')),
    (14,'Contrat de partenariat signé électroniquement',exists (select 1 from partner_contracts where partner_id=p and status='validee' and signed_at is not null)),
    (15,'Menu entièrement configuré',(select count(*) >= 1 from partner_menu_items where partner_id=p)),
    (16,'Au moins une photo sélectionnée ou importée',(select count(*) >= 1 from partner_photos where partner_id=p)),
    (17,'Compte de reversement opérationnel',exists (select 1 from partner_payout_accounts where partner_id=p and charges_enabled and payouts_enabled)),
    (18,'Formations obligatoires validées',not exists (select 1 from training_modules m
        where m.obligatoire and not exists (select 1 from partner_training_completions c
          where c.partner_id=p and c.module_code=m.code and c.passed))))
  as t(rang, condition, satisfaite);
$$;


--
-- Name: partner_progress(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.partner_progress(p uuid) RETURNS TABLE(etape_courante smallint, etapes_total smallint, minutes_restantes integer, statut public.partner_status)
    LANGUAGE sql STABLE
    AS $$
  select coalesce((select min(s.step) from partner_steps s
      where not exists (select 1 from partner_step_completions c where c.partner_id=p and c.step=s.step)),
      (select max(step) from partner_steps))::smallint,
    (select count(*) from partner_steps)::smallint,
    (select coalesce(sum(s.est_minutes),0)::int from partner_steps s
      where not exists (select 1 from partner_step_completions c where c.partner_id=p and c.step=s.step)),
    (select status from partners where id = p);
$$;


--
-- Name: peut_proposer(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.peut_proposer(cible uuid) RETURNS TABLE(autorise boolean, motif text)
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.peut_proposer(auth.uid(), cible);
end $$;


--
-- Name: priorite_coef(smallint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.priorite_coef(rang smallint) RETURNS numeric
    LANGUAGE sql IMMUTABLE
    AS $$
  select case when rang is null then 1.0
    when rang >= private.engine_param('priorites_visibles_premium') then 1.0
    else private.engine_param('priorite_coef_max')
         - (private.engine_param('priorite_coef_max') - 1.0) * (rang - 1)
           / (private.engine_param('priorites_visibles_premium') - 1) end::numeric;
$$;


--
-- Name: profil_preferences(numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.profil_preferences(min_confiance numeric DEFAULT 0) RETURNS TABLE(criterion_key text, libelle text, grp public.score_group, observations integer, taux_oui numeric, importance numeric, confiance numeric, derive boolean)
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.profil_preferences(auth.uid(), min_confiance);
end $$;


--
-- Name: profile_header(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.profile_header() RETURNS TABLE(age integer, photo_principale text, profil_verifie boolean, connaissance numeric, est_premium boolean)
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  return query select * from private.profile_header(auth.uid());
end $$;


--
-- Name: profile_knowledge(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.profile_knowledge() RETURNS numeric
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  return private.profile_knowledge(auth.uid());
end $$;


--
-- Name: profile_sections(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.profile_sections() RETURNS TABLE(section public.score_group, ord smallint, pair_key text, phrase text)
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  return query select * from private.profile_sections(auth.uid());
end $$;


--
-- Name: proposer_conversation(uuid, public.rencontre_type, public.score_group[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.proposer_conversation(cible uuid, type_rencontre public.rencontre_type, ordre_ecrans public.score_group[] DEFAULT ARRAY['physique'::public.score_group, 'valeurs'::public.score_group, 'mode_vie'::public.score_group]) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return private.proposer_conversation(auth.uid(), cible, type_rencontre, ordre_ecrans);
end $$;


--
-- Name: proximite_disponible(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.proximite_disponible() RETURNS boolean
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then return false; end if;
  return private.proximite_disponible(auth.uid());
end $$;


--
-- Name: quota_restant(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.quota_restant() RETURNS integer
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return private.quota_restant(auth.uid());
end $$;


--
-- Name: rejoindre_conversation(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.rejoindre_conversation(conversation uuid) RETURNS TABLE(statut public.conversation_status, demarree boolean, attend_qui uuid, decompte_s integer, secondes_restantes integer)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return query select * from private.rejoindre_conversation(auth.uid(), conversation);
end $$;


--
-- Name: render_measure(numeric, numeric, text, public.unit_system); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.render_measure(v_min numeric, v_max numeric, v_unit text, sys public.unit_system) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare f numeric; suffixe text; a text; b text;
begin
  if v_unit is null then return null; end if;
  if sys = 'metrique' then
    if v_min is null then return format('moins de %s %s', v_max, v_unit); end if;
    if v_max is null then return format('plus de %s %s', v_min, v_unit); end if;
    return format('entre %s et %s %s', v_min, v_max, v_unit);
  end if;
  if v_unit = 'kg' then
    f := 2.20462; suffixe := ' lb';
    a := case when v_min is null then null else round(v_min * f)::text end;
    b := case when v_max is null then null else round(v_max * f)::text end;
  else
    a := case when v_min is null then null else format('%s''%s"', floor(v_min/2.54/12), round(v_min/2.54) % 12) end;
    b := case when v_max is null then null else format('%s''%s"', floor(v_max/2.54/12), round(v_max/2.54) % 12) end;
    suffixe := '';
  end if;
  if a is null then return format('moins de %s%s', b, suffixe); end if;
  if b is null then return format('plus de %s%s', a, suffixe); end if;
  return format('entre %s et %s%s', a, b, suffixe);
end $$;


--
-- Name: reorder_priorities(text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reorder_priorities(ordre text[]) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  perform private.reorder_priorities(auth.uid(), ordre);
end $$;


--
-- Name: repondre_demande(uuid, public.date_intent); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.repondre_demande(demande uuid, reponse public.date_intent) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return private.repondre_demande(auth.uid(), demande, reponse);
end $$;


--
-- Name: repondre_focus(uuid, smallint[], text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.repondre_focus(focus uuid, options smallint[] DEFAULT NULL::smallint[], categorie text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  perform private.repondre_focus(auth.uid(), focus, options, categorie);
end $$;


--
-- Name: reproposer_date_surprise(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reproposer_date_surprise(cible uuid) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return private.reproposer_date_surprise(auth.uid(), cible);
end $$;


--
-- Name: request_account_deletion(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.request_account_deletion() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
declare u uuid := auth.uid();
begin
  if u is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  insert into deletion_requests (user_id) values (u)
  on conflict (user_id) do update set requested_at = now(),
    execute_after = now() + interval '7 days', cancelled_at = null;
  update profiles set is_active = false where id = u;
end $$;


--
-- Name: reveal_establishment(uuid, public.geography); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reveal_establishment(d_id uuid, position_actuelle public.geography) RETURNS TABLE(nom text, adresse text, code_postal text, ville text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  return query select * from private.reveal_establishment(d_id, auth.uid(), position_actuelle);
end $$;


--
-- Name: set_geolocation_choice(boolean, boolean, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_geolocation_choice(autorise boolean, precise boolean, p_code text, p_version text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  perform private.set_geolocation_choice(auth.uid(), autorise, precise, p_code, p_version);
end $$;


--
-- Name: set_primary_photo(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_primary_photo(photo_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  perform private.set_primary_photo(auth.uid(), photo_id);
end $$;


--
-- Name: signaler_presence(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.signaler_presence() RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return private.signaler_presence(auth.uid());
end $$;


--
-- Name: submit_answer(text, smallint[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.submit_answer(k text, idx smallint[]) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  perform private.submit_answer(auth.uid(), k, idx);
end $$;


--
-- Name: trg_bloque_si_rejete(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trg_bloque_si_rejete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  if (select status from partners where id = new.partner_id) = 'rejete' then
    raise exception 'Dossier rejeté : aucune étape supplémentaire ne peut être franchie'
      using errcode = 'check_violation';
  end if;
  return new;
end $$;


--
-- Name: trg_check_sensitive_consent(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trg_check_sensitive_consent() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare cat sensitive_category;
begin
  select sensitive_category into cat from criteria where key = new.criterion_key;
  if cat is not null and not has_consent(new.user_id, cat) then
    raise exception 'Consentement manquant pour la catégorie % (critère %). RGPD art. 9.',
      cat, new.criterion_key using errcode = 'check_violation';
  end if;
  return new;
end $$;


--
-- Name: trg_consent_withdrawn(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trg_consent_withdrawn() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if new.withdrawn_at is not null and old.withdrawn_at is null then
    delete from profile_answers where user_id = new.user_id
      and criterion_key in (select key from criteria where sensitive_category = new.category);
  end if;
  return new;
end $$;


--
-- Name: trg_learning_conversation(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trg_learning_conversation() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
declare v_autre uuid;
begin
  if new.decision = 'plus_tard' then return null; end if;
  select case when c.user_a = new.user_id then c.user_b else c.user_a end
    into v_autre from conversations c where c.id = new.conversation_id;
  perform private.apply_learning(new.user_id, v_autre, new.decision = 'oui',
                                 private.engine_param('coef_conversation'));
  return null;
end $$;


--
-- Name: trg_learning_date_review(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trg_learning_date_review() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
declare v_autre uuid; v_coef numeric := private.engine_param('coef_feedback_date');
begin
  select case when d.user_a = new.user_id then d.user_b else d.user_a end
    into v_autre from dates d where d.id = new.date_id;
  if v_autre is null then return null; end if;

  if new.attirance is not null and new.attirance <> 3 then
    perform private.apply_learning(new.user_id, v_autre, new.attirance >= 4, v_coef, array['physique']::score_group[]);
  end if;
  if new.valeurs is not null and new.valeurs <> 3 then
    perform private.apply_learning(new.user_id, v_autre, new.valeurs >= 4, v_coef, array['valeurs']::score_group[]);
  end if;
  if new.mode_vie is not null and new.mode_vie <> 3 then
    perform private.apply_learning(new.user_id, v_autre, new.mode_vie >= 4, v_coef, array['mode_vie']::score_group[]);
  end if;
  return null;
end $$;


--
-- Name: trg_learning_swipe(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trg_learning_swipe() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
declare v_coef numeric;
begin
  v_coef := case when new.signal_fort and not new.decision
                 then private.engine_param('coef_rejet_fort')
                 else 1 end;
  perform private.apply_learning(new.user_id, new.target_id, new.decision, v_coef);
  return null;
end $$;


--
-- Name: trg_menu_label(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trg_menu_label() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare c text;
begin
  c := menu_label_conflit(new.partner_id, new.label);
  if c is not null then
    raise exception 'L''intitulé « % » contient le nom de l''établissement (« % »).', new.label, c
      using errcode = 'check_violation';
  end if;
  return new;
end $$;


--
-- Name: trg_option_mappings_mask(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trg_option_mappings_mask() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ begin
     new.accepted_mask := om_accepted_mask(new.accepted_self_idx);
     return new;
   end $$;


--
-- Name: trg_refresh_vectors(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trg_refresh_vectors() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
declare u uuid := coalesce(new.user_id, old.user_id);
begin
  -- La suppression d'un profil fait disparaître ses réponses en cascade, ce
  -- qui déclenche ce trigger. Sans ce garde-fou, il tentait de réécrire un
  -- vecteur pour une personne qui n'existe plus et faisait échouer toute
  -- suppression de compte par la table profiles.
  if not exists (select 1 from profiles where id = u) then
    return null;
  end if;
  perform private.refresh_profile_vectors(u);
  return null;
end $$;


--
-- Name: trg_surprise_cooldown(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trg_surprise_cooldown() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
declare v_fin timestamptz;
begin
  if new.response is null or new.response = old.response then
    return null;
  end if;

  if new.response = 'accepte' then
    delete from surprise_cooldowns
     where from_user = new.from_user and to_user = new.to_user;
    return null;
  end if;

  v_fin := case new.response
             when 'indispo_jour'    then date_trunc('day',  now()) + interval '1 day'
             when 'indispo_semaine' then date_trunc('week', now()) + interval '1 week'
             when 'refus'           then now() + interval '30 days'
           end;

  -- Le blocage ne vise que l'emetteur : celui qui a decline garde la
  -- possibilite de reprendre l'initiative a tout moment.
  insert into surprise_cooldowns (from_user, to_user, blocked_until, reason)
  values (new.from_user, new.to_user, v_fin, new.response)
  on conflict (from_user, to_user) do update
    set blocked_until = greatest(surprise_cooldowns.blocked_until, excluded.blocked_until),
        reason        = excluded.reason;
  return null;
end $$;


--
-- Name: trg_zone_utile(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trg_zone_utile() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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


--
-- Name: user_activation_checklist(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.user_activation_checklist() RETURNS TABLE(rang smallint, condition text, satisfaite boolean)
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  return query select * from private.user_activation_checklist(auth.uid());
end $$;


--
-- Name: user_progress(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.user_progress() RETURNS TABLE(etape_courante smallint, etapes_total smallint, secondes_restantes integer, compte_actif boolean)
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  return query select * from private.user_progress(auth.uid());
end $$;


--
-- Name: verify_account_code(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.verify_account_code(code text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  return private.verify_account_code(auth.uid(), code);
end $$;


--
-- Name: verify_postal_code(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.verify_postal_code(code text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
declare p uuid;
begin
  select id into p from partners where owner_id = auth.uid() limit 1;
  if p is null then
    raise exception 'Aucun établissement rattaché à ce compte' using errcode='insufficient_privilege';
  end if;
  return private.verify_postal_code(p, code);
end $$;


--
-- Name: visible_priorities(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.visible_priorities() RETURNS TABLE(rang smallint, pair_key text, phrase text, verrouille boolean)
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  return query select * from private.visible_priorities(auth.uid());
end $$;


--
-- Name: criteria; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.criteria (
    key text NOT NULL,
    ord smallint NOT NULL,
    moment public.collection_moment NOT NULL,
    category text NOT NULL,
    subcategory text NOT NULL,
    cluster text,
    direction public.criterion_direction NOT NULL,
    pair_key text NOT NULL,
    question text NOT NULL,
    multi_select boolean DEFAULT false NOT NULL,
    sensitive_category public.sensitive_category
);


--
-- Name: profile_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profile_answers (
    user_id uuid NOT NULL,
    criterion_key text NOT NULL,
    option_idx smallint[] NOT NULL,
    answered_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: criterion_stats; Type: MATERIALIZED VIEW; Schema: private; Owner: -
--

CREATE MATERIALIZED VIEW private.criterion_stats AS
 WITH rep AS (
         SELECT a.criterion_key,
            a.option_idx[1] AS idx,
            (count(*))::numeric AS n
           FROM public.profile_answers a
          GROUP BY a.criterion_key, a.option_idx[1]
        ), tot AS (
         SELECT rep.criterion_key,
            sum(rep.n) AS total,
            count(*) AS modalites
           FROM rep
          GROUP BY rep.criterion_key
        )
 SELECT c.key AS criterion_key,
    (COALESCE(t.total, (0)::numeric))::integer AS reponses,
        CASE
            WHEN ((t.total IS NULL) OR (t.total < (30)::numeric)) THEN 1.00
            WHEN (t.modalites <= 1) THEN 0.00
            ELSE round((LEAST((1.0)::double precision, GREATEST((0.0)::double precision, (((- sum(((r.n / t.total) * ln((r.n / t.total))))))::double precision / ln((t.modalites)::double precision)))))::numeric, 3)
        END AS entropie
   FROM ((public.criteria c
     LEFT JOIN tot t ON ((t.criterion_key = c.key)))
     LEFT JOIN rep r ON ((r.criterion_key = c.key)))
  GROUP BY c.key, t.total, t.modalites
  WITH NO DATA;


--
-- Name: phrase_patterns; Type: TABLE; Schema: private; Owner: -
--

CREATE TABLE private.phrase_patterns (
    criterion_key text NOT NULL,
    mode text NOT NULL,
    pattern text NOT NULL,
    locale text DEFAULT 'fr'::text NOT NULL,
    CONSTRAINT phrase_patterns_mode_check CHECK ((mode = ANY (ARRAY['sub'::text, 'idx'::text])))
);


--
-- Name: TABLE phrase_patterns; Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON TABLE private.phrase_patterns IS 'Gabarits de reformulation, un par critere. Source de generation de criterion_option_phrasings : on edite ici, jamais les 918 phrases une par une.';


--
-- Name: user_criterion_learning; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_criterion_learning (
    user_id uuid NOT NULL,
    pair_key text NOT NULL,
    confirmations numeric DEFAULT 0 NOT NULL,
    contradictions numeric DEFAULT 0 NOT NULL,
    learned_mul numeric DEFAULT 1.0 NOT NULL,
    observations integer DEFAULT 0 NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE user_criterion_learning; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.user_criterion_learning IS 'Poids appris par utilisateur et par critere. Un critere systematiquement contredit par les decisions reelles est progressivement declasse, sans jamais etre annule.';


--
-- Name: COLUMN user_criterion_learning.learned_mul; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_criterion_learning.learned_mul IS 'Multiplicateur applique au poids du critere, borne entre apprentissage_mul_min et apprentissage_mul_max.';


--
-- Name: v_apprentissage_derive; Type: VIEW; Schema: private; Owner: -
--

CREATE VIEW private.v_apprentissage_derive AS
 SELECT user_id,
    count(*) AS criteres_appris,
    count(*) FILTER (WHERE (learned_mul <= private.engine_param('apprentissage_mul_min'::text))) AS au_plancher,
    round(((count(*) FILTER (WHERE (learned_mul <= private.engine_param('apprentissage_mul_min'::text))))::numeric / (NULLIF(count(*), 0))::numeric), 3) AS part_plancher,
    round(private.learning_reliability(user_id), 3) AS fiabilite,
    max(observations) AS observations
   FROM public.user_criterion_learning l
  GROUP BY user_id
 HAVING (((count(*) FILTER (WHERE (learned_mul <= private.engine_param('apprentissage_mul_min'::text))))::numeric / (NULLIF(count(*), 0))::numeric) >= private.engine_param('apprentissage_derive_alerte'::text));


--
-- Name: VIEW v_apprentissage_derive; Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON VIEW private.v_apprentissage_derive IS 'Profils dont une part anormale de criteres est tombee au plancher. Signale un comportement indifferencie plutot qu''une preference reelle : a inspecter avant d''accorder du credit a leur profil appris.';


--
-- Name: dates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dates (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_a uuid NOT NULL,
    user_b uuid NOT NULL,
    partner_id uuid NOT NULL,
    creneau_debut timestamp with time zone NOT NULL,
    status public.date_status DEFAULT 'en_preparation'::public.date_status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    conversation_id uuid,
    mode_rdv_active_at timestamp with time zone,
    ended_at timestamp with time zone,
    closed_at timestamp with time zone,
    ended_by uuid,
    table_number text,
    CONSTRAINT dates_check CHECK ((user_a <> user_b))
);


--
-- Name: COLUMN dates.mode_rdv_active_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.dates.mode_rdv_active_at IS 'Horodatage d''activation du Mode Rendez-vous, declenche quand la presence des deux utilisateurs dans l''etablissement est confirmee.';


--
-- Name: COLUMN dates.ended_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.dates.ended_at IS 'Moment ou "Terminer le rendez-vous" a ete confirme. Reversible tant que closed_at est nul.';


--
-- Name: COLUMN dates.closed_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.dates.closed_at IS 'Cloture definitive : les deux utilisateurs ont quitte l''etablissement et toutes les consommations sont reglees.';


--
-- Name: help_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.help_requests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    date_id uuid NOT NULL,
    user_id uuid NOT NULL,
    level public.help_level NOT NULL,
    fake_contact_id uuid,
    partner_notified_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    resolved_at timestamp with time zone,
    analyse_terminee_at timestamp with time zone,
    mesure_prise text
);


--
-- Name: TABLE help_requests; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.help_requests IS 'L''utilisation du bouton Help est strictement confidentielle : l''autre utilisateur n''en est jamais informe. La nature exacte de la demande n''est pas transmise a l''etablissement.';


--
-- Name: help_staff_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.help_staff_reports (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    help_request_id uuid NOT NULL,
    partner_id uuid NOT NULL,
    staff_identifiant text,
    table_number text,
    circonstances text,
    faits text,
    actions text,
    depart_accompagne boolean,
    secours_appeles boolean,
    observations text,
    dangerosite smallint NOT NULL,
    submitted_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT help_staff_reports_dangerosite_check CHECK (((dangerosite >= 1) AND (dangerosite <= 5)))
);


--
-- Name: TABLE help_staff_reports; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.help_staff_reports IS 'Rapport d''intervention obligatoire au titre du contrat de partenariat. Le personnel relate des faits objectifs, sans jugement sur les utilisateurs.';


--
-- Name: COLUMN help_staff_reports.dangerosite; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.help_staff_reports.dangerosite IS '1 aucune situation preoccupante · 2 legerement inhabituelle · 3 vigilance particuliere · 4 preoccupant, intervention importante · 5 risque manifeste. Strictement confidentiel, jamais communique aux utilisateurs.';


--
-- Name: moderation_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.moderation_actions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    report_id uuid,
    action public.moderation_action NOT NULL,
    motif text,
    decided_by uuid,
    decided_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone,
    leve_at timestamp with time zone
);


--
-- Name: TABLE moderation_actions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.moderation_actions IS 'Historique des mesures prises. Conserve meme apres expiration : c''est lui qui permet de detecter les comportements repetes et de graduer la sanction suivante.';


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profiles (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    birth_date date NOT NULL,
    age_min smallint DEFAULT 18 NOT NULL,
    age_max smallint DEFAULT 99 NOT NULL,
    search_radius_km smallint DEFAULT 25 NOT NULL,
    last_location public.geography(Point,4326),
    is_verified boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    langue text,
    pays character(2),
    geoloc_precise boolean,
    systeme_unites public.unit_system DEFAULT 'metrique'::public.unit_system NOT NULL,
    is_premium boolean DEFAULT false NOT NULL,
    prenom text,
    always_available boolean DEFAULT false NOT NULL,
    notify_when_offline boolean DEFAULT false NOT NULL,
    intentions public.rencontre_type[] DEFAULT ARRAY['amour'::public.rencontre_type] NOT NULL,
    last_seen_at timestamp with time zone,
    CONSTRAINT profiles_age_min_check CHECK ((age_min >= 18)),
    CONSTRAINT profiles_intentions_non_vide CHECK (((cardinality(intentions) >= 1) AND (cardinality(intentions) <= 3))),
    CONSTRAINT profiles_majeur CHECK ((birth_date <= (CURRENT_DATE - '18 years'::interval)))
);


--
-- Name: COLUMN profiles.always_available; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.profiles.always_available IS 'Option SAFE Premium : disponibilite consideree comme permanente (24h/24).';


--
-- Name: COLUMN profiles.notify_when_offline; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.profiles.notify_when_offline IS 'Option SAFE Premium : notifier les demandes de discussion meme hors application.';


--
-- Name: COLUMN profiles.intentions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.profiles.intentions IS 'Types de rencontre acceptes par l''utilisateur. Une demande d''un type non accepte est rejetee a l''envoi, sans revelation du motif exact a l''emetteur.';


--
-- Name: COLUMN profiles.last_seen_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.profiles.last_seen_at IS 'Dernier signe de vie. Sert a determiner la presence effective, distincte de l''acceptation.';


--
-- Name: reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reports (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    reporter_id uuid,
    reported_id uuid,
    reason public.report_reason NOT NULL,
    details text,
    status public.report_status DEFAULT 'nouveau'::public.report_status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    handled_at timestamp with time zone,
    handled_by uuid,
    outcome text
);


--
-- Name: v_file_moderation; Type: VIEW; Schema: private; Owner: -
--

CREATE VIEW private.v_file_moderation AS
 SELECT r.id AS report_id,
    r.created_at,
    r.reason,
    r.details,
    r.reported_id,
    p.prenom,
    ( SELECT count(*) AS count
           FROM public.reports r2
          WHERE ((r2.reported_id = r.reported_id) AND (r2.status = ANY (ARRAY['nouveau'::public.report_status, 'en_cours'::public.report_status])))) AS signalements_ouverts,
    ( SELECT count(*) AS count
           FROM public.moderation_actions m
          WHERE ((m.user_id = r.reported_id) AND (m.action <> 'classe_sans_suite'::public.moderation_action))) AS mesures_anterieures,
    ( SELECT max(s.dangerosite) AS max
           FROM ((public.help_staff_reports s
             JOIN public.help_requests h ON ((h.id = s.help_request_id)))
             JOIN public.dates d ON ((d.id = h.date_id)))
          WHERE (((d.user_a = r.reported_id) OR (d.user_b = r.reported_id)) AND (h.user_id <> r.reported_id))) AS dangerosite_max,
    private.escalade_recommandee(r.reported_id, r.reason) AS mesure_recommandee
   FROM (public.reports r
     JOIN public.profiles p ON ((p.id = r.reported_id)))
  WHERE (r.status = ANY (ARRAY['nouveau'::public.report_status, 'en_cours'::public.report_status]))
  ORDER BY
        CASE
            WHEN (r.reason = ANY (ARRAY['mineur'::public.report_reason, 'violence'::public.report_reason])) THEN 0
            ELSE 1
        END, r.created_at;


--
-- Name: VIEW v_file_moderation; Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON VIEW private.v_file_moderation IS 'File de traitement priorisee. Les motifs de minorite et de violence remontent en tete, avant l''anciennete. Chaque ligne porte l''historique de l''utilisateur et la mesure recommandee.';


--
-- Name: v_fonctions_definisseur_exposees; Type: VIEW; Schema: private; Owner: -
--

CREATE VIEW private.v_fonctions_definisseur_exposees AS
 SELECT p.proname AS fonction,
    pg_get_function_identity_arguments(p.oid) AS arguments,
        CASE
            WHEN p.prosecdef THEN 'CRITIQUE — droits définisseur'::text
            ELSE 'À VÉRIFIER — droits appelant'::text
        END AS gravite
   FROM (pg_proc p
     JOIN pg_namespace ns ON ((ns.oid = p.pronamespace)))
  WHERE ((ns.nspname = 'public'::name) AND (p.prorettype <> ('trigger'::regtype)::oid) AND (('uuid'::regtype)::oid = ANY ((p.proargtypes)::oid[])) AND (pg_get_function_identity_arguments(p.oid) !~ '^(p_id |p )?uuid$'::text) AND (p.proname <> ALL (ARRAY['check_partner_eligibility'::name, 'partner_activation_checklist'::name, 'activate_partner'::name, 'partner_progress'::name, 'diagnostic_zones'::name, 'menu_label_conflit'::name, 'are_blocked'::name, 'has_consent'::name, 'set_primary_photo'::name, 'reveal_establishment'::name, 'compat_score'::name, 'creer_demande'::name, 'repondre_demande'::name, 'envoyer_message'::name, 'reproposer_date_surprise'::name])))
  ORDER BY p.proname;


--
-- Name: criterion_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.criterion_options (
    criterion_key text NOT NULL,
    idx smallint NOT NULL,
    label text NOT NULL,
    is_neutral boolean DEFAULT false NOT NULL,
    value_min numeric,
    value_max numeric,
    unit text,
    CONSTRAINT criterion_options_idx_check CHECK (((idx >= 0) AND (idx <= 14)))
);


--
-- Name: v_gabarits_incoherents; Type: VIEW; Schema: private; Owner: -
--

CREATE VIEW private.v_gabarits_incoherents AS
 SELECT t.criterion_key,
    t.mode,
    array_length(string_to_array(t.pattern, '||'::text), 1) AS segments,
    count(o.idx) AS options
   FROM (private.phrase_patterns t
     JOIN public.criterion_options o ON ((o.criterion_key = t.criterion_key)))
  WHERE (t.mode = 'idx'::text)
  GROUP BY t.criterion_key, t.mode, t.pattern
 HAVING (array_length(string_to_array(t.pattern, '||'::text), 1) <> count(o.idx));


--
-- Name: criterion_pairs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.criterion_pairs (
    pair_key text NOT NULL,
    slot smallint NOT NULL,
    self_key text NOT NULL,
    pref_key text NOT NULL,
    category text NOT NULL,
    cluster text,
    grp public.score_group NOT NULL,
    match_type public.match_type NOT NULL,
    is_absolute boolean DEFAULT false NOT NULL,
    base_weight numeric(4,2) DEFAULT 1.00 NOT NULL,
    mapping_validated boolean DEFAULT false NOT NULL,
    filtre_cadrage boolean DEFAULT false NOT NULL,
    affichable_apprentissage boolean DEFAULT true NOT NULL,
    CONSTRAINT criterion_pairs_slot_check CHECK (((slot >= 0) AND (slot <= 132)))
);


--
-- Name: COLUMN criterion_pairs.filtre_cadrage; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.criterion_pairs.filtre_cadrage IS 'Parmi les criteres absolus, distingue le cadrage du dealbreaker. Le cadrage retire le profil du fil : personne ne veut faire defiler des profils du genre qu''il ne cherche pas. Le dealbreaker laisse le profil visible mais desactive la proposition de conversation. Reversible sans migration : il suffit de basculer ce booleen.';


--
-- Name: COLUMN criterion_pairs.affichable_apprentissage; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.criterion_pairs.affichable_apprentissage IS 'Faux pour les criteres exclus de l''onglet d''apprentissage : taille, poids, profession, religion, niveau d''etudes, opinions politiques. Ils restent exploitables par le moteur pour formuler des questions, et redeviennent visibles dans Partir en date, ou les profils sont presentes en entier.';


--
-- Name: option_mappings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.option_mappings (
    pair_key text NOT NULL,
    pref_idx smallint NOT NULL,
    accepted_self_idx smallint[] DEFAULT '{}'::smallint[] NOT NULL,
    weight_multiplier numeric(3,2) DEFAULT 1.00 NOT NULL,
    tolerance smallint,
    relative_op public.relative_op,
    relative_criterion_key text,
    accepted_mask integer DEFAULT 0 NOT NULL,
    CONSTRAINT option_mappings_cible_definie CHECK (((relative_op IS NOT NULL) OR (accepted_self_idx IS NOT NULL))),
    CONSTRAINT option_mappings_weight_multiplier_check CHECK ((weight_multiplier >= (0)::numeric))
);


--
-- Name: COLUMN option_mappings.relative_op; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.option_mappings.relative_op IS 'Si non nul, la correspondance est evaluee en comparant l''index self de la cible a celui du demandeur, au lieu d''utiliser accepted_self_idx. Suppose des options ordinales.';


--
-- Name: COLUMN option_mappings.relative_criterion_key; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.option_mappings.relative_criterion_key IS 'Critere sur lequel porte la comparaison relative. Nul = le self_key de la paire elle-meme.';


--
-- Name: v_mappings_invalides; Type: VIEW; Schema: private; Owner: -
--

CREATE VIEW private.v_mappings_invalides AS
 SELECT m.pair_key,
    m.pref_idx,
    acc.acc AS idx_inexistant
   FROM ((public.option_mappings m
     JOIN public.criterion_pairs p ON ((p.pair_key = m.pair_key)))
     CROSS JOIN LATERAL unnest(m.accepted_self_idx) acc(acc))
  WHERE (NOT (EXISTS ( SELECT 1
           FROM public.criterion_options o
          WHERE ((o.criterion_key = p.self_key) AND (o.idx = acc.acc)))));


--
-- Name: v_mappings_manquants; Type: VIEW; Schema: private; Owner: -
--

CREATE VIEW private.v_mappings_manquants AS
 SELECT p.pair_key,
    p.match_type,
    c.question,
    o.idx AS pref_idx,
    o.label AS pref_label
   FROM (((public.criterion_pairs p
     JOIN public.criteria c ON ((c.key = p.pref_key)))
     JOIN public.criterion_options o ON ((o.criterion_key = p.pref_key)))
     LEFT JOIN public.option_mappings m ON (((m.pair_key = p.pair_key) AND (m.pref_idx = o.idx))))
  WHERE (m.pair_key IS NULL)
  ORDER BY p.slot, o.idx;


--
-- Name: v_paires_non_validees; Type: VIEW; Schema: private; Owner: -
--

CREATE VIEW private.v_paires_non_validees AS
 SELECT p.pair_key,
    p.match_type,
    p.category,
    c.question AS question_recherchee,
    ( SELECT count(*) AS count
           FROM public.option_mappings m
          WHERE (m.pair_key = p.pair_key)) AS propositions
   FROM (public.criterion_pairs p
     JOIN public.criteria c ON ((c.key = p.pref_key)))
  WHERE (NOT p.mapping_validated)
  ORDER BY p.slot;


--
-- Name: criterion_option_phrasings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.criterion_option_phrasings (
    criterion_key text NOT NULL,
    idx smallint NOT NULL,
    locale text DEFAULT 'fr'::text NOT NULL,
    phrase text NOT NULL
);


--
-- Name: v_phrasings_manquants; Type: VIEW; Schema: private; Owner: -
--

CREATE VIEW private.v_phrasings_manquants AS
 SELECT c.ord,
    c.key AS criterion_key,
    c.direction,
    c.category,
    c.question,
    o.idx,
    o.label
   FROM ((public.criteria c
     JOIN public.criterion_options o ON ((o.criterion_key = c.key)))
     LEFT JOIN public.criterion_option_phrasings p ON (((p.criterion_key = o.criterion_key) AND (p.idx = o.idx) AND (p.locale = 'fr'::text))))
  WHERE (p.criterion_key IS NULL)
  ORDER BY c.ord, o.idx;


--
-- Name: v_tables_sans_rls; Type: VIEW; Schema: private; Owner: -
--

CREATE VIEW private.v_tables_sans_rls AS
 SELECT tablename
   FROM pg_tables t
  WHERE ((schemaname = 'public'::name) AND (NOT rowsecurity) AND (NOT (EXISTS ( SELECT 1
           FROM ((pg_class c
             JOIN pg_namespace ns ON ((ns.oid = c.relnamespace)))
             JOIN pg_depend d ON (((d.classid = ('pg_class'::regclass)::oid) AND (d.objid = c.oid) AND (d.deptype = 'e'::"char"))))
          WHERE ((ns.nspname = t.schemaname) AND (c.relname = t.tablename))))))
  ORDER BY tablename;


--
-- Name: v_utilisateurs_signales_multi; Type: VIEW; Schema: private; Owner: -
--

CREATE VIEW private.v_utilisateurs_signales_multi AS
 SELECT d.user_a AS user_id,
    count(*) AS interventions,
    max(r.dangerosite) AS dangerosite_max,
    count(DISTINCT r.partner_id) AS etablissements
   FROM ((public.help_staff_reports r
     JOIN public.help_requests h ON ((h.id = r.help_request_id)))
     JOIN public.dates d ON ((d.id = h.date_id)))
  WHERE (d.user_a <> h.user_id)
  GROUP BY d.user_a
 HAVING (count(DISTINCT r.partner_id) > 1)
UNION ALL
 SELECT d.user_b AS user_id,
    count(*) AS interventions,
    max(r.dangerosite) AS dangerosite_max,
    count(DISTINCT r.partner_id) AS etablissements
   FROM ((public.help_staff_reports r
     JOIN public.help_requests h ON ((h.id = r.help_request_id)))
     JOIN public.dates d ON ((d.id = h.date_id)))
  WHERE (d.user_b <> h.user_id)
  GROUP BY d.user_b
 HAVING (count(DISTINCT r.partner_id) > 1);


--
-- Name: VIEW v_utilisateurs_signales_multi; Type: COMMENT; Schema: private; Owner: -
--

COMMENT ON VIEW private.v_utilisateurs_signales_multi IS 'Utilisateurs concernes par des interventions dans plusieurs etablissements distincts. Declenche une analyse renforcee du compte.';


--
-- Name: availability_windows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.availability_windows (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    debut timestamp with time zone NOT NULL,
    fin timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT availability_ordre CHECK ((fin > debut))
);


--
-- Name: TABLE availability_windows; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.availability_windows IS 'Creneaux pendant lesquels l''utilisateur se declare disponible pour partir en date.';


--
-- Name: blocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.blocks (
    blocker_id uuid NOT NULL,
    blocked_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT blocks_check CHECK ((blocker_id <> blocked_id))
);


--
-- Name: consents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.consents (
    user_id uuid NOT NULL,
    category public.sensitive_category NOT NULL,
    policy_code text NOT NULL,
    policy_version text NOT NULL,
    granted_at timestamp with time zone DEFAULT now() NOT NULL,
    withdrawn_at timestamp with time zone,
    ip_address inet,
    user_agent text
);


--
-- Name: context_weight_defaults; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.context_weight_defaults (
    type_rencontre public.rencontre_type NOT NULL,
    poids_physique numeric(4,3) NOT NULL,
    poids_mode_vie numeric(4,3) NOT NULL,
    poids_valeurs numeric(4,3) NOT NULL,
    seuil_exigence numeric(4,3) NOT NULL,
    CONSTRAINT cwd_somme_unitaire CHECK ((abs((((poids_physique + poids_mode_vie) + poids_valeurs) - (1)::numeric)) < 0.001))
);


--
-- Name: TABLE context_weight_defaults; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.context_weight_defaults IS 'Point de depart, pas verite. Le document les qualifie d''illustratives : elles servent tant que le comportement de l''utilisateur n''a rien appris, puis s''effacent progressivement devant lui.';


--
-- Name: COLUMN context_weight_defaults.seuil_exigence; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.context_weight_defaults.seuil_exigence IS 'Compatibilite minimale pour proposer une rencontre dans ce contexte. Soixante-dix pour cent peuvent suffire en amitie et rester insuffisants en amour : preference et niveau d''exigence sont deux choses distinctes.';


--
-- Name: conversation_decisions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conversation_decisions (
    conversation_id uuid NOT NULL,
    user_id uuid NOT NULL,
    decision public.date_intent NOT NULL,
    decided_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE conversation_decisions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.conversation_decisions IS 'Reponse a "Souhaitez-vous partir en date aujourd''hui ?" a l''issue des 5 minutes.';


--
-- Name: conversations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conversations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    request_id uuid NOT NULL,
    user_a uuid NOT NULL,
    user_b uuid NOT NULL,
    started_at timestamp with time zone,
    ends_at timestamp with time zone,
    locked_at timestamp with time zone,
    status public.conversation_status DEFAULT 'prete'::public.conversation_status NOT NULL,
    illimitee boolean DEFAULT false NOT NULL,
    prete_at timestamp with time zone DEFAULT now() NOT NULL,
    presence_a_at timestamp with time zone,
    presence_b_at timestamp with time zone,
    CONSTRAINT conversations_demarrage_coherent CHECK ((num_nulls(started_at, ends_at) <> 1))
);


--
-- Name: TABLE conversations; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.conversations IS 'Espace d''echange de 5 minutes ouvert lorsqu''une demande de discussion est acceptee. Verrouillage automatique a expiration, simultane pour les deux utilisateurs.';


--
-- Name: COLUMN conversations.started_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.conversations.started_at IS 'Nul tant que les deux personnes n''ont pas ete presentes simultanement. C''est ici, et seulement ici, que les cinq minutes commencent.';


--
-- Name: COLUMN conversations.prete_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.conversations.prete_at IS 'Moment ou les deux ont accepte. La conversation existe des cet instant, mais rien ne s''ecoule encore.';


--
-- Name: date_followups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.date_followups (
    date_id uuid NOT NULL,
    user_id uuid NOT NULL,
    decision public.date_intent NOT NULL,
    decided_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE date_followups; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.date_followups IS 'Souhait de poursuivre la discussion. Le choix de l''autre n''est jamais revele avant que les deux reponses soient enregistrees.';


--
-- Name: date_meeting_points; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.date_meeting_points (
    date_id uuid NOT NULL,
    user_id uuid NOT NULL,
    point public.geography(Point,4326) NOT NULL,
    arrivee_at timestamp with time zone NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    revealed_at timestamp with time zone
);


--
-- Name: date_presence; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.date_presence (
    date_id uuid NOT NULL,
    user_id uuid NOT NULL,
    arrived_at timestamp with time zone,
    confirmed_at timestamp with time zone,
    left_at timestamp with time zone,
    distance_m integer
);


--
-- Name: TABLE date_presence; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.date_presence IS 'Suivi de presence par geolocalisation. distance_m sert notamment au seuil de 350 m qui conditionne l''affichage des evaluations.';


--
-- Name: date_reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.date_reviews (
    date_id uuid NOT NULL,
    user_id uuid NOT NULL,
    attirance smallint,
    valeurs smallint,
    mode_vie smallint,
    commentaire text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT date_reviews_attirance_check CHECK (((attirance >= 1) AND (attirance <= 5))),
    CONSTRAINT date_reviews_mode_vie_check CHECK (((mode_vie >= 1) AND (mode_vie <= 5))),
    CONSTRAINT date_reviews_valeurs_check CHECK (((valeurs >= 1) AND (valeurs <= 5)))
);


--
-- Name: TABLE date_reviews; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.date_reviews IS 'Strictement confidentiel : jamais communique au partenaire, jamais rendu public. Affiche seulement lorsque les deux utilisateurs sont separes d''au moins 350 metres.';


--
-- Name: deletion_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deletion_requests (
    user_id uuid NOT NULL,
    requested_at timestamp with time zone DEFAULT now() NOT NULL,
    execute_after timestamp with time zone DEFAULT (now() + '7 days'::interval) NOT NULL,
    executed_at timestamp with time zone,
    cancelled_at timestamp with time zone
);


--
-- Name: engine_params; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.engine_params (
    key text NOT NULL,
    value numeric NOT NULL,
    description text NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: fake_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fake_contacts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    genre text NOT NULL,
    prenom text NOT NULL,
    photo_path text,
    message_template text NOT NULL,
    active boolean DEFAULT true NOT NULL
);


--
-- Name: TABLE fake_contacts; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.fake_contacts IS 'Contacts fictifs predefinis servant a afficher une fausse conversation permettant a l''utilisateur de justifier naturellement son depart.';


--
-- Name: focus_compatibilite; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.focus_compatibilite (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    context public.focus_context NOT NULL,
    target_user_id uuid,
    target_partner_id uuid,
    question text NOT NULL,
    reponse text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    answered_at timestamp with time zone,
    criterion_key text,
    sens boolean,
    swipe_id bigint,
    options jsonb
);


--
-- Name: TABLE focus_compatibilite; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.focus_compatibilite IS 'Question posee par le moteur lorsqu''une decision utilisateur parait difficile a expliquer. Donnee d''apprentissage a forte valeur.';


--
-- Name: COLUMN focus_compatibilite.sens; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.focus_compatibilite.sens IS 'Sens de la serie ayant declenche la question : vrai apres une serie de oui, faux apres une serie de non.';


--
-- Name: grille_import_v1; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.grille_import_v1 (
    src_row integer NOT NULL,
    pair_key text,
    pref_idx smallint,
    pref_label text,
    accepted smallint[],
    poids numeric,
    commentaire text
);


--
-- Name: TABLE grille_import_v1; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.grille_import_v1 IS 'Grille de correspondance remplie par le client (Thomas GASPOZ), retournee le 29/07/2026. Table de reference/audit : ne pas modifier, sert de trace contractuelle pour la recette du jalon M2. Source : Grille_de_correspondance.xlsx onglet Correspondances.';


--
-- Name: help_user_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.help_user_reports (
    help_request_id uuid NOT NULL,
    user_id uuid NOT NULL,
    raison text,
    recit text,
    comportement text,
    ressenti text,
    complement text,
    submitted_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE help_user_reports; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.help_user_reports IS 'Formulaire confidentiel presente a l''utilisateur une fois qu''il s''est eloigne d''au moins 350 metres de l''etablissement.';


--
-- Name: identity_verifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.identity_verifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    provider text NOT NULL,
    provider_ref text NOT NULL,
    status public.verification_status DEFAULT 'en_attente'::public.verification_status NOT NULL,
    liveness_ok boolean,
    age_estimated smallint,
    checked_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    comparison_ok boolean,
    comparison_score numeric(4,3),
    photo_id uuid
);


--
-- Name: TABLE identity_verifications; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.identity_verifications IS 'Cette table ne contient AUCUNE donnee biometrique : ni image, ni gabarit, ni vecteur facial. Seuls le resultat et la reference opaque du prestataire sont conserves.';


--
-- Name: invoice_lines; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invoice_lines (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    invoice_id uuid NOT NULL,
    label text NOT NULL,
    quantity smallint DEFAULT 1 NOT NULL,
    unit_price_cents integer NOT NULL,
    vat_rate numeric(5,2),
    total_cents integer NOT NULL
);


--
-- Name: invoice_number_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invoice_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invoices (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    date_id uuid NOT NULL,
    payment_id uuid,
    partner_id uuid NOT NULL,
    user_id uuid,
    number text NOT NULL,
    type public.invoice_type DEFAULT 'detaillee'::public.invoice_type NOT NULL,
    issued_at timestamp with time zone DEFAULT now() NOT NULL,
    paid_at timestamp with time zone,
    covers smallint,
    subtotal_ht_cents integer,
    vat_cents integer,
    total_ttc_cents integer NOT NULL,
    tip_cents integer DEFAULT 0 NOT NULL,
    billing_info jsonb,
    pdf_path text
);


--
-- Name: COLUMN invoices.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.invoices.type IS 'La facture simplifiee n''indique que le nombre de couverts et le montant global, sans detailler les produits.';


--
-- Name: COLUMN invoices.billing_info; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.invoices.billing_info IS 'Raison sociale, adresse, numero de TVA, centre de couts : informations de facturation renseignees par l''utilisateur.';


--
-- Name: menu_stopwords; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.menu_stopwords (
    mot text NOT NULL
);


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    conversation_id uuid NOT NULL,
    sender_id uuid NOT NULL,
    kind public.message_kind DEFAULT 'texte'::public.message_kind NOT NULL,
    body text,
    audio_path text,
    duration_ms integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT message_contenu CHECK ((((kind = 'texte'::public.message_kind) AND (body IS NOT NULL)) OR ((kind = 'vocal'::public.message_kind) AND (audio_path IS NOT NULL)) OR ((kind = 'photo'::public.message_kind) AND (audio_path IS NOT NULL))))
);


--
-- Name: TABLE messages; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.messages IS 'Seuls le texte et le message vocal sont autorises pendant la conversation : ni photo, ni fichier, ni lien, ni coordonnees.';


--
-- Name: COLUMN messages.audio_path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.messages.audio_path IS 'Chemin de stockage du media : enregistrement vocal ou photographie selon le type de message.';


--
-- Name: order_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_id uuid NOT NULL,
    menu_item_id uuid,
    label_snapshot text NOT NULL,
    unit_price_cents integer NOT NULL,
    quantity smallint DEFAULT 1 NOT NULL,
    options jsonb DEFAULT '{}'::jsonb NOT NULL,
    line_total_cents integer GENERATED ALWAYS AS ((unit_price_cents * quantity)) STORED,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT order_items_quantity_check CHECK ((quantity > 0)),
    CONSTRAINT order_items_unit_price_cents_check CHECK ((unit_price_cents >= 0))
);


--
-- Name: COLUMN order_items.label_snapshot; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.order_items.label_snapshot IS 'Libelle fige au moment de la commande : le menu du partenaire peut evoluer, la facture ne doit pas.';


--
-- Name: COLUMN order_items.options; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.order_items.options IS 'Personnalisations proposees par l''etablissement : cuisson, accompagnement, supplement, sauce.';


--
-- Name: order_payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_payments (
    payment_id uuid NOT NULL,
    order_id uuid NOT NULL
);


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orders (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    date_id uuid NOT NULL,
    user_id uuid NOT NULL,
    partner_id uuid NOT NULL,
    status public.order_status DEFAULT 'brouillon'::public.order_status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    sent_at timestamp with time zone,
    served_at timestamp with time zone
);


--
-- Name: TABLE orders; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.orders IS 'Chaque utilisateur commande librement et independamment de son partenaire. Les commandes restent separees jusqu''au paiement final.';


--
-- Name: outstanding_debts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outstanding_debts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    date_id uuid NOT NULL,
    partner_id uuid NOT NULL,
    amount_cents integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    settled_at timestamp with time zone,
    settlement_payment_id uuid,
    relances smallint DEFAULT 0 NOT NULL,
    CONSTRAINT outstanding_debts_amount_cents_check CHECK ((amount_cents > 0))
);


--
-- Name: TABLE outstanding_debts; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.outstanding_debts IS 'Consommation restee impayee. Tant qu''une dette est ouverte, un ecran de regularisation bloque l''acces a l''application. La regularisation doit se faire par paiement numerique.';


--
-- Name: partner_acceptances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.partner_acceptances (
    partner_id uuid NOT NULL,
    policy_code text NOT NULL,
    policy_version text NOT NULL,
    accepted_at timestamp with time zone DEFAULT now() NOT NULL,
    ip_address inet
);


--
-- Name: partner_contracts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.partner_contracts (
    partner_id uuid NOT NULL,
    provider text NOT NULL,
    provider_ref text NOT NULL,
    document_sha256 text NOT NULL,
    status public.verification_status DEFAULT 'en_attente'::public.verification_status NOT NULL,
    signed_at timestamp with time zone
);


--
-- Name: partner_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.partner_documents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    partner_id uuid NOT NULL,
    doc_type text NOT NULL,
    storage_path text NOT NULL,
    status public.verification_status DEFAULT 'en_attente'::public.verification_status NOT NULL,
    checked_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: partner_menu_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.partner_menu_categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    partner_id uuid NOT NULL,
    label text NOT NULL,
    "position" smallint DEFAULT 0 NOT NULL
);


--
-- Name: partner_menu_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.partner_menu_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    partner_id uuid NOT NULL,
    category_id uuid,
    label text NOT NULL,
    description text,
    price_cents integer NOT NULL,
    currency character(3) DEFAULT 'EUR'::bpchar NOT NULL,
    is_available boolean DEFAULT true NOT NULL,
    "position" smallint DEFAULT 0 NOT NULL,
    CONSTRAINT partner_menu_items_price_cents_check CHECK ((price_cents >= 0))
);


--
-- Name: partner_payout_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.partner_payout_accounts (
    partner_id uuid NOT NULL,
    stripe_account_id text NOT NULL,
    charges_enabled boolean DEFAULT false NOT NULL,
    payouts_enabled boolean DEFAULT false NOT NULL,
    requirements_due text[] DEFAULT '{}'::text[] NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: partner_photos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.partner_photos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    partner_id uuid NOT NULL,
    source public.photo_source NOT NULL,
    google_photo_reference text,
    storage_path text,
    "position" smallint DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT partner_photos_check CHECK ((((source = 'google_reference'::public.photo_source) AND (google_photo_reference IS NOT NULL) AND (storage_path IS NULL)) OR ((source = 'import_partenaire'::public.photo_source) AND (storage_path IS NOT NULL) AND (google_photo_reference IS NULL))))
);


--
-- Name: partner_postal_verifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.partner_postal_verifications (
    partner_id uuid NOT NULL,
    code_sha256 text NOT NULL,
    sent_at timestamp with time zone DEFAULT now() NOT NULL,
    verified_at timestamp with time zone,
    attempts smallint DEFAULT 0 NOT NULL
);


--
-- Name: partner_safe_zones; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.partner_safe_zones (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    partner_id uuid NOT NULL,
    label text NOT NULL,
    zone public.geography(Polygon,4326) NOT NULL,
    validated boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: partner_settlements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.partner_settlements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    payment_id uuid,
    partner_id uuid NOT NULL,
    gross_cents integer NOT NULL,
    commission_cents integer DEFAULT 0 NOT NULL,
    net_cents integer NOT NULL,
    stripe_transfer_id text,
    transferred_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    tip_cents integer DEFAULT 0 NOT NULL,
    commission_reportee_cents integer DEFAULT 0 NOT NULL,
    garantie boolean DEFAULT false NOT NULL
);


--
-- Name: TABLE partner_settlements; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.partner_settlements IS 'Repartition automatique de chaque encaissement entre la part etablissement et la commission Safe Date. Les pourboires ne supportent aucune commission.';


--
-- Name: COLUMN partner_settlements.commission_reportee_cents; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.partner_settlements.commission_reportee_cents IS 'Commission non prelevable lors d''un reglement en especes. Sera recuperee sur un paiement numerique ulterieur dans le meme etablissement.';


--
-- Name: COLUMN partner_settlements.garantie; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.partner_settlements.garantie IS 'Reversement effectue par Safe Date en garantie d''une consommation impayee. L''etablissement est regle, Safe Date se retourne ensuite vers l''utilisateur.';


--
-- Name: partner_step_completions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.partner_step_completions (
    partner_id uuid NOT NULL,
    step smallint NOT NULL,
    completed_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: partner_steps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.partner_steps (
    step smallint NOT NULL,
    code text NOT NULL,
    label text NOT NULL,
    est_minutes smallint DEFAULT 1 NOT NULL,
    bloquante boolean DEFAULT true NOT NULL,
    CONSTRAINT partner_steps_step_check CHECK (((step >= 1) AND (step <= 99)))
);


--
-- Name: partner_training_completions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.partner_training_completions (
    partner_id uuid NOT NULL,
    module_code text NOT NULL,
    quiz_score smallint NOT NULL,
    passed boolean GENERATED ALWAYS AS ((quiz_score >= 80)) STORED,
    completed_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT partner_training_completions_quiz_score_check CHECK (((quiz_score >= 0) AND (quiz_score <= 100)))
);


--
-- Name: partners; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.partners (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    owner_id uuid NOT NULL,
    langue text NOT NULL,
    pays character(2) NOT NULL,
    nom_commercial text,
    raison_sociale text,
    adresse text,
    code_postal text,
    ville text,
    telephone text,
    email text,
    site_web text,
    google_place_id text,
    google_maps_url text,
    google_note numeric(2,1),
    google_avis integer,
    google_verifie_le timestamp with time zone,
    status public.partner_status DEFAULT 'brouillon'::public.partner_status NOT NULL,
    motif_rejet text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    activated_at timestamp with time zone,
    location public.geography(Point,4326),
    commission_taux numeric(5,4),
    CONSTRAINT partners_commission_taux_check CHECK (((commission_taux >= (0)::numeric) AND (commission_taux <= (1)::numeric)))
);


--
-- Name: COLUMN partners.commission_taux; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.partners.commission_taux IS 'Taux de commission Safe Date prevu au contrat de partenariat. NULL = taux plateforme par defaut.';


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    date_id uuid NOT NULL,
    payer_id uuid,
    partner_id uuid NOT NULL,
    kind public.payment_kind DEFAULT 'paiement'::public.payment_kind NOT NULL,
    mode public.payment_mode DEFAULT 'individuel'::public.payment_mode NOT NULL,
    amount_cents integer NOT NULL,
    tip_cents integer DEFAULT 0 NOT NULL,
    currency character(3) DEFAULT 'EUR'::bpchar NOT NULL,
    stripe_payment_intent_id text,
    status public.payment_status DEFAULT 'en_attente'::public.payment_status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    captured_at timestamp with time zone,
    CONSTRAINT payments_amount_cents_check CHECK ((amount_cents >= 0)),
    CONSTRAINT payments_tip_cents_check CHECK ((tip_cents >= 0))
);


--
-- Name: TABLE payments; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.payments IS 'Couvre l''empreinte bancaire (preautorisation), le reglement et le remboursement. Le mode "especes" est enregistre pour la tracabilite meme si la transaction se fait hors plateforme.';


--
-- Name: platform_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.platform_messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    code text NOT NULL,
    titre text,
    corps text NOT NULL,
    actions jsonb DEFAULT '[]'::jsonb NOT NULL,
    a_envoyer_a timestamp with time zone DEFAULT now() NOT NULL,
    envoye_at timestamp with time zone,
    lu_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE platform_messages; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.platform_messages IS 'Messages emis par Safe Date dans la messagerie de l''utilisateur : rappel des regles, relance d''evaluation, fin de conversation, regularisation. a_envoyer_a permet le differe prevu au cahier des charges.';


--
-- Name: policy_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.policy_documents (
    code text NOT NULL,
    version text NOT NULL,
    published_at timestamp with time zone NOT NULL,
    body text NOT NULL,
    body_sha256 text NOT NULL,
    is_current boolean DEFAULT false NOT NULL
);


--
-- Name: profile_exclusions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profile_exclusions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_lo uuid NOT NULL,
    user_hi uuid NOT NULL,
    initiator uuid NOT NULL,
    reason public.exclusion_reason NOT NULL,
    source_request_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone,
    CONSTRAINT profile_exclusions_paire_ordonnee CHECK ((user_lo < user_hi))
);


--
-- Name: TABLE profile_exclusions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.profile_exclusions IS 'Exclusion mutuelle entre deux utilisateurs. Toujours reciproque : celui qui a ete refuse cesse egalement de voir celui qui a refuse, sans en etre informe. expires_at nul = permanent. Aucune policy de lecture directe : l''acces passe exclusivement par les fonctions private.';


--
-- Name: profile_presentations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profile_presentations (
    id bigint NOT NULL,
    observer_id uuid NOT NULL,
    target_id uuid NOT NULL,
    contexte public.swipe_contexte NOT NULL,
    ordre_pages public.score_group[] NOT NULL,
    criteres jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    critere_isole text,
    serie_id uuid,
    CONSTRAINT presentations_pas_soi_meme CHECK ((observer_id <> target_id)),
    CONSTRAINT presentations_trois_pages CHECK ((cardinality(ordre_pages) = 3))
);


--
-- Name: TABLE profile_presentations; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.profile_presentations IS 'Une ligne par profil servi. Le meme profil peut etre presente differemment a deux personnes : l''ordre des pages et les criteres retenus dependent de ce que le moteur cherche a apprendre de l''observateur.';


--
-- Name: COLUMN profile_presentations.ordre_pages; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.profile_presentations.ordre_pages IS 'Ordre decide par le moteur, jamais fixe. Faire varier l''ordre n''est pas un choix d''interface : c''est ce qui permet de distinguer une page ignoree d''une page simplement placee en dernier.';


--
-- Name: COLUMN profile_presentations.criteres; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.profile_presentations.criteres IS 'Criteres retenus par page. Ce qui n''y figure pas n''a pas ete montre et ne peut donc pas avoir influence la decision.';


--
-- Name: COLUMN profile_presentations.critere_isole; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.profile_presentations.critere_isole IS 'Critere que cette presentation cherche a isoler. Les profils d''une meme serie ne different volontairement que sur lui.';


--
-- Name: COLUMN profile_presentations.serie_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.profile_presentations.serie_id IS 'Regroupe les presentations d''une meme experience. Sans ce lien, les decisions ne peuvent pas etre comparees entre elles.';


--
-- Name: profile_presentations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.profile_presentations ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.profile_presentations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: profile_vectors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profile_vectors (
    user_id uuid NOT NULL,
    self_mask integer[] NOT NULL,
    pref_mask integer[] NOT NULL,
    weight_mul numeric[] NOT NULL,
    answered_self smallint DEFAULT 0 NOT NULL,
    answered_pref smallint DEFAULT 0 NOT NULL,
    refreshed_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: quiz_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quiz_answers (
    question_id uuid NOT NULL,
    user_id uuid NOT NULL,
    answer_idx smallint,
    answer_text text,
    answered_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE quiz_answers; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.quiz_answers IS 'Reponses jamais visibles par les autres utilisateurs. Servent uniquement a affiner le moteur de compatibilite. Aucune notion de bonne ou mauvaise reponse.';


--
-- Name: quiz_questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quiz_questions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    session_id uuid NOT NULL,
    ordre smallint DEFAULT 0 NOT NULL,
    question text NOT NULL,
    source_pair_key text,
    options jsonb DEFAULT '[]'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: COLUMN quiz_questions.source_pair_key; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.quiz_questions.source_pair_key IS 'Critere de compatibilite ayant inspire la question. Les points communs ne sont jamais reveles directement : ils doivent se decouvrir au fil de l''echange.';


--
-- Name: quiz_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quiz_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    date_id uuid NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    ended_at timestamp with time zone
);


--
-- Name: TABLE quiz_sessions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.quiz_sessions IS 'Quiz genere dynamiquement pendant le rendez-vous a partir des profils des deux utilisateurs. Reserve aux membres SAFE Premium, entierement facultatif, interruptible.';


--
-- Name: sensitive_access_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sensitive_access_log (
    id bigint NOT NULL,
    occurred_at timestamp with time zone DEFAULT now() NOT NULL,
    actor text NOT NULL,
    subject_id uuid,
    category public.sensitive_category,
    purpose text NOT NULL,
    row_count integer
);


--
-- Name: sensitive_access_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sensitive_access_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sensitive_access_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sensitive_access_log_id_seq OWNED BY public.sensitive_access_log.id;


--
-- Name: session_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.session_messages (
    id smallint NOT NULL,
    message text NOT NULL,
    actif boolean DEFAULT true NOT NULL
);


--
-- Name: session_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.session_messages ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.session_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: surprise_cooldowns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.surprise_cooldowns (
    from_user uuid NOT NULL,
    to_user uuid NOT NULL,
    blocked_until timestamp with time zone NOT NULL,
    reason public.surprise_response NOT NULL
);


--
-- Name: TABLE surprise_cooldowns; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.surprise_cooldowns IS 'Anti-insistance : indisponible aujourd''hui bloque jusqu''au lendemain, cette semaine jusqu''a la fin de semaine, refus pendant 30 jours. Ne s''applique qu''a l''emetteur : celui qui a decline peut reprendre l''initiative a tout moment.';


--
-- Name: surprise_proposals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.surprise_proposals (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    from_user uuid NOT NULL,
    to_user uuid NOT NULL,
    previous_date_id uuid,
    response public.surprise_response,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    responded_at timestamp with time zone,
    CONSTRAINT surprise_pas_soi_meme CHECK ((from_user <> to_user))
);


--
-- Name: swipe_decisions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.swipe_decisions (
    id bigint NOT NULL,
    user_id uuid NOT NULL,
    target_id uuid NOT NULL,
    decision boolean NOT NULL,
    signal_fort boolean DEFAULT false NOT NULL,
    ecran text,
    duree_ms integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    contexte public.swipe_contexte DEFAULT 'partir_en_date'::public.swipe_contexte NOT NULL,
    duree_totale_ms integer,
    ordre_consultation public.score_group[],
    retours smallint DEFAULT 0 NOT NULL,
    criteres_exposes text[],
    criteres_consultes text[],
    attention_physique numeric(4,3),
    attention_mode_vie numeric(4,3),
    attention_valeurs numeric(4,3),
    fiabilite_attention numeric(4,3),
    snapshot jsonb,
    type_rencontre public.rencontre_type,
    score_predit numeric(6,2),
    seuil_predit numeric(4,3),
    erreur_prediction numeric(5,4),
    presentation_id bigint,
    pages_ignorees public.score_group[],
    vitesse_ms_page integer,
    CONSTRAINT swipe_type_selon_contexte CHECK (((contexte = 'partir_en_date'::public.swipe_contexte) OR (type_rencontre IS NULL)))
);


--
-- Name: COLUMN swipe_decisions.contexte; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.swipe_decisions.contexte IS 'Un swipe d''apprentissage et un swipe de rencontre ne veulent pas dire la meme chose. Le premier signifie "ce profil me plait", le second "je considere reellement cette personne". Leur poids et leurs consequences different.';


--
-- Name: COLUMN swipe_decisions.ordre_consultation; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.swipe_decisions.ordre_consultation IS 'Ordre reel de consultation des sections. Aller droit aux valeurs et ne jamais revenir a la photo ne dit pas la meme chose que l''inverse.';


--
-- Name: COLUMN swipe_decisions.criteres_exposes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.swipe_decisions.criteres_exposes IS 'Criteres reellement affiches sur le profil au moment du swipe. Un critere absent ne peut pas avoir influence la decision.';


--
-- Name: COLUMN swipe_decisions.criteres_consultes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.swipe_decisions.criteres_consultes IS 'Sous-ensemble reellement consulte. Etre visible n''est pas etre regarde : c''est toute la difference entre exposition et attention.';


--
-- Name: COLUMN swipe_decisions.fiabilite_attention; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.swipe_decisions.fiabilite_attention IS 'Confiance accordee a la repartition d''attention. Un profil balaye en deux secondes produit une repartition sans valeur, meme si elle est calculable.';


--
-- Name: COLUMN swipe_decisions.snapshot; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.swipe_decisions.snapshot IS 'Etat du profil au moment du swipe. Sans cela, un profil modifie ensuite rendrait la decision passee inexplicable.';


--
-- Name: COLUMN swipe_decisions.type_rencontre; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.swipe_decisions.type_rencontre IS 'Renseigne uniquement dans Partir en date. Nul en apprentissage : Mieux me connaitre ignore volontairement ce que l''utilisateur recherche.';


--
-- Name: COLUMN swipe_decisions.score_predit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.swipe_decisions.score_predit IS 'Compatibilite annoncee par le moteur au moment du swipe, dans le contexte de recherche actif. Sans elle, aucune erreur ne peut etre imputee.';


--
-- Name: COLUMN swipe_decisions.erreur_prediction; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.swipe_decisions.erreur_prediction IS 'Ecart entre prediction et decision reelle, de 0 a 1. Une prediction elevee suivie d''un refus, ou l''inverse, produit une erreur proche de 1.';


--
-- Name: COLUMN swipe_decisions.pages_ignorees; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.swipe_decisions.pages_ignorees IS 'Pages servies mais jamais ouvertes. Un refus prononce apres avoir seulement regarde les photos ne dit pas la meme chose qu''un refus apres avoir tout lu.';


--
-- Name: COLUMN swipe_decisions.vitesse_ms_page; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.swipe_decisions.vitesse_ms_page IS 'Temps moyen par page consultee. Une navigation tres rapide affaiblit la valeur de tout signal tire de cette consultation.';


--
-- Name: swipe_decisions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.swipe_decisions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: swipe_decisions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.swipe_decisions_id_seq OWNED BY public.swipe_decisions.id;


--
-- Name: swipe_ecrans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.swipe_ecrans (
    swipe_id bigint NOT NULL,
    ecran public.score_group NOT NULL,
    duree_ms integer DEFAULT 0 NOT NULL,
    consultations smallint DEFAULT 1 NOT NULL,
    CONSTRAINT swipe_ecrans_consultations_positives CHECK ((consultations >= 0)),
    CONSTRAINT swipe_ecrans_duree_positive CHECK ((duree_ms >= 0))
);


--
-- Name: TABLE swipe_ecrans; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.swipe_ecrans IS 'Une ligne par section consultee lors d''un swipe. Aucune policy : la lecture passe par les fonctions private.';


--
-- Name: training_modules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.training_modules (
    code text NOT NULL,
    titre text NOT NULL,
    "position" smallint NOT NULL,
    obligatoire boolean DEFAULT true NOT NULL,
    video_path text,
    score_min smallint DEFAULT 80 NOT NULL
);


--
-- Name: user_acceptances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_acceptances (
    user_id uuid NOT NULL,
    policy_code text NOT NULL,
    policy_version text NOT NULL,
    accepted_at timestamp with time zone DEFAULT now() NOT NULL,
    ip_address inet
);


--
-- Name: user_criterion_priorities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_criterion_priorities (
    user_id uuid NOT NULL,
    pair_key text NOT NULL,
    rang smallint NOT NULL,
    manuel boolean DEFAULT false NOT NULL,
    CONSTRAINT user_criterion_priorities_rang_check CHECK ((rang >= 1))
);


--
-- Name: user_criterion_profile; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_criterion_profile (
    user_id uuid NOT NULL,
    criterion_key text NOT NULL,
    grp public.score_group,
    observations integer DEFAULT 0 NOT NULL,
    taux_oui numeric(5,4),
    taux_recent numeric(5,4),
    importance numeric(5,4),
    confiance numeric(5,4),
    derive boolean DEFAULT false NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE user_criterion_profile; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.user_criterion_profile IS 'Ce que le moteur pense actuellement savoir, et a quel point il en est sur. Aucune ligne ne constitue une verite : importance et confiance doivent toujours etre lues ensemble.';


--
-- Name: COLUMN user_criterion_profile.importance; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_criterion_profile.importance IS 'Pouvoir discriminant du critere : mesure a quel point le taux d''acceptation varie selon les options. Un critere dont toutes les options obtiennent le meme taux n''influence rien, quel que soit ce taux.';


--
-- Name: COLUMN user_criterion_profile.confiance; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_criterion_profile.confiance IS 'Fonction du volume d''observations. Cent pour cent de oui sur une observation donne une importance apparente maximale et une confiance quasi nulle.';


--
-- Name: COLUMN user_criterion_profile.derive; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_criterion_profile.derive IS 'Signale un ecart marque entre le comportement global et le comportement recent. Une preference ancienne ne doit pas primer sur un comportement actuel.';


--
-- Name: user_knowledge_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_knowledge_history (
    user_id uuid NOT NULL,
    jour date NOT NULL,
    niveau numeric(5,4) NOT NULL
);


--
-- Name: TABLE user_knowledge_history; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.user_knowledge_history IS 'Un releve par jour, pour pouvoir dire a l''utilisateur ou il en est par rapport a hier sans recalculer le passe.';


--
-- Name: user_option_outcome; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_option_outcome (
    user_id uuid NOT NULL,
    criterion_key text NOT NULL,
    option_idx smallint NOT NULL,
    rencontres integer DEFAULT 0 NOT NULL,
    satisfaction_moy numeric(5,4),
    poursuites integer DEFAULT 0 NOT NULL,
    taux_poursuite numeric(5,4),
    pouvoir_predictif numeric(6,4),
    confiance numeric(5,4),
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE user_option_outcome; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.user_option_outcome IS 'Couches D et E, a la meme granularite que l''attraction : par option. Mesurer au niveau du critere reviendrait a moyenner ensemble les profils appreciez et les autres, ce qui annule precisement l''ecart que l''on cherche.';


--
-- Name: COLUMN user_option_outcome.pouvoir_predictif; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.user_option_outcome.pouvoir_predictif IS 'Ecart entre la satisfaction obtenue avec les personnes portant cette option et la satisfaction moyenne de l''utilisateur. Positif : l''option annonce de bonnes rencontres. Negatif : elle attire sans tenir ses promesses.';


--
-- Name: user_option_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_option_stats (
    user_id uuid NOT NULL,
    criterion_key text NOT NULL,
    option_idx smallint NOT NULL,
    observations integer DEFAULT 0 NOT NULL,
    oui integer DEFAULT 0 NOT NULL,
    poids numeric DEFAULT 0 NOT NULL,
    poids_oui numeric DEFAULT 0 NOT NULL,
    obs_recentes integer DEFAULT 0 NOT NULL,
    oui_recents integer DEFAULT 0 NOT NULL,
    derniere_vue timestamp with time zone,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE user_option_stats; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.user_option_stats IS 'Compteurs bruts par option reellement observee. poids et poids_oui sont ponderes par le contexte du swipe et par l''attention accordee a la categorie concernee : un oui donne apres trente secondes sur la photo ne pese pas comme un oui donne sans l''avoir regardee.';


--
-- Name: user_payment_methods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_payment_methods (
    user_id uuid NOT NULL,
    stripe_customer_id text NOT NULL,
    stripe_payment_method_id text NOT NULL,
    brand text,
    last4 character(4),
    exp_month smallint,
    exp_year smallint,
    is_default boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE user_payment_methods; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.user_payment_methods IS 'Aucune donnee de carte n''est stockee : uniquement les references opaques du prestataire de paiement et les elements d''affichage.';


--
-- Name: user_photos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_photos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    storage_path text NOT NULL,
    "position" smallint DEFAULT 0 NOT NULL,
    moderation public.moderation_status DEFAULT 'en_attente'::public.moderation_status NOT NULL,
    moderated_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    is_primary boolean DEFAULT false NOT NULL
);


--
-- Name: user_step_completions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_step_completions (
    user_id uuid NOT NULL,
    step smallint NOT NULL,
    completed_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_steps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_steps (
    step smallint NOT NULL,
    code text NOT NULL,
    label text NOT NULL,
    est_seconds smallint DEFAULT 30 NOT NULL,
    bloquante boolean DEFAULT true NOT NULL
);


--
-- Name: user_verification_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_verification_codes (
    user_id uuid NOT NULL,
    channel public.verif_channel NOT NULL,
    destination text NOT NULL,
    code_sha256 text NOT NULL,
    sent_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '00:15:00'::interval) NOT NULL,
    verified_at timestamp with time zone,
    attempts smallint DEFAULT 0 NOT NULL
);


--
-- Name: v_chat_requests_du_jour; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_chat_requests_du_jour AS
 SELECT from_user,
    count(*) AS envoyees
   FROM public.chat_requests
  WHERE (created_at >= date_trunc('day'::text, now()))
  GROUP BY from_user;


--
-- Name: venue_proposals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.venue_proposals (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    conversation_id uuid NOT NULL,
    partner_id uuid NOT NULL,
    ordre smallint DEFAULT 0 NOT NULL,
    creneau_debut timestamp with time zone NOT NULL,
    score_pertinence numeric(6,3),
    status public.venue_proposal_status DEFAULT 'en_cours'::public.venue_proposal_status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE venue_proposals; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.venue_proposals IS 'Etablissements proposes un par un aux deux utilisateurs. Le nom, l''adresse exacte, les coordonnees et les photos restent masques jusqu''a confirmation du rendez-vous.';


--
-- Name: venue_reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.venue_reviews (
    date_id uuid NOT NULL,
    user_id uuid NOT NULL,
    partner_id uuid NOT NULL,
    note_produits smallint,
    note_rapport_qp smallint,
    note_service smallint,
    note_globale numeric(3,2),
    commentaire text,
    publier_google boolean DEFAULT false NOT NULL,
    status public.review_status DEFAULT 'propose'::public.review_status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    submitted_at timestamp with time zone,
    CONSTRAINT venue_reviews_note_globale_check CHECK (((note_globale >= (1)::numeric) AND (note_globale <= (5)::numeric))),
    CONSTRAINT venue_reviews_note_produits_check CHECK (((note_produits >= 1) AND (note_produits <= 5))),
    CONSTRAINT venue_reviews_note_rapport_qp_check CHECK (((note_rapport_qp >= 1) AND (note_rapport_qp <= 5))),
    CONSTRAINT venue_reviews_note_service_check CHECK (((note_service >= 1) AND (note_service <= 5)))
);


--
-- Name: TABLE venue_reviews; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.venue_reviews IS 'Evaluation totalement independante de la qualite de la rencontre. Proposee des la sortie de l''etablissement, sans delai supplementaire.';


--
-- Name: COLUMN venue_reviews.note_globale; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.venue_reviews.note_globale IS 'Moyenne des trois criteres, proposee automatiquement mais librement modifiable par l''utilisateur.';


--
-- Name: venue_votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.venue_votes (
    proposal_id uuid NOT NULL,
    user_id uuid NOT NULL,
    accepted boolean NOT NULL,
    decided_at timestamp with time zone DEFAULT now() NOT NULL,
    duree_ms integer
);


--
-- Name: TABLE venue_votes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.venue_votes IS 'Swipe droite = accepte, gauche = refuse. Un seul refus ecarte definitivement l''etablissement pour cette rencontre.';


--
-- Name: sensitive_access_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sensitive_access_log ALTER COLUMN id SET DEFAULT nextval('public.sensitive_access_log_id_seq'::regclass);


--
-- Name: swipe_decisions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.swipe_decisions ALTER COLUMN id SET DEFAULT nextval('public.swipe_decisions_id_seq'::regclass);


--
-- Name: compat_cache compat_cache_pkey; Type: CONSTRAINT; Schema: private; Owner: -
--

ALTER TABLE ONLY private.compat_cache
    ADD CONSTRAINT compat_cache_pkey PRIMARY KEY (user_lo, user_hi);


--
-- Name: phrase_patterns phrase_patterns_pkey; Type: CONSTRAINT; Schema: private; Owner: -
--

ALTER TABLE ONLY private.phrase_patterns
    ADD CONSTRAINT phrase_patterns_pkey PRIMARY KEY (criterion_key);


--
-- Name: availability_windows availability_windows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.availability_windows
    ADD CONSTRAINT availability_windows_pkey PRIMARY KEY (id);


--
-- Name: blocks blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_pkey PRIMARY KEY (blocker_id, blocked_id);


--
-- Name: chat_requests chat_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_requests
    ADD CONSTRAINT chat_requests_pkey PRIMARY KEY (id);


--
-- Name: consents consents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consents
    ADD CONSTRAINT consents_pkey PRIMARY KEY (user_id, category, granted_at);


--
-- Name: context_weight_defaults context_weight_defaults_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.context_weight_defaults
    ADD CONSTRAINT context_weight_defaults_pkey PRIMARY KEY (type_rencontre);


--
-- Name: conversation_decisions conversation_decisions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversation_decisions
    ADD CONSTRAINT conversation_decisions_pkey PRIMARY KEY (conversation_id, user_id);


--
-- Name: conversations conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_pkey PRIMARY KEY (id);


--
-- Name: conversations conversations_request_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_request_id_key UNIQUE (request_id);


--
-- Name: criteria criteria_ord_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.criteria
    ADD CONSTRAINT criteria_ord_key UNIQUE (ord);


--
-- Name: criteria criteria_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.criteria
    ADD CONSTRAINT criteria_pkey PRIMARY KEY (key);


--
-- Name: criterion_option_phrasings criterion_option_phrasings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.criterion_option_phrasings
    ADD CONSTRAINT criterion_option_phrasings_pkey PRIMARY KEY (criterion_key, idx, locale);


--
-- Name: criterion_options criterion_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.criterion_options
    ADD CONSTRAINT criterion_options_pkey PRIMARY KEY (criterion_key, idx);


--
-- Name: criterion_pairs criterion_pairs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.criterion_pairs
    ADD CONSTRAINT criterion_pairs_pkey PRIMARY KEY (pair_key);


--
-- Name: criterion_pairs criterion_pairs_slot_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.criterion_pairs
    ADD CONSTRAINT criterion_pairs_slot_key UNIQUE (slot);


--
-- Name: date_followups date_followups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.date_followups
    ADD CONSTRAINT date_followups_pkey PRIMARY KEY (date_id, user_id);


--
-- Name: date_meeting_points date_meeting_points_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.date_meeting_points
    ADD CONSTRAINT date_meeting_points_pkey PRIMARY KEY (date_id, user_id);


--
-- Name: date_presence date_presence_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.date_presence
    ADD CONSTRAINT date_presence_pkey PRIMARY KEY (date_id, user_id);


--
-- Name: date_reviews date_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.date_reviews
    ADD CONSTRAINT date_reviews_pkey PRIMARY KEY (date_id, user_id);


--
-- Name: dates dates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dates
    ADD CONSTRAINT dates_pkey PRIMARY KEY (id);


--
-- Name: deletion_requests deletion_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deletion_requests
    ADD CONSTRAINT deletion_requests_pkey PRIMARY KEY (user_id);


--
-- Name: engine_params engine_params_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.engine_params
    ADD CONSTRAINT engine_params_pkey PRIMARY KEY (key);


--
-- Name: fake_contacts fake_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fake_contacts
    ADD CONSTRAINT fake_contacts_pkey PRIMARY KEY (id);


--
-- Name: focus_compatibilite focus_compatibilite_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.focus_compatibilite
    ADD CONSTRAINT focus_compatibilite_pkey PRIMARY KEY (id);


--
-- Name: grille_import_v1 grille_import_v1_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grille_import_v1
    ADD CONSTRAINT grille_import_v1_pkey PRIMARY KEY (src_row);


--
-- Name: help_requests help_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_requests
    ADD CONSTRAINT help_requests_pkey PRIMARY KEY (id);


--
-- Name: help_staff_reports help_staff_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_staff_reports
    ADD CONSTRAINT help_staff_reports_pkey PRIMARY KEY (id);


--
-- Name: help_user_reports help_user_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_user_reports
    ADD CONSTRAINT help_user_reports_pkey PRIMARY KEY (help_request_id);


--
-- Name: identity_verifications identity_verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identity_verifications
    ADD CONSTRAINT identity_verifications_pkey PRIMARY KEY (id);


--
-- Name: invoice_lines invoice_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice_lines
    ADD CONSTRAINT invoice_lines_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_number_key UNIQUE (number);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: menu_stopwords menu_stopwords_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_stopwords
    ADD CONSTRAINT menu_stopwords_pkey PRIMARY KEY (mot);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: moderation_actions moderation_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_actions
    ADD CONSTRAINT moderation_actions_pkey PRIMARY KEY (id);


--
-- Name: option_mappings option_mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.option_mappings
    ADD CONSTRAINT option_mappings_pkey PRIMARY KEY (pair_key, pref_idx);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- Name: order_payments order_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_payments
    ADD CONSTRAINT order_payments_pkey PRIMARY KEY (payment_id, order_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: outstanding_debts outstanding_debts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outstanding_debts
    ADD CONSTRAINT outstanding_debts_pkey PRIMARY KEY (id);


--
-- Name: partner_acceptances partner_acceptances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_acceptances
    ADD CONSTRAINT partner_acceptances_pkey PRIMARY KEY (partner_id, policy_code);


--
-- Name: partner_contracts partner_contracts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_contracts
    ADD CONSTRAINT partner_contracts_pkey PRIMARY KEY (partner_id);


--
-- Name: partner_documents partner_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_documents
    ADD CONSTRAINT partner_documents_pkey PRIMARY KEY (id);


--
-- Name: partner_menu_categories partner_menu_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_menu_categories
    ADD CONSTRAINT partner_menu_categories_pkey PRIMARY KEY (id);


--
-- Name: partner_menu_items partner_menu_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_menu_items
    ADD CONSTRAINT partner_menu_items_pkey PRIMARY KEY (id);


--
-- Name: partner_payout_accounts partner_payout_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_payout_accounts
    ADD CONSTRAINT partner_payout_accounts_pkey PRIMARY KEY (partner_id);


--
-- Name: partner_payout_accounts partner_payout_accounts_stripe_account_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_payout_accounts
    ADD CONSTRAINT partner_payout_accounts_stripe_account_id_key UNIQUE (stripe_account_id);


--
-- Name: partner_photos partner_photos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_photos
    ADD CONSTRAINT partner_photos_pkey PRIMARY KEY (id);


--
-- Name: partner_postal_verifications partner_postal_verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_postal_verifications
    ADD CONSTRAINT partner_postal_verifications_pkey PRIMARY KEY (partner_id);


--
-- Name: partner_safe_zones partner_safe_zones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_safe_zones
    ADD CONSTRAINT partner_safe_zones_pkey PRIMARY KEY (id);


--
-- Name: partner_settlements partner_settlements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_settlements
    ADD CONSTRAINT partner_settlements_pkey PRIMARY KEY (id);


--
-- Name: partner_step_completions partner_step_completions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_step_completions
    ADD CONSTRAINT partner_step_completions_pkey PRIMARY KEY (partner_id, step);


--
-- Name: partner_steps partner_steps_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_steps
    ADD CONSTRAINT partner_steps_code_key UNIQUE (code);


--
-- Name: partner_steps partner_steps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_steps
    ADD CONSTRAINT partner_steps_pkey PRIMARY KEY (step);


--
-- Name: partner_training_completions partner_training_completions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_training_completions
    ADD CONSTRAINT partner_training_completions_pkey PRIMARY KEY (partner_id, module_code);


--
-- Name: partners partners_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partners
    ADD CONSTRAINT partners_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: platform_messages platform_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.platform_messages
    ADD CONSTRAINT platform_messages_pkey PRIMARY KEY (id);


--
-- Name: policy_documents policy_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.policy_documents
    ADD CONSTRAINT policy_documents_pkey PRIMARY KEY (code, version);


--
-- Name: profile_answers profile_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_answers
    ADD CONSTRAINT profile_answers_pkey PRIMARY KEY (user_id, criterion_key);


--
-- Name: profile_exclusions profile_exclusions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_exclusions
    ADD CONSTRAINT profile_exclusions_pkey PRIMARY KEY (id);


--
-- Name: profile_presentations profile_presentations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_presentations
    ADD CONSTRAINT profile_presentations_pkey PRIMARY KEY (id);


--
-- Name: profile_vectors profile_vectors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_vectors
    ADD CONSTRAINT profile_vectors_pkey PRIMARY KEY (user_id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: quiz_answers quiz_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quiz_answers
    ADD CONSTRAINT quiz_answers_pkey PRIMARY KEY (question_id, user_id);


--
-- Name: quiz_questions quiz_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quiz_questions
    ADD CONSTRAINT quiz_questions_pkey PRIMARY KEY (id);


--
-- Name: quiz_sessions quiz_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quiz_sessions
    ADD CONSTRAINT quiz_sessions_pkey PRIMARY KEY (id);


--
-- Name: reports reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_pkey PRIMARY KEY (id);


--
-- Name: sensitive_access_log sensitive_access_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sensitive_access_log
    ADD CONSTRAINT sensitive_access_log_pkey PRIMARY KEY (id);


--
-- Name: session_messages session_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session_messages
    ADD CONSTRAINT session_messages_pkey PRIMARY KEY (id);


--
-- Name: surprise_cooldowns surprise_cooldowns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.surprise_cooldowns
    ADD CONSTRAINT surprise_cooldowns_pkey PRIMARY KEY (from_user, to_user);


--
-- Name: surprise_proposals surprise_proposals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.surprise_proposals
    ADD CONSTRAINT surprise_proposals_pkey PRIMARY KEY (id);


--
-- Name: swipe_decisions swipe_decisions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.swipe_decisions
    ADD CONSTRAINT swipe_decisions_pkey PRIMARY KEY (id);


--
-- Name: swipe_ecrans swipe_ecrans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.swipe_ecrans
    ADD CONSTRAINT swipe_ecrans_pkey PRIMARY KEY (swipe_id, ecran);


--
-- Name: training_modules training_modules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_modules
    ADD CONSTRAINT training_modules_pkey PRIMARY KEY (code);


--
-- Name: user_acceptances user_acceptances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_acceptances
    ADD CONSTRAINT user_acceptances_pkey PRIMARY KEY (user_id, policy_code);


--
-- Name: user_context_weights user_context_weights_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_context_weights
    ADD CONSTRAINT user_context_weights_pkey PRIMARY KEY (user_id, type_rencontre);


--
-- Name: user_criterion_learning user_criterion_learning_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_criterion_learning
    ADD CONSTRAINT user_criterion_learning_pkey PRIMARY KEY (user_id, pair_key);


--
-- Name: user_criterion_priorities user_criterion_priorities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_criterion_priorities
    ADD CONSTRAINT user_criterion_priorities_pkey PRIMARY KEY (user_id, pair_key);


--
-- Name: user_criterion_priorities user_criterion_priorities_user_id_rang_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_criterion_priorities
    ADD CONSTRAINT user_criterion_priorities_user_id_rang_key UNIQUE (user_id, rang) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_criterion_profile user_criterion_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_criterion_profile
    ADD CONSTRAINT user_criterion_profile_pkey PRIMARY KEY (user_id, criterion_key);


--
-- Name: user_knowledge_history user_knowledge_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_knowledge_history
    ADD CONSTRAINT user_knowledge_history_pkey PRIMARY KEY (user_id, jour);


--
-- Name: user_option_outcome user_option_outcome_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_option_outcome
    ADD CONSTRAINT user_option_outcome_pkey PRIMARY KEY (user_id, criterion_key, option_idx);


--
-- Name: user_option_stats user_option_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_option_stats
    ADD CONSTRAINT user_option_stats_pkey PRIMARY KEY (user_id, criterion_key, option_idx);


--
-- Name: user_payment_methods user_payment_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_payment_methods
    ADD CONSTRAINT user_payment_methods_pkey PRIMARY KEY (user_id, stripe_payment_method_id);


--
-- Name: user_photos user_photos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_photos
    ADD CONSTRAINT user_photos_pkey PRIMARY KEY (id);


--
-- Name: user_step_completions user_step_completions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_step_completions
    ADD CONSTRAINT user_step_completions_pkey PRIMARY KEY (user_id, step);


--
-- Name: user_steps user_steps_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_steps
    ADD CONSTRAINT user_steps_code_key UNIQUE (code);


--
-- Name: user_steps user_steps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_steps
    ADD CONSTRAINT user_steps_pkey PRIMARY KEY (step);


--
-- Name: user_verification_codes user_verification_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_verification_codes
    ADD CONSTRAINT user_verification_codes_pkey PRIMARY KEY (user_id);


--
-- Name: venue_proposals venue_proposals_conversation_id_partner_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.venue_proposals
    ADD CONSTRAINT venue_proposals_conversation_id_partner_id_key UNIQUE (conversation_id, partner_id);


--
-- Name: venue_proposals venue_proposals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.venue_proposals
    ADD CONSTRAINT venue_proposals_pkey PRIMARY KEY (id);


--
-- Name: venue_reviews venue_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.venue_reviews
    ADD CONSTRAINT venue_reviews_pkey PRIMARY KEY (date_id, user_id);


--
-- Name: venue_votes venue_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.venue_votes
    ADD CONSTRAINT venue_votes_pkey PRIMARY KEY (proposal_id, user_id);


--
-- Name: compat_cache_hi_score; Type: INDEX; Schema: private; Owner: -
--

CREATE INDEX compat_cache_hi_score ON private.compat_cache USING btree (user_hi, score_global DESC) WHERE affichable;


--
-- Name: compat_cache_lo_score; Type: INDEX; Schema: private; Owner: -
--

CREATE INDEX compat_cache_lo_score ON private.compat_cache USING btree (user_lo, score_global DESC) WHERE affichable;


--
-- Name: criterion_stats_criterion_key_idx; Type: INDEX; Schema: private; Owner: -
--

CREATE UNIQUE INDEX criterion_stats_criterion_key_idx ON private.criterion_stats USING btree (criterion_key);


--
-- Name: blocks_blocked_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX blocks_blocked_id_idx ON public.blocks USING btree (blocked_id);


--
-- Name: chat_requests_active_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX chat_requests_active_uniq ON public.chat_requests USING btree (from_user, to_user) WHERE (status = ANY (ARRAY['en_attente'::public.chat_request_status, 'reportee'::public.chat_request_status]));


--
-- Name: chat_requests_boite_reception; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX chat_requests_boite_reception ON public.chat_requests USING btree (to_user, status, created_at DESC);


--
-- Name: chat_requests_echeance_dormante; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX chat_requests_echeance_dormante ON public.chat_requests USING btree (stale_at) WHERE (status = 'en_attente'::public.chat_request_status);


--
-- Name: chat_requests_echeance_ouverte; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX chat_requests_echeance_ouverte ON public.chat_requests USING btree (expires_at) WHERE (status = ANY (ARRAY['en_attente'::public.chat_request_status, 'reportee'::public.chat_request_status]));


--
-- Name: consents_user_id_category_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX consents_user_id_category_idx ON public.consents USING btree (user_id, category) WHERE (withdrawn_at IS NULL);


--
-- Name: criteria_moment_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX criteria_moment_idx ON public.criteria USING btree (moment);


--
-- Name: criteria_pair_key_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX criteria_pair_key_idx ON public.criteria USING btree (pair_key);


--
-- Name: date_meeting_points_point_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX date_meeting_points_point_idx ON public.date_meeting_points USING gist (point);


--
-- Name: identity_verifications_user_id_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX identity_verifications_user_id_status_idx ON public.identity_verifications USING btree (user_id, status);


--
-- Name: idx_availability_user_debut; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_availability_user_debut ON public.availability_windows USING btree (user_id, debut);


--
-- Name: idx_chat_req_dest; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_chat_req_dest ON public.chat_requests USING btree (to_user, status, created_at DESC);


--
-- Name: idx_chat_req_exp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_chat_req_exp ON public.chat_requests USING btree (from_user, created_at DESC);


--
-- Name: idx_chat_req_pending; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_chat_req_pending ON public.chat_requests USING btree (expires_at) WHERE (status = 'en_attente'::public.chat_request_status);


--
-- Name: idx_conv_a; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_conv_a ON public.conversations USING btree (user_a, started_at DESC);


--
-- Name: idx_conv_b; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_conv_b ON public.conversations USING btree (user_b, started_at DESC);


--
-- Name: idx_dates_conv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dates_conv ON public.dates USING btree (conversation_id);


--
-- Name: idx_debts_ouverts; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_debts_ouverts ON public.outstanding_debts USING btree (user_id) WHERE (settled_at IS NULL);


--
-- Name: idx_focus_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_focus_user ON public.focus_compatibilite USING btree (user_id, created_at DESC);


--
-- Name: idx_help_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_help_date ON public.help_requests USING btree (date_id, created_at DESC);


--
-- Name: idx_invlines_inv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_invlines_inv ON public.invoice_lines USING btree (invoice_id);


--
-- Name: idx_invoices_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_invoices_date ON public.invoices USING btree (date_id);


--
-- Name: idx_invoices_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_invoices_user ON public.invoices USING btree (user_id, issued_at DESC);


--
-- Name: idx_moderation_actives; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_moderation_actives ON public.moderation_actions USING btree (expires_at) WHERE ((leve_at IS NULL) AND (expires_at IS NOT NULL));


--
-- Name: idx_moderation_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_moderation_user ON public.moderation_actions USING btree (user_id, decided_at DESC);


--
-- Name: idx_msg_conv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_msg_conv ON public.messages USING btree (conversation_id, created_at);


--
-- Name: idx_orderitems_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_orderitems_order ON public.order_items USING btree (order_id);


--
-- Name: idx_orders_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_orders_date ON public.orders USING btree (date_id, created_at);


--
-- Name: idx_payments_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payments_date ON public.payments USING btree (date_id, created_at);


--
-- Name: idx_payments_payer; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payments_payer ON public.payments USING btree (payer_id, created_at DESC);


--
-- Name: idx_platform_msg_afaire; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_platform_msg_afaire ON public.platform_messages USING btree (a_envoyer_a) WHERE (envoye_at IS NULL);


--
-- Name: idx_platform_msg_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_platform_msg_user ON public.platform_messages USING btree (user_id, created_at DESC);


--
-- Name: idx_quizq_session; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_quizq_session ON public.quiz_questions USING btree (session_id, ordre);


--
-- Name: idx_quizsess_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_quizsess_date ON public.quiz_sessions USING btree (date_id);


--
-- Name: idx_settle_partner; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_settle_partner ON public.partner_settlements USING btree (partner_id, created_at DESC);


--
-- Name: idx_staffrep_partner; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_staffrep_partner ON public.help_staff_reports USING btree (partner_id, submitted_at DESC);


--
-- Name: idx_surprise_dest; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_surprise_dest ON public.surprise_proposals USING btree (to_user, created_at DESC);


--
-- Name: idx_venueprop_conv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_venueprop_conv ON public.venue_proposals USING btree (conversation_id, ordre);


--
-- Name: idx_venuerev_partner; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_venuerev_partner ON public.venue_reviews USING btree (partner_id, submitted_at DESC);


--
-- Name: partner_menu_items_partner_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX partner_menu_items_partner_id_idx ON public.partner_menu_items USING btree (partner_id) WHERE is_available;


--
-- Name: partner_safe_zones_partner_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX partner_safe_zones_partner_id_idx ON public.partner_safe_zones USING btree (partner_id) WHERE validated;


--
-- Name: partner_safe_zones_zone_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX partner_safe_zones_zone_idx ON public.partner_safe_zones USING gist (zone);


--
-- Name: partners_owner_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX partners_owner_id_idx ON public.partners USING btree (owner_id);


--
-- Name: partners_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX partners_status_idx ON public.partners USING btree (status);


--
-- Name: policy_documents_code_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX policy_documents_code_idx ON public.policy_documents USING btree (code) WHERE is_current;


--
-- Name: presentations_observateur; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX presentations_observateur ON public.profile_presentations USING btree (observer_id, created_at DESC);


--
-- Name: presentations_serie; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX presentations_serie ON public.profile_presentations USING btree (serie_id) WHERE (serie_id IS NOT NULL);


--
-- Name: profile_answers_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX profile_answers_user_id_idx ON public.profile_answers USING btree (user_id);


--
-- Name: profile_exclusions_expiry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX profile_exclusions_expiry ON public.profile_exclusions USING btree (expires_at);


--
-- Name: profile_exclusions_paire_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX profile_exclusions_paire_uniq ON public.profile_exclusions USING btree (user_lo, user_hi);


--
-- Name: profiles_last_seen; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX profiles_last_seen ON public.profiles USING btree (last_seen_at DESC);


--
-- Name: reports_status_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX reports_status_created_at_idx ON public.reports USING btree (status, created_at);


--
-- Name: sensitive_access_log_subject_id_occurred_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sensitive_access_log_subject_id_occurred_at_idx ON public.sensitive_access_log USING btree (subject_id, occurred_at DESC);


--
-- Name: swipe_decisions_contexte; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX swipe_decisions_contexte ON public.swipe_decisions USING btree (user_id, contexte, created_at DESC);


--
-- Name: swipe_decisions_user_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX swipe_decisions_user_id_created_at_idx ON public.swipe_decisions USING btree (user_id, created_at DESC);


--
-- Name: user_criterion_profile_tri; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_criterion_profile_tri ON public.user_criterion_profile USING btree (user_id, importance DESC NULLS LAST);


--
-- Name: user_photos_une_principale; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX user_photos_une_principale ON public.user_photos USING btree (user_id) WHERE is_primary;


--
-- Name: user_photos_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_photos_user_id_idx ON public.user_photos USING btree (user_id);


--
-- Name: consents consents_withdrawn; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER consents_withdrawn AFTER UPDATE ON public.consents FOR EACH ROW EXECUTE FUNCTION public.trg_consent_withdrawn();


--
-- Name: conversation_decisions conversation_decisions_apprentissage; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER conversation_decisions_apprentissage AFTER INSERT ON public.conversation_decisions FOR EACH ROW EXECUTE FUNCTION public.trg_learning_conversation();


--
-- Name: date_reviews date_reviews_apprentissage; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER date_reviews_apprentissage AFTER INSERT ON public.date_reviews FOR EACH ROW EXECUTE FUNCTION public.trg_learning_date_review();


--
-- Name: partner_menu_items menu_items_label; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER menu_items_label BEFORE INSERT OR UPDATE OF label ON public.partner_menu_items FOR EACH ROW EXECUTE FUNCTION public.trg_menu_label();


--
-- Name: option_mappings option_mappings_maj_masque; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER option_mappings_maj_masque BEFORE INSERT OR UPDATE OF accepted_self_idx ON public.option_mappings FOR EACH ROW EXECUTE FUNCTION public.trg_option_mappings_mask();


--
-- Name: partner_step_completions partner_steps_bloque; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER partner_steps_bloque BEFORE INSERT ON public.partner_step_completions FOR EACH ROW EXECUTE FUNCTION public.trg_bloque_si_rejete();


--
-- Name: profile_answers profile_answers_consent; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER profile_answers_consent BEFORE INSERT OR UPDATE ON public.profile_answers FOR EACH ROW EXECUTE FUNCTION public.trg_check_sensitive_consent();


--
-- Name: profile_answers profile_answers_refresh; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER profile_answers_refresh AFTER INSERT OR DELETE OR UPDATE ON public.profile_answers FOR EACH ROW EXECUTE FUNCTION public.trg_refresh_vectors();


--
-- Name: partner_safe_zones safe_zones_utile; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER safe_zones_utile BEFORE INSERT OR UPDATE OF zone ON public.partner_safe_zones FOR EACH ROW EXECUTE FUNCTION public.trg_zone_utile();


--
-- Name: surprise_proposals surprise_proposals_cooldown; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER surprise_proposals_cooldown AFTER UPDATE OF response ON public.surprise_proposals FOR EACH ROW EXECUTE FUNCTION public.trg_surprise_cooldown();


--
-- Name: swipe_decisions swipe_decisions_apprentissage; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER swipe_decisions_apprentissage AFTER INSERT ON public.swipe_decisions FOR EACH ROW EXECUTE FUNCTION public.trg_learning_swipe();


--
-- Name: profile_vectors trg_profile_vectors_invalide_compat; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_profile_vectors_invalide_compat AFTER INSERT OR UPDATE ON public.profile_vectors FOR EACH ROW EXECUTE FUNCTION private.trg_invalider_compat();


--
-- Name: compat_cache compat_cache_user_hi_fkey; Type: FK CONSTRAINT; Schema: private; Owner: -
--

ALTER TABLE ONLY private.compat_cache
    ADD CONSTRAINT compat_cache_user_hi_fkey FOREIGN KEY (user_hi) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: compat_cache compat_cache_user_lo_fkey; Type: FK CONSTRAINT; Schema: private; Owner: -
--

ALTER TABLE ONLY private.compat_cache
    ADD CONSTRAINT compat_cache_user_lo_fkey FOREIGN KEY (user_lo) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: phrase_patterns phrase_patterns_criterion_key_fkey; Type: FK CONSTRAINT; Schema: private; Owner: -
--

ALTER TABLE ONLY private.phrase_patterns
    ADD CONSTRAINT phrase_patterns_criterion_key_fkey FOREIGN KEY (criterion_key) REFERENCES public.criteria(key) ON DELETE CASCADE;


--
-- Name: availability_windows availability_windows_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.availability_windows
    ADD CONSTRAINT availability_windows_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: blocks blocks_blocked_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_blocked_id_fkey FOREIGN KEY (blocked_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: blocks blocks_blocker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_blocker_id_fkey FOREIGN KEY (blocker_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: chat_requests chat_requests_from_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_requests
    ADD CONSTRAINT chat_requests_from_user_fkey FOREIGN KEY (from_user) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: chat_requests chat_requests_to_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_requests
    ADD CONSTRAINT chat_requests_to_user_fkey FOREIGN KEY (to_user) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: consents consents_policy_code_policy_version_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consents
    ADD CONSTRAINT consents_policy_code_policy_version_fkey FOREIGN KEY (policy_code, policy_version) REFERENCES public.policy_documents(code, version);


--
-- Name: consents consents_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.consents
    ADD CONSTRAINT consents_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: conversation_decisions conversation_decisions_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversation_decisions
    ADD CONSTRAINT conversation_decisions_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON DELETE CASCADE;


--
-- Name: conversation_decisions conversation_decisions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversation_decisions
    ADD CONSTRAINT conversation_decisions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: conversations conversations_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_request_id_fkey FOREIGN KEY (request_id) REFERENCES public.chat_requests(id) ON DELETE CASCADE;


--
-- Name: conversations conversations_user_a_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_user_a_fkey FOREIGN KEY (user_a) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: conversations conversations_user_b_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_user_b_fkey FOREIGN KEY (user_b) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: criterion_option_phrasings criterion_option_phrasings_criterion_key_idx_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.criterion_option_phrasings
    ADD CONSTRAINT criterion_option_phrasings_criterion_key_idx_fkey FOREIGN KEY (criterion_key, idx) REFERENCES public.criterion_options(criterion_key, idx) ON DELETE CASCADE;


--
-- Name: criterion_options criterion_options_criterion_key_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.criterion_options
    ADD CONSTRAINT criterion_options_criterion_key_fkey FOREIGN KEY (criterion_key) REFERENCES public.criteria(key) ON DELETE CASCADE;


--
-- Name: criterion_pairs criterion_pairs_pref_key_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.criterion_pairs
    ADD CONSTRAINT criterion_pairs_pref_key_fkey FOREIGN KEY (pref_key) REFERENCES public.criteria(key);


--
-- Name: criterion_pairs criterion_pairs_self_key_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.criterion_pairs
    ADD CONSTRAINT criterion_pairs_self_key_fkey FOREIGN KEY (self_key) REFERENCES public.criteria(key);


--
-- Name: date_followups date_followups_date_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.date_followups
    ADD CONSTRAINT date_followups_date_id_fkey FOREIGN KEY (date_id) REFERENCES public.dates(id) ON DELETE CASCADE;


--
-- Name: date_followups date_followups_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.date_followups
    ADD CONSTRAINT date_followups_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: date_meeting_points date_meeting_points_date_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.date_meeting_points
    ADD CONSTRAINT date_meeting_points_date_id_fkey FOREIGN KEY (date_id) REFERENCES public.dates(id) ON DELETE CASCADE;


--
-- Name: date_meeting_points date_meeting_points_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.date_meeting_points
    ADD CONSTRAINT date_meeting_points_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: date_presence date_presence_date_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.date_presence
    ADD CONSTRAINT date_presence_date_id_fkey FOREIGN KEY (date_id) REFERENCES public.dates(id) ON DELETE CASCADE;


--
-- Name: date_presence date_presence_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.date_presence
    ADD CONSTRAINT date_presence_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: date_reviews date_reviews_date_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.date_reviews
    ADD CONSTRAINT date_reviews_date_id_fkey FOREIGN KEY (date_id) REFERENCES public.dates(id) ON DELETE CASCADE;


--
-- Name: date_reviews date_reviews_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.date_reviews
    ADD CONSTRAINT date_reviews_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: dates dates_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dates
    ADD CONSTRAINT dates_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON DELETE SET NULL;


--
-- Name: dates dates_ended_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dates
    ADD CONSTRAINT dates_ended_by_fkey FOREIGN KEY (ended_by) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- Name: dates dates_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dates
    ADD CONSTRAINT dates_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id);


--
-- Name: dates dates_user_a_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dates
    ADD CONSTRAINT dates_user_a_fkey FOREIGN KEY (user_a) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: dates dates_user_b_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dates
    ADD CONSTRAINT dates_user_b_fkey FOREIGN KEY (user_b) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: deletion_requests deletion_requests_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deletion_requests
    ADD CONSTRAINT deletion_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: focus_compatibilite focus_compatibilite_swipe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.focus_compatibilite
    ADD CONSTRAINT focus_compatibilite_swipe_id_fkey FOREIGN KEY (swipe_id) REFERENCES public.swipe_decisions(id) ON DELETE SET NULL;


--
-- Name: focus_compatibilite focus_compatibilite_target_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.focus_compatibilite
    ADD CONSTRAINT focus_compatibilite_target_partner_id_fkey FOREIGN KEY (target_partner_id) REFERENCES public.partners(id) ON DELETE SET NULL;


--
-- Name: focus_compatibilite focus_compatibilite_target_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.focus_compatibilite
    ADD CONSTRAINT focus_compatibilite_target_user_id_fkey FOREIGN KEY (target_user_id) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- Name: focus_compatibilite focus_compatibilite_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.focus_compatibilite
    ADD CONSTRAINT focus_compatibilite_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: help_requests help_requests_date_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_requests
    ADD CONSTRAINT help_requests_date_id_fkey FOREIGN KEY (date_id) REFERENCES public.dates(id) ON DELETE CASCADE;


--
-- Name: help_requests help_requests_fake_contact_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_requests
    ADD CONSTRAINT help_requests_fake_contact_id_fkey FOREIGN KEY (fake_contact_id) REFERENCES public.fake_contacts(id) ON DELETE SET NULL;


--
-- Name: help_requests help_requests_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_requests
    ADD CONSTRAINT help_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: help_staff_reports help_staff_reports_help_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_staff_reports
    ADD CONSTRAINT help_staff_reports_help_request_id_fkey FOREIGN KEY (help_request_id) REFERENCES public.help_requests(id) ON DELETE CASCADE;


--
-- Name: help_staff_reports help_staff_reports_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_staff_reports
    ADD CONSTRAINT help_staff_reports_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id) ON DELETE CASCADE;


--
-- Name: help_user_reports help_user_reports_help_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_user_reports
    ADD CONSTRAINT help_user_reports_help_request_id_fkey FOREIGN KEY (help_request_id) REFERENCES public.help_requests(id) ON DELETE CASCADE;


--
-- Name: help_user_reports help_user_reports_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_user_reports
    ADD CONSTRAINT help_user_reports_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: identity_verifications identity_verifications_photo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identity_verifications
    ADD CONSTRAINT identity_verifications_photo_id_fkey FOREIGN KEY (photo_id) REFERENCES public.user_photos(id) ON DELETE SET NULL;


--
-- Name: identity_verifications identity_verifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identity_verifications
    ADD CONSTRAINT identity_verifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: invoice_lines invoice_lines_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice_lines
    ADD CONSTRAINT invoice_lines_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(id) ON DELETE CASCADE;


--
-- Name: invoices invoices_date_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_date_id_fkey FOREIGN KEY (date_id) REFERENCES public.dates(id) ON DELETE CASCADE;


--
-- Name: invoices invoices_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id) ON DELETE CASCADE;


--
-- Name: invoices invoices_payment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES public.payments(id) ON DELETE SET NULL;


--
-- Name: invoices invoices_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- Name: messages messages_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON DELETE CASCADE;


--
-- Name: messages messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: moderation_actions moderation_actions_report_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_actions
    ADD CONSTRAINT moderation_actions_report_id_fkey FOREIGN KEY (report_id) REFERENCES public.reports(id) ON DELETE SET NULL;


--
-- Name: moderation_actions moderation_actions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_actions
    ADD CONSTRAINT moderation_actions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: option_mappings option_mappings_pair_key_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.option_mappings
    ADD CONSTRAINT option_mappings_pair_key_fkey FOREIGN KEY (pair_key) REFERENCES public.criterion_pairs(pair_key) ON DELETE CASCADE;


--
-- Name: option_mappings option_mappings_relative_criterion_key_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.option_mappings
    ADD CONSTRAINT option_mappings_relative_criterion_key_fkey FOREIGN KEY (relative_criterion_key) REFERENCES public.criteria(key);


--
-- Name: order_items order_items_menu_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_menu_item_id_fkey FOREIGN KEY (menu_item_id) REFERENCES public.partner_menu_items(id) ON DELETE SET NULL;


--
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: order_payments order_payments_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_payments
    ADD CONSTRAINT order_payments_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: order_payments order_payments_payment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_payments
    ADD CONSTRAINT order_payments_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES public.payments(id) ON DELETE CASCADE;


--
-- Name: orders orders_date_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_date_id_fkey FOREIGN KEY (date_id) REFERENCES public.dates(id) ON DELETE CASCADE;


--
-- Name: orders orders_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id) ON DELETE CASCADE;


--
-- Name: orders orders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: outstanding_debts outstanding_debts_date_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outstanding_debts
    ADD CONSTRAINT outstanding_debts_date_id_fkey FOREIGN KEY (date_id) REFERENCES public.dates(id) ON DELETE CASCADE;


--
-- Name: outstanding_debts outstanding_debts_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outstanding_debts
    ADD CONSTRAINT outstanding_debts_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id) ON DELETE CASCADE;


--
-- Name: outstanding_debts outstanding_debts_settlement_payment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outstanding_debts
    ADD CONSTRAINT outstanding_debts_settlement_payment_id_fkey FOREIGN KEY (settlement_payment_id) REFERENCES public.payments(id) ON DELETE SET NULL;


--
-- Name: outstanding_debts outstanding_debts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outstanding_debts
    ADD CONSTRAINT outstanding_debts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: partner_acceptances partner_acceptances_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_acceptances
    ADD CONSTRAINT partner_acceptances_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id) ON DELETE CASCADE;


--
-- Name: partner_acceptances partner_acceptances_policy_code_policy_version_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_acceptances
    ADD CONSTRAINT partner_acceptances_policy_code_policy_version_fkey FOREIGN KEY (policy_code, policy_version) REFERENCES public.policy_documents(code, version);


--
-- Name: partner_contracts partner_contracts_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_contracts
    ADD CONSTRAINT partner_contracts_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id) ON DELETE CASCADE;


--
-- Name: partner_documents partner_documents_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_documents
    ADD CONSTRAINT partner_documents_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id) ON DELETE CASCADE;


--
-- Name: partner_menu_categories partner_menu_categories_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_menu_categories
    ADD CONSTRAINT partner_menu_categories_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id) ON DELETE CASCADE;


--
-- Name: partner_menu_items partner_menu_items_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_menu_items
    ADD CONSTRAINT partner_menu_items_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.partner_menu_categories(id) ON DELETE SET NULL;


--
-- Name: partner_menu_items partner_menu_items_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_menu_items
    ADD CONSTRAINT partner_menu_items_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id) ON DELETE CASCADE;


--
-- Name: partner_payout_accounts partner_payout_accounts_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_payout_accounts
    ADD CONSTRAINT partner_payout_accounts_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id) ON DELETE CASCADE;


--
-- Name: partner_photos partner_photos_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_photos
    ADD CONSTRAINT partner_photos_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id) ON DELETE CASCADE;


--
-- Name: partner_postal_verifications partner_postal_verifications_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_postal_verifications
    ADD CONSTRAINT partner_postal_verifications_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id) ON DELETE CASCADE;


--
-- Name: partner_safe_zones partner_safe_zones_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_safe_zones
    ADD CONSTRAINT partner_safe_zones_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id) ON DELETE CASCADE;


--
-- Name: partner_settlements partner_settlements_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_settlements
    ADD CONSTRAINT partner_settlements_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id) ON DELETE CASCADE;


--
-- Name: partner_settlements partner_settlements_payment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_settlements
    ADD CONSTRAINT partner_settlements_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES public.payments(id) ON DELETE CASCADE;


--
-- Name: partner_step_completions partner_step_completions_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_step_completions
    ADD CONSTRAINT partner_step_completions_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id) ON DELETE CASCADE;


--
-- Name: partner_step_completions partner_step_completions_step_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_step_completions
    ADD CONSTRAINT partner_step_completions_step_fkey FOREIGN KEY (step) REFERENCES public.partner_steps(step);


--
-- Name: partner_training_completions partner_training_completions_module_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_training_completions
    ADD CONSTRAINT partner_training_completions_module_code_fkey FOREIGN KEY (module_code) REFERENCES public.training_modules(code);


--
-- Name: partner_training_completions partner_training_completions_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_training_completions
    ADD CONSTRAINT partner_training_completions_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id) ON DELETE CASCADE;


--
-- Name: partners partners_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partners
    ADD CONSTRAINT partners_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: payments payments_date_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_date_id_fkey FOREIGN KEY (date_id) REFERENCES public.dates(id) ON DELETE CASCADE;


--
-- Name: payments payments_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id) ON DELETE CASCADE;


--
-- Name: payments payments_payer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_payer_id_fkey FOREIGN KEY (payer_id) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- Name: platform_messages platform_messages_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.platform_messages
    ADD CONSTRAINT platform_messages_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: profile_answers profile_answers_criterion_key_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_answers
    ADD CONSTRAINT profile_answers_criterion_key_fkey FOREIGN KEY (criterion_key) REFERENCES public.criteria(key);


--
-- Name: profile_answers profile_answers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_answers
    ADD CONSTRAINT profile_answers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: profile_exclusions profile_exclusions_initiator_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_exclusions
    ADD CONSTRAINT profile_exclusions_initiator_fkey FOREIGN KEY (initiator) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: profile_exclusions profile_exclusions_source_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_exclusions
    ADD CONSTRAINT profile_exclusions_source_request_id_fkey FOREIGN KEY (source_request_id) REFERENCES public.chat_requests(id) ON DELETE SET NULL;


--
-- Name: profile_exclusions profile_exclusions_user_hi_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_exclusions
    ADD CONSTRAINT profile_exclusions_user_hi_fkey FOREIGN KEY (user_hi) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: profile_exclusions profile_exclusions_user_lo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_exclusions
    ADD CONSTRAINT profile_exclusions_user_lo_fkey FOREIGN KEY (user_lo) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: profile_presentations profile_presentations_observer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_presentations
    ADD CONSTRAINT profile_presentations_observer_id_fkey FOREIGN KEY (observer_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: profile_presentations profile_presentations_target_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_presentations
    ADD CONSTRAINT profile_presentations_target_id_fkey FOREIGN KEY (target_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: profile_vectors profile_vectors_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile_vectors
    ADD CONSTRAINT profile_vectors_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: profiles profiles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: quiz_answers quiz_answers_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quiz_answers
    ADD CONSTRAINT quiz_answers_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.quiz_questions(id) ON DELETE CASCADE;


--
-- Name: quiz_answers quiz_answers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quiz_answers
    ADD CONSTRAINT quiz_answers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: quiz_questions quiz_questions_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quiz_questions
    ADD CONSTRAINT quiz_questions_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.quiz_sessions(id) ON DELETE CASCADE;


--
-- Name: quiz_questions quiz_questions_source_pair_key_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quiz_questions
    ADD CONSTRAINT quiz_questions_source_pair_key_fkey FOREIGN KEY (source_pair_key) REFERENCES public.criterion_pairs(pair_key) ON DELETE SET NULL;


--
-- Name: quiz_sessions quiz_sessions_date_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quiz_sessions
    ADD CONSTRAINT quiz_sessions_date_id_fkey FOREIGN KEY (date_id) REFERENCES public.dates(id) ON DELETE CASCADE;


--
-- Name: reports reports_reported_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_reported_id_fkey FOREIGN KEY (reported_id) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: reports reports_reporter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_reporter_id_fkey FOREIGN KEY (reporter_id) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: surprise_cooldowns surprise_cooldowns_from_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.surprise_cooldowns
    ADD CONSTRAINT surprise_cooldowns_from_user_fkey FOREIGN KEY (from_user) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: surprise_cooldowns surprise_cooldowns_to_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.surprise_cooldowns
    ADD CONSTRAINT surprise_cooldowns_to_user_fkey FOREIGN KEY (to_user) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: surprise_proposals surprise_proposals_from_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.surprise_proposals
    ADD CONSTRAINT surprise_proposals_from_user_fkey FOREIGN KEY (from_user) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: surprise_proposals surprise_proposals_previous_date_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.surprise_proposals
    ADD CONSTRAINT surprise_proposals_previous_date_id_fkey FOREIGN KEY (previous_date_id) REFERENCES public.dates(id) ON DELETE SET NULL;


--
-- Name: surprise_proposals surprise_proposals_to_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.surprise_proposals
    ADD CONSTRAINT surprise_proposals_to_user_fkey FOREIGN KEY (to_user) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: swipe_decisions swipe_decisions_presentation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.swipe_decisions
    ADD CONSTRAINT swipe_decisions_presentation_id_fkey FOREIGN KEY (presentation_id) REFERENCES public.profile_presentations(id) ON DELETE SET NULL;


--
-- Name: swipe_decisions swipe_decisions_target_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.swipe_decisions
    ADD CONSTRAINT swipe_decisions_target_id_fkey FOREIGN KEY (target_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: swipe_decisions swipe_decisions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.swipe_decisions
    ADD CONSTRAINT swipe_decisions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: swipe_ecrans swipe_ecrans_swipe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.swipe_ecrans
    ADD CONSTRAINT swipe_ecrans_swipe_id_fkey FOREIGN KEY (swipe_id) REFERENCES public.swipe_decisions(id) ON DELETE CASCADE;


--
-- Name: user_acceptances user_acceptances_policy_code_policy_version_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_acceptances
    ADD CONSTRAINT user_acceptances_policy_code_policy_version_fkey FOREIGN KEY (policy_code, policy_version) REFERENCES public.policy_documents(code, version);


--
-- Name: user_acceptances user_acceptances_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_acceptances
    ADD CONSTRAINT user_acceptances_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: user_context_weights user_context_weights_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_context_weights
    ADD CONSTRAINT user_context_weights_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: user_criterion_learning user_criterion_learning_pair_key_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_criterion_learning
    ADD CONSTRAINT user_criterion_learning_pair_key_fkey FOREIGN KEY (pair_key) REFERENCES public.criterion_pairs(pair_key) ON DELETE CASCADE;


--
-- Name: user_criterion_learning user_criterion_learning_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_criterion_learning
    ADD CONSTRAINT user_criterion_learning_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: user_criterion_priorities user_criterion_priorities_pair_key_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_criterion_priorities
    ADD CONSTRAINT user_criterion_priorities_pair_key_fkey FOREIGN KEY (pair_key) REFERENCES public.criterion_pairs(pair_key) ON DELETE CASCADE;


--
-- Name: user_criterion_priorities user_criterion_priorities_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_criterion_priorities
    ADD CONSTRAINT user_criterion_priorities_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: user_criterion_profile user_criterion_profile_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_criterion_profile
    ADD CONSTRAINT user_criterion_profile_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: user_knowledge_history user_knowledge_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_knowledge_history
    ADD CONSTRAINT user_knowledge_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: user_option_outcome user_option_outcome_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_option_outcome
    ADD CONSTRAINT user_option_outcome_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: user_option_stats user_option_stats_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_option_stats
    ADD CONSTRAINT user_option_stats_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: user_payment_methods user_payment_methods_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_payment_methods
    ADD CONSTRAINT user_payment_methods_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: user_photos user_photos_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_photos
    ADD CONSTRAINT user_photos_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: user_step_completions user_step_completions_step_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_step_completions
    ADD CONSTRAINT user_step_completions_step_fkey FOREIGN KEY (step) REFERENCES public.user_steps(step);


--
-- Name: user_step_completions user_step_completions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_step_completions
    ADD CONSTRAINT user_step_completions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: user_verification_codes user_verification_codes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_verification_codes
    ADD CONSTRAINT user_verification_codes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: venue_proposals venue_proposals_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.venue_proposals
    ADD CONSTRAINT venue_proposals_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON DELETE CASCADE;


--
-- Name: venue_proposals venue_proposals_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.venue_proposals
    ADD CONSTRAINT venue_proposals_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id) ON DELETE CASCADE;


--
-- Name: venue_reviews venue_reviews_date_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.venue_reviews
    ADD CONSTRAINT venue_reviews_date_id_fkey FOREIGN KEY (date_id) REFERENCES public.dates(id) ON DELETE CASCADE;


--
-- Name: venue_reviews venue_reviews_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.venue_reviews
    ADD CONSTRAINT venue_reviews_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id) ON DELETE CASCADE;


--
-- Name: venue_reviews venue_reviews_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.venue_reviews
    ADD CONSTRAINT venue_reviews_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: venue_votes venue_votes_proposal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.venue_votes
    ADD CONSTRAINT venue_votes_proposal_id_fkey FOREIGN KEY (proposal_id) REFERENCES public.venue_proposals(id) ON DELETE CASCADE;


--
-- Name: venue_votes venue_votes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.venue_votes
    ADD CONSTRAINT venue_votes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: compat_cache; Type: ROW SECURITY; Schema: private; Owner: -
--

ALTER TABLE private.compat_cache ENABLE ROW LEVEL SECURITY;

--
-- Name: availability_windows; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.availability_windows ENABLE ROW LEVEL SECURITY;

--
-- Name: blocks; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.blocks ENABLE ROW LEVEL SECURITY;

--
-- Name: chat_requests; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.chat_requests ENABLE ROW LEVEL SECURITY;

--
-- Name: consents; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.consents ENABLE ROW LEVEL SECURITY;

--
-- Name: conversation_decisions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.conversation_decisions ENABLE ROW LEVEL SECURITY;

--
-- Name: conversations; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;

--
-- Name: criteria; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.criteria ENABLE ROW LEVEL SECURITY;

--
-- Name: criterion_option_phrasings; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.criterion_option_phrasings ENABLE ROW LEVEL SECURITY;

--
-- Name: criterion_options; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.criterion_options ENABLE ROW LEVEL SECURITY;

--
-- Name: criterion_pairs; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.criterion_pairs ENABLE ROW LEVEL SECURITY;

--
-- Name: date_followups; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.date_followups ENABLE ROW LEVEL SECURITY;

--
-- Name: date_meeting_points; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.date_meeting_points ENABLE ROW LEVEL SECURITY;

--
-- Name: date_presence; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.date_presence ENABLE ROW LEVEL SECURITY;

--
-- Name: date_reviews; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.date_reviews ENABLE ROW LEVEL SECURITY;

--
-- Name: dates; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.dates ENABLE ROW LEVEL SECURITY;

--
-- Name: deletion_requests; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.deletion_requests ENABLE ROW LEVEL SECURITY;

--
-- Name: engine_params; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.engine_params ENABLE ROW LEVEL SECURITY;

--
-- Name: fake_contacts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.fake_contacts ENABLE ROW LEVEL SECURITY;

--
-- Name: focus_compatibilite; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.focus_compatibilite ENABLE ROW LEVEL SECURITY;

--
-- Name: grille_import_v1; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.grille_import_v1 ENABLE ROW LEVEL SECURITY;

--
-- Name: help_requests; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.help_requests ENABLE ROW LEVEL SECURITY;

--
-- Name: help_staff_reports; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.help_staff_reports ENABLE ROW LEVEL SECURITY;

--
-- Name: help_user_reports; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.help_user_reports ENABLE ROW LEVEL SECURITY;

--
-- Name: identity_verifications; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.identity_verifications ENABLE ROW LEVEL SECURITY;

--
-- Name: invoice_lines; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.invoice_lines ENABLE ROW LEVEL SECURITY;

--
-- Name: invoices; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;

--
-- Name: menu_stopwords; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.menu_stopwords ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: moderation_actions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.moderation_actions ENABLE ROW LEVEL SECURITY;

--
-- Name: option_mappings; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.option_mappings ENABLE ROW LEVEL SECURITY;

--
-- Name: order_items; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

--
-- Name: order_payments; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.order_payments ENABLE ROW LEVEL SECURITY;

--
-- Name: orders; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

--
-- Name: outstanding_debts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.outstanding_debts ENABLE ROW LEVEL SECURITY;

--
-- Name: partner_acceptances p_accept_owner; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_accept_owner ON public.partner_acceptances USING ((partner_id IN ( SELECT partners.id
   FROM public.partners
  WHERE (partners.owner_id = auth.uid())))) WITH CHECK ((partner_id IN ( SELECT partners.id
   FROM public.partners
  WHERE (partners.owner_id = auth.uid()))));


--
-- Name: user_acceptances p_accept_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_accept_self ON public.user_acceptances USING ((user_id = auth.uid())) WITH CHECK ((user_id = auth.uid()));


--
-- Name: profile_answers p_answers_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_answers_self ON public.profile_answers FOR SELECT USING ((user_id = auth.uid()));


--
-- Name: availability_windows p_avail_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_avail_self ON public.availability_windows USING ((user_id = auth.uid())) WITH CHECK ((user_id = auth.uid()));


--
-- Name: blocks p_blocks_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_blocks_self ON public.blocks USING ((blocker_id = auth.uid())) WITH CHECK ((blocker_id = auth.uid()));


--
-- Name: partner_menu_categories p_cat_owner; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_cat_owner ON public.partner_menu_categories USING ((partner_id IN ( SELECT partners.id
   FROM public.partners
  WHERE (partners.owner_id = auth.uid())))) WITH CHECK ((partner_id IN ( SELECT partners.id
   FROM public.partners
  WHERE (partners.owner_id = auth.uid()))));


--
-- Name: chat_requests p_chatreq_envoi; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_chatreq_envoi ON public.chat_requests FOR INSERT WITH CHECK ((from_user = auth.uid()));


--
-- Name: chat_requests p_chatreq_partie; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_chatreq_partie ON public.chat_requests FOR SELECT USING (((from_user = auth.uid()) OR (to_user = auth.uid())));


--
-- Name: consents p_consents_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_consents_self ON public.consents USING ((user_id = auth.uid())) WITH CHECK ((user_id = auth.uid()));


--
-- Name: partner_contracts p_contrat_owner; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_contrat_owner ON public.partner_contracts FOR SELECT USING ((partner_id IN ( SELECT partners.id
   FROM public.partners
  WHERE (partners.owner_id = auth.uid()))));


--
-- Name: conversations p_conv_partie; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_conv_partie ON public.conversations FOR SELECT USING (((user_a = auth.uid()) OR (user_b = auth.uid())));


--
-- Name: conversation_decisions p_convdec_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_convdec_self ON public.conversation_decisions USING ((user_id = auth.uid())) WITH CHECK ((user_id = auth.uid()));


--
-- Name: surprise_cooldowns p_cooldown_emetteur; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_cooldown_emetteur ON public.surprise_cooldowns FOR SELECT USING ((from_user = auth.uid()));


--
-- Name: date_reviews p_daterev_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_daterev_self ON public.date_reviews USING ((user_id = auth.uid())) WITH CHECK ((user_id = auth.uid()));


--
-- Name: dates p_dates_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_dates_self ON public.dates FOR SELECT USING (((user_a = auth.uid()) OR (user_b = auth.uid())));


--
-- Name: outstanding_debts p_debts_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_debts_self ON public.outstanding_debts FOR SELECT USING ((user_id = auth.uid()));


--
-- Name: deletion_requests p_deletion_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_deletion_self ON public.deletion_requests USING ((user_id = auth.uid())) WITH CHECK ((user_id = auth.uid()));


--
-- Name: partner_documents p_docs_owner; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_docs_owner ON public.partner_documents USING ((partner_id IN ( SELECT partners.id
   FROM public.partners
  WHERE (partners.owner_id = auth.uid())))) WITH CHECK ((partner_id IN ( SELECT partners.id
   FROM public.partners
  WHERE (partners.owner_id = auth.uid()))));


--
-- Name: fake_contacts p_fakecontacts_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_fakecontacts_read ON public.fake_contacts FOR SELECT USING (active);


--
-- Name: focus_compatibilite p_focus_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_focus_self ON public.focus_compatibilite USING ((user_id = auth.uid())) WITH CHECK ((user_id = auth.uid()));


--
-- Name: date_followups p_followup_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_followup_self ON public.date_followups USING ((user_id = auth.uid())) WITH CHECK ((user_id = auth.uid()));


--
-- Name: help_requests p_help_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_help_self ON public.help_requests USING ((user_id = auth.uid())) WITH CHECK ((user_id = auth.uid()));


--
-- Name: help_staff_reports p_helpstaffrep_partenaire; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_helpstaffrep_partenaire ON public.help_staff_reports USING ((partner_id IN ( SELECT partners.id
   FROM public.partners
  WHERE (partners.owner_id = auth.uid())))) WITH CHECK ((partner_id IN ( SELECT partners.id
   FROM public.partners
  WHERE (partners.owner_id = auth.uid()))));


--
-- Name: help_user_reports p_helpuserrep_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_helpuserrep_self ON public.help_user_reports USING ((user_id = auth.uid())) WITH CHECK ((user_id = auth.uid()));


--
-- Name: identity_verifications p_idv_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_idv_self ON public.identity_verifications FOR SELECT USING ((user_id = auth.uid()));


--
-- Name: invoice_lines p_invlines_lisible; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_invlines_lisible ON public.invoice_lines FOR SELECT USING ((invoice_id IN ( SELECT invoices.id
   FROM public.invoices
  WHERE (invoices.user_id = auth.uid())
UNION
 SELECT i.id
   FROM (public.invoices i
     JOIN public.partners p ON ((p.id = i.partner_id)))
  WHERE (p.owner_id = auth.uid()))));


--
-- Name: invoices p_invoices_partenaire; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_invoices_partenaire ON public.invoices FOR SELECT USING ((partner_id IN ( SELECT partners.id
   FROM public.partners
  WHERE (partners.owner_id = auth.uid()))));


--
-- Name: invoices p_invoices_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_invoices_self ON public.invoices FOR SELECT USING ((user_id = auth.uid()));


--
-- Name: user_criterion_learning p_learning_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_learning_self ON public.user_criterion_learning FOR SELECT USING ((user_id = auth.uid()));


--
-- Name: partner_menu_items p_menu_owner; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_menu_owner ON public.partner_menu_items USING ((partner_id IN ( SELECT partners.id
   FROM public.partners
  WHERE (partners.owner_id = auth.uid())))) WITH CHECK ((partner_id IN ( SELECT partners.id
   FROM public.partners
  WHERE (partners.owner_id = auth.uid()))));


--
-- Name: moderation_actions p_moderation_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_moderation_self ON public.moderation_actions FOR SELECT USING (((user_id = auth.uid()) AND (action <> 'classe_sans_suite'::public.moderation_action)));


--
-- Name: date_meeting_points p_mp_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_mp_self ON public.date_meeting_points FOR SELECT USING ((user_id = auth.uid()));


--
-- Name: messages p_msg_envoi; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_msg_envoi ON public.messages FOR INSERT WITH CHECK (((sender_id = auth.uid()) AND (conversation_id IN ( SELECT conversations.id
   FROM public.conversations
  WHERE ((conversations.user_a = auth.uid()) OR (conversations.user_b = auth.uid()))))));


--
-- Name: messages p_msg_partie; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_msg_partie ON public.messages FOR SELECT USING ((conversation_id IN ( SELECT conversations.id
   FROM public.conversations
  WHERE ((conversations.user_a = auth.uid()) OR (conversations.user_b = auth.uid())))));


--
-- Name: criterion_options p_opt_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_opt_read ON public.criterion_options FOR SELECT TO authenticated USING (true);


--
-- Name: order_items p_orderitems_partenaire; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_orderitems_partenaire ON public.order_items FOR SELECT USING ((order_id IN ( SELECT o.id
   FROM (public.orders o
     JOIN public.partners p ON ((p.id = o.partner_id)))
  WHERE (p.owner_id = auth.uid()))));


--
-- Name: order_items p_orderitems_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_orderitems_self ON public.order_items USING ((order_id IN ( SELECT orders.id
   FROM public.orders
  WHERE (orders.user_id = auth.uid())))) WITH CHECK ((order_id IN ( SELECT orders.id
   FROM public.orders
  WHERE (orders.user_id = auth.uid()))));


--
-- Name: order_payments p_orderpay_lisible; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_orderpay_lisible ON public.order_payments FOR SELECT USING (((order_id IN ( SELECT orders.id
   FROM public.orders
  WHERE (orders.user_id = auth.uid()))) OR (order_id IN ( SELECT o.id
   FROM (public.orders o
     JOIN public.partners p ON ((p.id = o.partner_id)))
  WHERE (p.owner_id = auth.uid())))));


--
-- Name: orders p_orders_partenaire; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_orders_partenaire ON public.orders FOR SELECT USING ((partner_id IN ( SELECT partners.id
   FROM public.partners
  WHERE (partners.owner_id = auth.uid()))));


--
-- Name: orders p_orders_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_orders_self ON public.orders USING ((user_id = auth.uid())) WITH CHECK ((user_id = auth.uid()));


--
-- Name: criterion_pairs p_pair_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_pair_read ON public.criterion_pairs FOR SELECT TO authenticated USING (true);


--
-- Name: partners p_partners_owner; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_partners_owner ON public.partners USING ((owner_id = auth.uid())) WITH CHECK ((owner_id = auth.uid()));


--
-- Name: payments p_payments_partenaire; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_payments_partenaire ON public.payments FOR SELECT USING ((partner_id IN ( SELECT partners.id
   FROM public.partners
  WHERE (partners.owner_id = auth.uid()))));


--
-- Name: payments p_payments_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_payments_self ON public.payments FOR SELECT USING ((payer_id = auth.uid()));


--
-- Name: partner_payout_accounts p_payout_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_payout_read ON public.partner_payout_accounts FOR SELECT USING ((partner_id IN ( SELECT partners.id
   FROM public.partners
  WHERE (partners.owner_id = auth.uid()))));


--
-- Name: partner_photos p_photos_owner; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_photos_owner ON public.partner_photos USING ((partner_id IN ( SELECT partners.id
   FROM public.partners
  WHERE (partners.owner_id = auth.uid())))) WITH CHECK ((partner_id IN ( SELECT partners.id
   FROM public.partners
  WHERE (partners.owner_id = auth.uid()))));


--
-- Name: user_photos p_photos_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_photos_self ON public.user_photos USING ((user_id = auth.uid())) WITH CHECK ((user_id = auth.uid()));


--
-- Name: criterion_option_phrasings p_phrasings_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_phrasings_read ON public.criterion_option_phrasings FOR SELECT USING (true);


--
-- Name: platform_messages p_platform_msg_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_platform_msg_self ON public.platform_messages FOR SELECT USING (((user_id = auth.uid()) AND (envoye_at IS NOT NULL)));


--
-- Name: user_payment_methods p_pm_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_pm_self ON public.user_payment_methods USING ((user_id = auth.uid())) WITH CHECK ((user_id = auth.uid()));


--
-- Name: policy_documents p_policies_public; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_policies_public ON public.policy_documents FOR SELECT TO authenticated, anon USING (true);


--
-- Name: date_presence p_presence_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_presence_self ON public.date_presence FOR SELECT USING ((user_id = auth.uid()));


--
-- Name: user_criterion_priorities p_prio_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_prio_self ON public.user_criterion_priorities FOR SELECT USING ((user_id = auth.uid()));


--
-- Name: profiles p_profiles_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_profiles_self ON public.profiles USING ((id = auth.uid())) WITH CHECK ((id = auth.uid()));


--
-- Name: partner_steps p_psteps_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_psteps_read ON public.partner_steps FOR SELECT USING (true);


--
-- Name: quiz_answers p_quizans_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_quizans_self ON public.quiz_answers USING ((user_id = auth.uid())) WITH CHECK ((user_id = auth.uid()));


--
-- Name: quiz_questions p_quizq_partie; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_quizq_partie ON public.quiz_questions FOR SELECT USING ((session_id IN ( SELECT s.id
   FROM (public.quiz_sessions s
     JOIN public.dates d ON ((d.id = s.date_id)))
  WHERE ((d.user_a = auth.uid()) OR (d.user_b = auth.uid())))));


--
-- Name: quiz_sessions p_quizsess_partie; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_quizsess_partie ON public.quiz_sessions FOR SELECT USING ((date_id IN ( SELECT dates.id
   FROM public.dates
  WHERE ((dates.user_a = auth.uid()) OR (dates.user_b = auth.uid())))));


--
-- Name: criteria p_ref_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_ref_read ON public.criteria FOR SELECT TO authenticated USING (true);


--
-- Name: reports p_reports_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_reports_insert ON public.reports FOR INSERT WITH CHECK ((reporter_id = auth.uid()));


--
-- Name: partner_settlements p_settle_partenaire; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_settle_partenaire ON public.partner_settlements FOR SELECT USING ((partner_id IN ( SELECT partners.id
   FROM public.partners
  WHERE (partners.owner_id = auth.uid()))));


--
-- Name: partner_step_completions p_steps_owner; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_steps_owner ON public.partner_step_completions USING ((partner_id IN ( SELECT partners.id
   FROM public.partners
  WHERE (partners.owner_id = auth.uid())))) WITH CHECK ((partner_id IN ( SELECT partners.id
   FROM public.partners
  WHERE (partners.owner_id = auth.uid()))));


--
-- Name: user_step_completions p_steps_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_steps_self ON public.user_step_completions FOR SELECT USING ((user_id = auth.uid()));


--
-- Name: surprise_proposals p_surprise_envoi; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_surprise_envoi ON public.surprise_proposals FOR INSERT WITH CHECK ((from_user = auth.uid()));


--
-- Name: surprise_proposals p_surprise_partie; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_surprise_partie ON public.surprise_proposals FOR SELECT USING (((from_user = auth.uid()) OR (to_user = auth.uid())));


--
-- Name: swipe_decisions p_swipe_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_swipe_self ON public.swipe_decisions USING ((user_id = auth.uid())) WITH CHECK ((user_id = auth.uid()));


--
-- Name: partner_training_completions p_training_owner; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_training_owner ON public.partner_training_completions USING ((partner_id IN ( SELECT partners.id
   FROM public.partners
  WHERE (partners.owner_id = auth.uid())))) WITH CHECK ((partner_id IN ( SELECT partners.id
   FROM public.partners
  WHERE (partners.owner_id = auth.uid()))));


--
-- Name: training_modules p_training_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_training_read ON public.training_modules FOR SELECT USING (true);


--
-- Name: user_steps p_usteps_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_usteps_read ON public.user_steps FOR SELECT USING (true);


--
-- Name: profile_vectors p_vectors_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_vectors_self ON public.profile_vectors FOR SELECT USING ((user_id = auth.uid()));


--
-- Name: venue_proposals p_venueprop_partie; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_venueprop_partie ON public.venue_proposals FOR SELECT USING ((conversation_id IN ( SELECT conversations.id
   FROM public.conversations
  WHERE ((conversations.user_a = auth.uid()) OR (conversations.user_b = auth.uid())))));


--
-- Name: venue_reviews p_venuerev_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_venuerev_self ON public.venue_reviews USING ((user_id = auth.uid())) WITH CHECK ((user_id = auth.uid()));


--
-- Name: venue_votes p_venuevote_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_venuevote_self ON public.venue_votes USING ((user_id = auth.uid())) WITH CHECK ((user_id = auth.uid()));


--
-- Name: partner_safe_zones p_zones_owner; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY p_zones_owner ON public.partner_safe_zones USING ((partner_id IN ( SELECT partners.id
   FROM public.partners
  WHERE (partners.owner_id = auth.uid())))) WITH CHECK ((partner_id IN ( SELECT partners.id
   FROM public.partners
  WHERE (partners.owner_id = auth.uid()))));


--
-- Name: partner_acceptances; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.partner_acceptances ENABLE ROW LEVEL SECURITY;

--
-- Name: partner_contracts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.partner_contracts ENABLE ROW LEVEL SECURITY;

--
-- Name: partner_documents; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.partner_documents ENABLE ROW LEVEL SECURITY;

--
-- Name: partner_menu_categories; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.partner_menu_categories ENABLE ROW LEVEL SECURITY;

--
-- Name: partner_menu_items; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.partner_menu_items ENABLE ROW LEVEL SECURITY;

--
-- Name: partner_payout_accounts; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.partner_payout_accounts ENABLE ROW LEVEL SECURITY;

--
-- Name: partner_photos; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.partner_photos ENABLE ROW LEVEL SECURITY;

--
-- Name: partner_postal_verifications; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.partner_postal_verifications ENABLE ROW LEVEL SECURITY;

--
-- Name: partner_safe_zones; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.partner_safe_zones ENABLE ROW LEVEL SECURITY;

--
-- Name: partner_settlements; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.partner_settlements ENABLE ROW LEVEL SECURITY;

--
-- Name: partner_step_completions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.partner_step_completions ENABLE ROW LEVEL SECURITY;

--
-- Name: partner_steps; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.partner_steps ENABLE ROW LEVEL SECURITY;

--
-- Name: partner_training_completions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.partner_training_completions ENABLE ROW LEVEL SECURITY;

--
-- Name: partners; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.partners ENABLE ROW LEVEL SECURITY;

--
-- Name: payments; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

--
-- Name: platform_messages; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.platform_messages ENABLE ROW LEVEL SECURITY;

--
-- Name: policy_documents; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.policy_documents ENABLE ROW LEVEL SECURITY;

--
-- Name: profile_answers; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.profile_answers ENABLE ROW LEVEL SECURITY;

--
-- Name: profile_exclusions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.profile_exclusions ENABLE ROW LEVEL SECURITY;

--
-- Name: profile_presentations; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.profile_presentations ENABLE ROW LEVEL SECURITY;

--
-- Name: profile_vectors; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.profile_vectors ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

--
-- Name: quiz_answers; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.quiz_answers ENABLE ROW LEVEL SECURITY;

--
-- Name: quiz_questions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.quiz_questions ENABLE ROW LEVEL SECURITY;

--
-- Name: quiz_sessions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.quiz_sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: reports; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

--
-- Name: sensitive_access_log; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.sensitive_access_log ENABLE ROW LEVEL SECURITY;

--
-- Name: surprise_cooldowns; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.surprise_cooldowns ENABLE ROW LEVEL SECURITY;

--
-- Name: surprise_proposals; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.surprise_proposals ENABLE ROW LEVEL SECURITY;

--
-- Name: swipe_decisions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.swipe_decisions ENABLE ROW LEVEL SECURITY;

--
-- Name: swipe_ecrans; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.swipe_ecrans ENABLE ROW LEVEL SECURITY;

--
-- Name: training_modules; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.training_modules ENABLE ROW LEVEL SECURITY;

--
-- Name: user_acceptances; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_acceptances ENABLE ROW LEVEL SECURITY;

--
-- Name: user_context_weights; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_context_weights ENABLE ROW LEVEL SECURITY;

--
-- Name: user_criterion_learning; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_criterion_learning ENABLE ROW LEVEL SECURITY;

--
-- Name: user_criterion_priorities; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_criterion_priorities ENABLE ROW LEVEL SECURITY;

--
-- Name: user_criterion_profile; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_criterion_profile ENABLE ROW LEVEL SECURITY;

--
-- Name: user_knowledge_history; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_knowledge_history ENABLE ROW LEVEL SECURITY;

--
-- Name: user_option_outcome; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_option_outcome ENABLE ROW LEVEL SECURITY;

--
-- Name: user_option_stats; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_option_stats ENABLE ROW LEVEL SECURITY;

--
-- Name: user_payment_methods; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_payment_methods ENABLE ROW LEVEL SECURITY;

--
-- Name: user_photos; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_photos ENABLE ROW LEVEL SECURITY;

--
-- Name: user_step_completions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_step_completions ENABLE ROW LEVEL SECURITY;

--
-- Name: user_steps; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_steps ENABLE ROW LEVEL SECURITY;

--
-- Name: user_verification_codes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.user_verification_codes ENABLE ROW LEVEL SECURITY;

--
-- Name: venue_proposals; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.venue_proposals ENABLE ROW LEVEL SECURITY;

--
-- Name: venue_reviews; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.venue_reviews ENABLE ROW LEVEL SECURITY;

--
-- Name: venue_votes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.venue_votes ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--

\unrestrict 9ouVU5pfwuQXK32u74taG1qPWpjxh9cfoTNKepfhuNjsRipLigfMeLIbhZdbl28

