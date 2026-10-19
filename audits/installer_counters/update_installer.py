"""Add per-version, per-action counters without rebuilding or changing Lua packages.

Run after a package builder if regenerating the permanent installer.
Historical source templates and embedded scripts remain unchanged.
"""
from pathlib import Path
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
CSS = """/* SCRIPT_ACTION_COUNTERS */
.script h3{display:flex;align-items:center;flex-wrap:wrap;gap:6px 10px}.scriptname{min-width:0;overflow-wrap:anywhere}.scriptprogress{flex:none;white-space:nowrap;margin:0;font-variant-numeric:tabular-nums}
"""


def update(html):
    if '/* SCRIPT_ACTION_COUNTERS */' in html:
        return html
    old = '  for(const s of v.scripts||[]){'
    new = '''  const scripts=v.scripts||[],totals={new:0,replace:0},positions={new:0,replace:0};
  for(const s of scripts)totals[s.action==="CRIAR"?"new":"replace"]++;
  for(const s of scripts){'''
    assert html.count(old) == 1
    html = html.replace(old, new, 1)
    old = '   const isNew=s.action==="CRIAR",label=isNew?"(NOVO)":"(SUBSTITUIR)";'
    new = '''   const isNew=s.action==="CRIAR",label=isNew?"(NOVO)":"(SUBSTITUIR)",group=isNew?"new":"replace";
   const progress=`${++positions[group]}/${totals[group]} ${label}`;'''
    assert html.count(old) == 1
    html = html.replace(old, new, 1)
    old = '<h3>${esc(s.name)} <span class="tag ${isNew?"newtag":""}">${label}</span></h3>'
    new = '<h3><span class="scriptname">${esc(s.name)}</span><span class="tag ${isNew?"newtag":""} scriptprogress">${progress}</span></h3>'
    assert html.count(old) == 1
    html = html.replace(old, new, 1)
    assert html.count('</style>') == 1
    return html.replace('</style>', CSS + '</style>', 1)


def build():
    permanent = ROOT / 'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html'
    manifest_path = ROOT / 'manifest.json'
    manifest_bytes = manifest_path.read_bytes()
    manifest = json.loads(manifest_bytes)
    current = ROOT / f"AVATAR_PLAZA_{manifest['latest']}.html"
    before = permanent.read_text()
    after = update(before)
    assert update(after) == after, 'Update must be idempotent'
    constants = lambda text: re.search(r'const FALLBACK_MANIFEST=([\s\S]*?)let manifest=null', text).group(1)
    assert constants(before) == constants(after), 'Embedded sources or metadata changed'
    permanent.write_text(after)
    current.write_text(after)
    assert manifest_path.read_bytes() == manifest_bytes
    report = dict(result='pass', latest=manifest['latest'], separate_counters='per version: CRIAR / SUBSTITUIR',
                  embedded_package_unchanged=True, manifest_sha256=hashlib.sha256(manifest_bytes).hexdigest(),
                  html_bytes=permanent.stat().st_size, html_sha256=hashlib.sha256(permanent.read_bytes()).hexdigest())
    (HERE / 'build_results.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report))


if __name__ == '__main__':
    build()
