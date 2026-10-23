-- BC_Combat | ModuleScript | ServerScriptService | V75 (SUBSTITUIR)
-- Cliente envia somente direção/token. Origem, cadência, munição e vítimas são validadas aqui.
local C=require(game:GetService('ReplicatedStorage'):WaitForChild('BC_Config'))
local M={}
function M.New(ctx)
 local B={pending={}};local serial=0
 local function valid(round,s)
  return round and round.phase=='ACTIVE'and ctx.now()<round.deadline and s and s.alive and s.pl.Parent and s.pl.Character==s.char and s.hum.Health>0 and s.root.Parent and ctx.arena.Inside(s.root.Position,1)
 end
 function B.Clear(s)
  if s.weapon and s.weapon.tool then s.weapon.tool:Destroy()end;s.weapon=nil
 end
 function B.Knockback(round,actor,target,speed,lift)
  if not valid(round,actor)or not valid(round,target)or actor==target then return false end
  if target.immune>ctx.now()then return false end
  if target.shield>ctx.now()then target.shield=0;ctx.emit('shield',{user=target.pl.UserId,blocked=true});return false end
  local delta=target.root.Position-actor.root.Position;local flat=Vector3.new(delta.X,0,delta.Z)
  if flat.Magnitude<.01 then return false end
  local mass=target.root.AssemblyMass
  if type(mass)~='number'or mass~=mass or mass<=0 or mass>100000 then return false end
  local velocity=flat.Unit*math.min(speed,28)+Vector3.new(0,math.min(lift,8),0)
  pcall(function()target.root:SetNetworkOwner(nil)end)
  target.root:ApplyImpulse((velocity-target.root.AssemblyLinearVelocity)*mass)
  task.delay(.35,function()if target.root.Parent then pcall(function()target.root:SetNetworkOwnershipAuto()end)end end)
  ctx.emit('push',{from=actor.root.Position,to=target.root.Position,user=actor.pl.UserId});return true
 end
 function B.Push(round,pl)
  local s=round and round.players[pl];if not valid(round,s)or s.frozen or s.effects.freeze then return false,'Você não pode empurrar agora.'end
  local now=ctx.now();if now-(s.lastPush or -math.huge)<C.PushCooldown then return false,'Aguarde para empurrar novamente.'end
  local candidate;local nearest=C.PushDistance+.001;local facing=s.root.CFrame.LookVector
  for other,t in pairs(round.players)do if other~=pl and valid(round,t)then
   local delta=t.root.Position-s.root.Position;local distance=delta.Magnitude
   if distance>.01 and distance<nearest and facing:Dot(delta.Unit)>.15 then candidate=t;nearest=distance end
  end end
  if not candidate then return false,'Aproxime-se e olhe para outro jogador.'end
  local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={s.char};params.RespectCanCollide=true
  local hit=workspace:Raycast(s.root.Position,candidate.root.Position-s.root.Position,params)
  if hit and not hit.Instance:IsDescendantOf(candidate.char)then return false,'Há um obstáculo entre vocês.'end
  s.lastPush=now
  if not B.Knockback(round,s,candidate,C.PushSpeed,C.PushLift)then return false,'O jogador está protegido.'end
  return true
 end
 function B.Damage(round,owner,victim,amount,kind)
  local s=round.players[victim];if not valid(round,s)or type(amount)~='number'or amount<=0 or amount~=amount then return false end
  if owner then local a=round.players[owner];if not a or(owner~=victim and owner:GetAttribute('BC_MatchId')~=round.id)then return false end end
  local now=ctx.now();if s.immune>now then return false end
  if s.shield>now then s.shield=0;ctx.emit('shield',{user=victim.UserId,blocked=true});return false end
  local health=math.max(0,s.hum.Health-amount)
  if health<=0 then s.killer=owner~=victim and owner or nil;s.killKind=kind end
  s.hum.Health=health
  if health<=0 then ctx.eliminate(victim,s.killer,kind)end
  return true
 end
 function B.Grant(round,s,kind)
  B.Clear(s);serial=serial+1;local tool=Instance.new('Tool');tool.Name=kind=='E01'and'Blaster de energia'or'Bomba de espuma'
  tool.CanBeDropped=false;tool.RequiresHandle=true;tool:SetAttribute('BC_Tool',true);tool:SetAttribute('BC_WeaponToken',round.id..':'..serial)
  local handle=Instance.new('Part');handle.Name='Handle';handle.Size=kind=='E01'and Vector3.new(.7,.7,2)or Vector3.new(1.2,1.2,1.2)
  handle.Color=kind=='E01'and C.Palette.Cyan or C.Palette.Violet;handle.Material=Enum.Material.SmoothPlastic
  handle.Massless=true;handle.CanCollide=false;handle.CanTouch=false;handle.CanQuery=false;handle.Parent=tool
  if kind=='E02'then handle.Shape=Enum.PartType.Ball end
  local ring=Instance.new('Part');ring.Name='BC_GripDetail';ring.Size=Vector3.new(.84,.22,.84);ring.Color=C.Palette.Gold
  ring.Massless=true;ring.CanCollide=false;ring.CanTouch=false;ring.CanQuery=false;ring.CFrame=handle.CFrame;ring.Parent=tool
  local weld=Instance.new('WeldConstraint');weld.Part0=handle;weld.Part1=ring;weld.Parent=ring
  local pack=s.pl:FindFirstChildOfClass('Backpack');if not pack then tool:Destroy();return false end
  tool.Parent=pack;s.hum:EquipTool(tool)
  s.weapon={kind=kind,token=tool:GetAttribute('BC_WeaponToken'),ammo=kind=='E01'and 3 or 1,last=-math.huge,untilAt=ctx.now()+(kind=='E01'and 12 or 10),tool=tool}
  return true
 end
 local function direction(v)
  if typeof(v)~='Vector3' then return nil end
  for _,n in ipairs({v.X,v.Y,v.Z})do if n~=n or math.abs(n)>1e6 then return nil end end
  if v.Magnitude<.001 then return nil end;return v.Unit
 end
 function B.Shoot(round,pl,arg)
  local s=round and round.players[pl];if not valid(round,s)or type(arg)~='table'then return false,'Você não pode atacar agora.'end
  local w=s.weapon;local now=ctx.now();local dir=direction(arg.direction)
  if not w or w.token~=arg.token or now>=w.untilAt or w.ammo<=0 or not w.tool.Parent or w.tool.Parent~=s.char or not dir then return false,'Ferramenta ou mira inválida.'end
  local cadence=w.kind=='E01'and .9 or .2;if now-w.last<cadence then return false,'Aguarde o próximo disparo.'end
  w.last=now;w.ammo=w.ammo-1
  local origin=s.root.Position+Vector3.new(0,1,0);local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={s.char}
  local range=w.kind=='E01'and 55 or 50;local hit=workspace:Raycast(origin,dir*range,params);local at=hit and hit.Position or origin+dir*range
  if w.kind=='E01'then
   if hit then for victim,v in pairs(round.players)do if victim~=pl and hit.Instance:IsDescendantOf(v.char)then B.Damage(round,pl,victim,35,'weapon');break end end end
   ctx.emit('trace',{from=origin,to=at,user=pl.UserId})
  else
   at=ctx.arena.Clamp(Vector3.new(at.X,ctx.arena.Top+.7,at.Z),4)
   B.pending[#B.pending+1]={round=round,id=round.id,owner=pl,at=at,when=now+1.8}
   ctx.emit('foamThrow',{from=origin,to=at,seconds=1.8})
  end
  if w.ammo<=0 then B.Clear(s)end
  return true
 end
 function B.Tick(round)
  local now=ctx.now()
  for i=#B.pending,1,-1 do local p=B.pending[i]
   if p.round~=round or not round or round.phase~='ACTIVE'then table.remove(B.pending,i)
   elseif now>=p.when then
    table.remove(B.pending,i);ctx.emit('foam',{at=p.at})
    -- Todos os danos são processados antes da verificação de fim em RoundManager.Tick.
    for victim,s in pairs(round.players)do if s.root.Parent and(s.root.Position-p.at).Magnitude<=9 then B.Damage(round,p.owner,victim,45,'weapon')end end
   end
  end
  if round then for _,s in pairs(round.players)do if s.weapon and now>=s.weapon.untilAt then B.Clear(s)end end end
 end
 function B.Cleanup(round)B.pending={};if round then for _,s in pairs(round.players)do B.Clear(s)end end end
 return B
end
return M
