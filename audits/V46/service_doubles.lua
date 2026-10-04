-- Deterministic services only. No Roblox networking, native rendering or payment.
function deep(t)if type(t)~="table"then return t end;local out={};for k,v in pairs(t)do out[k]=deep(v)end;return out end
StoreData={};FailStores=false;StoreRetry=false;local callbackDepth=0
local function asyncAllowed()assert(callbackDepth==0,'Async service call inside UpdateAsync callback')end
local function transform(fn,value)
 callbackDepth=callbackDepth+1;local ok,result=pcall(fn,value);callbackDepth=callbackDepth-1;if not ok then error(result)end;return result
end
local function getStore(name)
 StoreData[name]=StoreData[name]or{};local data=StoreData[name]
 return {
 GetAsync=function(_,key)asyncAllowed();if FailStores then error("service offline")end;return deep(data[key])end,
 SetAsync=function(_,key,value)asyncAllowed();if FailStores then error("service offline")end;data[key]=deep(value)end,
 RemoveAsync=function(_,key)asyncAllowed();data[key]=nil end,
 UpdateAsync=function(_,key,fn)asyncAllowed();if FailStores then error("service offline")end;if StoreRetry then transform(fn,deep(data[key]))end;local v=transform(fn,deep(data[key]));if v==nil then return nil end;data[key]=deep(v);return deep(v)end,
 GetSortedAsync=function(_,asc,count)asyncAllowed();local rows={};for key,v in pairs(data)do rows[#rows+1]={key=key,value=v}end;table.sort(rows,function(a,b)return asc and a.value<b.value or not asc and a.value>b.value end);while #rows>count do table.remove(rows)end;return{GetCurrentPage=function()return deep(rows)end}end
 }
end
Services.DataStoreService={GetDataStore=function(_,name)return getStore(name)end,GetOrderedDataStore=function(_,name)return getStore(name)end}
Services.MemoryStoreService={GetHashMap=function(_,name)return getStore(name)end}
Services.PolicyService={GetPolicyInfoForPlayerAsync=function()if FailPolicy then error("offline")end;return{ArePaidRandomItemsRestricted=RestrictRandom or false}end}
Services.Players.PlayerAdded=Signal();Services.MarketplaceService.PromptGamePassPurchaseFinished=Signal();Services.MarketplaceService.PromptBulkPurchaseFinished=Signal()
pl.Parent=Services.Players;pl.DisplayName="Tester";pl.CharacterAppearanceLoaded=Signal()
function Services.Players:GetPlayerByUserId(id)for _,p in ipairs(self:GetPlayers())do if p.UserId==id then return p end end end
function Services.Players:GetNameFromUserIdAsync(id)return "User"..id end
OwnedAssets={};OwnedBundles={};OwnedPasses={}
function Services.MarketplaceService:PlayerOwnsAssetAsync(_,id)return OwnedAssets[id]==true end
function Services.MarketplaceService:PlayerOwnsBundleAsync(_,id)return OwnedBundles[id]==true end
function Services.MarketplaceService:UserOwnsGamePassAsync(_,id)return OwnedPasses[id]==true end
function Services.MarketplaceService:PromptGamePassPurchase(p,id)LastPrompt={kind="pass",id=id,player=p}end
function Services.MarketplaceService:PromptProductPurchase(p,id)LastPrompt={kind="product",id=id,player=p}end
function Services.MarketplaceService:PromptBulkPurchase(p,items)LastBulk=deep(items)end
local guid=0;Services.HttpService.GenerateGUID=function()guid=guid+1;return "guid-"..guid end
game.JobId="job-A";game.PlaceId=10;game.GameId=5
pl.attributes={};pl.attributeSignals={}
function pl:GetAttribute(k)return self.attributes[k]end
function pl:GetAttributeChangedSignal(k)self.attributeSignals[k]=self.attributeSignals[k]or Signal();return self.attributeSignals[k]end
function pl:SetAttribute(k,v)local old=self.attributes[k];self.attributes[k]=v;if old~=v then self:GetAttributeChangedSignal(k):Fire()end end
local newInstance=Instance.new
Instance.new=function(class)local o=newInstance(class);if o:IsA('BasePart')then o.Color=Color3.fromRGB(163,162,165);o.Material=Enum.Material.Plastic end;return o end
Services.TeleportService={TeleportInitFailed=Signal(),TeleportAsync=function(_,place,players,options)if FailTeleport then error('offline')end;LastTeleport={place=place,players=players,options=options}end}
function Services.RunService:IsStudio()return STUDIO==true end
workspace.Gravity=196.2
local constructor=Instance.new
Instance.new=function(class)
 local o=constructor(class)
 if class=='TeleportOptions'then function o:SetTeleportData(d)self.TeleportData=d end end
 if class=='RemoteEvent'then o.sent={};function o:FireClient(p,kind,data)self.sent[#self.sent+1]={player=p,kind=kind,data=data}end end
 return o
end
function makePlayer(id)
 local p={UserId=id,Name='User'..id,DisplayName='Player '..id,Parent=Services.Players,CharacterAdded=Signal(),attributes={},attributeSignals={}}
 p.SetAttribute=pl.SetAttribute;p.GetAttribute=pl.GetAttribute;p.GetAttributeChangedSignal=pl.GetAttributeChangedSignal
 p.Character=Services.Players:CreateHumanoidModelFromDescriptionAsync(InitialDescription,Enum.HumanoidRigType.R15);p.Character.Parent=workspace
 local hum=p.Character:FindFirstChildOfClass('Humanoid');hum.Health=100
 function p:GetJoinData()return self.JoinData or{}end;return p
end
function workspace:FindFirstChildWhichIsA(class,recursive)for _,o in ipairs(recursive and self:GetDescendants()or self:GetChildren())do if o:IsA(class)then return o end end end
