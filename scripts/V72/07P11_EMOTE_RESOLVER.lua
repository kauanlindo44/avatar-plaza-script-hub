-- 07P11_EMOTE_RESOLVER | ModuleScript | ServerScriptService | V72 (SUBSTITUIR)
-- Resolve o item EmoteAnimation para Animation.AnimationId sem executar o recipiente.
local Market=game:GetService('MarketplaceService');local Insert=game:GetService('InsertService')
local Players=game:GetService('Players');local M={Version='V72'};local cache,jobs,last={},{},{};local active=0
function M.Resolve(pl,args)
 local id=tonumber(args.id);if not id or id~=id or id<=0 or id%1~=0 or id>9007199254740991 then error('Emote inválido.',0)end
 local slot=({IdleAnimation=true,WalkAnimation=true,RunAnimation=true,JumpAnimation=true,FallAnimation=true,ClimbAnimation=true,SwimAnimation=true})[args.slot]and args.slot or'IdleAnimation';local bundle=args.bundle==true;local key=(bundle and'B:'or'A:')..id..':'..slot
 local old=cache[key];if old and os.clock()-old.at<600 then return old.value end
 if os.clock()-(last[pl]or-10)<.5 then error('Aguarde um instante antes de trocar o emote.',0)end;last[pl]=os.clock()
 local job=jobs[key]
 if not job then
  if active>=4 then error('Consulta de emotes ocupada. Tente em instantes.',0)end
  job={};jobs[key]=job;active=active+1
  local function finish(ok,value)
   if job.done then return end;job.ok=ok;job.value=value;job.done=true;active=math.max(0,active-1);jobs[key]=nil
   if ok then cache[key]={at=os.clock(),value=value};local n=0;for _ in pairs(cache)do n=n+1 end;if n>120 then cache={}end
   else warn('[Photo V66] EMOTE_RESOLVE | id='..id..' | '..tostring(value))end
  end
  task.delay(10,function()finish(false,'EMOTE_RESOLVE_TIMEOUT')end)
  task.spawn(function()
   local ok,value=pcall(function()
    local asset=id
    if bundle then
     local detail=game:GetService('AssetService'):GetBundleDetailsAsync(id)
     if detail.BundleType~='Animations'and detail.BundleType~=Enum.BundleType.Animations then error('Escolha um pacote de animação.',0)end
     asset=nil;for i,row in ipairs(detail.Items or{})do if i>30 then break end;if row.Type=='Asset'then local info=Market:GetProductInfoAsync(row.Id,Enum.InfoType.Asset);if tonumber(info.AssetTypeId)==Enum.AvatarAssetType[slot].Value then asset=row.Id;break end end end
     if not asset then error('Esse pacote não contém '..slot..'.',0)end
    else local info=Market:GetProductInfoAsync(id,Enum.InfoType.Asset);if tonumber(info.AssetTypeId)~=Enum.AvatarAssetType.EmoteAnimation.Value then error('Escolha um emote do catálogo.',0)end end
    local model=Insert:LoadAsset(asset);local animation=model:FindFirstChildWhichIsA('Animation',true)
    local raw=animation and animation.AnimationId;model:Destroy()
    local clip=type(raw)=='string'and(raw:match('^rbxassetid://(%d+)$')or raw:match('[?&]id=(%d+)'))
    if not clip or tonumber(clip)<=0 then error('O Roblox não forneceu AnimationId para esse emote.',0)end
    return{id=id,animation='rbxassetid://'..clip,source='RobloxEmote',version=M.Version}
   end)
   finish(ok,value)
  end)
 end
 local deadline=os.clock()+10;while not job.done and os.clock()<deadline and pl.Parent do task.wait(.05)end
 if not job.done then error('O Roblox demorou para carregar o emote.',0)end
 if not job.ok then error('O Roblox não liberou a animação desse emote. Tente outro; detalhes no Output.',0)end
 return job.value
end
Players.PlayerRemoving:Connect(function(pl)last[pl]=nil end)
return M
