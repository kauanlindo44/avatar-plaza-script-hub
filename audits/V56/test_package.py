from test_support import *
import hashlib
m=json.loads((ROOT/'manifest.json').read_text());effective={s['name']:s for v in m['versions']for s in v['scripts']}
# Existing pre-V41 modules listed explicitly in the V42/V43 installation prerequisites.
legacy={'07P1_CAPTURE_ENGINE','08L_COMMUNITY'}
for name,spec in effective.items():
 l=Lua()
 try:l.run((ROOT/spec['path']).read_text(),name,execute=False)
 finally:l.close()
v=m['versions'][-1];assert v['id']==m['latest']=='V56'
assert len(v['scripts'])==32 and sum(s['action']=='CRIAR'for s in v['scripts'])==4
for spec in v['scripts']:
 text=(ROOT/spec['path']).read_text();assert len(text.splitlines())<=400
 assert hashlib.sha256(text.encode()).hexdigest()==spec['sha256']
 for dep in re.findall(r'require\([^\n]*?WaitForChild\(["\']([^"\']+)',text):assert dep in effective or dep in legacy,'Missing '+dep
names={s['name']:s for s in v['scripts']};assert '09A_SHOP_UI'not in names and '07A0_CHESS_RULES'not in names
assert names['09I_ASSISTANT_SERVER']['type']=='Script'and names['09I_ASSISTANT_SERVER']['location']=='ServerScriptService'
assert names['09I_ASSISTANT_CLIENT']['type']=='LocalScript'and names['09I_ASSISTANT_CLIENT']['location']=='StarterPlayer > StarterPlayerScripts'
assert effective['07M0_MUSIC_PREFS']['type']=='ModuleScript'and effective['07M0_MUSIC_PREFS']['location']=='ServerScriptService'
assert effective['09I0_ASSISTANT_CONFIG']['location']=='ReplicatedStorage'
owners=[]
for name,spec in effective.items():
 text=(ROOT/spec['path']).read_text()
 if re.search(r'Market\.ProcessReceipt\s*=',text):owners.append(name)
assert owners==['07K10_CARD_COMMERCE'],owners
newcode='\n'.join((ROOT/s['path']).read_text()for s in v['scripts'])
assert '3716300364'not in re.sub(r'--[^\n]*','',newcode)
result={'syntax':'pass','effective_sources':len(effective),'delta_items':32,'replace':28,'create':4,'max_lines':max(s['lines']for s in v['scripts']),'receipt_owner':owners,'dependencies_and_hashes':'pass'}
HERE.joinpath('syntax_results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
