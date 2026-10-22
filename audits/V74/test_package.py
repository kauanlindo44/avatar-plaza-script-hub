"""Validate immutable delta, source types, dependencies, game integrity and installer package."""
from test_support import *
import hashlib
m=json.loads((ROOT/'manifest.json').read_text());base=json.loads((HERE/'base_manifest.json').read_text())
assert m['latest']=='V74'and base['latest']=='V73'and m['versions'][:-1]==base['versions']
old={s['name']:s for v in base['versions']for s in v['scripts']};effective={s['name']:s for v in m['versions']for s in v['scripts']};v=m['versions'][-1]
new={'07H11_GAME_LIBRARY','09I25_PLAN_PRODUCTS','BC_Config','BC_ArenaBuilder','BC_Queue','BC_RoundManager','BC_ButtonController','BC_EffectRegistry','BC_EffectExecutor','BC_Combat','BC_PlayerState','BC_HUD','BC_VisualEffects','BC_Integration','BC_Server','BC_Client'}
changed={'07G_HUB_UI','07H1_GAME_LOBBY','07H_GAME_UI','01C_HUB_CHALLENGES','07K_TRUCO_SERVER','07G_SETTINGS_SERVER','07G3_PERSONAL_TOOLS','09B5_AVATAR_RUNTIME','09C5_UGC_STORES','09I7_ASSISTANT_PROFILE','09I_ASSISTANT_SERVER','09I9_GAME_GUIDE'}
assert len(v['scripts'])==28 and v['base_version']=='V73'
assert{s['name']for s in v['scripts']if s['action']=='CRIAR'}==new
assert{s['name']for s in v['scripts']if s['action']=='SUBSTITUIR'}==changed
for name,s in effective.items():
 p=ROOT/s['path'];t=p.read_text();l=Lua()
 try:l.run(t,name,execute=False)
 finally:l.close()
 if name not in new|changed:assert s==old[name]
 if s.get('sha256'):assert hashlib.sha256(p.read_bytes()).hexdigest()==s['sha256'],s['path']
for s in v['scripts']:
 t=(ROOT/s['path']).read_text();assert len(t.splitlines())==s['lines']<=400
 assert t.splitlines()[0]==f"-- {s['name']} | {s['type']} | {s['location']} | V74 ({s['action']})"
 if s['name']in changed:assert s['type']==old[s['name']]['type']and s['location']==old[s['name']]['location']
 else:assert s['name']not in old
 for dep in re.findall(r'require\([^\n]*?WaitForChild\(["\']([^"\']+)',t):assert dep in effective or dep in {'07Z_BOARD_VISUALS','07P1_CAPTURE_ENGINE','08L_COMMUNITY'},dep
for s in old.values():
 if s.get('sha256'):assert hashlib.sha256((ROOT/s['path']).read_bytes()).hexdigest()==s['sha256'],'Historical source changed: '+s['path']
assert len(effective)==171
owners=[n for n,s in effective.items()if re.search(r'Market\.ProcessReceipt\s*=',(ROOT/s['path']).read_text())];assert owners==['07K10_CARD_COMMERCE']
# The Truco authority differs only in its two admission guards and metadata header.
a=(ROOT/old['07K_TRUCO_SERVER']['path']).read_text().splitlines()[1:]
b=[line for line in src('07K_TRUCO_SERVER').splitlines()[1:]if 'BC_MatchId'not in line];assert a==b
for name in ['07A0_CHESS_RULES','07B0_CHECKERS_RULES','07H4_BOT_ENGINE','07K0_TRUCO_RULES','07K1_TRUCO_AI','07H7_BOARD_SESSIONS','07K10_CARD_COMMERCE']:
 assert effective[name]==old[name]
assert (ROOT/'AVATAR_PLAZA_V74.html').read_bytes()==(ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html').read_bytes()
result=dict(syntax='pass',effective_sources=171,delta_items=28,replace=12,create=16,max_lines=max(s['lines']for s in v['scripts']),receipt_owner=owners,history_unchanged=True,existing_game_rules_bots_and_clocks_unchanged=True,native_tests='PENDENTE DE TESTE')
(HERE/'syntax_results.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n');print(json.dumps(result))
