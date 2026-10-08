from test_support import *
PHOTO=THEME+DATA+PREVIEW+module('07P0_STUDIO_PRESETS')+module('07P3_POSE_EDITOR')+module('07P5_POSE_CANVAS')+module('07P6_STUDIO_SETS')+module('07P2_STUDIO_AVATAR')+"Studio=Modules['07P2_STUDIO_AVATAR']\n"
case('pineapple_native_description_and_visible_structure',DATA+PREVIEW+r'''
local item={Id=72779265740934,AssetType='ShirtAccessory'};Details[item.Id]=item
local shirt,pants=S.Current.props.Shirt,S.Current.props.Pants;assert(S.Try(item));assert(S.Rig=='R15')
assert(S.Current.props.Shirt==shirt and S.Current.props.Pants==pants)
local view=Instance.new('ViewportFrame');view.Size=UDim2.fromOffset(260,320);view.Parent=pg
local ready;local p=Preview.Mount(view,S.Current,'R6',{drag=true,ready=function(m)ready=m end});flush()
assert(ready==p.Model and p.Model and p.Model.Humanoid.RigType.Name=='R15')
assert(PreloadCount>0 and not view.RetryAvatar.Visible and not view.PreviewLoadStatus.Visible)
return 'exact ID remains layered Shirt; R15 selected; classic outfit preserved; physical structure and visual preloading required'
''')
case('cages_meshes_and_specific_instances_required',DATA+r'''
local Load=Modules['08B4_AVATAR_LOAD'];local d=A.Unpack(S.Current)
for _,flag in ipairs({'MissingCage','EmptyMesh','WrongPhysicalID'})do
 _G[flag]=true;local m,e=Load.Create(d,'R15');assert(not m and e,flag);_G[flag]=false
end
d:Destroy();return 'missing body cage, empty accessory mesh and missing exact applied instance cannot pass validation'
''')
case('visual_fetch_failure_and_recoverable_saved_preview',UI+DATA+PREVIEW+COMMUNITY+module('09C1_SHOP_LOOKS')+r'''
FailVisual=true
local ctl=Modules['09C1_SHOP_LOOKS'].Init({U=U,A=A,S=S,pl=pl,buyBody=function()end,toast=function()end,call=function(a)
 if a=='List'then return{skins={{id='audit',name='Look',body=A.Copy(S.Current),rig='R15'}},persistent=true}end;return{items={},finished=true}
end})
U.Root.Visible=true;U.LooksArea.Visible=true;U.SetWide(true);ctl.Saved();flush()
assert(not Preview.Get(U.SavedPreview).Model and U.SavedPreview.RetryAvatar.Visible)
assert(U.SavedPreview.PreviewLoadStatus.Text:find('textura'))
FailVisual=false;U.SavedPreview.RetryAvatar.Activated:Fire();flush();assert(Preview.Get(U.SavedPreview).Model)
return 'content failure visible in saved looks; retry loads valid preview and clears the failure state'
''')
case('photo_uses_same_validation_and_preserves_previous_scene',PHOTO+r'''
MissingPhysical=true;local ok,e=Studio.Enter();assert(not ok and e and not Studio.Model)
MissingPhysical=false;assert(Studio.Enter());local old=Studio.Model
Details[9000]={Id=9000,AssetType='EmoteAnimation'};FailVisual=true
local changed,e=Studio.PlayEmote(9000);assert(not changed and Studio.Model==old)
FailVisual=false;Studio.Exit();return 'photo rejects incomplete clothing; failed emote rebuild leaves previous model intact'
''')
case('disabled_project_setting_has_explicit_error',DATA+r'''
Services.StarterPlayer.LoadCharacterLayeredClothing=Enum.LoadCharacterLayeredClothing.Disabled
local m,e=Modules['08B4_AVATAR_LOAD'].Create(A.Unpack(S.Current),'R15');assert(not m and e:find('configurações'))
return 'disabled project layered setting reports a concrete configuration message without trying to modify a protected property'
''')
HERE.joinpath('avatar_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
