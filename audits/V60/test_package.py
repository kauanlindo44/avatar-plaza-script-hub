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
assert v['id'] == m['latest'] == 'V60' and m['versions'][-2]['id'] == 'V59'
assert m['versions'][:-1] == base['versions'], 'Historical metadata changed'
assert len(v['scripts']) == 18
assert sum(s['action'] == 'CRIAR' for s in v['scripts']) == 3
assert sum(s['action'] == 'SUBSTITUIR' for s in v['scripts']) == 15
assert len({s['name'] for s in v['scripts']}) == 18
new = {
    '09B8_FREE_HIGHLIGHTS': ('ModuleScript', 'ServerScriptService'),
    '07P7_ROBLOX_BACKGROUNDS': ('ModuleScript', 'ReplicatedStorage'),
    '07P8_BACKGROUND_RESOLVER': ('ModuleScript', 'ServerScriptService'),
}
assert {s['name'] for s in v['scripts'] if s['action'] == 'CRIAR'} == set(new)
baseline = {s['name']: s for version in base['versions'] for s in version['scripts']}
legacy = {'07P1_CAPTURE_ENGINE', '08L_COMMUNITY'}
for spec in v['scripts']:
    text = (ROOT / spec['path']).read_text()
    assert len(text.splitlines()) == spec['lines'] <= 400
    assert hashlib.sha256(text.encode()).hexdigest() == spec['sha256']
    assert not re.search(r'[()]', spec['name'])
    if spec['action'] == 'CRIAR':
        assert spec['name'] not in baseline
        assert (spec['type'], spec['location']) == new[spec['name']]
    else:
        old = baseline[spec['name']]
        assert text != (ROOT / old['path']).read_text()
        assert spec['type'] == old['type'] and spec['location'] == old['location']
    for dep in re.findall(r'require\([^\n]*?WaitForChild\(["\']([^"\']+)', text):
        assert dep in effective or dep in legacy, 'Missing ' + dep

# Effective V59 sources must match the published manifest. Historical metadata
# is compared above; remote historical blobs are preserved by the base Git tree.
for spec in baseline.values():
    if spec.get('sha256'):
        assert hashlib.sha256((ROOT / spec['path']).read_bytes()).hexdigest() == spec['sha256'], spec['path']
owners = [name for name, s in effective.items() if re.search(r'Market\.ProcessReceipt\s*=', (ROOT / s['path']).read_text())]
assert owners == ['07K10_CARD_COMMERCE']
for name in ['07K10_CARD_COMMERCE', '07K0_CARD_CONFIG', '09I0_ASSISTANT_CONFIG', '09I1_ASSISTANT_ACCOUNTS', '09B5_AVATAR_RUNTIME', '09B7_LAST_AVATAR', '09C6_SHOP_CART']:
    if name in baseline:
        assert effective[name] == baseline[name], name
assert (ROOT / 'AVATAR_PLAZA_V60.html').read_bytes() == (ROOT / 'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html').read_bytes()
assert len(effective) == 101
result = dict(syntax='pass', effective_sources=len(effective), delta_items=18, replace=15, create=3, max_lines=max(s['lines'] for s in v['scripts']), receipt_owner=owners, historical_manifest_hashes_dependencies='pass', previous_effective_sources_checked=len(baseline))
(HERE / 'syntax_results.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result))
