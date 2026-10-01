-- 08D_SKIN_STATE
-- ModuleScript | ReplicatedStorage
-- AVATAR PLAZA V37 - estado da skin + R6/R15 + escalas do corpo + histórico.
local Players=game:GetService("Players")
local Avatar=game:GetService("AvatarEditorService")
local Rep=game:GetService("ReplicatedStorage")
local A=require(Rep:WaitForChild("08B_AVATAR_DATA"))

local S={Changed=Instance.new("BindableEvent"),Current=nil,Original=nil,History={},Future={},SelectedSave=nil,Rig="R15",OriginalRig="R15"}

local SCALE_RULES={
 HeightScale={.90,1.05,.01},WidthScale={.70,1.00,.01},DepthScale={.70,1.00,.01},
 HeadScale={.95,1.00,.01},BodyTypeScale={0,1,.05},ProportionScale={0,1,.05}
}

local function normRig(v)
 return tostring(v)=="R6" and "R6" or "R15"
end
local function snap()
 return S.Current and{body=A.Copy(S.Current),rig=S.Rig}or nil
end
local function push()
 local v=snap();if not v then return end
 table.insert(S.History,v);if #S.History>15 then table.remove(S.History,1)end
end
local function restore(v)
 if type(v)~="table"or type(v.body)~="table"then return false,"Estado inválido."end
 local clean,err=A.Clean(v.body);if not clean then return false,err end
 S.Current=clean;S.Rig=normRig(v.rig);S.Changed:Fire();return true
end

function S.Init()
 if S.Current then return true end
 local pl=Players.LocalPlayer;local hum=pl.Character and pl.Character:FindFirstChildOfClass("Humanoid")
 local ok,desc=pcall(function()
  if hum and pl:HasAppearanceLoaded()then return hum:GetAppliedDescription()end
  return Players:GetHumanoidDescriptionFromUserIdAsync(pl.UserId)
 end)
 if not ok or not desc then return false,"Seu avatar ainda não carregou."end
 local raw=A.Pack(desc);desc:Destroy();local rig=hum and hum.RigType==Enum.HumanoidRigType.R6 and"R6"or"R15"
 S.Original=A.Copy(raw);S.Current=raw;S.Rig=rig;S.OriginalRig=rig;S.Changed:Fire();return true
end

function S.Set(raw,noHistory,rig)
 local clean,err=A.Clean(raw);if not clean then return false,err end
 if not noHistory then push();S.Future={}end
 S.Current=clean;if rig~=nil then S.Rig=normRig(rig)end;S.Changed:Fire();return true
end
function S.SetRig(rig,noHistory)
 rig=normRig(rig);if S.Rig==rig then return true end
 if not noHistory then push();S.Future={}end
 S.Rig=rig;S.Changed:Fire();return true
end
function S.GetRig()return S.Rig end
function S.ScaleRules()return SCALE_RULES end
function S.GetScale(name)
 local r=S.Current and S.Current.scales
 return r and tonumber(r[name])or nil
end
function S.SetScale(name,value,noHistory)
 if not S.Current or type(S.Current.scales)~="table"then return false,"Avatar não carregado."end
 local rule=SCALE_RULES[name];if not rule then return false,"Escala inválida."end
 if S.Rig=="R6"then return false,"Escalas corporais são do R15."end
 local v=math.clamp(tonumber(value)or S.Current.scales[name]or 1,rule[1],rule[2])
 if not noHistory then push();S.Future={}end
 S.Current.scales[name]=v;S.Changed:Fire();return true,v
end
function S.ResetScales()
 if not S.Current or not S.Original then return false,"Avatar não carregado."end
 if S.Rig=="R6"then return false,"Escalas corporais são do R15."end
 push();S.Future={}
 for name in pairs(SCALE_RULES)do S.Current.scales[name]=tonumber(S.Original.scales and S.Original.scales[name])or S.Current.scales[name]or 1 end
 S.Changed:Fire();return true
end

function S.Undo()
 if #S.History==0 then return false,"Nada para desfazer."end
 local now=snap();if now then table.insert(S.Future,now)end
 return restore(table.remove(S.History))
end
function S.Redo()
 if #S.Future==0 then return false,"Nada para refazer."end
 local now=snap();if now then table.insert(S.History,now)end
 return restore(table.remove(S.Future))
end
function S.Reset()
 if not S.Original then return S.Init()end
 push();S.Future={};S.Current=A.Copy(S.Original);S.Rig=S.OriginalRig;S.Changed:Fire();return true
end
function S.Remove(id)
 if not S.Current then return false,"Avatar não carregado."end
 return S.Set(A.Remove(S.Current,id))
end
function S.Blank()
 if not S.Current then return false,"Avatar não carregado."end
 local clean,err=A.Blank(S.Current);if not clean then return false,err end;return S.Set(clean)
end
function S.Try(item)
 if not S.Current then return false,"Avatar não carregado."end
 local id=tonumber(item and item.Id);if not id then return false,"Item inválido."end
 local enum=A.ItemEnum(item)
 local ok,detail=pcall(function()return Avatar:GetItemDetailsAsync(id,enum)end)
 if not ok or type(detail)~="table"then return false,"Não foi possível abrir esse item."end
 if A.ItemType(detail)=="Bundle"then
  local body,rig,err=A.BundleBody(detail,S.Current)
  if not body then return false,err or"Não foi possível carregar essa skin 3D."end
  return S.Set(body,false,rig or"R15")
 end
 local nextData,err=A.Add(A.Copy(S.Current),detail)
 if not nextData then return false,err end
 return S.Set(nextData)
end
function S.Description()if not S.Current then return nil end;return A.Unpack(S.Current)end
print("AVATAR PLAZA V37: 08D_SKIN_STATE corpo/R6/R15 pronto")
return S
