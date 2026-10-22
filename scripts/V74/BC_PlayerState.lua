-- BC_PlayerState | ModuleScript | ServerScriptService | V74 (CRIAR)
local Rep=game:GetService('ReplicatedStorage');local C=require(Rep:WaitForChild('BC_Config'))
local Move=require(Rep:WaitForChild('08B6_AVATAR_MOVEMENT'));local M={}
function M.Capture(pl)
 local char=pl.Character;local hum=char and char:FindFirstChildOfClass('Humanoid');local root=char and char:FindFirstChild('HumanoidRootPart')
 if not hum or not root or hum.Health<=0 or root.Anchored then return nil,'Aguarde seu avatar carregar em um chão seguro.'end
 local clearance,why=Move.Clearance(char);if not clearance then return nil,why end
 local s={pl=pl,char=char,hum=hum,root=root,alive=true,score=0,effects={},shield=0,immune=0,connections={},frozen=true,
 original={pivot=char:GetPivot(),max=hum.MaxHealth,health=hum.Health,speed=hum.WalkSpeed,jump=hum.JumpPower,height=hum.JumpHeight,
 usePower=hum.UseJumpPower,auto=hum.AutoRotate,platform=hum.PlatformStand,anchored=root.Anchored,fly=pl:GetAttribute('ACP_PersonalFly')},lastSafe=root.CFrame}
 return s
end
function M.Place(s,pos)
 if not s.root.Parent or not s.char.Parent then return false end
 local h=Move.Clearance(s.char);local at=pos+Vector3.new(0,h+.12,0);local face=Vector3.new(C.Center.X,at.Y,C.Center.Z)
 local target=CFrame.lookAt(at,face);s.char:PivotTo(target*s.root.CFrame:Inverse()*s.char:GetPivot())
 s.root.AssemblyLinearVelocity=Vector3.zero;s.root.AssemblyAngularVelocity=Vector3.zero;s.lastSafe=s.root.CFrame
 return true
end
function M.Begin(s,pos)
 s.hum.MaxHealth=C.Health;s.hum.Health=C.Health;s.hum.AutoRotate=true;s.hum.Sit=false;s.hum.PlatformStand=false;s.root.Anchored=false
 M.Place(s,pos);s.root.Anchored=true;s.hum.WalkSpeed=0;s.hum.JumpPower=0;s.hum.JumpHeight=0
end
function M.Recalculate(s,now)
 if not s.alive or not s.hum.Parent then return end
 for key,v in pairs(s.effects)do if now>=v.untilAt then s.effects[key]=nil end end
 local e=s.effects;local frozen=s.frozen or e.freeze~=nil
 s.hum.WalkSpeed=frozen and 0 or e.slow and C.Slow or e.speed and C.Fast or C.Speed
 -- 1,8× de altura: potência escala pela raiz, pois altura é proporcional à potência².
 s.hum.UseJumpPower=s.original.usePower
 s.hum.JumpPower=frozen and 0 or s.original.jump*(e.jump and math.sqrt(1.8)or 1)
 s.hum.JumpHeight=frozen and 0 or s.original.height*(e.jump and 1.8 or 1)
 s.hum.AutoRotate=not frozen
 if s.shield>0 and s.shield<=now then s.shield=0 end
end
function M.Release(s,now)s.frozen=false;s.root.Anchored=false;M.Recalculate(s,now)end
function M.Buff(s,key,untilAt,name)s.effects[key]={untilAt=untilAt,name=name}end
function M.Restore(s)
 for _,c in ipairs(s.connections)do c:Disconnect()end;s.connections={};s.effects={};s.shield=0;s.weapon=nil
 if s.char.Parent and s.pl.Character==s.char then
  local h=s.hum;local o=s.original;s.root.Anchored=o.anchored;h.MaxHealth=o.max
  if h.Health>0 then h.Health=math.min(o.health,o.max)end
  h.WalkSpeed=o.speed;h.JumpPower=o.jump;h.JumpHeight=o.height;h.UseJumpPower=o.usePower;h.AutoRotate=o.auto;h.PlatformStand=o.platform
  s.char:PivotTo(o.pivot);s.root.AssemblyLinearVelocity=Vector3.zero;s.root.AssemblyAngularVelocity=Vector3.zero
 end
end
function M.Timers(s,now)
 local out={};for _,e in pairs(s.effects)do if e.untilAt>now then out[#out+1]={name=e.name,remaining=math.ceil(e.untilAt-now)}end end
 if s.shield>now then out[#out+1]={name='Escudo · 1 bloqueio',remaining=math.ceil(s.shield-now)}end
 table.sort(out,function(a,b)return a.name<b.name end);return out
end
return M
