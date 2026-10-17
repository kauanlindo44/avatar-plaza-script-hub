-- 09B12_PRIVATE_LOOKS | ModuleScript | ServerScriptService | V68 (SUBSTITUIR)
-- Cache por sessão, migração tolerante e falha de leitura nunca vira lista vazia salva.
local DS=game:GetService('DataStoreService');local Players=game:GetService('Players');local Rep=game:GetService('ReplicatedStorage')
local A=require(Rep:WaitForChild('08B_AVATAR_DATA'));local Budget=require(script.Parent:WaitForChild('09B11_DATA_BUDGET'))
local store=DS:GetDataStore('AvatarShop08_Private_v1');local M={Version='V68'};local sessions={}
local function normalize(raw)
 if raw~=nil and(type(raw)~='table'or type(raw.skins)~='table')then error('Formato de looks inválido; dados anteriores preservados.')end
 local d={version=1,skins={},catalogFavorites={}};local bad=0
 for _,s in ipairs(raw and raw.skins or{})do
  if type(s)=='table'and type(s.id)=='string'and type(s.body)=='table'then
   local body=A.Clean(s.body)
   if body then local skin=A.Copy(s);skin.body=body;skin.rig=A.BodyRequiresR15(body)and'R15'or s.rig=='R6'and'R6'or'R15';d.skins[#d.skins+1]=skin else bad=bad+1 end
  else bad=bad+1 end
 end
 for _,v in ipairs(raw and raw.catalogFavorites or{})do
  if type(v)=='table'and type(v.Id)=='number'and v.Id>0 and v.Id%1==0 and #d.catalogFavorites<80 then d.catalogFavorites[#d.catalogFavorites+1]={Id=v.Id,Name=tostring(v.Name or'Item'):sub(1,100),ItemType=v.ItemType=='Bundle'and'Bundle'or'Asset',AssetType=v.AssetType}end
 end
 return d,bad
end
local function state(pl)
 if not sessions[pl]then sessions[pl]={data={version=1,skins={}},ready=false,retry=0}end;return sessions[pl]
end
function M.Load(pl)
 local s=state(pl);if s.ready then return A.Copy(s.data),true,false,s.bad end
 if s.loading or os.clock()<s.retry then return A.Copy(s.data),false,true,s.bad end
 s.loading=true
 local ok,data=Budget.Run('Read',false,function()return store:GetAsync('u_'..pl.UserId)end)
 if ok then local valid,clean,bad=pcall(normalize,data);ok=valid;if valid then s.data=clean;s.bad=bad;s.ready=true;if bad>0 then warn('[Looks V68] INVALID_RECORDS user='..pl.UserId..' count='..bad..' storage=AvatarShop08_Private_v1 key=u_'..pl.UserId)end else warn('[Looks V68] LOAD '..pl.UserId..' '..tostring(clean))end end
 s.loading=false;if not ok then s.retry=os.clock()+3 end
 return A.Copy(s.data),s.ready,not s.ready,s.bad
end
function M.Update(pl,fn)
 local _,ready=M.Load(pl);local s=state(pl)
 if not ready then error('Seus looks ainda não carregaram. Toque em Recarregar antes de salvar ou excluir.')end
 if(s.bad or 0)>0 then error('Há um look antigo inválido. A edição foi bloqueada para preservar seus dados; veja [Looks V68] no Output.')end
 fn(A.Copy(s.data)) -- Confere limites/ID antes de consumir orçamento de gravação.
 local ok,data,why=Budget.Run('Write',false,function()return store:UpdateAsync('u_'..pl.UserId,function(old)
  local clean,bad=normalize(old);if bad>0 then error('Look antigo inválido; alteração cancelada.')end
  return fn(clean)
 end)end)
 if not ok or not data then error(why or'Alteração não confirmada; seus looks anteriores foram mantidos.')end
 s.data=normalize(data);s.ready=true;return A.Copy(s.data),true
end
Players.PlayerRemoving:Connect(function(pl)sessions[pl]=nil end)
return M
