from test_support import *
for p in sorted((ROOT/'scripts/V43').glob('*.lua')):
 s=p.read_text();assert len(s.splitlines())<=400,p;assert not re.search(r'(?:\+|-|\*|/|\.\.)=',s),p
 l=Lua();l.run(s,p.name,execute=False);l.close()
results.append(dict(case='syntax_studio_lite_limits',result='pass',detail='27 scripts <=400 lines, no compound assignment'))

case('viewport_controls_and_fixed_close_targets',UI+r'''
for _,v in ipairs({{320,568,0,0,58,0},{360,640,0,0,58,0},{390,844,0,0,58,22},{800,360,0,0,58,0},{844,390,44,44,58,22},{1460,821,0,0,58,0},{1920,1080,0,0,58,0}})do
 SCREEN_W,SCREEN_H,CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=table.unpack(v);U.SetWide(false);flush()
 assert(U.Root.AbsolutePosition.Y==0 and U.Root.AbsoluteSize.Y==SCREEN_H)
 for _,o in ipairs({U.Main,U.Viewport,U.EditorFooter,U.Query,U.SearchGo,U.Filter,U.Sort,U.Close,U.Grid})do inside(o,U.Root)end
 for _,o in ipairs({U.Query,U.SearchGo,U.Filter,U.Sort})do assert(not intersects(o,U.Close),'close overlaps catalog control')end
 assert(U.Viewport.AbsoluteSize.Y>=100);assert(U.EditorFooter.AbsolutePosition.Y>=U.Viewport.AbsolutePosition.Y+U.Viewport.AbsoluteSize.Y)
 for _,close in ipairs({U.Close,U.CartClose,U.LoaderClose,U.LookClose,U.SaveClose,U.PublishClose,U.RigClose,U.BodyClose,U.CloseFilter,U.DetailClose})do
  assert(close.Text=='×');assert(close.AbsoluteSize.X>=48 and close.AbsoluteSize.Y>=48,close.Name..' undersized');inside(close,U.Root)
 end
 assert(U.LoaderClose.AbsolutePosition.Y>=CORE_TOP)
 local p=U.CloseFilter.AbsolutePosition;U.FilterPanel.CanvasPosition=Vector2.new(0,200);assert(U.CloseFilter.AbsolutePosition.Y==p.Y)
 p=U.DetailClose.AbsolutePosition;U.Detail.CanvasPosition=Vector2.new(0,200);assert(U.DetailClose.AbsolutePosition.Y==p.Y)
 assert(not intersects(U.ZoomIn,U.ViewRight)and not intersects(U.ZoomOut,U.ViewRight))
end
return '7 screen sizes; full background, safe 48px X targets and no scrolling close buttons'
''')
case('catalog_five_by_four_and_explicit_prices',UI+DATA+PREVIEW+module('09C4_OUTFIT_LIBRARY')+r'''
local items={};for i=1,30 do items[i]={Id=i,Name='Item '..i,AssetType='Shirt',ItemType='Asset',Price=1234}end
function Services.AvatarEditorService:SearchCatalogAsync()return{IsFinished=true,GetCurrentPage=function()return items end}end
local ctl=loadModule('CATALOG','Catalog').Init({U=U,A=A,S=S,toast=function()end})
U.Root.Visible=true;U.Grid.Visible=true
for _,v in ipairs({{768,432,0,0,58,0},{800,360,0,0,58,0},{844,390,44,44,58,22},{1460,821,0,0,58,0},{1920,1080,0,0,58,0}})do
 SCREEN_W,SCREEN_H,CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=table.unpack(v);U.SetWide(false);ctl.Search();flush();ctl.Resize()
 local g=U.GridLayout;assert(g.FillDirectionMaxCells==5,'not five columns at '..SCREEN_W)
 assert(math.floor((U.Grid.AbsoluteSize.Y+g.CellPadding.Y.Offset)/(g.CellSize.Y.Offset+g.CellPadding.Y.Offset))==4,'not four visible rows')
 local n=0;for _,c in ipairs(U.Grid:GetChildren())do if c:IsA('GuiButton')then n=n+1;if n<=20 then inside(c,U.Grid)end
  assert(c.ItemPrice.Text=='1.234 Robux'or c.ItemPrice.Text=='1.234\nRobux');assert(c.ItemImage.AbsoluteSize.Y>=32)
 end end;assert(n==30)
end
return '20 cards fully visible in 5x4 at 768x432, short landscape and desktop; numeric Robux values retained'
'''.replace("'CATALOG'",q(src('09C2_SHOP_CATALOG'))))

case('settings_categories_and_local_world_restoration',THEME+module('07G2_LOCAL_WORLDS')+module('07G1_HUB_SETTINGS')+r'''
local world=Instance.new('Folder');world.Name='PracaAvatar_V2';world.Parent=workspace
local ground=Instance.new('Folder');ground.Name='AvatarFieldGround';ground.Parent=world
local tile=Instance.new('Part');tile:SetAttribute('FieldTone',1);tile.Color=Color3.fromRGB(100,150,100);tile.CanCollide=true;tile.CanTouch=true;tile.CanQuery=true;tile.Parent=ground
local originalColor=tile.Color;local originalClock=Services.Lighting.ClockTime
local gui=Instance.new('ScreenGui');gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;gui.Parent=pg
local root=Instance.new('Frame');root.Size=UDim2.fromScale(1,1);root.Parent=gui
local c=Modules['07G1_HUB_SETTINGS'].Build(root,pg,function()end,function()end)
for _,v in ipairs({{360,640},{768,432},{1920,1080}})do
 SCREEN_W,SCREEN_H,CORE_TOP=v[1],v[2],58;c.Panel.Visible=false;c.Panel.Visible=true;c.Layout();inside(c.Close,root)
 named(c.Panel,'ChangeWorld').Activated:Fire();c.Layout();assert(c.Page=='World'and #c.Body:GetChildren()==5)
 for _,b in ipairs(c.Body:GetChildren())do inside(b,c.Body)end
 named(c.Panel,'CLOUD').Activated:Fire();assert(Modules['07G2_LOCAL_WORLDS'].Selected=='CLOUD')
 assert(tile.CanCollide and tile.CanTouch and tile.CanQuery and tile.Color~=originalColor)
 for _,p in ipairs(workspace.ACP_LocalWorldVisuals:GetChildren())do assert(not p.CanCollide and not p.CanTouch and not p.CanQuery)end
 c.Back.Activated:Fire();assert(c.Page=='Home');c.Close.Activated:Fire();assert(not c.Panel.Visible)
end
assert(Modules['07G2_LOCAL_WORLDS'].Apply('ORIGINAL'));assert(tile.Color==originalColor and Services.Lighting.ClockTime==originalClock)
return 'colored categories, nested world X, local cosmetics with unchanged collision and exact restoration'
''')
case('hud_plus_native_direct_and_music',THEME+module('07G2_LOCAL_WORLDS')+module('07G1_HUB_SETTINGS')+r'''
local kit=Instance.new('Folder');kit.Name='PracaKit';kit.Parent=rep
local prompts=0;function Services.MarketplaceService:PromptRobloxSubscriptionPurchase(p)assert(p==pl);prompts=prompts+1 end
'''+src('07G_HUB_UI')+r'''
flush();named(pg.LimitedMarketHUD,'Plus').Activated:Fire();assert(prompts==1)
named(pg.LimitedMarketHUD,'Plus').Activated:Fire();assert(prompts==1);advance(3);named(pg.LimitedMarketHUD,'Plus').Activated:Fire();assert(prompts==2)
assert(not pg:FindFirstChild('AvatarShop08Gui'));named(pg.AvatarShopLauncherGui,'TopMusic').Activated:Fire();assert(pg:GetAttribute('ACP_OpenMusicNonce')==1)
named(pg.LimitedMarketHUD,'Cfg').Activated:Fire();assert(named(pg.LimitedMarketHUD,'Settings').Visible)
named(pg.LimitedMarketHUD,'CloseCfg').Activated:Fire();assert(not named(pg.LimitedMarketHUD,'Settings').Visible)
return 'Plus opens official prompt without shop dependency or intermediate page; debounce and music work'
''')
case('preview_bounds_angles_drag_and_stale_error',DATA+PREVIEW+r'''
local gui=Instance.new('ScreenGui');gui.ScreenInsets=Enum.ScreenInsets.None;gui.Parent=pg
local v=Instance.new('ViewportFrame');v.Size=UDim2.fromOffset(260,400);v.Parent=gui
local p=Preview.Mount(v,S.Current,'R15',{drag=true});flush();assert(p.Model)
local function dot(a,b)return a.X*b.X+a.Y*b.Y+a.Z*b.Z end
for _,yaw in ipairs({0,90,180,270})do
 p.SetYaw(yaw);local cf,size=Preview.Bounds(p.Model);local cam=p.Camera.CFrame;local tan=math.tan(math.rad(p.Camera.FieldOfView)*.5)
 for _,sx in ipairs({-1,1})do for _,sy in ipairs({-1,1})do for _,sz in ipairs({-1,1})do
  local d=cf.Position+Vector3.new(size.X*sx/2,size.Y*sy/2,size.Z*sz/2)-cam.Position;local depth=dot(d,cam.LookVector)
  assert(depth>0 and math.abs(dot(d,cam.RightVector)/(depth*tan*v.AbsoluteSize.X/v.AbsoluteSize.Y))<1.01 and math.abs(dot(d,cam.UpVector)/(depth*tan))<1.01,'clipped bounds')
 end end end
end
local t={UserInputType=Enum.UserInputType.Touch,Position=Vector3.new(60,60,0)};v.InputBegan:Fire(t)
t.Position=Vector3.new(100,60,0);Services.UserInputService.InputChanged:Fire(t);local yaw=p.Yaw
v.Size=UDim2.fromOffset(300,400);assert(p.Yaw==yaw);Services.UserInputService.InputEnded:Fire(t)
local first=Preview.Mount(v,S.Current,'R6');local second=Preview.Mount(v,S.Current,'R15');flush();assert(not first.Alive and second.Alive and second.Model)
onCreate=function()error('asset network error')end;local err=nil;local failed=Preview.Mount(v,S.Current,'R15',{failed=function(e)err=e end});flush();assert(err and not failed.Model)
Preview.Unmount(v);assert(not v:FindFirstChildOfClass('WorldModel'))
return 'four full-body angles, drag/resize retention, stale-model disposal and safe string errors'
''')

case('community_pool_prefetch_lru_and_back_scroll',UI+DATA+PREVIEW+COMMUNITY+r'''
local requests={};local ctl=Modules['09C7_COMMUNITY_FEED'].Init({U=U,A=A,toast=function()end,show=function()end,call=function(a,args)
 assert(a=='DiscoverPage');requests[#requests+1]=args.page;local out={}
 for i=1,50 do local id=args.page*50+i;out[i]={id='roblox:'..id,owner=id,name='Avatar '..id,sourceUsername='User'..id,source='Roblox',thumbnail='rbxthumb://type=Avatar&id='..id..'&w=420&h=420'}end
 return{items=out,finished=args.page==19999}
end})
SCREEN_W,SCREEN_H,CORE_TOP=1460,821,58;U.SetWide(true);U.Root.Visible=true;U.CommunityArea.Visible=true;U.Layout();ctl.Open();flush()
assert(#ctl.Pool==50 and guiCards(U.CommunityGrid)==50 and ctl.Highest==0,'prefetch too early')
for i=1,120 do
 local row=math.floor((ctl.End-10)/5);local step=ctl.Pool[1].root.AbsoluteSize.Y+6
 U.CommunityGrid.CanvasPosition=Vector2.new(0,row*step);flush();assert(#ctl.Order<=12 and guiCards(U.CommunityGrid)==50)
end
assert(ctl.Highest>100 and ctl.Cache[0]==nil)
U.CommunityGrid.CanvasPosition=Vector2.zero;flush();assert(ctl.Cache[0]and requests[#requests]==0)
for _,s in ipairs(ctl.Pool)do assert(not s.view:FindFirstChildOfClass('WorldModel'),'native thumbnails created 3D models')end
local before=#requests;U.LookDetail.Visible=true;U.CommunityGrid.CanvasPosition=Vector2.new(0,100000);flush();assert(#requests==before)
U.LookDetail.Visible=false;U.Root.Visible=false;flush();for _,s in ipairs(ctl.Pool)do assert(not s.root.Visible)end
return '50 reusable slots over 100+ pages, prefetch after 30 visible entries, 12 cached pages and correct back-scroll reload'
''')
case('discovery_real_profiles_bounds_authorization_cache',DATA+module('09B2_COSPLAY_METADATA')+module('09B1_AVATAR_DISCOVERY')+r'''
local d=Modules['09B1_AVATAR_DISCOVERY'];assert(d.MaxPages*d.PageSize==1000000)
local first=d.Page(pl,{page=0});assert(#first.items==50 and #UserBatches[1]<=100)
for _,r in ipairs(first.items)do assert(r.sourceUsername=='User'..r.owner and r.username=='CAETANOYX'and not r.body)end
assert(not pcall(d.Page,pl,{page=20000})and not pcall(d.Page,pl,{page=-1}))
assert(not pcall(d.Load,pl,{id=999999}));local record=d.Load(pl,{id=first.items[1].owner});assert(record.body.props.Shirt==11 and record.sourceUsername=='User'..record.owner)
advance(1);local page=d.Page(pl,{page=1});local calls=#UserBatches;local again=d.Page(pl,{page=1});assert(#UserBatches==calls and #again.items==50)
record=d.Load(pl,{id=page.items[1].owner});assert(record.body and record.checkedAt)
assert(not pcall(d.Page,pl,{page=0/0}));Services.Players.PlayerRemoving:Fire(pl);assert(not pcall(d.Load,pl,{id=page.items[1].owner}))
return '50 confirmed real profiles per page, million-entry capacity, metadata cache, validated IDs and cleanup'
''')
case('cosplay_names_require_matching_live_clothes',DATA+module('09B2_COSPLAY_METADATA')+module('09B1_AVATAR_DISCOVERY')+r'''
local c=Modules['09B2_COSPLAY_METADATA']
assert(not c.Match({{id=1,slot='Shirt',name='Naruto Uzumaki shirt'}}))
assert(not c.Match({{id=1,slot='Shirt',name='Naruto shirt'},{id=2,slot='Pants',name='Naruto pants'}}))
assert(not c.Match({{id=1,slot='Shirt',name='Naruto Uzumaki'},{id=2,slot='Pants',name='Son Goku'}}))
local hit=c.Match({{id=1,slot='Shirt',name='Naruto Uzumaki shirt'},{id=2,slot='Pants',name='Naruto Uzumaki pants'}});assert(hit.name=='Naruto Uzumaki'and hit.source and hit.basis)
local d=Modules['09B1_AVATAR_DISCOVERY'];local page=d.Page(pl,{page=0});local id=page.items[1].owner
onProduct=function(id)return{Name=id==11 and'Naruto Uzumaki Shirt'or'Naruto Uzumaki Pants'}end
local live=d.Research(pl,{id=id});assert(live.character and live.name:find('Naruto Uzumaki',1,true))
onProduct=function()return{Name='Generic clothes'}end;live=d.Research(pl,{id=id});assert(not live.character and live.name=='Avatar de @User'..id)
return 'fresh item-name consultation; no title guesses from a single item, generic Naruto label or mixed characters'
''')
case('community_detail_opaque_rotation_items_close_and_save',UI+DATA+PREVIEW+COMMUNITY+r'''
local saved=nil;local ctx={U=U,A=A,S=S,toast=function()end,buyBody=function()end,call=function(action,args)
 if action=='DiscoverAvatar'then return{id='roblox:7',owner=7,name='Avatar de @RealOwner',source='Roblox',username='CAETANOYX',sourceUsername='RealOwner',body=A.Copy(S.Current),rig='R15'}
 elseif action=='DiscoverResearch'then return{name='Avatar de @RealOwner'}
 elseif action=='Save'then saved=args;return{persistent=true}end
end}
local details=Modules['09C8_COMMUNITY_DETAILS'].Init(ctx);U.Root.Visible=true;U.CommunityArea.Visible=true
details.Show({source='Roblox',owner=7,username='CAETANOYX',sourceUsername='RealOwner'});flush()
assert(U.LookDetail.ClassName=='Frame'and U.LookDetail.BackgroundTransparency==0)
assert(U.LookCreator.Text:find('Publicado por @CAETANOYX',1,true)and U.LookCreator.Text:find('Avatar de @RealOwner',1,true))
assert(#U.LookItems:GetChildren()==#A.Entries(S.Current)+1)
for i,b in ipairs(U.LookViews)do b.Activated:Fire();assert(Preview.Get(U.LookPreview).Yaw==({180,0,90,270})[i])end
U.LookRigToggle.Activated:Fire();flush();assert(Preview.Get(U.LookPreview).Model:FindFirstChildOfClass('Humanoid').RigType==Enum.HumanoidRigType.R6)
local rm=named(U.LookItems,'RemoveLookItem');assert(rm.AbsoluteSize.X==40);local before=#A.Entries(select(2,details.Active()));rm.Activated:Fire();flush();assert(#A.Entries(select(2,details.Active()))==before-1)
U.LookFav.Activated:Fire();assert(saved and saved.rig=='R6')
for _,v in ipairs({{360,640},{768,432},{1920,1080}})do SCREEN_W,SCREEN_H,CORE_TOP=v[1],v[2],58;U.Layout();flush();for _,o in ipairs({U.LookPreview,U.LookItems,U.LookClose,U.LookTry,U.LookBuy,U.LookFav})do inside(o,U.Root)end end
U.LookClose.Activated:Fire();assert(not U.LookDetail.Visible and not Preview.Get(U.LookPreview))
details.Show({source='Roblox',owner=7});U.LookClose.Activated:Fire();flush();assert(not U.LookDetail.Visible and not Preview.Get(U.LookPreview))
return 'full opaque detail, all four sides, R6/R15, item X, save and stale-close protection'
''')

case('saved_preview_larger_compact_cards_and_restore',UI+DATA+PREVIEW+COMMUNITY+r'''
local saved={};for i=1,20 do saved[i]={id=tostring(i),name='Look '..i,body=A.Copy(S.Current),rig='R15'}end
local ctl=loadModule('LOOKS','Looks').Init({U=U,A=A,S=S,toast=function()end,buyBody=function()end,call=function(a)if a=='List'then return{skins=saved}end end})
SCREEN_W,SCREEN_H,CORE_TOP=1920,1080,58;U.SetWide(true);U.Root.Visible=true;U.LooksArea.Visible=true;ctl.Saved();flush()
assert(U.SavedPreview.AbsoluteSize.Y>550 and U.SavedPreview.AbsoluteSize.X>=280)
local layout=U.SavedGrid:FindFirstChildOfClass('UIGridLayout');assert(layout.FillDirectionMaxCells==5 and layout.CellSize.Y.Offset<=162)
U.SavedRight.Activated:Fire();assert(Preview.Get(U.SavedPreview).Yaw~=180);U.OutfitRestore.Activated:Fire();flush();assert(Preview.Get(U.SavedPreview).Yaw==180)
SCREEN_W,SCREEN_H=768,432;U.Layout();flush();U.SavedPreviewToggle.Activated:Fire();assert(U.SavedPreview.AbsoluteSize.Y>=250)
assert(not intersects(U.SavedPreviewClose,U.SavedZoomIn)and not intersects(U.SavedPreviewClose,U.SavedRight));inside(U.SavedPreviewClose,U.Root)
U.SavedPreviewClose.Activated:Fire();assert(not U.SavedPreviewPanel.Visible)
return 'selected preview >550px at desktop and >250px in short landscape, smaller cards and working restore/X'
'''.replace("'LOOKS'",q(src('09C1_SHOP_LOOKS'))))

PHOTO=DATA+PREVIEW+module('07P0_STUDIO_PRESETS')+module('07P3_POSE_EDITOR')+module('07P5_POSE_CANVAS')+module('07P6_STUDIO_SETS')+module('07P2_STUDIO_AVATAR')+"Studio=Modules['07P2_STUDIO_AVATAR']\n"
case('photo_sets_clear_360_animation_and_restore',THEME+PHOTO+r'''
local light=Services.Lighting;local before=light.ClockTime;local cam=workspace.CurrentCamera;local beforeCamera=cam.CFrame
local bloom=Instance.new('BloomEffect');bloom.Enabled=true;bloom.Parent=light
assert(Studio.Enter());assert(not bloom.Enabled)
for _,preset in ipairs(Modules['07P0_STUDIO_PRESETS'].Backgrounds)do
 assert(Studio.BuildSet(preset.id));local scene=Studio.Scene;local parts=#Studio.SetFolder:GetDescendants();assert(parts>=9 and parts<80)
 Services.RunService.RenderStepped:Fire(.16);assert(scene.Alive)
 for _,yaw in ipairs({0,90,180,270})do
  Studio.SetYaw(yaw);local cf,size=Preview.Bounds(Studio.Model);local dir=cam.CFrame.LookVector
  for _,p in ipairs(Studio.SetFolder:GetDescendants())do if p:IsA('BasePart')and p.Name~='PhotoFloor'then
   local d=p.Position-cf.Position;assert(d.X*dir.X+d.Y*dir.Y+d.Z*dir.Z>20,'set blocks avatar from angle '..yaw)
   assert(not p.CanCollide and not p.CanTouch and not p.CanQuery)
  end end
 end
 scene.SetAnimated(false);Services.RunService.RenderStepped:Fire(.16)
end
assert(Studio.SetEnvironment('Exposure',99)and light.ExposureCompensation==.65)
Studio.Exit();assert(cam.CFrame==beforeCamera and light.ClockTime==before and bloom.Enabled)
assert(not workspace:FindFirstChild('ACP_PhotoPreview_123')and not Studio.Scene)
return 'five actual local sets, animation/pause, scenery stays behind all angles, restored camera and lighting'
''')
case('pose_canvas_drag_confirm_cancel_no_scroll',THEME+PHOTO+module('07P4_STUDIO_UI')+r'''
local U=Modules['07P4_STUDIO_UI'].Build(pl);assert(Studio.Enter());local pose=Studio.Pose
for _,v in ipairs({{320,568},{360,640},{768,432},{844,390},{1920,1080}})do
 SCREEN_W,SCREEN_H,CORE_TOP=v[1],v[2],58;U.Root.Visible=true;U.Popup.Visible=true;U.PoseMode=true;U.PoseFooter.Visible=true;U.Layout()
 pose.Begin();local editor=Modules['07P5_POSE_CANVAS'].Build(U.Popup,pose,function()end);flush()
 assert(editor.Root.ClassName=='Frame'and not U.Content.Visible and not U.Nav.Visible)
 for _,o in ipairs({U.Close,U.PopupClose,U.PoseConfirm,U.PoseCancel,U.PoseReset,editor.Root})do inside(o,U.Root)end
 assert(named(editor.Root,'Mannequin').AbsoluteSize.Y>=140,'mannequin too small')
 local b=editor.Parts.RightShoulder;local p,s=b.AbsolutePosition,b.AbsoluteSize
 local input={UserInputType=Enum.UserInputType.Touch,Position=Vector3.new(p.X+s.X/2,p.Y+s.Y/2,0)}
 b.InputBegan:Fire(input);input.Position=Vector3.new(p.X+s.X/2+24,p.Y+s.Y/2,0);Services.UserInputService.InputChanged:Fire(input)
 assert(math.abs(pose.Values.RightShoulder[3])>5);Services.UserInputService.InputEnded:Fire(input)
 pose.Confirm();local saved=pose.Values.RightShoulder[3];pose.Begin();pose.Set('RightShoulder',3,0);pose.Cancel();assert(pose.Values.RightShoulder[3]==saved)
 pose.Begin();assert(pose.SetOffset('RightShoulder',1,20)and pose.Offsets.RightShoulder[1]==1.5);pose.Reset();assert(pose.Offsets.RightShoulder[1]==0)
 editor.Destroy()
end
Studio.Exit();return 'direct touchscreen mannequin, no pose scrolling, all actions visible, confirm/cancel and bounded movement'
''')
case('chess_bot_tactics_search_depth_and_cancellation',module('07H4_BOT_ENGINE')+module('07A0_CHESS_RULES','V37')+r'''
local engine=Modules['07H4_BOT_ENGINE'];local rules=Modules['07A0_CHESS_RULES'];local st=rules.New();for r=1,8 do st.board[r]={}end
st.board[1][8]={t='K',c='B'};st.board[8][1]={t='K',c='W'};st.board[4][4]={t='Q',c='B'};st.board[4][5]={t='R',c='W'};st.board[5][6]={t='P',c='W'};st.turn='B';st.repetition={}
local oldRandom=math.random;math.random=function(a,b)return a end
local easy=engine.Choose(rules,st,'Xadrez','FACIL');assert(easy.tr==4 and easy.tc==5,'fixture does not offer tempting capture')
math.random=oldRandom
local medium,ms=engine.Choose(rules,st,'Xadrez','MEDIO',function()return true end);assert(not(medium.tr==4 and medium.tc==5),'medium sacrificed queen')
local hard,hs=engine.Choose(rules,st,'Xadrez','DIFICIL',function()return true end);assert(not(hard.tr==4 and hard.tc==5),'hard sacrificed queen');assert(ms.depth>=2 and hs.depth>ms.depth and hs.nodes>ms.nodes)
assert(st.board[4][4].t=='Q'and st.board[4][5].t=='R'and st.turn=='B','search mutated live game')
local n=0;local cancelled,meta=engine.Choose(rules,st,'Xadrez','DIFICIL',function()n=n+1;return n<50 end);assert(not cancelled and meta.cancelled)
return 'medium/hard avoid a defended capture; hard searches deeper; live state immutable and cancelled search cannot move'
''')
case('checkers_bot_forced_chain_and_memory_levels',module('07H4_BOT_ENGINE')+module('07B0_CHECKERS_RULES','V37')+r'''
local engine=Modules['07H4_BOT_ENGINE'];local rules=Modules['07B0_CHECKERS_RULES'];local st=rules.New();for r=1,8 do st.board[r]={}end
st.board[4][3]={c='B',k=false};st.board[5][4]={c='W',k=false};st.board[7][4]={c='W',k=false};st.board[7][6]={c='W',k=false};st.turn='B'
local move=engine.Choose(rules,st,'Damas','DIFICIL',function()return true end);assert(move.capture and move.tr==6 and move.tc==5)
assert(not st.forced);rules.Apply(st,move);assert(st.turn=='B'and st.forced)
local nextMove=engine.Choose(rules,st,'Damas','DIFICIL',function()return true end);assert(nextMove.capture and nextMove.fr==6 and nextMove.fc==5)
local poisons={[1]=true,[2]=true,[3]=true};local sums={}
for _,diff in ipairs({'FACIL','MEDIO','DIFICIL'})do local n=0;for _=1,2000 do local m=engine.PotatoMemory(poisons,diff);for _ in pairs(m)do n=n+1 end end;sums[diff]=n end
assert(sums.FACIL<sums.MEDIO and sums.MEDIO<sums.DIFICIL)
for _=1,1000 do local i=engine.PotatoPick({[1]=true,[2]=true,[3]=true,[4]=true},{[1]=true,[2]=true,[3]=true});assert(i==4)end
return 'mandatory multi-capture continues on same turn; measurable easy/medium/hard recall and no hidden-information access'
''')
HERE.joinpath('results.json').write_text(json.dumps(results,indent=2,ensure_ascii=False)+'\n')
print('TOTAL',len(results),'PASS')
