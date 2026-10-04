"""V47 functional and geometry checks in Lua 5.4 doubles, not native Roblox."""
from pathlib import Path
import json,re
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'V43'))
from lua_runner import Lua
HERE=Path(__file__).parent
ROOT=HERE.parents[1]
BASE=HERE.parent/'V43'
MOCK=(BASE/'roblox_mock.lua').read_text()+(BASE/'mock_extensions.lua').read_text()+(HERE/'service_doubles.lua').read_text()+(HERE/'ui_doubles.lua').read_text()
def src(n,v='V47'):
 p=ROOT/'scripts'/v/(n+'.lua')
 if not p.exists()and v=='V47':
  m=json.loads((ROOT/'manifest.json').read_text());paths={s['name']:s['path']for v in m['versions']for s in v['scripts']};p=ROOT/paths[n]
 return p.read_text()
def q(s):return'[====['+s+']====]'
def module(n,v='V47'):return"installModule('"+n+"',"+q(src(n,v))+")\n"
THEME=module('07UI_DESIGN_SYSTEM')+module('07UI_SCREEN_BOUNDS')+module('07G3_PERSONAL_TOOLS')
DATA=module('08B_AVATAR_DATA')+"A=Modules['08B_AVATAR_DATA'];HUM=setupAvatar()\n"+module('08D_SKIN_STATE','V41')+"S=Modules['08D_SKIN_STATE'];S.Init()\n"
PREVIEW=module('09C6_AVATAR_PREVIEW')+"Preview=Modules['09C6_AVATAR_PREVIEW']\n"
UI=THEME+module('09A2_PREVIEW_LAYOUT')+module('09A1_SHOP_LAYOUT')+"U=loadModule("+q(src('09A_SHOP_UI'))+",'UI').Build(pl);flush()\n"
COMMUNITY=module('09C4_OUTFIT_LIBRARY')+module('09C8_COMMUNITY_DETAILS')+module('09C7_COMMUNITY_FEED')
SERVER=module('09B3_PLAYER_INSPECT')+module('09B2_COSPLAY_METADATA')+module('09B1_AVATAR_DISCOVERY')+module('09B4_CURATED_LOOKS')+"setupServer("+q(src('09B_SHOP_SERVER'))+")\n"
results=[]
def case(name,code):
 l=Lua()
 try:
  detail=l.run(MOCK+code,name);results.append(dict(case=name,result='pass',detail=detail));print('PASS',name,detail or'',flush=True)
 except Exception:
  HERE.joinpath('failed_'+name+'.lua').write_text(MOCK+code);raise
 finally:l.close()
