-- 09C5_UGC_STORES | ModuleScript | ReplicatedStorage | V48
-- Vitrine Limiteds: filtro nativo e confirmação de collectible em cada resultado.
local Avatar=game:GetService("AvatarEditorService")
local D=require(game:GetService("ReplicatedStorage"):WaitForChild("07UI_DESIGN_SYSTEM"))
local M={}
function M.Init(ctx)
 local U,A=ctx.U,ctx.A;local C=U.Colors
 local grid,query,status=U.StoreGrid,U.StoreSearch,U.StoreStatus
 local pages;local sort=1;local token,count=0,0;local loading=false;local seen={};local slots={}
 local header=query.Parent;header.BackgroundColor3=Color3.fromRGB(32,29,20)
 query.PlaceholderText="Buscar Limiteds por nome…";U.StoreType.Text="POPULARES";U.StoreGo.Text="BUSCAR"
 local caption=U.Text(header,"LIMITEDS",{Name="LimitedMarketLabel",Font=Enum.Font.GothamBold,TextColor3=C.yellow,TextSize=17,TextXAlignment=Enum.TextXAlignment.Left})
 local more=U.Button(U.StoresArea,"Carregar mais",{Name="MoreLimiteds",TextSize=12,BackgroundColor3=Color3.fromRGB(75,66,37)})
 local function clear()slots={};for _,o in ipairs(grid:GetChildren())do if o:IsA("GuiObject")then o:Destroy()end end end
 local function resize()
  local w,h=U.StoresArea.AbsoluteSize.X,U.StoresArea.AbsoluteSize.Y;if w<1 then return end
  header.AnchorPoint=Vector2.zero;header.Position=UDim2.fromOffset(6,4);header.Size=UDim2.fromOffset(w-12,80)
  caption.Position=UDim2.fromOffset(8,2);caption.Size=UDim2.fromOffset(w-28,24)
  query.AnchorPoint=Vector2.zero;query.Position=UDim2.fromOffset(8,30);query.Size=UDim2.fromOffset(w-206,44)
  U.StoreType.AnchorPoint=Vector2.zero;U.StoreType.Position=UDim2.fromOffset(w-190,30);U.StoreType.Size=UDim2.fromOffset(98,44);U.StoreType.TextSize=11
  U.StoreGo.AnchorPoint=Vector2.zero;U.StoreGo.Position=UDim2.fromOffset(w-86,30);U.StoreGo.Size=UDim2.fromOffset(66,44)
  grid.Position=UDim2.fromOffset(6,90);grid.Size=UDim2.fromOffset(w-12,math.max(70,h-144))
  status.AnchorPoint=Vector2.zero;status.Position=UDim2.fromOffset(8,h-48);status.Size=UDim2.fromOffset(w-158,44);status.TextSize=11
  more.Position=UDim2.fromOffset(w-146,h-48);more.Size=UDim2.fromOffset(138,44)
  local gw,gh=grid.AbsoluteSize.X,grid.AbsoluteSize.Y;local cols=gw>=800 and 3 or gw>=430 and 2 or 1
  local cw=math.floor((gw-4-(cols-1)*8)/cols);local ch=math.max(86,math.floor((gh-8)/2))
  local layout=grid:FindFirstChildOfClass("UIGridLayout");if layout then layout.CellSize=UDim2.fromOffset(cw,ch);layout.CellPadding=UDim2.fromOffset(8,8);layout.FillDirectionMaxCells=cols;layout.SortOrder=Enum.SortOrder.LayoutOrder end
  for _,s in ipairs(slots)do
   local iw=math.min(ch-8,cw*.48);s.image.Position=UDim2.fromOffset(4,4);s.image.Size=UDim2.fromOffset(iw,ch-8)
   local x=iw+12;local rw=cw-x-8;s.tag.Position=UDim2.fromOffset(x,4);s.tag.Size=UDim2.fromOffset(rw,18)
   s.name.Position=UDim2.fromOffset(x,24);s.name.Size=UDim2.fromOffset(rw,math.max(20,ch-54))
   s.price.Position=UDim2.fromOffset(x,ch-28);s.price.Size=UDim2.fromOffset(rw,24)
  end
 end
 local function card(item)
  if type(item)~="table"or not tonumber(item.Id)or not A.PostFilter(item,nil,{limited="Only"})then return end
  local key=A.ItemType(item)..":"..item.Id;if seen[key]then return end;seen[key]=true;count=count+1
  local c=U.Button(grid,"",{Name="Limited_"..item.Id,BackgroundColor3=Color3.fromRGB(29,29,24),LayoutOrder=count})
  local pad=c:FindFirstChildOfClass("UIPadding");if pad then pad:Destroy()end;D.Stroke(c,C.yellow,.7,1)
  local im=U.New("ImageLabel",{Name="LimitedThumbnail",BackgroundColor3=Color3.fromRGB(98,105,106),BorderSizePixel=0,Image=A.Thumbnail(item,420),ScaleType=Enum.ScaleType.Fit,Active=false},c);U.Round(im,8)
  local tag=U.Text(c,"LIMITED",{TextSize=10,Font=Enum.Font.GothamBold,TextColor3=C.yellow,TextXAlignment=Enum.TextXAlignment.Left,Active=false})
  local name=U.Text(c,tostring(item.Name or"Limited"),{TextSize=14,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Active=false})
  local p=A.Price(item);local price=U.Text(c,p==nil and"Ver preço"or p==0 and"GRÁTIS"or math.floor(p).." Robux",{TextSize=15,Font=Enum.Font.GothamBold,TextColor3=C.green,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=false,Active=false})
  slots[#slots+1]={image=im,tag=tag,name=name,price=price};c.Activated:Connect(function()ctx.showItem(item,c)end)
 end
 local function run(append)
  if loading or append and(not pages or pages.IsFinished)then return end
  if not append then token=token+1;pages=nil;seen={};count=0;clear();grid.CanvasPosition=Vector2.zero end
  local mine=token;local source=pages;loading=true;status.Text="Buscando Limiteds…";more.Text="Carregando…";more.Active=false
  task.spawn(function()
   local ok,items=pcall(function()
    if append then source:AdvanceToNextPageAsync()else
     local p=CatalogSearchParams.new();p.SalesTypeFilter=Enum.SalesTypeFilter.Collectibles;p.IncludeOffSale=false;p.Limit=60
     p.SearchKeyword=tostring(query.Text or""):sub(1,100);p.SortType=sort==1 and Enum.CatalogSortType.Bestselling or Enum.CatalogSortType.PriceLowToHigh
     if sort==1 then p.SortAggregation=Enum.CatalogSortAggregation.PastWeek end;source=Avatar:SearchCatalogAsync(p)
    end;return source:GetCurrentPage()
   end)
   if mine~=token then return end;loading=false;more.Active=true;more.Text="Carregar mais"
   if not ok then status.Text="O Roblox não respondeu. Tente BUSCAR novamente.";return end
   pages=source;for _,item in ipairs(items or{})do card(item)end;resize();more.Active=not pages.IsFinished
   status.Text=count==0 and"Nenhum Limited nesta busca."or(count.." Limiteds · toque para experimentar")
  end)
 end
 U.StoreType.Activated:Connect(function()if loading then return end;sort=3-sort;U.StoreType.Text=sort==1 and"POPULARES"or"MENOR PREÇO";run(false)end)
 U.StoreGo.Activated:Connect(function()run(false)end);more.Activated:Connect(function()run(pages~=nil)end)
 query.FocusLost:Connect(function(enter)if enter then run(false)end end)
 U.StoresArea:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
 U.StoresArea:GetPropertyChangedSignal("Visible"):Connect(function()if not U.StoresArea.Visible then token=token+1;loading=false end end)
 resize();return{Search=function()run(false)end}
end
return M
