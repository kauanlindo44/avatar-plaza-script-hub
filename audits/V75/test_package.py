"""Compile and validate effective sources; preserve historical bytes and paid receipt ownership."""
from pathlib import Path
import hashlib,json,re,sys
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'audits/V43'));from lua_runner import Lua
m=json.loads((ROOT/'manifest.json').read_text());base=json.loads((HERE/'base_manifest.json').read_text())
assert m['latest']=='V75'and base['latest']=='V74'and m['versions'][:-1]==base['versions']
old={s['name']:s for v in base['versions']for s in v['scripts']};effective={s['name']:s for v in m['versions']for s in v['scripts']};v=m['versions'][-1]
new={s['name']for s in v['scripts']if s['action']=='CRIAR'};changed={s['name']for s in v['scripts']if s['action']=='SUBSTITUIR'}
assert new=={'07G9_COMMAND_PANEL','07UI_GAME_AUDIO'}and len(changed)==35 and len(v['scripts'])==37 and len(effective)==173
for name,s in effective.items():
 p=ROOT/s['path'];t=p.read_text();l=Lua()
 try:l.run(t,name,execute=False)
 finally:l.close()
 if s.get('sha256'):assert hashlib.sha256(p.read_bytes()).hexdigest()==s['sha256'],s['path']
 if name not in new|changed:assert s==old[name]
for s in v['scripts']:
 t=(ROOT/s['path']).read_text();assert len(t.splitlines())==s['lines']<=400
 assert t.splitlines()[0]==f"-- {s['name']} | {s['type']} | {s['location']} | V75 ({s['action']})"
 if s['name']in changed:assert s['type']==old[s['name']]['type']and s['location']==old[s['name']]['location']
 for dep in re.findall(r'require\([^\n]*?WaitForChild\(["\']([^"\']+)',t):assert dep in effective,dep
 assert not re.search(r'require\s*\(\s*\d|loadstring\s*\(|getfenv\s*\(|HttpService\s*:\s*(GetAsync|RequestAsync)',t),s['name']
# The inventory records bytes from the published base, including inherited V37 declaration mismatches.
history=json.loads((HERE/'history_inventory.json').read_text());assert len(history)==966
for s in history:assert hashlib.sha256((ROOT/s['path']).read_bytes()).hexdigest()==s['actual_sha256'],'Historical source changed: '+s['path']
inherited=[s['path']for s in history if not s['declaration_matches']];assert len(inherited)==11 and all(p.startswith('scripts/V37/')for p in inherited)
for name in ['07A0_CHESS_RULES','07B0_CHECKERS_RULES','07H4_BOT_ENGINE','07K0_TRUCO_RULES','07K1_TRUCO_AI','07H7_BOARD_SESSIONS','07K_TRUCO_SERVER','07K10_CARD_COMMERCE']:
 assert effective[name]==old[name],name
owners=[n for n,s in effective.items()if re.search(r'Market\.ProcessReceipt\s*=',(ROOT/s['path']).read_text())];assert owners==['07K10_CARD_COMMERCE']
assert (ROOT/'AVATAR_PLAZA_V75.html').read_bytes()==(ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html').read_bytes()
result=dict(syntax='pass',effective_sources=len(effective),delta_sources=len(v['scripts']),create=len(new),replace=len(changed),max_lines=max(s['lines']for s in v['scripts']),history_bytes_unchanged=True,versions_inventoried=len(base['versions']),historical_paths=len(history),inherited_v37_manifest_warnings=inherited,current_declared_hashes='all pass',current_sources_without_declared_hash=sum(not s.get('sha256')for s in effective.values()),previous_game_rules_bots_clocks='unchanged',receipt_owner=owners,native_roblox_tests='PENDENTE')
(HERE/'syntax_results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
