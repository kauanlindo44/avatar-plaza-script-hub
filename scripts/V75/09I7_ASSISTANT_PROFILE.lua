-- 09I7_ASSISTANT_PROFILE | ModuleScript | ReplicatedStorage | V75 (SUBSTITUIR)
-- Plus/Pro de 30 dias, preço consultado no Roblox e recibo como única concessão.
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local Config=require(Rep:WaitForChild('09I0_ASSISTANT_CONFIG'))
local Skin=require(Rep:WaitForChild('09I20_ASSISTANT_APPEARANCE'));local C=Skin.Colors;local Market=game:GetService('MarketplaceService');local Players=game:GetService('Players');local M={}
function M.Build(U,call,notice,refresh,onShared)
 local P={Page='Geral'};local serial=0;local latest
 local function products()
  local module=Rep:FindFirstChild('09I25_PLAN_PRODUCTS')
  if not module or not module:IsA('ModuleScript')then return nil end
  local ok,value=pcall(require,module);return ok and type(value)=='table'and value or nil
 end
 local function act(a,d)task.spawn(function()local ok,e=call(a,d);notice(ok and'Preferência salva.'or e);if ok then refresh()end end)end
 local function clear()for _,o in ipairs(U.Profile:GetChildren())do if o:IsA('GuiObject')then o:Destroy()end end;U.Profile.CanvasPosition=Vector2.zero end
 local function label(text,order,height)return D.Text(U.Profile,text,{Size=UDim2.new(1,-6,0,height or 44),LayoutOrder=order,TextXAlignment=Enum.TextXAlignment.Left,TextSize=14})end
 local function button(text,order,fn)local b=D.Button(U.Profile,text,{Size=UDim2.new(1,-6,0,44),LayoutOrder=order,TextSize=13});b.Activated:Connect(fn);return b end
 function P.Render(v)
  if v then v.prefs=v.prefs or{};v.expires=tonumber(v.expires)or 0 end
  latest=v;serial=serial+1;local mine=serial;clear();if not v then label('Recarregue seu perfil.',1);return end
  U.SettingsTitle.Text='Configurações · '..(Config.Labels[v.plan]or'Gratuito')
  local nav=D.Scroll(U.Profile,{Name='AssistantSettingsPages',Size=UDim2.new(1,-6,0,48),ScrollingDirection=Enum.ScrollingDirection.X,AutomaticCanvasSize=Enum.AutomaticSize.X,LayoutOrder=0,ScrollBarThickness=1});D.New('UIListLayout',{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,6)},nav)
  for _,name in ipairs({'Geral','Planos','Aparência','Compartilhar'})do local b=D.Button(nav,name,{Size=UDim2.fromOffset(110,44),TextSize=13});b:SetAttribute('ACP_Primary',P.Page==name);b.Activated:Connect(function()P.Page=name;P.Render(latest)end)end
  if v.storageAvailable==false then label(v.storageError,1,80)end
  if P.Page=='Geral'then
   label('Seu assistente de looks no Plaza',2,32);label('Plano '..(Config.Labels[v.plan]or'Gratuito')..(v.expires>0 and(' · válido até '..os.date('!%d/%m/%Y %H:%M',v.expires)..' UTC')or''),3,56)
   label(v.available and'Pesquisa e montagem de looks disponíveis.'or'Reconecte para consultar o catálogo.',4)
   button('Conferir Plus e Pro',5,function()P.Page='Planos';P.Render(v)end)
   button('Abrir looks salvos',6,function()U.SettingsShade.Visible=false;U.Profile.Visible=false;U.Select('Salvos')end)
   button('Conversas arquivadas',7,function()U.SettingsShade.Visible=false;U.Profile.Visible=false;U.MenuOpen=true;if U.OpenArchived then U.OpenArchived()end;U.Layout()end)
   label(Config.Disclosure,12,72)
  elseif P.Page=='Planos'then
   label('Gratuito → Plus → Pro',2,36);label('30 dias corridos por compra, inclusive fora do jogo. Compra avulsa, sem renovação automática.',3,64)
   label('Gratuito: 1 look por pedido · 10 pedidos/dia.',4)
   for i,key in ipairs({'Studio','Pro'})do
    local spec=Config.Plans[key];local name=Config.Labels[key];local count=key=='Pro'and'quantidade escolhida, em lotes de 5'or'até 5 looks por pedido'
    label(name..': '..count..' · '..spec.daily..' pedidos/dia compartilhados.',5+i*3,64)
    local b=button('Consultando preço do '..name..'…',6+i*3,function()end);D.SetEnabled(b,false);local ready=false
    b.Activated:Connect(function()if not ready then return end;task.spawn(function()local ok,e=call('prompt',{plan=key});notice(ok and'Confira os dados no prompt oficial do Roblox.'or e)end)end)
    task.spawn(function()
     local Products=products()
     local ok,result=pcall(function()return Products and Products.Check(spec.product,true)end)
     if mine~=serial or not b.Parent then return end
     if not ok or type(result)~='table'then b.Text=name..' · consulta indisponível';b.Size=UDim2.new(1,-6,0,64);b:SetAttribute('ProductDiagnostic','module_missing');return end
     ready=result.ready==true
     b.Text=ready and('Comprar '..name..' · '..result.price..' Robux · 30 dias')or(name..' · '..result.message);b:SetAttribute('ProductDiagnostic',result.stage);D.SetEnabled(b,ready)
     if not ready then b.Size=UDim2.new(1,-6,0,88)end
    end)
   end
   label('Plus e Pro incluem Extremo alto e Max. Respeitar escolhas obrigatórias faz parte de todos os planos. Pro mantém até 50 resultados recentes na tela; guarde os favoritos em Salvos.',20,100)
   label('O benefício comprado é deste jogo. Ele não concede ChatGPT Plus/Pro nem Roblox Plus.',21,56)
  elseif P.Page=='Aparência'then
   label('Leitura confortável',2,32)
   button('Tema suave / escuro da assistente',3,function()local mode=v.prefs.assistantTheme=='Escuro'and'Suave'or'Escuro';act('pref',{key='assistantTheme',value=mode});if U.SetAppearance then U.SetAppearance(mode)end end)
   button('Movimentos: '..(v.prefs.motion==false and'reduzidos'or'ativados'),4,function()act('pref',{key='motion',value=v.prefs.motion==false});Players.LocalPlayer:WaitForChild('PlayerGui'):SetAttribute('ACP_ReducedMotion',v.prefs.motion~=false)end)
   button('Enter para enviar: '..(v.prefs.enterSend==false and'desligado'or'ligado'),5,function()act('pref',{key='enterSend',value=v.prefs.enterSend==false})end)
   button('Restaurar aparência suave',6,function()act('pref',{key='assistantTheme',value='Suave'});if U.SetAppearance then U.SetAppearance('Suave')end end)
  else
   label('Compartilhar conversa',2,32);label('Uma cópia por código contém as últimas oito mensagens, filtradas pelo Roblox.',3,64)
   button('Compartilhar a conversa atual',4,function()U.SettingsShade.Visible=false;U.Profile.Visible=false;if U.OpenShare then U.OpenShare()end end)
   label('Compartilhar benefício do plano',5,36);label('Até 3 amigos. A conta Roblox, as conversas e as roupas não são compartilhadas. O grupo divide os pedidos diários.',6,70)
   if v.plan=='Normal'then label('Este recurso precisa de Plus ou Pro ativo.',7)
   elseif v.owner~=Players.LocalPlayer.UserId then
    label('Benefício compartilhado pelo jogador '..v.owner..'.',7)
    button('Sair do grupo do plano',8,function()act('leave')end)
    if v.plan=='Pro'then button('Coleções autorizadas do grupo',9,function()task.spawn(function()local rows,e=call('shared',{id=v.owner});if rows then onShared(rows)else notice(e)end end)end)end
   else
    local input=D.Box(U.Profile,'@amigo ou UserId',{Size=UDim2.new(1,-6,0,44),LayoutOrder=8})
    button('Convidar amigo',9,function()task.spawn(function()local raw=input.Text:gsub('^@','');local id=tonumber(raw);if not id then local ok,value=pcall(function()return Players:GetUserIdFromNameAsync(raw)end);if ok then id=value end end;if not id then notice('Amigo não encontrado.');return end;act('invite',{id=id})end)end)
    if v.plan=='Pro'then button(v.prefs.share and'Tornar minhas coleções privadas'or'Autorizar coleções para o grupo',10,function()act('pref',{key='share',value=v.prefs.share~=true})end)end
    for i,id in ipairs(v.members or{})do button('Remover amigo '..id,20+i,function()act('revoke',{id=id})end)end
   end
   for i,inv in ipairs(v.invites or{})do button('Aceitar convite de '..inv.owner,40+i*2,function()act('accept',{id=inv.owner})end);button('Recusar convite de '..inv.owner,41+i*2,function()act('decline',{id=inv.owner})end)end
  end
  button('Recarregar perfil e preços',90,function()refresh(true)end)
 end
 return P
end
return M
