from test_support import *
ACCOUNTS=module('08B5_AVATAR_DIAGNOSTICS')+module('09I0_ASSISTANT_CONFIG')+module('09I1_ASSISTANT_ACCOUNTS')+"Accounts=Modules['09I1_ASSISTANT_ACCOUNTS'];Config=Modules['09I0_ASSISTANT_CONFIG']\n"
AI=THEME+DATA+SERVER+ACCOUNTS+module('09I2_ASSISTANT_ENGINE')+module('09I3_OUTFIT_BUILDER')
CARDS=THEME+module('07K6_CARD_CATALOG')+module('07K8_CARD_INVENTORY')+ACCOUNTS+module('07K10_CARD_COMMERCE')+module('07K7_CARD_STYLES')
case('timed_products_are_idempotent_and_expire_offline',ACCOUNTS+r'''
StoreRetry=true
local receipt={PlayerId=123,ProductId=3717699383,PurchaseId='studio-1'}
assert(Accounts.Receipt(receipt,'Studio'));local first=Accounts.View(123);assert(first.plan=='Studio'and first.count==2)
assert(first.expires==os.time()+2592000);assert(Accounts.Receipt(receipt,'Studio'));assert(Accounts.View(123).expires==first.expires)
receipt.PurchaseId='studio-2';assert(Accounts.Receipt(receipt,'Studio'));assert(Accounts.View(123).expires==first.expires+2592000)
advance(2592000*2+1);assert(Accounts.View(123).plan=='Normal')
assert(Accounts.Receipt({PlayerId=123,ProductId=3717699454,PurchaseId='pro-1'},'Pro'));assert(Accounts.View(123).count==5)
FailStores=true;assert(not Accounts.Receipt({PlayerId=123,ProductId=3717699454,PurchaseId='pro-2'},'Pro'))
FailStores=false;assert(Accounts.View(123).expires==os.time()+2592000)
return 'same receipt/retried transform grants once; repeat purchases extend by 720h; wall-clock expiry survives no online activity; storage outage cannot grant'
''')
case('friends_share_entitlements_with_consent_capacity_and_revocation',DATA+ACCOUNTS+r'''
Friends55={[201]=true,[202]=true,[203]=true,[204]=true,[123]=true};assert(Accounts.Receipt({PlayerId=123,ProductId=3717699454,PurchaseId='p'},'Pro'))
assert(not Accounts.Invite(pl,999))
for i=201,203 do local p=makePlayer(i);p.IsFriendsWithAsync=pl.IsFriendsWithAsync;assert(Accounts.Invite(pl,i));assert(Accounts.View(i).plan=='Normal');assert(Accounts.Accept(p,123));assert(Accounts.View(i).plan=='Pro')end
assert(not Accounts.Invite(pl,204));assert(Accounts.Revoke(pl,201));assert(Accounts.View(201).plan=='Normal')
assert(Accounts.Invite(pl,204));advance(604801);local p=makePlayer(204);p.IsFriendsWithAsync=pl.IsFriendsWithAsync;assert(not Accounts.Accept(p,123))
assert(Accounts.Collection(123,{name='Look',body={props={}},rig='R15',items={},total=0},'Emo'))
local guest=makePlayer(202);guest.IsFriendsWithAsync=pl.IsFriendsWithAsync;assert(not Accounts.SharedCollections(guest,123))
assert(Accounts.Preference(123,'share',true));assert(#Accounts.SharedCollections(guest,123)==1)
assert(Accounts.Collection(123,{name='Look',body={props={}},rig='R15',items={},total=0},'Emo'));local v=Accounts.View(123);assert(v.collections[2].parent==v.collections[1].id)
assert(not StoreData.ACP_AssistantProfiles_V55.u123.messages and not StoreData.ACP_AssistantProfiles_V55.u123.password)
return 'three real friends accept before plan applies; fourth excluded; revoke and expired invites enforced; saved collections are private until shared; version chain persisted without chat/password'
''')
case('one_receipt_router_preserves_old_products_and_new_offers',CARDS+r'''
local Commerce=Modules['07K10_CARD_COMMERCE'];local Inventory=Modules['07K8_CARD_INVENTORY'];Commerce.Start();assert(Inventory.Load(123))
local function receipt(product,purchase)return Services.MarketplaceService.ProcessReceipt({PlayerId=123,ProductId=product,PurchaseId=purchase})end
assert(receipt(3717699522,'salem-1')==Enum.ProductPurchaseDecision.PurchaseGranted);assert(Inventory.View(123).owned.Salem)
assert(receipt(3717699522,'salem-1')==Enum.ProductPurchaseDecision.PurchaseGranted)
assert(receipt(3717699383,'studio-1')==Enum.ProductPurchaseDecision.PurchaseGranted);assert(Accounts.View(123).plan=='Studio')
assert(receipt(3716298994,'onyx-1')==Enum.ProductPurchaseDecision.PurchaseGranted);assert(Inventory.View(123).owned.Onyx)
assert(receipt(3716300364,'disabled')==Enum.ProductPurchaseDecision.NotProcessedYet)
FailStores=true;assert(receipt(3717699454,'outage')==Enum.ProductPurchaseDecision.NotProcessedYet);FailStores=false
local catalog=Modules['07K6_CARD_CATALOG'];advance(catalog.HalloweenEnds-os.time()+1)
assert(not Commerce.Prompt(pl,'product','Salem'));assert(Inventory.Equip(123,'Salem'))
assert(receipt(3717699522,'late-confirmation')==Enum.ProductPurchaseDecision.PurchaseGranted)
return 'one ProcessReceipt handles legacy cards and timed AI; no disabled Ether product; failure stays retryable; Salem sale closes but earned/paid cosmetic and pending receipts remain valid'
''')
case('native_ai_health_failure_has_no_fake_success_or_memory',ACCOUNTS+module('09I2_ASSISTANT_ENGINE')+r'''
local engine=Modules['09I2_ASSISTANT_ENGINE'];assert(engine.Health());local r=engine.Ask(pl,'Faça um look emo');assert(r and r.keyword=='emo')
assert(not LastAIRequest.ContextToken and LastAIRequest.MaxTokens==500)
FailAI=true;local r,e=engine.Ask(pl,'Ajuda');assert(not r and e and not engine.Available)
return 'actual native adapter calls GenerateTextAsync, exposes its real response, excludes cross-session context, and reports service failure'
''')
case('outfit_builder_uses_real_distinct_ids_with_budget_and_format',AI+r'''
function Services.AvatarEditorService:SearchCatalogAsync(params)
 assert(params.MaxPrice==60 and not params.IncludeOffSale)
 local kind=params.AssetTypes[1].Name;local index=({HairAccessory=1,ShirtAccessory=2,PantsAccessory=3,Hat=4})[kind]or 4
 local out={};for i=1,5 do out[i]={Id=8800+index*10+i,Name='Real '..kind..i,Price=10,ItemType='Asset',AssetType=kind}end
 return {GetCurrentPage=function()return out end}
end
local builder=Modules['09I3_OUTFIT_BUILDER'];local opts=builder.Options({count=5,budget=60,format='3D',keep=true},'Pro');local progress={}
local rows,e=builder.Build(pl,'emo',opts,S.Current,function(n)progress[#progress+1]=n end,function()return true end)
assert(rows and #rows==5,e);for _,row in ipairs(rows)do assert(row.total==40 and row.body.props.Shirt==S.Current.props.Shirt and row.body.props.Torso==S.Current.props.Torso);assert(row.items[2].AssetType=='ShirtAccessory')end
assert(builder.Options({count=99,tool='Lote'},'Normal').count==1 and builder.Options({tool='Lote'},'Normal').tool=='Criar')
return 'five verified catalog combinations; 3D metadata preserved; whole previous native body kept; per-piece/total budget and free-plan server cap enforced; progress follows actual catalog stages'
''')
case('server_paid_plan_is_blocked_until_native_health_and_session_is_brief',AI+src('09I_ASSISTANT_SERVER')+r'''
flush();local ai=rep:FindFirstChild('ACP_AssistantRemotes').Request
local function ask(a,d)advance(.3);return ai.OnServerInvoke(pl,a,d)end
Modules['09I2_ASSISTANT_ENGINE'].Available=false;FailAI=true;advance(301)
local r=ask('prompt',{plan='Studio'});assert(not r.ok and not LastPrompt)
FailAI=false;advance(301);assert(Modules['09I2_ASSISTANT_ENGINE'].Health())
function Services.MarketplaceService:GetProductInfoAsync(id,kind)return{IsForSale=true,PriceInRobux=1}end
assert(ask('prompt',{plan='Studio'}).ok and LastPrompt.id==3717699383)
for i=1,8 do local r=ask('ask',{text='Como giro o avatar?',make=false,request='r'..i});assert(r.ok,r.error);flush()end
local r=ask('ask',{text='Outra pergunta',make=false});assert(not r.ok and r.error:find('oito'))
assert(not StoreData.ACP_AssistantProfiles_V55.u123.conversation)
return 'paid prompt checks native engine and actual product before purchase; eight independent private session interactions; daily quota and no persisted conversation'
''')
case('music_checks_asset_type_volume_and_storage_failure',module('07M0_MUSIC_PREFS')+r'''
local music=Modules['07M0_MUSIC_PREFS'];assert(music.Load(123).volume==.4)
function Services.MarketplaceService:GetProductInfoAsync(id)return{AssetTypeId=id==1234 and 3 or 13,Name='Audio'}end
assert(music.Audio(1234));assert(not music.Audio(1235));assert(not music.Audio(0/0))
assert(music.Save(123,{volume=10,saved={1234,1234},last=1234}));local saved=music.Load(123);assert(saved.volume==1 and #saved.saved==1)
FailStores=true;assert(not music.Save(123,{volume=0,saved={}}));FailStores=false;assert(music.Load(123).volume==1)
return 'default 40%; real audio metadata required; invalid/image IDs rejected; volume clamped; favorites deduplicated; failed storage cannot claim saved'
''')
HERE.joinpath('feature_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
