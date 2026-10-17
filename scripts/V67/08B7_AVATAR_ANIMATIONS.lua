-- 08B7_AVATAR_ANIMATIONS | ModuleScript | ServerScriptService | V67 (NOVO)
-- IDs do HumanoidDescription são itens de animação; resolve os clips do corpo real.
local Market=game:GetService('MarketplaceService');local Insert=game:GetService('InsertService');local Players=game:GetService('Players')
local M={Version='V67'};local cache,jobs,last={},{},{};local active=0
local keys={'IdleAnimation','WalkAnimation','RunAnimation','JumpAnimation','FallAnimation','ClimbAnimation','SwimAnimation'}
local function clip(id,limit)
 if cache[id]then return cache[id]end
 local job=jobs[id]
 if not job then
  if active>=3 then return end;job={};jobs[id]=job;active=active+1
  local function finish(value)if job.done then return end;job.done=true;job.value=value;active=math.max(0,active-1);jobs[id]=nil;if value then cache[id]=value end end
  task.delay(8,function()finish(nil)end)
  task.spawn(function()
   local ok,value=pcall(function()
    local ok,info=pcall(function()return Market:GetProductInfoAsync(id,Enum.InfoType.Asset)end)
    if ok and tonumber(info.AssetTypeId)==Enum.AssetType.Animation.Value then return{'rbxassetid://'..string.format('%.0f',id)}end
    local asset=Insert:LoadAsset(id);local values={}
    for _,v in ipairs(asset:GetDescendants())do if v:IsA('Animation')and #values<2 then local text=tostring(v.AnimationId);local clip=text:match('^rbxassetid://(%d+)$')or text:match('[?&]id=(%d+)');if clip then values[#values+1]='rbxassetid://'..clip end end end
    asset:Destroy();return #values>0 and values or nil
   end);finish(ok and value or nil)
  end)
 end
 local deadline=math.min(os.clock()+8,limit or math.huge);while not job.done and os.clock()<deadline do task.wait(.05)end
 return job.value
end
function M.Resolve(pl)
 local old=last[pl];if old and old.character==pl.Character and old.epoch==pl:GetAttribute('ACP_AvatarEpoch')and os.clock()-old.at<2 then return old.value end
 local char=pl.Character;local h=char and char:FindFirstChildOfClass('Humanoid');if not h or h.Health<=0 then error('Avatar indisponível.',0)end
 local d=h:GetAppliedDescription();local ids={};for _,key in ipairs(keys)do ids[key]=tonumber(d[key])or 0 end;d:Destroy()
 local out={version=M.Version,clips={},epoch=pl:GetAttribute('ACP_AvatarEpoch')};last[pl]={at=os.clock(),character=char,epoch=pl:GetAttribute('ACP_AvatarEpoch'),value=out}
 local limit=os.clock()+10;for _,key in ipairs(keys)do if pl.Character~=char or os.clock()>=limit then break end;local id=ids[key];if id>0 then local value=clip(id,limit);if value then out.clips[key]=value end end end
 local n=0;for _ in pairs(cache)do n=n+1 end;if n>200 then cache={}end
 return out
end
Players.PlayerRemoving:Connect(function(pl)last[pl]=nil end)
return M
