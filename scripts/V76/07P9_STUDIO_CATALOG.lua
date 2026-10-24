-- 07P9_STUDIO_CATALOG | ModuleScript | ReplicatedStorage | V76 (SUBSTITUIR)
-- Fundos 3 × 3; emotes 5 × 4. Prévia sem compra automática e paginação limitada.
local Rep=game:GetService('ReplicatedStorage');local Avatar=game:GetService('AvatarEditorService');local Market=game:GetService('MarketplaceService')
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local B=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local M={Version='V76'}
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
 local query=D.Box(drawer,'Pesquisar emotes ou fundos',{TextSize=13,ZIndex=41});local search=D.IconButton(drawer,'SearchStudioCatalog','search','Pesquisar',{ZIndex=42})
 local emotes=D.Button(drawer,'Emotes',{TextSize=13,ZIndex=41});local packs=D.Button(drawer,'Pacotes',{TextSize=13,ZIndex=41})
 local pause=D.Button(drawer,'Pausar',{TextSize=13,ZIndex=41});local speed=D.Button(drawer,'Velocidade: 1×',{TextSize=13,ZIndex=41})
 local buy=D.Button(drawer,'Comprar item selecionado',{Name='BuySelectedStudioItem',TextSize=13,ZIndex=41});D.SetEnabled(buy,false)
 local slot=D.Button(drawer,'Animação: parado',{TextSize=13,ZIndex=41})
 local note=D.Text(drawer,'Toque na miniatura para testar. A compra só abre pelo botão Comprar.',{TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=41})
 local slots={'IdleAnimation','WalkAnimation','RunAnimation','JumpAnimation','FallAnimation','ClimbAnimation','SwimAnimation'}
 local labels={'Parado','Andar','Correr','Pular','Cair','Escalar','Nadar'};local slotIndex=1;local pack=false;local selected
 local pages;local cache={};local buying=false;local alive=true;local pageIndex=1;local ticket=0;local loading=false;local capacity=mode=='Background'and 9 or 20;local cards={};local load;local render
 local function layout()
  local w,h=host.AbsoluteSize.X,host.AbsoluteSize.Y;if w<1 or h<1 then return end
  local gap=4;local cols=mode=='Background'and 3 or 5;local maxRows=mode=='Background'and 3 or 4
  local rows=math.clamp(math.floor((h-48+gap)/(44+gap)),1,maxRows);local nextCapacity=rows*cols
  if nextCapacity~=capacity then local first=(pageIndex-1)*capacity;capacity=nextCapacity;pageIndex=math.floor(first/capacity)+1;task.defer(function()if host.Parent and render then render()end end)end
  local ch=math.min(68,math.floor((h-48-(rows-1)*gap)/rows));local cw=(w-(cols-1)*gap)/cols
  B.Rect(list,0,0,w,rows*(ch+gap)-gap)
  for i,c in ipairs(cards)do B.Rect(c,(i-1)%cols*(cw+gap),math.floor((i-1)/cols)*(ch+gap),cw,ch)end
  local bw=(w-16)/5;for i,b in ipairs({prev,page,more,stop,options})do B.Rect(b,(i-1)*(bw+4),h-44,bw,44);if i>=4 then b.TextSize=11;local pad=b:FindFirstChildOfClass('UIPadding');if pad then pad.PaddingLeft=UDim.new(0,1);pad.PaddingRight=UDim.new(0,1)end end end
  B.Rect(drawer,0,0,w,math.max(44,h-48));drawer.CanvasSize=UDim2.fromOffset(0,346)
  B.Rect(query,4,4,w-56,44);B.Rect(search,w-48,4,44,44)
  B.Rect(emotes,4,54,(w-14)/2,44);B.Rect(packs,(w+6)/2,54,(w-14)/2,44)
  B.Rect(pause,4,104,(w-14)/2,44);B.Rect(speed,(w+6)/2,104,(w-14)/2,44)
  B.Rect(slot,4,154,w-8,44);B.Rect(buy,4,204,w-8,44);B.Rect(note,8,256,w-16,84)
  emotes.Visible=mode=='Animations';packs.Visible=emotes.Visible;pause.Visible=playback~=nil;speed.Visible=pause.Visible;slot.Visible=pack
 end
 render=function()
  for _,c in ipairs(cards)do c:Destroy()end;cards={}
  local start=(pageIndex-1)*capacity+1
  for index=start,math.min(#cache,start+capacity-1)do
   local item=cache[index];local isPack=pack
   local b=D.Button(list,'',{Name='StudioCatalog_'..item.Id,BackgroundColor3=Color3.fromRGB(219,230,235),ZIndex=34})
   b:SetAttribute('ActionLabel','Experimentar '..tostring(item.Name));b:SetAttribute('AssetId',item.Id)
   D.New('ImageLabel',{Name='StudioItemImage',Image='rbxthumb://type='..(isPack and'BundleThumbnail'or'Asset')..'&id='..item.Id..'&w=150&h=150',Position=UDim2.fromOffset(2,2),Size=UDim2.new(1,-4,1,-17),BackgroundTransparency=1,ScaleType=Enum.ScaleType.Fit,ZIndex=35},b)
   D.Text(b,item.Name,{Position=UDim2.new(0,2,1,-16),Size=UDim2.new(1,-4,0,15),TextColor3=Color3.fromRGB(35,48,63),TextSize=10,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false,ZIndex=35})
   b.Activated:Connect(function()item.IsAnimationPack=isPack;item.AnimationSlot=slots[slotIndex];selected=item;D.SetEnabled(buy,true);U.PopupTitle.Text=tostring(item.Name):sub(1,42);onSelect(item)end);cards[#cards+1]=b
  end
  page.Text=tostring(pageIndex)..'/'..math.max(1,math.ceil(#cache/capacity));D.SetEnabled(prev,pageIndex>1)
  D.SetEnabled(more,not loading and((pageIndex*capacity)<#cache or pages and not pages.IsFinished))
  if #cache==0 then note.Text='Nenhum item carregado. Abra Opções e pesquise novamente.'end;layout()
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
   if not ok then U.Notify('A busca não respondeu. Abra Opções e tente novamente.');note.Text='A busca não respondeu. Tente pesquisar novamente.';render();return end
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
