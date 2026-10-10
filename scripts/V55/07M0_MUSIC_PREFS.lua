-- 07M0_MUSIC_PREFS | ModuleScript | ServerScriptService | V55 (NOVO)
-- Preferências de música por usuário; somente IDs de áudio e volume limitado.
local DS=game:GetService('DataStoreService'):GetDataStore('ACP_MusicPreferences_V55')
local Market=game:GetService('MarketplaceService');local M={};local cache={}
local function valid(id)id=tonumber(id);return id and id==id and id%1==0 and id>0 and id<9007199254740991 and id end
local function clean(d)
 d=type(d)=='table'and d or{};local saved={};local seen={}
 for _,id in ipairs(type(d.saved)=='table'and d.saved or{})do id=valid(id);if id and not seen[id]and #saved<24 then saved[#saved+1]=id;seen[id]=true end end
 local volume=tonumber(d.volume);if not volume or volume~=volume then volume=.4 end
 return{volume=math.clamp(volume,0,1),saved=saved,last=valid(d.last)or 0}
end
function M.Load(id)
 local ok,d=pcall(function()return DS:GetAsync('u'..id)end)
 if not ok then return nil,'Preferências não carregaram. Você pode ouvir nesta sessão.'end
 return clean(d)
end
function M.Save(id,data)
 local nextData=clean(data);local ok=pcall(function()DS:UpdateAsync('u'..id,function()return nextData end)end)
 return ok or nil,ok and nil or'Não foi possível guardar suas preferências.'
end
function M.Audio(raw)
 local id=valid(raw);if not id then return nil,'Informe um ID de áudio válido.'end
 local c=cache[id];if c and os.clock()-c.time<180 then return c.data end
 local ok,d=pcall(function()return Market:GetProductInfoAsync(id,Enum.InfoType.Asset)end)
 if not ok or not d then return nil,'O Roblox não respondeu ou não liberou esse ID.'end
 if tonumber(d.AssetTypeId)~=3 then return nil,'Esse ID não corresponde a um áudio.'end
 local out={id=id,name=tostring(d.Name or'Áudio Roblox'):sub(1,100)};cache[id]={time=os.clock(),data=out};local n=0;for _ in pairs(cache)do n=n+1 end;if n>128 then cache={}end;return out
end
return M
