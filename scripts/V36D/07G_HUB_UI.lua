-- 07G_HUB_UI
-- LocalScript | StarterPlayer > StarterPlayerScripts
-- AVATAR PLAZA V36D - HUD compacta Catalog Style, sem sobreposição.

local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local Lighting=game:GetService("Lighting")
local UIS=game:GetService("UserInputService")

local pl=Players.LocalPlayer
local pg=pl:WaitForChild("PlayerGui")
local kit=Rep:WaitForChild("PracaKit",40)
if not kit then return end

local old=pg:FindFirstChild("LimitedMarketHUD")
if old then old:Destroy() end

local gui=Instance.new("ScreenGui")
gui.Name="LimitedMarketHUD"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=55
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.Parent=pg

local root=Instance.new("Frame")
root.Size=UDim2.fromScale(1,1)
root.BackgroundTransparency=1
root.Parent=gui

local C={
 panel=Color3.fromRGB(18,19,24),
 line=Color3.fromRGB(72,76,89),
 white=Color3.fromRGB(247,248,252),
 cyan=Color3.fromRGB(92,205,226)
}

local function round(o,r)
 local x=Instance.new("UICorner")
 x.CornerRadius=UDim.new(0,r or 12)
 x.Parent=o
end

local function button(label,anchor,pos)
 local b=Instance.new("TextButton")
 b.Text=label
 b.AnchorPoint=anchor
 b.Position=pos
 b.Size=UDim2.fromOffset(98,38)
 b.BackgroundColor3=C.panel
 b.BackgroundTransparency=.04
 b.BorderSizePixel=0
 b.TextColor3=C.white
 b.Font=Enum.Font.GothamBold
 b.TextSize=8
 b.AutoButtonColor=true
 b.Parent=root
 round(b,12)
 local s=Instance.new("UIStroke")
 s.Color=C.line
 s.Transparency=.58
 s.Parent=b
 return b
end

local community=button("COMUNIDADE",Vector2.new(0,.5),UDim2.new(0,16,.35,0))
local loader=button("CARREGAR",Vector2.new(0,.5),UDim2.new(0,16,.42,0))
local photo=button("FOTO",Vector2.new(0,.5),UDim2.new(0,16,.49,0))

local looks=button("MEUS LOOKS",Vector2.new(1,.5),UDim2.new(1,-16,.35,0))
local emotes=button("EMOTES",Vector2.new(1,.5),UDim2.new(1,-16,.42,0))
local games=button("JOGOS",Vector2.new(1,.5),UDim2.new(1,-16,.49,0))
local cfg=button("CFG",Vector2.new(1,.5),UDim2.new(1,-16,.56,0))

local function shopGui()
 return pg:FindFirstChild("AvatarShop08Gui") or pg:WaitForChild("AvatarShop08Gui",5)
end

local function shop(mode)
 local g=shopGui()
 local e=g and g:FindFirstChild("OpenRequest")
 if e and e:IsA("BindableEvent")then
  e:Fire(mode)
 else
  warn("[V36D] Shop ainda não foi construída para "..tostring(mode))
 end
end

community.Activated:Connect(function()shop("Community")end)
loader.Activated:Connect(function()shop("Loader")end)
looks.Activated:Connect(function()shop("Looks")end)
emotes.Activated:Connect(function()shop("Emotes")end)

photo.Activated:Connect(function()
 pg:SetAttribute("ACP_OpenPhotoNonce",(tonumber(pg:GetAttribute("ACP_OpenPhotoNonce"))or 0)+1)
end)

games.Activated:Connect(function()
 pg:SetAttribute("ACP_OpenGamesNonce",(tonumber(pg:GetAttribute("ACP_OpenGamesNonce"))or 0)+1)
end)

local panel=Instance.new("Frame")
panel.AnchorPoint=Vector2.new(1,.5)
panel.Position=UDim2.new(1,-124,.56,0)
panel.Size=UDim2.fromOffset(196,206)
panel.BackgroundColor3=Color3.fromRGB(23,25,31)
panel.BorderSizePixel=0
panel.Visible=false
panel.Parent=root
round(panel,14)

local title=Instance.new("TextLabel")
title.BackgroundTransparency=1
title.Text="AMBIENTE"
title.Position=UDim2.fromOffset(12,8)
title.Size=UDim2.new(1,-24,0,22)
title.TextColor3=C.white
title.Font=Enum.Font.GothamBlack
title.TextSize=10
title.TextXAlignment=Enum.TextXAlignment.Left
title.Parent=panel

local themes={
 {"CYAN",Color3.fromRGB(92,205,226)},
 {"LILAC",Color3.fromRGB(164,129,231)},
 {"MINT",Color3.fromRGB(104,213,176)},
 {"BLUE",Color3.fromRGB(98,151,232)},
 {"PINK",Color3.fromRGB(226,125,184)},
 {"GOLD",Color3.fromRGB(229,184,92)}
}

local function applyAccent(color)
 local world=workspace:FindFirstChild("PracaAvatar_V2")
 local folder=world and world:FindFirstChild("AccentThemeParts")
 if folder then
  for _,p in ipairs(folder:GetDescendants())do
   if p:IsA("BasePart")and p:GetAttribute("Themeable")==true then
    p.Color=color
   end
  end
 end
 local a=Lighting:FindFirstChild("ACP_V36D_Atmosphere")
 if a then a.Color=color:Lerp(Color3.fromRGB(215,225,235),.72)end
end

for i,v in ipairs(themes)do
 local col=(i-1)%2
 local row=math.floor((i-1)/2)
 local b=Instance.new("TextButton")
 b.Text=v[1]
 b.Position=UDim2.fromOffset(10+col*90,40+row*49)
 b.Size=UDim2.fromOffset(84,40)
 b.BackgroundColor3=Color3.fromRGB(38,41,50)
 b.BorderSizePixel=0
 b.TextColor3=C.white
 b.Font=Enum.Font.GothamBold
 b.TextSize=7
 b.Parent=panel
 round(b,10)
 b.Activated:Connect(function()
  pg:SetAttribute("ACP_Environment",v[1])
  applyAccent(v[2])
 end)
end

cfg.Activated:Connect(function()
 panel.Visible=not panel.Visible
end)

local function adapt()
 local cam=workspace.CurrentCamera
 local v=cam and cam.ViewportSize or Vector2.new(900,600)
 local compact=UIS.TouchEnabled or v.X<760
 local w=compact and 88 or 98
 local h=compact and 35 or 38
 for _,b in ipairs({community,loader,photo,looks,emotes,games,cfg})do
  b.Size=UDim2.fromOffset(w,h)
 end
 local lx=compact and 10 or 16
 local rx=compact and -10 or -16
 community.Position=UDim2.new(0,lx,.34,0)
 loader.Position=UDim2.new(0,lx,.41,0)
 photo.Position=UDim2.new(0,lx,.48,0)
 looks.Position=UDim2.new(1,rx,.34,0)
 emotes.Position=UDim2.new(1,rx,.41,0)
 games.Position=UDim2.new(1,rx,.48,0)
 cfg.Position=UDim2.new(1,rx,.55,0)
 panel.Position=UDim2.new(1,rx-w-8,.55,0)
end

if workspace.CurrentCamera then
 workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(adapt)
end
task.defer(adapt)

task.spawn(function()
 local deadline=os.clock()+35
 while not kit:GetAttribute("BaseReady")and os.clock()<deadline do task.wait(.15)end
 applyAccent(Color3.fromRGB(92,205,226))
end)

print("AVATAR PLAZA V36D: HUD compacta carregada")
