-- 09C5_UGC_STORES | ModuleScript | ReplicatedStorage | V68 (SUBSTITUIR)
-- Destaques grátis, linhas horizontais, favoritos independentes e compra oficial.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'))
local Fx=require(Rep:WaitForChild('07UI_SURFACE_EFFECTS'));local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'))
local Design=require(Rep:WaitForChild('09C10_SPONSOR_DESIGN'));local C=D.Colors;local M={Version='V68'}
function M.Init(ctx)
 local U,A,call,toast=ctx.U,ctx.A,ctx.call,ctx.toast;local area=U.StoresArea;local grid=U.StoreGrid
 local query,status,filter,go=U.StoreSearch,U.StoreStatus,U.StoreType,U.StoreGo;local header=query.Parent
 local old=grid:FindFirstChildOfClass('UIGridLayout');if old then old:Destroy()end
 grid.AutomaticCanvasSize=Enum.AutomaticSize.None;grid.CanvasSize=UDim2.new();grid.ScrollingEnabled=true;grid.ScrollingDirection=Enum.ScrollingDirection.XY;grid.ScrollBarThickness=4;grid.ScrollBarImageColor3=C.orange;grid.Active=true
 local Merge=require(Rep:WaitForChild('09C11_SPONSOR_FEED'));local cards={};local examplesPages;local examplesKey;local exampleRows={};local realRows={};local currentKey;local categoriesOpen=false;local destinationMode=false;local groupBar=D.Scroll(area,{Name='SponsorCategories',ScrollingDirection=Enum.ScrollingDirection.X,ScrollBarThickness=0,AutomaticCanvasSize=Enum.AutomaticSize.None});local groupButtons={};local items={};local filterIndex=1;local token=0;local loading=false;local finished=false;local busy=false
 local groups=Design.Groups
 local refresh=D.Button(area,'Mais itens',{Name='MoreHighlights',TextSize=12})
 local publish=D.Button(area,'Patrocinar grátis',{Name='PublishHighlight',TextSize=13,BackgroundColor3=Color3.fromRGB(109,65,34)})
 local ia=D.Button(area,'Assistente',{Name='AssistantTab',TextSize=13});ia.Activated:Connect(function()if ctx.openAssistant then ctx.openAssistant()end end)
 local gameTab=D.Button(area,'Jogos',{Name='SponsoredGames',TextSize=12});local communityTab=D.Button(area,'Comunidades',{Name='SponsoredCommunities',TextSize=12})
 local scrollLeft=D.Button(area,'‹',{Name='HighlightsScrollLeft',TextSize=22});local scrollRight=D.Button(area,'›',{Name='HighlightsScrollRight',TextSize=22})
 local destinations=require(Rep:WaitForChild('09C12_DESTINATION_BROWSER')).Build(area,ctx)
 local tab=D.Button(area,'Itens',{Name='SponsorTab',TextSize=13,BackgroundColor3=C.orange});
 local empty=D.Text(grid,'Nenhum destaque ainda. Publique um item gratuitamente.',{Name='EmptyHighlights',TextSize=16,TextColor3=C.muted,TextWrapped=true})
 local shade=D.New('TextButton',{Name='HighlightModalShade',Text='',Size=UDim2.fromScale(1,1),BackgroundColor3=C.bg,BackgroundTransparency=.28,Visible=false,AutoButtonColor=false,Active=true,ZIndex=70},area)
 local p=D.Frame(shade,{Name='HighlightComposer',BackgroundColor3=C.panel,ZIndex=71})
 local title=D.Text(p,'Patrocinar item',{TextSize=20,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=72})
 local close=D.IconButton(p,'CloseHighlight','close','Fechar destaque',{ZIndex=75})
 local note=D.Text(p,'Grátis • 1 item por pessoa • 24 horas. Sem prioridade paga.',{TextSize=12,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=72})
 local idBox=D.Box(p,'ID do item no catálogo Roblox',{Name='HighlightID',ZIndex=72})
 local kind=D.Button(p,'Item',{Name='HighlightKind',TextSize=12,ZIndex=72})
 local check=D.Button(p,'Conferir',{Name='CheckHighlight',TextSize=12,ZIndex=72})
 local image=D.New('ImageLabel',{Name='HighlightPreview',BackgroundTransparency=1,Image='',ScaleType=Enum.ScaleType.Fit,Active=false,ZIndex=72},p)
 local info=D.Text(p,'Cole o ID e toque em Conferir.',{Name='HighlightInfo',TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=72})
 local submit=D.Button(p,'Publicar grátis',{Name='ConfirmHighlight',BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=73})
 local cancel=D.Button(p,'Cancelar',{Name='CancelHighlight',ZIndex=73})
 local menu=D.Frame(area,{Name='HighlightFilterMenu',Visible=false,BackgroundColor3=C.panel,ZIndex=50});local filterButtons={}
 local Pan=require(Rep:WaitForChild('07UI_PAN_GRID')).Bind(grid,function()return area.Visible and not destinationMode and not shade.Visible end)
 local current,verified=nil,nil;local lastFeed=-10;local itemKind='Asset';local render,run
 Design.Accent(tab,Color3.fromRGB(122,203,165));Design.Accent(ia,Color3.fromRGB(159,155,239));ia.BackgroundColor3=Color3.fromRGB(77,58,109)
 Fx.Surface(area,C.bg,C.panel);Fx.Surface(p,C.panel,C.card,C.orange);Fx.Button(publish,C.orange);Fx.Button(refresh,C.blue)
 local function cost(it)return it.Price==0 and'Grátis'or it.Price and(math.floor(it.Price)..' Robux')or'Ver preço'end
 local function api(action,args)
  if busy then return nil,'Aguarde a operação anterior.'end;busy=true;local r,e=call(action,args or{});busy=false;return r,e
 end
 local function clear()
  cards={};for _,o in ipairs(grid:GetChildren())do if o:IsA('GuiButton')then o:Destroy()end end
 end
 local function card(r,i)
  local it=r.item;it.ItemType=A.ItemType(it);it.Price=A.Price(it);if not Design.Paid(A,it)then return end;local b=D.Button(grid,'',{Name='Featured_'..it.ItemType..'_'..it.Id,BackgroundColor3=C.card})
  local pad=b:FindFirstChildOfClass('UIPadding');if pad then pad:Destroy()end;Fx.Button(b,C.orange)
  local im=D.New('ImageLabel',{Name='ItemThumbnail',Image=A.Thumbnail(it,420),BackgroundColor3=Color3.fromRGB(83,91,108),ScaleType=Enum.ScaleType.Fit,Active=false},b);D.Round(im,12);D.New('UIGradient',{Color=ColorSequence.new(Color3.fromRGB(156,167,184),Color3.fromRGB(90,102,125)),Rotation=110},im)
  local name=D.Text(b,it.Name,{Name='ItemName',Font=Enum.Font.GothamBold,TextSize=12,TextWrapped=true,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left})
  local price=D.Text(b,(r.temporary and'Exemplo • 'or'')..cost(it),{Name='ItemPrice',TextSize=12,TextColor3=C.gold,TextWrapped=false,TextXAlignment=Enum.TextXAlignment.Left})
  local buy=D.Button(b,'Comprar',{Name='BuyFeatured',TextSize=11,BackgroundColor3=Color3.fromRGB(60,87,65)})
  local fav=D.Button(b,r.favorite and'♥'or'♡',{Name='FavoriteFeatured',TextSize=17,BackgroundTransparency=1})
  b.Activated:Connect(function()if Pan.CanActivate()then ctx.showItem(it)end end)
  buy.Active=not it.unavailable;if it.unavailable then buy.Text='Indisponível'end
  buy.Activated:Connect(function()if it.unavailable or not Pan.CanActivate()then return end;task.spawn(function()local ok,e=api('HighlightPurchase',{id=it.Id,kind=it.ItemType});if not ok then toast(e)end end)end)
  fav.Activated:Connect(function()if not Pan.CanActivate()then return end;task.spawn(function()local d,e=api('HighlightFavorite',{id=it.Id,kind=it.ItemType,value=not r.favorite});if d then r.favorite=d.value;fav.Text=r.favorite and'♥'or'♡'else toast(e)end end)end)
  buy.Visible=false;Design.Accent(b,C.orange);fav.BackgroundTransparency=1;local border=fav:FindFirstChildOfClass('UIStroke');if border then border:Destroy()end
  cards[#cards+1]={root=b,image=im,name=name,price=price,buy=buy,fav=fav,index=i}
 end
 local picker=require(Rep:WaitForChild('09C9_SPONSOR_PICKER')).Build(shade,ctx,function(it)idBox.Text=tostring(it.Id);itemKind=it.ItemType=='Bundle'and'Bundle'or'Asset';kind.Text=itemKind=='Bundle'and'Pacote'or'Item';verified=nil;image.Image=A.Thumbnail(it,420);info.Text=tostring(it.Name)..'\nToque em Conferir para validar no Roblox.';submit.Active=false end)
 local browse=D.Button(p,'Buscar por nome',{Name='BrowseSponsor',TextSize=12,ZIndex=73});browse.Activated:Connect(function()picker.Open()end)
 local function layout()
  local w,h=area.AbsoluteSize.X,area.AbsoluteSize.Y;if w<1 or h<1 then return end
  local wide=w>=820 or w>=560 and h<400;local compactTop=wide and w<820;local topW=wide and math.min(100,(w-192)/4-6)or(w-30)/4
  for i,b in ipairs({tab,ia,gameTab,communityTab})do Bounds.Rect(b,6+(i-1)*(topW+6),0,topW,44);b.TextSize=topW<86 and 10 or 12 end
  local hx=6+4*(topW+6);Bounds.Rect(header,wide and hx or 6,wide and 0 or 50,wide and w-hx-6 or w-12,44);header.BackgroundTransparency=1
  local hw=header.AbsoluteSize.X;filter.Visible=not destinationMode and not compactTop;tab.Text=compactTop and'Itens ▾'or'Patrocinar itens';filter.Text=groups[filterIndex];filter.TextSize=10
  Bounds.Rect(query,0,0,hw-(compactTop and 50 or 144),44);Bounds.Rect(filter,hw-138,0,88,44);Bounds.Rect(go,hw-44,0,44,44)
  query.PlaceholderText='Nome ou ID do item';go.Text='';menu.Visible=false
  if not go:FindFirstChild('SearchIcon')then D.Icon(go,'search',{Name='SearchIcon',AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(20,20)})end
  local gy=wide and 50 or 100;groupBar.Visible=categoriesOpen and not destinationMode;groupBar.ZIndex=50;groupBar.BackgroundTransparency=0;groupBar.BackgroundColor3=C.panel
  Bounds.Rect(groupBar,6,gy,w-12,48);local gx=0
  for i,b in ipairs(groupButtons)do local width=math.max(74,#groups[i]*7+24);Bounds.Rect(b,gx,2,width,44);gx=gx+width+6;b.ZIndex=51;b.BackgroundColor3=i==filterIndex and Color3.fromRGB(196,109,45)or C.card;b.TextColor3=i==filterIndex and C.white or C.muted end
  groupBar.CanvasSize=UDim2.fromOffset(gx,0)
  Bounds.Rect(grid,6,gy,w-12,math.max(0,h-gy-50));local pubW=math.min(148,w*.37);local moreW=math.min(110,w*.27)
  Bounds.Rect(publish,6,h-46,pubW,44);Bounds.Rect(refresh,w-moreW-6,h-46,moreW,44)
  Bounds.Rect(scrollLeft,pubW+12,h-46,44,44);Bounds.Rect(scrollRight,pubW+62,h-46,44,44)
  Bounds.Rect(status,pubW+116,h-44,w-pubW-moreW-134,40);status.TextSize=11;status.Visible=w>=700
  for _,o in ipairs({grid,publish,refresh,scrollLeft,scrollRight,header})do o.Visible=not destinationMode end
  if destinationMode then status.Visible=false;filter.Visible=false end
  local gw,gh=grid.AbsoluteSize.X,grid.AbsoluteSize.Y;local cols=math.clamp(math.floor((gw+8)/118),2,7);local gap=8;local cw=(gw-gap*(cols-1)-4)/cols
  local ch=math.max(68,math.floor((gh-gap)/2));local totalCols=math.min(15,math.max(cols,#cards));grid:SetAttribute('VisibleColumns',cols);grid:SetAttribute('VisibleRows',gh/(ch+gap))
  grid.CanvasSize=UDim2.fromOffset(totalCols*(cw+gap)-gap+4,math.max(gh,math.ceil(#cards/totalCols)*(ch+gap)))
  for i,v in ipairs(cards)do
   Bounds.Rect(v.root,(i-1)%totalCols*(cw+gap),math.floor((i-1)/totalCols)*(ch+gap),cw,ch)
   Bounds.Rect(v.image,4,4,cw-8,math.max(20,ch-39));Bounds.Rect(v.name,7,ch-35,cw-14,18);Bounds.Rect(v.price,7,ch-17,cw-14,15)
   Bounds.Rect(v.fav,cw-46,2,44,44);v.price.TextSize=cw<130 and 10 or 12;v.name.TextSize=cw<130 and 11 or 13
  end
  empty.Visible=#items==0;Bounds.Rect(empty,8,8,gw-16,math.max(44,gh-16))
  local pw=math.min(460,w-12);local ph=math.min(350,h-12);Bounds.Rect(p,(w-pw)/2,(h-ph)/2,pw,ph)
  Bounds.Rect(title,12,4,pw-74,44);Bounds.Rect(close,pw-54,2,48,48)
  local compact=ph<300;note.Visible=not compact;Bounds.Rect(note,12,50,pw-24,34)
  local y=compact and 54 or 90;Bounds.Rect(idBox,12,y,pw-186,44);Bounds.Rect(kind,pw-168,y,68,44);Bounds.Rect(check,pw-94,y,82,44)
  local iy=y+50;local ih=math.max(36,ph-iy-60);Bounds.Rect(image,12,iy,ih,ih);Bounds.Rect(info,ih+22,iy,pw-ih-34,ih)
  Bounds.Rect(browse,12,ph-52,(pw-36)/3,44);Bounds.Rect(cancel,18+(pw-36)/3,ph-52,(pw-36)/3,44);Bounds.Rect(submit,24+2*(pw-36)/3,ph-52,(pw-36)/3,44)
 end
 render=function()clear();for i,r in ipairs(items)do card(r,i)end;layout()end
 run=function(nextPage)
  if loading and nextPage then return end;loading=true;token=token+1;local mine=token;refresh.Text='Aguarde…';refresh.Active=false
  task.spawn(function()
   local waitFor=.9-(os.clock()-lastFeed);if waitFor>0 then task.wait(waitFor)end;if mine~=token then return end;lastFeed=os.clock()
   local r,e=call('HighlightFeed',{next=nextPage==true,search=query.Text,group=groups[filterIndex]})
   if mine~=token then return end;loading=false;refresh.Active=true
   if not r then refresh.Text='Recarregar';status.Text=e;toast(e);if #items==0 then empty.Text=e end;return end
   local key=groups[filterIndex]..':'..query.Text;local reset=key~=currentKey;currentKey=key
   if not nextPage or reset then realRows={}end
   local realSeen={};for _,v in ipairs(realRows)do realSeen[v.key]=true end
   for _,v in ipairs(r.items or{})do if not realSeen[v.key]and Design.Paid(A,v.item)and #realRows<120 then realRows[#realRows+1]=v;realSeen[v.key]=true end end
   local favoriteMode=groups[filterIndex]=='Favoritos';local exampleFinished=true
   if not favoriteMode and #realRows<60 then
    local source=examplesKey==key and examplesPages or nil
    local fetch=not source or nextPage and not source.IsFinished
    if fetch then
     local ok,data=pcall(function()
      if source and nextPage then source:AdvanceToNextPageAsync()else source=game:GetService('AvatarEditorService'):SearchCatalogAsync(Design.Params(groups[filterIndex],query.Text))end
      return source:GetCurrentPage()
     end)
     if mine~=token then return end
     if ok then
      if examplesKey~=key then exampleRows={}end;examplesPages=source;examplesKey=key
      local seen={};for _,v in ipairs(exampleRows)do seen[v.key]=true end
      for _,it in ipairs(data or{})do local k=A.ItemType(it)..':'..it.Id;if not seen[k]and Design.Paid(A,it)and #exampleRows<120 then exampleRows[#exampleRows+1]={item=it,key=k,temporary=true,favorite=false};seen[k]=true end end
     else status.Text='Exemplos indisponíveis. Os destaques publicados continuam visíveis.'end
    end
    exampleFinished=not source or source.IsFinished
   end
   if favoriteMode then items=realRows else
    local examples=examplesKey==key and exampleRows or{};local capacity=math.max(#realRows,math.min(nextPage and 120 or math.max(60,#items),#examples));items=Merge.Merge(realRows,examples,math.max(1,capacity))
   end
   finished=r.finished and exampleFinished;refresh.Text=finished and'Atualizar'or'Mais itens';status.Text='Role para os lados e para baixo • envio grátis';empty.Text=favoriteMode and'Salve itens com ♡. Seus favoritos ficam aqui.'or'Nenhum item pago nesta seleção. Tente outra busca.'
   if reset then grid.CanvasPosition=Vector2.zero end;render()
   if #items==0 and not finished then empty.Text='Nenhum resultado nesta página. Toque em Mais itens.'end
  end)
 end
 local function resetVerification()verified=nil;submit.Active=current~=nil;image.Image='';info.Text='Cole o ID e toque em Conferir.'end
 idBox:GetPropertyChangedSignal('Text'):Connect(resetVerification)
 kind.Activated:Connect(function()if current then return end;itemKind=itemKind=='Asset'and'Bundle'or'Asset';kind.Text=itemKind=='Asset'and'Item'or'Pacote';resetVerification()end)
 check.Activated:Connect(function()task.spawn(function()
  if current then return end;local wanted=idBox.Text;local wantedKind=itemKind;local parsed=wanted:match('roblox%.com/catalog/(%d+)')or wanted:match('roblox%.com/bundles/(%d+)')or wanted;local nativeKind=wanted:find('roblox.com/bundles/',1,true)and'Bundle'or wantedKind;info.Text='Conferindo no Roblox…'
  local v,e=api('HighlightCheck',{id=parsed,kind=nativeKind});if idBox.Text~=wanted or itemKind~=wantedKind then return end
  if not v then info.Text=e;submit.Active=false;return end;verified=v;image.Image=A.Thumbnail(v,420);info.Text=v.Name..'\n'..cost(v)..'\nDestaque gratuito por 24 h';submit.Active=true
 end)end)
 submit.Activated:Connect(function()task.spawn(function()
  if busy then return end;local action=current and'HighlightWithdraw'or'HighlightSubmit'
  if not current and not verified then info.Text='Confira o item antes de publicar.';return end
  local r,e=api(action,current and{}or{id=verified.Id,kind=verified.ItemType});if not r then info.Text=e;toast(e);return end
  shade.Visible=false;toast(current and'Destaque retirado. O prazo original continua valendo.'or'Item em destaque por 24 horas • grátis.');run(false)
 end)end)
 publish.Activated:Connect(function()
  shade.Visible=true;current=nil;verified=nil;itemKind='Asset';kind.Text='Item';submit.Text='Publicar grátis';idBox.Text='';resetVerification();layout();picker.Open()
  task.spawn(function()local r,e=api('HighlightStatus');if not shade.Visible then return end
   if not r then info.Text=e;return end;current=r.item
   if current then idBox.Text=tostring(current.item.Id);itemKind=current.item.ItemType;kind.Text=itemKind=='Asset'and'Item'or'Pacote';image.Image=A.Thumbnail(current.item,420)
    info.Text=current.item.Name..'\nTermina em '..math.max(1,math.ceil((current.expires-os.time())/3600))..' h';submit.Text='Retirar destaque';submit.Active=true
    if not current.ready or r.indexed==false then verified=current.item;current=nil;submit.Text='Concluir envio';info.Text=verified.Name..'\nEnvio salvo • toque em Concluir envio.'end
   elseif r.nextAllowed>os.time()then info.Text='Seu próximo destaque libera em '..math.ceil((r.nextAllowed-os.time())/3600)..' h.';submit.Active=false end
   layout()
  end)
 end)
 close.Activated:Connect(function()shade.Visible=false end);cancel.Activated:Connect(function()shade.Visible=false end)
 for i,name in ipairs(groups)do local b=D.Button(groupBar,name,{Name='HighlightFilter_'..i,TextSize=12});groupButtons[i]=b;b.Activated:Connect(function()filterIndex=i;categoriesOpen=false;run(false);layout()end)end
 filter.Activated:Connect(function()categoriesOpen=not categoriesOpen;layout()end)
 tab.Activated:Connect(function()if not destinationMode then categoriesOpen=not categoriesOpen;layout();return end;destinationMode=false;destinations.Close();layout();run(false)end)
 gameTab.Activated:Connect(function()destinationMode=true;categoriesOpen=false;layout();destinations.Open('Game')end)
 communityTab.Activated:Connect(function()destinationMode=true;categoriesOpen=false;layout();destinations.Open('Community')end)
 scrollLeft.Activated:Connect(function()grid.CanvasPosition=Vector2.new(math.max(0,grid.CanvasPosition.X-grid.AbsoluteSize.X*.85),grid.CanvasPosition.Y)end)
 scrollRight.Activated:Connect(function()grid.CanvasPosition=Vector2.new(math.min(math.max(0,grid.AbsoluteCanvasSize.X-grid.AbsoluteSize.X),grid.CanvasPosition.X+grid.AbsoluteSize.X*.85),grid.CanvasPosition.Y)end)
 go.Activated:Connect(function()run(false)end);query.FocusLost:Connect(function(enter)if enter then run(false)end end)
 refresh.Activated:Connect(function()run(not finished and refresh.Text~='Recarregar')end)
 area:GetPropertyChangedSignal('AbsoluteSize'):Connect(layout)
 area:GetPropertyChangedSignal('Visible'):Connect(function()if not area.Visible then destinations.Close();destinationMode=false;shade.Visible=false;menu.Visible=false;token=token+1;loading=false;refresh.Active=true end end)
 local changed=(Rep:FindFirstChild('LMShop_Remotes')and Rep.LMShop_Remotes:FindFirstChild('HighlightChanged'));local changeConnection
 if changed then changeConnection=changed.OnClientEvent:Connect(function()if area.Visible and U.Root.Visible then if destinationMode then destinations.Refresh()else run(false)end end end)end
 local elapsed=0;local heartbeat=game:GetService('RunService').Heartbeat:Connect(function(dt)
  elapsed=elapsed+dt;if elapsed<10 or not area.Visible or not U.Root.Visible or destinationMode then return end;elapsed=0;local removed=false
  for i=#items,1,-1 do if items[i].expires and items[i].expires<=os.time()then table.remove(items,i);removed=true end end
  if removed then run(false)end
  if #items>0 and items[1].temporary then run(false)elseif #items==0 then run(false)end
 end)
 area.Destroying:Connect(function()token=token+1;heartbeat:Disconnect();if changeConnection then changeConnection:Disconnect()end end)
 layout();return{Search=function()destinationMode=false;destinations.Close();layout();run(false)end}
end
return M
