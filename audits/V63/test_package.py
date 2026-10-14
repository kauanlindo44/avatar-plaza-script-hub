from build_installer import NEW
from test_support import *
import hashlib

m = json.loads((ROOT / 'manifest.json').read_text())
base = json.loads((HERE / 'base_manifest.json').read_text())
effective = {s['name']: s for v in m['versions'] for s in v['scripts']}
for name, spec in effective.items():
    lua = Lua()
    try:
        lua.run((ROOT / spec['path']).read_text(), name, execute=False)
    finally:
        lua.close()

v = m['versions'][-1]
assert v['id'] == m['latest'] == 'V63' and m['versions'][-2]['id'] == 'V62'
assert m['versions'][:-1] == base['versions'], 'Historical metadata changed'
assert len(v['scripts']) == 25
assert sum(s['action'] == 'CRIAR' for s in v['scripts']) == 5
assert sum(s['action'] == 'SUBSTITUIR' for s in v['scripts']) == 20
assert len({s['name'] for s in v['scripts']}) == 25
assert {s['name'] for s in v['scripts'] if s['action'] == 'CRIAR'} == set(NEW)
baseline = {s['name']: s for version in base['versions'] for s in version['scripts']}
legacy = {'07Z_BOARD_VISUALS', '07P1_CAPTURE_ENGINE', '08L_COMMUNITY'}
for spec in v['scripts']:
    text = (ROOT / spec['path']).read_text()
    assert len(text.splitlines()) == spec['lines'] <= 400
    assert hashlib.sha256(text.encode()).hexdigest() == spec['sha256']
    assert not re.search(r'[()]', spec['name'])
    label = 'NOVO' if spec['action'] == 'CRIAR' else 'SUBSTITUIR'
    assert text.splitlines()[0] == f"-- {spec['name']} | {spec['type']} | {spec['location']} | V63 ({label})"
    if spec['action'] == 'CRIAR':
        assert spec['name'] not in baseline
        assert (spec['type'], spec['location']) == NEW[spec['name']]
    else:
        old = baseline[spec['name']]
        assert text != (ROOT / old['path']).read_text()
        assert spec['type'] == old['type'] and spec['location'] == old['location']
    for dep in re.findall(r'require\([^\n]*?WaitForChild\(["\']([^"\']+)', text):
        assert dep in effective or dep in legacy, 'Missing ' + dep

# Local effective V62 sources must match their published manifest hashes.
# Remote historical blobs are preserved using the base tree when publishing.
for spec in baseline.values():
    if spec.get('sha256'):
        assert hashlib.sha256((ROOT / spec['path']).read_bytes()).hexdigest() == spec['sha256'], spec['path']
owners = [name for name, s in effective.items() if re.search(r'Market\.ProcessReceipt\s*=', (ROOT / s['path']).read_text())]
assert owners == ['07K10_CARD_COMMERCE']
for name in ['07K10_CARD_COMMERCE', '07K6_CARD_CATALOG', '09I1_ASSISTANT_ACCOUNTS', '09B5_AVATAR_RUNTIME', '09B7_LAST_AVATAR', '09C6_AVATAR_PREVIEW', '09A_SHOP_UI']:
    assert effective[name] == baseline[name], name
old_config = (ROOT / baseline['09I0_ASSISTANT_CONFIG']['path']).read_text()
new_config = (ROOT / effective['09I0_ASSISTANT_CONFIG']['path']).read_text()
assert re.findall(r'product=\d+', old_config) == re.findall(r'product=\d+', new_config)
assert 'TextGenerator' not in (ROOT / effective['09I2_ASSISTANT_ENGINE']['path']).read_text()
assert (ROOT / 'AVATAR_PLAZA_V63.html').read_bytes() == (ROOT / 'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html').read_bytes()
assert len(effective) == 117
result = dict(syntax='pass', effective_sources=len(effective), delta_items=25, replace=20, create=5, max_lines=max(s['lines'] for s in v['scripts']), receipt_owner=owners, historical_manifest_hashes_dependencies='pass', previous_effective_sources_checked=len(baseline))
(HERE / 'syntax_results.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result))
