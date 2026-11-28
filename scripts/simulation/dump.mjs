// Lit les blocs COPY du dump de données du dépôt (supabase/seed.sql).
import { readFileSync } from 'node:fs';

const NUL = String.fromCharCode(92) + 'N';
const FIN = String.fromCharCode(92) + '.';

export function lireDump(chemin) {
  const lignes = readFileSync(chemin, 'utf8').split(/\r?\n/);
  const tables = {};
  for (let i = 0; i < lignes.length; i++) {
    const m = lignes[i].match(/^COPY public\.(\w+) \((.+)\) FROM stdin;$/);
    if (!m) continue;
    const colonnes = m[2].split(', ').map((c) => c.replace(/"/g, ''));
    const rangs = [];
    for (i += 1; lignes[i] !== FIN; i++) {
      const v = lignes[i].split('\t').map((x) => (x === NUL ? null : x));
      rangs.push(Object.fromEntries(colonnes.map((c, k) => [c, v[k]])));
    }
    tables[m[1]] = rangs;
  }
  return tables;
}
