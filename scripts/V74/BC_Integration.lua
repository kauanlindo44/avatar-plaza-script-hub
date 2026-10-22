-- BC_Integration | ModuleScript | ServerScriptService | V74 (CRIAR)
-- Guarda ferramentas sem destruir inventário. O mesmo personagem entra na arena.
local ServerStorage=game:GetService('ServerStorage');local M={}
function M.Available(pl)
 if not pl.Parent then return false,'Jogador desconectado.'end
 if pl:GetAttribute('BC_Returning')then return false,'Aguarde o retorno ao catálogo.'end
 if pl:GetAttribute('ACP_InGameRoom')or pl:GetAttribute('ACP_Competitive')or pl:GetAttribute('ACP_TrucoRoom')or pl:GetAttribute('ACP_BoardWaiting')then
  return false,'Saia da outra sala antes de entrar no Botão do Caos.'
 end
 return true
end
function M.Enter(s,id,arena)
 local pl=s.pl;pl:SetAttribute('BC_MatchId',id);pl:SetAttribute('BC_Live',true);pl:SetAttribute('BC_Queued',nil)
 pl:SetAttribute('ACP_InGameRoom',true);pl:SetAttribute('ACP_GameType','Botão do Caos');pl:SetAttribute('ACP_PersonalFly',false)
 local stash=Instance.new('Folder');stash.Name='BC_Stored_'..pl.UserId;stash.Parent=ServerStorage;s.stash=stash
 local function hold(tool)if tool:IsA('Tool')and not tool:GetAttribute('BC_Tool')then tool.Parent=stash end end
 for _,container in ipairs({s.char,pl:FindFirstChildOfClass('Backpack')})do
  if container then for _,o in ipairs(container:GetChildren())do hold(o)end;s.connections[#s.connections+1]=container.ChildAdded:Connect(hold)end
 end
 pcall(function()pl:AddReplicationFocus(arena.Floor)end)
 pcall(function()arena.Model:AddPersistentPlayer(pl)end)
end
function M.Eliminated(s)
 s.pl:SetAttribute('BC_Live',false)
 if s.char.Parent and s.root.Parent then
  s.root.Anchored=false;s.char:PivotTo(s.original.pivot);s.root.AssemblyLinearVelocity=Vector3.zero
 end
end
function M.Return(s,arena)
 local pl=s.pl;pl:SetAttribute('BC_Returning',true)
 pcall(function()pl:RemoveReplicationFocus(arena.Floor)end)
 pcall(function()arena.Model:RemovePersistentPlayer(pl)end)
 -- A ordem evita que ajustes pessoais concorram com o encerramento dos efeitos.
 pl:SetAttribute('ACP_InGameRoom',nil);pl:SetAttribute('ACP_GameType',nil);pl:SetAttribute('BC_Live',nil);pl:SetAttribute('BC_MatchId',nil)
 if pl.Parent then pl:SetAttribute('ACP_PersonalFly',s.original.fly)end
 local stash=s.stash;s.stash=nil;local done=false;local connections={}
 local function finish()
  if done then return true end
  local backpack=pl:FindFirstChildOfClass('Backpack')
  local waiting=pl.Parent and(not backpack or pl.Character==s.char and s.hum.Health<=0)
  if waiting then return false end
  done=true;for _,c in ipairs(connections)do c:Disconnect()end
  if stash then
   for _,tool in ipairs(stash:GetChildren())do if pl.Parent then tool.Parent=backpack else tool:Destroy()end end
   stash:Destroy();stash=nil
  end
  if pl.Parent then pl:SetAttribute('BC_Returning',nil)end;return true
 end
 -- A mochila nativa pode desaparecer durante o respawn. Nunca destruir ferramentas por essa espera.
 if not finish()then
  connections[#connections+1]=pl.ChildAdded:Connect(function(o)if o:IsA('Backpack')then finish()end end)
  connections[#connections+1]=pl.CharacterAdded:Connect(function()task.defer(finish)end)
  connections[#connections+1]=pl.AncestryChanged:Connect(finish)
  task.delay(12,function()if not done and pl.Parent then warn('[BC][RETURN] Aguardando personagem/mochila nativos de '..pl.UserId..'; ferramentas preservadas no servidor.')end end)
 end
end
return M
