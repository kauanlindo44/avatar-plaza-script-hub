-- 08B3_AVATAR_VERIFY | ModuleScript | ReplicatedStorage | V58 (SUBSTITUIR)
-- Confere a instância exata e a classificação aplicada, sem exigir WrapLayer de cabelo rígido.
local M={VERSION='V58'}
M.LayerTypes={TShirt=true,Shirt=true,Pants=true,Jacket=true,Sweater=true,Shorts=true,LeftShoe=true,RightShoe=true,DressSkirt=true}
local function fail(item,check,cause,expected,found,kind)
 local id=item and item.id;local typ=item and item.type
 local message=(id and('Item # '..id..' ('..tostring(typ)..'): ')or'')..cause
 return false,message,{stage='LAYERS',source='08B3_AVATAR_VERIFY.Check',kind=kind or'validation',
  itemId=id,itemType=typ,check=check,expected=expected,found=found}
end
local function typeName(v)local ok,n=pcall(function()return v.Name end);return ok and n or tostring(v)end
local function attached(model,instance)
 if not instance or not instance:IsA('Accessory')then return false end
 local p=instance.Parent
 while p do if p==model then return true end;if p:IsA('Tool')then return false end;p=p.Parent end
 return false
end
local function cage(model)
 for _,p in ipairs(model:GetDescendants())do
  if p:IsA('MeshPart')and not p:FindFirstAncestorOfClass('Accessory')and not p:FindFirstAncestorOfClass('Tool')and p:FindFirstChildOfClass('WrapTarget')then return true end
 end
 return false
end
local function onServer()local ok,v=pcall(function()return game:GetService('RunService'):IsServer()end);return ok and v end
function M.Stamp(model)
 if not onServer()then return end
 local hum=model and model:FindFirstChildOfClass('Humanoid');local desc=hum and hum:FindFirstChildOfClass('HumanoidDescription')
 if not desc then return end
 for _,row in ipairs(desc:GetChildren())do if row:IsA('AccessoryDescription')then
  local ok,instance=pcall(function()return row:GetAppliedInstance()end)
  if ok and attached(model,instance)then instance:SetAttribute('ACP_VerifiedAssetId',row.AssetId)end
 end end
end
function M.Replicated(model)
 local ids={}
 if onServer()or not model:GetAttribute('ACP_AvatarEpoch')or not model:GetAttribute('ACP_AvatarTrace')then return ids end
 for _,v in ipairs(model:GetChildren())do if v:IsA('Accessory')then
  local id=v:GetAttribute('ACP_VerifiedAssetId');if type(id)=='number'and id>0 then ids[id]=typeName(v.AccessoryType)end
 end end;return ids
end
local function replicatedInstance(model,id)
 if not M.Replicated(model)[id]then return nil end
 for _,v in ipairs(model:GetChildren())do if v:IsA('Accessory')and v:GetAttribute('ACP_VerifiedAssetId')==id then return v end end
end
function M.Check(model,body,rig,options)
 options=options or{};local hum=model and model:FindFirstChildOfClass('Humanoid')
 if not hum or not model:FindFirstChild('HumanoidRootPart')then return fail(nil,'STRUCTURE','Avatar incompleto.','Humanoid e HumanoidRootPart','Parte ausente')end
 local expected={};for _,v in ipairs(body.accessories or{})do if v.layer or M.LayerTypes[v.type]then expected[#expected+1]=v end end
 if #expected==0 then return true end
 table.sort(expected,function(a,b)return a.id<b.id end)
 local records={};local description=hum:FindFirstChildOfClass('HumanoidDescription')
 if description then for _,v in ipairs(description:GetChildren())do if v:IsA('AccessoryDescription')then records[v.AssetId]=v end end end
 local actual={}
 if options.applied then for _,v in ipairs(options.applied:GetAccessories(true))do actual[v.AssetId]=v end end
 for _,item in ipairs(expected)do
  local row=records[item.id];local ok,instance
  if row then ok,instance=pcall(function()return row:GetAppliedInstance()end)end
  -- Histórico local pode estar vazio após uma criação/aplicação feita no servidor.
  -- O ID abaixo foi gravado pelo servidor na instância exata, depois da validação.
  if not ok or not attached(model,instance)then local replicated=replicatedInstance(model,item.id);if replicated then ok,instance=true,replicated end end
  if not row and not instance then return fail(item,'APPLIED_DESCRIPTION','Descrição aplicada do acessório ainda não chegou.','AccessoryDescription ou instância confirmada pelo servidor','Descrição ausente')end
  if not ok then return fail(item,'GET_APPLIED_INSTANCE',tostring(instance),'GetAppliedInstance disponível','Erro na chamada nativa','roblox')end
  if not attached(model,instance)then return fail(item,'APPLIED_INSTANCE','A instância exata ainda não está aplicada ao personagem.','Accessory deste ID no personagem',instance and instance.ClassName or'nil')end
  local canonical=actual[item.id];local layered
  if row and type(row.IsLayered)=='boolean'then layered=row.IsLayered
  elseif canonical and type(canonical.IsLayered)=='boolean'then layered=canonical.IsLayered
  else layered=item.layer==true end
  -- Tipos de roupa 3D mantêm suas exigências, mesmo com metadado incompleto.
  layered=layered or M.LayerTypes[item.type]==true
  local physicalType=typeName(instance.AccessoryType)
  if physicalType~='Unknown'and physicalType~=item.type then return fail(item,'ACCESSORY_TYPE','Tipo da instância diferente do solicitado.',item.type,physicalType)end
  local handle=instance:FindFirstChild('Handle')
  if not handle or not handle:IsA('BasePart')then return fail(item,'HANDLE','Handle físico ausente.','Handle BasePart',handle and handle.ClassName or'nil')end
  if handle.Transparency>=1 then return fail(item,'VISIBILITY','Handle totalmente transparente.','Transparency menor que 1',tostring(handle.Transparency))end
  local mesh=handle:IsA('MeshPart')and handle or handle:FindFirstChildOfClass('SpecialMesh')
  if mesh then
   local file=handle:IsA('MeshPart')or typeName(mesh.MeshType)=='FileMesh'
   if file and(type(mesh.MeshId)~='string'or mesh.MeshId=='')then return fail(item,'MESH','ID da malha está vazio.','MeshId preenchido',mesh.MeshId==''and'"" (vazio)'or tostring(mesh.MeshId))end
  end
  if layered then
   if hum.RigType.Name~='R15'then return fail(item,'RIG','Este acessório em camadas exige R15.','R15',hum.RigType.Name)end
   if not handle:IsA('MeshPart')then return fail(item,'LAYER_HANDLE','Roupa em camadas sem Handle MeshPart.','MeshPart',handle.ClassName)end
   local layer=handle:FindFirstChildOfClass('WrapLayer')
   if not layer then return fail(item,'WRAP_LAYER','WrapLayer ausente na roupa 3D.','WrapLayer no Handle','nil')end
   if not layer.Enabled then return fail(item,'WRAP_ENABLED','WrapLayer está desativado.','Enabled=true','Enabled=false')end
   if not cage(model)then return fail(item,'BODY_CAGE','Corpo sem WrapTarget para encaixar a roupa 3D.','WrapTarget no corpo','WrapTarget ausente')end
  end
 end
 return true
end
return M
