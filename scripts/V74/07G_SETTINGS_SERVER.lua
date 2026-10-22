-- 07G_SETTINGS_SERVER | Script | ServerScriptService | V74 (SUBSTITUIR)
-- Comandos só afetam o solicitante. Partidas competitivas restauram os limites comuns.
local Players=game:GetService("Players")
local Rep=game:GetService("ReplicatedStorage")
local kit=Rep:WaitForChild("PracaKit");local rem=kit:WaitForChild("Remotes")
local rpc=rem:FindFirstChild("PersonalSettings")or Instance.new("RemoteFunction");rpc.Name="PersonalSettings";rpc.Parent=rem
local states={};local rate={}
local function state(pl)if not states[pl]then states[pl]={speed=16,jump=50,size=1,fly=false}end;return states[pl]end
local function competitive(pl)return pl:GetAttribute("ACP_InGameRoom")==true or pl:GetAttribute("ACP_Competitive")==true end
local function apply(pl)
 if pl:GetAttribute('BC_MatchId')then return state(pl)end
 local d=state(pl);if competitive(pl)then d.speed=16;d.jump=50;d.size=1;d.fly=false end
 local h=pl.Character and pl.Character:FindFirstChildOfClass("Humanoid")
 if h then h.WalkSpeed=d.speed;h.JumpPower=d.jump;h.JumpHeight=math.clamp(d.jump*d.jump/(2*workspace.Gravity),3,20)
  -- Multiplicador limitado separado das proporções persistentes do editor.
  local m=pl.Character;if m and m.GetScale and m.ScaleTo then pcall(function()if math.abs(m:GetScale()-d.size)>.001 then m:ScaleTo(d.size)end end)end
 end
 pl:SetAttribute("ACP_PersonalFly",d.fly);pl:SetAttribute("ACP_PersonalSpeed",d.speed);return d
end
local function handle(pl,key,value)
 if rate[pl]and os.clock()-rate[pl]<.2 then return{ok=false,error="Aguarde um instante."}end;rate[pl]=os.clock()
 if key=='camera'then local n=tonumber(value);if not n or n~=n then return{ok=false,error='Informe um FOV de 60 a 90.'}end;return{ok=true,data={camera=math.clamp(n,60,90)}}end
 if pl:GetAttribute('BC_MatchId')and key=='open'and value~='Music'then return{ok=false,error='Volte ao catálogo antes de abrir o editor.'}end
 if key=='open'then if value~='Catalog'and value~='Photo'and value~='Music'then return{ok=false,error='Tela inválida.'}end;return{ok=true,data={open=value}}end
 if key=='help'then return{ok=true,data={help=true}}end
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
rpc.OnServerInvoke=handle
local commandEvent=rem:FindFirstChild('PersonalCommand')or Instance.new('RemoteEvent');commandEvent.Name='PersonalCommand';commandEvent.Parent=rem
local list=require(Rep:WaitForChild('07G5_CHAT_COMMANDS'));local Chat=game:GetService('TextChatService')
for _,definition in ipairs(list)do
 local name='ACP_Command_'..definition.alias:sub(2);local old=Chat:FindFirstChild(name);if old then old:Destroy()end
 local cmd=Instance.new('TextChatCommand');cmd.Name=name;cmd.PrimaryAlias=definition.alias;cmd.Parent=Chat
 cmd.Triggered:Connect(function(source,text)
  local pl=source and Players:GetPlayerByUserId(source.UserId);if not pl then return end
  local value=definition.value
  if definition.argument then local raw=tostring(text):match('^%S+%s+(.+)$');if raw then value=tonumber(raw);if not value then commandEvent:FireClient(pl,{error='Use '..definition.alias..' seguido de um número.'});return end end end
  local ok,r=pcall(handle,pl,definition.key,value);if not ok then r={ok=false,error='Não foi possível aplicar o comando.'}end
  commandEvent:FireClient(pl,r)
 end)
end
local function added(pl)
 pl.CharacterAdded:Connect(function()task.wait(.3);apply(pl)end)
 for _,key in ipairs({"ACP_InGameRoom","ACP_Competitive","BC_MatchId"})do pl:GetAttributeChangedSignal(key):Connect(function()apply(pl)end)end
end
Players.PlayerAdded:Connect(added);for _,pl in ipairs(Players:GetPlayers())do added(pl)end
Players.PlayerRemoving:Connect(function(pl)states[pl]=nil;rate[pl]=nil end)
