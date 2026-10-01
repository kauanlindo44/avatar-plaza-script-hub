-- 07G_HUB_UI
-- LocalScript | StarterPlayer > StarterPlayerScripts
-- AVATAR PLAZA V38.1 - HUD limpa, funcional e ligada ao ambiente mint/sky.

local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local Lighting=game:GetService("Lighting")
local GuiService=game:GetService("GuiService")
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
local scale=Instance.new("UIScale")
scale.Parent=root

local C={
 bg=Color3.fromRGB(17,24,25),
 card=Color3.fromRGB(27,37,38),
 line=Color3.fromRGB(82,122,116),
 white=Color3.fromRGB(244,249,248),
 muted=Color3.fromRGB(172,194,190),
 mint=Color3.fromRGB(93,194,148),
 sky=Color3.fromRGB(99,174,198),
 orange=Color3.fromRGB(220,157,88),
 pink=Color3.fromRGB(211,105,151),
 purple=Color3.fromRGB(142,112,190),
 red=Color3.fromRGB(211,77,91)
}

local function round(o,r)
 local c=Instance.new("UICorner")
 c.CornerRadius=UDim.new(0,r or 11)
 c.Parent=o
end
local function stroke(o,col,t)
 local s=Instance.new("UIStroke")
 s.Color=col or C.line
 s.Transparency=t or 0.56
 s.Thickness=1
 s.Parent=o
end
local function textScale()
 local ok,v=pcall(function()return GuiService.PreferredTextSize end)
 if not ok then return 1 end
 local n=tostring(v)
 if n:find("Largest")then return 1.16 end
 if n:find("Larger")then return 1.10 end
 if n:find("Large")then return 1.05 end
 return 1
end
local TS=textScale()
local function label(p,txt,pos,size,fs,col,bold)
 local t=Instance.new("TextLabel")
 t.BackgroundTransparency=1
 t.Position=pos
 t.Size=size
 t.Text=txt
 t.TextColor3=col or C.white
 t.Font=bold==false and Enum.Font.Gotham or Enum.Font.GothamBold
 t.TextSize=math.max(7,math.floor((fs or 9)*TS+0.5))
 t.TextWrapped=false
 t.TextTruncate=Enum.TextTruncate.AtEnd
 t.Parent=p
 return t
end
local function miniIcon(parent,kind,color)
 local box=Instance.new("Frame")
 box.Position=UDim2.fromOffset(8,7)
 box.Size=UDim2.fromOffset(28,28)
 box.BackgroundColor3=Color3.fromRGB(35,47,48)
 box.BorderSizePixel=0
 box.Parent=parent
 round(box,8)
 local function f(x,y,w,h,c,r)
  local a=Instance.new("Frame")
  a.Position=UDim2.fromOffset(x,y)
  a.Size=UDim2.fromOffset(w,h)
  a.BackgroundColor3=c or color
  a.BorderSizePixel=0
  a.Parent=box
  if r then round(a,r)end
 end
 if kind=="community"then
  f(6,7,6,6,color,99);f(16,7,6,6,color,99);f(5,17,18,6,color,3)
 elseif kind=="photo"then
  f(5,9,18,13,color,4);f(10,6,8,4,color,2);f(11,12,6,6,C.bg,99)
 elseif kind=="games"then
  f(5,5,18,18,color,5);f(9,9,3,3,C.bg,99);f(16,9,3,3,C.bg,99)
  f(12,15,3,3,C.bg,99)
 else
  f(6,7,16,2,color,2);f(6,13,16,2,color,2);f(6,19,16,2,color,2)
 end
end
local function action(parent,txt,color,kind)
 local b=Instance.new("TextButton")
 b.Size=UDim2.fromOffset(150,43)
 b.BackgroundColor3=C.bg
 b.BackgroundTransparency=0.02
 b.BorderSizePixel=0
 b.Text=""
 b.AutoButtonColor=true
 b.Parent=parent
 round(b,12)
 stroke(b,nil,0.52)
 local left=8
 if kind then
  miniIcon(b,kind,color)
  left=45
 else
  local bar=Instance.new("Frame")
  bar.Position=UDim2.fromOffset(8,11)
  bar.Size=UDim2.fromOffset(3,21)
  bar.BackgroundColor3=color
  bar.BorderSizePixel=0
  bar.Parent=b
  round(bar,2)
  left=18
 end
 local t=label(
  b,txt,UDim2.fromOffset(left,0),UDim2.new(1,-left-10,1,0),
  8,C.white,true
 )
 t.TextXAlignment=Enum.TextXAlignment.Left
 return b
end
local function rail(anchor,pos,height)
 local f=Instance.new("Frame")
 f.AnchorPoint=anchor
 f.Position=pos
 f.Size=UDim2.fromOffset(156,height)
 f.BackgroundTransparency=1
 f.Parent=root
 local l=Instance.new("UIListLayout")
 l.Padding=UDim.new(0,12)
 l.VerticalAlignment=Enum.VerticalAlignment.Center
 l.Parent=f
 return f
end

local left=rail(Vector2.new(0,0.5),UDim2.new(0,16,0.52,0),190)
local right=rail(Vector2.new(1,0.5),UDim2.new(1,-16,0.52,0),245)
local community=action(left,"COMUNIDADE",C.purple,"community")
local loader=action(left,"CARREGAR",C.sky,nil)
local photo=action(left,"FOTO",C.pink,"photo")
local looks=action(right,"MEUS LOOKS",C.mint,nil)
local emotes=action(right,"EMOTES",C.orange,nil)
local games=action(right,"JOGOS",C.sky,"games")
local cfg=action(right,"CFG",C.muted,"cfg")

local function shop(mode)
 local g=pg:FindFirstChild("AvatarShop08Gui")
 if not g then g=pg:WaitForChild("AvatarShop08Gui",10)end
 local e=g and g:FindFirstChild("OpenRequest")
 if e and e:IsA("BindableEvent")then
  e:Fire(mode)
 end
end
community.Activated:Connect(function()shop("Community")end)
loader.Activated:Connect(function()shop("Loader")end)
looks.Activated:Connect(function()shop("Looks")end)
emotes.Activated:Connect(function()shop("Emotes")end)
photo.Activated:Connect(function()
 local n=tonumber(pg:GetAttribute("ACP_OpenPhotoNonce"))or 0
 pg:SetAttribute("ACP_OpenPhotoNonce",n+1)
end)
games.Activated:Connect(function()
 local n=tonumber(pg:GetAttribute("ACP_OpenGamesNonce"))or 0
 pg:SetAttribute("ACP_OpenGamesNonce",n+1)
end)

local panel=Instance.new("Frame")
panel.AnchorPoint=Vector2.new(1,0.5)
panel.Position=UDim2.new(1,-180,0.52,0)
panel.Size=UDim2.fromOffset(320,352)
panel.BackgroundColor3=C.bg
panel.BorderSizePixel=0
panel.Visible=false
panel.Parent=root
round(panel,15)
stroke(panel,nil,0.36)
label(panel,"CONFIGURACOES",UDim2.fromOffset(16,12),UDim2.new(1,-66,0,24),12)
local close=Instance.new("TextButton")
close.AnchorPoint=Vector2.new(1,0)
close.Position=UDim2.new(1,-10,0,10)
close.Size=UDim2.fromOffset(34,32)
close.BackgroundColor3=C.card
close.BorderSizePixel=0
close.Text="X"
close.TextColor3=C.white
close.Font=Enum.Font.GothamBold
close.TextSize=10
close.Parent=panel
round(close,9)

local body=Instance.new("Frame")
body.Position=UDim2.fromOffset(12,54)
body.Size=UDim2.new(1,-24,1,-66)
body.BackgroundTransparency=1
body.Parent=panel
local list=Instance.new("UIListLayout")
list.Padding=UDim.new(0,8)
list.Parent=body
local function row(title,aText,bText,color)
 local r=Instance.new("Frame")
 r.Size=UDim2.new(1,0,0,48)
 r.BackgroundColor3=C.card
 r.BorderSizePixel=0
 r.Parent=body
 round(r,10)
 local bar=Instance.new("Frame")
 bar.Position=UDim2.fromOffset(8,11)
 bar.Size=UDim2.fromOffset(3,26)
 bar.BackgroundColor3=color
 bar.BorderSizePixel=0
 bar.Parent=r
 round(bar,2)
 local name=label(
  r,title,UDim2.fromOffset(18,0),UDim2.new(0.34,-18,1,0),
  6,C.muted,false
 )
 name.TextXAlignment=Enum.TextXAlignment.Left
 local function mini(txt,x)
  local b=Instance.new("TextButton")
  b.Position=UDim2.new(x,0,0,7)
  b.Size=UDim2.new(0.31,-5,0,34)
  b.BackgroundColor3=Color3.fromRGB(38,50,51)
  b.BorderSizePixel=0
  b.Text=txt
  b.TextColor3=C.white
  b.Font=Enum.Font.GothamBold
  b.TextSize=6
  b.TextWrapped=true
  b.Parent=r
  round(b,8)
  return b
 end
 return mini(aText,0.36),mini(bText,0.68)
end
local field,fov=row("AMBIENTE","MINT","FOV 70",C.mint)
local time,contrast=row("LUZ","HORA 14","CONTRASTE",C.orange)
local saturation,effects=row("VISUAL","SATURACAO","EFEITOS",C.purple)
local hud,preview=row("INTERFACE","HUD NORMAL","PREVIEW",C.sky)
local music,reset=row("AUDIO","MUSICA ON","RESTAURAR",C.pink)

local fieldMode=true
local compact=false
local colors={
 [1]=Color3.fromRGB(116,177,145),
 [2]=Color3.fromRGB(108,169,138),
 [3]=Color3.fromRGB(101,162,131)
}
local function paintField()
 local world=workspace:FindFirstChild("PracaAvatar_V2")
 local g=world and world:FindFirstChild("AvatarFieldGround")
 if not g then return end
 for _,p in ipairs(g:GetChildren())do
  if p:IsA("BasePart")and p.Name:match("^Field_")then
   local tone=tonumber(p:GetAttribute("FieldTone"))or 3
   p.Color=fieldMode and(colors[tone]or colors[3])or Color3.fromRGB(137,150,148)
  end
 end
end
field.Activated:Connect(function()
 fieldMode=not fieldMode
 field.Text=fieldMode and"MINT"or"NEUTRO"
 paintField()
end)
fov.Activated:Connect(function()
 local cam=workspace.CurrentCamera
 if not cam then return end
 cam.FieldOfView=cam.FieldOfView>=85 and 60 or cam.FieldOfView+5
 fov.Text="FOV "..math.floor(cam.FieldOfView)
end)
time.Activated:Connect(function()
 Lighting.ClockTime=Lighting.ClockTime>=20 and 8 or Lighting.ClockTime+2
 time.Text="HORA "..math.floor(Lighting.ClockTime)
end)
contrast.Activated:Connect(function()
 local c=Lighting:FindFirstChild("ACP_V381_Color")
 if not c then return end
 c.Contrast=c.Contrast>=0.15 and 0 or c.Contrast+0.04
 contrast.Text=string.format("CONT. %.2f",c.Contrast)
end)
saturation.Activated:Connect(function()
 local c=Lighting:FindFirstChild("ACP_V381_Color")
 if not c then return end
 c.Saturation=c.Saturation>=0.12 and -0.08 or c.Saturation+0.05
 saturation.Text=string.format("SAT. %.2f",c.Saturation)
end)
effects.Activated:Connect(function()
 local on=pg:GetAttribute("ACP_Effects")~=false
 pg:SetAttribute("ACP_Effects",not on)
 effects.Text=on and"EFEITOS OFF"or"EFEITOS ON"
end)
hud.Activated:Connect(function()
 compact=not compact
 rootScale.Scale=compact and 0.88 or 1
 hud.Text=compact and"HUD COMPACTO"or"HUD NORMAL"
end)
preview.Activated:Connect(function()
 local on=pg:GetAttribute("ACP_PreviewStudio")~=false
 pg:SetAttribute("ACP_PreviewStudio",not on)
 preview.Text=on and"PREVIEW LIMPA"or"PREVIEW STUDIO"
end)
music.Activated:Connect(function()
 local on=pg:GetAttribute("ACP_MusicEnabled")~=false
 pg:SetAttribute("ACP_MusicEnabled",not on)
 music.Text=on and"MUSICA OFF"or"MUSICA ON"
end)
reset.Activated:Connect(function()
 workspace.CurrentCamera.FieldOfView=70
 Lighting.ClockTime=14.2
 local c=Lighting:FindFirstChild("ACP_V381_Color")
 if c then c.Contrast=0.035;c.Saturation=-0.055 end
 fieldMode=true;compact=false;rootScale.Scale=1;paintField()
 field.Text="MINT";fov.Text="FOV 70";time.Text="HORA 14"
 hud.Text="HUD NORMAL";music.Text="MUSICA ON";preview.Text="PREVIEW"
end)
cfg.Activated:Connect(function()panel.Visible=not panel.Visible end)
close.Activated:Connect(function()panel.Visible=false end)

print("AVATAR PLAZA V38.1: HUD mint/sky carregada")
