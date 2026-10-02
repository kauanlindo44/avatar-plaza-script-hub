-- 07P4_STUDIO_UI | ModuleScript | ReplicatedStorage
-- V42: editor de foto com paineis compactos e viewport livre para o avatar.
local Rep=game:GetService("ReplicatedStorage")
local D=require(Rep:WaitForChild("07UI_DESIGN_SYSTEM"));local C=D.Colors
local Bounds=require(Rep:WaitForChild("07UI_SCREEN_BOUNDS"))
local M={}
function M.Build(pl)
 local pg=pl:WaitForChild("PlayerGui");local old=pg:FindFirstChild("ACP_PhotoMode");if old then old:Destroy()end
 local gui=D.New("ScreenGui",{Name="ACP_PhotoMode",ResetOnSpawn=false,IgnoreGuiInset=true,ScreenInsets=Enum.ScreenInsets.None,SafeAreaCompatibility=Enum.SafeAreaCompatibility.None,ClipToDeviceSafeArea=false,DisplayOrder=220,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
 local U={Gui=gui,Buttons={},Axes={},Environment={}};local safe=Bounds.Bind(gui)
 U.Root=D.New("Frame",{Name="PhotoStudio",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false},gui)
 U.Title=D.Text(U.Root,"Photo Mode",{Font=Enum.Font.GothamBold,TextSize=22,TextXAlignment=Enum.TextXAlignment.Left,BackgroundColor3=C.panel,BackgroundTransparency=.1})
 U.Close=D.IconButton(U.Root,"ClosePhoto","close","Fechar Photo Mode",{Size=UDim2.fromOffset(44,40),ZIndex=40})
 U.Nav=D.Scroll(U.Root,{BackgroundColor3=C.panel,BackgroundTransparency=.04,ScrollingDirection=Enum.ScrollingDirection.X,AutomaticCanvasSize=Enum.AutomaticSize.X,ScrollBarThickness=0})
 D.New("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},U.Nav);D.Pad(U.Nav,4,4,4,4)
 for i,p in ipairs({{"Pose","Pose"},{"Background","Fundos"},{"Environment","Ambiente"},{"Camera","Câmera"},{"Capture","Foto"},{"Hide","Ocultar"}})do
  U.Buttons[p[1]]=D.Button(U.Nav,p[2],{LayoutOrder=i,Size=UDim2.fromOffset(92,40),TextSize=14})
 end
 U.Popup=D.Frame(U.Root,{Name="PhotoTools",BackgroundColor3=C.panel,Visible=false,ZIndex=30})
 U.PopupTitle=D.Text(U.Popup,"",{Position=UDim2.fromOffset(10,4),Size=UDim2.new(1,-60,0,36),Font=Enum.Font.GothamBold,TextSize=18,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=31})
 U.PopupClose=D.IconButton(U.Popup,"CloseTools","close","Fechar painel",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-6,0,4),Size=UDim2.fromOffset(40,36),ZIndex=32})
 U.Content=D.Scroll(U.Popup,{Position=UDim2.fromOffset(8,46),Size=UDim2.new(1,-16,1,-52),ZIndex=31})
 D.New("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},U.Content)
 U.PoseFooter=D.New("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,8,1,-8),Size=UDim2.new(1,-16,0,42),BackgroundTransparency=1,Visible=false,ZIndex=32},U.Popup)
 U.PoseCancel=D.Button(U.PoseFooter,"Cancelar",{Size=UDim2.new(.5,-3,1,0),ZIndex=33})
 U.PoseConfirm=D.Button(U.PoseFooter,"Confirmar",{Position=UDim2.new(.5,3,0,0),Size=UDim2.new(.5,-3,1,0),BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=33})
 U.Restore=D.Button(U.Root,"Mostrar UI",{Size=UDim2.fromOffset(118,40),Visible=false,BackgroundTransparency=.25,ZIndex=50})
 U.Status=D.Text(U.Root,"",{TextSize=14,BackgroundColor3=C.panel,BackgroundTransparency=.08,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=40})
 function U.Clear()
  for _,o in ipairs(U.Content:GetChildren())do if o:IsA("GuiObject")then o:Destroy()end end
  U.Axes={};U.Environment={}
 end
 function U.Row(label,value,order)
  local row=D.Frame(U.Content,{Size=UDim2.new(1,-4,0,80),BackgroundColor3=C.card,LayoutOrder=order or 0,ZIndex=32})
  D.Text(row,label,{Position=UDim2.fromOffset(8,4),Size=UDim2.new(1,-16,0,22),TextXAlignment=Enum.TextXAlignment.Left,TextSize=14,ZIndex=33})
  local minus=D.Button(row,"−",{Position=UDim2.fromOffset(8,30),Size=UDim2.fromOffset(44,42),ZIndex=33})
  local box=D.Box(row,"",{Position=UDim2.fromOffset(58,30),Size=UDim2.new(1,-116,0,42),Text=tostring(value),TextSize=17,ZIndex=33,TextXAlignment=Enum.TextXAlignment.Center})
  local plus=D.Button(row,"+",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-8,0,30),Size=UDim2.fromOffset(44,42),ZIndex=33})
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
  Bounds.Rect(U.Nav,il+6,h-ib-54,aw-12,48)
  Bounds.Rect(U.Restore,w-ir-124,it+6,118,40)
  Bounds.Rect(U.Status,il+8,y+4,aw-16,42)
  local top=y+52;local ph=landscape and h-ib-top-64 or math.min(330,math.max(200,h*.39))
  local pw=landscape and math.min(360,aw*.44)or aw-12
  Bounds.Rect(U.Popup,landscape and w-ir-pw-6 or il+6,landscape and top or h-ib-64-ph,pw,ph)
  U.Content.Size=UDim2.new(1,-16,1,U.PoseFooter.Visible and -102 or -52)
  if U.OnLayout then U.OnLayout(il,it,ir,ib,w,h,landscape,top)end
 end
 safe.Watch(U.Layout);U.Popup:GetPropertyChangedSignal("Visible"):Connect(U.Layout);U.PoseFooter:GetPropertyChangedSignal("Visible"):Connect(U.Layout)
 return U
end
return M
