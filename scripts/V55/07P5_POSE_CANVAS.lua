-- 07P5_POSE_CANVAS | ModuleScript | ReplicatedStorage
-- V55: arraste o manequim 2D para articular a previa R6/R15; sem rolagem.
local UIS=game:GetService("UserInputService")
local D=require(game:GetService("ReplicatedStorage"):WaitForChild("07UI_DESIGN_SYSTEM"));local C=D.Colors
local M={}
function M.Build(parent,pose,onChange,options)
 options=options or{}
 local P={Connections={},Front=true,Move=false,Alive=true,Parts={},Selected=nil}
 local root=D.New("Frame",{Name="PoseCanvas",Position=UDim2.fromOffset(8,52),Size=UDim2.new(1,-16,1,-110),BackgroundTransparency=1,ZIndex=33},parent);P.Root=root
 local tools=D.New("Frame",{Size=UDim2.new(1,0,0,44),BackgroundTransparency=1,ZIndex=34},root)
 local plane=D.Button(tools,"Frente",{Size=UDim2.new(1/3,-3,1,0),TextSize=13,ZIndex=35})
 local mode=D.Button(tools,"Girar",{Position=UDim2.new(1/3,1,0,0),Size=UDim2.new(1/3,-3,1,0),TextSize=13,ZIndex=35})
 local joint=D.Button(tools,"Ombro",{Position=UDim2.new(2/3,2,0,0),Size=UDim2.new(1/3,-3,1,0),TextSize=13,ZIndex=35})
 for _,b in ipairs({plane,mode,joint})do local pad=b:FindFirstChildOfClass("UIPadding");if pad then pad.PaddingLeft=UDim.new(0,3);pad.PaddingRight=UDim.new(0,3)end end
 local label=D.Text(root,"Toque e arraste uma parte",{Position=UDim2.fromOffset(0,38),Size=UDim2.new(1,0,0,20),TextSize=13,TextColor3=C.muted,ZIndex=34,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd})
 local canvas=D.New("Frame",{Name="Mannequin",Position=UDim2.fromOffset(0,50),Size=UDim2.new(1,0,1,-98),BackgroundTransparency=1,ZIndex=34},root)
 label.Visible=false
 local R15=pose.Values.RightShoulder~=nil
 local groups={
  Head={"Neck"},Body={R15 and"Waist"or"RootJoint"},
  RArm=R15 and{"RightShoulder","RightElbow","RightWrist"}or{"Right Shoulder"},
  LArm=R15 and{"LeftShoulder","LeftElbow","LeftWrist"}or{"Left Shoulder"},
  RLeg=R15 and{"RightHip","RightKnee","RightAnkle"}or{"Right Hip"},
  LLeg=R15 and{"LeftHip","LeftKnee","LeftAnkle"}or{"Left Hip"}
 }
 local labels={Head="Cabeça",Body="Cintura",RArm="Braço direito",LArm="Braço esquerdo",RLeg="Perna direita",LLeg="Perna esquerda"}
 local jointNames={Head={"Pescoço"},Body={"Cintura"},RArm={"Ombro","Cotovelo","Pulso"},LArm={"Ombro","Cotovelo","Pulso"},RLeg={"Quadril","Joelho","Pé"},LLeg={"Quadril","Joelho","Pé"}}
 local family,index="RArm",1;local drawing={};local redraw
 local startOffset=nil;local startAngle=0
 local pointer,start,origin,pivot=nil,nil,nil,nil;local scale=1;local worldDrag=false;local highlight;local dragAxis;local gizmo
 local function select(group,i)
  family,index=group,i or 1;P.Selected=groups[family][index]
  joint.Text=jointNames[family][index];joint.Active=#groups[family]>1
  label.Text=labels[family].." • "..joint.Text;redraw()
 end
 local function began(input,g,i,world,axis)
  if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end
  select(g,i);if not pose.Values[P.Selected]then return end
  if pose.Checkpoint then pose.Checkpoint()end
  pointer=input;start=input.Position;origin={table.unpack(pose.Values[P.Selected])};startOffset={table.unpack(pose.Offsets[P.Selected]or{0,0,0})}
  worldDrag=world==true;dragAxis=axis
  local data=drawing[P.Selected];pivot=data and Vector2.new(canvas.AbsolutePosition.X+data.x,canvas.AbsolutePosition.Y+data.y)or Vector2.new(start.X,start.Y)
  if worldDrag and options.camera and pose.Point then local point=pose.Point(P.Selected);if point then local p=options.camera:WorldToViewportPoint(point);pivot=Vector2.new(p.X,p.Y)end end
  startAngle=math.deg(math.atan2(start.X-pivot.X,start.Y-pivot.Y))
 end
 local function block(key,g,i,color)
  local b=D.New("TextButton",{Name="Pose_"..key,Text="",AutoButtonColor=true,BackgroundColor3=color,BorderSizePixel=0,Active=true,Selectable=true,ZIndex=35},canvas)
  D.Round(b,4);D.Stroke(b,C.white,.6,1)
  b.InputBegan:Connect(function(input)began(input,g,i)end);P.Parts[key]=b;return b
 end
 block("Head","Head",1,C.yellow);block("Body","Body",1,C.blue)
 for _,g in ipairs({"RArm","LArm","RLeg","LLeg"})do for i,key in ipairs(groups[g])do block(key,g,i,g:find("Arm")and C.yellow or C.green)end end
 local function angle(key)
  local v=pose.Values[key];return v and(P.Front and -v[3]or v[1])or 0
 end
 redraw=function()
  if not P.Alive then return end
  local w,h=canvas.AbsoluteSize.X,canvas.AbsoluteSize.Y;scale=math.max(.1,math.min(w/190,h/244))
  local cx,cy=w*.5,math.max(0,(h-244*scale)*.5);drawing={}
  local function place(id,key,x,y,bw,bh,a)
   local b=P.Parts[id];if not b then return end
   local offset=pose.Offsets and pose.Offsets[key]or{0,0,0}
   x=x-(P.Front and offset[1]or offset[3])*26;y=y-offset[2]*26
   b.AnchorPoint=Vector2.new(.5,0);b.Position=UDim2.fromOffset(cx+x*scale,cy+y*scale);b.Size=UDim2.fromOffset(bw*scale,bh*scale);b.Rotation=-a
   b.BackgroundTransparency=key==P.Selected and 0 or .10
   local stroke=b:FindFirstChildOfClass("UIStroke");if stroke then stroke.Thickness=key==P.Selected and 3 or 1;stroke.Transparency=key==P.Selected and 0 or .6 end
   drawing[key]={x=cx+x*scale,y=cy+y*scale,angle=a}
   return x+math.sin(math.rad(a))*bh,y+math.cos(math.rad(a))*bh
  end
  local bodyKey=groups.Body[1];local waist=angle(bodyKey)
  place("Head","Neck",0,0,48,44,angle("Neck"));place("Body",bodyKey,0,48,72,78,waist)
  for _,g in ipairs({"RArm","LArm","RLeg","LLeg"})do
   local arm=g:find("Arm")~=nil;local sign=g:sub(1,1)=="R"and -1 or 1
   local x,y=sign*(arm and 57 or 20),arm and 50 or 130;local total=arm and waist or 0
   for i,key in ipairs(groups[g])do
    total=total+angle(key);local bw=arm and 31 or 34
    local bh=R15 and(i==3 and 18 or arm and 33 or 44)or(arm and 81 or 110)
    x,y=place(key,key,x,y,bw,bh,total)
   end
  end
 end
 table.insert(P.Connections,UIS.InputChanged:Connect(function(input)
  if not pointer or not P.Alive or not pose.Editing then return end
  if input~=pointer and not(pointer.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseMovement)then return end
  local p=input.Position
  if P.Move and pose.SetOffset then
   local d=pose.Offsets[P.Selected]or{0,0,0};local axis=P.Front and 1 or 3
   local unit=worldDrag and 90 or math.max(1,scale*26)
   if dragAxis then local delta=dragAxis==1 and(p.X-start.X)or dragAxis==2 and(p.Y-start.Y)or(p.X-start.X+p.Y-start.Y)*.7
    pose.SetOffset(P.Selected,dragAxis,startOffset[dragAxis]-delta/unit)
   else pose.SetOffset(P.Selected,axis,startOffset[axis]-(p.X-start.X)/unit);pose.SetOffset(P.Selected,2,startOffset[2]-(p.Y-start.Y)/unit)end
  else
   local a=math.deg(math.atan2(p.X-pivot.X,p.Y-pivot.Y));local delta=(a-startAngle+180)%360-180
   local axis=dragAxis or(P.Front and 3 or 1);local value=origin[axis]+(P.Front and -delta or delta)
   pose.Set(P.Selected,axis,value)
  end
  redraw();onChange()
 end))
 table.insert(P.Connections,UIS.InputEnded:Connect(function(input)if input==pointer or input.UserInputType==Enum.UserInputType.MouseButton1 then pointer=nil end end))
 local history=D.New("Frame",{Position=UDim2.new(0,0,1,-44),Size=UDim2.new(1,0,0,44),BackgroundTransparency=1,ZIndex=36},root)
 local undo=D.Button(history,"Desfazer",{Size=UDim2.new(.5,-3,1,0),ZIndex=37})
 local redo=D.Button(history,"Refazer",{Position=UDim2.new(.5,3,0,0),Size=UDim2.new(.5,-3,1,0),ZIndex=37})
 undo.Activated:Connect(function()pointer=nil;if pose.Undo then pose.Undo()end;redraw();onChange()end)
 redo.Activated:Connect(function()pointer=nil;if pose.Redo then pose.Redo()end;redraw();onChange()end)
 plane.Activated:Connect(function()P.Front=not P.Front;plane.Text=P.Front and"Frente"or"Lado";if options.onPlane then options.onPlane(P.Front)end;redraw()end)
 mode.Activated:Connect(function()P.Move=not P.Move;mode.Text=P.Move and"Mover"or"Girar"end)
 joint.Activated:Connect(function()select(family,index%#groups[family]+1)end)
 function P.Reset()pose.Reset();redraw();onChange()end
 table.insert(P.Connections,canvas:GetPropertyChangedSignal("AbsoluteSize"):Connect(redraw))
 function P.Destroy()
  if not P.Alive then return end;P.Alive=false;pointer=nil
  for _,c in ipairs(P.Connections)do c:Disconnect()end;if highlight then highlight:Destroy()end;if gizmo then gizmo:Destroy()end;root:Destroy()
 end
 root.Destroying:Connect(function()if P.Alive then P.Alive=false;pointer=nil;for _,c in ipairs(P.Connections)do c:Disconnect()end;if highlight then highlight:Destroy()end;if gizmo then gizmo:Destroy()end end end)
 if options.gizmoParent and options.camera and pose.Point then
  gizmo=D.New("Frame",{Name="PoseHandles",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Active=false,ZIndex=42},options.gizmoParent);P.Gizmo=gizmo
  local knobs={};local defs={{"X",C.red,64,0},{"Y",C.green,0,-64},{"Z",C.blue,-46,46}}
  for i,def in ipairs(defs)do local b=D.Button(gizmo,def[1],{Name="PoseAxis"..def[1],AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(44,44),BackgroundColor3=def[2],TextSize=18,ZIndex=44,Visible=false});D.Round(b,22)
   b.InputBegan:Connect(function(input)began(input,family,index,true,i)end);knobs[i]=b
  end
  table.insert(P.Connections,game:GetService("RunService").RenderStepped:Connect(function()
   local point=pose.Point(P.Selected);local screen,visible;if point then screen,visible=options.camera:WorldToViewportPoint(point)end
   for i,b in ipairs(knobs)do local def=defs[i];local x,y=screen and screen.X+def[3]or 0,screen and screen.Y+def[4]or 0
    local a,s=parent.AbsolutePosition,parent.AbsoluteSize;local insidePanel=x>a.X-24 and x<a.X+s.X+24 and y>a.Y-24 and y<a.Y+s.Y+24
    b.Visible=P.Alive and pose.Editing and visible==true and not insidePanel and x>24 and y>24 and x<options.camera.ViewportSize.X-24 and y<options.camera.ViewportSize.Y-24
    if b.Visible then local base=gizmo.AbsolutePosition;b.Position=UDim2.fromOffset(x-base.X,y-base.Y)end
   end
  end))
 end
 if options.model and options.camera then
  table.insert(P.Connections,UIS.InputBegan:Connect(function(input,processed)
   if processed or not P.Alive or not pose.Editing or(input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1)then return end
   local p=input.Position;local a,s=parent.AbsolutePosition,parent.AbsoluteSize
   if p.X>=a.X and p.X<=a.X+s.X and p.Y>=a.Y and p.Y<=a.Y+s.Y then return end
   local ray=options.camera:ViewportPointToRay(p.X,p.Y);local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={options.model}
   local hit=workspace:Raycast(ray.Origin,ray.Direction*400,params);local key=hit and pose.Parts[hit.Instance.Name]
   if not key then return end
   for g,keys in pairs(groups)do for i,jointKey in ipairs(keys)do if jointKey==key then
    if not highlight then highlight=D.New("Highlight",{Name="SelectedPosePart",FillTransparency=.85,OutlineColor=C.green,OutlineTransparency=0,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop},options.model)end
    highlight.Adornee=hit.Instance;began(input,g,i,true);label.Text="Arraste o corpo · "..labels[g];return
   end end end
  end))
 end
 local function layout()
  if root.AbsoluteSize.Y<230 then
   local side=root.AbsoluteSize.X>=208
   tools.Position=side and UDim2.fromScale(.35,0)or UDim2.fromOffset(0,0);tools.Size=side and UDim2.fromScale(.65,1)or UDim2.new(1,0,0,94)
   history.Visible=false;undo.Parent=tools;redo.Parent=tools
   for i,b in ipairs({plane,mode,joint,undo,redo})do b.Position=UDim2.new((i-1)%3/3,1,0,math.floor((i-1)/3)*50);b.Size=UDim2.new(1/3,-3,0,44);b.TextSize=11 end
   undo.Text='↶';redo.Text='↷';undo.TextSize=22;redo.TextSize=22
   canvas.Position=side and UDim2.new()or UDim2.fromOffset(0,100);canvas.Size=side and UDim2.new(.32,0,1,0)or UDim2.new(1,0,1,-100)
  else
   history.Visible=true;undo.Parent=history;redo.Parent=history;undo.Text="Desfazer";redo.Text="Refazer"
   tools.Position=UDim2.fromOffset(0,0);tools.Size=UDim2.new(1,0,0,44)
   for i,b in ipairs({plane,mode,joint})do b.Position=UDim2.new((i-1)/3,(i-1),0,0);b.Size=UDim2.new(1/3,-3,1,0)end
   history.Position=UDim2.new(0,0,1,-44);history.Size=UDim2.new(1,0,0,44)
   undo.Size=UDim2.new(.5,-3,1,0);redo.Position=UDim2.new(.5,3,0,0);redo.Size=UDim2.new(.5,-3,1,0)
   canvas.Position=UDim2.fromOffset(0,50);canvas.Size=UDim2.new(1,0,1,-98)
  end;redraw()
 end
 table.insert(P.Connections,root:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout));layout()
 P.Redraw=redraw;select("RArm",1);return P
end
return M
