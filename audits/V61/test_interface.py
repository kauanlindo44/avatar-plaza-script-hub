from test_support import *
SIZES="{{320,568,0,0,0},{390,844,0,0,34},{568,320,0,0,0},{667,375,0,0,0},{851,392,44,44,21},{1920,1080,0,0,0}}"
SETTINGS=THEME+module('07G4_WORLD_SCENERY')+module('07G2_LOCAL_WORLDS')+module('07G1_HUB_SETTINGS')
case('hud_and_row_settings_geometry_in_six_sizes',SETTINGS+src('07G_HUB_UI')+r'''
flush();local hud=pg.LimitedMarketHUD;local root=hud.HudRoot
local names={'TopCatalog','TopStores','Community','Loader','Looks','Emotes','TopMusic','Cart','Avatar','SaveRoblox','Reset','Games','Photo','Cfg','Plus'}
for _,sz in ipairs('''+SIZES+r''')do
 SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;root:GetPropertyChangedSignal('AbsoluteSize'):Fire();flush()
 local buttons={};for _,n in ipairs(names)do local b=named(pg,n);if b.Visible then assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44,n);buttons[#buttons+1]=b end end
 for i,a in ipairs(buttons)do for j=i+1,#buttons do assert(not intersects(a,buttons[j]),a.Name..'/'..buttons[j].Name)end end
 local panel=named(root,'SettingsPanel');panel.Visible=true;flush();for _,b in ipairs(named(panel,'SettingsCategories'):GetChildren())do if b:IsA('GuiButton')then inside(b,b.Parent);assert(b.AbsoluteSize.Y>=44)end end;panel.Visible=false
end
return 'HUD controls do not overlap and settings categories keep touch targets across six viewport/safe-area geometries'
''')
case('music_discovery_list_and_id_are_both_visible_without_fullscreen',THEME+module('07M1_MUSIC_UI')+r'''
local u=Modules['07M1_MUSIC_UI'].Build(pl);u.Root.Visible=true
for _,sz in ipairs('''+SIZES+r''')do
 SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;u.Layout()
 assert(u.Content.Visible and u.Library.Visible and u.Page=='Descobrir');inside(u.ID,u.Root);inside(u.List,u.Root)
 for _,b in ipairs({u.Close,u.Load,u.Reload,u.Play,u.Previous,u.Next,u.Keep,u.Enqueue,u.DiscoverTab,u.QueueTab,u.SavedTab,u.Search,u.More})do inside(b,u.Root);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44,b.Name..' small')end
 assert(not intersects(u.ID,u.List));assert(not intersects(u.Close,u.Minimize))
end
return 'initial music discovery and ID/link input coexist in a compact panel with readable list and 44px controls in portrait/landscape'
''')
STORES=UI+DATA+module('09C9_SPONSOR_PICKER')+module('09C5_UGC_STORES')+r'''
U.Root.Visible=true;U.SetWide(true);U.StoresArea.Visible=true;local nativeRows={};local actions={};local published=false;local selected;local aiOpened=false
for i=1,28 do nativeRows[i]={Id=100+i,Name='Example '..i,ItemType='Asset',AssetType='Shirt',Price=5}end
function Services.AvatarEditorService:SearchCatalogAsync()return{GetCurrentPage=function()return deep(nativeRows)end}end
local function call(a,d)
 actions[#actions+1]={a=a,d=d}
 if a=='HighlightFeed'then if published then return{items={{item=deep(nativeRows[1]),key='Asset:101',favorite=false,expires=TIME60+86400}},finished=true,emptyGlobal=false}else return{items={},finished=true,emptyGlobal=true}end
 elseif a=='HighlightStatus'then return{nextAllowed=TIME60,favorites={}}
 elseif a=='HighlightCheck'then return deep(nativeRows[1])
 elseif a=='HighlightFavorite'then return{value=d.value}
 elseif a=='HighlightSubmit'then published=true;return{free=true}
 elseif a=='HighlightPurchase'then return true end
end
local ctl=Modules['09C5_UGC_STORES'].Init({U=U,A=A,call=call,toast=function()end,showItem=function(r)selected=r end,openAssistant=function()aiOpened=true end});ctl.Search();flush()
'''
case('temporary_sponsor_examples_rows_and_live_replacement',STORES+r'''
assert(named(U.StoresArea,'Featured_Asset_101').ItemName.Text=='Exemplo temporário')
for _,sz in ipairs('''+SIZES+r''')do
 SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;U.SetWide(true);U.StoresArea:GetPropertyChangedSignal('AbsoluteSize'):Fire();flush()
 local count=0;for i=1,3 do local row=named(U.StoresArea,'HighlightRow'..i);if row.Visible then count=count+1;inside(row,U.StoreGrid);assert(row:GetAttribute('VisibleColumns')<=7)end end;assert(count>=1 and count<=3)
 if SCREEN_W>=667 then assert(count>=2,'expected multiple rows')end
 for _,n in ipairs({'PublishHighlight','MoreHighlights','SponsorTab','AssistantTab'})do local b=named(U.StoresArea,n);inside(b,U.StoresArea);assert(b.AbsoluteSize.Y>=44)end
end
published=true;shop61.HighlightChanged.OnClientEvent:Fire();flush();local card=named(U.StoresArea,'Featured_Asset_101');assert(card.ItemName.Text=='Example 1')
card.Activated:Fire();assert(selected.Id==101);card.FavoriteFeatured.Activated:Fire();flush();assert(actions[#actions].a=='HighlightFavorite')
named(U.StoresArea,'AssistantTab').Activated:Fire();assert(aiOpened)
return 'native temporary examples are labelled, adapt to multiple horizontal rows, disappear on a real publication notification and keep favorites/IA routing separate'
''')
case('sponsor_name_search_has_examples_before_typing',STORES+r'''
named(U.StoresArea,'PublishHighlight').Activated:Fire();flush();local search=named(U.StoresArea,'SponsorSearch');assert(search.Visible)
assert(guiCards(named(search,'SponsorResults'))==28)
local first;for _,b in ipairs(named(search,'SponsorResults'):GetChildren())do if b:IsA('GuiButton')then first=b;break end end
first.Activated:Fire();assert(not search.Visible and named(U.StoresArea,'HighlightID').Text=='101')
assert(not named(U.StoresArea,'ConfirmHighlight').Active);named(U.StoresArea,'CheckHighlight').Activated:Fire();flush();assert(named(U.StoresArea,'ConfirmHighlight').Active)
named(U.StoresArea,'ConfirmHighlight').Activated:Fire();flush();assert(published)
return 'opening publish starts a native name/filter picker with immediate examples; selecting a result still requires server confirmation before free publication'
''')
case('community_two_modes_metadata_loading_and_price_fields',UI+DATA+PREVIEW+module('09C7_COMMUNITY_FEED')+r'''
U.Root.Visible=true;U.SetWide(true);U.CommunityArea.Visible=true;local requests={}
local f=Modules['09C7_COMMUNITY_FEED'].Init({U=U,A=A,call=function(a,d)requests[#requests+1]={a=a,d=d};return{items={{id='roblox:201',code='AV-201',owner=201,source='Roblox',name='Look de jogador'}},finished=true}end,toast=function()end,show=function()end});f.Open();flush()
assert(f.Pool[1].record and f.Pool[1].author.Text=='AV-201');assert(not U.ComTabButtons.ROBUX.Visible and not U.ComTabButtons.PUBLICADOS.Visible)
U.ComMin.Text='10';U.ComMax.Text='55';U.ComApply.Activated:Fire();flush();assert(requests[#requests].a=='CommunityPage'and requests[#requests].d.min==10 and requests[#requests].d.max==55)
return 'Todos/Grátis are the only modes, pending player thumbnails display without waiting for every 3D body, and explicit prices are sent to the real combined endpoint'
''')
case('catalog_price_validation_and_defaults_are_understandable',UI+DATA+PREVIEW+module('09C4_OUTFIT_LIBRARY')+module('09C3_CATALOG_FILTERS')+module('09C2_SHOP_CATALOG')+r'''
local searches={};function Services.AvatarEditorService:SearchCatalogAsync(p)searches[#searches+1]=deep(p);return{IsFinished=true,GetCurrentPage=function()return{}end}end
local messages={};local c=Modules['09C2_SHOP_CATALOG'].Init({U=U,A=A,S=S,toast=function(m)messages[#messages+1]=m end,call=function()return true end})
c.Search();flush();assert(searches[#searches].MinPrice==0)
U.FilterPanel.Visible=true;U.Min.Text='-1';U.ApplyFilter.Activated:Fire();flush();assert(U.FilterPanel.Visible and messages[#messages]:find('inteiro',1,true))
U.Min.Text='20';U.Max.Text='10';U.ApplyFilter.Activated:Fire();assert(U.FilterPanel.Visible)
U.Min.Text='10';U.Max.Text='20';U.ApplyFilter.Activated:Fire();flush();assert(searches[#searches].MinPrice==10 and searches[#searches].MaxPrice==20)
assert(U.Filter.Text:find('2',1,true)and not U.Form2D.Visible and U.FormClassic.Text=='Clássicas 2D')
return 'negative/reversed prices cannot close or execute a filter; default catalog includes free items; active-filter count and explicit 2D/3D clothing labels match native parameters'
''')
case('rich_local_scenes_and_ground_pool_remain_bounded',SETTINGS+DATA+r'''
local lighting=Services.Lighting;lighting.ClockTime=13;lighting.Brightness=2;lighting.Ambient=Color3.new(.4,.4,.4);lighting.OutdoorAmbient=Color3.new(.5,.5,.5);lighting.ExposureCompensation=.1;lighting.FogColor=Color3.new(.8,.8,.8);lighting.FogStart=500;lighting.FogEnd=2000
local world=Instance.new('Folder');world.Name='PracaAvatar_V2';world.Parent=workspace;local ground=Instance.new('Folder');ground.Name='AvatarFieldGround';ground.Parent=world
local w=Modules['07G2_LOCAL_WORLDS'];local types={ANIME='PagodaLevel',NEON='CityTower',COAST='SunUmbrella',HALLOWEEN='HauntedHouse',CLOUD='CloudArchTop'}
for id,name in pairs(types)do assert(w.Apply(id));local f=workspace.ACP_LocalWorldVisuals;assert(named(f,name));local floor=0
 for _,p in ipairs(f:GetChildren())do if p:IsA('BasePart')then assert(not p.CanCollide and not p.CanQuery);if p.Name=='InfiniteVisualGround'then floor=floor+1 end end end;assert(floor==25)
 HUM.Parent.HumanoidRootPart.Position=Vector3.new(15000,60,15000);Services.RunService.Heartbeat:Fire(.3)
 local count=0;for _,p in ipairs(f:GetChildren())do if p.Name=='InfiniteVisualGround'then count=count+1;assert(math.abs(p.Position.X-15000)<7000)end end;assert(count==25)
end
w.Destroy();assert(not workspace:FindFirstChild('ACP_LocalWorldVisuals'))
return 'five distinct original scene motifs exist and a reusable 25-part local floor follows long-distance movement; no collisions/query changes and cleanup restores the world'
''')
case('photo_catalog_scene_centers_avatar_and_rejects_invalid_replacement',THEME+DATA+PREVIEW+module('07P0_STUDIO_PRESETS')+module('07P3_POSE_EDITOR')+module('07P6_STUDIO_SETS')+module('07P2_STUDIO_AVATAR')+r'''
local s=Modules['07P2_STUDIO_AVATAR'];assert(s.Enter());local model=s.Model
assert(s.BuildSet({id=801,source='RobloxCatalog',preview=true,image='rbxthumb://type=Asset&id=801&w=420&h=420'}));local scene=s.Scene
s.SetMargins(70,60,230,12);local target=s.Model:GetBoundingBox();assert(math.abs(s.Camera.CFrame.Position.X-target.Position.X)<.001)
s.SetAvatarYaw(180);assert(s.Model==model and s.Scene==scene)
assert(not s.BuildSet({id=3,source='Invented',preview=true,image='rbxassetid://1'}));assert(s.Scene==scene)
s.Exit();assert(not scene.Alive)
return 'official store thumbnail/raw-image backgrounds remain behind the exact copied model; asymmetric sidebars no longer shift the avatar horizontally; invalid replacement preserves the prior scene'
''')
case('post_match_summary_review_and_replay_controls_are_safe',THEME+module('07H6_GAME_MOMENTS')+r'''
local gui=Instance.new('ScreenGui');gui.IgnoreGuiInset=true;gui.ScreenInsets=Enum.ScreenInsets.None;gui.Parent=pg;local parent=Instance.new('Frame');parent.Size=UDim2.fromScale(1,1);parent.Parent=gui
local u=Modules['07H6_GAME_MOMENTS'].Build(parent);u.Show({winner='W',won=true,moves=24,reason='Xeque-mate'})
u.SetTicket({token='t',yours=2,theirs=1,opponent='Amigo',canRematch=true});assert(u.Score.Text:find('2 × 1',1,true))
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;u.Layout()
 for _,b in ipairs({u.Close,u.Again,u.Review,u.Exit})do inside(b,u.Root);assert(b.AbsoluteSize.Y>=44,b.Name..':'..b.AbsoluteSize.Y)end;assert(u.Root.AbsolutePosition.Y>=0,'summary Y '..u.Root.AbsolutePosition.Y..' at '..SCREEN_W..'x'..SCREEN_H..' gui '..gui.AbsoluteSize.Y..' core '..tostring(CORE_TOP))
end
local reviewed=false;u.OnReview=function()reviewed=true end;u.Review.Activated:Fire();assert(reviewed and not u.Root.Visible and u.Final)
u.Show({winner='B',won=false,canRematch=false});assert(not u.Again.Active);u.Clear();assert(not u.Final)
return 'result keeps the board available, displays session score, uses explicit review/replay/next actions and avoids the Roblox topbar in every tested geometry'
''')
case('real_music_controller_seeds_queue_and_autoplays_verified_default',THEME+DATA+module('07M0_MUSIC_PREFS')+module('07M2_AUDIO_LIBRARY')+module('07M1_MUSIC_UI')+r'''
Audio61={{{Id=910,Title='Soft Lofi',Duration=90},{Id=911,Title='Studio Walk',Duration=120}}};for _,id in ipairs({910,911})do NativeInfo60[id]={Name='Track '..id,AssetTypeId=3,IsForSale=true}end
'''+src('07M_MUSIC_SERVER')+r'''
local rpc=rep.ACP_MusicRequest;function rpc:InvokeServer(a,d)return self.OnServerInvoke(pl,a,d)end
'''+src('07M_MUSIC_CLIENT')+r'''
flush();local sound=Services.SoundService:FindFirstChild('ACP_PersonalMusic');assert(sound and sound.IsPlaying and sound.SoundId=='rbxassetid://910'and sound.Volume==.4)
pg:SetAttribute('ACP_OpenMusicNonce',1);flush();local root=pg.ACP_Music.MusicPopup;assert(root.Visible);assert(named(root,'MusicLibrary'))
local fila;for _,o in ipairs(root:GetDescendants())do if o:IsA('GuiButton')and o.Text=='Fila'then fila=o end end;assert(fila);fila.Activated:Fire();flush()
assert(guiCards(named(root,'MusicLibrary'))==0);local n=0;for _,o in ipairs(named(root,'MusicLibrary'):GetChildren())do if o:IsA('GuiObject')then n=n+1 end end;assert(n==2)
sound.Ended:Fire();flush();assert(sound.SoundId=='rbxassetid://911')
return 'actual music LocalScript retrieves native defaults, starts the verified background audio at 40%, populates a queue before manual input and advances to the next track'
''')
case('real_game_controller_retains_board_after_server_close_and_review',THEME+DATA+module('07A0_CHESS_RULES')+module('07B0_CHECKERS_RULES')+module('07K6_CARD_CATALOG')+module('07K7_CARD_STYLES')+module('07H4_BOT_ENGINE')+module('07H5_TRUCO_SETUP')+module('07H1_GAME_LOBBY')+module('07H2_GAME_BOARD')+module('07H6_GAME_MOMENTS')+r'''
for _,n in ipairs({'HubGameUI','GameRoomPush','TrucoPush'})do local e=Instance.new('RemoteEvent');e.Name=n;e.Parent=rem61 end
for _,n in ipairs({'GameRoomRequest','TrucoRequest'})do local e=Instance.new('RemoteFunction');e.Name=n;e.Parent=rem61;function e:InvokeServer()return{ok=true,waiting={Xadrez=0,Damas=0},data={}}end end
'''+src('07H_GAME_UI')+r'''
flush();local event=rem61.HubGameUI;local board={};for r=1,8 do board[r]={}end
board[8][5]={c='W',t='K'};board[1][5]={c='B',t='K'}
event.OnClientEvent:Fire('boardOpen',{game='Xadrez',tableName='Xadrez01',side='W',board=board,turn='W'});flush()
event.OnClientEvent:Fire('boardClose',{tableName='Xadrez01',finished=true,summary={game='Xadrez',board=board,winner='W',moves=24,reason='mate',canRematch=true}});flush()
rem61.GameRoomPush.OnClientEvent:Fire('roomClosed');flush()
local root=pg.GameClubGui.GameMatch;assert(root.Visible and named(root,'MatchSummary').Visible)
named(root,'MatchReview').Activated:Fire();assert(root.Visible and not named(root,'MatchSummary').Visible)
return 'the actual game LocalScript holds the last board/result through room closure; review hides the summary while keeping the final board available'
''')
case('photo_side_catalog_tests_emote_on_copy_and_offers_native_purchase',THEME+DATA+module('07P4_STUDIO_UI')+module('07P9_STUDIO_CATALOG')+r'''
local u=Modules['07P4_STUDIO_UI'].Build(pl);u.Root.Visible=true;u.Popup.Visible=true
fixture60(6001,'Dance','EmoteAnimation');local item=NativeItems60['Asset:6001']
function Services.AvatarEditorService:SearchCatalogAsync(p)assert(p.AssetTypes[1]==Enum.AvatarAssetType.EmoteAnimation);return{IsFinished=true,GetCurrentPage=function()return{deep(item)}end}end
local selected;Modules['07P9_STUDIO_CATALOG'].Open(u,'Animations',function(v)selected=v.Id end,function()end);flush()
local b=named(u.Popup,'TryStudioItem');assert(b);b.Activated:Fire();assert(selected==6001)
local buy;for _,o in ipairs(u.Popup:GetDescendants())do if o:IsA('GuiButton')and o.Text=='Comprar'then buy=o end end;assert(buy);buy.Activated:Fire();flush();assert(LastPrompt.id==6001)
return 'small native emote sidebar directs testing to the copied-avatar callback and opens only Roblox purchase for an available catalog item'
''')
HERE.joinpath('interface_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
