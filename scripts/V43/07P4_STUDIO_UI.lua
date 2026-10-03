-- 07P4_STUDIO_UI | ModuleScript | ReplicatedStorage
-- V43: editor de foto com paineis compactos e viewport livre para o avatar.
local Rep=game:GetService("ReplicatedStorage")
local D=require(Rep:WaitForChild("07UI_DESIGN_SYSTEM"));local C=D.Colors
local Bounds=require(Rep:WaitForChild("07UI_SCREEN_BOUNDS"))
local M={}
function M.Build(pl)
 local pg=pl:WaitForChild("PlayerGui");local old=pg:FindFirstChild("ACP_PhotoMode");if old then old:Destroy()end
 local gui=D.New("ScreenGui",{Name="ACP_PhotoMode",ResetOnSpawn=false,IgnoreGuiInset=true,ScreenInsets=Enum.ScreenInsets.None,SafeAreaCompatibility=Enum.SafeAreaCompatibility.None,ClipToDeviceSafeArea=false,DisplayOrder=220,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
 local U={Gui=gui,Buttons={},Axes={},Environment={},PoseMode=false};local safe=Bounds.Bind(gui)
 U.Root=D.New("Frame",{Name="PhotoStudio",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false},gui)
 U.Title=D.Text(U.Root,"Estúdio de foto",{Font=Enum.Font.GothamBold,TextSize=22,TextXAlignment=Enum.TextXAlignment.Left,BackgroundColor3=C.panel,BackgroundTransparency=.1})
 U.Close=D.IconButton(U.Root,"ClosePhoto","close","Fechar Photo Mode",{Size=UDim2.fromOffset(48,48),ZIndex=40})
 U.Nav=D.Scroll(U.Root,{BackgroundColor3=C.panel,BackgroundTransparency=.04,ScrollingDirection=Enum.ScrollingDirection.X,AutomaticCanvasSize=Enum.AutomaticSize.X,ScrollBarThickness=0})
 D.New("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},U.Nav);D.Pad(U.Nav,4,4,4,4)
 for i,p in ipairs({{"Pose","Pose"},{"Background","Fundos"},{"Environment","Ambiente"},{"Camera","Câmera"},{"Capture","Foto"},{"Hide","Ocultar"}})do
  U.Buttons[p[1]]=D.Button(U.Nav,p[2],{LayoutOrder=i,Size=UDim2.fromOffset(92,40),TextSize=14})
 end
 U.Popup=D.Frame(U.Root,{Name="PhotoTools",BackgroundColor3=C.panel,Visible=false,ZIndex=30})
 U.PopupTitle=D.Text(U.Popup,"",{Position=UDim2.fromOffset(10,4),Size=UDim2.new(1,-60,0,36),Font=Enum.Font.GothamBold,TextSize=18,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=31})
 U.PopupClose=D.IconButton(U.Popup,"CloseTools","close","Fechar painel",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-6,0,4),Size=UDim2.fromOffset(48,48),ZIndex=32})
 U.Content=D.Scroll(U.Popup,{Position=UDim2.fromOffset(8,46),Size=UDim2.new(1,-16,1,-52),ZIndex=31})
 D.New("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},U.Content)
 U.PoseFooter=D.New("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,8,1,-8),Size=UDim2.new(1,-16,0,42),BackgroundTransparency=1,Visible=false,ZIndex=32},U.Popup)
 U.PoseReset=D.Button(U.PoseFooter,"↺",{Size=UDim2.fromOffset(40,44),TextSize=24,ZIndex=33})
 U.PoseCancel=D.Button(U.PoseFooter,"Cancelar",{Size=UDim2.new(.5,-3,1,0),ZIndex=33})
 U.PoseConfirm=D.Button(U.PoseFooter,"Aplicar",{Position=UDim2.new(.5,3,0,0),Size=UDim2.new(.5,-3,1,0),BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=33})
 U.Restore=D.Button(U.Root,"Mostrar UI",{Size=UDim2.fromOffset(118,40),Visible=false,BackgroundTransparency=.25,ZIndex=50})
 U.Status=D.Text(U.Root,"",{TextSize=14,BackgroundColor3=C.panel,BackgroundTransparency=.08,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=40})
 function U.Clear()
  if U.PoseEditor then U.PoseEditor.Destroy();U.PoseEditor=nil end
  U.PoseMode=false;U.Content.Visible=true
  for _,o in ipairs(U.Content:GetChildren())do if o:IsA("GuiObject")then o:Destroy()end end
  U.Axes={};U.Environment={}
 end
 function U.Row(label,value,order)
  local row=D.Frame(U.Content,{Size=UDim2.new(1,-4,0,52),BackgroundColor3=C.card,LayoutOrder=order or 0,ZIndex=32})
  D.Text(row,label,{Position=UDim2.fromOffset(8,6),Size=UDim2.new(.42,-10,0,40),TextXAlignment=Enum.TextXAlignment.Left,TextSize=13,ZIndex=33})
  local minus=D.Button(row,"−",{Position=UDim2.new(.42,0,0,6),Size=UDim2.fromOffset(34,40),ZIndex=33})
  local box=D.Box(row,"",{Position=UDim2.new(.42,36,0,6),Size=UDim2.new(.58,-78,0,40),Text=tostring(value),TextSize=14,ZIndex=33,TextXAlignment=Enum.TextXAlignment.Center})
  local plus=D.Button(row,"+",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-6,0,6),Size=UDim2.fromOffset(34,40),ZIndex=33})
  return{Minus=minus,Value=box,Plus=plus,Root=row}
 end
 function U.Option(label,order,color)
  return D.Button(U.Content,label,{Size=UDim2.new(1,-4,0,42),LayoutOrder=order or 0,BackgroundColor3=color or C.card,ZIndex=32})
 end
 function U.TextLine(label,order)
  return D.Text(U.Content,label,{Size=UDim2.new(1,-4,0,44),TextSize=14,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=order or 0,ZIndex=32})
 end
 function U.SetClean(on)
  U.Title.Visible=not on;U.Close.Visible=not on;U.Nav.Visible=not on;U.Status.Visible=not on;U.Popup.Visible=false;U.Restore.Visible=on;U.Layout()
 end
 function U.Layout()
  local il,it,ir,ib,w,h=safe.Read();if w<1 or h<1 then return end
  local y=safe.Heading(U.Title,U.Close);local aw=w-il-ir;local landscape=w>h*1.2
  U.Nav.Visible=not U.Restore.Visible and not U.PoseMode
  Bounds.Rect(U.Nav,il+6,h-ib-54,aw-12,48)
  Bounds.Rect(U.Restore,w-ir-124,it+6,118,40)
  local pw,ph,px,py
  if U.PoseMode then
   pw=math.min(400,math.max(174,aw*.51));ph=h-ib-it-12;px=w-ir-pw-6;py=it+6
   Bounds.Rect(U.Close,il+8,it+4,48,48);Bounds.Rect(U.Title,il+64,it+4,math.max(1,aw-pw-78),48);U.Title.TextSize=16;U.Title.TextTruncate=Enum.TextTruncate.AtEnd;U.Title.TextWrapped=false
   Bounds.Rect(U.Status,il+8,h-ib-48,aw-pw-22,42)
  else
   local top=y+4;pw=landscape and math.min(380,aw*.43)or aw-12
   ph=landscape and h-ib-top-64 or math.min(344,math.max(210,h*.42));px=landscape and w-ir-pw-6 or il+6;py=landscape and top or h-ib-64-ph
   Bounds.Rect(U.Status,il+8,y+4,landscape and aw-pw-24 or aw-16,38);U.Title.TextSize=22
  end
  Bounds.Rect(U.Popup,px,py,pw,ph);U.Content.Visible=not U.PoseMode
  U.PopupTitle.Size=UDim2.new(1,-70,0,44);U.PopupClose.Size=UDim2.fromOffset(48,48)
  U.Content.Position=UDim2.fromOffset(8,56);U.Content.Size=UDim2.new(1,-16,1,-64)
  U.PoseFooter.Size=UDim2.new(1,-16,0,44)
  U.PoseCancel.Position=UDim2.fromOffset(46,0);U.PoseCancel.Size=UDim2.new(.5,-26,1,0)
  U.PoseConfirm.Position=UDim2.new(.5,24,0,0);U.PoseConfirm.Size=UDim2.new(.5,-24,1,0)
  U.PoseCancel.TextSize=pw<230 and 11 or 13
  U.PoseConfirm.TextSize=pw<230 and 12 or 14
  for _,b in ipairs({U.PoseCancel,U.PoseConfirm})do local pad=b:FindFirstChildOfClass("UIPadding");if pad then pad.PaddingLeft=UDim.new(0,3);pad.PaddingRight=UDim.new(0,3)end end
  if U.OnLayout then U.OnLayout(il,it,ir,ib,w,h,landscape,y+46)end
 end
 safe.Watch(U.Layout);U.Popup:GetPropertyChangedSignal("Visible"):Connect(U.Layout);U.PoseFooter:GetPropertyChangedSignal("Visible"):Connect(U.Layout)
 return U
end
return M
