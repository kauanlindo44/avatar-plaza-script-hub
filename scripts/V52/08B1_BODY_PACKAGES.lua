-- 08B1_BODY_PACKAGES | ModuleScript | ReplicatedStorage | V51
-- Outfit nativo primeiro; extras não bloqueiam um corpo resolvido pelo Roblox.
local Asset=game:GetService("AssetService")
local Avatar=game:GetService("AvatarEditorService")
local Players=game:GetService("Players")
local M={};local cache={};local order={}
local keys={"Head","Torso","LeftArm","RightArm","LeftLeg","RightLeg"}
local function request(fn)
 for attempt=1,2 do local ok,value=pcall(fn)
  if ok and value then return value end
  if attempt<2 then task.wait(.35)end
 end
end
local function nativeOutfit(A,id)
 local saved=cache[id];if saved and os.clock()-saved.at<120 then return A.Copy(saved.body)end
 local desc=request(function()return Players:GetHumanoidDescriptionFromOutfitIdAsync(id)end)
 if not desc then return end
 local ok,body=pcall(function()return A.Clean(A.Pack(desc))end);desc:Destroy()
 if not ok or not body then return end
 if not cache[id]then order[#order+1]=id end
 cache[id]={body=A.Copy(body),at=os.clock()}
 while #order>32 do cache[table.remove(order,1)]=nil end
 return body
end
function M.Build(A,item,base)
 local id=tonumber(item and(item.Id or item.AssetId));if not id or id<=0 then return nil,nil,"Pacote inválido."end
 local bundle=request(function()return Asset:GetBundleDetailsAsync(id)end)
 local items=type(bundle)=="table"and bundle.Items or item.BundledItems
 if type(items)~="table"then return nil,nil,"O Roblox não carregou esse pacote. Tente experimentar novamente."end
 local kind=tostring(bundle and bundle.BundleType or item.BundleType or""):gsub("^Enum.BundleType%.","")
 local body=kind=="BodyParts"or kind=="DynamicHeadAvatar";local head=kind=="DynamicHead"
 local native;local outfitId
 for _,entry in ipairs(items)do if tostring(entry.Type or entry.ItemType):lower()=="useroutfit"and tonumber(entry.Id)then
  outfitId=tonumber(entry.Id);native=nativeOutfit(A,outfitId);if native then break end
 end end
 local work=A.Copy(base);local added=0
 if native and(body or head)then
  work.bodyParts=work.bodyParts or{};work.facial=native.facial
  for _,key in ipairs(keys)do if body or key=="Head"then
   work.props[key]=native.props[key];work.bodyParts[key]=native.bodyParts[key]and A.Copy(native.bodyParts[key])or nil
   if native.props[key]>0 then added=added+1 end
  end end
  if body then work.scales=A.Copy(native.scales);work.colors=A.Copy(native.colors)end
  for _,key in ipairs(A.Props)do if(key=="Face"or key:find("Animation",1,true))and native.props[key]>0 then work.props[key]=native.props[key]end end
  -- Cílios/sobrancelhas e acessórios nativos também pertencem ao pacote.
  local seen={};for _,v in ipairs(work.accessories)do seen[v.id]=true end
  for _,v in ipairs(native.accessories)do if not seen[v.id]then work.accessories[#work.accessories+1]=A.Copy(v);seen[v.id]=true end end
  local covered={};for _,v in pairs(native.props)do if v>0 then covered[v]=true end end
  for _,v in ipairs(native.accessories)do covered[v.id]=true end
  local referenced=0;local failed=false
  for _,entry in ipairs(items)do if tostring(entry.Type or entry.ItemType):lower():find("asset",1,true)and tonumber(entry.Id)then
   local assetId=tonumber(entry.Id)
   if covered[assetId]then referenced=referenced+1 else
    local detail=request(function()return Avatar:GetItemDetailsAsync(assetId,Enum.AvatarItemType.Asset)end)
    if type(detail)=="table"then
     detail.Id=assetId;local resolved=A.Add(work,detail)
     if resolved then work=resolved;referenced=referenced+1 end
    else failed=true end
   end
  end end
  if failed and referenced==0 then return nil,nil,"O Roblox não confirmou as peças desse pacote. Tente novamente."end
  if added==0 then return nil,nil,"O Roblox retornou esse pacote sem as peças do corpo. Tente novamente."end
  local clean,err=A.Clean(work);return clean,clean and"R15"or nil,err
 end
 -- Um outfit indisponível não autoriza aplicar só parte de um corpo completo.
 if (body or head)and outfitId then return nil,nil,"O Roblox não respondeu com o corpo completo. Tente experimentar novamente."end
 for _,entry in ipairs(items)do if tostring(entry.Type or entry.ItemType):lower():find("asset",1,true)and tonumber(entry.Id)then
  local detail=request(function()return Avatar:GetItemDetailsAsync(tonumber(entry.Id),Enum.AvatarItemType.Asset)end)
  if type(detail)~="table"then return nil,nil,"O Roblox não carregou uma peça desse pacote. Tente novamente."end
  local nextBody,err=A.Add(work,detail);if not nextBody then return nil,nil,err end
  work=nextBody;added=added+1
 end end
 if added==0 then return nil,nil,"O pacote não forneceu peças vestíveis."end
 local clean,err=A.Clean(work);return clean,clean and(body or head or A.BodyRequiresR15(clean))and"R15"or nil,err
end
return M
