import { PGlite } from '@electric-sql/pglite';
import { postgis } from '@electric-sql/pglite-postgis';
import { unaccent } from '@electric-sql/pglite/contrib/unaccent';
import { lireDump } from './dump.mjs';
const [, , donnees, seed] = process.argv;
const d = lireDump(seed);
const db = await PGlite.create({ dataDir: donnees, extensions: { postgis, unaccent } });
const compte = (t) => db.query(`select count(*)::int as n from public.${t}`).then((r) => r.rows[0].n);
for (const t of ['criteria', 'criterion_options', 'criterion_pairs', 'option_mappings', 'engine_params', 'context_weight_defaults', 'policy_documents', 'profiles', 'profile_answers', 'swipe_decisions', 'criterion_option_phrasings'])
  console.log(t.padEnd(28), 'dump', String(d[t]?.length ?? '—').padStart(5), '| local', String(await compte(t)).padStart(5));
// Paramètres du moteur : valeurs déployées contre valeurs des migrations
const loc = Object.fromEntries((await db.query('select key, value::float8 as v from engine_params')).rows.map((r) => [r.key, r.v]));
const diff = d.engine_params.filter((p) => loc[p.key] === undefined || Math.abs(loc[p.key] - Number(p.value)) > 1e-9).map((p) => `${p.key}: dump ${p.value} / local ${loc[p.key]}`);
console.log('engine_params différents :', diff.length ? '\n  ' + diff.join('\n  ') : 'aucun');
const absents = Object.keys(loc).filter((k) => !d.engine_params.some((p) => p.key === k));
console.log('engine_params absents du dump :', absents.join(', ') || 'aucun');
// Correspondances
const cle = (r) => `${r.pair_key}|${r.pref_idx}`;
const lm = Object.fromEntries((await db.query("select pair_key, pref_idx, accepted_self_idx::text as a, weight_multiplier::float8 as w, tolerance from option_mappings")).rows.map((r) => [cle(r), r]));
let ecarts = 0; const ex = [];
for (const r of d.option_mappings) { const l = lm[cle(r)]; if (!l || l.a !== r.accepted_self_idx || Math.abs(l.w - Number(r.weight_multiplier)) > 1e-9 || String(l.tolerance ?? '') !== String(r.tolerance ?? '')) { ecarts++; if (ex.length < 5) ex.push(`${cle(r)} dump ${r.accepted_self_idx}/${r.weight_multiplier}/${r.tolerance} local ${l ? `${l.a}/${l.w}/${l.tolerance}` : 'absent'}`); } }
console.log('option_mappings en écart :', ecarts, ex.join(' ; '));
const lp = Object.fromEntries((await db.query("select pair_key, slot, grp::text, match_type::text, is_absolute, base_weight::float8 as w, mapping_validated from criterion_pairs")).rows.map((r) => [r.pair_key, r]));
let ep = 0; const exp = [];
for (const r of d.criterion_pairs) { const l = lp[r.pair_key]; const ok = l && String(l.slot) === r.slot && l.grp === r.grp && l.match_type === r.match_type && (l.is_absolute ? 't' : 'f') === r.is_absolute && Math.abs(l.w - Number(r.base_weight)) < 1e-9; if (!ok) { ep++; if (exp.length < 5) exp.push(`${r.pair_key}: dump ${r.grp}/${r.match_type}/${r.is_absolute}/${r.base_weight} local ${l ? `${l.grp}/${l.match_type}/${l.is_absolute}/${l.w}` : 'absent'}`); } }
console.log('criterion_pairs en écart :', ep, exp.join(' ; '));
console.log('colonnes criterion_pairs du dump :', Object.keys(d.criterion_pairs[0]).join(', '));
console.log('profils du dump :', d.profiles.length, '| dont fictifs :', d.profiles.filter((p) => p.is_fictif === 't').length, '| réponses :', d.profile_answers.length, '| swipes :', d.swipe_decisions.length);
await db.close();
