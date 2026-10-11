Services.RunService.Heartbeat=Services.RunService.Heartbeat or Signal()
-- Contract/geometry fixtures only; no native Roblox service, rendering or payments.
TIME60=1800000000;CLOCK60=0;os.time=function()return TIME60 end;os.clock=function()return CLOCK60 end
function advance60(n)CLOCK60=CLOCK60+n;TIME60=TIME60+n end
function task.wait(n)CLOCK60=CLOCK60+(n or .05);local q=table.remove(task.queue,1);if q then q.fn(table.unpack(q.args))end end
local types60={TShirt=2,Hat=8,Shirt=11,Pants=12,Head=17,Face=18,Torso=27,RightArm=28,LeftArm=29,LeftLeg=30,RightLeg=31,HairAccessory=41,FaceAccessory=42,NeckAccessory=43,ShoulderAccessory=44,FrontAccessory=45,BackAccessory=46,WaistAccessory=47,EmoteAnimation=61,TShirtAccessory=64,ShirtAccessory=65,PantsAccessory=66,JacketAccessory=67,SweaterAccessory=68,ShortsAccessory=69,LeftShoeAccessory=70,RightShoeAccessory=71,DressSkirtAccessory=72,EyebrowAccessory=76,EyelashAccessory=77,DynamicHead=79,AvatarBackground=92}
for n,id in pairs(types60)do Enum.AvatarAssetType[n].Value=id end;Enum.AssetType.AvatarBackground.Value=92
NativeItems60={};NativeInfo60={};NativeRequests60=0
function fixture60(id,name,group,kind)
 kind=kind or'Asset';local v={Id=id,ItemType=kind,Name=name or('Item '..id),Price=5,IsPurchasable=true}
 if kind=='Bundle'then v.BundleType='BodyParts'else v.AssetType=group or'Shirt'end
 NativeItems60[kind..':'..id]=v;NativeInfo60[id]={Name=v.Name,AssetTypeId=kind=='Asset'and types60[v.AssetType]or nil,IsForSale=true,PriceInRobux=5};return v
end
function Services.AvatarEditorService:GetItemDetailsAsync(id,kind)
 NativeRequests60=NativeRequests60+1;local key=(kind==Enum.AvatarItemType.Bundle and'Bundle'or'Asset')..':'..id
 if not NativeItems60[key]then error('unknown catalog item')end;return deep(NativeItems60[key])
end
function Services.MarketplaceService:GetProductInfoAsync(id,kind)
 if FailMarket60 or not NativeInfo60[id]then error('not available')end;return deep(NativeInfo60[id])
end
function Services.MarketplaceService:PromptPurchase(p,id)LastPrompt={kind='asset',player=p,id=id}end
function Services.MarketplaceService:PromptBundlePurchase(p,id)LastPrompt={kind='bundle',player=p,id=id}end
Sorted60={};MapReads60=0;MapWrites60=0
function Services.MemoryStoreService:GetSortedMap(name)
 Sorted60[name]=Sorted60[name]or{};local data=Sorted60[name]
 return {
 SetAsync=function(_,key,value,ttl,score)
  if FailMemory60 then error('MemoryStore unavailable')end
  assert(type(value)=='table'and type(ttl)=='number'and ttl>0 and ttl<=86400 and type(score)=='number');MapWrites60=MapWrites60+1
  data[key]={value=deep(value),sortKey=score,deadline=TIME60+ttl}
 end,
 RemoveAsync=function(_,key)if FailMemory60 then error('MemoryStore unavailable')end;data[key]=nil end,
 GetRangeAsync=function(_,direction,count,lower,upper)
  if FailMemory60 then error('MemoryStore unavailable')end;assert(direction==Enum.SortDirection.Ascending and count<=200);MapReads60=MapReads60+1
  local out={}
  local function after(key,score,bound)
   if not bound then return true end
   return score>bound.sortKey or score==bound.sortKey and bound.key~=nil and key>bound.key
  end
  local function before(key,score,bound)
   if not bound then return true end
   return score<bound.sortKey or score==bound.sortKey and bound.key~=nil and key<bound.key
  end
  for key,r in pairs(data)do if r.deadline>TIME60 and after(key,r.sortKey,lower)and before(key,r.sortKey,upper)then out[#out+1]={key=key,value=deep(r.value),sortKey=r.sortKey}end end
  table.sort(out,function(a,b)return a.sortKey<b.sortKey or a.sortKey==b.sortKey and a.key<b.key end)
  while #out>count do table.remove(out)end;return out
 end}
end
Services.AvatarEditorService.PromptAllowInventoryReadAccessCompleted=Signal()
Inventory60={};InventoryCalls60=0;PermissionCalls60=0
function Services.AvatarEditorService:PromptAllowInventoryReadAccess()
 PermissionCalls60=PermissionCalls60+1;self.PromptAllowInventoryReadAccessCompleted:Fire(DenyInventory60 and Enum.AvatarPromptResult.PermissionDenied or Enum.AvatarPromptResult.Success)
end
function Services.AvatarEditorService:GetInventoryAsync(types)
 assert(#types==1 and types[1]==Enum.AvatarAssetType.AvatarBackground);if FailInventory60 then error('inventory offline')end
 InventoryCalls60=InventoryCalls60+1;local page=1;local p={IsFinished=#Inventory60<=1}
 function p:GetCurrentPage()return deep(Inventory60[page]or{})end
 function p:AdvanceToNextPageAsync()page=page+1;self.IsFinished=page>=#Inventory60 end;return p
end
local prevType60=typeof;function typeof(v)if type(v)=='table'and v.ClassName then return'Instance'end;return prevType60(v)end
Services.AssetService={GetBundleDetailsAsync=function(_,id)local v=NativeItems60['Bundle:'..id];if not v then error('not an avatar bundle')end;return deep(v)end,LoadAssetAsync=function(_,id)
 if FailAssetLoad60 then error('not permitted')end
 local m=Instance.new('Model');local d=Instance.new('Decal');d.Texture='rbxassetid://'..id..'1';d.Parent=m;LastBackgroundContainer60=m;return m
end}
local previousContent60=Services.ContentProvider.PreloadAsync
function Services.ContentProvider:PreloadAsync(objects,fn)
 local native={};for _,o in ipairs(objects)do if not(typeof(o)=='Instance'and o:IsA('ImageLabel'))then native[#native+1]=o end end
 if #native>0 and previousContent60 then previousContent60(self,native,fn)end
 for _,o in ipairs(objects)do if typeof(o)=='Instance'and o:IsA('ImageLabel')then o.IsLoaded=not FailImage60;if fn then fn(o.Image,FailImage60 and Enum.AssetFetchStatus.Failure or Enum.AssetFetchStatus.Success)end end end
end
function installDependencies60()
 installModule('09B8_FREE_HIGHLIGHTS', [====[return {}]====])
end
