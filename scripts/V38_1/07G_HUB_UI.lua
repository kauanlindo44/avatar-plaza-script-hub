-- 07G_HUB_UI
-- LocalScript | StarterPlayer > StarterPlayerScripts
-- AVATAR PLAZA V38.1 - HUD principal robusta.
-- Topo sempre existe, mesmo se a Shop falhar; botoes laterais usam o mesmo tema do chao/ceu.
local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local Market=game:GetService("MarketplaceService")
local GuiService=game:GetService("GuiService")
local pl=Players.LocalPlayer
local pg=pl:WaitForChild("PlayerGui")
local kit=Rep:WaitForChild("PracaKit",40)
if not kit then return end
for _,name in ipairs({"LimitedMarketHUD","AvatarShopLauncherGui"})do
 local old=pg:FindFirstChild(name)
 if old then old:Destroy()end
end
local C={
 bg=Color3.fromRGB(18,28,28),
 card=Color3.fromRGB(31,44,42),
 soft=Color3.fromRGB(51,67,64),
 line=Color3.fromRGB(91,119,112),
 white=Color3.fromRGB(244,249,247),
 muted=Color3.fromRGB(174,193,187),
 sage=Color3.fromRGB(112,181,122),
 sky=Color3.fromRGB(113,171,184),
 warm=Color3.fromRGB(204,170,105),
 red=Color3.fromRGB(210,86,92)
}
local function round(o,r)
 local c=Instance.new("UICorner")
 c.CornerRadius=UDim.new(0,r or 10)
 c.Parent=o
end
local function stroke(o,col,t)
 local s=Instance.new("UIStroke")
 s.Color=col or C.line
 s.Transparency=t or .55
 s.Thickness=1
 s.Parent=o
end
local function preferredScale()
 local ok,v=pcall(function()
  return GuiService.PreferredTextSize
 end)
 if not ok then return 1 end
 local n=tostring(v)
 if n:find("Largest")then return 1.16 end
 if n:find("Larger")then return 1.10 end
 if n:find("Large")then return 1.05 end
 return 1
end
local textScale=preferredScale()
local function label(parent,text,pos,size,fs,color,bold)
 local t=Instance.new("TextLabel")
 t.BackgroundTransparency=1
 t.Position=pos
 t.Size=size
 t.Text=text
 t.TextColor3=color or C.white
 t.Font=bold==false and Enum.Font.Gotham or Enum.Font.GothamBold
 t.TextSize=math.max(7,math.floor((fs or 9)*textScale+.5))
 t.TextWrapped=false
 t.TextTruncate=Enum.TextTruncate.AtEnd
 t.Parent=parent
 return t
end
local function button(parent,name,text,pos,size,accent)
 local b=Instance.new("TextButton")
 b.Name=name
 b.Position=pos
 b.Size=size
 b.BackgroundColor3=C.bg
 b.BackgroundTransparency=.04
 b.BorderSizePixel=0
 b.Text=text
 b.TextColor3=C.white
 b.Font=Enum.Font.GothamBold
 b.TextSize=math.max(7,math.floor(9*textScale+.5))
 b.AutoButtonColor=true
 b.Parent=parent
 round(b,11)
 stroke(b,nil,.50)
 local bar=Instance.new("Frame")
 bar.Size=UDim2.fromOffset(3,22)
 bar.Position=UDim2.fromOffset(7,9)
 bar.BackgroundColor3=accent or C.sage
 bar.BorderSizePixel=0
 bar.Parent=b
 round(bar,2)
 return b
end
local function toast(msg)
 local old=pg:FindFirstChild("ACP_HudToast")
 if old then old:Destroy()end
 local g=Instance.new("ScreenGui")
 g.Name="ACP_HudToast"
 g.ResetOnSpawn=false
 g.IgnoreGuiInset=true
 g.DisplayOrder=180
 g.Parent=pg
 local t=label(
  g,
  tostring(msg or""),
  UDim2.new(.5,-170,1,-62),
  UDim2.fromOffset(340,38),
  9,
  C.white
 )
 t.BackgroundTransparency=.05
 t.BackgroundColor3=C.bg
 t.TextXAlignment=Enum.TextXAlignment.Center
 round(t,10)
 stroke(t,C.sage,.35)
 task.delay(2.6,function()
  if g.Parent then g:Destroy()end
 end)
end
local hud=Instance.new("ScreenGui")
hud.Name="LimitedMarketHUD"
hud.ResetOnSpawn=false
hud.IgnoreGuiInset=true
hud.DisplayOrder=55
hud.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
hud.Parent=pg
local root=Instance.new("Frame")
root.Size=UDim2.fromScale(1,1)
root.BackgroundTransparency=1
root.Parent=hud
local launcher=Instance.new("ScreenGui")
launcher.Name="AvatarShopLauncherGui"
launcher.ResetOnSpawn=false
launcher.IgnoreGuiInset=true
launcher.DisplayOrder=84
launcher.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
launcher.Parent=pg
local top=Instance.new("Frame")
top.Name="LauncherBar"
top.Size=UDim2.fromScale(1,1)
top.BackgroundTransparency=1
top.Parent=launcher
local catalog=button(
 top,
 "TopCatalog",
 "CATALOGO",
 UDim2.new(.5,-132,0,16),
 UDim2.fromOffset(126,40),
 C.sage
)
local stores=button(
 top,
 "TopStores",
 "LOJAS",
 UDim2.new(.5,8,0,16),
 UDim2.fromOffset(108,40),
 C.sky
)
local music=button(
 top,
 "TopMusic",
 "MUSICA",
 UDim2.new(1,-144,0,16),
 UDim2.fromOffset(82,40),
 C.sky
)
music.AnchorPoint=Vector2.new(1,0)
local plus=button(
 top,
 "TopPlus",
 "+",
 UDim2.new(1,-14,0,16),
 UDim2.fromOffset(42,40),
 C.sage
)
plus.AnchorPoint=Vector2.new(1,0)
plus.TextSize=18
local function rail(leftSide)
 local f=Instance.new("Frame")
 f.AnchorPoint=Vector2.new(leftSide and 0 or 1,.5)
 f.Position=leftSide and UDim2.new(0,14,.53,0) or UDim2.new(1,-14,.53,0)
 f.Size=UDim2.fromOffset(138,226)
 f.BackgroundTransparency=1
 f.Parent=root
 local l=Instance.new("UIListLayout")
 l.Padding=UDim.new(0,10)
 l.HorizontalAlignment=leftSide and Enum.HorizontalAlignment.Left or Enum.HorizontalAlignment.Right
 l.VerticalAlignment=Enum.VerticalAlignment.Center
 l.Parent=f
 return f
end
local left=rail(true)
local right=rail(false)
local leftScale=Instance.new("UIScale");leftScale.Parent=left
local rightScale=Instance.new("UIScale");rightScale.Parent=right
local community=button(left,"Community","COMUNIDADE",UDim2.new(),UDim2.fromOffset(134,42),C.sky)
local loader=button(left,"Loader","CARREGAR",UDim2.new(),UDim2.fromOffset(134,42),C.sage)
local photo=button(left,"Photo","FOTO",UDim2.new(),UDim2.fromOffset(134,42),C.warm)
local looks=button(right,"Looks","MEUS LOOKS",UDim2.new(),UDim2.fromOffset(134,42),C.sage)
local emotes=button(right,"Emotes","EMOTES",UDim2.new(),UDim2.fromOffset(134,42),C.warm)
local games=button(right,"Games","JOGOS",UDim2.new(),UDim2.fromOffset(134,42),C.sky)
local cfg=button(right,"Cfg","CFG",UDim2.new(),UDim2.fromOffset(134,42),C.muted)
local function fireShop(mode)
 task.spawn(function()
  for _=1,35 do
   local g=pg:FindFirstChild("AvatarShop08Gui")
   local e=g and g:FindFirstChild("OpenRequest")
   if e and e:IsA("BindableEvent")then
    e:Fire(mode)
    return
   end
   task.wait(.2)
  end
  toast("A Shop ainda nao carregou. Confira o Output.")
 end)
end
catalog.Activated:Connect(function()
 fireShop("Catalog")
end)
stores.Activated:Connect(function()
 fireShop("Stores")
end)
community.Activated:Connect(function()
 fireShop("Community")
end)
loader.Activated:Connect(function()
 fireShop("Loader")
end)
looks.Activated:Connect(function()
 fireShop("Looks")
end)
emotes.Activated:Connect(function()
 fireShop("Emotes")
end)
photo.Activated:Connect(function()
 local n=tonumber(pg:GetAttribute("ACP_OpenPhotoNonce"))or 0
 pg:SetAttribute("ACP_OpenPhotoNonce",n+1)
end)
games.Activated:Connect(function()
 local n=tonumber(pg:GetAttribute("ACP_OpenGamesNonce"))or 0
 pg:SetAttribute("ACP_OpenGamesNonce",n+1)
end)
plus.Activated:Connect(function()
 local passId=tonumber(kit:GetAttribute("PlusGamePassId"))or 0
 if passId<=0 then
  toast("PLUS ainda nao esta configurado.")
  return
 end
 local ok=pcall(function()
  Market:PromptGamePassPurchase(pl,passId)
 end)
 if not ok then
  toast("Nao consegui abrir o PLUS.")
 end
end)
local panel=Instance.new("Frame")
panel.AnchorPoint=Vector2.new(1,.5)
panel.Position=UDim2.new(1,-160,.53,0)
panel.Size=UDim2.fromOffset(300,270)
panel.BackgroundColor3=Color3.fromRGB(22,34,33)
panel.BorderSizePixel=0
panel.Visible=false
panel.Parent=root
round(panel,14)
stroke(panel,nil,.35)
label(
 panel,
 "CONFIGURACOES",
 UDim2.fromOffset(14,12),
 UDim2.new(1,-60,0,24),
 12,
 C.white
)
local close=button(
 panel,
 "CloseCfg",
 "X",
 UDim2.new(1,-48,0,9),
 UDim2.fromOffset(34,32),
 C.red
)
local body=Instance.new("Frame")
body.Position=UDim2.fromOffset(12,54)
body.Size=UDim2.new(1,-24,1,-66)
body.BackgroundTransparency=1
body.Parent=panel
local list=Instance.new("UIListLayout")
list.Padding=UDim.new(0,8)
list.Parent=body
local function cfgButton(name,text,accent)
 return button(
  body,
  name,
  text,
  UDim2.new(),
  UDim2.new(1,0,0,40),
  accent
 )
end
local fov=cfgButton("Fov","FOV 70",C.sky)
local compact=cfgButton("HudSize","HUD NORMAL",C.sage)
local musicToggle=cfgButton("MusicToggle","MUSICA ON",C.warm)
local reset=cfgButton("Reset","RESTAURAR",C.muted)
local compactOn=false
fov.Activated:Connect(function()
 local cam=workspace.CurrentCamera
 if not cam then return end
 cam.FieldOfView=cam.FieldOfView>=85 and 60 or cam.FieldOfView+5
 fov.Text="FOV "..math.floor(cam.FieldOfView)
end)
compact.Activated:Connect(function()
 compactOn=not compactOn
 local scale=compactOn and .88 or 1
 leftScale.Scale=scale
 rightScale.Scale=scale
 compact.Text=compactOn and"HUD COMPACTO"or"HUD NORMAL"
end)
musicToggle.Activated:Connect(function()
 local on=pg:GetAttribute("ACP_MusicEnabled")~=false
 on=not on
 pg:SetAttribute("ACP_MusicEnabled",on)
 musicToggle.Text=on and"MUSICA ON"or"MUSICA OFF"
end)
reset.Activated:Connect(function()
 local cam=workspace.CurrentCamera
 if cam then cam.FieldOfView=70 end
 compactOn=false
 leftScale.Scale=1
 rightScale.Scale=1
 fov.Text="FOV 70"
 compact.Text="HUD NORMAL"
 musicToggle.Text=pg:GetAttribute("ACP_MusicEnabled")==false and"MUSICA OFF"or"MUSICA ON"
end)
cfg.Activated:Connect(function()
 panel.Visible=not panel.Visible
end)
close.Activated:Connect(function()
 panel.Visible=false
end)
local function adapt()
 local cam=workspace.CurrentCamera
 local vp=cam and cam.ViewportSize or Vector2.new(900,600)
 local edge=vp.X<760 and 7 or 14
 left.Position=UDim2.new(0,edge,.53,0)
 right.Position=UDim2.new(1,-edge,.53,0)
 panel.Position=UDim2.new(1,-edge-146,.53,0)
 if vp.X<720 then
  catalog.Position=UDim2.new(.5,-110,0,12)
  catalog.Size=UDim2.fromOffset(104,36)
  stores.Position=UDim2.new(.5,6,0,12)
  stores.Size=UDim2.fromOffset(90,36)
 else
  catalog.Position=UDim2.new(.5,-132,0,16)
  catalog.Size=UDim2.fromOffset(126,40)
  stores.Position=UDim2.new(.5,8,0,16)
  stores.Size=UDim2.fromOffset(108,40)
 end
end
if workspace.CurrentCamera then
 workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(adapt)
end
task.defer(adapt)
print("AVATAR PLAZA V38.1: HUD principal carregada")
