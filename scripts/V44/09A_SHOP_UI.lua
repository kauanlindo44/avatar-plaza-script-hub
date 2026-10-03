-- 09A_SHOP_UI
-- ModuleScript | ReplicatedStorage
local M={VERSION="V44_STUDIO_UI"}
local D=require(game:GetService("ReplicatedStorage"):WaitForChild("07UI_DESIGN_SYSTEM"))
local C=D.Colors
local N,R,S,L,B,T,F=D.New,D.Round,D.Stroke,D.Text,D.Button,D.Box,D.Scroll
local pad=D.Pad
local function list(p,h,g)return N("UIListLayout",{FillDirection=h and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,Padding=UDim.new(0,g or 5)},p)end
local function grid(p,w,h,g)return N("UIGridLayout",{CellSize=UDim2.fromOffset(w,h),CellPadding=UDim2.fromOffset(g or 8,g or 8),HorizontalAlignment=Enum.HorizontalAlignment.Center},p)end
local function area(p,name)return N("Frame",{Name=name,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false},p)end
function M.Build(pl)
 local pg=pl:WaitForChild("PlayerGui")
 local old=pg:FindFirstChild("AvatarShop08Gui")
 if old then old:Destroy()end
 local g=N("ScreenGui",{
  Name="AvatarShop08Gui",ResetOnSpawn=false,IgnoreGuiInset=true,ScreenInsets=Enum.ScreenInsets.None,
  SafeAreaCompatibility=Enum.SafeAreaCompatibility.None,ClipToDeviceSafeArea=false,
  DisplayOrder=90,ZIndexBehavior=Enum.ZIndexBehavior.Sibling
 },pg)
 local U={Gui=g,LauncherGui=pg:FindFirstChild("AvatarShopLauncherGui"),
  Colors=C,New=N,Round=R,Text=L,Button=B
 }
 U.OpenRequest=N("BindableEvent",{Name="OpenRequest"},g)
 U.HudAction=N("BindableEvent",{Name="HudAction"},g)
 local guide=N("ScreenGui",{Name="AvatarShop08Gui_SafeGuide",ResetOnSpawn=false,IgnoreGuiInset=false,DisplayOrder=0,ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets},pg)
 U.SafeGuide=N("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Active=false,Selectable=false},guide)
 g.Destroying:Connect(function()guide:Destroy()end)
 local root=N("Frame",{Name="ShopWindow",Size=UDim2.fromScale(1,1),BackgroundColor3=C.bg,BorderSizePixel=0,Visible=false},g);U.Root=root
 local left=N("Frame",{Position=UDim2.fromOffset(8,8),Size=UDim2.new(.30,-10,1,-16),BackgroundColor3=C.panel,BorderSizePixel=0},root)
 R(left,12)
 S(left,nil,.52)
 U.Left=left;local main=N("Frame",{Position=UDim2.new(.30,4,0,8),Size=UDim2.new(.70,-12,1,-16),BackgroundColor3=Color3.fromRGB(29,31,36),BorderSizePixel=0},root)
 R(main,12)
 S(main,nil,.55)
 U.Main=main
 U.PageTitle=L(main,"",{Font=Enum.Font.GothamBold,TextSize=22,TextXAlignment=Enum.TextXAlignment.Left,Visible=false})
 U.Viewport=N("ViewportFrame",{
  Position=UDim2.fromOffset(8,8),Size=UDim2.new(1,-16,.57,0),
  BackgroundColor3=Color3.fromRGB(126,135,149),Ambient=Color3.fromRGB(232,234,238),
  LightColor=Color3.fromRGB(255,255,255),LightDirection=Vector3.new(-.55,-1,-.42),BorderSizePixel=0
 },left)
 R(U.Viewport,10)
 N("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(151,162,180),Color3.fromRGB(100,110,128)),Rotation=90},U.Viewport)
 U.PreviewInfo=L(U.Viewport,"R15",{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-6),Size=UDim2.new(1,-16,0,20),Font=Enum.Font.GothamBold,TextColor3=C.white,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd})
 U.ViewLeft=B(U.Viewport,"<",{AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,6,.5,0),Size=UDim2.fromOffset(30,38),BackgroundColor3=Color3.fromRGB(35,39,47),TextSize=15})
 U.ViewRight=B(U.Viewport,">",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-6,.5,0),Size=UDim2.fromOffset(30,38),BackgroundColor3=Color3.fromRGB(35,39,47),TextSize=15})
 U.ZoomIn=B(U.Viewport,"+",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-6,0,6),Size=UDim2.fromOffset(28,28),BackgroundColor3=Color3.fromRGB(35,39,47),TextSize=12})
 U.ZoomOut=B(U.Viewport,"-",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-6,0,39),Size=UDim2.fromOffset(28,28),BackgroundColor3=Color3.fromRGB(35,39,47),TextSize=12})
 U.RigBack=B(left,"VOLTAR R6",{Visible=false})
 U.StopEmote=B(U.Viewport,"PARAR EMOTE",{Position=UDim2.fromOffset(8,8),Size=UDim2.fromOffset(124,36),BackgroundColor3=C.soft,Visible=false,ZIndex=5})
 U.EditorTabButtons={};U.EditorMode="AVATAR"
 U.Tools=N("Frame",{Visible=false,Size=UDim2.fromOffset(1,1),BackgroundTransparency=1},left)
 for _,key in ipairs({"SaveRoblox","Undo","Redo","Blank"})do U[key]=B(U.Tools,key,{Visible=false})end
 U.Total=L(left,"Itens",{TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,TextSize=13,TextWrapped=false})
 U.ItemStrip=F(left,{ScrollingDirection=Enum.ScrollingDirection.X,AutomaticCanvasSize=Enum.AutomaticSize.X,ScrollBarThickness=3})
 list(U.ItemStrip,true,6);U.ItemsPanel=U.ItemStrip
 U.BodyToggle=B(left,"CONFIGURAR CORPO",{BackgroundColor3=C.soft,TextSize=14})
 U.BodyWindow=N("Frame",{Name="BodySettings",BackgroundColor3=C.panel,BorderSizePixel=0,Visible=false,ZIndex=50},root)
 R(U.BodyWindow,10);S(U.BodyWindow,nil,.25)
 L(U.BodyWindow,"Configurar corpo",{Position=UDim2.fromOffset(10,4),Size=UDim2.new(1,-60,0,40),Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,TextSize=16,ZIndex=51})
 U.BodyClose=D.IconButton(U.BodyWindow,"BodyClose","close","Fechar",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-6,0,4),Size=UDim2.fromOffset(48,48),ZIndex=52})
 U.BodyApply=B(U.BodyWindow,"Aplicar no jogo",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,8,1,-8),Size=UDim2.new(1,-16,0,40),BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=52})
 U.BodyPanel=F(U.BodyWindow,{Position=UDim2.fromOffset(4,48),Size=UDim2.new(1,-8,1,-104),ZIndex=51,AutomaticCanvasSize=Enum.AutomaticSize.None,CanvasSize=UDim2.fromOffset(0,402)})
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
 local ag=N("UIGridLayout",{CellSize=UDim2.new(.5,-4,.5,-4),CellPadding=UDim2.fromOffset(8,8),FillDirectionMaxCells=2},actions);U.ActionGrid=ag
 U.Apply=B(actions,"Aplicar",{BackgroundColor3=C.green,TextColor3=C.bg})
 U.Save=B(actions,"Salvar",{BackgroundColor3=C.card})
 U.Reset=B(actions,"Restaurar",{BackgroundColor3=Color3.fromRGB(48,51,58)})
 U.BuyLook=B(actions,"Carrinho",{BackgroundColor3=Color3.fromRGB(48,51,58)})
 U.Close=D.IconButton(main,"Close","close","Fechar",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-8,0,8),Size=UDim2.fromOffset(48,48),BackgroundColor3=C.soft,ZIndex=40})
 U.Query=T(main,"Pesquisar itens...",{Position=UDim2.fromOffset(10,10),Size=UDim2.new(1,-238,0,34)})
 U.Filter=B(main,"FILTRO",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-136,0,10),Size=UDim2.fromOffset(88,34),BackgroundColor3=C.card,TextSize=7})
 U.Sort=B(main,"POPULAR",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-46,0,10),Size=UDim2.fromOffset(86,34),BackgroundColor3=C.card,TextSize=7})
 U.SearchGo=B(main,"IR",{Size=UDim2.fromOffset(40,40),BackgroundColor3=C.green,TextColor3=C.bg})
 U.PreviewToggle=B(main,"AVATAR",{Size=UDim2.fromOffset(96,36),BackgroundColor3=C.soft,Visible=false})
 U.HidePreview=D.IconButton(U.Viewport,"HidePreview","close","Fechar",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-44,0,10),Size=UDim2.fromOffset(48,48),Visible=false,ZIndex=15})
 local categoryRow=N("Frame",{Position=UDim2.fromOffset(10,51),Size=UDim2.new(1,-20,0,31),BackgroundTransparency=1},main)
 U.SubToggle=B(categoryRow,"EM ALTA",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),Size=UDim2.fromOffset(102,28),BackgroundColor3=Color3.fromRGB(62,65,72),TextSize=6})
 U.Groups=F(categoryRow,{Size=UDim2.new(1,-110,1,0),ScrollingDirection=Enum.ScrollingDirection.X,AutomaticCanvasSize=Enum.AutomaticSize.X,ScrollBarThickness=0})
 list(U.Groups,true,6)
 U.Grid=F(main,{Position=UDim2.fromOffset(8,88),Size=UDim2.new(1,-16,1,-124)});U.GridLayout=grid(U.Grid,132,174,8)
 U.Status=L(main,"",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,10,1,-8),Size=UDim2.new(1,-146,0,22),TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 U.More=B(main,"CARREGAR MAIS",{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-8,1,-7),Size=UDim2.fromOffset(124,28),BackgroundColor3=C.card,TextSize=6})
 U.SubsPopup=N("Frame",{Position=UDim2.new(0,10,0,84),Size=UDim2.new(1,-20,0,118),BackgroundColor3=Color3.fromRGB(29,31,36),BorderSizePixel=0,Visible=false,ZIndex=58},main)
 R(U.SubsPopup,10)
 S(U.SubsPopup,nil,.45)
 U.Subs=F(U.SubsPopup,{Position=UDim2.fromOffset(7,7),Size=UDim2.new(1,-14,1,-14),ZIndex=59});U.SubsLayout=grid(U.Subs,112,28,6);U.SubsLayout.FillDirectionMaxCells=4
 U.FilterPanel=F(main,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-8,0,54),Size=UDim2.fromOffset(342,338),BackgroundColor3=C.panel,BackgroundTransparency=0,Visible=false,ZIndex=65,AutomaticCanvasSize=Enum.AutomaticSize.None,CanvasSize=UDim2.fromOffset(0,338)})
 R(U.FilterPanel,10);S(U.FilterPanel,nil,.45)
 L(U.FilterPanel,"Filtros",{Position=UDim2.fromOffset(14,8),Size=UDim2.new(1,-60,0,28),Font=Enum.Font.GothamBold,TextSize=18,ZIndex=66,TextXAlignment=Enum.TextXAlignment.Left})
 U.CloseFilter=D.IconButton(U.FilterPanel,"CloseFilter","close","Fechar",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-8,0,8),Size=UDim2.fromOffset(48,48),ZIndex=66})
 U.Min=T(U.FilterPanel,"Preço mínimo",{Position=UDim2.fromOffset(10,62),Size=UDim2.new(.5,-15,0,38),ZIndex=66})
 U.Max=T(U.FilterPanel,"Preço máximo",{Position=UDim2.new(.5,5,0,62),Size=UDim2.new(.5,-15,0,38),ZIndex=66})
 U.Creator=T(U.FilterPanel,"Criador",{Position=UDim2.fromOffset(10,96),Size=UDim2.new(.55,-15,0,38),ZIndex=66})
 U.CreatorType=B(U.FilterPanel,"Todos criadores",{Position=UDim2.new(.55,5,0,96),Size=UDim2.new(.45,-15,0,38),ZIndex=66})
 U.LimAll=B(U.FilterPanel,"TODOS",{Position=UDim2.fromOffset(10,146),Size=UDim2.new(.33,-8,0,36),ZIndex=66})
 U.LimOnly=B(U.FilterPanel,"LIMITED",{Position=UDim2.new(.33,4,0,146),Size=UDim2.new(.33,-7,0,36),ZIndex=66})
 U.LimNo=B(U.FilterPanel,"SEM LIMITED",{Position=UDim2.new(.66,2,0,146),Size=UDim2.new(.34,-12,0,36),ZIndex=66})
 U.FormAll=B(U.FilterPanel,"TODOS",{Position=UDim2.fromOffset(10,194),Size=UDim2.new(.25,-6,0,36),ZIndex=66})
 U.FormClassic=B(U.FilterPanel,"CLÁSSICO",{Position=UDim2.new(.25,3,0,194),Size=UDim2.new(.25,-6,0,36),ZIndex=66})
 U.Form2D=B(U.FilterPanel,"2D",{Position=UDim2.new(.5,2,0,194),Size=UDim2.new(.25,-6,0,36),ZIndex=66})
 U.Form3D=B(U.FilterPanel,"3D",{Position=UDim2.new(.75,1,0,194),Size=UDim2.new(.25,-11,0,36),ZIndex=66})
 U.OffSale=B(U.FilterPanel,"Fora de venda: NÃO",{Position=UDim2.fromOffset(10,242),Size=UDim2.new(1,-20,0,36),ZIndex=66})
 U.ClearFilter=B(U.FilterPanel,"LIMPAR",{Position=UDim2.fromOffset(10,290),Size=UDim2.new(.36,-6,0,38),ZIndex=66})
 U.ApplyFilter=B(U.FilterPanel,"APLICAR",{Position=UDim2.new(.36,4,0,290),Size=UDim2.new(.64,-14,0,38),BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=66})
 U.Detail=N("Frame",{Name="CatalogItemDetails",Size=UDim2.fromScale(1,1),BackgroundColor3=C.bg,BorderSizePixel=0,Visible=false,Active=true,ZIndex=91},root)
 U.DetailClose=D.IconButton(U.Detail,"DetailClose","close","Fechar item",{Size=UDim2.fromOffset(48,48),ZIndex=98})
 U.DetailImage=N("ImageLabel",{BackgroundColor3=C.card,BorderSizePixel=0,ScaleType=Enum.ScaleType.Fit,ZIndex=92},U.Detail);R(U.DetailImage,10)
 U.DetailName=L(U.Detail,"Item",{Font=Enum.Font.GothamBold,TextSize=22,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=92})
 U.DetailCreator=L(U.Detail,"",{TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=92})
 U.DetailPrice=L(U.Detail,"",{Font=Enum.Font.GothamBold,TextColor3=C.green,TextSize=20,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=92})
 U.DescriptionScroll=F(U.Detail,{ZIndex=92});U.DetailDescription=L(U.DescriptionScroll,"Consultando descrição...",{Size=UDim2.new(1,-8,0,0),AutomaticSize=Enum.AutomaticSize.Y,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,ZIndex=93})
 U.Try=B(U.Detail,"EXPERIMENTAR",{BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=94})
 U.Buy=B(U.Detail,"+ CARRINHO",{BackgroundColor3=C.card,ZIndex=94})
 U.Favorite=B(U.Detail,"FAVORITAR",{BackgroundColor3=C.soft,ZIndex=94})
 U.LooksArea=area(main,"LooksArea")
 local sp=N("Frame",{Position=UDim2.fromOffset(6,6),Size=UDim2.new(.38,-9,1,-12),BackgroundColor3=Color3.fromRGB(29,31,36),BorderSizePixel=0},U.LooksArea)
 R(sp,10)
 U.SavedPreviewPanel=sp;sp.Visible=false;U.SavedPreview=N("ViewportFrame",{
  Position=UDim2.fromOffset(8,8),Size=UDim2.new(1,-16,.58,0),
  BackgroundColor3=Color3.fromRGB(83,87,95),Ambient=Color3.fromRGB(225,228,232),
  LightColor=Color3.fromRGB(255,255,255),LightDirection=Vector3.new(-.55,-1,-.5),BorderSizePixel=0
 },sp)
 R(U.SavedPreview,9)
 U.SavedLeft=B(U.SavedPreview,"<",{AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,5,.5,0),Size=UDim2.fromOffset(28,36),BackgroundColor3=C.card})
 U.SavedRight=B(U.SavedPreview,">",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-5,.5,0),Size=UDim2.fromOffset(28,36),BackgroundColor3=C.card})
 U.SavedZoomIn=B(U.SavedPreview,"+",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-5,0,5),Size=UDim2.fromOffset(25,25),BackgroundColor3=C.card})
 U.SavedZoomOut=B(U.SavedPreview,"-",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-5,0,34),Size=UDim2.fromOffset(25,25),BackgroundColor3=C.card})
 U.OutfitSelected=L(sp,"Selecione uma skin",{Position=UDim2.fromOffset(8,170),Size=UDim2.new(1,-16,0,22),Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd})
 U.SavedItems=F(sp,{Position=UDim2.fromOffset(8,196),Size=UDim2.new(1,-16,0,54),ScrollingDirection=Enum.ScrollingDirection.X,AutomaticCanvasSize=Enum.AutomaticSize.X,ScrollBarThickness=0})
 list(U.SavedItems,true,5)
 U.OutfitActions=F(sp,{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,8,1,-8),Size=UDim2.new(1,-16,0,104),Visible=false,AutomaticCanvasSize=Enum.AutomaticSize.None})
 U.OutfitApply=B(U.OutfitActions,"CARREGAR PRÉVIA",{Position=UDim2.fromOffset(0,0),Size=UDim2.new(.5,-3,0,30),BackgroundColor3=C.green,TextColor3=C.bg})
 U.OutfitUpdate=B(U.OutfitActions,"SALVAR ALTERAÇÕES",{Position=UDim2.new(.5,3,0,0),Size=UDim2.new(.5,-3,0,30),BackgroundColor3=C.card})
 U.OutfitRestore=B(U.OutfitActions,"RESTAURAR",{Position=UDim2.fromOffset(0,36),Size=UDim2.new(.5,-3,0,30),BackgroundColor3=C.orange,TextColor3=C.bg})
 U.OutfitBuy=B(U.OutfitActions,"COMPRAR ITENS",{Position=UDim2.new(.5,3,0,36),Size=UDim2.new(.5,-3,0,30),BackgroundColor3=C.yellow,TextColor3=C.bg})
 U.OutfitDelete=B(U.OutfitActions,"EXCLUIR",{Position=UDim2.fromOffset(0,72),Size=UDim2.new(.5,-3,0,30),BackgroundColor3=C.red})
 U.OutfitPublish=B(U.OutfitActions,"PUBLICAR",{Position=UDim2.new(.5,3,0,72),Size=UDim2.new(.5,-3,0,30),BackgroundColor3=C.purple})
 local gs=N("Frame",{Position=UDim2.new(.38,3,0,6),Size=UDim2.new(.62,-9,1,-12),BackgroundColor3=Color3.fromRGB(29,31,36),BorderSizePixel=0},U.LooksArea)
 R(gs,10);U.SavedGalleryPanel=gs
 U.SavedPreviewToggle=B(gs,"Ver look",{Size=UDim2.fromOffset(92,36),BackgroundColor3=C.soft})
 U.SavedPreviewClose=D.IconButton(sp,"CloseSavedPreview","close","Fechar prévia",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-8,0,8),Size=UDim2.fromOffset(48,48),Visible=false,ZIndex=44})
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
 for _,name in ipairs({"CURADOS","ROBLOX","PUBLICADOS","EM ALTA"})do comOrder=comOrder+1;U.ComTabButtons[name]=B(ctabs,name,{Size=UDim2.fromOffset(name=="LOOK DA SEMANA"and 154 or 126,34),LayoutOrder=comOrder,BackgroundColor3=name=="CURADOS"and C.soft or C.card,ZIndex=22,TextSize=5})end
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
 U.CartPanel=N("Frame",{Name="CartWindow",Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(19,20,24),BorderSizePixel=0,Visible=false,ZIndex=80},g)

 U.CartTitle=L(U.CartPanel,"CARRINHO",{Position=UDim2.fromOffset(16,12),Size=UDim2.new(1,-72,0,26),Font=Enum.Font.GothamBlack,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=81})
 U.CartClose=D.IconButton(U.CartPanel,"CartClose","close","Fechar",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,0,10),Size=UDim2.fromOffset(48,48),BackgroundColor3=C.soft,ZIndex=81})
 U.CartCount=L(U.CartPanel,"0 selecionados",{Position=UDim2.fromOffset(16,42),Size=UDim2.new(1,-32,0,20),TextColor3=C.muted,ZIndex=81})
 U.CartSelected=B(U.CartPanel,"Itens selecionados",{ZIndex=82})
 U.CartOutfit=B(U.CartPanel,"Outfit atual",{ZIndex=82})
 U.CartList=F(U.CartPanel,{Position=UDim2.fromOffset(14,70),Size=UDim2.new(1,-28,1,-142),ZIndex=81})
 list(U.CartList,false,7)
 U.CartTotal=L(U.CartPanel,"TOTAL: 0 Robux",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,16,1,-14),Size=UDim2.new(.38,0,0,34),Font=Enum.Font.GothamBlack,TextSize=10,TextColor3=C.green,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=81})
 U.CartClear=B(U.CartPanel,"LIMPAR",{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-190,1,-14),Size=UDim2.fromOffset(82,34),BackgroundColor3=C.soft,ZIndex=81})
 U.CartBuySelected=B(U.CartPanel,"COMPRAR SELECIONADOS",{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-14,1,-14),Size=UDim2.fromOffset(168,34),BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=81,TextSize=6})
 U.LookDetail=N("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.new(.94,0,.90,0),BackgroundColor3=Color3.fromRGB(29,31,36),BackgroundTransparency=0,BorderSizePixel=0,Visible=false,ZIndex=82},root)
 R(U.LookDetail,12)
 U.LookClose=D.IconButton(U.LookDetail,"LookClose","close","Fechar",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-9,0,8),Size=UDim2.fromOffset(48,48),BackgroundColor3=C.soft,ZIndex=83})
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
 U.LookItemLayout=grid(U.LookItems,124,126,6);U.LookItemLayout.SortOrder=Enum.SortOrder.LayoutOrder
 U.LookTry=B(U.LookDetail,"EXPERIMENTAR",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(.40,8,1,-12),Size=UDim2.new(.28,-6,0,34),BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=83})
 U.LookBuy=B(U.LookDetail,"COMPRAR",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(.68,8,1,-12),Size=UDim2.new(.18,-6,0,34),BackgroundColor3=C.yellow,TextColor3=C.bg,ZIndex=83})
 U.LookFav=B(U.LookDetail,"CURTIR",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(.86,8,1,-12),Size=UDim2.new(.14,-20,0,34),BackgroundColor3=C.card,ZIndex=83})
 U.SaveBox=D.Frame(root,{Name="SaveLookDialog",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(384,236),BackgroundColor3=C.panel,Visible=false,ZIndex=90})
 L(U.SaveBox,"Salvar look",{Position=UDim2.fromOffset(14,14),Size=UDim2.new(1,-84,0,32),Font=Enum.Font.GothamBold,TextSize=22,ZIndex=91})
 U.SaveName=T(U.SaveBox,"Nome do look",{Position=UDim2.fromOffset(14,58),Size=UDim2.new(1,-28,0,44),ZIndex=91})
 U.SaveR15=B(U.SaveBox,"SALVAR R15",{Position=UDim2.fromOffset(14,116),Size=UDim2.new(.5,-20,0,44),BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=91})
 U.SaveR6=B(U.SaveBox,"SALVAR R6",{Position=UDim2.new(.5,6,0,116),Size=UDim2.new(.5,-20,0,44),ZIndex=91})
 U.CancelSave=B(U.SaveBox,"Cancelar",{Position=UDim2.fromOffset(14,178),Size=UDim2.new(1,-28,0,40),ZIndex=91})
 U.PublishBox=D.Frame(root,{Name="PublishLookDialog",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(384,230),BackgroundColor3=C.panel,Visible=false,ZIndex=92})
 L(U.PublishBox,"Publicar na comunidade",{Position=UDim2.fromOffset(14,14),Size=UDim2.new(1,-84,0,36),Font=Enum.Font.GothamBold,TextSize=18,ZIndex=93})
 L(U.PublishBox,"Outros jogadores poderão experimentar seu look.",{Position=UDim2.fromOffset(14,48),Size=UDim2.new(1,-28,0,42),TextColor3=C.muted,ZIndex=93})
 U.PublishName=T(U.PublishBox,"Nome do look",{Position=UDim2.fromOffset(14,104),Size=UDim2.new(1,-28,0,44),ZIndex=93})
 U.PublishConfirm=B(U.PublishBox,"PUBLICAR",{Position=UDim2.fromOffset(14,172),Size=UDim2.new(.5,-20,0,44),BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=93})
 U.PublishCancel=B(U.PublishBox,"Cancelar",{Position=UDim2.new(.5,6,0,172),Size=UDim2.new(.5,-20,0,44),ZIndex=93})
 U.RigBox=D.Frame(root,{Name="EmoteRigDialog",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(384,220),BackgroundColor3=C.panel,Visible=false,ZIndex=94})
 L(U.RigBox,"Emotes em R15",{Position=UDim2.fromOffset(14,16),Size=UDim2.new(1,-84,0,36),Font=Enum.Font.GothamBold,TextSize=20,ZIndex=95})
 L(U.RigBox,"Troque a prévia para R15 e experimente esta animação.",{Position=UDim2.fromOffset(14,62),Size=UDim2.new(1,-28,0,66),TextColor3=C.muted,ZIndex=95})
 U.RigToR15=B(U.RigBox,"TESTAR R15",{Position=UDim2.fromOffset(14,154),Size=UDim2.new(.5,-20,0,44),BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=95})
 U.RigCancel=B(U.RigBox,"Cancelar",{Position=UDim2.new(.5,6,0,154),Size=UDim2.new(.5,-20,0,44),ZIndex=95})
 U.SaveClose=D.IconButton(U.SaveBox,"SaveClose","close","Fechar",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,0,10),Size=UDim2.fromOffset(48,48),ZIndex=92})
 U.PublishClose=D.IconButton(U.PublishBox,"PublishClose","close","Fechar",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-8,0,8),Size=UDim2.fromOffset(48,48),ZIndex=94})
 U.RigClose=D.IconButton(U.RigBox,"RigClose","close","Fechar",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-8,0,8),Size=UDim2.fromOffset(48,48),ZIndex=96})
 U.Loader=N("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(5,7,10),BackgroundTransparency=0,BorderSizePixel=0,Visible=false,ZIndex=96},g)
 local lc=N("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=C.panel,BorderSizePixel=0,ZIndex=97},U.Loader)
 U.LoaderCard=lc
 U.LoaderTitle=L(lc,"Carregar avatar",{Position=UDim2.fromOffset(16,14),Size=UDim2.new(1,-76,0,30),TextSize=22,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=98})
 U.LoaderClose=D.IconButton(lc,"LoaderClose","close","Fechar",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,0,9),Size=UDim2.fromOffset(48,48),BackgroundColor3=C.soft,ZIndex=98})
 U.LoaderQuery=T(lc,"Nome de usuário ou ID...",{Position=UDim2.fromOffset(16,60),Size=UDim2.new(1,-122,0,38),ZIndex=98})
 U.LoaderSearch=B(lc,"BUSCAR",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-16,0,60),Size=UDim2.fromOffset(92,38),BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=98})
 U.LoaderThumb=N("ImageLabel",{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,112),Size=UDim2.new(.56,0,.48,0),BackgroundColor3=C.card,Image="",ScaleType=Enum.ScaleType.Fit,ZIndex=98},lc)
 R(U.LoaderThumb,10)
 U.LoaderName=L(lc,"Digite um usuário.",{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-76),Size=UDim2.new(1,-40,0,22),Font=Enum.Font.GothamBold,TextSize=10,ZIndex=98})
 U.LoaderStatus=L(lc,"Carrega o avatar atual desse usuário.",{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-54),Size=UDim2.new(1,-40,0,18),TextColor3=C.muted,ZIndex=98})
 U.LoaderUse=B(lc,"USAR NA PRÉVIA",{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-14),Size=UDim2.fromOffset(178,32),BackgroundColor3=C.green,TextColor3=C.bg,Visible=false,ZIndex=98})
 U.LoaderMine=B(lc,"MEU",{Size=UDim2.fromOffset(64,40),BackgroundColor3=C.soft,ZIndex=98})
 U.LoaderUseR6=B(lc,"USAR R6",{BackgroundColor3=C.card,Visible=false,ZIndex=98})
 U.LoaderUse.Text="USAR R15"
 U.PlusPanel=N("Frame",{Name="PlusCompatibility",Size=UDim2.fromOffset(1,1),BackgroundTransparency=1,Visible=false},g)
 U.Toast=L(g,"",{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-10),Size=UDim2.new(.5,0,0,32),BackgroundTransparency=.02,BackgroundColor3=C.panel,Font=Enum.Font.GothamBold,Visible=false,ZIndex=120})
 R(U.Toast,9);S(U.Toast,nil,.5)
 U.EditorFooter=F(left,{AutomaticCanvasSize=Enum.AutomaticSize.None,ScrollBarThickness=2})
 for _,o in ipairs({U.Actions,U.BodyToggle,U.Total,U.ItemStrip})do o.Parent=U.EditorFooter end
 U.SavedGridPanel=gs
 U.LookRotation=N("Frame",{BackgroundTransparency=1,ZIndex=84},U.LookDetail)
 U.LookViews={}
 for i,name in ipairs({"Frente","Costas","Esq.","Dir."})do U.LookViews[i]=B(U.LookRotation,name,{Position=UDim2.new((i-1)/4,0,0,0),Size=UDim2.new(.25,-3,1,0),TextSize=13,ZIndex=85})end
 U.LookRigToggle=B(U.LookPreview,"R15",{Position=UDim2.fromOffset(6,6),Size=UDim2.fromOffset(52,36),ZIndex=85})
 for _,pair in ipairs({{U.CloseFilter,U.FilterPanel}})do
  local close,panel=pair[1],pair[2];close.Parent=main;close.ZIndex=90;close.Visible=false
  panel:GetPropertyChangedSignal("Visible"):Connect(function()close.Visible=panel.Visible end)
 end
 require(game:GetService("ReplicatedStorage"):WaitForChild("09A2_PREVIEW_LAYOUT")).Init(U)
 require(game:GetService("ReplicatedStorage"):WaitForChild("09A1_SHOP_LAYOUT")).Init(U)
 return U
end
print("[V44] 09A_SHOP_UI carregado de "..script:GetFullName())
return M
