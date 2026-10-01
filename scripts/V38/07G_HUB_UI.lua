-- 07G_HUB_UI
-- LocalScript | StarterPlayer > StarterPlayerScripts
-- AVATAR PLAZA V38 - HUD refinada: leve, hierárquica, responsiva e sem emojis obrigatórios.
-- As ações ficam nas laterais, o topo continua reservado a CATÁLOGO/LOJAS/MÚSICA/PLUS do 09A.

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
gui.Name="LimitedMarketHUD";gui.ResetOnSpawn=false;gui.IgnoreGuiInset=true;gui.DisplayOrder=55;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=pg
local root=Instance.new("Frame")
root.Size=UDim2.fromScale(1,1);root.BackgroundTransparency=1;root.Parent=gui
local rootScale=Instance.new("UIScale");rootScale.Parent=root

local C={bg=Color3.fromRGB(18,19,22),card=Color3.fromRGB(31,33,38),line=Color3.fromRGB(72,75,84),white=Color3.fromRGB(248,249,251),muted=Color3.fromRGB(176,180,187),green=Color3.fromRGB(76,210,123),blue=Color3.fromRGB(91,150,220),purple=Color3.fromRGB(157,111,213),orange=Color3.fromRGB(228,154,80),pink=Color3.fromRGB(221,104,160),red=Color3.fromRGB(220,78,92)}
local function round(o,r)local x=Instance.new("UICorner");x.CornerRadius=UDim.new(0,r or 11);x.Parent=o;return x end
local function stroke(o,c,t)local x=Instance.new("UIStroke");x.Color=c or C.line;x.Transparency=t or .58;x.Thickness=1;x.Parent=o;return x end
local function preferredScale()
 local ok,v=pcall(function()return GuiService.PreferredTextSize end)
 if not ok then return 1 end
 local n=tostring(v)
 if n:find("Largest")then return 1.18 elseif n:find("Larger")then return 1.12 elseif n:find("Large")then return 1.06 end
 return 1
end
local textScale=preferredScale()
local function label(p,txt,pos,size,fs,col,bold)
 local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Text=txt;t.Position=pos;t.Size=size;t.TextColor3=col or C.white;t.Font=bold==false and Enum.Font.Gotham or Enum.Font.GothamBold;t.TextSize=math.max(6,math.floor((fs or 8)*textScale+.5));t.TextWrapped=true;t.Parent=p;return t
end
local function icon(parent,kind,color)
 local box=Instance.new("Frame");box.Name="Icon";box.Position=UDim2.fromOffset(7,6);box.Size=UDim2.fromOffset(30,30);box.BackgroundColor3=Color3.fromRGB(39,41,47);box.BorderSizePixel=0;box.Parent=parent;round(box,9)
 local function f(pos,size,rot,c,r)local x=Instance.new("Frame");x.Position=pos;x.Size=size;x.Rotation=rot or 0;x.BackgroundColor3=c or color;x.BorderSizePixel=0;x.Parent=box;if r then round(x,r)end;return x end
 if kind=="community"then
  f(UDim2.fromOffset(6,6),UDim2.fromOffset(8,8),0,color,99);f(UDim2.fromOffset(16,7),UDim2.fromOffset(7,7),0,color,99);f(UDim2.fromOffset(4,17),UDim2.fromOffset(20,7),0,color,4)
 elseif kind=="load"then
  f(UDim2.fromOffset(13,5),UDim2.fromOffset(4,13));f(UDim2.fromOffset(9,13),UDim2.fromOffset(12,4));f(UDim2.fromOffset(7,21),UDim2.fromOffset(16,3),0,color,2)
 elseif kind=="photo"then
  f(UDim2.fromOffset(5,9),UDim2.fromOffset(20,14),0,color,4);f(UDim2.fromOffset(11,5),UDim2.fromOffset(8,5),0,color,2);f(UDim2.fromOffset(11,12),UDim2.fromOffset(8,8),0,C.bg,99)
 elseif kind=="looks"then
  f(UDim2.fromOffset(7,6),UDim2.fromOffset(16,18),0,color,5);f(UDim2.fromOffset(10,10),UDim2.fromOffset(10,10),0,C.bg,4)
 elseif kind=="emote"then
  f(UDim2.fromOffset(5,5),UDim2.fromOffset(20,20),0,color,99);f(UDim2.fromOffset(10,11),UDim2.fromOffset(3,3),0,C.bg,99);f(UDim2.fromOffset(18,11),UDim2.fromOffset(3,3),0,C.bg,99);f(UDim2.fromOffset(11,18),UDim2.fromOffset(9,2),0,C.bg,2)
 elseif kind=="games"then
  f(UDim2.fromOffset(5,5),UDim2.fromOffset(20,20),0,color,5);for _,v in ipairs({{9,9},{18,9},{13,14},{9,19},{18,19}})do f(UDim2.fromOffset(v[1],v[2]),UDim2.fromOffset(3,3),0,C.bg,99)end
 else
  for i=0,2 do local y=7+i*7;f(UDim2.fromOffset(6,y),UDim2.fromOffset(18,2),0,color,2);f(UDim2.fromOffset(i==1 and 9 or 17,y-2),UDim2.fromOffset(5,5),0,C.bg,99)end
 end
end
local function action(parent,text,kind,color)
 local b=Instance.new("TextButton");b.Size=UDim2.fromOffset(132,43);b.BackgroundColor3=C.bg;b.BackgroundTransparency=.02;b.BorderSizePixel=0;b.Text="";b.AutoButtonColor=true;b.Parent=parent;round(b,12);stroke(b,nil,.54);icon(b,kind,color)
 local t=label(b,text,UDim2.fromOffset(44,0),UDim2.new(1,-51,1,0),8,C.white);t.TextXAlignment=Enum.TextXAlignment.Left;t.TextTruncate=Enum.TextTruncate.AtEnd;t.TextWrapped=false
 return b
end
local function rail(anchor,pos,align)
 local f=Instance.new("Frame");f.AnchorPoint=anchor;f.Position=pos;f.Size=UDim2.fromOffset(142,230);f.BackgroundTransparency=1;f.Parent=root
 local l=Instance.new("UIListLayout");l.Padding=UDim.new(0,12);l.HorizontalAlignment=align;l.VerticalAlignment=Enum.VerticalAlignment.Center;l.Parent=f
 return f
end

local left=rail(Vector2.new(0,.5),UDim2.new(0,16,.51,0),Enum.HorizontalAlignment.Left)
local right=rail(Vector2.new(1,.5),UDim2.new(1,-16,.51,0),Enum.HorizontalAlignment.Right)
local community=action(left,"COMUNIDADE","community",C.purple)
local loader=action(left,"CARREGAR","load",C.blue)
local photo=action(left,"FOTO","photo",C.pink)
local looks=action(right,"MEUS LOOKS","looks",C.green)
local emotes=action(right,"EMOTES","emote",C.orange)
local games=action(right,"JOGOS","games",C.blue)
local cfg=action(right,"CFG","cfg",C.muted)

local function shop(mode)
 local g=pg:FindFirstChild("AvatarShop08Gui")or pg:WaitForChild("AvatarShop08Gui",5)
 local e=g and g:FindFirstChild("OpenRequest")
 if e and e:IsA("BindableEvent")then e:Fire(mode)end
end
community.Activated:Connect(function()shop("Community")end)
loader.Activated:Connect(function()shop("Loader")end)
looks.Activated:Connect(function()shop("Looks")end)
emotes.Activated:Connect(function()shop("Emotes")end)
photo.Activated:Connect(function()pg:SetAttribute("ACP_OpenPhotoNonce",(tonumber(pg:GetAttribute("ACP_OpenPhotoNonce"))or 0)+1)end)
games.Activated:Connect(function()pg:SetAttribute("ACP_OpenGamesNonce",(tonumber(pg:GetAttribute("ACP_OpenGamesNonce"))or 0)+1)end)

local panel=Instance.new("Frame")
panel.AnchorPoint=Vector2.new(1,.5);panel.Position=UDim2.new(1,-162,.51,0);panel.Size=UDim2.fromOffset(326,370);panel.BackgroundColor3=Color3.fromRGB(23,24,28);panel.BorderSizePixel=0;panel.Visible=false;panel.Parent=root;round(panel,16);stroke(panel,nil,.38)
label(panel,"CONFIGURAÇÕES",UDim2.fromOffset(15,12),UDim2.new(1,-58,0,24),12,C.white)
label(panel,"Ambiente, câmera e interface",UDim2.fromOffset(15,35),UDim2.new(1,-58,0,18),6,C.muted,false)
local close=Instance.new("TextButton");close.AnchorPoint=Vector2.new(1,0);close.Position=UDim2.new(1,-10,0,10);close.Size=UDim2.fromOffset(34,32);close.BackgroundColor3=C.card;close.BorderSizePixel=0;close.Text="X";close.TextColor3=C.white;close.Font=Enum.Font.GothamBold;close.TextSize=10;close.Parent=panel;round(close,9)
local body=Instance.new("Frame");body.Position=UDim2.fromOffset(12,62);body.Size=UDim2.new(1,-24,1,-74);body.BackgroundTransparency=1;body.Parent=panel
local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,8);layout.Parent=body
local function row(title,aText,bText,color)
 local r=Instance.new("Frame");r.Size=UDim2.new(1,0,0,48);r.BackgroundColor3=C.card;r.BorderSizePixel=0;r.Parent=body;round(r,10)
 local bar=Instance.new("Frame");bar.Size=UDim2.fromOffset(3,26);bar.Position=UDim2.fromOffset(8,11);bar.BackgroundColor3=color;r.BorderSizePixel=0;bar.Parent=r;round(bar,2)
 local name=label(r,title,UDim2.fromOffset(18,3),UDim2.new(.36,-18,1,-6),6,C.muted);name.TextXAlignment=Enum.TextXAlignment.Left
 local function mini(txt,x)
  local b=Instance.new("TextButton");b.Position=UDim2.new(x,0,0,7);b.Size=UDim2.new(.30,-5,0,34);b.BackgroundColor3=Color3.fromRGB(43,45,51);b.BorderSizePixel=0;b.Text=txt;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=6;b.TextWrapped=true;b.AutoButtonColor=true;b.Parent=r;round(b,8);return b
 end
 return mini(aText,.38),mini(bText,.69)
end
local field,fov=row("AMBIENTE / CÂMERA","FIELD","FOV 70",C.green)
local time,contrast=row("ILUMINAÇÃO","HORA 14","CONTRASTE",C.orange)
local saturation,effects=row("VISUAL","SATURAÇÃO","EFEITOS",C.purple)
local hud,preview=row("INTERFACE","HUD NORMAL","PREVIEW",C.blue)
local music,reset=row("ÁUDIO / RESET","MÚSICA ON","RESTAURAR",C.pink)

local fieldMode,compact=true,false
local fieldColors={[1]=Color3.fromRGB(117,185,112),[2]=Color3.fromRGB(111,179,107),[3]=Color3.fromRGB(105,173,102)}
local function paintField()
 local world=workspace:FindFirstChild("PracaAvatar_V2");local g=world and world:FindFirstChild("AvatarFieldGround");if not g then return end
 for _,p in ipairs(g:GetChildren())do if p:IsA("BasePart")and p.Name:match("^Field_")then local tone=tonumber(p:GetAttribute("FieldTone"))or 3;p.Color=fieldMode and(fieldColors[tone]or fieldColors[3])or Color3.fromRGB(145,148,151)end end
end
field.Activated:Connect(function()fieldMode=not fieldMode;pg:SetAttribute("ACP_Environment",fieldMode and"FIELD"or"NEUTRAL");field.Text=fieldMode and"FIELD"or"NEUTRO";paintField()end)
fov.Activated:Connect(function()local cam=workspace.CurrentCamera;if not cam then return end;cam.FieldOfView=cam.FieldOfView>=85 and 60 or cam.FieldOfView+5;fov.Text="FOV "..math.floor(cam.FieldOfView)end)
time.Activated:Connect(function()Lighting.ClockTime=Lighting.ClockTime>=20 and 8 or Lighting.ClockTime+2;time.Text="HORA "..math.floor(Lighting.ClockTime)end)
contrast.Activated:Connect(function()local c=Lighting:FindFirstChild("ACP_V38_Color");if c then c.Contrast=c.Contrast>=.16 and 0 or c.Contrast+.04;contrast.Text=string.format("CONT. %.2f",c.Contrast)end end)
saturation.Activated:Connect(function()local c=Lighting:FindFirstChild("ACP_V38_Color");if c then c.Saturation=c.Saturation>=.15 and -.10 or c.Saturation+.05;saturation.Text=string.format("SAT. %.2f",c.Saturation)end end)
effects.Activated:Connect(function()local a=Lighting:FindFirstChild("ACP_V38_Atmosphere");if not a then return end;local normal=a.Density<.08;a.Density=normal and .13 or .04;a.Haze=normal and .22 or .05;effects.Text=normal and"EFEITOS N"or"EFEITOS L"end)
hud.Activated:Connect(function()compact=not compact;rootScale.Scale=compact and .88 or 1;hud.Text=compact and"HUD COMPACTO"or"HUD NORMAL"end)
preview.Activated:Connect(function()local on=pg:GetAttribute("ACP_PreviewStudio")~=false;on=not on;pg:SetAttribute("ACP_PreviewStudio",on);preview.Text=on and"PREVIEW ST"or"PREVIEW CLEAN"end)
music.Activated:Connect(function()local on=pg:GetAttribute("ACP_MusicEnabled")~=false;on=not on;pg:SetAttribute("ACP_MusicEnabled",on);music.Text=on and"MÚSICA ON"or"MÚSICA OFF"end)
reset.Activated:Connect(function()local cam=workspace.CurrentCamera;if cam then cam.FieldOfView=70 end;Lighting.ClockTime=13.8;local c=Lighting:FindFirstChild("ACP_V38_Color");if c then c.Contrast=.035;c.Saturation=-.025 end;local a=Lighting:FindFirstChild("ACP_V38_Atmosphere");if a then a.Density=.13;a.Haze=.22 end;fieldMode=true;compact=false;rootScale.Scale=1;pg:SetAttribute("ACP_Environment","FIELD");pg:SetAttribute("ACP_PreviewStudio",true);field.Text="FIELD";fov.Text="FOV 70";time.Text="HORA 14";contrast.Text="CONTRASTE";saturation.Text="SATURAÇÃO";effects.Text="EFEITOS";hud.Text="HUD NORMAL";preview.Text="PREVIEW";paintField()end)
cfg.Activated:Connect(function()panel.Visible=not panel.Visible end);close.Activated:Connect(function()panel.Visible=false end)

local function adapt()
 local cam=workspace.CurrentCamera;local vp=cam and cam.ViewportSize or Vector2.new(900,600)
 local s=math.min(1,math.max(.78,math.min(vp.X/850,vp.Y/500)));rootScale.Scale=compact and s*.88 or s
 local edge=vp.X<760 and 8 or 16;left.Position=UDim2.new(0,edge,.51,0);right.Position=UDim2.new(1,-edge,.51,0);panel.Position=UDim2.new(1,-edge-146,.51,0)
end
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(adapt)end
pg:SetAttribute("ACP_PreviewStudio",true);task.defer(adapt)
print("AVATAR PLAZA V38: HUD refinada carregada")
