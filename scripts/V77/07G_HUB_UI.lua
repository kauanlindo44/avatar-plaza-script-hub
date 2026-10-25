-- 07G_HUB_UI | LocalScript | StarterPlayer > StarterPlayerScripts | V77 (SUBSTITUIR)
-- Catálogo no alto, pares laterais e ferramentas nas bordas; funções extras no +.
local Players=game:GetService('Players');local Rep=game:GetService('ReplicatedStorage');local UIS=game:GetService('UserInputService')
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local B=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local Layout=require(Rep:WaitForChild('07G10_HUD_LAYOUT'))
local pl=Players.LocalPlayer;local pg=pl:WaitForChild('PlayerGui');if not Rep:WaitForChild('PracaKit',40)then return end
for _,n in ipairs({'LimitedMarketHUD','AvatarShopLauncherGui'})do local old=pg:FindFirstChild(n);if old then old:Destroy()end end
local function screen(name,order)return D.New('ScreenGui',{Name=name,ResetOnSpawn=false,DisplayOrder=order,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)end
local hud=screen('LimitedMarketHUD',55);local launcher=screen('AvatarShopLauncherGui',56);local safe=B.Bind(hud);B.Bind(launcher)
local root=D.New('Frame',{Name='HudRoot',BackgroundTransparency=1,Size=UDim2.fromScale(1,1)},hud)
local top=D.New('Frame',{Name='Launcher',BackgroundTransparency=1,Size=UDim2.fromScale(1,1)},launcher)
local ink=Color3.fromRGB(38,43,53);local text=Color3.fromRGB(247,248,251)
local tones={blue=Color3.fromRGB(57,80,107),green=Color3.fromRGB(57,91,76),sand=Color3.fromRGB(236,210,164),violet=Color3.fromRGB(94,77,120)}
local all={};local adapt;local small=false;local launching=false;local dead=false;local links={}
local function connect(signal,fn)local c=signal:Connect(fn);links[#links+1]=c;return c end
local function nav(name,label,icon,color,parent)
 local b=D.Button(parent or root,icon and''or label,{Name=name,BackgroundColor3=color or ink,TextColor3=color==tones.sand and ink or text,TextSize=13,Corner=8,TextWrapped=true})
 b:SetAttribute('ActionLabel',label);b:SetAttribute('HudReferenceRole',name);all[name]=b
 if icon then Layout.Symbol(D,b,icon)end;return b
end
local catalog=nav('TopCatalog','Catálogo',nil,ink,top)
local stores=nav('TopStores','Lojas',nil,ink,top)
local community=nav('Community','Roupas da\nComunidade',nil,tones.blue);local emotes=nav('Emotes','Emotes',nil,ink)
local looks=nav('Looks','Roupas\nSalvas',nil,tones.green);local loader=nav('Loader','Roupas do\nRoblox',nil,tones.blue)
local effects=nav('Effects','Efeitos da foto','sparkles');local body=nav('Body','Configurar corpo','avatar')
local wearing=nav('CurrentlyWearing','Vestindo agora','avatarphoto',tones.green);local restore=nav('RestoreAvatar','Restaurar avatar','reset',tones.sand)
local games=nav('Games','Nossos jogos','dice');local photo=nav('Photo','Photo Mode','camera')
local commandButton=nav('Commands','Comandos','commands');local cfg=nav('Cfg','Configurações','settings')
local more=nav('AvatarTools','Mais opções','menu')
local clean=nav('HideUI','Ocultar interface','hide')
local undo=nav('Undo','Desfazer','undo');local redo=nav('Redo','Refazer','redo')
local music=nav('TopMusic','Reprodutor de música','music');local cart=nav('Cart','Carrinho','cart')
local removal=nav('RemoveItems','Remover itens','trash')
local newAvatar=nav('NewAvatar','Criar novo avatar','avatar')
local saveRoblox=nav('SaveRoblox','Salvar para Roblox','roblox')
local sheet=D.Frame(root,{Name='AvatarShortcuts',BackgroundColor3=Color3.fromRGB(236,242,248),Visible=false,ZIndex=80})
local title=D.Text(sheet,'Mais ferramentas',{TextColor3=ink,TextSize=20,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=81})
local sheetClose=D.IconButton(sheet,'CloseAvatarShortcuts','close','Fechar ferramentas',{ZIndex=83,BackgroundColor3=tones.blue,TextColor3=text})
local area=D.Scroll(sheet,{Name='AvatarShortcutList',ZIndex=81,AutomaticCanvasSize=Enum.AutomaticSize.None})
local settings;local commands;local rows={}
local function notice(message)
 if dead then return end;local old=pg:FindFirstChild('ACP_HudToast');if old then old:Destroy()end
 local g=screen('ACP_HudToast',220);local s=B.Bind(g);local il,it,ir,ib,w,h=s.Read()
 local t=D.Text(g,tostring(message),{BackgroundTransparency=0,BackgroundColor3=ink,TextColor3=text,TextSize=13});D.Round(t)
 B.Rect(t,il+8,it+54,math.min(420,w-il-ir-16),48);task.delay(3,function()if g.Parent then g:Destroy()end end)
end
local function hidePanels()sheet.Visible=false;if settings then settings.Panel.Visible=false end;if commands then commands.Close()end;if adapt then adapt()end end
local function blocked()return dead or pl:GetAttribute('BC_MatchId')or pl:GetAttribute('ACP_InGameRoom')or pg:GetAttribute('ACP_TrucoActive')==true end
local function dispatch(eventName,action)
 if launching or blocked()then return end;launching=true;hidePanels()
 task.spawn(function()
  for _=1,25 do
   if dead then return end;local g=pg:FindFirstChild('AvatarShop08Gui');local e=g and g:FindFirstChild(eventName)
   if e and e:IsA('BindableEvent')then e:Fire(action);launching=false;return end;task.wait(.2)
  end
  launching=false;notice('O editor ainda está carregando. Tente novamente.')
 end)
end
local featureAt={}
local function feature(key)
 if blocked()or os.clock()-(featureAt[key]or-10)<.45 then return end
 featureAt[key]=os.clock();hidePanels();pg:SetAttribute(key,(tonumber(pg:GetAttribute(key))or 0)+1)
end
settings=require(Rep:WaitForChild('07G1_HUB_SETTINGS')).Build(root,pg,function(v)small=v;if adapt then adapt()end end,notice,safe)
commands=require(Rep:WaitForChild('07G9_COMMAND_PANEL')).Build(root,safe)
settings.OnVisibility=function()if adapt then adapt()end end;commands.OnClose=function()if adapt then adapt()end end
local avatarDefs={
 {'Assistant','IA de looks','feature','ACP_OpenAINonce',tones.violet},
 {'SponsorShortcut','Patrocinar itens','OpenRequest','Stores',tones.blue},
 {'Avatar','Editar avatar','OpenRequest','Preview',tones.green},
 {'BodyShortcut','Configurar corpo','HudAction','Body',tones.green},
 {'CommunityShortcut','Roupas da comunidade','OpenRequest','Community',tones.blue},
 {'EmotesShortcut','Emotes','OpenRequest','Emotes',tones.violet},
 {'LooksShortcut','Meus looks','OpenRequest','Looks',tones.green},
 {'LoaderShortcut','Carregar avatar','OpenRequest','Loader',tones.blue},
 {'WearingShortcut','Vestindo agora','HudAction','Wearing',tones.green},
 {'RestoreShortcut','Restaurar avatar','HudAction','Reset',tones.blue},
 {'EffectsShortcut','Efeitos da foto','menu','Effects',tones.violet},
 {'Cart','Carrinho','HudAction','Cart',tones.blue},
 {'TopMusic','Música','feature','ACP_OpenMusicNonce',tones.violet},
 {'NewAvatar','Novo avatar','HudAction','Blank',tones.green},
 {'SaveRoblox','Salvar no Roblox','HudAction','SaveRoblox',tones.blue},
 {'Plus','Roblox Plus','OpenRequest','Plus',tones.violet},
 {'FreeCamera','Câmera livre','HudAction','FreeCamera',tones.green},
 {'Purchases','Minhas compras','HudAction','Purchases',tones.blue}}
local menuDefs={
 {'Purchases','Histórico de compras','HudAction','Purchases',ink},
 {'FreeCamera','Câmera livre','HudAction','FreeCamera',ink},
 {'Assistant','IA de looks','feature','ACP_OpenAINonce',ink},
 {'Games','Nossos jogos','feature','ACP_OpenGamesNonce',ink},
 {'Commands','Comandos de chat','commands','Commands',ink},
 {'MoreAvatar','Ferramentas do avatar','menu','Avatar',ink}}
local page='More'
local function openMenu(which)
 if blocked()then return end;local on=sheet.Visible and page==which;hidePanels();if on then return end;page=which
 for _,o in ipairs(area:GetChildren())do if o:IsA('GuiObject')then o:Destroy()end end;rows={}
 title.Text=which=='Effects'and'Efeitos da foto'or which=='More'and'Mais opções'or'Ferramentas do avatar'
 local defs=which=='Effects'and{{'ClonePhoto','Clonar na foto','feature','ACP_PhotoCloneNonce',tones.blue},{'HidePhotoHead','Cabeça: mostrar/ocultar','effect','Head',tones.green},{'HidePhotoBody','Corpo: mostrar/ocultar','effect','Body',tones.violet}}or which=='More'and menuDefs or avatarDefs
 for _,def in ipairs(defs)do
  local b=D.Button(area,def[2],{Name=def[1],BackgroundColor3=def[5],TextColor3=text,TextSize=14,ZIndex=82});rows[#rows+1]=b
  b.Activated:Connect(function()
   if def[3]=='menu'then openMenu(def[4])
   elseif def[3]=='commands'then hidePanels();commands.Open();adapt()
   elseif def[3]=='feature'then feature(def[4])
   elseif def[3]=='effect'then pg:SetAttribute('ACP_PhotoEffect',def[4]);feature('ACP_PhotoEffectNonce')
   else dispatch(def[3],def[4])end
  end)
 end
 sheet.Visible=true;adapt()
end
connect(catalog.Activated,function()dispatch('OpenRequest','Catalog')end)
connect(stores.Activated,function()dispatch('OpenRequest','Stores')end)
for _,def in ipairs({{community,'Community'},{emotes,'Emotes'},{looks,'Looks'},{loader,'Loader'}})do connect(def[1].Activated,function()dispatch('OpenRequest',def[2])end)end
connect(clean.Activated,function()dispatch('HudAction','CleanUI')end)
connect(undo.Activated,function()dispatch('HudAction','Undo')end);connect(redo.Activated,function()dispatch('HudAction','Redo')end)
connect(music.Activated,function()feature('ACP_OpenMusicNonce')end);connect(cart.Activated,function()dispatch('HudAction','Cart')end)
connect(removal.Activated,function()dispatch('HudAction','RemoveItems')end)
connect(newAvatar.Activated,function()dispatch('HudAction','Blank')end);connect(saveRoblox.Activated,function()dispatch('HudAction','SaveRoblox')end)
connect(body.Activated,function()dispatch('HudAction','Body')end);connect(wearing.Activated,function()dispatch('HudAction','Wearing')end)
connect(restore.Activated,function()dispatch('HudAction','Reset')end);connect(photo.Activated,function()feature('ACP_OpenPhotoNonce')end)
connect(games.Activated,function()feature('ACP_OpenGamesNonce')end);connect(more.Activated,function()openMenu('More')end)
connect(effects.Activated,function()openMenu('Effects')end);connect(commandButton.Activated,function()hidePanels();commands.Open();adapt()end)
connect(cfg.Activated,function()local show=not settings.Panel.Visible;hidePanels();settings.Panel.Visible=show;adapt()end)
connect(sheetClose.Activated,function()sheet.Visible=false;adapt()end)
adapt=function()
 if dead then return end;local il,it,ir,ib,w,h=safe.Read();local aw,ah=w-il-ir,h-it-ib;if aw<1 or ah<1 then return end
 settings.Layout();commands.Layout();local panel=sheet.Visible and page~='More'or settings.Panel.Visible or commands.Root.Visible
 local rects=Layout.Resolve(il,it,ir,ib,w,h,UIS.TouchEnabled==true,small,safe.Topbar())
 for name,b in pairs(all)do local r=rects[name];B.Rect(b,table.unpack(r));b.Visible=not panel and not rects.Hidden[name]
  if name=='Community'then b.TextSize=b.AbsoluteSize.X<110 and 11 or 13 elseif b.Text~=''then b.TextSize=13 end
 end
 if sheet.Visible then
  local dropdown=page=='More'
  local pw=math.min(dropdown and 208 or 324,aw-16)
  local header=dropdown and 0 or 50;local ph=math.min(ah-12,header+8+#rows*48)
  local anchor=rects.AvatarTools
  local x=dropdown and math.clamp(anchor[1],il+6,w-ir-pw-6)or il+(aw-pw)/2
  local y=dropdown and math.clamp(anchor[2]+anchor[4]+4,it+4,h-ib-ph-6)or it+(ah-ph)/2
  B.Rect(sheet,x,y,pw,ph);sheet.BackgroundColor3=dropdown and ink or Color3.fromRGB(236,242,248)
  title.Visible=not dropdown;sheetClose.Visible=not dropdown
  B.Rect(title,12,4,pw-76,44);B.Rect(sheetClose,pw-54,2,48,48)
  B.Rect(area,4,header+4,pw-8,ph-header-8);area.CanvasSize=UDim2.fromOffset(0,#rows*48)
  for i,b in ipairs(rows)do B.Rect(b,0,(i-1)*48,pw-8,44);b.TextSize=14 end
 end
end
connect(pg:GetAttributeChangedSignal('ACP_OpenCommandsNonce'),function()hidePanels();commands.Open();adapt()end)
connect(UIS.InputBegan,function(i,gp)if not gp and(i.KeyCode==Enum.KeyCode.Escape or i.KeyCode==Enum.KeyCode.ButtonB)then hidePanels()end end)
connect(root:GetPropertyChangedSignal('AbsoluteSize'),function()adapt()end)
hud.Destroying:Connect(function()dead=true;for _,c in ipairs(links)do c:Disconnect()end;commands.Close();if launcher.Parent then launcher:Destroy()end end)
safe.Watch(adapt);adapt();print('[V77] HUD: referência da gameplay e ações do avatar nas bordas')
