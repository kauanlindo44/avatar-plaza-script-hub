-- 07P7_ROBLOX_BACKGROUNDS | ModuleScript | ReplicatedStorage | V60 (NOVO)
-- Inventário nativo autorizado e imagem confirmada antes de substituir o fundo.
local Avatar=game:GetService('AvatarEditorService');local Content=game:GetService('ContentProvider');local Rep=game:GetService('ReplicatedStorage')
local M={};local pages;local pending={};local allowed={};local requesting=false;local permission=false
function M.Inventory(nextPage)
 if requesting then return nil,'Aguarde a consulta de fundos.'end;requesting=true
 local function finish(v,e)requesting=false;return v,e end
 local ok,assetType=pcall(function()return Enum.AvatarAssetType.AvatarBackground end)
 if not ok or not assetType then return finish(nil,'Esta versão do Roblox ainda não disponibiliza fundos de perfil para experiências.')end
 if not permission then
  local result;local connection=Avatar.PromptAllowInventoryReadAccessCompleted:Connect(function(v)result=v end)
  local prompted=pcall(function()Avatar:PromptAllowInventoryReadAccess()end)
  local limit=os.clock()+25;while prompted and result==nil and os.clock()<limit do task.wait(.05)end;connection:Disconnect()
  if not prompted or result~=Enum.AvatarPromptResult.Success then return finish(nil,'Autorize a leitura do inventário no pedido do Roblox para escolher seus fundos.')end
  permission=true
 end
 local source,buffer=pages,pending;local done=false;local worked,rows;task.spawn(function()worked,rows=pcall(function()
  if nextPage and #buffer>0 then return buffer
  elseif nextPage and source and not source.IsFinished then source:AdvanceToNextPageAsync()
  else source=Avatar:GetInventoryAsync({assetType})end
  buffer=source:GetCurrentPage();return buffer
 end);done=true end)
 local untilTime=os.clock()+12;while not done and os.clock()<untilTime do task.wait(.05)end
 if not done or not worked then pages=nil;pending={};return finish(nil,'O Roblox não respondeu ao inventário de fundos. Toque em Recarregar.')end
 pages=source;pending=buffer
 local result={};local inspected=0;while #pending>0 and #result<6 and inspected<100 do local v=table.remove(pending,1);inspected=inspected+1;local id=tonumber(v.AssetId or v.Id)
  if id and id>0 then allowed[id]=true;result[#result+1]={id=id,name=tostring(v.Name or'Fundo Roblox'),source='RobloxProfile',owned=true,thumbnail='rbxthumb://type=Asset&id='..id..'&w=420&h=420'}end
 end
 return finish({items=result,finished=pages.IsFinished and #pending==0,empty=#result==0})
end
function M.Image(background,alive)
 local id=background and tonumber(background.id)
 if not id or not allowed[id]or background.source~='RobloxProfile'then return nil,'Escolha um fundo da consulta nativa do Roblox.'end
 local rem=Rep:FindFirstChild('LMShop_Remotes');local rpc=rem and rem:FindFirstChild('Request')
 if not rpc then return nil,'O servidor de fundos ainda não conectou.'end
 local done=false;local ok,r;task.spawn(function()ok,r=pcall(function()return rpc:InvokeServer('PhotoBackground',{id=id})end);done=true end)
 local waitUntil=os.clock()+15;while not done and os.clock()<waitUntil and(not alive or alive())do task.wait(.05)end
 if not done then return nil,'O servidor de fundos demorou. O fundo anterior foi mantido; toque novamente para tentar.'end
 if alive and not alive()then return nil,'Seleção cancelada.'end
 if not ok or not r or not r.ok then return nil,r and r.error or'O Roblox não confirmou esse fundo.'end
 local value=r.data;if not value or value.source~='RobloxProfile'or value.owned~=true or not tostring(value.image):match('^rbxassetid://%d+$')then return nil,'A referência do fundo não foi confirmada.'end
 local probe=Instance.new('ImageLabel');probe.Image=value.image
 local fetched=false;local finished=false;local loaded;task.spawn(function()loaded=pcall(function()Content:PreloadAsync({probe},function(_,status)fetched=status==Enum.AssetFetchStatus.Success end)end);finished=true end)
 local deadline=os.clock()+8
 while(not finished or not probe.IsLoaded)and os.clock()<deadline and(not alive or alive())do task.wait(.05)end
 local success=finished and loaded and fetched and probe.IsLoaded;probe:Destroy()
 if alive and not alive()then return nil,'Seleção cancelada.'end
 if not success then warn('[V60 PhotoBackground] id='..id..' etapa=IMAGE_DECODE resolver='..tostring(value.stage));return nil,'O Roblox reconheceu o fundo, mas não liberou uma imagem utilizável neste jogo. O fundo anterior foi mantido.'end
 background.image=value.image;background.name=value.name;return background
end
return M
