"""V78 reproductions: real exported interfaces, guarded startup and real UI event handlers."""
from test_support import *

case('library_current_export_passes_api_contract_that_v77_rejected',UI+DATA+PREVIEW+module('09C4_OUTFIT_LIBRARY')+r'''
local lib=Modules['09C4_OUTFIT_LIBRARY'];local link=Modules['09C21_EDITOR_CONNECTION']
assert(lib.VERSION~='V58') -- V77 rejected this valid exported module by version label.
assert(link.Compatible(lib,{'Init','Open','OpenBody','OpenPlus','Add'}))
local calls={};lib.Init({U=U,A=A,S=S,pl=pl,toast=function()end,call=function(action)calls[#calls+1]=action;return{items={}}end,openUtility=function()U.CartPanel.Visible=true end})
lib.OpenBody();assert(U.BodyWindow.Visible);U.BodyClose.Activated:Fire();assert(not U.BodyWindow.Visible)
assert(lib.Add({Id=777,Name='My shirt',ItemType='Asset',Price=5},true));lib.Open();flush();assert(U.CartPanel.Visible and lib.Count()==1)
assert(not link.Compatible({VERSION='V58',Init=true},{'Init'}))
return 'actual V78 library initializes and opens body/cart; supported exports are accepted independently of version text'
''')

SHOP_DOUBLES=r'''
installModule('09B9_GLOBAL_LOOKS',[====[return{BindDescribe=function()end,Start=function()end}]====])
installModule('09B8_FREE_HIGHLIGHTS',[====[return{Version='native fixture',Changed=Instance.new('BindableEvent')}]====])
installModule('09B10_SPONSORED_DESTINATIONS',[====[return{Version='native fixture',Changed=Instance.new('BindableEvent')}]====])
installModule('09B12_PRIVATE_LOOKS',[====[return{}]====])
installModule('07P8_BACKGROUND_RESOLVER',[====[return{Version='native fixture'}]====])
'''
case('real_shop_guard_factory_starts_and_snapshot_yields_a_mountable_avatar',THEME+DATA+PREVIEW+SHOP_DOUBLES+SERVER+r'''
assert(rep.LMShop_Remotes:GetAttribute('GuardReady')==true)
local response=RPC:InvokeServer('AvatarSnapshot',{});assert(response.ok and response.data.body)
local view=Instance.new('ViewportFrame');view.Size=UDim2.fromOffset(280,380);view.Parent=pg
local controller=Preview.Mount(view,response.data.body,response.data.rig,{drag=true});flush()
assert(controller.Model and controller.Model:FindFirstChildOfClass('Humanoid'))
local before=controller.Model;controller.Rotate(90);assert(controller.Model==before)
return 'real New/Check/Enter factory protects the actual server RPC; its snapshot builds the preview through the real load/verify pipeline (native asset service simulated)'
''')

for bad,why in [('{}','missing New'),('{New=function()return{}end}','invalid guard instance')]:
 case('shop_guard_'+why.replace(' ','_')+'_fails_closed_with_diagnostic',THEME+DATA+SHOP_DOUBLES+"Modules['09I26_REQUEST_GUARD']="+bad+"\n"+SERVER+r'''
assert(rep.LMShop_Remotes:GetAttribute('GuardReady')==false)
local r=RPC:InvokeServer('AvatarSnapshot',{});assert(not r.ok and r.error:find('09I26_REQUEST_GUARD',1,true));assert(not r.error:find('nil value',1,true))
return 'invalid/missing factory does not execute unguarded handlers and the client receives the exact missing module/location instead of a nil-call exception'
''')

AI=THEME+DATA+module('09I0_ASSISTANT_CONFIG')+module('09I1_ASSISTANT_ACCOUNTS')+module('09I11_CONVERSATIONS')+module('09I2_ASSISTANT_ENGINE')+module('09I13_OUTFIT_SEARCH')+module('09I3_OUTFIT_BUILDER')+r'''
Modules['09B5_AVATAR_RUNTIME']={Description=function()return HUM,HUM:GetAppliedDescription()end};local o=Instance.new('ModuleScript');o.Name='09B5_AVATAR_RUNTIME';o.Parent=rep
'''
case('real_assistant_guard_factory_starts_and_services_status_and_help',AI+src('09I_ASSISTANT_SERVER')+r'''
local folder=rep.ACP_AssistantRemotes;local rpc=folder.Request;assert(folder:GetAttribute('GuardReady')==true)
local status=rpc.OnServerInvoke(pl,'status',{});assert(status.ok and status.protocol==2 and status.data.available)
advance60(1);local help=rpc.OnServerInvoke(pl,'ask',{text='Como usar o catálogo?',make=false,request='help'});assert(help.ok)
flush();return 'actual protected IA starts with compatible engine and builder and accepts a help request; existing plan/receipt authority is retained'
''')
case('assistant_incompatible_factory_reports_repair_without_unprotected_requests',AI+"Modules['09I26_REQUEST_GUARD']={}\n"+src('09I_ASSISTANT_SERVER')+r'''
local folder=rep.ACP_AssistantRemotes;assert(folder:GetAttribute('GuardReady')==false)
local r=folder.Request.OnServerInvoke(pl,'status',{});assert(not r.ok and r.protocol==2 and r.error:find('09I26_REQUEST_GUARD',1,true))
return 'IA remains fail-closed when a wrong module is installed and returns an actionable guarded bootstrap error'
''')

case('switching_every_world_preserves_character_and_camera_and_fixed_scene_origin',THEME+DATA+module('07G7_ADVENTURE_WORLD')+module('07G6_WORLD_DETAILS')+module('07G4_WORLD_SCENERY')+module('07G2_LOCAL_WORLDS')+r'''
local world=Instance.new('Folder');world.Name='PracaAvatar_V2';world.Parent=workspace
local tele=Instance.new('RemoteEvent');tele.Name='HubTeleport';tele.Parent=rep.PracaKit.Remotes;local returns=0;function tele:FireServer()returns=returns+1 end
local root=pl.Character:FindFirstChild('HumanoidRootPart');local original=CFrame.new(311,68,-277);root.CFrame=original;local cf=workspace.CurrentCamera.CFrame
local w=Modules['07G2_LOCAL_WORLDS']
for _,theme in ipairs(w.Worlds)do
 assert(w.Apply(theme.id));flush();assert(root.CFrame==original and workspace.CurrentCamera.CFrame==cf and returns==0)
 local floor=workspace.ACP_LocalWorldVisuals.FixedWorldGround;assert(floor and floor.Anchored);local pos=floor.Position
 root.CFrame=CFrame.new(900,68,700);Services.RunService.Heartbeat:Fire(1);assert((floor.Position-pos).Magnitude==0);root.CFrame=original
end
w.Destroy();return '19 theme switches send no HubTeleport and preserve the avatar/camera; walking away cannot translate the scene floor'
''')
case('world_details_have_native_materials_and_continuations_with_mobile_caps',THEME+r'''
local worlds=Modules['07G11_REFERENCE_WORLDS'];local totals={}
for _,touch in ipairs({false,true})do Services.UserInputService.TouchEnabled=touch;local peak=0
 for _,id in ipairs({'CLOUD','ICE','LAVA','PYRAMID','ANIME','CANDY','GRAVEYARD','CRYSTAL','CITY','GEARS','DIGITAL','LUMINOUS','PORTAL'})do
  local mats={};local extension=false;local count=worlds.Build(id,Vector3.zero,function(n,s,pos,c,shape,mat)
   assert(s.X>0 and s.Y>0 and s.Z>0);mats[tostring(mat)]=true;if n=='ContinuationPath'and pos.Z<-400 then extension=true end
   local o=Instance.new('Part');o.Material=mat;return o
  end,function()return true end)
  assert(count<=(touch and worlds.MobileBudget or worlds.Budget));assert(extension);local kinds=0;for _ in pairs(mats)do kinds=kinds+1 end;assert(kinds>=2);peak=math.max(peak,count)
 end;totals[#totals+1]=peak
end
return '13 themes include paths beyond Z=-400, multiple native surface materials and bounded primitive counts; peak desktop/mobile='..totals[1]..'/'..totals[2]
''')

CAMERA=THEME+DATA+module('07G13_FREE_CAMERA')+r'''
workspace.CurrentCamera.Parent=workspace
local controls={controlsEnabled=true};function controls:Disable()self.controlsEnabled=false end;function controls:Enable()self.controlsEnabled=true end
local ps=Instance.new('Folder');ps.Name='PlayerScripts';local oldFind=pl.FindFirstChild;function pl:FindFirstChild(n)if n=='PlayerScripts'then return ps end;return oldFind(self,n)end;local pm=Instance.new('ModuleScript');pm.Name='PlayerModule';pm.Parent=ps;Modules.PlayerModule={GetControls=function()return controls end}
local hum=pl.Character:FindFirstChildOfClass('Humanoid');local zeroes=0;function hum:Move(v)assert(v.Magnitude==0);zeroes=zeroes+1 end
local root=pl.Character:FindFirstChild('HumanoidRootPart');root.CFrame=CFrame.new(50,65,25);local before=root.CFrame
local safe=Modules['07UI_SCREEN_BOUNDS'].Bind(Modules['07UI_DESIGN_SYSTEM'].New('ScreenGui',{},pg));local camera=Modules['07G13_FREE_CAMERA'].Build(pg,safe,function()end)
'''
case('live_camera_wasd_moves_camera_only_and_restores_input_on_exit',CAMERA+r'''
local cam=workspace.CurrentCamera;local saved=cam.CFrame;local oldType=cam.CameraType;local oldSubject=cam.CameraSubject
assert(camera.Start()and not controls.controlsEnabled)
function Services.UserInputService:IsKeyDown(key)return key==Enum.KeyCode.W end
for i=1,120 do render78(1/60)end
assert((cam.CFrame.Position-saved.Position).Magnitude>20 and root.CFrame==before and zeroes==120)
camera.Stop();assert(controls.controlsEnabled and cam.CFrame==saved and cam.CameraType==oldType and cam.CameraSubject==oldSubject and root.CFrame==before)
assert(next(RenderCallbacks78)==nil and pg:GetAttribute('ACP_FreeCameraActive')==false)
return '120 WASD render steps move only camera coordinates, suppress avatar Move, then restore exact camera and native controls; no root anchoring/pivot/speed write'
''')
case('live_camera_touch_joystick_and_exit_fit_portrait_landscape_and_pc',CAMERA+r'''
local input=Services.UserInputService;input.TouchEnabled=true
for _,sz in ipairs({{320,568},{390,844},{568,320},{667,375},{851,392},{1920,1080}})do SCREEN_W,SCREEN_H=table.unpack(sz);CORE_TOP=58;camera.Start();camera.Layout();inside(camera.Exit,camera.Gui);inside(camera.Pad,camera.Gui);assert(camera.Exit.AbsoluteSize.Y>=52 and camera.Pad.AbsoluteSize.X==120)
 local position=camera.Pad.AbsolutePosition;local io={UserInputType=Enum.UserInputType.Touch,Position=Vector3.new(position.X+80,position.Y+30,0)}
 local initial=workspace.CurrentCamera.CFrame.Position;camera.Pad.InputBegan:Fire(io);render78(.06);assert((workspace.CurrentCamera.CFrame.Position-initial).Magnitude>0 and root.CFrame==before)
 input.InputEnded:Fire(io);camera.Exit.Activated:Fire();assert(not camera.Active and controls.controlsEnabled)
end
return 'actual joystick InputBegan/InputEnded and exit click work at six geometries, with unchanged character position'
''')
case('live_camera_stops_on_respawn_game_entry_and_photo_mode',CAMERA+r'''
for _,action in ipairs({'respawn','game','photo'})do assert(camera.Start());if action=='respawn'then pl.CharacterAdded:Fire()elseif action=='game'then pl:SetAttribute('ACP_InGameRoom',true)else pg:SetAttribute('ACP_OpenPhotoNonce',1)end;assert(not camera.Active and controls.controlsEnabled);pl:SetAttribute('ACP_InGameRoom',nil)end
pl:SetAttribute('ACP_InGameRoom',true);assert(not camera.Start()and next(RenderCallbacks78)==nil)
return 'respawn, room entry and photo mode release the camera and restore input; game membership prevents a concurrent free-camera session'
''')
case('compact_catalog_filters_sort_and_categories_remain_reachable',UI+DATA+PREVIEW+module('09C4_OUTFIT_LIBRARY')+module('09C3_CATALOG_FILTERS')+module('09C2_SHOP_CATALOG')+r'''
function Services.AvatarEditorService:SearchCatalogAsync()return{IsFinished=true,GetCurrentPage=function()return{}end}end
local ctl=Modules['09C2_SHOP_CATALOG'].Init({U=U,A=A,S=S,toast=function()end,call=function()return true end});U.Root.Visible=true;U.SetWide(false)
for _,sz in ipairs({{320,568},{390,844},{568,320},{667,375},{851,392},{1920,1080}})do
 SCREEN_W,SCREEN_H=table.unpack(sz);CORE_TOP=58;U.Layout();ctl.Resize()
 assert(U.Grid.AbsoluteSize.Y>=44);inside(U.ItemStrip,U.Left)
 if U.Filter.Parent==U.SubsPopup then
  U.SubsPopup.Visible=false;U.SubToggle.Activated:Fire();assert(U.SubsPopup.Visible);inside(U.Filter,U.SubsPopup);inside(U.Sort,U.SubsPopup);assert(not intersects(U.Filter,U.Sort))
 end
 U.Filter.Activated:Fire();assert(U.FilterPanel.Visible and not U.SubsPopup.Visible);U.CloseFilter.Activated:Fire();assert(not U.FilterPanel.Visible)
 U.Sort.Activated:Fire();flush();assert(U.Sort.Text~='')
end
return 'six real layout/click paths reach filters, sort and categories; compact controls share a popover, leaving card area and equipped strip visible'
''')
case('assistant_history_cannot_cover_saved_profile_or_new_chat_controls',THEME+DATA+module('09I4_ASSISTANT_UI')+module('09I10_CHAT_NAV')+r'''
local u=Modules['09I4_ASSISTANT_UI'].Build(pl);local n=Modules['09I10_CHAT_NAV'].Build(u,function()return{items={}}end,function()end);u.OnLayout=n.Layout;u.Root.Visible=true
for _,sz in ipairs({{320,568},{390,844},{568,320},{667,375},{851,392},{1920,1080}})do
 SCREEN_W,SCREEN_H=table.unpack(sz);CORE_TOP=58;u.MenuOpen=true;u.Layout();n.Layout()
 local buttons={u.NewChat,u.TabButtons.Salvos,u.Activities,u.Sponsor,u.TabButtons.Perfil}
 for i,b in ipairs(buttons)do assert(b.Visible and b.AbsoluteSize.Y>=52,b.Name.." hidden/small "..SCREEN_W..","..SCREEN_H);assert(not intersects(b,n.Search)and not intersects(b,n.List)and not intersects(b,n.Archived),b.Name.." history overlap "..SCREEN_W..","..SCREEN_H)
  for j=1,i-1 do assert(not intersects(b,buttons[j]))end
 end
 inside(u.Upgrade,u.Window);assert(not intersects(u.Upgrade,u.Tabs))
 assert(u.Tabs.CanvasSize.Y.Offset>=n.List.Position.Y.Offset+n.List.Size.Y.Offset)
end
return 'actual ChatNav and menu layout compose without overlapping targets; history follows navigation in a scrollable area and plan access has a separate fixed footer'
''')

HERE.joinpath('functional_repair_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
