// Fait noter des paires par le moteur réel et compare à la vérité latente.
//   node evaluer.mjs <dossier-donnees> <observateurs> <candidats-par-observateur> [sortie.json]
import { PGlite } from '@electric-sql/pglite';
import { postgis } from '@electric-sql/pglite-postgis';
import { unaccent } from '@electric-sql/pglite/contrib/unaccent';
import { writeFileSync } from 'node:fs';

const [, , donnees, nObsArg, nCandArg, sortie] = process.argv;
const N_OBS = Number(nObsArg);
const N_CAND = Number(nCandArg);
const TOP = 20;

const db = await PGlite.create({ dataDir: donnees, extensions: { postgis, unaccent } });
const q = async (sql, p) => (await db.query(sql, p)).rows;

await db.exec(`
  create schema if not exists sim;
  drop table if exists sim.eval;
  create table sim.eval (
    a uuid not null, b uuid not null, filtres_ok boolean, affichable boolean,
    score_global numeric, score_physique numeric, score_valeurs numeric, score_mode_vie numeric,
    a_vers_b numeric, b_vers_a numeric, n int, brut numeric, primary key (a, b));

  -- Étalon : part des critères satisfaits, tous comptés pareil. Ni poids, ni
  -- familles, ni filtres. Sert à voir ce que la pondération du moteur apporte.
  create or replace function sim.brut(u_a uuid, u_b uuid) returns numeric language sql stable as $f$
    select avg(case when m then 1.0 else 0.0 end) from (
      select (vb.self_mask[p.slot+1] & va.pref_mask[p.slot+1]) <> 0 as m
        from criterion_pairs p, profile_vectors va, profile_vectors vb
       where va.user_id = u_a and vb.user_id = u_b and not p.is_absolute
         and va.pref_mask[p.slot+1] is not null and vb.self_mask[p.slot+1] is not null and va.weight_mul[p.slot+1] > 0
      union all
      select (va.self_mask[p.slot+1] & vb.pref_mask[p.slot+1]) <> 0
        from criterion_pairs p, profile_vectors va, profile_vectors vb
       where va.user_id = u_a and vb.user_id = u_b and not p.is_absolute
         and vb.pref_mask[p.slot+1] is not null and va.self_mask[p.slot+1] is not null and vb.weight_mul[p.slot+1] > 0
    ) t
  $f$;
`);

const observateurs = (await q(`select user_id from sim.latent order by md5(user_id::text || 'obs') limit $1`, [N_OBS])).map((r) => r.user_id);
const t0 = Date.now();
let paires = 0;
for (const [i, a] of observateurs.entries()) {
  // Candidats tirés au hasard parmi ceux que le genre rend possibles dans les deux sens.
  const r = await db.query(
    `insert into sim.eval
     select $1::uuid, c.user_id, s.filtres_ok, s.affichable, s.score_global, s.score_physique, s.score_valeurs,
            s.score_mode_vie, s.score_a_vers_b, s.score_b_vers_a, s.criteres_evalues, sim.brut($1::uuid, c.user_id)
       from (select c.user_id from sim.latent c, sim.latent moi
              where moi.user_id = $1 and c.user_id <> moi.user_id
                and (moi.cherche = 3 or moi.cherche = c.genre) and (c.cherche = 3 or c.cherche = moi.genre)
              order by md5(c.user_id::text || $1::text) limit $2) c
      cross join lateral private.compat_score($1::uuid, c.user_id) s`,
    [a, N_CAND],
  );
  paires += r.affectedRows ?? 0;
  if (i % 25 === 0) console.log(`  observateur ${i + 1}/${observateurs.length}, ${paires} paires, ${Math.round((Date.now() - t0) / 1000)} s`);
}
const duree = (Date.now() - t0) / 1000;
console.log(`${paires} paires notées en ${Math.round(duree)} s (${((duree * 1000) / paires).toFixed(2)} ms par paire, étalon compris)`);

/* ------------------------------ mesures ---------------------------------- */
const lat = Object.fromEntries((await q(`select user_id, z, ideal from sim.latent`)).map((r) => [r.user_id, r]));
const lignes = await q(`select a, b, filtres_ok, affichable, score_global::float8 as g, score_physique::float8 as ph,
  score_valeurs::float8 as va, score_mode_vie::float8 as mv, a_vers_b::float8 as ab, b_vers_a::float8 as ba, n, brut::float8 as brut from sim.eval`);
const d2 = (x, y) => x.reduce((s, v, k) => s + (v - y[k]) ** 2, 0);
for (const l of lignes) {
  const A = lat[l.a], B = lat[l.b];
  l.vAB = -d2(B.z, A.ideal); // B correspond-il à ce que A cherche ?
  l.vBA = -d2(A.z, B.ideal);
  l.v = l.vAB + l.vBA;
}
function rangs(v) {
  const idx = v.map((x, i) => [x, i]).sort((p, r) => p[0] - r[0]);
  const out = new Array(v.length);
  for (let i = 0; i < idx.length; ) {
    let j = i;
    while (j + 1 < idx.length && idx[j + 1][0] === idx[i][0]) j++;
    for (let k = i; k <= j; k++) out[idx[k][1]] = (i + j) / 2 + 1;
    i = j + 1;
  }
  return out;
}
function spearman(x, y) {
  if (x.length < 8) return null;
  const rx = rangs(x), ry = rangs(y), n = x.length;
  const mx = rx.reduce((s, v) => s + v, 0) / n, my = ry.reduce((s, v) => s + v, 0) / n;
  let sxy = 0, sxx = 0, syy = 0;
  for (let i = 0; i < n; i++) { sxy += (rx[i] - mx) * (ry[i] - my); sxx += (rx[i] - mx) ** 2; syy += (ry[i] - my) ** 2; }
  return sxx && syy ? sxy / Math.sqrt(sxx * syy) : null;
}
const quantile = (t, p) => { const s = [...t].sort((a, b) => a - b); return s.length ? s[Math.min(s.length - 1, Math.floor(p * s.length))] : null; };
const resume = (t) => { const u = t.filter((x) => x !== null && !Number.isNaN(x)); return { n: u.length, mediane: quantile(u, 0.5), q1: quantile(u, 0.25), q3: quantile(u, 0.75) }; };
const moyenne = (t) => (t.length ? t.reduce((s, v) => s + v, 0) / t.length : null);
const arr = (x, d = 3) => (x === null || x === undefined ? null : Number(x.toFixed(d)));

const parObs = {};
for (const l of lignes) (parObs[l.a] ??= []).push(l);
const m = { global: [], brut: [], aller: [], physique: [], valeurs: [], mode_vie: [], precisionTop: [], centileTop: [], precisionBrut: [], visibles: [] };
for (const ls of Object.values(parObs)) {
  // Centile de vérité de chaque candidat, parmi tous ceux tirés pour cet observateur.
  const rv = rangs(ls.map((l) => l.v));
  ls.forEach((l, i) => { l.centile = rv[i] / ls.length; });
  const vus = ls.filter((l) => l.filtres_ok && l.g !== null);
  m.visibles.push(ls.filter((l) => l.affichable).length / ls.length);
  m.global.push(spearman(vus.map((l) => l.g), vus.map((l) => l.v)));
  m.brut.push(spearman(vus.map((l) => l.brut), vus.map((l) => l.v)));
  m.aller.push(spearman(vus.map((l) => l.ab), vus.map((l) => l.vAB)));
  for (const [nom, cle] of [['physique', 'ph'], ['valeurs', 'va'], ['mode_vie', 'mv']]) {
    const ok = vus.filter((l) => l[cle] !== null);
    m[nom].push(spearman(ok.map((l) => l[cle]), ok.map((l) => l.v)));
  }
  const affichables = ls.filter((l) => l.affichable);
  if (affichables.length >= TOP) {
    const tete = [...affichables].sort((x, y) => y.g - x.g).slice(0, TOP);
    m.precisionTop.push(tete.filter((l) => l.centile > 0.9).length / TOP);
    m.centileTop.push(moyenne(tete.map((l) => l.centile)));
    const teteBrut = [...affichables].sort((x, y) => y.brut - x.brut).slice(0, TOP);
    m.precisionBrut.push(teteBrut.filter((l) => l.centile > 0.9).length / TOP);
  }
}
const notes = lignes.filter((l) => l.g !== null).map((l) => l.g);
const filtres = lignes.filter((l) => !l.filtres_ok);
const resultat = {
  population: Number((await q(`select count(*)::int as n from sim.latent`))[0].n),
  observateurs: observateurs.length,
  paires: lignes.length,
  msParPaire: arr((duree * 1000) / paires, 2),
  partFiltresOk: arr(lignes.filter((l) => l.filtres_ok).length / lignes.length),
  partAffichable: arr(lignes.filter((l) => l.affichable).length / lignes.length),
  centileVeriteDesEcartes: arr(moyenne(filtres.map((l) => l.centile))),
  partEcartesDansLeMeilleurDecile: arr(filtres.filter((l) => l.centile > 0.9).length / Math.max(1, filtres.length)),
  scoreGlobal: Object.fromEntries([0, 0.1, 0.25, 0.5, 0.75, 0.9, 0.99, 1].map((p) => [`p${Math.round(p * 100)}`, quantile(notes, Math.min(p, 0.999999))])),
  partAuDessusDe85: arr(notes.filter((x) => x >= 85).length / notes.length, 4),
  partAuDessusDe70: arr(notes.filter((x) => x >= 70).length / notes.length, 4),
  criteresEvalues: resume(lignes.map((l) => l.n)),
  spearman: Object.fromEntries(['global', 'brut', 'aller', 'physique', 'valeurs', 'mode_vie'].map((k) => [k, Object.fromEntries(Object.entries(resume(m[k])).map(([a, b]) => [a, arr(b)]))])),
  [`precisionTop${TOP}`]: { moteur: arr(moyenne(m.precisionTop)), etalonBrut: arr(moyenne(m.precisionBrut)), hasard: 0.1, observateurs: m.precisionTop.length },
  [`centileMoyenTop${TOP}`]: arr(moyenne(m.centileTop)),
};
console.log(JSON.stringify(resultat, null, 1));
if (sortie) writeFileSync(sortie, JSON.stringify(resultat, null, 1));
await db.close();
