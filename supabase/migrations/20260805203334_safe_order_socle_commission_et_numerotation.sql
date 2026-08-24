-- Taux de commission : defini au contrat de partenariat, donc par
-- etablissement, avec une valeur par defaut au niveau plateforme.
alter table partners add column commission_taux numeric(5,4)
  check (commission_taux >= 0 and commission_taux <= 1);
comment on column partners.commission_taux is
  'Taux de commission Safe Date prevu au contrat de partenariat. NULL = taux plateforme par defaut.';

insert into engine_params (key, value, description) values
  ('commission_taux_defaut', 0.15, 'Commission Safe Date appliquee a defaut de taux contractuel propre a l''etablissement'),
  ('tva_taux_defaut',        0.10, 'Taux de TVA applique par defaut sur la restauration')
on conflict (key) do nothing;

-- Le pourboire ne supporte aucune commission : il est integralement
-- reverse a l'etablissement, seuls les frais du prestataire de paiement
-- peuvent en etre deduits.
alter table partner_settlements
  add column tip_cents               integer not null default 0,
  add column commission_reportee_cents integer not null default 0;
comment on column partner_settlements.commission_reportee_cents is
  'Commission non prelevable lors d''un reglement en especes. Sera recuperee sur un paiement numerique ulterieur dans le meme etablissement.';

create sequence if not exists invoice_number_seq;

create or replace function private.numero_facture()
returns text language sql volatile as
$fn$ select 'SD-' || to_char(now(), 'YYYY') || '-' ||
            lpad(nextval('invoice_number_seq')::text, 6, '0'); $fn$;

create or replace function private.commission_taux(p uuid)
returns numeric language sql stable as
$fn$ select coalesce((select commission_taux from partners where id = p),
                     private.engine_param('commission_taux_defaut')); $fn$;;
