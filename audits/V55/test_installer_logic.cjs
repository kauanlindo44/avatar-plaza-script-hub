// Executes the real installer JavaScript. Minimal DOM doubles do not test CSS.
const fs = require('fs'), path = require('path'), vm = require('vm'), assert = require('assert');
const crypto = require('crypto');
const root = path.resolve(__dirname, '../..');
const html = fs.readFileSync(path.join(root, 'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html'), 'utf8');
const js = html.match(/<script>([\s\S]*?)<\/script>/)[1];
const ids = new Map(), storage = new Map();
class Element {
  constructor(tag = 'div') { this.tag = tag; this.style = {}; this.dataset = {}; this.children = []; this.value = ''; this.checked = true; }
  set innerHTML(markup) {
    this.markup = markup; this.children = [];
    for (const match of markup.matchAll(/<(button|textarea|details|div)\b([^>]*)>/g)) {
      const el = new Element(match[1]);
      el.classes = (match[2].match(/class="([^"]*)"/)?.[1] || '').split(' ');
      el.hidden = /\bhidden\b/.test(match[2]);
      const id = match[2].match(/id="([^"]*)"/)?.[1]; if (id) ids.set(id, el);
      this.appendChild(el);
    }
  }
  get innerHTML() { return this.markup; }
  appendChild(el) { el.parent = this; this.children.push(el); return el; }
  querySelectorAll(selector) { return this.children.flatMap(el => [...((selector.startsWith('.') ? el.classes?.includes(selector.slice(1)) : el.tag === selector) ? [el] : []), ...el.querySelectorAll(selector)]); }
  querySelector(selector) { return this.querySelectorAll(selector)[0] || null; }
  remove() { if (this.parent) this.parent.children = this.parent.children.filter(el => el !== this); }
  addEventListener() {}
  focus() {}
  select() { this.selectionStart = 0; this.selectionEnd = this.value.length; }
  setSelectionRange(a, b) { this.selectionStart = a; this.selectionEnd = b; }
  closest() { return null; }
}
const copied = [];
const sandbox = {
  crypto: crypto.webcrypto, TextEncoder, AbortController, console,
  document: { getElementById: id => { if (!ids.has(id)) ids.set(id, new Element()); return ids.get(id); }, createElement: tag => new Element(tag), body: new Element('body') },
  navigator: { clipboard: { writeText: async text => copied.push(text) } },
  localStorage: { getItem: k => storage.get(k) || null, setItem: (k, v) => storage.set(k, v) },
  fetch: async () => { throw Error('offline'); },
  setTimeout: () => 1, clearTimeout() {}, setInterval: () => 1, clearInterval() {},
};
sandbox.window = { isSecureContext: true, addEventListener() {} };
vm.createContext(sandbox);
vm.runInContext(js, sandbox);
const evaluate = code => vm.runInContext(code, sandbox);
(async () => {
  await evaluate('loadManifest()');
  assert.equal(evaluate('manifest.latest'), 'V55');
  storage.set('ap_manifest_cache', JSON.stringify({ latest: 'V36A', updated_at: '2026-09-01', versions: [{ id: 'V36A', scripts: [] }] }));
  await evaluate('loadManifest()'); assert.equal(evaluate('manifest.latest'), 'V55');
  assert.equal(ids.get('net').textContent, 'OFFLINE • pacote V55 disponível');
  assert.equal(ids.get('net').className, 'status offline');
  await evaluate('openVersion("V55")'); assert.equal(evaluate('readyVersion'), 'V55', ids.get('scriptsLoad')?.textContent);
  const sections = ids.get('versionContent').children.filter(el => el.dataset.name);
  assert.equal(sections.length, 32);
  const manifest = JSON.parse(fs.readFileSync(path.join(root, 'manifest.json'), 'utf8'));
  const specs = manifest.versions.find(v => v.id === 'V55').scripts;
  assert.equal(specs.filter(s=>s.action==='CRIAR').length,14);assert.equal(specs.filter(s=>s.action==='SUBSTITUIR').length,18);assert(specs.every(s=>s.lines<=400));
  assert(!specs.some(s=>s.name==='09A_SHOP_UI'));assert.equal(new Set(specs.map(s=>s.name)).size,32);
  const oldShop = manifest.versions.find(v => v.id === 'V40').scripts.find(s => s.name === '09A_SHOP_UI');assert.equal(oldShop.parts,4);assert(oldShop.hide_full);
  const baseline = Object.fromEntries(manifest.versions.filter(v=>v.id!=='V55').flatMap(v=>v.scripts.map(s=>[s.name,s])));
  for (const section of sections) {
    const spec = specs.find(s => s.name === section.dataset.name && section.innerHTML.includes(s.location.replace(/>/g, '&gt;'))), source = fs.readFileSync(path.join(root, spec.path), 'utf8');
    const old = baseline[spec.name];
    if(spec.action==='CRIAR') assert(!old); else assert.notEqual(source,fs.readFileSync(path.join(root,old.path),'utf8'),'unchanged source leaked into V55 delta');
    const heading = section.innerHTML.match(/<h3>([\s\S]*?)<\/h3>/)[1];
    assert(heading.includes(spec.name));
    assert(heading.includes(spec.action === 'CRIAR' ? '(NOVO)' : '(SUBSTITUIR)'));
    assert.equal(heading.includes('newtag'), spec.action === 'CRIAR');
    assert(!/[()]/.test(spec.name), 'status label leaked into the actual Roblox instance name');
    const parts = section.querySelectorAll('.partarea');
    assert.equal(parts.map(el => el.value).join(''), source);
    assert.equal(crypto.createHash('sha256').update(source).digest('hex'), spec.sha256);
    assert(parts.every(el => el.hidden), 'part source visible before copying');
    assert(section.innerHTML.includes(spec.type));
    assert(section.innerHTML.includes(spec.location.replace(/>/g, '&gt;')));
    assert(section.innerHTML.includes('ÚLTIMA LINHA'));
    const expectedLastLine = evaluate(`esc(lastLine(${JSON.stringify(source)}))`);
    assert(section.innerHTML.includes(`<code>${expectedLastLine}</code>`));
    copied.length = 0;
    for (const button of section.querySelectorAll('.part')) await button.onclick();
    assert.equal(copied.join(''), source);assert(parts.every(el=>el.hidden));copied.length=0;
    if (spec.name === '09A_SHOP_UI') {
      assert.equal(parts.length, 4); assert.equal(section.querySelector('.allcode'), null);
      for (const button of section.querySelectorAll('.part')) await button.onclick();
      assert.equal(copied.join(''), source);
      assert(parts.every(el => el.hidden));
    } else {
      const area = section.querySelector('.allcode');
      assert.equal(area.value, source); assert(area.hidden);
      await section.querySelector('.all').onclick();
      assert.equal(copied[0], source); assert(area.hidden);
    }
  }
  const manualSection = sections.find(s => s.querySelector('.all'));
  sandbox.navigator.clipboard.writeText = async () => { throw Error('clipboard blocked'); };
  await manualSection.querySelector('.all').onclick();
  const manualArea = manualSection.querySelector('.allcode');
  assert.equal(manualArea.hidden, false);
  assert.equal(manualArea.selectionStart, 0);
  assert.equal(manualArea.selectionEnd, manualArea.value.length);
  assert(manualSection.querySelectorAll('.partarea').every(el => el.hidden));
  sandbox.navigator.clipboard.writeText = async text => copied.push(text);
  evaluate('markInstalled()'); assert.equal(storage.get('ap_installed_version'), 'V55');
  sandbox.fetch = async () => ({ ok: true, json: async () => manifest });
  await evaluate('loadManifest()');
  assert.equal(evaluate('manifest.latest'), 'V55');
  assert.equal(ids.get('net').textContent, 'ONLINE • sincronizado');
  assert.equal(ids.get('net').className, 'status online');
  sandbox.fetch = async () => { throw Error('offline'); };
  await evaluate('loadManifest()');
  assert.equal(ids.get('net').className, 'status offline');
  assert(!ids.get('net').className.includes('online'));
  sandbox.fetch = async () => ({ ok: true, text: async () => 'tampered' });
  evaluate('isRemote=true');
  const result = await evaluate('getText(FALLBACK_MANIFEST.versions[0].scripts[0])');
  assert.equal(result.source, 'embutido'); assert(result.verified);
  const opening = evaluate('openVersion("V55")'); evaluate('closeVersion()'); await opening;
  assert.equal(ids.get('overlay').style.display, 'none');
  assert.equal(evaluate('readyVersion'), null);
  const report = { result: 'pass', runtime: 'Node.js + minimal DOM doubles; no CSS rendering', checks: ['Offline V55', 'Current fallback version label', 'Old-cache rejection', '32 patch source hashes and offline V44 base', 'Exact part reconstruction', '14 creations and 18 replacements', 'New/replace labels with canonical instance names', 'Compact name/type/location and last-line cards', 'All full/part source fields initially hidden', 'Exact whole-script clipboard output and two-part reconstruction', 'Blocked clipboard reveals and selects only the requested source', 'Online status uses the green CSS class', 'Offline status clears the online CSS class', 'Tampered-source fallback', 'Closing during load', 'Thirty-two unique canonical instances with declared Studio types/locations', 'No JavaScript exceptions'] };
  fs.writeFileSync(path.join(__dirname, 'installer_logic_results.json'), JSON.stringify(report, null, 2) + '\n');
  console.log(JSON.stringify(report));
})().catch(error => { console.error(error); process.exit(1); });
