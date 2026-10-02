-- 07H1_GAME_LOBBY | ModuleScript | ReplicatedStorage
-- V42: navegacao por jogo, modos separados e estado real da sala.
local D=require(game:GetService("ReplicatedStorage"):WaitForChild("07UI_DESIGN_SYSTEM"))
local C,N=D.Colors,D.New
local M={}
local games={
 Xadrez={title="Xadrez",icon="chess",tag="ESTRATÉGIA",intro="Cada movimento conta.",rules="Proteja seu rei e encontre o xeque-mate. Jogue com um amigo, encontre um adversário ou treine contra o bot."},
 Damas={title="Damas",icon="checkers",tag="ESTRATÉGIA",intro="Uma jogada à frente.",rules="Capture as peças do adversário e alcance a última linha para virar dama. As regras incluem capturas obrigatórias e sequências."},
 Batata={title="Batata Envenenada",icon="potato",tag="PARTIDA CASUAL",intro="Escolha. Torça. Sobreviva.",rules="Escolha uma batata por turno. Algumas estão envenenadas. A partida termina quando alguém encontra uma delas."}
}
function M.Build(gui)
 local U={Selected="Xadrez",Difficulty="MEDIO",Mode="Online",WaitingState=false,Busy=false,GameButtons={},ModeButtons={},DiffButtons={}}
 U.Root=N("Frame",{Name="GamesLobby",Size=UDim2.fromScale(1,1),BackgroundColor3=C.bg,BorderSizePixel=0,Visible=false},gui)
 local r=U.Root
 U.Header=D.Text(r,"Jogos",{Position=UDim2.fromOffset(24,16),Size=UDim2.new(1,-100,0,32),TextSize=25,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})
 local crumb=D.Text(r,"AVATAR PLAZA  /  JOGAR",{Position=UDim2.fromOffset(24,52),Size=UDim2.new(1,-100,0,18),TextSize=13,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 U.Close=D.IconButton(r,"CloseLobby","close","Fechar jogos",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-20,0,16),Size=UDim2.fromOffset(44,44)})
 local nav=D.Frame(r,{Name="GameNavigation",Position=UDim2.fromOffset(20,90),Size=UDim2.new(0,208,1,-110),BackgroundColor3=C.panel})
 local navTitle=D.Text(nav,"ESCOLHA O JOGO",{Position=UDim2.fromOffset(16,14),Size=UDim2.new(1,-32,0,24),TextSize=13,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 for i,key in ipairs({"Xadrez","Damas","Batata"})do
  local b=D.Button(nav,"",{Name="Game_"..key,Position=UDim2.fromOffset(10,50+(i-1)*70),Size=UDim2.new(1,-20,0,60)})
  local pad=b:FindFirstChildOfClass("UIPadding");if pad then pad.PaddingLeft=UDim.new(0,0);pad.PaddingRight=UDim.new(0,0)end
  D.Text(b,games[key].title,{Name="GameButtonLabel",Position=UDim2.fromOffset(48,0),Size=UDim2.new(1,-58,1,0),Font=Enum.Font.GothamBold,TextSize=16,TextXAlignment=Enum.TextXAlignment.Left})
  D.Icon(b,games[key].icon,{Position=UDim2.new(0,12,.5,-12),Size=UDim2.fromOffset(24,24)})
  U.GameButtons[key]=b
 end
 local note=D.Text(nav,"Entre com o código para encontrar amigos em outros servidores.",{Position=UDim2.new(0,16,1,-82),Size=UDim2.new(1,-32,0,66),TextSize=13,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 local main=N("Frame",{Name="LobbyContent",Position=UDim2.fromOffset(248,90),Size=UDim2.new(1,-268,1,-110),BackgroundTransparency=1},r)
 U.GameTitle=D.Text(main,"Xadrez",{Size=UDim2.new(1,0,0,36),TextSize=28,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})
 U.Intro=D.Text(main,"Cada movimento conta.",{Position=UDim2.fromOffset(0,40),Size=UDim2.new(1,0,0,24),TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 local modeTabs=N("Frame",{Position=UDim2.fromOffset(0,78),Size=UDim2.new(1,0,0,44),BackgroundTransparency=1},main)
 N("UIGridLayout",{CellSize=UDim2.new(1/3,-6,1,0),CellPadding=UDim2.fromOffset(9,0),FillDirectionMaxCells=3,SortOrder=Enum.SortOrder.LayoutOrder},modeTabs)
 for i,v in ipairs({{"Online","Partida rápida"},{"Friends","Com amigo"},{"Practice","Treino"}})do
  U.ModeButtons[v[1]]=D.Button(modeTabs,v[2],{LayoutOrder=i})
 end
 local area=N("Frame",{Position=UDim2.fromOffset(0,138),Size=UDim2.new(1,0,1,-194),BackgroundTransparency=1},main)
 local deck=D.Frame(area,{Name="ModeCard",Size=UDim2.fromScale(1,1),BackgroundColor3=C.panel})
 local scroll=D.Scroll(deck,{Position=UDim2.fromOffset(18,14),Size=UDim2.new(1,-36,1,-28)})
 local panels={}
 local function panel(name)
  local p=N("Frame",{Name=name,Size=UDim2.new(1,-4,0,360),BackgroundTransparency=1,Visible=false},scroll);panels[name]=p;return p
 end
 local function heading(p,title,description)
  D.Text(p,title,{Name="ModeHeading",Position=UDim2.fromOffset(0,0),Size=UDim2.new(1,0,0,30),TextSize=21,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})
  D.Text(p,description,{Name="ModeDescription",Position=UDim2.fromOffset(0,40),Size=UDim2.new(1,0,0,56),TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 end
 local online=panel("Online");heading(online,"Encontre seu adversário","Entre na fila deste servidor. A partida começa quando outro jogador escolher o mesmo jogo.")
 U.QueueIcon=D.Icon(online,"chess",{Position=UDim2.fromOffset(4,120),Size=UDim2.fromOffset(56,56),IconColor=C.green})
 U.QueueCount=D.Text(online,"Consultando salas...",{Position=UDim2.fromOffset(76,128),Size=UDim2.new(1,-76,0,42),TextXAlignment=Enum.TextXAlignment.Left})
 U.Quick=D.Button(online,"Encontrar partida",{Position=UDim2.fromOffset(0,206),Size=UDim2.new(1,0,0,52),BackgroundColor3=C.green,TextColor3=C.bg,TextSize=17})
 local onlineHint=D.Text(online,"Você pode cancelar a espera a qualquer momento.",{Position=UDim2.fromOffset(0,272),Size=UDim2.new(1,0,0,42),TextColor3=C.muted,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left})
 local friends=panel("Friends");heading(friends,"Convide um amigo","Crie uma sala ou use o código de quem está esperando. O código funciona entre servidores do jogo publicado.")
 U.Create=D.Button(friends,"Criar sala com código",{Position=UDim2.fromOffset(0,112),Size=UDim2.new(1,0,0,48),BackgroundColor3=C.green,TextColor3=C.bg,TextSize=16})
 local friendsOr=D.Text(friends,"OU ENTRE COM UM CÓDIGO",{Position=UDim2.fromOffset(0,183),Size=UDim2.new(1,0,0,22),TextSize=13,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 U.Code=D.Box(friends,"Ex.: A7KD",{Position=UDim2.fromOffset(0,222),Size=UDim2.new(1,-104,0,48),TextSize=19})
 U.Join=D.Button(friends,"Entrar",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,222),Size=UDim2.fromOffset(94,48),BackgroundColor3=C.soft})
 local friendsHint=D.Text(friends,"O código tem quatro letras ou números.",{Position=UDim2.fromOffset(0,285),Size=UDim2.new(1,0,0,38),TextColor3=C.muted,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left})
 local practice=panel("Practice");heading(practice,"Jogue contra o bot","Teste suas ideias e pratique no seu ritmo. Escolha a dificuldade antes de começar.")
 local difficultyLabel=D.Text(practice,"DIFICULDADE",{Position=UDim2.fromOffset(0,114),Size=UDim2.new(1,0,0,24),TextSize=13,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 local diffRow=N("Frame",{Position=UDim2.fromOffset(0,150),Size=UDim2.new(1,0,0,48),BackgroundTransparency=1},practice)
 N("UIGridLayout",{CellSize=UDim2.new(1/3,-6,1,0),CellPadding=UDim2.fromOffset(9,0),FillDirectionMaxCells=3,SortOrder=Enum.SortOrder.LayoutOrder},diffRow)
 for i,v in ipairs({{"FACIL","Fácil"},{"MEDIO","Médio"},{"DIFICIL","Difícil"}})do U.DiffButtons[v[1]]=D.Button(diffRow,v[2],{LayoutOrder=i})end
 U.Bot=D.Button(practice,"Começar treino",{Position=UDim2.fromOffset(0,226),Size=UDim2.new(1,0,0,52),BackgroundColor3=C.green,TextColor3=C.bg,TextSize=17})
 local practiceHint=D.Text(practice,"O treino não exige outro jogador.",{Position=UDim2.fromOffset(0,292),Size=UDim2.new(1,0,0,34),TextColor3=C.muted,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left})
 local waiting=panel("Waiting");U.WaitingPanel=waiting
 U.WaitTitle=D.Text(waiting,"Sala criada",{Size=UDim2.new(1,0,0,32),TextSize=22,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})
 U.WaitDesc=D.Text(waiting,"Compartilhe o código com seu amigo.",{Position=UDim2.fromOffset(0,44),Size=UDim2.new(1,0,0,54),TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 U.CodeDisplay=D.Box(waiting,"",{Position=UDim2.fromOffset(0,116),Size=UDim2.new(1,0,0,60),TextSize=30,Font=Enum.Font.GothamBold,TextEditable=false,TextXAlignment=Enum.TextXAlignment.Center})
 U.SelectCode=D.Button(waiting,"Selecionar código",{Position=UDim2.fromOffset(0,190),Size=UDim2.new(1,0,0,42)})
 local waitingHint=D.Text(waiting,"AGUARDANDO OPONENTE  •  1 / 2",{Position=UDim2.fromOffset(0,248),Size=UDim2.new(1,0,0,28),TextSize=13,TextColor3=C.green,TextXAlignment=Enum.TextXAlignment.Left})
 U.Cancel=D.Button(waiting,"Cancelar espera",{Position=UDim2.fromOffset(0,300),Size=UDim2.new(1,0,0,48),TextColor3=C.red})
 local rules=D.Frame(area,{Name="GameGuide",AnchorPoint=Vector2.new(1,0),Position=UDim2.fromScale(1,0),Size=UDim2.new(0,244,1,0),BackgroundColor3=C.panel})
 local rs=D.Scroll(rules,{Position=UDim2.fromOffset(16,16),Size=UDim2.new(1,-32,1,-32),CanvasSize=UDim2.fromOffset(0,390),AutomaticCanvasSize=Enum.AutomaticSize.None})
 U.RuleTag=D.Text(rs,"ESTRATÉGIA",{Size=UDim2.new(1,0,0,22),TextSize=13,TextColor3=C.green,TextXAlignment=Enum.TextXAlignment.Left})
 local illustration=D.Frame(rs,{Position=UDim2.fromOffset(0,42),Size=UDim2.new(1,0,0,126),BackgroundColor3=C.card})
 local ruleIcon=D.Icon(illustration,"chess",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(78,78)})
 D.Text(rs,"Como jogar",{Position=UDim2.fromOffset(0,190),Size=UDim2.new(1,0,0,26),TextSize=18,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})
 U.Rules=D.Text(rs,games.Xadrez.rules,{Position=UDim2.fromOffset(0,234),Size=UDim2.new(1,0,0,126),TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 local footer=D.Frame(main,{Position=UDim2.new(0,0,1,-44),Size=UDim2.new(1,0,0,44),BackgroundColor3=C.panel})
 U.Status=D.Text(footer,"Escolha como jogar.",{Position=UDim2.fromOffset(12,0),Size=UDim2.new(1,-24,1,0),TextSize=13,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 U.Cancel.Parent=footer;U.Cancel.AnchorPoint=Vector2.new(1,0);U.Cancel.Position=UDim2.new(1,-4,0,4);U.Cancel.Size=UDim2.fromOffset(112,36);U.Cancel.Text="Cancelar"
 local waitingCounts=nil
 local function paint()
  for g,b in pairs(U.GameButtons)do b.BackgroundColor3=g==U.Selected and C.soft or C.panel end
  for m,b in pairs(U.ModeButtons)do b.BackgroundColor3=m==U.Mode and C.soft or C.card end
  for d,b in pairs(U.DiffButtons)do b.BackgroundColor3=d==U.Difficulty and C.soft or C.card end
  for name,p in pairs(panels)do p.Visible=U.WaitingState and name=="Waiting"or(not U.WaitingState and name==U.Mode)end
  U.Cancel.Visible=U.WaitingState;U.Status.Size=UDim2.new(1,U.WaitingState and -140 or -24,1,0)
  if U.Layout then U.Layout()end
 end
 function U.SetStatus(msg,error)U.Status.Text=tostring(msg or"");U.Status.TextColor3=error and C.red or C.muted end
 function U.SetGame(key)
  if U.WaitingState or U.Busy or not games[key]then return end
  U.Selected=key;local spec=games[key];U.GameTitle.Text=spec.title;U.Intro.Text=spec.intro;U.RuleTag.Text=spec.tag;U.Rules.Text=spec.rules
  ruleIcon:Destroy();ruleIcon=D.Icon(illustration,spec.icon,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(78,78)})
  U.QueueIcon:Destroy();U.QueueIcon=D.Icon(online,spec.icon,{Position=UDim2.fromOffset(4,120),Size=UDim2.fromOffset(56,56),IconColor=C.green})
  if waitingCounts then U.QueueCount.Text=(waitingCounts[key]or 0).." sala(s) aguardando neste servidor"end
  paint()
 end
 function U.SetCounts(counts)waitingCounts=counts;U.QueueCount.Text=(counts[U.Selected]or 0).." sala(s) aguardando neste servidor"end
 function U.SetBusy(on)
  U.Busy=on
  for _,b in ipairs({U.Quick,U.Create,U.Join,U.Bot,U.Cancel,U.Close})do D.SetEnabled(b,not on)end
  for _,group in ipairs({U.GameButtons,U.ModeButtons,U.DiffButtons})do for _,b in pairs(group)do D.SetEnabled(b,not on and not U.WaitingState)end end
 end
 function U.SetWaiting(code,quick,crossServer)
  U.WaitingState=true;U.CodeDisplay.Text=tostring(code or"");U.WaitTitle.Text=quick and"Procurando adversário"or"Sala criada"
  U.WaitDesc.Text=quick and"Sua fila está ativa. Aguarde alguém escolher o mesmo jogo."or crossServer and"Envie o código a um amigo. Ele virá para este servidor. A sala expira em 10 minutos."or"Código local a este servidor. Em servidores públicos, conecta amigos entre servidores."
  paint();U.SetBusy(false);scroll.CanvasPosition=Vector2.zero
 end
 function U.SetTransfer(code)
  U.SetWaiting(code,false,true);U.WaitTitle.Text="Indo até seu amigo";U.WaitDesc.Text="O Roblox está abrindo o servidor da sala. Aguarde a viagem."
 end
 function U.Reset()
  U.WaitingState=false;U.CodeDisplay.Text="";U.SetBusy(false);U.SetStatus("Escolha como jogar.");paint()
 end
 for key,b in pairs(U.GameButtons)do b.Activated:Connect(function()U.SetGame(key)end)end
 for key,b in pairs(U.ModeButtons)do b.Activated:Connect(function()if U.WaitingState or U.Busy then return end;U.Mode=key;paint();scroll.CanvasPosition=Vector2.zero end)end
 for key,b in pairs(U.DiffButtons)do b.Activated:Connect(function()if U.WaitingState or U.Busy then return end;U.Difficulty=key;paint()end)end
 U.SelectCode.Activated:Connect(function()
  pcall(function()U.CodeDisplay:CaptureFocus();U.CodeDisplay.CursorPosition=1;U.CodeDisplay.SelectionStart=#U.CodeDisplay.Text+1 end)
  U.SetStatus("Código selecionado. Copie e envie para seu amigo.")
 end)
 local Bounds=require(game:GetService("ReplicatedStorage"):WaitForChild("07UI_SCREEN_BOUNDS"))
 local safe=Bounds.Bind(gui)
 local function layout()
  local il,it,ir,ib,w,h=safe.Read();if w<1 or h<1 then return end
  local y=safe.Heading(U.Header,U.Close);local available=w-il-ir;local short=h<520
  crumb.Visible=false;navTitle.Visible=false;note.Visible=false
  Bounds.Rect(nav,il+6,y+4,available-12,48)
  for i,key in ipairs({"Xadrez","Damas","Batata"})do
   local btn=U.GameButtons[key];btn.Position=UDim2.new((i-1)/3,4,0,4);btn.Size=UDim2.new(1/3,-8,1,-8)
   local ic=btn:FindFirstChild("Icon_"..games[key].icon);if ic then ic.Visible=available>=760 end
   local label=btn.GameButtonLabel;label.Position=UDim2.fromOffset(available>=760 and 48 or 4,0);label.Size=UDim2.new(1,available>=760 and -56 or -8,1,0);label.TextSize=14
  end
  local my=y+58;Bounds.Rect(main,il+6,my,available-12,h-ib-my-6)
  U.GameTitle.Visible=false;U.Intro.Visible=false
  modeTabs.Position=UDim2.fromOffset(0,0);modeTabs.Size=UDim2.new(1,0,0,40)
  area.Position=UDim2.fromOffset(0,46);area.Size=UDim2.new(1,0,1,-90)
  rules.Visible=available>=1000;deck.Size=UDim2.new(1,rules.Visible and -254 or 0,1,0)
  scroll.Position=UDim2.fromOffset(12,8);scroll.Size=UDim2.new(1,-24,1,-16)
  for name,panel in pairs(panels)do
   panel.Size=UDim2.new(1,-4,0,short and 136 or 360)
   local title=panel:FindFirstChild("ModeHeading");if title then title.TextSize=19;title.Size=UDim2.new(1,0,0,short and 24 or 30)end
   local desc=panel:FindFirstChild("ModeDescription");if desc then desc.Visible=not short end
  end
  onlineHint.Visible=not short;friendsOr.Visible=not short;friendsHint.Visible=not short
  difficultyLabel.Visible=not short;practiceHint.Visible=not short;U.QueueIcon.Visible=not short
  U.QueueCount.Position=UDim2.fromOffset(short and 0 or 76,short and 28 or 128);U.QueueCount.Size=UDim2.new(1,short and 0 or -76,0,short and 24 or 42)
  U.Quick.Position=UDim2.fromOffset(0,short and 62 or 206);U.Quick.Size=UDim2.new(1,0,0,short and 44 or 52)
  local fw=friends.AbsoluteSize.X;local horizontal=short and fw>=580;local createW=horizontal and math.floor(fw*.32)or fw
  U.Create.Position=UDim2.fromOffset(0,short and 28 or 112);U.Create.Size=UDim2.fromOffset(createW,short and 44 or 48)
  U.Code.Position=UDim2.fromOffset(horizontal and createW+10 or 0,short and(horizontal and 28 or 80)or 222)
  U.Code.Size=UDim2.fromOffset(fw-104-(horizontal and createW+10 or 0),short and 44 or 48)
  U.Join.Position=UDim2.new(1,0,0,short and(horizontal and 28 or 80)or 222);U.Join.Size=UDim2.fromOffset(94,short and 44 or 48)
  diffRow.Position=UDim2.fromOffset(0,short and 32 or 150);diffRow.Size=UDim2.new(1,0,0,short and 40 or 48)
  U.Bot.Position=UDim2.fromOffset(0,short and 82 or 226);U.Bot.Size=UDim2.new(1,0,0,short and 44 or 52)
  U.WaitDesc.Visible=not short;U.WaitTitle.Size=UDim2.new(1,0,0,short and 24 or 32)
  U.CodeDisplay.Position=UDim2.fromOffset(0,short and 30 or 116);U.CodeDisplay.Size=UDim2.new(short and .55 or 1,0,0,short and 48 or 60)
  U.SelectCode.Position=short and UDim2.new(.55,8,0,34)or UDim2.fromOffset(0,190);U.SelectCode.Size=UDim2.new(short and .45 or 1,short and -8 or 0,0,42)
  waitingHint.Position=UDim2.fromOffset(0,short and 86 or 248)
 end
 safe.Watch(layout)
 r:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout);U.Layout=layout;layout();paint()
 return U
end
return M
