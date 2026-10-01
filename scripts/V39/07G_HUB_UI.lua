-- 07G_HUB_UI | LocalScript | StarterPlayer > StarterPlayerScripts
-- AVATAR PLAZA V39: HUD legivel, menu compacto e launcher independente.
local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local Market=game:GetService("MarketplaceService")
local GuiService=game:GetService("GuiService")
local pl=Players.LocalPlayer
local pg=pl:WaitForChild("PlayerGui")
local kit=Rep:WaitForChild("PracaKit",40)
if not kit then return end
for _,name in ipairs({"LimitedMarketHUD","AvatarShopLauncherGui"})do
 local old=pg:FindFirstChild(name);if old then old:Destroy()end
end
local C={bg=Color3.fromRGB(18,28,28),card=Color3.fromRGB(31,44,42),soft=Color3.fromRGB(51,67,64),
 white=Color3.fromRGB(244,249,247),muted=Color3.fromRGB(174,193,187),sage=Color3.fromRGB(112,181,122),
 sky=Color3.fromRGB(113,171,184),warm=Color3.fromRGB(204,170,105),red=Color3.fromRGB(210,86,92)}
local function round(o,r)
 local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o
end
local function border(o)
 local s=Instance.new("UIStroke");s.Color=C.muted;s.Transparency=.78;s.Parent=o
end
local function textScale()
 local ok,v=pcall(function()return GuiService.PreferredTextSize end)
 local n=ok and tostring(v)or""
 return n:find("Largest")and 1.16 or n:find("Larger")and 1.10 or n:find("Large")and 1.05 or 1
end
local function label(parent,text,pos,size)
 local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Position=pos;t.Size=size
 t.Text=text;t.TextColor3=C.white;t.Font=Enum.Font.GothamBold;t.TextSize=14*textScale()
 t.TextTruncate=Enum.TextTruncate.AtEnd;t.Parent=parent;return t
end
local function button(parent,name,text,accent)
 local b=Instance.new("TextButton");b.Name=name;b.Size=UDim2.fromOffset(124,44)
 b.BackgroundColor3=C.bg;b.BackgroundTransparency=.04;b.BorderSizePixel=0
 b.Text=text;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=12*textScale()
 b.TextTruncate=Enum.TextTruncate.AtEnd;b.Parent=parent;round(b);border(b)
 local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,14);pad.PaddingRight=UDim.new(0,8);pad.Parent=b
 local bar=Instance.new("Frame");bar.Name="Accent";bar.Size=UDim2.fromOffset(3,22)
 bar.Position=UDim2.new(0,-7,.5,-11);bar.BackgroundColor3=accent or C.sage;bar.BorderSizePixel=0;bar.Parent=b;round(bar,2)
 return b
end
local function screen(name,order)
 local g=Instance.new("ScreenGui");g.Name=name;g.ResetOnSpawn=false;g.IgnoreGuiInset=false
 g.DisplayOrder=order;g.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;g.Parent=pg;return g
end
local hud=screen("LimitedMarketHUD",55)
local root=Instance.new("Frame");root.Name="HudRoot";root.Size=UDim2.fromScale(1,1);root.BackgroundTransparency=1;root.Parent=hud
local launcher=screen("AvatarShopLauncherGui",84)
local top=Instance.new("Frame");top.Size=UDim2.fromScale(1,1);top.BackgroundTransparency=1;top.Parent=launcher
local catalog=button(top,"TopCatalog","CATÁLOGO",C.sage)
local stores=button(top,"TopStores","LOJAS",C.sky)
local music=button(top,"TopMusic","MÚSICA",C.sky)
local plus=button(top,"TopPlus","+",C.sage);plus.TextSize=22
local menu=button(top,"Menu","MENU",C.muted)
local drawer=Instance.new("Frame");drawer.Name="ActionMenu";drawer.Size=UDim2.fromScale(1,1)
drawer.BackgroundTransparency=1;drawer.BackgroundColor3=C.card;drawer.BorderSizePixel=0;drawer.Parent=root;round(drawer,14)
local function rail(leftSide)
 local f=Instance.new("Frame");f.Name=leftSide and"LeftRail"or"RightRail"
 f.Size=UDim2.fromOffset(124,208);f.BackgroundTransparency=1;f.Parent=drawer
 local l=Instance.new("UIListLayout");l.SortOrder=Enum.SortOrder.LayoutOrder;l.Padding=UDim.new(0,8)
 l.VerticalAlignment=Enum.VerticalAlignment.Center;l.Parent=f;return f
end
local left,right=rail(true),rail(false)
local community=button(left,"Community","COMUNIDADE",C.sky)
local loader=button(left,"Loader","CARREGAR",C.sage)
local photo=button(left,"Photo","FOTO",C.warm)
local looks=button(right,"Looks","MEUS LOOKS",C.sage)
local emotes=button(right,"Emotes","EMOTES",C.warm)
local games=button(right,"Games","JOGOS",C.sky)
local cfg=button(right,"Cfg","AJUSTES",C.muted)
for i,b in ipairs({community,loader,photo,looks,emotes,games,cfg})do b.LayoutOrder=i end
local menuOpen,compactOn=false,false
local adapt
local function toast(msg)
 local old=pg:FindFirstChild("ACP_HudToast");if old then old:Destroy()end
 local g=screen("ACP_HudToast",180)
 local t=label(g,tostring(msg or""),UDim2.new(.5,-155,1,-54),UDim2.fromOffset(310,44))
 t.BackgroundTransparency=.04;t.BackgroundColor3=C.bg;t.TextWrapped=true;round(t);border(t)
 task.delay(3,function()if g.Parent then g:Destroy()end end)
end
local launching=false
local function fireShop(which)
 if launching then return end
 launching=true;menuOpen=false;if adapt then adapt()end
 task.spawn(function()
  for _=1,35 do
   local g=pg:FindFirstChild("AvatarShop08Gui");local e=g and g:FindFirstChild("OpenRequest")
   if e and e:IsA("BindableEvent")then e:Fire(which);launching=false;return end
   task.wait(.2)
  end
  launching=false;toast("O editor ainda está carregando. Tente novamente.")
 end)
end
for b,which in pairs({[catalog]="Catalog",[stores]="Stores",[community]="Community",
 [loader]="Loader",[looks]="Looks",[emotes]="Emotes"})do
 b.Activated:Connect(function()fireShop(which)end)
end
local function openFeature(attribute)
 menuOpen=false;if adapt then adapt()end
 pg:SetAttribute(attribute,(tonumber(pg:GetAttribute(attribute))or 0)+1)
end
photo.Activated:Connect(function()openFeature("ACP_OpenPhotoNonce")end)
games.Activated:Connect(function()openFeature("ACP_OpenGamesNonce")end)
menu.Activated:Connect(function()menuOpen=not menuOpen;adapt()end)
music.Activated:Connect(function()menuOpen=false;adapt()end)
plus.Activated:Connect(function()
 local id=tonumber(kit:GetAttribute("PlusGamePassId"))or 0
 if id>0 then pcall(function()Market:PromptGamePassPurchase(pl,id)end)end
end)
local panel=Instance.new("Frame");panel.Name="Settings";panel.AnchorPoint=Vector2.new(.5,.5)
panel.Position=UDim2.fromScale(.5,.5);panel.Size=UDim2.fromOffset(300,298)
panel.BackgroundColor3=C.card;panel.BorderSizePixel=0;panel.Visible=false;panel.Parent=root;round(panel,14);border(panel)
label(panel,"AJUSTES",UDim2.fromOffset(14,12),UDim2.new(1,-70,0,30))
local close=button(panel,"CloseCfg","X",C.red);close.Size=UDim2.fromOffset(44,40);close.Position=UDim2.new(1,-54,0,8)
local body=Instance.new("Frame");body.Position=UDim2.fromOffset(12,60);body.Size=UDim2.new(1,-24,1,-72)
body.BackgroundTransparency=1;body.Parent=panel
local list=Instance.new("UIListLayout");list.Padding=UDim.new(0,8);list.SortOrder=Enum.SortOrder.LayoutOrder;list.Parent=body
local fov=button(body,"Fov","CAMERA: FOV 70",C.sky)
local compact=button(body,"HudSize","MENU AUTOMÁTICO",C.sage)
local toggle=button(body,"MusicToggle","MÚSICA LIGADA",C.warm)
local reset=button(body,"Reset","RESTAURAR",C.muted)
for i,b in ipairs({fov,compact,toggle,reset})do b.Size=UDim2.new(1,0,0,44);b.LayoutOrder=i end
fov.Activated:Connect(function()
 local cam=workspace.CurrentCamera;if not cam then return end
 cam.FieldOfView=cam.FieldOfView>=85 and 60 or cam.FieldOfView+5;fov.Text="CAMERA: FOV "..math.floor(cam.FieldOfView)
end)
compact.Activated:Connect(function()
 compactOn=not compactOn;compact.Text=compactOn and"MENU COMPACTO"or"MENU AUTOMÁTICO";menuOpen=false;adapt()
end)
local function musicText()toggle.Text=pg:GetAttribute("ACP_MusicEnabled")==false and"MÚSICA DESLIGADA"or"MÚSICA LIGADA"end
toggle.Activated:Connect(function()pg:SetAttribute("ACP_MusicEnabled",pg:GetAttribute("ACP_MusicEnabled")==false);musicText()end)
pg:GetAttributeChangedSignal("ACP_MusicEnabled"):Connect(musicText)
reset.Activated:Connect(function()
 local cam=workspace.CurrentCamera;if cam then cam.FieldOfView=70 end
 compactOn=false;menuOpen=false;compact.Text="MENU AUTOMÁTICO";fov.Text="CAMERA: FOV 70";musicText();adapt()
end)
cfg.Activated:Connect(function()panel.Visible=not panel.Visible;menuOpen=false;adapt()end)
close.Activated:Connect(function()panel.Visible=false;adapt()end)
adapt=function()
 local w,h=root.AbsoluteSize.X,root.AbsoluteSize.Y;if w<1 or h<1 then return end
 local small=w<680 or h<370 or compactOn
 top.Visible=not panel.Visible;panel.Size=UDim2.fromOffset(math.min(300,w-16),math.min(298,h-16))
 local hasPlus=(tonumber(kit:GetAttribute("PlusGamePassId"))or 0)>0
 menu.Visible=small;plus.Visible=hasPlus and not small
 catalog.AnchorPoint=Vector2.new(.5,0);stores.AnchorPoint=Vector2.new(.5,0)
 catalog.Size=UDim2.fromOffset(small and math.min(124,w*.34)or 146,44)
 stores.Size=UDim2.fromOffset(small and math.min(90,w*.23)or 104,44)
 if small then
  menu.Size=UDim2.fromOffset(math.min(80,w*.22),44);menu.Position=UDim2.fromOffset(8,8)
  catalog.Position=UDim2.new(.5,8,0,8);stores.Position=UDim2.new(1,-stores.Size.X.Offset*.5-8,0,8)
  drawer.AnchorPoint=Vector2.new(.5,0);drawer.Position=UDim2.new(.5,0,0,62)
  drawer.Size=UDim2.new(0,math.min(w-16,380),0,math.min(270,h-70));drawer.BackgroundTransparency=.04
  drawer.Visible=menuOpen and not panel.Visible
  left.AnchorPoint=Vector2.zero;right.AnchorPoint=Vector2.zero
  left.Position=UDim2.fromOffset(10,8);right.Position=UDim2.new(.5,4,0,8)
  left.Size=UDim2.new(.5,-14,1,-66);right.Size=UDim2.new(.5,-14,1,-16)
  for _,b in ipairs({community,loader,photo,looks,emotes,games,cfg})do b.Size=UDim2.new(1,0,0,44)end
  music.Visible=drawer.Visible;music.AnchorPoint=Vector2.new(.5,0);music.Size=UDim2.fromOffset(math.min(144,(w-40)*.5),44)
  music.Position=UDim2.new(.5,-math.min(w-16,380)*.25,0,62+drawer.Size.Y.Offset-54)
 else
  catalog.Position=UDim2.new(.5,-66,0,8);stores.Position=UDim2.new(.5,70,0,8)
  music.Visible=true;music.AnchorPoint=Vector2.new(1,0);music.Size=UDim2.fromOffset(96,44)
  music.Position=UDim2.new(1,hasPlus and -64 or -12,0,8)
  plus.AnchorPoint=Vector2.new(1,0);plus.Size=UDim2.fromOffset(44,44);plus.Position=UDim2.new(1,-12,0,8)
  drawer.AnchorPoint=Vector2.zero;drawer.Position=UDim2.new();drawer.Size=UDim2.fromScale(1,1);drawer.BackgroundTransparency=1;drawer.Visible=true
  left.AnchorPoint=Vector2.new(0,.5);left.Position=UDim2.new(0,12,.49,0);left.Size=UDim2.fromOffset(124,208)
  right.AnchorPoint=Vector2.new(1,.5);right.Position=UDim2.new(1,-12,.49,0);right.Size=UDim2.fromOffset(124,208)
  for _,b in ipairs({community,loader,photo,looks,emotes,games,cfg})do b.Size=UDim2.fromOffset(124,44)end
 end
end
root:GetPropertyChangedSignal("AbsoluteSize"):Connect(adapt)
kit:GetAttributeChangedSignal("PlusGamePassId"):Connect(adapt)
task.defer(adapt);musicText()
print("AVATAR PLAZA V39: HUD e launcher prontos")
