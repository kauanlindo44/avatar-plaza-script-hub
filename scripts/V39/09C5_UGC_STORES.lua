-- 09C5_UGC_STORES | ModuleScript | ReplicatedStorage
-- AVATAR PLAZA V39: vitrines reais, pesquisa por criador/grupo e paginas sem duplicatas.
local Avatar=game:GetService("AvatarEditorService")
local M={}
function M.Init(ctx)
 local U,A=ctx.U,ctx.A
 local grid,query,status=U.StoreGrid,U.StoreSearch,U.StoreStatus
 local pages=nil
 local creatorType="User"
 local token,count=0,0
 local loading=false
 local seen={}
 local function clear()
  for _,o in ipairs(grid:GetChildren())do if o:IsA("GuiObject")then o:Destroy()end end
 end
 local function resize()
  local w=grid.AbsoluteSize.X;if w<1 then return end
  local cols=math.max(1,math.floor((w-4)/158));local cw=math.floor((w-12-(cols-1)*8)/cols)
  local layout=grid:FindFirstChildOfClass("UIGridLayout")
  if layout then layout.CellSize=UDim2.fromOffset(cw,cw+58);layout.FillDirectionMaxCells=cols;layout.SortOrder=Enum.SortOrder.LayoutOrder end
 end
 local function card(item)
  if type(item)~="table"or not tonumber(item.Id)then return end
  local key=A.ItemType(item)..":"..item.Id;if seen[key]then return end;seen[key]=true;count=count+1
  local c=U.Button(grid,"",{BackgroundColor3=U.Colors.card,LayoutOrder=count})
  local im=U.New("ImageLabel",{Position=UDim2.fromOffset(6,6),Size=UDim2.new(1,-12,1,-64),BackgroundColor3=Color3.fromRGB(54,66,63),
   BorderSizePixel=0,Image=A.Thumbnail(item,420),ScaleType=Enum.ScaleType.Fit},c);U.Round(im,8)
  U.Text(c,tostring(item.Name or"Item"),{Position=UDim2.new(0,8,1,-51),Size=UDim2.new(1,-16,0,24),Font=Enum.Font.GothamBold,
   TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false})
  local p=A.Price(item);local cap=p==nil and"CONSULTAR"or p==0 and"GRÁTIS"or math.floor(p).." Robux"
  U.Text(c,cap,{Position=UDim2.new(0,8,1,-26),Size=UDim2.new(1,-16,0,20),TextColor3=U.Colors.green,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=false})
  c.Activated:Connect(function()ctx.showItem(item)end)
 end
 local function run(append)
  if append and(loading or not pages or pages.IsFinished)then return end
  if not append then token=token+1;pages=nil;seen={};count=0;clear();grid.CanvasPosition=Vector2.zero end
  local mine=token;local source=pages;local name=tostring(query.Text or""):match("^%s*(.-)%s*$")
  local kind=creatorType;loading=true;status.Text=name==""and"Buscando UGC em alta..."or("Buscando "..name.."...")
  task.spawn(function()
   local ok,items=pcall(function()
    if append then source:AdvanceToNextPageAsync()
    else
     local p=CatalogSearchParams.new();p.CategoryFilter=Enum.CatalogCategoryFilter.CommunityCreations
     p.IncludeOffSale=false;p.MinPrice=1;p.Limit=60
     p.SortType=name==""and Enum.CatalogSortType.Bestselling or Enum.CatalogSortType.Relevance
     if name~=""then p.CreatorName=name:sub(1,50);p.CreatorType=kind=="Group"and Enum.CreatorTypeFilter.Group or Enum.CreatorTypeFilter.User end
     source=Avatar:SearchCatalogAsync(p)
    end
    return source:GetCurrentPage()
   end)
   if mine~=token then return end
   loading=false
   if not ok then status.Text="Busca indisponível. Toque em BUSCAR para tentar novamente.";return end
   pages=source;for _,item in ipairs(items or{})do card(item)end;resize()
   status.Text=count==0 and"Nenhum item encontrado. Confira o nome e o tipo de criador."or(count.." itens • toque para experimentar")
  end)
 end
 U.StoreType.Activated:Connect(function()
  creatorType=creatorType=="User"and"Group"or"User";U.StoreType.Text=creatorType=="User"and"CRIADOR"or"GRUPO"
  if query.Text~=""then run(false)end
 end)
 U.StoreGo.Activated:Connect(function()run(false)end)
 query.FocusLost:Connect(function(enter)if enter then run(false)end end)
 grid:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
 grid:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
  if not U.StoresArea.Visible or loading or not pages or pages.IsFinished then return end
  if grid.CanvasPosition.Y+grid.AbsoluteWindowSize.Y>grid.AbsoluteCanvasSize.Y-180 then run(true)end
 end)
 U.StoresArea:GetPropertyChangedSignal("Visible"):Connect(function()if not U.StoresArea.Visible then token=token+1;loading=false end end)
 resize()
 return{Search=function()run(false)end}
end
return M
