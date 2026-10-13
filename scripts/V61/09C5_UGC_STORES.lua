-- 09C5_UGC_STORES | ModuleScript | ReplicatedStorage | V61 (SUBSTITUIR)
-- Destaques grátis, linhas horizontais, favoritos independentes e compra oficial.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'))
local Fx=require(Rep:WaitForChild('07UI_SURFACE_EFFECTS'));local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'))
local C=D.Colors;local M={}
function M.Init(ctx)
 local U,A,call,toast=ctx.U,ctx.A,ctx.call,ctx.toast;local area=U.StoresArea;local grid=U.StoreGrid
 local query,status,filter,go=U.StoreSearch,U.StoreStatus,U.StoreType,U.StoreGo;local header=query.Parent
 local old=grid:FindFirstChildOfClass('UIGridLayout');if old then old:Destroy()end
 grid.AutomaticCanvasSize=Enum.AutomaticSize.None;grid.CanvasSize=UDim2.new();grid.ScrollingEnabled=false;grid.ScrollBarThickness=0
 local rows,cards={},{};local items={};local filterIndex=1;local token=0;local loading=false;local finished=false;local busy=false
 local groups={'Todos','Roupas','Acessórios','Corpo','Emotes','Favoritos'}
 local refresh=D.Button(area,'Mais itens',{Name='MoreHighlights',TextSize=12})
 local publish=D.Button(area,'Patrocinar grátis',{Name='PublishHighlight',TextSize=13,BackgroundColor3=Color3.fromRGB(109,65,34)})
 local ia=D.Button(area,'IA de looks',{Name='AssistantTab',TextSize=13});ia.Activated:Connect(function()if ctx.openAssistant then ctx.openAssistant()end end)
 local tab=D.Button(area,'Patrocinar',{Name='SponsorTab',TextSize=13,BackgroundColor3=C.orange});
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
 local current,verified=nil,nil;local lastFeed=-10;local itemKind='Asset';local render,run
 Fx.Surface(area,C.bg,C.panel);Fx.Surface(p,C.panel,C.card,C.orange);Fx.Button(publish,C.orange);Fx.Button(refresh,C.blue)
 for i=1,3 do rows[i]=D.New('ScrollingFrame',{Name='HighlightRow'..i,BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.None,ScrollingDirection=Enum.ScrollingDirection.X,ScrollBarThickness=3,ScrollBarImageColor3=C.orange,Active=true,ClipsDescendants=true},grid)end
 local function cost(it)return it.Price==0 and'Grátis'or it.Price and(math.floor(it.Price)..' Robux')or'Ver preço'end
 local function api(action,args)
  if busy then return nil,'Aguarde a operação anterior.'end;busy=true;local r,e=call(action,args or{});busy=false;return r,e
 end
 local function clear()
  cards={};for _,row in ipairs(rows)do for _,o in ipairs(row:GetChildren())do o:Destroy()end;row.CanvasPosition=Vector2.zero end
 end
 local function card(r,i)
  local it=r.item;it.ItemType=A.ItemType(it);it.Price=A.Price(it);local b=D.Button(rows[1],'',{Name='Featured_'..it.ItemType..'_'..it.Id,BackgroundColor3=C.card})
  local pad=b:FindFirstChildOfClass('UIPadding');if pad then pad:Destroy()end;Fx.Button(b,C.orange)
  local im=D.New('ImageLabel',{Name='ItemThumbnail',Image=A.Thumbnail(it,420),BackgroundColor3=Color3.fromRGB(120,132,151),ScaleType=Enum.ScaleType.Fit,Active=false},b);D.Round(im,8)
  local name=D.Text(b,r.temporary and'Exemplo temporário'or it.Name,{Name='ItemName',Font=Enum.Font.GothamBold,TextSize=12,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left})
  local price=D.Text(b,cost(it),{Name='ItemPrice',TextSize=12,TextColor3=C.gold,TextWrapped=false,TextXAlignment=Enum.TextXAlignment.Left})
  local buy=D.Button(b,'Comprar',{Name='BuyFeatured',TextSize=11,BackgroundColor3=Color3.fromRGB(60,87,65)})
  local fav=D.Button(b,r.favorite and'♥'or'♡',{Name='FavoriteFeatured',TextSize=20})
  b.Activated:Connect(function()ctx.showItem(it)end)
  buy.Active=not it.unavailable;if it.unavailable then buy.Text='Indisponível'end
  buy.Activated:Connect(function()if it.unavailable then return end;task.spawn(function()local ok,e=api('HighlightPurchase',{id=it.Id,kind=it.ItemType});if not ok then toast(e)end end)end)
  fav.Activated:Connect(function()task.spawn(function()local d,e=api('HighlightFavorite',{id=it.Id,kind=it.ItemType,value=not r.favorite});if d then r.favorite=d.value;fav.Text=r.favorite and'♥'or'♡'else toast(e)end end)end)
  cards[#cards+1]={root=b,image=im,name=name,price=price,buy=buy,fav=fav,index=i}
 end
 local picker=require(Rep:WaitForChild('09C9_SPONSOR_PICKER')).Build(shade,ctx,function(it)idBox.Text=tostring(it.Id);itemKind=it.ItemType=='Bundle'and'Bundle'or'Asset';kind.Text=itemKind=='Bundle'and'Pacote'or'Item';verified=nil;image.Image=A.Thumbnail(it,420);info.Text=tostring(it.Name)..'\nToque em Conferir para validar no Roblox.';submit.Active=false end)
 local browse=D.Button(p,'Buscar por nome',{Name='BrowseSponsor',TextSize=12,ZIndex=73});browse.Activated:Connect(function()picker.Open()end)
 local function layout()
  local w,h=area.AbsoluteSize.X,area.AbsoluteSize.Y;if w<1 or h<1 then return end
  local wide=w>=580;local tabsW=wide and 98 or math.min(150,(w-18)/2)
  Bounds.Rect(tab,6,0,tabsW,44);Bounds.Rect(ia,12+tabsW,0,tabsW,44)
  Bounds.Rect(header,wide and 218 or 6,wide and 0 or 50,wide and w-224 or w-12,48);header.BackgroundTransparency=1
  local mw=math.min(300,w-12);Bounds.Rect(menu,w-mw-6,100,mw,150)
  for i,b in ipairs(filterButtons)do Bounds.Rect(b,6+(i-1)%2*(mw-6)/2,6+math.floor((i-1)/2)*48,(mw-18)/2,44)end
  local hw=header.AbsoluteSize.X;Bounds.Rect(query,0,2,hw-150,44);Bounds.Rect(go,hw-144,2,44,44);Bounds.Rect(filter,hw-94,2,94,44)
  query.PlaceholderText='Buscar item ou ID';filter.Text=groups[filterIndex];go.Text=''
  if not go:FindFirstChild('SearchIcon')then D.Icon(go,'search',{Name='SearchIcon',AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(20,20)})end
  local gy=wide and 52 or 100;Bounds.Rect(grid,6,gy,w-12,math.max(1,h-gy-50));Bounds.Rect(publish,6,h-46,142,44);Bounds.Rect(refresh,w-110,h-46,104,44)
  Bounds.Rect(status,156,h-44,w-274,40);status.TextSize=11;status.Visible=w>=500
  local gw,gh=grid.AbsoluteSize.X,grid.AbsoluteSize.Y;local n=gh>=300 and 3 or gh>=130 and 2 or 1
  local cols=math.clamp(math.floor((gw+6)/106),2,7);local cw=(gw-(cols-1)*6)/cols;local ch=(gh-(n-1)*6)/n
  for i,row in ipairs(rows)do row.Visible=i<=n;row:SetAttribute('VisibleColumns',cols);row:SetAttribute('VisibleRows',n);Bounds.Rect(row,0,(i-1)*(ch+6),gw,ch);row.CanvasSize=UDim2.fromOffset(math.max(gw,math.ceil(#cards/n)*(cw+6)-6),0)end
  for i,s in ipairs(cards)do
   local line=(i-1)%n+1;local x=math.floor((i-1)/n)
   s.root.Parent=rows[line];Bounds.Rect(s.root,x*(cw+6),0,cw,ch-4)
   local ih=math.max(16,ch-34);Bounds.Rect(s.image,3,3,cw-6,ih);Bounds.Rect(s.name,4,ch-31,cw-8,15);Bounds.Rect(s.price,4,ch-16,cw-8,14)
   Bounds.Rect(s.buy,3,ch-50,cw-53,44);Bounds.Rect(s.fav,cw-47,ch-50,44,44)
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
   items=r.items or{};if #items==0 and r.emptyGlobal and groups[filterIndex]~='Favoritos'then
    local p=CatalogSearchParams.new();p.SearchKeyword=query.Text;p.IncludeOffSale=false;p.Limit=30;p.AssetTypes={Enum.AvatarAssetType.Shirt,Enum.AvatarAssetType.Pants,Enum.AvatarAssetType.Hat,Enum.AvatarAssetType.HairAccessory};p.SortType=Enum.CatalogSortType.Relevance
    local ok,examples=pcall(function()return game:GetService('AvatarEditorService'):SearchCatalogAsync(p):GetCurrentPage()end)
    if mine~=token then return end;if ok then for i,it in ipairs(examples or{})do if i>28 then break end;items[#items+1]={item=it,key='Asset:'..it.Id,favorite=false,temporary=true}end end
   end;finished=r.finished;refresh.Text=finished and'Atualizar'or'Mais itens';status.Text='Grátis • 24 h • deslize para o lado';empty.Text=groups[filterIndex]=='Favoritos'and'Seus favoritos aparecem aqui. Toque em ♡ nos itens para salvar.'or'Nenhum patrocínio nesta seleção. Publique um item gratuitamente.';render()
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
 for i,name in ipairs(groups)do local b=D.Button(menu,name,{Name='HighlightFilter_'..i,TextSize=12,ZIndex=51});filterButtons[i]=b;b.Activated:Connect(function()filterIndex=i;menu.Visible=false;run(false);layout()end)end
 filter.Activated:Connect(function()menu.Visible=not menu.Visible;layout()end)
 tab.Activated:Connect(function()run(false)end)
 go.Activated:Connect(function()run(false)end);query.FocusLost:Connect(function(enter)if enter then run(false)end end)
 refresh.Activated:Connect(function()run(not finished and refresh.Text~='Recarregar')end)
 area:GetPropertyChangedSignal('AbsoluteSize'):Connect(layout)
 area:GetPropertyChangedSignal('Visible'):Connect(function()if not area.Visible then shade.Visible=false;menu.Visible=false;token=token+1;loading=false;refresh.Active=true end end)
 local changed=(Rep:FindFirstChild('LMShop_Remotes')and Rep.LMShop_Remotes:FindFirstChild('HighlightChanged'));local changeConnection
 if changed then changeConnection=changed.OnClientEvent:Connect(function()if area.Visible and U.Root.Visible then run(false)end end)end
 local elapsed=0;local heartbeat=game:GetService('RunService').Heartbeat:Connect(function(dt)
  elapsed=elapsed+dt;if elapsed<10 or not area.Visible or not U.Root.Visible then return end;elapsed=0;local removed=false
  for i=#items,1,-1 do if items[i].expires and items[i].expires<=os.time()then table.remove(items,i);removed=true end end
  if removed then render()end
  if #items>0 and items[1].temporary then run(false)elseif #items==0 then run(false)end
 end)
 area.Destroying:Connect(function()token=token+1;heartbeat:Disconnect();if changeConnection then changeConnection:Disconnect()end end)
 layout();return{Search=function()run(false)end}
end
return M
