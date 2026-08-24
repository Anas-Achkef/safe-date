create schema if not exists private;
revoke all on schema private from public;
do $$
begin
  if exists (select 1 from pg_roles where rolname = 'authenticated') then
    execute 'revoke all on schema private from authenticated';
    execute 'revoke all on all functions in schema private from authenticated';
    execute 'revoke all on all tables in schema private from authenticated';
  end if;
  if exists (select 1 from pg_roles where rolname = 'anon') then
    execute 'revoke all on schema private from anon';
  end if;
  if exists (select 1 from pg_roles where rolname = 'service_role') then
    grant usage on schema private to service_role;
  end if;
end $$;
drop function if exists public.execute_account_deletion(uuid);
drop function if exists public.request_account_deletion(uuid);
create or replace function private.execute_account_deletion(u uuid)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
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
revoke all on function private.execute_account_deletion(uuid) from public;
create or replace function public.request_account_deletion()
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare u uuid := auth.uid();
begin
  if u is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  insert into deletion_requests (user_id) values (u)
  on conflict (user_id) do update set requested_at = now(),
    execute_after = now() + interval '7 days', cancelled_at = null;
  update profiles set is_active = false where id = u;
end $$;
drop function if exists public.submit_answer(uuid, text, smallint[]);
create or replace function public.submit_answer(k text, idx smallint[])
returns void language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  perform private.submit_answer(auth.uid(), k, idx);
end $$;
drop function if exists public.verify_postal_code(uuid, text);
create or replace function public.verify_postal_code(code text)
returns boolean language plpgsql security definer set search_path = public, pg_temp as $$
declare p uuid;
begin
  select id into p from partners where owner_id = auth.uid() limit 1;
  if p is null then
    raise exception 'Aucun établissement rattaché à ce compte' using errcode='insufficient_privilege';
  end if;
  return private.verify_postal_code(p, code);
end $$;
drop function if exists public.eligible_candidates(uuid);
create or replace function public.eligible_candidates()
returns table (candidate_id uuid) language plpgsql stable security definer
set search_path = public, pg_temp as $$
begin
  if auth.uid() is null then raise exception 'Authentification requise' using errcode='insufficient_privilege'; end if;
  return query select * from private.eligible_candidates(auth.uid());
end $$;
do $$
begin
  if exists (select 1 from pg_matviews where schemaname='public' and matviewname='criterion_stats') then
    execute 'alter materialized view public.criterion_stats set schema private';
  end if;
  if exists (select 1 from pg_matviews where schemaname='private' and matviewname='criterion_stats')
     and exists (select 1 from pg_roles where rolname='service_role') then
    execute 'grant select on private.criterion_stats to service_role';
  end if;
end $$;
do $$
declare r record;
begin
  for r in select p.oid::regprocedure::text as sig from pg_proc p
           join pg_namespace ns on ns.oid = p.pronamespace where ns.nspname = 'private'
  loop
    execute format('revoke all on function %s from public', r.sig);
  end loop;
end $$;
create or replace view private.v_fonctions_definisseur_exposees as
select p.proname as fonction, pg_get_function_identity_arguments(p.oid) as arguments,
  case when p.prosecdef then 'CRITIQUE — droits définisseur' else 'À VÉRIFIER — droits appelant' end as gravite
from pg_proc p join pg_namespace ns on ns.oid = p.pronamespace
where ns.nspname = 'public' and p.prorettype <> 'trigger'::regtype::oid
  and 'uuid'::regtype::oid = any(p.proargtypes)
  and pg_get_function_identity_arguments(p.oid) !~ '^(p_id |p )?uuid$'
  and p.proname not in ('check_partner_eligibility','partner_activation_checklist',
    'activate_partner','partner_progress','diagnostic_zones','menu_label_conflit',
    'are_blocked','has_consent','set_primary_photo','reveal_establishment','compat_score')
order by 1;;
