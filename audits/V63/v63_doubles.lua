-- Extra contracts for destinations; these are service doubles, not live Roblox.
Enum.AssetType.Place.Value=9
Services.GroupService=Services.GroupService or{};Groups63={}
function Services.GroupService:GetGroupInfoAsync(id)if not Groups63[id]then error('unknown community')end;return deep(Groups63[id])end
function Services.GroupService:PromptJoinAsync(id)GroupPrompt63=id;return Enum.GroupMembershipStatus.Joined end
Services.SocialService=Services.SocialService or{}
function Services.SocialService:GetUpcomingExperienceEventsAsync()return Events63 or{}end
function Services.SocialService:PromptRsvpToEventAsync(id)EventPrompt63=id end
local oldMap=Services.MemoryStoreService.GetSortedMap
function Services.MemoryStoreService:GetSortedMap(name)
 local map=oldMap(self,name)
 if name~='AvatarPlaza_Destinations_v1'then return map end
 function map:GetRangeAsync(direction,count,lower,upper)
  assert(direction==Enum.SortDirection.Descending);if FailMemory60 then error('offline')end
  local out={}
  for key,r in pairs(Sorted60[name])do
   local below=not upper or r.sortKey<upper.sortKey or r.sortKey==upper.sortKey and upper.key and key<upper.key
   if r.deadline>TIME60 and below then out[#out+1]={key=key,value=deep(r.value),sortKey=r.sortKey}end
  end
  table.sort(out,function(a,b)return a.sortKey>b.sortKey or a.sortKey==b.sortKey and a.key>b.key end)
  while #out>count do table.remove(out)end;return out
 end
 return map
end
function seed63()
 NativeInfo60[83720142132483]={Name='Avatar Creator Plaza',Description='Own game',AssetTypeId=9}
 Groups63[546113316]={Id=546113316,Name='Own Community',Description='Native community description',EmblemUrl='rbxassetid://501',Shout={Body='Native announcement'}}
end
