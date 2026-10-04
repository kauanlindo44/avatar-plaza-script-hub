-- 07H1_GAME_LOBBY | ModuleScript | ReplicatedStorage | V47
-- Jogos no topo; formulario compacto abaixo. Tela inteira, sem rolagem.
local Rep=game:GetService("ReplicatedStorage")
local D=require(Rep:WaitForChild("07UI_DESIGN_SYSTEM"));local C=D.Colors
local Bounds=require(Rep:WaitForChild("07UI_SCREEN_BOUNDS"))
local M={};local order={"Xadrez","Damas","Truco"}
local accents={Xadrez=C.blue,Damas=C.purple,Truco=C.green}
local icons={Xadrez="chess",Damas="checkers",Truco="catalog"}
local info={Xadrez="Estratégia · 1 contra 1",Damas="Capturas · 1 contra 1",Truco="Duplas · 3 cartas"}
function M.Build(gui)
 local U={Selected="Xadrez",Difficulty="MEDIO",Variant="Paulista",Team=1,Manual=false,Mode="Online",Busy=false,WaitingState=false,GameButtons={},ModeButtons={},DiffButtons={}}
 local safe=Bounds.Bind(gui);local bg=Color3.fromRGB(21,23,28);local panel=Color3.fromRGB(30,33,40)
 U.Root=D.New("Frame",{Name="GamesLobby",Size=UDim2.fromScale(1,1),BackgroundColor3=bg,Visible=false},gui)
 D.New("UIGradient",{Color=ColorSequence.new(bg,Color3.fromRGB(33,37,47)),Rotation=105},U.Root)
 U.Header=D.Text(U.Root,"JOGOS",{Font=Enum.Font.GothamBold,TextSize=21,TextXAlignment=Enum.TextXAlignment.Left})
 U.Close=D.IconButton(U.Root,"CloseGames","close","Fechar jogos",{Size=UDim2.fromOffset(48,48),ZIndex=50})
 U.Inventory=D.Button(U.Root,"Baralhos",{TextSize=12});U.Cups=D.Button(U.Root,"Torneios",{TextSize=12})
 local nav=D.New("Frame",{Name="TopGameTabs",BackgroundTransparency=1},U.Root);local tiles={}
 for _,key in ipairs(order)do
  local b=D.Button(nav,"",{Name="Choose"..key,BackgroundColor3=panel});U.GameButtons[key]=b
  local padding=b:FindFirstChildOfClass("UIPadding");if padding then padding:Destroy()end
  local icon=D.Icon(b,icons[key],{IconColor=accents[key]})
  local label=D.Text(b,key,{Font=Enum.Font.GothamBold,TextSize=17,TextXAlignment=Enum.TextXAlignment.Left,Active=false})
  local sub=D.Text(b,info[key],{TextSize=11,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,Active=false,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd})
  local line=D.New("Frame",{BackgroundColor3=accents[key],BorderSizePixel=0,Active=false},b)
  local stroke=b:FindFirstChildOfClass("UIStroke")
  tiles[key]={icon=icon,label=label,sub=sub,line=line,stroke=stroke}
  b.Activated:Connect(function()U.SetGame(key)end)
 end
 local area=D.Frame(U.Root,{Name="RoomMode",BackgroundColor3=panel});U.Panel=area
 U.GameTitle=D.Text(area,"Xadrez",{Font=Enum.Font.GothamBold,TextSize=20,TextXAlignment=Enum.TextXAlignment.Left})
 U.Intro=D.Text(area,"",{TextSize=12,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 local modes=D.New("Frame",{Name="PlayModes",BackgroundTransparency=1},area)
 for _,pair in ipairs({{"Online","Partida rápida"},{"Friends","Criar / entrar"},{"Practice","Contra bots"}})do
  local b=D.Button(modes,pair[2],{TextSize=13});U.ModeButtons[pair[1]]=b
  b.Activated:Connect(function()if not U.WaitingState and not U.Busy then U.Mode=pair[1];U.Layout()end end)
 end
 local options=D.New("Frame",{Name="TrucoOptions",BackgroundTransparency=1},area)
 U.VariantButton=D.Button(options,"Paulista",{TextSize=12});U.TeamButton=D.Button(options,"Dupla 1",{TextSize=12});U.ManualButton=D.Button(options,"Automática",{TextSize=12})
 U.VariantButton.Activated:Connect(function()
  if U.WaitingState or U.Busy then return end;local list={"Paulista","Mineiro","Goiano"};local n=table.find(list,U.Variant)or 1;U.Variant=list[n%3+1];if U.Variant=="Mineiro"then U.Manual=false end;U.Layout()
 end)
 U.TeamButton.Activated:Connect(function()if not U.WaitingState and not U.Busy then U.Team=3-U.Team;U.Layout()end end)
 U.ManualButton.Activated:Connect(function()if not U.WaitingState and not U.Busy and U.Variant~="Mineiro"then U.Manual=not U.Manual;U.Layout()end end)
 U.QueueCount=D.Text(area,"",{TextSize=12,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 U.Quick=D.Button(area,"Encontrar partida",{BackgroundColor3=C.green,TextColor3=C.bg})
 U.Create=D.Button(area,"Criar sala de Xadrez",{BackgroundColor3=C.green,TextColor3=C.bg})
 U.Code=D.Box(area,"Código da sala",{TextSize=16});U.Join=D.Button(area,"Entrar",{TextSize=14})
 local diff=D.New("Frame",{BackgroundTransparency=1},area)
 for _,pair in ipairs({{"FACIL","Fácil"},{"MEDIO","Médio"},{"DIFICIL","Difícil"}})do
  local b=D.Button(diff,pair[2],{TextSize=13});U.DiffButtons[pair[1]]=b
  b.Activated:Connect(function()if not U.Busy and not U.WaitingState then U.Difficulty=pair[1];U.Layout()end end)
 end
 U.Bot=D.Button(area,"Jogar contra bots",{BackgroundColor3=C.green,TextColor3=C.bg})
 U.WaitTitle=D.Text(area,"Sala criada",{Font=Enum.Font.GothamBold,TextSize=20,TextXAlignment=Enum.TextXAlignment.Left})
 U.WaitDesc=D.Text(area,"",{TextSize=12,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 U.CodeDisplay=D.Box(area,"",{TextEditable=false,TextSize=23,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Center})
 U.SelectCode=D.Button(area,"Copiar código",{TextSize=12})
 U.SelectCode.Activated:Connect(function()U.CodeDisplay:CaptureFocus();U.CodeDisplay.SelectionStart=1;U.CodeDisplay.CursorPosition=#U.CodeDisplay.Text+1 end)
 U.Cancel=D.Button(area,"Cancelar espera",{TextColor3=C.red})
 U.Status=D.Text(U.Root,"Escolha como jogar.",{TextColor3=C.muted,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd})
 U.Rules=D.Text(area,"",{TextSize=12,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 local counts={}
 function U.SetStatus(text,error)U.Status.Text=tostring(text or"");U.Status.TextColor3=error and C.red or C.muted end
 function U.SetGame(key)if U.WaitingState or U.Busy or not accents[key]then return end;U.Selected=key;U.Code.Text="";U.Layout()end
 function U.SetCounts(v)counts=v or{};U.QueueCount.Text=(counts[U.Selected]or 0).." sala(s) aguardando jogadores"end
 function U.SetBusy(on)
  U.Busy=on==true
  for _,b in ipairs({U.Quick,U.Create,U.Join,U.Bot,U.Cancel,U.Close,U.VariantButton,U.TeamButton,U.ManualButton})do D.SetEnabled(b,not U.Busy)end
  for _,group in ipairs({U.GameButtons,U.ModeButtons,U.DiffButtons})do for _,b in pairs(group)do D.SetEnabled(b,not U.Busy and not U.WaitingState)end end
 end
 function U.SetWaiting(code,quick,crossServer,count)
  U.WaitingState=true;U.CodeDisplay.Text=tostring(code or"");U.WaitTitle.Text=quick and"Procurando jogadores"or"Sua sala está pronta"
  U.WaitDesc.Text=U.Selected=="Truco"and((count or 1).." / 4 jogadores · parceiros em lados opostos")or"1 / 2 jogadores · compartilhe o código"
  U.SetBusy(false);U.SetStatus(U.WaitDesc.Text);U.Layout()
 end
 function U.SetTransfer(code)U.SetWaiting(code,false,true);U.WaitTitle.Text="Conectando à sala";U.WaitDesc.Text="A Roblox está conectando você ao servidor do anfitrião.";U.SetStatus(U.WaitDesc.Text)end
 function U.Reset()U.WaitingState=false;U.SetBusy(false);U.SetStatus("Escolha como jogar.");U.Layout()end
 function U.Layout()
  local il,it,ir,ib,w,h=safe.Read();if w<1 or h<1 then return end
  local aw=w-il-ir;local top=safe.Heading(U.Header,U.Close);local short=h<500;local truco=U.Selected=="Truco"
  local inv=truco and 88 or 0;U.Inventory.Visible=truco
  Bounds.Rect(U.Header,il+8,it+4,math.max(48,aw-162-inv),48);U.Header.TextSize=aw<360 and 18 or 21
  Bounds.Rect(U.Cups,w-ir-146,it+8,88,44);Bounds.Rect(U.Inventory,w-ir-240,it+8,88,44)
  local navH=short and 54 or 76;local navW=aw-16;Bounds.Rect(nav,il+8,top,navW,navH)
  for i,key in ipairs(order)do
   local tile,b=tiles[key],U.GameButtons[key];local bw=(navW-12)/3;local chosen=U.Selected==key
   Bounds.Rect(b,(i-1)*(bw+6),0,bw,navH);b.BackgroundColor3=chosen and C.soft or panel
   local small=bw<125;Bounds.Rect(tile.icon,small and 8 or 12,(navH-30)/2,small and 24 or 30,30)
   Bounds.Rect(tile.label,small and 38 or 50,short and 6 or 12,bw-(small and 44 or 58),30);tile.label.TextSize=small and 13 or 17
   Bounds.Rect(tile.sub,50,42,bw-58,20);tile.sub.Visible=not short and not small
   Bounds.Rect(tile.line,10,navH-4,bw-20,3);tile.line.Visible=chosen
   if tile.stroke then tile.stroke.Color=accents[key];tile.stroke.Transparency=chosen and .12 or .8 end
  end
  local panelY=top+navH+8;local available=h-ib-panelY-32
  local pw=math.min(aw-16,860);local ph=math.min(available,short and(truco and 218 or 176)or(truco and 352 or 304))
  local px=il+(aw-pw)/2;Bounds.Rect(area,px,panelY,pw,ph)
  Bounds.Rect(U.Status,il+10,h-ib-28,aw-20,24)
  local inner=pw-24;local roomy=ph>=270;local titleH=roomy and 58 or 0;local waiting=U.WaitingState
  U.GameTitle.Visible=roomy and not waiting;U.Intro.Visible=U.GameTitle.Visible;U.GameTitle.Text=U.Selected
  Bounds.Rect(U.GameTitle,12,8,inner,28);Bounds.Rect(U.Intro,12,36,inner,22);U.Intro.Text=info[U.Selected].." · escolha seu modo"
  modes.Visible=not waiting;Bounds.Rect(modes,12,roomy and 64 or 8,inner,44)
  for i,key in ipairs({"Online","Friends","Practice"})do local b=U.ModeButtons[key];Bounds.Rect(b,(i-1)*(inner+6)/3,0,(inner-12)/3,44);b.BackgroundColor3=U.Mode==key and C.soft or C.card;b.TextSize=pw<400 and 11 or 13 end
  local y=(roomy and 64 or 8)+50
  options.Visible=truco and not waiting;Bounds.Rect(options,12,y,inner,40)
  for i,b in ipairs({U.VariantButton,U.TeamButton,U.ManualButton})do Bounds.Rect(b,(i-1)*(inner+6)/3,0,(inner-12)/3,40);b.TextSize=pw<400 and 11 or 12 end
  U.VariantButton.Text=U.Variant.." ▾";U.TeamButton.Text="Dupla "..U.Team.." ▾";U.ManualButton.Text=U.Manual and"Manual · casual"or"Automática"
  if truco then y=y+46 end
  local online=U.Mode=="Online"and not waiting;local friends=U.Mode=="Friends"and not waiting;local practice=U.Mode=="Practice"and not waiting
  U.Quick.Visible=online;U.Create.Visible=friends;U.Code.Visible=friends;U.Join.Visible=friends;diff.Visible=practice;U.Bot.Visible=practice;U.QueueCount.Visible=online
  U.Create.Text="Criar sala de "..U.Selected;U.Bot.Text="Jogar "..U.Selected.." contra bots"
  local split=pw>=520;local gap=6;local half=(inner-gap)/2
  if split then
   Bounds.Rect(U.Create,12,y,half,44);Bounds.Rect(U.Code,18+half,y,half-94,44);Bounds.Rect(U.Join,pw-96,y,84,44)
   Bounds.Rect(diff,12,y,half,44);Bounds.Rect(U.Bot,18+half,y,half,44)
  else
   Bounds.Rect(U.Create,12,y,inner,44);Bounds.Rect(U.Code,12,y+50,inner-90,44);Bounds.Rect(U.Join,pw-96,y+50,84,44)
   Bounds.Rect(diff,12,y,inner,40);Bounds.Rect(U.Bot,12,y+46,inner,44)
  end
  for i,key in ipairs({"FACIL","MEDIO","DIFICIL"})do local b=U.DiffButtons[key];local dw=diff.Size.X.Offset;Bounds.Rect(b,(i-1)*(dw+4)/3,0,(dw-8)/3,diff.Size.Y.Offset);b.TextSize=pw<400 and 12 or 13;b.BackgroundColor3=U.Difficulty==key and C.soft or C.card end
  Bounds.Rect(U.Quick,12,y,split and half or inner,44);Bounds.Rect(U.QueueCount,split and 18+half or 12,split and y or y+50,split and half or inner,24);U.SetCounts(counts)
  U.Rules.Visible=roomy and not waiting;Bounds.Rect(U.Rules,12,ph-52,inner,40)
  U.Rules.Text=truco and(U.Manual and"Carteada manual: mesa casual com conferência. Cosméticos não mudam as regras."or"Paulista, Mineiro e Goiano. Três cartas, duplas e placar até doze.")or U.Selected=="Xadrez"and"Xadrez 5+3 · proteja seu rei e encontre o xeque-mate."or"Capturas obrigatórias, sequências e promoção a dama."
  for _,o in ipairs({U.WaitTitle,U.WaitDesc,U.CodeDisplay,U.SelectCode,U.Cancel})do o.Visible=waiting end
  U.WaitDesc.Visible=waiting and ph>=180;Bounds.Rect(U.WaitTitle,12,8,inner,30);Bounds.Rect(U.WaitDesc,12,42,inner,28)
  local codeY=ph>=180 and 78 or 42
  Bounds.Rect(U.CodeDisplay,12,codeY,inner-126,44);Bounds.Rect(U.SelectCode,pw-132,codeY,120,44);Bounds.Rect(U.Cancel,12,ph-54,inner,44)
 end
 safe.Watch(U.Layout);U.Layout();return U
end
return M
