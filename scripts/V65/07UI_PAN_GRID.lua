-- 07UI_PAN_GRID | ModuleScript | ReplicatedStorage | V65 (NOVO)
-- Toque nativo nos dois eixos; arraste com mouse e não abra um card ao soltá-lo.
local Input=game:GetService('UserInputService');local M={Version='V65'}
function M.Bind(scroll,enabled)
 local P={};local drag;local blockedUntil=0;local links={};local closed=false
 scroll.ScrollingDirection=Enum.ScrollingDirection.XY;scroll.ScrollingEnabled=true;scroll.Active=true
 local function visible()
  if closed or not scroll.Parent or enabled and not enabled()then return false end
  local a=scroll;while a do if a:IsA('GuiObject')and not a.Visible then return false end;a=a.Parent end;return true
 end
 local function inside(p)
  local a,s=scroll.AbsolutePosition,scroll.AbsoluteSize
  return p.X>=a.X and p.X<=a.X+s.X and p.Y>=a.Y and p.Y<=a.Y+s.Y
 end
 function P.Move(x,y)
  local s=scroll.AbsoluteSize;local canvas=scroll.CanvasSize
  local maxX=math.max(0,canvas.X.Scale*s.X+canvas.X.Offset-s.X);local maxY=math.max(0,canvas.Y.Scale*s.Y+canvas.Y.Offset-s.Y)
  scroll.CanvasPosition=Vector2.new(math.clamp(x,0,maxX),math.clamp(y,0,maxY))
 end
 function P.Step(direction)local pos=scroll.CanvasPosition;P.Move(pos.X+scroll.AbsoluteSize.X*.8*direction,pos.Y)end
 function P.CanActivate()return os.clock()>=blockedUntil and not(drag and drag.moved)end
 links[#links+1]=Input.InputBegan:Connect(function(io)
  local k=io.UserInputType
  if(k~=Enum.UserInputType.MouseButton1 and k~=Enum.UserInputType.Touch)or not visible()or not inside(io.Position)then return end
  drag={input=io,start=Vector2.new(io.Position.X,io.Position.Y),canvas=scroll.CanvasPosition,touch=k==Enum.UserInputType.Touch,moved=false}
 end)
 links[#links+1]=Input.InputChanged:Connect(function(io)
  if not drag then return end
  if drag.touch and io~=drag.input or not drag.touch and io.UserInputType~=Enum.UserInputType.MouseMovement then return end
  local delta=Vector2.new(io.Position.X,io.Position.Y)-drag.start
  if delta.Magnitude>=10 then drag.moved=true;blockedUntil=os.clock()+.25 end
  if drag.moved and not drag.touch then P.Move(drag.canvas.X-delta.X,drag.canvas.Y-delta.Y)end
 end)
 links[#links+1]=Input.InputEnded:Connect(function(io)
  if not drag or io~=drag.input then return end
  if drag.moved then blockedUntil=os.clock()+.25 end;drag=nil
 end)
 function P.Destroy()if closed then return end;closed=true;for _,c in ipairs(links)do c:Disconnect()end;links={};drag=nil end
 links[#links+1]=scroll.Destroying:Connect(P.Destroy);return P
end
return M
