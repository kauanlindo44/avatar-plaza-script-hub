-- 07UI_SURFACE_EFFECTS | ModuleScript | ReplicatedStorage | V54 (NOVO)
-- Acabamento original para jogos/looks/carrinho; decoração não intercepta toque.
local D=require(game:GetService('ReplicatedStorage'):WaitForChild('07UI_DESIGN_SYSTEM'))
local Tween=game:GetService('TweenService');local Gui=game:GetService('GuiService')
local M={Colors={navy=Color3.fromRGB(22,23,31),panel=Color3.fromRGB(37,36,47),jade=Color3.fromRGB(222,158,100),gold=Color3.fromRGB(240,200,121),blue=Color3.fromRGB(156,178,225),violet=Color3.fromRGB(188,167,242)}}
local C=M.Colors
local function blend(a,b,n)return Color3.new(a.R+(b.R-a.R)*n,a.G+(b.G-a.G)*n,a.B+(b.B-a.B)*n)end
function M.Animate(o,values,duration)
 local reduced=false;pcall(function()local p=game:GetService('Players').LocalPlayer;local pg=p and p:FindFirstChild('PlayerGui');reduced=Gui.ReducedMotionEnabled or pg and pg:GetAttribute('ACP_ReducedMotion')==true end)
 if reduced then for k,v in pairs(values)do o[k]=v end;return end
 pcall(function()Tween:Create(o,TweenInfo.new(duration or .16,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),values):Play()end)
end
function M.Surface(o,low,high,accent)
 low=low or C.navy;high=high or C.panel;o.BorderSizePixel=0
 local g=o:FindFirstChild('V54Gradient')or D.New('UIGradient',{Name='V54Gradient'},o)
 -- UIGradient multiplica a cor original; normalize para não escurecer duas vezes.
 if o:IsA('TextLabel')or o:IsA('GuiButton')then
  o.BackgroundColor3=blend(low,high,.5);g.Color=ColorSequence.new(Color3.new(1,1,1),Color3.new(.92,.94,.96))
 else
  local base=Color3.new(math.max(low.R,high.R,.001),math.max(low.G,high.G,.001),math.max(low.B,high.B,.001));o.BackgroundColor3=base
  local function relative(c)return Color3.new(c.R/base.R,c.G/base.G,c.B/base.B)end
  g.Color=ColorSequence.new(relative(low),relative(high))
 end;g.Rotation=110
 if accent then local s=o:FindFirstChildOfClass('UIStroke')or D.Stroke(o);s.Color=accent;s.Transparency=.72;s.Thickness=1 end
 return o
end
function M.Button(b,accent)
 if b:GetAttribute('V54Button')then return b end;b:SetAttribute('V54Button',true)
 accent=accent or C.jade
 local g=D.New('UIGradient',{Name='V54ButtonLight',Rotation=90},b)
 local s=b:FindFirstChildOfClass('UIStroke')or D.Stroke(b,accent,.6,1)
 g.Color=ColorSequence.new(Color3.new(1,1,1),Color3.new(.86,.90,.94));s.Color=accent
 b.MouseButton1Down:Connect(function()if b.Active then M.Animate(s,{Transparency=.08,Thickness=2},.08)end end)
 b.MouseButton1Up:Connect(function()M.Animate(s,{Transparency=.55,Thickness=1},.16)end)
 b.MouseLeave:Connect(function()M.Animate(s,{Transparency=.65,Thickness=1},.16)end)
 return b
end
function M.Enter(o)
 if not o.Visible then return end
 local scale=o:FindFirstChildOfClass('UIScale')or D.New('UIScale',{},o);scale.Scale=.99
 M.Animate(scale,{Scale=1},.18)
end
function M.Stage(parent,name,z)
 local stage=D.Frame(parent,{Name=name or 'PortraitStage',BackgroundColor3=Color3.fromRGB(151,173,196),ClipsDescendants=true,Active=false,Selectable=false,ZIndex=z or parent.ZIndex})
 M.Surface(stage,Color3.fromRGB(180,198,218),Color3.fromRGB(102,128,153))
 local halo=D.New('Frame',{Name='StudioHalo',AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.42),Size=UDim2.fromScale(.72,.88),BackgroundColor3=Color3.fromRGB(227,237,245),BackgroundTransparency=.72,BorderSizePixel=0,Active=false,Selectable=false,ZIndex=stage.ZIndex},stage);D.Round(halo,300)
 local floor=D.New('Frame',{Name='StudioFloorLight',AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.90),Size=UDim2.fromScale(.65,.12),BackgroundColor3=Color3.fromRGB(40,60,80),BackgroundTransparency=.72,BorderSizePixel=0,Active=false,Selectable=false,ZIndex=stage.ZIndex},stage);D.Round(floor,300)
 return stage
end
function M.BotPortrait(parent,name,color,z)
 local frame=D.Frame(parent,{Name='Portrait'..name,BackgroundColor3=color,Active=false,Selectable=false,ZIndex=z or parent.ZIndex+1});M.Surface(frame,color,blend(color,C.navy,.45))
 local function part(n,x,y,w,h,col,r)
  local f=D.New('Frame',{Name=n,Position=UDim2.fromScale(x,y),Size=UDim2.fromScale(w,h),BackgroundColor3=col,BorderSizePixel=0,Active=false,Selectable=false,ZIndex=frame.ZIndex+1},frame);D.Round(f,r or 8);return f
 end
 local skin=name=='Dante'and Color3.fromRGB(139,91,66)or name=='Lia'and Color3.fromRGB(219,161,125)or Color3.fromRGB(243,198,155)
 part('Shoulders',.13,.65,.74,.42,C.navy,18);part('Head',.25,.20,.5,.5,skin,22)
 part('Hair',.22,.13,.56,.22,name=='Nico'and Color3.fromRGB(105,74,46)or Color3.fromRGB(37,34,49),14)
 if name=='Lia'then part('HairSide',.69,.27,.10,.41,Color3.fromRGB(37,34,49),8)end
 part('EyeLeft',.37,.42,.05,.05,C.navy,3);part('EyeRight',.58,.42,.05,.05,C.navy,3)
 part('ShirtAccent',.39,.75,.22,.07,color,3);return frame
end
function M.Separator(parent,color,z)
 return D.New('Frame',{Name='AccentLine',Size=UDim2.new(1,0,0,2),BackgroundColor3=color or C.jade,BackgroundTransparency=.2,BorderSizePixel=0,Active=false,Selectable=false,ZIndex=z or parent.ZIndex},parent)
end
return M
