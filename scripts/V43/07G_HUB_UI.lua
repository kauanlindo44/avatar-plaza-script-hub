-- 07G_HUB_UI | LocalScript | StarterPlayer > StarterPlayerScripts
-- V43: configuracoes coloridas, mundos locais e plano oficial direto.
local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local D=require(Rep:WaitForChild("07UI_DESIGN_SYSTEM"))
local C,N=D.Colors,D.New
local pl=Players.LocalPlayer;local pg=pl:WaitForChild("PlayerGui")
local kit=Rep:WaitForChild("PracaKit",40);if not kit then return end
for _,name in ipairs({"LimitedMarketHUD","AvatarShopLauncherGui"})do local old=pg:FindFirstChild(name);if old then old:Destroy()end end
local function screen(name,order)return N("ScreenGui",{Name=name,ResetOnSpawn=false,IgnoreGuiInset=false,DisplayOrder=order,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)end
local hud=screen("LimitedMarketHUD",55);local launcher=screen("AvatarShopLauncherGui",84)
local root=N("Frame",{Name="HudRoot",Size=UDim2.fromScale(1,1),BackgroundTransparency=1},hud)
local top=N("Frame",{Name="Launcher",Size=UDim2.fromScale(1,1),BackgroundTransparency=1},launcher)
local function floating(p,name,caption)
 return D.Button(p,caption,{Name=name,BackgroundColor3=C.bg,TextSize=19,BackgroundTransparency=.06,Corner=12})
end
local catalog=floating(top,"TopCatalog","Catálogo")
local stores=floating(top,"TopStores","Lojas UGC")
 local community=floating(root,"Community","Looks da\ncomunidade")
local loader=floating(root,"Loader","Carregar\navatar")
local looks=floating(root,"Looks","Meus\nlooks")
local emotes=floating(root,"Emotes","Emotes")
local music=D.IconButton(top,"TopMusic","music","Música",{BackgroundColor3=C.bg})
local cart=D.IconButton(top,"Cart","cart","Carrinho",{BackgroundColor3=C.bg})
local blank=D.IconButton(top,"Blank","trash","Limpar prévia",{BackgroundColor3=C.bg})
local avatar=D.IconButton(root,"Avatar","avatar","Editar avatar",{BackgroundColor3=C.bg})
local save=D.IconButton(root,"SaveRoblox","roblox","Salvar no Roblox",{BackgroundColor3=C.bg})
local reset=D.IconButton(root,"Reset","reset","Restaurar avatar",{BackgroundColor3=C.bg})
local games=D.IconButton(root,"Games","games","Jogos",{BackgroundColor3=C.bg})
local photo=D.IconButton(root,"Photo","camera","Modo foto",{BackgroundColor3=C.bg})
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
settings=require(Rep:WaitForChild("07G1_HUB_SETTINGS")).Build(root,pg,function(v)smallPreference=v;if adapt then adapt()end end,toast)
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
for b,action in pairs({[cart]="Cart",[blank]="Blank",[reset]="Reset",[save]="SaveRoblox"})do b.Activated:Connect(function()dispatch("HudAction",action)end)end
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
 local w,h=root.AbsoluteSize.X,root.AbsoluteSize.Y;if w<1 or h<1 then return end
 local compact=w<700 or h<380 or smallPreference
 local scale=math.clamp(math.min(w/1460,h/785),.72,1.1)
 top.Visible=not panel.Visible
 for _,b in ipairs({community,loader,looks,emotes,avatar,save,reset,games,photo,cfg,plus})do b.Visible=not panel.Visible end
 settings.Layout()
 local cw=compact and math.min(154,(w-32)/2)or math.floor(244*scale)
 local ch=compact and 48 or math.floor(62*scale);local gap=compact and 8 or 12
 local topY=w<700 and 46 or 4
 catalog.AnchorPoint=Vector2.new(1,0);catalog.Position=UDim2.new(.5,-gap/2,0,topY);catalog.Size=UDim2.fromOffset(cw,ch)
 stores.AnchorPoint=Vector2.zero;stores.Position=UDim2.new(.5,gap/2,0,topY);stores.Size=catalog.Size
 catalog.TextSize=compact and 22 or math.floor(32*scale);stores.TextSize=catalog.TextSize
 local sw=compact and math.clamp(w*.27,88,112)or math.floor(144*scale)
 local sh=compact and 48 or math.floor(62*scale)
 for _,b in ipairs({community,loader,looks,emotes})do b.Size=UDim2.fromOffset(sw,sh);b.TextSize=compact and 14 or math.floor((b==community and 18 or 21)*scale)end
 community.Position=UDim2.new(0,10,.47,-sh-5);loader.Position=UDim2.new(0,10,.47,5)
 looks.AnchorPoint=Vector2.new(1,0);emotes.AnchorPoint=Vector2.new(1,0)
 looks.Position=UDim2.new(1,-10,.47,-sh-5);emotes.Position=UDim2.new(1,-10,.47,5)
 local ts=compact and 36 or 38;local miniY=w>=700 and w<1100 and ch+12 or 4
 for i,b in ipairs({music,cart,blank})do b.AnchorPoint=Vector2.new(1,0);b.Size=UDim2.fromOffset(ts,ts);b.Position=UDim2.new(1,-10-(3-i)*(ts+8),0,miniY)end
 local bs=compact and 44 or math.floor(80*scale);local by=compact and -12 or -10
 for _,b in ipairs({avatar,save,reset,games,photo,cfg,plus})do b.Size=UDim2.fromOffset(bs,bs);b.AnchorPoint=Vector2.new(0,1)end
 if compact then
  save.Visible=false;reset.Visible=false
  local start=(w-(5*bs+4*8))/2
  for i,b in ipairs({avatar,games,plus,photo,cfg})do b.Position=UDim2.new(0,start+(i-1)*(bs+8),1,by)end
 else
  for i,b in ipairs({avatar,save,reset})do b.Position=UDim2.new(0,10+(i-1)*(bs+10),1,by)end
  for i,b in ipairs({games,photo,cfg})do b.Position=UDim2.new(1,-10-(4-i)*bs-(3-i)*10,1,by)end
  plus.AnchorPoint=Vector2.new(.5,1);plus.Position=UDim2.new(.5,0,1,by)
 end
end
root:GetPropertyChangedSignal("AbsoluteSize"):Connect(adapt)
task.defer(adapt)
print("AVATAR PLAZA V43: HUD pronta")
