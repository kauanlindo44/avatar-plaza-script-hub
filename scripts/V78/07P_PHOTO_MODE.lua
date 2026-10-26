-- 07P_PHOTO_MODE | LocalScript | StarterPlayer > StarterPlayerScripts | V78 (SUBSTITUIR)
-- V60 (SUBSTITUIR): fundos nativos do perfil, cópia do avatar e controles preservados.
local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local Run=game:GetService("RunService")
local Studio=require(Rep:WaitForChild("07P2_STUDIO_AVATAR"))
local Presets=require(Rep:WaitForChild("07P0_STUDIO_PRESETS"))
local Capture=require(Rep:WaitForChild("07P1_CAPTURE_ENGINE"));local Backgrounds=require(Rep:WaitForChild("07P7_ROBLOX_BACKGROUNDS"))
local pl=Players.LocalPlayer;local pg=pl:WaitForChild("PlayerGui")
local U=require(Rep:WaitForChild("07P4_STUDIO_UI")).Build(pl)
local D=require(Rep:WaitForChild("07UI_DESIGN_SYSTEM"))
local hidden={};local current=nil;local active=false;local entering=false;local serial=0
local Video=require(Rep:WaitForChild('07P10_VIDEO_MOTION')).New(Studio,function()return active end)
local Rehearsal=require(Rep:WaitForChild('09I19_REHEARSAL_CUES')).Build(U,Studio,function()return active end)
local orbit=nil;local orbitSpeed=.5;local capturing=false;local captureId=0;local drag=nil;local lastX=0;local lastY=0;local cameraDrag=false
local function status(msg)U.Notify(msg)end
local function stopOrbit()Video.Stop(false);if orbit then orbit:Disconnect();orbit=nil end;if Studio.Pan and Studio.Pan~=0 then Studio.SetPan(0)end end
local function cancelPose()if Studio.Pose and Studio.Pose.Editing then Studio.Pose.Cancel()end end
local function closePanel()
 cancelPose();if U.PoseEditor then U.PoseEditor.Destroy();U.PoseEditor=nil end
 if U.CameraChoices then U.CameraChoices.Hide()end;U.PoseMode=false;current=nil;U.Popup.Visible=false;U.PoseFooter.Visible=false;U.Select(nil);U.Layout()
end
U.OnLayout=function(il,it,ir,ib,w,h,landscape,top)
 if not active then return end
 -- Abrir menus nunca muda o centro óptico, o tamanho ou a posição da cópia.
 Studio.SetMargins(0,0,0,0)
end
local function leave()
 Rehearsal.Close();serial=serial+1;active=false;entering=false;capturing=false;drag=nil;stopOrbit();closePanel();Studio.Exit()
 U.Root.Visible=false;U.Popup.Visible=false;U.Restore.Visible=false;U.Gui.Enabled=true
 for g,enabled in pairs(hidden)do if g.Parent then g.Enabled=enabled end end
 hidden={};current=nil
end
local function enter()
 if active or entering then return end
 require(Rep:WaitForChild('07G13_FREE_CAMERA')).StopActive()
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
local function showMotions()Video.Panel(U,status)end
local Catalog=require(Rep:WaitForChild('07P9_STUDIO_CATALOG'))
local backgroundChoice=0
local function showAnimations()
 Catalog.Open(U,'Animations',function(item)
  local mine=serial;status('Carregando no avatar copiado…');task.spawn(function()
   local ok,e=Studio.PlayEmote(item.Id,{bundle=item.IsAnimationPack,slot=item.AnimationSlot});if active and mine==serial then status(ok and'Emote tocando na cópia • abra Pose para congelar e editar'or e)end
  end)
 end,function()Studio.StopEmote();status('Emote parado.')end,{pause=Studio.PauseEmote,speed=Studio.SetEmoteSpeed})
end
local function showBackgrounds()
 if type(Catalog.Open)~='function'or type(Backgrounds.Image)~='function'then status('Loja de fundos indisponível: confira os módulos do estúdio.');return end
 Catalog.Open(U,'Background',function(item)
  backgroundChoice=backgroundChoice+1;local choice=backgroundChoice;local mine=serial;status('Testando fundo da loja…')
  task.spawn(function()
   local function alive()return active and mine==serial and choice==backgroundChoice and current=='Background'end
   local value,e=Backgrounds.Image({id=item.Id,name=item.Name,source='RobloxCatalog'},alive)
   if not alive()then return end;if not value then status(e);return end
   local ok,why=Studio.BuildSet(value);status(ok and(value.quality=='STORE_THUMBNAIL'and'Prévia oficial da loja carregada.'or'Fundo da loja carregado.')or why)
  end)
 end,function()backgroundChoice=backgroundChoice+1;Studio.BuildSet('NONE');status('Fundo removido.')end)
end
local function showEnvironment()
 U.PopupTitle.Text="Ambiente"
 local defs={{'Exposure','Claridade'},{'Brightness','Luz'},{'Time','Hora'},{'Contrast','Contraste'},{'Saturation','Cor'}}
 local Slider=require(Rep:WaitForChild('07UI_SLIDER'))
 for i,def in ipairs(defs)do
  local key=def[1];local rule=Studio.EnvironmentRules[key];local ctl
  ctl=Slider.Build(U.Content,def[2],function(v)
   local n=rule[1]+v*(rule[2]-rule[1]);n=math.floor(n/rule[3]+.5)*rule[3]
   if Studio.SetEnvironment(key,n)then ctl.Label.Text=def[2]..' '..string.format('%.2f',Studio.Environment[key])end
  end)
  ctl.Root.LayoutOrder=i;U.Environment[key]=ctl;ctl.Set((Studio.Environment[key]-rule[1])/(rule[2]-rule[1]),true);ctl.Label.Text=def[2]..' '..string.format('%.2f',Studio.Environment[key])
 end
 local lightIndex=1;local light,reset=U.Pair("Luz: "..Presets.Lights[1].name,"Restaurar",6)
 light.Activated:Connect(function()lightIndex=lightIndex%#Presets.Lights+1;local p=Presets.Lights[lightIndex];Studio.SetLight(p.id);light.Text="Luz: "..p.name end)
 reset.Activated:Connect(function()Studio.SetLight("BRIGHT");Studio.ResetEnvironment();lightIndex=1;light.Text="Luz: "..Presets.Lights[1].name;for key,c in pairs(U.Environment)do local rule=Studio.EnvironmentRules[key];c.Set((Studio.Environment[key]-rule[1])/(rule[2]-rule[1]),true);c.Label.Text=key..' '..string.format("%.2f",Studio.Environment[key])end end)
end
local function startOrbit()
 stopOrbit();orbit=Run.RenderStepped:Connect(function(dt)if active then Studio.SetAvatarYaw((Studio.AvatarYaw+dt*45*orbitSpeed)%360)end end)
 status("Giro automático do avatar ligado.")
end
local function showCamera()
 U.PopupTitle.Text='Enquadramento';local choice=U.CameraChoices;if not choice then choice=require(Rep:WaitForChild('07UI_CHOICE_LIST')).Build(U.Popup);U.CameraChoices=choice end
 U.Option('Enquadramento ▾',1).Activated:Connect(function()local rows={};for _,p in ipairs(Presets.Frames)do rows[#rows+1]={id=p.id,name=p.name}end;choice.Open('Enquadrar avatar',rows,Studio.Frame,function(v)Studio.SetFrame(v.id)end)end)
 U.Option('Frente, costas e lados ▾',2).Activated:Connect(function()choice.Open('Direção do avatar',{{id='0',name='Frente'},{id='180',name='Costas'},{id='90',name='Lado esquerdo'},{id='270',name='Lado direito'}},tostring(Studio.AvatarYaw),function(v)stopOrbit();Studio.Pitch=0;Studio.SetYaw(180);Studio.SetAvatarYaw(tonumber(v.id))end)end)
 local plus,minus=U.Pair('Aproximar','Afastar',3);plus.Activated:Connect(function()Studio.SetZoom(Studio.Zoom+.1)end);minus.Activated:Connect(function()Studio.SetZoom(Studio.Zoom-.1)end)
 U.Option('Movimentos para vídeo',4).Activated:Connect(function()choice.Hide();showMotions()end)
 U.Option('Giro automático do avatar',5).Activated:Connect(function()if orbit then stopOrbit();status('Giro parado.')else startOrbit()end end)
 U.Option('Clonar avatar na cena',7).Activated:Connect(function()local ok,e=Studio.CloneAvatar();status(ok and'Cópia criada apenas neste estúdio.'or e)end)
 U.Option('Limpar cópias',8).Activated:Connect(Studio.ClearCopies)
 local head,body=U.Pair('Cabeça: mostrar/ocultar','Corpo: mostrar/ocultar',9);head.Activated:Connect(function()Studio.HidePart('Head')end);body.Activated:Connect(function()Studio.HidePart('Body')end)
 U.Option('Restaurar enquadramento',6).Activated:Connect(function()stopOrbit();Studio.SetFrame('FULL');Studio.SetZoom(1);Studio.Pitch=0;Studio.SetYaw(180);Studio.SetAvatarYaw(0)end)

end
local function showSpotlight()
 U.PopupTitle.Text='Luz direcional';U.Clear();local defs={{'Brightness','Intensidade',0,8,.25},{'Angle','Ângulo',10,120,5},{'Range','Alcance',10,100,5},{'X','Posição X',-20,20,1},{'Y','Posição Y',-5,25,1},{'Z','Posição Z',-20,20,1}}
 for i,r in ipairs(defs)do local ctl=U.Row(r[2],Studio.SpotSettings[r[1]],i);local function set(v)local n=tonumber(v);if Studio.SetSpot(r[1],n)then ctl.Value.Text=tostring(Studio.SpotSettings[r[1]])else ctl.Value.Text=tostring(Studio.SpotSettings[r[1]])end end;ctl.Minus.Activated:Connect(function()set((tonumber(ctl.Value.Text)or r[3])-r[5])end);ctl.Plus.Activated:Connect(function()set((tonumber(ctl.Value.Text)or r[3])+r[5])end);ctl.Value.FocusLost:Connect(function()set(ctl.Value.Text)end)end
 local colors={Color3.fromRGB(255,245,232),Color3.fromRGB(221,235,255),Color3.fromRGB(255,211,193),Color3.fromRGB(224,208,255)};local index=1;local b=U.Option('Cor: neutra',7);b.Activated:Connect(function()index=index%#colors+1;Studio.SetSpotColor(colors[index]);b.Text=({'Cor: neutra','Cor: fria','Cor: quente','Cor: lilás'})[index]end);U.Layout()
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
 U.Option("Salvar última foto",3).Activated:Connect(function()local ok,err=Capture.SaveLast(function(saved)status(saved and"Foto salva na galeria do Roblox."or"Salvamento não confirmado ou cancelado.")end);if not ok then status(err)end end)
 U.Option("Compartilhar última foto",4).Activated:Connect(function()local ok,err=Capture.ShareLast(function()status("Compartilhamento confirmado.")end,function()status("Compartilhamento cancelado.")end);if not ok then status(err)end end)
end
local shows={Pose=showPose,Animations=showAnimations,Background=showBackgrounds,Environment=showEnvironment,Camera=showCamera,Video=showMotions,Capture=showCapture};local panelAt=-10
local function panel(key)
 if not active or capturing or os.clock()-panelAt<.18 then return end;panelAt=os.clock()
 if current==key and U.Popup.Visible then closePanel();return end
 closePanel();U.Clear();current=key;U.Select(key);U.Popup.Visible=true
 shows[key]();if key=='Environment'then U.Option('Luz direcional…',7).Activated:Connect(showSpotlight)end;U.Layout()
end
for key,fn in pairs(shows)do U.Buttons[key].Activated:Connect(function()panel(key)end)end
U.Rotate.Activated:Connect(function()if active then if orbit then stopOrbit()else startOrbit()end end end)
U.Buttons.Hide.Activated:Connect(function()if active then closePanel();U.SetClean(true)end end)
U.Shutter.Activated:Connect(function()if active then takePhoto()end end)
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
pg:GetAttributeChangedSignal('ACP_PhotoCloneNonce'):Connect(function()if not active then enter()end;if active then local ok,e=Studio.CloneAvatar();status(ok and'Cópia criada na cena.'or e)end end)
pg:GetAttributeChangedSignal('ACP_PhotoEffectNonce'):Connect(function()if not active then enter()end;if active then Studio.HidePart(pg:GetAttribute('ACP_PhotoEffect'));status('Efeito visual aplicado só à cópia da foto.')end end)
pg:GetAttributeChangedSignal('ACP_RehearsalNonce'):Connect(function()if not active then enter()end;if active then Rehearsal.Open()end end)
pl.CharacterAdded:Connect(function()if active or entering then leave()end end)
pg:GetAttributeChangedSignal("ACP_TrucoActive"):Connect(function()if pg:GetAttribute("ACP_TrucoActive")and(active or entering)then leave()end end)
pl:GetAttributeChangedSignal("ACP_InGameRoom"):Connect(function()if pl:GetAttribute("ACP_InGameRoom")and(active or entering)then leave()end end)
UIS.InputBegan:Connect(function(input,gp)
 if not active or capturing then return end
 if input.KeyCode==Enum.KeyCode.Escape or input.KeyCode==Enum.KeyCode.ButtonB then if U.Popup.Visible then closePanel()elseif U.Restore.Visible then U.SetClean(false)else leave()end;return end
 if U.Restore.Visible and(input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1)then U.SetClean(false);return end
 if gp then return end
 if current=="Pose"then return end
 if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
  local p=input.Position
  for _,o in ipairs({U.Nav,U.Extras,U.Popup,U.Close,U.Restore,U.DragMode,U.Buttons.Hide,U.ToolsToggle,U.Shutter,Rehearsal.Root})do if o.Visible then local a,s=o.AbsolutePosition,o.AbsoluteSize;if p.X>=a.X and p.X<=a.X+s.X and p.Y>=a.Y and p.Y<=a.Y+s.Y then return end end end
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
print("[V77] Photo Mode: barra de cinco ações, três colunas e centro fixo")
