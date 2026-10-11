from test_support import *
import hashlib
m=json.loads((ROOT/'manifest.json').read_text());effective={s['name']:s for v in m['versions']for s in v['scripts']}
for name,spec in effective.items():
 l=Lua()
 try:l.run((ROOT/spec['path']).read_text(),name,execute=False)
 finally:l.close()
v=m['versions'][-1];assert v['id']==m['latest']=='V59'and m['versions'][-2]['id']=='V58'
assert len(v['scripts'])==4 and all(s['action']=='SUBSTITUIR'for s in v['scripts'])
assert {s['name']for s in v['scripts']}=={'09I2_ASSISTANT_ENGINE','09I4_ASSISTANT_UI','09I_ASSISTANT_SERVER','09I_ASSISTANT_CLIENT'}
baseline={s['name']:s for version in m['versions'][:-1]for s in version['scripts']}
assert baseline==json.loads((HERE/'base_sources.json').read_text())
history=json.dumps(m['versions'][:-1],ensure_ascii=False,sort_keys=True,separators=(',',':')).encode()
assert hashlib.sha256(history).hexdigest()==(HERE/'base_versions_sha256.txt').read_text().strip()
legacy={'07P1_CAPTURE_ENGINE','08L_COMMUNITY'}
for spec in v['scripts']:
 text=(ROOT/spec['path']).read_text();assert len(text.splitlines())<=400
 assert hashlib.sha256(text.encode()).hexdigest()==spec['sha256']
 assert text!=(ROOT/baseline[spec['name']]['path']).read_text()
 assert spec['type']==baseline[spec['name']]['type']and spec['location']==baseline[spec['name']]['location']
 for dep in re.findall(r'require\([^\n]*?WaitForChild\(["\']([^"\']+)',text):assert dep in effective or dep in legacy,'Missing '+dep
for spec in baseline.values():
 if spec.get('sha256'):assert hashlib.sha256((ROOT/spec['path']).read_bytes()).hexdigest()==spec['sha256'],spec['path']
owners=[name for name,s in effective.items()if re.search(r'Market\.ProcessReceipt\s*=',(ROOT/s['path']).read_text())]
assert owners==['07K10_CARD_COMMERCE']
assert (ROOT/'AVATAR_PLAZA_V59.html').read_bytes()==(ROOT/'AVATAR_PLAZA_SCRIPT_HUB_PERMANENTE.html').read_bytes()
result={'syntax':'pass','effective_sources':len(effective),'delta_items':4,'replace':4,'create':0,'max_lines':max(s['lines']for s in v['scripts']),'receipt_owner':owners,'historical_manifest_hashes_dependencies':'pass'}
HERE.joinpath('syntax_results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
