const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const assert = require('assert');
const { pathToFileURL } = require('url');
const { chromium } = require(process.env.CODEX_PRIMARY_RUNTIME_NODE_MODULES
  ? path.join(process.env.CODEX_PRIMARY_RUNTIME_NODE_MODULES, 'playwright') : 'playwright');
const root = path.resolve(__dirname, '../..');
const installer = path.join(root, 'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html');
const manifest = JSON.parse(fs.readFileSync(path.join(root, 'manifest.json'), 'utf8'));
const latest = manifest.versions.find(v => v.id === 'V39');
const errors = [];

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  page.on('pageerror', e => errors.push(String(e)));
  await page.route('https://raw.githubusercontent.com/**', route => route.abort());
  await page.goto(pathToFileURL(installer).href);
  await page.waitForFunction(() => manifest?.latest === 'V39');
  // An outdated manifest cache must never replace the embedded current package.
  await page.evaluate(() => {
    localStorage.setItem('ap_manifest_cache', JSON.stringify({ latest: 'V36A', updated_at: '2026-09-01', versions: [{ id: 'V36A', scripts: [] }] }));
    return loadManifest();
  });
  assert.equal(await page.evaluate(() => manifest.latest), 'V39');
  await page.evaluate(() => openLatest());
  await page.waitForFunction(() => readyVersion === 'V39');
  const sections = await page.locator('.script').evaluateAll(nodes => nodes.map(node => ({
    name: node.dataset.name,
    full: node.querySelector('.allcode')?.value,
    parts: [...node.querySelectorAll('.partarea')].map(t => t.value),
    selectButtons: node.querySelectorAll('.selectpart').length,
    verified: node.querySelector('.hash').textContent.includes('verificado'),
  })));
  assert.equal(sections.length, 9);
  for (const section of sections) {
    const spec = latest.scripts.find(s => s.name === section.name);
    const source = fs.readFileSync(path.join(root, spec.path), 'utf8');
    assert.equal(section.parts.join(''), source, section.name + ' parts are not byte-complete');
    assert.equal(crypto.createHash('sha256').update(section.parts.join('')).digest('hex'), spec.sha256);
    assert.equal(section.selectButtons, section.parts.length);
    assert(section.verified, section.name + ' hash not verified');
    if (section.name === '09A_SHOP_UI') {
      assert.equal(section.full, undefined);
      assert.equal(section.parts.length, 4);
    } else assert.equal(section.full, source);
  }
  await page.evaluate(() => {
    window.copiedContents = [];
    Object.defineProperty(navigator, 'clipboard', { configurable: true, value: { writeText: async text => window.copiedContents.push(text) } });
  });
  const shop = page.locator('[data-name="09A_SHOP_UI"]');
  for (let i = 0; i < 4; i++) {
    await shop.locator('details').nth(i).evaluate(node => { node.open = true; });
    await shop.locator('.part').nth(i).click();
  }
  assert.equal(await page.evaluate(() => window.copiedContents.join('')), fs.readFileSync(path.join(root, 'scripts/V39/09A_SHOP_UI.lua'), 'utf8'));
  await shop.locator('.selectpart').nth(0).click();
  assert.equal(await shop.locator('.partarea').nth(0).evaluate(t => t.selectionEnd - t.selectionStart), sections.find(s => s.name === '09A_SHOP_UI').parts[0].length);
  await page.evaluate(() => closeVersion());
  await page.screenshot({ path: '/workspace/scratch/ec6f584177a3/analysis/installer_desktop.png' });
  await page.setViewportSize({ width: 390, height: 844 });
  await page.evaluate(() => openLatest());
  await page.waitForFunction(() => readyVersion === 'V39');
  assert(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), 'mobile page overflows');
  await page.screenshot({ path: '/workspace/scratch/ec6f584177a3/analysis/installer_mobile.png' });
  await page.evaluate(() => { openVersion('V39'); closeVersion(); });
  await page.waitForTimeout(150);
  assert.equal(await page.evaluate(() => document.getElementById('overlay').style.display), 'none');
  assert.equal(errors.length, 0, errors.join('\n'));
  await browser.close();
  const result = { result: 'pass', checks: ['Offline V39', 'Old-cache rejection', '9 script hashes', 'Exact part reconstruction', '09A only four parts', 'Clipboard/manual selection', 'Mobile width', 'Closing during load', 'No JavaScript exceptions'] };
  fs.writeFileSync(path.join(__dirname, 'installer_results.json'), JSON.stringify(result, null, 2) + '\n');
  console.log(JSON.stringify(result));
})().catch(error => { console.error(error); process.exit(1); });
