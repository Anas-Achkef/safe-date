// Exécute une requête sur la base locale :  node q.mjs <dossier-donnees> "<sql>"
import { PGlite } from '@electric-sql/pglite';
import { postgis } from '@electric-sql/pglite-postgis';
import { unaccent } from '@electric-sql/pglite/contrib/unaccent';
import { readFileSync } from 'node:fs';
const [, , donnees, sqlOuFichier] = process.argv;
const db = await PGlite.create({ dataDir: donnees, extensions: { postgis, unaccent } });
const sql = sqlOuFichier.endsWith('.sql') ? readFileSync(sqlOuFichier, 'utf8') : sqlOuFichier;
try {
  const t = Date.now();
  const res = await db.exec(sql);
  for (const r of res) if (r.rows?.length) console.table(r.rows.slice(0, 60));
  console.log(`(${Date.now() - t} ms)`);
} catch (e) { console.log('ERREUR', e.message, e.position ? `@${e.position}: …${sql.slice(Math.max(0, e.position - 120), +e.position + 80)}…` : ''); }
await db.close();
