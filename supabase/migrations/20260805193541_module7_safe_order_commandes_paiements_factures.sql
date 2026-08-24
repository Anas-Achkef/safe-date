-- ============================================================
-- MODULE 7 — Safe Order : commandes, paiements, factures,
-- reversements et impayes.
-- ============================================================

create type order_status   as enum ('brouillon','transmise','acceptee','servie','annulee');
create type payment_kind   as enum ('preautorisation','paiement','remboursement');
create type payment_mode   as enum ('individuel','integral','especes');
create type payment_status as enum ('en_attente','autorise','capture','echoue','annule','rembourse');
create type invoice_type   as enum ('detaillee','simplifiee');

-- ---------- Moyens de paiement ----------

create table user_payment_methods (
  user_id                   uuid not null references profiles(id) on delete cascade,
  stripe_customer_id        text not null,
  stripe_payment_method_id  text not null,
  brand                     text,
  last4                     char(4),
  exp_month                 smallint,
  exp_year                  smallint,
  is_default                boolean not null default false,
  created_at                timestamptz not null default now(),
  primary key (user_id, stripe_payment_method_id)
);
comment on table user_payment_methods is 'Aucune donnee de carte n''est stockee : uniquement les references opaques du prestataire de paiement et les elements d''affichage.';

-- ---------- Commandes ----------

create table orders (
  id         uuid primary key default gen_random_uuid(),
  date_id    uuid not null references dates(id) on delete cascade,
  user_id    uuid not null references profiles(id) on delete cascade,
  partner_id uuid not null references partners(id) on delete cascade,
  status     order_status not null default 'brouillon',
  created_at timestamptz not null default now(),
  sent_at    timestamptz,
  served_at  timestamptz
);
create index idx_orders_date on orders (date_id, created_at);
comment on table orders is 'Chaque utilisateur commande librement et independamment de son partenaire. Les commandes restent separees jusqu''au paiement final.';

create table order_items (
  id              uuid primary key default gen_random_uuid(),
  order_id        uuid not null references orders(id) on delete cascade,
  menu_item_id    uuid references partner_menu_items(id) on delete set null,
  label_snapshot  text not null,
  unit_price_cents integer not null check (unit_price_cents >= 0),
  quantity        smallint not null default 1 check (quantity > 0),
  options         jsonb not null default '{}'::jsonb,
  line_total_cents integer generated always as (unit_price_cents * quantity) stored,
  created_at      timestamptz not null default now()
);
create index idx_orderitems_order on order_items (order_id);
comment on column order_items.label_snapshot is 'Libelle fige au moment de la commande : le menu du partenaire peut evoluer, la facture ne doit pas.';
comment on column order_items.options is 'Personnalisations proposees par l''etablissement : cuisson, accompagnement, supplement, sauce.';

-- ---------- Paiements ----------

create table payments (
  id                       uuid primary key default gen_random_uuid(),
  date_id                  uuid not null references dates(id) on delete cascade,
  payer_id                 uuid references profiles(id) on delete set null,
  partner_id               uuid not null references partners(id) on delete cascade,
  kind                     payment_kind not null default 'paiement',
  mode                     payment_mode not null default 'individuel',
  amount_cents             integer not null check (amount_cents >= 0),
  tip_cents                integer not null default 0 check (tip_cents >= 0),
  currency                 char(3) not null default 'EUR',
  stripe_payment_intent_id text,
  status                   payment_status not null default 'en_attente',
  created_at               timestamptz not null default now(),
  captured_at              timestamptz
);
create index idx_payments_date  on payments (date_id, created_at);
create index idx_payments_payer on payments (payer_id, created_at desc);
comment on table payments is 'Couvre l''empreinte bancaire (preautorisation), le reglement et le remboursement. Le mode "especes" est enregistre pour la tracabilite meme si la transaction se fait hors plateforme.';

create table order_payments (
  payment_id uuid not null references payments(id) on delete cascade,
  order_id   uuid not null references orders(id) on delete cascade,
  primary key (payment_id, order_id)
);

-- ---------- Factures ----------

create table invoices (
  id                uuid primary key default gen_random_uuid(),
  date_id           uuid not null references dates(id) on delete cascade,
  payment_id        uuid references payments(id) on delete set null,
  partner_id        uuid not null references partners(id) on delete cascade,
  user_id           uuid references profiles(id) on delete set null,
  number            text not null unique,
  type              invoice_type not null default 'detaillee',
  issued_at         timestamptz not null default now(),
  paid_at           timestamptz,
  covers            smallint,
  subtotal_ht_cents integer,
  vat_cents         integer,
  total_ttc_cents   integer not null,
  tip_cents         integer not null default 0,
  billing_info      jsonb,
  pdf_path          text
);
create index idx_invoices_date on invoices (date_id);
create index idx_invoices_user on invoices (user_id, issued_at desc);
comment on column invoices.billing_info is 'Raison sociale, adresse, numero de TVA, centre de couts : informations de facturation renseignees par l''utilisateur.';
comment on column invoices.type is 'La facture simplifiee n''indique que le nombre de couverts et le montant global, sans detailler les produits.';

create table invoice_lines (
  id           uuid primary key default gen_random_uuid(),
  invoice_id   uuid not null references invoices(id) on delete cascade,
  label        text not null,
  quantity     smallint not null default 1,
  unit_price_cents integer not null,
  vat_rate     numeric(5,2),
  total_cents  integer not null
);
create index idx_invlines_inv on invoice_lines (invoice_id);

-- ---------- Reversements ----------

create table partner_settlements (
  id                 uuid primary key default gen_random_uuid(),
  payment_id         uuid not null references payments(id) on delete cascade,
  partner_id         uuid not null references partners(id) on delete cascade,
  gross_cents        integer not null,
  commission_cents   integer not null default 0,
  net_cents          integer not null,
  stripe_transfer_id text,
  transferred_at     timestamptz,
  created_at         timestamptz not null default now()
);
create index idx_settle_partner on partner_settlements (partner_id, created_at desc);
comment on table partner_settlements is 'Repartition automatique de chaque encaissement entre la part etablissement et la commission Safe Date. Les pourboires ne supportent aucune commission.';

-- ---------- Impayes ----------

create table outstanding_debts (
  id                    uuid primary key default gen_random_uuid(),
  user_id               uuid not null references profiles(id) on delete cascade,
  date_id               uuid not null references dates(id) on delete cascade,
  partner_id            uuid not null references partners(id) on delete cascade,
  amount_cents          integer not null check (amount_cents > 0),
  created_at            timestamptz not null default now(),
  settled_at            timestamptz,
  settlement_payment_id uuid references payments(id) on delete set null,
  relances              smallint not null default 0
);
create index idx_debts_ouverts on outstanding_debts (user_id) where settled_at is null;
comment on table outstanding_debts is 'Consommation restee impayee. Tant qu''une dette est ouverte, un ecran de regularisation bloque l''acces a l''application. La regularisation doit se faire par paiement numerique.';

-- ---------- RLS ----------

alter table user_payment_methods enable row level security;
alter table orders               enable row level security;
alter table order_items          enable row level security;
alter table payments             enable row level security;
alter table order_payments       enable row level security;
alter table invoices             enable row level security;
alter table invoice_lines        enable row level security;
alter table partner_settlements  enable row level security;
alter table outstanding_debts    enable row level security;

create policy p_pm_self on user_payment_methods for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy p_orders_self on orders for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy p_orders_partenaire on orders for select
  using (partner_id in (select id from partners where owner_id = auth.uid()));

create policy p_orderitems_self on order_items for all
  using (order_id in (select id from orders where user_id = auth.uid()))
  with check (order_id in (select id from orders where user_id = auth.uid()));
create policy p_orderitems_partenaire on order_items for select
  using (order_id in (select o.id from orders o join partners p on p.id = o.partner_id where p.owner_id = auth.uid()));

create policy p_payments_self on payments for select
  using (payer_id = auth.uid());
create policy p_payments_partenaire on payments for select
  using (partner_id in (select id from partners where owner_id = auth.uid()));

create policy p_invoices_self on invoices for select
  using (user_id = auth.uid());
create policy p_invoices_partenaire on invoices for select
  using (partner_id in (select id from partners where owner_id = auth.uid()));

create policy p_invlines_lisible on invoice_lines for select
  using (invoice_id in (
    select id from invoices where user_id = auth.uid()
    union
    select i.id from invoices i join partners p on p.id = i.partner_id where p.owner_id = auth.uid()));

create policy p_settle_partenaire on partner_settlements for select
  using (partner_id in (select id from partners where owner_id = auth.uid()));

create policy p_debts_self on outstanding_debts for select
  using (user_id = auth.uid());;
