-- 07H2_GAME_BOARD | ModuleScript | ReplicatedStorage | V77 (SUBSTITUIR)
-- V42: tabuleiro responsivo, relogios legiveis e controles da partida.
local D=require(game:GetService("ReplicatedStorage"):WaitForChild("07UI_DESIGN_SYSTEM"))
local C,N=D.Colors,D.New
local Sheet=require(game:GetService('ReplicatedStorage'):WaitForChild('07H12_SCORE_SHEET'))
local Audio=require(game:GetService('ReplicatedStorage'):WaitForChild('07UI_GAME_AUDIO'));local M={}
local Fx=require(game:GetService('ReplicatedStorage'):WaitForChild('07UI_SURFACE_EFFECTS'));local F=Fx.Colors
local function rect(p,name,pos,size,col,r,z)
 local f=N("Frame",{Name=name,Position=pos,Size=size,BackgroundColor3=col,BorderSizePixel=0,ZIndex=z or 3},p)
 if r then D.Round(f,r)end;return f
end
local function pieceIcon(cell,p,kind)
 local key=p and(kind..':'..p.c..':'..tostring(p.t)..':'..tostring(p.k))or''
 if cell:GetAttribute('RenderedPiece')==key then return end;cell:SetAttribute('RenderedPiece',key)
 local old=cell:FindFirstChild("PieceIcon");if old then old:Destroy()end;if not p then return end
 local icon=N("Frame",{Name="PieceIcon",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(.75,.75),BackgroundTransparency=1,ZIndex=4},cell)
 local col=kind=="Damas"and(p.c=="W"and Color3.fromRGB(53,39,32)or Color3.fromRGB(201,48,42))or(p.c=="W"and Color3.fromRGB(246,240,215)or Color3.fromRGB(62,62,55))
 local edge=kind=="Damas"and(p.c=="W"and Color3.fromRGB(161,133,103)or Color3.fromRGB(255,169,121))or(p.c=="W"and Color3.fromRGB(107,98,76)or Color3.fromRGB(190,187,166))
 local function shape(name,x,y,w,h,r,angle)
  local f=rect(icon,name,UDim2.fromScale(x,y),UDim2.fromScale(w,h),col,r or 3,5)
  f.Rotation=angle or 0;D.Stroke(f,edge,.15,1);N('UIGradient',{Color=ColorSequence.new(col:Lerp(Color3.new(1,1,1),.24),col:Lerp(Color3.new(0,0,0),.18)),Rotation=100},f);return f
 end
 local shadow=rect(icon,'PieceShadow',UDim2.fromScale(.10,.83),UDim2.fromScale(.80,.13),Color3.new(0,0,0),99,4);shadow.BackgroundTransparency=.65
 if kind=="Damas"then
  shape('DiscEdge',.10,.18,.80,.74,99)
  local disc=shape("Disc",.10,.08,.80,.74,99)
  local ring=N("Frame",{Position=UDim2.fromScale(.17,.17),Size=UDim2.fromScale(.66,.66),BackgroundTransparency=1,ZIndex=6},disc);D.Round(ring,99);D.Stroke(ring,edge,.25,1)
  local shine=rect(disc,'Inset',UDim2.fromScale(.25,.25),UDim2.fromScale(.50,.50),col:Lerp(Color3.new(1,1,1),.08),99,6);D.Stroke(shine,edge,.4,1)
  if p.k then local t=D.Text(disc,"♛",{Size=UDim2.fromScale(1,1),Font=Enum.Font.GothamBold,TextSize=20,TextColor3=edge,ZIndex=7});t.TextScaled=true end
  return
 end
 local t=tostring(p.t or"P")
 shape("Base",.17,.80,.66,.12,4);shape("Foot",.25,.72,.50,.12,4)
 if t=="P"then shape("Stem",.37,.40,.26,.35,6);shape("Head",.30,.12,.40,.36,99)
 elseif t=="R"then
  shape("Tower",.28,.30,.44,.46,4);shape("Top",.20,.18,.60,.19,3)
  for i=0,2 do shape("Tooth"..i,.20+i*.23,.07,.14,.20,2)end
 elseif t=="B"then shape("Stem",.35,.40,.30,.34,7);shape("Head",.31,.10,.38,.36,99,-20);rect(icon,"Cut",UDim2.fromScale(.49,.12),UDim2.fromScale(.05,.22),edge,2,7).Rotation=25
 elseif t=="N"then
  shape("Body",.30,.39,.42,.39,8,-8);shape("Neck",.36,.20,.33,.37,8,-18)
  shape("Head",.20,.18,.45,.24,7,-15);shape("Muzzle",.13,.29,.28,.17,6,-12);shape("Ear",.49,.04,.12,.22,3,-14)
  rect(icon,"Eye",UDim2.fromScale(.43,.25),UDim2.fromScale(.07,.07),edge,99,7)
 elseif t=="Q"then
  shape("Body",.31,.39,.38,.37,6);shape("Crown",.26,.22,.48,.23,5)
  for i=0,2 do shape("Jewel"..i,.17+i*.25,.07+(i%2)*-.02,.16,.20,99)end
 elseif t=="K"then
  shape("Body",.31,.42,.38,.33,7);shape("Crown",.28,.32,.44,.18,5)
  shape("CrossV",.45,.04,.10,.30,2);shape("CrossH",.34,.13,.32,.10,2)
 end
end
function M.Build(gui)
 local U={Cells={},PotatoButtons={},PromotionButtons={},Ranks={},Files={}}
 U.Root=N("Frame",{Name="GameMatch",Size=UDim2.fromScale(1,1),BackgroundColor3=C.bg,BorderSizePixel=0,Visible=false},gui)
 U.Root:SetAttribute('V56_NoTheme',true);local accent=U.Root:FindFirstChild('HalloweenSceneAccent');if accent then accent:Destroy()end
 Fx.Surface(U.Root,Color3.fromRGB(49,46,43),Color3.fromRGB(43,41,38))
 Audio.Bind(U.Root)
 local r=U.Root
 local header=D.Frame(r,{Name="MatchHeader",Position=UDim2.fromOffset(16,12),Size=UDim2.new(1,-32,0,74),BackgroundColor3=Color3.fromRGB(57,66,54)})
 U.Title=D.Text(header,"Xadrez",{Position=UDim2.fromOffset(16,8),Size=UDim2.new(1,-82,0,30),TextSize=23,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})
 U.Message=D.Text(header,"Sua vez.",{Position=UDim2.fromOffset(16,42),Size=UDim2.new(1,-82,0,24),TextSize=13,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 U.Minimize=D.IconButton(header,"Minimize","close","Ocultar partida",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-12,.5,0),Size=UDim2.fromOffset(44,44)})
 local group=N("Frame",{Name="MatchContent",Position=UDim2.fromOffset(16,102),Size=UDim2.new(1,-32,1,-118),BackgroundTransparency=1},r)
 U.Grid=N("Frame",{Name="Board",Size=UDim2.fromOffset(512,512),BackgroundColor3=C.card,BorderSizePixel=0},group)
 U.Rim=rect(group,'ClassicBoardRim',UDim2.fromOffset(0,0),UDim2.fromOffset(528,528),Color3.fromRGB(75,65,43),8,1);U.Grid.ZIndex=3;D.Stroke(U.Rim,Color3.fromRGB(137,118,78),.15,2);D.Stroke(U.Grid,C.line,.1,2)
 local boardEdge=U.Grid:FindFirstChildOfClass('UIStroke');boardEdge.Color=Color3.fromRGB(137,118,78);boardEdge.Thickness=2
 for vr=1,8 do U.Cells[vr]={};for vc=1,8 do
  local b=N("TextButton",{Name="Cell_"..vr.."_"..vc,Position=UDim2.fromScale((vc-1)/8,(vr-1)/8),Size=UDim2.fromScale(1/8,1/8),Text="",BorderSizePixel=0,AutoButtonColor=false,
   BackgroundColor3=(vr+vc)%2==0 and C.sq1 or C.sq2},U.Grid);U.Cells[vr][vc]=b
  local co=N("TextLabel",{Name="Coord",BackgroundTransparency=1,Position=UDim2.new(0,3,1,-15),Size=UDim2.new(1,-6,0,13),Text="",TextSize=10,Font=Enum.Font.GothamBold,
   TextXAlignment=Enum.TextXAlignment.Right,TextColor3=(vr+vc)%2==0 and C.sq2 or C.sq1,ZIndex=8,Visible=false},b)
  local dot=N("Frame",{Name="Hint",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(.20,.20),BackgroundColor3=C.bg,BackgroundTransparency=.38,BorderSizePixel=0,Visible=false,ZIndex=8},b);D.Round(dot,99)
 end end
 for i=1,8 do
  U.Ranks[i]=D.Text(U.Grid,tostring(9-i),{AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,-18,(i-.5)/8,0),Size=UDim2.fromOffset(16,18),TextSize=13,TextColor3=C.muted})
  U.Files[i]=D.Text(U.Grid,string.char(96+i),{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new((i-.5)/8,0,1,3),Size=UDim2.fromOffset(18,18),TextSize=13,TextColor3=C.muted})
 end
 U.Potato=N("Frame",{Name="PotatoBoard",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false},group)
 N("UIGridLayout",{CellSize=UDim2.new(.2,-8,.5,-8),CellPadding=UDim2.fromOffset(10,10),FillDirectionMaxCells=5,SortOrder=Enum.SortOrder.LayoutOrder},U.Potato)
 for i=1,10 do
  local b=D.Button(U.Potato,tostring(i),{Name="Potato"..i,LayoutOrder=i,TextSize=18,TextYAlignment=Enum.TextYAlignment.Bottom,BackgroundColor3=C.card})
  D.Icon(b,"potato",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.42),Size=UDim2.fromScale(.48,.48),IconColor=C.gold})
  local pad=b:FindFirstChildOfClass("UIPadding");if pad then pad.PaddingBottom=UDim.new(0,8)end;U.PotatoButtons[i]=b
 end
 U.Side=D.Scroll(group,{Name="MatchPanel",Position=UDim2.fromOffset(536,0),Size=UDim2.fromOffset(292,512),BackgroundColor3=C.panel,BackgroundTransparency=0,AutomaticCanvasSize=Enum.AutomaticSize.None});D.Round(U.Side,12)
 local side=U.Side
 U.Info=D.Text(side,"Você joga com as claras",{Position=UDim2.fromOffset(16,12),Size=UDim2.new(1,-32,0,28),TextSize=14,TextXAlignment=Enum.TextXAlignment.Left})
 U.ClockRow=N("Frame",{Position=UDim2.fromOffset(12,54),Size=UDim2.new(1,-24,0,74),BackgroundTransparency=1},side)
 local function timer(name,x)
  local card=D.Frame(U.ClockRow,{Position=UDim2.new(x,x==0 and 0 or 4,0,0),Size=UDim2.new(.5,-4,1,0),BackgroundColor3=C.bg})
  D.Text(card,name,{Name="ClockCaption",Position=UDim2.fromOffset(8,6),Size=UDim2.new(1,-16,0,19),TextSize=13,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
  return D.Text(card,"—",{Position=UDim2.fromOffset(8,30),Size=UDim2.new(1,-16,0,32),TextSize=26,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})
 end
 U.WhiteClock=timer("Claras",0);U.BlackClock=timer("Escuras",.5)
 U.TrainingInfo=D.Text(side,"Treino • Médio",{Position=UDim2.fromOffset(16,54),Size=UDim2.new(1,-32,0,64),TextSize=20,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,Visible=false})
 U.Turn=D.Text(side,"SUA VEZ",{Position=UDim2.fromOffset(16,150),Size=UDim2.new(1,-32,0,38),TextSize=14,Font=Enum.Font.GothamBold,BackgroundColor3=C.green,BackgroundTransparency=0,TextColor3=C.bg});D.Round(U.Turn,8)
 U.Material=D.Text(side,'',{Name='BoardMaterialBalance',TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=C.gold})
 U.PlayerTop=D.Frame(group,{Name='OpponentStrip',BackgroundTransparency=1})
 U.PlayerBottom=D.Frame(group,{Name='YourStrip',BackgroundTransparency=1})
 U.PlayerNames={};U.PlayerImages={}
 for _,host in ipairs({U.PlayerTop,U.PlayerBottom})do
  U.PlayerImages[host]=N('ImageLabel',{Name='PlayerPortrait',BackgroundTransparency=1,Size=UDim2.fromOffset(36,36),Position=UDim2.fromOffset(0,4)},host)
  U.PlayerNames[host]=D.Text(host,'Jogador',{Position=UDim2.fromOffset(44,4),Size=UDim2.new(1,-152,0,36),TextXAlignment=Enum.TextXAlignment.Left,TextSize=14})
 end
 U.Sheet=Sheet.Build(side);U.SheetHeading=D.Text(side,'Lances',{TextSize=16,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})
 function U.SetMoveLog(rows)U.Sheet.Set(rows)end
 U.LocalLog={};U.LocalPly=0
 function U.ResetLog()U.LocalLog={};U.LocalPly=0;U.Previous=nil;U.LastSquares={};U.Sheet.Set({})end
 function U.RecordMove(move,side,promotion)U.LocalPly=U.LocalPly+1;Sheet.Append(U.LocalLog,move,side,U.LocalPly,promotion);U.Sheet.Set(U.LocalLog)end
 function U.SetPlayers(players,viewSide)U.Players=players;U.ViewSide=viewSide or'W';U.Layout()end
 U.MatchNote=D.Text(side,"Partida neste servidor",{Position=UDim2.fromOffset(16,204),Size=UDim2.new(1,-32,0,44),TextSize=13,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 local actions=N("Frame",{Name="MatchActions",AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,12,1,-12),Size=UDim2.new(1,-24,0,102),BackgroundTransparency=1},side)
 U.Chat=D.Button(side,'Conversa',{Name='OpenBoardChat',Size=UDim2.fromOffset(112,44)})
 U.MatchChat=require(game:GetService('ReplicatedStorage'):WaitForChild('07H10_MATCH_CHAT_UI')).Build(U.Root,U.Chat)
 U.Claim=D.Button(actions,"Pedir empate",{Size=UDim2.new(1,0,0,44)})
 U.Resign=D.Button(actions,"Desistir",{Position=UDim2.fromOffset(0,56),Size=UDim2.new(1,0,0,44),TextColor3=C.red})
 U.Mini=D.Button(gui,"Voltar à partida",{Name="ReturnMatch",AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-16),Size=UDim2.fromOffset(204,44),BackgroundColor3=C.green,TextColor3=C.bg,Visible=false})
 U.Promotion=D.Frame(r,{Name="Promotion",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(360,154),BackgroundColor3=C.panel,Visible=false,ZIndex=100});D.Stroke(U.Promotion)
 D.Text(U.Promotion,"Promover peão",{Position=UDim2.fromOffset(16,12),Size=UDim2.new(1,-32,0,30),TextSize=20,Font=Enum.Font.GothamBold,ZIndex=101})
 for i,v in ipairs({{"Q","Rainha"},{"R","Torre"},{"B","Bispo"},{"N","Cavalo"}})do
  U.PromotionButtons[v[1]]=D.Button(U.Promotion,v[2],{Position=UDim2.new((i-1)/4,8,0,68),Size=UDim2.new(.25,-16,0,60),ZIndex=101})
 end
 U.Confirm=D.Frame(r,{Name="ResignDialog",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(380,188),BackgroundColor3=C.panel,Visible=false,ZIndex=110});D.Stroke(U.Confirm)
 U.ConfirmTitle=D.Text(U.Confirm,"Desistir da partida?",{Position=UDim2.fromOffset(16,18),Size=UDim2.new(1,-32,0,30),TextSize=21,Font=Enum.Font.GothamBold,ZIndex=111})
 U.ConfirmDescription=D.Text(U.Confirm,"Seu adversário vence esta partida.",{Position=UDim2.fromOffset(16,59),Size=UDim2.new(1,-32,0,38),TextColor3=C.muted,ZIndex=111})
 U.ConfirmYes=D.Button(U.Confirm,"Desistir",{Position=UDim2.fromOffset(16,122),Size=UDim2.new(.5,-22,0,44),TextColor3=C.red,ZIndex=111})
 U.ConfirmNo=D.Button(U.Confirm,"Continuar",{Position=UDim2.new(.5,6,0,122),Size=UDim2.new(.5,-22,0,44),BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=111})
 function U.Draw(state,kind,viewSide,sel,hints)
  if not state or not state.board then return end;U.Root:SetAttribute('ACP_ChatGameType',kind);U.Kind=kind;U.ViewSide=viewSide;U.ActiveSide=state.turn;U.Rim.BackgroundColor3=kind=='Damas'and Color3.fromRGB(72,47,34)or Color3.fromRGB(70,75,47)
  local previous=U.Previous or{};local nextKeys,changes={},{}
  for rr=1,8 do nextKeys[rr]={};for cc=1,8 do local p=state.board[rr]and state.board[rr][cc];local key=p and(p.c..':'..tostring(p.t)..':'..tostring(p.k))or'';nextKeys[rr][cc]=key;if previous[rr]and previous[rr][cc]~=key then changes[#changes+1]={r=rr,c=cc,old=previous[rr][cc],key=key}end end end
  local white,black=0,0;local values={P=1,N=3,B=3,R=5,Q=9,K=0}
  for _,row in ipairs(state.board)do for _,p in pairs(row)do local v=kind=='Damas'and(p.k and 3 or 1)or(values[p.t]or 0);if p.c=='W'then white=white+v else black=black+v end end end
  U.Material.Text=kind=='Damas'and('Material · claras '..white..' / vermelhas '..black)or('Material · claras '..white..' / escuras '..black)
  if #changes>0 and U.PreviousKind==kind then Audio.Play('move',nil,.12,kind=='Damas'and 1.15 or 1)end
  U.LastSquares=U.LastSquares or{}
  if #changes>0 then U.LastSquares={};for _,c in ipairs(changes)do U.LastSquares[c.r..':'..c.c]=true end end
  local slide=#changes>=2 and #changes<=4 and U.PreviousKind==kind
  for i=1,8 do local index=viewSide=="B"and 9-i or i;U.Ranks[i].Text=tostring(9-index);U.Files[i].Text=string.char(96+index)end
  for vr=1,8 do for vc=1,8 do
   local row,col=vr,vc;if viewSide=="B"then row,col=9-vr,9-vc end
   local b=U.Cells[vr][vc];local p=state.board[row]and state.board[row][col]
   local light=Color3.fromRGB(238,238,210);local dark=kind=='Damas'and Color3.fromRGB(138,117,93)or Color3.fromRGB(118,150,86)
   b.BackgroundColor3=sel and sel.r==row and sel.c==col and Color3.fromRGB(204,189,99)or((vr+vc)%2==0 and light or dark)
   if not(sel and sel.r==row and sel.c==col)and U.LastSquares[row..':'..col]then b.BackgroundColor3=b.BackgroundColor3:Lerp(Color3.fromRGB(235,197,104),.24)end
   b.Hint.Visible=hints and hints[row..":"..col]==true or false
   local before=b:GetAttribute('RenderedPiece');local chosen=sel and sel.r==row and sel.c==col
   local edge=b:FindFirstChildOfClass('UIStroke')or D.Stroke(b,C.blue,1,2);edge.Transparency=chosen and .05 or 1
   b.Coord.Text=(vr==8 or vc==1)and(string.char(96+col)..tostring(9-row))or"";pieceIcon(b,p,kind)
   if slide and p and before~=b:GetAttribute('RenderedPiece')then
    for _,change in ipairs(changes)do if change.old==nextKeys[row][col]and change.key~=change.old then
     local icon=b:FindFirstChild('PieceIcon');if icon then local dx,dy=change.c-col,change.r-row;if viewSide=='B'then dx,dy=-dx,-dy end;icon.Position=UDim2.fromScale(.5+dx,.5+dy);Fx.Animate(icon,{Position=UDim2.fromScale(.5,.5)},.14)end;break
    end end
   end
  end end
  U.Previous=nextKeys;U.PreviousKind=kind;U.Layout()
 end
 local function fmt(v)v=math.max(0,math.floor(tonumber(v)or 0));return string.format("%d:%02d",math.floor(v/60),v%60)end
 function U.SetTimes(white,black)U.WhiteClock.Text=fmt(white);U.BlackClock.Text=fmt(black)
  for color,clock in pairs({W=U.WhiteClock,B=U.BlackClock})do clock.Parent.BackgroundColor3=U.ActiveSide==color and Color3.fromRGB(67,76,54)or Color3.fromRGB(48,46,43) end
 end
 function U.SetTraining(on,diff)
  U.Root:SetAttribute('ACP_ChatBot',on==true)
  U.ClockRow.Visible=not on;U.TrainingInfo.Visible=on;local names={FACIL='Nico',MEDIO='Lia',DIFICIL='Dante'};U.TrainingInfo.Text='Contra '..tostring(names[diff]or diff or'Lia');U.Training=on;U.Players=on and{W={name='Você'},B={name=names[diff]or'Lia'}}or U.Players
  U.MatchNote.Text=on and"Jogue no seu ritmo; o placar da sessão continua na revanche."or"Resultado, revisão do tabuleiro e revanche ao terminar."
 end
 function U.SetTurn(label,yours)U.Turn.Text=label;U.Turn.BackgroundColor3=yours and C.green or C.soft;U.Turn.TextColor3=yours and C.bg or C.white end
 local Bounds=require(game:GetService("ReplicatedStorage"):WaitForChild("07UI_SCREEN_BOUNDS"));local safe=Bounds.Bind(gui)
 function U.Layout()
  local il,it,ir,ib,w,h=safe.Read();if w<1 or h<1 then return end
  local usable=w-il-ir;U.Title.Parent=r;U.Minimize.Parent=r;header.Visible=false
  local freeY=safe.Heading(U.Title,U.Minimize);local bar=safe.Topbar()
  if usable>=520 and bar.Right-bar.X>=320 and bar.Bottom-bar.Y>=48 then
   Bounds.Rect(U.Title,bar.X+8,bar.Y+4,bar.Right-bar.X-72,44);Bounds.Rect(U.Minimize,bar.Right-56,bar.Y+4,48,48);freeY=it+4
  end
  U.Message.Parent=r;Bounds.Rect(U.Message,il+8,freeY,usable-16,24)
  local gy=freeY+28;local gh=h-ib-gy-8;local landscape=usable>=560 and w>h
  local sideW=landscape and math.clamp(usable*.26,172,280)or usable-16
  local dim=math.max(80,math.min(landscape and gh-112 or gh-204,landscape and usable-sideW-60 or usable-32,720))
  local left=landscape and(usable-dim-sideW-28)/2 or(usable-dim)/2
  Bounds.Rect(group,il,gy,usable,gh);Bounds.Rect(U.Grid,left,52,dim,dim)
  Bounds.Rect(U.Rim,left-6,46,dim+12,dim+12)
  Bounds.Rect(U.PlayerTop,left,0,dim,44);Bounds.Rect(U.PlayerBottom,left,dim+60,dim,44)
  local sh=landscape and gh or gh-dim-116;local sideX=landscape and left+dim+28 or 8;local sideY=landscape and 0 or dim+116
  Bounds.Rect(U.Side,sideX,sideY,sideW,math.max(80,sh));U.Side.ScrollingEnabled=false
  U.Side.CanvasSize=UDim2.fromOffset(0,math.max(80,sh));U.ClockRow.Visible=false
  U.Info.Visible=false;U.MatchNote.Visible=false;U.TrainingInfo.Visible=false
  Bounds.Rect(U.Turn,8,4,sideW-16,28);U.Material.Visible=sh>=260;Bounds.Rect(U.Material,8,36,sideW-16,36)
  local listY=sh>=260 and 80 or 36
  U.SheetHeading.Visible=sh>=200;U.Sheet.List.Visible=sh>=200
  Bounds.Rect(U.SheetHeading,8,listY,sideW-16,26);Bounds.Rect(U.Sheet.List,4,listY+28,sideW-8,math.max(1,sh-listY-86))
  Bounds.Rect(actions,8,math.max(36,sh-48),sideW-16,44)
  Bounds.Rect(U.Claim,0,0,(sideW-22)/2,44);Bounds.Rect(U.Resign,U.Claim.Visible and(sideW-10)/2 or 0,0,U.Claim.Visible and(sideW-22)/2 or sideW-16,44)
  U.Resign.TextSize=12;U.Claim.TextSize=12
  local view=U.ViewSide or'W';local topSide=view=='W'and'B'or'W'
  local players=U.Players or{W={name='Claras'},B={name='Escuras'}}
  for _,entry in ipairs({{U.PlayerTop,topSide},{U.PlayerBottom,view}})do
   local host,color=entry[1],entry[2];local data=players[color]or{};local clock=color=='W'and U.WhiteClock or U.BlackClock
   clock.Parent=host;Bounds.Rect(clock,math.max(44,dim-102),0,102,44);clock.TextSize=24;clock.TextXAlignment=Enum.TextXAlignment.Right
   clock.Visible=not U.Training;U.PlayerNames[host].Text=data.name or(color=='W'and'Claras'or'Escuras')
   U.PlayerImages[host].Image=data.id and('rbxthumb://type=AvatarHeadShot&id='..data.id..'&w=150&h=150')or''
   host.BackgroundColor3=U.ActiveSide==color and Color3.fromRGB(67,76,54)or Color3.fromRGB(48,46,43);host.BackgroundTransparency=.15
  end
  U.Chat.Parent=r;Bounds.Rect(U.Chat,U.Minimize.Position.X.Offset-100,U.Minimize.Position.Y.Offset+2,94,44)
  U.Title.Size=UDim2.fromOffset(math.max(60,U.Title.Size.X.Offset-100),U.Title.Size.Y.Offset)
  U.Potato.Position=U.Grid.Position;U.Potato.Size=U.Grid.Size
  U.Promotion.Size=UDim2.fromOffset(math.min(360,usable-24),154);U.Confirm.Size=UDim2.fromOffset(math.min(380,usable-24),188)
 end
 Fx.Surface(U.Side,F.panel,Color3.fromRGB(40,42,40),Color3.fromRGB(137,118,78))
 for _,b in ipairs({U.Claim,U.Resign,U.Minimize,U.Mini,U.ConfirmNo,U.ConfirmYes})do Fx.Button(b,F.blue)end
 for _,b in pairs(U.PromotionButtons)do Fx.Button(b,F.gold)end
 Fx.Surface(U.Promotion,F.navy,F.panel,F.gold);Fx.Surface(U.Confirm,F.navy,F.panel,F.blue)
 safe.Watch(U.Layout);r:GetPropertyChangedSignal("AbsoluteSize"):Connect(U.Layout);U.Claim:GetPropertyChangedSignal("Visible"):Connect(U.Layout);U.Layout()
 return U
end
return M
