-- 07G_HUB_UI | LocalScript | StarterPlayer > StarterPlayerScripts | V69 (SUBSTITUIR)
-- V60 (SUBSTITUIR): uma área segura comum, atalhos sem sobreposição e destaques grátis.
local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local D=require(Rep:WaitForChild("07UI_DESIGN_SYSTEM"))
local C,N=D.Colors,D.New;local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local Fx=require(Rep:WaitForChild('07UI_SURFACE_EFFECTS'))
local pl=Players.LocalPlayer;local pg=pl:WaitForChild("PlayerGui")
local kit=Rep:WaitForChild("PracaKit",40);if not kit then return end
for _,name in ipairs({"LimitedMarketHUD","AvatarShopLauncherGui"})do local old=pg:FindFirstChild(name);if old then old:Destroy()end end
local function screen(name,order)return N("ScreenGui",{Name=name,ResetOnSpawn=false,IgnoreGuiInset=false,DisplayOrder=order,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)end
local hud=screen("LimitedMarketHUD",55);local launcher=screen("AvatarShopLauncherGui",56);local safe=Bounds.Bind(hud);Bounds.Bind(launcher)
local root=N("Frame",{Name="HudRoot",Size=UDim2.fromScale(1,1),BackgroundTransparency=1},hud)
local top=N("Frame",{Name="Launcher",Size=UDim2.fromScale(1,1),BackgroundTransparency=1},launcher)
local function floating(p,name,caption)
 local b=D.Button(p,caption,{Name=name,BackgroundColor3=C.bg,TextSize=19,BackgroundTransparency=.06,Corner=12});Fx.Button(b,C.orange);return b
end
local catalog=floating(top,"TopCatalog","Catálogo")
local stores=floating(top,"TopStores","Patrocinar + IA")
 local community=floating(root,"Community","Looks da\ncomunidade")
local loader=floating(root,"Loader","Carregar\navatar")
local looks=floating(root,"Looks","Meus\nlooks")
local emotes=floating(root,"Emotes","Emotes")
local music=D.IconButton(top,"TopMusic","music","Música",{BackgroundColor3=C.bg})
local cart=D.IconButton(top,"Cart","cart","Carrinho",{BackgroundColor3=C.bg})
local avatar=D.IconButton(root,"Avatar","avatar","Editar avatar",{BackgroundColor3=C.bg})
local save=D.IconButton(root,"SaveRoblox","roblox","Salvar no Roblox",{BackgroundColor3=C.bg})
local games=D.IconButton(root,"Games","games","Jogos",{BackgroundColor3=C.bg})
local photo=D.IconButton(root,"Photo","avatarphoto","Estúdio de avatar e fotos",{BackgroundColor3=C.bg})
local cfg=D.IconButton(root,"Cfg","settings","Configurações",{BackgroundColor3=C.bg})
local plus=D.IconButton(root,"Plus","plus","Plus",{BackgroundColor3=C.bg})
local panel,settings
local smallPreference=false;local adapt
local function toast(msg)
 local old=pg:FindFirstChild("ACP_HudToast");if old then old:Destroy()end
 local g=screen("ACP_HudToast",180)
 local t=D.Text(g,msg,{AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-82),Size=UDim2.new(0,math.min(420,root.AbsoluteSize.X-24),0,44),BackgroundColor3=C.panel,BackgroundTransparency=0})
 D.Round(t);task.delay(3,function()if g.Parent then g:Destroy()end end)
end
settings=require(Rep:WaitForChild("07G1_HUB_SETTINGS")).Build(root,pg,function(v)smallPreference=v;if adapt then adapt()end end,toast,safe)
panel=settings.Panel;settings.OnVisibility=function()if adapt then adapt()end end
local launching=false
local function dispatch(eventName,action)
 if launching then return end;launching=true;panel.Visible=false;adapt()
 task.spawn(function()
  for _=1,35 do
   local g=pg:FindFirstChild("AvatarShop08Gui");local e=g and g:FindFirstChild(eventName)
   if e and e:IsA("BindableEvent")then e:Fire(action);launching=false;return end
   task.wait(.2)
  end
  launching=false;toast("O editor está carregando. Tente novamente.")
 end)
end
for b,mode in pairs({[catalog]="Catalog",[stores]="Stores",[community]="Community",[loader]="Loader",[looks]="Looks",[emotes]="Emotes",[avatar]="Preview"})do
 b.Activated:Connect(function()dispatch("OpenRequest",mode)end)
end
for b,action in pairs({[cart]="Cart",[save]="SaveRoblox"})do b.Activated:Connect(function()dispatch("HudAction",action)end)end
local function feature(key)panel.Visible=false;adapt();pg:SetAttribute(key,(tonumber(pg:GetAttribute(key))or 0)+1)end
music.Activated:Connect(function()feature("ACP_OpenMusicNonce")end)
games.Activated:Connect(function()feature("ACP_OpenGamesNonce")end)
photo.Activated:Connect(function()feature("ACP_OpenPhotoNonce")end)
local prompting=false
plus.Activated:Connect(function()
 if prompting then return end;prompting=true;panel.Visible=false;adapt()
 local ok=pcall(function()game:GetService("MarketplaceService"):PromptRobloxSubscriptionPurchase(pl)end)
 task.delay(3,function()prompting=false end)
 if not ok then toast("O Roblox não abriu o plano. Tente no jogo publicado.")end
end)
cfg.Activated:Connect(function()panel.Visible=not panel.Visible end)
adapt=function()
 local il,it,ir,ib,w,h=safe.Read();local aw,ah=w-il-ir,h-it-ib;if aw<1 or ah<1 then return end
 local compact=aw<700 or ah<420 or smallPreference;local short=ah<280
 top.Visible=not panel.Visible
 for _,b in ipairs({community,loader,looks,emotes,avatar,save,games,photo,cfg,plus})do b.Visible=not panel.Visible end
 settings.Layout()
 local topH=48;local sideW=math.clamp(aw*.15,100,120);local gap=8
 local reserve=short and 104 or 0;local cw=math.min(compact and 148 or 180,(aw-reserve-20)/2)
 local x=il+6+(aw-reserve-12-(2*cw+gap))/2
 Bounds.Rect(catalog,x,it+4,cw,topH);Bounds.Rect(stores,x+cw+gap,it+4,cw,topH)
 catalog.TextSize=cw<150 and 15 or 18;stores.TextSize=catalog.TextSize
 local miniY=it+(short and 4 or 54)
 Bounds.Rect(music,w-ir-102,miniY,44,44);Bounds.Rect(cart,w-ir-52,miniY,44,44)
 if short then
  local sw=(aw-30)/4
  for i,b in ipairs({community,loader,looks,emotes})do Bounds.Rect(b,il+6+(i-1)*(sw+6),it+54,sw,44);b.TextSize=14 end
 else
  Bounds.Rect(community,il+6,it+108,sideW,44);Bounds.Rect(loader,il+6,it+158,sideW,44)
  Bounds.Rect(looks,w-ir-sideW-6,it+108,sideW,44);Bounds.Rect(emotes,w-ir-sideW-6,it+158,sideW,44)
  for _,b in ipairs({community,loader,looks,emotes})do b.TextSize=14 end
 end
 local row=aw<380 and{avatar,games,plus,photo,cfg}or{avatar,save,games,plus,photo,cfg}
 local size=48;local bgap=math.min(8,math.max(2,(aw-12-#row*size)/math.max(1,#row-1)))
 local bx=il+(aw-(#row*size+(#row-1)*bgap))/2
 if aw<380 then save.Visible=false end
 for i,b in ipairs(row)do Bounds.Rect(b,bx+(i-1)*(size+bgap),h-ib-size-6,size,size)end
end
safe.Watch(adapt)
root:GetPropertyChangedSignal('AbsoluteSize'):Connect(adapt)
print('[V65] HUD compacto; Restaurar permanece dentro do editor com confirmação')
