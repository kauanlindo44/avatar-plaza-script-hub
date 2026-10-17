-- 07P8_BACKGROUND_RESOLVER | ModuleScript | ServerScriptService | V67 (SUBSTITUIR)
-- AvatarBackground é um recipiente: ImageId.Value e Color.Value, não o próprio asset de imagem.
local Market=game:GetService('MarketplaceService');local Insert=game:GetService('InsertService')
local M={Version='V67'};local cache={};local jobs={};local active=0
local function uri(value)
 local text=tostring(value or'');if text:match('^rbxasset://textures/[%w_%.%/%-]+$')then return text end
 local id=text:match('^rbxassetid://(%d+)$')or text:match('^%s*(%d+)%s*$')or text:match('^https?://www%.roblox%.com/asset/%?id=(%d+)')or text:match('^https?://roblox%.com/asset/%?id=(%d+)')
 id=tonumber(id);if id and id>0 and id%1==0 and id<=9007199254740991 then return'rbxassetid://'..string.format('%.0f',id)end
end
local function extract(model)
 local images,seen={},{};local color;local shape={}
 local function add(value)local image=uri(value);if image and not seen[image]and #images<4 then seen[image]=true;images[#images+1]=image end end
 local nodes=model:GetDescendants();table.insert(nodes,1,model)
 -- Leitura conhecida vem primeiro para evitar escolher uma miniatura do recipiente.
 for _,o in ipairs(nodes)do
  if o.Name=='ImageId'and(o:IsA('StringValue')or o:IsA('IntValue')or o:IsA('NumberValue'))then add(o.Value)end
  if o.Name=='Color'and o:IsA('Color3Value')then local c=o.Value;color={c.R,c.G,c.B}end
 end
 for index,o in ipairs(nodes)do if index>400 then break end
  if #shape<12 then shape[#shape+1]=o.ClassName..':'..o.Name end
  if o:IsA('ImageLabel')or o:IsA('ImageButton')then add(o.Image)
  elseif o:IsA('Decal')or o:IsA('Texture')then add(o.Texture)end
 end
 return images,color,table.concat(shape,',')
end
local function work(id)
 local ok,info=pcall(function()return Market:GetProductInfoAsync(id,Enum.InfoType.Asset)end)
 if not ok or not info then error('O Roblox não confirmou os dados do fundo.',0)end
 if tonumber(info.AssetTypeId)~=Enum.AssetType.AvatarBackground.Value then error('Escolha um AvatarBackground da loja Roblox.',0)end
 if info.IsForSale~=true then error('O Roblox não confirmou que esse fundo está à venda.',0)end
 local loaded,model=pcall(function()return Insert:LoadAsset(id)end)
 if not loaded or typeof(model)~='Instance'then
  warn('[Photo V67] BACKGROUND_INSERT | id='..id..' | '..tostring(model))
  error('O Roblox não liberou o recipiente desse fundo para o servidor. Tente outro fundo.',0)
 end
 local read,images,color,shape=pcall(extract,model);model:Destroy()
 if not read or #images==0 then
  warn('[Photo V67] BACKGROUND_REFERENCE | id='..id..' | '..tostring(shape or images))
  error('Esse fundo não forneceu ImageId utilizável. O formato recebido está no Output.',0)
 end
 return{version=M.Version,id=id,name=tostring(info.Name or'Fundo Roblox'):sub(1,100),image=images[1],images=images,color=color,source='RobloxCatalog',preview=true,price=tonumber(info.PriceInRobux),stage='INSERT_IMAGE_VALUE'}
end
function M.Resolve(pl,args)
 local id=tonumber(args.id);if not id or id~=id or id<=0 or id%1~=0 or id>9007199254740991 then error('ID de fundo inválido.',0)end
 local entry=cache[id];if entry and os.clock()-entry.at<300 then return entry.value end
 local job=jobs[id]
 if not job then
  if active>=4 then error('Consulta de fundos ocupada. Tente em instantes.',0)end
  job={};jobs[id]=job;active=active+1
  local function finish(ok,value)
   if job.done then return end;job.ok=ok;job.value=value;job.done=true;active=math.max(0,active-1);jobs[id]=nil
   if ok then cache[id]={at=os.clock(),value=value};local n=0;for _ in pairs(cache)do n=n+1 end;if n>100 then cache={}end end
  end
  task.delay(12,function()finish(false,'O Roblox demorou para liberar esse fundo. Tente novamente.')end)
  task.spawn(function()local ok,value=pcall(work,id);finish(ok,value)end)
 end
 local deadline=os.clock()+12;while not job.done and os.clock()<deadline and pl.Parent do task.wait(.05)end
 if not job.done then error('O Roblox demorou para liberar esse fundo. Tente outro ou recarregue.',0)end
 if not job.ok then error(job.value,0)end;return job.value
end
return M
