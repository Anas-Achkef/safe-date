// Génère une population fictive dans la base locale et fait calculer ses
// vecteurs par la vraie fonction du moteur.
//   node generer.mjs <dossier-donnees> <nombre> [graine]
//
// Modèle : chaque personne a des traits latents z (qui elle est) et z* (qui
// elle cherche). Ses réponses « moi » découlent de z, ses réponses « je
// recherche » sont l'option qui accepte ce qu'une personne z* répondrait.
// La proximité entre z d'autrui et z* est donc une vérité connue d'avance,
// indépendante des correspondances et des poids du moteur.
import { PGlite } from '@electric-sql/pglite';
import { postgis } from '@electric-sql/pglite-postgis';
import { unaccent } from '@electric-sql/pglite/contrib/unaccent';
import { readFileSync } from 'node:fs';

const [, , donnees, nArg, graineArg] = process.argv;
const N = Number(nArg);
const GRAINE = Number(graineArg ?? 20261124);

export const PARAMS = {
  dimensions: 6,
  // Part de l'idéal recherché qui ressemble à soi-même (0 = sans rapport).
  homophilie: 0.5,
  // Bruit propre à chaque réponse : on ne se décrit pas avec une précision parfaite.
  bruitReponse: 0.6,
  // Part de réponses données au hasard, dans les deux sens.
  reponsesAuHasard: 0.05,
  // Sur un critère rédhibitoire, probabilité de répondre « peu importe » quand
  // l'option existe. null : tirage égal entre toutes les options qui conviennent.
  indifferenceRedhibitoires: null,
  ...JSON.parse(process.env.SIM_PARAMS ?? '{}'),
};
console.log('Paramètres :', JSON.stringify(PARAMS));

/* ------------------------------ hasard ----------------------------------- */
function mulberry32(a) {
  return () => {
    a |= 0; a = (a + 0x6d2b79f5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}
const rnd = mulberry32(GRAINE);
const normale = () => {
  let u = 0;
  while (u === 0) u = rnd();
  return Math.sqrt(-2 * Math.log(u)) * Math.cos(2 * Math.PI * rnd());
};
const entier = (n) => Math.floor(rnd() * n);
const auHasard = (t) => t[entier(t.length)];
const hex = (n) => Array.from({ length: n }, () => entier(16).toString(16)).join('');
const uuid = () => `${hex(8)}-${hex(4)}-4${hex(3)}-a${hex(3)}-${hex(12)}`;
// Fonction de répartition de la loi normale (Abramowitz-Stegun 26.2.17).
function phi(x) {
  const t = 1 / (1 + 0.2316419 * Math.abs(x));
  const d = 0.3989423 * Math.exp((-x * x) / 2);
  const p = d * t * (0.3193815 + t * (-0.3565638 + t * (1.781478 + t * (-1.821256 + t * 1.330274))));
  return x > 0 ? 1 - p : p;
}

/* ------------------------------ référentiel ------------------------------ */
const db = await PGlite.create({ dataDir: donnees, extensions: { postgis, unaccent } });
const q = async (sql, p) => (await db.query(sql, p)).rows;

const cles = new Set(JSON.parse(readFileSync(new URL('./cles-repondues.json', import.meta.url), 'utf8')));
const paires = (
  await q(`select p.pair_key, p.self_key, p.pref_key, p.match_type::text as type, p.is_absolute,
                  (select array_agg(o.idx order by o.idx) from criterion_options o where o.criterion_key = p.self_key) as opts_self,
                  (select array_agg(o.idx order by o.idx) from criterion_options o where o.criterion_key = p.pref_key) as opts_pref
             from criterion_pairs p order by p.slot`)
).filter((p) => cles.has(p.self_key) && cles.has(p.pref_key));
const corr = await q(
  `select pair_key, pref_idx, accepted_self_idx as acc, tolerance, relative_op::text as rel,
          weight_multiplier::float8 as poids from option_mappings`,
);
const corrPar = {};
for (const c of corr) (corrPar[c.pair_key] ??= []).push(c);

// Chaque paire dépend surtout d'un trait, un peu des autres.
for (const p of paires) {
  const principal = entier(PARAMS.dimensions);
  p.poids = Array.from({ length: PARAMS.dimensions }, (_, d) => (d === principal ? 0.9 : 0.15 * normale()));
  const norme = Math.hypot(...p.poids);
  p.poids = p.poids.map((w) => w / norme);
  // Les options sont ordonnées quand le moteur les traite comme telles
  // (échelle, comparaison relative) ; sinon l'ordre des index ne veut rien dire.
  const ordonnee = p.type === 'echelle' || (corrPar[p.pair_key] ?? []).some((c) => c.rel);
  p.ordre = [...p.opts_self];
  if (!ordonnee) for (let i = p.ordre.length - 1; i > 0; i--) {
    const j = entier(i + 1);
    [p.ordre[i], p.ordre[j]] = [p.ordre[j], p.ordre[i]];
  }
}
const projeter = (p, z, bruit) => {
  const u = p.poids.reduce((s, w, d) => s + w * z[d], 0) + bruit * normale();
  const rang = Math.min(p.ordre.length - 1, Math.floor(phi(u / Math.sqrt(1 + bruit * bruit)) * p.ordre.length));
  return p.ordre[rang];
};

/** L'option « je recherche » qui accepte la réponse idéale, compte tenu de la sienne. */
function choisirRecherche(p, ideale, mienne) {
  const lignes = corrPar[p.pair_key] ?? [];
  if (rnd() < PARAMS.reponsesAuHasard || lignes.length === 0) return auHasard(p.opts_pref);
  const conviennent = lignes.filter((c) => {
    if (c.rel === 'sup') return ideale > mienne;
    if (c.rel === 'inf') return ideale < mienne;
    if (c.rel === 'egal') return ideale === mienne;
    if (p.type === 'echelle') return c.tolerance !== null && Math.abs(ideale - mienne) <= c.tolerance;
    return c.acc.includes(ideale);
  });
  if (p.is_absolute && PARAMS.indifferenceRedhibitoires !== null) {
    const indifferentes = conviennent.filter((c) => c.poids === 0);
    const exigeantes = conviennent.filter((c) => c.poids > 0);
    if (indifferentes.length && (rnd() < PARAMS.indifferenceRedhibitoires || !exigeantes.length)) {
      return auHasard(indifferentes).pref_idx;
    }
    if (exigeantes.length) return auHasard(exigeantes).pref_idx;
  }
  return (conviennent.length ? auHasard(conviennent) : auHasard(lignes)).pref_idx;
}

/* ------------------------------ population ------------------------------- */
// genre : 0 homme, 1 femme, 2 non-binaire ; recherche : idem, 3 = peu importe.
// orientation : 0 hétéro, 1 homo, 2 bi.
const DEMO = [
  { part: 0.44, genre: 0, cherche: 1, orientation: 0 },
  { part: 0.44, genre: 1, cherche: 0, orientation: 0 },
  { part: 0.03, genre: 0, cherche: 0, orientation: 1 },
  { part: 0.03, genre: 1, cherche: 1, orientation: 1 },
  { part: 0.02, genre: 0, cherche: 3, orientation: 2 },
  { part: 0.02, genre: 1, cherche: 3, orientation: 2 },
  { part: 0.02, genre: 2, cherche: 3, orientation: 2 },
];
function tirerDemo() {
  let r = rnd();
  for (const d of DEMO) { if ((r -= d.part) < 0) return d; }
  return DEMO[0];
}

await db.exec(`
  create schema if not exists sim;
  create table if not exists sim.latent (
    user_id uuid primary key, z float8[] not null, ideal float8[] not null,
    genre smallint not null, cherche smallint not null);
  -- Valeurs relevées dans le dump de la base réelle, différentes des migrations.
  update engine_params set value = 15 where key = 'min_criteres_affiches';
  update engine_params set value = 25 where key = 'plancher_directionnel';
  insert into policy_documents (code, version, published_at, body, body_sha256, is_current)
    values ('confidentialite', 'simulation', now(), 'Population fictive locale.', repeat('0', 64), false)
    on conflict do nothing;
  alter table profile_answers disable trigger profile_answers_refresh;
`);

const sensibles = (await q(`select distinct sensitive_category::text as c from criteria where sensitive_category is not null`)).map((r) => r.c);
const t0 = Date.now();
const LOT = 100;
let reponses = 0;

for (let debut = 0; debut < N; debut += LOT) {
  const gens = [];
  for (let i = debut; i < Math.min(N, debut + LOT); i++) {
    const demo = tirerDemo();
    const z = Array.from({ length: PARAMS.dimensions }, normale);
    const ideal = z.map((v) => PARAMS.homophilie * v + Math.sqrt(1 - PARAMS.homophilie ** 2) * normale());
    const age = 20 + Math.floor(Math.abs(normale()) * 9) + entier(8);
    const rep = [];
    for (const p of paires) {
      let moi, rech;
      if (p.pair_key === 'genre') { moi = demo.genre; rech = demo.cherche; }
      else if (p.pair_key === 'db_sex_or') { moi = demo.orientation; rech = rnd() < 0.6 ? 5 : demo.orientation; }
      else {
        moi = rnd() < PARAMS.reponsesAuHasard ? auHasard(p.opts_self) : projeter(p, z, PARAMS.bruitReponse);
        rech = choisirRecherche(p, projeter(p, ideal, 0), moi);
      }
      rep.push([p.self_key, moi], [p.pref_key, rech]);
    }
    gens.push({ id: uuid(), i, demo, z, ideal, age, rep });
  }

  const v = (g) => `'${g.id}'`;
  await db.exec(`
    insert into auth.users (id, email) values ${gens.map((g) => `(${v(g)}, 'fictif+${g.i}@safedate.test')`).join(',')};
    insert into public.profiles (id, birth_date, prenom, is_active, is_verified, is_fictif,
        age_min, age_max, search_radius_km, intentions, langue, pays, last_location, last_seen_at)
      values ${gens.map((g) => `(${v(g)}, current_date - ${g.age * 365 + entier(365)}, 'Fictif ${g.i}', true, ${rnd() < 0.35}, true,
        ${Math.max(18, g.age - 8)}, ${g.age + 8}, 25, array['amour']::public.rencontre_type[], 'fr', 'FR',
        st_setsrid(st_makepoint(${(2.3522 + (rnd() - 0.5) * 0.4).toFixed(5)}, ${(48.8566 + (rnd() - 0.5) * 0.3).toFixed(5)}), 4326)::geography,
        now() - random() * interval '5 days')`).join(',')};
    insert into public.consents (user_id, category, policy_code, policy_version)
      values ${gens.flatMap((g) => sensibles.map((c) => `(${v(g)}, '${c}', 'confidentialite', 'simulation')`)).join(',')};
    insert into public.profile_answers (user_id, criterion_key, option_idx)
      values ${gens.flatMap((g) => g.rep.map(([k, o]) => `(${v(g)}, '${k}', '{${o}}')`)).join(',')};
    insert into sim.latent (user_id, z, ideal, genre, cherche)
      values ${gens.map((g) => `(${v(g)}, '{${g.z.join(',')}}', '{${g.ideal.join(',')}}', ${g.demo.genre}, ${g.demo.cherche})`).join(',')};
  `);
  reponses += gens.length * gens[0].rep.length;
  if ((debut / LOT) % 15 === 0) console.log(`  ${Math.min(N, debut + LOT)} profils, ${reponses} réponses, ${Math.round((Date.now() - t0) / 1000)} s`);
}
console.log(`Population : ${N} profils, ${reponses} réponses en ${Math.round((Date.now() - t0) / 1000)} s`);

await db.exec(`alter table profile_answers enable trigger profile_answers_refresh;`);

// Les vecteurs sont calculés par la fonction du moteur, une fois par profil.
const t1 = Date.now();
const ids = (await q(`select id from profiles where is_fictif order by id`)).map((r) => r.id);
for (let i = 0; i < ids.length; i += 250) {
  await db.exec(`select private.refresh_profile_vectors(id) from profiles where id in (${ids.slice(i, i + 250).map((x) => `'${x}'`).join(',')});`);
  if ((i / 250) % 10 === 0) console.log(`  vecteurs ${Math.min(ids.length, i + 250)}/${ids.length}, ${Math.round((Date.now() - t1) / 1000)} s`);
}
console.log(`Vecteurs : ${ids.length} en ${Math.round((Date.now() - t1) / 1000)} s`);
console.table(await q(`select count(*)::int as profils, round(avg(answered_self), 1) as moi, round(avg(answered_pref), 1) as recherche from profile_vectors`));
await db.close();
