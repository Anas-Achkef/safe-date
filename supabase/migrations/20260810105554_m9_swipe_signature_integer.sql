-- Signature unique, en integer : PostgREST envoie des entiers,
-- et integer -> smallint n'est pas une conversion implicite
-- lors de la resolution de surcharge.
create function private.enregistrer_swipe(
  u uuid, cible uuid, p_garde boolean,
  p_contexte public.swipe_contexte default 'partir_en_date',
  p_fort boolean default false,
  p_ecran text default null,
  p_duree integer default null,
  p_ecrans jsonb default null,
  p_ordre public.score_group[] default null,
  p_retours integer default 0,
  p_exposes text[] default null,
  p_consultes text[] default null
) returns uuid
language plpgsql set search_path = public, private as $$
declare v_id bigint;
begin
  if u = cible then
    raise exception 'Cible invalide' using errcode = 'check_violation';
  end if;

  insert into public.swipe_decisions
    (user_id, target_id, decision, contexte, signal_fort, ecran, duree_ms,
     duree_totale_ms, ordre_consultation, retours, criteres_exposes, criteres_consultes, snapshot)
  values
    (u, cible, p_garde, p_contexte, p_fort, p_ecran, p_duree,
     p_duree, p_ordre, coalesce(p_retours, 0)::smallint, p_exposes, p_consultes,
     jsonb_build_object(
       'age',        (select h.age from private.profile_header(cible) h),
       'verifie',    (select h.profil_verifie from private.profile_header(cible) h),
       'vecteur_le', (select v.refreshed_at from public.profile_vectors v where v.user_id = cible)))
  returning id into v_id;

  if p_ecrans is not null then
    insert into public.swipe_ecrans (swipe_id, ecran, duree_ms, consultations)
    select v_id,
           (e->>'ecran')::public.score_group,
           coalesce((e->>'duree_ms')::int, 0),
           coalesce((e->>'consultations')::smallint, 1)
    from jsonb_array_elements(p_ecrans) e
    on conflict (swipe_id, ecran) do update
      set duree_ms      = public.swipe_ecrans.duree_ms + excluded.duree_ms,
          consultations = public.swipe_ecrans.consultations + excluded.consultations;

    perform private.calculer_attention(v_id);
  end if;

  if p_contexte = 'mieux_me_connaitre' then
    return private.declencher_focus(u);
  end if;

  if not p_garde then
    perform private.exclure(u, cible, u, 'refus_conversation', interval '30 days');
  end if;
  return null;
end $$;

comment on function private.enregistrer_swipe is
  'Enregistre la decision et son contexte comportemental en une seule transaction. Les parametres de detail sont facultatifs : un client qui ne les fournit pas produit un swipe valide, simplement moins informatif.';

create function public.enregistrer_swipe(
  cible uuid, garder boolean,
  contexte public.swipe_contexte default 'partir_en_date',
  signal_fort boolean default false,
  ecran text default null,
  duree_ms integer default null,
  ecrans jsonb default null,
  ordre_consultation public.score_group[] default null,
  retours integer default 0,
  criteres_exposes text[] default null,
  criteres_consultes text[] default null
) returns uuid
language plpgsql security definer set search_path = 'public','pg_temp' as $$
begin
  if auth.uid() is null then
    raise exception 'Authentification requise' using errcode = 'insufficient_privilege';
  end if;
  return private.enregistrer_swipe(auth.uid(), cible, garder, contexte, signal_fort,
    ecran, duree_ms, ecrans, ordre_consultation, retours, criteres_exposes, criteres_consultes);
end $$;

revoke all on function public.enregistrer_swipe(uuid, boolean, public.swipe_contexte, boolean, text, integer, jsonb, public.score_group[], integer, text[], text[]) from public;
grant execute on function public.enregistrer_swipe(uuid, boolean, public.swipe_contexte, boolean, text, integer, jsonb, public.score_group[], integer, text[], text[]) to authenticated;;
