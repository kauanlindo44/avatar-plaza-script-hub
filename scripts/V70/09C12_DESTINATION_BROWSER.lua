-- 09C12_DESTINATION_BROWSER | ModuleScript | ReplicatedStorage | V69 (SUBSTITUIR)
-- Jogos/comunidades publicados, favoritos próprios e ações nativas do Roblox.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local B=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local C=D.Colors
local Fx=require(Rep:WaitForChild('07UI_SURFACE_EFFECTS'));local Groups=game:GetService('GroupService');local Social=game:GetService('SocialService');local M={Version='V69'}
function M.Build(area,ctx)
 local U={Kind='Game',Items={},Favorites=false};local generation=0;local busy=false;local finished=false;local selected;local verified;local statusRecord
 U.Root=D.New('Frame',{Name='SponsoredDestinations',BackgroundColor3=C.bg,Visible=false,ZIndex=10},area);Fx.Surface(U.Root,Color3.fromRGB(46,38,64),Color3.fromRGB(33,58,53),Color3.fromRGB(126,195,167))
 local root=U.Root;U.Heading=D.Text(root,'Jogos em destaque',{TextSize=18,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=11})
 U.Query=D.Box(root,'Nome ou ID',{TextSize=13,ZIndex=11});U.Search=D.IconButton(root,'SearchDestinations','search','Pesquisar',{ZIndex=11})
 U.FavoritesButton=D.Button(root,'Favoritos',{TextSize=12,ZIndex=11});U.Publish=D.Button(root,'Publicar grátis',{TextSize=12,BackgroundColor3=C.orange,TextColor3=C.bg,ZIndex=11})
 U.More=D.Button(root,'Recarregar',{TextSize=12,ZIndex=11});U.Note=D.Text(root,'',{TextSize=11,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=11})
 U.Grid=D.Scroll(root,{Name='DestinationGrid',AutomaticCanvasSize=Enum.AutomaticSize.None,ScrollingDirection=Enum.ScrollingDirection.XY,ScrollBarThickness=4,ZIndex=11})
 local shade=D.New('TextButton',{Name='DestinationShade',Text='',Visible=false,Size=UDim2.fromScale(1,1),BackgroundColor3=C.bg,BackgroundTransparency=.18,Active=true,ZIndex=70},root)
 local modal=D.Frame(shade,{Name='DestinationDetails',BackgroundColor3=C.panel,ZIndex=71});Fx.Surface(modal,C.panel,C.card,C.purple)
 local title=D.Text(modal,'',{Font=Enum.Font.GothamBold,TextSize=19,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=72})
 local close=D.IconButton(modal,'CloseDestination','close','Fechar detalhes',{ZIndex=80})
 local picture=D.New('ImageLabel',{Name='DestinationPicture',BackgroundColor3=C.card,ScaleType=Enum.ScaleType.Fit,ZIndex=72},modal);D.Round(picture,12)
 local detail=D.Scroll(modal,{Name='DestinationDescription',ScrollBarThickness=3,ZIndex=72})
 local text=D.Text(detail,'',{Size=UDim2.new(1,-8,0,180),AutomaticSize=Enum.AutomaticSize.Y,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,ZIndex=73})
 local primary=D.Button(modal,'Testar / jogar',{Name='NativeDestinationAction',BackgroundColor3=C.green,TextColor3=C.bg,TextSize=12,ZIndex=74})
 local like=D.Button(modal,'Curtir',{TextSize=12,ZIndex=74});local favorite=D.Button(modal,'Favoritar',{TextSize=12,ZIndex=74})
 local news=D.Button(modal,'Avisos',{TextSize=12,ZIndex=74});local events=D.Button(modal,'Eventos do jogo',{TextSize=12,ZIndex=74})
 local input=D.Box(modal,'ID ou link Roblox',{Name='DestinationID',TextSize=13,Visible=false,ZIndex=74})
 local check=D.Button(modal,'Conferir',{TextSize=12,Visible=false,ZIndex=74});local publish=D.Button(modal,'Publicar 24 h grátis',{BackgroundColor3=C.orange,TextColor3=C.bg,TextSize=12,Visible=false,ZIndex=74})
 local cards={};local compose=false;local confirmPlay=false
 local Pan=require(Rep:WaitForChild('07UI_PAN_GRID')).Bind(U.Grid,function()return root.Visible and not shade.Visible end)
 U.Left=D.Button(root,'‹',{Name='PanDestinationsLeft',TextSize=24,ZIndex=11});U.Right=D.Button(root,'›',{Name='PanDestinationsRight',TextSize=24,ZIndex=11})
 U.Left.Activated:Connect(function()Pan.Step(-1)end);U.Right.Activated:Connect(function()Pan.Step(1)end)
 local function call(action,args)local r,e=ctx.call(action,args or{});if not r then U.Note.Text=tostring(e);ctx.toast(e)end;return r,e end
 local function layout()
  local w,h=area.AbsoluteSize.X,area.AbsoluteSize.Y;local wide=w>=820 or w>=560 and h<400
  B.Rect(root,0,wide and 0 or 50,w,math.max(0,h-(wide and 0 or 50)));h=root.AbsoluteSize.Y;root.BackgroundTransparency=1
  local headerH=50;U.Heading.Visible=false
  local reserved=wide and 6+4*(math.min(100,(w-192)/4-6)+6)or 8
  local qw=math.max(44,w-reserved-108)
  B.Rect(U.Query,reserved,0,qw,44);B.Rect(U.Search,w-100,0,44,44);B.Rect(U.FavoritesButton,w-50,0,44,44)
  U.FavoritesButton.Text=U.Favorites and'♥'or'♡';U.FavoritesButton.TextSize=18
  B.Rect(U.Grid,8,headerH,w-16,math.max(0,h-headerH-52));B.Rect(U.Publish,8,h-48,132,44);B.Rect(U.More,w-112,h-48,104,44)
  B.Rect(U.Left,148,h-48,44,44);B.Rect(U.Right,198,h-48,44,44);U.Left.Visible=w>=370;U.Right.Visible=w>=370
  B.Rect(U.Note,248,h-48,math.max(0,w-368),44);U.Note.Visible=w>=660
  local gw,gh=U.Grid.AbsoluteSize.X,U.Grid.AbsoluteSize.Y
  local visibleCols=math.clamp(math.floor((gw+8)/125),2,7);local cols=15
  local cw=math.max(92,(gw-(visibleCols-1)*8-4)/visibleCols)
  local rows=gh>=136 and 2 or 1;local ch=math.clamp((gh-(rows-1)*8-4)/rows,60,242)
  U.Grid.CanvasSize=UDim2.fromOffset(math.max(gw,math.min(cols,math.max(visibleCols,math.ceil(#cards/rows)))*(cw+8)-8),math.max(gh,math.ceil(#cards/(cols*rows))*rows*(ch+8)-8))
  for i,c in ipairs(cards)do
   B.Rect(c.root,math.floor((i-1)/rows)%cols*(cw+8),((i-1)%rows+math.floor((i-1)/(cols*rows))*rows)*(ch+8),cw,ch);B.Rect(c.image,4,4,cw-8,math.max(30,ch-42));B.Rect(c.name,8,ch-38,cw-16,22);B.Rect(c.tag,8,ch-17,cw-16,17)
   B.Rect(c.favorite,cw-48,4,44,44)
  end
  local mw=math.min(720,w-12);local mh=math.min(470,h-12);B.Rect(modal,(w-mw)/2,(h-mh)/2,mw,mh)
  B.Rect(title,12,4,mw-74,44);B.Rect(close,mw-54,2,48,48)
  local tiny=mh<280;local bodyY=compose and 106 or 54;local footerRows=compose and 1 or 2;local bodyH=math.max(0,mh-bodyY-footerRows*50-10)
  local iw=math.floor(mw*.43);picture.Visible=not tiny and not compose
  B.Rect(picture,12,bodyY,iw,bodyH);B.Rect(detail,picture.Visible and iw+22 or 12,bodyY,picture.Visible and mw-iw-34 or mw-24,bodyH)
  local bw=(mw-30)/2;local ay=mh-52;B.Rect(primary,12,ay,bw,44);B.Rect(favorite,18+bw,ay,bw,44)
  B.Rect(like,12,ay-50,(mw-36)/3,44);B.Rect(news,18+(mw-36)/3,ay-50,(mw-36)/3,44);B.Rect(events,24+2*(mw-36)/3,ay-50,(mw-36)/3,44)
  for _,b in ipairs({primary,favorite,like,news,events})do b.Visible=not compose end
  B.Rect(input,12,54,mw-116,44);B.Rect(check,mw-98,54,86,44);B.Rect(publish,12,ay,mw-24,44)
  input.Visible=compose;check.Visible=compose;publish.Visible=compose;U.FavoritesButton.BackgroundColor3=U.Favorites and C.soft or C.card
 end
 local function paint()
  for _,c in ipairs(cards)do c.root:Destroy()end;cards={}
  for _,r in ipairs(U.Items)do
   local it=r.item;local b=D.Button(U.Grid,'',{Name='Destination_'..it.Id,BackgroundColor3=C.card,ZIndex=12});Fx.Button(b,C.purple)
   local im=D.New('ImageLabel',{BackgroundTransparency=1,Image=it.image or'',ScaleType=Enum.ScaleType.Fit,ZIndex=13},b)
   local name=D.Text(b,it.Name,{TextSize=13,Font=Enum.Font.GothamBold,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13})
   local tag=D.Text(b,r.permanent and'Oficial da praça'or'Publicado • 24 h',{TextSize=10,TextColor3=C.purple,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13})
   local fav=D.Button(b,r.favorite and'♥'or'♡',{Name='DestinationFavorite',TextSize=18,BackgroundTransparency=1,ZIndex=14})
   fav.Activated:Connect(function()if not Pan.CanActivate()then return end;task.spawn(function()local v=call('DestinationReaction',{id=it.Id,kind=it.ItemType,action='favorite',value=not r.favorite});if v then r.favorite=v.value;fav.Text=v.value and'♥'or'♡';ctx.toast('Favorito salvo nesta vitrine.')end end)end)
   b.Activated:Connect(function()
    if not Pan.CanActivate()then return end
    selected=r;compose=false;confirmPlay=false;shade.Visible=true;title.Text=it.Name;picture.Image=it.image or'';text.Text=it.description or''
    favorite.Text=r.favorite and'Salvo nesta vitrine'or'Favoritar';like.Text=r.liked and'Curtido nesta vitrine'or'Curtir na vitrine'
    primary.Text=it.ItemType=='Game'and'Testar / jogar'or'Entrar na comunidade';news.Text='Descrição / avisos';layout()
    task.spawn(function()local v=call('DestinationCheck',{id=it.Id,kind=it.ItemType});if selected~=r or not shade.Visible or compose then return end;if v then r.item=v;title.Text=v.Name;picture.Image=v.image or'';text.Text=v.description end end)
   end)
   cards[#cards+1]={root=b,image=im,name=name,tag=tag,favorite=fav}
  end;layout()
 end
 local function run(nextPage)
  if busy then return end;busy=true;generation=generation+1;local mine=generation;U.More.Text='Aguarde…'
  task.spawn(function()
   local r,e=call('DestinationFeed',{kind=U.Kind,search=U.Query.Text,favorites=U.Favorites,next=nextPage==true});busy=false
   if mine~=generation or not root.Visible then return end
   if not r then U.More.Text='Recarregar';return end
   if not nextPage then U.Items={};U.Grid.CanvasPosition=Vector2.zero end
   local seen={};for _,v in ipairs(U.Items)do seen[v.key]=true end
   for _,v in ipairs(r.items or{})do if not seen[v.key]and #U.Items<120 then U.Items[#U.Items+1]=v;seen[v.key]=true end end
   finished=r.finished;U.More.Text=finished and'Recarregar'or'Mais';U.Note.Text=#U.Items==0 and'Nenhum publicado nesta seleção.'or'Favoritos e curtidas salvos nesta vitrine';paint()
  end)
 end
 function U.Open(kind)
  U.Kind=kind;U.Items={};paint();U.Root.Visible=true;U.Query.Text='';U.Favorites=false;U.Heading.Text=kind=='Game'and'Jogos em destaque'or'Comunidades em destaque';layout();run(false)
 end
 function U.Refresh()if root.Visible and not shade.Visible then run(false)end end
 function U.Close()generation=generation+1;busy=false;root.Visible=false;shade.Visible=false end
 primary.Activated:Connect(function()
  if not selected then return end;local it=selected.item
  task.spawn(function()
   if it.ItemType=='Community'then local ok,result=pcall(function()return Groups:PromptJoinAsync(it.Id)end);text.Text=ok and('Roblox: '..tostring(result)..'\n'..(it.description or''))or'O Roblox não abriu a entrada na comunidade neste dispositivo. Tente no jogo publicado.';return end
   local r=call('DestinationPlay',{id=it.Id,confirm=confirmPlay});if not r then return end
   if r.here then text.Text='Você já está nesta experiência.'
   elseif r.confirm then confirmPlay=true;primary.Text='Entrar agora';text.Text='Entrar em '..r.name..' encerra sua sessão aqui. Toque Entrar agora para continuar.'
   else text.Text='O Roblox está iniciando a entrada…'end
  end)
 end)
 favorite.Activated:Connect(function()if not selected then return end;local r=selected;task.spawn(function()local v=call('DestinationReaction',{kind=r.item.ItemType,id=r.item.Id,action='favorite',value=not r.favorite});if v and selected==r then r.favorite=v.value;favorite.Text=v.value and'Salvo nesta vitrine'or'Favoritar';paint()end end)end)
 like.Activated:Connect(function()if not selected then return end;local r=selected;task.spawn(function()local v=call('DestinationReaction',{kind=r.item.ItemType,id=r.item.Id,action='like',value=not r.liked});if v and selected==r then r.liked=v.value;like.Text=v.value and'Curtido nesta vitrine'or'Curtir na vitrine'end end)end)
 news.Activated:Connect(function()if selected then local it=selected.item;text.Text=(it.notice and it.notice~=''and('Aviso público\n'..it.notice..'\n\n')or'')..(it.description or'') end end)
 events.Activated:Connect(function()
  text.Text='Eventos oficiais da experiência atual…';task.spawn(function()
   local ok,rows=pcall(function()return Social:GetUpcomingExperienceEventsAsync()end)
   if not shade.Visible or compose then return end
   if not ok then text.Text='O Roblox não disponibilizou os eventos neste dispositivo.';return end
   local nextEvent;for _,event in ipairs(rows or{})do if not event.HasEnded then nextEvent=event;break end end
   if not nextEvent then text.Text='Não há eventos oficiais ativos ou futuros nesta experiência. A consulta nativa não fornece eventos de qualquer comunidade externa.';return end
   local shown=pcall(function()Social:PromptRsvpToEventAsync(nextEvent.Id)end);text.Text=shown and'O evento oficial foi aberto pelo Roblox.'or'O Roblox não abriu os detalhes do evento.'
  end)
 end)
 U.Publish.Activated:Connect(function()
  compose=true;selected=nil;verified=nil;statusRecord=nil;shade.Visible=true;title.Text=U.Kind=='Game'and'Publicar um jogo'or'Publicar uma comunidade';input.Text='';picture.Image='';text.Text='Cole o ID ou link e toque em Conferir.\nGrátis • um por pessoa nesta categoria • 24 horas.';publish.Text='Publicar 24 h grátis';publish.Active=false;layout()
  task.spawn(function()local r=call('DestinationStatus',{kind=U.Kind});if not compose or not shade.Visible then return end;statusRecord=r
   if r and r.item then local it=r.item.item;input.Text=tostring(it.Id);verified=it;text.Text=it.Name..'\nDestaque de 24 h • termina em '..math.max(1,math.ceil((r.item.expires-os.time())/3600))..' h.';publish.Text=r.item.ready and'Retirar destaque'or'Concluir envio';publish.Active=true
   elseif r and r.nextAllowed>os.time()then text.Text='Seu próximo destaque nesta categoria libera em '..math.ceil((r.nextAllowed-os.time())/3600)..' h.'end
  end)
 end)
 input:GetPropertyChangedSignal('Text'):Connect(function()verified=nil;publish.Active=false end)
 check.Activated:Connect(function()task.spawn(function()
  local wanted=input.Text;local parsed=wanted:match('/games/(%d+)')or wanted:match('/communities/(%d+)')or wanted:match('/groups/(%d+)')or wanted;local r=call('DestinationCheck',{kind=U.Kind,id=parsed})
  if wanted~=input.Text or not shade.Visible or not compose then return end
  if r then verified=r;text.Text=r.Name..'\n'..r.description;publish.Active=true end
 end)end)
 publish.Activated:Connect(function()if not verified then return end;task.spawn(function()
  local withdrawing=statusRecord and statusRecord.item and statusRecord.item.ready
  local r=call(withdrawing and'DestinationWithdraw'or'DestinationSubmit',{kind=U.Kind,id=verified.Id});if r then shade.Visible=false;run(false)end
 end)end)
 close.Activated:Connect(function()shade.Visible=false;selected=nil;compose=false end)
 U.Search.Activated:Connect(function()run(false)end);U.Query.FocusLost:Connect(function(enter)if enter then run(false)end end)
 U.FavoritesButton.Activated:Connect(function()U.Favorites=not U.Favorites;run(false);layout()end)
 U.More.Activated:Connect(function()run(not finished)end)
 local elapsed=0;local clock=game:GetService('RunService').Heartbeat:Connect(function(dt)
  elapsed=elapsed+dt;if elapsed<10 or not root.Visible or shade.Visible then return end;elapsed=0
  for _,r in ipairs(U.Items)do if r.expires and r.expires<=os.time()then run(false);break end end
 end)
 root.Destroying:Connect(function()generation=generation+1;clock:Disconnect();Pan.Destroy()end)
 root:GetPropertyChangedSignal('AbsoluteSize'):Connect(layout);area:GetPropertyChangedSignal('AbsoluteSize'):Connect(layout)
 return U
end
return M
