-- BC_ButtonController | ModuleScript | ServerScriptService | V74 (CRIAR)
local C=require(game:GetService('ReplicatedStorage'):WaitForChild('BC_Config'))
local Registry=require(script.Parent:WaitForChild('BC_EffectRegistry'));local M={}
function M.New(ctx)
 local B={state='INATIVO',serial=0,lastIndex=0,nextAt=math.huge,expires=0,position=nil,round=nil,bad={},checkAt=0}
 local function off(state)B.state=state;ctx.arena.Show(false);ctx.arena.Prompt:SetAttribute('BC_State',state)end
 function B.Start(round)B.round=round;B.lastIndex=0;B.bad={};B.nextAt=ctx.now()+C.FirstButton;off('REPOSICIONANDO')end
 function B.Stop()B.round=nil;B.nextAt=math.huge;off('INATIVO')end
 function B.Spawn(round)
  if B.round~=round or round.phase~='ACTIVE'then return end
  local choices,valid,characters={},{},{};for _,s in pairs(round.players)do characters[#characters+1]=s.char end
  for i,pos in ipairs(ctx.arena.ButtonPositions)do
   local reachable,why=ctx.arena.Reachable(pos,characters)
   if reachable then valid[#valid+1]=i;B.bad[i]=nil
   elseif B.bad[i]~=why then B.bad[i]=why;warn('[BC][BUTTON] posição='..i..' '..tostring(why))end
  end
  for _,i in ipairs(valid)do if i~=B.lastIndex or #valid==1 then choices[#choices+1]=i end end
  if #choices==0 then warn('[BC][BUTTON] Nenhuma posição configurada.');B.nextAt=ctx.now()+C.NextButton;return end
  local index=choices[ctx.random:NextInteger(1,#choices)];local pos=ctx.arena.ButtonPositions[index]
  local ok,err=pcall(function()ctx.arena.Position(pos);ctx.arena.Show(true)end)
  if not ok then warn('[BC][BUTTON] '..tostring(err));off('REPOSICIONANDO');B.nextAt=ctx.now()+C.NextButton;return end
  B.serial=B.serial+1;B.lastIndex=index;B.position=ctx.arena.Cap.Position;B.expires=ctx.now()+C.ButtonTimeout;B.state='DISPONÍVEL';B.checkAt=ctx.now()+.5
  ctx.arena.Prompt:SetAttribute('BC_Token',B.serial);ctx.arena.Prompt:SetAttribute('BC_State',B.state)
  ctx.announce('CORRA ATÉ O BOTÃO!','Aproxime-se e toque em Apertar.',2)
 end
 function B.Press(pl)
  local round=B.round;local s=round and round.players[pl]
  if not round or round.phase~='ACTIVE'or B.state~='DISPONÍVEL'or not s or not s.alive or s.left or s.pl.Character~=s.char or s.hum.Health<=0 or not s.root.Parent then return false end
  if pl:GetAttribute('BC_MatchId')~=round.id or ctx.now()>=round.deadline or ctx.now()>=B.expires or not ctx.arena.Inside(s.root.Position,1)then return false end
  if(s.root.Position-ctx.arena.Cap.Position).Magnitude>C.PressDistance then return false end
  -- Nenhuma operação que cede execução antes da reivindicação: a primeira validação vence.
  off('ACIONADO');s.score=s.score+C.PressPoints;B.nextAt=ctx.now()+C.NextButton
  ctx.emit('buttonPress',{at=ctx.arena.Cap.Position})
  local ok,err=pcall(function()
   ctx.arena.Pressed();local effect=Registry.Draw(round,pl,ctx.random)
   if not effect then error('Sorteio sem efeitos elegíveis.')end
   round.lastEffect=effect.id;round.lastEffectName=effect.name
   ctx.announce(effect.name,'Botão acionado! '..effect.desc,2)
   ctx.execute(round,pl,effect)
  end)
  if not ok then warn('[BC][EFFECT] rodada='..round.id..' jogador='..pl.UserId..' erro='..tostring(err));ctx.announce('Efeito interrompido','O próximo botão já está sendo preparado.',2)end
  if B.round==round and round.phase=='ACTIVE'then off('REPOSICIONANDO')end
  return true
 end
 function B.Tick(round)
  if B.round~=round or not round or round.phase~='ACTIVE'then return end
  if B.state=='DISPONÍVEL'and ctx.now()>=B.checkAt then
   B.checkAt=ctx.now()+.5;local chars={};for _,s in pairs(round.players)do chars[#chars+1]=s.char end
   local good,why=ctx.arena.Reachable(ctx.arena.ButtonPositions[B.lastIndex],chars)
   if not good or not ctx.arena.Prompt.Enabled then warn('[BC][BUTTON] reposicionando: '..tostring(why or'Prompt indisponível'));off('REPOSICIONANDO');B.nextAt=ctx.now()end
  end
  if B.state=='DISPONÍVEL'and ctx.now()>=B.expires then off('REPOSICIONANDO');B.nextAt=ctx.now()end
  if B.state=='REPOSICIONANDO'and ctx.now()>=B.nextAt then B.Spawn(round)end
 end
 B.Connection=ctx.arena.Prompt.Triggered:Connect(B.Press)
 function B.Destroy()B.Stop();B.Connection:Disconnect()end
 return B
end
return M
