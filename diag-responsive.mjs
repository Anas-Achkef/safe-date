import { chromium } from 'playwright';
const URL = 'https://safe-date-apercu.vercel.app/discovery';
const TAILLES = [
  ['iphone-se', 375, 667],
  ['android-courant', 360, 740],
  ['iphone-15-pro-max', 430, 932],
  ['tablette', 820, 1180],
  ['bureau', 1440, 900],
];
const n = await chromium.launch();
for (const [nom, w, h] of TAILLES) {
  const page = await (await n.newContext({ viewport: { width: w, height: h }, deviceScaleFactor: 2, colorScheme: 'dark', isMobile: w < 500, hasTouch: w < 500 })).newPage();
  await page.goto(URL, { waitUntil: 'domcontentloaded', timeout: 90000 });
  await page.waitForTimeout(6500);
  const m = await page.evaluate(() => {
    const r = document.getElementById('root');
    const c = r?.firstElementChild;
    const b = c?.getBoundingClientRect();
    return {
      vue: `${window.innerWidth}x${window.innerHeight}`,
      cadre: b ? `${Math.round(b.width)}x${Math.round(b.height)} @ x=${Math.round(b.left)} y=${Math.round(b.top)}` : 'absent',
      deborde: b ? (b.bottom > window.innerHeight + 1 || b.right > window.innerWidth + 1 || b.top < -1 || b.left < -1) : null,
      coupe: b ? Math.max(0, Math.round(b.bottom - window.innerHeight)) : 0,
    };
  });
  console.log(`${nom.padEnd(20)} vue ${m.vue.padEnd(10)} cadre ${String(m.cadre).padEnd(30)} ${m.deborde ? 'DÉBORDE (' + m.coupe + 'px coupés en bas)' : 'ok'}`);
  await page.screenshot({ path: `/tmp/resp-${nom}.png` });
  await page.context().close();
}
await n.close();
