-- 07G_HUB_UI | LocalScript | StarterPlayer > StarterPlayerScripts | V75 (SUBSTITUIR)
-- Trilhos compactos nas bordas; centro reservado ao personagem e ao mapa.
local Players=game:GetService('Players');local Rep=game:GetService('ReplicatedStorage')
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local B=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'))
local pl=Players.LocalPlayer;local pg=pl:WaitForChild('PlayerGui');if not Rep:WaitForChild('PracaKit',40)then return end
for _,n in ipairs({'LimitedMarketHUD','AvatarShopLauncherGui'})do local old=pg:FindFirstChild(n);if old then old:Destroy()end end
local function screen(name,order)return D.New('ScreenGui',{Name=name,ResetOnSpawn=false,DisplayOrder=order,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)end
local hud=screen('LimitedMarketHUD',55);local launcher=screen('AvatarShopLauncherGui',56);local safe=B.Bind(hud);B.Bind(launcher)
local root=D.New('Frame',{Name='HudRoot',BackgroundTransparency=1,Size=UDim2.fromScale(1,1)},hud)
local top=D.New('Frame',{Name='Launcher',BackgroundTransparency=1,Size=UDim2.fromScale(1,1)},launcher)
local ink=Color3.fromRGB(37,49,63);local light=Color3.fromRGB(242,247,250)
local colors={blue=Color3.fromRGB(49,87,119),green=Color3.fromRGB(48,100,81),violet=Color3.fromRGB(101,77,131),sand=Color3.fromRGB(239,210,155)}
local all={};local icons={}
local function nav(parent,name,label,icon,color)
 local b=D.Button(parent,label,{Name=name,BackgroundColor3=color or ink,TextColor3=color==colors.sand and ink or light,TextSize=14,Corner=12,TextWrapped=false})
 if icon then icons[b]=D.Icon(b,icon,{IconColor=b.TextColor3,Size=UDim2.fromOffset(18,18)})end
 b:SetAttribute('ActionLabel',label);all[#all+1]=b;return b
end
local catalog=nav(top,'TopCatalog','Catálogo','catalog',colors.blue)
local games=nav(root,'Games','Jogos','games',colors.green)
local community=nav(root,'Community','Comunidade',nil,colors.blue);local looks=nav(root,'Looks','Meus looks',nil,colors.green)
local ai=nav(root,'Assistant','IA de looks',nil,colors.violet);local stores=nav(root,'TopStores','Patrocinar',nil,colors.blue)
local avatar=nav(root,'AvatarTools','Avatar',nil,colors.sand)
local photo=nav(root,'Photo','Fotos','avatarphoto');local music=nav(root,'TopMusic','Música','music')
local cart=nav(root,'Cart','Carrinho','cart');local cfg=nav(root,'Cfg','Ajustes','settings')
local sheet=D.Frame(root,{Name='AvatarShortcuts',BackgroundColor3=Color3.fromRGB(234,240,246),Visible=false,ZIndex=80});D.Stroke(sheet,colors.blue,.6)
local title=D.Text(sheet,'Seu avatar',{TextColor3=ink,TextSize=20,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=81})
local sheetClose=D.IconButton(sheet,'CloseAvatarShortcuts','close','Fechar atalhos',{ZIndex=83,BackgroundColor3=colors.blue,TextColor3=light})
local area=D.Scroll(sheet,{Name='AvatarShortcutList',ZIndex=81,AutomaticCanvasSize=Enum.AutomaticSize.None})
local defs={{'Avatar','Editar avatar','OpenRequest','Preview'},{'Loader','Carregar avatar','OpenRequest','Loader'},
 {'Emotes','Emotes','OpenRequest','Emotes'},{'CurrentlyWearing','Vestindo agora','HudAction','Wearing'},
 {'NewAvatar','Novo avatar','HudAction','Blank'},{'SaveRoblox','Salvar no Roblox','HudAction','SaveRoblox'},
 {'RestoreAvatar','Restaurar avatar','HudAction','Reset'},{'Commands','Comandos','local','Commands'},{'Plus','Roblox Plus','native','Plus'}}
local tools={};local settings;local adapt;local small=false;local launching=false
local function notice(message)
 local old=pg:FindFirstChild('ACP_HudToast');if old then old:Destroy()end
 local g=screen('ACP_HudToast',220);B.Bind(g)
 local t=D.Text(g,tostring(message),{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-68),Size=UDim2.fromOffset(math.min(420,root.AbsoluteSize.X-24),48),BackgroundTransparency=0,BackgroundColor3=ink,TextColor3=light});D.Round(t)
 task.delay(3,function()if g.Parent then g:Destroy()end end)
end
settings=require(Rep:WaitForChild('07G1_HUB_SETTINGS')).Build(root,pg,function(v)small=v;if adapt then adapt()end end,notice,safe)
settings.OnVisibility=function()if adapt then adapt()end end
local commands=require(Rep:WaitForChild('07G9_COMMAND_PANEL')).Build(root,safe)
local function hidePanels()sheet.Visible=false;settings.Panel.Visible=false;commands.Close();if adapt then adapt()end end
local function dispatch(eventName,action)
 if launching or pl:GetAttribute('BC_MatchId')then return end;launching=true;hidePanels()
 task.spawn(function()
  for _=1,25 do local g=pg:FindFirstChild('AvatarShop08Gui');local e=g and g:FindFirstChild(eventName)
   if e and e:IsA('BindableEvent')then e:Fire(action);launching=false;return end;task.wait(.2)
  end
  launching=false;notice('O editor ainda está carregando. Tente novamente.')
 end)
end
local function feature(key)hidePanels();pg:SetAttribute(key,(tonumber(pg:GetAttribute(key))or 0)+1)end
catalog.Activated:Connect(function()dispatch('OpenRequest','Catalog')end)
games.Activated:Connect(function()feature('ACP_OpenGamesNonce')end);ai.Activated:Connect(function()feature('ACP_OpenAINonce')end)
stores.Activated:Connect(function()dispatch('OpenRequest','Stores')end);community.Activated:Connect(function()dispatch('OpenRequest','Community')end)
looks.Activated:Connect(function()dispatch('OpenRequest','Looks')end);cart.Activated:Connect(function()dispatch('HudAction','Cart')end)
photo.Activated:Connect(function()feature('ACP_OpenPhotoNonce')end);music.Activated:Connect(function()feature('ACP_OpenMusicNonce')end)
avatar.Activated:Connect(function()settings.Panel.Visible=false;commands.Close();sheet.Visible=not sheet.Visible;adapt()end)
cfg.Activated:Connect(function()sheet.Visible=false;commands.Close();settings.Panel.Visible=not settings.Panel.Visible;adapt()end)
sheetClose.Activated:Connect(function()sheet.Visible=false;adapt()end)
local prompting=false
for i,def in ipairs(defs)do
 local color=def[1]=='RestoreAvatar'and colors.sand or i%2==0 and Color3.fromRGB(202,223,235)or Color3.fromRGB(215,229,218)
 local b=D.Button(area,def[2],{Name=def[1],BackgroundColor3=color,TextColor3=ink,TextSize=14,ZIndex=82});tools[#tools+1]=b
 b.Activated:Connect(function()
  if def[3]=='local'then hidePanels();commands.Open();return end
  if def[3]~='native'then dispatch(def[3],def[4]);return end
  if prompting then return end;prompting=true;hidePanels()
  local ok=pcall(function()game:GetService('MarketplaceService'):PromptRobloxSubscriptionPurchase(pl)end)
  task.delay(3,function()prompting=false end);if not ok then notice('O Roblox não abriu o plano. Tente no jogo publicado.')end
 end)
end
adapt=function()
 local il,it,ir,ib,w,h=safe.Read();local aw,ah=w-il-ir,h-it-ib;if aw<1 or ah<1 then return end
 settings.Layout();commands.Layout();local panel=settings.Panel.Visible or sheet.Visible or commands.Root.Visible
 for _,b in ipairs(all)do b.Visible=not panel end
 local rail=math.min(small and 112 or 132,math.max(88,math.floor(aw*.21)));local step=50
 B.Rect(catalog,il+(aw-136)/2,it+4,136,44)
 for i,b in ipairs({games,community,looks})do B.Rect(b,il+8,it+58+(i-1)*step,rail,44)end
 for i,b in ipairs({ai,stores,avatar})do B.Rect(b,w-ir-rail-8,it+58+(i-1)*step,rail,44)end
 local utilityW=math.min(92,(aw-34)/4);local total=utilityW*4+18;local x=il+(aw-total)/2
 for i,b in ipairs({photo,music,cart,cfg})do B.Rect(b,x+(i-1)*(utilityW+6),h-ib-52,utilityW,44)end
 for b,icon in pairs(icons)do
  local show=b==catalog or b.AbsoluteSize.X>=86;icon.Visible=show
  B.Rect(icon,7,13,18,18);b.TextSize=b.AbsoluteSize.X<86 and 12 or 14
  local pad=b:FindFirstChildOfClass('UIPadding');if pad then pad.PaddingLeft=UDim.new(0,show and 28 or 4);pad.PaddingRight=UDim.new(0,4)end
 end
 if sheet.Visible then
  local pw=math.min(380,aw-24);local ph=math.min(ah-16,58+#tools*50);local sx=il+(aw-pw)/2;local sy=it+(ah-ph)/2
  B.Rect(sheet,sx,sy,pw,ph);B.Rect(title,14,4,pw-80,44);B.Rect(sheetClose,pw-54,4,48,48)
  B.Rect(area,8,56,pw-16,ph-64);area.CanvasSize=UDim2.fromOffset(0,#tools*50)
  for i,b in ipairs(tools)do B.Rect(b,4,(i-1)*50,pw-24,44)end
 end
end
pg:GetAttributeChangedSignal('ACP_OpenCommandsNonce'):Connect(function()hidePanels();commands.Open();adapt()end)
commands.OnClose=function()if adapt then adapt()end end
safe.Watch(adapt);root:GetPropertyChangedSignal('AbsoluteSize'):Connect(adapt);adapt()
print('[V75] HUD compacto: centro livre, IA direta e atalhos por função')
