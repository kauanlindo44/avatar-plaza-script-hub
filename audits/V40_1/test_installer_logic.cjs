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
  assert.equal(evaluate('manifest.latest'), 'V40.1');
  storage.set('ap_manifest_cache', JSON.stringify({ latest: 'V36A', updated_at: '2026-09-01', versions: [{ id: 'V36A', scripts: [] }] }));
  await evaluate('loadManifest()'); assert.equal(evaluate('manifest.latest'), 'V40.1');
  await evaluate('openVersion("V40.1")'); assert.equal(evaluate('readyVersion'), 'V40.1', ids.get('scriptsLoad')?.textContent);
  const sections = ids.get('versionContent').children.filter(el => el.dataset.name);
  assert.equal(sections.length, 1);
  const manifest = JSON.parse(fs.readFileSync(path.join(root, 'manifest.json'), 'utf8'));
  const specs = manifest.versions.find(v => v.id === 'V40.1').scripts;
  assert.equal(specs[0].action, 'SUBSTITUIR');assert.equal(specs[0].name, '07UI_DESIGN_SYSTEM');
  const oldShop = manifest.versions.find(v => v.id === 'V40').scripts.find(s => s.name === '09A_SHOP_UI');assert.equal(oldShop.parts,4);assert(oldShop.hide_full);
  for (const section of sections) {
    const spec = specs.find(s => s.name === section.dataset.name), source = fs.readFileSync(path.join(root, spec.path), 'utf8');
    const parts = section.querySelectorAll('.partarea');
    assert.equal(parts.map(el => el.value).join(''), source);
    assert.equal(crypto.createHash('sha256').update(source).digest('hex'), spec.sha256);
    assert.equal(section.querySelectorAll('.selectpart').length, parts.length);
    if (spec.name === '09A_SHOP_UI') {
      assert.equal(parts.length, 4); assert.equal(section.querySelector('.allcode'), null);
      for (const button of section.querySelectorAll('.part')) await button.onclick();
      assert.equal(copied.join(''), source);
      section.querySelector('.selectpart').onclick(); assert.equal(parts[0].selectionEnd, parts[0].value.length);
    } else assert.equal(section.querySelector('.allcode').value, source);
  }
  evaluate('markInstalled()'); assert.equal(storage.get('ap_installed_version'), 'V40.1');
  sandbox.fetch = async () => ({ ok: true, text: async () => 'tampered' });
  evaluate('isRemote=true');
  const result = await evaluate('getText(FALLBACK_MANIFEST.versions[0].scripts[0])');
  assert.equal(result.source, 'embutido'); assert(result.verified);
  const opening = evaluate('openVersion("V40.1")'); evaluate('closeVersion()'); await opening;
  assert.equal(ids.get('overlay').style.display, 'none');
  assert.equal(evaluate('readyVersion'), null);
  const report = { result: 'pass', runtime: 'Node.js + minimal DOM doubles; no CSS rendering', checks: ['Offline V40.1', 'Old-cache rejection', '1 source hash', 'Exact part reconstruction', 'Single module replacement', 'Clipboard/manual selection', 'Tampered-source fallback', 'Closing during load', 'No JavaScript exceptions'] };
  fs.writeFileSync(path.join(__dirname, 'installer_logic_results.json'), JSON.stringify(report, null, 2) + '\n');
  console.log(JSON.stringify(report));
})().catch(error => { console.error(error); process.exit(1); });
