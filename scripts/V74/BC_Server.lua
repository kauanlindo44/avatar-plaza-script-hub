-- BC_Server | Script | ServerScriptService | V74 (CRIAR)
local Players=game:GetService('Players');local Rep=game:GetService('ReplicatedStorage');local Run=game:GetService('RunService')
local Http=game:GetService('HttpService');local S=script.Parent
local kit=Rep:WaitForChild('PracaKit',40);if not kit then warn('[BC][BOOT] PracaKit ausente: confira 01A_HUB_CORE_ENV.');return end
if kit:GetAttribute('BC_ServerRunning')then warn('[BC][BOOT] BC_Server duplicado. Mantenha uma única instância.');return end
local loaded,Manager=pcall(function()return require(S:WaitForChild('BC_RoundManager',20))end)
if not loaded then warn('[BC][BOOT] '..tostring(Manager));return end
local Builder=require(S:WaitForChild('BC_ArenaBuilder'));local arena=Builder.Build();local rem=kit:WaitForChild('Remotes')
local function remote(class,name)
 local r=rem:FindFirstChild(name);if r and not r:IsA(class)then error('[BC][BOOT] Tipo incorreto: '..name)end
 if not r then r=Instance.new(class);r.Name=name;r.Parent=rem end;return r
end
local rpc=remote('RemoteFunction','BC_Request');local push=remote('RemoteEvent','BC_Push');local fire=remote('RemoteEvent','BC_Fire')
local context={arena=arena,now=os.clock,random=Random.new(),serverId=Http:GenerateGUID(false),push=function(pl,kind,data)push:FireClient(pl,kind,data)end}
local Runtime=require(S:WaitForChild('09B5_AVATAR_RUNTIME'))
context.ready=function(pl)local h,description=Runtime.Description(pl);description:Destroy();return h~=nil end
local G=Manager.New(context)
kit:SetAttribute('BC_ServerRunning',true);local limits={};local lastError=-math.huge
local function rate(pl,key,delay)
 local t=limits[pl]or{};limits[pl]=t;local now=os.clock();if t[key]and now-t[key]<delay then return false end;t[key]=now;return true
end
rpc.OnServerInvoke=function(pl,action,arg)
 if type(action)~='string'or #action>16 or action=='fire'then return{ok=false,error='Pedido inválido.'}end
 if not rate(pl,'request',action=='status'and .4 or .2)then return{ok=false,error='Aguarde um instante.'}end
 local ok,allowed,value=pcall(G.Request,pl,action,arg)
 if not ok then warn('[BC][REQUEST] '..pl.UserId..' '..action..' '..tostring(allowed));return{ok=false,error='Não foi possível concluir. O erro foi registrado no servidor.'}end
 return{ok=allowed==true,data=allowed and type(value)=='table'and value or nil,error=not allowed and value or nil}
end
fire.OnServerEvent:Connect(function(pl,arg)
 if not rate(pl,'fire',.12)then return end
 local ok,err=pcall(G.Request,pl,'fire',arg);if not ok then warn('[BC][FIRE] '..pl.UserId..' '..tostring(err))end
end)
local accumulated=0
local connection=Run.Heartbeat:Connect(function(dt)
 accumulated=accumulated+dt;if accumulated<.1 then return end;accumulated=0
 local ok,err=pcall(G.Tick)
 if not ok then
  if os.clock()-lastError>3 then lastError=os.clock();warn('[BC][TICK] '..tostring(err))end
  -- Recuperação determinística: limpa poderes, restaura personagens e libera a arena.
  local watchers={};for pl in pairs(G.watchers)do watchers[#watchers+1]=pl end
  local restored,why=pcall(function()
   G.Shutdown();arena.Destroy();arena=Builder.Build();context.arena=arena;G=Manager.New(context);kit:SetAttribute('BC_ServerError',nil)
   for _,pl in ipairs(watchers)do if pl.Parent then push:FireClient(pl,'return',{});push:FireClient(pl,'error',{text='A arena foi reiniciada com segurança. Abra Nossos jogos para entrar novamente.'})end end
  end)
  if not restored then warn('[BC][RECOVERY] '..tostring(why));kit:SetAttribute('BC_ServerError',tostring(why))end
 end
end)
Players.PlayerRemoving:Connect(function(pl)G.Leave(pl);limits[pl]=nil end)
game:BindToClose(function()connection:Disconnect();G.Shutdown();arena.Destroy();kit:SetAttribute('BC_ServerRunning',nil)end)
print('[V74][BC] V1 pronta para testes nativos · arena isolada · 12 efeitos · servidor autoritativo')
