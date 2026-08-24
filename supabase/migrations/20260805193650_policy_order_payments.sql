create policy p_orderpay_lisible on order_payments for select
  using (order_id in (select id from orders where user_id = auth.uid())
      or order_id in (select o.id from orders o join partners p on p.id = o.partner_id where p.owner_id = auth.uid()));;
