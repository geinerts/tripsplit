const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { chromium } = require('playwright');
const root = path.resolve(__dirname, '../..');

for (const viewport of [{width:1280,height:900}, {width:390,height:844}]) {
  test(`Premium administration lifecycle at ${viewport.width}px`, async () => {
    const browser = await chromium.launch({headless:true, channel:process.env.PLAYWRIGHT_CHANNEL || 'chrome'});
    try {
      const page = await browser.newPage({viewport});
      const errors = [];
      const mutations = [];
      const queries = [];
      let grants = [];
      const history = [];
      const partners = [];
      let failNext = false;
      let canManage = true;
      const hostile = `Partner <img src=x onerror=window.xss=1> & "quote"`;
      const user = {id:7, nickname:'Partner tester', email:'tester@example.test', account_status:'active', created_at:'2026-01-01 00:00:00'};
      page.on('pageerror', error => errors.push(error.message));
      await page.route('**/*', async route => {
        const url = new URL(route.request().url());
        if (url.pathname === '/api/api.php') {
          const action = url.searchParams.get('action');
          if (action === 'admin_panel_session_check') return route.fulfill({json:{authenticated:false}});
          if (action === 'admin_panel_user_detail') return route.fulfill({json:{ok:true,user,trips:[],unread_notifs:0,
            premium:{can_manage:canManage,csrf_token:canManage?'fixture-csrf':null,grants,history,
              access:{plan:grants.some(g=>!g.revoked_at)?'premium':'free',expires_at:grants.find(g=>!g.revoked_at)?.ends_at}}}});
          if (action === 'admin_panel_premium_list') {
            queries.push(Object.fromEntries(url.searchParams));
            return route.fulfill({json:{ok:true,can_manage:canManage,csrf_token:'fixture-csrf',has_more:false,
              rows:url.searchParams.get('kind')==='partners'?partners:grants.map(g=>({...g,nickname:user.nickname,account_status:'active'}))}});
          }
          if (action === 'admin_panel_premium_mutate') {
            const body = route.request().postDataJSON();
            mutations.push(body);
            assert.equal(route.request().headers()['x-premium-csrf'],'fixture-csrf');
            if (failNext) { failNext=false; return route.fulfill({status:503,json:{ok:false,error:'Temporary save failure'}}); }
            if (body.operation === 'partner_create') partners.push({id:1,name:body.name,active_grants:0});
            if (body.operation === 'grant_create') grants.push({id:1,user_id:7,version:1,source:body.source,partner_id:body.partner_id,
              partner_name:partners[0].name,starts_at:'2026-09-23 12:00:00',ends_at:body.ends_at.replace('T',' ').replace('Z',''),reason:body.reason,revoked_at:null});
            if (body.operation === 'grant_extend') { assert.equal(body.version,1); grants[0].version++; grants[0].ends_at=body.ends_at.replace('T',' ').replace('Z',''); }
            if (body.operation === 'grant_revoke') { assert.equal(body.version,2); grants[0].revoked_at='2026-09-23 13:00:00'; }
            history.push({action:body.operation,admin_username:'Test admin',created_at:'2026-09-23 12:00:00',reason:body.reason});
            return route.fulfill({json:{ok:true}});
          }
          return route.fulfill({json:{ok:true}});
        }
        const files = {'/admin2/':'admin2/index.html','/admin2/app.js':'admin2/app.js','/admin2/app.css':'admin2/app.css'};
        const file = files[url.pathname];
        if (!file) return route.abort();
        return route.fulfill({body:fs.readFileSync(path.join(root,file)),contentType:file.endsWith('.js')?'text/javascript':file.endsWith('.css')?'text/css':'text/html'});
      });
      await page.goto('https://splyto.test/admin2/');
      await page.locator('#auth-screen.visible').waitFor();
      await page.evaluate(() => {state.user={id:1,username:'Test admin',role:'superadmin'};showApp();navigate('partners');});
      await page.locator('#partner-create').click();
      await page.locator('[name="name"]').fill(hostile);
      await page.locator('[name="reason"]').fill('Partnership pilot');
      await page.locator('#premium-form [type="submit"]').click();
      await page.locator('#modal-backdrop').waitFor({state:'hidden'});
      assert.equal(await page.locator('#premium-results tbody td').first().textContent(),hostile);
      await page.evaluate(() => openUserDetail(7));
      await page.getByRole('button',{name:'Grant Premium',exact:true}).click();
      await page.locator('[name="source"]').selectOption('partner');
      await page.locator('[name="partner_id"]').selectOption('1');
      await page.locator('[name="reason"]').fill('One month collaboration');
      const submit = page.locator('#premium-form [type="submit"]');
      await submit.waitFor();
      failNext = true;
      await submit.click();
      await page.getByText('Temporary save failure',{exact:true}).waitFor();
      await submit.click();
      await page.getByRole('button',{name:'Extend',exact:true}).waitFor();
      const creates = mutations.filter(m=>m.operation==='grant_create');
      assert.equal(creates.length,2);
      assert.equal(creates[0].request_id,creates[1].request_id);
      assert.equal(creates[0].partner_id,1);
      await page.screenshot({path:`/tmp/splyto-premium-admin-${viewport.width}.png`,fullPage:true});
      assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth > innerWidth),false);
      assert.equal(await page.locator('#modal-body img').count(),0);
      await page.getByRole('button',{name:'Extend',exact:true}).click();
      await page.locator('[name="reason"]').fill('Extended collaboration');
      await page.locator('#premium-form [type="submit"]').click();
      await page.getByRole('button',{name:'Revoke',exact:true}).waitFor();
      await page.getByRole('button',{name:'Revoke',exact:true}).click();
      await page.locator('[name="reason"]').fill('Collaboration ended');
      await page.locator('#premium-form [type="submit"]').click();
      await page.getByRole('heading',{name:'Free',exact:true}).waitFor();
      await page.locator('summary').click();
      assert.ok(await page.getByText('Collaboration ended',{exact:true}).count());
      await page.getByRole('button',{name:'Close',exact:true}).click();
      await page.evaluate(()=>navigate('premium',{partnerId:1}));
      await page.locator('#premium-status').selectOption('expiring');
      await page.waitForFunction(()=>document.querySelector('#premium-results table'));
      assert.ok(queries.some(q=>q.status==='expiring'&&q.partner_id==='1'));
      canManage=false;
      await page.evaluate(()=>openUserDetail(7));
      assert.equal(await page.getByRole('button',{name:'Grant Premium',exact:true}).count(),0);
      assert.equal(await page.evaluate(()=>window.xss),undefined);
      assert.deepEqual(errors,[]);
    } finally { await browser.close(); }
  });
}
