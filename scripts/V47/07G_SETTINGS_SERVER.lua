-- 07G_SETTINGS_SERVER | Script | ServerScriptService | V44
-- Comandos só afetam o solicitante. Partidas competitivas restauram os limites comuns.
local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local kit=Rep:WaitForChild("PracaKit");local rem=kit:WaitForChild("Remotes")
local rpc=rem:FindFirstChild("PersonalSettings")or Instance.new("RemoteFunction");rpc.Name="PersonalSettings";rpc.Parent=rem
local states={};local rate={}
local function state(pl)if not states[pl]then states[pl]={speed=16,jump=50,size=1,fly=false}end;return states[pl]end
local function competitive(pl)return pl:GetAttribute("ACP_InGameRoom")==true or pl:GetAttribute("ACP_Competitive")==true end
local function apply(pl)
 local d=state(pl);if competitive(pl)then d.speed=16;d.jump=50;d.size=1;d.fly=false end
 local h=pl.Character and pl.Character:FindFirstChildOfClass("Humanoid")
 if h then h.WalkSpeed=d.speed;h.JumpPower=d.jump;h.JumpHeight=math.clamp(d.jump*d.jump/(2*workspace.Gravity),3,20)
  -- Multiplicador limitado separado das proporções persistentes do editor.
  local m=pl.Character;if m and m.GetScale and m.ScaleTo then pcall(function()m:ScaleTo(d.size)end)end
 end
 pl:SetAttribute("ACP_PersonalFly",d.fly);pl:SetAttribute("ACP_PersonalSpeed",d.speed);return d
end
rpc.OnServerInvoke=function(pl,key,value)
 if rate[pl]and os.clock()-rate[pl]<.2 then return{ok=false,error="Aguarde um instante."}end;rate[pl]=os.clock()
 if key=="get"then return{ok=true,data=apply(pl)}end
 if competitive(pl)then apply(pl);return{ok=false,error="Comandos de movimento ficam desligados durante partidas."}end
 local d=state(pl)
 if key=="reset"then states[pl]={speed=16,jump=50,size=1,fly=false}
 elseif key=="fly"then d.fly=value==true
 elseif key=="speed"or key=="jump"or key=="size"then
  local n=tonumber(value);if not n or n~=n then return{ok=false,error="Valor inválido."}end
  d[key]=key=="speed"and math.clamp(n,16,32)or key=="jump"and math.clamp(n,50,80)or math.clamp(n,.9,1.15)
 else return{ok=false,error="Comando indisponível."}end
 return{ok=true,data=apply(pl)}
end
local function added(pl)
 pl.CharacterAdded:Connect(function()task.wait(.3);apply(pl)end)
 for _,key in ipairs({"ACP_InGameRoom","ACP_Competitive"})do pl:GetAttributeChangedSignal(key):Connect(function()apply(pl)end)end
end
Players.PlayerAdded:Connect(added);for _,pl in ipairs(Players:GetPlayers())do added(pl)end
Players.PlayerRemoving:Connect(function(pl)states[pl]=nil;rate[pl]=nil end)
