-- ============================================================
-- Regles de communication.
-- Avant le rendez-vous : texte et vocal uniquement, et aucun contenu
-- permettant de quitter l'ecosysteme Safe Date. Apres le rendez-vous,
-- si les deux ont souhaite poursuivre, la conversation s'ouvre.
-- ============================================================

alter table messages drop constraint if exists message_contenu;
alter table messages add constraint message_contenu check (
  (kind = 'texte' and body is not null) or
  (kind = 'vocal' and audio_path is not null) or
  (kind = 'photo' and audio_path is not null)
);
comment on column messages.audio_path is
  'Chemin de stockage du media : enregistrement vocal ou photographie selon le type de message.';

-- Detection des tentatives de sortie de plateforme. Renvoie le motif
-- detecte, ou NULL si le message est acceptable.
create or replace function private.motif_interdit(t text)
returns text language sql immutable as
$fn$
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
$fn$;

comment on function private.motif_interdit is
  'Controle serveur des regles de communication d''avant rendez-vous. Le filtrage cote application ne suffit pas : il peut etre contourne.';

-- ---------- Envoi d'un message ----------

create or replace function private.envoyer_message(
  u uuid, conv uuid, p_kind message_kind default 'texte',
  p_body text default null, p_media text default null, p_duree integer default null)
returns uuid language plpgsql as $fn$
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
end $fn$;

-- ---------- Onglet « L'autre » ----------
-- Informations publiques uniquement. Ni les reponses au questionnaire,
-- ni les evaluations, ni les coordonnees ne sont accessibles.

create or replace function private.onglet_autre(u uuid, autre uuid)
returns jsonb language sql stable as
$fn$
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
$fn$;

comment on function private.onglet_autre is
  'Profil public du partenaire. Les criteres sensibles et les paires eliminatoires sont exclus, et les points communs identifies par le moteur ne sont jamais reveles ici : ils doivent se decouvrir au fil de l''echange.';;
