-- 07K16_ATELIER_UI | ModuleScript | ReplicatedStorage | V56
-- Arraste, amplie, gire e guarde enquadramentos. Nunca salva uma imagem não carregada.
local Rep=game:GetService('ReplicatedStorage')
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local C=D.Colors
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'))
local Cards=require(Rep:WaitForChild('07K7_CARD_STYLES'))
local Catalog=require(Rep:WaitForChild('07K6_CARD_CATALOG'))
local UIS=game:GetService('UserInputService');local Content=game:GetService('ContentProvider')
local M={}
local function id(text)
 text=tostring(text or''):sub(1,240)
 local n=tonumber(text)or tonumber(text:match('rbxassetid://(%d+)')or text:match('[?&]id=(%d+)')or text:match('/assets?/(%d+)')or text:match('/library/(%d+)')or text:match('/catalog/(%d+)'))
 return n and n==n and n>0 and n<=9007199254740991 and n%1==0 and n or 0
end
function M.Build(parent,call,toast,prompt,refresh)
 local V={Editor={image=0,texture=0,zoom=1,x=0,y=0,rotation=0,brightness=1,layout='Full'},Token=0,Ready=false};local N=D.New;local R=Bounds.Rect
 V.Root=D.Frame(parent,{Name='AtelierEditor',BackgroundColor3=C.panel,Visible=false})
 V.ID=D.Box(V.Root,'ID ou link da imagem / decal',{TextSize=14})
 V.Load=D.Button(V.Root,'Carregar',{BackgroundColor3=C.orange,TextColor3=C.bg,TextSize=12});V.Reload=D.IconButton(V.Root,'ReloadArtwork','reset','Recarregar imagem',{})
 V.Status=D.Text(V.Root,'Cole uma imagem publicada no Roblox.',{TextSize=12,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 V.Preview=N('Frame',{Name='EditableCard',BackgroundTransparency=1,Active=true},V.Root)
 V.Help=D.Text(V.Root,'Arraste a imagem na carta para enquadrar.',{TextSize=12,TextColor3=C.muted})
 V.Controls=N('Frame',{Name='ImageAdjustments',BackgroundTransparency=1},V.Root);local buttons={}
 local picture;local activeID=0;local connection;local owner;local drag;local origin;local startX,startY;local paint
 local function status(text,kind)V.Status.Text=text;V.Status.TextColor3=kind=='Ready'and C.green or kind=='Error'and C.red or C.muted;V.Status:SetAttribute('LoadState',kind)end
 local function button(text,fn)local b=D.Button(V.Controls,text,{TextSize=12});buttons[#buttons+1]=b;b.Activated:Connect(fn);return b end
 V.Minus=button('− zoom',function()V.Editor.zoom=math.max(1,V.Editor.zoom-.15);paint()end)
 V.Plus=button('+ zoom',function()V.Editor.zoom=math.min(4,V.Editor.zoom+.15);paint()end)
 V.Left=button('Girar −15°',function()V.Editor.rotation=math.max(-180,V.Editor.rotation-15);paint()end)
 V.Right=button('Girar +15°',function()V.Editor.rotation=math.min(180,V.Editor.rotation+15);paint()end)
 V.Center=button('Centralizar',function()V.Editor.x=0;V.Editor.y=0;V.Editor.rotation=0;V.Editor.zoom=1;paint()end)
 V.Brightness=button('Luz: 100%',function()V.Editor.brightness=V.Editor.brightness<=.61 and 1 or V.Editor.brightness-.1;paint()end)
 V.Format=button('Foto inteira',function()local t={'Full','Inset','Banner'};V.Editor.layout=t[(table.find(t,V.Editor.layout)or 1)%3+1];paint(true)end)
 V.Flip=button('Ver verso',function()V.Back=not V.Back;paint(true)end)
 V.Save=D.Button(V.Root,'Aplicar nas cartas',{BackgroundColor3=C.green,TextColor3=C.bg,TextSize=13})
 V.Keep=D.Button(V.Root,'Guardar visual',{TextSize=13})
 local function identity()return not V.Back and{rank='A',suit='S'}or nil end
 local function clear()if connection then connection:Disconnect();connection=nil end;for _,o in ipairs(V.Preview:GetChildren())do if o:IsA('GuiObject')then o:Destroy()end end;picture=nil end
 local function updateArt()
  local e=V.Editor;local limit=(e.zoom-1)/2;e.x=math.clamp(e.x,-limit,limit);e.y=math.clamp(e.y,-limit,limit)
  if picture then local sx,sy=1,1;if e.layout=='Inset'then sx,sy=.76,.66 elseif e.layout=='Banner'then sx,sy=1,.54 end
   picture.Position=UDim2.fromScale(.5+e.x,.5+e.y);picture.Size=UDim2.fromScale(sx*e.zoom,sy*e.zoom);picture.Rotation=e.rotation;picture.ImageColor3=Color3.new(e.brightness,e.brightness,e.brightness)
  end
  V.Brightness.Text='Luz: '..math.floor(e.brightness*100+.5)..'%';V.Format.Text=({Full='Foto inteira',Inset='Moldura',Banner='Faixa central'})[e.layout];V.Flip.Text=V.Back and'Ver frente'or'Ver verso'
 end
 paint=function(force)
  local image=id(V.ID.Text);local e=V.Editor;e.image=image
  if not force and image==activeID then updateArt();return end
  activeID=image;V.Token=V.Token+1;local token=V.Token;V.Ready=false;clear();D.SetEnabled(V.Save,not V.Data.ateliers);D.SetEnabled(V.Keep,false)
  if image<1 then status('Cole o ID e pressione Carregar.','Idle');return end
  status('Verificando o ID no Roblox…','Loading');local expired=false
  task.delay(12,function()if token==V.Token and not picture then expired=true;status('Não carregou: Roblox demorou. Toque ↻.','Error')end end)
  task.spawn(function()
   local meta,err=call('image',{image=image})
   if token~=V.Token or expired or not V.Root.Visible then return end
   if not meta or meta.image~=image or(meta.assetType~=1 and meta.assetType~=13)then status(err or'Esse ID não é uma imagem ou decal.','Error');return end
   e.texture=meta.texture or 0;e.thumb=false
   local root=Cards.Render(V.Preview,identity(),'Custom',{Size=UDim2.fromScale(1,1)},e);picture=root:FindFirstChild('CustomArtwork');updateArt()
   if not picture then status('Não foi possível montar a carta. Recarregue.','Error');return end
   local current=picture;local done=false
   local function check()
    if token~=V.Token or current~=picture or not current.Parent then return end
    if current.IsLoaded then done=true;V.Ready=true;status('✓ Imagem carregada. Ajuste, aplique ou guarde.','Ready');D.SetEnabled(V.Save,true);D.SetEnabled(V.Keep,V.Data.ateliers)end
   end
   connection=current:GetPropertyChangedSignal('IsLoaded'):Connect(check)
   local function preload()task.spawn(function()pcall(function()Content:PreloadAsync({current})end);check()end)end
   status('Carregando a imagem em resolução original…','Loading');preload();check()
   task.delay(8,function()
    if token~=V.Token or done then return end
    e.thumb=true;current.Image='rbxthumb://type=Asset&id='..image..'&w=420&h=420';status('Tentando a miniatura do Roblox…','Loading');preload();check()
    task.delay(8,function()if token==V.Token and not done then V.Ready=false;status('Não carregou. Pode ser permissão, moderação ou conexão. Tente ↻.','Error');D.SetEnabled(V.Save,not V.Data.ateliers);D.SetEnabled(V.Keep,false)end end)
   end)
  end)
 end
 V.Load.Activated:Connect(function()paint(true)end);V.Reload.Activated:Connect(function()paint(true)end)
 V.ID.FocusLost:Connect(function(enter)if enter then paint(true)end end)
 V.Preview.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=i;origin=i.Position;startX,startY=V.Editor.x,V.Editor.y end end)
 local moving=UIS.InputChanged:Connect(function(i)if drag and(i==drag or i.UserInputType==Enum.UserInputType.MouseMovement)then
  local delta=i.Position-origin;V.Editor.x=startX+delta.X/math.max(1,V.Preview.AbsoluteSize.X);V.Editor.y=startY+delta.Y/math.max(1,V.Preview.AbsoluteSize.Y);updateArt()
 end end)
 local ending=UIS.InputEnded:Connect(function(i)if i==drag or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=nil end end)
 local busy=false
 local function save(keep)
  if busy then return end
  if not V.Data.ateliers then prompt('pass',Catalog.CustomPass);return end
  if not V.Ready or id(V.ID.Text)~=activeID or not picture or not picture.IsLoaded then toast('Carregue uma imagem antes de salvar.');return end
  busy=true;local d,e=call('custom',V.Editor)
  if d and keep then d,e=call('savepreset',{style='Custom'})end
  busy=false;toast(d and(keep and'Visual guardado em Salvos e equipado.'or'Imagem aplicada nas suas cartas.')or e);if d then owner=nil;refresh()end
 end
 V.Save.Activated:Connect(function()save(false)end);V.Keep.Activated:Connect(function()save(true)end)
 function V.SetData(data,store)
  V.Data=data
  if owner~=data.custom then
   owner=data.custom;local e={};for k,v in pairs(data.custom or V.Editor)do e[k]=v end
   e.rotation=e.rotation or 0;e.brightness=e.brightness or 1;e.layout=e.layout or'Full';V.Editor=e;V.ID.Text=(e.image or 0)>0 and tostring(e.image)or'';paint(true)
  end
  if not data.ateliers then local p=store and store.passes[tostring(Catalog.CustomPass)];V.Save.Text=p and p.sale and('Ateliê · '..p.price..' Robux')or'Ateliê indisponível';D.SetEnabled(V.Save,p and p.sale);D.SetEnabled(V.Keep,false)
  else V.Save.Text='Aplicar nas cartas'end
 end
 function V.Layout(w,h)
  local wide=w>=520;local toolbar=wide and 90 or 114
  R(V.ID,8,6,w-144,44);R(V.Load,w-130,6,72,44);R(V.Reload,w-52,6,44,44);R(V.Status,8,54,w-16,44)
  local previewH=math.max(30,h-toolbar-58);local previewW=math.min(wide and w*.42 or w*.44,previewH*.70)
  R(V.Preview,10,toolbar,previewW,previewH);local x=previewW+22;local rw=w-x-10
  R(V.Controls,x,toolbar,rw,math.max(48,h-toolbar-58));local cols=wide or rw>=280 and 2 or 1;cols=type(cols)=='boolean'and 2 or cols
  local bh=44;for i,b in ipairs(buttons)do R(b,(i-1)%cols*(rw+6)/cols,math.floor((i-1)/cols)*50,(rw-6*(cols-1))/cols,bh);b.TextSize=rw<180 and 11 or 12 end
  V.Help.Visible=h>=440;R(V.Help,x,toolbar+math.ceil(#buttons/cols)*50,rw,40)
  R(V.Save,8,h-50,(w-22)/2,44);R(V.Keep,(w+6)/2,h-50,(w-22)/2,44)
  if wide and h<300 then
   local left=w*.65;local ch=h-12;local cw=math.min(w-left-20,ch*.70)
   R(V.ID,8,6,left-142,44);R(V.Load,left-128,6,72,44);R(V.Reload,left-50,6,42,44);R(V.Status,8,54,left-16,30)
   R(V.Preview,left+(w-left-cw)/2,6,cw,ch);R(V.Controls,8,88,left-16,96);local bw=(left-34)/4
   for i,b in ipairs(buttons)do R(b,(i-1)%4*(bw+6),math.floor((i-1)/4)*50,bw,44)end
   R(V.Save,8,h-50,(left-22)/2,44);R(V.Keep,(left+6)/2,h-50,(left-22)/2,44)
  end
  if wide and h<240 then
   local left=math.max(410,w*.76);local cw=math.min(w-left-16,(h-12)*.70)
   R(V.ID,8,6,left-142,44);R(V.Load,left-128,6,72,44);R(V.Reload,left-50,6,44,44);R(V.Status,8,54,left-16,26)
   R(V.Preview,left+(w-left-cw)/2,6,cw,h-12);R(V.Controls,8,86,left-16,44);local bw=(left-58)/8
   for i,b in ipairs(buttons)do R(b,(i-1)*(bw+6),0,bw,44);b.TextSize=11 end
   R(V.Save,8,h-50,(left-22)/2,44);R(V.Keep,(left+6)/2,h-50,(left-22)/2,44)
  end
 end
 function V.Cancel()V.Token=V.Token+1;drag=nil;if connection then connection:Disconnect();connection=nil end end
 parent.Destroying:Connect(function()moving:Disconnect();ending:Disconnect();V.Cancel()end)
 return V
end
return M
