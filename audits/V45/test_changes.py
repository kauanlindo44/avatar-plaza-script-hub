from test_support import *
CARD_UI=THEME+module('07K0_TRUCO_RULES')+module('07K6_CARD_CATALOG')+module('07K7_CARD_STYLES')+module('07K5_TRUCO_UI')+module('07K9_CARD_INVENTORY_UI')+module('07K12_TOURNAMENT_UI')+module('07H1_GAME_LOBBY')
case('card_face_artwork_readable_suits_all_styles_and_custom_both_sides',CARD_UI+r'''
local c=Modules['07K6_CARD_CATALOG'];local cards=Modules['07K7_CARD_STYLES'];local r=Modules['07K0_TRUCO_RULES'];local host=Instance.new('Frame');host.Size=UDim2.fromOffset(120,180)
local function luminance(v)return .2126*v.R+.7152*v.G+.0722*v.B end
for style in pairs(c.Styles)do local part=Instance.new('Part');local surface=cards.Surface(part,{rank='A',suit='S'},style);assert(typeof(part.Material)=='EnumItem'and surface.Face==Enum.NormalId.Top);part:Destroy();for _,card in ipairs(r.Deck())do
 local face=cards.Render(host,card,style,{Size=UDim2.fromScale(1,1)})
 assert(face:GetAttribute('Suit')==card.suit and face:GetAttribute('Rank')==card.rank and face:GetAttribute('FaceIdentityProtected'))
 local symbol=named(face,'Suit');local corner=named(face,'RankAndSuit');assert(symbol and corner and corner.Text:find(card.rank,1,true))
 assert(luminance(symbol.Parent.BackgroundColor3)-luminance(symbol.TextColor3)>.6,'suit contrast insufficient')
 assert(face.BackgroundColor3.R==c.Styles[style].colors[1][1]/255,'front lost chosen material')
 face:Destroy()
end end
for _,card in ipairs({{rank='A',suit='D'},false,{covered=true},{hidden=true}})do
 local root=cards.Render(host,card or nil,'Custom',{Size=UDim2.fromScale(1,1)},{image=6789,zoom=1.4,x=.1,y=-.1})
 assert(named(root,'CustomArtwork'),'custom image missing on front or back')
 if card and card.rank then assert(named(root,'CardFace'))else assert(not named(root,'RankAndSuit'),'covered/hidden card leaked identity')end;root:Destroy()
end
return '400 style/card combinations retain rank and suit with high contrast; full material visible on fronts; custom artwork visible on both sides; covered/iron cards reveal no identity'
''')
case('inventory_all_pages_no_scroll_fixed_controls_and_owned_atelier',CARD_UI+r'''
local gui=Instance.new('ScreenGui');gui.ScreenInsets=Enum.ScreenInsets.None;gui.Parent=pg
local catalog=Modules['07K6_CARD_CATALOG'];local data={coins=10000,owned={},equipped='Classic',ateliers=true,boxes={Nox=1,Reign=1,Eclipse=1},custom={image=6789,zoom=1.3,x=.1,y=0}}
for key in pairs(catalog.Styles)do data.owned[key]=true end
local u=Modules['07K9_CARD_INVENTORY_UI'].Build(gui,function(a)if a=='inventory'then return data end;return{passes={},products={}}end,function()end)
u.Show();flush();assert(u.List.ClassName=='Frame')
for _,v in ipairs({{320,568,0,0,58,0},{360,640,0,0,58,0},{800,360,0,0,58,0},{844,390,44,44,58,22},{1920,1080,0,0,58,0}})do
 SCREEN_W,SCREEN_H,CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=table.unpack(v)
 for _,tab in ipairs({'Caixas','Visuais','Loja'})do
  u.Tab=tab;u.Page=1;u.Render();flush();local seen={};local pages=tonumber(u.PageLabel.Text:match('/ (%d+)'))
  for page=1,pages do
   u.Page=page;u.PaintPage();for _,b in ipairs(u.List:GetChildren())do if b:IsA('GuiButton')then inside(b,u.List);seen[b.Name]=true end end
   for _,o in ipairs({u.Previous,u.Next,u.CardHost,u.Flip,u.Note,u.CoinBuy,u.RobuxBuy,u.Close})do if o.Visible then inside(o,u.Root)end end
   assert(not intersects(u.Flip,u.CoinBuy)and not intersects(u.CoinBuy,u.Note),'fixed details overlap')
  end
  local n=0;for _ in pairs(seen)do n=n+1 end;assert(n==(tab=='Caixas'and 3 or tab=='Visuais'and 11 or 12),'page lost inventory/shop entries')
 end
 u.Tab='Ateliê';u.Render();for _,o in ipairs({u.CustomID,u.ImageStatus,u.CustomPreview,u.Minus,u.Plus,u.Center,u.CustomFlip,u.SaveCustom})do inside(o,u.Atelier)end
 for _,b in ipairs({u.Minus,u.Plus,u.Center,u.CustomFlip,u.SaveCustom})do assert(b.AbsoluteSize.Y>=44);assert(not intersects(b,u.CustomPreview))end
 assert(not intersects(u.SaveCustom,u.Center)and not intersects(u.SaveCustom,u.CustomFlip))
end
return 'all 12 shop entries and 11 owned visuals reachable via fixed pages; six slots landscape/four portrait; no vertical scrolling; buy/flip/X and entire Atelier visible without overlap at five sizes including notches'
''')
case('atelier_loading_failure_draft_preservation_and_boolean_controls',CARD_UI+r'''
local gui=Instance.new('ScreenGui');gui.Parent=pg;local data={coins=0,owned={Classic=true},equipped='Classic',ateliers=true,boxes={},custom={image=6789,zoom=1.3,x=0,y=0}}
local old=Instance.new;Instance.new=function(class)local o=old(class);if class=='ImageLabel'then o.IsLoaded=false end;return o end
local saved;local u=Modules['07K9_CARD_INVENTORY_UI'].Build(gui,function(a,args)if a=='inventory'then return data elseif a=='custom'then saved=deep(args);return true end;return{passes={},products={}}end,function()end)
u.Tab='Ateliê';u.Show();flush();assert(not u.SaveCustom.Active)
u.CustomID.Text='https://www.roblox.com/library/9999/Test';u.CustomID.FocusLost:Fire();advance(11);assert(u.ImageStatus.Text:find('indisponível',1,true))
u.SaveCustom.Activated:Fire();assert(not saved,'unloaded image was saved')
local image=named(u.CustomPreview,'CustomArtwork');image.IsLoaded=true;image:GetPropertyChangedSignal('IsLoaded'):Fire();assert(u.SaveCustom.Active)
u.SaveCustom.Activated:Fire();assert(saved.image==9999)
local button=Instance.new('TextButton');Modules['07UI_DESIGN_SYSTEM'].SetEnabled(button,nil);assert(button.Active==false and button.AutoButtonColor==false)
return 'unavailable/unmoderated image cannot appear saved; loaded event enables saving; edits preserved; nil enable value converts to native boolean safely'
''')
case('community_two_visible_rows_paid_free_tabs_and_larger_catalog_thumbnails',UI+DATA+PREVIEW+COMMUNITY+r'''
local requests={};local ctl=Modules['09C7_COMMUNITY_FEED'].Init({U=U,A=A,toast=function()end,show=function()end,call=function(action,args)
 assert(action=='CuratedPage'and(args.budget=='free'or args.budget=='paid'));requests[#requests+1]=args.budget
 local out={};for i=1,50 do local id=args.page*50+i+1;out[i]={id='roblox:'..id,owner=id,source='Roblox',sourceUsername='Real'..id,body=A.Copy(S.Current),name='Look de jogador',total=args.budget=='free'and 0 or 25,signature=tostring(id)}end
 return{items=out,finished=false}
end})
U.Root.Visible=true;U.CommunityArea.Visible=true;U.SetWide(true)
for _,v in ipairs({{320,568,0,0,58,0},{800,360,0,0,58,0},{844,390,44,44,58,22},{1920,1080,0,0,58,0}})do
 SCREEN_W,SCREEN_H,CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=table.unpack(v);U.Layout();ctl.Open('JOGADORES');flush()
 local step=ctl.Pool[1].root.AbsoluteSize.Y+6;local cols=math.clamp(math.floor((U.CommunityGrid.AbsoluteSize.X+6)/126),2,5)
 assert(step*2-6<=U.CommunityGrid.AbsoluteWindowSize.Y+1,'second community row clipped')
 for i=1,cols*2 do inside(ctl.Pool[i].root,U.CommunityGrid);assert(ctl.Pool[i].image.AbsoluteSize.Y>=45)end
 U.ComTabButtons['GRÁTIS'].Activated:Fire();flush();assert(requests[#requests]=='free'and ctl.Pool[1].author.Text=='GRÁTIS')
end
return 'two complete rows at four sizes with native player thumbnails; explicit paid/free tabs call validated budgets; no synthetic Roblox character tab'
''')
case('community_free_body_bundle_and_unknown_price_retry',DATA+module('09B2_COSPLAY_METADATA')+module('09B1_AVATAR_DISCOVERY')+module('09B4_CURATED_LOOKS')+r'''
function Services.Players:GetHumanoidDescriptionFromUserIdAsync(id)local d=InitialDescription:Clone();d.Shirt=id*10+1;d.Pants=id*10+2;d.Head=900;return d end
function Services.AvatarEditorService:GetBatchItemDetailsAsync(ids)
 local out={};for _,id in ipairs(ids)do out[#out+1]={Id=id,Name='Item',Price=0,PriceStatus=id==900 and 'Off Sale' or 'Free'}end;return out
end
local calls=0
function Services.AvatarEditorService:GetBundlesByAssetIdAsync(id)
 calls=calls+1;assert(id==900);return{GetCurrentPage=function()return{{Id=555,Price=0,PriceStatus='Free',BundledItems={{Id=900}}}}end}
end
local m=Modules['09B4_CURATED_LOOKS'];local page=m.Page(pl,{page=0,budget='free'});assert(#page.items>0 and calls==1,'free native body bundle failed or cache absent')
for _,r in ipairs(page.items)do assert(r.total==0 and r.body.props.Head==900)end
return 'off-sale body asset may be obtained in a verified free native bundle; bundle priced once and cached; unknown items still cannot be classified free'
''')
TRUCO=CARD_UI+DATA+module('07K4_TRUCO_TABLES')+r'''
local kit=Instance.new('Folder');kit.Name='PracaKit';kit.Parent=rep;local rem=Instance.new('Folder');rem.Name='Remotes';rem.Parent=kit
local request=Instance.new('RemoteFunction');request.Name='TrucoRequest';request.Parent=rem
local push=Instance.new('RemoteEvent');push.Name='TrucoPush';push.Parent=rem
local inv={coins=1000,owned={Classic=true,Aether=true},equipped='Aether',ateliers=true,boxes={},custom={image=6789,zoom=1.3,x=.1,y=0},view='mine'}
local lastAction;local leaves=0;local function rpc(action,args)
 if action=='inventory'then return{ok=true,data=inv}elseif action=='action'then lastAction=deep(args);return{ok=true,data=true}elseif action=='leave'then leaves=leaves+1;return{ok=true,data=true}end
 return{ok=true,data=true}
end
request.InvokeServer=function(_,action,args)return rpc(action,args)end
local world=Instance.new('Folder');world.Name='PracaAvatar_V2';world.Parent=workspace;local district=Instance.new('Folder');district.Name='ChallengeDistrict';district.Parent=world
local tables=Modules['07K4_TRUCO_TABLES'].Build(district);local tableModel=tables[1]
pl.Character=Services.Players:CreateHumanoidModelFromDescriptionAsync(InitialDescription,Enum.HumanoidRigType.R15);pl.Character.Parent=workspace
for _,side in ipairs({'Left','Right'})do local hand=Instance.new('Part');hand.Name=side..'Hand';hand.Parent=pl.Character end
task.wait=function(seconds)TEST_TIME=TEST_TIME+(seconds or 0)end
local savedCamera={kind=workspace.CurrentCamera.CameraType,cf=workspace.CurrentCamera.CFrame,fov=workspace.CurrentCamera.FieldOfView}
'''+src('07K_TRUCO_CLIENT')+r'''
flush();local gui=pg.ACP_Truco;local r=Modules['07K0_TRUCO_RULES'];local s=r.New('Paulista',4);r.Begin(s,r.Deck(),false)
local view=r.View(s,1);view.players={{name='A'},{name='B'},{name='C'},{name='D'}};view.styles={{style='Classic'},{style='Onyx'},{style='Hex'},{style='Nova'}};view.tableName=tableModel.Name;view.revision=1
'''
case('truco_first_person_private_world_hand_touch_and_restore',TRUCO+r'''
local cam=workspace.CurrentCamera
for _,screen in ipairs({{320,568},{844,390},{1920,1080}})do
 SCREEN_W,SCREEN_H=screen[1],screen[2];cam.ViewportSize=Vector2.new(SCREEN_W,SCREEN_H);pl.Character.Head.CFrame=CFrame.new(tableModel.Seat1.Position+Vector3.new(0,3.4,0))
 push.OnClientEvent:Fire('match',view);flush();Services.RunService.RenderStepped:Fire()
 assert(cam.CameraType==Enum.CameraType.Scriptable and cam.FieldOfView==65 and Services.GuiService.TouchControlsEnabled==false)
 assert((cam.CFrame.Position-pl.Character.Head.Position).Magnitude>.5,'camera remained in the head')
 assert(pl.Character.Head.LocalTransparencyModifier==1 and pl.Character.LeftHand.LocalTransparencyModifier==1)
 local count=0;for _,p in ipairs(cam:GetChildren())do if p.Name=='ACP_PrivateHandCard'then count=count+1;assert(p.ACP_CardFace.Face==Enum.NormalId.Back and not p.CanCollide and not p.CanQuery)
  local center=cam:WorldToViewportPoint(p.Position);assert(center.X>0 and center.X<SCREEN_W and center.Y>SCREEN_H*.50 and center.Y<SCREEN_H-44,'hand hides table or leaves screen')
 end end;assert(count==3 and cam:FindFirstChild('ACP_LeftHand')and cam:FindFirstChild('ACP_RightHand'))
 assert(not named(gui,'PrivateHand').Visible and not named(gui,'PlayCard'),'rectangle overlay hand remained')
end
local cards={};for _,p in ipairs(cam:GetChildren())do if p.Name=='ACP_PrivateHandCard'then cards[#cards+1]=p end end
local point=cam:WorldToViewportPoint(cards[#cards].Position);local input={UserInputType=Enum.UserInputType.Touch,Position=point}
Services.UserInputService.InputBegan:Fire(input,true);assert(not lastAction)
Services.UserInputService.InputBegan:Fire(input,false);assert(lastAction and lastAction.action=='play'and lastAction.arg==3 and lastAction.revision==1)
view.turn=2;lastAction=nil;push.OnClientEvent:Fire('match',view);Services.UserInputService.InputBegan:Fire(input,false);assert(not lastAction)
push.OnClientEvent:Fire('closed');assert(cam.CameraType==savedCamera.kind and cam.FieldOfView==savedCamera.fov)
assert(pl.Character.Head.LocalTransparencyModifier==0 and pl.Character.LeftHand.LocalTransparencyModifier==0 and Services.GuiService.TouchControlsEnabled==true)
assert(not cam:FindFirstChild('ACP_PrivateHandCard')and pg:GetAttribute('ACP_TrucoActive')==false)
return 'first-person camera looks outward; original face/accessories hidden only locally; three private 3D cards and avatar hands; touch ray selects correct owned card; opponent turn ignored; camera/transparency/models restored on exit'
''')
HERE.joinpath('changes_results.json').write_text(json.dumps(results,indent=2,ensure_ascii=False)+'\n')
print('V45 CHANGES',len(results),'PASS')
