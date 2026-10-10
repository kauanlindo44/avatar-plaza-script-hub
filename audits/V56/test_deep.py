from test_support import *
PHOTO=THEME+DATA+PREVIEW+module('07P0_STUDIO_PRESETS')+module('07P3_POSE_EDITOR')+module('07P5_POSE_CANVAS')+module('07P6_STUDIO_SETS')+module('07P2_STUDIO_AVATAR')+"Studio=Modules['07P2_STUDIO_AVATAR']\n"
AI=THEME+DATA+SERVER+module('09I0_ASSISTANT_CONFIG')+module('09I1_ASSISTANT_ACCOUNTS')+module('09I2_ASSISTANT_ENGINE')+module('09I3_OUTFIT_BUILDER')
case('native_error_trace_keeps_original_asset_and_stage',DATA+r'''
local logs={};warn=function(s)logs[#logs+1]=s end
local D=Modules['08B5_AVATAR_DIAGNOSTICS'];local ctx=D.New({player=pl,source='native-test',items={72779265740934},quiet=true})
local original=Services.Players.CreateHumanoidModelFromDescriptionAsync
Services.Players.CreateHumanoidModelFromDescriptionAsync=function()error('HTTP 429 asset 72779265740934')end
local model,message,detail=Modules['08B4_AVATAR_LOAD'].Create(A.Unpack(S.Current),'R15',{diagnostic=ctx})
assert(not model and detail.stage=='CREATE' and detail.trace==ctx.trace and detail.items[1]==72779265740934)
assert(detail.cause:find('HTTP 429 asset 72779265740934',1,true));assert(logs[#logs]:find('Erro original:',1,true))
assert(pl:GetAttribute('ACP_AvatarFailure')and message:find('código',1,true))
assert(#D.Items({accessories='wrong',props=false})==0)
return 'native 429 preserved verbatim in Output with stage/source/ID/trace; malformed diagnostic input stays bounded'
''')
case('server_confirmation_does_not_require_client_content_download',DATA+r'''
SERVER_SIDE=true;FailVisual=true;local before=PreloadCount or 0
local Load=Modules['08B4_AVATAR_LOAD'];local model,e=Load.Create(A.Unpack(S.Current),'R15');assert(model,e);assert((PreloadCount or 0)==before)
SERVER_SIDE=false;local ok,e,proof=Load.Check(model,A.Unpack(S.Current),'R15');assert(not ok and proof.stage=='CONTENT')
assert(e:find('Failure',1,true));model:Destroy()
return 'server confirms native description/physical instances; the client reports its separate fetch failure instead of blocking all server swaps'
''')
case('equipped_tool_assets_cannot_block_avatar_validation',DATA+r'''
local Load=Modules['08B4_AVATAR_LOAD'];local m=assert(Load.Create(A.Unpack(S.Current),'R15'))
local tool=Instance.new('Tool');tool.Parent=m;local mesh=Instance.new('MeshPart');mesh.MeshId='bad-tool';mesh.Parent=tool
function Services.ContentProvider:PreloadAsync(assets,callback)
 for _,o in ipairs(assets)do callback(o.MeshId,Enum.AssetFetchStatus[o.MeshId=='bad-tool'and'Failure'or'Success'])end
end
assert(Load.Check(m,A.Unpack(S.Current),'R15'));m:Destroy()
return 'unrelated tool meshes are excluded from avatar content verification'
''')
case('failed_postswap_confirmation_restores_old_character_and_tools',DATA+r'''
SERVER_SIDE=true
'''+SERVER+r'''
local Runtime=Modules['09B5_AVATAR_RUNTIME'];flush();local old=pl.Character
local tool=Instance.new('Tool');tool.Name='KeptTool';tool.Parent=old
local before=A.Copy(S.Current);before.props.Torso=9001
local check=Modules['08B4_AVATAR_LOAD'].Check
Modules['08B4_AVATAR_LOAD'].Check=function(model,...)
 if pl.Character==model and model~=old then return false,'fixture final confirmation failure' end
 return check(model,...)
end
local ok,e=pcall(Runtime.Apply,pl,A.Unpack(before),'R15');assert(not ok)
assert(pl.Character==old and old.Parent==workspace and tool.Parent==old and old.Humanoid.Health>0)
return 'old character remains intact through final verification; failed replacement restores its tools, parent and live player reference'
''')
case('fixed_block_sets_do_not_follow_avatar_camera_or_resize',PHOTO+r'''
assert(Studio.Enter());local scene=Studio.Scene;local before={}
for _,p in ipairs(scene.Model:GetChildren())do if p:IsA('BasePart')then before[p]=p.CFrame;assert(not p.CanQuery and not p.CanCollide)end end
local camera=Studio.Camera.CFrame;Studio.Rotate(90);assert(Studio.Camera.CFrame==camera and Studio.AvatarYaw==90)
Studio.RotateCamera(45,12);Studio.SetFrame('MEDIUM');Studio.SetMargins(100,70,200,10)
for p,cf in pairs(before)do assert(p.CFrame==cf,p.Name..' moved with camera')end
for _,preset in ipairs(Modules['07P0_STUDIO_PRESETS'].Backgrounds)do
 assert(Studio.BuildSet(preset.id));assert(Studio.Scene.Count>=6 and Studio.Scene.Count<=70)
 assert(Studio.Scene.Model:FindFirstChild('Backdrop')and Studio.Scene.Model:FindFirstChild('WallFront'))
 if preset.id=='HALLOWEEN'then assert(Studio.Scene.Model:FindFirstChild('PumpkinEye')and Studio.Scene.Model:FindFirstChild('FriendlyGhost'))end
end
Studio.Exit();assert(not Studio.Folder and not Studio.Scene)
return 'rotating avatar leaves camera and block CFrames unchanged; six local rooms including Halloween stay fixed during independent camera and layout changes'
''')
case('animated_ghost_details_keep_their_relative_position',PHOTO+r'''
assert(Studio.Enter());Studio.BuildSet('HALLOWEEN');local scene=Studio.Scene
local ghost=scene.Model:FindFirstChild('FriendlyGhost');local eye=scene.Model:FindFirstChild('GhostEye');local offset=eye.CFrame.Position.Y-ghost.CFrame.Position.Y
scene.SetAnimated(true);Services.RunService.RenderStepped:Fire(.2)
assert(math.abs((eye.CFrame.Position.Y-ghost.CFrame.Position.Y)-offset)<.00001);Studio.Exit()
return 'optional ghost animation carries its eyes; main room and avatar remain stationary'
''')
case('failed_native_emote_play_keeps_previous_pose_and_model',PHOTO+r'''
assert(Studio.Enter());local old=Studio.Model;local oldPose=Studio.Pose
Details[9000]={Id=9000,AssetType='EmoteAnimation'}
local create=Services.Players.CreateHumanoidModelFromDescriptionAsync
function Services.Players:CreateHumanoidModelFromDescriptionAsync(...)
 local model=create(self,...);model.Humanoid.PlayEmoteAsync=function()return false end;return model
end
local ok,e=Studio.PlayEmote(9000);assert(not ok and Studio.Model==old and Studio.Pose==oldPose and old.Parent)
assert(e:find('anterior',1,true));Studio.Exit()
return 'animation creation and playback validate before replacing the current avatar or pose'
''')
case('native_health_completion_updates_all_connected_clients',AI+src('09I_ASSISTANT_SERVER')+r'''
local events=rep:FindFirstChild('ACP_AssistantRemotes').Progress;local health={}
function events:FireClient(player,data)if data.kind=='health'then health[player.UserId]=data end end
flush();assert(health[123]and health[123].available and not health[123].checking)
local request=rep:FindFirstChild('ACP_AssistantRemotes').Request
advance(.3);local r=request.OnServerInvoke(pl,'status',{});assert(r.ok and r.data.available and not r.data.checking)
return 'startup native health broadcasts readiness; an early unavailable snapshot cannot leave the interface permanently offline'
''')
case('hair_edit_preserves_other_items_and_cleans_previous_hair',AI+r'''
function Services.AvatarEditorService:SearchCatalogAsync(p)
 assert(p.AssetTypes[1].Name=='HairAccessory');return{GetCurrentPage=function()return{{Id=99111,Name='Real hair',Price=20,ItemType='Asset',AssetType='HairAccessory'}}end}
end
local base=A.Copy(S.Current);base.accessories[#base.accessories+1]={id=99222,type='Hair',layer=false,order=0,puff=0}
local builder=Modules['09I3_OUTFIT_BUILDER'];local opts=builder.Options({scope='Cabelo',keep=false,budget=30},'Normal')
assert(opts.keep and opts.scope=='Cabelo')
local rows,e=builder.Build(pl,'emo',opts,base,function()end,function()return true end);assert(rows,e)
assert(rows[1].body.props.Shirt==base.props.Shirt and rows[1].body.props.Torso==base.props.Torso)
local oldHair,newHair=false,false;for _,v in ipairs(rows[1].body.accessories)do oldHair=oldHair or v.id==99222;newHair=newHair or v.id==99111 end
assert(not oldHair and newHair and rows[1].total==20)
return 'a targeted hair change keeps clothes/body/other accessories; replacement scope and budget are validated server-side'
''')
case('dynamic_halloween_windows_preserve_card_and_board_art',THEME+module('07K6_CARD_CATALOG')+module('07K7_CARD_STYLES')+r'''
local theme=Modules['07UI_HALLOWEEN_THEME'];theme.Start(pg)
local d=Modules['07UI_DESIGN_SYSTEM'];local gui=d.New('ScreenGui',{Name='ACP_TestHalloween'},pg);local root=d.Frame(gui,{Name='SettingsPanel'})
local button=d.Button(root,'Abrir');flush();assert(named(root,'HalloweenSceneAccent'))
local popup=d.Frame(root,{Name='WorldPickerDialog'});local x=d.IconButton(popup,'Close','close','Fechar');flush()
assert(named(popup,'HalloweenSceneAccent')and x.AbsoluteSize.X>=44 and x.Active)
for _,o in ipairs(named(popup,'HalloweenSceneAccent'):GetDescendants())do if o:IsA('GuiObject')then assert(not o.Active and not o.Selectable)end end
local board=d.New('Frame',{Name='Board'},root);local cell=d.Button(board,'',{BackgroundColor3=Color3.fromRGB(200,150,80)})
local art=Modules['07K7_CARD_STYLES'].Render(root,{rank='7',suit='H'},'Salem',{Size=UDim2.fromOffset(90,128)})
flush();assert(not cell:FindFirstChildOfClass('UIGradient'));assert(art:GetAttribute('V56_PreserveArt')and named(art,'PumpkinEye'))
pg:SetAttribute('ACP_HalloweenEnabled',false);assert(not named(popup,'HalloweenSceneAccent').Visible)
return 'late-created dialogs receive Halloween decoration; decorative objects cannot intercept touches; board cells and card identities stay protected'
''')
case('music_reuses_legacy_audio_and_stops_duplicate_controller',THEME+module('07M1_MUSIC_UI')+r'''
local legacyScript=Instance.new('LocalScript');legacyScript.Name='07M_PLAZA_MUSIC';legacyScript.Parent=PlayerScripts56
local shop=Instance.new('ScreenGui');shop.Name='AvatarShop08Gui';shop.Parent=pg
local oldPanel=Instance.new('Frame');oldPanel.Name='ACP_MusicPanel';oldPanel.Parent=shop
local first=Instance.new('Sound');first.Name='ACPPlazaMusicV2';first.SoundId='';first.Parent=Services.SoundService
local extra=Instance.new('Sound');extra.Name='ACPPlazaMusic';extra.Volume=.8;extra:Play();extra.Parent=Services.SoundService
local rpc=Instance.new('RemoteFunction');rpc.Name='ACP_MusicRequest';rpc.Parent=rep
function rpc:InvokeServer(a,d)if a=='load'then return{ok=true,data={volume=.4,saved={},last=0}}else return{ok=true,data=true}end end
'''+src('07M_MUSIC_CLIENT')+r'''
flush();assert(legacyScript.Disabled and not oldPanel.Parent);assert(first.Name=='ACP_PersonalMusic'and first.Volume==.4)
assert(not extra.IsPlaying and extra.Volume==0);assert(named(pg,'MusicPopup'))
local late=Instance.new('LocalScript');late.Name='07M_PLAZA_MUSIC';late.Parent=PlayerScripts56;assert(late.Disabled)
return 'existing ACPPlazaMusicV2 sound is adopted; old controller/panel and later duplicate startup are disabled without a second audio stream'
''')
case('photo_prefers_exact_character_clone_and_restores_archivable',PHOTO+r'''
local char=Services.Players:CreateHumanoidModelFromDescriptionAsync(A.Unpack(S.Current),Enum.HumanoidRigType.R15);char.Parent=workspace;pl.Character=char;char.Archivable=false
local cloned=0;function char:Clone()assert(self.Archivable);cloned=cloned+1;local m=Services.Players:CreateHumanoidModelFromDescriptionAsync(A.Unpack(S.Current),Enum.HumanoidRigType.R15);m:SetAttribute('CloneWitness',true);return m end
assert(Studio.Enter());assert(cloned==1 and char.Archivable==false and Studio.Model:GetAttribute('CloneWitness'))
assert(Studio.Source=='Cópia do avatar no mapa');Studio.Exit()
return 'matching live appearance takes the character clone path and restores its original Archivable value'
''')
HERE.joinpath('deep_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')

