-- 09B3_PLAYER_INSPECT | ModuleScript | ServerScriptService | V64 (SUBSTITUIR)
-- Inspeção e consentimento só para jogadores presentes. Curtidas únicas por visitante.
local Players=game:GetService("Players")
local DS=game:GetService("DataStoreService")
local Rep=game:GetService("ReplicatedStorage")
local A=require(Rep:WaitForChild("08B_AVATAR_DATA"))
local likes=DS:GetDataStore("ACP_AvatarLikes_V44")
local M={Version='V64'};local sources={};local transfers={};local Market=game:GetService('MarketplaceService');local Budget=require(script.Parent:WaitForChild('09B11_DATA_BUDGET'))
local function target(args)
 local n=tonumber(args.id);if not n or n%1~=0 then error("Jogador inválido.")end
 local pl=Players:GetPlayerByUserId(n);if not pl then error("O jogador saiu do servidor.")end;return pl
end
function M.Avatar(pl,args)
 local other=target(args);local hum=other.Character and other.Character:FindFirstChildOfClass("Humanoid")
 if not hum then error("Avatar ainda está carregando.")end
 local desc=hum:GetAppliedDescription();local body=A.Pack(desc);desc:Destroy()
 return {id="player:"..other.UserId,owner=other.UserId,name="Look de "..other.DisplayName,source="Player",sourceUsername=other.Name,
  publisher=other.Name,likes=tonumber(other:GetAttribute('ACP_AvatarLikes'))or 0,body=body,rig=hum.RigType==Enum.HumanoidRigType.R6 and"R6"or"R15",allowCopy=other==pl or other:GetAttribute("ACP_AllowAvatarCopy")==true}
end
function M.Use(pl,args)
 local other=target(args)
 if other~=pl and other:GetAttribute("ACP_AllowAvatarCopy")~=true then error("O dono deste avatar desativou o uso do look.")end
 local record=M.Avatar(pl,args);sources[pl]=other.UserId;return record
end
function M.CheckApply(pl)
 local id=sources[pl];local other=id and Players:GetPlayerByUserId(id)
 if id and id~=pl.UserId and not other then return false,"O dono saiu. Carregue seu avatar antes de aplicar outro look."end
 if other and other~=pl and other:GetAttribute("ACP_AllowAvatarCopy")~=true then return false,"O dono revogou o uso desse look. Carregue seu próprio avatar."end
 return true
end
function M.Clear(pl)sources[pl]=nil end
function M.Like(pl,args)
 local other=target(args);if other==pl then error("Curtidas são dadas a outros jogadores.")end
 local ok,d=Budget.Run('Write',false,function()return likes:UpdateAsync(tostring(other.UserId),function(old)
  old=old or{count=0,users={}};local key=tostring(pl.UserId)
  if not old.users[key]then old.users[key]=true;old.count=old.count+1 end;return old
 end)end)
 if not ok then error("Não foi possível registrar sua curtida.")end
 other:SetAttribute("ACP_AvatarLikes",d.count);return{likes=d.count}
end
function M.Transfer(pl,args)
 local other=target(args);if other==pl then error('Escolha outro jogador.')end
 local amount=tonumber(args.amount);if not amount or amount~=amount or amount%1~=0 or amount<10 or amount>500 then error('Valor permitido: 10 a 500 Robux.')end
 if os.clock()-(transfers[pl]or -100)<10 then error('Aguarde antes de abrir outra transferência.')end
 local entitled,plus=pcall(function()return pl.HasRobloxSubscription end)
 if not entitled or not plus then error('Enviar Robux exige Roblox Plus. O Roblox verifica a elegibilidade.')end
 transfers[pl]=os.clock()
 local ok,id=pcall(function()return Market:PromptRobuxTransferAsync(pl,other.UserId,amount)end)
 if not ok or not id then warn('[Player V64] TRANSFER_PROMPT '..tostring(id));error('O Roblox não abriu a transferência. Veja elegibilidade e permissões no aplicativo.')end
 return{request=tostring(id),prompted=true}
end
-- Recibos de transferência separados de ProcessReceipt, sem conceder vantagens.
for _,name in ipairs({'RobuxTransferSender','RobuxTransferReceiver'})do
 local ok,e=pcall(function()Market:BindReceiptHandler(Enum.ReceiptType[name],function(receipt)
  print('[Player V64] TRANSFER_CONFIRMED '..name..' request='..tostring(receipt.TransferRequestId));return Enum.ReceiptDecision.Processed
 end)end)
 if not ok then warn('[Player V64] Transferências indisponíveis neste runtime: '..tostring(e))end
end
Players.PlayerRemoving:Connect(function(pl)M.Clear(pl);transfers[pl]=nil end)
return M
