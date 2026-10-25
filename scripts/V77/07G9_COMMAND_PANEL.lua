-- 07G9_COMMAND_PANEL | ModuleScript | ReplicatedStorage | V77 (SUBSTITUIR)
-- Lista legível inspirada na referência enviada; não executa comandos ao tocar no texto.
local Rep=game:GetService('ReplicatedStorage');local UIS=game:GetService('UserInputService')
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local B=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'))
local Commands=require(Rep:WaitForChild('07G5_CHAT_COMMANDS'));local M={}
function M.Build(parent,safe)
 local U={};local ink=Color3.fromRGB(34,45,59);local cream=Color3.fromRGB(239,245,248)
 U.Root=D.Frame(parent,{Name='CommandWindow',BackgroundColor3=ink,BackgroundTransparency=.08,Visible=false,ZIndex=90})
 D.Stroke(U.Root,Color3.fromRGB(130,176,203),.4);D.New('UIGradient',{Color=ColorSequence.new(ink,Color3.fromRGB(60,76,89)),Rotation=90},U.Root)
 U.Header=D.New('Frame',{Name='DragCommandWindow',BackgroundTransparency=1,Active=true,ZIndex=91},U.Root)
 U.Title=D.Text(U.Header,'Comandos',{Font=Enum.Font.GothamBold,TextSize=22,TextColor3=cream,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=92})
 U.Exit=D.IconButton(U.Root,'CloseCommands','close','Fechar lista de comandos',{ZIndex=93})
 U.Hint=D.Text(U.Root,'Digite no chat. Estes comandos afetam só você.',{TextColor3=Color3.fromRGB(174,204,218),TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=91})
 U.List=D.Scroll(U.Root,{Name='PersonalCommandList',AutomaticCanvasSize=Enum.AutomaticSize.None,ZIndex=91,ScrollBarThickness=3})
 local rows={};local lastGroup;local total=0
 for i,c in ipairs(Commands)do
  local group=c.key=='camera'and'Câmera'or(c.key=='open'or c.key=='help')and'Menus'or'Jogador'
  if group~=lastGroup then
   local heading=D.Text(U.List,group,{Name='CommandGroup'..group,Font=Enum.Font.GothamBold,TextSize=17,TextColor3=cream,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=92})
   rows[#rows+1]={object=heading,y=total,h=30};total=total+30;lastGroup=group
  end
  local row=D.New('Frame',{Name='Command'..i,BackgroundTransparency=1,ZIndex=92},U.List)
  D.Text(row,c.alias..(c.argument and('  '..c.argument)or''),{Position=UDim2.fromOffset(4,0),Size=UDim2.new(1,-8,0,22),TextColor3=cream,Font=Enum.Font.GothamBold,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=93})
  D.Text(row,'<i>'..c.description..'</i>',{RichText=true,Position=UDim2.fromOffset(4,22),Size=UDim2.new(1,-8,0,34),TextColor3=Color3.fromRGB(196,210,222),TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=93})
  rows[#rows+1]={object=row,y=total,h=58};total=total+60
 end
 local px,py;local drag;local start;local origin
 function U.Layout()
  local il,it,ir,ib,w,h=safe.Read();local pw=math.min(304,w-il-ir-20);local ph=math.min(400,h-it-ib-20)
  px=math.clamp(px or il+(w-il-ir-pw)/2,il+4,w-ir-pw-4);py=math.clamp(py or it+(h-it-ib-ph)/2,it+4,h-ib-ph-4)
  B.Rect(U.Root,px,py,pw,ph);B.Rect(U.Header,0,0,pw-56,48);B.Rect(U.Title,12,2,pw-80,44);B.Rect(U.Exit,pw-54,2,48,48)
  U.Hint.Visible=false;B.Rect(U.List,12,50,pw-24,math.max(44,ph-58))
  for _,r in ipairs(rows)do B.Rect(r.object,0,r.y,pw-28,r.h)end;U.List.CanvasSize=UDim2.fromOffset(0,total)
 end
 function U.Close()U.Root.Visible=false;drag=nil;if U.OnClose then U.OnClose()end end
 function U.Open()U.Root.Visible=true;U.Layout()end
 U.Exit.Activated:Connect(U.Close)
 U.Header.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=i;start=i.Position;origin=Vector2.new(px,py)end end)
 local move=UIS.InputChanged:Connect(function(i)if drag and(i==drag or i.UserInputType==Enum.UserInputType.MouseMovement)then local delta=i.Position-start;px=origin.X+delta.X;py=origin.Y+delta.Y;U.Layout()end end)
 local ended=UIS.InputEnded:Connect(function(i)if i==drag or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=nil end end)
 U.Root.Destroying:Connect(function()move:Disconnect();ended:Disconnect()end);return U
end
return M
