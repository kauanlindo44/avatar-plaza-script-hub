-- Reproduce the concrete native contracts shown by the new photos/research.
local ctor66=Instance.new
Instance.new=function(class)
 local o=ctor66(class)
 function o:FindFirstChildWhichIsA(kind,recursive)
  for _,v in ipairs(recursive and self:GetDescendants()or self:GetChildren())do if v:IsA(kind)then return v end end
 end
 return o
end
local make66=Services.Players.CreateHumanoidModelFromDescriptionAsync
function Services.Players:CreateHumanoidModelFromDescriptionAsync(...)
 local model=make66(self,...)
 function model.Humanoid:PlayEmoteAsync()if self.Parent~=pl.Character then error('You can only play emotes for the LocalPlayer')end;return true end
 return model
end
InsertCalls66=0;Assets66={};DeniedAssets66={}
Services.InsertService={LoadAsset=function(_,id)
 InsertCalls66=InsertCalls66+1;if DeniedAssets66[id]then error('asset not accessible')end
 local factory=Assets66[id];if not factory then error('unknown insert asset '..tostring(id))end;return factory()
end}
function background66(id,image,color)
 NativeInfo60[id]={Name='Backdrop '..id,AssetTypeId=92,IsForSale=true,PriceInRobux=5}
 Assets66[id]=function()
  local model=Instance.new('Model');local background=Instance.new('Folder');background.Name='AvatarBackground';background.Parent=model
  local v=Instance.new('StringValue');v.Name='ImageId';v.Value=image;v.Parent=background
  local c=Instance.new('Color3Value');c.Name='Color';c.Value=color or Color3.fromRGB(220,210,200);c.Parent=background
  LastInserted66=model;return model
 end
end
function emote66(id,clip)
 fixture60(id,'Emote '..id,'EmoteAnimation');Assets66[id]=function()
  local model=Instance.new('Model');local animation=Instance.new('Animation');animation.AnimationId='rbxassetid://'..clip;animation.Parent=model
  local unwanted=Instance.new('Script');unwanted.Name='NeverRun';unwanted.Parent=model;LastInserted66=model;return model
 end
end
function emoteRpc66()
 local rem=rep.LMShop_Remotes;local rpc=rem.Request or Instance.new('RemoteFunction');rpc.Name='Request';rpc.Parent=rem
 function rpc:InvokeServer(action,args)
  assert(action=='PhotoEmote');PhotoEmoteCalls66=(PhotoEmoteCalls66 or 0)+1
  if RejectEmote66 then return{ok=false,error='Native resolver rejected'}end
  return{ok=true,data={id=args.id,source='RobloxEmote',animation='rbxassetid://'..(100000+args.id)}}
 end
 return rpc
end
