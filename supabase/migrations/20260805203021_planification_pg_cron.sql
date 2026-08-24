create extension if not exists pg_cron;

-- Expirations et verrouillages : la minute est la granularite utile,
-- les delais en jeu etant de 5 et 30 minutes.
select cron.schedule('safedate-maintenance', '* * * * *',
  $$select private.maintenance_periodique();$$);

-- Entropie des criteres : un passage quotidien suffit, de nuit.
select cron.schedule('safedate-criterion-stats', '15 3 * * *',
  $$select private.refresh_criterion_stats();$$);;
