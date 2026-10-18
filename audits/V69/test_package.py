from build_installer import NEW, EXTERNAL
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
assert v['id'] == m['latest'] == 'V69' and m['versions'][-2]['id'] == 'V68'
assert m['versions'][:-1] == base['versions'], 'Historical metadata changed'
assert len(v['scripts']) == 45
assert sum(s['action'] == 'CRIAR' for s in v['scripts']) == 10
assert sum(s['action'] == 'SUBSTITUIR' for s in v['scripts']) == 35
assert len({s['name'] for s in v['scripts']}) == 45
assert {s['name'] for s in v['scripts'] if s['action'] == 'CRIAR'} == set(NEW)
baseline = {s['name']: s for version in base['versions'] for s in version['scripts']}
legacy = {'07Z_BOARD_VISUALS', '07P1_CAPTURE_ENGINE', '08L_COMMUNITY'}
for spec in v['scripts']:
    text = (ROOT / spec['path']).read_text()
    assert len(text.splitlines()) == spec['lines'] <= 400
    assert hashlib.sha256(text.encode()).hexdigest() == spec['sha256']
    assert not re.search(r'[()]', spec['name'])
    label = 'NOVO' if spec['action'] == 'CRIAR' else 'SUBSTITUIR'
    assert text.splitlines()[0] == f"-- {spec['name']} | {spec['type']} | {spec['location']} | V69 ({label})"
    if spec['action'] == 'CRIAR':
        assert spec['name'] not in baseline
        assert (spec['type'], spec['location']) == NEW[spec['name']]
    else:
        old = baseline.get(spec['name']) or dict(type=EXTERNAL[spec['name']][0],location=EXTERNAL[spec['name']][1])
        if spec['name'] in baseline: assert text != (ROOT / old['path']).read_text()
        assert spec['type'] == old['type'] and spec['location'] == old['location']
    for dep in re.findall(r'require\([^\n]*?WaitForChild\(["\']([^"\']+)', text):
        assert dep in effective or dep in legacy, 'Missing ' + dep

# Local effective V66 sources must match their published manifest hashes.
# Remote historical blobs are preserved using the base tree when publishing.
for spec in baseline.values():
    if spec.get('sha256'):
        assert hashlib.sha256((ROOT / spec['path']).read_bytes()).hexdigest() == spec['sha256'], spec['path']
owners = [name for name, s in effective.items() if re.search(r'Market\.ProcessReceipt\s*=', (ROOT / s['path']).read_text())]
assert owners == ['07K10_CARD_COMMERCE']
for name in ['07K10_CARD_COMMERCE', '07K6_CARD_CATALOG', '09B7_LAST_AVATAR', '09A_SHOP_UI', '07A0_CHESS_RULES', '07B0_CHECKERS_RULES', '07K0_TRUCO_RULES', '07K2_TRUCO_MATCH']:
    assert effective[name] == baseline[name], name
for name in baseline:
    if re.search(r'RULES|BOT|DIRECTORY|DECK_OPTIONS',name) and not name.startswith('09I'):
        assert effective[name] == baseline[name], 'Changed game kernel: '+name
# Strip only the reviewed chat hooks, then demand byte-identical match authority.
def original(name):return (ROOT/baseline[name]['path']).read_text()
def current(name):return (ROOT/effective[name]['path']).read_text()
chat_import="local MatchChat=require(script.Parent:WaitForChild('07H9_MATCH_CHAT'))\n"
board=current('07H7_BOARD_SESSIONS').replace(chat_import,'').replace("Version='V69'","Version='V62'")
board=board.replace(';MatchChat.Close(s.id)','').replace("MatchChat.Open(s.id,s.game,s.players);",'')
assert board.partition('\n')[2]==original('07H7_BOARD_SESSIONS').partition('\n')[2]
truco=current('07K_TRUCO_SERVER').replace(chat_import,'')
for hook in [";if room.chatKey then MatchChat.Close(room.chatKey)end","room.chatKey=room.match.id;MatchChat.Open(room.chatKey,'Truco',room.players);","if room.chatKey then MatchChat.Close(room.chatKey);MatchChat.Open(room.chatKey,'Truco',room.players)end;","if room.chatKey then MatchChat.Close(room.chatKey)end;","MatchChat.Remove(pl);"]:
    truco=truco.replace(hook,'')
assert truco.partition('\n')[2]==original('07K_TRUCO_SERVER').partition('\n')[2]
old_config = (ROOT / baseline['09I0_ASSISTANT_CONFIG']['path']).read_text()
new_config = (ROOT / effective['09I0_ASSISTANT_CONFIG']['path']).read_text()
assert re.findall(r'product=\d+', old_config) == re.findall(r'product=\d+', new_config)
old_accounts=(ROOT/baseline['09I1_ASSISTANT_ACCOUNTS']['path']).read_text();new_accounts=(ROOT/effective['09I1_ASSISTANT_ACCOUNTS']['path']).read_text()
assert old_accounts[old_accounts.index('function A.Receipt'):old_accounts.index('function A.Reserve')]==new_accounts[new_accounts.index('function A.Receipt'):new_accounts.index('function A.Reserve')]
assert 'TextGenerator' not in (ROOT / effective['09I2_ASSISTANT_ENGINE']['path']).read_text()
assert (ROOT / 'AVATAR_PLAZA_V69.html').read_bytes() == (ROOT / 'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html').read_bytes()
assert len(effective) == 146
result = dict(syntax='pass', effective_sources=len(effective), delta_items=45, replace=35, create=10, max_lines=max(s['lines'] for s in v['scripts']), receipt_owner=owners, historical_manifest_hashes_dependencies='pass', match_authority_only_chat_hooks='pass', previous_effective_sources_checked=len(baseline))
(HERE / 'syntax_results.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result))
