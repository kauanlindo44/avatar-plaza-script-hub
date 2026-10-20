"""V62 focused and geometry checks in Lua 5.4 doubles, not native Roblox."""
from pathlib import Path
import json,re
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'V43'))
from lua_runner import Lua
HERE=Path(__file__).parent
ROOT=HERE.parents[1]
BASE=HERE.parent/'V43'
MOCK=(BASE/'roblox_mock.lua').read_text()+(BASE/'mock_extensions.lua').read_text()+(HERE.parent/'V48/service_doubles.lua').read_text()+(HERE.parent/'V48/ui_doubles.lua').read_text()
def src(n,v='V72'):
 p=ROOT/'scripts'/v/(n+'.lua')
 if not p.exists()and v=='V72':
  m=json.loads((HERE/'base_manifest.json').read_text());paths={s['name']:s['path']for v in m['versions']for s in v['scripts']};p=ROOT/paths[n]
 return p.read_text()
def q(s):return'[====['+s+']====]'
def module(n,v='V72'):
 if v=='V72'and n=='09I4_ASSISTANT_UI':return module('09I23_REQUEST_PROGRESS')+"installModule('"+n+"',"+q(src(n,v))+")\n"
 if v=='V72'and n=='09I5_ASSISTANT_QUESTIONNAIRE':return DATA+PREVIEW+module('09I0_ASSISTANT_CONFIG')+module('09I21_LOOK_CONTRACT')+module('09I22_BODY_CHOOSER')+"installModule('"+n+"',"+q(src(n,v))+")\n"
 if v=='V72'and n=='09I3_OUTFIT_BUILDER':return module('09I0_ASSISTANT_CONFIG')+module('09I21_LOOK_CONTRACT')+module('09B14_AVATAR_BASES')+module('09I24_LOOK_BATCHES')+"installModule('"+n+"',"+q(src(n,v))+")\n"
 return"installModule('"+n+"',"+q(src(n,v))+")\n"
MOCK+=(HERE.parent/'V49/avatar_doubles.lua').read_text()
MOCK+=(HERE.parent/'V51/native_doubles.lua').read_text()
MOCK+=(HERE.parent/'V52/physical_doubles.lua').read_text()
MOCK+=(HERE.parent/'V53/asset_doubles.lua').read_text()
MOCK+=(HERE.parent/'V54/v54_doubles.lua').read_text()
MOCK+=(HERE.parent/'V55/v55_doubles.lua').read_text()
MOCK+=(HERE.parent/'V56/v56_doubles.lua').read_text()
MOCK+=(HERE.parent/'V57/v57_doubles.lua').read_text()
MOCK+=(HERE.parent/'V58/v58_doubles.lua').read_text()
THEME=module('09I8_AVATAR_STYLES')+module('09I12_REQUEST_PLAN')+module('09I9_GAME_GUIDE')+module('07UI_HALLOWEEN_THEME')+module('08B5_AVATAR_DIAGNOSTICS')+module('07K14_DECK_OPTIONS')+module('07UI_DESIGN_SYSTEM')+module('07UI_SCREEN_BOUNDS')+module('07G5_CHAT_COMMANDS')+module('07G3_PERSONAL_TOOLS')+module('07UI_SURFACE_EFFECTS')
THEME+=module('07H10_MATCH_CHAT_UI')+module('07UI_SLIDER')+module('07UI_CHOICE_LIST')+module('09I10_CHAT_NAV')
DATA=module('08B8_ACCESSORY_REFINEMENT')+module('08B5_AVATAR_DIAGNOSTICS')+module('08B3_AVATAR_VERIFY')+module('08B2_BODY_DESCRIPTION')+module('08B1_BODY_PACKAGES')+module('08B_AVATAR_DATA')+"A=Modules['08B_AVATAR_DATA'];HUM=setupAvatar()\n"+module('08D_SKIN_STATE')+"S=Modules['08D_SKIN_STATE'];S.Init()\n"
DATA+=module('08B4_AVATAR_LOAD')
PREVIEW=module('09C6_AVATAR_PREVIEW')+"Preview=Modules['09C6_AVATAR_PREVIEW']\n"
UI=THEME+module('09A4_UTILITY_SKIN')+module('09A2_PREVIEW_LAYOUT')+module('09A1_SHOP_LAYOUT')+"U=loadModule("+q(src('09A_SHOP_UI'))+",'UI').Build(pl);flush()\n"
COMMUNITY=module('09C4_OUTFIT_LIBRARY')+module('09C8_COMMUNITY_DETAILS')+module('09C7_COMMUNITY_FEED')
SERVER=module('08B7_AVATAR_ANIMATIONS')+module('07P11_EMOTE_RESOLVER')+module('08B6_AVATAR_MOVEMENT')+module('09B7_LAST_AVATAR')+module('09B6_CART_RESOLVER')+module('09B5_AVATAR_RUNTIME')+module('09B3_PLAYER_INSPECT')+module('09B2_COSPLAY_METADATA')+module('09B1_AVATAR_DISCOVERY')+module('09B4_CURATED_LOOKS')+"setupServer("+q(src('09B_SHOP_SERVER'))+");flush();HUM=pl.Character:FindFirstChildOfClass('Humanoid')\n"
results=[]
def case(name,code):
 l=Lua()
 try:
  detail=l.run(MOCK+code,name);results.append(dict(case=name,result='pass',detail=detail));print('PASS',name,detail or'',flush=True)
 except Exception:
  HERE.joinpath('failed_'+name+'.lua').write_text(MOCK+code);raise
 finally:l.close()

MOCK+=(HERE.parent/'V59/v59_doubles.lua').read_text()
MOCK+=(HERE.parent/'V60/v60_doubles.lua').read_text()
MOCK+=(HERE.parent/'V61/v61_doubles.lua').read_text()
MOCK+=(HERE.parent/'V62/v62_doubles.lua').read_text()
MOCK+=(HERE.parent/'V63/v63_doubles.lua').read_text()

MOCK+=(HERE.parent/'V64/v64_doubles.lua').read_text()

MOCK+=(HERE.parent/'V65/v65_doubles.lua').read_text()

MOCK+=(HERE.parent/'V66/v66_doubles.lua').read_text()
MOCK+=(HERE.parent/'V67/v67_doubles.lua').read_text()
MOCK+=(HERE.parent/'V68/v68_doubles.lua').read_text()
MOCK+=(HERE/'v69_doubles.lua').read_text()

THEME+=module('07G8_VEGETATION_PLAN')+module('09I15_ACTIVITY_RULES')+module('09I19_REHEARSAL_CUES')
MOCK+=module('07H9_MATCH_CHAT')

THEME+=module('09I20_ASSISTANT_APPEARANCE')

MOCK+='Services.UserInputService.TouchPinch=signal()\n'

MOCK+=(HERE/'v72_doubles.lua').read_text()
DATA+=module('09B11_DATA_BUDGET')+module('09B13_PURCHASE_HISTORY')
SERVER=module('09B14_AVATAR_BASES')+SERVER
