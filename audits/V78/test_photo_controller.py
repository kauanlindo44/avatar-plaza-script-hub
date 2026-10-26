from test_support import *
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
case('live_camera_closes_before_photo_captures_camera_even_with_reverse_signal_order',STUDIO+src('07P_PHOTO_MODE')+r'''
workspace.CurrentCamera.Parent=workspace
local gui=pg.ACP_PhotoMode;local d=Modules['07UI_DESIGN_SYSTEM'];local bounds=Modules['07UI_SCREEN_BOUNDS'];local free=Modules['07G13_FREE_CAMERA'].Build(pg,bounds.Bind(d.New('ScreenGui',{},pg)),function()end)
local original=workspace.CurrentCamera.CameraType;assert(free.Start()and free.Active)
pg:SetAttribute('ACP_OpenPhotoNonce',1);flush()
assert(not free.Active and Modules['07P2_STUDIO_AVATAR'].Model and workspace.CurrentCamera.CameraType==Enum.CameraType.Scriptable)
named(gui,'ClosePhoto').Activated:Fire();assert(workspace.CurrentCamera.CameraType==original and next(RenderCallbacks78)==nil)
return 'photo first, free-camera callback second: explicit handoff restores the original state before photo snapshots it; photo close returns to the original camera type'
''')
HERE.joinpath('photo_controller_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
