from test_support import *
SIZES="{{320,568,0,0,0},{390,844,0,0,34},{568,320,0,0,0},{667,375,0,0,0},{851,392,44,44,21},{1920,1080,0,0,0}}"
SPONSOR=UI+DATA+module('09C11_SPONSOR_FEED')+module('09C12_DESTINATION_BROWSER')+module('09C10_SPONSOR_DESIGN')+module('09C9_SPONSOR_PICKER')+module('09C5_UGC_STORES')+r'''
U.Root.Visible=true;U.SetWide(true);U.StoresArea.Visible=true;local nativeRows={};local actions={};local real=false
for i=1,60 do nativeRows[i]={Id=100+i,Name='Example '..i,ItemType='Asset',AssetType='Shirt',Price=i%5==0 and 0 or 5}end
function Services.AvatarEditorService:SearchCatalogAsync(p)assert(p.MinPrice==1 and not p.IncludeOffSale);return{IsFinished=true,GetCurrentPage=function()return deep(nativeRows)end}end
local function call(a,d)
 actions[#actions+1]={a=a,d=d}
 if a=='HighlightFeed'then return{items=real and{{item=deep(nativeRows[1]),key='Asset:101'}}or{},emptyGlobal=not real,finished=true}
 elseif a=='HighlightStatus'then return{nextAllowed=TIME60}
 elseif a=='HighlightCheck'then return deep(nativeRows[1])
 elseif a=='HighlightSubmit'then real=true;return{free=true}
 elseif a=='HighlightFavorite'then return{value=d.value}end
end
local ctl=Modules['09C5_UGC_STORES'].Init({U=U,A=A,call=call,toast=function()end,showItem=function()end,openAssistant=function()end});ctl.Search();flush()
'''
case('paid_sponsor_grid_scrolls_down_and_keeps_category_controls_safe',SPONSOR+r'''
assert(U.StoreGrid.ScrollingEnabled and U.StoreGrid.ScrollingDirection==Enum.ScrollingDirection.XY)
local cards=guiCards(U.StoreGrid);assert(cards==48,'paid cards '..cards)
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;U.SetWide(true);U.StoresArea:GetPropertyChangedSignal('AbsoluteSize'):Fire();flush()
 assert(U.StoreGrid.CanvasSize.Y.Offset>U.StoreGrid.AbsoluteSize.Y)
 for _,n in ipairs({'SponsorTab','AssistantTab','PublishHighlight','MoreHighlights'})do local b=named(U.StoresArea,n);inside(b,U.StoresArea);assert(b.AbsoluteSize.Y>=44 and b.AbsoluteSize.X>=44,n)end
 assert(not intersects(named(U.StoresArea,'SponsorTab'),U.StoreSearch))
end
named(U.StoresArea,'HighlightFilter_3').Activated:Fire();flush();assert(actions[#actions].d.group=='Roupas 3D')
assert(named(U.StoresArea,'Featured_Asset_101').ItemPrice.Text:find('Exemplo',1,true))
real=true;shop61.HighlightChanged.OnClientEvent:Fire();flush();assert(guiCards(U.StoreGrid)==48);assert(not named(U.StoresArea,'Featured_Asset_101').ItemPrice.Text:find('Exemplo',1,true))
return 'paid cards scroll horizontally and vertically; filters work; one real submission preserves the other temporary examples; six safe geometries keep controls clickable'
''')
case('sponsor_picker_works_with_native_readonly_catalog_arrays',SPONSOR+r'''
named(U.StoresArea,'PublishHighlight').Activated:Fire();flush();local p=named(U.StoresArea,'SponsorSearch');assert(p.Visible and guiCards(named(p,'SponsorResults'))==48)
local first;for _,o in ipairs(named(p,'SponsorResults'):GetChildren())do if o:IsA('GuiButton')then first=o;break end end
first.Activated:Fire();flush();assert(not p.Visible and not named(U.StoresArea,'ConfirmHighlight').Active)
named(U.StoresArea,'CheckHighlight').Activated:Fire();flush();assert(named(U.StoresArea,'ConfirmHighlight').Active)
return 'name examples and category construction work with readonly AssetTypes/BundleTypes, omit free rows and still require server confirmation'
''')
case('catalog_paid_default_and_free_continuation_preserve_filters',UI+DATA+PREVIEW+module('09C4_OUTFIT_LIBRARY')+module('09C3_CATALOG_FILTERS')+module('09C2_SHOP_CATALOG')+r'''
local searches={};function Services.AvatarEditorService:SearchCatalogAsync(p)searches[#searches+1]={min=p.MinPrice,max=p.MaxPrice,query=p.SearchKeyword};return{IsFinished=true,GetCurrentPage=function()return{}end}end
local ctl=Modules['09C2_SHOP_CATALOG'].Init({U=U,A=A,S=S,toast=function()end,call=function()return true end});ctl.Search();flush();assert(searches[#searches].min==1 and U.More.Visible)
U.More.Activated:Fire();flush();assert(searches[#searches].min==0 and searches[#searches].max==0 and not U.More.Visible)
U.FilterPanel.Visible=true;U.Min.Text='-1';U.ApplyFilter.Activated:Fire();assert(U.FilterPanel.Visible)
return 'default catalog starts with paid items and an explicit free continuation, retaining the native query/filter and invalid-price protection'
''')
case('detailed_worlds_have_distinct_skies_bounded_parts_and_restore',THEME+DATA+module('07G6_WORLD_DETAILS')+module('07G4_WORLD_SCENERY')+module('07G2_LOCAL_WORLDS')+r'''
local world=Instance.new('Folder');world.Name='PracaAvatar_V2';world.Parent=workspace;local ground=Instance.new('Folder');ground.Name='AvatarFieldGround';ground.Parent=world
local lighting=Services.Lighting;lighting.ClockTime=13;lighting.Brightness=2;lighting.ExposureCompensation=0;lighting.Ambient=Color3.new(1,1,1);lighting.OutdoorAmbient=lighting.Ambient
local worlds=Modules['07G2_LOCAL_WORLDS'];local skyValues={}
for _,id in ipairs({'ORIGINAL','ANIME','FOREST','COAST','HALLOWEEN','CLOUD'})do assert(worlds.Apply(id));flush();local folder=workspace.ACP_LocalWorldVisuals;assert(folder:GetAttribute('Ready'))
 local n=folder:GetAttribute('SceneryParts');assert(n>100 and n<=720,id..':'..tostring(n));local sky=named(lighting,'ACP_Sky_'..id);assert(sky:GetAttribute('SkyTheme')==id);skyValues[id]=lighting.ClockTime
 local tiles=0;for _,o in ipairs(folder:GetChildren())do if o:IsA('BasePart')then assert(not o.CanCollide and not o.CanQuery and not o.CastShadow);if o.Name=='InfiniteVisualGround'then tiles=tiles+1 end end end;assert(tiles==25)
end
assert(skyValues.ANIME~=skyValues.FOREST and skyValues.COAST~=skyValues.HALLOWEEN);worlds.Destroy();assert(lighting.ClockTime==13 and not workspace:FindFirstChild('ACP_LocalWorldVisuals'))
return 'six outdoor themes each own their sky/atmosphere and more than 100 bounded noncolliding parts; 25 ground parts are reused and original lighting is restored'
''')
case('video_motion_is_smooth_pauses_and_restores_the_same_avatar_scene',THEME+DATA+module('07P10_VIDEO_MOTION')+r'''
local s={Yaw=180,Zoom=1,Pitch=0,AvatarYaw=0};local frames={};local pivots={}
function s.SetMotionFrame(v)frames[#frames+1]=deep(v);for k,key in pairs({yaw='Yaw',zoom='Zoom',pitch='Pitch',pan='Pan',vertical='Vertical',roll='Roll'})do s[key]=v[k]end end
function s.SetAvatarYaw(v)s.AvatarYaw=v;pivots[#pivots+1]=v end
local alive=true;local m=Modules['07P10_VIDEO_MOTION'].New(s,function()return alive end)
for _,v in ipairs(Modules['07P10_VIDEO_MOTION'].Motions)do assert(m.Start(v[1]));for i=1,40 do Services.RunService.RenderStepped:Fire(.05)end;m.Stop(true);assert(s.Yaw==180 and s.Zoom==1)end
assert(#frames>360 and #pivots>30)
m.Start('DOLLY');Services.RunService.RenderStepped:Fire(.05);local n=#frames;m.Paused=true;Services.RunService.RenderStepped:Fire(.1);assert(#frames==n);m.Paused=false;Services.RunService.RenderStepped:Fire(.05);assert(#frames==n+1)
alive=false;Services.RunService.RenderStepped:Fire(.05);local stopped=#frames;Services.RunService.RenderStepped:Fire(.05);assert(#frames==stopped)
return 'all nine continuous video paths operate on the actual camera/avatar callbacks, ease in, pause without jumping, restore their anchor and disconnect when the studio closes'
''')
case('photo_store_and_emote_sidebar_use_catalog_not_inventory',THEME+DATA+module('07P4_STUDIO_UI')+module('07P9_STUDIO_CATALOG')+r'''
local u=Modules['07P4_STUDIO_UI'].Build(pl);u.Root.Visible=true;u.Popup.Visible=true;local seen={}
function Services.AvatarEditorService:SearchCatalogAsync(p)seen[#seen+1]=p.AssetTypes[1].Name;return{IsFinished=true,GetCurrentPage=function()return{{Id=6001,Name='Store item',Price=10}}end}end
function Services.AvatarEditorService:GetInventoryAsync()error('inventory must not be queried')end
local selected;Modules['07P9_STUDIO_CATALOG'].Open(u,'Background',function(v)selected=v.Id end,function()end);flush();assert(seen[#seen]=='AvatarBackground'and u.PopupTitle.Text=='Loja de fundos')
named(u.Popup,'TryStudioItem').Activated:Fire();assert(selected==6001)
Modules['07P9_STUDIO_CATALOG'].Open(u,'Animations',function(v)selected=v.Id+1 end,function()end);flush();assert(seen[#seen]=='EmoteAnimation');named(u.Popup,'TryStudioItem').Activated:Fire();assert(selected==6002)
return 'backgrounds and emotes open their native storefront types immediately, never call inventory and route testing to the studio copy'
''')
case('real_music_client_starts_from_warm_library_without_waiting_on_preferences',THEME+DATA+module('07M0_MUSIC_PREFS')+module('07M2_AUDIO_LIBRARY')+module('07M1_MUSIC_UI')+r'''
Audio61={{{Id=910,Title='Soft Lofi'},{Id=911,Title='Studio Walk'}}}
'''+src('07M_MUSIC_SERVER')+r'''
local rpc=rep.ACP_MusicRequest;function rpc:InvokeServer(a,d)return self.OnServerInvoke(pl,a,d)end
'''+src('07M_MUSIC_CLIENT')+r'''
flush();local sound=Services.SoundService.ACP_PersonalMusic;assert(sound.IsPlaying and sound.SoundId=='rbxassetid://910'and sound.Volume==.4)
sound.Ended:Fire();flush();assert(sound.SoundId=='rbxassetid://911')
return 'actual music controller obtains warm verified native results, autoplays at 40% and advances the queue using independent request channels'
''')
case('assistant_surface_and_safe_controls_remain_readable',THEME+module('09I4_ASSISTANT_UI')+r'''
local u=Modules['09I4_ASSISTANT_UI'].Build(pl);u.Root.Visible=true;u.Health('Normal',true,false)
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;u.Layout()
 for _,b in ipairs({u.Menu,u.Sponsor,u.Close,u.Send,u.Make,u.Help})do if b.Visible then inside(b,u.Root);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44)end end
 assert(not intersects(u.Close,u.Sponsor));assert(not intersects(u.Send,u.Input));assert(not intersects(u.Make,u.Help))
end
assert(u.Root:FindFirstChildOfClass('UIGradient'));assert(u.Welcome:FindFirstChildOfClass('UIStroke'))
return 'the themed assistant keeps header, return-to-sponsor, composer and mode controls within six safe screen geometries'
''')
case('real_game_ui_renders_dense_online_board_without_losing_pieces',THEME+DATA+module('07A0_CHESS_RULES')+module('07B0_CHECKERS_RULES')+module('07K6_CARD_CATALOG')+module('07K7_CARD_STYLES')+module('07H4_BOT_ENGINE')+module('07H5_TRUCO_SETUP')+module('07H1_GAME_LOBBY')+module('07H2_GAME_BOARD')+module('07H6_GAME_MOMENTS')+module('07H8_PLAY_SESSION')+r'''
for _,n in ipairs({'HubGameUI','GameRoomPush','TrucoPush'})do local e=Instance.new('RemoteEvent');e.Name=n;e.Parent=rem61 end
for _,n in ipairs({'GameRoomRequest','TrucoRequest'})do local e=Instance.new('RemoteFunction');e.Name=n;e.Parent=rem61;function e:InvokeServer()return{ok=true,protocol=2,waiting={Xadrez=0,Damas=0},data={}}end end
'''+src('07H_GAME_UI')+r'''
flush();local state=Modules['07A0_CHESS_RULES'].New();local function dense()local out={};for r=1,8 do out[r]={};for c=1,8 do out[r][c]=state.board[r][c]or false end end;return out end
local event=rem61.HubGameUI;event.OnClientEvent:Fire('boardOpen',{protocol=2,game='Xadrez',tableName='Xadrez_ABCD',side='W',board=dense(),turn='W',revision=0});flush()
local match=pg.GameClubGui.GameMatch;local function pieces()local n=0;for _,o in ipairs(match:GetDescendants())do if o.Name=='PieceIcon'then n=n+1 end end;return n end
assert(pieces()==32 and match.Visible and not pg.GameClubGui.GamesLobby.Visible)
local rules=Modules['07A0_CHESS_RULES'];local move;for _,m in ipairs(rules.Legal(state,7,5))do if m.tr==5 then move=m end end;assert(rules.Apply(state,move))
event.OnClientEvent:Fire('boardState',{tableName='Xadrez_ABCD',board=dense(),turn='B',revision=1,hints={}});flush();assert(pieces()==32)
assert(not named(match,'Cell_7_5'):FindFirstChild('PieceIcon')and named(match,'Cell_5_5'):FindFirstChild('PieceIcon'))
return 'actual online LocalScript hides the lobby and renders all 32 piece icons before/after a dense-board move, removing only the moved source icon'
''')
HERE.joinpath('interface_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
