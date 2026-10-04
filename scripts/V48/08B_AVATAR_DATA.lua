-- 08B_AVATAR_DATA
-- ModuleScript | ReplicatedStorage
-- AVATAR CREATOR PLAZA V48 - dados do avatar e bundles sem apagar as roupas existentes.
local Avatar=game:GetService("AvatarEditorService")
local Players=game:GetService("Players")
local AssetService=game:GetService("AssetService")
local M={VERSION="V41_AVATAR_DATA"}
M.Logo="rbxassetid://79546051070701"
M.MaxSaved=40
M.MaxItems=35
M.Props={
 "GraphicTShirt","Shirt","Pants","Face","Head","Torso","LeftArm","RightArm","LeftLeg","RightLeg",
 "ClimbAnimation","FallAnimation","IdleAnimation","JumpAnimation","RunAnimation","SwimAnimation","WalkAnimation","MoodAnimation"
}
M.Scales={"HeightScale","WidthScale","DepthScale","HeadScale","BodyTypeScale","ProportionScale"}
M.Colors={"HeadColor","TorsoColor","LeftArmColor","RightArmColor","LeftLegColor","RightLegColor"}
M.AssetProps={
 TShirt="GraphicTShirt",Shirt="Shirt",Pants="Pants",Face="Face",Head="Head",DynamicHead="Head",
 Torso="Torso",LeftArm="LeftArm",RightArm="RightArm",LeftLeg="LeftLeg",RightLeg="RightLeg",
 ClimbAnimation="ClimbAnimation",FallAnimation="FallAnimation",IdleAnimation="IdleAnimation",
 JumpAnimation="JumpAnimation",RunAnimation="RunAnimation",SwimAnimation="SwimAnimation",
 WalkAnimation="WalkAnimation",MoodAnimation="MoodAnimation"
}
M.Groups={
 {name="TODOS",subs={
  {"MARKETPLACE INTEIRO"},
  {"DESTAQUES",category="Featured"},{"RECOMENDADOS",category="Recommended"},{"COMUNIDADE",category="CommunityCreations"},
  {"PREMIUM",sales="Premium"},{"TEMPO LIMITADO",sales="TimedOptions"}
 }},
 {name="ROUPAS",subs={
  {"TODAS AS ROUPAS",assets={"TShirt","Shirt","Pants","TShirtAccessory","ShirtAccessory","PantsAccessory","JacketAccessory","SweaterAccessory","ShortsAccessory","LeftShoeAccessory","RightShoeAccessory","DressSkirtAccessory"}},
  {"CAMISETAS CLÁSSICAS",assets={"TShirt"}},{"CAMISAS CLÁSSICAS",assets={"Shirt"}},{"CALÇAS CLÁSSICAS",assets={"Pants"}},
  {"CAMISETAS 3D",assets={"TShirtAccessory"}},{"CAMISAS 3D",assets={"ShirtAccessory"}},{"CALÇAS 3D",assets={"PantsAccessory"}},
  {"CASACOS",assets={"JacketAccessory"}},{"SUÉTERES",assets={"SweaterAccessory"}},{"SHORTS",assets={"ShortsAccessory"}},
  {"SAPATO ESQUERDO",assets={"LeftShoeAccessory"}},{"SAPATO DIREITO",assets={"RightShoeAccessory"}},{"SAPATOS / BUNDLES",bundles={"Shoes"}},
  {"VESTIDOS E SAIAS",assets={"DressSkirtAccessory"}}
 }},
 {name="ACESSÓRIOS",subs={
  {"TODOS OS ACESSÓRIOS",assets={"Hat","HairAccessory","FaceAccessory","NeckAccessory","ShoulderAccessory","FrontAccessory","BackAccessory","WaistAccessory","EyebrowAccessory","EyelashAccessory"}},
  {"CHAPÉUS",assets={"Hat"}},{"CABELOS",assets={"HairAccessory"}},{"ROSTO",assets={"FaceAccessory"}},{"PESCOÇO",assets={"NeckAccessory"}},
  {"OMBRO",assets={"ShoulderAccessory"}},{"FRENTE",assets={"FrontAccessory"}},{"COSTAS",assets={"BackAccessory"}},{"CINTURA",assets={"WaistAccessory"}},
  {"SOBRANCELHAS",assets={"EyebrowAccessory"}},{"CÍLIOS",assets={"EyelashAccessory"}}
 }},
 {name="CABEÇA E ROSTO",subs={
  {"TUDO DE CABEÇA",assets={"Head","Face","DynamicHead","EyebrowAccessory","EyelashAccessory","FaceMakeup","LipMakeup","EyeMakeup"}},
  {"CABEÇAS CLÁSSICAS",assets={"Head"}},{"ROSTOS CLÁSSICOS",assets={"Face"}},{"CABEÇAS DINÂMICAS",assets={"DynamicHead"},bundles={"DynamicHead"}},
  {"MAQUIAGEM DE ROSTO",assets={"FaceMakeup"}},{"MAQUIAGEM DE BOCA",assets={"LipMakeup"}},{"MAQUIAGEM DE OLHOS",assets={"EyeMakeup"}},
  {"BUNDLES CABEÇA DINÂMICA",bundles={"DynamicHead"}}
 }},
 {name="CORPO",subs={
  {"TODOS OS CORPOS",bundles={"BodyParts","DynamicHeadAvatar"}},
  {"TORSO",assets={"Torso"}},{"BRAÇO DIREITO",assets={"RightArm"}},{"BRAÇO ESQUERDO",assets={"LeftArm"}},
  {"PERNA ESQUERDA",assets={"LeftLeg"}},{"PERNA DIREITA",assets={"RightLeg"}},
  {"PACOTES DE CORPO",bundles={"BodyParts"}},{"AVATARES DINÂMICOS",bundles={"DynamicHeadAvatar"}},
  {"MEMES / CRIATURAS",bundles={"BodyParts","DynamicHeadAvatar"},keyword="meme"},{"CORPOS GRÁTIS",bundles={"BodyParts","DynamicHeadAvatar"},free=true}
 }},
 {name="ANIMAÇÕES",subs={
  {"TODAS AS ANIMAÇÕES",assets={"ClimbAnimation","FallAnimation","IdleAnimation","JumpAnimation","RunAnimation","SwimAnimation","WalkAnimation","EmoteAnimation","MoodAnimation"},bundles={"Animations"}},
  {"PACOTES DE ANIMAÇÃO",bundles={"Animations"}},{"EMOTES",assets={"EmoteAnimation"}},{"HUMOR",assets={"MoodAnimation"}},
  {"ESCALAR",assets={"ClimbAnimation"}},{"CAIR",assets={"FallAnimation"}},{"PARADO / IDLE",assets={"IdleAnimation"}},
  {"PULAR",assets={"JumpAnimation"}},{"CORRER",assets={"RunAnimation"}},{"NADAR",assets={"SwimAnimation"}},{"ANDAR",assets={"WalkAnimation"}}
 }},
 {name="LIMITEDS",subs={
  {"TODOS LIMITEDS",sales="Collectibles"},{"COM REVENDA",sales="Collectibles",resale=true},
  {"UGC LIMITED",sales="Collectibles",kind="ugc"},{"ROBLOX LIMITED",sales="Collectibles",kind="roblox"}
 }},
 {name="GRÁTIS",subs={{"TODOS GRÁTIS",free=true}}},
 {name="GEAR",subs={{"TODOS OS GEARS",assets={"Gear"}}}},
 {name="EXTRAS",subs={
  {"FUNDOS DE AVATAR",assets={"AvatarBackground"}},
  {"TODOS OS BUNDLES",bundles={"BodyParts","Animations","Shoes","DynamicHead","DynamicHeadAvatar"}},
  {"BODY PARTS",bundles={"BodyParts"}},{"SHOES",bundles={"Shoes"}},{"DYNAMIC HEAD",bundles={"DynamicHead"}},{"DYNAMIC AVATAR",bundles={"DynamicHeadAvatar"}}
 }}
}
M.Sorts={"Relevance","Bestselling","RecentlyCreated","MostFavorited","PriceLowToHigh","PriceHighToLow"}
local function validNumber(v,lo,hi)
 return type(v)=="number" and v==v and v>=lo and v<=hi
end
local function validId(v)
 return validNumber(v,0,9007199254740991) and v%1==0
end
local function enumValue(enumTable,name)
 local ok,value=pcall(function() return enumTable[name] end)
 if ok then return value end
 return nil
end
local function copy(t)
 local o={}
 for k,v in pairs(t or {}) do o[k]=type(v)=="table" and copy(v) or v end
 return o
end
M.Copy=copy
function M.Pack(desc)
 local d={props={},scales={},colors={},accessories={},emotes={}}
 for _,k in ipairs(M.Props) do d.props[k]=tonumber(desc[k]) or 0 end
 for _,k in ipairs(M.Scales) do d.scales[k]=tonumber(desc[k]) or 1 end
 for _,k in ipairs(M.Colors) do
  local c=desc[k]
  d.colors[k]={c.R,c.G,c.B}
 end
 for _,v in ipairs(desc:GetAccessories(true)) do
  table.insert(d.accessories,{
   id=v.AssetId,type=v.AccessoryType.Name,layer=v.IsLayered==true,
   order=v.Order or 0,puff=v.Puffiness or 0
  })
 end
 local ok,emotes=pcall(function() return desc:GetEmotes() end)
 if ok and type(emotes)=="table" then
  for _,ids in pairs(emotes) do
   for _,id in ipairs(ids) do
    if #d.emotes<8 and validId(id) and id>0 then table.insert(d.emotes,id) end
   end
  end
 end
 return d
end
function M.Clean(raw)
 if type(raw)~="table" then return nil,"Skin inválida." end
 local d={props={},scales={},colors={},accessories={},emotes={}}
 for _,k in ipairs(M.Props) do
  local v=type(raw.props)=="table" and raw.props[k] or 0
  if not validId(v) then return nil,"ID inválido na skin." end
  d.props[k]=v
 end
 for _,k in ipairs(M.Scales) do
  local v=type(raw.scales)=="table" and raw.scales[k] or 1
  if not validNumber(v,0,2) then return nil,"Escala inválida." end
  d.scales[k]=v
 end
 for _,k in ipairs(M.Colors) do
  local v=type(raw.colors)=="table" and raw.colors[k] or {1,1,1}
  if type(v)~="table" or not validNumber(v[1],0,1) or not validNumber(v[2],0,1) or not validNumber(v[3],0,1) then
   return nil,"Cor inválida."
  end
  d.colors[k]={v[1],v[2],v[3]}
 end
 if type(raw.accessories)~="table" or #raw.accessories>20 then return nil,"Acessórios demais." end
 local seen={}
 for _,v in ipairs(raw.accessories) do
  if type(v)~="table" or not validId(v.id) or v.id<=0 or type(v.type)~="string" then return nil,"Acessório inválido." end
  local kind=enumValue(Enum.AccessoryType,v.type)
  if kind and kind~=Enum.AccessoryType.Unknown and not seen[v.id] then
   seen[v.id]=true
   local ord=math.clamp(math.floor(tonumber(v.order)or(#d.accessories+1)),0,100);local puff=math.clamp(tonumber(v.puff)or 0,-1,1)
   table.insert(d.accessories,{id=v.id,type=kind.Name,layer=v.layer==true,order=ord,puff=puff})
  end
 end
 if type(raw.emotes)=="table" then
  for i,v in ipairs(raw.emotes) do
   if i>8 then break end
   if validId(v) and v>0 then table.insert(d.emotes,v) end
  end
 end
 if #M.Entries(d)>M.MaxItems then return nil,"Itens demais na combinação." end
 return d
end
function M.Unpack(raw)
 local d,err=M.Clean(raw)
 if not d then error(err) end
 local desc=Instance.new("HumanoidDescription")
 for k,v in pairs(d.props) do desc[k]=v end
 for k,v in pairs(d.scales) do desc[k]=v end
 for k,v in pairs(d.colors) do desc[k]=Color3.new(v[1],v[2],v[3]) end
 local acc={}
 for i,v in ipairs(d.accessories) do
  local entry={AssetId=v.id,AccessoryType=Enum.AccessoryType[v.type],IsLayered=v.layer}
  if v.layer then entry.Order=tonumber(v.order)or i;entry.Puffiness=tonumber(v.puff)or 0 end
  table.insert(acc,entry)
 end
 desc:SetAccessories(acc,true)
 if #d.emotes>0 then
  local em={}
  for i,v in ipairs(d.emotes) do em["Emote"..i]={v} end
  pcall(function() desc:SetEmotes(em) end)
 end
 return desc
end
function M.Entries(d)
 local out,seen={},{}
 local function add(id,slot)
  if type(id)=="number" and id>0 and not seen[id] then
   seen[id]=true
   table.insert(out,{Id=id,Slot=slot})
  end
 end
 for _,k in ipairs(M.Props) do add((d.props or {})[k],k) end
 for _,v in ipairs(d.accessories or {}) do add(v.id,v.type) end
 for _,v in ipairs(d.emotes or {}) do add(v,"Emote") end
 return out
end
function M.Blank(d)
 d=copy(d)
 d.props=d.props or {}
 d.props.GraphicTShirt=0
 d.props.Shirt=0
 d.props.Pants=0
 d.accessories={}
 d.emotes={}
 return M.Clean(d)
end
function M.Remove(d,itemId)
 d=copy(d)
 for k,v in pairs(d.props or {}) do if v==itemId then d.props[k]=0 end end
 for i=#(d.accessories or {}),1,-1 do if d.accessories[i].id==itemId then table.remove(d.accessories,i) end end
 for i=#(d.emotes or {}),1,-1 do if d.emotes[i]==itemId then table.remove(d.emotes,i) end end
 return d
end
local function assetTypeName(item)
 local raw=item and item.AssetType
 if typeof(raw)=="EnumItem" then return raw.Name end
 if type(raw)=="table" then raw=raw.Name or raw.Id end
 if type(raw)=="number" then
  for _,e in ipairs(Enum.AvatarAssetType:GetEnumItems()) do if e.Value==raw then return e.Name end end
 end
 return tostring(raw or "")
end
function M.Add(d,item)
 if type(item)~="table" or not tonumber(item.Id) then return nil,"Item inválido." end
 d=M.Remove(copy(d),tonumber(item.Id))
 local assetType=assetTypeName(item)
 local prop=M.AssetProps[assetType]
 if prop then
  d.props[prop]=tonumber(item.Id)
 elseif assetType=="EmoteAnimation" then
  if #d.emotes>=8 then table.remove(d.emotes,1) end
  table.insert(d.emotes,tonumber(item.Id))
 else
  local av=enumValue(Enum.AvatarAssetType,assetType)
  if not av then return nil,"Esse tipo não pode ser vestido na prévia." end
  local ok,kind=pcall(function() return Avatar:GetAccessoryType(av) end)
  if not ok or not kind or kind==Enum.AccessoryType.Unknown then return nil,"Esse item não é vestível nesta prévia." end
  local layered={TShirt=true,Shirt=true,Pants=true,Jacket=true,Sweater=true,Shorts=true,LeftShoe=true,RightShoe=true,DressSkirt=true}
  local ord=0;for _,v in ipairs(d.accessories)do ord=math.max(ord,tonumber(v.order)or 0)end
  table.insert(d.accessories,{id=tonumber(item.Id),type=kind.Name,layer=layered[kind.Name]==true,order=ord+1,puff=0})
 end
 return M.Clean(d)
end
function M.BundleBody(item,base)
 local bundleId=tonumber(item and(item.Id or item.AssetId))
 if not bundleId then return nil,nil,"Pacote 3D inválido."end
 local items=nil
 local ok,bundle=pcall(function()return AssetService:GetBundleDetailsAsync(bundleId)end)
 if ok and type(bundle)=="table"and type(bundle.Items)=="table"then items=bundle.Items end
 if type(items)~="table"and type(item.BundledItems)=="table"then items=item.BundledItems end
 items=type(items)=="table"and items or{}
 local work=M.Copy(base or{})
 local added=0
 for _,entry in ipairs(items)do
  local kind=string.lower(tostring(entry.Type or entry.ItemType or""))
  if kind:find("asset",1,true)and tonumber(entry.Id)then
   local got,detail=pcall(function()return Avatar:GetItemDetailsAsync(tonumber(entry.Id),Enum.AvatarItemType.Asset)end)
   if not got or type(detail)~="table"then return nil,nil,"Não foi possível carregar todas as peças desse pacote."end
   local nextData,err=M.Add(work,detail)
   if not nextData then return nil,nil,err end
   work=nextData;added=added+1
  end
 end
 if added==0 then return nil,nil,"Essa skin 3D não forneceu um avatar utilizável."end
 if bundle and tostring(bundle.BundleType)=="BodyParts"or bundle and tostring(bundle.BundleType)=="DynamicHeadAvatar"then
  for _,entry in ipairs(items)do if tostring(entry.Type or entry.ItemType)=="UserOutfit"and tonumber(entry.Id)then
   local got,desc=pcall(function()return Players:GetHumanoidDescriptionFromOutfitIdAsync(tonumber(entry.Id))end)
   if got and desc then local valid,native=pcall(M.Pack,desc);desc:Destroy()
    if valid and native then work.scales=native.scales;work.colors=native.colors end
   end;break
  end end
 end
 local clean,err=M.Clean(work)
 return clean,clean and"R15"or nil,err
end
function M.ItemType(item)
 local raw=item and item.ItemType
 if typeof(raw)=="EnumItem" then return raw==Enum.AvatarItemType.Bundle and "Bundle" or "Asset" end
 return string.find(string.lower(tostring(raw or "")),"bundle",1,true) and "Bundle" or "Asset"
end
function M.ItemEnum(item)
 return M.ItemType(item)=="Bundle" and Enum.AvatarItemType.Bundle or Enum.AvatarItemType.Asset
end
function M.Thumbnail(item,size)
 local id=tonumber(item and (item.Id or item.AssetId)) or 0
 local kind=M.ItemType(item)=="Bundle" and "BundleThumbnail" or "Asset"
 size=size or 420
 return "rbxthumb://type="..kind.."&id="..id.."&w="..size.."&h="..size
end
function M.AssetThumb(id,size)
 size=size or 150
 return "rbxthumb://type=Asset&id="..tostring(id).."&w="..size.."&h="..size
end
function M.Price(item)
 if not item then return nil end
 if item.UnitsAvailableForConsumption==0 and item.HasResellers then
  return tonumber(item.LowestResalePrice) or tonumber(item.LowestPrice)
 end
 local status=string.lower(tostring(item.PriceStatus or ""))
 if status=="free" then return 0 end
 return tonumber(item.Price) or tonumber(item.LowestResalePrice) or tonumber(item.LowestPrice)
end
function M.PriceText(item)
 local p=M.Price(item)
 if p==nil then return "Consultar" end
 return p==0 and "GRÁTIS" or tostring(math.floor(p)).." R$"
end
function M.BuildParams(groupIndex,subIndex,query,sortIndex,minText,maxText,creator,creatorType,itemMode,limitedMode,formatMode,includeOffSale)
 local group=M.Groups[groupIndex] or M.Groups[1]
 local sub=group.subs[subIndex] or group.subs[1]
 local p=CatalogSearchParams.new()
 p.Limit=120
 p.SearchKeyword=tostring(query or ""):sub(1,100);if p.SearchKeyword==""and sub.keyword then p.SearchKeyword=sub.keyword end
 p.IncludeOffSale=includeOffSale==true
 local lo=tonumber(minText);local hi=tonumber(maxText)
 local freeCategory=(group.name=="GRÁTIS" or sub.free==true)
 if freeCategory then
  p.MinPrice=0
  p.MaxPrice=0
 else
  p.MinPrice=math.max(0,math.floor(lo or 0))
  p.MaxPrice=math.max(p.MinPrice,math.floor(hi or 2147483647))
 end
 local assets=sub.assets and copy(sub.assets) or nil
 if formatMode=="2D" or formatMode=="Classic" then assets={"TShirt","Shirt","Pants"}
 elseif formatMode=="3D" then assets={"TShirtAccessory","ShirtAccessory","PantsAccessory","JacketAccessory","SweaterAccessory","ShortsAccessory","LeftShoeAccessory","RightShoeAccessory","DressSkirtAccessory"} end
 if assets then
  local list={}
  for _,name in ipairs(assets) do local value=enumValue(Enum.AvatarAssetType,name);if value then table.insert(list,value) end end
  p.AssetTypes=list
 end
 if sub.bundles and not (formatMode=="2D" or formatMode=="Classic" or formatMode=="3D") then
  local list={}
  for _,name in ipairs(sub.bundles) do local value=enumValue(Enum.BundleType,name);if value then table.insert(list,value) end end
  p.BundleTypes=list
 end
 local saleName=limitedMode=="Only" and "Collectibles" or sub.sales
 if saleName then local sale=enumValue(Enum.SalesTypeFilter,saleName);if sale then p.SalesTypeFilter=sale end end
 local category=sub.category and enumValue(Enum.CatalogCategoryFilter,sub.category)
 if category then p.CategoryFilter=category end
 creator=tostring(creator or ""):match("^%s*(.-)%s*$")
 if creator~="" then
  p.CreatorName=creator:sub(1,50)
  p.CreatorType=enumValue(Enum.CreatorTypeFilter,creatorType or "All") or Enum.CreatorTypeFilter.All
 end
 local sortName=sub.sort or M.Sorts[sortIndex or 1] or "Relevance"
 p.SortType=enumValue(Enum.CatalogSortType,sortName) or Enum.CatalogSortType.Relevance
 if sortName=="Bestselling" or sortName=="MostFavorited" then p.SortAggregation=Enum.CatalogSortAggregation.PastWeek end
 return p,sub,{
  item=itemMode,
  limited=limitedMode,
  format=formatMode,
  freeCategory=freeCategory
 }
end
function M.PostFilter(item,sub,filter)
 if not item then return false end
 local restrictions=item.ItemRestrictions or {};local parts={}
 for _,v in ipairs(restrictions) do table.insert(parts,string.lower(tostring(v))) end
 local text=table.concat(parts,",")
 local collectible=text:find("collectible",1,true)~=nil or text:find("limited",1,true)~=nil or item.HasResellers==true or item.IsLimited==true or item.IsLimitedUnique==true or tonumber(item.CollectibleItemId)~=nil or type(item.CollectibleItemId)=="string"and item.CollectibleItemId~=""
 if sub then
  if sub.kind=="ugc" and tostring(item.CreatorName or "")=="Roblox" then return false end
  if sub.kind=="roblox" and tostring(item.CreatorName or "")~="Roblox" then return false end
  if sub.resale and item.HasResellers~=true then return false end
 end
 filter=filter or {}
 if filter.limited=="Only" and not collectible then return false end
 if filter.limited=="Exclude" and collectible then return false end
 local price=M.Price(item)
 if filter.freeCategory==true and price~=0 then return false end
 if filter.item=="Free" and price~=0 then return false end
 if filter.item=="Paid" and (not price or price<=0) then return false end
 return true
end
return M
