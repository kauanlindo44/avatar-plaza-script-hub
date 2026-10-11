from test_support import *
SETTINGS=THEME+module('07G2_LOCAL_WORLDS')+module('07G1_HUB_SETTINGS')
SIZES="{{320,568,0,0,0},{390,844,0,0,34},{568,320,0,0,0},{667,375,0,0,0},{851,392,44,44,21},{1920,1080,0,0,0}}"
case('hud_safe_geometry_without_music_cart_looks_overlap',SETTINGS+r'''
local kit=Instance.new('Folder');kit.Name='PracaKit';kit.Parent=rep
'''+src('07G_HUB_UI')+r'''
flush();local hud=pg:FindFirstChild('LimitedMarketHUD');local root=hud:FindFirstChild('HudRoot')
local names={'TopCatalog','TopStores','Community','Loader','Looks','Emotes','TopMusic','Cart','Avatar','SaveRoblox','Reset','Games','Photo','Cfg','Plus'}
for _,sz in ipairs('''+SIZES+r''')do
 SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0
 root:GetPropertyChangedSignal('AbsoluteSize'):Fire();flush()
 local target=Instance.new('Frame');target.Position=UDim2.fromOffset(DEVICE_LEFT,58);target.Size=UDim2.fromOffset(SCREEN_W-DEVICE_LEFT-DEVICE_RIGHT,SCREEN_H-58-DEVICE_BOTTOM);target.Parent=hud
 local buttons={};for _,n in ipairs(names)do local b=named(pg,n);assert(b,n);if b.Visible then inside(b,target);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44,n);buttons[#buttons+1]=b end end
 for i,a in ipairs(buttons)do for j=i+1,#buttons do assert(not intersects(a,buttons[j]),a.Name..' overlaps '..buttons[j].Name..' at '..SCREEN_W..'x'..SCREEN_H)end end
 assert(named(pg,'TopStores').Text=='Destaques');target:Destroy()
end
local e=Instance.new('BindableEvent');e.Name='OpenRequest';local gui=Instance.new('ScreenGui');gui.Name='AvatarShop08Gui';gui.Parent=pg;e.Parent=gui
local opened;e.Event:Connect(function(v)opened=v end);named(pg,'TopStores').Activated:Fire();flush();assert(opened=='Stores'and not pg:GetAttribute('ACP_OpenAINonce'))
return '15 HUD controls checked for safe bounds and pairwise overlap at six sizes; free Highlights launches Stores without opening AI'
''')
case('compact_settings_all_categories_worlds_and_legacy_access',SETTINGS+r'''
local gui=Instance.new('ScreenGui');gui.Name='SettingsTest';gui.Parent=pg;local root=Instance.new('Frame');root.Size=UDim2.fromScale(1,1);root.Parent=gui
local u=Modules['07G1_HUB_SETTINGS'].Build(root,pg,function()end,function()end);u.Panel.Visible=true;flush()
for _,sz in ipairs('''+SIZES+r''')do
 SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0
 for _,legacy in ipairs({false,true})do
  pl:SetAttribute('ACP_LegacyAIPlan',legacy and'Pro'or nil);u.Panel.Visible=false;u.Panel.Visible=true;u.Layout()
  assert(u.Panel.AbsoluteSize.X<=620 and u.Panel.AbsoluteSize.Y<=382);inside(u.Close,u.Panel);assert(u.Close.AbsoluteSize.X==48)
  for _,b in ipairs(u.Body:GetChildren())do if b:IsA('GuiButton')then inside(b,u.Body);assert(b.AbsoluteSize.Y>=44 and b.AbsoluteSize.X>=44);assert(b:FindFirstChild('CategoryAccent'))end end
  named(u.Body,'ChangeWorld').Activated:Fire();u.Layout();assert(u.Back.Visible)
  for _,b in ipairs(u.Body:GetChildren())do if b:IsA('GuiButton')then inside(b,u.Body);assert(b.AbsoluteSize.Y>=44)end end
  if legacy then u.Back.Activated:Fire();named(u.Body,'LegacyAI').Activated:Fire();assert(not u.Panel.Visible and pg:GetAttribute('ACP_OpenAINonce'))end
 end
end
return 'compact capped settings panel preserves 44px touch targets, six worlds, back/X, and an optional earlier-purchase shortcut at every safe size'
''')
case('local_world_themes_are_distinct_restore_and_do_not_change_physics',SETTINGS+DATA+r'''
local lighting=Services.Lighting;lighting.ClockTime=13;lighting.Brightness=2;lighting.Ambient=Color3.new(.4,.4,.4);lighting.OutdoorAmbient=Color3.new(.5,.5,.5);lighting.ExposureCompensation=.1;lighting.FogColor=Color3.new(.8,.8,.8);lighting.FogStart=500;lighting.FogEnd=2000
local originalSky=Instance.new('Sky');originalSky.Parent=lighting
local kit=Instance.new('Folder');kit.Name='PracaKit';kit.Parent=rep;kit:SetAttribute('OriginY',60)
local world=Instance.new('Folder');world.Name='PracaAvatar_V2';world.Parent=workspace
local ground=Instance.new('Folder');ground.Name='AvatarFieldGround';ground.Parent=world
local field=Instance.new('Part');field.Name='FieldBase';field.Color=Color3.new(.1,.2,.3);local originalColor=field.Color;field.Material=Enum.Material.Grass;field.Parent=ground
local originals={Cloud='Cloud',ANIME='ToriiBeam',NEON='Skyline',COAST='SeaHorizon',HALLOWEEN='Pumpkin'};local worlds=Modules['07G2_LOCAL_WORLDS'];local health=HUM.Health;local gravity=workspace.Gravity
for _,id in ipairs({'CLOUD','ANIME','NEON','COAST','HALLOWEEN'})do
 assert(worlds.Apply(id));local f=workspace:FindFirstChild('ACP_LocalWorldVisuals');assert(f and named(f,id=='CLOUD'and'FloatingIsland'or originals[id]))
 for _,o in ipairs(f:GetDescendants())do if o:IsA('BasePart')then assert(o.Anchored and not o.CanCollide and not o.CanTouch and not o.CanQuery)end;assert(not o:IsA('Script')and not o:IsA('LocalScript'))end
 assert(workspace.Gravity==gravity and HUM.Health==health and field.Parent==ground)
end
assert(worlds.Apply('ORIGINAL'));assert(not workspace:FindFirstChild('ACP_LocalWorldVisuals'));assert(field.Color==originalColor and field.Material==Enum.Material.Grass)
assert(lighting.ClockTime==13 and originalSky.Parent==lighting)
return 'cloud islands, anime village/gates, neon city, coast and Halloween trees/pumpkins are distinct local geometry; collisions and player untouched, original ground/sky/light restored'
''')
STORES=UI+DATA+module('09C5_UGC_STORES')+r'''
U.Root.Visible=true;U.SetWide(true);U.StoresArea.Visible=true;local actions={};local shown=0;local messages={}
local rows={};for i=1,45 do rows[i]={item={Id=100+i,ItemType='Asset',AssetType='Shirt',Name='Item '..i,Price=i},key='Asset:'..(100+i),favorite=false}end
local function call(a,d)
 actions[#actions+1]={a=a,d=deep(d)}
 if a=='HighlightFeed'then return{items=deep(rows),finished=false}
 elseif a=='HighlightFavorite'then return{value=d.value,favorites={'Asset:'..d.id}}
 elseif a=='HighlightCheck'then return{Id=tonumber(d.id),ItemType=d.kind,Name='Validado',Price=5}
 elseif a=='HighlightStatus'then return{free=true,duration=86400,nextAllowed=TIME60,favorites={}}
 elseif a=='HighlightSubmit'then return{free=true,expires=TIME60+86400}
 elseif a=='HighlightPurchase'then return true end
end
local ctl=Modules['09C5_UGC_STORES'].Init({U=U,A=A,call=call,toast=function(t)messages[#messages+1]=t end,showItem=function()shown=shown+1 end});ctl.Search();flush()
'''
case('horizontal_highlights_adapt_rows_cards_and_touch_controls',STORES+r'''
for _,sz in ipairs('''+SIZES+r''')do
 SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;U.SetWide(true);U.StoresArea:GetPropertyChangedSignal('AbsoluteSize'):Fire();flush()
 local total=0;local visible=0
 for i=1,3 do local row=named(U.StoresArea,'HighlightRow'..i);if row.Visible then visible=visible+1;inside(row,U.StoreGrid);assert(row:GetAttribute('VisibleColumns')<=7);assert(row.CanvasSize.X.Offset>row.AbsoluteSize.X)
  for _,b in ipairs(row:GetChildren())do if b:IsA('GuiButton')then total=total+1
   for _,n in ipairs({'BuyFeatured','FavoriteFeatured'})do local btn=b:FindFirstChild(n);inside(btn,b);assert(btn.AbsoluteSize.X>=44 and btn.AbsoluteSize.Y>=44,n)end
   assert(not intersects(b:FindFirstChild('ItemPrice'),b:FindFirstChild('BuyFeatured')))
   assert(not intersects(b:FindFirstChild('BuyFeatured'),b:FindFirstChild('FavoriteFeatured')))
  end end
 end end
 assert(visible>=1 and visible<=3 and total==45)
 for _,n in ipairs({'PublishHighlight','MoreHighlights'})do local b=named(U.StoresArea,n);inside(b,U.StoresArea);assert(b.AbsoluteSize.Y==44)end
end
return '45 items stay reachable through horizontal rows; at most seven visible cards and three rows, safe footer, readable nonoverlapping prices and 44px buy/favorite targets'
''')
case('highlight_composer_favorite_buy_and_details_are_separate',STORES+r'''
local card=named(U.StoresArea,'Featured_Asset_101');card:FindFirstChild('FavoriteFeatured').Activated:Fire();flush();assert(actions[#actions].a=='HighlightFavorite'and shown==0)
card:FindFirstChild('BuyFeatured').Activated:Fire();flush();assert(actions[#actions].a=='HighlightPurchase'and shown==0)
card.Activated:Fire();assert(shown==1)
local publish=named(U.StoresArea,'PublishHighlight');publish.Activated:Fire();flush()
local shade=named(U.StoresArea,'HighlightModalShade');local composer=named(shade,'HighlightComposer')
assert(shade.Visible and not named(composer,'ConfirmHighlight').Active)
for _,sz in ipairs('''+SIZES+r''')do
 SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;U.SetWide(true);U.StoresArea:GetPropertyChangedSignal('AbsoluteSize'):Fire()
 inside(composer,U.StoresArea)
 for _,n in ipairs({'CloseHighlight','HighlightID','HighlightKind','CheckHighlight','CancelHighlight','ConfirmHighlight'})do local b=named(composer,n);inside(b,composer);assert(b.AbsoluteSize.Y>=44)end
 assert(not intersects(named(composer,'CheckHighlight'),named(composer,'CloseHighlight')))
end
named(composer,'HighlightID').Text='101';named(composer,'CheckHighlight').Activated:Fire();flush();assert(named(composer,'ConfirmHighlight').Active)
named(composer,'ConfirmHighlight').Activated:Fire();flush();assert(not shade.Visible)
local submitted=false;for _,a in ipairs(actions)do if a.a=='HighlightSubmit'then assert(a.d.id==101 and a.d.kind=='Asset');submitted=true end;assert(a.a~='Favorite'and a.a~='CartPurchase')end;assert(submitted)
return 'favorite never enters cart, direct buy opens only purchase, card opens details, composer confirms native item before free submit with safe close and controls'
''')
COMM=UI+DATA+PREVIEW+module('09C7_COMMUNITY_FEED')+r'''
U.Root.Visible=true;U.SetWide(true);U.CommunityArea.Visible=true;local shown
local f=Modules['09C7_COMMUNITY_FEED'].Init({U=U,A=A,call=function(a,d)
 if a=='CuratedPage'then return{items={{id='roblox:321',source='Roblox',owner=321,code='AV-321',name='Look de usuário',sourceUsername='HiddenUser',body=A.Copy(S.Current)}},finished=true}
 elseif a=='Code'then assert(d.code=='AV-321');return{id='roblox:321',source='Roblox',owner=321,code='AV-321',name='Look de jogador',body=A.Copy(S.Current)}end
end,toast=function()end,show=function(r)shown=r end});f.Open();flush()
'''
case('community_cards_only_player_look_and_working_code',COMM+r'''
local slot=f.Pool[1];assert(slot.record and slot.name.Text=='Look de jogador'and slot.author.Text=='AV-321')
assert(not slot.author.Text:find('HiddenUser',1,true)and not slot.author.Text:find('Robux',1,true))
U.ComSearch.Text='AV-321';f.Open();flush();assert(shown and shown.code=='AV-321')
return 'community cards display exactly Look de jogador and a searchable code, without usernames or price text'
''')
PHOTO=THEME+DATA+PREVIEW+module('07P0_STUDIO_PRESETS')+module('07P3_POSE_EDITOR')+module('07P6_STUDIO_SETS')+module('07P2_STUDIO_AVATAR')
case('photo_profile_image_scene_keeps_avatar_pose_and_rotation',PHOTO+r'''
local studio=Modules['07P2_STUDIO_AVATAR'];local ok,e=studio.Enter();assert(ok,e)
assert(studio.Background=='NONE'and studio.Model and #Modules['07P0_STUDIO_PRESETS'].Backgrounds==0)
local avatar=studio.Model;local allowed={id=801,image='rbxassetid://8011',source='RobloxProfile',owned=true,name='Perfil real'}
assert(studio.BuildSet(allowed));local scene=studio.Scene;assert(scene.Image.Image==allowed.image and scene.Count==1)
studio.SetAvatarYaw(120);assert(studio.Scene==scene and studio.Model==avatar)
studio.RotateCamera(20,8);assert(studio.Scene==scene and scene.Image.Image==allowed.image)
assert(not studio.BuildSet({id='HALLOWEEN',image='rbxassetid://1',source='Invented',owned=true}));assert(studio.Scene==scene)
studio.Exit();assert(not scene.Alive and not scene.Model.Parent)
return 'exact avatar model is preserved while rotating/posing; only a validated Roblox profile image is placed, no old decorative rooms, invalid replacement keeps current scene and exit cleans up'
''')
case('actual_shop_client_stores_music_and_cart_focus',UI+DATA+PREVIEW+module('07P8_BACKGROUND_RESOLVER')+module('09B8_FREE_HIGHLIGHTS')+SERVER+module('09C4_OUTFIT_LIBRARY')+module('09C10_CONFIRM_ACTION')+module('09C9_PLAYER_INSPECT')+module('09C5_UGC_STORES')+r'''
local music=Instance.new('ScreenGui');music.Name='ACP_Music';music.Parent=pg;local popup=Instance.new('Frame');popup.Name='MusicPopup';popup.Visible=true;popup.Parent=music
local hud=Instance.new('ScreenGui');hud.Name='LimitedMarketHUD';hud.Enabled=true;hud.Parent=pg
local launcher=Instance.new('ScreenGui');launcher.Name='AvatarShopLauncherGui';launcher.Enabled=true;launcher.Parent=pg;U.LauncherGui=launcher
Modules['09A_SHOP_UI']={VERSION='V44_STUDIO_UI',Build=function()return U end};local u=Instance.new('ModuleScript');u.Name='09A_SHOP_UI';u.Parent=rep
for _,n in ipairs({'09C2_SHOP_CATALOG','09C1_SHOP_LOOKS'})do local o=Instance.new('ModuleScript');o.Name=n;o.Parent=rep;Modules[n]={Init=function()return{Search=function()end,Saved=function()end,Community=function()end,ShowItem=function()end}end}end
'''+src('09C_SHOP_CLIENT')+r'''
flush();U.OpenRequest:Fire('Stores');flush();assert(U.Root.Visible and U.StoresArea.Visible and U.PageTitle.Text=='Destaques grátis')
assert(not pg:GetAttribute('ACP_OpenAINonce')and not popup.Visible and not hud.Enabled and not launcher.Enabled)
U.HudAction:Fire('Cart');flush();assert(U.CartPanel.Visible and not U.Root.Visible and not U.StoresArea.Visible)
U.CartClose.Activated:Fire();flush();assert(U.Root.Visible and U.StoresArea.Visible)
U.Close.Activated:Fire();assert(not U.Root.Visible and hud.Enabled and launcher.Enabled)
return 'actual shop client opens free highlights, closes only music popup without stopping audio, isolates cart, returns to prior page, restores HUD on exit'
''')
case('catalog_halloween_selection_is_orange',UI+DATA+PREVIEW+module('09C4_OUTFIT_LIBRARY')+module('09C2_SHOP_CATALOG')+r'''
U.Root.Visible=true;U.SetWide(false);local selected
local catalog=Modules['09C2_SHOP_CATALOG'].Init({U=U,A=A,S=S,toast=function()end,call=function()return true end,preview=function()end})
for _,b in ipairs(U.Groups:GetChildren())do if b:IsA('GuiButton')and b.Text=='HALLOWEEN'then selected=b end end;assert(selected)
assert(selected.BackgroundColor3.R>selected.BackgroundColor3.G and selected.BackgroundColor3.G>selected.BackgroundColor3.B)
selected.Activated:Fire();flush();local active
for _,b in ipairs(U.Groups:GetChildren())do if b:IsA('GuiButton')and b.Text=='HALLOWEEN'then active=b end end
assert(active.BackgroundColor3.R>.8 and active.BackgroundColor3.G>.4 and active.BackgroundColor3.B<.3)
assert(U.SubToggle.BackgroundColor3.R>U.SubToggle.BackgroundColor3.B and U.SubToggle.TextColor3.R>U.SubToggle.TextColor3.B)
return 'Halloween tab remains orange before and after selection; its submenu uses an orange palette without changing native keyword searches'
''')
HERE.joinpath('interface_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
