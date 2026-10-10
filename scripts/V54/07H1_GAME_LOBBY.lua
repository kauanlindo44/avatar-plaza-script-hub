-- 07H1_GAME_LOBBY | ModuleScript | ReplicatedStorage | V54 (SUBSTITUIR)
-- Um jogo de cada vez, bots com perfis e sala de duplas com confirmação.
local Rep=game:GetService('ReplicatedStorage')
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local C=D.Colors
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'))
local Cards=require(Rep:WaitForChild('07K7_CARD_STYLES'))
local Fx=require(Rep:WaitForChild('07UI_SURFACE_EFFECTS'));local F=Fx.Colors
local M={};local order={'Truco','Damas','Xadrez'}
local profiles={{key='FACIL',name='Nico',style='Iniciante · aprende com você',color=Color3.fromRGB(170,203,173)},
 {key='MEDIO',name='Lia',style='Equilibrada · pensa antes de jogar',color=Color3.fromRGB(163,186,209)},
 {key='DIFICIL',name='Dante',style='Estrategista · antecipa suas decisões',color=Color3.fromRGB(206,181,156)}}
function M.Build(gui)
 local U={Selected='Truco',Difficulty='MEDIO',Variant='Paulista',Team=1,Manual=false,Mode='Online',Busy=false,WaitingState=false,GameButtons={},DiffButtons={},ModeButtons={},PlayButtons={},IsReady=false}
 local safe=Bounds.Bind(gui);local N=D.New;local R=Bounds.Rect
 U.Root=N('Frame',{Name='GamesLobby',Size=UDim2.fromScale(1,1),BackgroundColor3=F.navy,Visible=false},gui)
 Fx.Surface(U.Root,F.navy,Color3.fromRGB(23,58,58))
 U.Header=D.Text(U.Root,'JOGOS',{Font=Enum.Font.GothamBold,TextSize=22,TextXAlignment=Enum.TextXAlignment.Left})
 U.Coins=D.Text(U.Root,'◉ 0',{TextColor3=Color3.fromRGB(220,203,161),Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Right,TextSize=15})
 U.Close=D.IconButton(U.Root,'CloseGames','close','Fechar jogos',{ZIndex=80})
 U.Status=D.Text(U.Root,'',{TextColor3=C.muted,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=75,Visible=false})
 U.Tabs=N('Frame',{Name='GameTabs',BackgroundTransparency=1},U.Root)
 U.Hero=D.Frame(U.Root,{Name='SelectedGame',BackgroundColor3=F.panel});Fx.Surface(U.Hero,F.panel,Color3.fromRGB(27,61,65),F.jade)
 U.Art=N('Frame',{Name='GameArtwork',BackgroundTransparency=1,ClipsDescendants=true},U.Hero)
 U.Canvas=N('Frame',{Name='ArtworkCanvas',BackgroundTransparency=1},U.Art)
 U.HeroTitle=D.Text(U.Hero,'',{Font=Enum.Font.GothamBold,TextSize=25,TextXAlignment=Enum.TextXAlignment.Left})
 U.HeroText=D.Text(U.Hero,'',{TextColor3=C.muted,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left})
 U.Inventory=D.Button(U.Hero,'Baralhos',{TextSize=12});U.Cups=D.Button(U.Hero,'Torneios',{TextSize=12})
 U.ActionHeading=D.Text(U.Hero,'COMO VOCÊ QUER JOGAR?',{TextSize=12,Font=Enum.Font.GothamBold,TextColor3=F.jade,TextXAlignment=Enum.TextXAlignment.Left})
 local actions={{'Online','Partida rápida','Encontre uma mesa'},{'Create','Criar sala','Jogue com seus amigos'},{'Join','Entrar na sala','Use um código'},{'Practice','Jogar com bots','Escolha um parceiro'}}
 local actionButtons={}
 for _,key in ipairs(order)do
  local b=D.Button(U.Tabs,key=='Damas'and'Dama'or key,{TextSize=15});Fx.Button(b,key=='Truco'and F.jade or key=='Damas'and F.gold or F.blue);U.GameButtons[key]=b
  b.Activated:Connect(function()U.SetGame(key)end);U.PlayButtons[key]={}
 end
 for i,a in ipairs(actions)do
  local accent=({F.jade,F.blue,F.violet,F.gold})[i]
  local b=D.Button(U.Hero,'',{Name='Mode'..a[1],TextSize=15,BackgroundColor3=i==1 and F.jade or F.panel,TextColor3=i==1 and F.navy or C.white});Fx.Button(b,accent)
  local title=D.Text(b,a[2],{Font=Enum.Font.GothamBold,TextSize=16,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=i==1 and F.navy or C.white})
  local subtitle=D.Text(b,a[3],{TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=i==1 and Color3.fromRGB(28,71,65)or C.muted})
  local icon=D.Icon(b,({'play','plus','link','people'})[i],{IconColor=i==1 and F.navy or accent})
  actionButtons[i]={root=b,subtitle=subtitle,title=title,icon=icon}
  for _,key in ipairs(order)do U.PlayButtons[key][a[1]]=b end
  b.Activated:Connect(function()if U.Busy or U.WaitingState then return end;U.Mode=a[1];U.Options.Visible=true;U.PracticeRulesOn=false;U.Layout()end)
 end
 U.Options=D.Frame(U.Root,{Name='GameOptions',BackgroundColor3=F.navy,Visible=false,ZIndex=40});Fx.Surface(U.Options,F.navy,Color3.fromRGB(30,54,65),F.jade)
 U.GameTitle=D.Text(U.Options,'',{TextSize=20,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=41})
 U.OptionsClose=D.IconButton(U.Options,'CloseGameOptions','close','Voltar aos jogos',{ZIndex=70})
 U.OptionsClose.Activated:Connect(function()if U.Busy then return end;if U.WaitingState then if U.OnCancel then U.OnCancel()end else U.Options.Visible=false end end)
 U.Intro=D.Text(U.Options,'',{TextSize=12,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=41})
 U.VariantButton=D.Button(U.Options,'Paulista',{ZIndex=41});U.TeamButton=D.Button(U.Options,'Dupla 1',{ZIndex=41});U.ManualButton=D.Button(U.Options,'Automática',{Visible=false,ZIndex=41})
 U.VariantButton.Activated:Connect(function()if U.Busy or U.WaitingState then return end;local v={'Paulista','Mineiro','Goiano'};U.Variant=v[(table.find(v,U.Variant)or 1)%3+1];U.Layout()end)
 U.TeamButton.Activated:Connect(function()if not U.Busy then U.Team=3-U.Team;U.Layout()end end)
 U.Quick=D.Button(U.Options,'Encontrar partida',{BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=41})
 U.Create=D.Button(U.Options,'Criar sala',{BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=41})
 U.Code=D.Box(U.Options,'Código da sala',{TextSize=18,ZIndex=41});U.Join=D.Button(U.Options,'Entrar',{ZIndex=41})
 U.BotRows={};U.BotDescriptions={}
 for _,p in ipairs(profiles)do
  local b=D.Button(U.Options,p.name,{Name='Bot'..p.name,TextXAlignment=Enum.TextXAlignment.Left,TextSize=15,ZIndex=41})
  local portrait=Fx.BotPortrait(b,p.name,p.color,42)
  local name=D.Text(b,p.name,{Font=Enum.Font.GothamBold,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=42})
  local text=D.Text(b,p.style,{TextSize=11,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=42})
  local selected=D.Text(b,'',{Name='BotSelected',Font=Enum.Font.GothamBold,TextSize=13,TextColor3=F.jade,ZIndex=42})
  b.Text='';Fx.Button(b,p.color);U.DiffButtons[p.key]=b;U.BotRows[p.key]={portrait=portrait,name=name,text=text,selected=selected}
  b.Activated:Connect(function()if not U.Busy then U.Difficulty=p.key;U.Layout()end end)
 end
 U.Bot=D.Button(U.Options,'Jogar com Lia',{BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=41})
 U.PracticeRules=D.Button(U.Options,'Regras',{TextSize=12,ZIndex=41})
 U.PracticeRules.Activated:Connect(function()if not U.Busy then U.PracticeRulesOn=not U.PracticeRulesOn;U.Layout()end end)
 U.WaitTitle=D.Text(U.Options,'',{TextSize=18,ZIndex=41});U.WaitDesc=D.Text(U.Options,'',{TextSize=12,TextColor3=C.muted,ZIndex=41})
 U.CodeDisplay=D.Box(U.Options,'',{TextEditable=false,TextSize=21,ZIndex=41})
 U.SelectCode=D.Button(U.Options,'Copiar',{TextSize=12,ZIndex=41});U.Cancel=D.Button(U.Options,'Sair da sala',{TextSize=13,ZIndex=41})
 U.Ready=D.Button(U.Options,'Estou pronto',{BackgroundColor3=C.green,TextColor3=C.bg,TextSize=13,ZIndex=41})
 U.Partner=D.Button(U.Options,'Dupla',{TextSize=12,ZIndex=41})
 U.TeamTitles={};U.RoomSlots={}
 for i=1,2 do U.TeamTitles[i]=D.Text(U.Options,'DUPLA '..i,{Font=Enum.Font.GothamBold,TextSize=12,ZIndex=41})end
 for i=1,4 do U.RoomSlots[i]=D.Text(U.Options,'Vaga disponível',{TextSize=12,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=41})end
 U.PartnerPanel=D.Frame(U.Options,{Name='ReservePartner',BackgroundColor3=C.panel,Visible=false,ZIndex=72})
 U.PartnerTitle=D.Text(U.PartnerPanel,'Reserve a vaga da sua dupla',{TextSize=18,Font=Enum.Font.GothamBold,ZIndex=73})
 U.FriendBox=D.Box(U.PartnerPanel,'Nome de usuário ou ID do amigo',{TextSize=14,ZIndex=73})
 U.Reserve=D.Button(U.PartnerPanel,'Reservar por 2 minutos',{TextSize=13,BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=73})
 U.PartnerClose=D.IconButton(U.PartnerPanel,'ClosePartner','close','Voltar à sala',{ZIndex=74})
 U.Partner.Activated:Connect(function()U.PartnerPanel.Visible=true;U.Layout()end)
 U.PartnerClose.Activated:Connect(function()U.PartnerPanel.Visible=false end)
 U.SelectCode.Activated:Connect(function()U.CodeDisplay:CaptureFocus();U.CodeDisplay.SelectionStart=1;U.CodeDisplay.CursorPosition=#U.CodeDisplay.Text+1 end)
 local DeckUI=require(Rep:WaitForChild('07H5_TRUCO_SETUP')).Build(U.Options,U)
 local artwork
 function U.SetStatus(t,e)U.Status.Text=tostring(t or'');U.Status.TextColor3=e and C.red or C.white;U.Status.Visible=U.Status.Text~=''and not U.Options.Visible;if U.Options.Visible and e and U.OnNotice then U.OnNotice(U.Status.Text)end end
 function U.SetCounts(c)U.Counts=c or{}end
 function U.SetGame(k)if not U.Busy and not U.WaitingState then U.Selected=k;U.Options.Visible=false;U.Layout()end end
 function U.SetBusy(v)
  U.Busy=v==true
  for _,b in ipairs({U.Close,U.OptionsClose,U.Quick,U.Create,U.Join,U.Bot,U.Cancel,U.Ready,U.Reserve,U.Partner,U.VariantButton,U.TeamButton})do D.SetEnabled(b,not U.Busy)end
  for _,v in ipairs(actionButtons)do D.SetEnabled(v.root,not U.Busy and not U.WaitingState)end
  for _,b in pairs(U.GameButtons)do D.SetEnabled(b,not U.Busy and not U.WaitingState)end
 end
 function U.SetWaiting(code,quick,cross,count)
  U.WaitingState=true;U.Options.Visible=true;U.CodeDisplay.Text=tostring(code or'')
  U.WaitDesc.Text=(count or 1)..(U.Selected=='Truco'and' / 4 jogadores · confirme quando estiver pronto.'or' / 2 jogadores · compartilhe o código.')
  U.SetBusy(false);U.Layout()
 end
 function U.SetRoom(data)
  U.Selected='Truco';U.SetWaiting(data.code,false,true,data.count);U.IsOwner=data.owner==game:GetService('Players').LocalPlayer.UserId
  U.IsReady=data.ready==true
  for i,b in ipairs(U.RoomSlots)do local p=(data.players or{})[i];b.Text=p and(p.name..(p.ready and' · pronto'or' · aguardando'))or'Vaga disponível';b.TextColor3=p and p.ready and C.green or C.muted end
  U.Layout()
 end
 function U.SetTransfer(code)U.SetWaiting(code);U.WaitDesc.Text='A Roblox está conectando ao anfitrião.'end
 function U.Reset()U.WaitingState=false;U.IsReady=false;U.IsOwner=false;U.PartnerPanel.Visible=false;U.Options.Visible=false;U.SetBusy(false);U.Layout()end
 function U.Layout()
  local il,it,ir,ib,w,h=safe.Read();local aw=w-il-ir;local y=safe.Heading(U.Header,U.Close);local bar=safe.Topbar()
  local useBar=aw>=520 and bar.Right-bar.X>=320 and bar.Bottom-bar.Y>=48
  R(U.Header,il+10,it+4,aw-200,48);R(U.Coins,w-ir-190,it+4,124,48)
  if useBar then y=it+4;R(U.Header,bar.X+6,bar.Y+4,bar.Right-bar.X-206,44);R(U.Coins,bar.Right-188,bar.Y+4,122,44);R(U.Close,bar.Right-56,bar.Y+4,48,48)end
  R(U.Tabs,il+8,y,aw-16,44)
  for i,key in ipairs(order)do local b=U.GameButtons[key];R(b,(i-1)*(aw-10)/3,0,(aw-28)/3,44);b.BackgroundColor3=key==U.Selected and Color3.fromRGB(72,100,83)or Color3.fromRGB(29,39,36)end
  local top=y+50;local ph=h-ib-top-6;local pw=aw-16;R(U.Hero,il+8,top,pw,ph)
  local wide=pw>=520;local artW=wide and pw*.34 or pw;local artH=wide and ph-60 or math.max(0,ph-252)
  local ax=wide and 10 or 0;R(U.Art,ax,wide and 56 or 50,artW-20,math.max(1,artH))
  R(U.HeroTitle,12,4,math.max(1,pw-220),42);R(U.Inventory,pw-204,6,98,44);R(U.Cups,pw-100,6,88,44);U.Inventory.TextSize=pw<340 and 10 or 12
  U.HeroText.Visible=wide and ph>=340;R(U.HeroText,12,ph-38,artW-24,30)
  U.HeroTitle.Text=U.Selected=='Damas'and'Dama'or U.Selected
  U.HeroText.Text=U.Selected=='Truco'and'Duplas, conversa e blefe. Cada mão tem uma história.'or U.Selected=='Damas'and'Uma pausa, um tabuleiro e uma boa partida.'or'Encontre sua próxima jogada no seu ritmo.'
  local bx=wide and artW+12 or 12;local bw=wide and pw-artW-24 or pw-24
  local by=wide and 84 or math.max(72,ph-188);local bh=math.max(44,(ph-by-18)/2-3);U.Art.Visible=artH>=50
  U.ActionHeading.Visible=wide and ph>=245;R(U.ActionHeading,bx,56,bw,22)
  for i,p in ipairs(actionButtons)do
   local buttonW=(bw-6)/2;R(p.root,bx+(i-1)%2*(bw+6)/2,by+math.floor((i-1)/2)*(bh+6),buttonW,bh)
   local iconSize=bh>=100 and 34 or 24;local tx=buttonW>=176 and 52 or 10
   p.icon.Visible=buttonW>=176;R(p.icon,12,math.max(8,(bh-iconSize)/2),iconSize,iconSize)
   R(p.title,tx,bh>=70 and bh*.28 or 4,buttonW-tx-8,24);p.title.TextSize=buttonW<160 and 12 or 16
   p.subtitle.Visible=bh>=70 and buttonW>=150;R(p.subtitle,tx,bh*.52,buttonW-tx-8,math.min(36,bh*.30))
  end
  local fw=math.min(U.Art.Size.X.Offset,U.Art.Size.Y.Offset*(U.Selected=='Truco'and 2 or 1));R(U.Canvas,(U.Art.Size.X.Offset-fw)/2,0,fw,math.max(1,U.Selected=='Truco'and fw/2 or fw))
  if artwork~=U.Selected then
   artwork=U.Selected;for _,c in ipairs(U.Canvas:GetChildren())do c:Destroy()end
   if artwork=='Truco'then for i,c in ipairs({{rank='A',suit='S'},{rank='K',suit='H'},{rank='7',suit='C'}})do Cards.Render(U.Canvas,c,({'Onyx','Aurum','Hex'})[i],{Position=UDim2.new((i-1)/3,3,.04,0),Size=UDim2.new(1/3,-6,.92,0),Rotation=(i-2)*5})end
   else D.Icon(U.Canvas,artwork=='Damas'and'checkers'or'chess',{Size=UDim2.fromScale(.8,.8),Position=UDim2.fromScale(.1,.1),IconColor=Color3.fromRGB(196,217,195)})end
  end
  R(U.Status,il+12,h-ib-28,aw-24,24)
  local ow=aw-16;local oh=h-it-ib-12
  R(U.Options,il+8,it+6,ow,oh);R(U.GameTitle,12,4,ow-80,48);R(U.OptionsClose,ow-60,4,48,48)
  U.GameTitle.Text=(U.Selected=='Damas'and'Dama'or U.Selected)..' · '..({Online='Partida rápida',Create='Criar sala',Join='Entrar',Practice='Bots'})[U.Mode]
  local waiting=U.WaitingState;local truco=U.Selected=='Truco';local show=not waiting
  local bots=show and U.Mode=='Practice'and not U.PracticeRulesOn
  U.Intro.Visible=show and not bots;R(U.Intro,12,54,ow-24,24);U.Intro.Text=U.Mode=='Join'and'Código de quatro caracteres.'or'Escolha as regras e sente à mesa.'
  U.VariantButton.Visible=show and truco and U.Mode~='Join'and not bots;R(U.VariantButton,12,84,ow-24,44);U.VariantButton.Text=U.Variant..' ▾'
  U.TeamButton.Visible=show and truco and U.Mode=='Join';R(U.TeamButton,12,84,ow-24,44);U.TeamButton.Text='Entrar na dupla '..U.Team..' ▾'
  U.Quick.Visible=show and U.Mode=='Online';U.Create.Visible=show and U.Mode=='Create';U.Join.Visible=show and U.Mode=='Join';U.Code.Visible=U.Join.Visible
  U.Bot.Visible=show and U.Mode=='Practice';U.PracticeRules.Visible=U.Bot.Visible and truco
  if U.PracticeRules.Visible then R(U.GameTitle,12,4,ow-176,48);R(U.PracticeRules,ow-162,6,96,44);U.PracticeRules.Text=U.PracticeRulesOn and'Bots'or'Regras'end
  R(U.Code,12,truco and 134 or 90,ow-24,44)
  local botWide=ow>=520;local rowGap=oh<254 and 2 or 8;local rowH=botWide and math.max(78,oh-124)or math.max(44,math.floor((oh-120-rowGap*2)/3));local rowY=58
  for i,p in ipairs(profiles)do local b=U.DiffButtons[p.key];local info=U.BotRows[p.key];b.Visible=bots;R(b,12,rowY+(i-1)*(rowH+rowGap),ow-24,rowH)
   if botWide then local cell=(ow-40)/3;R(b,12+(i-1)*(cell+8),rowY,cell,rowH)
    local portrait=math.min(100,rowH*.43);R(info.portrait,(cell-portrait)/2,10,portrait,portrait);R(info.name,8,portrait+14,cell-16,26)
    R(info.text,12,portrait+42,cell-24,math.max(18,rowH-portrait-60));R(info.selected,cell-30,6,24,24)
   else
    local portrait=math.min(66,rowH-8);R(info.portrait,6,4,portrait,portrait);R(info.name,portrait+14,4,ow-portrait-68,24)
    R(info.text,portrait+14,28,ow-portrait-68,math.max(16,rowH-32));R(info.selected,ow-52,8,22,24)
   end
   info.selected.Text=U.Difficulty==p.key and'✓'or'';b.BackgroundColor3=U.Difficulty==p.key and Color3.fromRGB(34,80,73)or F.panel
   info.text.Text=botWide and rowH<170 and({'Iniciante','Equilibrada','Estrategista'})[i]or p.style;info.text.TextWrapped=not(botWide and rowH<170)
   if U.Difficulty==p.key then U.Bot.Text='Jogar com '..p.name end
  end
  for _,b in ipairs({U.Quick,U.Create,U.Join,U.Bot})do R(b,12,oh-54,ow-24,44)end
  for _,o in ipairs({U.WaitTitle,U.WaitDesc,U.CodeDisplay,U.SelectCode,U.Cancel})do o.Visible=waiting end;U.WaitTitle.Visible=false
  U.Ready.Visible=waiting and truco;U.Partner.Visible=waiting and truco and U.IsOwner;U.WaitDesc.Visible=waiting and oh>=340
  R(U.CodeDisplay,12,58,math.max(70,ow-220),44);R(U.SelectCode,ow-198,58,88,44);R(U.Partner,ow-104,58,92,44)
  R(U.WaitDesc,12,194,ow-24,42);R(U.Cancel,12,oh-54,truco and(ow-30)/2 or ow-24,44);R(U.Ready,(ow+6)/2,oh-54,(ow-30)/2,44);U.Ready.Text=U.IsReady and'Pronto ✓ · cancelar'or'Estou pronto'
  for i,b in ipairs(U.TeamTitles)do b.Visible=waiting and truco;R(b,12+(i-1)*(ow-18)/2,106,(ow-30)/2,24)end
  for i,b in ipairs(U.RoomSlots)do local team=(i-1)%2;local row=math.floor((i-1)/2);b.Visible=waiting and truco;R(b,12+team*(ow-18)/2,132+row*30,(ow-30)/2,28)end
  R(U.PartnerPanel,8,54,ow-16,oh-62);R(U.PartnerTitle,8,4,ow-88,48);R(U.PartnerClose,ow-78,4,48,48)
  R(U.FriendBox,12,64,ow-56,44);R(U.Reserve,12,oh-116,ow-56,44)
  DeckUI.Layout(ow,oh,truco and show and U.Mode~='Join'and not bots)
 end
 for _,b in ipairs({U.Close,U.OptionsClose,U.Inventory,U.Cups,U.Quick,U.Create,U.Join,U.Bot,U.PracticeRules,U.VariantButton,U.TeamButton,U.SelectCode,U.Cancel,U.Ready,U.Partner,U.Reserve,U.PartnerClose})do Fx.Button(b,F.jade)end
 for _,b in ipairs({U.Quick,U.Create,U.Bot,U.Ready,U.Reserve})do b.BackgroundColor3=F.jade;b.TextColor3=F.navy end
 U.Options:GetPropertyChangedSignal('Visible'):Connect(function()U.Hero.Visible=not U.Options.Visible;U.Tabs.Visible=not U.Options.Visible;U.Close.Visible=not U.Options.Visible;U.Status.Visible=not U.Options.Visible and U.Status.Text~='';Fx.Enter(U.Options)end)
 safe.Watch(U.Layout);U.Layout();return U
end
return M
