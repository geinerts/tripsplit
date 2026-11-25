const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { exposeAdmin, fulfillAdmin } = require('./admin-page.cjs');
const { chromium } = require('playwright');
const root = path.resolve(__dirname, '../..');

for (const width of [1440, 390]) {
  test(`Deletion feedback dashboard at ${width}px`, async () => {
    const browser = await chromium.launch({headless:true, channel:process.env.PLAYWRIGHT_CHANNEL || 'chrome'});
    try {
      const page = await browser.newPage({viewport:{width,height:1000}});
      const errors = [];
      let feedback = {available:true,total_selections:20,reasons:[
        {code:'not_using',count:8},{code:'another_way',count:4},
        {code:'too_complicated',count:3},{code:'technical_issue',count:2},
        {code:'privacy',count:2},{code:'other',count:1},
      ]};
      page.on('pageerror', error => errors.push(error.message));
      await page.route('**/*', async route => {
        const url = new URL(route.request().url());
        if (url.pathname === '/api/api.php') {
          const action = url.searchParams.get('action');
          if (action === 'admin_panel_session_check') return route.fulfill({json:{authenticated:false}});
          if (action === 'admin_panel_dashboard') return route.fulfill({json:{ok:true,stats:{account_deletion_feedback:feedback}}});
          return route.fulfill({json:{ok:true,log:[],events:[]}});
        }
        return fulfillAdmin(route, url);
      });
      await page.goto('https://ops.splyto.test/admin2/');
      await exposeAdmin(page);
      await page.locator('#auth-screen.visible').waitFor();
      await page.evaluate(() => {admin.state.user={id:1,username:'Test admin',role:'superadmin'};admin.showApp();admin.navigate('growth');});
      const card = page.locator('.deletion-feedback');
      await card.waitFor();
      assert.equal(await card.locator('.deletion-donut-total strong').textContent(),'20');
      assert.equal(await card.locator('.deletion-legend li').count(),6);
      assert.equal(await card.locator('.deletion-percent').first().textContent(),'40.0%');
      assert.equal(await card.locator('.deletion-donut circle').count(),7);
      assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth > innerWidth),false);
      fs.mkdirSync(path.join(root,'output/design/account-deletion-admin'),{recursive:true});
      await card.screenshot({path:path.join(root,`output/design/account-deletion-admin/${width}.png`)});
      feedback = {available:true,total_selections:0,reasons:[]};
      await page.evaluate(()=>admin.navigate('growth'));
      await card.getByText('No reasons collected yet.',{exact:true}).waitFor();
      assert.equal(await card.locator('.deletion-donut circle').count(),1);
      feedback = {available:false,total_selections:null,reasons:[]};
      await page.evaluate(()=>admin.navigate('growth'));
      await card.getByText(/Reason statistics are unavailable/).waitFor();
      assert.equal(await card.locator('.deletion-donut').count(),0);
      const hostile = await page.evaluate(()=>String(admin.renderDeletionFeedback({available:true,reasons:[{code:'other',count:'<img src=x onerror=alert(1)>'}]})));
      assert.equal(hostile.includes('<img'),false);
      assert.deepEqual(errors,[]);
    } finally {await browser.close();}
  });
}
