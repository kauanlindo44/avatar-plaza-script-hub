-- 07K_TRUCO_CLIENT | LocalScript | StarterPlayer > StarterPlayerScripts | V44
local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local Tween=game:GetService("TweenService")
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
local function focus(on)
 pg:SetAttribute("ACP_TrucoActive",on)
 for _,name in ipairs({"LimitedMarketHUD","AvatarShopLauncherGui","CreatorHUD_V2","HubAvatarLauncher","GameClubGui","AvatarShop08Gui","ACP_PhotoMode","HubProgress07Gui","HubTitlesGui"})do
  local g=pg:FindFirstChild(name);if g and g:IsA("ScreenGui")then if on then if hidden[g]==nil then hidden[g]=g.Enabled end;g.Enabled=false elseif hidden[g]~=nil then g.Enabled=hidden[g];hidden[g]=nil end end
 end
end
local function cleanVisuals()for _,v in ipairs(visuals)do v:Destroy()end;visuals={}end
local function restore()
 cleanVisuals();if cameraSaved and workspace.CurrentCamera then local c=workspace.CurrentCamera;c.CameraType=cameraSaved.kind;c.FieldOfView=cameraSaved.fov;c.CameraSubject=pl.Character and pl.Character:FindFirstChildOfClass("Humanoid")or cameraSaved.subject;c.CFrame=cameraSaved.cf end
 cameraSaved=nil;state=nil;matchUI.Root.Visible=false;focus(false)
end
local function renderTable(v)
 cleanVisuals();local world=workspace:FindFirstChild("PracaAvatar_V2");local d=world and world:FindFirstChild("ChallengeDistrict");local zone=d and d:FindFirstChild("Truco");local tableModel=zone and zone:FindFirstChild(v.tableName)
 if not tableModel then task.delay(.5,function()if state==v then renderTable(v)end end);return end
 local cam=workspace.CurrentCamera
 if cam and not cameraSaved then cameraSaved={kind=cam.CameraType,subject=cam.CameraSubject,cf=cam.CFrame,fov=cam.FieldOfView}end
 local seat=tableModel:FindFirstChild("Seat"..v.seat);local top=tableModel:FindFirstChild("TableTop")
 if cam and seat and top then cam.CameraType=Enum.CameraType.Scriptable;cam.FieldOfView=72;cam.CFrame=CFrame.lookAt(seat.Position+Vector3.new(0,3.6,0),top.Position+Vector3.new(0,.8,0))end
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
matchUI=require(Rep:WaitForChild("07K5_TRUCO_UI")).Build(gui,function(action,arg,extra)
 if not state then return end;local d,e=call("action",{action=action,arg=arg,extra=extra,revision=state.revision});if not d then toast(e)end
end)
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
 if inventoryUI.Root.Visible then inventoryUI.Render()end
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
gui.Destroying:Connect(restore)
task.spawn(function()syncInventory(call("inventory"));call("arrival")end)
