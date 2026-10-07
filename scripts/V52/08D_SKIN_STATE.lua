-- 08D_SKIN_STATE
-- ModuleScript | ReplicatedStorage
-- AVATAR PLAZA V51 - edicoes isoladas preservam a skin do personagem.
local Players=game:GetService("Players")
local Avatar=game:GetService("AvatarEditorService")
local Rep=game:GetService("ReplicatedStorage")
local A=require(Rep:WaitForChild("08B_AVATAR_DATA"))

local S={VERSION="V41_SKIN_STATE",Changed=Instance.new("BindableEvent"),Current=nil,Original=nil,History={},Future={},SelectedSave=nil,Rig="R15",OriginalRig="R15",Base=nil,Replace=false,Generation=0}

local SCALE_RULES={
 HeightScale={.90,1.05,.01},WidthScale={.70,1.00,.01},DepthScale={.70,1.00,.01},
 HeadScale={.95,1.00,.01},BodyTypeScale={0,1,.05},ProportionScale={0,1,.05}
}

local function changed()S.Generation=S.Generation+1;S.Changed:Fire()end
local function normRig(v,body)
 return tostring(v)=="R6"and not A.BodyRequiresR15(body)and"R6"or"R15"
end
local function snap()
 return S.Current and{body=A.Copy(S.Current),rig=S.Rig,replace=S.Replace}or nil
end
local function push()
 local v=snap();if not v then return end
 table.insert(S.History,v);if #S.History>15 then table.remove(S.History,1)end
end
local function restore(v)
 if type(v)~="table"or type(v.body)~="table"then return false,"Estado inválido."end
 local clean,err=A.Clean(v.body);if not clean then return false,err end
 S.Current=clean;S.Rig=normRig(v.rig,clean);S.Replace=v.replace==true;changed();return true
end

function S.Init(fetch)
 if S.Current then return true end
 local raw,rig
 if fetch then
  local data,err=fetch("AvatarSnapshot",{})
  if not data then return false,err or"Seu avatar ainda não carregou."end
  raw,rig=data.body,normRig(data.rig)
 else
  local pl=Players.LocalPlayer;local hum=pl.Character and pl.Character:FindFirstChildOfClass("Humanoid")
  if not hum or not pl:HasAppearanceLoaded()then return false,"Seu avatar ainda não carregou."end
  local ok,desc=pcall(function()return hum:GetAppliedDescription()end)
  if not ok or not desc then return false,"Seu avatar ainda não carregou."end
  raw=A.Pack(desc);desc:Destroy();rig=hum.RigType==Enum.HumanoidRigType.R6 and"R6"or"R15"
 end
 local clean,err=A.Clean(raw);if not clean then return false,err end
 S.Original=A.Copy(clean);S.Base=A.Copy(clean);S.Current=clean
 rig=normRig(rig,clean);S.Rig=rig;S.OriginalRig=rig;S.Replace=false;changed();return true
end
function S.AcceptApplied(raw,generation,rig)
 if generation~=S.Generation then return end
 local clean=A.Clean(raw);if not clean then return end
 S.Base=A.Copy(clean);S.Current=clean;if rig then S.Rig=normRig(rig,clean)end;S.Replace=false;changed()
end

function S.Set(raw,noHistory,rig,incremental)
 local clean,err=A.Clean(raw);if not clean then return false,err end
 if not noHistory then push();S.Future={}end
 S.Current=clean;if incremental~=true then S.Replace=true end;S.Rig=normRig(rig or S.Rig,clean);changed();return true
end
function S.SetRig(rig,noHistory)
 rig=normRig(rig,S.Current);if S.Rig==rig then return true end
 if not noHistory then push();S.Future={}end
 S.Rig=rig;changed();return true
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
 S.Current.scales[name]=v;changed();return true,v
end
function S.ResetScales()
 if not S.Current or not S.Original then return false,"Avatar não carregado."end
 if S.Rig=="R6"then return false,"Escalas corporais são do R15."end
 push();S.Future={}
 for name in pairs(SCALE_RULES)do S.Current.scales[name]=tonumber(S.Original.scales and S.Original.scales[name])or S.Current.scales[name]or 1 end
 changed();return true
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
 push();S.Future={};S.Current=A.Copy(S.Original);S.Rig=S.OriginalRig;S.Replace=true;changed();return true
end
function S.Remove(id)
 if not S.Current then return false,"Avatar não carregado."end
 return S.Set(A.Remove(S.Current,id),false,nil,true)
end
function S.Blank()
 if not S.Current then return false,"Avatar não carregado."end
 local clean,err=A.Blank(S.Current);if not clean then return false,err end;return S.Set(clean)
end
function S.Try(item)
 if not S.Current then return false,"Avatar não carregado."end
 local mine=S.Generation
 local id=tonumber(item and item.Id);if not id then return false,"Item inválido."end
 if A.ItemType(item)=="Bundle"then
  local body,rig,err=A.BundleBody(item,S.Current)
  if not body then return false,err or"Não foi possível carregar essa skin 3D."end
  if mine~=S.Generation then return false,"A prévia mudou. Escolha o pacote novamente."end
  return S.Set(body,false,rig or S.Rig,true)
 end
 local ok,detail=pcall(function()return Avatar:GetItemDetailsAsync(id,Enum.AvatarItemType.Asset)end)
 if not ok or type(detail)~="table"then return false,"O Roblox não respondeu sobre esse item. Tente novamente."end
 if mine~=S.Generation then return false,"A prévia mudou. Escolha o item novamente."end
 local nextData,err=A.Add(A.Copy(S.Current),detail)
 if not nextData then return false,err end
 return S.Set(nextData,false,A.RequiresR15(detail)and"R15"or nil,true)
end
function S.Description()if not S.Current then return nil end;return A.Unpack(S.Current)end
print("AVATAR PLAZA V41: 08D_SKIN_STATE corpo/R6/R15 pronto")
return S
