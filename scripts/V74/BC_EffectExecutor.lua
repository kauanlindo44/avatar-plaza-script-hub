-- BC_EffectExecutor | ModuleScript | ServerScriptService | V74 (CRIAR)
local C=require(game:GetService('ReplicatedStorage'):WaitForChild('BC_Config'))
local State=require(script.Parent:WaitForChild('BC_PlayerState'));local M={}
function M.New(ctx)
 local E={pending={}}
 local function enemy(round,actor)
  local list={};for pl,s in pairs(round.players)do if pl~=actor and s.alive and s.hum.Health>0 and pl.Parent then list[#list+1]=s end end
  table.sort(list,function(a,b)return a.pl.UserId<b.pl.UserId end);if #list==0 then return nil end;return list[ctx.random:NextInteger(1,#list)]
 end
 function E.Execute(round,actor,e)
  local s=round.players[actor];if not s or not s.alive then return end
  local now=ctx.now();local id=e.id;local target=e.target and enemy(round,actor)or nil
  if e.target and not target then return end
  if id=='E01'or id=='E02'then if not ctx.combat.Grant(round,s,id)then error('Não foi possível equipar a ferramenta temporária.')end
  elseif id=='E03'then
   round.nuclearUsed=true;local n={round=round,target=target.pl,owner=actor,when=now+4};E.pending[#E.pending+1]=n
   round.nuclear={target=target.pl.UserId,name=target.pl.DisplayName,untilAt=n.when};ctx.announce('ALERTA: BOMBA NUCLEAR',target.pl.DisplayName..' · 4 segundos',4)
   ctx.emit('nuclearMark',{user=target.pl.UserId,seconds=4})
  elseif id=='E04'then State.Buff(target,'freeze',now+3,e.name);ctx.emit('freeze',{user=target.pl.UserId,seconds=3})
  elseif id=='E05'then State.Buff(s,'speed',now+9,e.name)
  elseif id=='E06'then s.shield=now+12;ctx.emit('shield',{user=actor.UserId,seconds=12})
  elseif id=='E07'then
   local a,b=s.root.CFrame,target.root.CFrame;local ignore={};for _,v in pairs(round.players)do ignore[#ignore+1]=v.char end
   if ctx.arena.Safe(a.Position,ignore)and ctx.arena.Safe(b.Position,ignore)then
    s.char:PivotTo(b*s.root.CFrame:Inverse()*s.char:GetPivot());target.char:PivotTo(a*target.root.CFrame:Inverse()*target.char:GetPivot())
    for _,v in ipairs({s,target})do v.root.AssemblyLinearVelocity=Vector3.zero;v.lastSafe=v.root.CFrame;v.immune=now+.75 end
    ctx.emit('swap',{from=a.Position,to=b.Position})
   else ctx.announce('Troca cancelada','Os destinos não estavam seguros.',2)end
  elseif id=='E08'then State.Buff(s,'jump',now+8,e.name)
  elseif id=='E09'then
   for pl,v in pairs(round.players)do if pl~=actor and v.alive then
    local delta=v.root.Position-s.root.Position;local flat=Vector3.new(delta.X,0,delta.Z)
    if flat.Magnitude<=14 and flat.Magnitude>.01 then
     local at=ctx.arena.Clamp(v.root.Position+flat.Unit*8,5);local ignore={s.char,v.char}
     if ctx.arena.Safe(at,ignore)then v.char:PivotTo(CFrame.new(at-v.root.Position)*v.char:GetPivot());v.root.AssemblyLinearVelocity=Vector3.zero;v.lastSafe=v.root.CFrame end
    end
   end end
   ctx.emit('wave',{at=s.root.Position,radius=14})
  elseif id=='E10'then State.Buff(s,'slow',now+5,e.name)
  elseif id=='E11'then s.hum.Health=math.min(100,s.hum.Health+50);ctx.emit('heal',{user=actor.UserId})
  elseif id=='E12'then round.blackoutUntil=now+5;ctx.emit('blackout',{seconds=5})
  else error('Efeito não registrado: '..tostring(id))end
  for _,v in pairs(round.players)do State.Recalculate(v,now)end
 end
 function E.Tick(round)
  for i=#E.pending,1,-1 do local n=E.pending[i]
   if n.round~=round or not round or round.phase~='ACTIVE'then table.remove(E.pending,i)
   elseif ctx.now()>=n.when then
    table.remove(E.pending,i);round.nuclear=nil;local target=round.players[n.target]
    if target and target.alive and target.pl.Parent then ctx.emit('nuclear',{at=target.root.Position,user=n.target.UserId});ctx.combat.Damage(round,n.owner,n.target,10000,'nuclear')end
   end
  end
 end
 function E.Cleanup()E.pending={}end
 return E
end
return M
