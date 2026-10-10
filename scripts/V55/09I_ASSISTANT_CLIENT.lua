-- 09I_ASSISTANT_CLIENT | LocalScript | StarterPlayer > StarterPlayerScripts | V55 (NOVO)
local Players=game:GetService('Players');local Rep=game:GetService('ReplicatedStorage');local Http=game:GetService('HttpService')
local pl=Players.LocalPlayer;local pg=pl:WaitForChild('PlayerGui');local C=require(Rep:WaitForChild('09I0_ASSISTANT_CONFIG'))
local U=require(Rep:WaitForChild('09I4_ASSISTANT_UI')).Build(pl)
local rem=Rep:WaitForChild('ACP_AssistantRemotes',30);local rpc=rem and rem:WaitForChild('Request',10);local event=rem and rem:WaitForChild('Progress',10)
local busy=false;local request;local account={plan='Normal',count=1};local Results;local Profile;local refresh;local lastCall=0
local function notice(text)U.Notice.Text=tostring(text or C.Disclosure)end
local function call(a,args)
 if not rpc then return nil,'O servidor da IA ainda não conectou.'end
 local waitFor=.3-(os.clock()-lastCall);if waitFor>0 then task.wait(waitFor)end;lastCall=os.clock()
 local done=false;local ok,result;task.spawn(function()ok,result=pcall(function()return rpc:InvokeServer(a,args or{})end);done=true end)
 local limit=os.clock()+15;while not done and os.clock()<limit do task.wait(.05)end
 if not done then return nil,'O servidor demorou. Recarregue.'end
 if not ok or type(result)~='table'then return nil,'O servidor não respondeu.'end
 return result.ok and result.data or nil,result.error
end
Results=require(Rep:WaitForChild('09I6_ASSISTANT_RESULTS')).Build(U,call,notice)
refresh=function(force)task.spawn(function()
 local v,e=call('status',{retry=force==true});if not v then notice(e);return end;account=v;U.Plan.Text=v.plan..(v.available and' • online'or' • indisponível')
 Results.Plan=v.plan;Results.SetSaved(v.collections);Profile.Render(v);notice(C.Disclosure)
 local fx=require(Rep:WaitForChild('07UI_SURFACE_EFFECTS'));pg:SetAttribute('ACP_HalloweenEnabled',v.prefs.theme~='Neutro');pg:SetAttribute('ACP_ReducedMotion',v.prefs.motion==false)
end)end
Results.Refresh=refresh
Profile=require(Rep:WaitForChild('09I7_ASSISTANT_PROFILE')).Build(U,call,notice,refresh,function(rows)Results.SetSaved(rows);U.Select('Salvos');Results.Resume()end)
local message;local make=true
local function send(options)
 if busy then return end
 if not account.available then notice('IA Roblox indisponível. Abra Perfil e recarregue.');return end
 if not message or message:match('^%s*$')then notice('Escreva seu pedido.');return end
 busy=true;U.Send.Active=false;request=Http:GenerateGUID(false);U.Progress.Visible=true;U.Progress.Text='Conectando…'
 U.Select('Conversa');U.Add(message,true);local current=request
 task.spawn(function()
  local accepted,e=call('ask',{text=message,options=options,make=make,request=current,baseIndex=Results.Index})
  if request~=current then return end
  if not accepted then busy=false;U.Send.Active=true;U.Progress.Visible=false;notice(e);return end
  U.Input.Text='';task.delay(60,function()if busy and request==current then call('cancel');request=nil;busy=false;U.Send.Active=true;U.Progress.Visible=false;notice('A solicitação demorou. Tente novamente.')end end)
 end)
end
local Q=require(Rep:WaitForChild('09I5_ASSISTANT_QUESTIONNAIRE')).Build(U,send)
local function submit()
 if busy then return end;message=U.Input.Text:sub(1,1200)
 if make then Q.Open(account.plan)else send({count=1})end
end
U.Send.Activated:Connect(submit);U.Input.FocusLost:Connect(function(enter)if enter then submit()end end)
local function mode(v)make=v;U.Make.BackgroundColor3=v and Color3.fromRGB(114,70,39)or Color3.fromRGB(39,40,48);U.Help.BackgroundColor3=not v and Color3.fromRGB(114,70,39)or Color3.fromRGB(39,40,48)end
U.Make.Activated:Connect(function()mode(true)end);U.Help.Activated:Connect(function()mode(false)end);mode(true)
for name,b in pairs(U.TabButtons)do b.Activated:Connect(function()Results.Hide();U.Select(name);Results.Resume();if name=='Perfil'or name=='Salvos'then refresh()end end)end
U.OnLayout=function(w,h)Results.Layout(w,h)end
local function close()U.Root.Visible=false;Q.Shade.Visible=false;Results.Hide();if busy then task.spawn(function()call('cancel')end);request=nil;busy=false;U.Send.Active=true;U.Progress.Visible=false end end
U.Close.Activated:Connect(close)
if event then event.OnClientEvent:Connect(function(data)
 if type(data)~='table'then return end
 if data.kind=='health'then account.available=data.available;if U.Root.Visible then refresh()end;return end
 if data.request~=request then return end
 if data.kind=='progress'then U.Progress.Text=tostring(data.label)..' • '..math.clamp(tonumber(data.percent)or 0,0,100)..'%'
 elseif data.kind=='result'or data.kind=='error'then
  busy=false;U.Send.Active=true;U.Progress.Visible=false;request=nil
  if data.kind=='error'then notice(data.error);return end
  local block=U.Add(data.data.answer,false);Results.Accept(data.data)
  if #(data.data.looks or{})>0 then U.Select('Looks');Results.Resume();notice(data.data.count<data.data.requested and'Encontrei menos variações distintas nesse orçamento.'or'Looks prontos. Gire a prévia para conferir.')end
  task.spawn(function()local ad=call('ad');if ad then U.Ad(block,ad,function()U.Root.Visible=false;pg:SetAttribute('ACP_OpenCatalogAsset',nil);pg:SetAttribute('ACP_OpenCatalogAsset',ad.id)end)end end)
 end
end)end
local nonce=tonumber(pg:GetAttribute('ACP_OpenAINonce'))or 0
pg:GetAttributeChangedSignal('ACP_OpenAINonce'):Connect(function()local n=tonumber(pg:GetAttribute('ACP_OpenAINonce'))or 0;if n~=nonce then nonce=n;if U.Root.Visible then close()else U.Root.Visible=true;U.Select('Conversa');refresh()end end end)
pg:GetAttributeChangedSignal('ACP_TrucoActive'):Connect(function()if pg:GetAttribute('ACP_TrucoActive')then close()end end)
game:GetService('UserInputService').InputBegan:Connect(function(i,gp)if not gp and U.Root.Visible and(i.KeyCode==Enum.KeyCode.Escape or i.KeyCode==Enum.KeyCode.ButtonB)then if Q.Shade.Visible then Q.Shade.Visible=false else close()end end end)
U.Gui.Destroying:Connect(close);notice(C.Disclosure)
game:GetService('MarketplaceService').PromptProductPurchaseFinished:Connect(function(uid,id,bought)
 if uid~=pl.UserId or not bought or(id~=C.Plans.Studio.product and id~=C.Plans.Pro.product)then return end
 -- Fechar o prompt não concede o plano; o perfil lido é o concedido por ProcessReceipt.
 for _,delay in ipairs({1,3,8})do task.delay(delay,function()if U.Root.Visible then refresh()end end)end
end)
