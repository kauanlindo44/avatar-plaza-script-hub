-- 09B4_CURATED_LOOKS | ModuleScript | ServerScriptService | V44
-- Cosplays montados com itens reais consultados agora. Até 5 combinações distintas por referência.
-- Referência inferida dos títulos; não promete reconhecimento visual nem um milhão já curado.
local Rep=game:GetService("ReplicatedStorage")
local Avatar=game:GetService("AvatarEditorService")
local A=require(Rep:WaitForChild("08B_AVATAR_DATA"))
local Meta=require(script.Parent:WaitForChild("09B2_COSPLAY_METADATA"))
local M={};local cache={};local loading={}
local function norm(s)return tostring(s or""):lower():gsub("[%p%c]"," "):gsub("%s+"," ")end
local function matches(item,char)
 local name=" "..norm(item.Name).." "
 for _,alias in ipairs(char.aliases)do if name:find(" "..alias.." ",1,true)then return true end end;return false
end
function M.Budget(n)
 if n==nil then return"unknown"end
 if n==0 then return"free"elseif n<=55 then return"1_55"elseif n<=150 then return"56_150"elseif n<=300 then return"151_300"elseif n<=600 then return"301_600"else return"601_plus"end
end
local function search(char,assetType)
 local params=CatalogSearchParams.new();params.SearchKeyword=char.query or char.name;params.AssetTypes={assetType};params.IncludeOffSale=false
 params.SortType=Enum.CatalogSortType.Bestselling;params.Limit=30
 local pages=Avatar:SearchCatalogAsync(params);local out={}
 for _,item in ipairs(pages:GetCurrentPage())do if matches(item,char)and tonumber(item.Id)then table.insert(out,item)end end
 return out
end
local function build(char)
 local shirts=search(char,Enum.AvatarAssetType.Shirt);local pants=search(char,Enum.AvatarAssetType.Pants)
 local accessories={};local ok,extras=pcall(function()return search(char,Enum.AvatarAssetType.Hat)end);if ok then accessories=extras end
 local result={};local signatures={}
 for _,shirt in ipairs(shirts)do for _,pant in ipairs(pants)do
  if #result>=5 then return result end
  local key=shirt.Id..":"..pant.Id
  if not signatures[key]then
   local ref=Meta.Match({{id=shirt.Id,name=shirt.Name,slot="Shirt"},{id=pant.Id,name=pant.Name,slot="Pants"}})
   if ref and ref.name==char.name then
    signatures[key]=true;local desc=Instance.new("HumanoidDescription");desc.Shirt=shirt.Id;desc.Pants=pant.Id;local body=A.Pack(desc);desc:Destroy()
    local accessory=accessories[#result%math.max(1,#accessories)+1];if accessory then body=A.Add(body,accessory)or body end
    local s,p,e=A.Price(shirt),A.Price(pant),accessory and A.Price(accessory)or 0
    local total=s and p and e and(s+p+e)or nil
    table.insert(result,{id="curated:"..key,source="Curated",name=char.name.." • Traje "..(#result+1),publisher="CAETANOYX",
     username="CAETANOYX",rig="R15",body=body,character=ref,budget=M.Budget(total),total=total,checkedAt=os.time(),
     itemAuthors={shirt.CreatorName,pant.CreatorName},basis="Composição do catálogo; referência inferida dos nomes das peças"})
   end
  end
 end end
 return result
end
function M.Page(pl,args)
 local page=math.floor(tonumber(args.page)or 0);if page<0 or page>=math.ceil(#Meta.Characters/5)then return{items={},finished=true}end
 local q=norm(args.search);local out={}
 for i=page*5+1,math.min(#Meta.Characters,page*5+5)do
  local char=Meta.Characters[i]
  if q==""or norm(char.name):find(q,1,true)then
   local entry=cache[char.name]
   if not entry or os.clock()-entry.at>600 then
    if not loading[char.name]then
     loading[char.name]=true;local ok,rows=pcall(build,char);loading[char.name]=nil
     if ok then entry={at=os.clock(),rows=rows};cache[char.name]=entry end
    end
   end
   if entry then for _,r in ipairs(entry.rows)do table.insert(out,A.Copy(r))end end
  end
 end
 return {items=out,finished=page==math.ceil(#Meta.Characters/5)-1,page=page}
end
return M
