-- 07H1_GAME_LOBBY | ModuleScript | ReplicatedStorage | V70 (SUBSTITUIR)
-- Salão de jogos com mesa ilustrada, caminhos claros e perfis de bots adaptáveis.
local Rep=game:GetService('ReplicatedStorage')
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local C=D.Colors
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'))
local Cards=require(Rep:WaitForChild('07K7_CARD_STYLES'))
local Fx=require(Rep:WaitForChild('07UI_SURFACE_EFFECTS'));local F=Fx.Colors
local M={};local order={'Truco','Damas','Xadrez'}
local profiles={{key='FACIL',name='Nico',style='Iniciante · aprende com você',color=Color3.fromRGB(38,116,108)},
 {key='MEDIO',name='Lia',style='Equilibrada · pensa antes de jogar',color=Color3.fromRGB(64,100,156)},
 {key='DIFICIL',name='Dante',style='Estrategista · antecipa suas decisões',color=Color3.fromRGB(153,81,48)}}
function M.Build(gui)
 local U={Selected='Truco',Difficulty='MEDIO',Variant='Paulista',Team=1,Manual=false,Mode='Online',Busy=false,WaitingState=false,GameButtons={},DiffButtons={},ModeButtons={},PlayButtons={},IsReady=false}
 local safe=Bounds.Bind(gui);local N=D.New;local R=Bounds.Rect
 U.Root=N('Frame',{Name='GamesLobby',Size=UDim2.fromScale(1,1),BackgroundColor3=F.navy,Visible=false},gui)
 Fx.Surface(U.Root,Color3.fromRGB(20,29,33),Color3.fromRGB(28,44,45),F.jade)
 U.Header=D.Text(U.Root,'Salão de jogos',{Font=Enum.Font.GothamBold,TextSize=22,TextXAlignment=Enum.TextXAlignment.Left})
 U.Coins=D.Text(U.Root,'◉ 0',{TextColor3=Color3.fromRGB(153,81,48),Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Right,TextSize=15})
 U.Close=D.IconButton(U.Root,'CloseGames','close','Fechar jogos',{ZIndex=80})
 U.Status=D.Text(U.Root,'',{TextColor3=C.muted,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=75,Visible=false})
 U.Tabs=N('Frame',{Name='GameTabs',BackgroundTransparency=1},U.Root)
 U.Hero=D.Frame(U.Root,{Name='SelectedGame',BackgroundColor3=F.panel});Fx.Surface(U.Hero,Color3.fromRGB(31,48,50),Color3.fromRGB(24,35,41),F.jade)
 U.Art=N('Frame',{Name='GameArtwork',BackgroundTransparency=1,ClipsDescendants=true},U.Hero)
 U.Canvas=N('Frame',{Name='ArtworkCanvas',BackgroundTransparency=1},U.Art)
 U.HeroTitle=D.Text(U.Hero,'',{Font=Enum.Font.GothamBold,TextSize=25,TextXAlignment=Enum.TextXAlignment.Left})
 U.HeroText=D.Text(U.Hero,'',{TextColor3=C.muted,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left})
 U.Inventory=D.Button(U.Hero,'Baralhos',{TextSize=12});U.Cups=D.Button(U.Hero,'Torneios',{TextSize=12})
 U.ActionHeading=D.Text(U.Hero,'COMO VOCÊ QUER JOGAR?',{TextSize=12,Font=Enum.Font.GothamBold,TextColor3=F.jade,TextXAlignment=Enum.TextXAlignment.Left})
 local actions={{'Online','Encontrar partida','Jogue com outras pessoas'},{'Create','Criar uma sala','Convide sua dupla ou rival'},{'Join','Tenho um código','Entre na sala de um amigo'},{'Practice','Jogar com companhia','Conheça Nico, Lia e Dante'}}
 local actionButtons={}
 for _,key in ipairs(order)do
  local b=D.Button(U.Tabs,key=='Damas'and'Dama'or key,{TextSize=15});Fx.Button(b,key=='Truco'and F.jade or key=='Damas'and F.gold or F.blue);U.GameButtons[key]=b
  b.Activated:Connect(function()U.SetGame(key)end);U.PlayButtons[key]={}
 end
 for i,a in ipairs(actions)do
  local accent=({F.jade,F.blue,F.violet,F.gold})[i]
  local b=D.Button(U.Hero,'',{Name='Mode'..a[1],TextSize=15,BackgroundColor3=i==1 and F.jade or F.panel,TextColor3=i==1 and F.navy or C.white});Fx.Button(b,accent)
  local title=D.Text(b,a[2],{Font=Enum.Font.GothamBold,TextSize=16,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=i==1 and F.navy or C.white})
  local subtitle=D.Text(b,a[3],{TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=i==1 and F.navy or C.muted})
  local icon=D.Icon(b,({'play','plus','link','people'})[i],{IconColor=i==1 and F.navy or accent})
  actionButtons[i]={root=b,subtitle=subtitle,title=title,icon=icon}
  for _,key in ipairs(order)do U.PlayButtons[key][a[1]]=b end
  b.Activated:Connect(function()if U.Busy or U.WaitingState then return end;U.Mode=a[1];U.Options.Visible=true;U.PracticeRulesOn=false;U.Layout()end)
 end
 U.Options=D.Frame(U.Root,{Name='GameOptions',BackgroundColor3=F.navy,Visible=false,ZIndex=40});Fx.Surface(U.Options,F.navy,Color3.fromRGB(47,37,58),F.jade)
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
  for i,key in ipairs(order)do local b=U.GameButtons[key];R(b,(i-1)*(aw-10)/3,0,(aw-28)/3,44);b.BackgroundColor3=key==U.Selected and C.soft or C.card;b.TextColor3=key==U.Selected and C.green or C.muted;b.Text=(key==U.Selected and'✓ 'or'')..(key=='Damas'and'Dama'or key) end
  local top=y+50;local ph=h-ib-top-6;local pw=aw-16;R(U.Hero,il+8,top,pw,ph)
  local wide=pw>=520;local artW=wide and pw*.38 or pw;local artH=wide and ph-72 or math.max(0,ph-258)
  local ax=wide and 10 or 0;R(U.Art,ax,wide and 56 or 50,artW-20,math.max(1,artH))
  R(U.HeroTitle,12,4,math.max(1,pw-220),42);R(U.Inventory,pw-204,6,98,44);R(U.Cups,pw-100,6,88,44);U.Inventory.TextSize=pw<340 and 10 or 12
  U.HeroText.Visible=wide and ph>=340;R(U.HeroText,12,ph-38,artW-24,30)
  U.HeroTitle.Text=U.Selected=='Damas'and'Dama'or U.Selected
  U.HeroText.Text=U.Selected=='Truco'and'Duplas, conversa e blefe. Cada mão tem uma história.'or U.Selected=='Damas'and'Uma pausa, um tabuleiro e uma boa partida.'or'Encontre sua próxima jogada no seu ritmo.'
  local bx=wide and artW+12 or 12;local bw=wide and pw-artW-24 or pw-24
  local by=wide and 84 or math.max(64,ph-190);local bh=math.max(44,(ph-by-18)/2-3);U.Art.Visible=artH>=50
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
   if artwork=='Truco'then
    local felt=D.Frame(U.Canvas,{Name='IllustratedTrucoTable',Position=UDim2.fromScale(.02,.06),Size=UDim2.fromScale(.96,.88),BackgroundColor3=Color3.fromRGB(218,233,229)})
    Fx.Surface(felt,Color3.fromRGB(35,95,72),Color3.fromRGB(19,65,51),Color3.fromRGB(154,138,100))
    for i,c in ipairs({{rank='A',suit='S'},{rank='K',suit='H'},{rank='7',suit='C'}})do Cards.Render(felt,c,({'Classic','Aurum','Classic'})[i],{Position=UDim2.new(.2+(i-1)*.18,0,.12+(i-2)^2*.04,0),Size=UDim2.fromScale(.24,.76),Rotation=(i-2)*9})end
   else
    local board=D.Frame(U.Canvas,{Name='IllustratedBoard',Position=UDim2.fromScale(.06,.06),Size=UDim2.fromScale(.88,.88),BackgroundColor3=Color3.fromRGB(146,119,89)})
    for row=0,7 do for col=0,7 do
     local cell=N('Frame',{Name='BoardSquare',Position=UDim2.fromScale(col/8,row/8),Size=UDim2.fromScale(1/8,1/8),BorderSizePixel=0,BackgroundColor3=(row+col)%2==0 and Color3.fromRGB(153,81,48)or Color3.fromRGB(218,233,229)},board)
     if artwork=='Damas'and(row<3 or row>4)and(row+col)%2==1 then local chip=D.Frame(cell,{Size=UDim2.fromScale(.76,.76),Position=UDim2.fromScale(.12,.12),BackgroundColor3=row<3 and Color3.fromRGB(238,241,241)or Color3.fromRGB(153,81,48)});local round=chip:FindFirstChildOfClass('UICorner');if round then round.CornerRadius=UDim.new(1,0)end;D.Stroke(chip,Color3.fromRGB(176,151,111),.35)
     elseif artwork=='Xadrez'and(row<2 or row>5)then D.Text(cell,(row==1 or row==6)and'♟'or({'♜','♞','♝','♛','♚','♝','♞','♜'})[col+1],{Size=UDim2.fromScale(1,1),TextScaled=true,TextColor3=row<2 and Color3.fromRGB(238,241,241)or Color3.fromRGB(255,248,229)})end
    end end
   end
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
  local botWide=ow>=520;local space=math.max(116,oh-124);local alternate=0
  for _,p in ipairs(profiles)do local b=U.DiffButtons[p.key];local info=U.BotRows[p.key];b.Visible=bots
   local selected=U.Difficulty==p.key;local x,y,bw,bh
   if botWide then
    local mainW=(ow-32)*.46
    if selected then x,y,bw,bh=12,58,mainW,space else alternate=alternate+1;x,y,bw,bh=20+mainW,58+(alternate-1)*(space+8)/2,ow-mainW-32,(space-8)/2 end
   else
    local mainH=space*.48
    if selected then x,y,bw,bh=12,58,ow-24,mainH else alternate=alternate+1;x,y,bw,bh=12+(alternate-1)*(ow-18)/2,66+mainH,(ow-30)/2,space-mainH-8 end
   end
   R(b,x,y,bw,bh);local tall=bh>=120;local portrait=tall and math.min(94,bh*.45)or math.min(48,bh-12)
   if tall then
    R(info.portrait,(bw-portrait)/2,8,portrait,portrait);R(info.name,8,portrait+10,bw-16,24)
    R(info.text,10,portrait+36,bw-20,math.max(16,bh-portrait-42))
   else
    R(info.portrait,6,(bh-portrait)/2,portrait,portrait);R(info.name,portrait+14,math.max(2,bh*.5-24),bw-portrait-26,22)
    R(info.text,portrait+14,math.max(24,bh*.5),bw-portrait-26,math.max(16,bh*.5-4))
   end
   info.text.Visible=bh>=56;info.text.Text=selected and bh>=150 and p.style or p.key=='FACIL'and'Leve e tranquilo'or p.key=='MEDIO'and'Um bom desafio'or'Pense a próxima jogada'
   info.name.TextSize=bw<170 and 13 or 16;info.text.TextSize=11
   R(info.selected,bw-28,4,24,24);info.selected.Text=selected and'✓'or'';b.BackgroundColor3=selected and C.soft or C.card
   if selected then U.Bot.Text='Começar com '..p.name end
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
