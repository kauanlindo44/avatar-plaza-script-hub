"""Parse effective Lua, check metadata, dependencies and exact delta only."""
from test_support import *
m=json.loads((ROOT/'manifest.json').read_text());effective={s['name']:s for v in m['versions']for s in v['scripts']}
for name,spec in effective.items():
 l=Lua()
 try:l.run((ROOT/spec['path']).read_text(),name,execute=False)
 finally:l.close()
v=m['versions'][-1];assert v['id']==m['latest']=='V53'
assert len(v['scripts'])==21 and sum(s['action']=='CRIAR'for s in v['scripts'])==2
for spec in v['scripts']:
 text=(ROOT/spec['path']).read_text();assert len(text.splitlines())<=400
 assert not re.search(r'(?m)^\s*[^-\n]*\+=',text),'Studio Lite incompatible shorthand'
 for dep in re.findall(r'require\([^\n]*?WaitForChild\(["\']([^"\']+)',text):
  assert dep in effective or dep=='08L_COMMUNITY','Missing dependency '+dep # Legacy module supplied with the existing place.
assert not any(s['name']=='09A_SHOP_UI'for s in v['scripts'])
names={s['name']:s for s in v['scripts']}
assert names['08B4_AVATAR_LOAD']['location']=='ReplicatedStorage'
assert names['09B6_CART_RESOLVER']['location']=='ServerScriptService'
result={'syntax':'pass','effective_sources':len(effective),'delta_items':21,'replace':19,'create':2,'dependency_metadata':'pass','max_lines':max(s['lines']for s in v['scripts'])}
HERE.joinpath('syntax_results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))

