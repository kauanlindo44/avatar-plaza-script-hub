-- 07G_HUB_UI
-- LocalScript | StarterPlayer > StarterPlayerScripts
-- AVATAR PLAZA V36E - HUD Catalog Style + CFG colorido e útil.

local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local Lighting=game:GetService("Lighting")
local UIS=game:GetService("UserInputService")

local pl=Players.LocalPlayer
local pg=pl:WaitForChild("PlayerGui")
local kit=Rep:WaitForChild("PracaKit",40)
if not kit then return end

local old=pg:FindFirstChild("LimitedMarketHUD")
if old then old:Destroy()end

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

local rootScale=Instance.new("UIScale")
rootScale.Parent=root

local C={
 black=Color3.fromRGB(20,20,23),
 line=Color3.fromRGB(79,81,89),
 white=Color3.fromRGB(248,248,250),
 muted=Color3.fromRGB(182,184,190)
}

local function round(o,r)
 local c=Instance.new("UICorner")
 c.CornerRadius=UDim.new(0,r or 12)
 c.Parent=o
end

local function stroke(o,color,transparency)
 local s=Instance.new("UIStroke")
 s.Color=color or C.line
 s.Transparency=transparency or .65
 s.Thickness=1
 s.Parent=o
end

local function button(text,anchor,pos)
 local b=Instance.new("TextButton")
 b.Text=text
 b.AnchorPoint=anchor
 b.Position=pos
 b.Size=UDim2.fromOffset(96,36)
 b.BackgroundColor3=C.black
 b.BackgroundTransparency=.02
 b.BorderSizePixel=0
 b.TextColor3=C.white
 b.Font=Enum.Font.GothamBold
 b.TextSize=8
 b.AutoButtonColor=true
 b.Parent=root
 round(b,11)
 stroke(b)
 return b
end

local community=button("COMUNIDADE",Vector2.new(0,.5),UDim2.new(0,18,.36,0))
local loader=button("CARREGAR",Vector2.new(0,.5),UDim2.new(0,18,.43,0))
local photo=button("FOTO",Vector2.new(0,.5),UDim2.new(0,18,.50,0))
local looks=button("MEUS LOOKS",Vector2.new(1,.5),UDim2.new(1,-18,.36,0))
local emotes=button("EMOTES",Vector2.new(1,.5),UDim2.new(1,-18,.43,0))
local games=button("JOGOS",Vector2.new(1,.5),UDim2.new(1,-18,.50,0))
local cfg=button("CFG",Vector2.new(1,.5),UDim2.new(1,-18,.57,0))

local function shopGui()
 return pg:FindFirstChild("AvatarShop08Gui")or pg:WaitForChild("AvatarShop08Gui",5)
end

local function shop(mode)
 local g=shopGui()
 local e=g and g:FindFirstChild("OpenRequest")
 if e and e:IsA("BindableEvent")then e:Fire(mode)end
end

community.Activated:Connect(function()shop("Community")end)
loader.Activated:Connect(function()shop("Loader")end)
looks.Activated:Connect(function()shop("Looks")end)
emotes.Activated:Connect(function()shop("Emotes")end)

photo.Activated:Connect(function()
 pg:SetAttribute(
  "ACP_OpenPhotoNonce",
  (tonumber(pg:GetAttribute("ACP_OpenPhotoNonce"))or 0)+1
 )
end)

games.Activated:Connect(function()
 pg:SetAttribute(
  "ACP_OpenGamesNonce",
  (tonumber(pg:GetAttribute("ACP_OpenGamesNonce"))or 0)+1
 )
end)

local panel=Instance.new("Frame")
panel.AnchorPoint=Vector2.new(1,.5)
panel.Position=UDim2.new(1,-126,.57,0)
panel.Size=UDim2.fromOffset(286,300)
panel.BackgroundColor3=Color3.fromRGB(28,29,34)
panel.BorderSizePixel=0
panel.Visible=false
panel.Parent=root
round(panel,16)
stroke(panel,Color3.fromRGB(96,99,111),.45)

local title=Instance.new("TextLabel")
title.BackgroundTransparency=1
title.Text="CONFIGURAÇÕES"
title.Position=UDim2.fromOffset(14,10)
title.Size=UDim2.new(1,-28,0,24)
title.TextColor3=C.white
title.Font=Enum.Font.GothamBlack
title.TextSize=12
title.TextXAlignment=Enum.TextXAlignment.Left
title.Parent=panel

local sub=Instance.new("TextLabel")
sub.BackgroundTransparency=1
sub.Text="Mapa • HUD • música • desempenho"
sub.Position=UDim2.fromOffset(14,34)
sub.Size=UDim2.new(1,-28,0,18)
sub.TextColor3=C.muted
sub.Font=Enum.Font.Gotham
sub.TextSize=7
sub.TextXAlignment=Enum.TextXAlignment.Left
sub.Parent=panel

local themes={
 {"ORIGINAL",Color3.fromRGB(85,181,79)},
 {"CYAN",Color3.fromRGB(73,205,222)},
 {"LILAC",Color3.fromRGB(169,126,225)},
 {"PINK",Color3.fromRGB(225,112,177)},
 {"SUNSET",Color3.fromRGB(237,152,74)},
 {"BLUE",Color3.fromRGB(83,141,226)}
}

local function small(text,pos,size,color)
 local b=Instance.new("TextButton")
 b.Text=text
 b.Position=pos
 b.Size=size
 b.BackgroundColor3=color
 b.BorderSizePixel=0
 b.TextColor3=Color3.fromRGB(255,255,255)
 b.Font=Enum.Font.GothamBold
 b.TextSize=7
 b.Parent=panel
 round(b,9)
 return b
end

local function applyTheme(name,color)
 pg:SetAttribute("ACP_Environment",name)
 local world=workspace:FindFirstChild("PracaAvatar_V2")
 local folder=world and world:FindFirstChild("AccentThemeParts")
 if folder then
  for _,p in ipairs(folder:GetDescendants())do
   if p:IsA("BasePart")and p:GetAttribute("Themeable")then
    p.Color=color
   end
  end
 end
 local cc=Lighting:FindFirstChild("ACP_V36E_Color")
 if cc then
  cc.TintColor=color:Lerp(Color3.fromRGB(244,246,248),.82)
 end
end

for i,v in ipairs(themes)do
 local col=(i-1)%3
 local row=math.floor((i-1)/3)
 local b=small(
  v[1],
  UDim2.fromOffset(14+col*88,66+row*44),
  UDim2.fromOffset(80,36),
  v[2]
 )
 b.Activated:Connect(function()
  applyTheme(v[1],v[2])
 end)
end

local music=small(
 "MÚSICA: ON",
 UDim2.fromOffset(14,160),
 UDim2.fromOffset(122,36),
 Color3.fromRGB(63,150,102)
)
local fx=small(
 "EFEITOS: NORMAL",
 UDim2.fromOffset(146,160),
 UDim2.fromOffset(126,36),
 Color3.fromRGB(91,112,164)
)
local hud=small(
 "HUD: NORMAL",
 UDim2.fromOffset(14,206),
 UDim2.fromOffset(122,36),
 Color3.fromRGB(160,95,159)
)
local preview=small(
 "PREVIEW: STUDIO",
 UDim2.fromOffset(146,206),
 UDim2.fromOffset(126,36),
 Color3.fromRGB(184,118,63)
)
local close=small(
 "FECHAR",
 UDim2.fromOffset(14,252),
 UDim2.new(1,-28,0,34),
 Color3.fromRGB(66,68,76)
)

local fxNormal=true
local hudCompact=false
local previewStudio=true

music.Activated:Connect(function()
 local on=pg:GetAttribute("ACP_MusicEnabled")~=false
 on=not on
 pg:SetAttribute("ACP_MusicEnabled",on)
 music.Text=on and"MÚSICA: ON"or"MÚSICA: OFF"
 music.BackgroundColor3=on
  and Color3.fromRGB(63,150,102)
  or Color3.fromRGB(112,70,74)
end)

fx.Activated:Connect(function()
 fxNormal=not fxNormal
 local cc=Lighting:FindFirstChild("ACP_V36E_Color")
 if cc then cc.Enabled=fxNormal end
 local a=Lighting:FindFirstChild("ACP_V36E_Atmosphere")
 if a then
  a.Density=fxNormal and .16 or .04
  a.Haze=fxNormal and .32 or .08
 end
 fx.Text=fxNormal and"EFEITOS: NORMAL"or"EFEITOS: LEVE"
end)

hud.Activated:Connect(function()
 hudCompact=not hudCompact
 rootScale.Scale=hudCompact and .88 or 1
 hud.Text=hudCompact and"HUD: COMPACTO"or"HUD: NORMAL"
end)

preview.Activated:Connect(function()
 previewStudio=not previewStudio
 pg:SetAttribute("ACP_PreviewStudio",previewStudio)
 preview.Text=previewStudio and"PREVIEW: STUDIO"or"PREVIEW: CLEAN"
end)

cfg.Activated:Connect(function()
 panel.Visible=not panel.Visible
end)
close.Activated:Connect(function()
 panel.Visible=false
end)

local allButtons={community,loader,photo,looks,emotes,games,cfg}
local function adapt()
 local cam=workspace.CurrentCamera
 local vp=cam and cam.ViewportSize or Vector2.new(900,600)
 local compact=UIS.TouchEnabled or vp.X<760
 local w=compact and 88 or 96
 local h=compact and 34 or 36
 for _,b in ipairs(allButtons)do
  b.Size=UDim2.fromOffset(w,h)
 end
 local lx=compact and 10 or 18
 local rx=compact and -10 or -18
 community.Position=UDim2.new(0,lx,.35,0)
 loader.Position=UDim2.new(0,lx,.42,0)
 photo.Position=UDim2.new(0,lx,.49,0)
 looks.Position=UDim2.new(1,rx,.35,0)
 emotes.Position=UDim2.new(1,rx,.42,0)
 games.Position=UDim2.new(1,rx,.49,0)
 cfg.Position=UDim2.new(1,rx,.56,0)
 panel.Position=UDim2.new(1,rx-w-8,.56,0)
end

if workspace.CurrentCamera then
 workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(adapt)
end

task.defer(adapt)
pg:SetAttribute("ACP_PreviewStudio",true)
applyTheme("ORIGINAL",themes[1][2])
print("AVATAR PLAZA V36E: HUD Catalog Style carregada")
