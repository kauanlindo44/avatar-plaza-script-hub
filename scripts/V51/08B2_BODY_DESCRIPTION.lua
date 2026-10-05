-- 08B2_BODY_DESCRIPTION | ModuleScript | ReplicatedStorage | V51
-- Metadados nativos dos seis assets; nenhuma Instance enviada pelo cliente.
local M={Keys={"Head","Torso","LeftArm","RightArm","LeftLeg","RightLeg"}}
local known={};for _,k in ipairs(M.Keys)do known[k]=true end
local function id(v)return type(v)=="number"and v==v and v>=0 and v<=9007199254740991 and v%1==0 end
function M.Pack(desc,d)
 d.bodyParts={};d.facial=desc.StaticFacialAnimation==true
 for _,p in ipairs(desc:GetChildren())do if p:IsA("BodyPartDescription")then
  local k=p.BodyPart.Name
  if known[k]and id(p.AssetId)then
   -- A propriedade pública é a fonte canônica; não ressuscite uma peça removida.
   local asset=d.props[k]
   if asset==p.AssetId then d.bodyParts[k]={id=asset,shape=k=="Head"and p.HeadShape or""}end
  end
 end end
end
function M.Clean(raw,d)
 d.bodyParts={};local parts=raw.bodyParts
 if raw.facial~=nil and type(raw.facial)~="boolean"then return false,"Expressão facial inválida."end
 d.facial=raw.facial
 if parts==nil then return true end
 if type(parts)~="table"then return false,"Descrição do corpo inválida."end
 local count=0
 for k,p in pairs(parts)do
  count=count+1
  if count>6 or not known[k]or type(p)~="table"or not id(p.id)then return false,"Peça do corpo inválida."end
  local shape=p.shape or""
  if type(shape)~="string"or #shape>120 or shape:find("[%c]")or(k~="Head"and shape~="")then return false,"Formato da cabeça inválido."end
  if p.id==d.props[k]then d.bodyParts[k]={id=p.id,shape=shape}end
 end
 return true
end
function M.Prepare(desc,d)
 for _,p in ipairs(desc:GetChildren())do if p:IsA("BodyPartDescription")then
  local k=p.BodyPart.Name;local row=d.bodyParts[k]
  if not known[k]or p.AssetId~=d.props[k]or(p.HeadShape~=""and(not row or row.shape~=p.HeadShape))then p:Destroy()end
 end end
end
function M.Restore(desc,d)
 if d.facial~=nil then desc.StaticFacialAnimation=d.facial end
 for k,row in pairs(d.bodyParts)do
  local part
  for _,p in ipairs(desc:GetChildren())do if p:IsA("BodyPartDescription")and p.BodyPart==Enum.BodyPart[k]then part=p;break end end
  if not part then part=Instance.new("BodyPartDescription");part.BodyPart=Enum.BodyPart[k];part.Parent=desc end
  part.AssetId=d.props[k];part.Color=desc[k.."Color"]
  if k=="Head"then part.HeadShape=row.shape end
 end
end
function M.Merge(live,before,after,result,equal,copy)
 result.bodyParts=copy(live.bodyParts or{})
 if after.facial~=before.facial then result.facial=after.facial end
 for _,k in ipairs(M.Keys)do
  if after.props[k]~=before.props[k]or not equal((before.bodyParts or{})[k],(after.bodyParts or{})[k])then
   result.bodyParts[k]=(after.bodyParts or{})[k]and copy(after.bodyParts[k])or nil
  end
 end
end
function M.Matches(desc,actual)
 for _,k in ipairs(M.Keys)do if desc[k]~=actual[k]then return false,"O Roblox não confirmou a peça "..k.." desse corpo."end end
 local shape=""
 for _,p in ipairs(actual:GetChildren())do if p:IsA("BodyPartDescription")and p.BodyPart==Enum.BodyPart.Head then shape=p.HeadShape end end
 for _,p in ipairs(desc:GetChildren())do if p:IsA("BodyPartDescription")and p.BodyPart==Enum.BodyPart.Head and p.HeadShape~=""and p.HeadShape~=shape then return false,"O Roblox não confirmou o formato da cabeça."end end
 return true
end
function M.Key(A,d,rig,floor,emote)
 local out={tostring(rig),tostring(floor),tostring(emote or 0),tostring(d.facial==true)}
 for _,k in ipairs(A.Props)do out[#out+1]=tostring(d.props[k])end
 for _,k in ipairs(A.Scales)do out[#out+1]=string.format("%.8f",d.scales[k])end
 for _,k in ipairs(A.Colors)do for _,v in ipairs(d.colors[k])do out[#out+1]=string.format("%.8f",v)end end
 local accessories={};for _,v in ipairs(d.accessories)do accessories[#accessories+1]=v end
 table.sort(accessories,function(a,b)return a.id<b.id end)
 for _,v in ipairs(accessories)do out[#out+1]=table.concat({v.id,v.type,tostring(v.layer),v.order or 0,v.puff or 0},":")end
 for _,v in ipairs(d.emotes)do out[#out+1]=tostring(v)end
 local shape=((d.bodyParts or{}).Head or{}).shape or"";out[#out+1]=#shape..":"..shape
 return table.concat(out,"|")
end
return M
