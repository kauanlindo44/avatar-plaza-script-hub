-- 07K9_CARD_INVENTORY_UI | ModuleScript | ReplicatedStorage | V55
-- Compra direta, três cartas na prévia e até 12 visuais salvos. Sem caixas.
local Rep=game:GetService('ReplicatedStorage')
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local C=D.Colors
local Catalog=require(Rep:WaitForChild('07K6_CARD_CATALOG'))
local Cards=require(Rep:WaitForChild('07K7_CARD_STYLES'))
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'))
local Market=game:GetService('MarketplaceService')
local M={}
function M.Build(gui,call,toast)
 local U={Tab='Loja',Style='Classic',Page=1,Capacity=6,Selected=nil};local N=D.New;local R=Bounds.Rect;local safe=Bounds.Bind(gui)
 local entries,slots,tabs={},{},{};local prices={};local storeToken=0;local busy=false;local refresh,details
 local function clear(p)for _,v in ipairs(p:GetChildren())do if v:IsA('GuiObject')then v:Destroy()end end end
 U.Root=N('Frame',{Name='CardInventory',Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(12,20,23),Visible=false},gui)
 N('UIGradient',{Color=ColorSequence.new(Color3.fromRGB(12,20,23),Color3.fromRGB(23,38,34)),Rotation=100},U.Root)
 U.Title=D.Text(U.Root,'Baralhos',{Font=Enum.Font.GothamBold,TextSize=23,TextXAlignment=Enum.TextXAlignment.Left})
 U.Coins=D.Text(U.Root,'',{TextColor3=C.yellow,TextSize=16,TextXAlignment=Enum.TextXAlignment.Right})
 U.Close=D.IconButton(U.Root,'CloseInventory','close','Fechar baralhos',{ZIndex=80})
 U.Tabs=N('Frame',{BackgroundTransparency=1},U.Root)
 for i,key in ipairs({'Loja','Visuais','Salvos','Ateliê'})do local b=D.Button(U.Tabs,({Loja='Loja',Visuais='Meus visuais',Salvos='Salvos',['Ateliê']='Ateliê'})[key],{TextSize=13});tabs[i]=b;b:SetAttribute('TabKey',key)
  b.Activated:Connect(function()U.Tab=key;U.Page=1;U.Selected=nil;U.Render()end)
 end
 U.Preview=D.Frame(U.Root,{Name='ThreeCardPreview',BackgroundColor3=C.panel})
 U.PreviewName=D.Text(U.Preview,'',{TextSize=20,Font=Enum.Font.GothamBold,AutoLocalize=false})
 U.CardHost=N('Frame',{BackgroundTransparency=1,ClipsDescendants=true},U.Preview);U.SampleCards={}
 U.Note=D.Text(U.Preview,'',{TextSize=12,TextColor3=C.muted})
 U.Flip=D.Button(U.Preview,'Ver verso',{TextSize=12});U.Keep=D.Button(U.Preview,'Guardar visual',{TextSize=12})
 U.CoinBuy=D.Button(U.Preview,'',{BackgroundColor3=C.green,TextColor3=C.bg,TextSize=12})
 U.RobuxBuy=D.Button(U.Preview,'',{TextSize=12});U.Delete=D.Button(U.Preview,'Excluir salvo',{TextSize=12,TextColor3=C.red,Visible=false})
 U.List=N('Frame',{Name='DirectStyles',BackgroundTransparency=1,ClipsDescendants=true},U.Root)
 U.Pager=N('Frame',{BackgroundTransparency=1},U.Root);U.Previous=D.Button(U.Pager,'‹',{TextSize=26});U.Next=D.Button(U.Pager,'›',{TextSize=26});U.PageLabel=D.Text(U.Pager,'',{TextColor3=C.muted})
 local function prompt(kind,key)local d,e=call('prompt',{kind=kind,key=key});if not d then toast(e)end end
 refresh=function()local d,e=call('inventory');if d then U.Data=d;U.Render()else toast(e)end end
 local atelier=require(Rep:WaitForChild('07K16_ATELIER_UI')).Build(U.Root,call,toast,prompt,refresh);U.Atelier=atelier
 local function transact(action,data,message)
  if busy then return end;busy=true;local d,e=call(action,data);busy=false;toast(d and message or e);if d then refresh()end
 end
 function U.SetPreview(style,custom)
  U.Style=style;clear(U.CardHost);U.SampleCards={}
  for i,c in ipairs({{rank='A',suit='S'},{rank='K',suit='H'},{rank='7',suit='C'}})do
   U.SampleCards[i]=Cards.Render(U.CardHost,not U.Back and c or nil,style,{Name='Sample'..i},custom)
  end
  U.PreviewName.Text=Catalog.Name(style);U.Flip.Text=U.Back and'Ver frente'or'Ver verso'
 end
 local function product(e)local pass=Catalog.PassFor(e.key);return pass and U.Store and U.Store.passes[tostring(pass)]or U.Store and U.Store.products[e.key],pass end
 details=function(e)
  U.Selected=e;U.SetPreview(e.key,e.custom or U.Data.custom);U.CoinBuy.Visible=true;U.RobuxBuy.Visible=U.Tab=='Loja';U.Delete.Visible=U.Tab=='Salvos';U.Keep.Visible=U.Tab~='Salvos'
  local owned=e.key=='Custom'and U.Data.ateliers or U.Data.owned[e.key]
  D.SetEnabled(U.Keep,owned==true)
  if U.Tab=='Salvos'then U.CoinBuy.Text='Equipar salvo';U.RobuxBuy.Visible=false;U.Note.Text='Seu enquadramento guardado · frente e verso';D.SetEnabled(U.CoinBuy,true)
  elseif U.Tab=='Visuais'then U.Note.Text=Catalog.Designs[e.key]or'Imagem personalizada';U.CoinBuy.Text=U.Data.equipped==e.key and'Equipado'or'Equipar';D.SetEnabled(U.CoinBuy,U.Data.equipped~=e.key)
  else
   local style=Catalog.Styles[e.key];local credit=style and(U.Data.boxes[style.collection]or 0)>0 and not owned
   U.Note.Text=(Catalog.Designs[e.key]or'')..(e.key=='Salem'and' • até 02/11/2026 UTC • permanece após adquirir'or' · apenas visual')
   U.CoinBuy.Text=owned and'Equipar'or credit and'Resgatar crédito'or(style.coins..' moedas');D.SetEnabled(U.CoinBuy,owned or credit or U.Data.coins>=style.coins)
   local p=product(e);U.RobuxBuy.Text=owned and'Já possui'or p and p.sale and(p.price..' Robux')or p and p.pending and'Consultando preço…'or'Robux indisponível'
   D.SetEnabled(U.RobuxBuy,p and p.sale and not owned and not credit)
  end
  U.Layout()
 end
 U.Flip.Activated:Connect(function()U.Back=not U.Back;if U.Selected then details(U.Selected)end end)
 U.Keep.Activated:Connect(function()if U.Selected then transact('savepreset',{style=U.Selected.key},'Visual guardado em Salvos.')end end)
 U.Delete.Activated:Connect(function()if U.Selected then transact('deletepreset',{id=U.Selected.id},'Visual salvo removido.')end end)
 U.CoinBuy.Activated:Connect(function()
  local e=U.Selected;if not e then return end
  if U.Tab=='Salvos'then transact('usepreset',{id=e.id},'Visual salvo equipado.')
  elseif U.Data.owned[e.key]or e.key=='Custom'and U.Data.ateliers then transact('equip',{style=e.key},'Visual equipado.')
  else local style=Catalog.Styles[e.key];if style and(U.Data.boxes[style.collection]or 0)>0 then transact('redeemcredit',{key=style.collection,style=e.key},'Crédito antigo convertido neste visual.')
   else transact('buycoins',{kind='style',key=e.key,quantity=1},'Visual comprado e disponível em Meus visuais.')end
  end
 end)
 U.RobuxBuy.Activated:Connect(function()local e=U.Selected;if e then local _,pass=product(e);prompt(pass and'pass'or'product',pass or e.key)end end)
 local function collect()
  entries={}
  if U.Tab=='Salvos'then for _,p in ipairs(U.Data.presets or{})do entries[#entries+1]={key=p.style,id=p.id,custom=p.custom}end;return end
  for _,key in ipairs({'Classic','Salem','Onyx','Vesper','Hex','Regent','Aurum','Valor','Zenith','Aether','Nova'})do
   if U.Tab=='Loja'and key~='Classic'and Catalog.Available(key)or U.Tab=='Visuais'and U.Data.owned[key]then entries[#entries+1]={key=key}end
  end
  if U.Tab=='Visuais'and U.Data.ateliers then entries[#entries+1]={key='Custom'}end
 end
 function U.PaintPage()
  U.Layout();clear(U.List);slots={};local pages=math.max(1,math.ceil(#entries/U.Capacity));U.Page=math.clamp(U.Page,1,pages)
  U.PageLabel.Text=U.Page..' / '..pages;D.SetEnabled(U.Previous,U.Page>1);D.SetEnabled(U.Next,U.Page<pages)
  if #entries==0 then D.Text(U.List,U.Tab=='Salvos'and'Guarde os visuais de que gostou para equipar depois.'or'Seus visuais aparecerão aqui.',{Size=UDim2.fromScale(1,1),TextColor3=C.muted})end
  for j=(U.Page-1)*U.Capacity+1,math.min(#entries,U.Page*U.Capacity)do local e=entries[j]
   local b=D.Button(U.List,'',{Name='Style_'..e.key,BackgroundColor3=C.panel});local pad=b:FindFirstChildOfClass('UIPadding');if pad then pad:Destroy()end
   local host=N('Frame',{BackgroundTransparency=1},b);Cards.Render(host,{rank='A',suit='H'},e.key,{Size=UDim2.fromScale(1,1)},e.custom or U.Data.custom)
   local text=D.Text(b,Catalog.Name(e.key),{Font=Enum.Font.GothamBold,TextSize=13,AutoLocalize=false,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd})
   local stroke=b:FindFirstChildOfClass('UIStroke');if stroke then stroke.Transparency=U.Selected and U.Selected==e and .1 or .7 end
   slots[#slots+1]={root=b,host=host,text=text};b.Activated:Connect(function()details(e)end)
  end;U.Layout()
 end
 U.Previous.Activated:Connect(function()U.Page=U.Page-1;U.PaintPage()end);U.Next.Activated:Connect(function()U.Page=U.Page+1;U.PaintPage()end)
 function U.AcceptData(data)U.Data=data end
 function U.Render()
  if not U.Data then return end;U.Coins.Text='◉ '..U.Data.coins
  local edit=U.Tab=='Ateliê';atelier.Root.Visible=edit;U.List.Visible=not edit;U.Preview.Visible=not edit;U.Pager.Visible=not edit
  for _,b in ipairs(tabs)do b.BackgroundColor3=b:GetAttribute('TabKey')==U.Tab and C.green or C.card end
  if edit then atelier.SetData(U.Data,U.Store)
  else
   collect();local pick=entries[1]
   if U.Selected then for _,e in ipairs(entries)do if U.Selected.id and e.id==U.Selected.id or not U.Selected.id and e.key==U.Selected.key then pick=e;break end end end
   if pick then details(pick)else U.Selected=nil;clear(U.CardHost);U.PreviewName.Text='Nenhum visual salvo';for _,b in ipairs({U.CoinBuy,U.RobuxBuy,U.Keep,U.Flip,U.Delete})do b.Visible=false end end
   U.PaintPage()
  end;U.Layout()
 end
 function U.Layout()
  local il,it,ir,ib,w,h=safe.Read();local aw=w-il-ir;local top=safe.Heading(U.Title,U.Close);local bar=safe.Topbar()
  R(U.Title,il+8,it+4,aw-200,48);R(U.Coins,w-ir-186,it+4,124,48)
  if aw>=520 and bar.Right-bar.X>=320 and bar.Bottom-bar.Y>=48 then R(U.Title,bar.X+6,bar.Y+4,bar.Right-bar.X-206,44);R(U.Coins,bar.Right-188,bar.Y+4,122,44);R(U.Close,bar.Right-56,bar.Y+4,48,48);top=it+4 end
  R(U.Tabs,il+8,top,aw-16,44);for i,b in ipairs(tabs)do R(b,(i-1)*(aw-12)/4,0,(aw-28)/4,44)end
  local y=top+50;local ah=h-ib-y-6;local wide=aw>=520;local pw=wide and math.floor(aw*.48)or aw-16
  local ph=wide and ah or math.min(260,ah*.46);local listY=wide and y or y+ph+6;local lx=wide and il+pw+16 or il+8;local lw=wide and aw-pw-24 or aw-16;local lh=wide and ah-48 or ah-ph-54
  R(U.Preview,il+8,y,pw,ph);R(U.List,lx,listY,lw,math.max(1,lh));R(U.Pager,lx,listY+lh+4,lw,44)
  R(U.Previous,0,0,44,44);R(U.Next,lw-44,0,44,44);R(U.PageLabel,50,0,lw-100,44)
  local compact=ph<240;local titleH=compact and 26 or 34;local noteH=compact and 24 or 40;local actionsH=100
  R(U.PreviewName,6,4,pw-12,titleH);R(U.Note,6,ph-actionsH-noteH-2,pw-12,noteH);U.Note.TextSize=11
  local ch=math.max(26,ph-titleH-noteH-actionsH-12);R(U.CardHost,6,titleH+8,pw-12,ch)
  local cw=math.min((pw-28)/3,ch*.70);local cardH=cw/.70;local total=cw*3+12
  for i,c in ipairs(U.SampleCards)do R(c,(pw-12-total)/2+(i-1)*(cw+6),(ch-cardH)/2,cw,cardH)end
  R(U.Flip,6,ph-96,(pw-18)/2,44);R(U.Keep,(pw+6)/2,ph-96,(pw-18)/2,44);R(U.Delete,(pw+6)/2,ph-96,(pw-18)/2,44)
  R(U.CoinBuy,6,ph-46,U.RobuxBuy.Visible and(pw-18)/2 or pw-12,44);R(U.RobuxBuy,(pw+6)/2,ph-46,(pw-18)/2,44)
  if wide and ph<300 then
   local nh=24;local bh=44;local previewH=math.max(40,ph-titleH-nh-bh-16)
   R(U.Note,6,ph-bh-nh-4,pw-12,nh);U.Note.TextSize=11
   if U.Style=='Salem'then U.Note.Text='Halloween • venda até 02/11/2026 UTC'end
   R(U.CardHost,6,titleH+6,pw-12,previewH)
   local cardW=math.min((pw-28)/3,previewH*.70);local cardH=cardW/.70;local allW=cardW*3+12
   for i,c in ipairs(U.SampleCards)do R(c,(pw-12-allW)/2+(i-1)*(cardW+6),(previewH-cardH)/2,cardW,cardH)end
   local actions={U.Flip};if U.Keep.Visible then actions[#actions+1]=U.Keep elseif U.Delete.Visible then actions[#actions+1]=U.Delete end
   actions[#actions+1]=U.CoinBuy;if U.RobuxBuy.Visible then actions[#actions+1]=U.RobuxBuy end
   local bw=(pw-12-(#actions-1)*4)/#actions
   for i,b in ipairs(actions)do R(b,6+(i-1)*(bw+4),ph-48,bw,44);b.TextSize=11 end
   U.Flip.Text=U.Back and'Frente'or'Verso';U.Keep.Text='Guardar';U.Delete.Text='Excluir'
  end
  local cols=wide and 3 or 3;local gap=6;local cw=(lw-gap*(cols-1))/cols;local rows=lh<150 and 1 or 2;local ch=(lh-gap*(rows-1))/rows;U.Capacity=cols*rows
  for i,s in ipairs(slots)do R(s.root,(i-1)%cols*(cw+gap),math.floor((i-1)/cols)*(ch+gap),cw,ch);local sh=math.max(20,ch-28);local sw=math.min(cw-8,sh*.70);R(s.host,(cw-sw)/2,4,sw,sh);R(s.text,3,ch-22,cw-6,20)end
  R(atelier.Root,il+8,y,aw-16,ah);atelier.Layout(aw-16,ah)
 end
 function U.Show()
  storeToken=storeToken+1;local token=storeToken;U.Root.Visible=true;U.Store=nil;refresh()
  local store,e=call('store');if not store then toast(e);return end
  for _,group in ipairs({store.passes,store.products})do for _,p in pairs(group)do p.pending=true;p.sale=false end end;U.Store=store;U.Render()
  task.spawn(function()
   for _,kind in ipairs({'pass','product'})do for _,p in pairs(kind=='pass'and store.passes or store.products)do
    if token~=storeToken or not U.Root.Visible then return end
    local key=kind..p.id;local cache=prices[key];local info=cache and os.clock()-cache.time<30 and cache.info
    if not info then local ok,d=pcall(function()return Market:GetProductInfoAsync(p.id,kind=='pass'and Enum.InfoType.GamePass or Enum.InfoType.Product)end);info=ok and d or nil;if info then prices[key]={time=os.clock(),info=info}end end
    p.pending=false;p.price=info and info.PriceInRobux;p.sale=info and info.IsForSale==true and type(p.price)=='number'and p.price==p.price and p.price>=0 or false
   end end
   if token==storeToken and U.Root.Visible then U.Render()end
  end)
 end
 U.Close.Activated:Connect(function()storeToken=storeToken+1;atelier.Cancel();U.Root.Visible=false;if U.OnClose then U.OnClose()end end)
 safe.Watch(function()U.Layout();if U.Data and U.Tab~='Ateliê'then U.PaintPage()end end);return U
end
return M
