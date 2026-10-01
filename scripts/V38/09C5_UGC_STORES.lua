-- 09C5_UGC_STORES
-- ModuleScript | ReplicatedStorage
-- AVATAR PLAZA V38 - Lojas UGC com descoberta útil + busca por criador/grupo.

local Avatar=game:GetService("AvatarEditorService")
local M={}

function M.Init(ctx)
 local U,A=ctx and ctx.U,ctx and ctx.A
 local toast=ctx and ctx.toast or function()end
 local showItem=ctx and ctx.showItem or function()end
 if not U or not A then return{Search=function()end}end
 local grid,search,status,typeBtn,go=U.StoreGrid,U.StoreSearch,U.StoreStatus,U.StoreType,U.StoreGo
 if not grid or not search or not status then return{Search=function()toast("Lojas ainda não estão prontas.")end}end
 local creatorType,pages,loading="User",nil,false
 local function clear()for _,c in ipairs(grid:GetChildren())do if c:IsA("GuiObject")then c:Destroy()end end end
 local function rawPrice(item)local p=A.Price(item);return p end
 local function price(item)local p=rawPrice(item);if p==nil then return"VER PREÇO"end;return p<=0 and"GRÁTIS"or tostring(math.floor(p)).." R$"end
 local function card(item)
  if type(item)~="table"then return end
  local c=U.Button(grid,"",{BackgroundColor3=Color3.fromRGB(34,35,39),AutoButtonColor=false});c.Text="";U.Round(c,10);U.New("UIStroke",{Color=Color3.fromRGB(72,74,80),Transparency=.66,Thickness=1},c)
  local im=U.New("ImageLabel",{Position=UDim2.fromOffset(6,6),Size=UDim2.new(1,-12,1,-42),BackgroundColor3=Color3.fromRGB(49,50,55),BorderSizePixel=0,Image=A.Thumbnail(item,420),ScaleType=Enum.ScaleType.Fit},c);U.Round(im,8)
  U.Text(c,tostring(item.Name or"Item"),{Position=UDim2.new(0,8,1,-34),Size=UDim2.new(1,-16,0,17),Font=Enum.Font.GothamBold,TextSize=7,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false})
  local dot=U.New("Frame",{Position=UDim2.new(0,8,1,-14),Size=UDim2.fromOffset(6,6),BackgroundColor3=U.Colors.green,BorderSizePixel=0},c);U.Round(dot,99)
  U.Text(c,price(item),{Position=UDim2.new(0,18,1,-19),Size=UDim2.new(1,-26,0,15),TextColor3=Color3.fromRGB(223,226,231),Font=Enum.Font.GothamBold,TextSize=7,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=false})
  c.Activated:Connect(function()showItem(item)end)
 end
 local function draw(items,append)if not append then clear()end;for _,item in ipairs(items or{})do card(item)end end
 local function enumCreator()return creatorType=="Group"and Enum.CreatorTypeFilter.Group or Enum.CreatorTypeFilter.User end
 local function run(nextPage)
  if loading then return end;loading=true;local name=tostring(search.Text or""):match("^%s*(.-)%s*$");status.Text=name==""and"Descobrindo itens UGC em alta..."or("Abrindo vitrine de "..name.."...")
  local ok,res=pcall(function()
   if nextPage and pages then if pages.IsFinished then return{}end;pages:AdvanceToNextPageAsync();return pages:GetCurrentPage()end
   local p=CatalogSearchParams.new();p.CategoryFilter=Enum.CatalogCategoryFilter.CommunityCreations;p.IncludeOffSale=false;p.MinPrice=1;p.SortType=name==""and Enum.CatalogSortType.Bestselling or Enum.CatalogSortType.Relevance
   if name~=""then p.CreatorName=name;p.CreatorType=enumCreator()end
   pages=Avatar:SearchCatalogAsync(p);return pages:GetCurrentPage()
  end)
  if ok then draw(res,nextPage);if #res==0 then status.Text=name==""and"Nenhum destaque UGC encontrado agora."or"Nenhum item encontrado para esse criador/grupo."else status.Text=name==""and"UGC em alta • toque em um item para ver detalhes"or("Vitrine de "..name.." • toque em um item")end else if not nextPage then clear()end;status.Text="Não foi possível abrir esta vitrine.";toast("A busca de Lojas UGC falhou.")end;loading=false
 end
 if typeBtn and typeBtn:IsA("GuiButton")then typeBtn.Activated:Connect(function()creatorType=creatorType=="User"and"Group"or"User";typeBtn.Text=creatorType=="User"and"CRIADOR"or"GRUPO"end)end
 if go and go:IsA("GuiButton")then go.Activated:Connect(function()pages=nil;run(false)end)end
 search.FocusLost:Connect(function(enter)if enter then pages=nil;run(false)end end)
 grid:GetPropertyChangedSignal("CanvasPosition"):Connect(function()if loading or not pages or pages.IsFinished then return end;local y=grid.CanvasPosition.Y+grid.AbsoluteWindowSize.Y;if y>grid.AbsoluteCanvasSize.Y-280 then task.defer(function()run(true)end)end end)
 task.defer(function()if search.Text==""then run(false)end end)
 print("[V38] 09C5_UGC_STORES descoberta + criador carregado")
 return{Search=function()pages=nil;run(false)end}
end
return M
