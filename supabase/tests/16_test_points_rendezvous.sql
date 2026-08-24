-- =====================================================================
--  Safe Date / Prom'us — Vecteurs de test des points de rendez-vous
--  Cahier des charges module 5, § 5.12.7.
--
--  Géographie de test : centre de Nyon, là où se trouve le client.
-- =====================================================================

begin;

insert into auth.users (id) values
  ('00000000-0000-0000-0000-0000000000e1'::uuid),
  ('00000000-0000-0000-0000-0000000000e2'::uuid),
  ('00000000-0000-0000-0000-0000000000e3'::uuid);
insert into profiles (id, birth_date) values
  ('00000000-0000-0000-0000-0000000000e1', '1994-01-01'),
  ('00000000-0000-0000-0000-0000000000e2', '1995-01-01');

do $$
declare
  ua uuid := '00000000-0000-0000-0000-0000000000e1';
  ub uuid := '00000000-0000-0000-0000-0000000000e2';
  ow uuid := '00000000-0000-0000-0000-0000000000e3';
  etab uuid; d_id uuid; loc geography;
  r record; n int; dmin numeric; dmax numeric; ecart numeric;
  pa geography; pb geography;
begin
  loc := ST_Point(6.2394, 46.3833)::geography;   -- Nyon, place du Marché

  insert into partners (owner_id, langue, pays, nom_commercial, raison_sociale,
                        adresse, code_postal, ville, telephone, email,
                        google_place_id, google_note, google_avis, location, status)
  values (ow, 'fr', 'CH', 'Le Café du Port', 'Le Café du Port SA',
          '3 quai Louis-Bonnard', '1260', 'Nyon', '+41220000000', 'c@test.ch',
          'place_nyon', 4.4, 210, loc, 'actif')
  returning id into etab;

  -- =================================================================
  --  Zones praticables déclarées par l'établissement
  -- =================================================================

  -- CAS 1 — Une zone hors de la couronne réglementaire est refusée dès
  -- la déclaration : inutile de découvrir à l'heure du rendez-vous
  -- qu'elle ne sert à rien.
  begin
    insert into partner_safe_zones (partner_id, label, zone, validated)
    values (etab, 'Trop loin',
            ST_Buffer(ST_Project(loc, 300, radians(0)), 20)::geography, true);
    raise exception 'CAS 1 ÉCHEC : zone hors couronne acceptée';
  exception when check_violation then
    raise notice 'CAS 1 OK  — zone hors couronne 60–100 m refusée à la déclaration';
  end;

  -- CAS 2 — Sans aucune zone validée, la génération échoue avec un
  -- message explicite. Le cahier des charges prévoit de « recalculer
  -- jusqu'à obtenir une configuration conforme » : cette boucle ne se
  -- terminerait jamais ici.
  insert into dates (user_a, user_b, partner_id, creneau_debut)
  values (ua, ub, etab, now() + interval '2 hours') returning id into d_id;

  begin
    perform private.generate_meeting_points(d_id);
    raise exception 'CAS 2 ÉCHEC : génération réussie sans aucune zone déclarée';
  exception when no_data_found then
    raise notice 'CAS 2 OK  — échec explicite et borné en l''absence de zone praticable';
  end;

  -- CAS 3 — Une seule zone étroite : la couronne est respectée mais
  -- l'écart de 100 m entre les deux points est impossible. Le générateur
  -- doit le dire, pas boucler.
  insert into partner_safe_zones (partner_id, label, zone, validated)
  values (etab, 'Parvis nord (étroit)',
          ST_Buffer(ST_Project(loc, 80, radians(0)), 12)::geography, true);
  begin
    perform private.generate_meeting_points(d_id);
    raise exception 'CAS 3 ÉCHEC : couple généré dans une zone de 24 m de diamètre';
  exception when no_data_found then
    raise notice 'CAS 3 OK  — écart de 100 m impossible dans une zone unique : échec déclaré';
  end;

  -- CAS 4 — Deux zones opposées : la génération réussit, et les trois
  -- contraintes du cahier des charges sont vérifiées sur le résultat réel.
  insert into partner_safe_zones (partner_id, label, zone, validated)
  values (etab, 'Quai sud',
          ST_Buffer(ST_Project(loc, 85, radians(180)), 18)::geography, true);

  perform private.generate_meeting_points(d_id, now() + interval '2 hours');

  select value into dmin from engine_params where key = 'point_rdv_dist_min';
  select value into dmax from engine_params where key = 'point_rdv_dist_max';

  select count(*) into n from date_meeting_points where date_id = d_id;
  if n <> 2 then raise exception 'CAS 4 ÉCHEC : % point(s) généré(s) au lieu de 2', n; end if;

  for r in select m.user_id, ST_Distance(m.point, loc) as d
           from date_meeting_points m where m.date_id = d_id loop
    if r.d < dmin or r.d > dmax then
      raise exception 'CAS 4 ÉCHEC : point à % m de l''établissement, hors couronne %–% m',
        round(r.d), dmin, dmax;
    end if;
  end loop;

  select point into pa from date_meeting_points where date_id = d_id and user_id = ua;
  select point into pb from date_meeting_points where date_id = d_id and user_id = ub;
  ecart := ST_Distance(pa, pb);
  select value into n from engine_params where key = 'point_rdv_ecart_min';
  if ecart < n then
    raise exception 'CAS 4 ÉCHEC : points distants de % m, minimum % m', round(ecart), n;
  end if;

  raise notice 'CAS 4 OK  — couple conforme : % m et % m de l''établissement, % m d''écart',
    round((select ST_Distance(pa, loc))), round((select ST_Distance(pb, loc))), round(ecart);

  -- CAS 5 — Les deux utilisateurs reçoivent des points DIFFÉRENTS.
  if ST_Equals(pa::geometry, pb::geometry) then
    raise exception 'CAS 5 ÉCHEC : les deux utilisateurs partagent le même point';
  end if;
  raise notice 'CAS 5 OK  — coordonnées distinctes pour chaque utilisateur';

  -- =================================================================
  --  Révélation de l'adresse
  -- =================================================================

  -- CAS 6 — Tant que l'utilisateur n'est pas arrivé, l'adresse reste
  -- confidentielle. C'est le différenciateur central du produit.
  begin
    perform private.reveal_establishment(d_id, ua, ST_Project(pa, 400, radians(90))::geography);
    raise exception 'CAS 6 ÉCHEC : adresse révélée à 400 m du point';
  exception when check_violation then
    raise notice 'CAS 6 OK  — adresse refusée tant que l''utilisateur n''est pas sur place';
  end;

  -- CAS 7 — Arrivé dans le rayon, l'adresse est délivrée et l'arrivée
  -- horodatée.
  select * into r from private.reveal_establishment(d_id, ua, ST_Project(pa, 8, radians(45))::geography);
  if r.adresse is null then
    raise exception 'CAS 7 ÉCHEC : adresse vide alors que l''utilisateur est arrivé';
  end if;
  if (select revealed_at from date_meeting_points where date_id = d_id and user_id = ua) is null then
    raise exception 'CAS 7 ÉCHEC : arrivée non horodatée';
  end if;
  if (select status from dates where id = d_id) <> 'en_cours' then
    raise exception 'CAS 7 ÉCHEC : le rendez-vous n''est pas passé en cours';
  end if;
  raise notice 'CAS 7 OK  — arrivée vérifiée à 8 m : adresse « % » délivrée', r.adresse;

  -- CAS 8 — La révélation à un utilisateur ne révèle rien à l'autre.
  if (select revealed_at from date_meeting_points where date_id = d_id and user_id = ub) is not null then
    raise exception 'CAS 8 ÉCHEC : l''arrivée de A a marqué B comme arrivé';
  end if;
  raise notice 'CAS 8 OK  — les révélations sont individuelles';

  -- CAS 9 — Un point expiré ne délivre plus rien, même sur place.
  update date_meeting_points set expires_at = now() - interval '1 minute'
   where date_id = d_id and user_id = ub;
  begin
    perform private.reveal_establishment(d_id, ub, ST_Project(pb, 5, radians(0))::geography);
    raise exception 'CAS 9 ÉCHEC : adresse délivrée sur un point expiré';
  exception when check_violation then
    raise notice 'CAS 9 OK  — point expiré : aucune adresse délivrée';
  end;

  -- CAS 10 — Les coordonnées ne survivent pas au rendez-vous.
  update dates set status = 'termine' where id = d_id;
  n := expirer_points_rendezvous();
  if (select count(*) from date_meeting_points where date_id = d_id) <> 0 then
    raise exception 'CAS 10 ÉCHEC : des coordonnées subsistent après le rendez-vous';
  end if;
  raise notice 'CAS 10 OK — % coordonnée(s) purgée(s) à la clôture', n;

  -- =================================================================
  --  Diagnostic à l'inscription du partenaire
  -- =================================================================

  -- CAS 11 — L'établissement sait dès son inscription si ses zones
  -- permettront d'organiser des rendez-vous, plutôt que de l'apprendre
  -- au premier échec en production.
  select * into r from diagnostic_zones(etab);
  if not r.couple_possible then
    raise exception 'CAS 11 ÉCHEC : diagnostic négatif alors qu''un couple a été généré';
  end if;
  raise notice 'CAS 11 OK — diagnostic : % zones, % points possibles, écart max % m',
    r.zones_validees, r.points_possibles, r.ecart_max_m;

  -- CAS 12 — Le tirage n'est pas déterministe : deux rendez-vous
  -- successifs au même établissement ne produisent pas les mêmes
  -- coordonnées, conformément au § 5.12.7.
  declare d2 uuid; p2a geography;
  begin
    insert into dates (user_a, user_b, partner_id, creneau_debut)
    values (ua, ub, etab, now() + interval '5 hours') returning id into d2;
    perform private.generate_meeting_points(d2);
    select point into p2a from date_meeting_points where date_id = d2 and user_id = ua;
    if ST_Distance(p2a, pa) < 0.5 then
      raise exception 'CAS 12 ÉCHEC : coordonnées identiques d''un rendez-vous à l''autre';
    end if;
    raise notice 'CAS 12 OK — nouveau tirage à % m du précédent', round(ST_Distance(p2a, pa));
  end;

  raise notice '--------------------------------------------------';
  raise notice 'TOUS LES CAS SONT PASSÉS';
end $$;

rollback;

-- L'éditeur Supabase n'affiche pas les « raise notice ». Un échec lève une
-- exception, donc visible ; cette ligne rend la réussite visible aussi.
select 'TOUS LES CAS SONT PASSÉS' as resultat;
