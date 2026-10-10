-- 09C12_AVATAR_FEEDBACK | LocalScript | StarterPlayer > StarterPlayerScripts | V56 (NOVO)
-- Verifica o avatar replicado no aparelho e envia ao Output a etapa/erro do cliente.
local Players=game:GetService('Players');local Rep=game:GetService('ReplicatedStorage');local Http=game:GetService('HttpService')
local pl=Players.LocalPlayer;local pg=pl:WaitForChild('PlayerGui')
local A=require(Rep:WaitForChild('08B_AVATAR_DATA'));local Load=require(Rep:WaitForChild('08B4_AVATAR_LOAD'))
local Diag=require(Rep:WaitForChild('08B5_AVATAR_DIAGNOSTICS'));local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'))
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local C=D.Colors
local gui=D.New('ScreenGui',{Name='ACP_AvatarDiagnostic',ResetOnSpawn=false,DisplayOrder=245,IgnoreGuiInset=true,ScreenInsets=Enum.ScreenInsets.None,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
local root=D.Frame(gui,{Name='AvatarFailureDialog',Visible=false,BackgroundColor3=C.panel,ZIndex=50})
local title=D.Text(root,'A roupa não foi confirmada',{TextSize=19,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=51})
local close=D.IconButton(root,'CloseDiagnostic','close','Fechar diagnóstico',{ZIndex=53})
local stage=D.Text(root,'',{TextSize=14,TextColor3=C.orange,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=51})
local scroll=D.Scroll(root,{Name='FailureDetails',ZIndex=51})
local text=D.Text(scroll,'',{Size=UDim2.new(1,-6,0,200),AutomaticSize=Enum.AutomaticSize.Y,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,ZIndex=52})
local retry=D.Button(root,'Tentar aplicar novamente',{TextSize=12,BackgroundColor3=C.orange,TextColor3=C.bg,ZIndex=52})
local catalog=D.Button(root,'Abrir catálogo',{TextSize=12,ZIndex=52})
local safe=Bounds.Bind(gui);local serial=0;local lastFailure;local lastEpoch=-1
local function layout()
 local il,it,ir,ib,w,h=safe.Read();local rw=math.min(570,w-il-ir-16);local rh=math.min(390,h-it-ib-16)
 Bounds.Rect(root,il+(w-il-ir-rw)/2,it+(h-it-ib-rh)/2,rw,rh)
 Bounds.Rect(title,10,4,rw-72,48);Bounds.Rect(close,rw-54,4,48,48)
 Bounds.Rect(stage,10,58,rw-20,42);Bounds.Rect(scroll,10,104,rw-20,math.max(24,rh-160))
 Bounds.Rect(retry,10,rh-50,(rw-26)/2,44);Bounds.Rect(catalog,(rw+6)/2,rh-50,(rw-26)/2,44)
end
safe.Watch(layout)
local function show(detail)
 lastFailure=detail;stage.Text='Etapa: '..tostring(detail.label or detail.stage or'Confirmação')
 local ids={};for _,id in ipairs(detail.items or{})do ids[#ids+1]=tostring(id)end
 text.Text='Código: '..tostring(detail.trace or'')..'\nOrigem: '..tostring(detail.source or'')..
  '\nItens: '..table.concat(ids,', ')..'\n\nErro do Roblox:\n'..tostring(detail.cause or'Não informado.')..
  (detail.expected and detail.expected~=''and('\n\nEsperado: '..detail.expected)or'')..
  (detail.found and detail.found~=''and('\nEncontrado: '..detail.found)or'')..'\n\nO mesmo código aparece no Output.'
 root.Visible=true;layout()
end
local function failure()
 local raw=pl:GetAttribute('ACP_AvatarFailure');if not raw then root.Visible=false;return end
 local ok,d=pcall(function()return Http:JSONDecode(raw)end);if ok and type(d)=='table'then show(d)end
end
local function rpc(action,args)
 local folder=Rep:FindFirstChild('LMShop_Remotes');local request=folder and folder:FindFirstChild('Request')
 if not request then return nil,'Servidor do catálogo indisponível.'end
 local worked,result=pcall(function()return request:InvokeServer(action,args)end)
 return worked and result and result.ok and result.data or nil,worked and result and result.error or tostring(result)
end
local function report(detail,epoch,success)
 task.spawn(function()
  for _=1,3 do
   local got=rpc('ReportVisual',{epoch=epoch,success=success,trace=detail and detail.trace,stage=detail and detail.stage,
    source=detail and detail.source,cause=detail and Diag.Cut(detail.cause,1000),found=detail and detail.found})
   if got then return end;task.wait(.4)
  end
 end)
end
local function verify()
 local epoch=tonumber(pl:GetAttribute('ACP_AvatarEpoch'));if not epoch or epoch==lastEpoch then return end
 lastEpoch=epoch;serial=serial+1;local mine=serial;pg:SetAttribute('ACP_AvatarVisualState','checking')
 task.spawn(function()
  task.wait(.3);local deadline=os.clock()+8;local char,hum
  repeat
   char=pl.Character;hum=char and char:FindFirstChildOfClass('Humanoid')
   if hum and char:GetAttribute('ACP_AvatarEpoch')==epoch then break end
   task.wait(.1)
  until os.clock()>=deadline or mine~=serial
  if mine~=serial then return end
  local ctx=Diag.New({source='09C12_AVATAR_FEEDBACK.verify',quiet=true})
  if not char or not hum or char:GetAttribute('ACP_AvatarEpoch')~=epoch then
   local _,detail=Diag.Fail(ctx,'STRUCTURE','O avatar confirmado pelo servidor não chegou ao cliente em 8 segundos.','Época '..epoch,char and char:GetAttribute('ACP_AvatarEpoch'))
   pg:SetAttribute('ACP_AvatarVisualState','failed');show(detail);report(detail,epoch,false);return
  end
  ctx.trace=char:GetAttribute('ACP_AvatarTrace')or ctx.trace
  local got,desc=pcall(function()return hum:GetAppliedDescription()end)
  local good,why,proof
  if got then
   ctx.items=Diag.Items(A.Pack(desc))
   good,why,proof=Load.Check(char,desc,hum.RigType.Name,{diagnostic=ctx,alive=function()return mine==serial and pl.Character==char end})
   desc:Destroy()
  else why=tostring(desc);proof={stage='CONFIRM'}end
  if mine~=serial or pl.Character~=char then return end
  if good then root.Visible=false;lastFailure=nil;pg:SetAttribute('ACP_AvatarVisualState','confirmed');report(nil,epoch,true)
  else
   local _,detail=Diag.Fail(ctx,proof and proof.stage or ctx.stage,why,'Avatar completo no cliente',proof and proof.found)
   pg:SetAttribute('ACP_AvatarVisualState','failed');show(detail);report(detail,epoch,false)
  end
 end)
end
close.Activated:Connect(function()root.Visible=false end)
local function openCatalog()
 root.Visible=false;local shop=pg:FindFirstChild('AvatarShop08Gui');local event=shop and shop:FindFirstChild('OpenRequest')
 if event and event:IsA('BindableEvent')then event:Fire('Catalog')end
end
catalog.Activated:Connect(openCatalog)
retry.Activated:Connect(function()
 root.Visible=false;task.spawn(function()
  local S=require(Rep:WaitForChild('08D_SKIN_STATE'));if not S.Current then openCatalog();return end
  local got,why=rpc('Apply',{body=A.Copy(S.Current),rig=S.Rig,base=S.Base,replace=S.Replace==true})
  if not got then failure();if not root.Visible and lastFailure then lastFailure.cause=why;show(lastFailure)end end
 end)
end)
pl:GetAttributeChangedSignal('ACP_AvatarFailure'):Connect(failure)
pl:GetAttributeChangedSignal('ACP_AvatarEpoch'):Connect(verify)
pg:GetAttributeChangedSignal('ACP_OpenAvatarDiagnostic'):Connect(function()if lastFailure then show(lastFailure)end end)
task.defer(verify);task.defer(failure)
