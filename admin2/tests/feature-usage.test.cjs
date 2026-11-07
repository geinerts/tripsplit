const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { chromium } = require('playwright');
const root = path.resolve(__dirname, '../..');

for (const width of [1440, 390]) {
  test(`Feature usage dashboard at ${width}px`, async () => {
    const browser = await chromium.launch({headless:true, channel:process.env.PLAYWRIGHT_CHANNEL || 'chrome'});
    try {
      const page = await browser.newPage({viewport:{width,height:1000}});
      const errors = [];
      let usage = {available:true,months:[
        {month:'2026-11',counts:[{feature:'random_pick',count:12},{feature:'analytics_open',count:3}]},
        {month:'2026-10',counts:[{feature:'random_pick',count:4}]},
      ]};
      page.on('pageerror', error => errors.push(error.message));
      await page.route('**/*', async route => {
        const url = new URL(route.request().url());
        if (url.pathname === '/api/api.php') {
          const action = url.searchParams.get('action');
          if (action === 'admin_panel_session_check') return route.fulfill({json:{authenticated:false}});
          if (action === 'admin_panel_dashboard') return route.fulfill({json:{ok:true,stats:{feature_usage:usage}}});
          return route.fulfill({json:{ok:true,log:[],events:[]}});
        }
        const file = {'/admin2/':'admin2/index.html','/admin2/app.js':'admin2/app.js','/admin2/app.css':'admin2/app.css'}[url.pathname];
        if (!file) return route.abort();
        return route.fulfill({body:fs.readFileSync(path.join(root,file)),contentType:file.endsWith('.js')?'text/javascript':file.endsWith('.css')?'text/css':'text/html'});
      });
      await page.goto('https://ops.splyto.test/admin2/');
      await page.locator('#auth-screen.visible').waitFor();
      await page.evaluate(() => {state.user={id:1,username:'Test admin',role:'superadmin'};showApp();navigate('dashboard');});
      const card = page.locator('.feature-usage');
      await card.waitFor();
      assert.equal(await card.locator('tbody tr').count(),9);
      assert.deepEqual(await card.locator('thead th').allTextContents(),['Feature','2026-11','2026-10']);
      const picker = card.locator('tbody tr',{hasText:'Random picker'}).locator('td');
      assert.deepEqual(await picker.allTextContents(),['12','4']);
      assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth > innerWidth),false);
      usage = {available:true,months:[]};
      await page.evaluate(()=>navigate('dashboard'));
      await card.getByText('No feature use counted yet.',{exact:true}).waitFor();
      usage = {available:false,months:[]};
      await page.evaluate(()=>navigate('dashboard'));
      await card.getByText(/Usage totals are unavailable/).waitFor();
      const hostile = await page.evaluate(()=>renderFeatureUsage({available:true,months:[{month:'<img src=x>',counts:[{feature:'random_pick',count:'<img src=x>'}]}]}));
      assert.equal(hostile.includes('<img'),false);
      assert.deepEqual(errors,[]);
    } finally {await browser.close();}
  });
}
