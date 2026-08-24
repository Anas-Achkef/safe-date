create or replace function trg_refresh_vectors() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
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

delete from profiles where id::text like 'e0000000%';
delete from auth.users where id::text like 'e0000000%';;
