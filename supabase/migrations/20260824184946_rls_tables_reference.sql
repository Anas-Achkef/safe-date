-- Active RLS sur trois tables de reference laissees ouvertes.

alter table public.context_weight_defaults enable row level security;
create policy p_context_weight_defaults_read on public.context_weight_defaults
  for select to authenticated using (true);

alter table public.session_messages enable row level security;
create policy p_session_messages_read on public.session_messages
  for select to authenticated using (actif);

-- Usage strictement interne (generateur de profils fictifs) : aucune policy.
alter table public.test_archetypes enable row level security;
