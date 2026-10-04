-- 08B1_BODY_PACKAGES | ModuleScript | ReplicatedStorage | V49
-- O outfit nativo fornece as peças e proporções; roupas já vestidas são mantidas.
local Asset=game:GetService("AssetService")
local Avatar=game:GetService("AvatarEditorService")
local Players=game:GetService("Players")
local M={}
local bodyKeys={"Head","Torso","LeftArm","RightArm","LeftLeg","RightLeg"}
function M.Build(A,item,base)
 local id=tonumber(item and(item.Id or item.AssetId));if not id then return nil,nil,"Pacote inválido."end
 local ok,bundle=pcall(function()return Asset:GetBundleDetailsAsync(id)end)
 local items=ok and type(bundle)=="table"and bundle.Items or item.BundledItems
 if type(items)~="table"then return nil,nil,"O Roblox não carregou as peças desse pacote. Tente novamente."end
 local kind=tostring(ok and bundle and bundle.BundleType or item.BundleType or ""):gsub("^Enum.BundleType%.","")
 local body=kind=="BodyParts"or kind=="DynamicHeadAvatar";local head=kind=="DynamicHead"
 local work=A.Copy(base);local added=0;local native=nil
 for _,entry in ipairs(items)do
  if tostring(entry.Type or entry.ItemType)=="UserOutfit"and tonumber(entry.Id)then
   local got,desc=pcall(function()return Players:GetHumanoidDescriptionFromOutfitIdAsync(tonumber(entry.Id))end)
   if got and desc then local packed,value=pcall(A.Pack,desc);desc:Destroy();if packed then native=value end end
   if (body or head)and not native then return nil,nil,"Não foi possível carregar o corpo completo. Tente novamente."end
   break
  end
 end
 if native and(body or head)then
  for _,key in ipairs(bodyKeys)do if body or key=="Head"then work.props[key]=native.props[key];added=added+1 end end
  if body then work.scales=A.Copy(native.scales);work.colors=A.Copy(native.colors)end
  for _,key in ipairs(A.Props)do
   if(key=="Face"or key:find("Animation",1,true))and native.props[key]>0 then work.props[key]=native.props[key]end
  end
 end
 for _,entry in ipairs(items)do
  if tostring(entry.Type or entry.ItemType):lower():find("asset",1,true)and tonumber(entry.Id)then
   local covered=false
   if native then for _,value in pairs(native.props)do if value==tonumber(entry.Id)then covered=true;break end end end
   if not covered then
    local got,detail=pcall(function()return Avatar:GetItemDetailsAsync(tonumber(entry.Id),Enum.AvatarItemType.Asset)end)
    if not got or type(detail)~="table"then return nil,nil,"Não foi possível carregar todas as peças desse pacote."end
    local nextBody,err=A.Add(work,detail);if not nextBody then return nil,nil,err end
    work=nextBody;added=added+1
   end
  end
 end
 if added==0 then return nil,nil,"O pacote não forneceu peças vestíveis."end
 local clean,err=A.Clean(work)
 return clean,clean and(body or head)and"R15"or nil,err
end
return M
