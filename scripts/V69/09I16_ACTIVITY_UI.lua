-- 09I16_ACTIVITY_UI | ModuleScript | ReplicatedStorage | V69 (NOVO)
-- Quatro atividades com ações explícitas, prévia e convites; teclado e áreas seguras.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local C=D.Colors
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local Rules=require(Rep:WaitForChild('09I15_ACTIVITY_RULES'))
local Styles=require(Rep:WaitForChild('09I8_AVATAR_STYLES'));local Preview=require(Rep:WaitForChild('09C6_AVATAR_PREVIEW'))
local Choice=require(Rep:WaitForChild('07UI_CHOICE_LIST'));local M={}
function M.Build(pl,run)
 local pg=pl:WaitForChild('PlayerGui');local old=pg:FindFirstChild('ACP_Activities');if old then old:Destroy()end
 local U={Kind=nil,Draft=Rules.Settings({}),State=nil,Players={},Invites={},Mine={},Selected=pl.UserId,Busy=false}
 U.Gui=D.New('ScreenGui',{Name='ACP_Activities',ResetOnSpawn=false,IgnoreGuiInset=true,ScreenInsets=Enum.ScreenInsets.None,DisplayOrder=195,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
 U.Root=D.New('Frame',{Name='CreativeActivities',Size=UDim2.fromScale(1,1),BackgroundColor3=C.bg,Visible=false},U.Gui)
 local safe=Bounds.Bind(U.Gui);U.Safe=safe
 U.Title=D.Text(U.Root,'Criar com amigos',{Font=Enum.Font.GothamBold,TextSize=23,TextXAlignment=Enum.TextXAlignment.Left})
 U.Close=D.IconButton(U.Root,'CloseActivities','close','Voltar à praça')
 U.Back=D.Button(U.Root,'‹ Atividades',{TextSize=14});U.Inbox=D.Button(U.Root,'Convites',{TextSize=14});U.Reload=D.IconButton(U.Root,'RefreshActivities','reset','Atualizar atividade')
 U.Status=D.Text(U.Root,'Criação guiada · busca real no catálogo · sem compras automáticas',{TextSize=14,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 U.Home=D.New('Frame',{Name='ActivityChoices',BackgroundTransparency=1},U.Root);U.HomeButtons={}
 for i,v in ipairs(Rules.Activities)do
  local b=D.Button(U.Home,'',{Name='Activity_'..v.id,BackgroundColor3=C.panel});U.HomeButtons[i]=b
  local icon=D.Icon(b,v.icon,{Size=UDim2.fromOffset(38,38),IconColor=i%2==0 and C.purple or C.green});icon.Name='ActivityIcon'
  D.Text(b,v.name,{Name='ActivityName',Font=Enum.Font.GothamBold,TextSize=19,TextXAlignment=Enum.TextXAlignment.Left})
  D.Text(b,v.note,{Name='ActivityNote',TextSize=14,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
  b.Activated:Connect(function()U.Kind=v.id;U.Layout();U.Render()end)
 end
 U.Work=D.New('Frame',{Name='ActivityWorkspace',BackgroundTransparency=1,Visible=false},U.Root)
 U.FormPane=D.Scroll(U.Work,{Name='ActivityFormPane',BackgroundTransparency=1,AutomaticCanvasSize=Enum.AutomaticSize.None})
 U.Settings=D.New('Frame',{Name='ActivitySettings',BackgroundTransparency=1},U.Work)
 U.Style=D.Button(U.Settings,'Estilo ▾',{TextSize=14});U.Budget=D.Box(U.Settings,'Robux por look',{Text='100',TextSize=15})
 U.Palette=D.Button(U.Settings,'Cores livres ▾',{TextSize=14});U.Format=D.Button(U.Settings,'Roupa clássica 2D ▾',{TextSize=14})
 U.Note=D.Text(U.Work,'',{TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=C.muted})
 U.Stage=D.Frame(U.Work,{Name='ActivityPreviewStage',BackgroundColor3=Color3.fromRGB(166,181,187),ClipsDescendants=true})
 U.View=D.New('ViewportFrame',{Name='ActivityAvatar',Position=UDim2.fromOffset(4,4),Size=UDim2.new(1,-8,1,-8),BackgroundTransparency=1},U.Stage)
 U.Pager=D.New('Frame',{Name='ActivityLookPager',BackgroundTransparency=1},U.Work)
 U.Prev=D.Button(U.Pager,'‹',{TextSize=24});U.Next=D.Button(U.Pager,'›',{TextSize=24});U.LookName=D.Text(U.Pager,'',{TextSize=14,Font=Enum.Font.GothamBold})
 U.Detail=D.Scroll(U.Work,{Name='ActivityDetails',BackgroundColor3=C.panel,BackgroundTransparency=0,ScrollBarThickness=3});D.Round(U.Detail)
 U.List=D.New('UIListLayout',{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},U.Detail);D.Pad(U.Detail,10,10,8,8)
 U.Credit=D.Text(U.Work,'',{TextSize=13,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
 U.Toolbar=D.New('Frame',{BackgroundTransparency=1},U.Root)
 U.Start=D.Button(U.Toolbar,'Criar atividade',{Name='ActivityStart',BackgroundColor3=C.green,TextColor3=C.bg,TextSize=14})
 U.Invite=D.Button(U.Toolbar,'Convidar',{TextSize=14});U.Contribute=D.Button(U.Toolbar,'Contribuir',{TextSize=14});U.Leave=D.Button(U.Toolbar,'Encerrar',{TextSize=14,TextColor3=C.red})
 U.More=D.Button(U.Toolbar,'Mais opções',{Name='MoreActivityActions',TextSize=14,Visible=false})
 U.Actions=D.New('Frame',{BackgroundTransparency=1},U.Root)
 U.Apply=D.Button(U.Actions,'Aplicar',{TextSize=14});U.Save=D.Button(U.Actions,'Guardar',{TextSize=14});U.Cart=D.Button(U.Actions,'Carrinho',{TextSize=14});U.Catalog=D.Button(U.Actions,'Catálogo',{TextSize=14})
 U.Remix=D.New('Frame',{Name='RemixPermissionTools',BackgroundTransparency=1},U.Work)
 U.Code=D.Box(U.Remix,'Cole um código de remix',{TextSize=14});U.OpenCode=D.Button(U.Remix,'Abrir código',{TextSize=14})
 U.Publish=D.Button(U.Remix,'Compartilhar combinação',{TextSize=14});U.MySources=D.Button(U.Remix,'Meus códigos',{TextSize=14})
 U.Permission=D.Button(U.Remix,'Remix bloqueado',{TextSize=14});U.Copy=D.Button(U.Remix,'Selecionar código',{TextSize=14})
 U.Choices=Choice.Build(U.Root)
 U.Invitation=D.Frame(U.Root,{Name='ActivityInvitation',BackgroundColor3=C.panel,Visible=false,ZIndex=80});D.Stroke(U.Invitation,C.green,.3)
 U.InviteText=D.Text(U.Invitation,'',{Position=UDim2.fromOffset(12,8),Size=UDim2.new(1,-24,0,54),TextSize=16,ZIndex=81})
 U.Accept=D.Button(U.Invitation,'Aceitar',{Position=UDim2.new(0,12,1,-56),Size=UDim2.new(.5,-18,0,44),BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=82})
 U.Decline=D.Button(U.Invitation,'Recusar',{Position=UDim2.new(.5,6,1,-56),Size=UDim2.new(.5,-18,0,44),ZIndex=82})
 local function call(action,data,done)
  if U.Busy then return end;U.Busy=true;D.SetEnabled(U.Start,false);U.Status.Text='Aguarde…'
  task.spawn(function()local value,e=run(action,data or{});U.Busy=false;D.SetEnabled(U.Start,true)
   if not value then U.Status.Text=e or'Não foi possível concluir.';return end
   if done then done(value)end;U.Render()
  end)
 end
 function U.SetState(s)
  U.State=s;if s then U.Kind=s.kind;U.Draft=Rules.Settings(s.settings);for _,p in ipairs(s.members)do if p.uid==pl.UserId then U.Draft.style=p.style end end;U.Budget.Text=tostring(U.Draft.budget)end
  U.Render()
 end
 function U.SetStatus(data)
  U.Players=data.players or{};U.Invites=data.invites or{};U.SetState(data.session);U.Inbox.Text=#U.Invites>0 and('Convites ('..#U.Invites..')')or'Convites'
 end
 function U.VisibleLook()
  local s=U.State;if not s or s.kind~=U.Kind then return end
  if s.kind=='collab'or s.kind=='remix'then return s.look,true end
  for _,entry in ipairs(s.results or{})do if entry.uid==U.Selected then return entry.look,entry.uid==pl.UserId,entry.name end end
 end
 local function line(text,order)
  local label=D.Text(U.Detail,text,{Size=UDim2.new(1,-4,0,48),TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,LayoutOrder=order})
  local function fit()label.Size=UDim2.new(1,-4,0,math.max(36,label.TextBounds.Y+8))end;label:GetPropertyChangedSignal('TextBounds'):Connect(fit);task.defer(fit);return label
 end
 function U.Render()
  local rule=Rules.Activity(U.Kind);U.Home.Visible=rule==nil;U.Work.Visible=rule~=nil;U.Toolbar.Visible=rule~=nil;U.Actions.Visible=rule~=nil;U.Back.Visible=rule~=nil
  U.Title.Text=rule and rule.name or'Criar com amigos'
  local s=U.State;local joined=s and s.kind==U.Kind
  U.Style.Text='Estilo · '..Styles.Get(U.Draft.style).name..' ▾';U.Palette.Text=Rules.Palette(U.Draft.palette).name..' ▾';U.Format.Text=U.Draft.format=='3D'and'Camadas 3D ▾'or'Roupa clássica 2D ▾'
  U.Start.Text=not joined and'Criar atividade'or U.Kind=='shoot'and'Abrir ensaio'or U.Kind=='duo'and'Sugerir meu look'or'Sugerir base'
  U.Contribute.Visible=joined and U.Kind=='collab';U.Invite.Visible=joined and s.owner==pl.UserId and Rules.Activity(s.kind).max>1;U.Leave.Visible=joined
  U.Leave.Text=joined and s.owner==pl.UserId and'Encerrar'or'Sair'
  U.Note.Text=rule and(rule.note..(U.Kind=='collab'and' A nova base substitui a composição compartilhada. Use o catálogo antes de enviar suas peças.'or''))or''
  U.Remix.Visible=U.Kind=='remix';U.Permission.Text=U.Source and U.Source.allow and'Remix autorizado ✓'or'Remix bloqueado';D.SetEnabled(U.Permission,U.Source~=nil)
  for _,o in ipairs(U.Detail:GetChildren())do if o:IsA('GuiObject')then o:Destroy()end end
  if joined then
   line('Participantes · '..#s.members,1)
   for i,v in ipairs(s.members)do line((v.uid==s.owner and'Criador · 'or'')..v.name..' · '..Styles.Get(v.style).name..(v.remixAllowed and' · remix ✓'or''),1+i)end
   if U.Kind=='shoot'then for i,v in ipairs(s.steps or{})do line(v.title..'\n'..v.text,10+i).Size=UDim2.new(1,-4,0,98)end
   elseif U.Kind=='collab'then line('Aplique ou guarde quando todos estiverem satisfeitos. Cada contribuição altera somente a parte escolhida.',10).Size=UDim2.new(1,-4,0,82)
   elseif U.Kind=='duo'then line(Rules.Prompt(U.Draft).note,10).Size=UDim2.new(1,-4,0,78)end
  else line('1 · Escolha estilo, orçamento e paleta.\n2 · Crie a atividade.\n3 · Convide pessoas ou peça uma sugestão.',1).Size=UDim2.new(1,-4,0,110)end
  local look,mine,name=U.VisibleLook();U.Look=look
  local fingerprint=look and tostring(look.signature or'')..tostring(look.total)..tostring(joined and s.revision)..tostring(U.Selected)or''
  if fingerprint~=U.PreviewKey or not U.Root.Visible then
   U.PreviewKey=fingerprint;Preview.Unmount(U.View)
   if look and U.Root.Visible then Preview.Mount(U.View,look.body,look.rig,{drag=true,floor=false,zoom=1.03,failed=function(e)U.Status.Text=e end})end
  end
  U.LookName.Text=name or(look and look.name)or'Prévia da combinação'
  U.Credit.Text=look and(look.remix and('Original: @'..look.remix.originalCreatorName..' · remix com autorização')or'Confira a combinação antes de aplicar.')or''
  if look and look.contributors then local names={};for _,v in ipairs(look.contributors)do names[#names+1]=v.name end;U.Credit.Text='Colaboração: '..table.concat(names,', ')end
  if look then line(look.pricePending and'Preço das peças a consultar.'or('Roupas: '..tostring(look.total or'?')..' Robux'),20)end
  D.SetEnabled(U.Apply,look~=nil and mine==true);D.SetEnabled(U.Save,look~=nil and mine==true);D.SetEnabled(U.Cart,look~=nil)
  U.Prev.Visible=joined and U.Kind=='duo'and #s.results>1;U.Next.Visible=U.Prev.Visible
  U.Layout()
 end
 function U.Layout()
  local il,it,ir,ib,w,h=safe.Read();local aw=w-il-ir;local top=safe.Heading(U.Title,U.Close);local bar=safe.Topbar()
  local landscape=w>h and aw>=520;local compact=landscape or h-it-ib<550;U.Compact=compact
  if landscape and bar.Right-bar.X>=320 and bar.Bottom-bar.Y>=48 then Bounds.Rect(U.Title,bar.X+6,bar.Y+4,bar.Right-bar.X-70,44);Bounds.Rect(U.Close,bar.Right-54,bar.Y+2,48,48);top=it+4 end
  local row=top;Bounds.Rect(U.Back,il+6,row,112,44);Bounds.Rect(U.Inbox,w-ir-156,row,100,44);Bounds.Rect(U.Reload,w-ir-50,row,44,44)
  U.Status.Visible=U.Kind~=nil or not compact;Bounds.Rect(U.Status,il+8,row+48,aw-16,34)
  local y=row+(compact and 50 or 86);local height=math.max(1,h-ib-y-8);Bounds.Rect(U.Home,il+8,y,aw-16,height)
  local cols=aw>=1000 and 4 or 2;local gap=12;local cw=(aw-16-gap*(cols-1))/cols;local ch=(height-gap*(math.ceil(4/cols)-1))/math.ceil(4/cols)
  for i,b in ipairs(U.HomeButtons)do
   Bounds.Rect(b,(i-1)%cols*(cw+gap),math.floor((i-1)/cols)*(ch+gap),cw,ch)
   local compact=ch<130;local icon=b:FindFirstChild('ActivityIcon');local name=b:FindFirstChild('ActivityName');local note=b:FindFirstChild('ActivityNote')
   Bounds.Rect(icon,12,12,compact and 26 or 38,compact and 26 or 38);Bounds.Rect(name,12,compact and 42 or 60,cw-24,compact and 40 or 54);name.TextSize=compact and 15 or 19
   note.Visible=ch>=165;Bounds.Rect(note,12,114,cw-24,math.max(30,ch-126))
  end
  local active=U.Kind~=nil;local controlRows=aw<520 and 2 or 1;local controls=controlRows*48;local footer=active and(compact and 76 or 98)or 0
  Bounds.Rect(U.Work,il+8,y,aw-16,math.max(1,height-footer));local ww,wh=aw-16,math.max(1,height-footer)
  for _,o in ipairs({U.Settings,U.Note,U.Remix,U.Detail})do o.Parent=landscape and U.FormPane or U.Work end
  U.FormPane.Visible=landscape
  Bounds.Rect(U.Settings,0,0,ww,controls)
  local cols2=controlRows==2 and 2 or 4;local fw=(ww-(cols2-1)*6)/cols2
  for i,b in ipairs({U.Style,U.Budget,U.Palette,U.Format})do Bounds.Rect(b,(i-1)%cols2*(fw+6),math.floor((i-1)/cols2)*48,fw,44)end
  U.Note.Visible=not compact and wh>=300;local noteH=U.Note.Visible and 48 or 0;Bounds.Rect(U.Note,0,controls,ww,noteH)
  local ry=controls+noteH;local remixH=U.Remix.Visible and(aw<620 and 144 or 96)or 0
  Bounds.Rect(U.Remix,0,ry,ww,remixH)
  Bounds.Rect(U.Code,0,0,ww-110,44);Bounds.Rect(U.OpenCode,ww-104,0,104,44)
  local rc=aw<620 and 2 or 4;local rw=(ww-(rc-1)*6)/rc
  for i,b in ipairs({U.Publish,U.MySources,U.Permission,U.Copy})do Bounds.Rect(b,(i-1)%rc*(rw+6),48+math.floor((i-1)/rc)*48,rw,44);b.TextSize=13 end
  ry=ry+remixH+4;local available=math.max(1,wh-ry-32);local wide=aw>=700 and w>h
  local stageW=wide and math.floor(ww*.58)or math.floor(ww*.55);local detailW=ww-stageW-8
  Bounds.Rect(U.Stage,0,ry,stageW,math.max(1,available-44));Bounds.Rect(U.Pager,0,ry+available-44,stageW,44)
  Bounds.Rect(U.Prev,0,0,44,44);Bounds.Rect(U.Next,stageW-44,0,44,44);Bounds.Rect(U.LookName,U.Prev.Visible and 46 or 0,0,stageW-(U.Prev.Visible and 92 or 0),44)
  Bounds.Rect(U.Detail,stageW+8,ry,detailW,available);Bounds.Rect(U.Credit,0,wh-30,ww,28)
  Bounds.Rect(U.Toolbar,il+8,h-ib-100,aw-16,44);Bounds.Rect(U.Actions,il+8,h-ib-50,aw-16,44)
  U.More.Visible=compact;U.Actions.Visible=active and not compact
  local primary={U.Start};for _,b in ipairs({U.Invite,U.Contribute,U.Leave})do if compact then b.Visible=false elseif b.Visible then primary[#primary+1]=b end end
  if compact then primary={U.Start,U.Apply,U.Save,U.More};U.Apply.Parent=U.Toolbar;U.Save.Parent=U.Toolbar;Bounds.Rect(U.Toolbar,il+8,h-ib-50,aw-16,44)else U.Apply.Parent=U.Actions;U.Save.Parent=U.Actions end
  local bw=(aw-16-(#primary-1)*6)/#primary;for i,b in ipairs(primary)do Bounds.Rect(b,(i-1)*(bw+6),0,bw,44)end
  if compact and active then Bounds.Rect(U.Status,il+8,h-ib-78,aw-16,24)end
  if not compact then local bw2=(aw-34)/4;for i,b in ipairs({U.Apply,U.Save,U.Cart,U.Catalog})do Bounds.Rect(b,(i-1)*(bw2+6),0,bw2,44)end end
  if landscape then
   local fw=math.clamp(ww*.32,190,300);Bounds.Rect(U.FormPane,0,0,fw,wh);local cell=(fw-10)/2
   Bounds.Rect(U.Settings,0,0,fw-4,96);for i,b in ipairs({U.Style,U.Budget,U.Palette,U.Format})do Bounds.Rect(b,(i-1)%2*(cell+6),math.floor((i-1)/2)*48,cell,44)end
   U.Note.Visible=false;local rh=U.Remix.Visible and 192 or 0;Bounds.Rect(U.Remix,0,100,fw-4,rh)
   if U.Remix.Visible then
    Bounds.Rect(U.Code,0,0,fw-4,44);Bounds.Rect(U.OpenCode,0,48,fw-4,44)
    local rw=(fw-10)/2;for i,b in ipairs({U.Publish,U.MySources,U.Permission,U.Copy})do Bounds.Rect(b,(i-1)%2*(rw+6),96+math.floor((i-1)/2)*48,rw,44)end
   end
   Bounds.Rect(U.Detail,0,104+rh,fw-4,math.max(130,wh-108-rh));U.FormPane.CanvasSize=UDim2.fromOffset(0,104+rh+U.Detail.Size.Y.Offset)
   local sx=fw+10;local sw=ww-sx;Bounds.Rect(U.Stage,sx,0,sw,math.max(50,wh-72));Bounds.Rect(U.Pager,sx,wh-72,sw,44)
   Bounds.Rect(U.Prev,0,0,44,44);Bounds.Rect(U.Next,sw-44,0,44,44);Bounds.Rect(U.LookName,U.Prev.Visible and 46 or 0,0,sw-(U.Prev.Visible and 92 or 0),44)
   Bounds.Rect(U.Credit,sx,wh-28,sw,28)
  elseif U.Kind=='remix'and wh<400 then
   U.Note.Visible=false;U.Stage.Visible=false;U.Pager.Visible=false;U.Detail.Visible=false;U.Credit.Visible=false
   for _,o in ipairs({U.Settings,U.Remix})do o.Parent=U.FormPane end;U.FormPane.Visible=true;Bounds.Rect(U.FormPane,0,0,ww,wh);Bounds.Rect(U.Settings,0,0,ww,96);Bounds.Rect(U.Remix,0,100,ww,144);U.FormPane.CanvasSize=UDim2.fromOffset(0,248)
  else U.Stage.Visible=true;U.Pager.Visible=true;U.Detail.Visible=true;U.Credit.Visible=true end
  if landscape then U.Stage.Visible=true;U.Pager.Visible=true;U.Detail.Visible=true;U.Credit.Visible=true end
  local iw=math.min(420,aw-16);Bounds.Rect(U.Invitation,il+(aw-iw)/2,it+math.max(8,(h-it-ib-144)/2),iw,144)
 end
 U.Style.Activated:Connect(function()U.Choices.Open('Seu estilo',Styles.Styles,U.Draft.style,function(v)U.Draft.style=v.id;U.Render()end)end)
 U.Palette.Activated:Connect(function()U.Choices.Open('Paleta em comum',Rules.Palettes,U.Draft.palette,function(v)U.Draft.palette=v.id;U.Render()end)end)
 U.Format.Activated:Connect(function()U.Draft.format=U.Draft.format=='2D'and'3D'or'2D';U.Render()end)
 local function settings()local v=Rules.Settings(U.Draft);v.budget=tonumber(U.Budget.Text)or 100;v.kind=U.Kind;v.code=U.Code.Text;return v end
 U.Start.Activated:Connect(function()
  if not U.State or U.State.kind~=U.Kind then call('create',settings(),U.SetState);return end
  call('configure',settings(),function(s)U.SetState(s)
   if U.Kind=='shoot'then if U.OnShoot then U.OnShoot(s.settings)end
   else task.defer(function()call('generate',{},function()U.Status.Text='Pesquisando peças reais…'end)end)end
  end)
 end)
 local function invitePlayer()local rows={};for _,p in ipairs(U.Players)do rows[#rows+1]={id=p.uid,name=p.name,note='Recebe um convite; precisa aceitar.'}end
  U.Choices.Open('Convidar para esta atividade',rows,nil,function(v)call('invite',{uid=v.id},function()U.Status.Text='Convite enviado. Aguarde a aceitação.'end)end)
 end
 U.Invite.Activated:Connect(invitePlayer)
 local function contribute()U.Choices.Open('Enviar peças que você está vestindo',Rules.Slots,nil,function(v)call('contribute',{slot=v.id},U.SetState)end)end
 U.Contribute.Activated:Connect(contribute)
 U.More.Activated:Connect(function()
  local rows={{id='catalog',name='Abrir catálogo'},{id='cart',name='Carrinho da combinação'},{id='invite',name='Convidar participantes'},{id='contribute',name='Enviar minhas peças'},{id='publish',name='Compartilhar combinação para remix'},{id='vote',name='Autorizar remix desta versão'},{id='unvote',name='Revogar minha autorização desta versão'},{id='leave',name='Sair ou encerrar atividade'}}
  U.Choices.Open('Mais opções da atividade',rows,nil,function(v)if v.id=='vote'or v.id=='unvote'then call('voteremix',{allow=v.id=='vote'},U.SetState)elseif v.id=='publish'then call('publish',{},function(row)U.Source=row;U.Code.Text=row.code;U.Kind='remix';U.Render();U.Status.Text='Código criado. Autorize o remix se quiser.'end)elseif v.id=='invite'then invitePlayer()elseif v.id=='contribute'then contribute()elseif v.id=='leave'then call('leave',{},function()U.State=nil;U.Kind=nil;U.Render()end)elseif v.id=='catalog'and U.OnCatalog then U.OnCatalog()elseif v.id=='cart'and U.Look and U.OnCart then U.OnCart(U.Look.body)end end)
 end)
 U.Apply.Activated:Connect(function()call('apply',{},function()U.Status.Text='Combinação aplicada no personagem.'end)end)
 U.Save.Activated:Connect(function()call('save',{},function()U.Status.Text='Guardado em Assistente > Looks salvos, com os créditos.'end)end)
 U.Leave.Activated:Connect(function()call('leave',{},function()U.State=nil;U.Kind=nil;U.Render();U.Status.Text='Atividade encerrada para você.'end)end)
 U.Cart.Activated:Connect(function()if U.Look and U.OnCart then U.OnCart(U.Look.body)end end)
 U.Catalog.Activated:Connect(function()if U.OnCatalog then U.OnCatalog()end end)
 U.OpenCode.Activated:Connect(function()local v=settings();v.kind='remix';call('create',v,U.SetState)end)
 U.Publish.Activated:Connect(function()call('publish',{},function(v)U.Source=v;U.Code.Text=v.code;U.Status.Text='Código criado com remix BLOQUEADO. Autorize apenas se quiser.'end)end)
 U.Permission.Activated:Connect(function()if U.Source then call('permission',{code=U.Source.code,allow=not U.Source.allow},function(v)U.Source=v;U.Status.Text=v.allow and'Remix autorizado. Você pode revogar aqui.'or'Autorização revogada para novos usos.'end)end end)
 U.Copy.Activated:Connect(function()U.Code:CaptureFocus();U.Code.CursorPosition=#U.Code.Text+1;U.Code.SelectionStart=1 end)
 U.MySources.Activated:Connect(function()call('mine',{},function(rows)U.Mine=rows;local list={};for _,v in ipairs(rows)do list[#list+1]={id=v.code,name=v.code,note=v.allow and'Remix autorizado'or'Remix bloqueado'}end
  U.Choices.Open('Seus códigos',list,nil,function(v)call('source',{code=v.id},function(row)U.Source=row;U.Code.Text=row.code;U.Render()end)end)
 end)end)
 local function invitation(v)U.Pending=v;U.InviteText.Text=v.ownerName..' convidou você para '..Rules.Activity(v.kind).name..'. Sua conta Roblox não é compartilhada.';U.Invitation.Visible=true;U.Layout()end
 U.Inbox.Activated:Connect(function()local rows={};for _,v in ipairs(U.Invites)do rows[#rows+1]={id=v.id,name=v.ownerName..' · '..Rules.Activity(v.kind).name}end;U.Choices.Open('Convites recebidos',rows,nil,function(v)for _,i in ipairs(U.Invites)do if i.id==v.id then invitation(i)end end end)end)
 U.Accept.Activated:Connect(function()if U.Pending then call('answer',{id=U.Pending.id,accept=true},function(v)U.Invitation.Visible=false;U.SetState(v)end)end end)
 U.Decline.Activated:Connect(function()if U.Pending then call('answer',{id=U.Pending.id,accept=false},function()U.Invitation.Visible=false;if U.Refresh then U.Refresh()end end)end end)
 local function cycle(n)local rows=U.State and U.State.results or{};if #rows<1 then return end;local index=1;for i,v in ipairs(rows)do if v.uid==U.Selected then index=i end end;U.Selected=rows[(index-1+n)%#rows+1].uid;U.PreviewKey=nil;U.Render()end
 U.Prev.Activated:Connect(function()cycle(-1)end);U.Next.Activated:Connect(function()cycle(1)end)
 U.Back.Activated:Connect(function()U.Kind=nil;U.Render()end)
 U.Reload.Activated:Connect(function()if U.Refresh then U.Refresh()end end)
 U.Close.Activated:Connect(function()U.Root.Visible=false end)
 U.Root:GetPropertyChangedSignal('Visible'):Connect(function()if not U.Root.Visible then Preview.Unmount(U.View);U.PreviewKey=nil;U.Choices.Hide();U.Invitation.Visible=false elseif U.Refresh then U.Refresh()end end)
 safe.Watch(U.Layout);U.Render();U.Call=call;return U
end
return M
