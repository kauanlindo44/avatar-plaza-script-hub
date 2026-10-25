-- 07P9_STUDIO_CATALOG | ModuleScript | ReplicatedStorage | V77 (SUBSTITUIR)
-- Fundos e emotes com três colunas, conforme a referência mais recente. Prévia sem compra automática e paginação limitada.
local Rep=game:GetService('ReplicatedStorage');local Avatar=game:GetService('AvatarEditorService');local Market=game:GetService('MarketplaceService')
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local B=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local M={Version='V77'}
function M.Open(U,mode,onSelect,onStop,playback)
 U.Clear();U.CatalogMode=true;U.CatalogKind=mode;U.PopupTitle.Text=mode=='Background'and'Fundos'or'Emotes'
 local host=D.New('Frame',{Name='StudioCatalog',BackgroundTransparency=1,ZIndex=32,LayoutOrder=1},U.Content)
 local list=D.New('Frame',{Name='StudioCatalogItems',BackgroundTransparency=1,ZIndex=33},host)
 local prev=D.Button(host,'‹',{Name='PreviousEmotePage',TextSize=24,ZIndex=35})
 local more=D.Button(host,'›',{Name='NextEmotePage',TextSize=24,ZIndex=35})
 local stop=D.Button(host,mode=='Background'and'Limpar'or'Parar',{TextSize=12,ZIndex=35})
 local options=D.Button(host,'Opções',{Name='StudioCatalogOptions',TextSize=12,ZIndex=35})
 local page=D.Text(host,'1',{Name='StudioCatalogPage',TextSize=12,ZIndex=35})
 local drawer=D.Scroll(host,{Name='StudioCatalogSettings',BackgroundColor3=D.Colors.panel,BackgroundTransparency=0,Visible=false,ZIndex=40,AutomaticCanvasSize=Enum.AutomaticSize.None})
 local query=D.Box(host,'Pesquisar emotes ou fundos',{TextSize=13,ZIndex=41});local search=D.IconButton(host,'SearchStudioCatalog','search','Pesquisar',{ZIndex=42})
 local emotes=D.Button(host,'Emotes',{TextSize=13,ZIndex=41});local packs=D.Button(host,'Pacotes',{TextSize=13,ZIndex=41})
 local pause=D.Button(drawer,'Pausar',{TextSize=13,ZIndex=41});local speed=D.Button(drawer,'Velocidade: 1×',{TextSize=13,ZIndex=41})
 local buy=D.Button(drawer,'Comprar item selecionado',{Name='BuySelectedStudioItem',TextSize=13,ZIndex=41});D.SetEnabled(buy,false)
 local slot=D.Button(drawer,'Animação: parado',{TextSize=13,ZIndex=41})
 local note=D.Text(drawer,'Toque na miniatura para testar. A compra só abre pelo botão Comprar.',{TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=41})
 local slots={'IdleAnimation','WalkAnimation','RunAnimation','JumpAnimation','FallAnimation','ClimbAnimation','SwimAnimation'}
 local labels={'Parado','Andar','Correr','Pular','Cair','Escalar','Nadar'};local slotIndex=1;local pack=false;local selected
 local pages;local cache={};local buying=false;local alive=true;local pageIndex=1;local ticket=0;local loading=false;local capacity=9;local cards={};local load;local render
 local function layout()
  local w,h=host.AbsoluteSize.X,host.AbsoluteSize.Y;if w<1 or h<1 then return end
  local gap=4;local cols=3;local maxRows=3;local top=mode=='Animations'and 48 or 0
  local rows=math.clamp(math.floor((h-top-96+gap)/(44+gap)),1,maxRows);local nextCapacity=rows*cols
  if nextCapacity~=capacity then local first=(pageIndex-1)*capacity;capacity=nextCapacity;pageIndex=math.floor(first/capacity)+1;task.defer(function()if host.Parent and render then render()end end)end
  local ch=math.min(68,math.floor((h-top-96-(rows-1)*gap)/rows));local cw=(w-(cols-1)*gap)/cols
  B.Rect(list,0,top,w,rows*(ch+gap)-gap)
  for i,c in ipairs(cards)do B.Rect(c,(i-1)%cols*(cw+gap),math.floor((i-1)/cols)*(ch+gap),cw,ch)end
  local pageW=math.max(8,w-192)
  B.Rect(prev,0,h-92,44,44);B.Rect(page,48,h-92,pageW,44)
  B.Rect(more,w-140,h-92,44,44);B.Rect(stop,w-92,h-92,44,44);B.Rect(options,w-44,h-92,44,44)
  for _,b in ipairs({stop,options})do b.TextSize=10;local pad=b:FindFirstChildOfClass('UIPadding');if pad then pad.PaddingLeft=UDim.new(0,1);pad.PaddingRight=UDim.new(0,1)end end
  B.Rect(drawer,0,0,w,math.max(44,h-96));drawer.CanvasSize=UDim2.fromOffset(0,346)
  B.Rect(query,0,h-44,w-48,44);B.Rect(search,w-44,h-44,44,44)
  B.Rect(emotes,0,0,(w-4)/2,44);B.Rect(packs,(w+4)/2,0,(w-4)/2,44)
  B.Rect(pause,4,104,(w-14)/2,44);B.Rect(speed,(w+6)/2,104,(w-14)/2,44)
  B.Rect(slot,4,154,w-8,44);B.Rect(buy,4,204,w-8,44);B.Rect(note,8,256,w-16,84)
  emotes.Visible=mode=='Animations';packs.Visible=emotes.Visible;pause.Visible=playback~=nil;speed.Visible=pause.Visible;slot.Visible=pack
 end
 render=function()
  for _,c in ipairs(cards)do c:Destroy()end;cards={}
  local start=(pageIndex-1)*capacity+1
  for index=start,math.min(#cache,start+capacity-1)do
   local item=cache[index];local isPack=pack
   local b=D.Button(list,'',{Name='StudioCatalog_'..item.Id,BackgroundColor3=Color3.fromRGB(67,69,76),ZIndex=34})
   b:SetAttribute('ActionLabel','Experimentar '..tostring(item.Name));b:SetAttribute('AssetId',item.Id)
   D.New('ImageLabel',{Name='StudioItemImage',Image='rbxthumb://type='..(isPack and'BundleThumbnail'or'Asset')..'&id='..item.Id..'&w=150&h=150',Position=UDim2.fromOffset(2,2),Size=UDim2.new(1,-4,1,-17),BackgroundTransparency=1,ScaleType=Enum.ScaleType.Fit,ZIndex=35},b)
   D.Text(b,item.Name,{Position=UDim2.new(0,2,1,-16),Size=UDim2.new(1,-4,0,15),TextColor3=Color3.fromRGB(240,240,244),TextSize=10,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false,ZIndex=35})
   b.Activated:Connect(function()item.IsAnimationPack=isPack;item.AnimationSlot=slots[slotIndex];selected=item;D.SetEnabled(buy,true);U.PopupTitle.Text=tostring(item.Name):sub(1,42);for _,card in ipairs(cards)do local outline=card:FindFirstChild('SelectedOutline');if outline then outline.Enabled=card==b end end;onSelect(item)end);D.New('UIStroke',{Name='SelectedOutline',Color=Color3.fromRGB(107,238,131),Thickness=2,Enabled=selected and selected.Id==item.Id or false},b);cards[#cards+1]=b
  end
  page.Text=tostring(pageIndex)..'/'..math.max(1,math.ceil(#cache/capacity));D.SetEnabled(prev,pageIndex>1)
  D.SetEnabled(more,not loading and((pageIndex*capacity)<#cache or pages and not pages.IsFinished))
  if #cache==0 then note.Text='Nenhum item carregado. Use a busca abaixo para tentar novamente.'end;layout()
 end
 load=function(reset,advance)
  if loading then return end;loading=true;ticket=ticket+1;local mine=ticket;more.Text='…'
  task.spawn(function()
   local source=pages;local ok,rows=pcall(function()
    if not reset and source and not source.IsFinished then source:AdvanceToNextPageAsync()else
     local p=CatalogSearchParams.new();p.Limit=30;p.IncludeOffSale=false;p.SearchKeyword=query.Text:sub(1,80);p.SortType=Enum.CatalogSortType.Relevance
     if pack then p.BundleTypes={Enum.BundleType.Animations}else p.AssetTypes={mode=='Background'and Enum.AvatarAssetType.AvatarBackground or Enum.AvatarAssetType.EmoteAnimation}end
     source=Avatar:SearchCatalogAsync(p)
    end;return source:GetCurrentPage()
   end)
   if mine~=ticket or not host.Parent then return end;loading=false;more.Text='›'
   if not ok then U.Notify('A busca não respondeu. Use a busca abaixo para tentar novamente.');note.Text='A busca não respondeu. Tente pesquisar novamente.';render();return end
   pages=source;if reset then cache={};pageIndex=1 end
   local seen={};for _,item in ipairs(cache)do seen[item.Id]=true end
   for _,item in ipairs(rows or{})do if not seen[item.Id]then cache[#cache+1]=item;seen[item.Id]=true end end
   if advance and(pageIndex*capacity)<#cache then pageIndex=pageIndex+1 end;drawer.Visible=false;render()
  end)
 end
 prev.Activated:Connect(function()pageIndex=math.max(1,pageIndex-1);render()end)
 more.Activated:Connect(function()if pageIndex*capacity<#cache then pageIndex=pageIndex+1;render()elseif pages and not pages.IsFinished then load(false,true)end end)
 stop.Activated:Connect(onStop);options.Activated:Connect(function()drawer.Visible=not drawer.Visible;layout()end)
 search.Activated:Connect(function()load(true)end);query.FocusLost:Connect(function(enter)if enter then load(true)end end)
 for _,def in ipairs({{emotes,false},{packs,true}})do def[1].Activated:Connect(function()ticket=ticket+1;loading=false;pack=def[2];selected=nil;D.SetEnabled(buy,false);cache={};pages=nil;pageIndex=1;load(true)end)end
 pause.Activated:Connect(function()if playback then local ok,on=playback.pause();if ok then pause.Text=on and'Continua'or'Pausar'else U.Notify(on)end end end)
 local speeds={.5,1,1.5,2};local si=2;speed.Activated:Connect(function()if playback then si=si%#speeds+1;playback.speed(speeds[si]);speed.Text='Velocidade: '..speeds[si]..'×'end end)
 slot.Activated:Connect(function()slotIndex=slotIndex%#slots+1;slot.Text='Animação: '..labels[slotIndex];if selected and pack then selected.AnimationSlot=slots[slotIndex];onSelect(selected)end end)
 buy.Activated:Connect(function()
  local item=selected;if not item or buying or not alive then return end;buying=true;D.SetEnabled(buy,false);local isPack=item.IsAnimationPack
  task.spawn(function()
   local ok,info=pcall(function()return Avatar:GetItemDetailsAsync(item.Id,isPack and Enum.AvatarItemType.Bundle or Enum.AvatarItemType.Asset)end)
   if not alive or not host.Parent then return end;buying=false;D.SetEnabled(buy,selected~=nil)
   if not ok or not info or info.IsForSale==false then U.Notify('O Roblox não confirmou a disponibilidade.');return end
   local pl=game:GetService('Players').LocalPlayer
   local prompted=pcall(function()if isPack then Market:PromptBundlePurchase(pl,item.Id)else Market:PromptPurchase(pl,item.Id)end end)
   if not prompted then U.Notify('Não foi possível abrir a compra oficial.')end
  end)
 end)
 host:GetPropertyChangedSignal('AbsoluteSize'):Connect(layout);host.Destroying:Connect(function()alive=false;ticket=ticket+1;U.CatalogMode=false;U.CatalogKind=nil end)
 layout();load(true);U.Layout()
end
return M
