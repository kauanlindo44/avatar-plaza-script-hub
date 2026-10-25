-- 07P4_STUDIO_UI | ModuleScript | ReplicatedStorage | V77 (SUBSTITUIR)
-- Barra lateral, avatar em cena e paineis contextuais sem rolagem.
local Rep=game:GetService("ReplicatedStorage")
local D=require(Rep:WaitForChild("07UI_DESIGN_SYSTEM"));local C=D.Colors
local Bounds=require(Rep:WaitForChild("07UI_SCREEN_BOUNDS"))
local M={Version='V77'};local navOrder={"Pose","Animations","Background","Environment","Camera","Video","Capture"}
function M.Build(pl)
 local pg=pl:WaitForChild("PlayerGui");local old=pg:FindFirstChild("ACP_PhotoMode");if old then old:Destroy()end
 local gui=D.New("ScreenGui",{Name="ACP_PhotoMode",ResetOnSpawn=false,IgnoreGuiInset=true,ScreenInsets=Enum.ScreenInsets.None,SafeAreaCompatibility=Enum.SafeAreaCompatibility.None,ClipToDeviceSafeArea=false,DisplayOrder=220,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
 local U={Gui=gui,Buttons={},Axes={},Environment={},PoseMode=false,MenuOpen=false};local safe=Bounds.Bind(gui)
 U.Root=D.New("Frame",{Name="PhotoStudio",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false},gui)
 U.Title=D.Text(U.Root,"Estúdio de fotos",{Font=Enum.Font.GothamBold,TextSize=20,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,ZIndex=10})
 U.Close=D.IconButton(U.Root,"ClosePhoto","close","Fechar Photo Mode",{Size=UDim2.fromOffset(48,48),ZIndex=40})
 U.Nav=D.Frame(U.Root,{Name="PhotoSidebar",BackgroundColor3=C.panel,BackgroundTransparency=.08,ZIndex=15})
 for i,p in ipairs({{"Pose","Pose","avatar"},{"Animations","Emotes","emote"},{"Background","Fundos","catalog"},{"Environment","Luz","settings"},{"Camera","Câmera","camera"},{"Video","Vídeo","camera"},{"Capture","Foto","save"}})do
  local b=D.Button(U.Nav,p[2],{Name="Photo"..p[1],TextSize=12,ZIndex=16});U.Buttons[p[1]]=b
  b.TextYAlignment=Enum.TextYAlignment.Bottom
  D.Icon(b,p[3],{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,4),Size=UDim2.fromOffset(18,18),ZIndex=17})
 end
 U.Shutter=D.IconButton(U.Root,'TakePhoto','camera','Tirar foto sem interface',{Size=UDim2.fromOffset(48,48),BackgroundColor3=Color3.fromRGB(222,235,245),TextColor3=Color3.fromRGB(34,51,69),ZIndex=45})
 U.Buttons.Hide=D.Button(U.Root,"Sem interface",{TextSize=12,ZIndex=40})
 U.DragMode=D.Button(U.Root,"Girar avatar",{TextSize=12,ZIndex=40})
 U.ToolsToggle=D.IconButton(U.Root,"TogglePhotoTools","menu","Mostrar ou ocultar ferramentas",{ZIndex=40})
 U.Extras=D.Frame(U.Root,{Name='AdditionalPhotoTools',BackgroundColor3=C.panel,Visible=false,ZIndex=26})
 U.Rotate=D.IconButton(U.Nav,'RotatePhotoAvatar','reset','Giro automático do avatar',{ZIndex=40})
 U.Close.Parent=U.Nav;U.Close.BackgroundColor3=Color3.fromRGB(213,83,91);U.Buttons.Hide.Parent=U.Nav
 for _,key in ipairs({'Pose','Environment','Camera','Video','Capture'})do U.Buttons[key].Parent=U.Extras end
 U.Shutter.Parent=U.Extras;U.DragMode.Parent=U.Extras
 U.Popup=D.Frame(U.Root,{Name="PhotoTools",BackgroundColor3=C.panel,BackgroundTransparency=.02,Visible=false,ZIndex=30})
 D.Stroke(U.Popup,C.orange,.48,1);D.New("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(58,60,67),Color3.fromRGB(40,42,48)),Rotation=110},U.Popup)
 U.PopupTitle=D.Text(U.Popup,"",{Position=UDim2.fromOffset(12,4),Size=UDim2.new(1,-72,0,44),Font=Enum.Font.GothamBold,TextSize=18,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=31})
 U.PopupClose=D.IconButton(U.Popup,"CloseTools","close","Fechar painel",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-6,0,4),Size=UDim2.fromOffset(48,48),ZIndex=32})
 U.Content=D.Scroll(U.Popup,{Position=UDim2.fromOffset(8,56),Size=UDim2.new(1,-16,1,-64),BackgroundTransparency=1,ZIndex=31,ScrollBarThickness=2,AutomaticCanvasSize=Enum.AutomaticSize.None})
 U.ContentGrid=D.New("UIGridLayout",{CellPadding=UDim2.fromOffset(6,6),SortOrder=Enum.SortOrder.LayoutOrder},U.Content)
 U.PoseFooter=D.New("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,8,1,-8),Size=UDim2.new(1,-16,0,44),BackgroundTransparency=1,Visible=false,ZIndex=32},U.Popup)
 U.PoseReset=D.IconButton(U.PoseFooter,"ResetPose","reset","Restaurar pose",{Size=UDim2.fromOffset(44,44),ZIndex=33})
 U.PoseCancel=D.Button(U.PoseFooter,"Cancelar",{Size=UDim2.new(.5,-3,1,0),ZIndex=33})
 U.PoseConfirm=D.Button(U.PoseFooter,"Aplicar",{Position=UDim2.new(.5,3,0,0),Size=UDim2.new(.5,-3,1,0),BackgroundColor3=C.green,TextColor3=C.bg,ZIndex=33})
 U.Restore=D.Button(U.Root,"Mostrar UI",{Size=UDim2.fromOffset(118,44),Visible=false,BackgroundTransparency=.15,ZIndex=50})
 U.Status=D.Text(U.Root,"",{Name="PhotoNotice",TextSize=12,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,Visible=false,ZIndex=12})
 local noticeId=0
 function U.Notify(text)
  noticeId=noticeId+1;local id=noticeId;U.Status.Text=tostring(text or"");U.Status.Visible=U.Status.Text~=""and not U.Restore.Visible
  task.delay(5,function()if noticeId==id then U.Status.Visible=false end end)
 end
 function U.Clear()
  if U.CameraChoices then U.CameraChoices.Hide()end
  if U.PoseEditor then U.PoseEditor.Destroy();U.PoseEditor=nil end
  U.PoseMode=false;U.CatalogMode=false;U.CatalogKind=nil;U.Content.Visible=true
  for _,o in ipairs(U.Content:GetChildren())do if o:IsA("GuiObject")then o:Destroy()end end
  U.Axes={};U.Environment={}
 end
 function U.Row(label,value,order)
  local row=D.Frame(U.Content,{BackgroundColor3=C.card,LayoutOrder=order or 0,ZIndex=32});row:SetAttribute("MinimumCellHeight",66)
  D.Text(row,label,{Position=UDim2.fromOffset(4,0),Size=UDim2.new(1,-8,0,20),TextSize=12,ZIndex=33})
  local minus=D.Button(row,"−",{Position=UDim2.new(0,2,0,21),Size=UDim2.new(0,44,1,-22),ZIndex=33})
  local box=D.Box(row,"",{Position=UDim2.new(0,46,0,21),Size=UDim2.new(1,-92,1,-22),Text=tostring(value),TextSize=12,ZIndex=33,TextXAlignment=Enum.TextXAlignment.Center})
  local plus=D.Button(row,"+",{Position=UDim2.new(1,-46,0,21),Size=UDim2.new(0,44,1,-22),ZIndex=33})
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
  for name,b in pairs(U.Buttons)do if name~="Hide"then b.BackgroundColor3=name==key and Color3.fromRGB(247,228,209)or C.card end end
 end
 function U.SetClean(on)
  U.Shutter.Visible=not on;U.Title.Visible=not on;U.Close.Visible=not on;U.Nav.Visible=not on;U.Status.Visible=false;U.Buttons.Hide.Visible=not on;U.DragMode.Visible=not on
  U.Popup.Visible=false;U.Restore.Visible=on;U.ToolsToggle.Visible=not on;U.Layout()
 end
 function U.Layout()
  local il,it,ir,ib,w,h=safe.Read();if w<1 or h<1 then return end
  local aw,ah=w-il-ir,h-it-ib;local clean=U.Restore.Visible
  local cell=ah<330 and 44 or 48;local barW=52;local barH=cell*5+16
  local x=w-ir-barW-12;local y=it+math.max(4,(ah-barH)/2)
  Bounds.Rect(U.Nav,x,y,barW,barH);U.Nav.Visible=not clean
  local primary={U.Close,U.Buttons.Background,U.Buttons.Animations,U.Rotate,U.Buttons.Hide}
  for i,b in ipairs(primary)do Bounds.Rect(b,2,2+(i-1)*(cell+3),48,cell)end
  U.Buttons.Hide.Text='Ocultar';U.Buttons.Hide.TextSize=10
  Bounds.Rect(U.ToolsToggle,x-52,y+barH-44,48,44);U.ToolsToggle.Visible=not clean and not U.Popup.Visible
  local extrasW=math.min(244,aw-76);local extrasH=math.min(ah-12,196)
  Bounds.Rect(U.Extras,x-extrasW-8,it+ah-extrasH-6,extrasW,extrasH);U.Extras.Visible=not clean and U.MenuOpen
  local extra={U.Buttons.Pose,U.Buttons.Environment,U.Buttons.Camera,U.Buttons.Video,U.Buttons.Capture,U.Shutter}
  local cw=(extrasW-16)/3
  for i,b in ipairs(extra)do Bounds.Rect(b,4+(i-1)%3*(cw+4),4+math.floor((i-1)/3)*58,cw,54);b.TextSize=10 end
  Bounds.Rect(U.DragMode,4,124,extrasW-8,44);U.DragMode.Visible=not clean
  U.Shutter.Visible=not clean;U.Close.Visible=not clean;U.Buttons.Hide.Visible=not clean
  U.Title.Visible=false;Bounds.Rect(U.Restore,w-ir-126,it+6,118,44)
  local pw=math.min(300,math.max(220,aw*.247));pw=math.min(pw,aw-76)
  local ph=math.min(ah-8,U.CatalogMode and 360 or 400)
  local px=x-pw-10;local py=it+math.max(4,(ah-ph)/2)
  Bounds.Rect(U.Popup,px,py,pw,ph);U.Content.Visible=not U.PoseMode
  if U.Popup.Visible then U.Extras.Visible=false;U.MenuOpen=false end
  local count,minimum=0,44
  for _,o in ipairs(U.Content:GetChildren())do if o:IsA('GuiObject')then count=count+1;minimum=math.max(minimum,tonumber(o:GetAttribute('MinimumCellHeight'))or 44)end end
  local cols=U.CatalogMode and 1 or 2;local rows=math.max(1,math.ceil(count/cols))
  local cw=(pw-16-(cols-1)*6)/cols
  local cellH=U.CatalogMode and ph-64 or math.max(minimum,(ph-64-(rows-1)*6)/rows)
  U.ContentGrid.FillDirectionMaxCells=cols;U.ContentGrid.CellSize=UDim2.fromOffset(cw,cellH)
  U.Content.CanvasSize=UDim2.fromOffset(0,rows*(cellH+6)-6);U.Content.ScrollingEnabled=not U.CatalogMode
  U.PoseCancel.Position=UDim2.fromOffset(46,0);U.PoseCancel.Size=UDim2.new(.5,-26,1,0)
  U.PoseConfirm.Position=UDim2.new(.5,24,0,0);U.PoseConfirm.Size=UDim2.new(.5,-24,1,0)
  Bounds.Rect(U.Status,il+8,h-ib-44,math.max(70,aw-pw-94),36)
  U.SceneMargins={0,0,0,0}
  if U.OnLayout then U.OnLayout(il,it,ir,ib,w,h,w>h,it+54)end
 end
 U.ToolsToggle.Activated:Connect(function()U.MenuOpen=not U.MenuOpen;if U.MenuOpen then U.Popup.Visible=false end;U.Layout()end)
 safe.Watch(U.Layout);U.Popup:GetPropertyChangedSignal("Visible"):Connect(U.Layout);U.PoseFooter:GetPropertyChangedSignal("Visible"):Connect(U.Layout)
 return U
end
return M
