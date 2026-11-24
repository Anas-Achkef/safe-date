import { chromium } from 'playwright';
const URL = 'https://safe-date-apercu.vercel.app/discovery';
const TAILLES = [
  ['iPhone SE', 375, 667], ['Android 360', 360, 740], ['iPhone 15', 393, 852],
  ['iPhone Pro Max', 430, 932], ['tablette', 820, 1180],
  ['portable 1440x800', 1440, 800], ['bureau 1920', 1920, 1080],
];
const n = await chromium.launch();
let souci = 0;
for (const [nom, w, h] of TAILLES) {
  const page = await (await n.newContext({ viewport: { width: w, height: h }, deviceScaleFactor: 2, colorScheme: 'dark', isMobile: w < 500, hasTouch: w < 500 })).newPage();
  const err = [];
  page.on('pageerror', (e) => err.push(String(e).slice(0, 80)));
  await page.goto(URL, { waitUntil: 'domcontentloaded', timeout: 90000 });
  await page.waitForTimeout(6500);
  const m = await page.evaluate(() => {
    const c = document.getElementById('root')?.firstElementChild;
    const b = c?.getBoundingClientRect();
    const ong = Array.from(document.querySelectorAll('*')).find((e) => e.textContent?.trim() === 'Découverte' && e.children.length === 0);
    const ob = ong?.getBoundingClientRect();
    const btn = Array.from(document.querySelectorAll('*')).find((e) => e.textContent?.trim() === 'Ça m’intéresse' && e.children.length === 0);
    const bb = btn?.getBoundingClientRect();
    return {
      cadre: b ? `${Math.round(b.width)}x${Math.round(b.height)}` : 'absent',
      deborde: b ? (b.bottom > innerHeight + 1 || b.right > innerWidth + 1 || b.top < -1 || b.left < -1) : true,
      onglets: ob ? (ob.bottom <= innerHeight + 1 && ob.top >= 0) : false,
      bouton: bb ? (bb.bottom <= innerHeight + 1 && bb.top >= 0) : false,
    };
  });
  const ok = !m.deborde && m.onglets && m.bouton && err.length === 0;
  if (!ok) souci += 1;
  console.log(`${ok ? '✓' : '✗'} ${nom.padEnd(18)} ${String(w+'×'+h).padEnd(10)} cadre ${m.cadre.padEnd(10)} ${m.deborde ? 'DÉBORDE' : 'tient'} · onglets ${m.onglets ? 'ok' : 'COUPÉS'} · bouton ${m.bouton ? 'ok' : 'COUPÉ'}${err.length ? ' · ' + err[0] : ''}`);
  await page.screenshot({ path: `/tmp/live-${w}.png` });
  await page.context().close();
}
await n.close();
console.log(souci ? `\n${souci} taille(s) en défaut` : '\nToutes les tailles passent.');
