from test_support import *

case('same_emotes_in_another_order_keep_the_same_appearance_key',DATA+r'''
local Native=Modules['08B2_BODY_DESCRIPTION'];local one=A.Copy(S.Current);one.emotes={31,32};local two=A.Copy(one);two.emotes={32,31}
local key=Native.Key(A,one,'R15',false);assert(key==Native.Key(A,two,'R15',false));assert(two.emotes[1]==32)
two.emotes={31,33};assert(key~=Native.Key(A,two,'R15',false));assert(key~=Native.Key(A,one,'R6',false))
return 'unordered native emote dictionaries cannot trigger a false appearance change; actual emote or rig changes still invalidate the key without mutating the saved list'
''')

case('native_rigid_hair_correction_accepts_special_mesh_without_wrap',DATA+r'''
CorrectNativeHair=true
local body=A.Copy(S.Current);body.accessories={{id=80032754788229,type='Hair',layer=true,order=1,puff=0}}
local desc=A.Unpack(body);local Load=Modules['08B4_AVATAR_LOAD']
local m,e=Load.Create(desc,'R15');assert(m,e)
local h=m.Humanoid;local actual=h:GetAppliedDescription();assert(A.Pack(actual).accessories[1].layer==false)
local hair=m:FindFirstChild('RigidHairFixture');assert(hair.Handle:IsA('Part')and hair.Handle:FindFirstChildOfClass('SpecialMesh')and not hair.Handle:FindFirstChildOfClass('WrapLayer'))
MissingCage=true;local noCage,e=Load.Create(desc,'R15');assert(noCage,e);MissingCage=false
Services.StarterPlayer.LoadCharacterLayeredClothing=Enum.LoadCharacterLayeredClothing.Disabled
local disabled,e=Load.Create(desc,'R15');assert(disabled,e)
return 'requested layered Hair corrected by applied native metadata to rigid accepts Part+SpecialMesh without cages or enabled layered clothing'
''')

case('attached_native_classification_overrides_stale_blob',DATA+r'''
CorrectNativeHair=true
local body=A.Copy(S.Current);body.accessories={{id=80032754788229,type='Hair',layer=true,order=1,puff=0}}
local desc=A.Unpack(body);local m=assert(Modules['08B4_AVATAR_LOAD'].Create(desc,'R15'))
assert(Modules['08B3_AVATAR_VERIFY'].Check(m,body,'R15',{applied=desc}))
return 'the applied AccessoryDescription.IsLayered wins over a stale GetAccessories blob and request flag'
''')

case('layered_items_remain_strict_and_identify_exact_failure',DATA+r'''
local Load=Modules['08B4_AVATAR_LOAD'];local body=A.Copy(S.Current)
body.accessories={{id=72779265740934,type='Shirt',layer=true,order=1,puff=0}}
local desc=A.Unpack(body)
for _,spec in ipairs({{'MissingCage','BODY_CAGE'},{'EmptyMesh','MESH'},{'DisabledWrap','WRAP_ENABLED'},{'WrongPhysicalID','APPLIED_INSTANCE'}})do
 _G[spec[1]]=true;local m,e,d=Load.Create(desc,'R15');_G[spec[1]]=false
 assert(not m and d.kind=='validation'and d.itemId==72779265740934 and d.itemType=='Shirt'and d.check==spec[2],e)
 assert(d.cause:find('72779265740934',1,true)and d.expected~='R15'and d.found~='',spec[1]..' cause='..tostring(d.cause)..' expected='..tostring(d.expected)..' found='..tostring(d.found))
end
local m=assert(Load.Create(desc,'R15'));local ad=m.Humanoid:FindFirstChildOfClass('HumanoidDescription'):FindFirstChildOfClass('AccessoryDescription')
ad.IsLayered=false;ad:GetAppliedInstance().Handle:FindFirstChildOfClass('WrapLayer').Enabled=false
local good,e,d=Load.Check(m,desc,'R15');assert(not good and d.check=='WRAP_ENABLED')
return 'shirt remains layered even if metadata says rigid; missing cage/mesh/instance and disabled WrapLayer fail with exact ID and requirement'
''')

case('actually_layered_hair_still_requires_its_wrap',DATA+r'''
local body=A.Copy(S.Current);body.accessories={{id=80032754788229,type='Hair',layer=true,order=1,puff=0}}
local desc=A.Unpack(body);local Load=Modules['08B4_AVATAR_LOAD'];assert(Load.Create(desc,'R15'))
DisabledWrap=true;local m,e,d=Load.Create(desc,'R15');DisabledWrap=false
assert(not m and d.itemId==80032754788229 and d.itemType=='Hair'and d.check=='WRAP_ENABLED')
return 'genuinely layered Hair is still rejected when its WrapLayer is disabled; correction is limited to natively rigid hair'
''')

case('same_type_cannot_substitute_for_missing_requested_item',DATA+r'''
local body=A.Copy(S.Current);body.accessories={{id=72779265740934,type='Shirt',layer=true,order=1,puff=0}}
local desc=A.Unpack(body);local m=assert(Modules['08B4_AVATAR_LOAD'].Create(desc,'R15'))
local ad=m.Humanoid:FindFirstChildOfClass('HumanoidDescription'):FindFirstChildOfClass('AccessoryDescription');ad:Destroy()
local good,e,d=Modules['08B4_AVATAR_LOAD'].Check(m,desc,'R15')
assert(not good and d.itemId==72779265740934 and d.check=='APPLIED_DESCRIPTION')
return 'a valid Shirt instance of the same type cannot confirm an ID whose applied descriptor is absent'
''')

case('rigid_hair_combined_with_pineapple_applies_on_actual_character',DATA+r'''
CorrectNativeHair=true;SERVER_SIDE=true
'''+SERVER+r'''
local body=A.Copy(S.Current);body.accessories={{id=80032754788229,type='Hair',layer=true,order=1,puff=0},{id=72779265740934,type='Shirt',layer=true,order=2,puff=0}}
local Runtime=Modules['09B5_AVATAR_RUNTIME'];local old=pl.Character
local result=Runtime.Apply(pl,A.Unpack(body),'R15');assert(result.applied and pl.Character~=old and pl.Character.Parent==workspace)
assert(result.body.props.Shirt==body.props.Shirt and result.body.props.Pants==body.props.Pants)
local hair,shirt;for _,v in ipairs(result.body.accessories)do if v.id==80032754788229 then hair=v elseif v.id==72779265740934 then shirt=v end end
assert(hair and hair.layer==false and shirt and shirt.layer and not pl:GetAttribute('ACP_AvatarFailure'))
return 'server swap accepts rigid corrected hair plus real layered shirt, preserves classic clothes and records canonical appearance'
''')

case('diagnostic_kind_id_and_requirement_survive_public_and_output',DATA+r'''
local D=Modules['08B5_AVATAR_DIAGNOSTICS'];local ctx=D.New({player=pl,quiet=true})
local logs={};warn=function(v)logs[#logs+1]=v end
local _,detail=D.Fail(ctx,'LAYERS','Missing WrapLayer',nil,nil,{kind='validation',itemId=72779265740934,itemType='Shirt',check='WRAP_LAYER',expected='WrapLayer',found='nil'})
assert(detail.kindLabel=='Validação do jogo'and detail.expected=='WrapLayer'and detail.itemId==72779265740934)
assert(logs[1]:find('item=72779265740934',1,true)and logs[1]:find('requisito=WRAP_LAYER',1,true))
local stored=Services.HttpService:JSONDecode(pl:GetAttribute('ACP_AvatarFailure'));assert(stored.check=='WRAP_LAYER')
D.Mark(ctx,'CREATE','NativeCreate');local _,native=D.Fail(ctx,'CREATE','HTTP 429',nil,nil,{kind='roblox',check='CREATE_MODEL'})
assert(native.kindLabel=='Erro retornado pelo Roblox'and not native.itemId and native.check=='CREATE_MODEL')
return 'typed diagnostics preserve exact failure and original native error; next stage cannot inherit a stale failed item'
''')

case('shop_bootstrap_accepts_existing_v55_cart_module',UI+DATA+PREVIEW+SERVER+module('09C4_OUTFIT_LIBRARY')+module('09C10_CONFIRM_ACTION')+module('09C9_PLAYER_INSPECT')+r'''
local cart=Modules['09C4_OUTFIT_LIBRARY'];assert(cart.VERSION=='V55');local init=cart.Init;local initialized=false
cart.Init=function(ctx)initialized=true;return init(ctx)end
Modules['09A_SHOP_UI']={VERSION='V44_STUDIO_UI',Build=function()return U end};local ui=Instance.new('ModuleScript');ui.Name='09A_SHOP_UI';ui.Parent=rep
for _,n in ipairs({'09C2_SHOP_CATALOG','09C1_SHOP_LOOKS'})do local o=Instance.new('ModuleScript');o.Name=n;o.Parent=rep;Modules[n]={Init=function()return{Search=function()end,Saved=function()end,Community=function()end}end}end
local logs={};warn=function(s)logs[#logs+1]=s end
'''+src('09C_SHOP_CLIENT')+r'''
flush();assert(initialized,'compatible cart was rejected');U.HudAction:Fire('Cart');flush()
assert(U.CartPanel.Visible,'cart action failed through the real shop client')
for _,s in ipairs(logs)do assert(not s:find('09C4_OUTFIT_LIBRARY',1,true),s)end
CorrectNativeHair=true;local old=pl.Character;local body=A.Copy(S.Current)
for _,v in ipairs(body.accessories)do if v.type=='Hair'then v.layer=true end end
body.accessories[#body.accessories+1]={id=72779265740934,type='Shirt',layer=true,order=3,puff=0}
assert(S.Set(body,false,'R15',true));U.Close.Activated:Fire();advance(.5);flush()
assert(pl.Character~=old and not pl:GetAttribute('ACP_AvatarFailure'))
local hair,shirt;for _,v in ipairs(S.Current.accessories)do if v.type=='Hair'then hair=v elseif v.id==72779265740934 then shirt=v end end
assert(hair and hair.layer==false and shirt and shirt.layer)
return 'actual shop initializes V55 cart, opens it, applies layered shirt with corrected rigid hair after closing, and accepts canonical state without another apply loop'
''')

case('native_instance_error_keeps_exact_id_and_native_label',DATA+r'''
local body=A.Copy(S.Current);body.accessories={{id=72779265740934,type='Shirt',layer=true,order=1,puff=0}}
local desc=A.Unpack(body);local Load=Modules['08B4_AVATAR_LOAD'];local m=assert(Load.Create(desc,'R15'))
local ad=m.Humanoid:FindFirstChildOfClass('HumanoidDescription'):FindFirstChildOfClass('AccessoryDescription')
function ad:GetAppliedInstance()error('Native no matching instance #72779265740934')end
local good,e,d=Load.Check(m,desc,'R15');assert(not good and d.itemId==72779265740934 and d.kind=='roblox'and d.check=='GET_APPLIED_INSTANCE')
assert(e:find('Native no matching instance',1,true))
return 'a native per-item API exception keeps its original cause, ID and distinct native classification'
''')

case('client_failure_window_distinguishes_validation_from_native_error',THEME+DATA+r'''
local FeedbackDiag=Modules['08B5_AVATAR_DIAGNOSTICS'];local ctx=FeedbackDiag.New({player=pl,quiet=true})
FeedbackDiag.Fail(ctx,'LAYERS','WrapLayer disabled',nil,nil,{kind='validation',itemId=72779265740934,itemType='Shirt',check='WRAP_ENABLED',expected='Enabled=true',found='Enabled=false'})
'''+src('09C12_AVATAR_FEEDBACK')+r'''
flush();local dialog=named(pg,'AvatarFailureDialog');assert(dialog.Visible)
local function details()for _,o in ipairs(dialog:GetDescendants())do if o:IsA('TextLabel')and o.Text:find('Código:',1,true)then return o.Text end end end
local s=details();assert(s:find('Item com falha: # 72779265740934',1,true)and s:find('Validação do jogo:',1,true)and s:find('WRAP_ENABLED',1,true))
assert(not s:find('Erro do Roblox:',1,true))
FeedbackDiag.Mark(ctx,'CREATE','Players.CreateHumanoidModelFromDescriptionAsync');FeedbackDiag.Fail(ctx,'CREATE','HTTP 429',nil,nil,{kind='roblox',check='CREATE_MODEL'})
s=details();assert(s:find('Erro retornado pelo Roblox:',1,true)and s:find('HTTP 429',1,true))
for _,size in ipairs({{320,568},{851,392},{568,320}})do SCREEN_W,SCREEN_H=size[1],size[2];dialog.Parent:GetPropertyChangedSignal('AbsoluteSize'):Fire();local x=named(dialog,'CloseDiagnostic');assert(x.AbsoluteSize.X>=44 and x.AbsoluteSize.Y>=44)end
return 'real feedback controller labels validation honestly, shows precise ID/check and retains native exception text and accessible close'
''')

case('server_receives_typed_client_item_report_and_drops_forged_id',DATA+r'''
SERVER_SIDE=true
'''+SERVER+r'''
flush();local request=rep:FindFirstChild('LMShop_Remotes').Request;local epoch=pl:GetAttribute('ACP_AvatarEpoch')
advance(.3);local r=request.OnServerInvoke(pl,'ReportVisual',{epoch=epoch,success=false,cause='WrapLayer disabled',kind='validation',stage='LAYERS',itemId=23,itemType='forged',check='WRAP_ENABLED',expected='Enabled=true',found='Enabled=false'})
assert(r.ok,r.error);local d=Services.HttpService:JSONDecode(pl:GetAttribute('ACP_AvatarFailure'))
assert(d.itemId==23 and d.itemType=='Pants'and d.kind=='validation'and d.check=='WRAP_ENABLED'and d.expected=='Enabled=true'and d.side=='Client')
advance(.3);r=request.OnServerInvoke(pl,'ReportVisual',{epoch=epoch,success=false,cause='bad ID',stage='LAYERS',itemId=99999999,check='WRAP_LAYER'});assert(r.ok,r.error)
d=Services.HttpService:JSONDecode(pl:GetAttribute('ACP_AvatarFailure'));assert(not d.itemId)
return 'client proof is preserved in server Output while item identity/type must belong to the server-confirmed avatar'
''')

HERE.joinpath('regression_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
