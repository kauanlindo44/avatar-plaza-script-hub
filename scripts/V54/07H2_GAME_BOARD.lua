-- 07H2_GAME_BOARD | ModuleScript | ReplicatedStorage | V54 (SUBSTITUIR)
-- V42: tabuleiro responsivo, relogios legiveis e controles da partida.
local D=require(game:GetService("ReplicatedStorage"):WaitForChild("07UI_DESIGN_SYSTEM"))
local C,N=D.Colors,D.New
local M={}
local Fx=require(game:GetService('ReplicatedStorage'):WaitForChild('07UI_SURFACE_EFFECTS'));local F=Fx.Colors
local function rect(p,name,pos,size,col,r,z)
 local f=N("Frame",{Name=name,Position=pos,Size=size,BackgroundColor3=col,BorderSizePixel=0,ZIndex=z or 3},p)
 if r then D.Round(f,r)end;return f
end
local function pieceIcon(cell,p,kind)
 local old=cell:FindFirstChild("PieceIcon");if old then old:Destroy()end;if not p then return end
 local icon=N("Frame",{Name="PieceIcon",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(.75,.75),BackgroundTransparency=1,ZIndex=4},cell)
 local col=p.c=="W"and Color3.fromRGB(253,250,238)or C.blackPiece
 local edge=p.c=="W"and Color3.fromRGB(59,61,65)or Color3.fromRGB(234,236,238)
 local function shape(name,x,y,w,h,r,angle)
  local f=rect(icon,name,UDim2.fromScale(x,y),UDim2.fromScale(w,h),col,r or 3,5)
  f.Rotation=angle or 0;D.Stroke(f,edge,.25,1);return f
 end
 if kind=="Damas"then
  local disc=shape("Disc",.10,.10,.80,.80,99)
  local ring=N("Frame",{Position=UDim2.fromScale(.17,.17),Size=UDim2.fromScale(.66,.66),BackgroundTransparency=1,ZIndex=6},disc);D.Round(ring,99);D.Stroke(ring,edge,.25,1)
  if p.k then local t=D.Text(disc,"★",{Size=UDim2.fromScale(1,1),Font=Enum.Font.GothamBold,TextSize=20,TextColor3=edge,ZIndex=7});t.TextScaled=true end
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
 Fx.Surface(U.Root,F.navy,Color3.fromRGB(27,48,60))
 local r=U.Root
 local header=D.Frame(r,{Name="MatchHeader",Position=UDim2.fromOffset(16,12),Size=UDim2.new(1,-32,0,74),BackgroundColor3=C.panel})
 U.Title=D.Text(header,"Xadrez",{Position=UDim2.fromOffset(16,8),Size=UDim2.new(1,-82,0,30),TextSize=23,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})
 U.Message=D.Text(header,"Sua vez.",{Position=UDim2.fromOffset(16,42),Size=UDim2.new(1,-82,0,24),TextSize=13,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 U.Minimize=D.IconButton(header,"Minimize","close","Ocultar partida",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-12,.5,0),Size=UDim2.fromOffset(44,44)})
 local group=N("Frame",{Name="MatchContent",Position=UDim2.fromOffset(16,102),Size=UDim2.new(1,-32,1,-118),BackgroundTransparency=1},r)
 U.Grid=N("Frame",{Name="Board",Size=UDim2.fromOffset(512,512),BackgroundColor3=C.card,BorderSizePixel=0},group)
 D.Stroke(U.Grid,C.line,.1,2)
 local boardEdge=U.Grid:FindFirstChildOfClass('UIStroke');boardEdge.Color=F.gold;boardEdge.Thickness=3
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
 U.MatchNote=D.Text(side,"Partida neste servidor",{Position=UDim2.fromOffset(16,204),Size=UDim2.new(1,-32,0,44),TextSize=13,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 local actions=N("Frame",{Name="MatchActions",AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,12,1,-12),Size=UDim2.new(1,-24,0,102),BackgroundTransparency=1},side)
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
  if not state or not state.board then return end
  for i=1,8 do local index=viewSide=="B"and 9-i or i;U.Ranks[i].Text=tostring(9-index);U.Files[i].Text=string.char(96+index)end
  for vr=1,8 do for vc=1,8 do
   local row,col=vr,vc;if viewSide=="B"then row,col=9-vr,9-vc end
   local b=U.Cells[vr][vc];local p=state.board[row]and state.board[row][col]
   b.BackgroundColor3=sel and sel.r==row and sel.c==col and C.blue or((vr+vc)%2==0 and C.sq1 or C.sq2)
   b.Hint.Visible=hints and hints[row..":"..col]==true or false
   b.Coord.Text=(vr==8 or vc==1)and(string.char(96+col)..tostring(9-row))or"";pieceIcon(b,p,kind)
  end end
 end
 local function fmt(v)v=math.max(0,math.floor(tonumber(v)or 0));return string.format("%d:%02d",math.floor(v/60),v%60)end
 function U.SetTimes(white,black)U.WhiteClock.Text=fmt(white);U.BlackClock.Text=fmt(black)end
 function U.SetTraining(on,diff)
  U.ClockRow.Visible=not on;U.TrainingInfo.Visible=on;local names={FACIL='Nico',MEDIO='Lia',DIFICIL='Dante'};U.TrainingInfo.Text='Contra '..tostring(names[diff]or diff or'Lia')
  U.MatchNote.Text=on and"Pratique no seu ritmo."or"Partida neste servidor"
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
  local gy=freeY+30;local gh=h-ib-gy-14;local landscape=usable>=520 and w>h*1.2
  local dim=math.max(80,math.min(usable-28,gh-(landscape and 0 or 164),860))
  group.Position=UDim2.fromOffset(il,gy);group.Size=UDim2.fromOffset(usable,gh)
  U.Grid.Position=UDim2.fromOffset((usable-dim)/2,0);U.Grid.Size=UDim2.fromOffset(dim,dim);U.Potato.Position=U.Grid.Position;U.Potato.Size=U.Grid.Size
  local sideW=landscape and math.min(260,(usable-dim)/2-12)or usable-16
  U.Side.Position=UDim2.fromOffset(landscape and(usable+dim)/2+8 or 8,landscape and 0 or dim+24);U.Side.Size=UDim2.fromOffset(sideW,landscape and gh or gh-dim-24)
  local sh=U.Side.AbsoluteSize.Y;local compact=sh<350
  U.Info.Visible=not compact;U.MatchNote.Visible=not compact;U.Side.ScrollingEnabled=false;U.Side.CanvasSize=UDim2.fromOffset(0,sh)
  Bounds.Rect(U.Turn,8,compact and 0 or 124,sideW-16,28)
  Bounds.Rect(U.ClockRow,8,compact and 32 or 44,sideW-16,56)
  Bounds.Rect(U.TrainingInfo,8,compact and 32 or 44,sideW-16,56);U.TrainingInfo.TextSize=16
  for _,clock in ipairs({U.WhiteClock,U.BlackClock})do Bounds.Rect(clock,6,24,clock.Parent.AbsoluteSize.X-12,28);clock.TextSize=22 end
  Bounds.Rect(actions,8,sh-48,sideW-16,44)
  Bounds.Rect(U.Claim,0,0,U.Claim.Visible and(sideW-22)/2 or sideW-16,44)
  Bounds.Rect(U.Resign,U.Claim.Visible and(sideW-10)/2 or 0,0,U.Claim.Visible and(sideW-22)/2 or sideW-16,44);U.Resign.TextSize=12;U.Claim.TextSize=12
  if not compact then Bounds.Rect(U.Info,8,8,sideW-16,28);Bounds.Rect(U.MatchNote,8,164,sideW-16,44)end
  U.Promotion.Size=UDim2.fromOffset(math.min(360,usable-24),154);U.Confirm.Size=UDim2.fromOffset(math.min(380,usable-24),188)
 end
 Fx.Surface(U.Side,F.panel,Color3.fromRGB(31,54,67),F.blue)
 for _,b in ipairs({U.Claim,U.Resign,U.Minimize,U.Mini,U.ConfirmNo,U.ConfirmYes})do Fx.Button(b,F.blue)end
 for _,b in pairs(U.PromotionButtons)do Fx.Button(b,F.gold)end
 Fx.Surface(U.Promotion,F.navy,F.panel,F.gold);Fx.Surface(U.Confirm,F.navy,F.panel,F.blue)
 safe.Watch(U.Layout);r:GetPropertyChangedSignal("AbsoluteSize"):Connect(U.Layout);U.Claim:GetPropertyChangedSignal("Visible"):Connect(U.Layout);U.Layout()
 return U
end
return M
