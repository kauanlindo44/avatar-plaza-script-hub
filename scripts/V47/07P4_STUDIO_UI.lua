-- 07P4_STUDIO_UI | ModuleScript | ReplicatedStorage | V47
-- Barra lateral, avatar em cena e paineis contextuais sem rolagem.
local Rep=game:GetService("ReplicatedStorage")
local D=require(Rep:WaitForChild("07UI_DESIGN_SYSTEM"));local C=D.Colors
local Bounds=require(Rep:WaitForChild("07UI_SCREEN_BOUNDS"))
local M={};local navOrder={"Pose","Animations","Background","Environment","Camera","Capture"}
function M.Build(pl)
 local pg=pl:WaitForChild("PlayerGui");local old=pg:FindFirstChild("ACP_PhotoMode");if old then old:Destroy()end
 local gui=D.New("ScreenGui",{Name="ACP_PhotoMode",ResetOnSpawn=false,IgnoreGuiInset=true,ScreenInsets=Enum.ScreenInsets.None,SafeAreaCompatibility=Enum.SafeAreaCompatibility.None,ClipToDeviceSafeArea=false,DisplayOrder=220,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
 local U={Gui=gui,Buttons={},Axes={},Environment={},PoseMode=false};local safe=Bounds.Bind(gui)
 U.Root=D.New("Frame",{Name="PhotoStudio",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false},gui)
 U.Title=D.Text(U.Root,"Estúdio de foto",{Font=Enum.Font.GothamBold,TextSize=20,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,ZIndex=10})
 U.Close=D.IconButton(U.Root,"ClosePhoto","close","Fechar Photo Mode",{Size=UDim2.fromOffset(48,48),ZIndex=40})
 U.Nav=D.Frame(U.Root,{Name="PhotoSidebar",BackgroundColor3=C.panel,BackgroundTransparency=.06,ZIndex=15})
 for i,p in ipairs({{"Pose","Pose","avatar"},{"Animations","Emotes","emote"},{"Background","Fundos","catalog"},{"Environment","Luz","settings"},{"Camera","Câmera","camera"},{"Capture","Foto","save"}})do
  local b=D.Button(U.Nav,p[2],{Name="Photo"..p[1],TextSize=12,ZIndex=16});U.Buttons[p[1]]=b
  b.TextYAlignment=Enum.TextYAlignment.Bottom
  D.Icon(b,p[3],{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,4),Size=UDim2.fromOffset(18,18),ZIndex=17})
 end
 U.Buttons.Hide=D.Button(U.Root,"Ocultar UI",{TextSize=12,ZIndex=40})
 U.Popup=D.Frame(U.Root,{Name="PhotoTools",BackgroundColor3=C.panel,BackgroundTransparency=.02,Visible=false,ZIndex=30})
 U.PopupTitle=D.Text(U.Popup,"",{Position=UDim2.fromOffset(12,4),Size=UDim2.new(1,-72,0,44),Font=Enum.Font.GothamBold,TextSize=18,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=31})
 U.PopupClose=D.IconButton(U.Popup,"CloseTools","close","Fechar painel",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-6,0,4),Size=UDim2.fromOffset(48,48),ZIndex=32})
 U.Content=D.New("Frame",{Position=UDim2.fromOffset(8,56),Size=UDim2.new(1,-16,1,-64),BackgroundTransparency=1,ZIndex=31},U.Popup)
 U.ContentGrid=D.New("UIGridLayout",{CellPadding=UDim2.fromOffset(6,6),SortOrder=Enum.SortOrder.LayoutOrder},U.Content)
 U.PoseFooter=D.New("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,8,1,-8),Size=UDim2.new(1,-16,0,44),BackgroundTransparency=1,Visible=false,ZIndex=32},U.Popup)
 U.PoseReset=D.Button(U.PoseFooter,"↺",{Size=UDim2.fromOffset(40,44),TextSize=24,ZIndex=33})
 U.PoseCancel=D.Button(U.PoseFooter,"Cancelar",{Size=UDim2.new(.5,-3,1,0),ZIndex=33})
 U.PoseConfirm=D.Button(U.PoseFooter,"Aplicar",{Position=UDim2.new(.5,3,0,0),Size=UDim2.new(.5,-3,1,0),BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=33})
 U.Restore=D.Button(U.Root,"Mostrar UI",{Size=UDim2.fromOffset(118,44),Visible=false,BackgroundTransparency=.15,ZIndex=50})
 U.Status=D.Text(U.Root,"",{TextSize=12,BackgroundColor3=C.panel,BackgroundTransparency=.12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=12});D.Round(U.Status,8)
 function U.Clear()
  if U.PoseEditor then U.PoseEditor.Destroy();U.PoseEditor=nil end
  U.PoseMode=false;U.Content.Visible=true
  for _,o in ipairs(U.Content:GetChildren())do if o:IsA("GuiObject")then o:Destroy()end end
  U.Axes={};U.Environment={}
 end
 function U.Row(label,value,order)
  local row=D.Frame(U.Content,{BackgroundColor3=C.card,LayoutOrder=order or 0,ZIndex=32})
  D.Text(row,label,{Position=UDim2.fromOffset(4,0),Size=UDim2.new(1,-8,0,20),TextSize=12,ZIndex=33})
  local minus=D.Button(row,"−",{Position=UDim2.new(0,2,0,21),Size=UDim2.new(0,40,1,-22),ZIndex=33})
  local box=D.Box(row,"",{Position=UDim2.new(0,42,0,21),Size=UDim2.new(1,-84,1,-22),Text=tostring(value),TextSize=12,ZIndex=33,TextXAlignment=Enum.TextXAlignment.Center})
  local plus=D.Button(row,"+",{Position=UDim2.new(1,-42,0,21),Size=UDim2.new(0,40,1,-22),ZIndex=33})
  local pad=box:FindFirstChildOfClass("UIPadding");if pad then pad.PaddingLeft=UDim.new(0,0);pad.PaddingRight=UDim.new(0,0)end
  return{Minus=minus,Value=box,Plus=plus,Root=row}
 end
 function U.Option(label,order,color)
  return D.Button(U.Content,label,{Size=UDim2.new(1,-4,0,44),LayoutOrder=order or 0,BackgroundColor3=color or C.card,ZIndex=32,TextSize=13})
 end
 function U.Pair(left,right,order)
  local row=D.New("Frame",{BackgroundTransparency=1,LayoutOrder=order or 0,ZIndex=32},U.Content)
  local a=D.Button(row,left,{Size=UDim2.new(.5,-3,1,0),ZIndex=33,TextSize=11})
  local b=D.Button(row,right,{Position=UDim2.new(.5,3,0,0),Size=UDim2.new(.5,-3,1,0),ZIndex=33,TextSize=11})
  return a,b
 end
 function U.TextLine(label,order)
  return D.Text(U.Content,label,{Size=UDim2.new(1,-4,0,44),TextSize=13,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=order or 0,ZIndex=32})
 end
 function U.Select(key)
  for name,b in pairs(U.Buttons)do if name~="Hide"then b.BackgroundColor3=name==key and C.soft or C.card end end
 end
 function U.SetClean(on)
  U.Title.Visible=not on;U.Close.Visible=not on;U.Nav.Visible=not on;U.Status.Visible=not on;U.Buttons.Hide.Visible=not on
  U.Popup.Visible=false;U.Restore.Visible=on;U.Layout()
 end
 function U.Layout()
  local il,it,ir,ib,w,h=safe.Read();if w<1 or h<1 then return end
  local aw=w-il-ir;local ah=h-it-ib;local landscape=aw>=620;local clean=U.Restore.Visible
  local narrow=aw<420;local nw=narrow and 60 or 78;local packed=ah<304
  if packed then nw=108 end
  U.Nav.Visible=not clean and not U.PoseMode and(landscape or not U.Popup.Visible)
  local navH=packed and 162 or 302;Bounds.Rect(U.Nav,il+6,it+6,nw,math.min(navH,ah-12))
  for i,key in ipairs(navOrder)do local b=U.Buttons[key];local x=packed and(i-1)%2*50+4 or 4;local y=packed and math.floor((i-1)/2)*50+4 or(i-1)*49+4
   Bounds.Rect(b,x,y,packed and 46 or nw-8,44);b.TextSize=packed and 9 or narrow and 10 or 12
   local pad=b:FindFirstChildOfClass("UIPadding");if pad then pad.PaddingLeft=UDim.new(0,1);pad.PaddingRight=UDim.new(0,1);pad.PaddingBottom=UDim.new(0,1)end
  end
  local left=U.Nav.Visible and nw+18 or 8
  Bounds.Rect(U.Title,il+left,it+4,math.max(50,aw-left-150),44);Bounds.Rect(U.Close,w-ir-56,it+4,48,48)
  Bounds.Rect(U.Buttons.Hide,w-ir-150,it+6,88,44);Bounds.Rect(U.Restore,w-ir-126,it+6,118,44)
  local pw=landscape and math.min(464,math.max(260,aw*.47))or aw-12
  local ph=landscape and ah-12 or math.min(380,math.max(280,ah*.50));local px=landscape and w-ir-pw-6 or il+6;local py=landscape and it+6 or h-ib-ph-6
  if U.PoseMode and landscape then pw=math.min(390,aw*.43);px=w-ir-pw-6 end
  Bounds.Rect(U.Popup,px,py,pw,ph);U.Content.Visible=not U.PoseMode
  if U.Popup.Visible and landscape then
   Bounds.Rect(U.Title,il+left,it+4,math.max(50,aw-pw-left-18),44)
   Bounds.Rect(U.Close,il+left,it+52,48,48);Bounds.Rect(U.Buttons.Hide,il+left+54,it+54,88,44)
  end
  local count=0;for _,o in ipairs(U.Content:GetChildren())do if o:IsA("GuiObject")then count=count+1 end end
  local cols=pw>=390 and 3 or pw>=270 and 2 or 1;local rows=math.max(1,math.ceil(count/cols))
  if(ph-64-(rows-1)*6)/rows<44 and pw>=284 then cols=3;rows=math.max(1,math.ceil(count/cols))end
  local cw=(pw-16-(cols-1)*6)/cols
  U.ContentGrid.FillDirectionMaxCells=cols;U.ContentGrid.CellSize=UDim2.fromOffset(cw,math.max(1,(ph-64-(rows-1)*6)/rows))
  U.PoseCancel.Position=UDim2.fromOffset(46,0);U.PoseCancel.Size=UDim2.new(.5,-26,1,0);U.PoseConfirm.Position=UDim2.new(.5,24,0,0);U.PoseConfirm.Size=UDim2.new(.5,-24,1,0)
  U.PoseCancel.TextSize=pw<230 and 11 or 13;U.PoseConfirm.TextSize=pw<230 and 12 or 14
  local statusW=landscape and U.Popup.Visible and aw-pw-left-22 or aw-left-16
  Bounds.Rect(U.Status,il+left,h-ib-50,statusW,44)
  if U.Popup.Visible and not landscape then Bounds.Rect(U.Status,il+left,it+52,aw-left-16,38)end
  U.SceneMargins={il+left,it+54,ir+6,ib+56}
  if U.Popup.Visible then
   if landscape then U.SceneMargins={il+left,it+104,ir+pw+18,ib+56}
   else U.SceneMargins={il+8,it+98,ir+8,ib+ph+16}end
  end
  if U.PoseMode and landscape then U.SceneMargins={il+8,it+104,ir+pw+18,ib+56}end
  if U.OnLayout then U.OnLayout(il,it,ir,ib,w,h,landscape,it+54)end
 end
 safe.Watch(U.Layout);U.Popup:GetPropertyChangedSignal("Visible"):Connect(U.Layout);U.PoseFooter:GetPropertyChangedSignal("Visible"):Connect(U.Layout)
 return U
end
return M
