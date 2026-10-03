-- 07H1_GAME_LOBBY | ModuleScript | ReplicatedStorage | V45
-- Página inteira, controles fixos e nenhuma rolagem para criar ou entrar em sala.
local Rep=game:GetService("ReplicatedStorage")
local D=require(Rep:WaitForChild("07UI_DESIGN_SYSTEM"));local C=D.Colors
local Bounds=require(Rep:WaitForChild("07UI_SCREEN_BOUNDS"))
local M={}
local games={Xadrez="Xadrez",Damas="Damas",Truco="Truco"}
local accents={Xadrez=C.blue,Damas=C.purple,Truco=C.green}
local glyphs={Xadrez="♞",Damas="●",Truco="A♠"}
function M.Build(gui)
 local U={Selected="Xadrez",Difficulty="MEDIO",Variant="Paulista",Team=1,Manual=false,Mode="Online",Busy=false,WaitingState=false,GameButtons={},ModeButtons={},DiffButtons={}}
 local safe=Bounds.Bind(gui)
 U.Root=D.New("Frame",{Name="GamesLobby",Size=UDim2.fromScale(1,1),BackgroundColor3=C.bg,Visible=false},gui)
 U.Header=D.Text(U.Root,"Jogos",{Font=Enum.Font.GothamBold,TextSize=24,TextXAlignment=Enum.TextXAlignment.Left})
 U.Close=D.IconButton(U.Root,"CloseGames","close","Fechar jogos",{Size=UDim2.fromOffset(48,48),ZIndex=50})
 U.Inventory=D.Button(U.Root,"Baralhos",{});U.Cups=D.Button(U.Root,"Convites",{})
 local nav=D.New("Frame",{BackgroundTransparency=1},U.Root)
 local tiles={}
 for i,key in ipairs({"Xadrez","Damas","Truco"})do
  local b=D.Button(nav,"",{Name="Choose"..key,BackgroundColor3=C.panel});U.GameButtons[key]=b
  local padding=b:FindFirstChildOfClass("UIPadding");if padding then padding:Destroy()end
  local icon=D.Text(b,glyphs[key],{TextColor3=accents[key],Font=Enum.Font.GothamBold,TextSize=32,Active=false})
  local label=D.Text(b,key,{Font=Enum.Font.GothamBold,TextSize=17,Active=false})
  local line=D.New("Frame",{BackgroundColor3=accents[key],BorderSizePixel=0,Active=false},b)
  tiles[key]={icon=icon,label=label,line=line};b.Activated:Connect(function()U.SetGame(key)end)
 end
 local modes=D.New("Frame",{BackgroundTransparency=1},U.Root)
 for _,pair in ipairs({{"Online","Partida rápida"},{"Friends","Com amigos"},{"Practice","Treino"}})do
  local b=D.Button(modes,pair[2],{});U.ModeButtons[pair[1]]=b;b.Activated:Connect(function()if not U.WaitingState and not U.Busy then U.Mode=pair[1];U.Layout()end end)
 end
 local options=D.New("Frame",{BackgroundTransparency=1},U.Root)
 U.VariantButton=D.Button(options,"Paulista ▾",{});U.TeamButton=D.Button(options,"Dupla 1 ▾",{});U.ManualButton=D.Button(options,"Carteada automática",{})
 U.VariantButton.Activated:Connect(function()if U.WaitingState or U.Busy then return end;local variants={"Paulista","Mineiro","Goiano"};local n=table.find(variants,U.Variant)or 1;U.Variant=variants[n%3+1];if U.Variant=="Mineiro"then U.Manual=false end;U.Layout()end)
 U.TeamButton.Activated:Connect(function()if U.WaitingState or U.Busy then return end;U.Team=3-U.Team;U.Layout()end)
 U.ManualButton.Activated:Connect(function()if U.WaitingState or U.Busy then return end;if U.Variant~="Mineiro"then U.Manual=not U.Manual end;U.Layout()end)
 local area=D.Frame(U.Root,{Name="RoomMode",BackgroundColor3=C.panel})
 U.GameTitle=D.Text(area,"Xadrez",{Font=Enum.Font.GothamBold,TextSize=22,TextXAlignment=Enum.TextXAlignment.Left})
 U.Intro=D.Text(area,"",{TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 U.QueueCount=D.Text(area,"",{TextColor3=C.green,TextXAlignment=Enum.TextXAlignment.Left})
 U.Quick=D.Button(area,"Encontrar partida",{BackgroundColor3=C.green,TextColor3=C.bg})
 U.Create=D.Button(area,"Criar sala com código",{BackgroundColor3=C.green,TextColor3=C.bg})
 U.Code=D.Box(area,"Código: A7KD",{TextSize=18});U.Join=D.Button(area,"Entrar",{})
 local diff=D.New("Frame",{BackgroundTransparency=1},area)
 for _,pair in ipairs({{"FACIL","Fácil"},{"MEDIO","Médio"},{"DIFICIL","Difícil"}})do local b=D.Button(diff,pair[2],{});U.DiffButtons[pair[1]]=b
  b.Activated:Connect(function()U.Difficulty=pair[1];U.Layout()end)
 end
 U.Bot=D.Button(area,"Começar treino",{BackgroundColor3=C.green,TextColor3=C.bg})
 U.WaitTitle=D.Text(area,"Sala criada",{Font=Enum.Font.GothamBold,TextSize=22,TextXAlignment=Enum.TextXAlignment.Left})
 U.WaitDesc=D.Text(area,"",{TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 U.CodeDisplay=D.Box(area,"",{TextEditable=false,TextSize=24,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Center})
 U.SelectCode=D.Button(area,"Copiar",{});U.SelectCode.Activated:Connect(function()U.CodeDisplay:CaptureFocus();U.CodeDisplay.SelectionStart=1;U.CodeDisplay.CursorPosition=#U.CodeDisplay.Text+1 end)
 U.Cancel=D.Button(area,"Cancelar espera",{TextColor3=C.red})
 U.Status=D.Text(U.Root,"Escolha como jogar.",{TextColor3=C.muted,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd})
 U.Rules=D.Text(area,"",{TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 local counts={}
 function U.SetStatus(text,error)U.Status.Text=tostring(text or"");U.Status.TextColor3=error and C.red or C.muted end
 function U.SetGame(key)if U.WaitingState or U.Busy or not games[key]then return end;U.Selected=key;U.Layout()end
 function U.SetCounts(v)counts=v or{};U.QueueCount.Text=(counts[U.Selected]or 0).." sala(s) esperando"end
 function U.SetBusy(on)
  U.Busy=on;for _,b in ipairs({U.Quick,U.Create,U.Join,U.Bot,U.Cancel,U.Close,U.VariantButton,U.TeamButton,U.ManualButton})do D.SetEnabled(b,not on)end
  for _,group in ipairs({U.GameButtons,U.ModeButtons,U.DiffButtons})do for _,b in pairs(group)do D.SetEnabled(b,not on and not U.WaitingState)end end
 end
 function U.SetWaiting(code,quick,crossServer,count)
  U.WaitingState=true;U.CodeDisplay.Text=tostring(code or"");U.WaitTitle.Text=quick and"Buscando jogadores"or"Sua sala está pronta"
  U.WaitDesc.Text=U.Selected=="Truco"and((count or 1).." / 4 jogadores • parceiros em lados opostos")or"1 / 2 jogadores • compartilhe o código"
  U.SetBusy(false);U.Layout()
 end
 function U.SetTransfer(code)U.SetWaiting(code,false,true);U.WaitTitle.Text="Viajando para a sala";U.WaitDesc.Text="A Roblox está conectando você ao servidor do anfitrião."end
 function U.Reset()U.WaitingState=false;U.SetBusy(false);U.SetStatus("Escolha como jogar.");U.Layout()end
 function U.Layout()
  local il,it,ir,ib,w,h=safe.Read();if w<1 or h<1 then return end
  local aw=w-il-ir;local top=safe.Heading(U.Header,U.Close)
  Bounds.Rect(U.Header,il+8,it+4,math.max(60,aw-248),48);Bounds.Rect(U.Inventory,w-ir-234,it+8,82,44);Bounds.Rect(U.Cups,w-ir-146,it+8,88,44)
  local compact=w>h*1.2 and h<520;local truco=U.Selected=="Truco"
  local left=compact and math.clamp(aw*.24,142,220)or 0;local ax=il+8+left;local arw=aw-16-left
  local navHeight=compact and h-ib-top-34 or math.min(112,math.max(74,(h-it-ib)*.18))
  Bounds.Rect(nav,il+8,top,compact and left-8 or aw-16,navHeight)
  for i,key in ipairs({"Xadrez","Damas","Truco"})do local b=U.GameButtons[key];local tile=tiles[key]
   local bw=compact and left-8 or(aw-28)/3;local bh=compact and(navHeight-12)/3 or navHeight
   Bounds.Rect(b,compact and 0 or(i-1)*(bw+6),compact and(i-1)*(bh+6)or 0,bw,bh)
   b.BackgroundColor3=U.Selected==key and C.soft or C.panel
   local tiny=bh<70;Bounds.Rect(tile.icon,6,tiny and 0 or 4,tiny and 36 or bw-12,tiny and bh-4 or bh-34)
   Bounds.Rect(tile.label,tiny and 44 or 4,tiny and 0 or bh-34,tiny and bw-48 or bw-8,tiny and bh-4 or 30)
   tile.icon.TextSize=tiny and 24 or 34;tile.label.TextSize=bw<118 and 14 or 17
   Bounds.Rect(tile.line,6,bh-4,bw-12,3);tile.line.Visible=U.Selected==key
  end
  local my=compact and top or top+navHeight+8
  Bounds.Rect(modes,ax,my,arw,44)
  for i,key in ipairs({"Online","Friends","Practice"})do local b=U.ModeButtons[key];Bounds.Rect(b,(i-1)*(arw+6)/3,0,(arw-12)/3,44);b.TextSize=arw<390 and 12 or 14;b.BackgroundColor3=U.Mode==key and C.soft or C.card end
  options.Visible=truco and not U.WaitingState;local oy=my+50
  Bounds.Rect(options,ax,oy,arw,44);for i,b in ipairs({U.VariantButton,U.TeamButton,U.ManualButton})do Bounds.Rect(b,(i-1)*(arw+6)/3,0,(arw-12)/3,44);b.TextSize=arw<390 and 12 or 14 end
  U.VariantButton.Text=U.Variant.." ▾";U.TeamButton.Text="Dupla "..U.Team.." ▾";U.ManualButton.Text=U.Manual and"Manual • casual"or"Automática"
  local y=oy+(options.Visible and 50 or 0);local ah=h-ib-y-34;Bounds.Rect(area,ax,y,arw,ah);Bounds.Rect(U.Status,il+10,h-ib-28,aw-20,24)
  local pw=arw-24;local spacious=ah>=280;local cy=spacious and 108 or 8
  U.GameTitle.Visible=spacious and not U.WaitingState;U.Intro.Visible=U.GameTitle.Visible;U.Rules.Visible=spacious and not U.WaitingState
  Bounds.Rect(U.GameTitle,12,8,pw,34);Bounds.Rect(U.Intro,12,46,pw,50)
  U.GameTitle.Text=U.Selected;U.Intro.Text=truco and"Duplas, três cartas na mão e placar até doze. Cosméticos não mudam o jogo."or U.Selected=="Xadrez"and"Xadrez 5+3. Proteja seu rei e encontre o xeque-mate."or"Capturas obrigatórias, sequências e promoção a dama."
  Bounds.Rect(U.Rules,12,ah-104,pw,88);U.Rules.Text=truco and(U.Manual and"Mesa casual: tirar pelo meio ou trocar a origem permite conferência e desclassificação. Não há aposta nem prêmio por carteada irregular."or"Paulista e Goiano: vira e 3/6/9/12. Mineiro: manilhas fixas e 4/6/10/12. Torneios usam distribuição automática.")or"Treino não gera moedas, vitórias classificatórias ou convites."
  U.Quick.Visible=not U.WaitingState and U.Mode=="Online";U.QueueCount.Visible=U.Quick.Visible and ah>=170
  Bounds.Rect(U.Quick,12,cy,pw,48);Bounds.Rect(U.QueueCount,12,cy+54,pw,30);U.QueueCount.Text=(counts[U.Selected]or 0).." sala(s) esperando"
  local friends=not U.WaitingState and U.Mode=="Friends";U.Create.Visible=friends;U.Code.Visible=friends;U.Join.Visible=friends
  Bounds.Rect(U.Create,12,cy,pw,44);Bounds.Rect(U.Code,12,cy+50,pw-96,44);Bounds.Rect(U.Join,pw-78,cy+50,90,44)
  local practice=not U.WaitingState and U.Mode=="Practice";diff.Visible=practice;U.Bot.Visible=practice;Bounds.Rect(diff,12,cy,pw,44)
  for i,key in ipairs({"FACIL","MEDIO","DIFICIL"})do local b=U.DiffButtons[key];Bounds.Rect(b,(i-1)*(pw+6)/3,0,(pw-12)/3,44);b.BackgroundColor3=U.Difficulty==key and C.soft or C.card end
  Bounds.Rect(U.Bot,12,cy+50,pw,44)
  for _,b in ipairs({U.WaitTitle,U.WaitDesc,U.CodeDisplay,U.SelectCode,U.Cancel})do b.Visible=U.WaitingState end
  U.WaitTitle.Visible=U.WaitingState and spacious;U.WaitDesc.Visible=U.WaitingState and ah>=170
  Bounds.Rect(U.WaitTitle,12,8,pw,34);Bounds.Rect(U.WaitDesc,12,46,pw,50);Bounds.Rect(U.CodeDisplay,12,cy,pw-96,44);Bounds.Rect(U.SelectCode,pw-78,cy,90,44);Bounds.Rect(U.Cancel,12,cy+50,pw,44)
 end
 safe.Watch(U.Layout);return U
end
return M
