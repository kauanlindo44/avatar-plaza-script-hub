-- 09I20_ASSISTANT_APPEARANCE | ModuleScript | ReplicatedStorage | V78 (SUBSTITUIR)
-- Aparência clara do assistente, independente do catálogo grafite; nenhuma lógica de conta.
local M={Colors={paper=Color3.fromRGB(226,236,244),panel=Color3.fromRGB(212,225,236),card=Color3.fromRGB(222,226,242),
 ink=Color3.fromRGB(32,33,38),muted=Color3.fromRGB(82,98,116),line=Color3.fromRGB(215,217,223),blue=Color3.fromRGB(42,99,159),white=Color3.new(1,1,1)}}
local light=M.Colors;local dark={paper=Color3.fromRGB(37,38,42),panel=Color3.fromRGB(44,45,50),card=Color3.fromRGB(58,59,65),ink=Color3.fromRGB(235,235,232),muted=Color3.fromRGB(172,174,181),line=Color3.fromRGB(88,90,101),blue=Color3.fromRGB(67,120,220),white=Color3.new(1,1,1)}
function M.Bind(root)
 root:SetAttribute('V56_NoTheme',true)
 local watched=setmetatable({},{__mode='k'});local changing=setmetatable({},{__mode='k'})
 local function apply(o)
  if changing[o]or not o:IsA('GuiObject')then return end
  local p=o;local icon=false;local iconPrimary=false
  while p and p~=root do
   if p:IsA('ViewportFrame')or p:GetAttribute('ACP_KeepAppearance')then return end
   if (p.Name:find('Icon_',1,true)or p.Name=='RailGlyph')then icon=true end;if p:GetAttribute('ACP_Primary')then iconPrimary=true end;p=p.Parent
  end
  local C=root:GetAttribute('AssistantDark')and dark or light;changing[o]=true;local primary=o:GetAttribute('ACP_Primary')==true
  if o:IsA('TextLabel')or o:IsA('TextButton')or o:IsA('TextBox')then
   o.TextColor3=primary and C.white or o:GetAttribute('ACP_Muted')and C.muted or C.ink
   if o:IsA('TextBox')then o.PlaceholderColor3=C.muted end
  end
  if icon and o.ClassName=='Frame'and o.BackgroundTransparency<1 then o.BackgroundColor3=iconPrimary and C.white or C.ink
  elseif(o:IsA('GuiButton')or o:IsA('TextBox'))and o.BackgroundTransparency<1 then o.BackgroundColor3=primary and C.blue or C.card
  elseif o.ClassName=='Frame'and o.BackgroundTransparency<1 then o.BackgroundColor3=o==root and C.paper or C.panel end
  local gradient=o:FindFirstChildOfClass('UIGradient');if gradient then gradient.Enabled=false end
  local stroke=o:FindFirstChildOfClass('UIStroke');if stroke then stroke.Color=icon and(iconPrimary and C.white or C.ink)or C.line;stroke.Transparency=o:GetAttribute('ACP_Plain')and 1 or icon and 0 or .2 end
  changing[o]=nil
 end
 local function watch(o)
  if watched[o]or not o:IsA('GuiObject')then return end;watched[o]=true
  for _,name in ipairs({'BackgroundColor3','TextColor3'})do
   if name~='TextColor3'or o:IsA('TextLabel')or o:IsA('TextButton')or o:IsA('TextBox')then o:GetPropertyChangedSignal(name):Connect(function()apply(o)end)end
  end
  for _,name in ipairs({'ACP_Primary','ACP_Muted','ACP_KeepAppearance','ACP_Plain'})do o:GetAttributeChangedSignal(name):Connect(function()apply(o)end)end
  apply(o)
 end
 watch(root);for _,o in ipairs(root:GetDescendants())do watch(o)end
 root.DescendantAdded:Connect(function(o)task.defer(watch,o)end)
 root:GetAttributeChangedSignal('AssistantDark'):Connect(function()for o in pairs(watched)do if o.Parent then apply(o)end end end)
 return M.Colors
end
return M
