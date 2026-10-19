-- 09C16_CATALOG_HOME | ModuleScript | ReplicatedStorage | V71 (SUBSTITUIR)
-- Entrada por categorias; abrir o catálogo não dispara uma busca automaticamente.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local B=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local Fx=require(Rep:WaitForChild('07UI_SURFACE_EFFECTS'));local C=D.Colors
local M={}
function M.Build(ctx)
 local U,A=ctx.U,ctx.A;local H={Buttons={},Favorites={}}
 H.Root=D.New('Frame',{Name='CatalogHome',BackgroundTransparency=1,Visible=false},U.Main);U.CatalogHome=H.Root
 local title=D.Text(H.Root,'Seu próximo estilo começa aqui',{TextSize=22,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})
 local back=D.Button(H.Root,'Categorias',{Name='BackToCatalogCategories',TextSize=12,Visible=false})
 local State=require(Rep:WaitForChild('08D_SKIN_STATE'));local pl=game:GetService('Players').LocalPlayer
 local hair=63690008;local accessory;for _,v in ipairs(State.Current and State.Current.accessories or{})do if v.type=='Hair'then hair=v.id elseif not accessory then accessory=v.id end end
 local shirt=State.Current and State.Current.props.Shirt or 0
 local definitions={{'EM DESTAQUE','Featured','avatar',Color3.fromRGB(143,38,211)}, {'CABELOS','Hair','avatar',Color3.fromRGB(116,32,181)},
  {'ROUPAS','Clothing','catalog',Color3.fromRGB(242,154,43)}, {'ACESSÓRIOS','Accessories','catalog',Color3.fromRGB(230,144,44)},
  {'HALLOWEEN','Halloween','emote',Color3.fromRGB(237,137,37)}, {'ROSTOS','Faces','avatar',Color3.fromRGB(154,53,210)},
  {'Corpos','Body','avatar',C.card},{'Emotes','Emotes','emote',C.card},{'Favoritos','Favorites','save',C.card}}
 for i,v in ipairs(definitions)do
  local b=D.Button(H.Root,'',{Name='Home'..v[2],BackgroundColor3=v[4]});b:SetAttribute('V56_PreserveArt',true);H.Buttons[i]=b
  local ink=(i==3 or i==4 or i==5)and Color3.fromRGB(39,30,21)or Color3.fromRGB(255,255,255)
  local label=D.Text(b,v[1],{Name='CategoryLabel',Font=Enum.Font.GothamBold,TextSize=19,TextColor3=ink,TextXAlignment=Enum.TextXAlignment.Left})
  local icon=D.Icon(b,v[3],{Name='CategoryArt',IconColor=ink});icon.Name='CategoryArt'
  local uri=i==1 and('rbxthumb://type=Avatar&id='..pl.UserId..'&w=420&h=420')or i==2 and A.AssetThumb(hair,420)or i==3 and shirt>0 and A.AssetThumb(shirt,420)or i==4 and accessory and A.AssetThumb(accessory,420)or i==6 and('rbxthumb://type=AvatarHeadShot&id='..pl.UserId..'&w=420&h=420')
  if uri then local im=D.New('ImageLabel',{Name='CategoryThumbnail',Image=uri,BackgroundTransparency=1,ScaleType=Enum.ScaleType.Fit,Active=false},b);local function ready()icon.Visible=not im.IsLoaded end;im:GetPropertyChangedSignal('IsLoaded'):Connect(ready);ready()end
  if i==5 then icon.Visible=false;local pumpkin=require(Rep:WaitForChild('07UI_HALLOWEEN_THEME')).Pumpkin(b,96);pumpkin.Name='CategoryPumpkin'end
  b.Activated:Connect(function()if v[2]=='Favorites'then H.OpenFavorites()else H.Hide();ctx.browse(v[2])end end)
 end
 H.Shelf=D.Scroll(H.Root,{Name='CatalogFavoriteShelf',Visible=false,ScrollBarThickness=3,AutomaticCanvasSize=Enum.AutomaticSize.None});local favoriteCards={}
 local note=D.Text(H.Root,'Escolha uma categoria ou pesquise pelo nome. Sua prévia fica à esquerda.',{TextSize=12,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 function H.Layout()
  local row=U.Groups.Parent;local y=math.max(52,row.Position.Y.Offset);local w=U.Main.AbsoluteSize.X-12;local h=U.Main.AbsoluteSize.Y-y-4
  B.Rect(H.Root,6,y,w,h);local gap=10;local footer=48;local content=math.max(94,h-footer-8);local third=(w-2*gap)/3;local half=(content-gap)/2
  local areas={{0,0,third,content*.68},{third+gap,0,third,content*.34-gap/2},{third+gap,content*.34+gap/2,third,content*.34-gap/2},
   {0,content*.68+gap,third*2+gap,math.max(44,content*.32-gap)}, {2*(third+gap),0,third,content*.58}, {2*(third+gap),content*.58+gap,third,math.max(44,content*.42-gap)}}
  if w<370 or content<170 then
   local cw=(w-12)/3;local rh=(content-8)/2
   for i=1,6 do areas[i]={(i-1)%3*(cw+6),math.floor((i-1)/3)*(rh+8),cw,rh}end
  end
  title.Visible=H.Shelf.Visible;note.Visible=false;B.Rect(title,4,0,w-118,40);B.Rect(back,w-110,0,104,44)
  for i,b in ipairs(H.Buttons)do
   if i<=6 then local a=areas[i];B.Rect(b,a[1],a[2],a[3],a[4])else B.Rect(b,(i-7)*(w+8)/3,h-44,(w-16)/3,44)end
   local bw,bh=b.AbsoluteSize.X,b.AbsoluteSize.Y;local label=b:FindFirstChild('CategoryLabel');local art=b:FindFirstChild('CategoryArt');local im=b:FindFirstChild('CategoryThumbnail');local pumpkin=b:FindFirstChild('CategoryPumpkin')
   B.Rect(label,10,6,bw-20,i<=6 and math.min(52,bh*.32)or 32);label.TextSize=bw<150 and 13 or i==1 and 23 or 18
   if i>6 then label.TextXAlignment=Enum.TextXAlignment.Center end
   if art then B.Rect(art,bw*.26,bh*.36,bw*.48,bh*.50);art.Visible=i<=6 and not im and i~=5 and bh>=68 end
   if im then B.Rect(im,6,math.min(48,bh*.34),bw-12,math.max(1,bh-math.min(48,bh*.34)-6))end
   if pumpkin then pumpkin.AnchorPoint=Vector2.new(.5,.5);B.Rect(pumpkin,math.max(0,(bw-96)/2),math.max(28,(bh-96)/2),64,64);pumpkin.Visible=bh>=98 end
  end
  B.Rect(H.Shelf,4,50,w-8,math.max(44,h-56));local gw,gh=H.Shelf.AbsoluteSize.X,H.Shelf.AbsoluteSize.Y;local fc=math.clamp(math.floor(gw/120),2,5);local fw=(gw-6*(fc-1)-4)/fc;local fh=math.max(86,gh/2-4)
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
