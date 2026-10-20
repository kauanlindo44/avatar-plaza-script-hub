-- 09B13_PURCHASE_HISTORY | ModuleScript | ServerScriptService | V72 (NOVO)
-- Somente compras de catálogo confirmadas nesta experiência; sem conceder benefícios.
local Market=game:GetService('MarketplaceService');local Players=game:GetService('Players');local DS=game:GetService('DataStoreService')
local Budget=require(script.Parent:WaitForChild('09B11_DATA_BUDGET'));local Store=DS:GetDataStore('ACP_CatalogPurchases_V72');local M={};local states={};local started=false
local function state(pl)local s=states[pl];if not s then s={rows={},dirty=false};states[pl]=s end;return s end
local function merge(a,b)
 local rows,seen={},{};for _,list in ipairs({a or{},b or{}})do for _,r in ipairs(list)do local key=tostring(r.kind)..':'..tostring(r.id)..':'..tostring(r.at);if not seen[key]and tonumber(r.id)and tonumber(r.at)then seen[key]=true;rows[#rows+1]=r end end end
 table.sort(rows,function(x,y)return x.at>y.at end);while #rows>80 do table.remove(rows)end;return rows
end
function M.List(pl)
 local s=state(pl);if not s.loaded then
  local ok,data=Budget.Run('Read',false,function()return Store:GetAsync('p:'..pl.UserId)end)
  if not ok then return{rows=s.rows,persistent=false,retry=true}end;s.rows=merge(s.rows,type(data)=='table'and data.rows or{});s.loaded=true
 end;return{rows=s.rows,persistent=not s.dirty}
end
local function flush(pl)
 local s=states[pl];if not s or not s.dirty or s.writing then return end;s.writing=true;local revision=s.revision;local snapshot=merge(s.rows,{})
 local ok,data=Budget.Run('Write',false,function()return Store:UpdateAsync('p:'..pl.UserId,function(old)return{rows=merge(snapshot,type(old)=='table'and old.rows or{})}end)end)
 s.writing=false;if ok then s.rows=merge(s.rows,data.rows);if s.revision==revision then s.dirty=false end end
end
local function confirmed(pl,id,kind,purchased)
 if not purchased or not pl or not pl.Parent then return end
 task.spawn(function()
  local ok,owned=pcall(function()if kind=='Bundle'then return Market:PlayerOwnsBundleAsync(pl,id)end;return Market:PlayerOwnsAssetAsync(pl,id)end);if not ok or not owned then return end
  local s=state(pl);s.rows=merge({{id=id,kind=kind,at=os.time()}},s.rows);s.dirty=true;s.revision=(s.revision or 0)+1
 end)
end
function M.Start()
 if started then return end;started=true
 Market.PromptPurchaseFinished:Connect(function(pl,id,purchased)confirmed(pl,id,'Asset',purchased)end)
 Market.PromptBundlePurchaseFinished:Connect(function(pl,id,purchased)confirmed(pl,id,'Bundle',purchased)end)
 local elapsed=0;game:GetService('RunService').Heartbeat:Connect(function(dt)elapsed=elapsed+dt;if elapsed<45 then return end;elapsed=0;for pl,s in pairs(states)do if s.dirty then task.spawn(flush,pl)end end end)
 Players.PlayerRemoving:Connect(function(pl)flush(pl);states[pl]=nil end);game:BindToClose(function()for pl in pairs(states)do flush(pl)end end)
end
return M
