-- 09I_ACTIVITIES_CLIENT | LocalScript | StarterPlayer > StarterPlayerScripts | V69 (NOVO)
local Rep=game:GetService('ReplicatedStorage');local Players=game:GetService('Players');local Http=game:GetService('HttpService')
local pl=Players.LocalPlayer;local pg=pl:WaitForChild('PlayerGui');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'))
local folder=Rep:WaitForChild('ACP_ActivityRemotes',30);local rpc=folder and folder:WaitForChild('Request',10);local push=folder and folder:WaitForChild('Update',10)
local function call(action,args)
 if not rpc then return nil,'As atividades ainda não conectaram ao servidor. Confira os scripts NOVOS da V69.'end
 local ok,value=pcall(function()return rpc:InvokeServer(action,args or{})end)
 if not ok or type(value)~='table'then return nil,'O servidor da atividade não respondeu.'end
 return value.ok and value.data or nil,value.error
end
local U=require(Rep:WaitForChild('09I16_ACTIVITY_UI')).Build(pl,call)
U.Refresh=function()task.spawn(function()local data,e=call('status');if data then U.SetStatus(data)else U.Status.Text=e end end)end
U.OnCatalog=function()
 local shop=pg:FindFirstChild('AvatarShop08Gui');local bus=shop and shop:FindFirstChild('OpenRequest')
 if bus then U.Root.Visible=false;bus:Fire('Catalog')else U.Status.Text='O catálogo ainda está carregando.'end
end
U.OnCart=function(body)U.Root.Visible=false;require(Rep:WaitForChild('09C4_OUTFIT_LIBRARY')).Open(body)end
U.OnShoot=function(settings)
 U.Root.Visible=false;pg:SetAttribute('ACP_RehearsalSettings',Http:JSONEncode(settings));pg:SetAttribute('ACP_RehearsalNonce',(pg:GetAttribute('ACP_RehearsalNonce')or 0)+1)
end
U.Root.Active=true
U.Root:GetPropertyChangedSignal('Visible'):Connect(function()
 if U.Root.Visible then local assistant=pg:FindFirstChild('ACP_Assistant');local root=assistant and assistant:FindFirstChild('AssistantRoot');if root then root.Visible=false end end
end)
local function inMatch()if pg:GetAttribute('ACP_TrucoActive')or pl:GetAttribute('ACP_InGameRoom')then U.Root.Visible=false end end
pg:GetAttributeChangedSignal('ACP_TrucoActive'):Connect(inMatch);pl:GetAttributeChangedSignal('ACP_InGameRoom'):Connect(inMatch)
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local bounds=Bounds.Bind(U.Gui)
local toast=D.Button(U.Gui,'Convite para criar um look · Abrir',{Name='ActivityInviteNotice',Visible=false,BackgroundColor3=D.Colors.soft,TextSize=14,ZIndex=210})
local pending=false
local function updateToast()
 local il,it,ir,ib,w=bounds.Read();local width=math.min(360,w-il-ir-16);Bounds.Rect(toast,w-ir-width-8,it+58,width,48)
 toast.Visible=pending and not U.Root.Visible and not pg:GetAttribute('ACP_TrucoActive')and not pl:GetAttribute('ACP_InGameRoom')
end
toast.Activated:Connect(function()pending=false;U.Root.Visible=true;U.Kind=nil;U.Refresh();updateToast()end)
bounds.Watch(updateToast);pg:GetAttributeChangedSignal('ACP_TrucoActive'):Connect(updateToast);pl:GetAttributeChangedSignal('ACP_InGameRoom'):Connect(updateToast)
U.Root:GetPropertyChangedSignal('Visible'):Connect(updateToast)
pg:GetAttributeChangedSignal('ACP_OpenActivitiesNonce'):Connect(function()U.Root.Visible=not U.Root.Visible;if U.Root.Visible then U.Refresh()end end)
if push then push.OnClientEvent:Connect(function(data)
 if type(data)~='table'then return end
 if data.kind=='state'then U.SetState(data.session)
 elseif data.kind=='progress'then U.Status.Text=tostring(data.message or'')..' · '..math.clamp(tonumber(data.percent)or 0,0,100)..'%'
 elseif data.kind=='invite'then pending=true;toast.Text=tostring(data.ownerName)..' convidou você · Abrir';updateToast()
 elseif data.kind=='closed'then U.State=nil;U.Kind=nil;U.Render();U.Status.Text=data.message or'Atividade encerrada.'
 elseif data.kind=='error'then U.Status.Text=data.message or'Não foi possível concluir.'end
end)end
-- O painel não altera Enabled de outros ScreenGui; evita disputar o foco das partidas.
