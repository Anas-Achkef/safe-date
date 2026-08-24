-- ---------- Empreinte bancaire ----------

create or replace function private.preautoriser(u uuid, d_id uuid, montant integer)
returns uuid language plpgsql as $fn$
declare v_partner uuid; v_id uuid;
begin
  select partner_id into v_partner from dates
   where id = d_id and (user_a = u or user_b = u);
  if v_partner is null then
    raise exception 'Rendez-vous introuvable' using errcode = 'no_data_found';
  end if;
  if not exists (select 1 from user_payment_methods where user_id = u) then
    raise exception 'Aucun moyen de paiement enregistré' using errcode = 'check_violation';
  end if;

  insert into payments (date_id, payer_id, partner_id, kind, amount_cents, status)
  values (d_id, u, v_partner, 'preautorisation', montant, 'autorise')
  returning id into v_id;
  return v_id;
end $fn$;
comment on function private.preautoriser is
  'Empreinte bancaire, sans debit. Garantit que les consommations pourront etre reglees, tout en laissant le choix du mode de reglement final.';

-- ---------- Reglement ----------

create or replace function private.regler(
  u uuid, d_id uuid, p_mode payment_mode default 'individuel',
  pourboire integer default 0, facture_simplifiee boolean default false)
returns uuid language plpgsql as $fn$
declare
  v_partner uuid; v_montant integer; v_pay uuid; v_inv uuid;
  v_taux numeric; v_tva numeric; v_commission integer; v_reportee integer := 0;
  v_ht integer; v_tva_cents integer; v_couverts smallint;
begin
  select partner_id into v_partner from dates
   where id = d_id and (user_a = u or user_b = u);
  if v_partner is null then
    raise exception 'Rendez-vous introuvable' using errcode = 'no_data_found';
  end if;

  if p_mode = 'integral' then
    v_montant := private.reste_a_payer(d_id);
  else
    v_montant := coalesce((select montant_cents from private.addition(d_id) a
                           where a.user_id = u), 0)
               - coalesce((select sum(p.amount_cents) from payments p
                           where p.date_id = d_id and p.payer_id = u
                             and p.kind = 'paiement' and p.status = 'capture'), 0);
  end if;

  if v_montant <= 0 then
    raise exception 'Aucun montant à régler' using errcode = 'check_violation';
  end if;

  insert into payments (date_id, payer_id, partner_id, kind, mode,
                        amount_cents, tip_cents, status, captured_at)
  values (d_id, u, v_partner, 'paiement', p_mode,
          v_montant, greatest(pourboire, 0), 'capture', now())
  returning id into v_pay;

  -- Prise en charge integrale : les empreintes de l'autre utilisateur
  -- sont liberees pour eviter double paiement et frais inutiles.
  if p_mode = 'integral' then
    update payments set status = 'annule'
     where date_id = d_id and kind = 'preautorisation'
       and status = 'autorise' and payer_id <> u;
  end if;
  update payments set status = 'annule'
   where date_id = d_id and kind = 'preautorisation'
     and status = 'autorise' and payer_id = u;

  -- Reversement. En especes, la commission n'est pas prelevable :
  -- elle est reportee sur un paiement numerique ulterieur.
  v_taux := private.commission_taux(v_partner);
  if p_mode = 'especes' then
    v_commission := 0;
    v_reportee   := round(v_montant * v_taux);
  else
    v_commission := round(v_montant * v_taux);
  end if;

  insert into partner_settlements (payment_id, partner_id, gross_cents,
                                   commission_cents, net_cents, tip_cents,
                                   commission_reportee_cents)
  values (v_pay, v_partner, v_montant, v_commission,
          v_montant - v_commission + greatest(pourboire, 0),
          greatest(pourboire, 0), v_reportee);

  -- Facture
  v_tva := private.engine_param('tva_taux_defaut');
  v_ht  := round(v_montant / (1 + v_tva));
  v_tva_cents := v_montant - v_ht;
  select count(distinct o.user_id)::smallint into v_couverts
    from orders o where o.date_id = d_id and o.status <> 'annulee';

  insert into invoices (date_id, payment_id, partner_id, user_id, number, type,
                        paid_at, covers, subtotal_ht_cents, vat_cents,
                        total_ttc_cents, tip_cents)
  values (d_id, v_pay, v_partner, u, private.numero_facture(),
          case when facture_simplifiee then 'simplifiee' else 'detaillee' end::invoice_type,
          now(), v_couverts, v_ht, v_tva_cents, v_montant, greatest(pourboire, 0))
  returning id into v_inv;

  if not facture_simplifiee then
    insert into invoice_lines (invoice_id, label, quantity, unit_price_cents, vat_rate, total_cents)
    select v_inv, i.label_snapshot, i.quantity, i.unit_price_cents,
           v_tva * 100, i.line_total_cents
    from order_items i
    join orders o on o.id = i.order_id
    where o.date_id = d_id and o.status <> 'annulee'
      and (p_mode = 'integral' or o.user_id = u);
  end if;

  return v_inv;
end $fn$;

comment on function private.regler is
  'Reglement des consommations. Le mode integral solde la totalite du rendez-vous et libere les empreintes de l''autre utilisateur. Le mode especes est trace pour la coherence des factures, la commission etant reportee.';;
