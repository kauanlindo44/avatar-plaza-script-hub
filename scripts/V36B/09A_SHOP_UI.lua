-- 09A_SHOP_UI
-- ModuleScript | ReplicatedStorage
-- AVATAR PLAZA V36A - Shop Catalog Style: preview maior, layout de galeria e controles compactos.
-- Base V27.8.4 comprovada; resgate limpo sem require recursivo.

local M={VERSION="V27.8.10_CLEAN_RESCUE"}

local C={
 bg=Color3.fromRGB(7,18,31),panel=Color3.fromRGB(15,31,46),card=Color3.fromRGB(25,51,70),
 soft=Color3.fromRGB(36,74,98),white=Color3.fromRGB(248,252,255),muted=Color3.fromRGB(166,198,218),
 blue=Color3.fromRGB(35,168,235),cyan=Color3.fromRGB(70,218,255),green=Color3.fromRGB(73,224,137),
 red=Color3.fromRGB(239,82,101),yellow=Color3.fromRGB(255,213,82),purple=Color3.fromRGB(176,83,246),
 pink=Color3.fromRGB(246,92,160),orange=Color3.fromRGB(255,165,66)
}

local function N(class,props,parent)
 local o=Instance.new(class)
 for k,v in pairs(props or{}) do o[k]=v end
 if parent then o.Parent=parent end
 return o
end

local function R(o,n)
 local c=Instance.new("UICorner")
 c.CornerRadius=UDim.new(0,n or 8)
 c.Parent=o
 return c
end

local function S(o,col,t)
 local s=Instance.new("UIStroke")
 s.Color=col or C.cyan
 s.Transparency=t or .72
 s.Thickness=1
 s.Parent=o
 return s
end

local function L(parent,text,p)
 p=p or{}
 p.Text=text
 p.BackgroundTransparency=p.BackgroundTransparency==nil and 1 or p.BackgroundTransparency
 p.TextColor3=p.TextColor3 or C.white
 p.Font=p.Font or Enum.Font.Gotham
 p.TextSize=p.TextSize or 8
 p.TextWrapped=p.TextWrapped~=false
 return N("TextLabel",p,parent)
end

local function B(parent,text,p)
 p=p or{}
 p.Text=text
 p.BackgroundColor3=p.BackgroundColor3 or C.blue
 p.TextColor3=p.TextColor3 or C.white
 p.Font=p.Font or Enum.Font.GothamBold
 p.TextSize=p.TextSize or 8
 p.BorderSizePixel=0
 p.AutoButtonColor=true
 p.Accent=nil
 local b=N("TextButton",p,parent)
 R(b,8)
 return b
end

local function T(parent,placeholder,p)
 p=p or{}
 p.PlaceholderText=placeholder or""
 p.Text=p.Text or""
 p.ClearTextOnFocus=false
 p.BackgroundColor3=p.BackgroundColor3 or C.card
 p.TextColor3=p.TextColor3 or C.white
 p.PlaceholderColor3=p.PlaceholderColor3 or C.muted
 p.Font=p.Font or Enum.Font.Gotham
 p.TextSize=p.TextSize or 8
 p.BorderSizePixel=0
 local b=N("TextBox",p,parent)
 R(b,8)
 return b
end

local function F(parent,p)
 p=p or{}
 p.BackgroundTransparency=p.BackgroundTransparency==nil and 1 or p.BackgroundTransparency
 p.BorderSizePixel=0
 p.ScrollBarThickness=p.ScrollBarThickness or 3
 p.ScrollBarImageColor3=p.ScrollBarImageColor3 or C.cyan
 p.AutomaticCanvasSize=p.AutomaticCanvasSize or Enum.AutomaticSize.Y
 p.CanvasSize=p.CanvasSize or UDim2.new()
 return N("ScrollingFrame",p,parent)
end

local function list(parent,horizontal,pad)
 return N("UIListLayout",{
  FillDirection=horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
  Padding=UDim.new(0,pad or 5)
 },parent)
end

local function grid(parent,w,h)
 return N("UIGridLayout",{
  CellSize=UDim2.fromOffset(w,h),CellPadding=UDim2.fromOffset(8,8),
  HorizontalAlignment=Enum.HorizontalAlignment.Center
 },parent)
end

local function area(parent,name)
 return N("Frame",{Name=name,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false},parent)
end

function M.Build(pl)
 local pg=pl:WaitForChild("PlayerGui")
 for _,name in ipairs({"AvatarShop08Gui","AvatarShopLauncherGui"}) do
  local old=pg:FindFirstChild(name)
  if old then old:Destroy() end
 end

 local lg=N("ScreenGui",{Name="AvatarShopLauncherGui",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=84},pg)
 local launch=N("Frame",{Name="LauncherBar",Position=UDim2.fromOffset(0,0),Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0},lg)
 local g=N("ScreenGui",{Name="AvatarShop08Gui",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=90,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
 local U={Gui=g,LauncherGui=lg,Colors=C,New=N,Round=R,Text=L,Button=B}
 U.OpenRequest=N("BindableEvent",{Name="OpenRequest"},g)
 U.HudAction=N("BindableEvent",{Name="HudAction"},g)

 U.TopCatalog=B(launch,"CATÁLOGO",{Name="TopCatalog",AnchorPoint=Vector2.new(1,0),Position=UDim2.new(.5,-6,0,82),Size=UDim2.fromOffset(112,42),BackgroundColor3=Color3.fromRGB(15,16,22),TextSize=10})
 U.TopMusic=B(launch,"MÚSICA",{Name="TopMusic",AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-138,0,28),Size=UDim2.fromOffset(66,44),BackgroundColor3=Color3.fromRGB(15,16,22),TextSize=8})
 U.TopStores=B(launch,"LOJAS",{Name="TopStores",AnchorPoint=Vector2.new(0,0),Position=UDim2.new(.5,6,0,82),Size=UDim2.fromOffset(112,42),BackgroundColor3=Color3.fromRGB(15,16,22),TextSize=10})

 local root=N("Frame",{Name="ShopWindow",Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(12,14,19),BorderSizePixel=0,Visible=false},g)
 U.Root=root
 local left=N("Frame",{Position=UDim2.fromOffset(8,8),Size=UDim2.new(.28,-10,1,-16),BackgroundColor3=Color3.fromRGB(22,24,30),BorderSizePixel=0},root)
 R(left,10);S(left,C.soft,.45)
 local main=N("Frame",{Position=UDim2.new(.28,4,0,8),Size=UDim2.new(.72,-12,1,-16),BackgroundColor3=Color3.fromRGB(17,19,24),BorderSizePixel=0},root)
 R(main,10);S(main,C.soft,.45)
 U.Left=left;U.Main=main

 U.Viewport=N("ViewportFrame",{Position=UDim2.fromOffset(8,8),Size=UDim2.new(1,-16,.57,0),BackgroundColor3=Color3.fromRGB(96,112,127),Ambient=Color3.fromRGB(198,205,212),LightColor=Color3.fromRGB(255,255,255),LightDirection=Vector3.new(-1,-1,-1),BorderSizePixel=0},left)
 R(U.Viewport,9)
 U.PreviewInfo=L(U.Viewport,"PRÉVIA R15",{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-4),Size=UDim2.new(1,-8,0,18),TextColor3=C.cyan,Font=Enum.Font.GothamBold})
 U.ViewLeft=B(U.Viewport,"<",{AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,5,.5,0),Size=UDim2.fromOffset(28,36),BackgroundColor3=Color3.fromRGB(45,55,68),TextSize=15})
 U.ViewRight=B(U.Viewport,">",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-5,.5,0),Size=UDim2.fromOffset(28,36),BackgroundColor3=Color3.fromRGB(45,55,68),TextSize=15})
 U.ZoomIn=B(U.Viewport,"+",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-5,0,5),Size=UDim2.fromOffset(26,26),BackgroundColor3=Color3.fromRGB(44,49,59)})
 U.ZoomOut=B(U.Viewport,"-",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-5,0,35),Size=UDim2.fromOffset(26,26),BackgroundColor3=Color3.fromRGB(44,49,59)})
 U.RigBack=B(left,"VOLTAR R6",{Position=UDim2.new(0,8,.58,0),Size=UDim2.new(1,-16,0,24),BackgroundColor3=Color3.fromRGB(44,49,59),Visible=false})

 local tools=N("Frame",{Position=UDim2.new(0,8,.58,30),Size=UDim2.new(1,-16,0,32),BackgroundColor3=Color3.fromRGB(29,31,38),BackgroundTransparency=.04,BorderSizePixel=0},left);R(tools,9);S(tools,Color3.fromRGB(83,91,103),.7)
 U.SaveRoblox=B(tools,"RBLX",{Size=UDim2.new(.25,-3,1,0),BackgroundColor3=Color3.fromRGB(39,44,54)})
 U.Undo=B(tools,"UNDO",{Position=UDim2.new(.25,2,0,0),Size=UDim2.new(.25,-3,1,0),BackgroundColor3=Color3.fromRGB(39,44,54),TextSize=6})
 U.Redo=B(tools,"REDO",{Position=UDim2.new(.5,2,0,0),Size=UDim2.new(.25,-3,1,0),BackgroundColor3=Color3.fromRGB(39,44,54),TextSize=6})
 U.Blank=B(tools,"LIMPAR",{Position=UDim2.new(.75,2,0,0),Size=UDim2.new(.25,-3,1,0),BackgroundColor3=Color3.fromRGB(39,44,54),TextSize=6})
 U.Total=L(left,"0 itens",{Position=UDim2.new(0,8,.58,67),Size=UDim2.new(1,-16,0,18),TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Right})
 U.ItemStrip=F(left,{Position=UDim2.new(0,8,.58,87),Size=UDim2.new(1,-16,0,54),ScrollingDirection=Enum.ScrollingDirection.X,AutomaticCanvasSize=Enum.AutomaticSize.X,ScrollBarThickness=0})
 list(U.ItemStrip,true,5)
 U.Apply=B(left,"APLICAR",{Position=UDim2.new(0,8,1,-72),Size=UDim2.new(.5,-10,0,29),BackgroundColor3=Color3.fromRGB(38,43,52)})
 U.Save=B(left,"SALVAR",{Position=UDim2.new(.5,2,1,-72),Size=UDim2.new(.5,-10,0,29),BackgroundColor3=Color3.fromRGB(38,43,52)})
 U.Reset=B(left,"RESET",{Position=UDim2.new(0,8,1,-37),Size=UDim2.new(.5,-10,0,29),BackgroundColor3=Color3.fromRGB(38,43,52)})
 U.BuyLook=B(left,"CARRINHO",{Position=UDim2.new(.5,2,1,-37),Size=UDim2.new(.5,-10,0,29),BackgroundColor3=Color3.fromRGB(38,43,52)})

 U.Close=B(main,"X",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-8,0,7),Size=UDim2.fromOffset(34,32),BackgroundColor3=C.red,ZIndex=40})
 L(main,"CATÁLOGO",{Position=UDim2.fromOffset(12,8),Size=UDim2.new(1,-60,0,22),Font=Enum.Font.GothamBlack,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left})
 U.Query=T(main,"Pesquisar item...",{Position=UDim2.fromOffset(10,43),Size=UDim2.new(1,-238,0,32)})
 U.Filter=B(main,"FILTROS",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-142,0,43),Size=UDim2.fromOffset(90,32),BackgroundColor3=Color3.fromRGB(36,42,51)})
 U.Sort=B(main,"POPULAR",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-8,0,43),Size=UDim2.fromOffset(128,32),BackgroundColor3=Color3.fromRGB(36,42,51)})
 U.Groups=F(main,{Position=UDim2.fromOffset(10,80),Size=UDim2.new(1,-20,0,25),ScrollingDirection=Enum.ScrollingDirection.X,AutomaticCanvasSize=Enum.AutomaticSize.X,ScrollBarThickness=0})
 list(U.Groups,true,5)
 U.Subs=F(main,{Position=UDim2.fromOffset(10,109),Size=UDim2.new(1,-20,0,23),ScrollingDirection=Enum.ScrollingDirection.X,AutomaticCanvasSize=Enum.AutomaticSize.X,ScrollBarThickness=0})
 list(U.Subs,true,5)
 U.Grid=F(main,{Position=UDim2.fromOffset(8,138),Size=UDim2.new(1,-16,1,-170)})
 U.GridLayout=grid(U.Grid,124,164)
 U.Status=L(main,"",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,10,1,-6),Size=UDim2.new(1,-130,0,20),TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 U.More=B(main,"CARREGAR MAIS",{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-8,1,-5),Size=UDim2.fromOffset(110,24)})

 U.FilterPanel=N("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-8,0,80),Size=UDim2.fromOffset(292,220),BackgroundColor3=C.panel,Visible=false,ZIndex=50},main)
 R(U.FilterPanel,10)
 U.CloseFilter=B(U.FilterPanel,"X",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-6,0,5),Size=UDim2.fromOffset(28,28),BackgroundColor3=C.red,ZIndex=51})
 U.Min=T(U.FilterPanel,"Preço mínimo",{Position=UDim2.fromOffset(10,38),Size=UDim2.new(.5,-15,0,27),ZIndex=51})
 U.Max=T(U.FilterPanel,"Preço máximo",{Position=UDim2.new(.5,5,0,38),Size=UDim2.new(.5,-15,0,27),ZIndex=51})
 U.Creator=T(U.FilterPanel,"Criador",{Position=UDim2.fromOffset(10,70),Size=UDim2.new(.58,-15,0,27),ZIndex=51})
 U.CreatorType=B(U.FilterPanel,"Todos os criadores",{Position=UDim2.new(.58,5,0,70),Size=UDim2.new(.42,-15,0,27),BackgroundColor3=C.purple,ZIndex=51,TextSize=6})
 U.LimAll=B(U.FilterPanel,"TODOS",{Position=UDim2.fromOffset(10,102),Size=UDim2.new(.33,-8,0,24),ZIndex=51})
 U.LimOnly=B(U.FilterPanel,"LIMITED",{Position=UDim2.new(.33,4,0,102),Size=UDim2.new(.33,-7,0,24),BackgroundColor3=C.yellow,TextColor3=C.bg,ZIndex=51})
 U.LimNo=B(U.FilterPanel,"SEM LIMITED",{Position=UDim2.new(.66,2,0,102),Size=UDim2.new(.34,-12,0,24),BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=51,TextSize=6})
 U.FormAll=B(U.FilterPanel,"TODOS",{Position=UDim2.fromOffset(10,132),Size=UDim2.new(.25,-6,0,24),ZIndex=51})
 U.FormClassic=B(U.FilterPanel,"CLÁSSICO",{Position=UDim2.new(.25,3,0,132),Size=UDim2.new(.25,-6,0,24),BackgroundColor3=C.orange,TextColor3=C.bg,ZIndex=51})
 U.Form2D=B(U.FilterPanel,"2D",{Position=UDim2.new(.5,2,0,132),Size=UDim2.new(.25,-6,0,24),BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=51})
 U.Form3D=B(U.FilterPanel,"3D",{Position=UDim2.new(.75,1,0,132),Size=UDim2.new(.25,-11,0,24),BackgroundColor3=C.pink,ZIndex=51})
 U.OffSale=B(U.FilterPanel,"Fora de venda: NÃO",{Position=UDim2.fromOffset(10,160),Size=UDim2.new(1,-20,0,20),BackgroundColor3=C.soft,ZIndex=51})
 U.ClearFilter=B(U.FilterPanel,"LIMPAR",{Position=UDim2.fromOffset(10,184),Size=UDim2.new(.36,-6,0,27),BackgroundColor3=C.red,ZIndex=51})
 U.ApplyFilter=B(U.FilterPanel,"APLICAR FILTROS",{Position=UDim2.new(.36,4,0,184),Size=UDim2.new(.64,-14,0,27),ZIndex=51})

 U.Detail=N("Frame",{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-34),Size=UDim2.new(.92,0,0,72),BackgroundColor3=Color3.fromRGB(24,27,34),Visible=false,ZIndex=35},main)
 R(U.Detail,9)
 U.DetailImage=N("ImageLabel",{Position=UDim2.fromOffset(6,6),Size=UDim2.fromOffset(54,54),BackgroundColor3=C.card,ScaleType=Enum.ScaleType.Fit,ZIndex=36},U.Detail)
 U.DetailName=L(U.Detail,"Item",{Position=UDim2.fromOffset(66,7),Size=UDim2.new(.36,-66,0,20),Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=36})
 U.DetailPrice=L(U.Detail,"",{Position=UDim2.fromOffset(66,31),Size=UDim2.new(.36,-66,0,18),TextColor3=C.green,ZIndex=36})
 U.Try=B(U.Detail,"VESTIR",{Position=UDim2.new(.38,0,0,19),Size=UDim2.fromOffset(86,32),BackgroundColor3=Color3.fromRGB(44,50,60),ZIndex=36})
 U.Buy=B(U.Detail,"COMPRAR",{Position=UDim2.new(.38,92,0,19),Size=UDim2.fromOffset(88,32),BackgroundColor3=Color3.fromRGB(44,50,60),ZIndex=36})
 U.Favorite=B(U.Detail,"FAV",{Position=UDim2.new(.38,186,0,19),Size=UDim2.fromOffset(48,32),BackgroundColor3=Color3.fromRGB(44,50,60),TextSize=7,ZIndex=36})
 U.DetailClose=B(U.Detail,"X",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-6,0,6),Size=UDim2.fromOffset(28,28),BackgroundColor3=Color3.fromRGB(44,50,60),ZIndex=36})

 U.LooksArea=area(main,"LooksArea")
 local sp=F(U.LooksArea,{Position=UDim2.fromOffset(6,6),Size=UDim2.new(.38,-9,1,-12),BackgroundTransparency=0,BackgroundColor3=Color3.fromRGB(18,19,24)})
 R(sp,10);U.SavedPreviewPanel=sp
 U.SavedPreview=N("ViewportFrame",{Position=UDim2.fromOffset(8,8),Size=UDim2.new(1,-16,.58,0),BackgroundColor3=Color3.fromRGB(96,112,127),Ambient=Color3.fromRGB(198,205,212),LightColor=Color3.fromRGB(255,255,255),LightDirection=Vector3.new(-1,-1,-1),BorderSizePixel=0},sp)
 R(U.SavedPreview,9)
 U.SavedLeft=B(U.SavedPreview,"<",{AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,6,.5,0),Size=UDim2.fromOffset(30,42),BackgroundColor3=Color3.fromRGB(44,49,59),TextSize=15})
 U.SavedRight=B(U.SavedPreview,">",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-6,.5,0),Size=UDim2.fromOffset(30,42),BackgroundColor3=Color3.fromRGB(44,49,59),TextSize=15})
 U.SavedZoomIn=B(U.SavedPreview,"+",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-6,0,6),Size=UDim2.fromOffset(28,28),BackgroundColor3=Color3.fromRGB(44,49,59)})
 U.SavedZoomOut=B(U.SavedPreview,"-",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-6,0,39),Size=UDim2.fromOffset(28,28),BackgroundColor3=Color3.fromRGB(44,49,59)})
 U.OutfitSelected=L(sp,"Selecione uma skin.",{Position=UDim2.new(0,10,.59,0),Size=UDim2.new(1,-150,0,34),Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})
 U.OutfitPublish=B(sp,"PUBLICAR",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-8,.59,0),Size=UDim2.fromOffset(126,34),BackgroundColor3=C.purple,Visible=false})
 U.SavedItems=F(sp,{Position=UDim2.new(0,8,.59,42),Size=UDim2.new(1,-16,0,52),ScrollingDirection=Enum.ScrollingDirection.X,AutomaticCanvasSize=Enum.AutomaticSize.X,ScrollBarThickness=0})
 list(U.SavedItems,true,5)
 U.OutfitActions=N("Frame",{Position=UDim2.new(0,8,.59,101),Size=UDim2.new(1,-16,0,120),BackgroundTransparency=1,Visible=false},sp)
 U.OutfitApply=B(U.OutfitActions,"CARREGAR PRÉVIA",{Size=UDim2.new(1,0,0,36)})
 U.OutfitUpdate=B(U.OutfitActions,"SALVAR ALTERAÇÕES",{Position=UDim2.fromOffset(0,42),Size=UDim2.new(.56,-3,0,32),BackgroundColor3=C.green,TextColor3=C.bg})
 U.OutfitRestore=B(U.OutfitActions,"RESTAURAR",{Position=UDim2.new(.56,3,0,42),Size=UDim2.new(.44,-3,0,32),BackgroundColor3=C.orange,TextColor3=C.bg})
 U.OutfitBuy=B(U.OutfitActions,"COMPRAR ITENS",{Position=UDim2.fromOffset(0,80),Size=UDim2.new(.56,-3,0,32),BackgroundColor3=C.yellow,TextColor3=C.bg})
 U.OutfitDelete=B(U.OutfitActions,"EXCLUIR",{Position=UDim2.new(.56,3,0,80),Size=UDim2.new(.44,-3,0,32),BackgroundColor3=C.red})

 local gs=N("Frame",{Position=UDim2.new(.38,3,0,6),Size=UDim2.new(.62,-9,1,-12),BackgroundColor3=Color3.fromRGB(16,17,22),BorderSizePixel=0},U.LooksArea)
 R(gs,10);U.SavedGridShell=gs
 U.SavedCount=L(gs,"0 skins",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,0,8),Size=UDim2.fromOffset(80,20),TextColor3=C.cyan,TextXAlignment=Enum.TextXAlignment.Right})
 U.OutfitSaveNew=B(gs,"+ SALVAR NOVA SKIN",{Position=UDim2.fromOffset(10,34),Size=UDim2.new(.48,-14,0,34),BackgroundColor3=C.purple})
 U.LookSearch=T(gs,"Pesquisar skins...",{Position=UDim2.new(.48,4,0,34),Size=UDim2.new(.52,-14,0,34)})
 U.SavedGrid=F(gs,{Position=UDim2.fromOffset(6,76),Size=UDim2.new(1,-12,1,-82)})
 grid(U.SavedGrid,142,168)

 U.CommunityArea=area(main,"CommunityArea")
 local cg=N("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(12,13,18),BorderSizePixel=0},U.CommunityArea)
 R(cg,10)
 U.CommunityGrid=F(cg,{Position=UDim2.fromOffset(6,6),Size=UDim2.new(1,-12,1,-38)})
 grid(U.CommunityGrid,168,202)
 U.CommunityStatus=L(cg,"",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,10,1,-5),Size=UDim2.new(1,-116,0,20),TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 U.ComMore=B(cg,"MAIS",{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-7,1,-5),Size=UDim2.fromOffset(96,24),Visible=false})
 U.ComGridTitle=L(cg,"",{Visible=false});U.ComCount=L(cg,"",{Visible=false})
 local cm=N("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-8,0,8),Size=UDim2.fromOffset(178,124),BackgroundColor3=Color3.fromRGB(21,22,28),ZIndex=20},U.CommunityArea)
 R(cm,10)
 U.ComMyOutfits=B(cm,"MEUS OUTFITS",{Position=UDim2.fromOffset(8,8),Size=UDim2.new(1,-16,0,25),BackgroundColor3=C.purple,ZIndex=21})
 local ct=N("Frame",{Position=UDim2.fromOffset(8,39),Size=UDim2.new(1,-16,0,25),BackgroundTransparency=1,ZIndex=21},cm)
 U.ComSearch=T(ct,"Pesquisar...",{Size=UDim2.new(1,-56,1,0),ZIndex=22})
 U.ComSearchGo=B(ct,"IR",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-27,0,0),Size=UDim2.fromOffset(27,25),ZIndex=22})
 U.ComRefresh=B(ct,"↻",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),Size=UDim2.fromOffset(24,25),BackgroundColor3=C.soft,ZIndex=22})
 local tabs=F(cm,{Position=UDim2.fromOffset(8,70),Size=UDim2.new(1,-16,0,30),ScrollingDirection=Enum.ScrollingDirection.X,AutomaticCanvasSize=Enum.AutomaticSize.X,ScrollBarThickness=0,ZIndex=21})
 list(tabs,true,4);U.ComTabButtons={}
 for _,name in ipairs({"NOVOS","EM ALTA","MAIS CURTIDOS","LOOK DA SEMANA"}) do
  U.ComTabButtons[name]=B(tabs,name,{Size=UDim2.fromOffset(name=="LOOK DA SEMANA" and 92 or 70,26),BackgroundColor3=name=="NOVOS" and C.blue or C.soft,ZIndex=22,TextSize=5})
 end
 U.ComFeatured=N("Frame",{Size=UDim2.fromOffset(1,1),BackgroundTransparency=1,Visible=false},cg)
 U.ComFeaturedEyebrow=L(U.ComFeatured,"",{Visible=false})
 U.ComFeaturedPreview=N("ViewportFrame",{Size=UDim2.fromOffset(1,1),BackgroundTransparency=1,Visible=false},U.ComFeatured)
 U.ComFeaturedName=L(U.ComFeatured,"",{Visible=false});U.ComFeaturedCreator=L(U.ComFeatured,"",{Visible=false});U.ComFeaturedMeta=L(U.ComFeatured,"",{Visible=false})
 U.ComFeaturedOpen=B(U.ComFeatured,"",{Size=UDim2.fromOffset(1,1),Visible=false})

 U.StoresArea=area(main,"StoresArea")
 U.StoreSearch=T(U.StoresArea,"Nome exato do criador ou grupo...",{Position=UDim2.fromOffset(8,50),Size=UDim2.new(1,-190,0,34)})
 U.StoreType=B(U.StoresArea,"CRIADOR",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-92,0,50),Size=UDim2.fromOffset(90,34),BackgroundColor3=C.purple})
 U.StoreGo=B(U.StoresArea,"BUSCAR",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,50),Size=UDim2.fromOffset(84,34),BackgroundColor3=C.pink})
 U.StoreGrid=F(U.StoresArea,{Position=UDim2.fromOffset(4,92),Size=UDim2.new(1,-8,1,-122)})
 grid(U.StoreGrid,148,176)
 U.StoreStatus=L(U.StoresArea,"Digite um criador ou grupo.",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,4,1,-2),Size=UDim2.new(1,-8,0,20),TextColor3=C.muted})

 U.LookDetail=N("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.new(.94,0,.9,0),BackgroundColor3=Color3.fromRGB(17,18,23),Visible=false,ZIndex=70},root)
 R(U.LookDetail,11)
 U.LookClose=B(U.LookDetail,"X",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-8,0,7),Size=UDim2.fromOffset(34,34),BackgroundColor3=C.red,ZIndex=71})
 U.LookPreview=N("ViewportFrame",{Position=UDim2.fromOffset(12,12),Size=UDim2.new(.38,-18,1,-70),BackgroundColor3=Color3.fromRGB(96,112,127),Ambient=Color3.fromRGB(198,205,212),LightColor=Color3.fromRGB(255,255,255),LightDirection=Vector3.new(-1,-1,-1),BorderSizePixel=0,ZIndex=71},U.LookDetail)
 U.LookName=L(U.LookDetail,"LOOK",{Position=UDim2.new(.38,8,0,15),Size=UDim2.new(.62,-58,0,24),Font=Enum.Font.GothamBlack,TextSize=12,ZIndex=71})
 U.LookCreator=L(U.LookDetail,"Criador",{Position=UDim2.new(.38,8,0,43),Size=UDim2.new(.62,-28,0,18),TextColor3=C.muted,ZIndex=71})
 U.LookMeta=L(U.LookDetail,"RIG",{Position=UDim2.new(.38,8,0,64),Size=UDim2.new(.62,-28,0,18),TextColor3=C.cyan,ZIndex=71})
 U.LookCodeBox=T(U.LookDetail,"",{Position=UDim2.new(.38,8,0,90),Size=UDim2.new(.62,-96,0,28),Text="SEM CÓDIGO",TextEditable=false,ZIndex=71})
 U.LookCopy=B(U.LookDetail,"COPIAR",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,90),Size=UDim2.fromOffset(74,28),BackgroundColor3=C.purple,ZIndex=71})
 U.LookTotal=L(U.LookDetail,"Valor total: calculando...",{Position=UDim2.new(.38,8,0,124),Size=UDim2.new(.62,-28,0,20),Font=Enum.Font.GothamBold,TextColor3=C.green,ZIndex=71})
 U.LookItems=F(U.LookDetail,{Position=UDim2.new(.38,8,0,151),Size=UDim2.new(.62,-20,1,-214),ZIndex=71})
 list(U.LookItems,false,4)
 U.LookTry=B(U.LookDetail,"EXPERIMENTAR",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(.38,8,1,-12),Size=UDim2.new(.28,-6,0,34),ZIndex=71})
 U.LookBuy=B(U.LookDetail,"COMPRAR",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(.66,8,1,-12),Size=UDim2.new(.19,-6,0,34),BackgroundColor3=C.yellow,TextColor3=C.bg,ZIndex=71})
 U.LookFav=B(U.LookDetail,"♡ CURTIR",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(.85,8,1,-12),Size=UDim2.new(.15,-20,0,34),BackgroundColor3=C.pink,ZIndex=71})

 U.SaveBox=N("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.52),Size=UDim2.fromOffset(350,176),BackgroundColor3=C.panel,Visible=false,ZIndex=85},root)
 R(U.SaveBox,10)
 U.SaveName=T(U.SaveBox,"Nome da skin",{Position=UDim2.fromOffset(13,48),Size=UDim2.new(1,-26,0,34),ZIndex=86})
 U.SaveR15=B(U.SaveBox,"SALVAR R15",{Position=UDim2.fromOffset(13,94),Size=UDim2.fromOffset(153,31),ZIndex=86})
 U.SaveR6=B(U.SaveBox,"SALVAR R6",{Position=UDim2.fromOffset(184,94),Size=UDim2.fromOffset(153,31),BackgroundColor3=C.purple,ZIndex=86})
 U.CancelSave=B(U.SaveBox,"CANCELAR",{Position=UDim2.fromOffset(13,135),Size=UDim2.new(1,-26,0,27),BackgroundColor3=C.red,ZIndex=86})

 U.PublishBox=N("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(350,176),BackgroundColor3=C.panel,Visible=false,ZIndex=88},root)
 R(U.PublishBox,10)
 U.PublishName=T(U.PublishBox,"Nome do look",{Position=UDim2.fromOffset(13,70),Size=UDim2.new(1,-26,0,34),ZIndex=89})
 U.PublishConfirm=B(U.PublishBox,"CONFIRMAR PUBLICAÇÃO",{Position=UDim2.fromOffset(13,118),Size=UDim2.fromOffset(205,34),BackgroundColor3=C.yellow,TextColor3=C.bg,ZIndex=89})
 U.PublishCancel=B(U.PublishBox,"CANCELAR",{Position=UDim2.fromOffset(228,118),Size=UDim2.fromOffset(109,34),BackgroundColor3=C.red,ZIndex=89})

 U.RigBox=N("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(330,150),BackgroundColor3=C.panel,Visible=false,ZIndex=92},root)
 R(U.RigBox,10)
 U.RigToR15=B(U.RigBox,"TROCAR PARA R15",{Position=UDim2.fromOffset(13,94),Size=UDim2.fromOffset(147,34),BackgroundColor3=C.pink,ZIndex=93})
 U.RigCancel=B(U.RigBox,"CANCELAR",{Position=UDim2.fromOffset(170,94),Size=UDim2.fromOffset(147,34),BackgroundColor3=C.red,ZIndex=93})

 U.Loader=N("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(3,12,20),BackgroundTransparency=.1,Visible=false,ZIndex=94},g)
 local lc=N("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.52),Size=UDim2.new(.72,0,.8,0),BackgroundColor3=C.panel,ZIndex=95},U.Loader)
 R(lc,10)
 U.LoaderClose=B(lc,"X",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,0,9),Size=UDim2.fromOffset(34,34),BackgroundColor3=C.red,ZIndex=96})
 U.LoaderQuery=T(lc,"Nome de usuário...",{Position=UDim2.fromOffset(16,60),Size=UDim2.new(1,-122,0,38),ZIndex=96})
 U.LoaderSearch=B(lc,"BUSCAR",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-16,0,60),Size=UDim2.fromOffset(92,38),ZIndex=96})
 U.LoaderThumb=N("ImageLabel",{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,112),Size=UDim2.new(.56,0,.48,0),BackgroundColor3=C.card,Image="",ScaleType=Enum.ScaleType.Fit,ZIndex=96},lc)
 U.LoaderName=L(lc,"Digite um usuário.",{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-76),Size=UDim2.new(1,-40,0,22),Font=Enum.Font.GothamBold,TextSize=10,ZIndex=96})
 U.LoaderStatus=L(lc,"Carrega o avatar atual desse usuário.",{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-54),Size=UDim2.new(1,-40,0,18),TextColor3=C.muted,ZIndex=96})
 U.LoaderUse=B(lc,"USAR NA PRÉVIA",{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-14),Size=UDim2.fromOffset(178,32),BackgroundColor3=C.green,TextColor3=C.bg,Visible=false,ZIndex=96})

 U.Toast=L(g,"",{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-10),Size=UDim2.new(.5,0,0,31),BackgroundTransparency=0,BackgroundColor3=C.panel,Font=Enum.Font.GothamBold,Visible=false,ZIndex=120})
 R(U.Toast,8)

 function U.SetWide(v)
  local wide=v==true
  left.Visible=not wide
  if wide then
   main.Position=UDim2.fromOffset(6,6);main.Size=UDim2.new(1,-12,1,-12)
  else
   main.Position=UDim2.new(.28,4,0,8);main.Size=UDim2.new(.72,-12,1,-16)
  end
 end
 function U.AnimateMode() end
 root:GetPropertyChangedSignal("Visible"):Connect(function()lg.Enabled=not root.Visible end)

 return U
end

print("[V36B] 09A_SHOP_UI Shop Gallery + HUD launcher carregado de "..script:GetFullName())
return M
-- END V27.8.10 CLEAN RESCUE
