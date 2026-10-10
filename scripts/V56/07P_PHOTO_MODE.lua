-- 07P_PHOTO_MODE | LocalScript | StarterPlayer > StarterPlayerScripts
-- V56: cenário local fixo, cópia do avatar e câmera/rotação independentes.
local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local Run=game:GetService("RunService")
local Studio=require(Rep:WaitForChild("07P2_STUDIO_AVATAR"))
local Presets=require(Rep:WaitForChild("07P0_STUDIO_PRESETS"))
local Capture=require(Rep:WaitForChild("07P1_CAPTURE_ENGINE"))
local pl=Players.LocalPlayer;local pg=pl:WaitForChild("PlayerGui")
local U=require(Rep:WaitForChild("07P4_STUDIO_UI")).Build(pl)
local D=require(Rep:WaitForChild("07UI_DESIGN_SYSTEM"))
local hidden={};local current=nil;local active=false;local entering=false;local serial=0
local orbit=nil;local orbitSpeed=.5;local capturing=false;local captureId=0;local drag=nil;local lastX=0;local lastY=0;local cameraDrag=false
local function status(msg)U.Notify(msg)end
local function stopOrbit()if orbit then orbit:Disconnect();orbit=nil end end
local function cancelPose()if Studio.Pose and Studio.Pose.Editing then Studio.Pose.Cancel()end end
local function closePanel()
 cancelPose();if U.PoseEditor then U.PoseEditor.Destroy();U.PoseEditor=nil end
 U.PoseMode=false;current=nil;U.Popup.Visible=false;U.PoseFooter.Visible=false;U.Select(nil);U.Layout()
end
U.OnLayout=function(il,it,ir,ib,w,h,landscape,top)
 if not active then return end
 if U.Restore.Visible or capturing then Studio.SetMargins(0,0,0,0);return end
 local a=U.SceneMargins or{il+6,top,ir+6,ib+56};Studio.SetMargins(table.unpack(a))
end
local function leave()
 serial=serial+1;active=false;entering=false;capturing=false;drag=nil;stopOrbit();closePanel();Studio.Exit()
 U.Root.Visible=false;U.Popup.Visible=false;U.Restore.Visible=false;U.Gui.Enabled=true
 for g,enabled in pairs(hidden)do if g.Parent then g.Enabled=enabled end end
 hidden={};current=nil
end
local function enter()
 if active or entering then return end
 serial=serial+1;local mine=serial;entering=true
 local ok,worked,msg=pcall(Studio.Enter)
 entering=false
 if mine~=serial then return end
 if not ok or not worked then Studio.Exit();U.Root.Visible=true;status(ok and msg or"Não foi possível abrir o estúdio.");task.delay(3,function()if not active then U.Root.Visible=false end end);return end
 active=true;hidden={};cameraDrag=false;U.DragMode.Text='Girar avatar'
 for _,g in ipairs(pg:GetChildren())do if g:IsA("ScreenGui")and g~=U.Gui then hidden[g]=g.Enabled;g.Enabled=false end end
 U.Gui.Enabled=true;U.Root.Visible=true;U.SetClean(false);status("Arraste o avatar para girar. O fundo fica no lugar.");U.Layout()
end
local function showPose()
 stopOrbit();if Studio.Track then Studio.FreezeEmote()end
 local pose=Studio.Pose;if not pose or #pose.Joints==0 then status("Este avatar não tem articulações editáveis.");return end
 pose.Begin();U.PoseMode=true;U.PoseFooter.Visible=true;U.PopupTitle.Text="Editar pose"
 U.PoseEditor=require(Rep:WaitForChild("07P5_POSE_CANVAS")).Build(U.Popup,pose,function()
  -- A câmera mantém o enquadramento enquanto uma articulação é arrastada.
 end,{model=Studio.Model,camera=Studio.Camera,gizmoParent=U.Root,onPlane=function(front)Studio.SetYaw(front and 180 or 90)end})
 status("Toque no corpo do avatar e arraste. O manequim também funciona.")
end
local function showAnimations()
 U.PopupTitle.Text="Emotes ao vivo";local mine=serial
 U.Option("Parar animação",1).Activated:Connect(function()Studio.StopEmote();status("Animação parada.")end)
 U.Option("Congelar como pose",2,D.Colors.green).Activated:Connect(function()status(Studio.FreezeEmote()and"Pose congelada. Abra Pose para ajustar."or"Escolha uma animação primeiro.")end)
 
 local loading=U.TextLine("Buscando emotes…",3)
 task.spawn(function()
  local params=CatalogSearchParams.new();params.AssetTypes={Enum.AvatarAssetType.EmoteAnimation};params.Limit=10;params.SortType=Enum.CatalogSortType.Bestselling
  local ok,pages=pcall(function()return game:GetService("AvatarEditorService"):SearchCatalogAsync(params)end)
  if not active or mine~=serial or current~="Animations"or not loading.Parent then return end
  loading:Destroy()
  if not ok then U.Option("Recarregar animações",4).Activated:Connect(function()U.Clear();showAnimations();U.Layout()end);status("O Roblox não respondeu. Tente recarregar.");U.Layout();return end
  local got,rows=pcall(function()return pages:GetCurrentPage()end)
  if not got or #rows==0 then U.Option("Recarregar animações",4).Activated:Connect(function()U.Clear();showAnimations();U.Layout()end);status("Nenhuma animação disponível agora. Tente recarregar.")
  else for i,item in ipairs(rows)do if i>4 then break end
   local b=U.Option(tostring(item.Name or"Emote"),i+2)
   b.Activated:Connect(function()
    status("Carregando emote no avatar…");task.spawn(function()local worked,message=Studio.PlayEmote(item.Id);if active and current=="Animations"and b.Parent then
     b.BackgroundColor3=worked and D.Colors.green or D.Colors.card;status(worked and"Emote em execução no avatar · congele para editar a pose"or message)
    end end)
   end)
  end end;U.Layout()
 end)
end
local function showBackgrounds()
 U.PopupTitle.Text="Fundos"
 for i,p in ipairs(Presets.Backgrounds)do
  local b=U.Option(p.name,i,p.a:Lerp(D.Colors.bg,.4));b.Name="SceneChoice"..p.id;b.TextYAlignment=Enum.TextYAlignment.Bottom
  D.New("UIGradient",{Color=ColorSequence.new(p.a,p.b),Rotation=100},b)
  D.Icon(b,p.id=="STUDIO"and"camera"or p.id=="GARDEN"and"avatar"or"catalog",{IconColor=p.accent,AnchorPoint=Vector2.new(.5,0),Position=UDim2.fromScale(.5,.05),Size=UDim2.fromScale(.30,.42),ZIndex=33})
  b.Activated:Connect(function()Studio.BuildSet(p.id);for _,o in ipairs(U.Content:GetChildren())do if o:IsA("GuiButton")and o.Name:find("SceneChoice",1,true)then o.BackgroundColor3=o==b and D.Colors.green or D.Colors.card end end;U.Status.Visible=false end)
 end
 U.Option("Detalhes animados: ligar / pausar",7).Activated:Connect(function()if Studio.Scene then Studio.Scene.SetAnimated(not Studio.Scene.Animated);status(Studio.Scene.Animated and'Detalhes animados ligados.'or'Detalhes pausados.')end end)
end
local function showEnvironment()
 U.PopupTitle.Text="Ambiente"
 local defs={{"Exposure","Claridade"},{"Brightness","Luz"},{"Time","Hora do dia"}}
 for i,def in ipairs(defs)do
  local key=def[1];local ctl=U.Row(def[2],string.format("%.2f",Studio.Environment[key]),i);U.Environment[key]=ctl
  local function set(n)if Studio.SetEnvironment(key,n)then ctl.Value.Text=string.format("%.2f",Studio.Environment[key])end end
  local step=Studio.EnvironmentRules[key][3]
  ctl.Minus.Activated:Connect(function()set(Studio.Environment[key]-step)end)
  ctl.Plus.Activated:Connect(function()set(Studio.Environment[key]+step)end)
  ctl.Value.FocusLost:Connect(function()local n=tonumber(ctl.Value.Text);if n then set(n)else ctl.Value.Text=string.format("%.2f",Studio.Environment[key])end end)
 end
 local lightIndex=1;local light,reset=U.Pair("Luz: "..Presets.Lights[1].name,"Restaurar",4)
 light.Activated:Connect(function()lightIndex=lightIndex%#Presets.Lights+1;local p=Presets.Lights[lightIndex];Studio.SetLight(p.id);light.Text="Luz: "..p.name end)
 reset.Activated:Connect(function()Studio.SetLight("BRIGHT");Studio.ResetEnvironment();lightIndex=1;light.Text="Luz: "..Presets.Lights[1].name;for key,c in pairs(U.Environment)do c.Value.Text=string.format("%.2f",Studio.Environment[key])end end)
end
local function startOrbit()
 stopOrbit();orbit=Run.RenderStepped:Connect(function(dt)if active then Studio.SetAvatarYaw((Studio.AvatarYaw+dt*45*orbitSpeed)%360)end end)
 status("Giro automático do avatar ligado.")
end
local function showCamera()
 U.PopupTitle.Text="Câmera"
 for i,p in ipairs(Presets.Frames)do U.Option(p.name,i).Activated:Connect(function()Studio.SetFrame(p.id)end)end
 U.Option("Frente",4).Activated:Connect(function()stopOrbit();Studio.Pitch=0;Studio.SetYaw(180);Studio.SetAvatarYaw(0)end)
 U.Option("Costas",5).Activated:Connect(function()stopOrbit();Studio.Pitch=0;Studio.SetYaw(180);Studio.SetAvatarYaw(180)end)
 U.Option("Lado esquerdo",6).Activated:Connect(function()stopOrbit();Studio.SetYaw(180);Studio.SetAvatarYaw(90)end)
 U.Option("Lado direito",7).Activated:Connect(function()stopOrbit();Studio.SetYaw(180);Studio.SetAvatarYaw(270)end)
 U.Option("Aproximar",8).Activated:Connect(function()Studio.SetZoom(Studio.Zoom+.1)end)
 U.Option("Afastar",9).Activated:Connect(function()Studio.SetZoom(Studio.Zoom-.1)end)
 U.Option("Girar avatar automaticamente",10).Activated:Connect(function()if orbit then stopOrbit();status("Giro parado.")else startOrbit()end end)
end
local function takePhoto()
 if capturing then return end
 capturing=true;captureId=captureId+1;local shot=captureId;local mine=serial;closePanel();U.Gui.Enabled=false;Studio.SetMargins(0,0,0,0)
 task.spawn(function()
  Run.RenderStepped:Wait();Run.RenderStepped:Wait()
  local function finish(msg)
   if mine~=serial or shot~=captureId or not capturing then return end;capturing=false;U.Gui.Enabled=true;U.SetClean(false);status(msg)
  end
  local worked,ok,err=pcall(Capture.TakePhoto,nil,function(success)finish(success and"Foto pronta. Abra Foto para salvar ou compartilhar."or"Não foi possível criar a foto.")end)
  if not worked or not ok then finish(worked and err or"Não foi possível criar a foto.")end
  task.delay(12,function()if mine==serial and capturing then finish("Captura indisponível neste dispositivo. Tente novamente.")end end)
 end)
end
local function showCapture()
 U.PopupTitle.Text="Foto"
 U.TextLine("Capture sem a interface e salve pela galeria do Roblox.",1)
 U.Option("Tirar foto",2,D.Colors.green).Activated:Connect(takePhoto)
 U.Option("Salvar última foto",3).Activated:Connect(function()local ok,err=Capture.SaveLast(function()status("Pedido de salvamento concluído.")end);if not ok then status(err)end end)
 U.Option("Compartilhar última foto",4).Activated:Connect(function()local ok,err=Capture.ShareLast(function()status("Compartilhamento confirmado.")end,function()status("Compartilhamento cancelado.")end);if not ok then status(err)end end)
end
local shows={Pose=showPose,Animations=showAnimations,Background=showBackgrounds,Environment=showEnvironment,Camera=showCamera,Capture=showCapture}
local function panel(key)
 if not active or capturing then return end
 if current==key and U.Popup.Visible then closePanel();return end
 closePanel();U.Clear();current=key;U.Select(key);U.Popup.Visible=true
 shows[key]();U.Layout()
end
for key,fn in pairs(shows)do U.Buttons[key].Activated:Connect(function()panel(key)end)end
U.Buttons.Hide.Activated:Connect(function()if active then closePanel();U.SetClean(true)end end)
U.Close.Activated:Connect(leave);U.PopupClose.Activated:Connect(closePanel)
U.Restore.Activated:Connect(function()U.SetClean(false);U.Layout()end)
U.DragMode.Activated:Connect(function()cameraDrag=not cameraDrag;U.DragMode.Text=cameraDrag and'Mover câmera'or'Girar avatar';stopOrbit();status(cameraDrag and'Arraste para mover a câmera. O cenário continua fixo.'or'Arraste para girar apenas o avatar.')end)
U.PoseConfirm.Activated:Connect(function()if Studio.Pose then Studio.Pose.Confirm()end;closePanel();status("Pose confirmada. O avatar permanece assim no estúdio.")end)
U.PoseCancel.Activated:Connect(closePanel)
U.PoseReset.Activated:Connect(function()if U.PoseEditor then U.PoseEditor.Reset()end end)
local nonce=tonumber(pg:GetAttribute("ACP_OpenPhotoNonce"))or 0
pg:GetAttributeChangedSignal("ACP_OpenPhotoNonce"):Connect(function()
 local n=tonumber(pg:GetAttribute("ACP_OpenPhotoNonce"))or 0
 if n~=nonce then nonce=n;if active or entering then leave()else enter()end end
end)
pl.CharacterAdded:Connect(function()if active or entering then leave()end end)
pg:GetAttributeChangedSignal("ACP_TrucoActive"):Connect(function()if pg:GetAttribute("ACP_TrucoActive")and(active or entering)then leave()end end)
pl:GetAttributeChangedSignal("ACP_InGameRoom"):Connect(function()if pl:GetAttribute("ACP_InGameRoom")and(active or entering)then leave()end end)
UIS.InputBegan:Connect(function(input,gp)
 if not active or capturing then return end
 if input.KeyCode==Enum.KeyCode.Escape or input.KeyCode==Enum.KeyCode.ButtonB then if U.Popup.Visible then closePanel()elseif U.Restore.Visible then U.SetClean(false)else leave()end;return end
 if gp then return end
 if current=="Pose"then return end
 if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
  local p=input.Position
  for _,o in ipairs({U.Nav,U.Popup,U.Close,U.Restore,U.DragMode,U.Buttons.Hide})do if o.Visible then local a,s=o.AbsolutePosition,o.AbsoluteSize;if p.X>=a.X and p.X<=a.X+s.X and p.Y>=a.Y and p.Y<=a.Y+s.Y then return end end end
  drag=input;lastX=p.X;lastY=p.Y;stopOrbit()
 end
end)
UIS.InputChanged:Connect(function(input)
 if active and drag and(input==drag or input.UserInputType==Enum.UserInputType.MouseMovement)then
  local x,y=input.Position.X,input.Position.Y
  if cameraDrag then Studio.RotateCamera(-(x-lastX)*.3,-(y-lastY)*.2)else Studio.Rotate(-(x-lastX)*.3)end
  lastX=x;lastY=y
 end
end)
UIS.InputEnded:Connect(function(input)if input==drag or input.UserInputType==Enum.UserInputType.MouseButton1 then drag=nil end end)
U.Gui.Destroying:Connect(leave)
print("[V56] Photo Mode local com cenário fixo e cópia do avatar pronto")
