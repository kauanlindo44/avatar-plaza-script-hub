-- Additional contract doubles. No claim of native privacy decisions or native rendering.
local type69=typeof
function typeof(x)if type(x)=='table'and x._player69 then return'Instance'end;return type69(x)end
pl._player69=true;function pl:IsA(c)return c=='Player'or c=='Instance'end
local make69=makePlayer
function makePlayer(id)local p=make69(id);p._player69=true;p.IsA=pl.IsA;return p end
local guid69=0
function Services.HttpService:GenerateGUID()guid69=guid69+1;return string.format('%032x',guid69)end
local old69=Instance.new
ChatMembers69={};ChatPermission69={};DirectPermission69={};ChatCalls69={send=0,add=0,direct=0};Sent69={}
Services.TextChatService=Instance.new('Folder');Services.TextChatService.Name='TextChatService'
function Services.TextChatService:CanUserChatAsync(uid)if ChatPermissionError69 then error('privacy unavailable')end;return ChatPermission69[uid]~=false end
function Services.TextChatService:CanUsersDirectChatAsync(uid,ids)
 if ChatPermissionError69 then error('privacy unavailable')end;local out={};for _,id in ipairs(ids)do if DirectPermission69[uid..':'..id]~=false then out[#out+1]=id end end;return out
end
function Instance.new(class,parent)
 local o=old69(class,parent)
 if class=='RemoteEvent'and not o.OnServerEvent then o.OnServerEvent=Signal()end
 if class=='TextChannel'then
  o.MessageReceived=Signal()
  function o:AddUserAsync(uid)
   assert(Services.Players:GetPlayerByUserId(uid),'player must be online');ChatCalls69.add=ChatCalls69.add+1
   local src=old69('TextSource');src.UserId=uid;src.CanSend=true;src.Parent=self;return src
  end
  function o:SetDirectChatRequester(p)
   assert(p.Parent==Services.Players);ChatCalls69.direct=ChatCalls69.direct+1;self.DirectChatRequester=p;self:AddUserAsync(p.UserId)
  end
  function o:SendAsync(text)
   ChatCalls69.send=ChatCalls69.send+1;Sent69[#Sent69+1]={channel=self,text=text}
   if SendDenied69 then return{Status=Enum.TextChatMessageStatus.Failure}end
   return{Status=Enum.TextChatMessageStatus.Success,Text='FILTERED'}
  end
 end
 return o
end
