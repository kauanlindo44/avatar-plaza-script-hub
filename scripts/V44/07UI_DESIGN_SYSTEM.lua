-- 07UI_DESIGN_SYSTEM | ModuleScript | ReplicatedStorage
-- V43: controles acessiveis, X explicito e decoracao sem capturar toque.
local Gui=game:GetService("GuiService")
local Tween=game:GetService("TweenService")
local M={}
M.Colors={bg=Color3.fromRGB(20,21,24),panel=Color3.fromRGB(29,31,36),card=Color3.fromRGB(38,41,47),
 soft=Color3.fromRGB(51,55,63),line=Color3.fromRGB(76,81,91),white=Color3.fromRGB(245,246,248),
 muted=Color3.fromRGB(168,175,188),green=Color3.fromRGB(143,190,94),red=Color3.fromRGB(224,106,112),
 blue=Color3.fromRGB(114,166,230),yellow=Color3.fromRGB(225,187,107),gold=Color3.fromRGB(225,187,107),
 purple=Color3.fromRGB(167,151,212),orange=Color3.fromRGB(213,165,111),pink=Color3.fromRGB(212,152,179),
 cyan=Color3.fromRGB(139,188,223),sq1=Color3.fromRGB(235,236,217),sq2=Color3.fromRGB(112,141,89),blackPiece=Color3.fromRGB(31,32,35)}
local C=M.Colors
function M.TextScale()
 local ok,v=pcall(function()return Gui.PreferredTextSize end);local n=ok and tostring(v)or""
 return n:find("Largest")and 1.16 or n:find("Larger")and 1.10 or n:find("Large")and 1.05 or 1
end
local scale=M.TextScale()
local function screenBackdrop(owner)
 local name=owner.Name.."_FullBackground";local old=owner.Parent and owner.Parent:FindFirstChild(name);if old then old:Destroy()end
 local back=Instance.new("ScreenGui");back.Name=name;back.ResetOnSpawn=owner.ResetOnSpawn;back.IgnoreGuiInset=true
 back.ScreenInsets=Enum.ScreenInsets.None;back.SafeAreaCompatibility=Enum.SafeAreaCompatibility.None;back.ClipToDeviceSafeArea=false
 back.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;back.Enabled=false;back.Parent=owner.Parent
 local fill=Instance.new("Frame");fill.Name="FullscreenFill";fill.Position=UDim2.new();fill.Size=UDim2.fromScale(1,1)
 fill.BackgroundColor3=C.bg;fill.BorderSizePixel=0;fill.Active=false;fill.Selectable=false;fill.Parent=back
 local roots,known={},{};local dead,syncing=false,false
 local function sync()
  if dead or syncing then return end;syncing=true
  back.Parent=owner.Parent;back.DisplayOrder=math.max(0,owner.DisplayOrder-1)
  local selected
  for _,root in ipairs(roots)do
   if root.Parent==owner and root.Visible and root.BackgroundTransparency<1 and(not selected or root.ZIndex>=selected.ZIndex)then selected=root end
  end
  if selected then fill.BackgroundColor3=selected.BackgroundColor3;fill.BackgroundTransparency=selected.BackgroundTransparency end
  back.Enabled=selected~=nil and owner.Enabled;syncing=false
 end
 local function watch(root)
  if known[root]then sync();return end
  if not root:IsA("Frame")then return end;local s=root.Size
  if s.X.Scale~=1 or s.Y.Scale~=1 or s.X.Offset~=0 or s.Y.Offset~=0 then return end
  known[root]=true;roots[#roots+1]=root
  for _,property in ipairs({"Visible","BackgroundColor3","BackgroundTransparency","Parent","ZIndex"})do root:GetPropertyChangedSignal(property):Connect(sync)end
  sync()
 end
 owner.ChildAdded:Connect(watch);owner.ChildRemoved:Connect(sync);back:GetPropertyChangedSignal("Enabled"):Connect(sync)
 for _,property in ipairs({"Enabled","DisplayOrder","Parent"})do owner:GetPropertyChangedSignal(property):Connect(sync)end
 owner.Destroying:Connect(function()dead=true;back:Destroy()end)
 for _,root in ipairs(owner:GetChildren())do watch(root)end;sync()
end
function M.New(class,props,parent)
 local o=Instance.new(class);for k,v in pairs(props or{})do o[k]=v end;if parent then o.Parent=parent end
 if class=="ScreenGui"and(o.Name=="AvatarShop08Gui"or o.Name=="GameClubGui")then screenBackdrop(o)end;return o
end
function M.Round(o,r)return M.New("UICorner",{CornerRadius=UDim.new(0,r or 10)},o)end
function M.Stroke(o,color,t,width)return M.New("UIStroke",{Color=color or C.line,Transparency=t or .45,Thickness=width or 1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},o)end
function M.Pad(o,l,r,t,b)
 return M.New("UIPadding",{PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or 0),PaddingTop=UDim.new(0,t or 0),PaddingBottom=UDim.new(0,b or 0)},o)
end
function M.Text(p,txt,q)
 q=q or{};q.Active=false;q.Selectable=false;q.Text=txt;q.BackgroundTransparency=q.BackgroundTransparency==nil and 1 or q.BackgroundTransparency
 q.TextColor3=q.TextColor3 or C.white;q.Font=q.Font or Enum.Font.Gotham
 q.TextSize=math.max(13,math.floor((q.TextSize or 14)*scale+.5));q.TextWrapped=q.TextWrapped~=false
 return M.New("TextLabel",q,p)
end
function M.Button(p,txt,q)
 q=q or{};q.Text=txt;q.BackgroundColor3=q.BackgroundColor3 or C.card;q.TextColor3=q.TextColor3 or C.white
 q.Font=q.Font or Enum.Font.GothamBold;q.TextSize=math.max(13,math.floor((q.TextSize or 14)*scale+.5))
 q.BorderSizePixel=0;q.AutoButtonColor=true;q.TextWrapped=q.TextWrapped~=false;q.Selectable=true
 local radius=q.Corner or 10;q.Corner=nil;q.Active=q.Active~=false
 local b=M.New("TextButton",q,p);M.Round(b,radius);M.Pad(b,8,8)
 local st=M.Stroke(b,nil,.65)
 local function animate(t)if b.Parent then pcall(function()Tween:Create(st,TweenInfo.new(.12),{Transparency=t}):Play()end)end end
 b.MouseEnter:Connect(function()if b.Active~=false then animate(.15)end end)
 b.MouseLeave:Connect(function()animate(.65)end)
 b.SelectionGained:Connect(function()animate(0)end);b.SelectionLost:Connect(function()animate(.65)end)
 return b
end
function M.Box(p,ph,q)
 q=q or{};q.PlaceholderText=ph or"";q.Text=q.Text or"";q.ClearTextOnFocus=false
 q.BackgroundColor3=q.BackgroundColor3 or C.bg;q.TextColor3=q.TextColor3 or C.white;q.PlaceholderColor3=q.PlaceholderColor3 or C.muted
 q.Font=q.Font or Enum.Font.Gotham;q.TextSize=math.max(13,math.floor((q.TextSize or 14)*scale+.5));q.BorderSizePixel=0;q.TextWrapped=false
 local o=M.New("TextBox",q,p);M.Round(o,9);M.Pad(o,12,12);M.Stroke(o,nil,.55);return o
end
function M.Scroll(p,q)
 q=q or{};q.BackgroundTransparency=q.BackgroundTransparency==nil and 1 or q.BackgroundTransparency;q.BorderSizePixel=0
 q.ScrollBarThickness=q.ScrollBarThickness or 4;q.ScrollBarImageColor3=q.ScrollBarImageColor3 or C.muted
 q.AutomaticCanvasSize=q.AutomaticCanvasSize or Enum.AutomaticSize.Y;q.CanvasSize=q.CanvasSize or UDim2.new();q.ClipsDescendants=true
 return M.New("ScrollingFrame",q,p)
end
function M.Frame(p,q)local o=M.New("Frame",q,p);o.BorderSizePixel=0;M.Round(o,12);return o end
function M.Icon(parent,kind,q)
 q=q or{};q.Name="Icon_"..kind;q.BackgroundTransparency=1;q.Size=q.Size or UDim2.fromOffset(26,26);q.Active=false;q.Selectable=false
 local col=q.IconColor or C.white;q.IconColor=nil
 local icon=M.New("Frame",q,parent);local z=icon.ZIndex+1
 local function shape(x,y,w,h,r,angle,outline)
  local f=M.New("Frame",{Position=UDim2.fromScale(x,y),Size=UDim2.fromScale(w,h),BackgroundColor3=col,
   BorderSizePixel=0,Active=false,Selectable=false,Rotation=angle or 0,BackgroundTransparency=outline and 1 or 0,ZIndex=z},icon)
  if r then M.Round(f,r)end;if outline then M.Stroke(f,col,0,outline)end;return f
 end
 if kind=="music"then
  shape(.42,.12,.10,.61,2);shape(.50,.12,.32,.10,2);shape(.18,.64,.33,.24,99);shape(.72,.16,.10,.48,2);shape(.52,.55,.29,.23,99)
 elseif kind=="cart"then
  shape(.04,.12,.22,.09,2);shape(.20,.19,.10,.48,2,-12);shape(.29,.25,.59,.34,3,0,2);shape(.29,.72,.15,.15,99);shape(.70,.72,.15,.15,99)
 elseif kind=="trash"then
  shape(.24,.26,.54,.60,3,0,2);shape(.17,.18,.68,.09,2);shape(.36,.08,.29,.09,2);shape(.41,.40,.06,.29,2);shape(.58,.40,.06,.29,2)
 elseif kind=="avatar"or kind=="people"then
  shape(.35,.09,.30,.30,99,0,2);shape(.25,.47,.50,.41,7,0,2)
  if kind=="people"then shape(.02,.22,.22,.22,99,0,2);shape(.03,.58,.16,.26,4,0,2);shape(.76,.22,.22,.22,99,0,2);shape(.81,.58,.16,.26,4,0,2)end
 elseif kind=="camera"then
  shape(.08,.28,.84,.57,5,0,2);shape(.32,.15,.35,.13,3);shape(.35,.40,.30,.30,99,0,2)
 elseif kind=="settings"then
  shape(.30,.30,.40,.40,99,0,3)
  for i=0,3 do shape(.43,.06,.14,.22,2,i*90);local a=math.rad(i*90);shape(.43+math.sin(a)*.34,.43-math.cos(a)*.34,.14,.14,2,i*90)end
 elseif kind=="reset"then
  shape(.15,.17,.66,.66,99,0,3);shape(.64,.09,.24,.24,2);shape(.66,.18,.22,.07,2,30)
 elseif kind=="roblox"then
  shape(.16,.16,.68,.68,1,15);local hole=shape(.38,.38,.24,.24,1,15);hole.BackgroundColor3=C.bg
 elseif kind=="save"then
  shape(.15,.10,.70,.80,3,0,2);shape(.30,.14,.35,.23,2);shape(.29,.61,.42,.26,2,0,2)
 elseif kind=="load"then
  shape(.37,.06,.26,.25,99,0,2);shape(.22,.40,.56,.24,5,0,2);shape(.47,.67,.07,.24,2);shape(.34,.79,.18,.07,2,45);shape(.49,.79,.18,.07,2,-45)
 elseif kind=="outfits"then
  shape(.21,.23,.58,.56,4,0,2);shape(.32,.08,.36,.12,2);shape(.35,.84,.30,.06,2)
 elseif kind=="emote"then
  shape(.37,.03,.24,.24,99);shape(.40,.33,.18,.35,4);shape(.15,.30,.31,.08,3,-25);shape(.53,.31,.31,.08,3,25)
  shape(.29,.65,.12,.30,3,24);shape(.58,.65,.12,.30,3,-24)
 elseif kind=="games"or kind=="chess"then
  shape(.40,.38,.20,.38,5);shape(.32,.28,.36,.16,4);shape(.45,.04,.10,.26,2);shape(.35,.12,.30,.09,2);shape(.23,.79,.54,.11,3)
 elseif kind=="checkers"then
  shape(.15,.15,.70,.70,99,0,3);shape(.31,.31,.38,.38,99,0,2)
 elseif kind=="potato"then
  shape(.19,.10,.63,.81,99,-20,2);shape(.39,.31,.08,.08,99);shape(.58,.55,.08,.08,99);shape(.38,.70,.07,.07,99)
 elseif kind=="plus"then shape(.43,.15,.14,.70,2);shape(.15,.43,.70,.14,2)
 elseif kind=="search"then shape(.12,.10,.53,.53,99,0,2);shape(.61,.61,.30,.09,2,45)
 elseif kind=="close"then shape(.14,.46,.72,.08,2,45);shape(.14,.46,.72,.08,2,-45)
 elseif kind=="catalog"then shape(.16,.16,.68,.68,5,0,2);shape(.36,.06,.28,.21,3,0,2)
 elseif kind=="menu"then for i=0,2 do shape(.14,.19+i*.26,.72,.08,2)end
 elseif kind=="play"then shape(.35,.20,.12,.42,2,-35);shape(.35,.50,.12,.32,2,35)
 elseif kind=="link"then shape(.08,.35,.48,.30,6,-30,2);shape(.44,.35,.48,.30,6,-30,2)
 end
 return icon
end
function M.IconButton(p,name,icon,tip,q)
 q=q or{};q.Name=name;q.Size=q.Size or UDim2.fromOffset(52,52)
 if icon=="close"then q.TextSize=28;q.TextWrapped=false;q.Active=true end
 local b=M.Button(p,icon=="close"and"×"or"",q)
 if icon~="close"then M.Icon(b,icon,{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(.55,.55),ZIndex=b.ZIndex+1})end
 b:SetAttribute("ActionLabel",tip)
 return b
end
function M.SetEnabled(b,on)b.Active=on;b.AutoButtonColor=on;b.TextTransparency=on and 0 or .4 end
return M
