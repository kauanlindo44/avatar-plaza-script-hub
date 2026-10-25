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
HERE.joinpath('photo_controller_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
