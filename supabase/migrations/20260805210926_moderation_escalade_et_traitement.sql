-- ---------- Graduation de la sanction ----------
-- La mesure proposee depend de l'historique de l'utilisateur, pas du
-- seul signalement en cours. Les mesures classees sans suite ne comptent pas.

create or replace function private.escalade_recommandee(u uuid, p_motif report_reason default null)
returns moderation_action language plpgsql stable as $fn$
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
end $fn$;

comment on function private.escalade_recommandee is
  'Mesure proposee au moderateur. La suspicion de minorite ou de violence court-circuite la graduation et appelle une mesure immediate.';

-- ---------- Traitement d'un signalement ----------

create or replace function private.traiter_signalement(
  p_report uuid, p_action moderation_action, p_motif text default null,
  p_moderateur uuid default null)
returns jsonb language plpgsql as $fn$
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
end $fn$;

-- ---------- File de moderation ----------

create or replace view private.v_file_moderation as
  select r.id as report_id, r.created_at, r.reason, r.details,
         r.reported_id, p.prenom,
         (select count(*) from reports r2
          where r2.reported_id = r.reported_id and r2.status in ('nouveau','en_cours')) as signalements_ouverts,
         (select count(*) from moderation_actions m
          where m.user_id = r.reported_id and m.action <> 'classe_sans_suite') as mesures_anterieures,
         (select max(s.dangerosite) from help_staff_reports s
          join help_requests h on h.id = s.help_request_id
          join dates d on d.id = h.date_id
          where (d.user_a = r.reported_id or d.user_b = r.reported_id)
            and h.user_id <> r.reported_id) as dangerosite_max,
         private.escalade_recommandee(r.reported_id, r.reason) as mesure_recommandee
  from reports r
  join profiles p on p.id = r.reported_id
  where r.status in ('nouveau','en_cours')
  order by
    case when r.reason in ('mineur','violence') then 0 else 1 end,
    r.created_at;

comment on view private.v_file_moderation is
  'File de traitement priorisee. Les motifs de minorite et de violence remontent en tete, avant l''anciennete. Chaque ligne porte l''historique de l''utilisateur et la mesure recommandee.';

-- ---------- Levee automatique des suspensions ----------

create or replace function private.lever_suspensions()
returns integer language plpgsql as $fn$
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
end $fn$;

create or replace function private.envoyer_messages_plateforme()
returns integer language plpgsql as $fn$
declare n integer;
begin
  update platform_messages set envoye_at = now()
   where envoye_at is null and a_envoyer_a <= now();
  get diagnostics n = row_count;
  return n;
end $fn$;

create or replace function private.maintenance_periodique()
returns jsonb language plpgsql as $fn$
begin
  return jsonb_build_object(
    'demandes_expirees',          private.expirer_demandes(),
    'conversations_verrouillees', private.verrouiller_conversations(),
    'cooldowns_purges',           private.purger_cooldowns(),
    'points_rdv_expires',         (select expirer_points_rendezvous()),
    'suspensions_levees',         private.lever_suspensions(),
    'messages_envoyes',           private.envoyer_messages_plateforme(),
    'execute_a',                  now());
end $fn$;;
