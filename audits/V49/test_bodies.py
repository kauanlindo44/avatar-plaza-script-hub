"""Actual V49 Lua source under doubles: no native Roblox meshes or purchases."""
from test_support import *
RUNTIME=module('09B5_AVATAR_RUNTIME')+"Runtime=Modules['09B5_AVATAR_RUNTIME']\n"
BOOT=DATA+RUNTIME+"Runtime.Start();flush();HUM=pl.Character.Humanoid\n"

case('owned_profile_overrides_forced_game_body',DATA+RUNTIME+r'''
InitialDescription.Torso=8801;InitialDescription.Head=8802;InitialDescription.LeftArm=8803;InitialDescription.RightArm=8804;InitialDescription.LeftLeg=8805;InitialDescription.RightLeg=8806
InitialDescription.HeightScale=.72;InitialDescription.WidthScale=.63;InitialDescription.BodyTypeScale=1
HUM.applied.Torso=0;HUM.applied.UseAvatarSettings=true;HUM.applied.HeightScale=1
Runtime.Start();flush();local h,d=Runtime.Description(pl)
assert(d.Torso==8801 and d.Head==8802 and d.LeftArm==8803 and d.RightLeg==8806)
assert(d.HeightScale==.72 and not d.UseAvatarSettings and h.AutomaticScalingEnabled)
assert(d.Shirt==11 and d.Pants==12 and #d:GetAccessories(true)==3)
assert(pl:GetAttribute('ACP_AvatarEpoch')==1 and not pl:GetAttribute('ACP_AvatarError'))
return 'native equipped user description replaces the experience-forced body; six parts/scales survive with original clothes/accessories; no purchase API'
''')
case('join_forced_r6_uses_profile_r15_and_full_parts',DATA+RUNTIME+r'''
HUM.RigType=Enum.HumanoidRigType.R6;local old=pl.Character;local pos=old:GetPivot()
InitialDescription.Torso=9011;InitialDescription.Head=9012;ProfileRig='R15'
Runtime.Start();flush();local h,d=Runtime.Description(pl)
assert(pl.Character~=old and old.destroyed and h.RigType==Enum.HumanoidRigType.R15)
assert(pl.Character:FindFirstChild('UpperTorso')and pl.Character:FindFirstChild('LeftHand')and pl.Character:FindFirstChild('RightFoot'))
assert(d.Torso==9011 and d.Head==9012 and d.Shirt==11)
assert((pl.Character:GetPivot().Position-pos.Position).Magnitude<.001)
pl.appearance=false;assert(Runtime.Description(pl),'managed character depends on native appearance-loaded event that does not fire')
return 'join rebuilds a forced R6 into the equipped R15 profile, keeps spawn position and serves snapshots for managed characters'
''')
case('apply_r6_to_r15_returns_actual_rig_and_body',BOOT+r'''
local old=pl.Character;HUM.RigType=Enum.HumanoidRigType.R6
local d=InitialDescription:Clone();d.Torso=7771;d.Head=7772;d.HeightScale=.68;local events=0
pl.CharacterAdded:Connect(function()events=events+1 end)
local r=Runtime.Apply(pl,d,'R15');local h=pl.Character.Humanoid
assert(r.applied and r.liveRig=='R15'and r.wantedRig=='R15'and h.RigType==Enum.HumanoidRigType.R15)
assert(old.destroyed and events==1 and r.body.props.Torso==7771 and r.body.scales.HeightScale==.68)
assert(r.body.props.Pants==12 and #r.body.accessories==3)
return 'actual generated rig and read-back appearance are returned, instead of success with a live R6'
''')
case('explicit_r15_to_r6_is_rebuilt_instead_of_enum_write',BOOT+r'''
local old=pl.Character;local r=Runtime.Apply(pl,InitialDescription:Clone(),'R6')
assert(r.applied and r.liveRig=='R6'and old.destroyed and pl.Character.Humanoid.RigType==Enum.HumanoidRigType.R6)
for _,n in ipairs({'Torso','Left Arm','Right Arm','Left Leg','Right Leg'})do assert(pl.Character:FindFirstChild(n))end
return 'explicit R6 selection replaces the joint/part hierarchy; no RigType reassignment'
''')
case('wrong_readback_falls_back_to_verified_body_model',BOOT+r'''
WrongReadback=true;MismatchID=15;local old=pl.Character;local d=InitialDescription:Clone();d.HeightScale=.74
local r=Runtime.Apply(pl,d,'R15');assert(r.applied and old.destroyed and r.body.props.Torso==15 and r.body.scales.HeightScale==.74)
return 'successful native method with wrong description is detected and repaired with a verified native model'
''')
case('failed_model_load_keeps_previous_body_and_reports_failure',BOOT+r'''
FailBuild=true;local old=pl.Character;local d=InitialDescription:Clone();d.Torso=7901
local ok=pcall(Runtime.Apply,pl,d,'R15');assert(not ok and pl.Character==old and not old.destroyed)
local _,after=Runtime.Description(pl);assert(after.Torso==15 and after.Shirt==11 and #after:GetAccessories(true)==3)
return 'failed correction returns error and rolls the existing appearance back; no fake success or destroyed avatar'
''')
case('wrong_rig_structure_or_body_assets_never_committed',BOOT+r'''
local old=pl.Character;HUM.RigType=Enum.HumanoidRigType.R6
WrongStructure=true;assert(not pcall(Runtime.Apply,pl,InitialDescription:Clone(),'R15'));assert(pl.Character==old and not old.destroyed)
WrongStructure=false;WrongBuild=true;assert(not pcall(Runtime.Apply,pl,InitialDescription:Clone(),'R15'));assert(pl.Character==old)
return 'wrong fifteen-part structure and wrong body ID both fail before character ownership changes'
''')
case('body_bundle_uses_native_outfit_all_parts_and_scales',DATA+r'''
local native=InitialDescription:Clone()
for i,k in ipairs({'Head','Torso','LeftArm','RightArm','LeftLeg','RightLeg'})do native[k]=8100+i end
native.HeightScale=.71;native.WidthScale=.61;native.RunAnimation=8201;native.Shirt=999;native.Pants=998
function Services.Players:GetHumanoidDescriptionFromOutfitIdAsync(id)assert(id==555);return native:Clone()end
Details[501]={Id=501,ItemType='Bundle',BundleType='BodyParts'}
Bundles[501]={BundleType='BodyParts',Items={{Id=555,Type='UserOutfit'},{Id=8101,Type='Asset'},{Id=8102,Type='Asset'}}}
assert(S.Try(Details[501]));assert(S.Rig=='R15'and S.Current.props.RightLeg==8106 and S.Current.props.RunAnimation==8201)
assert(S.Current.scales.HeightScale==.71 and S.Current.scales.WidthScale==.61)
assert(S.Current.props.Shirt==11 and S.Current.props.Pants==12 and #S.Current.accessories==3)
return 'native package supplies all six meshes, native proportions and animations even if the catalog item list is incomplete; old clothes/accessories survive'
''')
case('unavailable_native_body_outfit_is_not_partial_success',DATA+r'''
Details[501]={Id=501,ItemType='Bundle',BundleType='BodyParts'};Details[8101]={Id=8101,ItemType='Asset',AssetType='Torso'}
Bundles[501]={BundleType='BodyParts',Items={{Id=555,Type='UserOutfit'},{Id=8101,Type='Asset'}}}
function Services.Players:GetHumanoidDescriptionFromOutfitIdAsync()error('HTTP 503')end
local generation=S.Generation;local ok=S.Try(Details[501]);assert(not ok and S.Current.props.Torso==15 and S.Generation==generation)
return 'unavailable native body description reports retry without applying half a package'
''')
case('direct_body_part_promotes_r15_but_shirt_does_not',DATA+r'''
S.SetRig('R6');Details[6501]={Id=6501,ItemType='Asset',AssetType='Shirt'};assert(S.Try(Details[6501])and S.Rig=='R6')
Details[6502]={Id=6502,ItemType='Asset',AssetType='Torso'};assert(S.Try(Details[6502])and S.Rig=='R15'and S.Current.props.Torso==6502)
local current=S.Generation;S.AcceptApplied(A.Copy(S.Current),current,'R15');assert(S.Rig=='R15')
local stale=S.Generation;S.SetScale('HeightScale',1);S.AcceptApplied(A.Copy(S.Original),stale,'R6');assert(S.Rig=='R15')
return 'individual body meshes use R15; normal clothes keep the selected rig; stale server reply cannot change later edits'
''')
case('animation_package_does_not_force_rig_change',DATA+r'''
S.SetRig('R6');Details[500]={Id=500,ItemType='Bundle',BundleType='Animations'};Details[501]={Id=501,ItemType='Asset',AssetType='RunAnimation'}
Bundles[500]={BundleType='Animations',Items={{Id=501,Type='Asset'}}}
assert(S.Try(Details[500])and S.Rig=='R6'and S.Current.props.RunAnimation==501 and S.Current.props.Torso==15)
return 'only body packages force R15; animation packages preserve the existing rig and body'
''')
case('session_outfit_survives_native_respawn',BOOT+r'''
local d=InitialDescription:Clone();d.Torso=8301;d.Shirt=8302;Runtime.Apply(pl,d,'R15')
pl:LoadCharacterAsync();flush();local _,actual=Runtime.Description(pl)
assert(actual.Torso==8301 and actual.Shirt==8302 and actual.Pants==12)
return 'respawn uses the last confirmed outfit in this server session instead of reverting to the experience-forced body'
''')
case('startup_service_outage_retries_without_claiming_loaded_body',DATA+RUNTIME+r'''
local native=Services.Players.GetHumanoidDescriptionFromUserIdAsync
Services.Players.GetHumanoidDescriptionFromUserIdAsync=function()error('HTTP 503')end
Runtime.Start();flush();assert(pl:GetAttribute('ACP_AvatarError')and not pcall(Runtime.Description,pl))
Services.Players.GetHumanoidDescriptionFromUserIdAsync=native;flush()
assert(Runtime.Description(pl)and not pl:GetAttribute('ACP_AvatarError'))
local h=pl.Character.Humanoid;local read=h.GetAppliedDescription
h.GetAppliedDescription=function()error('description unavailable')end
assert(not pcall(Runtime.Apply,pl,InitialDescription:Clone(),'R15'))
h.GetAppliedDescription=read;assert(Runtime.Description(pl),'read failure left the busy flag locked')
return 'profile outage gives a short retry message and can recover; no incorrect body-ready state'
''')
case('catalog_square_preview_controls_and_equipped_x_do_not_overlap',UI+DATA+module('09C4_OUTFIT_LIBRARY')+r'''
local Cart=Modules['09C4_OUTFIT_LIBRARY'];Cart.Init({U=U,A=A,S=S,pl=pl,toast=function()end,call=function()end})
for _,v in ipairs({{320,568},{390,844},{800,360},{844,390},{1600,720},{1920,1080}})do
 SCREEN_W,SCREEN_H=v[1],v[2];U.SetWide(false);flush();U.ItemStrip:GetPropertyChangedSignal('AbsoluteSize'):Fire()
 assert(math.abs(U.Viewport.AbsoluteSize.X-U.Viewport.AbsoluteSize.Y)<.001)
 for _,button in ipairs({U.Apply,U.Save,U.Reset,U.BuyLook,U.BodyToggle})do inside(button,U.Actions);assert(button.AbsoluteSize.Y>=44)end
 assert(U.BodyToggle.Parent==U.Actions and U.Apply.TextColor3.G>U.Apply.TextColor3.R)
 for _,row in ipairs(U.ItemStrip:GetChildren())do if row:IsA('Frame')then
  local image=row:FindFirstChildOfClass('ImageLabel');local close=row.RemoveItem
  assert(image.Image:find('rbxthumb:',1,true)and close.AbsoluteSize.X>=40 and close.AbsoluteSize.Y>=44)
  assert(not intersects(image,close));inside(image,row);inside(close,row)
 end end
end
return 'square viewport, same compact action area, real equipped thumbnails and separate >=40x44 X target on six screens'
''')
case('owned_body_promotes_even_a_profile_marked_r6',DATA+RUNTIME+r'''
ProfileRig='R6';HUM.RigType=Enum.HumanoidRigType.R6;InitialDescription.Torso=8511
Runtime.Start();flush();local h,d=Runtime.Description(pl)
assert(h.RigType==Enum.HumanoidRigType.R15 and d.Torso==8511)
return 'equipped custom body gets the complete R15 hierarchy even when the profile still reports R6'
''')
case('failed_old_request_cannot_replace_a_newer_character',BOOT+r'''
local previous=pl.Character;local other=Services.Players:CreateHumanoidModelFromDescriptionAsync(InitialDescription,Enum.HumanoidRigType.R15);other.Parent=workspace
local factory=Services.Players.CreateHumanoidModelFromDescriptionAsync
function Services.Players:CreateHumanoidModelFromDescriptionAsync(desc,rig)local m=factory(self,desc,rig);pl.Character=other;return m end
local d=InitialDescription:Clone();d.Torso=8501;assert(not pcall(Runtime.Apply,pl,d,'R15'))
assert(pl.Character==other and not other.destroyed and not previous.destroyed)
return 'character replacement during an asset request invalidates the old operation before swap or destruction'
''')
case('movement_camera_and_animation_bundle_refresh_for_rebuilt_character',BOOT+r'''
local char=pl.Character;local h=char.Humanoid;local a=char.AnimatorTestSetup();workspace.CurrentCamera.CameraType=Enum.CameraType.Custom
local old=pl.Character;local animate=Instance.new('LocalScript');animate.Name='Animate';animate.Parent=old
local template=Instance.new('LocalScript');template.Name='Animate';template.Parent=Services.StarterPlayer.StarterCharacterScripts
-- Verify incompatible Animate isn't carried across a rig transition.
local r=Runtime.Apply(pl,InitialDescription:Clone(),'R6');char=pl.Character;h=char.Humanoid;a=char.AnimatorTestSetup()
assert(not char:FindFirstChild('Animate'));assert(old.destroyed)
'''+src('09C11_AVATAR_CHARACTER')+r'''
flush();assert(workspace.CurrentCamera.CameraSubject==h and #a.loaded==1 and a.loaded[1].playing)
h.Running:Fire(16);assert(#a.loaded==2 and a.loaded[2].playing and not a.loaded[1].playing)
h.StateChanged:Fire(Enum.HumanoidStateType.Running,Enum.HumanoidStateType.Jumping);assert(#a.loaded==3)
h.applied.IdleAnimation=9999;pl:SetAttribute('ACP_AvatarEpoch',99);flush()
assert(a.loaded[#a.loaded].AnimationId=='rbxassetid://9999')
workspace.CurrentCamera.CameraType=Enum.CameraType.Scriptable;local subject=workspace.CurrentCamera.CameraSubject
pl:SetAttribute('ACP_AvatarEpoch',100);flush();assert(workspace.CurrentCamera.CameraType==Enum.CameraType.Scriptable and workspace.CurrentCamera.CameraSubject==subject)
return 'new Humanoid becomes normal camera subject; rig-specific fallback locomotion works and refreshed animation IDs take effect without forcing a scripted camera'
''')
HERE.joinpath('body_results.json').write_text(json.dumps(results,indent=2,ensure_ascii=False)+'\n')
print('BODY AND CATALOG',len(results),'PASS')
