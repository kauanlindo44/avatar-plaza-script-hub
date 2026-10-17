-- 09I7_ASSISTANT_PROFILE | ModuleScript | ReplicatedStorage | V67 (SUBSTITUIR)
-- Plano, aparência e amigos separados; preços reais e convites com consentimento.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local C=D.Colors
local Config=require(Rep:WaitForChild('09I0_ASSISTANT_CONFIG'));local Players=game:GetService('Players');local Market=game:GetService('MarketplaceService');local M={}
function M.Build(U,call,notice,refresh,onShared)
 local P={Page='Geral'};local serial=0;local latest
 local function act(a,d)if a=='pref'and d and d.key=='theme'then require(Rep:WaitForChild('07UI_HALLOWEEN_THEME')).SetMode(Players.LocalPlayer.PlayerGui,d.value=='Neutro'and'Off'or d.value=='Halloween'and'On'or'Auto')end;task.spawn(function()local ok,e=call(a,d);notice(ok and'Perfil atualizado.'or e);if ok then refresh()end end)end
 local function clear()for _,o in ipairs(U.Profile:GetChildren())do if o:IsA('GuiObject')then o:Destroy()end end;U.Profile.CanvasPosition=Vector2.new(0,0)end
 local function label(text,order,height)return D.Text(U.Profile,text,{Size=UDim2.new(1,-6,0,height or 44),LayoutOrder=order,TextXAlignment=Enum.TextXAlignment.Left,TextSize=14})end
 local function button(text,order,fn)local b=D.Button(U.Profile,text,{Size=UDim2.new(1,-6,0,44),LayoutOrder=order,TextSize=13});b.Activated:Connect(fn);return b end
 function P.Render(v)
  latest=v;serial=serial+1;local token=serial;clear();if not v then label('Recarregue o perfil.',1);return end
  local nav=D.New('Frame',{Size=UDim2.new(1,-6,0,44),BackgroundTransparency=1,LayoutOrder=0},U.Profile)
  for i,name in ipairs({'Geral','Aparência','Compartilhar'})do
   D.Button(nav,name,{Position=UDim2.new((i-1)/3,2,0,0),Size=UDim2.new(1/3,-4,1,0),BackgroundColor3=P.Page==name and C.orange or C.card,TextColor3=P.Page==name and C.bg or C.white}).Activated:Connect(function()P.Page=name;P.Render(latest)end)
  end
  if v.storageAvailable==false then label(v.storageError,1,68)end
  local own=v.owner==Players.LocalPlayer.UserId
  if P.Page=='Geral'then
   label(v.plan..(v.expires>0 and(' • até '..os.date('!%d/%m/%Y %H:%M',v.expires)..' UTC')or' • gratuito'),2)
   label('Até '..v.count..' look(s) por pedido • '..v.daily..' pedidos/dia. O grupo divide esse limite.',3,48)
   label(v.checking and'Carregando sua conta…'or v.available and'Busca de looks disponível'or'Conexão indisponível. Recarregue ou envie um novo pedido.',4,48)
   label('O assistente de looks é gratuito. Não há venda de planos novos.',10,52)
   label(Config.Disclosure,15,70)
   if v.plan=='Pro'then label(table.concat(Config.ProBenefits,' • '),16,100)end
  elseif P.Page=='Aparência'then
   label('Estas opções mudam as interfaces do seu jogo.',2)
   local theme=v.prefs.theme or'Auto';local names={Auto='Automático até 31/10',Neutro='Neutro',Halloween='Halloween ligado'}
   button('Tema: '..names[theme]..' • trocar',3,function()act('pref',{key='theme',value=theme=='Auto'and'Neutro'or theme=='Neutro'and'Halloween'or'Auto'})end)
   button('Movimento: '..(v.prefs.motion==false and'reduzido'or'padrão')..' • trocar',4,function()act('pref',{key='motion',value=v.prefs.motion==false})end)
  else
   if v.plan=='Normal'then label('Compartilhe uma cópia textual da conversa por código. Sua conta Roblox e os outros chats ficam privados.',2,72);button('Compartilhar conversa atual',3,function()U.SettingsShade.Visible=false;U.Profile.Visible=false;if U.OpenShare then U.OpenShare()end end);button('Recarregar perfil',80,function()refresh(true)end);return end
   label('Compartilhe somente o plano da IA com até 3 amigos Roblox. Conversas e avatares são privados.',2,68)
   if not own then
    label('Plano compartilhado por '..v.owner..'.',3);button('Sair do grupo',4,function()act('leave')end)
    if v.plan=='Pro'then button('Abrir looks compartilhados',5,function()task.spawn(function()local rows,e=call('shared',{id=v.owner});if rows then onShared(rows)else notice(e)end end)end)end
   else
    local input=D.Box(U.Profile,'@amigo ou UserId',{Size=UDim2.new(1,-6,0,44),LayoutOrder=5})
    button('Convidar amigo',6,function()task.spawn(function()
     local raw=input.Text:gsub('^@','');local id=tonumber(raw);if not id then local ok,value=pcall(function()return Players:GetUserIdFromNameAsync(raw)end);if ok then id=value end end
     if not id then notice('Amigo não encontrado.');return end;act('invite',{id=id})
    end)end)
    if v.plan=='Pro'then button(v.prefs.share==true and'Looks do grupo: compartilhados • tornar privados'or'Looks do grupo: privados • compartilhar',7,function()act('pref',{key='share',value=v.prefs.share~=true})end)end
    for i,id in ipairs(v.members or{})do button('Remover amigo '..id,20+i,function()act('revoke',{id=id})end)end
   end
   for i,inv in ipairs(v.invites or{})do
    button('Aceitar convite de '..inv.owner,40+i*2,function()act('accept',{id=inv.owner})end)
    button('Recusar convite de '..inv.owner,41+i*2,function()act('decline',{id=inv.owner})end)
   end
  end
  button('Recarregar conexão e perfil',80,function()refresh(true)end)
 end
 return P
end
return M
