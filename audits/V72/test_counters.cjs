// Runs the actual embedded installer, with DOM doubles; does not claim CSS rendering.
const fs = require('fs'), path = require('path'), vm = require('vm'), assert = require('assert');
const root = path.resolve(__dirname, '../..');
const html = fs.readFileSync(path.join(root, 'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html'), 'utf8');
assert.equal(html, fs.readFileSync(path.join(root, 'AVATAR_PLAZA_V72.html'), 'utf8'));
const ids = new Map(), storage = new Map();
class Element {
  constructor(tag = 'div') { this.tag = tag; this.style = {}; this.dataset = {}; this.children = []; this.checked = true; }
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
}
const sandbox = {
  crypto: require('crypto').webcrypto, TextEncoder, AbortController,
  document: {getElementById: id => { if (!ids.has(id)) ids.set(id, new Element()); return ids.get(id); }, createElement: tag => new Element(tag), body: new Element('body')},
  localStorage: {getItem: k => storage.get(k) || null, setItem: (k, v) => storage.set(k, v)},
  fetch: async () => { throw Error('offline'); },
  setTimeout: () => 1, clearTimeout() {}, setInterval: () => 1, clearInterval() {},
  window: {isSecureContext: true, addEventListener() {}}
};
vm.createContext(sandbox);
vm.runInContext(html.match(/<script>([\s\S]*?)<\/script>/)[1], sandbox);
const evaluate = code => vm.runInContext(code, sandbox);
let scriptsChecked = 0;
async function checkVersion(version) {
  await evaluate(`openVersion(${JSON.stringify(version.id)})`);
  assert.equal(evaluate('readyVersion'), version.id, ids.get('scriptsLoad')?.textContent);
  const sections = ids.get('versionContent').children.filter(el => el.dataset.name);
  assert.equal(sections.length, version.scripts.length);
  const totals = [version.scripts.filter(s => s.action === 'CRIAR').length, version.scripts.filter(s => s.action !== 'CRIAR').length];
  const seen = [0, 0];
  sections.forEach((section, i) => {
    const spec = version.scripts[i], group = spec.action === 'CRIAR' ? 0 : 1;
    const expected = `${++seen[group]}/${totals[group]} (${group === 0 ? 'NOVO' : 'SUBSTITUIR'})`;
    const heading = section.innerHTML.match(/<h3>([\s\S]*?)<\/h3>/)[1];
    assert(heading.includes(`<span class="scriptname">${spec.name}</span>`), spec.name);
    assert(heading.includes(`scriptprogress">${expected}</span>`), `${version.id}: ${spec.name}: expected ${expected}`);
    assert.equal(section.dataset.name, spec.name);
    scriptsChecked++;
  });
}
(async () => {
  await evaluate('loadManifest()');
  const versions = evaluate('JSON.parse(JSON.stringify(FALLBACK_MANIFEST.versions))');
  for (const version of versions) await checkVersion(version);
  const base = versions.at(-1).scripts[0];
  const synthetic = {id: 'COUNTER_TEST', scripts: ['CRIAR', 'SUBSTITUIR', 'CRIAR', 'SUBSTITUIR', 'SUBSTITUIR', 'CRIAR'].map((action, i) => ({...base, name: `COUNTER_${i}`, action}))};
  evaluate(`manifest.versions.push(${JSON.stringify(synthetic)})`);
  await checkVersion(synthetic);
  // Reopening resets both counters, including after another version and mixed actions.
  await checkVersion(versions.find(v => v.id === 'V72'));
  await checkVersion(versions.find(v => v.id === 'V69'));
  await checkVersion(versions.find(v => v.id === 'V72'));
  // Online manifests use the same renderer as embedded and cached versions.
  const manifest = JSON.parse(fs.readFileSync(path.join(root, 'manifest.json'), 'utf8'));
  sandbox.fetch = async () => ({ok: true, json: async () => manifest, text: async () => { throw Error('use verified embedded source'); }});
  await evaluate('loadManifest()');
  await checkVersion(manifest.versions.find(v => v.id === 'V72'));
  const report = {result: 'pass', runtime: 'actual installer JavaScript + DOM doubles', embedded_versions: versions.length, script_cards_checked: scriptsChecked,
    checks: ['Separate new/replacement denominators', 'Mixed installation actions keep their own sequence', 'Version changes and reopen reset counters', 'Online and offline V72 use identical counters', 'All embedded historical versions numbered', 'Canonical names unchanged', 'Permanent/current HTML identical']};
  fs.writeFileSync(path.join(__dirname, 'counter_results.json'), JSON.stringify(report, null, 2) + '\n');
  console.log(JSON.stringify(report));
})().catch(error => { console.error(error); process.exit(1); });
