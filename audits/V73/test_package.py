"""Check the shipped delta and all effective sources against the immutable V72 base."""
from test_support import *
import hashlib
m=json.loads((ROOT/'manifest.json').read_text());base=json.loads((HERE/'base_manifest.json').read_text());assert m['latest']=='V73'and base['latest']=='V72'and m['versions'][:-1]==base['versions']
old={s['name']:s for v in base['versions']for s in v['scripts']};effective={s['name']:s for v in m['versions']for s in v['scripts']};v=m['versions'][-1]
expected={'09A1_SHOP_LAYOUT','09C5_UGC_STORES','09C2_SHOP_CATALOG','09C_SHOP_CLIENT','09I4_ASSISTANT_UI','09I_ASSISTANT_CLIENT','09I_ACTIVITIES_CLIENT','07M_MUSIC_CLIENT'}
assert {s['name']for s in v['scripts']}==expected and len(v['scripts'])==8 and all(s['action']=='SUBSTITUIR'for s in v['scripts'])and v['base_version']=='V72'
for name,s in effective.items():
 p=ROOT/s['path'];t=p.read_text();l=Lua()
 try:l.run(t,name,execute=False)
 finally:l.close()
 if name not in expected:assert s==old[name]
 if s.get('sha256'):assert hashlib.sha256(p.read_bytes()).hexdigest()==s['sha256'],s['path']
for s in v['scripts']:
 t=(ROOT/s['path']).read_text();assert len(t.splitlines())==s['lines']<=400
 assert t.splitlines()[0]==f"-- {s['name']} | {s['type']} | {s['location']} | V73 (SUBSTITUIR)"
 assert s['type']==old[s['name']]['type']and s['location']==old[s['name']]['location']
 for dep in re.findall(r'require\([^\n]*?WaitForChild\(["\']([^"\']+)',t):assert dep in effective or dep in {'07Z_BOARD_VISUALS','07P1_CAPTURE_ENGINE','08L_COMMUNITY'},dep
for s in old.values():
 if s.get('sha256'):assert hashlib.sha256((ROOT/s['path']).read_bytes()).hexdigest()==s['sha256'],'Historical source changed: '+s['path']
assert len(effective)==155
owners=[n for n,s in effective.items()if re.search(r'Market\.ProcessReceipt\s*=',(ROOT/s['path']).read_text())];assert owners==['07K10_CARD_COMMERCE']
assert (ROOT/'AVATAR_PLAZA_V73.html').read_bytes()==(ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html').read_bytes()
result=dict(syntax='pass',effective_sources=155,delta_items=8,replace=8,create=0,max_lines=max(s['lines']for s in v['scripts']),receipt_owner=owners,history_unchanged=True,server_and_games_unchanged=True)
(HERE/'syntax_results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
