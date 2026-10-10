-- 07M_MUSIC_SERVER | Script | ServerScriptService | V55 (NOVO)
local Rep=game:GetService('ReplicatedStorage');local Players=game:GetService('Players')
local P=require(script.Parent:WaitForChild('07M0_MUSIC_PREFS'));local last={}
local rpc=Rep:FindFirstChild('ACP_MusicRequest')or Instance.new('RemoteFunction');rpc.Name='ACP_MusicRequest';rpc.Parent=Rep
rpc.OnServerInvoke=function(pl,action,args)
 local now=os.clock();if last[pl]and now-last[pl]<.25 then return{ok=false,error='Aguarde um instante.'}end;last[pl]=now
 if args~=nil and type(args)~='table'then return{ok=false,error='Pedido inválido.'}end
 local ok,d,e=pcall(function()
  if action=='load'then return P.Load(pl.UserId)
  elseif action=='audio'then return P.Audio(args and args.id)
  elseif action=='save'and args then
   if type(args.saved)~='table'or #args.saved>24 then return nil,'São até 24 músicas salvas.'end
   for _,id in ipairs(args.saved)do local confirmed,why=P.Audio(id);if not confirmed then return nil,why end end
   return P.Save(pl.UserId,args)
  end;return nil,'Pedido desconhecido.'
 end)
 return {ok=ok and d~=nil,data=ok and d or nil,error=ok and e or'Não foi possível concluir.'}
end
Players.PlayerRemoving:Connect(function(pl)last[pl]=nil end)
