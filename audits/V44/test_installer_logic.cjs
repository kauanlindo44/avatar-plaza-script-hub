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
  assert.equal(evaluate('manifest.latest'), 'V44');
  storage.set('ap_manifest_cache', JSON.stringify({ latest: 'V36A', updated_at: '2026-09-01', versions: [{ id: 'V36A', scripts: [] }] }));
  await evaluate('loadManifest()'); assert.equal(evaluate('manifest.latest'), 'V44');
  await evaluate('openVersion("V44")'); assert.equal(evaluate('readyVersion'), 'V44', ids.get('scriptsLoad')?.textContent);
  const sections = ids.get('versionContent').children.filter(el => el.dataset.name);
  assert.equal(sections.length, 55);
  const manifest = JSON.parse(fs.readFileSync(path.join(root, 'manifest.json'), 'utf8'));
  const specs = manifest.versions.find(v => v.id === 'V44').scripts;
  assert.equal(specs.filter(s=>s.action==='CRIAR').length,22);assert.deepEqual(specs.filter(s=>s.action==='CRIAR').map(s=>s.name).sort(),["07G3_PERSONAL_TOOLS", "07G_SETTINGS_SERVER", "07K0_TRUCO_RULES", "07K10_CARD_COMMERCE", "07K11_GAMES_PROGRESS", "07K12_TOURNAMENT_UI", "07K13_TOURNAMENT_SERVICE", "07K1_TRUCO_AI", "07K2_TRUCO_MATCH", "07K3_TRUCO_DIRECTORY", "07K4_TRUCO_TABLES", "07K5_TRUCO_UI", "07K6_CARD_CATALOG", "07K7_CARD_STYLES", "07K8_CARD_INVENTORY", "07K9_CARD_INVENTORY_UI", "07K_TRUCO_CLIENT", "07K_TRUCO_SERVER", "09B3_PLAYER_INSPECT", "09B4_CURATED_LOOKS", "09C10_CONFIRM_ACTION", "09C9_PLAYER_INSPECT"]);assert.equal(specs.filter(s=>s.action==='SUBSTITUIR').length,33);assert(specs.every(s=>s.lines<=400));
  for(const name of ['07A_CHESS','07B_CHECKERS','07C_POISON_POTATO','07W_WINS_SERVICE'])assert.equal(specs.find(s=>s.name===name).action,'SUBSTITUIR');
  for(const name of ['07A0_CHESS_RULES','07B0_CHECKERS_RULES']){const s=manifest.versions.find(v=>v.id==='V37').scripts.find(s=>s.name===name);assert.equal(crypto.createHash('sha256').update(fs.readFileSync(path.join(root,s.path))).digest('hex'),s.sha256)}
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
  evaluate('markInstalled()'); assert.equal(storage.get('ap_installed_version'), 'V44');
  sandbox.fetch = async () => ({ ok: true, text: async () => 'tampered' });
  evaluate('isRemote=true');
  const result = await evaluate('getText(FALLBACK_MANIFEST.versions[0].scripts[0])');
  assert.equal(result.source, 'embutido'); assert(result.verified);
  const opening = evaluate('openVersion("V44")'); evaluate('closeVersion()'); await opening;
  assert.equal(ids.get('overlay').style.display, 'none');
  assert.equal(evaluate('readyVersion'), null);
  const report = { result: 'pass', runtime: 'Node.js + minimal DOM doubles; no CSS rendering', checks: ['Offline V44', 'Old-cache rejection', '55 source hashes', 'Exact part reconstruction', '22 creations and 33 replacements', 'Clipboard/manual selection', 'Tampered-source fallback', 'Closing during load', 'No JavaScript exceptions'] };
  fs.writeFileSync(path.join(__dirname, 'installer_logic_results.json'), JSON.stringify(report, null, 2) + '\n');
  console.log(JSON.stringify(report));
})().catch(error => { console.error(error); process.exit(1); });
