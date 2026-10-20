-- 07P9_STUDIO_CATALOG | ModuleScript | ReplicatedStorage | V72 (SUBSTITUIR)
-- Miniaturas em grade, compra oficial e emotes/pacotes tocando na cópia real.
local Rep=game:GetService('ReplicatedStorage');local Avatar=game:GetService('AvatarEditorService');local Market=game:GetService('MarketplaceService')
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local B=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local M={Version='V72'}
function M.Open(U,mode,onSelect,onStop,playback)
 U.Clear();U.CatalogMode=true;U.PopupTitle.Text=mode=='Background'and'Fundos da loja'or'Emotes e animações'
 local host=D.New('Frame',{Name='StudioCatalog',BackgroundTransparency=1,ZIndex=32,LayoutOrder=1},U.Content)
 local query=D.Box(host,'Pesquisar nome',{TextSize=12,ZIndex=33});local search=D.IconButton(host,'SearchStudioCatalog','search','Pesquisar no catálogo',{ZIndex=33})
 local list=D.Scroll(host,{Name='StudioCatalogItems',ScrollBarThickness=3,ZIndex=33});local grid=D.New('UIGridLayout',{CellPadding=UDim2.fromOffset(6,6),SortOrder=Enum.SortOrder.LayoutOrder},list)
 local notice=D.Text(host,'',{Name='StudioCatalogStatus',TextSize=10,ZIndex=33,TextColor3=D.Colors.muted,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false})
 local more=D.Button(host,'Mais',{TextSize=11,ZIndex=33});local stop=D.Button(host,mode=='Background'and'Neutro'or'Parar',{TextSize=11,ZIndex=33})
 local pause,speed,emotes,packs,slot;local pack=false;local selected;local slots={'IdleAnimation','WalkAnimation','RunAnimation','JumpAnimation','FallAnimation','ClimbAnimation','SwimAnimation'};local slotIndex=1
 if mode=='Animations'and playback then
  pause=D.Button(host,'Pausar',{Name='PauseStudioEmote',TextSize=11,ZIndex=33});speed=D.Button(host,'1×',{Name='StudioEmoteSpeed',TextSize=11,ZIndex=33})
  emotes=D.Button(host,'Emotes',{TextSize=12,ZIndex=33});packs=D.Button(host,'Pacotes',{TextSize=12,ZIndex=33});slot=D.Button(host,'Parado',{TextSize=11,ZIndex=33})
  pause.Activated:Connect(function()local ok,paused=playback.pause();if ok then pause.Text=paused and'Continuar'or'Pausar'else U.Notify(paused)end end)
  local speeds={.5,1,1.5,2};local si=2;speed.Activated:Connect(function()si=si%#speeds+1;playback.speed(speeds[si]);speed.Text=speeds[si]..'×'end)
  slot.Activated:Connect(function()slotIndex=slotIndex%#slots+1;slot.Text=({'Parado','Andar','Correr','Pular','Cair','Escalar','Nadar'})[slotIndex];if selected and pack then selected.AnimationSlot=slots[slotIndex];onSelect(selected)end end)
 end
 local pages;local ticket=0;local loading=false;local load
 local function layout()
  local w,h=host.AbsoluteSize.X,host.AbsoluteSize.Y;B.Rect(query,0,0,w-50,44);B.Rect(search,w-44,0,44,44)
  local top=50;if emotes then B.Rect(emotes,0,50,(w-6)/2,44);B.Rect(packs,(w+6)/2,50,(w-6)/2,44);emotes.BackgroundColor3=not pack and D.Colors.soft or D.Colors.card;packs.BackgroundColor3=pack and D.Colors.soft or D.Colors.card;top=100 end
  local footer=pause and 98 or 50;B.Rect(list,0,top,w,math.max(44,h-top-footer-18));B.Rect(notice,0,h-footer-16,w,16)
  local n=pause and 5 or 2;local bw=(w-6*(n-1))/n;local buttons=pause and{stop,pause,speed,slot,more}or{stop,more}
  if pause then for i,b in ipairs(buttons)do local row=i>3 and 1 or 0;local cols=row==1 and 2 or 3;local x=row==1 and i-4 or i-1;B.Rect(b,x*(w+6)/cols,h-94+row*50,(w-6*(cols-1))/cols,44);b.Visible=b~=slot or pack end
   if not pack then B.Rect(more,0,h-44,w,44)end
  else for i,b in ipairs(buttons)do B.Rect(b,(i-1)*(bw+6),h-44,bw,44)end end
  local cols=w>=300 and 3 or 2;local cw=(w-(cols-1)*6-4)/cols;grid.FillDirectionMaxCells=cols;grid.CellSize=UDim2.fromOffset(cw,math.max(104,cw+32))
 end
 load=function(nextPage)
  if loading then return end;loading=true;ticket=ticket+1;local mine=ticket;more.Text='…';notice.Text='Consultando itens à venda no Roblox…'
  task.spawn(function()
   local source=pages;local ok,rows=pcall(function()
    if nextPage and source and not source.IsFinished then source:AdvanceToNextPageAsync()else
     local p=CatalogSearchParams.new();if pack then p.BundleTypes={Enum.BundleType.Animations}else p.AssetTypes={mode=='Background'and Enum.AvatarAssetType.AvatarBackground or Enum.AvatarAssetType.EmoteAnimation}end
     p.Limit=30;p.IncludeOffSale=false;p.SearchKeyword=query.Text:sub(1,80);p.SortType=Enum.CatalogSortType.Relevance;source=Avatar:SearchCatalogAsync(p)
    end;return source:GetCurrentPage()
   end)
   if mine~=ticket or not host.Parent then return end;loading=false;pages=source
   if not ok then U.Notify('O catálogo Roblox não respondeu. Use Buscar para tentar novamente.');more.Text='Repetir';return end
   for _,o in ipairs(list:GetChildren())do if o:IsA('GuiObject')then o:Destroy()end end
   for i,it in ipairs(rows or{})do local isPack=pack;
    local row=D.Button(list,'',{Name='StudioCatalog_'..it.Id,LayoutOrder=i,BackgroundColor3=D.Colors.card,ZIndex=34})
    D.New('ImageLabel',{Name='StudioItemImage',Image='rbxthumb://type='..(pack and'BundleThumbnail'or'Asset')..'&id='..it.Id..'&w=420&h=420',Position=UDim2.fromOffset(2,2),Size=UDim2.new(1,-4,1,-48),BackgroundTransparency=1,ScaleType=Enum.ScaleType.Fit,ZIndex=35},row)
    D.Text(row,it.Name,{Position=UDim2.new(0,5,1,-47),Size=UDim2.new(1,-10,0,20),TextSize=10,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false,ZIndex=35})
    local buy=D.Button(row,tostring(it.Price or'?')..' R$',{Name='BuyStudioItem',Position=UDim2.new(1,-46,1,-46),Size=UDim2.fromOffset(44,44),BackgroundTransparency=1,TextSize=9,ZIndex=36});buy:SetAttribute('ActionLabel','Comprar pelo Roblox')
    row.Activated:Connect(function()it.IsAnimationPack=isPack;it.AnimationSlot=slots[slotIndex];selected=it;onSelect(it)end)
    buy.Activated:Connect(function()task.spawn(function()local good,info=pcall(function()return Avatar:GetItemDetailsAsync(it.Id,isPack and Enum.AvatarItemType.Bundle or Enum.AvatarItemType.Asset)end);if not good or info.IsForSale==false then U.Notify('O Roblox não confirmou a compra.');return end;local pl=game:GetService('Players').LocalPlayer;if isPack then Market:PromptBundlePurchase(pl,it.Id)else Market:PromptPurchase(pl,it.Id)end end)end)
   end
   notice.Text=#(rows or{})==0 and'Nenhum item nesta busca.'or'Toque na miniatura para testar • preço para comprar';more.Text=pages.IsFinished and'Atualizar'or'Mais';more:SetAttribute('Finished',pages.IsFinished);layout()
  end)
 end
 if emotes then emotes.Activated:Connect(function()ticket=ticket+1;loading=false;pack=false;pages=nil;selected=nil;layout();load(false)end);packs.Activated:Connect(function()ticket=ticket+1;loading=false;pack=true;pages=nil;selected=nil;layout();load(false)end)end
 stop.Activated:Connect(onStop);search.Activated:Connect(function()load(false)end);query.FocusLost:Connect(function(enter)if enter then load(false)end end);more.Activated:Connect(function()load(not more:GetAttribute('Finished'))end)
 host:GetPropertyChangedSignal('AbsoluteSize'):Connect(layout);host.Destroying:Connect(function()ticket=ticket+1;U.CatalogMode=false end);layout();load(false);U.Layout()
end
return M
