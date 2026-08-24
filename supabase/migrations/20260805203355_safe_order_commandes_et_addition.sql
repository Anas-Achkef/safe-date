-- ---------- Panier et transmission ----------

create or replace function private.ajouter_consommation(
  u uuid, d_id uuid, item uuid, qte smallint default 1, opts jsonb default '{}'::jsonb)
returns uuid language plpgsql as $fn$
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
end $fn$;

create or replace function private.transmettre_commande(u uuid, o_id uuid)
returns void language plpgsql as $fn$
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
end $fn$;
comment on function private.transmettre_commande is
  'Chaque utilisateur commande quand il le souhaite : il n''est jamais necessaire que les deux valident simultanement.';

-- ---------- Addition ----------

create or replace function private.addition(d_id uuid)
returns table (user_id uuid, articles integer, montant_cents integer, regle boolean)
language sql stable as $fn$
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
$fn$;

create or replace function private.addition_totale(d_id uuid)
returns integer language sql stable as $fn$
  select coalesce(sum(montant_cents), 0)::integer from private.addition(d_id);
$fn$;

create or replace function private.reste_a_payer(d_id uuid)
returns integer language sql stable as $fn$
  select greatest(0,
    private.addition_totale(d_id)
    - coalesce((select sum(p.amount_cents) from payments p
                where p.date_id = d_id and p.kind = 'paiement' and p.status = 'capture'), 0));
$fn$;
comment on function private.reste_a_payer is
  'Solde restant sur le rendez-vous. Conditionne la cloture : un rendez-vous ne peut pas etre cloture tant qu''il est superieur a zero.';;
