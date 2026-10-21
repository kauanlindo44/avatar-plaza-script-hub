-- 09I_ASSISTANT_CLIENT | LocalScript | StarterPlayer > StarterPlayerScripts | V73 (SUBSTITUIR)
local Players=game:GetService('Players');local Rep=game:GetService('ReplicatedStorage');local Http=game:GetService('HttpService')
local pl=Players.LocalPlayer;local pg=pl:WaitForChild('PlayerGui')
if script:IsA('LocalScript')and script.Name~='09I_ASSISTANT_CLIENT'then warn('[ACP V73] Fonte da assistente no script errado: '..script:GetFullName()..'. Restaure a fonte correta desse script.');return end
local owner=pg:FindFirstChild('ACP_AssistantOwner')
if owner and owner.Value and owner.Value.Parent then warn('[ACP V73] Assistente duplicada; mantendo '..owner.Value:GetFullName()..'. Deixe apenas um 09I_ASSISTANT_CLIENT.');return end
owner=owner or Instance.new('ObjectValue');owner.Name='ACP_AssistantOwner';owner.Value=script;owner.Parent=pg
local C=require(Rep:WaitForChild('09I0_ASSISTANT_CONFIG'))
local U=require(Rep:WaitForChild('09I4_ASSISTANT_UI')).Build(pl)
local Progress=require(Rep:WaitForChild('09I23_REQUEST_PROGRESS')).Build(U);local continuation=0
local rem=Rep:WaitForChild('ACP_AssistantRemotes',30);local rpc=rem and rem:WaitForChild('Request',10);local event=rem and rem:WaitForChild('Progress',10)
local busy=false;local request;local account={plan='Normal',count=1};local Results;local Profile;local refresh;local lastCall=0;local resetting=false
local function notice(text)U.Notice.Text=tostring(text==C.Disclosure and'Assistente de looks • escolhas obrigatórias e peças verificadas'or text or'')end
local function call(a,args)
 if not rpc then return nil,'O servidor da IA ainda não conectou.'end
 local function finish(value,errorText)return value,errorText end
 local now=os.clock();local slot=math.max(now,lastCall+.35);lastCall=slot;if slot>now then task.wait(slot-now)end
 local done=false;local ok,result;task.spawn(function()ok,result=pcall(function()return rpc:InvokeServer(a,args or{})end);done=true end)
 local limit=os.clock()+15;while not done and os.clock()<limit do task.wait(.05)end
 if not done then return finish(nil,'O servidor demorou. Recarregue.')end
 if not ok or type(result)~='table'then return finish(nil,'O servidor não respondeu.')end
 if result.protocol~=2 then return finish(nil,'Servidor antigo/duplicado da IA respondeu. Confira 09I_ASSISTANT_SERVER e reinicie Play.')end
 return finish(result.ok and result.data or nil,result.error)
end
Results=require(Rep:WaitForChild('09I6_ASSISTANT_RESULTS')).Build(U,call,notice)
refresh=function(force)task.spawn(function()
 U.Health(account.plan,account.available,true)
 local v,e=call('status',{retry=force==true});if not v then U.Health(account.plan,false,false);notice(e);return end;account=v;U.Language=v.language or'pt';U.Health(v.plan,v.available,v.checking)
 Results.Plan=v.plan;Results.SetSaved(v.collections);Profile.Render(v);if U.SetAppearance then U.SetAppearance(v.prefs and v.prefs.assistantTheme or'Suave')end;notice(v.storageError or(v.connectionError and('Conexão: '..v.connectionError..' • '..tostring(v.diagnostic or'use Recarregar IA')))or C.Disclosure)
 if v.retired then U.Root.Visible=false;notice(v.disclosure);return end
 local fx=require(Rep:WaitForChild('07UI_SURFACE_EFFECTS'));if v.prefs.theme and pg:GetAttribute('ACP_HalloweenMode')==nil then require(Rep:WaitForChild('07UI_HALLOWEEN_THEME')).SetMode(pg,v.prefs.theme=='Neutro'and'Off'or v.prefs.theme=='Halloween'and'On'or'Auto')end;if v.prefs.motion~=nil then pg:SetAttribute('ACP_ReducedMotion',v.prefs.motion==false)end
end)end
Results.Refresh=refresh
Profile=require(Rep:WaitForChild('09I7_ASSISTANT_PROFILE')).Build(U,call,notice,refresh,function(rows)Results.SetSaved(rows);U.Select('Salvos');Results.Resume()end)
U.Upgrade.Activated:Connect(function()Profile.Page='Planos';U.Select('Perfil');Profile.Render(account)end)
local Guide=require(Rep:WaitForChild('09I9_GAME_GUIDE'));local Choice=require(Rep:WaitForChild('07UI_CHOICE_LIST'))
local helpChoices=Choice.Build(U.Body)
local message;local make=true
local function send(options)
 if busy then return end
 if not message or message:match('^%s*$')then notice('Escreva seu pedido.');return end
 continuation=continuation+1;busy=true;U.Send.Active=false;Progress.Reset();Progress.Busy(true);request=Http:GenerateGUID(false);U.Progress.Visible=true;U.Progress.Text='Entendendo seu pedido…'
 U.Select('Conversa');U.Add(message,true);U.Progress.LayoutOrder=U.NextOrder();U.ScrollBottom();local current=request
 task.spawn(function()
  local accepted,e=call('ask',{text=message,options=options,make=make and not Guide.IsQuestion(message),request=current,baseIndex=Results.Index,baseKey=Results.Rows[Results.Index]and Results.Rows[Results.Index].key})
  if request~=current then return end
  if not accepted then busy=false;Progress.Busy(false);U.Send.Active=true;U.Progress.Visible=false;U.Add(e or'Não foi possível iniciar.',false);notice(e);return end
  U.Input.Text='';local seconds=require(Rep:WaitForChild('09I21_LOOK_CONTRACT')).Effort(options and options.effort,account.plan).seconds;task.delay(seconds+25,function()if busy and request==current then call('cancel');request=nil;busy=false;U.Send.Active=true;Progress.Busy(false);U.Progress.Visible=false;U.Add('A solicitação demorou. Seu pedido pode ser enviado novamente.',false);notice('Tente novamente.')end end)
 end)
end
local Q=require(Rep:WaitForChild('09I5_ASSISTANT_QUESTIONNAIRE')).Build(U,send,call)
local ChatNav=require(Rep:WaitForChild('09I10_CHAT_NAV')).Build(U,call,notice)
local Efforts=require(Rep:WaitForChild('09I21_LOOK_CONTRACT'));local EffortButton=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM')).Button(U.Root,'Esforço · Padrão ▾',{Name='AssistantEffortSelector',TextSize=12,ZIndex=82})
EffortButton.Activated:Connect(function()if U.Tab~='Conversa'then U.Select('Conversa');return end;local rows={};for _,v in ipairs(Efforts.Efforts)do rows[#rows+1]={id=v.id,name=v.name,note=v.paid and'Plus e Pro'or'Disponível'}end;helpChoices.Open('Esforço da busca',rows,pg:GetAttribute('ACP_AssistantEffort')or'Padrao',function(v)local e=Efforts.Effort(v.id,account.plan);if e.id~=v.id then notice('Esse modo está disponível em Plus e Pro.');return end;pg:SetAttribute('ACP_AssistantEffort',v.id);EffortButton.Text=e.name..' ▾'end)end)
U.OnSwitchConversation=function()continuation=continuation+1;Progress.Busy(false);request=nil;busy=false;U.Send.Active=true;U.Progress.Visible=false;Q.CloseGuide();Q.Reset();Results.NewConversation();task.spawn(function()call('newchat')end)end
local mode
local function submit()
 if busy or resetting then return end;if account.available~=true then notice('O assistente está conectando. Use Recarregar para tentar novamente.');return end;message=U.Input.Text:sub(1,1200)
 if message:match('^%s*$')then notice('Escreva seu pedido.');return end
 local text=message:lower();local social=text=='oi'or text=='olá'or text=='ola'or text=='tudo bem'or text=='valeu'or text:find('obrigad',1,true)
 if Guide.IsLookRequest(message)then mode(true);Q.Open(account.plan,message)else mode(false);send({count=1})end
end
U.Send.Activated:Connect(submit);U.Input.FocusLost:Connect(function(enter)if enter and(not account.prefs or account.prefs.enterSend~=false)then submit()end end)
mode=function(v)make=v;U.Make.BackgroundColor3=v and Color3.fromRGB(38,116,108)or Color3.fromRGB(237,243,244);U.Help.BackgroundColor3=not v and Color3.fromRGB(38,116,108)or Color3.fromRGB(237,243,244);local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));U.Make.TextColor3=v and D.Colors.bg or D.Colors.white;U.Help.TextColor3=not v and D.Colors.bg or D.Colors.white end
U.Make.Activated:Connect(function()mode(true);message=U.Input.Text:match('^%s*$')and'Quero criar um look'or U.Input.Text;Q.Open(account.plan,message)end);U.Help.Activated:Connect(function()mode(false)end);mode(true)
U.OnSuggest=mode
U.OnCategory=function(kind,text)
 if busy or resetting then return end
 if kind=='activities'then pg:SetAttribute('ACP_OpenActivitiesNonce',(pg:GetAttribute('ACP_OpenActivitiesNonce')or 0)+1)
 elseif kind=='help'then
  helpChoices.Open('Guia do jogo',Guide.Topics,nil,function(v)mode(false);message='Como usar '..v.name..'?';U.Input.Text=message;send({count=1})end)
 elseif kind then
  mode(true);message=text;U.Input.Text=text;Q.Open(account.plan,message)
  if kind=='styles'then Q.OpenStyles()elseif kind=='budget'then Q.OpenBudget()end
 else mode(false);message=text;send({count=1})end
end
U.NewChat.Activated:Connect(function()
 if resetting then return end;if U.BeforeNewChat then U.BeforeNewChat()end;resetting=true;continuation=continuation+1;Progress.Busy(false);request=nil;busy=false;U.Send.Active=false;U.NewChat.Active=false;U.Progress.Visible=false
 helpChoices.Hide();Q.CloseGuide();Q.Reset();Results.NewConversation();U.ClearConversation();U.Input.Text='';U.Select('Conversa')
 task.spawn(function()local ok,e=call('newchat');resetting=false;U.Send.Active=true;U.NewChat.Active=true;notice(ok and'Nova conversa pronta. Seus looks salvos e limites foram mantidos.'or e)end)
end)
U.Connection.Activated:Connect(function()refresh(true)end)
for name,b in pairs(U.TabButtons)do b.Activated:Connect(function()Results.Hide();U.Select(name);Results.Resume();if name=='Perfil'or name=='Salvos'then refresh()end end)end
U.OnLayout=function(w,h)Results.Layout(w,h);Q.Layout();ChatNav.Layout();EffortButton.Position=U.TabButtons.Conversa.Position;EffortButton.Size=U.TabButtons.Conversa.Size;U.TabButtons.Conversa.Visible=false;EffortButton.Text=U.Tab=='Conversa'and(Efforts.Effort(pg:GetAttribute('ACP_AssistantEffort'),account.plan).name..' ▾')or'‹ Conversa'end
local function close()continuation=continuation+1;Progress.Busy(false);helpChoices.Hide();U.Root.Visible=false;Q.CloseGuide();Results.Hide();if busy then task.spawn(function()call('cancel')end);request=nil;busy=false;U.Send.Active=true;U.Progress.Visible=false end end
U.Close.Activated:Connect(close)
if event then event.OnClientEvent:Connect(function(data)
 if type(data)~='table'then return end
 if data.kind=='health'then U.Language=data.language or'pt';account.available=data.available;account.checking=data.checking;U.Health(account.plan,data.available,data.checking);if U.Root.Visible then refresh()end;return end
 if data.request~=request then return end
 if data.kind=='progress'then Progress.Update(data);if U.ProgressFill then U.ProgressFill.Size=UDim2.fromScale(math.clamp(tonumber(data.percent)or 0,0,100)/100,1)end;U.Progress.Text=tostring(data.label)..' • '..math.clamp(tonumber(data.percent)or 0,0,100)..'%';U.ScrollBottom()
 elseif data.kind=='result'or data.kind=='error'then
  busy=false;Progress.Busy(false);U.Send.Active=true;U.Progress.Visible=false;request=nil
  if data.kind=='error'then
   if data.available~=nil then account.available=data.available;U.Health(account.plan,data.available,false)end
   U.Add(data.error or'Não foi possível concluir.',false);notice(data.error);refresh();return end
  U.Language=data.data.language or'pt';local block=U.Add(data.data.answer,false);Results.Accept(data.data)
  if data.data.batch then local mine=continuation;U.Progress.Text='Lote '..tostring(data.data.completed)..' / '..tostring(data.data.target)..' · preparando próximos 5';U.Progress.Visible=true;Progress.Busy(true)
   task.delay(1,function()if mine~=continuation or not U.Root.Visible or busy then return end
    busy=true;request=Http:GenerateGUID(false);local current=request;task.delay(130,function()if busy and request==current then call('cancel');continuation=continuation+1;busy=false;request=nil;Progress.Busy(false);U.Progress.Visible=false;U.Add('O lote demorou. Os looks já criados continuam disponíveis.',false)end end);task.spawn(function()local accepted,e=call('more',{batch=data.data.batch,request=current});if request~=current then return end;if not accepted then busy=false;Progress.Busy(false);U.Progress.Visible=false;U.Add(e or'Não foi possível continuar o lote.',false)end end)
   end)
  end
  if #(data.data.looks or{})>0 then U.Select('Conversa');Results.Resume();notice(data.data.count<data.data.requested and'Encontrei menos variações distintas nesse orçamento.'or'Looks verificados. Arraste a prévia para girar; confirme antes de usar.')end
  task.spawn(function()local ad=call('ad');if ad then U.Ad(block,ad,function()U.Root.Visible=false;pg:SetAttribute('ACP_OpenCatalogAsset',nil);pg:SetAttribute('ACP_OpenCatalogAsset',ad.id)end)end end)
 end
end)end
U.OnCancelRequest=function()continuation=continuation+1;local was=busy;request=nil;busy=false;Progress.Busy(false);U.Send.Active=true;U.Progress.Visible=false;task.spawn(function()call('cancel')end);notice(was and'Busca interrompida. Seus looks anteriores continuam disponíveis.'or'Próximos lotes interrompidos.')end
local nonce=tonumber(pg:GetAttribute('ACP_OpenAINonce'))or 0
pg:GetAttributeChangedSignal('ACP_OpenAINonce'):Connect(function()local n=tonumber(pg:GetAttribute('ACP_OpenAINonce'))or 0;if n~=nonce then nonce=n;if U.Root.Visible then close()else U.Root.Visible=true;U.Select('Conversa');refresh()end end end)
U.Sponsor.Activated:Connect(function()close();local shop=pg:FindFirstChild('AvatarShop08Gui');local bus=shop and shop:FindFirstChild('OpenRequest');if bus then bus:Fire('Stores')end end)
local hidden={};U.Root:GetPropertyChangedSignal('Visible'):Connect(function()for _,name in ipairs({'LimitedMarketHUD','AvatarShopLauncherGui','AvatarShop08Gui','ACP_Music'})do local g=pg:FindFirstChild(name);if g then if U.Root.Visible then if hidden[g]==nil then hidden[g]=g.Enabled end;g.Enabled=false elseif hidden[g]~=nil then g.Enabled=hidden[g];hidden[g]=nil end end end end)
pg:GetAttributeChangedSignal('ACP_TrucoActive'):Connect(function()if pg:GetAttribute('ACP_TrucoActive')then close()end end)
game:GetService('UserInputService').InputBegan:Connect(function(i,gp)if not gp and U.Root.Visible and(i.KeyCode==Enum.KeyCode.Escape or i.KeyCode==Enum.KeyCode.ButtonB)then if Q.Shade.Visible then Q.CloseGuide() else close()end end end)
U.Gui.Destroying:Connect(function()close();if owner.Value==script then owner.Value=nil end end);notice(C.Disclosure)
game:GetService('MarketplaceService').PromptProductPurchaseFinished:Connect(function(uid,id,bought)
 if uid~=pl.UserId or not bought or(id~=C.Plans.Studio.product and id~=C.Plans.Pro.product)then return end
 -- Fechar o prompt não concede o plano; o perfil lido é o concedido por ProcessReceipt.
 for _,delay in ipairs({1,3,8})do task.delay(delay,function()if U.Root.Visible then refresh()end end)end
end)

-- Consulta apenas o plano existente; não abre a IA nem compra produtos.
task.defer(function()local v=call('status');if v then pl:SetAttribute('ACP_LegacyAIPlan',v.plan~='Normal'and v.plan or nil)end end)
