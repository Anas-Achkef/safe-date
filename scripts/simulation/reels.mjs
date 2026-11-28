// Recharge les profils du dump du dépôt dans la base locale et fait noter
// leurs paires par le moteur : un point de repère sur des questionnaires
// réellement remplis.   node reels.mjs <dossier-donnees> <seed.sql>
import { PGlite } from '@electric-sql/pglite';
import { postgis } from '@electric-sql/pglite-postgis';
import { unaccent } from '@electric-sql/pglite/contrib/unaccent';
import { lireDump } from './dump.mjs';

const [, , donnees, seed] = process.argv;
const d = lireDump(seed);
const db = await PGlite.create({ dataDir: donnees, extensions: { postgis, unaccent } });
const s = (x) => (x === null || x === undefined ? 'null' : `'${String(x).replace(/'/g, "''")}'`);

await db.exec(`
  update engine_params set value = 15 where key = 'min_criteres_affiches';
  update engine_params set value = 25 where key = 'plancher_directionnel';
  insert into policy_documents (code, version, published_at, body, body_sha256, is_current)
    values ${d.policy_documents.map((p) => `(${s(p.code)}, ${s(p.version)}, ${s(p.published_at)}, 'x', ${s(p.body_sha256)}, true)`).join(',')};
  insert into auth.users (id, email) values ${d.profiles.map((p, i) => `(${s(p.id)}, 'reel${i}@local')`).join(',')};
  insert into profiles (id, birth_date, age_min, age_max, search_radius_km, is_verified, is_active, prenom, intentions)
    values ${d.profiles.map((p, i) => `(${s(p.id)}, ${s(p.birth_date)}, ${p.age_min}, ${p.age_max}, ${p.search_radius_km}, false, true, 'Réel ${i + 1}', ${s(p.intentions)})`).join(',')};
  insert into consents (user_id, category, policy_code, policy_version)
    values ${d.consents.filter((c) => !c.withdrawn_at).map((c) => `(${s(c.user_id)}, ${s(c.category)}, ${s(c.policy_code)}, ${s(c.policy_version)})`).join(',')};
  insert into profile_answers (user_id, criterion_key, option_idx)
    values ${d.profile_answers.map((a) => `(${s(a.user_id)}, ${s(a.criterion_key)}, ${s(a.option_idx)})`).join(',')};
`);
const r = await db.query(`
  select pa.prenom as a, pb.prenom as b, s.filtres_ok, s.affichable, s.score_global, s.score_physique,
         s.score_valeurs, s.score_mode_vie, s.score_a_vers_b, s.score_b_vers_a, s.criteres_evalues
    from profiles pa join profiles pb on pb.id > pa.id
    cross join lateral private.compat_score(pa.id, pb.id) s order by 1, 2`);
console.table(r.rows);
const g = await db.query(`
  select p.prenom, (select option_idx from profile_answers a where a.user_id = p.id and a.criterion_key = 'genre_moi') as genre,
         (select option_idx from profile_answers a where a.user_id = p.id and a.criterion_key = 'genre_rech') as cherche
    from profiles p order by 1`);
console.table(g.rows);
await db.close();
