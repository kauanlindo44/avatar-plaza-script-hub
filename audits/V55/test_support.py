"""V55 functional and geometry checks in Lua 5.4 doubles, not native Roblox."""
from pathlib import Path
import json,re
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'V43'))
from lua_runner import Lua
HERE=Path(__file__).parent
ROOT=HERE.parents[1]
BASE=HERE.parent/'V43'
MOCK=(BASE/'roblox_mock.lua').read_text()+(BASE/'mock_extensions.lua').read_text()+(HERE.parent/'V48/service_doubles.lua').read_text()+(HERE.parent/'V48/ui_doubles.lua').read_text()
def src(n,v='V55'):
 p=ROOT/'scripts'/v/(n+'.lua')
 if not p.exists()and v=='V55':
  m=json.loads((ROOT/'manifest.json').read_text());paths={s['name']:s['path']for v in m['versions']for s in v['scripts']};p=ROOT/paths[n]
 return p.read_text()
def q(s):return'[====['+s+']====]'
def module(n,v='V55'):return"installModule('"+n+"',"+q(src(n,v))+")\n"
MOCK+=(HERE.parent/'V49/avatar_doubles.lua').read_text()
MOCK+=(HERE.parent/'V51/native_doubles.lua').read_text()
MOCK+=(HERE.parent/'V52/physical_doubles.lua').read_text()
MOCK+=(HERE.parent/'V53/asset_doubles.lua').read_text()
MOCK+=(HERE.parent/'V54/v54_doubles.lua').read_text()
MOCK+=(HERE/'v55_doubles.lua').read_text()
THEME=module('07K14_DECK_OPTIONS')+module('07UI_DESIGN_SYSTEM')+module('07UI_SCREEN_BOUNDS')+module('07G3_PERSONAL_TOOLS')+module('07UI_SURFACE_EFFECTS')
DATA=module('08B3_AVATAR_VERIFY')+module('08B2_BODY_DESCRIPTION')+module('08B1_BODY_PACKAGES')+module('08B_AVATAR_DATA')+"A=Modules['08B_AVATAR_DATA'];HUM=setupAvatar()\n"+module('08D_SKIN_STATE')+"S=Modules['08D_SKIN_STATE'];S.Init()\n"
DATA+=module('08B4_AVATAR_LOAD')
PREVIEW=module('09C6_AVATAR_PREVIEW')+"Preview=Modules['09C6_AVATAR_PREVIEW']\n"
UI=THEME+module('09A4_UTILITY_SKIN')+module('09A2_PREVIEW_LAYOUT')+module('09A1_SHOP_LAYOUT')+"U=loadModule("+q(src('09A_SHOP_UI'))+",'UI').Build(pl);flush()\n"
COMMUNITY=module('09C4_OUTFIT_LIBRARY')+module('09C8_COMMUNITY_DETAILS')+module('09C7_COMMUNITY_FEED')
SERVER=module('09B7_LAST_AVATAR')+module('09B6_CART_RESOLVER')+module('09B5_AVATAR_RUNTIME')+module('09B3_PLAYER_INSPECT')+module('09B2_COSPLAY_METADATA')+module('09B1_AVATAR_DISCOVERY')+module('09B4_CURATED_LOOKS')+"setupServer("+q(src('09B_SHOP_SERVER'))+");flush();HUM=pl.Character:FindFirstChildOfClass('Humanoid')\n"
results=[]
def case(name,code):
 l=Lua()
 try:
  detail=l.run(MOCK+code,name);results.append(dict(case=name,result='pass',detail=detail));print('PASS',name,detail or'',flush=True)
 except Exception:
  HERE.joinpath('failed_'+name+'.lua').write_text(MOCK+code);raise
 finally:l.close()
