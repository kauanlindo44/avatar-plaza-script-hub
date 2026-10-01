-- 09A_SHOP_UI
-- ModuleScript | ReplicatedStorage
local M={VERSION="V39_STUDIO_UI"}
local GuiService=game:GetService("GuiService")
local function preferredScale()
 local ok,v=pcall(function()return GuiService.PreferredTextSize end);if not ok then return 1 end
 local n=tostring(v);if n:find("Largest")then return 1.18 elseif n:find("Larger")then return 1.12 elseif n:find("Large")then return 1.06 end;return 1
end
local TEXT_SCALE=preferredScale()
local C={
 bg=Color3.fromRGB(14,23,23),panel=Color3.fromRGB(24,36,35),
 card=Color3.fromRGB(36,50,48),soft=Color3.fromRGB(56,72,69),
 white=Color3.fromRGB(246,249,248),muted=Color3.fromRGB(174,193,187),
 green=Color3.fromRGB(112,181,122),red=Color3.fromRGB(211,83,91),
 yellow=Color3.fromRGB(207,174,101),blue=Color3.fromRGB(102,164,180),
 purple=Color3.fromRGB(128,116,173),orange=Color3.fromRGB(195,145,94),
 pink=Color3.fromRGB(185,119,150),cyan=Color3.fromRGB(145,194,200)
}
local function N(class,p,parent)local o=Instance.new(class);for k,v in pairs(p or{})do o[k]=v end;if parent then o.Parent=parent end;return o end
local function R(o,n)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,n or 9);c.Parent=o;return c end
local function S(o,col,t,th)local s=Instance.new("UIStroke");s.Color=col or C.soft;s.Transparency=t or .65;s.Thickness=th or 1;s.Parent=o;return s end
local function pad(o,l,r,t,b)return N("UIPadding",{PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or 0),PaddingTop=UDim.new(0,t or 0),PaddingBottom=UDim.new(0,b or 0)},o)end
local function L(p,txt,x)local q=x or{}
q.Text=txt
q.BackgroundTransparency=q.BackgroundTransparency==nil and 1 or q.BackgroundTransparency
q.TextColor3=q.TextColor3 or C.white
q.Font=q.Font or Enum.Font.Gotham
q.TextSize=math.max(12,math.floor((q.TextSize or 12)*TEXT_SCALE+.5))
q.TextWrapped=q.TextWrapped~=false
return N("TextLabel",q,p)end
local function B(p,txt,x)local q=x or{}
q.Text=txt
q.BackgroundColor3=q.BackgroundColor3 or C.blue
q.TextColor3=q.TextColor3 or C.white
q.Font=q.Font or Enum.Font.GothamBold
q.TextSize=math.max(12,math.floor((q.TextSize or 12)*TEXT_SCALE+.5))
q.BorderSizePixel=0
q.AutoButtonColor=true
q.TextWrapped=q.TextWrapped~=false
local b=N("TextButton",q,p)
R(b,q.Corner or 8)
pad(b,6,6)
return b end
local function T(p,ph,x)local q=x or{}
q.PlaceholderText=ph or""
q.Text=q.Text or""
q.ClearTextOnFocus=false
q.BackgroundColor3=q.BackgroundColor3 or C.card
q.TextColor3=q.TextColor3 or C.white
q.PlaceholderColor3=q.PlaceholderColor3 or C.muted
q.Font=q.Font or Enum.Font.Gotham
q.TextSize=math.max(12,math.floor((q.TextSize or 12)*TEXT_SCALE+.5))
q.BorderSizePixel=0
q.TextWrapped=false
local t=N("TextBox",q,p)
R(t,8)
pad(t,8,8)
return t end
local function F(p,x)local q=x or{}
q.BackgroundTransparency=q.BackgroundTransparency==nil and 1 or q.BackgroundTransparency
q.BorderSizePixel=0
q.ScrollBarThickness=q.ScrollBarThickness or 3
q.ScrollBarImageColor3=q.ScrollBarImageColor3 or C.muted
q.AutomaticCanvasSize=q.AutomaticCanvasSize or Enum.AutomaticSize.Y
q.CanvasSize=q.CanvasSize or UDim2.new()
return N("ScrollingFrame",q,p)end
local function list(p,h,g)return N("UIListLayout",{FillDirection=h and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,Padding=UDim.new(0,g or 5)},p)end
local function grid(p,w,h,g)return N("UIGridLayout",{CellSize=UDim2.fromOffset(w,h),CellPadding=UDim2.fromOffset(g or 8,g or 8),HorizontalAlignment=Enum.HorizontalAlignment.Center},p)end
local function area(p,name)return N("Frame",{Name=name,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false},p)end
function M.Build(pl)
 local pg=pl:WaitForChild("PlayerGui")
 local old=pg:FindFirstChild("AvatarShop08Gui")
 if old then old:Destroy()end
 local g=N("ScreenGui",{
  Name="AvatarShop08Gui",ResetOnSpawn=false,IgnoreGuiInset=false,
  DisplayOrder=90,ZIndexBehavior=Enum.ZIndexBehavior.Sibling
 },pg)
 local U={Gui=g,LauncherGui=pg:FindFirstChild("AvatarShopLauncherGui"),
  Colors=C,New=N,Round=R,Text=L,Button=B
 }
 U.OpenRequest=N("BindableEvent",{Name="OpenRequest"},g)
 U.HudAction=N("BindableEvent",{Name="HudAction"},g)
 local root=N("Frame",{Name="ShopWindow",Size=UDim2.fromScale(1,1),BackgroundColor3=C.bg,BorderSizePixel=0,Visible=false},g);U.Root=root
 local left=N("Frame",{Position=UDim2.fromOffset(8,8),Size=UDim2.new(.30,-10,1,-16),BackgroundColor3=C.panel,BorderSizePixel=0},root)
 R(left,12)
 S(left,nil,.52)
 U.Left=left;local main=N("Frame",{Position=UDim2.new(.30,4,0,8),Size=UDim2.new(.70,-12,1,-16),BackgroundColor3=Color3.fromRGB(20,31,30),BorderSizePixel=0},root)
 R(main,12)
 S(main,nil,.55)
 U.Main=main
 U.Viewport=N("ViewportFrame",{
  Position=UDim2.fromOffset(8,8),Size=UDim2.new(1,-16,.57,0),
  BackgroundColor3=Color3.fromRGB(93,112,108),Ambient=Color3.fromRGB(232,234,238),
  LightColor=Color3.fromRGB(255,255,255),LightDirection=Vector3.new(-.55,-1,-.42),BorderSizePixel=0
 },left)
 R(U.Viewport,10)
 N("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(116,139,133),Color3.fromRGB(72,91,88)),Rotation=90},U.Viewport)
 U.PreviewInfo=L(U.Viewport,"PRÉVIA • R15",{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-6),Size=UDim2.new(1,-16,0,20),Font=Enum.Font.GothamBold,TextColor3=C.white})
 U.ViewLeft=B(U.Viewport,"<",{AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,6,.5,0),Size=UDim2.fromOffset(30,38),BackgroundColor3=Color3.fromRGB(35,39,47),TextSize=15})
 U.ViewRight=B(U.Viewport,">",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-6,.5,0),Size=UDim2.fromOffset(30,38),BackgroundColor3=Color3.fromRGB(35,39,47),TextSize=15})
 U.ZoomIn=B(U.Viewport,"+",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-6,0,6),Size=UDim2.fromOffset(28,28),BackgroundColor3=Color3.fromRGB(35,39,47),TextSize=12})
 U.ZoomOut=B(U.Viewport,"-",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-6,0,39),Size=UDim2.fromOffset(28,28),BackgroundColor3=Color3.fromRGB(35,39,47),TextSize=12})
 U.RigBack=B(left,"VOLTAR R6",{Visible=false})
 U.StopEmote=B(U.Viewport,"PARAR EMOTE",{Position=UDim2.fromOffset(8,8),Size=UDim2.fromOffset(124,36),BackgroundColor3=C.soft,Visible=false,ZIndex=5})
 local tabs=N("Frame",{Position=UDim2.new(0,8,.585,0),Size=UDim2.new(1,-16,0,30),BackgroundTransparency=1},left);U.EditorTabButtons={}
 local tl=N("UIGridLayout",{CellSize=UDim2.new(.25,-4,1,0),CellPadding=UDim2.fromOffset(5,0),FillDirectionMaxCells=4},tabs)
 for _,name in ipairs({"AVATAR","CORPO","ITENS","EMOTES"})do local b=B(tabs,name,{BackgroundColor3=name=="AVATAR"and C.soft or Color3.fromRGB(39,41,46),TextSize=12})
 U.EditorTabButtons[name]=b
 if name=="AVATAR"then U.EditorAvatar=b elseif name=="CORPO"then U.EditorBody=b elseif name=="ITENS"then U.EditorItems=b else U.EditorEmotes=b end end
 local edit=N("Frame",{Position=UDim2.new(0,8,.585,36),Size=UDim2.new(1,-16,1,-208),BackgroundTransparency=1},left);U.EditorArea=edit
 local tools=N("Frame",{Size=UDim2.new(1,0,0,36),BackgroundTransparency=1},edit);U.Tools=tools
 local tg=N("UIGridLayout",{CellSize=UDim2.new(.25,-4,1,0),CellPadding=UDim2.fromOffset(5,0),FillDirectionMaxCells=4},tools)
 U.SaveRoblox=B(tools,"RBLX",{BackgroundColor3=C.soft})
 U.Undo=B(tools,"UNDO",{BackgroundColor3=C.card,TextSize=6})
 U.Redo=B(tools,"REDO",{BackgroundColor3=C.card,TextSize=6})
 U.Blank=B(tools,"LIMPAR",{BackgroundColor3=C.card,TextSize=6})
 U.Total=L(edit,"0 itens",{Position=UDim2.fromOffset(0,40),Size=UDim2.new(1,0,0,18),TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Right})
 U.ItemStrip=F(edit,{Position=UDim2.fromOffset(0,60),Size=UDim2.new(1,0,1,-60),ScrollingDirection=Enum.ScrollingDirection.X,AutomaticCanvasSize=Enum.AutomaticSize.X,ScrollBarThickness=0})
 list(U.ItemStrip,true,6)
 U.ItemsPanel=F(edit,{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(31,44,42),BackgroundTransparency=0,Visible=false,ScrollBarThickness=2})
 R(U.ItemsPanel,9)
 pad(U.ItemsPanel,6,6,6,6)
 list(U.ItemsPanel,false,5)
 U.EmotePanel=F(edit,{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(31,44,42),BackgroundTransparency=0,Visible=false,AutomaticCanvasSize=Enum.AutomaticSize.None,CanvasSize=UDim2.fromOffset(0,154)})
 R(U.EmotePanel,9)
 L(U.EmotePanel,"EMOTES R15",{Position=UDim2.fromOffset(10,10),Size=UDim2.new(1,-20,0,22),Font=Enum.Font.GothamBlack,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left})
 L(U.EmotePanel,"Teste animações diretamente na prévia. Em R6, escolha testar em R15 antes de tocar.",{Position=UDim2.fromOffset(10,38),Size=UDim2.new(1,-20,0,54),TextColor3=C.muted,TextSize=6,TextXAlignment=Enum.TextXAlignment.Left})
 U.OpenEmotes=B(U.EmotePanel,"ABRIR EMOTES",{Position=UDim2.fromOffset(10,104),Size=UDim2.new(1,-20,0,40),BackgroundColor3=C.green,TextColor3=C.bg})
 U.BodyPanel=F(edit,{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(31,44,42),BackgroundTransparency=0,Visible=false,ScrollBarThickness=2,AutomaticCanvasSize=Enum.AutomaticSize.None,CanvasSize=UDim2.fromOffset(0,402)})
 R(U.BodyPanel,9)
 U.RigR6=B(U.BodyPanel,"R6",{Position=UDim2.fromOffset(6,6),Size=UDim2.new(.5,-9,0,40),BackgroundColor3=C.soft})
 U.RigR15=B(U.BodyPanel,"R15",{Position=UDim2.new(.5,3,0,6),Size=UDim2.new(.5,-9,0,40),BackgroundColor3=C.green,TextColor3=C.bg})
 U.BodyNote=L(U.BodyPanel,"R15 permite ajustar proporções.",{Position=UDim2.fromOffset(8,49),Size=UDim2.new(1,-16,0,26),TextColor3=C.muted,TextSize=5,TextXAlignment=Enum.TextXAlignment.Left})
 U.BodyControls={}
 local function bodyRow(key,label,row)local y=82+(row-1)*44
 L(U.BodyPanel,label,{Position=UDim2.fromOffset(8,y),Size=UDim2.new(.44,-8,0,40),TextSize=5,TextXAlignment=Enum.TextXAlignment.Left})
 local m=B(U.BodyPanel,"-",{Position=UDim2.new(.44,0,0,y),Size=UDim2.fromOffset(36,40)})
 local v=L(U.BodyPanel,"1.00",{Position=UDim2.new(.44,38,0,y),Size=UDim2.new(.56,-82,0,40),TextSize=5,TextXAlignment=Enum.TextXAlignment.Center})
 local p=B(U.BodyPanel,"+",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-7,0,y),Size=UDim2.fromOffset(36,40)})
 U.BodyControls[key]={Minus=m,Value=v,Plus=p}end
 bodyRow("HeightScale","ALTURA",1)
 bodyRow("WidthScale","LARGURA",2)
 bodyRow("DepthScale","PROFUNDIDADE",3)
 bodyRow("HeadScale","CABEÇA",4)
 bodyRow("BodyTypeScale","TIPO CORPO",5)
 bodyRow("ProportionScale","PROPORÇÃO",6)
 U.BodyReset=B(U.BodyPanel,"RESTAURAR CORPO",{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,356),Size=UDim2.new(.92,0,0,40),BackgroundColor3=C.soft,TextSize=5})
 local actions=N("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,8,1,-8),Size=UDim2.new(1,-16,0,88),BackgroundTransparency=1},left);U.Actions=actions
 local ag=N("UIGridLayout",{CellSize=UDim2.new(.5,-4,.5,-4),CellPadding=UDim2.fromOffset(8,8),FillDirectionMaxCells=2},actions)
 U.Apply=B(actions,"APLICAR",{BackgroundColor3=C.green,TextColor3=C.bg})
 U.Save=B(actions,"SALVAR",{BackgroundColor3=C.blue,TextColor3=C.bg})
 U.Reset=B(actions,"RESTAURAR",{BackgroundColor3=Color3.fromRGB(48,51,58)})
 U.BuyLook=B(actions,"CARRINHO",{BackgroundColor3=Color3.fromRGB(48,51,58)})
 U.Close=B(main,"X",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-8,0,8),Size=UDim2.fromOffset(34,32),BackgroundColor3=C.soft,ZIndex=40})
 U.Query=T(main,"Pesquisar itens...",{Position=UDim2.fromOffset(10,10),Size=UDim2.new(1,-238,0,34)})
 U.Filter=B(main,"FILTRO",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-136,0,10),Size=UDim2.fromOffset(88,34),BackgroundColor3=C.card,TextSize=7})
 U.Sort=B(main,"POPULAR",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-46,0,10),Size=UDim2.fromOffset(86,34),BackgroundColor3=C.card,TextSize=7})
 U.SearchGo=B(main,"IR",{Size=UDim2.fromOffset(40,40),BackgroundColor3=C.green,TextColor3=C.bg})
 U.PreviewToggle=B(main,"AVATAR",{Size=UDim2.fromOffset(96,36),BackgroundColor3=C.blue,TextColor3=C.bg,Visible=false})
 U.HidePreview=B(U.Viewport,"X",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-44,0,10),Size=UDim2.fromOffset(40,40),Visible=false,ZIndex=15})
 local categoryRow=N("Frame",{Position=UDim2.fromOffset(10,51),Size=UDim2.new(1,-20,0,31),BackgroundTransparency=1},main)
 U.SubToggle=B(categoryRow,"EM ALTA",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),Size=UDim2.fromOffset(102,28),BackgroundColor3=Color3.fromRGB(62,65,72),TextSize=6})
 U.Groups=F(categoryRow,{Size=UDim2.new(1,-110,1,0),ScrollingDirection=Enum.ScrollingDirection.X,AutomaticCanvasSize=Enum.AutomaticSize.X,ScrollBarThickness=0})
 list(U.Groups,true,6)
 U.Grid=F(main,{Position=UDim2.fromOffset(8,88),Size=UDim2.new(1,-16,1,-124)});U.GridLayout=grid(U.Grid,132,174,8)
 U.Status=L(main,"",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,10,1,-8),Size=UDim2.new(1,-146,0,22),TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 U.More=B(main,"CARREGAR MAIS",{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-8,1,-7),Size=UDim2.fromOffset(124,28),BackgroundColor3=C.card,TextSize=6})
 U.SubsPopup=N("Frame",{Position=UDim2.new(0,10,0,84),Size=UDim2.new(1,-20,0,118),BackgroundColor3=Color3.fromRGB(30,43,41),BorderSizePixel=0,Visible=false,ZIndex=58},main)
 R(U.SubsPopup,10)
 S(U.SubsPopup,nil,.45)
 U.Subs=F(U.SubsPopup,{Position=UDim2.fromOffset(7,7),Size=UDim2.new(1,-14,1,-14),ZIndex=59});U.SubsLayout=grid(U.Subs,112,28,6);U.SubsLayout.FillDirectionMaxCells=4
 U.FilterPanel=N("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-8,0,50),Size=UDim2.fromOffset(302,226),BackgroundColor3=C.panel,Visible=false,ZIndex=65},main)
 R(U.FilterPanel,10)
 S(U.FilterPanel,nil,.45)
 U.CloseFilter=B(U.FilterPanel,"X",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-7,0,6),Size=UDim2.fromOffset(28,28),BackgroundColor3=C.soft,ZIndex=66})
 U.Min=T(U.FilterPanel,"Preço mínimo",{Position=UDim2.fromOffset(10,40),Size=UDim2.new(.5,-15,0,28),ZIndex=66})
 U.Max=T(U.FilterPanel,"Preço máximo",{Position=UDim2.new(.5,5,0,40),Size=UDim2.new(.5,-15,0,28),ZIndex=66})
 U.Creator=T(U.FilterPanel,"Criador",{Position=UDim2.fromOffset(10,74),Size=UDim2.new(.58,-15,0,28),ZIndex=66})
 U.CreatorType=B(U.FilterPanel,"Todos criadores",{Position=UDim2.new(.58,5,0,74),Size=UDim2.new(.42,-15,0,28),BackgroundColor3=C.card,ZIndex=66,TextSize=6})
 U.LimAll=B(U.FilterPanel,"TODOS",{Position=UDim2.fromOffset(10,108),Size=UDim2.new(.33,-8,0,24),ZIndex=66})
 U.LimOnly=B(U.FilterPanel,"LIMITED",{Position=UDim2.new(.33,4,0,108),Size=UDim2.new(.33,-7,0,24),BackgroundColor3=C.yellow,TextColor3=C.bg,ZIndex=66})
 U.LimNo=B(U.FilterPanel,"SEM LIMITED",{Position=UDim2.new(.66,2,0,108),Size=UDim2.new(.34,-12,0,24),BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=66,TextSize=6})
 U.FormAll=B(U.FilterPanel,"TODOS",{Position=UDim2.fromOffset(10,138),Size=UDim2.new(.25,-6,0,24),ZIndex=66})
 U.FormClassic=B(U.FilterPanel,"CLÁSSICO",{Position=UDim2.new(.25,3,0,138),Size=UDim2.new(.25,-6,0,24),BackgroundColor3=C.orange,TextColor3=C.bg,ZIndex=66})
 U.Form2D=B(U.FilterPanel,"2D",{Position=UDim2.new(.5,2,0,138),Size=UDim2.new(.25,-6,0,24),BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=66})
 U.Form3D=B(U.FilterPanel,"3D",{Position=UDim2.new(.75,1,0,138),Size=UDim2.new(.25,-11,0,24),BackgroundColor3=C.pink,ZIndex=66})
 U.OffSale=B(U.FilterPanel,"Fora de venda: NÃO",{Position=UDim2.fromOffset(10,168),Size=UDim2.new(1,-20,0,20),BackgroundColor3=C.soft,ZIndex=66})
 U.ClearFilter=B(U.FilterPanel,"LIMPAR",{Position=UDim2.fromOffset(10,194),Size=UDim2.new(.36,-6,0,25),BackgroundColor3=C.red,ZIndex=66})
 U.ApplyFilter=B(U.FilterPanel,"APLICAR",{Position=UDim2.new(.36,4,0,194),Size=UDim2.new(.64,-14,0,25),BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=66})
 U.Detail=N("ScrollingFrame",{
  AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-8,0,8),Size=UDim2.new(0,276,1,-16),
  CanvasSize=UDim2.fromOffset(0,360),AutomaticCanvasSize=Enum.AutomaticSize.None,
  ScrollBarThickness=2,ScrollBarImageColor3=C.muted,ClipsDescendants=true,
  BackgroundColor3=Color3.fromRGB(24,37,35),BorderSizePixel=0,Visible=false,ZIndex=72
 },main)
 R(U.Detail,11);S(U.Detail,nil,.4)
 U.DetailClose=B(U.Detail,"X",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-8,0,8),Size=UDim2.fromOffset(30,30),BackgroundColor3=C.soft,ZIndex=75})
 U.DetailImage=N("ImageLabel",{Position=UDim2.fromOffset(12,12),Size=UDim2.new(1,-24,0,210),BackgroundColor3=Color3.fromRGB(55,72,68),BorderSizePixel=0,ScaleType=Enum.ScaleType.Fit,ZIndex=73},U.Detail)
 R(U.DetailImage,9)
 U.DetailName=L(U.Detail,"Item",{Position=UDim2.fromOffset(12,230),Size=UDim2.new(1,-24,0,34),Font=Enum.Font.GothamBold,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=73})
 U.DetailPrice=L(U.Detail,"",{Position=UDim2.fromOffset(12,266),Size=UDim2.new(1,-24,0,20),Font=Enum.Font.GothamBold,TextColor3=C.green,TextSize=8,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=73})
 U.Try=B(U.Detail,"EXPERIMENTAR",{Position=UDim2.fromOffset(12,296),Size=UDim2.new(.52,-15,0,36),BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=73})
 U.Buy=B(U.Detail,"+ CARRINHO",{Position=UDim2.new(.52,3,0,296),Size=UDim2.new(.48,-15,0,36),BackgroundColor3=C.card,ZIndex=73,TextSize=6})
 U.Favorite=B(U.Detail,"FAVORITAR",{Position=UDim2.fromOffset(12,336),Size=UDim2.new(1,-24,0,18),BackgroundColor3=C.soft,ZIndex=73,TextSize=5})
 U.LooksArea=area(main,"LooksArea")
 local sp=N("Frame",{Position=UDim2.fromOffset(6,6),Size=UDim2.new(.38,-9,1,-12),BackgroundColor3=Color3.fromRGB(18,29,28),BorderSizePixel=0},U.LooksArea)
 R(sp,10)
 U.SavedPreviewPanel=sp;U.SavedPreview=N("ViewportFrame",{
  Position=UDim2.fromOffset(8,8),Size=UDim2.new(1,-16,.58,0),
  BackgroundColor3=Color3.fromRGB(83,87,95),Ambient=Color3.fromRGB(225,228,232),
  LightColor=Color3.fromRGB(255,255,255),LightDirection=Vector3.new(-.55,-1,-.5),BorderSizePixel=0
 },sp)
 R(U.SavedPreview,9)
 U.SavedLeft=B(U.SavedPreview,"<",{AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,5,.5,0),Size=UDim2.fromOffset(28,36),BackgroundColor3=C.card})
 U.SavedRight=B(U.SavedPreview,">",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-5,.5,0),Size=UDim2.fromOffset(28,36),BackgroundColor3=C.card})
 U.SavedZoomIn=B(U.SavedPreview,"+",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-5,0,5),Size=UDim2.fromOffset(25,25),BackgroundColor3=C.card})
 U.SavedZoomOut=B(U.SavedPreview,"-",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-5,0,34),Size=UDim2.fromOffset(25,25),BackgroundColor3=C.card})
 U.OutfitSelected=L(sp,"Selecione uma skin",{Position=UDim2.fromOffset(8,170),Size=UDim2.new(1,-16,0,22),Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})
 U.SavedItems=F(sp,{Position=UDim2.fromOffset(8,196),Size=UDim2.new(1,-16,0,54),ScrollingDirection=Enum.ScrollingDirection.X,AutomaticCanvasSize=Enum.AutomaticSize.X,ScrollBarThickness=0})
 list(U.SavedItems,true,5)
 U.OutfitActions=F(sp,{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,8,1,-8),Size=UDim2.new(1,-16,0,104),Visible=false,AutomaticCanvasSize=Enum.AutomaticSize.None})
 U.OutfitApply=B(U.OutfitActions,"CARREGAR PRÉVIA",{Position=UDim2.fromOffset(0,0),Size=UDim2.new(.5,-3,0,30),BackgroundColor3=C.green,TextColor3=C.bg})
 U.OutfitUpdate=B(U.OutfitActions,"SALVAR ALTERAÇÕES",{Position=UDim2.new(.5,3,0,0),Size=UDim2.new(.5,-3,0,30),BackgroundColor3=C.card})
 U.OutfitRestore=B(U.OutfitActions,"RESTAURAR",{Position=UDim2.fromOffset(0,36),Size=UDim2.new(.5,-3,0,30),BackgroundColor3=C.orange,TextColor3=C.bg})
 U.OutfitBuy=B(U.OutfitActions,"COMPRAR ITENS",{Position=UDim2.new(.5,3,0,36),Size=UDim2.new(.5,-3,0,30),BackgroundColor3=C.yellow,TextColor3=C.bg})
 U.OutfitDelete=B(U.OutfitActions,"EXCLUIR",{Position=UDim2.fromOffset(0,72),Size=UDim2.new(.5,-3,0,30),BackgroundColor3=C.red})
 U.OutfitPublish=B(U.OutfitActions,"PUBLICAR",{Position=UDim2.new(.5,3,0,72),Size=UDim2.new(.5,-3,0,30),BackgroundColor3=C.purple})
 local gs=N("Frame",{Position=UDim2.new(.38,3,0,6),Size=UDim2.new(.62,-9,1,-12),BackgroundColor3=Color3.fromRGB(25,38,36),BorderSizePixel=0},U.LooksArea)
 R(gs,10)
 U.SavedCount=L(gs,"0 skins",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,0,8),Size=UDim2.fromOffset(90,20),TextColor3=C.cyan,TextXAlignment=Enum.TextXAlignment.Right})
 U.OutfitSaveNew=B(gs,"+ SALVAR NOVA",{Position=UDim2.fromOffset(10,36),Size=UDim2.new(.42,-14,0,32),BackgroundColor3=C.soft})
 U.LookSearch=T(gs,"Pesquisar skins...",{Position=UDim2.new(.42,4,0,36),Size=UDim2.new(.58,-14,0,32)})
 U.SavedGrid=F(gs,{Position=UDim2.fromOffset(6,76),Size=UDim2.new(1,-12,1,-82)})
 grid(U.SavedGrid,146,174,8)
 U.CommunityArea=area(main,"CommunityArea");local cg=N("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(16,17,20),BorderSizePixel=0},U.CommunityArea)
 R(cg,10)
 local cm=N("Frame",{Position=UDim2.fromOffset(7,7),Size=UDim2.new(1,-14,0,92),BackgroundColor3=Color3.fromRGB(28,29,33),BorderSizePixel=0,ZIndex=20},cg);R(cm,10)
 U.ComMyOutfits=B(cm,"MEUS LOOKS",{Position=UDim2.fromOffset(7,7),Size=UDim2.fromOffset(106,36),BackgroundColor3=C.soft,ZIndex=21,TextSize=5})
 U.ComSearch=T(cm,"Pesquisar look, criador ou código...",{Position=UDim2.fromOffset(119,7),Size=UDim2.new(1,-218,0,36),ZIndex=21})
 U.ComSearchGo=B(cm,"IR",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-52,0,7),Size=UDim2.fromOffset(40,36),ZIndex=21})
 U.ComRefresh=B(cm,"R",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-7,0,7),Size=UDim2.fromOffset(40,36),BackgroundColor3=C.soft,ZIndex=21})
 local ctabs=F(cm,{Position=UDim2.fromOffset(7,50),Size=UDim2.new(1,-14,0,36),ScrollingDirection=Enum.ScrollingDirection.X,AutomaticCanvasSize=Enum.AutomaticSize.X,ZIndex=21})
 local ctl=N("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6)},ctabs)
 U.ComTabButtons={};local comOrder=0
 for _,name in ipairs({"NOVOS","EM ALTA","MAIS CURTIDOS","LOOK DA SEMANA"})do comOrder=comOrder+1;U.ComTabButtons[name]=B(ctabs,name,{Size=UDim2.fromOffset(name=="LOOK DA SEMANA"and 154 or 126,34),LayoutOrder=comOrder,BackgroundColor3=name=="NOVOS"and C.soft or C.card,ZIndex=22,TextSize=5})end
 U.CommunityGrid=F(cg,{Position=UDim2.fromOffset(7,108),Size=UDim2.new(1,-14,1,-146)})
 grid(U.CommunityGrid,162,194,9)
 U.CommunityStatus=L(cg,"",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,10,1,-5),Size=UDim2.new(1,-116,0,20),TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 U.ComMore=B(cg,"MAIS",{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-7,1,-5),Size=UDim2.fromOffset(94,24),Visible=false,TextSize=6})
 U.ComGridTitle=L(cg,"",{Visible=false});U.ComCount=L(cg,"",{Visible=false})
 U.ComFeatured=N("Frame",{Size=UDim2.fromOffset(1,1),BackgroundTransparency=1,Visible=false},cg)
 U.ComFeaturedEyebrow=L(U.ComFeatured,"",{Visible=false});U.ComFeaturedPreview=N("ViewportFrame",{Size=UDim2.fromOffset(1,1),BackgroundTransparency=1,Visible=false},U.ComFeatured)
 U.ComFeaturedName=L(U.ComFeatured,"",{Visible=false});U.ComFeaturedCreator=L(U.ComFeatured,"",{Visible=false})
 U.ComFeaturedMeta=L(U.ComFeatured,"",{Visible=false});U.ComFeaturedOpen=B(U.ComFeatured,"",{Size=UDim2.fromOffset(1,1),Visible=false})
 U.StoresArea=area(main,"StoresArea");local sh=N("Frame",{Position=UDim2.fromOffset(7,7),Size=UDim2.new(1,-14,0,50),BackgroundColor3=Color3.fromRGB(28,29,33),BorderSizePixel=0},U.StoresArea)
 R(sh,10)
 U.StoreSearch=T(sh,"Nome do criador ou grupo...",{Position=UDim2.fromOffset(7,8),Size=UDim2.new(1,-184,0,34)})
 U.StoreType=B(sh,"CRIADOR",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-88,0,8),Size=UDim2.fromOffset(82,34),BackgroundColor3=C.card,TextSize=6})
 U.StoreGo=B(sh,"BUSCAR",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-6,0,8),Size=UDim2.fromOffset(76,34),BackgroundColor3=C.green,TextColor3=C.bg,TextSize=6})
 U.StoreGrid=F(U.StoresArea,{Position=UDim2.fromOffset(5,64),Size=UDim2.new(1,-10,1,-94)})
 grid(U.StoreGrid,154,184,8)
 U.StoreStatus=L(U.StoresArea,"Pesquise um criador ou grupo.",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,8,1,-3),Size=UDim2.new(1,-16,0,20),TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 U.CartPanel=N("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.new(.80,0,.84,0),BackgroundColor3=Color3.fromRGB(19,20,24),Visible=false,ZIndex=80},root)
 R(U.CartPanel,12);S(U.CartPanel,nil,.4)
 L(U.CartPanel,"CARRINHO",{Position=UDim2.fromOffset(16,12),Size=UDim2.new(1,-72,0,26),Font=Enum.Font.GothamBlack,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=81})
 U.CartClose=B(U.CartPanel,"X",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,0,10),Size=UDim2.fromOffset(34,34),BackgroundColor3=C.soft,ZIndex=81})
 U.CartCount=L(U.CartPanel,"0 selecionados",{Position=UDim2.fromOffset(16,42),Size=UDim2.new(1,-32,0,20),TextColor3=C.muted,ZIndex=81})
 U.CartList=F(U.CartPanel,{Position=UDim2.fromOffset(14,70),Size=UDim2.new(1,-28,1,-142),ZIndex=81})
 list(U.CartList,false,7)
 U.CartTotal=L(U.CartPanel,"TOTAL: 0 Robux",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,16,1,-14),Size=UDim2.new(.38,0,0,34),Font=Enum.Font.GothamBlack,TextSize=10,TextColor3=C.green,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=81})
 U.CartClear=B(U.CartPanel,"LIMPAR",{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-190,1,-14),Size=UDim2.fromOffset(82,34),BackgroundColor3=C.soft,ZIndex=81})
 U.CartBuySelected=B(U.CartPanel,"COMPRAR SELECIONADOS",{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-14,1,-14),Size=UDim2.fromOffset(168,34),BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=81,TextSize=6})
 U.LookDetail=N("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.new(.94,0,.90,0),BackgroundColor3=Color3.fromRGB(18,29,28),Visible=false,ZIndex=82},root)
 R(U.LookDetail,12)
 U.LookClose=B(U.LookDetail,"X",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-9,0,8),Size=UDim2.fromOffset(34,34),BackgroundColor3=C.soft,ZIndex=83})
 U.LookPreview=N("ViewportFrame",{
  Position=UDim2.fromOffset(12,12),Size=UDim2.new(.40,-18,1,-70),
  BackgroundColor3=Color3.fromRGB(84,88,96),Ambient=Color3.fromRGB(228,230,234),
  LightColor=Color3.fromRGB(255,255,255),LightDirection=Vector3.new(-.55,-1,-.5),
  BorderSizePixel=0,ZIndex=83
 },U.LookDetail)
 R(U.LookPreview,9)
 U.LookName=L(U.LookDetail,"LOOK",{Position=UDim2.new(.40,8,0,15),Size=UDim2.new(.60,-58,0,24),Font=Enum.Font.GothamBlack,TextSize=12,ZIndex=83})
 U.LookCreator=L(U.LookDetail,"Criador",{Position=UDim2.new(.40,8,0,43),Size=UDim2.new(.60,-28,0,18),TextColor3=C.muted,ZIndex=83})
 U.LookMeta=L(U.LookDetail,"RIG",{Position=UDim2.new(.40,8,0,64),Size=UDim2.new(.60,-28,0,18),TextColor3=C.cyan,ZIndex=83})
 U.LookCodeBox=T(U.LookDetail,"",{Position=UDim2.new(.40,8,0,90),Size=UDim2.new(.60,-98,0,28),Text="SEM CÓDIGO",TextEditable=false,ZIndex=83})
 U.LookCopy=B(U.LookDetail,"COPIAR",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,90),Size=UDim2.fromOffset(76,28),BackgroundColor3=C.card,ZIndex=83})
 U.LookTotal=L(U.LookDetail,"Valor total: calculando...",{Position=UDim2.new(.40,8,0,124),Size=UDim2.new(.60,-28,0,20),Font=Enum.Font.GothamBold,TextColor3=C.green,ZIndex=83})
 U.LookItems=F(U.LookDetail,{Position=UDim2.new(.40,8,0,151),Size=UDim2.new(.60,-20,1,-214),ZIndex=83})
 list(U.LookItems,false,5)
 U.LookTry=B(U.LookDetail,"EXPERIMENTAR",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(.40,8,1,-12),Size=UDim2.new(.28,-6,0,34),BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=83})
 U.LookBuy=B(U.LookDetail,"COMPRAR",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(.68,8,1,-12),Size=UDim2.new(.18,-6,0,34),BackgroundColor3=C.yellow,TextColor3=C.bg,ZIndex=83})
 U.LookFav=B(U.LookDetail,"CURTIR",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(.86,8,1,-12),Size=UDim2.new(.14,-20,0,34),BackgroundColor3=C.card,ZIndex=83})
 U.SaveBox=N("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.52),Size=UDim2.fromOffset(350,176),BackgroundColor3=C.panel,Visible=false,ZIndex=90},root)
 R(U.SaveBox,10);U.SaveName=T(U.SaveBox,"Nome da skin",{Position=UDim2.fromOffset(13,48),Size=UDim2.new(1,-26,0,34),ZIndex=91})
 U.SaveR15=B(U.SaveBox,"SALVAR R15",{Position=UDim2.fromOffset(13,94),Size=UDim2.fromOffset(153,31),BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=91})
 U.SaveR6=B(U.SaveBox,"SALVAR R6",{Position=UDim2.fromOffset(184,94),Size=UDim2.fromOffset(153,31),BackgroundColor3=C.card,ZIndex=91})
 U.CancelSave=B(U.SaveBox,"CANCELAR",{Position=UDim2.fromOffset(13,135),Size=UDim2.new(1,-26,0,27),BackgroundColor3=C.red,ZIndex=91})
 U.PublishBox=N("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(350,176),BackgroundColor3=C.panel,Visible=false,ZIndex=92},root)
 R(U.PublishBox,10);U.PublishName=T(U.PublishBox,"Nome do look",{Position=UDim2.fromOffset(13,70),Size=UDim2.new(1,-26,0,34),ZIndex=93})
 U.PublishConfirm=B(U.PublishBox,"CONFIRMAR PUBLICAÇÃO",{Position=UDim2.fromOffset(13,118),Size=UDim2.fromOffset(205,34),BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=93})
 U.PublishCancel=B(U.PublishBox,"CANCELAR",{Position=UDim2.fromOffset(228,118),Size=UDim2.fromOffset(109,34),BackgroundColor3=C.red,ZIndex=93})
 U.RigBox=N("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(330,150),BackgroundColor3=C.panel,Visible=false,ZIndex=94},root)
 R(U.RigBox,10);U.RigToR15=B(U.RigBox,"TESTAR EM R15",{Position=UDim2.fromOffset(13,94),Size=UDim2.fromOffset(147,34),BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=95})
 U.RigCancel=B(U.RigBox,"CANCELAR",{Position=UDim2.fromOffset(170,94),Size=UDim2.fromOffset(147,34),BackgroundColor3=C.red,ZIndex=95})
 U.Loader=N("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(5,7,10),BackgroundTransparency=.08,Visible=false,ZIndex=96},g)
 local lc=N("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.52),Size=UDim2.new(.72,0,.80,0),BackgroundColor3=C.panel,ZIndex=97},U.Loader)
 R(lc,12)
 U.LoaderClose=B(lc,"X",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,0,9),Size=UDim2.fromOffset(34,34),BackgroundColor3=C.soft,ZIndex=98})
 U.LoaderQuery=T(lc,"Nome de usuário ou ID...",{Position=UDim2.fromOffset(16,60),Size=UDim2.new(1,-122,0,38),ZIndex=98})
 U.LoaderSearch=B(lc,"BUSCAR",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-16,0,60),Size=UDim2.fromOffset(92,38),BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=98})
 U.LoaderThumb=N("ImageLabel",{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,112),Size=UDim2.new(.56,0,.48,0),BackgroundColor3=C.card,Image="",ScaleType=Enum.ScaleType.Fit,ZIndex=98},lc)
 R(U.LoaderThumb,10)
 U.LoaderName=L(lc,"Digite um usuário.",{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-76),Size=UDim2.new(1,-40,0,22),Font=Enum.Font.GothamBold,TextSize=10,ZIndex=98})
 U.LoaderStatus=L(lc,"Carrega o avatar atual desse usuário.",{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-54),Size=UDim2.new(1,-40,0,18),TextColor3=C.muted,ZIndex=98})
 U.LoaderUse=B(lc,"USAR NA PRÉVIA",{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-14),Size=UDim2.fromOffset(178,32),BackgroundColor3=C.green,TextColor3=C.bg,Visible=false,ZIndex=98})
 U.Toast=L(g,"",{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-10),Size=UDim2.new(.5,0,0,32),BackgroundTransparency=.02,BackgroundColor3=C.panel,Font=Enum.Font.GothamBold,Visible=false,ZIndex=120})
 R(U.Toast,9);S(U.Toast,nil,.5)
 U.EditorTabs=tabs;U.EditorMode="AVATAR"
 function U.LayoutEditor(mode)
  U.EditorMode=mode or U.EditorMode or"AVATAR"
  local h=math.max(220,left.AbsoluteSize.Y);local small=h<460
  local actionsH=small and 80 or 96;local tabsH=small and 32 or 36
  local reserve=small and 112 or(U.EditorMode=="AVATAR"and 100 or 154)
  local available=math.max(52,h-actionsH-tabsH-reserve-40)
  local vh=math.min(math.floor(h*(U.EditorMode=="AVATAR"and .54 or .43)),available)
  U.Viewport.Position=UDim2.fromOffset(8,8);U.Viewport.Size=UDim2.new(1,-16,0,vh)
  tabs.Position=UDim2.fromOffset(8,14+vh);tabs.Size=UDim2.new(1,-16,0,tabsH)
  local editY=20+vh+tabsH;local actionY=h-8-actionsH
  edit.Position=UDim2.fromOffset(8,editY);edit.Size=UDim2.new(1,-16,0,math.max(16,actionY-editY-6))
  actions.AnchorPoint=Vector2.zero;actions.Position=UDim2.fromOffset(8,actionY);actions.Size=UDim2.new(1,-16,0,actionsH)
 end
 function U.LayoutLooks()
  local h=math.max(220,sp.AbsoluteSize.Y);local narrow=sp.AbsoluteSize.X<220;local actionH=narrow and math.min(210,math.floor(h*.38))or 104;local actionY=h-8-actionH;local previewH=math.max(52,math.min(math.floor(h*.43),actionY-82))
  U.SavedPreview.Position=UDim2.fromOffset(8,8);U.SavedPreview.Size=UDim2.new(1,-16,0,previewH)
  U.OutfitSelected.Position=UDim2.fromOffset(8,14+previewH)
  U.SavedItems.Position=UDim2.fromOffset(8,40+previewH)
  U.SavedItems.Size=UDim2.new(1,-16,0,math.max(36,actionY-previewH-46))
  U.OutfitActions.Position=UDim2.new(0,8,1,-8);U.OutfitActions.Size=UDim2.new(1,-16,0,actionH);U.OutfitActions.CanvasSize=UDim2.fromOffset(0,narrow and 294 or 104)
  for i,b in ipairs({U.OutfitApply,U.OutfitUpdate,U.OutfitRestore,U.OutfitBuy,U.OutfitDelete,U.OutfitPublish})do local n=i-1
   b.Position=narrow and UDim2.fromOffset(0,n*50)or UDim2.new(n%2*.5,n%2==0 and 0 or 3,0,math.floor(n/2)*36);b.Size=narrow and UDim2.new(1,-4,0,44)or UDim2.new(.5,-3,0,30)end
 end
 local wide,previewOpen=true,false
 local function responsive()
  local w,h=root.AbsoluteSize.X,root.AbsoluteSize.Y;if w<1 or h<1 then return end
  local portrait=w<640;local lw=math.floor(w*.31)
  left.Visible=not wide and(not portrait or previewOpen)
  left.Position=UDim2.fromOffset(8,8)
  left.Size=portrait and UDim2.new(1,-16,1,-16)or UDim2.new(0,lw-12,1,-16)
  left.ZIndex=portrait and 25 or 1;U.HidePreview.Visible=portrait and previewOpen
  if wide or portrait then main.Position=UDim2.fromOffset(8,8);main.Size=UDim2.new(1,-16,1,-16)
  else main.Position=UDim2.fromOffset(lw+4,8);main.Size=UDim2.new(1,-lw-12,1,-16)end
  local mw=main.AbsoluteSize.X;local compact=mw<600
  U.Close.Position=UDim2.new(1,-8,0,8);U.Close.Size=UDim2.fromOffset(40,40)
  U.Query.Position=UDim2.fromOffset(10,8);U.Query.Size=UDim2.new(1,compact and -114 or -318,0,40)
  U.SearchGo.AnchorPoint=Vector2.new(1,0);U.SearchGo.Position=UDim2.new(1,compact and -56 or -260,0,8)
  U.Filter.Position=compact and UDim2.fromOffset(10,56)or UDim2.new(1,-252,0,8)
  U.Filter.Size=UDim2.fromOffset(86,36)
  U.Sort.Position=compact and UDim2.fromOffset(194,56)or UDim2.new(1,-56,0,8)
  U.Sort.Size=UDim2.fromOffset(compact and mw<340 and 86 or 102,36);U.Sort.AnchorPoint=compact and Vector2.zero or Vector2.new(1,0)
  U.Filter.AnchorPoint=Vector2.zero
  U.PreviewToggle.Position=UDim2.new(1,-104,0,56);U.PreviewToggle.Visible=portrait and not wide
  if compact then U.Sort.Position=UDim2.fromOffset(104,56)end
  categoryRow.Position=UDim2.fromOffset(10,compact and 100 or 56);categoryRow.Size=UDim2.new(1,-20,0,36)
  U.SubToggle.Size=UDim2.fromOffset(math.min(110,mw*.30),34)
  U.Groups.Size=UDim2.new(1,-U.SubToggle.Size.X.Offset-8,1,0)
  local gy=compact and 142 or 98;U.Grid.Position=UDim2.fromOffset(8,gy);U.Grid.Size=UDim2.new(1,-16,1,-gy-40)
  U.Status.Size=UDim2.new(1,-148,0,28);U.Status.TextSize=12
  U.More.Size=UDim2.fromOffset(128,32)
  U.SubsPopup.Position=UDim2.fromOffset(10,gy);U.SubsPopup.Size=UDim2.new(1,-20,0,154)
  U.FilterPanel.Size=UDim2.new(0,math.min(342,mw-16),0,226)
  U.Detail.Size=UDim2.new(0,math.min(300,mw-16),1,-16)
  U.Detail.CanvasSize=UDim2.fromOffset(0,400);U.Favorite.Size=UDim2.new(1,-24,0,36)
  local cw=U.CartPanel.AbsoluteSize.X;local narrowCart=cw<600
  U.CartTotal.Position=UDim2.new(0,16,1,narrowCart and -96 or -14);U.CartTotal.Size=UDim2.new(narrowCart and 1 or .38,narrowCart and -32 or 0,0,34)
  U.CartClear.Position=UDim2.new(0,16,1,-14);U.CartClear.AnchorPoint=Vector2.new(0,1);U.CartClear.Size=UDim2.fromOffset(88,44)
  U.CartBuySelected.Size=UDim2.new(1,-120,0,44);U.CartBuySelected.Position=UDim2.new(1,-16,1,-14)
  U.CartList.Size=UDim2.new(1,-28,1,narrowCart and -176 or -142)
  if not narrowCart then U.CartClear.Position=UDim2.new(1,-190,1,-14);U.CartClear.AnchorPoint=Vector2.new(1,1);U.CartBuySelected.Size=UDim2.fromOffset(168,44)end
  U.LayoutEditor(U.EditorMode);U.LayoutLooks()
 end
 function U.SetWide(v)wide=v==true;previewOpen=false;responsive()end
 function U.ShowPreview()wide=false;previewOpen=true;responsive()end
 U.PreviewToggle.Activated:Connect(U.ShowPreview)
 U.HidePreview.Activated:Connect(function()previewOpen=false;responsive()end)
 root:GetPropertyChangedSignal("AbsoluteSize"):Connect(responsive)
 main:GetPropertyChangedSignal("AbsoluteSize"):Connect(responsive);U.CartPanel:GetPropertyChangedSignal("AbsoluteSize"):Connect(responsive)
 function U.AnimateMode()end
 left:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()task.defer(function()U.LayoutEditor(U.EditorMode)end)end)
 sp:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()task.defer(U.LayoutLooks)end)
 task.defer(function()U.LayoutEditor(U.EditorMode)
 U.LayoutLooks()end)
 root:GetPropertyChangedSignal("Visible"):Connect(function()
  local launcher=pg:FindFirstChild("AvatarShopLauncherGui")
  if launcher then launcher.Enabled=not root.Visible end
 end)
 return U
end
print("[V39] 09A_SHOP_UI SAFE carregado de "..script:GetFullName())
return M
