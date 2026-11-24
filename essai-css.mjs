import { chromium } from 'playwright';
const URL = 'https://safe-date-apercu.vercel.app/discovery';
const CORRECTIF = `
  #root > div:first-child {
    width: 100% !important;
    height: 100% !important;
    max-height: none !important;
    border-radius: 0 !important;
    box-shadow: none !important;
  }
  @media (min-width: 430px) and (min-height: 864px) {
    #root > div:first-child {
      width: 390px !important;
      height: 844px !important;
      border-radius: 20px !important;
      box-shadow: 0 24px 60px rgba(0,0,0,0.18) !important;
    }
  }
`;
const TAILLES = [
  ['iphone-se', 375, 667], ['android-courant', 360, 740],
  ['iphone-15-pro-max', 430, 932], ['tablette', 820, 1180], ['bureau', 1440, 900],
];
const n = await chromium.launch();
for (const [nom, w, h] of TAILLES) {
  const page = await (await n.newContext({ viewport: { width: w, height: h }, deviceScaleFactor: 2, colorScheme: 'dark', isMobile: w < 500, hasTouch: w < 500 })).newPage();
  await page.goto(URL, { waitUntil: 'domcontentloaded', timeout: 90000 });
  await page.waitForTimeout(6500);
  await page.addStyleTag({ content: CORRECTIF });
  await page.waitForTimeout(1200);
  const m = await page.evaluate(() => {
    const c = document.getElementById('root')?.firstElementChild;
    const b = c?.getBoundingClientRect();
    const onglets = Array.from(document.querySelectorAll('*')).find((e) => e.textContent?.trim() === 'Découverte' && e.children.length === 0);
    const ob = onglets?.getBoundingClientRect();
    return {
      cadre: b ? `${Math.round(b.width)}x${Math.round(b.height)} @ ${Math.round(b.left)},${Math.round(b.top)}` : 'absent',
      deborde: b ? (b.bottom > innerHeight + 1 || b.right > innerWidth + 1 || b.top < -1 || b.left < -1) : null,
      ongletsVisibles: ob ? (ob.bottom <= innerHeight + 1 && ob.top >= -1) : false,
    };
  });
  console.log(`${nom.padEnd(20)} ${String(w+'x'+h).padEnd(10)} cadre ${m.cadre.padEnd(24)} ${m.deborde ? 'DÉBORDE' : 'tient'}  barre d'onglets ${m.ongletsVisibles ? 'visible' : 'COUPÉE'}`);
  await page.screenshot({ path: `/tmp/fix-${nom}.png` });
  await page.context().close();
}
await n.close();
