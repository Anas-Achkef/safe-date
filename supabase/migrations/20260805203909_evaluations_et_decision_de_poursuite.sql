-- Une conversation rouverte apres un rendez-vous n'est plus chronometree.
alter table conversations add column illimitee boolean not null default false;

create or replace function private.verrouiller_conversations()
returns integer language plpgsql as $fn$
declare n integer;
begin
  update conversations
     set status = 'verrouillee', locked_at = now()
   where status = 'active' and not illimitee and ends_at <= now();
  get diagnostics n = row_count;
  return n;
end $fn$;

-- ---------- Evaluation de l'etablissement ----------
-- Proposee des la sortie, sans attendre l'eloignement : elle porte sur
-- le lieu, pas sur la rencontre.

create or replace function private.evaluer_etablissement(
  u uuid, d_id uuid, p_produits smallint, p_rapport_qp smallint, p_service smallint,
  p_globale numeric default null, p_commentaire text default null,
  p_publier_google boolean default false)
returns numeric language plpgsql as $fn$
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
end $fn$;

create or replace function private.reporter_evaluation_etablissement(u uuid, d_id uuid, p_status review_status)
returns void language plpgsql as $fn$
begin
  insert into venue_reviews (date_id, user_id, partner_id, status)
  select d_id, u, d.partner_id, p_status from dates d
   where d.id = d_id and (d.user_a = u or d.user_b = u)
  on conflict (date_id, user_id) do update set status = excluded.status;
end $fn$;
comment on function private.reporter_evaluation_etablissement is
  'Choix « Plus tard » ou « Passer ». Passer n''entraine aucune relance ; plus tard autorise un unique rappel en messagerie.';

-- ---------- Evaluation de la rencontre ----------

create or replace function private.evaluer_rencontre(
  u uuid, d_id uuid, p_attirance smallint, p_valeurs smallint,
  p_mode_vie smallint, p_commentaire text default null)
returns void language plpgsql as $fn$
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
end $fn$;
comment on function private.evaluer_rencontre is
  'Strictement confidentiel : jamais communique au partenaire. Le declencheur date_reviews_apprentissage exploite les trois notes, chacune sur sa dimension.';

-- ---------- Decision de poursuite ----------

create or replace function private.decider_poursuite(u uuid, d_id uuid, p_decision date_intent)
returns jsonb language plpgsql as $fn$
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
end $fn$;

comment on function private.decider_poursuite is
  'Le choix de l''autre n''est jamais revele avant que les deux reponses soient enregistrees, et en cas de divergence on ne revele jamais lequel des deux a decline. notifier_en_differe designe l''utilisateur a prevenir quelques instants plus tard en messagerie.';;
