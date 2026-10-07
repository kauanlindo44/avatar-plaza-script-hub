-- 07K_TRUCO_CLIENT | LocalScript | StarterPlayer > StarterPlayerScripts | V48
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
local state,inventory=nil,nil;local hidden={};local matchUI
local touchSaved
local function focus(on)
 pg:SetAttribute("ACP_TrucoActive",on)
 if on and state then pcall(function()if touchSaved==nil then touchSaved=Gui.TouchControlsEnabled end;Gui.TouchControlsEnabled=false end)
 elseif not on and touchSaved~=nil then pcall(function()Gui.TouchControlsEnabled=touchSaved end);touchSaved=nil end
 for _,name in ipairs({"LimitedMarketHUD","AvatarShopLauncherGui","CreatorHUD_V2","HubAvatarLauncher","GameClubGui","AvatarShop08Gui","ACP_PhotoMode","HubProgress07Gui","HubTitlesGui"})do
  local g=pg:FindFirstChild(name);if g and g:IsA("ScreenGui")then if on then if hidden[g]==nil then hidden[g]=g.Enabled end;g.Enabled=false elseif hidden[g]~=nil then g.Enabled=hidden[g];hidden[g]=nil end end
 end
end
local playing=false
local function restore()
 state=nil;matchUI.Root.Visible=false;focus(false)
end
local function sendAction(action,arg,extra)
 if not state or playing then return end;playing=true
 local d,e=call("action",{action=action,arg=arg,extra=extra,revision=state.revision});playing=false;if not d then toast(e)end
end
matchUI=require(Rep:WaitForChild("07K5_TRUCO_UI")).Build(gui,function(action,arg,extra)
 sendAction(action,arg,extra)
end)
local click=UIS.InputBegan:Connect(function(input,processed)
 if processed or not state or matchUI.Dialog.Visible or input.UserInputType~=Enum.UserInputType.Keyboard then return end
 local index=({[Enum.KeyCode.One]=1,[Enum.KeyCode.Two]=2,[Enum.KeyCode.Three]=3})[input.KeyCode]
 if index then matchUI.PlayOwned(index)end
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
 if not data then return end;inventory=data;pg:SetAttribute("ACP_GameCoins",data.coins or 0);inventoryUI.AcceptData(data);pg:SetAttribute("ACP_CardView",data.view)
 if inventoryUI.Root.Visible then inventoryUI.Render()end;if state then matchUI.Update(state,inventory)end
end
pg:GetAttributeChangedSignal("ACP_CardView"):Connect(function()
 local value=pg:GetAttribute("ACP_CardView");if inventory and inventory.view==value then return end
 local d,e=call("settings",{view=value});if not d then toast(e);if inventory then pg:SetAttribute("ACP_CardView",inventory.view)end end
end)
push.OnClientEvent:Connect(function(kind,data)
 if kind=="match"then state=data;inventoryUI.Root.Visible=false;cupUI.Root.Visible=false;focus(true);matchUI.Update(data,inventory)
 elseif kind=="inventory"then syncInventory(data)
 elseif kind=="inbox"then cupUI.SetInbox(data);local n=0;for _,i in ipairs(data)do if i.canAnswer and not i.answered or i.match then n=n+1 end end;pg:SetAttribute("ACP_CupNotifications",n)
 elseif kind=="waiting"then pg:SetAttribute("ACP_TrucoWaitingCode",data.code);pg:SetAttribute("ACP_TrucoWaitingCount",data.count)
 elseif kind=="notice"then toast(data)
 elseif kind=="closed"then if state then restore()end;pg:SetAttribute("ACP_TrucoWaitingCode",nil)
 elseif kind=="shout"then toast(data)
 end
end)
pl.CharacterAdded:Connect(function()if state then matchUI.Update(state,inventory)end end)
gui.Destroying:Connect(function()click:Disconnect();restore()end)
task.spawn(function()syncInventory(call("inventory"));call("arrival")end)
