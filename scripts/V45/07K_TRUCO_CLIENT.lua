-- 07K_TRUCO_CLIENT | LocalScript | StarterPlayer > StarterPlayerScripts | V45
local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local Tween=game:GetService("TweenService")
local Run=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local Gui=game:GetService("GuiService")
local pl=Players.LocalPlayer;local pg=pl:WaitForChild("PlayerGui")
local rem=Rep:WaitForChild("PracaKit"):WaitForChild("Remotes")
local request=rem:WaitForChild("TrucoRequest");local push=rem:WaitForChild("TrucoPush")
local D=require(Rep:WaitForChild("07UI_DESIGN_SYSTEM"))
local Cards=require(Rep:WaitForChild("07K7_CARD_STYLES"))
local old=pg:FindFirstChild("ACP_Truco");if old then old:Destroy()end
local gui=D.New("ScreenGui",{Name="ACP_Truco",ResetOnSpawn=false,IgnoreGuiInset=true,ScreenInsets=Enum.ScreenInsets.None,
 SafeAreaCompatibility=Enum.SafeAreaCompatibility.None,ClipToDeviceSafeArea=false,DisplayOrder=210,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
local notice=D.Text(gui,"",{AnchorPoint=Vector2.new(.5,0),Position=UDim2.fromScale(.5,.17),Size=UDim2.new(.8,0,0,44),
 BackgroundColor3=D.Colors.panel,BackgroundTransparency=.08,Visible=false,ZIndex=100})
local serial=0;local function toast(s)if not s then return end;serial=serial+1;local n=serial;notice.Text=tostring(s);notice.Visible=true;task.delay(4,function()if serial==n then notice.Visible=false end end)end
local rpcBusy=false;local rpcFinished=-100
local function call(action,data)
 while rpcBusy or os.clock()-rpcFinished<.15 do task.wait(.03)end;rpcBusy=true
 local ok,r=pcall(function()return request:InvokeServer(action,data or{})end)
 rpcBusy=false;rpcFinished=os.clock()
 if not ok or type(r)~="table"then return nil,"Servidor não respondeu. Tente novamente."end
 return r.ok and r.data or nil,r.error
end
local state,inventory,cameraSaved=nil,nil,nil;local hidden={};local visuals={};local matchUI
local touchSaved
local function focus(on)
 pg:SetAttribute("ACP_TrucoActive",on)
 if on and state then pcall(function()if touchSaved==nil then touchSaved=Gui.TouchControlsEnabled end;Gui.TouchControlsEnabled=false end)
 elseif not on and touchSaved~=nil then pcall(function()Gui.TouchControlsEnabled=touchSaved end);touchSaved=nil end
 for _,name in ipairs({"LimitedMarketHUD","AvatarShopLauncherGui","CreatorHUD_V2","HubAvatarLauncher","GameClubGui","AvatarShop08Gui","ACP_PhotoMode","HubProgress07Gui","HubTitlesGui"})do
  local g=pg:FindFirstChild(name);if g and g:IsA("ScreenGui")then if on then if hidden[g]==nil then hidden[g]=g.Enabled end;g.Enabled=false elseif hidden[g]~=nil then g.Enabled=hidden[g];hidden[g]=nil end end
 end
end
local handParts,handVisuals,limbs,hiddenParts={},{},{},{}
local currentTable;local cameraStep;local hoverIndex;local playing=false
local function cleanHand()
 for _,v in ipairs(handVisuals)do v:Destroy()end;handVisuals={};handParts={};limbs={};hoverIndex=nil
end
local function hideCharacter()
 local char=pl.Character;if not char then return end
 for _,v in ipairs(char:GetDescendants())do if v:IsA("BasePart")then
  if hiddenParts[v]==nil then hiddenParts[v]=v.LocalTransparencyModifier end;v.LocalTransparencyModifier=1
 end end
end
local function releaseCharacter()
 for v,old in pairs(hiddenParts)do if v.Parent then v.LocalTransparencyModifier=old or 0 end end;hiddenParts={}
end
local function privateHand(v)
 cleanHand();local cam=workspace.CurrentCamera;if not cam then return end
 local style=inventory and inventory.view~="classic"and inventory.equipped or"Classic";local custom=inventory and inventory.custom
 for i,card in ipairs(v.hand)do
  local part=Instance.new("Part");part.Name="ACP_PrivateHandCard";part.Anchored=true;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false
  part.Size=Vector3.new(.75,1.08,.025);part.Color=Color3.fromRGB(45,48,55);part.CastShadow=false;part.Parent=cam
  Cards.Surface(part,card,style,custom,Enum.NormalId.Back);table.insert(handVisuals,part);handParts[i]=part
 end
 local char=pl.Character
 for _,side in ipairs({"Left","Right"})do
  local source=char and(char:FindFirstChild(side.."Hand")or char:FindFirstChild(side.." Arm"))
  if source and source:IsA("BasePart")then local ok,copy=pcall(function()return source:Clone()end)
   if ok and copy then
    for _,v in ipairs(copy:GetDescendants())do if v:IsA("JointInstance")or v:IsA("Constraint")or v:IsA("LuaSourceContainer")then v:Destroy()end end
    copy.Name="ACP_"..side.."Hand";copy.Anchored=true;copy.CanCollide=false;copy.CanTouch=false;copy.CanQuery=false;copy.CastShadow=false;copy.LocalTransparencyModifier=0
    copy.Size=Vector3.new(.40,.54,.50);copy.Parent=cam;table.insert(handVisuals,copy);limbs[side]=copy
   end
  end
 end
end
local function updateCamera()
 if not state or not currentTable then return end;local cam=workspace.CurrentCamera
 local seat=currentTable:FindFirstChild("Seat"..state.seat);local top=currentTable:FindFirstChild("TableTop");if not cam or not seat or not top then return end
 hideCharacter();cam.CameraType=Enum.CameraType.Scriptable;cam.FieldOfView=65
 local direction=Vector3.new(top.Position.X-seat.Position.X,0,top.Position.Z-seat.Position.Z).Unit
 local head=pl.Character and pl.Character:FindFirstChild("Head");local height=head and math.clamp(head.Position.Y-seat.Position.Y,2.4,4.2)or 3.3
 local eye=seat.Position+Vector3.new(0,height+.15,0)+direction*.65
 cam.CFrame=CFrame.lookAt(eye,top.Position+Vector3.new(0,.8,0));cam.Focus=CFrame.new(top.Position)
 local viewport=cam.ViewportSize;local aspect=viewport.X/math.max(1,viewport.Y);local scale=math.min(1,math.max(.58,aspect*.95))
 local count=#handParts;local canPlay=state.phase=="play"and state.turn==state.seat and not matchUI.Dialog.Visible
 local lift=canPlay and .06 or 0
 for i,part in ipairs(handParts)do
  local x=(i-(count+1)/2)*.52*scale;local hover=canPlay and hoverIndex==i and .16 or 0
  part.Size=Vector3.new(.75*scale,1.08*scale,.025)
  local controls=matchUI.Controls.AbsoluteSize.Y;local bottom=(controls+16)/math.max(1,viewport.Y)
  local span=2.8*math.tan(math.rad(cam.FieldOfView/2));local cy=-span*(1-2*bottom)+.54*scale+.06
  part.CFrame=cam.CFrame*CFrame.new(x,cy+lift+hover,-2.8-(i-1)*.018)*CFrame.Angles(math.rad(-8),0,math.rad((i-(count+1)/2)*-10))
 end
 local cy=handParts[1]and(cam.CFrame:PointToObjectSpace(handParts[1].Position).Y-.45*scale)or -1.1
 if limbs.Left then limbs.Left.CFrame=cam.CFrame*CFrame.new(-.7*scale,cy,-2.65)*CFrame.Angles(0,0,math.rad(-40))end
 if limbs.Right then limbs.Right.CFrame=cam.CFrame*CFrame.new(.7*scale,cy,-2.65)*CFrame.Angles(0,0,math.rad(40))end
end
local function cardAt(position)
 local cam=workspace.CurrentCamera;if not cam or not state then return end
 local ray=cam:ViewportPointToRay(position.X,position.Y)
 for i=#handParts,1,-1 do local part=handParts[i];local localRay=part.CFrame:PointToObjectSpace(ray.Origin);local dir=part.CFrame:VectorToObjectSpace(ray.Direction)
  if math.abs(dir.Z)>.0001 then local t=(part.Size.Z/2-localRay.Z)/dir.Z
   if t>0 then local p=localRay+dir*t;if math.abs(p.X)<=part.Size.X/2 and math.abs(p.Y)<=part.Size.Y/2 then return i end end
  end
 end
end
local function cleanVisuals()for _,v in ipairs(visuals)do v:Destroy()end;visuals={}end
local function restore()
 cleanVisuals();cleanHand();releaseCharacter();currentTable=nil;if cameraStep then cameraStep:Disconnect();cameraStep=nil end;if cameraSaved and workspace.CurrentCamera then local c=workspace.CurrentCamera;c.CameraType=cameraSaved.kind;c.FieldOfView=cameraSaved.fov;c.CameraSubject=pl.Character and pl.Character:FindFirstChildOfClass("Humanoid")or cameraSaved.subject;c.CFrame=cameraSaved.cf;c.Focus=cameraSaved.focus end
 cameraSaved=nil;state=nil;matchUI.Root.Visible=false;focus(false)
end
local function renderTable(v)
 cleanVisuals();local world=workspace:FindFirstChild("PracaAvatar_V2");local d=world and world:FindFirstChild("ChallengeDistrict");local zone=d and d:FindFirstChild("Truco");local tableModel=zone and zone:FindFirstChild(v.tableName)
 if not tableModel then task.delay(.5,function()if state==v then renderTable(v)end end);return end
 local cam=workspace.CurrentCamera
 if cam and not cameraSaved then cameraSaved={kind=cam.CameraType,subject=cam.CameraSubject,cf=cam.CFrame,fov=cam.FieldOfView,focus=cam.Focus}end
 local seat=tableModel:FindFirstChild("Seat"..v.seat);local top=tableModel:FindFirstChild("TableTop")
 currentTable=tableModel;privateHand(v);updateCamera()
 if not cameraStep then cameraStep=Run.RenderStepped:Connect(updateCamera)end
 local cards=#v.tableCards>0 and v.tableCards or v.lastTrick or{}
 for _,p in ipairs(cards)do
  local anchor=tableModel:FindFirstChild("CardAnchor"..p.seat);if anchor then
   local choice=inventory and inventory.view or"mine";local info=choice=="players"and v.styles[p.seat]or{style=inventory and inventory.equipped or"Classic",custom=inventory and inventory.custom}
   if choice=="classic"then info={style="Classic"}end
   local part=Instance.new("Part");part.Name="ACP_PublicCard";part.Anchored=true;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false;part.Size=anchor.Size;part.CFrame=anchor.CFrame;part.Color=Color3.fromRGB(241,238,228);part.Parent=workspace;table.insert(visuals,part)
   Cards.Surface(part,p.card,info.style,info.custom)
   if #v.tableCards>0 then part.CFrame=tableModel.DeckAnchor.CFrame;Tween:Create(part,TweenInfo.new(.23),{CFrame=anchor.CFrame}):Play()end
  end
 end
 local deck=tableModel:FindFirstChild("DeckAnchor");if deck then local surface=Cards.Surface(deck,nil,inventory and inventory.equipped or"Classic",inventory and inventory.custom);table.insert(visuals,surface)end
 if v.vira then
  local part=Instance.new("Part");part.Name="ACP_Vira";part.Size=Vector3.new(2.4,.06,3.5);part.CFrame=top.CFrame*CFrame.new(-3,.5,0);part.Anchored=true;part.CanCollide=false;part.CanQuery=false;part.Parent=workspace
  table.insert(visuals,part);Cards.Surface(part,v.vira,"Classic")
 end
end
local function sendAction(action,arg,extra)
 if not state or playing then return end;playing=true
 local d,e=call("action",{action=action,arg=arg,extra=extra,revision=state.revision});playing=false;if not d then toast(e)end
end
matchUI=require(Rep:WaitForChild("07K5_TRUCO_UI")).Build(gui,function(action,arg,extra)
 sendAction(action,arg,extra)
end)
matchUI.WorldHand=true;matchUI.Hand.Visible=false
local click=UIS.InputBegan:Connect(function(input,processed)
 if processed or not state or state.phase~="play"or state.turn~=state.seat or matchUI.Dialog.Visible then return end
 if input.UserInputType==Enum.UserInputType.Keyboard then
  local index=({[Enum.KeyCode.One]=1,[Enum.KeyCode.Two]=2,[Enum.KeyCode.Three]=3})[input.KeyCode]
  if index and handParts[index]then sendAction("play",index,matchUI.Covered==true)end;return
 end
 if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
  local i=cardAt(input.Position);if i then sendAction("play",i,matchUI.Covered==true)end
 end
end)
local hover=UIS.InputChanged:Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseMovement and state then hoverIndex=cardAt(input.Position)end end)
matchUI.OnLeave=function()local d,e=call("leave");if d then restore();pg:SetAttribute("ACP_OpenGamesNonce",(pg:GetAttribute("ACP_OpenGamesNonce")or 0)+1)else toast(e)end end
matchUI.OnShout=function(text)local d,e=call("shout",{text=text});if not d then toast(e)end end
local inventoryUI=require(Rep:WaitForChild("07K9_CARD_INVENTORY_UI")).Build(gui,call,toast)
local cupUI
cupUI=require(Rep:WaitForChild("07K12_TOURNAMENT_UI")).Build(gui,call,toast,function(invite)
 local d,e=call("cupjoin",{id=invite.id,match=invite.match.id});if d then cupUI.Root.Visible=false;focus(false)else toast(e)end
end)
local function back()focus(false)end;inventoryUI.OnClose=back;cupUI.OnClose=back
pg:GetAttributeChangedSignal("ACP_OpenInventoryNonce"):Connect(function()if state then return end;focus(true);inventoryUI.Show()end)
pg:GetAttributeChangedSignal("ACP_OpenCupsNonce"):Connect(function()if state then return end;focus(true);cupUI.Show()end)
local function syncInventory(data)
 if not data then return end;inventory=data;inventoryUI.Data=data;pg:SetAttribute("ACP_CardView",data.view)
 if inventoryUI.Root.Visible then inventoryUI.Render()end;if state then matchUI.Update(state,inventory);renderTable(state)end
end
pg:GetAttributeChangedSignal("ACP_CardView"):Connect(function()
 local value=pg:GetAttribute("ACP_CardView");if inventory and inventory.view==value then return end
 local d,e=call("settings",{view=value});if not d then toast(e);if inventory then pg:SetAttribute("ACP_CardView",inventory.view)end end
end)
push.OnClientEvent:Connect(function(kind,data)
 if kind=="match"then state=data;inventoryUI.Root.Visible=false;cupUI.Root.Visible=false;focus(true);matchUI.Update(data,inventory);renderTable(data)
 elseif kind=="inventory"then syncInventory(data)
 elseif kind=="inbox"then cupUI.SetInbox(data);local n=0;for _,i in ipairs(data)do if i.canAnswer and not i.answered or i.match then n=n+1 end end;pg:SetAttribute("ACP_CupNotifications",n)
 elseif kind=="waiting"then pg:SetAttribute("ACP_TrucoWaitingCode",data.code);pg:SetAttribute("ACP_TrucoWaitingCount",data.count)
 elseif kind=="notice"then toast(data)
 elseif kind=="closed"then if state then restore()end;pg:SetAttribute("ACP_TrucoWaitingCode",nil)
 elseif kind=="shout"then toast(data)
 end
end)
pl.CharacterAdded:Connect(function()if state then task.delay(.7,function()if state then renderTable(state)end end)end end)
gui.Destroying:Connect(function()click:Disconnect();hover:Disconnect();restore()end)
task.spawn(function()syncInventory(call("inventory"));call("arrival")end)
