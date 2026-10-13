-- 07P8_BACKGROUND_RESOLVER | ModuleScript | ServerScriptService | V61 (SUBSTITUIR)
-- Somente fundos AvatarBackground à venda; prévia nativa sem exigir compra.
local Market=game:GetService('MarketplaceService');local Assets=game:GetService('AssetService');local M={}
local active=0
local function resolve(pl,args)
 local id=tonumber(args.id)
 if not id or id~=id or id%1~=0 or id<=0 or id>9007199254740991 then error('ID de fundo inválido.',0)end
 local ok,info=pcall(function()return Market:GetProductInfoAsync(id,Enum.InfoType.Asset)end)
 if not ok or not info then error('O Roblox não confirmou o fundo de perfil.',0)end
 local got,typeId=pcall(function()return Enum.AssetType.AvatarBackground.Value end)
 if not got or tonumber(info.AssetTypeId)~=typeId then error('Este item não é um fundo de perfil do Roblox.',0)end
 if info.IsForSale~=true then error('Esse fundo não está disponível para teste na loja.',0)end
 local content='rbxassetid://'..string.format('%.0f',id);local stage='DIRECT_IMAGE'
 local loaded,model=pcall(function()return Assets:LoadAssetAsync(id)end)
 if loaded and typeof(model)=='Instance'then
  -- O recipiente nunca entra no Workspace nem em PlayerGui.
  for _,o in ipairs(model:GetDescendants())do
   local value=o:IsA('ImageLabel')and o.Image or o:IsA('ImageButton')and o.Image or o:IsA('Decal')and o.Texture or o:IsA('Texture')and o.Texture
   if type(value)=='string'and value:match('^rbxassetid://%d+$')then content=value;stage='IMAGE_REFERENCE';break end
  end
  model:Destroy()
 end
 return{id=id,name=tostring(info.Name or'Fundo Roblox'):sub(1,100),image=content,source='RobloxCatalog',preview=true,price=tonumber(info.PriceInRobux),stage=stage,thumbnail='rbxthumb://type=Asset&id='..string.format('%.0f',id)..'&w=420&h=420'}
end
function M.Resolve(pl,args)
 if active>=4 then error('A consulta de fundos está ocupada. Tente em instantes.',0)end
 active=active+1;local done=false;local ok,value
 task.spawn(function()ok,value=pcall(resolve,pl,args);active=math.max(0,active-1);done=true end)
 local untilTime=os.clock()+12;while not done and os.clock()<untilTime and pl.Parent do task.wait(.05)end
 if not done then error('O Roblox demorou na consulta da imagem de perfil. O fundo anterior foi mantido.',0)end
 if not ok then error(value,0)end;return value
end
return M
