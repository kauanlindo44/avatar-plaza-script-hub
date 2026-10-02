"""Selected UI and integration logic, using Lua 5.4 and Roblox service doubles.
This is not a Roblox Studio playtest or a rendering test.
"""
from pathlib import Path
import json,re
from lua_runner import Lua
ROOT=Path(__file__).resolve().parents[2]
MOCK=Path(__file__).with_name('roblox_mock.lua').read_text()
def src(n,v='V40'):return (ROOT/'scripts'/v/(n+'.lua')).read_text()
def q(s):
 assert ']====]'not in s
 return '[====['+s+']====]'
THEME="installModule('07UI_DESIGN_SYSTEM',"+q(src('07UI_DESIGN_SYSTEM','V40_1'))+")\n"
results=[]
def case(name,code):
 l=Lua()
 try:
  result=l.run(MOCK+THEME+code,name);results.append(dict(case=name,result='pass',detail=result));print('PASS',name,result or '')
 finally:l.close()
for p in sorted((ROOT/'scripts/V40_1').glob('*.lua')):
 s=p.read_text();assert len(s.splitlines())<=400,p
 assert not re.search(r'(?:\+|-|\*|/|\.\.)=',s),p
 l=Lua();l.run(s,p.name,execute=False);l.close()
results.append(dict(case='syntax_and_limits',result='pass',detail='1 changed module, <=400 lines, no compound assignments'))
case('shop_dialogs_and_editor_bounds',"U=loadModule("+q(src('09A_SHOP_UI'))+",'09A').Build(pl);flush()\n"+'''
for _,s in ipairs({{320,604},{360,604},{800,324},{1460,785},{1920,1040}})do
 SCREEN_W,SCREEN_H=s[1],s[2];U.Root:GetPropertyChangedSignal('AbsoluteSize'):Fire();flush()
 for _,d in ipairs({U.SaveBox,U.PublishBox,U.RigBox,U.LoaderCard,U.CartPanel})do inside(d,U.Gui)end
 for _,b in ipairs({U.SaveName,U.SaveR15,U.SaveR6,U.CancelSave})do inside(b,U.SaveBox)end
 for _,b in ipairs({U.PublishName,U.PublishConfirm,U.PublishCancel})do inside(b,U.PublishBox)end
 for _,b in ipairs({U.RigToR15,U.RigCancel})do inside(b,U.RigBox)end
 assert(not intersects(U.SaveR6,U.SaveR15));assert(not intersects(U.PublishConfirm,U.PublishCancel))
 U.SetWide(false);U.ShowPreview();flush();inside(U.Left,U.Root);inside(U.Viewport,U.Left);inside(U.Actions,U.Left)
 for _,b in ipairs({U.Apply,U.Save,U.Reset,U.BuyLook})do inside(b,U.Left)end
 for _,m in ipairs({'AVATAR','CORPO','ITENS','EMOTES'})do U.LayoutEditor(m);inside(U.EditorTabs,U.Left);inside(U.EditorArea,U.Left);assert(not intersects(U.EditorArea,U.Actions))end
end
return 'dialogues and editor controls fit five safe viewports'
''')
case('hud_reference_layout_and_actions',"local k=Instance.new('Folder');k.Name='PracaKit';k.Parent=rep\n"+src('07G_HUB_UI')+'''
flush();local hud=pg:FindFirstChild('LimitedMarketHUD');local r=hud:FindFirstChild('HudRoot');local top=pg:FindFirstChild('AvatarShopLauncherGui').Launcher
local calls={};local shop=Instance.new('ScreenGui');shop.Name='AvatarShop08Gui';shop.Parent=pg
for _,n in ipairs({'OpenRequest','HudAction'})do local e=Instance.new('BindableEvent');e.Name=n;e.Parent=shop;e.Event:Connect(function(a)calls[#calls+1]={n,a}end)end
for _,s in ipairs({{320,604},{360,604},{800,324},{1460,785},{1920,1040}})do
 SCREEN_W,SCREEN_H=s[1],s[2];r:GetPropertyChangedSignal('AbsoluteSize'):Fire();flush()
 for _,p in ipairs({r,top})do for _,b in ipairs(p:GetChildren())do if b:IsA('GuiButton')and b.Visible then inside(b,p)end end end
 assert(not intersects(top.TopCatalog,top.TopStores));assert(top.TopCatalog.AbsolutePosition.Y<r.Community.AbsolutePosition.Y)
 r.Cfg.Activated:Fire();inside(r.Settings,r);assert(not top.Visible);named(r.Settings,'CloseCfg').Activated:Fire();assert(top.Visible)
end
for _,pair in ipairs({{top.TopCatalog,'Catalog'},{top.TopStores,'Stores'},{r.Community,'Community'},{r.Loader,'Loader'},{r.Looks,'Looks'},{r.Emotes,'Emotes'},{r.Avatar,'Preview'},{top.Cart,'Cart'},{top.Blank,'Blank'},{r.SaveRoblox,'SaveRoblox'},{r.Reset,'Reset'}})do
 pair[1].Activated:Fire();flush();assert(calls[#calls][2]==pair[2])
end
r.Games.Activated:Fire();assert(pg:GetAttribute('ACP_OpenGamesNonce')==1)
r.Photo.Activated:Fire();assert(pg:GetAttribute('ACP_OpenPhotoNonce')==1)
return 'reference arrangement, music binding and 13 actions verified'
''')
case('lobby_modes_waiting_and_bounds',"local g=Instance.new('ScreenGui');g.Parent=pg;L=loadModule("+q(src('07H1_GAME_LOBBY'))+",'Lobby').Build(g)\n"+'''
for _,s in ipairs({{320,604},{360,604},{800,324},{1460,785},{1920,1040}})do
 SCREEN_W,SCREEN_H=s[1],s[2];L.Layout()
 for _,b in pairs(L.GameButtons)do inside(b,L.Root)end
 for _,b in pairs(L.ModeButtons)do inside(b,L.Root)end
 inside(L.Close,L.Root);L.SetWaiting('A7KD',false);inside(L.Cancel,L.Root);inside(L.Status,L.Root);assert(not intersects(L.Cancel,L.Status));L.Reset()
end
L.SetGame('Damas');L.SetCounts({Damas=2});assert(L.QueueCount.Text:find('2 sala'))
L.ModeButtons.Friends.Activated:Fire();assert(L.Mode=='Friends')
L.SetWaiting('A7KD',false);assert(L.Cancel.Visible and L.CodeDisplay.Text=='A7KD');assert(not L.ModeButtons.Practice.Active)
L.SetGame('Batata');L.ModeButtons.Practice.Activated:Fire();assert(L.Selected=='Damas'and L.Mode=='Friends')
L.SelectCode.Activated:Fire();assert(L.CodeDisplay.focused and L.CodeDisplay.SelectionStart==5)
L.Reset();L.ModeButtons.Practice.Activated:Fire();L.DiffButtons.DIFICIL.Activated:Fire();assert(L.Difficulty=='DIFICIL'and L.Mode=='Practice')
L.SetBusy(true);assert(not L.Bot.Active);L.SetGame('Xadrez');assert(L.Selected=='Damas');L.SetBusy(false)
return 'real waiting state, locked modes, selectable code and accessible cancel'
''')
case('board_responsive_and_piece_mapping',"local g=Instance.new('ScreenGui');g.Parent=pg;B=loadModule("+q(src('07H2_GAME_BOARD'))+",'Board').Build(g)\n"+'''
for _,s in ipairs({{320,604},{360,604},{800,324},{1460,785},{1920,1040}})do
 SCREEN_W,SCREEN_H=s[1],s[2];B.Layout();inside(B.Grid,B.Root);inside(B.Side,B.Root);inside(B.Promotion,B.Root);inside(B.Confirm,B.Root)
 for vr=1,8 do for vc=1,8 do inside(B.Cells[vr][vc],B.Grid)end end
 assert(not intersects(B.Turn,B.Resign)and not intersects(B.Turn,B.Claim));inside(B.Resign,B.Side);inside(B.Claim,B.Side)
end
local st={board={{[1]={c='B',t='K'}}}};B.Draw(st,'Xadrez','B',nil,{['1:1']=true})
assert(B.Cells[8][8].PieceIcon and B.Cells[8][8].Hint.Visible);assert(not B.Cells[1][1].PieceIcon)
B.SetTimes(601,59);assert(B.WhiteClock.Text=='10:01'and B.BlackClock.Text=='0:59')
B.SetTraining(true,'Fácil');assert(B.TrainingInfo.Visible and not B.ClockRow.Visible)
B.SetTurn('SUA VEZ',true);assert(B.Turn.Text=='SUA VEZ')
return 'square cells, inverted board, visible clocks and responsive actions'
''')

GAME_ENV="""
local kit=Instance.new('Folder');kit.Name='PracaKit';kit.Parent=rep
local rem=Instance.new('Folder');rem.Name='Remotes';rem.Parent=kit
local event=Instance.new('RemoteEvent');event.Name='HubGameUI';event.Parent=rem;GameEvent=event
local rq=Instance.new('RemoteFunction');rq.Name='GameRoomRequest';rq.Parent=rem
local push=Instance.new('RemoteEvent');push.Name='GameRoomPush';push.Parent=rem;RoomPush=push
requests={};sent={};failure=false
function event:FireServer(...)sent[#sent+1]={...}end
function rq:InvokeServer(action,arg)
 requests[#requests+1]={action,arg}
 if failure then return{ok=false,error='Falha controlada'}end
 if action=='stats'then return{ok=true,waiting={Xadrez=2,Damas=0,Batata=1}}end
 if action=='cancel'or action=='leave'then push.OnClientEvent:Fire('roomClosed');return{ok=true}end
 if action=='join'then push.OnClientEvent:Fire('matched',{game='Xadrez',tableName='Sala1',code=arg});return{ok=true,code=arg,matched=true,game='Xadrez'}end
 return{ok=true,code='A7KD',game=arg}
end
local old=Instance.new('ScreenGui');old.Name='LimitedMarketHUD';old.Parent=pg
local disabled=Instance.new('ScreenGui');disabled.Name='ACP_TitlesGui';disabled.Enabled=false;disabled.Parent=pg
"""
GAME_ENV+="installModule('07A0_CHESS_RULES',"+q(src('07A0_CHESS_RULES','V37'))+")\n"
GAME_ENV+="installModule('07B0_CHECKERS_RULES',"+q(src('07B0_CHECKERS_RULES','V37'))+")\n"
for n,target in [('07H1_GAME_LOBBY','GL'),('07H2_GAME_BOARD','GB')]:
 GAME_ENV+="local mod=installModule('"+n+"',"+q(src(n))+");local build=mod.Build;mod.Build=function(g) "+target+"=build(g);return "+target+" end\n"
GAME_ENV+=src('07H_GAME_UI')+'\n'
case('game_controller_room_contract_and_failures',GAME_ENV+r"""
pg:SetAttribute('ACP_OpenGamesNonce',1);flush();assert(GL.Root.Visible and not pg.LimitedMarketHUD.Enabled)
local n=#requests;GL.Code.Text='bad';GL.Join.Activated:Fire();assert(#requests==n)
GL.ModeButtons.Friends.Activated:Fire();GL.Create.Activated:Fire();assert(GL.WaitingState and GL.CodeDisplay.Text=='A7KD')
assert(requests[#requests][1]=='create'and requests[#requests][2]=='Xadrez')
GL.Quick.Activated:Fire();assert(requests[#requests][1]=='create')
failure=true;GL.Cancel.Activated:Fire();assert(GL.WaitingState and GL.Status.Text=='Falha controlada');failure=false
GL.Cancel.Activated:Fire();assert(not GL.WaitingState and GL.Root.Visible and not pg.LimitedMarketHUD.Enabled);flush()
GL.Code.Text=' a7 kd ';GL.Join.Activated:Fire();assert(requests[#requests][1]=='join'and requests[#requests][2]=='A7KD')
assert(not GL.Root.Visible)
local board=Modules['07A0_CHESS_RULES'].New().board
GameEvent.OnClientEvent:Fire('boardOpen',{game='Xadrez',tableName='Sala1',side='B',board=board,turn='W'})
assert(GB.Root.Visible and GB.Grid.Visible and GB.Claim.Visible)
GameEvent.OnClientEvent:Fire('boardState',{tableName='Sala1',board=board,turn='B',whiteTime=600,blackTime=421,message='Sua vez',hints={{r=2,c=3}}})
assert(GB.WhiteClock.Text=='10:00'and GB.BlackClock.Text=='7:01'and GB.Turn.Text=='SUA VEZ')
GB.Cells[8][8].Activated:Fire();assert(sent[#sent][1]=='boardTap'and sent[#sent][3]==1 and sent[#sent][4]==1)
GB.Minimize.Activated:Fire();assert(GB.Mini.Visible and pg.LimitedMarketHUD.Enabled and not pg.ACP_TitlesGui.Enabled)
GB.Mini.Activated:Fire();assert(GB.Root.Visible and not pg.LimitedMarketHUD.Enabled)
GB.Resign.Activated:Fire();GB.ConfirmYes.Activated:Fire();assert(sent[#sent][1]=='resignGame')
GameEvent.OnClientEvent:Fire('boardClose',{tableName='Sala1'});assert(not GB.Root.Visible and pg.LimitedMarketHUD.Enabled)
pg:SetAttribute('ACP_OpenGamesNonce',2);flush();GL.Close.Activated:Fire();assert(pg.LimitedMarketHUD.Enabled and not pg.ACP_TitlesGui.Enabled)
return 'create/join/cancel, cancellation failure, push race, board RPC and HUD restoration'
""")
case('bot_training_and_stale_potato_callback',GAME_ENV+r"""
pg:SetAttribute('ACP_OpenGamesNonce',1);flush();GL.ModeButtons.Practice.Activated:Fire();GL.Bot.Activated:Fire()
assert(GB.Root.Visible and GB.TrainingInfo.Visible and not GB.ClockRow.Visible)
GB.Cells[7][5].Activated:Fire();assert(GB.Cells[5][5].Hint.Visible)
GB.Cells[5][5].Activated:Fire();flush();assert(GB.Cells[5][5].PieceIcon and GB.Turn.Text=='SUA VEZ')
GB.Resign.Activated:Fire();assert(GL.Root.Visible and not GB.Root.Visible)
GL.SetGame('Batata');GL.DiffButtons.FACIL.Activated:Fire();math.random=function(a,b)return a end;GL.Bot.Activated:Fire()
GB.PotatoButtons[2].Activated:Fire();assert(GB.Turn.Text=='BOT JOGANDO')
GB.PotatoButtons[3].Activated:Fire();assert(GB.PotatoButtons[3].Text=='3')
GB.Resign.Activated:Fire();GL.Bot.Activated:Fire();flush();assert(GB.PotatoButtons[1].Text=='1'and GB.PotatoButtons[2].Text=='2')
GB.PotatoButtons[2].Activated:Fire();flush();assert(GB.Resign.Text=='Voltar aos jogos'and GB.Turn.Text=='VOCÊ VENCEU')
GB.Resign.Activated:Fire();assert(GL.Root.Visible)
return 'legal chess training, turn lock, clear result and stale callback cancellation'
""")
case('online_potato_overlay_and_leave',GAME_ENV+r"""
GameEvent.OnClientEvent:Fire('potatoOpen',{tableName='SalaBatata'})
assert(GB.Root.Visible and GB.Root.BackgroundTransparency==1 and not GB.Grid.Visible and not GB.Potato.Visible)
GameEvent.OnClientEvent:Fire('potatoState',{tableName='SalaBatata',message='Seu turno'});assert(GB.Message.Text=='Seu turno')
GB.Resign.Activated:Fire();assert(GB.ConfirmYes.Text=='Sair da sala');GB.ConfirmYes.Activated:Fire()
assert(requests[#requests][1]=='leave'and not GB.Root.Visible)
return 'physical online table kept visible, honest status and room leave'
""")
SHOP_ENV="""
script.Parent=Instance.new('Folder')
installModule('09A_SHOP_UI',SHOP_SOURCE)
local original=Modules['09A_SHOP_UI'].Build;Modules['09A_SHOP_UI'].Build=function(p)Shop=original(p);return Shop end
local state={Rig='R15',Current=nil,Changed=Instance.new('BindableEvent')};Skin=state
function state.Blank()state.blank=true;return true end
function state.Reset()state.reset=true;return true end
function state.Description()return{Destroy=function()state.descDestroyed=true end}end
Modules['08D_SKIN_STATE']=state;local sk=Instance.new('ModuleScript');sk.Name='08D_SKIN_STATE';sk.Parent=rep
local data={};Modules['08B_AVATAR_DATA']=data;local ad=Instance.new('ModuleScript');ad.Name='08B_AVATAR_DATA';ad.Parent=rep
function Services.AvatarEditorService:PromptSaveAvatar(d,rig)state.saved=rig end
function Services.Players:GetUserIdFromNameAsync()return 456 end
function Services.Players:GetNameFromUserIdAsync()return 'Example'end
function Services.Players:GetUserInfosByUserIdsAsync()return{{DisplayName='Example'}}end
function Services.Players:GetHumanoidDescriptionFromUserIdAsync()return{Destroy=function()end}end
function data.Pack()return{}end
local extras={Init=function()end,Open=function()Shop.CartPanel.Visible=true end}
Modules['09C4_OUTFIT_LIBRARY']=extras;local ex=Instance.new('ModuleScript');ex.Name='09C4_OUTFIT_LIBRARY';ex.Parent=rep
for _,name in ipairs({'09C2_SHOP_CATALOG','09C1_SHOP_LOOKS','09C5_UGC_STORES'})do
 local o=Instance.new('ModuleScript');o.Name=name;o.Parent=rep
 Modules[name]={Init=function()return{Search=function()end,Preset=function()end,Saved=function()end,Community=function()end}end}
end
""".replace('SHOP_SOURCE',q(src('09A_SHOP_UI')))+src('09C_SHOP_CLIENT')+'\nflush()\n'
case('shop_client_hud_and_loader_integration',SHOP_ENV+r"""
for _,s in ipairs({{320,604},{360,604},{800,324},{1460,785}})do
 SCREEN_W,SCREEN_H=s[1],s[2];Shop.Root:GetPropertyChangedSignal('AbsoluteSize'):Fire();Shop.LoaderCard:GetPropertyChangedSignal('AbsoluteSize'):Fire();flush()
 for _,b in ipairs({Shop.LoaderThumb,Shop.LoaderName,Shop.LoaderStatus,Shop.LoaderQuery,Shop.LoaderSearch})do inside(b,Shop.LoaderCard)end
 for _,b in ipairs(Shop.LoaderCard:GetChildren())do if b:IsA('GuiButton')then inside(b,Shop.LoaderCard)end end
 assert(not intersects(Shop.LoaderThumb,Shop.LoaderName)and not intersects(Shop.LoaderThumb,Shop.LoaderStatus))
 Shop.OpenRequest:Fire('Preview');assert(Shop.Root.Visible and Shop.Left.Visible)
end
Shop.HudAction:Fire('Cart');assert(Shop.Root.Visible and Shop.CartPanel.Visible)
Shop.CartPanel.Visible=false;Shop.HudAction:Fire('Blank');assert(Skin.blank and Shop.Left.Visible)
Shop.HudAction:Fire('Reset');assert(Skin.reset);Shop.HudAction:Fire('SaveRoblox');assert(Skin.saved==Enum.HumanoidRigType.R15 and Skin.descDestroyed)
Shop.OpenRequest:Fire('Loader');assert(Shop.Loader.Visible and not Shop.Root.Visible);Shop.LoaderQuery.Text='@Example';Shop.LoaderSearch.Activated:Fire();flush()
assert(Shop.LoaderUse.Visible and Shop.LoaderStatus.Text=='Avatar pronto. Escolha R6 ou R15 para experimentar.')
Shop.LoaderClose.Activated:Fire();assert(not Shop.Loader.Visible and not Shop.LoaderUse.Visible)
return 'all new HUD actions, avatar preview, responsive loader and honest loading state'
""")

case('fullscreen_coverage_with_core_and_device_insets',"U=loadModule("+q(src('09A_SHOP_UI'))+",'Shop').Build(pl);flush()\n"+"local g=Modules['07UI_DESIGN_SYSTEM'].New('ScreenGui',{Name='GameClubGui',DisplayOrder=120,IgnoreGuiInset=false,ResetOnSpawn=false},pg);L=loadModule("+q(src('07H1_GAME_LOBBY'))+",'Lobby').Build(g);B=loadModule("+q(src('07H2_GAME_BOARD'))+",'Board').Build(g)\n"+r"""
local shopBack=pg:FindFirstChild('AvatarShop08Gui_FullBackground');local gameBack=pg:FindFirstChild('GameClubGui_FullBackground')
assert(shopBack and gameBack,'fullscreen backgrounds missing')
for _,back in ipairs({shopBack,gameBack})do
 assert(back.IgnoreGuiInset and back.ScreenInsets==Enum.ScreenInsets.None and not back.ClipToDeviceSafeArea)
 assert(back.SafeAreaCompatibility==Enum.SafeAreaCompatibility.None)
 assert(not back.FullscreenFill.Active and not back.FullscreenFill.Selectable)
end
for _,v in ipairs({{360,640,0,0,36,0},{360,780,0,0,64,22},{844,390,44,44,58,22},{1460,821,0,0,36,0},{1920,1080,0,0,88,0}})do
 SCREEN_W,SCREEN_H,CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=table.unpack(v)
 U.Root:GetPropertyChangedSignal('AbsoluteSize'):Fire();L.Layout();B.Layout();flush()
 U.Root.Visible=true;L.Root.Visible=true
 assert(shopBack.Enabled and gameBack.Enabled)
 for _,back in ipairs({shopBack,gameBack})do local p,z=back.FullscreenFill.AbsolutePosition,back.FullscreenFill.AbsoluteSize
  assert(p.X==0 and p.Y==0 and z.X==SCREEN_W and z.Y==SCREEN_H,'background does not cover viewport')
 end
 assert(U.Root.AbsolutePosition.Y==CORE_TOP and U.Root.AbsoluteSize.Y<SCREEN_H,'test must reproduce the reserved top strip')
 inside(U.Close,U.Gui);inside(L.Close,g);inside(B.Minimize,g)
 assert(shopBack.DisplayOrder==U.Gui.DisplayOrder-1 and gameBack.DisplayOrder==g.DisplayOrder-1)
end
U.Root.Visible=false;assert(not shopBack.Enabled)
U.Loader.Visible=true;assert(shopBack.Enabled and shopBack.FullscreenFill.BackgroundTransparency==U.Loader.BackgroundTransparency)
U.Gui.Enabled=false;assert(not shopBack.Enabled);U.Gui.Enabled=true;assert(shopBack.Enabled)
U.Loader.Visible=false;assert(not shopBack.Enabled)
L.Root.Visible=false;assert(not gameBack.Enabled)
B.Root.Visible=true;assert(gameBack.Enabled);B.Root.BackgroundTransparency=1;assert(not gameBack.Enabled)
B.Root.BackgroundTransparency=0;assert(gameBack.Enabled);B.Root.Visible=false;B.Mini.Visible=true;assert(not gameBack.Enabled)
return 'viewport filled at 36/58/64/88 px top insets, notches and bottom inset; controls remain accessible'
""")
case('fullscreen_owner_lifecycle_and_rebuild',r"""
local D=Modules['07UI_DESIGN_SYSTEM']
local owner=D.New('ScreenGui',{Name='AvatarShop08Gui',DisplayOrder=90,IgnoreGuiInset=false},pg)
local root=D.New('Frame',{Size=UDim2.fromScale(1,1),BackgroundColor3=D.Colors.bg},owner)
local old=pg.AvatarShop08Gui_FullBackground;assert(old.Enabled)
owner.DisplayOrder=140;assert(old.DisplayOrder==139)
old.Enabled=false;assert(old.Enabled,'background must follow the visible owner')
owner.Enabled=false;old.Enabled=true;assert(not old.Enabled);owner.Enabled=true;assert(old.Enabled)
root.BackgroundColor3=D.Colors.red;assert(old.FullscreenFill.BackgroundColor3==D.Colors.red)
root.Parent=nil;assert(not old.Enabled);root.Parent=owner;assert(old.Enabled)
owner:Destroy();assert(old.destroyed and not pg:FindFirstChild('AvatarShop08Gui_FullBackground'))
local second=D.New('ScreenGui',{Name='AvatarShop08Gui',DisplayOrder=90,IgnoreGuiInset=false},pg)
local r=D.New('Frame',{Size=UDim2.fromScale(1,1),BackgroundColor3=D.Colors.bg},second)
local count=0;for _,o in ipairs(pg:GetChildren())do if o.Name=='AvatarShop08Gui_FullBackground'then count=count+1 end end
assert(count==1,'duplicate fullscreen layer');local back=pg.AvatarShop08Gui_FullBackground
second.Parent=nil;assert(back.Parent==nil);second.Parent=pg;assert(back.Parent==pg and back.Enabled)
return 'rebuild, disable, reparent, order, color and cleanup without persistent overlay'
""")
Path(__file__).with_name('results.json').write_text(json.dumps(results,indent=2,ensure_ascii=False)+'\n')
print('Validated',len(results),'cases')
