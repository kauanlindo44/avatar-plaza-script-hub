from test_support import *
BASE=THEME+DATA+module('08B6_AVATAR_MOVEMENT')+module('BC_Config')+r'''BCSetup()'''
for name in ['BC_Queue','BC_ArenaBuilder','BC_PlayerState','BC_Integration','BC_EffectRegistry','BC_Combat','BC_EffectExecutor','BC_ButtonController','BC_RoundManager']:
 BASE+="BCInstall('"+name+"',"+q(src(name))+")\n"
BASE+=r'''
local C=Modules.BC_Config;local arena=Modules.BC_ArenaBuilder.Build();local rng=BCRandom();local clock=0;local messages={}
local G=Modules.BC_RoundManager.New({arena=arena,now=function()return clock end,random=rng,serverId='test-server',ready=function(p)return not p:GetAttribute('AvatarBusyFixture')end,push=function(p,k,d)messages[#messages+1]={p=p,k=k,d=d}end})
local function add(id,rig)local p=BCPlayer(id,rig);BC_PLAYERS[#BC_PLAYERS+1]=p;return p end
local function tick(n)clock=clock+(n or .1);G.Tick()end
local function start(n)
 local out={};for i=1,n do out[i]=add(100+i);assert(G.Join(out[i]))end
 tick(0);tick(12);assert(G.round and G.round.phase=='COUNTDOWN');tick(5);assert(G.round.phase=='ACTIVE');return table.unpack(out)
end
local function at(p,v)local s=G.round.players[p];s.char:PivotTo(CFrame.new(v-s.root.Position)*s.char:GetPivot());return s end
local function button(p)at(p,arena.Cap.Position+Vector3.new(0,2.4,0));return G.button.Press(p)end
'''
