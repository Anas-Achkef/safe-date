// Rejoue les migrations du dépôt dans un Postgres embarqué, hors du projet.
//   node charger.mjs <depot> <dossier-donnees> [derniere-migration]
import { PGlite } from '@electric-sql/pglite';
import { postgis } from '@electric-sql/pglite-postgis';
import { unaccent } from '@electric-sql/pglite/contrib/unaccent';
import { mkdirSync, readdirSync, readFileSync, rmSync } from 'node:fs';
import { dirname, resolve } from 'node:path';

const [, , depot, donnees, jusqua] = process.argv;
const correctifs = JSON.parse(
  readFileSync(new URL('./correctifs.json', import.meta.url), 'utf8'),
);

rmSync(donnees, { recursive: true, force: true });
// Le moteur embarqué ne crée pas les dossiers parents.
mkdirSync(dirname(resolve(donnees)), { recursive: true });
const db = await PGlite.create({ dataDir: donnees, extensions: { postgis, unaccent } });

// Ce que la plateforme d'hébergement fournit et que les migrations supposent.
await db.exec(`
  create role anon nologin; create role authenticated nologin; create role service_role nologin;
  create extension postgis; create extension unaccent;
  create schema auth;
  create table auth.users (id uuid primary key, email text, created_at timestamptz default now());
  create function auth.uid() returns uuid language sql stable as
    $$ select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid $$;
  create schema cron;
  create function cron.schedule(text, text, text) returns bigint language sql as $$ select 0::bigint $$;
`);

const dir = `${depot}/supabase/migrations`;
const fichiers = readdirSync(dir).filter((f) => f.endsWith('.sql')).sort();
let ok = 0;
const retraits = [];
for (const f of fichiers) {
  if (jusqua && f > jusqua) break;
  let sql = readFileSync(`${dir}/${f}`, 'utf8').replace(/^﻿/, '');
  sql = sql.replace(/create extension if not exists pg_cron[^;]*;/gi, '');
  // Instructions absentes du dépôt, passées à part sur la base réelle.
  if (correctifs[f]) await db.exec(correctifs[f]);

  // Certaines migrations recréent par « create function » une fonction dont
  // la signature change, sans le « drop » qui a dû être passé à part sur la
  // base réelle. On retire ici les anciennes surcharges avant de rejouer.
  for (const m of sql.matchAll(/^create function\s+([a-z_]+)\.([a-z_0-9]+)\s*\(/gim)) {
    const { rows } = await db.query(
      `select p.oid::regprocedure::text as sig
         from pg_proc p join pg_namespace n on n.oid = p.pronamespace
        where n.nspname = $1 and p.proname = $2`,
      [m[1], m[2]],
    );
    for (const r of rows) {
      await db.exec(`drop function if exists ${r.sig} cascade;`);
      retraits.push(`${f.slice(0, 14)} ${r.sig}`);
    }
  }

  try {
    await db.exec(sql);
    ok += 1;
  } catch (e) {
    const autour = e.position
      ? `\n  …${sql.slice(Math.max(0, e.position - 200), +e.position + 100).replace(/\s+/g, ' ')}…`
      : '';
    console.log(`ÉCHEC ${f}\n  ${String(e.message).slice(0, 400)}${autour}`);
    break;
  }
}
console.log(
  `${ok}/${fichiers.length} migrations rejouées, ${retraits.length} surcharge(s) retirée(s) au passage`,
);
if (process.env.DETAIL) console.log(retraits.join('\n'));
await db.close();
