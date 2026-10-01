-- 07G_HUB_UI
-- LocalScript | StarterPlayer > StarterPlayerScripts
-- AVATAR PLAZA V37 - HUD mais leve + CFG útil de ambiente/câmera/HUD/áudio.

local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local Lighting=game:GetService("Lighting")
local UIS=game:GetService("UserInputService")
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
local rootScale=Instance.new("UIScale");rootScale.Parent=root

local C={black=Color3.fromRGB(20,20,23),soft=Color3.fromRGB(54,56,63),line=Color3.fromRGB(80,82,91),white=Color3.fromRGB(248,249,251),muted=Color3.fromRGB(182,184,190)}
local function round(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 11);c.Parent=o end
local function stroke(o,t)local s=Instance.new("UIStroke");s.Color=C.line;s.Transparency=t or .6;s.Thickness=1;s.Parent=o end
local function fit(o)o.TextScaled=false;o.TextWrapped=true end

local function button(text,anchor,pos)
 local b=Instance.new("TextButton")
 b.Text=text;b.AnchorPoint=anchor;b.Position=pos;b.Size=UDim2.fromOffset(112,40)
 b.BackgroundColor3=C.black;b.BackgroundTransparency=.05;b.BorderSizePixel=0
 b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=8;b.AutoButtonColor=true;b.Parent=root
 round(b,12);stroke(b,.68);fit(b,8,17)
 local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,9);pad.PaddingRight=UDim.new(0,9);pad.Parent=b
 return b
end

local community=button("COMUNIDADE",Vector2.new(0,.5),UDim2.new(0,18,.34,0))
local loader=button("CARREGAR",Vector2.new(0,.5),UDim2.new(0,18,.43,0))
local photo=button("FOTO",Vector2.new(0,.5),UDim2.new(0,18,.52,0))
local looks=button("MEUS LOOKS",Vector2.new(1,.5),UDim2.new(1,-18,.34,0))
local emotes=button("EMOTES",Vector2.new(1,.5),UDim2.new(1,-18,.43,0))
local games=button("JOGOS",Vector2.new(1,.5),UDim2.new(1,-18,.56,0))
local cfg=button("CFG",Vector2.new(1,.5),UDim2.new(1,-18,.65,0))

local function shopGui()return pg:FindFirstChild("AvatarShop08Gui")or pg:WaitForChild("AvatarShop08Gui",5)end
local function shop(mode)local g=shopGui();local e=g and g:FindFirstChild("OpenRequest");if e and e:IsA("BindableEvent")then e:Fire(mode)end end
community.Activated:Connect(function()shop("Community")end)
loader.Activated:Connect(function()shop("Loader")end)
looks.Activated:Connect(function()shop("Looks")end)
emotes.Activated:Connect(function()shop("Emotes")end)
photo.Activated:Connect(function()pg:SetAttribute("ACP_OpenPhotoNonce",(tonumber(pg:GetAttribute("ACP_OpenPhotoNonce"))or 0)+1)end)
games.Activated:Connect(function()pg:SetAttribute("ACP_OpenGamesNonce",(tonumber(pg:GetAttribute("ACP_OpenGamesNonce"))or 0)+1)end)

local panel=Instance.new("Frame")
panel.AnchorPoint=Vector2.new(1,.5);panel.Position=UDim2.new(1,-144,.58,0);panel.Size=UDim2.fromOffset(306,356)
panel.BackgroundColor3=Color3.fromRGB(28,29,34);panel.BorderSizePixel=0;panel.Visible=false;panel.Parent=root
round(panel,16);stroke(panel,.45)
local function label(text,pos,size,fs,col)
 local l=Instance.new("TextLabel");l.Text=text;l.Position=pos;l.Size=size;l.BackgroundTransparency=1;l.TextColor3=col or C.white;l.Font=Enum.Font.GothamBold;l.TextSize=fs or 9;l.TextXAlignment=Enum.TextXAlignment.Left;l.Parent=panel;return l
end
local function small(text,pos,size,color)
 local b=Instance.new("TextButton");b.Text=text;b.Position=pos;b.Size=size;b.BackgroundColor3=color or C.soft;b.BorderSizePixel=0;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=7;b.Parent=panel;round(b,9);fit(b,7,14);return b
end
label("CONFIGURAÇÕES",UDim2.fromOffset(14,9),UDim2.new(1,-28,0,24),12)
label("Ambiente • câmera • HUD • áudio • desempenho",UDim2.fromOffset(14,32),UDim2.new(1,-28,0,17),6,C.muted)
label("AMBIENTE",UDim2.fromOffset(14,56),UDim2.fromOffset(120,16),7,C.muted)

local themes={{"ORIGINAL",Color3.fromRGB(102,194,96)},{"CYAN",Color3.fromRGB(73,205,222)},{"LILAC",Color3.fromRGB(169,126,225)},{"PINK",Color3.fromRGB(225,112,177)},{"SUNSET",Color3.fromRGB(237,152,74)},{"BLUE",Color3.fromRGB(83,141,226)}}
local function applyTheme(name,color)
 pg:SetAttribute("ACP_Environment",name)
 local world=workspace:FindFirstChild("PracaAvatar_V2");local f=world and world:FindFirstChild("AccentThemeParts")
 if f then for _,p in ipairs(f:GetDescendants())do if p:IsA("BasePart")and p:GetAttribute("Themeable")then p.Color=color end end end
 local cc=Lighting:FindFirstChild("ACP_V37_Color");if cc then cc.TintColor=color:Lerp(Color3.fromRGB(244,246,248),.86)end
end
for i,v in ipairs(themes)do local c=(i-1)%3;local r=math.floor((i-1)/3);local b=small(v[1],UDim2.fromOffset(14+c*94,76+r*36),UDim2.fromOffset(86,30),v[2]);b.Activated:Connect(function()applyTheme(v[1],v[2])end)end

label("CÂMERA / LUZ",UDim2.fromOffset(14,151),UDim2.fromOffset(140,16),7,C.muted)
local fovM=small("FOV -",UDim2.fromOffset(14,171),UDim2.fromOffset(64,30),Color3.fromRGB(72,92,128))
local fovP=small("FOV +",UDim2.fromOffset(82,171),UDim2.fromOffset(64,30),Color3.fromRGB(72,92,128))
local timeM=small("HORA -",UDim2.fromOffset(154,171),UDim2.fromOffset(64,30),Color3.fromRGB(104,85,135))
local timeP=small("HORA +",UDim2.fromOffset(222,171),UDim2.fromOffset(64,30),Color3.fromRGB(104,85,135))
local conM=small("CONTR -",UDim2.fromOffset(14,205),UDim2.fromOffset(64,30),Color3.fromRGB(104,85,135))
local conP=small("CONTR +",UDim2.fromOffset(82,205),UDim2.fromOffset(64,30),Color3.fromRGB(104,85,135))
local satM=small("SAT -",UDim2.fromOffset(154,205),UDim2.fromOffset(64,30),Color3.fromRGB(72,92,128))
local satP=small("SAT +",UDim2.fromOffset(222,205),UDim2.fromOffset(64,30),Color3.fromRGB(72,92,128))

local music=small("MÚSICA: ON",UDim2.fromOffset(14,247),UDim2.fromOffset(88,32),Color3.fromRGB(63,150,102))
local fx=small("EFEITOS",UDim2.fromOffset(108,247),UDim2.fromOffset(82,32),Color3.fromRGB(91,112,164))
local hud=small("HUD",UDim2.fromOffset(196,247),UDim2.fromOffset(42,32),Color3.fromRGB(160,95,159))
local preview=small("PREVIEW",UDim2.fromOffset(244,247),UDim2.fromOffset(48,32),Color3.fromRGB(184,118,63))
local reset=small("RESTAURAR",UDim2.fromOffset(14,287),UDim2.fromOffset(132,32),Color3.fromRGB(89,91,101))
local close=small("FECHAR",UDim2.fromOffset(154,287),UDim2.fromOffset(138,32),Color3.fromRGB(66,68,76))
local info=label("FOV 70 • 14h • Contraste 0.04 • Saturação 0.04",UDim2.fromOffset(14,327),UDim2.new(1,-28,0,18),6,C.muted)

local hudCompact=false;local fxNormal=true;local previewStudio=true
local function updateInfo()
 local cam=workspace.CurrentCamera;local cc=Lighting:FindFirstChild("ACP_V37_Color")
 info.Text=string.format("FOV %d • %02dh • Contraste %.2f • Saturação %.2f",math.floor(cam and cam.FieldOfView or 70),math.floor(Lighting.ClockTime),cc and cc.Contrast or 0,cc and cc.Saturation or 0)
end
fovM.Activated:Connect(function()local c=workspace.CurrentCamera;if c then c.FieldOfView=math.clamp(c.FieldOfView-5,45,90)end;updateInfo()end)
fovP.Activated:Connect(function()local c=workspace.CurrentCamera;if c then c.FieldOfView=math.clamp(c.FieldOfView+5,45,90)end;updateInfo()end)
timeM.Activated:Connect(function()Lighting.ClockTime=(Lighting.ClockTime-1)%24;updateInfo()end)
timeP.Activated:Connect(function()Lighting.ClockTime=(Lighting.ClockTime+1)%24;updateInfo()end)
local function nudge(prop,d)local cc=Lighting:FindFirstChild("ACP_V37_Color");if cc then cc[prop]=math.clamp(cc[prop]+d,-.4,.4)end;updateInfo()end
conM.Activated:Connect(function()nudge("Contrast",-.03)end);conP.Activated:Connect(function()nudge("Contrast",.03)end)
satM.Activated:Connect(function()nudge("Saturation",-.03)end);satP.Activated:Connect(function()nudge("Saturation",.03)end)
music.Activated:Connect(function()local on=pg:GetAttribute("ACP_MusicEnabled")~=false;on=not on;pg:SetAttribute("ACP_MusicEnabled",on);music.Text=on and"MÚSICA: ON"or"MÚSICA: OFF";music.BackgroundColor3=on and Color3.fromRGB(63,150,102)or Color3.fromRGB(112,70,74)end)
fx.Activated:Connect(function()fxNormal=not fxNormal;local a=Lighting:FindFirstChild("ACP_V37_Atmosphere");if a then a.Density=fxNormal and .14 or .035;a.Haze=fxNormal and .28 or .06 end;fx.Text=fxNormal and"EFEITOS"or"FX LEVE"end)
hud.Activated:Connect(function()hudCompact=not hudCompact;rootScale.Scale=hudCompact and .86 or 1;hud.Text=hudCompact and"HUD -"or"HUD"end)
preview.Activated:Connect(function()previewStudio=not previewStudio;pg:SetAttribute("ACP_PreviewStudio",previewStudio);preview.Text=previewStudio and"PREVIEW"or"LIMPO"end)
reset.Activated:Connect(function()local c=workspace.CurrentCamera;if c then c.FieldOfView=70 end;Lighting.ClockTime=14;local cc=Lighting:FindFirstChild("ACP_V37_Color");if cc then cc.Contrast=.04;cc.Saturation=.04 end;rootScale.Scale=1;hudCompact=false;previewStudio=true;pg:SetAttribute("ACP_PreviewStudio",true);applyTheme("ORIGINAL",themes[1][2]);updateInfo()end)
cfg.Activated:Connect(function()panel.Visible=not panel.Visible;updateInfo()end);close.Activated:Connect(function()panel.Visible=false end)

local all={community,loader,photo,looks,emotes,games,cfg}
local function adapt()
 local cam=workspace.CurrentCamera;local vp=cam and cam.ViewportSize or Vector2.new(900,600);local compact=UIS.TouchEnabled or vp.X<780
 local pref=GuiService.PreferredTextSize.Value;local grow=math.max(0,pref-1)
 local w=(compact and 96 or 112)+grow*10;local h=(compact and 36 or 40)+grow*4;for _,b in ipairs(all)do b.Size=UDim2.fromOffset(w,h)end
 local lx=compact and 10 or 18;local rx=compact and -10 or -18
 community.Position=UDim2.new(0,lx,.33,0);loader.Position=UDim2.new(0,lx,.42,0);photo.Position=UDim2.new(0,lx,.51,0)
 looks.Position=UDim2.new(1,rx,.33,0);emotes.Position=UDim2.new(1,rx,.42,0);games.Position=UDim2.new(1,rx,.56,0);cfg.Position=UDim2.new(1,rx,.65,0)
 panel.Position=UDim2.new(1,rx-w-14,.58,0)
end
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(adapt)end
GuiService:GetPropertyChangedSignal("PreferredTextSize"):Connect(adapt)
task.defer(adapt);pg:SetAttribute("ACP_PreviewStudio",true);applyTheme("ORIGINAL",themes[1][2]);updateInfo()
print("AVATAR PLAZA V37: HUD/CFG carregada")
