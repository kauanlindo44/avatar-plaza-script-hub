-- 09C16_CATALOG_HOME | ModuleScript | ReplicatedStorage | V68 (NOVO)
-- Entrada por categorias; abrir o catálogo não dispara uma busca automaticamente.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local B=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local Fx=require(Rep:WaitForChild('07UI_SURFACE_EFFECTS'));local C=D.Colors
local M={}
function M.Build(ctx)
 local U,A=ctx.U,ctx.A;local H={Buttons={},Favorites={}}
 H.Root=D.New('Frame',{Name='CatalogHome',BackgroundTransparency=1,Visible=false},U.Main);U.CatalogHome=H.Root
 local title=D.Text(H.Root,'Seu próximo estilo começa aqui',{TextSize=22,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})
 local back=D.Button(H.Root,'Categorias',{Name='BackToCatalogCategories',TextSize=12,Visible=false})
 local definitions={{'Destaques','Featured','catalog',Color3.fromRGB(93,67,114)},{'Cabelos','Hair','avatar',Color3.fromRGB(106,77,56)},{'Roupas','Clothing','catalog',Color3.fromRGB(57,91,82)},{'Corpos','Body','avatar',Color3.fromRGB(57,75,110)},{'Emotes e animações','Emotes','emote',Color3.fromRGB(103,70,91)},{'Seus favoritos','Favorites','save',Color3.fromRGB(91,85,52)}}
 for i,v in ipairs(definitions)do
  local b=D.Button(H.Root,v[1],{Name='Home'..v[2],Font=Enum.Font.GothamBold,TextSize=16,BackgroundColor3=v[4],TextYAlignment=Enum.TextYAlignment.Bottom});Fx.Button(b,v[4]:Lerp(C.white,.5))
  local icon=D.Icon(b,v[3],{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.37),Size=UDim2.fromOffset(34,34),IconColor=v[4]:Lerp(C.white,.75)})
  H.Buttons[i]=b;b.Activated:Connect(function()if v[2]=='Favorites'then H.OpenFavorites()else H.Hide();ctx.browse(v[2])end end)
 end
 H.Shelf=D.Scroll(H.Root,{Name='CatalogFavoriteShelf',Visible=false,ScrollBarThickness=3,AutomaticCanvasSize=Enum.AutomaticSize.None});local favoriteCards={}
 local note=D.Text(H.Root,'Escolha uma categoria ou pesquise pelo nome. Sua prévia fica à esquerda.',{TextSize=12,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 function H.Layout()
  local row=U.Groups.Parent;local y=row.Position.Y.Offset;local w=U.Main.AbsoluteSize.X;local h=U.Main.AbsoluteSize.Y-y
  B.Rect(H.Root,6,y,w-12,h-4);w=w-12;h=h-4;local short=h<300;local cols=w>=590 and 3 or 2;local top=short and 38 or 50;local footer=short and 0 or 26;local gap=8;local rows=math.ceil(#H.Buttons/cols);local cw=(w-8-(cols-1)*gap)/cols;local ch=(h-top-footer-8-(rows-1)*gap)/rows
  B.Rect(title,4,0,w-(H.Shelf.Visible and 116 or 8),38);title.TextSize=short and 16 or 22;B.Rect(back,w-108,0,104,44)
  for i,b in ipairs(H.Buttons)do B.Rect(b,4+(i-1)%cols*(cw+gap),top+math.floor((i-1)/cols)*(ch+gap),cw,ch);b.TextSize=short and 12 or 16;local icon=b:FindFirstChild('Icon_'..definitions[i][3]);if icon then icon.Visible=ch>=65 end end
  note.Visible=not short;B.Rect(note,4,h-24,w-8,22);B.Rect(H.Shelf,4,48,w-8,h-76)
  local gw,gh=H.Shelf.AbsoluteSize.X,H.Shelf.AbsoluteSize.Y;local fc=math.clamp(math.floor(gw/120),2,5);local fw=(gw-6*(fc-1)-4)/fc;local fh=math.max(86,gh/2-4)
  for i,v in ipairs(favoriteCards)do B.Rect(v,(i-1)%fc*(fw+6),math.floor((i-1)/fc)*(fh+6),fw,fh)end;H.Shelf.CanvasSize=UDim2.fromOffset(0,math.ceil(#favoriteCards/fc)*(fh+6))
 end
 function H.Hide()
  H.Root.Visible=false;U.HomeOpen=false;U.Grid.Visible=true;U.Groups.Visible=true;U.Groups.Parent.Visible=true;U.Status.Visible=true;U.SubToggle.Visible=true;U.Filter.Visible=true;U.Sort.Visible=true
 end
 function H.Open()
  U.HomeOpen=true;H.Root.Visible=true;H.Shelf.Visible=false;back.Visible=false;title.Text='Seu próximo estilo começa aqui';for _,b in ipairs(H.Buttons)do b.Visible=true end
  for _,o in ipairs({U.Grid,U.Status,U.More,U.Groups,U.SubToggle,U.FilterPanel,U.SubsPopup,U.Detail})do o.Visible=false end;U.Groups.Parent.Visible=false;H.Layout()
 end
 function H.OpenFavorites()
  H.Open();H.Shelf.Visible=true;back.Visible=true;title.Text='Seus favoritos';for _,b in ipairs(H.Buttons)do b.Visible=false end
  task.spawn(function()
   local r,e=ctx.call('CatalogFavorites');if not H.Root.Visible or not H.Shelf.Visible then return end
   if not r then ctx.toast(e);return end;if r.loading then ctx.toast('Seus favoritos ainda estão carregando. Tente novamente em instantes.');return end
   for _,b in ipairs(favoriteCards)do b:Destroy()end;favoriteCards={}
   for _,item in ipairs(r.items or{})do item.CatalogFavorite=true;local b=D.Button(H.Shelf,'',{Name='Bookmarked_'..item.Id});local im=D.New('ImageLabel',{Image=A.Thumbnail(item,420),BackgroundTransparency=1,Position=UDim2.fromOffset(2,2),Size=UDim2.new(1,-4,1,-26),ScaleType=Enum.ScaleType.Fit},b)
    D.Text(b,item.Name,{Position=UDim2.new(0,4,1,-24),Size=UDim2.new(1,-8,0,22),TextSize=11,TextTruncate=Enum.TextTruncate.AtEnd});b.Activated:Connect(function()ctx.showItem(item)end);favoriteCards[#favoriteCards+1]=b
   end;if #favoriteCards==0 then title.Text='Favorite peças nos detalhes';end;H.Layout()
  end)
 end
 back.Activated:Connect(H.Open);local old=U.Layout;U.Layout=function(...)old(...);H.Layout()end;U.OnCatalogBrowse=function()if U.HomeOpen then H.Hide()end end
 U.Main:GetPropertyChangedSignal('AbsoluteSize'):Connect(H.Layout);return H
end
return M
