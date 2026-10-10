from test_support import *
import hashlib
m=json.loads((ROOT/'manifest.json').read_text());effective={s['name']:s for v in m['versions']for s in v['scripts']}
legacy={'07P1_CAPTURE_ENGINE','08L_COMMUNITY'}
for name,spec in effective.items():
 l=Lua()
 try:l.run((ROOT/spec['path']).read_text(),name,execute=False)
 finally:l.close()
v=m['versions'][-1];assert v['id']==m['latest']=='V57'
assert len(v['scripts'])==7 and all(s['action']=='SUBSTITUIR'for s in v['scripts'])
for spec in v['scripts']:
 text=(ROOT/spec['path']).read_text();assert len(text.splitlines())<=400
 assert hashlib.sha256(text.encode()).hexdigest()==spec['sha256']
 for dep in re.findall(r'require\([^\n]*?WaitForChild\(["\']([^"\']+)',text):assert dep in effective or dep in legacy,'Missing '+dep
assert effective['09C4_OUTFIT_LIBRARY']['path']=='scripts/V55/09C4_OUTFIT_LIBRARY.lua'
assert "Extras.VERSION~='V55'"in src('09C_SHOP_CLIENT')
assert "Extras.VERSION~='V56'"not in src('09C_SHOP_CLIENT')
assert m['versions'][-2]['id']=='V56'
for old in m['versions'][-2:-1]:
 for s in old['scripts']:
  if s.get('sha256'):assert hashlib.sha256((ROOT/s['path']).read_bytes()).hexdigest()==s['sha256'],s['path']
owners=[name for name,s in effective.items()if re.search(r'Market\.ProcessReceipt\s*=',(ROOT/s['path']).read_text())]
assert owners==['07K10_CARD_COMMERCE'],owners
result={'syntax':'pass','effective_sources':len(effective),'delta_items':7,'replace':7,'create':0,'max_lines':max(s['lines']for s in v['scripts']),'receipt_owner':owners,'base_v56_hashes_dependencies':'pass'}
HERE.joinpath('syntax_results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
