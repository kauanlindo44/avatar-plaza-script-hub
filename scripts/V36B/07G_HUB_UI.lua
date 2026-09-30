-- 07G_HUB_UI
-- LocalScript | StarterPlayer > StarterPlayerScripts
-- AVATAR PLAZA V36B - HUD distribuída inspirada na lógica do Catalog Avatar.
-- Centro da tela livre; só ficam ações realmente úteis.

local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local Tween=game:GetService("TweenService")
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
 panel=Color3.fromRGB(16,17,23),
 panel2=Color3.fromRGB(22,23,31),
 line=Color3.fromRGB(76,79,96),
 white=Color3.fromRGB(248,249,252),
 muted=Color3.fromRGB(182,185,198),
 cyan=Color3.fromRGB(91,210,225)
}

local function round(o,r)
 local c=Instance.new("UICorner")
 c.CornerRadius=UDim.new(0,r or 12)
 c.Parent=o
end

local function stroke(o,col,t)
 local s=Instance.new("UIStroke")
 s.Color=col or C.line
 s.Transparency=t or .72
 s.Thickness=1
 s.Parent=o
 return s
end

local function button(parent,label,pos,size,anchor,textSize)
 local b=Instance.new("TextButton")
 b.Text=label
 b.AnchorPoint=anchor or Vector2.new(0,0)
 b.Position=pos
 b.Size=size
 b.BackgroundColor3=C.panel
 b.BackgroundTransparency=.04
 b.BorderSizePixel=0
 b.TextColor3=C.white
 b.Font=Enum.Font.GothamBold
 b.TextSize=textSize or 9
 b.AutoButtonColor=false
 b.Parent=parent
 round(b,12)
 stroke(b,C.line,.72)

 local sc=Instance.new("UIScale")
 sc.Parent=b
 b.MouseEnter:Connect(function()
  Tween:Create(sc,TweenInfo.new(.1),{Scale=1.035}):Play()
 end)
 b.MouseLeave:Connect(function()
  Tween:Create(sc,TweenInfo.new(.1),{Scale=1}):Play()
 end)
 b.Activated:Connect(function()
  Tween:Create(sc,TweenInfo.new(.05),{Scale=.94}):Play()
  task.delay(.06,function()
   if sc.Parent then
    Tween:Create(sc,TweenInfo.new(.14,Enum.EasingStyle.Back),{Scale=1}):Play()
   end
  end)
 end)
 return b
end

local function shopGui()
 return pg:FindFirstChild("AvatarShop08Gui")or pg:WaitForChild("AvatarShop08Gui",4)
end

local function shop(mode)
 local g=shopGui()
 local e=g and g:FindFirstChild("OpenRequest")
 if e and e:IsA("BindableEvent")then e:Fire(mode)end
end

local function action(name)
 local g=shopGui()
 local e=g and g:FindFirstChild("HudAction")
 if e and e:IsA("BindableEvent")then e:Fire(name)end
end

-- ESQUERDA
local community=button(root,"COMUNIDADE",UDim2.new(0,18,.43,0),UDim2.fromOffset(112,46),Vector2.new(0,.5),8)
local loader=button(root,"CARREGAR",UDim2.new(0,18,.51,0),UDim2.fromOffset(112,46),Vector2.new(0,.5),8)

-- DIREITA
local looks=button(root,"MEUS LOOKS",UDim2.new(1,-18,.43,0),UDim2.fromOffset(112,46),Vector2.new(1,.5),8)
local emotes=button(root,"EMOTES",UDim2.new(1,-18,.51,0),UDim2.fromOffset(112,46),Vector2.new(1,.5),9)

-- TOPO DIREITO
-- MÚSICA vem do 09A porque o 07M já escuta diretamente o TopMusic.
local cart=button(root,"CARRINHO",UDim2.new(1,-76,0,28),UDim2.fromOffset(66,44),Vector2.new(1,0),7)
local clear=button(root,"LIMPAR",UDim2.new(1,-10,0,28),UDim2.fromOffset(58,44),Vector2.new(1,0),7)

-- INFERIOR
local photo=button(root,"FOTO",UDim2.new(0,18,1,-116),UDim2.fromOffset(64,46),Vector2.new(0,1),9)
local games=button(root,"JOGOS",UDim2.new(1,-90,1,-116),UDim2.fromOffset(66,46),Vector2.new(1,1),8)
local cfg=button(root,"CFG",UDim2.new(1,-18,1,-116),UDim2.fromOffset(58,46),Vector2.new(1,1),9)

-- CONFIGURAÇÕES: fica escondida até clicar em CFG.
local panel=Instance.new("Frame")
panel.AnchorPoint=Vector2.new(1,1)
panel.Position=UDim2.new(1,-18,1,-172)
panel.Size=UDim2.fromOffset(270,222)
panel.BackgroundColor3=C.panel2
panel.BackgroundTransparency=.02
panel.BorderSizePixel=0
panel.Visible=false
panel.Parent=root
round(panel,15)
stroke(panel,C.line,.58)

local title=Instance.new("TextLabel")
title.BackgroundTransparency=1
title.Text="AMBIENTE"
title.Position=UDim2.fromOffset(13,9)
title.Size=UDim2.new(1,-58,0,22)
title.TextColor3=C.white
title.Font=Enum.Font.GothamBlack
title.TextSize=12
title.TextXAlignment=Enum.TextXAlignment.Left
title.Parent=panel

local close=button(panel,"X",UDim2.new(1,-8,0,7),UDim2.fromOffset(34,32),Vector2.new(1,0),11)

local note=Instance.new("TextLabel")
note.BackgroundTransparency=1
note.Text="temas claros para destacar a skin"
note.Position=UDim2.fromOffset(13,31)
note.Size=UDim2.new(1,-26,0,18)
note.TextColor3=C.muted
note.Font=Enum.Font.Gotham
note.TextSize=7
note.TextXAlignment=Enum.TextXAlignment.Left
note.Parent=panel

local envNames={"CYAN","MINT","SKY BLUE","LILAC","SOFT GREEN","PURPLE DAY"}
local envButtons={}
for i,name in ipairs(envNames)do
 local row=math.floor((i-1)/2)
 local col=(i-1)%2
 envButtons[name]=button(panel,name,UDim2.fromOffset(13+col*122,58+row*47),UDim2.fromOffset(113,39),Vector2.new(0,0),7)
end

local themes={
 CYAN={ground={166,224,228},ambient={145,166,181},outdoor={202,219,230},top={225,250,255},bottom={231,246,251},atm={212,239,244},decay={173,209,220},tint={244,253,255}},
 MINT={ground={181,225,197},ambient={151,170,160},outdoor={207,224,215},top={236,255,247},bottom={232,246,240},atm={220,243,232},decay={183,213,200},tint={248,255,250}},
 ["SKY BLUE"]={ground={178,214,238},ambient={146,162,183},outdoor={202,217,235},top={226,241,255},bottom={234,244,253},atm={216,234,250},decay={174,199,224},tint={247,251,255}},
 LILAC={ground={207,193,231},ambient={160,153,180},outdoor={219,211,232},top={244,234,255},bottom={241,238,249},atm={235,226,247},decay={202,188,222},tint={253,249,255}},
 ["SOFT GREEN"]={ground={187,216,176},ambient={156,169,151},outdoor={212,224,207},top={242,255,237},bottom={239,247,235},atm={228,243,222},decay={192,211,185},tint={251,255,248}},
 ["PURPLE DAY"]={ground={121,91,190},ambient={145,126,174},outdoor={203,186,221},top={207,157,244},bottom={143,104,202},atm={226,204,247},decay={171,131,209},tint={249,242,255}}
}

local function rgb(v)
 return Color3.fromRGB(v[1],v[2],v[3])
end

local function applyGround(base)
 local w=workspace:FindFirstChild("PracaAvatar_V2")
 local f=w and w:FindFirstChild("AvatarSpaceGround")
 if not f then return end
 for _,p in ipairs(f:GetChildren())do
  if p:IsA("BasePart")then
   local tone=tonumber(p:GetAttribute("Tone"))or 0
   p.Color=Color3.fromRGB(
    math.clamp(base[1]+tone,0,255),
    math.clamp(base[2]+tone,0,255),
    math.clamp(base[3]+tone,0,255)
   )
  end
 end
end

local function applyTheme(name)
 local t=themes[name]or themes.CYAN
 pg:SetAttribute("ACP_Environment",name)
 Lighting.ClockTime=13.7
 Lighting.Brightness=2.62
 Lighting.ExposureCompensation=.07
 Lighting.Ambient=rgb(t.ambient)
 Lighting.OutdoorAmbient=rgb(t.outdoor)
 Lighting.ColorShift_Top=rgb(t.top)
 Lighting.ColorShift_Bottom=rgb(t.bottom)

 local a=Lighting:FindFirstChild("ACP_V35Atmosphere")or Lighting:FindFirstChild("ACP_V36Atmosphere")
 if a then
  a.Color=rgb(t.atm)
  a.Decay=rgb(t.decay)
  a.Density=.12
  a.Haze=.42
  a.Glare=.025
 end

 local cc=Lighting:FindFirstChild("ACP_V35Color")or Lighting:FindFirstChild("ACP_V36Color")
 if cc then
  cc.TintColor=rgb(t.tint)
  cc.Brightness=.01
  cc.Contrast=.025
  cc.Saturation=.035
 end

 applyGround(t.ground)

 for n,b in pairs(envButtons)do
  local s=b:FindFirstChildOfClass("UIStroke")
  b.BackgroundColor3=n==name and Color3.fromRGB(43,50,64)or C.panel
  if s then
   s.Color=n==name and C.cyan or C.line
   s.Transparency=n==name and .3 or .72
  end
 end
end

community.Activated:Connect(function()shop("Community")end)
loader.Activated:Connect(function()shop("Loader")end)
looks.Activated:Connect(function()shop("Looks")end)
emotes.Activated:Connect(function()shop("Emotes")end)
cart.Activated:Connect(function()action("BuyLook")end)
clear.Activated:Connect(function()action("Blank")end)

photo.Activated:Connect(function()
 pg:SetAttribute("ACP_OpenPhotoNonce",(tonumber(pg:GetAttribute("ACP_OpenPhotoNonce"))or 0)+1)
end)

games.Activated:Connect(function()
 pg:SetAttribute("ACP_OpenGamesNonce",(tonumber(pg:GetAttribute("ACP_OpenGamesNonce"))or 0)+1)
end)

cfg.Activated:Connect(function()
 panel.Visible=not panel.Visible
end)

close.Activated:Connect(function()
 panel.Visible=false
end)

for name,b in pairs(envButtons)do
 b.Activated:Connect(function()
  applyTheme(name)
 end)
end

local function adapt()
 local cam=workspace.CurrentCamera
 local v=cam and cam.ViewportSize or Vector2.new(900,600)
 local touch=UIS.TouchEnabled or v.X<760

 if touch then
  photo.Position=UDim2.new(0,18,1,-178)
  games.Position=UDim2.new(1,-92,1,-174)
  cfg.Position=UDim2.new(1,-20,1,-174)
  panel.Position=UDim2.new(1,-18,1,-228)

  community.Position=UDim2.new(0,16,.44,0)
  loader.Position=UDim2.new(0,16,.53,0)
  looks.Position=UDim2.new(1,-16,.44,0)
  emotes.Position=UDim2.new(1,-16,.53,0)
 else
  photo.Position=UDim2.new(0,20,1,-92)
  games.Position=UDim2.new(1,-94,1,-92)
  cfg.Position=UDim2.new(1,-20,1,-92)
  panel.Position=UDim2.new(1,-18,1,-146)
 end
end

if workspace.CurrentCamera then
 workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(adapt)
end
task.defer(adapt)

task.spawn(function()
 local deadline=os.clock()+35
 while not kit:GetAttribute("BaseReady")and os.clock()<deadline do
  task.wait(.15)
 end
 applyTheme(tostring(pg:GetAttribute("ACP_Environment")or"CYAN"))
end)

print("AVATAR PLAZA V36B: HUD Catalog Layout carregada")
