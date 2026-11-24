import { chromium } from 'playwright';
const n = await chromium.launch();
const page = await (await n.newContext({ viewport: { width: 1280, height: 900 } })).newPage();
const logs = [];
page.on('console', (m) => logs.push(`[${m.type()}] ${m.text().slice(0, 200)}`));
page.on('pageerror', (e) => logs.push('PAGEERROR: ' + (e.stack || String(e)).slice(0, 400)));
page.on('requestfailed', (r) => logs.push('REQ KO: ' + r.url().slice(0, 120) + ' — ' + r.failure()?.errorText));
await page.goto('https://safe-date-apercu.vercel.app/discovery', { waitUntil: 'load', timeout: 90000 });
await page.waitForTimeout(9000);
const info = await page.evaluate(() => {
  const r = document.getElementById('root');
  return {
    root: r ? `enfants=${r.children.length} texte=${JSON.stringify((r.innerText||'').slice(0,120))}` : 'PAS DE #root',
    bodyBg: getComputedStyle(document.body).backgroundColor,
    scripts: Array.from(document.scripts).map((s) => s.src.split('/').pop()).join(', '),
  };
});
console.log('ROOT :', info.root);
console.log('FOND :', info.bodyBg);
console.log('SCRIPTS :', info.scripts);
console.log('--- journal ---');
console.log(logs.slice(0, 12).join('\n') || 'aucun message');
await n.close();
