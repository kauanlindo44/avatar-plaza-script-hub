-- Additional native contracts missed by older doubles: catalog arrays are readonly.
local Params62=CatalogSearchParams.new
function CatalogSearchParams.new()
 local values={};local o=Params62()
 return setmetatable({}, {__index=function(_,k)
  local v=values[k];if v==nil then v=o[k]end
  if(k=='AssetTypes'or k=='BundleTypes')and type(v)=='table'then
   return setmetatable({}, {__index=v,__len=function()return #v end,__pairs=function()return pairs(v)end,__newindex=function()error('native catalog array is read only')end})
  end;return v
 end,__newindex=function(_,k,v)values[k]=v end,__pairs=function()return pairs(values)end})
end
local AudioSearch62=Services.AssetService.SearchAudioAsync
function Services.AssetService:SearchAudioAsync(p)
 assert(p.AudioSubType==Enum.AudioSubType.Music);if FailAudio61 then error('HTTP 429')end
 AudioSearchCount62=(AudioSearchCount62 or 0)+1;local index=1;local pages={IsFinished=#Audio61<=1}
 function pages:GetCurrentPage()return deep(Audio61[index]or{})end
 function pages:AdvanceToNextPageAsync()index=index+1;self.IsFinished=index>=#Audio61 end
 return pages
end
