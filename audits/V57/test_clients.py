from test_support import *
case('replicated_avatar_fetch_failure_is_reported_with_native_id',THEME+DATA+r'''
local Load=Modules['08B4_AVATAR_LOAD'];local char=assert(Load.Create(A.Unpack(S.Current),'R15'))
char.Parent=workspace;char:SetAttribute('ACP_AvatarEpoch',10);char:SetAttribute('ACP_AvatarTrace','native-apply-10');pl.Character=char
pl:SetAttribute('ACP_AvatarEpoch',10);local requests={}
local folder=Instance.new('Folder');folder.Name='LMShop_Remotes';folder.Parent=rep
local rpc=Instance.new('RemoteFunction');rpc.Name='Request';rpc.Parent=folder
function rpc:InvokeServer(a,d)requests[#requests+1]={a=a,d=d};return{ok=true,data=true}end
FailVisual=true
'''+src('09C12_AVATAR_FEEDBACK')+r'''
flush();assert(pg:GetAttribute('ACP_AvatarVisualState')=='failed')
local report=requests[#requests];assert(report.a=='ReportVisual'and not report.d.success and report.d.epoch==10)
assert(report.d.trace=='native-apply-10'and report.d.stage=='CONTENT'and report.d.cause:find('Failure'))
assert(named(pg,'AvatarFailureDialog').Visible)
FailVisual=false;char:SetAttribute('ACP_AvatarEpoch',11);pl:SetAttribute('ACP_AvatarEpoch',11);flush()
assert(pg:GetAttribute('ACP_AvatarVisualState')=='confirmed'and requests[#requests].d.success and not named(pg,'AvatarFailureDialog').Visible)
return 'actual client verifier emits content failure with the server trace; next confirmed epoch closes the error and reports success'
''')
case('diagnostic_catalog_button_uses_real_open_event',UI+DATA+r'''
local Load=Modules['08B4_AVATAR_LOAD'];local char=assert(Load.Create(A.Unpack(S.Current),'R15'));char.Parent=workspace;pl.Character=char
local opened;U.OpenRequest.Event:Connect(function(page)opened=page end)
'''+src('09C12_AVATAR_FEEDBACK')+r'''
named(pg,'AvatarFailureDialog'):FindFirstChildWhichIsA('TextButton').Activated:Fire();flush()
local found=false
for _,o in ipairs(named(pg,'AvatarFailureDialog'):GetChildren())do if o:IsA('TextButton')and o.Text=='Abrir catálogo'then o.Activated:Fire();found=true end end
assert(found and opened=='Catalog');return 'catalog action fires AvatarShop08Gui.OpenRequest instead of relying on an unused nonce or invalid Activate method'
''')
case('truco_card_store_prices_complete_individually_and_retry',THEME+module('07K6_CARD_CATALOG')+module('07K7_CARD_STYLES')+module('07K16_ATELIER_UI')+module('07K9_CARD_INVENTORY_UI')+r'''
local data={coins=1500,owned={Classic=true},boxes={},ateliers=false,presets={},custom={image=0,zoom=1,x=0,y=0}}
local function call(action)
 if action=='inventory'then return data elseif action=='store'then return{passes={['1951234105']={id=1951234105}},products={Onyx={id=3716298994},Vesper={id=3716299051},Hex={id=3716299236}}}end
end
local requests=0
function Services.MarketplaceService:GetProductInfoAsync(id)
 requests=requests+1;if id==3716299051 then error('price offline')end;return{IsForSale=true,PriceInRobux=1}
end
local g=Instance.new('ScreenGui');g.Parent=pg;g.ScreenInsets=Enum.ScreenInsets.None
local u=Modules['07K9_CARD_INVENTORY_UI'].Build(g,call,function()end);u.Show();flush()
assert(u.Store.products.Onyx.sale and not u.Store.products.Onyx.pending)
assert(not u.Store.products.Vesper.sale and not u.Store.products.Vesper.pending)
assert(u.Store.products.Hex.sale and #u.SampleCards==3 and requests==4)
u.RetryPrices.Activated:Fire();flush();assert(requests==8)
return 'one failed price cannot keep other visuals consulting forever; each purchase needs a confirmed native price; retry reloads the store'
''')
case('assistant_real_controller_keeps_results_in_conversation_and_handles_error',THEME+DATA+PREVIEW+module('09I0_ASSISTANT_CONFIG')+module('09I4_ASSISTANT_UI')+module('09I5_ASSISTANT_QUESTIONNAIRE')+module('09I6_ASSISTANT_RESULTS')+module('09I7_ASSISTANT_PROFILE')+r'''
local cfg=Modules['09I0_ASSISTANT_CONFIG'];local folder=Instance.new('Folder');folder.Name='ACP_AssistantRemotes';folder.Parent=rep
local rpc=Instance.new('RemoteFunction');rpc.Name='Request';rpc.Parent=folder
local event=Instance.new('RemoteEvent');event.Name='Progress';event.Parent=folder
local captured;local account={plan='Normal',available=true,checking=false,count=1,daily=10,owner=123,expires=0,prefs={theme='Halloween',motion=true},collections={},members={},invites={}}
function rpc:InvokeServer(action,d)
 if action=='status'then return{ok=true,data=account}elseif action=='ask'then captured=d;return{ok=true,data={request=d.request}}elseif action=='ad'then return{ok=true,data={hidden=true}}end;return{ok=true,data=true}
end
local build=Modules['09I4_ASSISTANT_UI'].Build;local u
Modules['09I4_ASSISTANT_UI'].Build=function(...)u=build(...);return u end
'''+src('09I_ASSISTANT_CLIENT')+r'''
pg:SetAttribute('ACP_OpenAINonce',1);flush();assert(u.Root.Visible and u.Plan.Text:find('online'))
u.Input.Text='Quero um look emo';u.Send.Activated:Fire();local q=named(u.Chat,'LookQuestionnaire');assert(q.Visible)
for _,b in ipairs(q:GetChildren())do if b:IsA('TextButton')and b.Text=='Confirmar e criar'then b.Activated:Fire()end end
flush();assert(captured and captured.make and captured.options.budget==100)
event.OnClientEvent:Fire({kind='result',request=captured.request,data={answer='Aqui está seu look.',plan='Normal',count=1,requested=1,looks={{name='Emo',body=A.Copy(S.Current),rig='R15',total=30,items={}}}}});flush()
assert(u.Tab=='Conversa'and named(u.Chat,'InlineLooks')and not u.Progress.Visible)
u.Help.Activated:Fire();u.Input.Text='Ajuda';u.Send.Activated:Fire();flush()
event.OnClientEvent:Fire({kind='error',request=captured.request,error='fixture IA error'});flush()
local shown=false;for _,o in ipairs(u.Chat:GetDescendants())do if o:IsA('TextLabel')and o.Text=='fixture IA error'then shown=true end end
assert(shown and not u.Progress.Visible and u.Send.Active)
return 'actual LocalScript opens inline questionnaire, keeps look results in chat, and displays failures inline while releasing the send control'
''')
HERE.joinpath('client_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')

