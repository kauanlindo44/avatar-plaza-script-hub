-- 07G_HUB_UI | LocalScript | StarterPlayer > StarterPlayerScripts | V74 (SUBSTITUIR)
-- Navegação com nomes legíveis, grafite suave e atalhos de avatar agrupados.
local Players=game:GetService('Players');local Rep=game:GetService('ReplicatedStorage')
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local C=D.Colors
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local Fx=require(Rep:WaitForChild('07UI_SURFACE_EFFECTS'))
local pl=Players.LocalPlayer;local pg=pl:WaitForChild('PlayerGui');if not Rep:WaitForChild('PracaKit',40)then return end
for _,name in ipairs({'LimitedMarketHUD','AvatarShopLauncherGui'})do local old=pg:FindFirstChild(name);if old then old:Destroy()end end
local function screen(name,order)return D.New('ScreenGui',{Name=name,ResetOnSpawn=false,DisplayOrder=order,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)end
local hud=screen('LimitedMarketHUD',55);local launcher=screen('AvatarShopLauncherGui',56);local safe=Bounds.Bind(hud);Bounds.Bind(launcher)
local root=D.New('Frame',{Name='HudRoot',BackgroundTransparency=1,Size=UDim2.fromScale(1,1)},hud)
local top=D.New('Frame',{Name='Launcher',BackgroundTransparency=1,Size=UDim2.fromScale(1,1)},launcher)
local graphite=Color3.fromRGB(49,55,65);local accent=Color3.fromRGB(126,188,169);local all={}
local function nav(parent,name,label,icon,color)
 local b=D.Button(parent,label,{Name=name,BackgroundColor3=color or graphite,BackgroundTransparency=.04,TextSize=16,TextColor3=C.white,Corner=14})
 local i=icon and D.Icon(b,icon,{IconColor=C.white,Size=UDim2.fromOffset(24,24),Position=UDim2.fromOffset(10,14)})or nil
 b:SetAttribute('ActionLabel',label);all[#all+1]=b;Fx.Button(b,accent);return b,i
end
local catalog,ci=nav(top,'TopCatalog','Catálogo','catalog',Color3.fromRGB(56,83,91))
local games,gi=nav(top,'Games','Nossos jogos','games',Color3.fromRGB(65,87,73))
local stores,si=nav(top,'TopStores','Patrocinar + IA','people',Color3.fromRGB(80,71,98))
local community=nav(root,'Community','Comunidade');local looks=nav(root,'Looks','Meus looks');local avatar=nav(root,'AvatarTools','Avatar ▾')
local music,mi=nav(root,'TopMusic','Música','music');local cart,cai=nav(root,'Cart','Carrinho','cart')
local photo,pi=nav(root,'Photo','Fotos','avatarphoto');local cfg,cfi=nav(root,'Cfg','Ajustes','settings')
local sheet=D.Frame(root,{Name='AvatarShortcuts',BackgroundColor3=Color3.fromRGB(47,53,63),Visible=false,ZIndex=80});D.Stroke(sheet,accent,.45)
local title=D.Text(sheet,'Seu avatar',{TextSize=21,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=81})
local sheetClose=D.IconButton(sheet,'CloseAvatarShortcuts','close','Fechar atalhos',{ZIndex=83,BackgroundColor3=graphite})
local toolArea=D.Scroll(sheet,{Name='AvatarShortcutList',ZIndex=81,AutomaticCanvasSize=Enum.AutomaticSize.None})
local toolDefs={{'Avatar','Editar avatar','avatar','OpenRequest','Preview'},{'Loader','Carregar avatar','load','OpenRequest','Loader'},
 {'Emotes','Emotes','emote','OpenRequest','Emotes'},{'CurrentlyWearing','Vestindo agora','catalog','HudAction','Wearing'},
 {'NewAvatar','Novo avatar','plus','HudAction','Blank'},{'SaveRoblox','Salvar no Roblox','save','HudAction','SaveRoblox'},
 {'RestoreAvatar','Restaurar avatar','reset','HudAction','Reset'},{'Plus','Roblox Plus','roblox','native','Plus'}}
local tools={};local adapt;local settings;local smallPreference=false;local launching=false
local function toast(msg)
 local old=pg:FindFirstChild('ACP_HudToast');if old then old:Destroy()end
 local g=screen('ACP_HudToast',220);Bounds.Bind(g)
 local t=D.Text(g,msg,{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-100),Size=UDim2.fromOffset(math.min(440,root.AbsoluteSize.X-24),54),BackgroundTransparency=0,BackgroundColor3=graphite});D.Round(t)
 task.delay(3,function()if g.Parent then g:Destroy()end end)
end
settings=require(Rep:WaitForChild('07G1_HUB_SETTINGS')).Build(root,pg,function(v)smallPreference=v;if adapt then adapt()end end,toast,safe)
settings.OnVisibility=function()if adapt then adapt()end end
local function hidePanels()sheet.Visible=false;settings.Panel.Visible=false;if adapt then adapt()end end
local function dispatch(eventName,action)
 if launching or pl:GetAttribute('BC_MatchId')then return end;launching=true;hidePanels()
 task.spawn(function()
  for _=1,35 do local g=pg:FindFirstChild('AvatarShop08Gui');local e=g and g:FindFirstChild(eventName)
   if e and e:IsA('BindableEvent')then e:Fire(action);launching=false;return end;task.wait(.2)
  end
  launching=false;toast('O editor ainda está carregando. Tente novamente.')
 end)
end
local function feature(key)hidePanels();pg:SetAttribute(key,(tonumber(pg:GetAttribute(key))or 0)+1)end
catalog.Activated:Connect(function()dispatch('OpenRequest','Catalog')end);stores.Activated:Connect(function()dispatch('OpenRequest','Stores')end)
community.Activated:Connect(function()dispatch('OpenRequest','Community')end);looks.Activated:Connect(function()dispatch('OpenRequest','Looks')end)
music.Activated:Connect(function()feature('ACP_OpenMusicNonce')end);cart.Activated:Connect(function()dispatch('HudAction','Cart')end)
games.Activated:Connect(function()feature('ACP_OpenGamesNonce')end);photo.Activated:Connect(function()feature('ACP_OpenPhotoNonce')end)
avatar.Activated:Connect(function()settings.Panel.Visible=false;sheet.Visible=not sheet.Visible;adapt()end)
cfg.Activated:Connect(function()sheet.Visible=false;settings.Panel.Visible=not settings.Panel.Visible;adapt()end)
sheetClose.Activated:Connect(function()sheet.Visible=false;adapt()end)
local prompting=false
for _,def in ipairs(toolDefs)do
 local b=D.Button(toolArea,def[2],{Name=def[1],BackgroundColor3=graphite,TextSize=14,ZIndex=82});local icon=D.Icon(b,def[3],{Position=UDim2.fromOffset(10,15),Size=UDim2.fromOffset(22,22),ZIndex=83})
 local pad=b:FindFirstChildOfClass('UIPadding');if pad then pad.PaddingLeft=UDim.new(0,38)end
 tools[#tools+1]={button=b,icon=icon};b.Activated:Connect(function()
  if def[4]~='native'then dispatch(def[4],def[5]);return end
  if prompting then return end;prompting=true;hidePanels()
  local ok=pcall(function()game:GetService('MarketplaceService'):PromptRobloxSubscriptionPurchase(pl)end)
  task.delay(3,function()prompting=false end);if not ok then toast('O Roblox não abriu o plano. Tente no jogo publicado.')end
 end)
end
adapt=function()
 local il,it,ir,ib,w,h=safe.Read();local aw,ah=w-il-ir,h-it-ib;if aw<1 or ah<1 then return end
 local settingsOn=settings.Panel.Visible;top.Visible=not settingsOn
 for _,b in ipairs(all)do b.Visible=not settingsOn and(not sheet.Visible or b==avatar)end
 settings.Layout();local mainW=math.min(720,aw-16);local mainX=il+(aw-mainW)/2;local gap=8;local bw=(mainW-2*gap)/3
 for i,b in ipairs({catalog,games,stores})do
  Bounds.Rect(b,mainX+(i-1)*(bw+gap),it+6,bw,56);b.TextSize=bw<150 and 14 or 17
  local icon=({ci,gi,si})[i];local show=bw>=172;icon.Visible=show
  local pad=b:FindFirstChildOfClass('UIPadding');if pad then pad.PaddingLeft=UDim.new(0,show and 38 or 6)end
 end
 local secondaryW=math.min(490,aw-20);local sw=(secondaryW-16)/3;local sx=il+(aw-secondaryW)/2
 for i,b in ipairs({community,looks,avatar})do Bounds.Rect(b,sx+(i-1)*(sw+8),it+70,sw,46);b.TextSize=sw<125 and 14 or 15 end
 local narrow=aw<620;local utilityW=smallPreference and 100 or 110;local uy=narrow and it+126 or h-ib-62
 local ux=narrow and w-ir-utilityW*2-14 or il+(aw-(4*utilityW+24))/2
 for i,b in ipairs({photo,music,cart,cfg})do
  local x=ux+(narrow and(i-1)%2 or i-1)*(utilityW+6);local y=uy+(narrow and math.floor((i-1)/2)*54 or 0)
  Bounds.Rect(b,x,y,utilityW,48);b.TextSize=smallPreference and 12 or 14
  local icon=({pi,mi,cai,cfi})[i];Bounds.Rect(icon,8,14,20,20)
  local pad=b:FindFirstChildOfClass('UIPadding');if pad then pad.PaddingLeft=UDim.new(0,30)end
 end
 if sheet.Visible then
  local pw=math.min(540,aw-24);local cols=pw>=260 and 2 or 1;local rows=math.ceil(#tools/cols);local ph=58+rows*58+10
  local maxH=math.min(ah-24,ph);local rowH=52
  Bounds.Rect(sheet,il+(aw-pw)/2,it+math.max(8,(ah-maxH)/2),pw,maxH);Bounds.Rect(title,14,6,pw-82,44);Bounds.Rect(sheetClose,pw-58,4,48,48)
  Bounds.Rect(toolArea,8,58,pw-16,maxH-64);toolArea.CanvasSize=UDim2.fromOffset(0,rows*58)
  for i,t in ipairs(tools)do local cw=(pw-24-(cols-1)*8)/cols;Bounds.Rect(t.button,4+(i-1)%cols*(cw+8),math.floor((i-1)/cols)*(rowH+6),cw,rowH);Bounds.Rect(t.icon,10,(rowH-22)/2,22,22)end
 end
 if smallPreference then for _,b in ipairs({catalog,games,stores})do b.TextSize=14 end end
end
safe.Watch(adapt);root:GetPropertyChangedSignal('AbsoluteSize'):Connect(adapt);adapt()
print('[V74] HUD identificado, biblioteca de jogos própria e atalhos agrupados')
