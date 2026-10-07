-- 07H1_GAME_LOBBY | ModuleScript | ReplicatedStorage | V52
-- Três painéis de jogos e configuração dedicada; tela segura sem rolagem.
local Rep=game:GetService('ReplicatedStorage')
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local C=D.Colors
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'))
local Cards=require(Rep:WaitForChild('07K7_CARD_STYLES'))
local M={};local order={'Truco','Damas','Xadrez'}
function M.Build(gui)
 local U={Selected='Truco',Difficulty='MEDIO',Variant='Paulista',Team=1,Manual=false,Mode='Online',Busy=false,WaitingState=false,GameButtons={},DiffButtons={},ModeButtons={}}
 local safe=Bounds.Bind(gui);local N=D.New;local R=Bounds.Rect
 U.Root=N('Frame',{Name='GamesLobby',Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(10,17,18),Visible=false},gui)
 N('UIGradient',{Color=ColorSequence.new(Color3.fromRGB(9,17,19),Color3.fromRGB(19,40,32)),Rotation=115},U.Root)
 U.Header=D.Text(U.Root,'JOGOS',{Font=Enum.Font.GothamBold,TextSize=23,TextXAlignment=Enum.TextXAlignment.Left})
 U.Coins=D.Text(U.Root,'◉ 0',{TextColor3=C.yellow,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Right,TextSize=16})
 U.Close=D.IconButton(U.Root,'CloseGames','close','Fechar jogos',{ZIndex=80})
 U.Inventory=D.Button(U.Root,'Meus baralhos',{TextSize=13});U.Cups=D.Button(U.Root,'Torneios',{TextSize=13})
 U.Status=D.Text(U.Root,'Escolha seu jogo e sente à mesa.',{TextColor3=C.muted,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left})
 local panels={};U.PlayButtons={}
 local actions={{'Online','Partida rápida',C.blue},{'Create','Criar sala',C.green},{'Join','Entrar na sala',C.soft},{'Practice','Contra bots',C.gold}}
 for _,key in ipairs(order)do
  local p=D.Frame(U.Root,{Name=key..'GamePanel',BackgroundColor3=Color3.fromRGB(20,29,32)});D.Stroke(p,C.green,.65,1)
  N('UIGradient',{Color=ColorSequence.new(Color3.fromRGB(29,43,46),Color3.fromRGB(13,23,27)),Rotation=90},p)
  local title=D.Text(p,key=='Damas'and'Dama'or key,{TextSize=23,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Center})
  local art=N('Frame',{Name='GameArtwork',BackgroundTransparency=1,ClipsDescendants=true},p)
  local canvas=N('Frame',{Name='ArtworkCanvas',BackgroundTransparency=1},art)
  if key=='Truco'then
   for i,c in ipairs({{rank='A',suit='S'},{rank='K',suit='H'},{rank='7',suit='C'}})do Cards.Render(canvas,c,({'Onyx','Regent','Hex'})[i],{Position=UDim2.new((i-1)/3,4,.03,0),Size=UDim2.new(1/3,-8,.94,0),Rotation=(i-2)*7})end
  else
   D.Icon(canvas,key=='Damas'and'checkers'or'chess',{Size=UDim2.fromScale(.8,.8),Position=UDim2.fromScale(.1,.1),IconColor=key=='Damas'and C.green or Color3.fromRGB(241,222,186)})
  end
  local sub=D.Text(p,key=='Truco'and'Duplas · blefe · estratégia'or key=='Damas'and'Capturas · decisões precisas'or'Planeje · ataque · proteja',{TextColor3=C.muted,TextSize=12,TextWrapped=true})
  local buttons={};U.PlayButtons[key]={}
  for i,a in ipairs(actions)do local b=D.Button(p,a[2],{TextSize=13,BackgroundColor3=a[3],TextColor3=(i==2 or i==4)and C.bg or C.text});buttons[i]=b;U.PlayButtons[key][a[1]]=b
   b.Activated:Connect(function()if U.Busy or U.WaitingState then return end;U.Selected=key;U.Mode=a[1];U.Options.Visible=true;U.Manual=false;U.Layout()end)
  end
  U.GameButtons[key]=title;panels[key]={root=p,title=title,art=art,canvas=canvas,sub=sub,buttons=buttons}
 end
 U.Options=D.Frame(U.Root,{Name='GameOptions',BackgroundColor3=Color3.fromRGB(14,24,25),Visible=false,ZIndex=40});D.Stroke(U.Options,C.green,.45,1)
 U.GameTitle=D.Text(U.Options,'',{TextSize=22,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=41})
 U.OptionsClose=D.IconButton(U.Options,'CloseGameOptions','close','Voltar aos jogos',{ZIndex=70})
 U.OptionsClose.Activated:Connect(function()if not U.WaitingState and not U.Busy then U.Options.Visible=false end end)
 U.Intro=D.Text(U.Options,'',{TextSize=12,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=41})
 U.VariantButton=D.Button(U.Options,'Paulista',{ZIndex=41});U.TeamButton=D.Button(U.Options,'Dupla 1',{ZIndex=41});U.ManualButton=D.Button(U.Options,'Automática',{Visible=false,ZIndex=41})
 U.VariantButton.Activated:Connect(function()if U.Busy or U.WaitingState then return end;local v={'Paulista','Mineiro','Goiano'};U.Variant=v[(table.find(v,U.Variant)or 1)%3+1];U.Layout()end)
 U.TeamButton.Activated:Connect(function()if not U.Busy then U.Team=3-U.Team;U.Layout()end end)
 U.Quick=D.Button(U.Options,'Encontrar partida',{BackgroundColor3=C.blue,ZIndex=41})
 U.Create=D.Button(U.Options,'Criar sala',{BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=41})
 U.Code=D.Box(U.Options,'Código da sala',{TextSize=18,ZIndex=41});U.Join=D.Button(U.Options,'Entrar',{ZIndex=41})
 for _,k in ipairs({'FACIL','MEDIO','DIFICIL'})do local b=D.Button(U.Options,({FACIL='Fácil',MEDIO='Médio',DIFICIL='Difícil'})[k],{ZIndex=41});U.DiffButtons[k]=b
  b.Activated:Connect(function()U.Difficulty=k;U.Layout()end)
 end
 U.Bot=D.Button(U.Options,'Jogar contra bots',{BackgroundColor3=C.gold,TextColor3=C.bg,ZIndex=41})
 U.WaitTitle=D.Text(U.Options,'Sua sala está pronta',{TextSize=22,Font=Enum.Font.GothamBold,ZIndex=41})
 U.WaitDesc=D.Text(U.Options,'',{TextSize=14,TextColor3=C.muted,ZIndex=41})
 U.CodeDisplay=D.Box(U.Options,'',{TextEditable=false,TextSize=26,ZIndex=41})
 U.SelectCode=D.Button(U.Options,'Copiar código',{ZIndex=41});U.Cancel=D.Button(U.Options,'Cancelar espera',{TextColor3=C.red,ZIndex=41})
 U.SelectCode.Activated:Connect(function()U.CodeDisplay:CaptureFocus();U.CodeDisplay.SelectionStart=1;U.CodeDisplay.CursorPosition=#U.CodeDisplay.Text+1 end)
 local DeckUI=require(Rep:WaitForChild('07H5_TRUCO_SETUP')).Build(U.Options,U)
 local counts={}
 function U.SetStatus(t,e)U.Status.Text=tostring(t or'');U.Status.TextColor3=e and C.red or C.muted end
 function U.SetCounts(c)counts=c or{} end
 function U.SetGame(k)if not U.Busy and not U.WaitingState then U.Selected=k;U.Layout()end end
 function U.SetBusy(v)
  U.Busy=v==true
  for _,b in ipairs({U.Close,U.OptionsClose,U.Quick,U.Create,U.Join,U.Bot,U.Cancel,U.VariantButton,U.TeamButton})do D.SetEnabled(b,not U.Busy)end
  for _,p in pairs(panels)do for _,b in ipairs(p.buttons)do D.SetEnabled(b,not U.Busy and not U.WaitingState)end end
 end
 function U.SetWaiting(code,quick,cross,count)
  U.WaitingState=true;U.Options.Visible=true;U.CodeDisplay.Text=tostring(code or'');U.WaitTitle.Text=quick and'Procurando jogadores'or'Sua sala está pronta'
  U.WaitDesc.Text=(count or 1)..(U.Selected=='Truco'and' / 4 jogadores'or' / 2 jogadores')..' · compartilhe o código';U.SetBusy(false);U.Layout()
 end
 function U.SetTransfer(code)U.SetWaiting(code);U.WaitTitle.Text='Conectando à sala';U.WaitDesc.Text='A Roblox está conectando ao anfitrião.'end
 function U.Reset()U.WaitingState=false;U.Options.Visible=false;U.SetBusy(false);U.Layout()end
 function U.Layout()
  local il,it,ir,ib,w,h=safe.Read();local aw=w-il-ir;local y=safe.Heading(U.Header,U.Close);local bar=safe.Topbar();local useBar=aw>=520 and bar.Right-bar.X>=320 and bar.Bottom-bar.Y>=48
  if useBar then y=it+4 end
  R(U.Header,il+10,it+4,aw-200,48);R(U.Coins,w-ir-190,it+4,124,48)
  if useBar then R(U.Header,bar.X+6,bar.Y+4,bar.Right-bar.X-206,44);R(U.Coins,bar.Right-188,bar.Y+4,122,44);R(U.Close,bar.Right-56,bar.Y+4,48,48)end
  R(U.Inventory,il+8,y,math.min(180,(aw-22)/2),44);R(U.Cups,il+math.min(180,(aw-22)/2)+14,y,math.min(180,(aw-22)/2),44)
  local top=y+52;local ph=h-ib-top-28;local stacked=aw<520 and ph>=560;local cw=stacked and aw-16 or(aw-28)/3
  if stacked then ph=(ph-12)/3 end
  for i,k in ipairs(order)do local p=panels[k];R(p.root,il+8+(stacked and 0 or(i-1)*(cw+6)),top+(stacked and(i-1)*(ph+6)or 0),cw,ph)
   local two=ph<280 and cw>=176;local rows=two and 2 or 4;local actionH=rows*44+(rows-1)*6
   local artH=math.max(0,ph-actionH-76);local titleY=artH>32 and artH+8 or 4
   p.art.Visible=artH>32;R(p.art,8,6,cw-16,artH);R(p.title,4,titleY,cw-8,32);p.title.TextSize=cw<160 and 18 or 23
   p.sub.Visible=ph>360 and cw>=170;R(p.sub,8,titleY+34,cw-16,24)
   local ay=ph-actionH-8;for j,b in ipairs(p.buttons)do R(b,8+(two and(j-1)%2*(cw-10)/2 or 0),ay+math.floor((j-1)/(two and 2 or 1))*50,two and(cw-22)/2 or cw-16,44);b.TextSize=cw<160 and 11 or 13;b.TextWrapped=true end
   if stacked then
    local left=cw*.4;p.art.Visible=true;p.sub.Visible=false;R(p.title,6,6,left-4,30);p.title.TextSize=20;R(p.art,8,40,left-10,ph-48)
    local bx=left+8;local bw=(cw-bx-14)/2;for j,b in ipairs(p.buttons)do R(b,bx+(j-1)%2*(bw+6),(ph-94)/2+math.floor((j-1)/2)*50,bw,44);b.TextSize=11 end
   end
   local artW,artHeight=p.art.Size.X.Offset,p.art.Size.Y.Offset;local fw,fh
   if k=='Truco'then fw=math.min(artW,artHeight*2.1);fh=fw/2.1 else fw=math.min(artW,artHeight);fh=fw end
   R(p.canvas,(artW-fw)/2,(artHeight-fh)/2,fw,fh)
  end
  R(U.Status,il+8,h-ib-24,aw-16,22)
  local ow=math.min(900,aw-16);local oh=math.min(620,h-it-ib-16)
  R(U.Options,il+(aw-ow)/2,it+8,ow,oh);R(U.GameTitle,12,4,ow-80,48);R(U.OptionsClose,ow-60,4,48,48)
  U.GameTitle.Text=(U.Selected=='Damas'and'Dama'or U.Selected)..' · '..({Online='Partida rápida',Create='Criar sala',Join='Entrar',Practice='Contra bots'})[U.Mode]
  R(U.Intro,12,54,ow-24,24);U.Intro.Text=U.Mode=='Online'and'Encontre jogadores com as mesmas regras.'or U.Mode=='Create'and'Sua sala, suas regras. Compartilhe o código.'or U.Mode=='Join'and'Cole o código de quatro caracteres.'or'Escolha um nível e jogue no seu ritmo.'
  local waiting=U.WaitingState;local truco=U.Selected=='Truco';local show=not waiting
  U.Intro.Visible=show;U.VariantButton.Visible=show and truco and U.Mode~='Join';U.TeamButton.Visible=show and truco and U.Mode=='Join'
  U.VariantButton.Text=U.Variant..' ▾';R(U.VariantButton,12,84,ow-24,44);R(U.TeamButton,12,84,ow-24,44);U.TeamButton.Text='Dupla '..U.Team..' ▾'
  U.Quick.Visible=show and U.Mode=='Online';U.Create.Visible=show and U.Mode=='Create';U.Join.Visible=show and U.Mode=='Join';U.Code.Visible=U.Join.Visible;U.Bot.Visible=show and U.Mode=='Practice'
  R(U.Code,12,truco and 134 or 90,ow-24,44)
  for i,k in ipairs({'FACIL','MEDIO','DIFICIL'})do local b=U.DiffButtons[k];b.Visible=U.Bot.Visible;R(b,12+(i-1)*(ow-18)/3,oh-104,(ow-36)/3,44);b.BackgroundColor3=U.Difficulty==k and C.green or C.card end
  for _,b in ipairs({U.Quick,U.Create,U.Join,U.Bot})do R(b,12,oh-54,ow-24,44)end
  for _,o in ipairs({U.WaitTitle,U.WaitDesc,U.CodeDisplay,U.SelectCode,U.Cancel})do o.Visible=waiting end
  R(U.WaitTitle,12,66,ow-24,42);R(U.WaitDesc,12,110,ow-24,44);R(U.CodeDisplay,12,164,ow-158,48);R(U.SelectCode,ow-138,164,126,48);R(U.Cancel,12,oh-54,ow-24,44)
  DeckUI.Layout(ow,oh,truco and show and U.Mode~='Join')
 end
 safe.Watch(U.Layout);U.Layout();return U
end
return M
