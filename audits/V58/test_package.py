from test_support import *
import hashlib
m=json.loads((ROOT/'manifest.json').read_text());effective={s['name']:s for v in m['versions']for s in v['scripts']}
legacy={'07P1_CAPTURE_ENGINE','08L_COMMUNITY'}
for name,spec in effective.items():
 l=Lua()
 try:l.run((ROOT/spec['path']).read_text(),name,execute=False)
 finally:l.close()
v=m['versions'][-1];assert v['id']==m['latest']=='V58'
assert len(v['scripts'])==27 and sum(s['action']=='SUBSTITUIR'for s in v['scripts'])==26
new=[s for s in v['scripts']if s['action']=='CRIAR'];assert len(new)==1 and new[0]['name']=='07UI_SLIDER'and new[0]['type']=='ModuleScript'and new[0]['location']=='ReplicatedStorage'
for spec in v['scripts']:
 text=(ROOT/spec['path']).read_text();assert len(text.splitlines())<=400
 assert hashlib.sha256(text.encode()).hexdigest()==spec['sha256']
 for dep in re.findall(r'require\([^\n]*?WaitForChild\(["\']([^"\']+)',text):assert dep in effective or dep in legacy,'Missing '+dep
assert effective['09C4_OUTFIT_LIBRARY']['path']=='scripts/V58/09C4_OUTFIT_LIBRARY.lua'
assert "Extras.VERSION~='V58'"in src('09C_SHOP_CLIENT')
assert m['versions'][-2]['id']=='V57'
baseline={s['name']:s for version in m['versions'][:-1]for s in version['scripts']}
assert baseline==json.loads((HERE/'base_sources.json').read_text()),'historical manifest changed'
for s in baseline.values():
 if s.get('sha256'):assert hashlib.sha256((ROOT/s['path']).read_bytes()).hexdigest()==s['sha256'],s['path']
for old in m['versions'][:-1]:
 if old['id']not in {'V44','V55','V56','V57'}:continue
 for s in old['scripts']:
  if s.get('sha256'):assert hashlib.sha256((ROOT/s['path']).read_bytes()).hexdigest()==s['sha256'],s['path']
owners=[name for name,s in effective.items()if re.search(r'Market\.ProcessReceipt\s*=',(ROOT/s['path']).read_text())]
assert owners==['07K10_CARD_COMMERCE'],owners
assert (ROOT/'AVATAR_PLAZA_V58.html').read_bytes()==(ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html').read_bytes()
result={'syntax':'pass','effective_sources':len(effective),'delta_items':27,'replace':26,'create':1,'max_lines':max(s['lines']for s in v['scripts']),'receipt_owner':owners,'historical_manifest_hashes_dependencies':'pass'}
HERE.joinpath('syntax_results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
