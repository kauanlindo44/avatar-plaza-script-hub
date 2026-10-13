-- 07M_MUSIC_SERVER | Script | ServerScriptService | V62 (SUBSTITUIR)
local Rep=game:GetService('ReplicatedStorage');local Players=game:GetService('Players')
local Library=require(script.Parent:WaitForChild('07M2_AUDIO_LIBRARY'))
local P=require(script.Parent:WaitForChild('07M0_MUSIC_PREFS'));local last={}
local rpc=Rep:FindFirstChild('ACP_MusicRequest')or Instance.new('RemoteFunction');rpc.Name='ACP_MusicRequest';rpc.Parent=Rep
local repAudio=Rep:FindFirstChild('ACP_AudioLibraryChanged')or Instance.new('RemoteEvent');repAudio.Name='ACP_AudioLibraryChanged';repAudio.Parent=Rep
rpc:SetAttribute('Version','V62');Library.Changed.Event:Connect(function(query)repAudio:FireAllClients(query)end)
rpc.OnServerInvoke=function(pl,action,args)
 if type(action)~='string'then return{ok=false,error='Pedido inválido.'}end
 local times=last[pl]or{};last[pl]=times;local now=os.clock();if times[action]and now-times[action]<.25 then return{ok=false,error='Aguarde um instante.'}end;times[action]=now
 if args~=nil and type(args)~='table'then return{ok=false,error='Pedido inválido.'}end
 local ok,d,e=pcall(function()
  if action=='search'then return Library.Search(pl,args or{})
  elseif action=='load'then return P.Load(pl.UserId)
  elseif action=='audio'then local meta=Library.Metadata(args and args.id);if meta then return meta end;return P.Audio(args and args.id)
  elseif action=='save'and args then
   if type(args.saved)~='table'or #args.saved>24 then return nil,'São até 24 músicas salvas.'end
   for _,id in ipairs(args.saved)do local confirmed,why=Library.Metadata(id);if not confirmed then confirmed,why=P.Audio(id)end;if not confirmed then return nil,why end end
   return P.Save(pl.UserId,args)
  end;return nil,'Pedido desconhecido.'
 end)
 return {ok=ok and d~=nil,data=ok and d or nil,error=ok and e or'Não foi possível concluir.'}
end
Players.PlayerRemoving:Connect(function(pl)last[pl]=nil end)
print('[Music V62] biblioteca='..tostring(Library.Version or'antigo')..' consulta em segundo plano')
