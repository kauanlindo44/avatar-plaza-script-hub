"""Execute the revised HUD/Photo Mode and preserve camera/application boundaries."""
from test_support import *
SIZES='{{320,568,0,0,0},{390,844,0,0,34},{568,320,0,0,0},{667,375,0,0,0},{851,392,44,44,21},{1280,720,0,0,0},{1920,1080,0,0,0}}'
HUD=THEME+module('07G6_WORLD_DETAILS')+module('07G4_WORLD_SCENERY')+module('07G7_ADVENTURE_WORLD')+module('07G2_LOCAL_WORLDS')+module('07G1_HUB_SETTINGS')
PHOTO=THEME+module('07P4_STUDIO_UI')+module('07P9_STUDIO_CATALOG')
case('hud_reference_positions_fit_seven_sizes_with_and_without_native_touch',HUD+src('07G_HUB_UI')+r'''
flush();local root=named(pg.LimitedMarketHUD,'HudRoot')
local names={'TopCatalog','TopStores','Community','Emotes','Looks','Loader','Effects','Body','CurrentlyWearing','RestoreAvatar','Games','Photo','Commands','Cfg','AvatarTools'}
for _,touch in ipairs({false,true})do Services.UserInputService.TouchEnabled=touch
 for _,sz in ipairs('''+SIZES+r''')do
  SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0
  root:GetPropertyChangedSignal('AbsoluteSize'):Fire();flush();local visible={}
  for _,name in ipairs(names)do
   local b=named(pg.LimitedMarketHUD,name)or named(pg.AvatarShopLauncherGui,name);assert(b and #b:GetAttribute('ActionLabel')>0)
   if b.Visible then inside(b,pg.LimitedMarketHUD);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44)
    for _,o in ipairs(visible)do assert(not intersects(b,o),name..' overlaps '..o.Name..' '..SCREEN_W..'x'..SCREEN_H..' touch='..tostring(touch))end;visible[#visible+1]=b
   end
  end
  assert(named(root,'Community').Position.X.Offset<named(root,'AvatarTools').Position.X.Offset)
  if touch then
   local jump=Instance.new('Frame');jump.Position=UDim2.fromOffset(SCREEN_W-(sz[4]or 0)-150,SCREEN_H-(sz[5]or 0)-150);jump.Size=UDim2.fromOffset(150,150);jump.Parent=pg.LimitedMarketHUD
   for _,b in ipairs(visible)do assert(not intersects(b,jump),b.Name..' covers native jump fallback')end;jump:Destroy()
  end
 end
end
return '15 actions adapt across 14 geometries, with 44px targets, named roles, no mutual overlap and a reserved touch jump region'
''')
case('hud_exact_destinations_and_body_shortcut_keep_existing_functions',HUD+r'''
local shop=Instance.new('ScreenGui');shop.Name='AvatarShop08Gui';shop.Parent=pg;local sent={}
for _,n in ipairs({'OpenRequest','HudAction'})do local e=Instance.new('BindableEvent');e.Name=n;e.Parent=shop;e.Event:Connect(function(a)sent[#sent+1]=n..':'..a end)end
'''+src('07G_HUB_UI')+r'''
flush();local hud=pg.LimitedMarketHUD;local launch=pg.AvatarShopLauncherGui
for _,v in ipairs({{'TopCatalog','OpenRequest:Catalog'},{'TopStores','OpenRequest:Stores'},{'Community','OpenRequest:Community'},{'Emotes','OpenRequest:Emotes'},{'Looks','OpenRequest:Looks'},{'Loader','OpenRequest:Loader'},{'Body','HudAction:Body'},{'CurrentlyWearing','HudAction:Wearing'},{'RestoreAvatar','HudAction:Reset'}})do
 (named(hud,v[1])or named(launch,v[1])).Activated:Fire();flush();assert(sent[#sent]==v[2],v[1])
end
named(hud,'AvatarTools').Activated:Fire();assert(named(hud,'AvatarShortcuts').Visible)
for _,n in ipairs({'Assistant','Cart','TopMusic','Plus','NewAvatar','SaveRoblox','LoaderShortcut','RestoreShortcut'})do assert(named(hud,n).Active)end
named(hud,'Assistant').Activated:Fire();flush();assert(pg:GetAttribute('ACP_OpenAINonce')==1)
for i=1,50 do named(hud,'Assistant').Activated:Fire()end;assert(pg:GetAttribute('ACP_OpenAINonce')==1)
named(hud,'Commands').Activated:Fire();assert(named(hud,'CommandWindow').Visible);named(hud,'CloseCommands').Activated:Fire();assert(not named(hud,'CommandWindow').Visible)
return 'real BindableEvents receive every intended action; IA remains the first + action, repeat taps cannot toggle it 50 times, and commands close cleanly'
''')
case('photo_background_is_three_by_three_with_pagination_and_no_automatic_purchase',PHOTO+r'''
SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM,CORE_LEFT,CORE_RIGHT,CORE_TOP=851,392,44,44,21,44,44,58
local u=Modules['07P4_STUDIO_UI'].Build(pl);u.Root.Visible=true;u.Popup.Visible=true
local rows={};for i=1,30 do rows[i]={Id=8000+i,Name='Fundo '..i}end
function Services.AvatarEditorService:SearchCatalogAsync(p)assert(p.AssetTypes[1]==Enum.AvatarAssetType.AvatarBackground);return{IsFinished=true,GetCurrentPage=function()return rows end}end
local picked;Modules['07P9_STUDIO_CATALOG'].Open(u,'Background',function(v)picked=v end,function()end);flush();u.Layout();flush()
local list=named(u.Content,'StudioCatalogItems');local cards=list:GetChildren();assert(#cards==9,'background cards '..#cards)
for i,c in ipairs(cards)do
 inside(c,u.Popup);assert(c.AbsoluteSize.X>=44 and c.AbsoluteSize.Y>=44)
 assert(c.Position.X.Offset==cards[(i-1)%3+1].Position.X.Offset and c.Position.Y.Offset==cards[math.floor((i-1)/3)*3+1].Position.Y.Offset)
 for j=1,i-1 do assert(not intersects(c,cards[j]))end
end
local before=LastPrompt;cards[1].Activated:Fire();assert(picked.Id==8001 and LastPrompt==before)
named(u.Content,'NextEmotePage').Activated:Fire();assert(#list:GetChildren()==9 and list:GetChildren()[1]:GetAttribute('AssetId')==8010)
named(u.Content,'PreviousEmotePage').Activated:Fire();assert(list:GetChildren()[1]:GetAttribute('AssetId')==8001)
return 'the actual background search renders exactly 9 cards in 3 columns × 3 rows; page 2 starts at item 10; selecting only previews'
''')
case('photo_seven_layouts_keep_frame_margins_zero_and_shutter_reachable',PHOTO+r'''
local u=Modules['07P4_STUDIO_UI'].Build(pl);u.Root.Visible=true
for _,sz in ipairs('''+SIZES+r''')do
 SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0
 for _,open in ipairs({false,true})do u.CatalogMode=open;u.CatalogKind='Background';u.Popup.Visible=open;u.Layout()
  for _,v in ipairs(u.SceneMargins)do assert(v==0)end;inside(u.Shutter,u.Gui);assert(u.Shutter.AbsoluteSize.X>=44 and u.Shutter.AbsoluteSize.Y>=44)
  if open then inside(u.Popup,u.Gui);assert(not intersects(u.Popup,u.Shutter),'panel covers shutter')end
 end
 u.SetClean(true);assert(not u.Shutter.Visible and u.Restore.Visible);u.SetClean(false);assert(u.Shutter.Visible)
end
return 'photo panels never introduce camera margins; shutter remains reachable and separate from the catalog in all seven safe geometries'
''')
case('body_hud_route_opens_real_body_dialog_without_applying_or_purchasing',UI+DATA+PREVIEW+COMMUNITY+module('09C18_AVATAR_SAVE')+module('09C19_EDITOR_UTILITIES')+r'''
local b=Modules['09C4_OUTFIT_LIBRARY'];local before=S.Current;local oldPrompt=LastPrompt
b.Init({U=U,A=A,S=S,pl=pl,call=function()return true end,toast=function()end});b.OpenBody()
assert(U.BodyWindow.Visible and S.Current==before and LastPrompt==oldPrompt)
return 'the HUD body shortcut reaches the existing proportion controls and leaves avatar state and purchasing unchanged'
''')
STUDIO=THEME+DATA+PREVIEW+module('07P0_STUDIO_PRESETS')+module('07P6_STUDIO_SETS')+module('07P3_POSE_EDITOR')+module('07P2_STUDIO_AVATAR')+module('07P4_STUDIO_UI')+module('07P9_STUDIO_CATALOG')+module('07P7_ROBLOX_BACKGROUNDS')+module('07P1_CAPTURE_ENGINE')+module('07P10_VIDEO_MOTION')
case('real_photo_controller_preserves_camera_and_clone_and_rejects_capture_spam',STUDIO+src('07P_PHOTO_MODE')+r'''
local gui=pg.ACP_PhotoMode;local studio=Modules['07P2_STUDIO_AVATAR'];local original=pl.Character;local cameraType=workspace.CurrentCamera.CameraType
local other=Instance.new('ScreenGui');other.Name='ExistingHud';other.Enabled=true;other.Parent=pg
function Services.AvatarEditorService:SearchCatalogAsync()return{IsFinished=true,GetCurrentPage=function()return{}end}end
pg:SetAttribute('ACP_OpenPhotoNonce',1);flush();assert(studio.Model and not other.Enabled)
local model=studio.Model;local pos=workspace.CurrentCamera.CFrame.Position;local look=workspace.CurrentCamera.CFrame.LookVector;local pivot=model:GetPivot().Position
for i=1,50 do
 advance60(.3);named(gui,i%2==0 and'PhotoBackground'or'PhotoAnimations').Activated:Fire();flush()
 assert(studio.Model==model and pl.Character==original)
 assert((workspace.CurrentCamera.CFrame.Position-pos).Magnitude<1e-9 and(workspace.CurrentCamera.CFrame.LookVector-look).Magnitude<1e-9 and(model:GetPivot().Position-pivot).Magnitude<1e-9)
end
HangCapture64=true;for i=1,100 do named(gui,'TakePhoto').Activated:Fire()end;flush();assert(CaptureCalls64.shot==1)
advance60(13);advance(13);flush();assert(gui.Enabled)
named(gui,'ClosePhoto').Activated:Fire();assert(studio.Model==nil and other.Enabled and pl.Character==original and workspace.CurrentCamera.CameraType==cameraType)
return 'the actual Photo Mode LocalScript survives 50 menu changes with identical camera position/direction and clone pivot; 100 capture taps start one native request, timeout recovers and exit restores the prior HUD/camera'
''')
HERE.joinpath('v76_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
