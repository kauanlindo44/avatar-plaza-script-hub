-- 07UI_HALLOWEEN_THEME | ModuleScript | ReplicatedStorage | V69 (SUBSTITUIR)
-- Camada sazonal discreta sobre a identidade clara; nunca recolore avatares/cartas.
local Gui=game:GetService('GuiService');local Tween=game:GetService('TweenService')
local M={};local bound=setmetatable({},{__mode='k'});local styled=setmetatable({},{__mode='k'})
M.Colors={bg=Color3.fromRGB(14,15,19),panel=Color3.fromRGB(25,27,34),card=Color3.fromRGB(36,39,48),line=Color3.fromRGB(83,91,106),orange=Color3.fromRGB(247,155,89),purple=Color3.fromRGB(177,143,242),white=Color3.fromRGB(242,245,249)}
M.EndsAt=1793502000 -- 01/11/2026, 00h de Brasília.
local C=M.Colors
function M.Enabled(pg,now)
 local mode=pg and pg:GetAttribute('ACP_HalloweenMode')or'Auto'
 if mode=='Off'then return false elseif mode=='On'then return true end
 return(not pg or pg:GetAttribute('ACP_HalloweenEnabled')~=false)and(now or os.time())<M.EndsAt
end
function M.SetMode(pg,mode)
 mode=(mode=='On'or mode=='Off')and mode or'Auto';pg:SetAttribute('ACP_HalloweenMode',mode)
 pg:SetAttribute('ACP_HalloweenEnabled',mode=='On'or mode=='Auto'and os.time()<M.EndsAt)
end
local function n(k,q,p)local o=Instance.new(k);for a,b in pairs(q)do o[a]=b end;o.Parent=p;return o end
local function round(o,r)n('UICorner',{CornerRadius=UDim.new(0,r or 10)},o)end
local function shape(p,x,y,w,h,c,r,rot)
 local o=n('Frame',{Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundColor3=c,BorderSizePixel=0,Active=false,Selectable=false,Rotation=rot or 0,ZIndex=p.ZIndex},p)
 if r then round(o,r)end;return o
end
function M.Pumpkin(parent,size)
 local f=n('Frame',{Name='PumpkinIllustration',BackgroundTransparency=1,Size=UDim2.fromOffset(64,64),Active=false,Selectable=false,ZIndex=parent.ZIndex},parent)
 local scale=n('UIScale',{Scale=(size or 44)/64},f)
 for i=-1,1 do shape(f,13+i*8,17,38,38,i==0 and C.orange or Color3.fromRGB(218,144,79),20)end
 shape(f,29,9,7,13,Color3.fromRGB(102,131,86),2,-13)
 shape(f,20,30,8,5,C.white,1,-18);shape(f,38,30,8,5,C.white,1,18);shape(f,26,44,17,4,C.white,2)
 return f,scale
end
local function preserve(o)
 local p=o
 for _=1,20 do
  if not p then break end
  if p:GetAttribute('V56_NoTheme')or p:GetAttribute('V56_PreserveArt')or p:IsA('ViewportFrame')then return true end
  if p.Name=='Board'or p.Name=='CardFace'or p.Name=='CardBack'or p.Name=='CustomArtwork'or p.Name=='BoardCanvas'or p.Name=='EditableCard'then return true end
  p=p.Parent
 end;return false
end
function M.Decorate(root)
 if not root or preserve(root)or root:FindFirstChild('HalloweenSceneAccent')then return end
 local owner=root:FindFirstAncestorOfClass('ScreenGui');if owner then local count=0;for _,o in ipairs(owner:GetDescendants())do if o.Name=='HalloweenSceneAccent'then count=count+1 end end;if count>=2 then return end end
 local layer=n('Frame',{Name='HalloweenSceneAccent',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Active=false,Selectable=false,ClipsDescendants=true,ZIndex=math.max(0,root.ZIndex-1)},root)
 layer:SetAttribute('V56_NoTheme',true)
 local leaf=shape(layer,0,0,180,100,Color3.fromRGB(235,216,241),70,-12);leaf.AnchorPoint=Vector2.new(1,0);leaf.Position=UDim2.new(1,60,0,-60);leaf.BackgroundTransparency=.5
 local pumpkin=M.Pumpkin(layer,38);pumpkin.AnchorPoint=Vector2.new(0,1);pumpkin.Position=UDim2.new(0,8,1,-6)
 local player=game:GetService('Players').LocalPlayer;local pg=player and player:FindFirstChild('PlayerGui')
 local function update()if layer.Parent then layer.Visible=M.Enabled(pg)end end
 if pg then local c=pg:GetAttributeChangedSignal('ACP_HalloweenEnabled'):Connect(update);layer.Destroying:Connect(function()c:Disconnect()end)end;update()
end
function M.Button(o)
 if styled[o]or preserve(o)then return end;styled[o]=true
 if o.BackgroundTransparency>=1 then return end
 if not o:FindFirstChildOfClass('UICorner')then round(o)end
 local st=o:FindFirstChildOfClass('UIStroke')or n('UIStroke',{Color=C.line,Thickness=1,Transparency=.65},o)
 local function focus(a)
  if not o.Parent then return end
  if Gui.ReducedMotionEnabled then st.Transparency=a else Tween:Create(st,TweenInfo.new(.12),{Transparency=a}):Play()end
 end
 o.SelectionGained:Connect(function()focus(.08)end);o.SelectionLost:Connect(function()focus(.65)end)
end
local textBound=setmetatable({},{__mode='k'});local changing=setmetatable({},{__mode='k'})
local function luminance(c)
 local function channel(v)return v<=.04045 and v/12.92 or((v+.055)/1.055)^2.4 end
 return channel(c.R)*.2126+channel(c.G)*.7152+channel(c.B)*.0722
end
local function contrast(o)
 if changing[o]or not o.Parent or preserve(o)then return end
 local p=o;local background=C.bg
 for _=1,12 do
  if not p then break end
  if p:IsA('GuiObject')and p.BackgroundColor3 and(p.BackgroundTransparency or 0)<.4 then background=p.BackgroundColor3;break end;p=p.Parent
 end
 local ink=o.TextColor3;if not ink then return end
 local a,b=luminance(background),luminance(ink);local ratio=(math.max(a,b)+.05)/(math.min(a,b)+.05)
 if ratio<4.5 then
  local light=Color3.fromRGB(35,39,49);local dark=C.white;local dl,ll=luminance(dark),luminance(light)
  local rd=(math.max(a,dl)+.05)/(math.min(a,dl)+.05);local rl=(math.max(a,ll)+.05)/(math.min(a,ll)+.05)
  changing[o]=true;o.TextColor3=rd>=rl and dark or light;changing[o]=nil
 end
end
local function text(o)
 if textBound[o]then return end;textBound[o]=true
 o:GetPropertyChangedSignal('TextColor3'):Connect(function()contrast(o)end)
 o:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()contrast(o)end)
 local parent=o.Parent
 if parent and parent:IsA('GuiObject')then local c=parent:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()contrast(o)end);o.Destroying:Connect(function()c:Disconnect()end)end
 contrast(o)
end
function M.Apply(o)
 if not o:IsA('GuiObject')or preserve(o)then return end
 if o:IsA('TextLabel')or o:IsA('TextButton')or o:IsA('TextBox')then text(o)end
 if o:IsA('GuiButton')then M.Button(o)
 elseif o:IsA('Frame')then
  local name=o.Name;local root=o.Parent and o.Parent:IsA('ScreenGui')
  if root or name:find('Window')or name:find('Popup')or name:find('Dialog')or name:find('Panel')then M.Decorate(o)end
 end
end
function M.IsGameGui(g)
 if not g:IsA('ScreenGui')then return false end;local name=g.Name
 if name:find('Guide')or name:find('FullBackground')then return false end
 return name:find('^ACP_')or name:find('^Avatar')or name=='GameClubGui'or name=='LimitedMarketHUD'or name:find('^LM')or name:find('^Fashion')
end
function M.Bind(g)
 if bound[g]or not M.IsGameGui(g)then return end;bound[g]=true
 local queue,pending={},false
 local function add(o)
  queue[#queue+1]=o;if pending then return end;pending=true
  task.defer(function()local batch=queue;queue={};pending=false;for _,v in ipairs(batch)do if v.Parent then M.Apply(v)end end end)
 end
 local c=g.DescendantAdded:Connect(add);g.Destroying:Connect(function()c:Disconnect();bound[g]=nil end)
 for _,o in ipairs(g:GetDescendants())do add(o)end
end
function M.Start(pg)
 if pg:GetAttribute('ACP_V69ThemeBound')then return end;pg:SetAttribute('ACP_V69ThemeBound',true)
 for _,g in ipairs(pg:GetChildren())do M.Bind(g)end;pg.ChildAdded:Connect(function(g)task.defer(M.Bind,g)end)
 local last=M.Enabled(pg);local elapsed=0
 game:GetService('RunService').Heartbeat:Connect(function(dt)elapsed=elapsed+dt;if elapsed<30 then return end;elapsed=0;local on=M.Enabled(pg);if on~=last then last=on;pg:SetAttribute('ACP_HalloweenEnabled',on)end end)
end
return M
