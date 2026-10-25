"""Compile the effective manifest, verify dependency/type/hash contracts and historical bytes."""
from pathlib import Path
import hashlib,json,re,sys
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'audits/V43'));from lua_runner import Lua
m=json.loads((ROOT/'manifest.json').read_text());base=json.loads((HERE/'base_manifest.json').read_text())
assert m['latest']=='V77'and base['latest']=='V76'and m['versions'][:-1]==base['versions']
old={s['name']:s for v in base['versions']for s in v['scripts']};effective={s['name']:s for v in m['versions']for s in v['scripts']};v=m['versions'][-1]
new={s['name']for s in v['scripts']if s['action']=='CRIAR'};changed={s['name']for s in v['scripts']if s['action']=='SUBSTITUIR'}
assert new=={'07UI_REFERENCE_LAYOUT','07G11_REFERENCE_WORLDS','07H12_SCORE_SHEET','09C20_AVATAR_REMOVAL','09I27_STYLE_CATALOG'}
assert len(changed)==24 and len(effective)==180
for name,s in effective.items():
 p=ROOT/s['path'];t=p.read_text();l=Lua()
 try:l.run(t,name,execute=False)
 finally:l.close()
 if s.get('sha256'):assert hashlib.sha256(p.read_bytes()).hexdigest()==s['sha256'],s['path']
 if name not in new|changed:assert s==old[name]
for s in v['scripts']:
 t=(ROOT/s['path']).read_text();assert len(t.splitlines())==s['lines']<=400
 assert t.splitlines()[0]==f"-- {s['name']} | {s['type']} | {s['location']} | V77 ({s['action']})"
 if s['name']in changed:assert s['type']==old[s['name']]['type']and s['location']==old[s['name']]['location']
 for dep in re.findall(r'require\([^\n]*?WaitForChild\(["\']([^"\']+)',t):assert dep in effective or dep=='08L_COMMUNITY',dep
 assert not re.search(r'require\s*\(\s*\d|loadstring\s*\(|getfenv\s*\(|HttpService\s*:\s*(GetAsync|RequestAsync)',t),s['name']
history=json.loads((HERE/'history_inventory.json').read_text());assert len(history)==1017
for s in history:assert hashlib.sha256((ROOT/s['path']).read_bytes()).hexdigest()==s['actual_sha256'],'Historical source changed: '+s['path']
inherited=[s['path']for s in history if not s['declaration_matches']];assert len(inherited)==11 and all(p.startswith('scripts/V37/')for p in inherited)
for name in ['07A0_CHESS_RULES','07B0_CHECKERS_RULES','07H4_BOT_ENGINE','07K0_TRUCO_RULES','07K1_TRUCO_AI','07K_TRUCO_SERVER','07K10_CARD_COMMERCE','BC_Config','BC_Combat','BC_EffectExecutor','BC_RoundManager','09I0_ASSISTANT_CONFIG','09I1_ASSISTANT_ACCOUNTS','09I25_PLAN_PRODUCTS','09I26_REQUEST_GUARD']:
 assert effective[name]==old[name],name
before=(ROOT/old['07H7_BOARD_SESSIONS']['path']).read_text();after=(ROOT/effective['07H7_BOARD_SESSIONS']['path']).read_text()
clock=lambda s:re.search(r'local function clock\(s\)[\s\S]*?\nend',s).group()
assert clock(before)==clock(after)
for invariant in ["clock={W=300,B=300}","s.clock[mover]+3","s.rules.Apply(s.state,move,promotion)","s.rules.Result(s.state)"]:
 assert invariant in before and invariant in after
owners=[n for n,s in effective.items()if re.search(r'Market\.ProcessReceipt\s*=',(ROOT/s['path']).read_text())];assert owners==['07K10_CARD_COMMERCE']
assert(ROOT/'AVATAR_PLAZA_V77.html').read_bytes()==(ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html').read_bytes()
result=dict(syntax='pass',compiler='Lua 5.4 compatibility; not native Luau/Roblox',effective_sources=len(effective),delta_sources=len(v['scripts']),create=len(new),replace=len(changed),max_lines=max(s['lines']for s in v['scripts']),history_bytes_unchanged=True,historical_paths=len(history),versions_inventoried=len(base['versions']),inherited_v37_manifest_warnings=inherited,current_declared_hashes='all declared hashes pass',current_sources_without_declared_hash=sum(not s.get('sha256')for s in effective.values()),game_rule_and_bot_modules='unchanged',board_clock_and_rule_invocations='unchanged; added accepted-move log',receipt_owner=owners,legacy_place_dependency=['08L_COMMUNITY'],native_roblox_tests='PENDENTE')
(HERE/'syntax_results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
