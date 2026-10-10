-- 07UI_HALLOWEEN_THEME | ModuleScript | ReplicatedStorage | V56 (NOVO)
-- Tema compartilhado. Cenografia/ícones não capturam toque nem alteram cartas/tabuleiros.
local Tween=game:GetService('TweenService');local Gui=game:GetService('GuiService')
local M={};local bound=setmetatable({},{__mode='k'});local styled=setmetatable({},{__mode='k'})
M.Colors={bg=Color3.fromRGB(23,20,31),panel=Color3.fromRGB(37,31,47),card=Color3.fromRGB(49,41,61),
 line=Color3.fromRGB(114,85,129),orange=Color3.fromRGB(247,171,77),purple=Color3.fromRGB(181,150,227),white=Color3.fromRGB(249,242,233)}
local C=M.Colors
local function n(kind,props,parent)local o=Instance.new(kind);for k,v in pairs(props)do o[k]=v end;o.Parent=parent;return o end
local function round(o,r)n('UICorner',{CornerRadius=UDim.new(0,r or 10)},o)end
local function shape(parent,x,y,w,h,color,r,angle)
 local f=n('Frame',{Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundColor3=color,BorderSizePixel=0,
  Active=false,Selectable=false,Rotation=angle or 0,ZIndex=parent.ZIndex},parent)
 if r then round(f,r)end;return f
end
function M.Pumpkin(parent,size)
 local host=n('Frame',{Name='PumpkinIllustration',BackgroundTransparency=1,Size=UDim2.fromOffset(size,size),Active=false,Selectable=false,ZIndex=parent.ZIndex},parent)
 local scale=n('UIScale',{Scale=size/64},host);host.Size=UDim2.fromOffset(64,64)
 for i=-1,1 do shape(host,13+i*8,17,38,38,i==0 and C.orange or Color3.fromRGB(221,127,57),20)end
 shape(host,29,9,7,13,Color3.fromRGB(119,149,85),2,-13)
 shape(host,20,30,8,5,C.bg,1,-18);shape(host,38,30,8,5,C.bg,1,18)
 shape(host,26,44,17,5,C.bg,2);shape(host,29,41,4,4,C.orange,0);shape(host,39,47,4,4,C.orange,0)
 return host,scale
end
local function spiderweb(parent)
 local web=n('Frame',{Name='CornerWeb',AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-2,0,0),Size=UDim2.fromOffset(112,94),
  BackgroundTransparency=1,Active=false,Selectable=false,ZIndex=parent.ZIndex},parent)
 for i=0,3 do local ray=shape(web,108,0,1,108,C.purple,nil,20+i*20);ray.AnchorPoint=Vector2.new(1,0);ray.BackgroundTransparency=.84 end
 for i=1,3 do
  local arc=n('Frame',{AnchorPoint=Vector2.new(1,0),Position=UDim2.fromOffset(112,0),Size=UDim2.fromOffset(i*31,i*27),
   BackgroundTransparency=1,Active=false,Selectable=false,ZIndex=web.ZIndex},web);round(arc,18)
  n('UIStroke',{Color=C.purple,Thickness=1,Transparency=.84},arc)
 end
end
function M.Decorate(root)
 if not root or root:GetAttribute('V56_NoTheme')or root:FindFirstChild('HalloweenSceneAccent')then return end
 local old=root:FindFirstChild('HalloweenAccent');if old then old:Destroy()end
 local layer=n('Frame',{Name='HalloweenSceneAccent',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
  Active=false,Selectable=false,ClipsDescendants=true,ZIndex=math.max(0,root.ZIndex-1)},root)
 layer:SetAttribute('V56_NoTheme',true)
 local glow=shape(layer,0,0,1,1,C.purple,90);glow.AnchorPoint=Vector2.new(1,0);glow.Position=UDim2.new(1,40,0,-70);glow.Size=UDim2.fromOffset(220,150);glow.BackgroundTransparency=.95
 spiderweb(layer)
 local pumpkin=M.Pumpkin(layer,56);pumpkin.AnchorPoint=Vector2.new(0,1);pumpkin.Position=UDim2.new(0,8,1,-6)
 local bat=shape(layer,0,0,12,7,C.purple,2);bat.Position=UDim2.new(1,-139,0,20);bat.BackgroundTransparency=.68
 shape(bat,-7,-1,9,5,C.purple,2,-28).BackgroundTransparency=.68;shape(bat,10,-1,9,5,C.purple,2,28).BackgroundTransparency=.68
 local pg=game:GetService('Players').LocalPlayer
 pg=pg and pg:FindFirstChild('PlayerGui')
 local function update()if layer.Parent then layer.Visible=not pg or pg:GetAttribute('ACP_HalloweenEnabled')~=false end end
 if pg then local c=pg:GetAttributeChangedSignal('ACP_HalloweenEnabled'):Connect(update);layer.Destroying:Connect(function()c:Disconnect()end)end;update()
end
local function preserve(o)
 local p=o
 for _=1,16 do
  if not p then break end
  if p:GetAttribute('V56_NoTheme')or p:GetAttribute('V56_PreserveArt')or p:IsA('ViewportFrame')then return true end
  local name=p.Name
  if name=='Board'or name=='BoardCanvas'or name=='CardHost'or name=='CardFace'or name=='CardBack'or name=='CustomArtwork'
   or name=='ThreeCardPreview'or name=='EditableCard'or name=='TrucoHand'or name=='PublicCards'then return true end
  p=p.Parent
 end;return false
end
function M.Button(o)
 if styled[o]or preserve(o)then return end;styled[o]=true
 if o.BackgroundTransparency>=1 then return end
 if not o:FindFirstChildOfClass('UICorner')then round(o,10)end
 local stroke=o:FindFirstChildOfClass('UIStroke')or n('UIStroke',{Color=C.line,Thickness=1,Transparency=.4},o)
 local light=o:FindFirstChildOfClass('UIGradient')or n('UIGradient',{Rotation=90,Color=ColorSequence.new(Color3.new(1,1,1),Color3.new(.88,.84,.95))},o)
 local function animate(alpha)
  if not o.Parent then return end
  local reduced=Gui.ReducedMotionEnabled
  pcall(function()local pg=game:GetService('Players').LocalPlayer.PlayerGui;reduced=reduced or pg:GetAttribute('ACP_ReducedMotion')==true end)
  if reduced then stroke.Transparency=alpha else Tween:Create(stroke,TweenInfo.new(.13),{Transparency=alpha}):Play()end
 end
 o.MouseEnter:Connect(function()if o.Active then animate(.06)end end);o.MouseLeave:Connect(function()animate(.45)end)
 o.SelectionGained:Connect(function()animate(0)end);o.SelectionLost:Connect(function()animate(.45)end)
 o.MouseButton1Down:Connect(function()if o.Active then animate(0)end end)
 o.MouseButton1Up:Connect(function()animate(.35)end)
 if o:IsA('TextButton')then
  local replacements={['↻']='Recarregar',['↺']='Restaurar',['↶ 15°']='Girar −15°',['↷ 15°']='Girar +15°'}
  if replacements[o.Text]then o.Text=replacements[o.Text]end
 end
end
function M.Apply(o)
 if not o:IsA('GuiObject')or preserve(o)then return end
 if o:IsA('GuiButton')then M.Button(o)
 elseif o:IsA('TextBox')then
  if not o:FindFirstChildOfClass('UICorner')then round(o,10)end
  if not o:FindFirstChildOfClass('UIStroke')then n('UIStroke',{Color=C.line,Thickness=1,Transparency=.4},o)end
 elseif o:IsA('Frame')then
  local name=o.Name;local root=o.Parent and o.Parent:IsA('ScreenGui')
  local panel=root or name:find('Window')or name:find('Popup')or name:find('Dialog')or name:find('Panel')or name=='PhotoTools'or name=='AtelierEditor'
  if panel then
   if o.BackgroundTransparency<.3 then
    local col=o.BackgroundColor3;if not o:FindFirstChildOfClass('UIGradient')and math.max(col.R,col.G,col.B)<.4 then o.BackgroundColor3=root and C.bg or C.panel end
    if not o:FindFirstChildOfClass('UIStroke')then n('UIStroke',{Color=C.line,Thickness=1,Transparency=.65},o)end
   end
   M.Decorate(o)
  end
 end
end
function M.IsGameGui(g)
 if not g:IsA('ScreenGui')then return false end;local name=g.Name
 if name:find('Guide')or name:find('FullBackground')then return false end
 return name:find('^ACP_')or name:find('^Avatar')or name=='GameClubGui'or name=='LimitedMarketHUD'or name:find('^LM')or name:find('^Fashion')
end
function M.Bind(g)
 if bound[g]or not M.IsGameGui(g)then return end;bound[g]=true
 local queue,scheduled={},false
 local function enqueue(o)
  queue[#queue+1]=o;if scheduled then return end;scheduled=true
  task.defer(function()local batch=queue;queue={};scheduled=false;for _,v in ipairs(batch)do if v.Parent then M.Apply(v)end end end)
 end
 local added=g.DescendantAdded:Connect(enqueue);g.Destroying:Connect(function()added:Disconnect();bound[g]=nil end)
 for _,o in ipairs(g:GetDescendants())do enqueue(o)end
end
function M.Start(pg)
 if pg:GetAttribute('ACP_V56ThemeBound')then return end;pg:SetAttribute('ACP_V56ThemeBound',true)
 for _,g in ipairs(pg:GetChildren())do M.Bind(g)end
 pg.ChildAdded:Connect(function(g)task.defer(M.Bind,g)end)
end
return M
