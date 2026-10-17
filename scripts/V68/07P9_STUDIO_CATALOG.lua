-- 07P9_STUDIO_CATALOG | ModuleScript | ReplicatedStorage | V68 (SUBSTITUIR)
-- Catálogo lateral de fundos à venda e emotes; ações no avatar copiado do estúdio.
local Rep=game:GetService('ReplicatedStorage');local Avatar=game:GetService('AvatarEditorService');local Market=game:GetService('MarketplaceService')
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local M={Version='V68'}
function M.Open(U,mode,onSelect,onStop,playback)
 U.Clear();U.CatalogMode=true;U.PopupTitle.Text=mode=='Background'and'Loja de fundos'or'Emotes • testar na cópia'
 local host=D.New('Frame',{Name='StudioCatalog',BackgroundTransparency=1,ZIndex=32,LayoutOrder=1},U.Content)
 local query=D.Box(host,'Pesquisar nome',{TextSize=12,ZIndex=33});local search=D.Button(host,'Buscar',{TextSize=12,ZIndex=33})
 local notice=D.Text(host,'',{Name='StudioCatalogStatus',TextSize=11,ZIndex=33,TextColor3=D.Colors.muted})
 local list=D.Scroll(host,{Name='StudioCatalogItems',ScrollBarThickness=3,ZIndex=33});D.New('UIListLayout',{Padding=UDim.new(0,6)},list)
 local more=D.Button(host,'Mais',{TextSize=12,ZIndex=33});local stop=D.Button(host,mode=='Background'and'Neutro'or'Parar',{TextSize=12,ZIndex=33})
 local pause,speed;if mode=='Animations'and playback then
  pause=D.Button(host,'Pausar',{Name='PauseStudioEmote',TextSize=12,ZIndex=33});speed=D.Button(host,'1×',{Name='StudioEmoteSpeed',TextSize=12,ZIndex=33})
  pause.Activated:Connect(function()local ok,paused=playback.pause();if ok then pause.Text=paused and'Continuar'or'Pausar'else U.Notify(paused)end end)
  local speeds={.5,1,1.5,2};local si=2;speed.Activated:Connect(function()si=si%#speeds+1;playback.speed(speeds[si]);speed.Text=speeds[si]..'×'end)
 end
 local pages;local ticket=0;local loading=false
 local function layout()
  local w,h=host.AbsoluteSize.X,host.AbsoluteSize.Y;Bounds.Rect(query,0,0,w-62,44);Bounds.Rect(search,w-56,0,56,44)
  Bounds.Rect(notice,0,46,w,22);local extra=pause and 48 or 0;Bounds.Rect(list,0,72,w,math.max(1,h-122-extra));Bounds.Rect(stop,0,h-44,(w-6)/2,44);Bounds.Rect(more,(w+6)/2,h-44,(w-6)/2,44);if pause then Bounds.Rect(pause,0,h-92,(w-6)/2,44);Bounds.Rect(speed,(w+6)/2,h-92,(w-6)/2,44)end
 end
 local function load(nextPage)
  if loading then return end;loading=true
  ticket=ticket+1;local mine=ticket;more.Text='Buscando…';notice.Text=mode=='Background'and'Buscando fundos à venda, não o inventário'or'Toque em Testar para animar a cópia'
  task.spawn(function()
   local source=pages;local ok,rows=pcall(function()
    if nextPage and source and not source.IsFinished then source:AdvanceToNextPageAsync()else
     local p=CatalogSearchParams.new();p.AssetTypes={mode=='Background'and Enum.AvatarAssetType.AvatarBackground or Enum.AvatarAssetType.EmoteAnimation};p.Limit=30;p.IncludeOffSale=false;p.SearchKeyword=query.Text:sub(1,80);p.SortType=Enum.CatalogSortType.Relevance;source=Avatar:SearchCatalogAsync(p)
    end;return source:GetCurrentPage()
   end)
   if mine~=ticket or not host.Parent then return end;loading=false;pages=source
   if not ok then U.Notify('O catálogo Roblox não respondeu. Toque em Buscar.');more.Text='Recarregar';return end
   for _,o in ipairs(list:GetChildren())do if o:IsA('GuiObject')then o:Destroy()end end
   for i,v in ipairs(rows or{})do
    local row=D.Frame(list,{Name='StudioCatalog_'..v.Id,Size=UDim2.new(1,-4,0,76),LayoutOrder=i,BackgroundColor3=D.Colors.card,ZIndex=34})
    local try=D.Button(row,'',{Name='TryStudioItem',Size=UDim2.new(1,-54,1,0),BackgroundTransparency=1,ZIndex=35})
    D.New('ImageLabel',{Name='StudioItemImage',Image='rbxthumb://type=Asset&id='..v.Id..'&w=420&h=420',Size=UDim2.fromOffset(64,64),Position=UDim2.fromOffset(4,6),BackgroundTransparency=1,ScaleType=Enum.ScaleType.Fit,Active=false,ZIndex=36},try)
    D.Text(try,tostring(v.Name or'Item Roblox'),{Position=UDim2.fromOffset(74,4),Size=UDim2.new(1,-78,0,42),TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Active=false,ZIndex=36})
    D.Text(try,'Testar • '..tostring(v.Price or'Consultar')..' Robux',{Position=UDim2.fromOffset(74,48),Size=UDim2.new(1,-78,0,22),TextSize=10,TextColor3=D.Colors.gold,Active=false,ZIndex=36})
    local buy=D.Button(row,'Comprar',{Position=UDim2.new(1,-48,.5,-22),Size=UDim2.fromOffset(44,44),TextSize=9,ZIndex=36})
    try.Activated:Connect(function()onSelect(v)end)
    buy.Activated:Connect(function()task.spawn(function()local ok,info=pcall(function()return Market:GetProductInfoAsync(v.Id,Enum.InfoType.Asset)end);if ok and info and info.IsForSale==true then Market:PromptPurchase(game:GetService('Players').LocalPlayer,v.Id)else U.Notify('O Roblox não confirmou disponibilidade para compra.')end end)end)
   end
   notice.Text=#(rows or{})==0 and'Nenhum item disponível. Tente outro nome.'or mode=='Background'and'Testar fundo • comprar pelo Roblox'or'Emotes do catálogo • na cópia do estúdio'
   more.Text=pages.IsFinished and'Atualizar'or'Mais';more:SetAttribute('Finished',pages.IsFinished);layout()
  end)
 end
 stop.Activated:Connect(onStop);search.Activated:Connect(function()load(false)end);query.FocusLost:Connect(function(enter)if enter then load(false)end end)
 more.Activated:Connect(function()load(not more:GetAttribute('Finished'))end);host:GetPropertyChangedSignal('AbsoluteSize'):Connect(layout)
 host.Destroying:Connect(function()ticket=ticket+1;U.CatalogMode=false end)
 layout();load(false);U.Layout()
end
return M
