-- 09I7_ASSISTANT_PROFILE | ModuleScript | ReplicatedStorage | V56
-- Convites com consentimento, expiração visível e preço consultado no Roblox.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local C=D.Colors
local Config=require(Rep:WaitForChild('09I0_ASSISTANT_CONFIG'));local Players=game:GetService('Players');local Market=game:GetService('MarketplaceService');local M={}
function M.Build(U,call,notice,refresh,onShared)
 local P={};local serial=0;local function act(a,d)task.spawn(function()local ok,e=call(a,d);notice(ok and'Perfil atualizado.'or e);if ok then refresh()end end)end
 local function clear()for _,o in ipairs(U.Profile:GetChildren())do if o:IsA('GuiObject')then o:Destroy()end end end
 local function label(text,order,height)return D.Text(U.Profile,text,{Size=UDim2.new(1,-6,0,height or 44),LayoutOrder=order,TextXAlignment=Enum.TextXAlignment.Left,TextSize=14})end
 local function button(text,order,fn)local b=D.Button(U.Profile,text,{Size=UDim2.new(1,-6,0,44),LayoutOrder=order,TextSize=13});b.Activated:Connect(fn);return b end
 function P.Render(v)
  serial=serial+1;local token=serial;clear();if not v then label('Recarregue o perfil.',1);return end
  label('Seu perfil usa seu UserId Roblox. Nunca informe senha, e-mail ou código de acesso.',1,60)
  label('Plano: '..v.plan..(v.expires>0 and(' • termina '..os.date('!%d/%m/%Y %H:%M',v.expires)..' UTC')or' • gratuito'),2)
  label('Até '..v.count..' look(s) por pedido • '..v.daily..' solicitações/dia, compartilhadas pelo grupo.',3,44)
  label(v.checking and'Conectando à IA Roblox…'or v.available and'IA Roblox online • criações independentes, sem histórico permanente de conversa.'or'IA Roblox indisponível • use Recarregar conexão.',7,60)
  label(Config.Disclosure,8,70)
  local own=v.owner==Players.LocalPlayer.UserId
  if not own then label('Usando plano compartilhado pelo titular '..v.owner..'. Conversas e avatar continuam privados.',4,52);button('Sair do grupo',5,function()act('leave')end)
   if v.plan=='Pro'then button('Ver coleções do grupo',6,function()task.spawn(function()local rows,e=call('shared',{id=v.owner});if rows then onShared(rows)else notice(e)end end)end)end
  end
  for i,key in ipairs({'Studio','Pro'})do
   local p=Config.Plans[key];local b=button(key..' • consultando preço… • 30 dias',10+i,function()act('prompt',{plan=key})end);D.SetEnabled(b,false)
   local completed=false
   task.delay(12,function()if not completed and token==serial and b.Parent then b.Text=key..' • preço demorou • recarregue o perfil';D.SetEnabled(b,false)end end)
   task.spawn(function()local ok,info=pcall(function()return Market:GetProductInfoAsync(p.product,Enum.InfoType.Product)end);completed=true
    if token~=serial or not b.Parent then return end
    b.Text=ok and info and info.IsForSale and type(info.PriceInRobux)=='number'and(key..' • '..info.PriceInRobux..' Robux • 30 dias')or(key..' indisponível')
    D.SetEnabled(b,v.available and ok and info and info.IsForSale and type(info.PriceInRobux)=='number')
   end)
  end
  label('Renovação manual. Compra adiciona 30 dias; prazo continua fora do jogo. Sem renovação automática.',14,56)
  if v.plan=='Pro'then label(table.concat(Config.ProBenefits,' • '),15,100)
   if own then button(v.prefs.share==true and'Coleções compartilhadas • tornar privadas'or'Coleções privadas • compartilhar com o grupo',16,function()act('pref',{key='share',value=v.prefs.share~=true})end)end
  end
  local input=D.Box(U.Profile,'@amigo ou UserId',{Size=UDim2.new(1,-6,0,44),LayoutOrder=20})
  button('Convidar amigo • até 3',21,function()task.spawn(function()
   local raw=input.Text:gsub('^@','');local id=tonumber(raw);if not id then local ok,vv=pcall(function()return Players:GetUserIdFromNameAsync(raw)end);if ok then id=vv end end
   if not id then notice('Amigo não encontrado.');return end;act('invite',{id=id})
  end)end)
  for i,id in ipairs(v.members or{})do button('Remover amigo '..id,30+i,function()act('revoke',{id=id})end)end
  for i,inv in ipairs(v.invites or{})do
   button('Aceitar convite do titular '..inv.owner,40+i*2,function()act('accept',{id=inv.owner})end)
   button('Recusar convite '..inv.owner,41+i*2,function()act('decline',{id=inv.owner})end)
  end
  button((v.prefs.theme=='Neutro'and'Tema neutro'or'Tema Halloween')..' • alternar',70,function()act('pref',{key='theme',value=v.prefs.theme=='Neutro'and'Halloween'or'Neutro'})end)
  button('Movimento: '..(v.prefs.motion==false and'reduzido'or'padrão'),71,function()act('pref',{key='motion',value=v.prefs.motion==false})end)
  button('Recarregar conexão e perfil',80,function()refresh(true)end)
 end
 return P
end
return M
