alter table partner_safe_zones enable row level security;
drop policy if exists p_zones_owner on partner_safe_zones;
create policy p_zones_owner on partner_safe_zones
  for all using (partner_id in (select id from partners where owner_id = auth.uid()))
  with check (partner_id in (select id from partners where owner_id = auth.uid()));
alter table partner_postal_verifications enable row level security;
alter table menu_stopwords enable row level security;
alter table partner_step_completions enable row level security;
alter table partner_acceptances enable row level security;
alter table partner_contracts enable row level security;
drop policy if exists p_steps_owner on partner_step_completions;
create policy p_steps_owner on partner_step_completions
  for all using (partner_id in (select id from partners where owner_id = auth.uid()))
  with check (partner_id in (select id from partners where owner_id = auth.uid()));
drop policy if exists p_accept_owner on partner_acceptances;
create policy p_accept_owner on partner_acceptances
  for all using (partner_id in (select id from partners where owner_id = auth.uid()))
  with check (partner_id in (select id from partners where owner_id = auth.uid()));
drop policy if exists p_contrat_owner on partner_contracts;
create policy p_contrat_owner on partner_contracts
  for select using (partner_id in (select id from partners where owner_id = auth.uid()));
alter table policy_documents enable row level security;
alter table criterion_option_phrasings enable row level security;
alter table partner_steps enable row level security;
alter table user_steps enable row level security;
alter table training_modules enable row level security;
drop policy if exists p_policies_public on policy_documents;
create policy p_policies_public on policy_documents for select to anon, authenticated using (true);
drop policy if exists p_phrasings_read on criterion_option_phrasings;
create policy p_phrasings_read on criterion_option_phrasings for select using (true);
drop policy if exists p_psteps_read on partner_steps;
create policy p_psteps_read on partner_steps for select using (true);
drop policy if exists p_usteps_read on user_steps;
create policy p_usteps_read on user_steps for select using (true);
drop policy if exists p_training_read on training_modules;
create policy p_training_read on training_modules for select using (true);
create or replace view private.v_tables_sans_rls as
select t.tablename from pg_tables t
where t.schemaname = 'public' and not t.rowsecurity
  and not exists (select 1 from pg_class c
    join pg_namespace ns on ns.oid = c.relnamespace
    join pg_depend d on d.classid = 'pg_class'::regclass and d.objid = c.oid and d.deptype = 'e'
    where ns.nspname = t.schemaname and c.relname = t.tablename)
order by 1;;
