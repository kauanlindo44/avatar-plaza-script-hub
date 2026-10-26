"""Source-built geometry review; not the Roblox renderer or physical device testing."""
from test_support import *
HERE.joinpath('layouts').mkdir(exist_ok=True)
DUMP=r'''
local function str(s)return '"'..tostring(s):gsub('\\','\\\\'):gsub('"','\\"'):gsub('\n','\\n'):gsub('\r','\\r'):gsub('\t','\\t')..'"'end
local function json(v)
 local t=type(v);if t=='string'then return str(v)elseif t=='boolean'then return v and'true'or'false'elseif t=='number'then return v==v and tostring(v)or'0'elseif t~='table'then return'null'end
 local out={};if #v>0 then for _,x in ipairs(v)do out[#out+1]=json(x)end;return'['..table.concat(out,',')..']'end
 for k,x in pairs(v)do out[#out+1]=str(k)..':'..json(x)end;return'{'..table.concat(out,',')..'}'
end
local function color(v)if not v or not v.R then return nil end;return{math.floor(v.R*255+.5),math.floor(v.G*255+.5),math.floor(v.B*255+.5)}end
local classes={Frame=true,TextLabel=true,TextBox=true,TextButton=true,ImageLabel=true,ImageButton=true,ScrollingFrame=true,ViewportFrame=true}
local function dump(o)
 if o.Visible==false or not classes[o.ClassName]then return end
 -- Native AbsolutePosition is relative to the core-safe origin; exported canvas is full-screen.
 local p,z=o.AbsolutePosition,o.AbsoluteSize;local n={name=o.Name,class=o.ClassName,x=p.X+(CORE_LEFT or 0),y=p.Y+(CORE_TOP or 0),w=z.X,h=z.Y,z=o.ZIndex,opacity=1-(o.BackgroundTransparency or 0),bg=color(o.BackgroundColor3),clip=o.ClipsDescendants==true,rotation=o.Rotation or 0}
 local corner=o:FindFirstChildOfClass('UICorner');if corner then n.radius=corner.CornerRadius.Scale*math.min(z.X,z.Y)+corner.CornerRadius.Offset end
 local stroke=o:FindFirstChildOfClass('UIStroke');if stroke then n.stroke=color(stroke.Color);n.strokeOpacity=1-(stroke.Transparency or 0);n.strokeWidth=stroke.Thickness or 1 end
 if o:IsA('TextLabel')or o:IsA('TextButton')or o:IsA('TextBox')then n.text=o.Text;n.placeholder=o.PlaceholderText;n.font=o.TextSize or 14;n.ink=color(o.TextColor3);n.bold=tostring(o.Font):find('Bold')~=nil;n.textOpacity=1-(o.TextTransparency or 0);n.wrap=o.TextWrapped==true;n.align=tostring(o.TextXAlignment);n.valign=tostring(o.TextYAlignment);n.scaled=o.TextScaled==true;local pad=o:FindFirstChildOfClass('UIPadding');if pad then n.padLeft=pad.PaddingLeft.Offset;n.padRight=pad.PaddingRight.Offset end end
 if o.ClassName=='ImageLabel'or o.ClassName=='ImageButton'then n.image=o.Image end
 n.children={};for _,child in ipairs(o:GetChildren())do local row=dump(child);if row then n.children[#n.children+1]=row end end
 return n
end
pg:SetAttribute('ACP_HalloweenMode','Off');pg:SetAttribute('ACP_HalloweenEnabled',false);Modules['07UI_HALLOWEEN_THEME'].Start(pg);flush()
local nodes={};for _,o in ipairs(EXPORT_GUI:GetChildren())do local row=dump(o);if row then nodes[#nodes+1]=row end end
local file=assert(io.open(EXPORT_PATH,'w'));file:write(json({width=SCREEN_W,height=SCREEN_H,nodes=nodes,label=EXPORT_LABEL}));file:close()
return EXPORT_PATH
'''
SCENES={}
LIBRARY=THEME+module('07K6_CARD_CATALOG')+module('07K7_CARD_STYLES')+module('07H5_TRUCO_SETUP')+module('07H1_GAME_LOBBY')
HUD=THEME+module('07G6_WORLD_DETAILS')+module('07G4_WORLD_SCENERY')+module('07G7_ADVENTURE_WORLD')+module('07G2_LOCAL_WORLDS')+module('07G1_HUB_SETTINGS')
CHAOS=THEME+module('BC_Config')+module('BC_HUD')+module('BC_VisualEffects')
SCENES['library']=(LIBRARY,"local d=Modules['07UI_DESIGN_SYSTEM'];local gui=d.New('ScreenGui',{Name='GameClubGui'},pg);local u=Modules['07H1_GAME_LOBBY'].Build(gui);flush();u.Root.Visible=true;u.OpenLibrary();EXPORT_GUI=gui")
SCENES['game_detail']=(LIBRARY,"local d=Modules['07UI_DESIGN_SYSTEM'];local gui=d.New('ScreenGui',{Name='GameClubGui'},pg);local u=Modules['07H1_GAME_LOBBY'].Build(gui);flush();u.Root.Visible=true;u.SetGame('Xadrez');EXPORT_GUI=gui")
SCENES['hud']=(HUD+src('07G_HUB_UI'),"flush();EXPORT_GUI=pg.LimitedMarketHUD;for _,o in ipairs(pg.AvatarShopLauncherGui:GetChildren())do o.Parent=EXPORT_GUI end")
SCENES['chaos_queue']=(CHAOS,"local d=Modules['07UI_DESIGN_SYSTEM'];local gui=d.New('ScreenGui',{Name='BC_GameGui'},pg);local u=Modules.BC_HUD.Build(gui);flush();u.Set({phase='QUEUE',queue=1});EXPORT_GUI=gui")
SCENES['chaos_match']=(CHAOS,"local d=Modules['07UI_DESIGN_SYSTEM'];local gui=d.New('ScreenGui',{Name='BC_GameGui'},pg);local u=Modules.BC_HUD.Build(gui);flush();u.Set({phase='ACTIVE',matchId='round',alive=true,remaining=128,score=3,aliveCount=7,health=100,lastEffect='Blaster de energia',effects={},weapon={name='Blaster de energia',ammo=3,remaining=12}});EXPORT_GUI=gui")
SCENES['chaos_results']=(CHAOS,"local d=Modules['07UI_DESIGN_SYSTEM'];local gui=d.New('ScreenGui',{Name='BC_GameGui'},pg);local u=Modules.BC_HUD.Build(gui);flush();local rows={};for i=1,8 do rows[i]={id=i,name='Jogador '..i,score=13-i,winner=i==1,alive=i<5}end;u.Set({phase='RESULTS',matchId='round',winner=true,remaining=10,roster=rows});EXPORT_GUI=gui")
SCENES['sponsor']=(UI+DATA+PREVIEW+module('07UI_PAN_GRID')+module('09C10_SPONSOR_DESIGN')+module('09C11_SPONSOR_FEED')+module('09C9_SPONSOR_PICKER')+module('09C12_DESTINATION_BROWSER')+module('09C5_UGC_STORES'),r"""
local rows={};for i=1,60 do local item=fixture60(1000+i,'Peça de estilo '..i,'Shirt');rows[#rows+1]={key='Asset:'..item.Id,item=item,temporary=false}end
function Services.AvatarEditorService:SearchCatalogAsync()return{IsFinished=true,GetCurrentPage=function()return{}end}end
local ctl=Modules['09C5_UGC_STORES'].Init({U=U,A=A,S=S,call=function(action)if action=='HighlightFeed'then return{items=rows,finished=true}end;return{}end,toast=function()end,showItem=function()end,openAssistant=function()end});U.Root.Visible=true;U.ActivePage='Stores';U.SetWide(false);U.StoresArea.Visible=true;for _,o in ipairs({U.Query,U.SearchGo,U.Filter,U.Sort,U.Groups.Parent,U.More,U.Grid,U.Status})do o.Visible=false end;ctl.Search();flush();U.Layout();flush();Preview.Mount(U.Viewport,S.Current,S.Rig,{drag=true,floor=true});EXPORT_GUI=U.Gui
""")
# Additional source-built scenes for V75.
BOARD=THEME+module('07H2_GAME_BOARD')+module('07A0_CHESS_RULES')+module('07B0_CHECKERS_RULES')
TRUCO=THEME+module('07K0_TRUCO_RULES')+module('07K6_CARD_CATALOG')+module('07K7_CARD_STYLES')+module('07H8_PLAY_SESSION')+module('07K15_TRUCO_TABLE')+module('07K5_TRUCO_UI')
SCENES['board']=(BOARD,"local d=Modules['07UI_DESIGN_SYSTEM'];local gui=d.New('ScreenGui',{Name='GameClubGui'},pg);local u=Modules['07H2_GAME_BOARD'].Build(gui);u.Root.Visible=true;u.Draw(Modules['07A0_CHESS_RULES'].New(),'Xadrez','W',nil,{});u.SetTimes(284,291);u.Layout();EXPORT_GUI=gui")
SCENES['checkers']=(BOARD,"local d=Modules['07UI_DESIGN_SYSTEM'];local gui=d.New('ScreenGui',{Name='GameClubGui'},pg);local u=Modules['07H2_GAME_BOARD'].Build(gui);u.Root.Visible=true;u.Title.Text='Damas';u.Draw(Modules['07B0_CHECKERS_RULES'].New(),'Damas','W',nil,{});u.SetTimes(284,291);u.Layout();EXPORT_GUI=gui")
SCENES['photo']=(THEME+module('07P4_STUDIO_UI')+module('07P9_STUDIO_CATALOG'),"local u=Modules['07P4_STUDIO_UI'].Build(pl);u.Root.Visible=true;u.Popup.Visible=true;function Services.AvatarEditorService:SearchCatalogAsync()local r={};for i=1,30 do r[i]={Id=100+i,Name='Emote '..i,Price=50}end;return{IsFinished=true,GetCurrentPage=function()return r end}end;Modules['07P9_STUDIO_CATALOG'].Open(u,'Animations',function()end,function()end,{pause=function()return true,true end,speed=function()end});flush();u.Layout();EXPORT_GUI=u.Gui")
SCENES['assistant']=(THEME+DATA+PREVIEW+module('09I4_ASSISTANT_UI')+module('09I6_ASSISTANT_RESULTS'),"local u=Modules['09I4_ASSISTANT_UI'].Build(pl);u.Root.Visible=true;u.ConversationEmpty=false;u.Add('Crie 6 looks azuis até 100 Robux',true);local r=Modules['09I6_ASSISTANT_RESULTS'].Build(u,function()return true end,function()end);local rows={};for i=1,6 do rows[i]={name='Azul casual '..i,total=85,body=A.Copy(S.Current),rig='R15'}end;r.Accept({looks=rows,plan='Pro'});u.Layout();EXPORT_GUI=u.Gui")
SCENES['commands']=(HUD+src('07G_HUB_UI'),"flush();pg:SetAttribute('ACP_OpenCommandsNonce',1);pg:GetAttributeChangedSignal('ACP_OpenCommandsNonce'):Fire();flush();EXPORT_GUI=pg.LimitedMarketHUD")
SCENES['loader']=(UI,"U.Root.Visible=false;U.Loader.Visible=true;U.Layout();EXPORT_GUI=U.Gui")
SCENES['truco']=(TRUCO,"local d=Modules['07UI_DESIGN_SYSTEM'];local gui=d.New('ScreenGui',{Name='ACP_Truco'},pg);local u=Modules['07K5_TRUCO_UI'].Build(gui,function()end);local v={seat=1,variant='Paulista',score={3,2},phase='play',turn=1,hand={{rank='3',suit='S'},{rank='A',suit='H'},{rank='K',suit='D'}},players={{uid=123,name='Você'},{uid=2,name='Rival'},{uid=3,name='Parceiro'},{uid=4,name='Rival 2'}},tableCards={{seat=2,card={rank='2',suit='H'}},{seat=3,card={rank='A',suit='S'}}},tricks={},lastTrick={},counts={3,2,2,3},value=1,nextRaise=3,handNumber=1,remaining=30,dealer=4};u.Update(v,{equipped='Classic'});u.Layout();EXPORT_GUI=gui")
SCENES['tools']=(HUD+src('07G_HUB_UI'),"flush();named(pg.LimitedMarketHUD,'AvatarTools').Activated:Fire();flush();EXPORT_GUI=pg.LimitedMarketHUD")
SCENES['background']=(SCENES['photo'][0],SCENES['photo'][1].replace("'Animations'","'Background'").replace("'Emote '","'Fundo '"))
SCENES['studio']=(THEME+module('07P4_STUDIO_UI'),"local u=Modules['07P4_STUDIO_UI'].Build(pl);u.Root.Visible=true;u.Layout();EXPORT_GUI=u.Gui")
SCENES['catalog_home']=(UI+DATA+module('09C16_CATALOG_HOME'),"local home=Modules['09C16_CATALOG_HOME'].Build({U=U,A=A,browse=function()end,call=function()return{items={}}end,toast=function()end});U.Root.Visible=true;U.SetWide(false);home.Open();EXPORT_GUI=U.Gui")
SCENES['settings']=(HUD+src('07G_HUB_UI'),"flush();named(pg.LimitedMarketHUD,'Cfg').Activated:Fire();flush();EXPORT_GUI=pg.LimitedMarketHUD")
SCENES['wearing']=(UI+DATA+PREVIEW+module('09C18_AVATAR_SAVE'),"local save=Modules['09C18_AVATAR_SAVE'].Build({U=U,A=A,S=S,call=function()return true end,toast=function()end,buyBody=function()end});U.Root.Visible=false;save.Wearing();flush();save.Layout();EXPORT_GUI=U.Gui")
SCENES['catalog_items']=(UI+DATA+PREVIEW+module('09C4_OUTFIT_LIBRARY')+module('09C3_CATALOG_FILTERS')+module('09C2_SHOP_CATALOG'),r"""
local rows={};for i=1,48 do rows[i]=fixture60(1000+i,'Peça de estilo '..i,'Shirt');rows[i].Price=15+i end
function Services.AvatarEditorService:SearchCatalogAsync()return{IsFinished=true,GetCurrentPage=function()return rows end}end
local ctl=Modules['09C2_SHOP_CATALOG'].Init({U=U,A=A,S=S,toast=function()end,call=function()return true end});U.Root.Visible=true;U.SetWide(false);U.Grid.Visible=true;U.Groups.Parent.Visible=true;U.Query.Visible=true;U.SearchGo.Visible=true;U.Filter.Visible=true;U.Sort.Visible=true;U.SubToggle.Visible=true;U.Status.Visible=true
ctl.Search();flush();U.Layout();ctl.Resize();EXPORT_GUI=U.Gui
""")
selected=set(__import__('sys').argv[1:])
for name,(pre,scene)in SCENES.items():
 if selected and name not in selected:continue
 for label,w,h,cut,bottom in [('desktop',1280,720,0,0),('phone',390,844,0,34),('landscape',851,392,44,21)]:
  l=Lua();path=HERE/'layouts'/f'{name}_{label}.json'
  try:
   setup=f'SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM,CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM={w},{h},{cut},{cut},{bottom},{cut},{cut},58,0\n'
   l.run(MOCK+setup+'Services.UserInputService.TouchEnabled=SCREEN_W<1000\n'+pre+'\n'+scene+f'\nEXPORT_PATH={q(str(path))};EXPORT_LABEL={q(name+" · "+label)}\n'+DUMP,name)
   print(path.name)
  finally:l.close()
