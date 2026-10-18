-- 09I_ACTIVITIES_SERVER | Script | ServerScriptService | V69 (NOVO)
local Rep=game:GetService('ReplicatedStorage');local Players=game:GetService('Players')
local Activities=require(script.Parent:WaitForChild('09I14_SOCIAL_ACTIVITIES'))
local folder=Rep:FindFirstChild('ACP_ActivityRemotes')or Instance.new('Folder');folder.Name='ACP_ActivityRemotes';folder.Parent=Rep
local rpc=folder:FindFirstChild('Request')or Instance.new('RemoteFunction');rpc.Name='Request';rpc.Parent=folder
local push=folder:FindFirstChild('Update')or Instance.new('RemoteEvent');push.Name='Update';push.Parent=folder
local busy,last={},{};local handlers={status=Activities.Status,create=Activities.Create,invite=Activities.Invite,answer=Activities.Answer,
 configure=Activities.Configure,contribute=Activities.Contribute,generate=Activities.Generate,save=Activities.Save,apply=Activities.Apply,
 publish=Activities.Publish,voteremix=Activities.VoteRemix,leave=Activities.Leave,mine=function(pl)return Activities.Consent.Mine(pl)end,
 source=function(pl,d)return Activities.Consent.Own(pl,d.code)end,
 permission=function(pl,d)return Activities.Consent.SetAllowed(pl,d.code,d.allow)end}
rpc.OnServerInvoke=function(pl,action,args)
 if type(action)~='string'or not handlers[action]or args~=nil and type(args)~='table'then return{ok=false,error='Pedido inválido.'}end
 local now=os.clock();local key=pl.UserId..':'..action;local expensive={publish=true,permission=true,source=true,mine=true,generate=true,save=true,apply=true};local interval=expensive[action]and 5 or action=='create'and 3 or action=='status'and 1 or .4
 if busy[pl]or now-(last[key]or-100)<interval then return{ok=false,error='Aguarde um instante.'}end
 busy[pl]=true;last[key]=now;local ok,value,e=pcall(handlers[action],pl,args or{});busy[pl]=nil
 if not ok then warn('[Activities V69] '..action..': '..tostring(value));return{ok=false,error='A atividade não respondeu. Tente novamente.'}end
 return{ok=value~=nil and value~=false,data=value,error=e,version='V69'}
end
Activities.Bind(push);Players.PlayerRemoving:Connect(function(pl)busy[pl]=nil;for k in pairs(last)do if k:sub(1,#tostring(pl.UserId)+1)==pl.UserId..':'then last[k]=nil end end end)
