from test_support import *
FEATURE=module('09B8_FREE_HIGHLIGHTS')+"F=Modules['09B8_FREE_HIGHLIGHTS'];fixture60(100,'Camisa Halloween','Shirt');fixture60(101,'Chapéu','Hat');fixture60(102,'Corpo',nil,'Bundle')\n"
case('one_free_slot_idempotent_expiry_and_restart',FEATURE+r'''
StoreRetry=true
local r=F.Submit(pl,{id=100});assert(r.free and r.expires==TIME60+86400 and r.item.ready)
advance60(300);local again=F.Submit(pl,{id=100});assert(again.expires==r.expires)
local ok,e=pcall(F.Submit,pl,{id=101});assert(not ok and e:find('24 horas',1,true))
local fresh=loadModule([====['''+src('09B8_FREE_HIGHLIGHTS')+r''']====],'FreshHighlights')
assert(fresh.Status(pl).item.expires==r.expires)
assert(not pcall(fresh.Submit,pl,{id=101}))
advance60(86400);local newer=fresh.Submit(pl,{id=101});assert(newer.expires==TIME60+86400)
assert(LastPrompt==nil and not StoreData['ACP_CardCommerce_v1'])
return 'same submission does not extend time; other item blocked across module/server restart; expiry releases the slot; no purchase or currency'
''')
case('global_dedup_and_withdraw_keep_original_deadline',FEATURE+r'''
local first=F.Submit(pl,{id=100});local other={UserId=456}
local ok,e=pcall(F.Submit,other,{id=100});assert(not ok and e:find('já está',1,true))
local choice=F.Submit(other,{id=101});assert(choice.item.item.Id==101)
local removed=F.Withdraw(pl);assert(removed.nextAllowed==first.expires)
assert(not pcall(F.Submit,pl,{id=102,kind='Bundle'}))
local third={UserId=789};assert(F.Submit(third,{id=100}).item.item.Id==100)
return 'duplicate asset refused globally without consuming another player slot; withdrawal releases asset but not the owner cooldown'
''')
case('storage_and_listing_failures_are_explicit_and_recoverable',FEATURE+r'''
FailStores=true;assert(not pcall(F.Submit,pl,{id=100}));FailStores=false
FailMemory60=true;local ok,e=pcall(F.Submit,pl,{id=100});assert(not ok and e:find('Envio salvo',1,true))
local r=StoreData.AvatarPlaza_FreeHighlights_v1['u_'..pl.UserId];local deadline=r.expires
assert(F.Status(pl).indexed==false)
FailMemory60=false;assert(F.Submit(pl,{id=100}).expires==deadline)
advance60(1);assert(#F.Feed(pl,{}).items==1)
FailMemory60=true;advance60(1);assert(not pcall(F.Feed,pl,{}))
assert(not pcall(F.Withdraw,pl));FailMemory60=false
assert(F.Status(pl).item==nil);advance60(1);assert(#F.Feed(pl,{}).items==0)
return 'no false publication/success on DataStore or MemoryStore failure; same draft repairs listing; interrupted withdrawal repairs on status reload'
''')
case('favorites_persist_after_expiry_and_never_change_visibility_rank',FEATURE+r'''
local r=F.Submit(pl,{id=100});local rank=Sorted60.AvatarPlaza_FreeHighlights_v1[tostring(pl.UserId)].sortKey
local writes=MapWrites60;assert(F.Favorite(pl,{id=100,value=true}).value)
F.Favorite(pl,{id=100,value=true});assert(#StoreData.AvatarPlaza_FreeHighlights_v1['f_'..pl.UserId]==1)
assert(MapWrites60==writes and Sorted60.AvatarPlaza_FreeHighlights_v1[tostring(pl.UserId)].sortKey==rank)
advance60(86401);local v=F.Feed(pl,{group='Favoritos'});assert(#v.items==1 and v.items[1].item.Id==100)
NativeInfo60[100].IsForSale=false;advance60(70);assert(F.Feed(pl,{group='Favoritos'}).items[1].item.unavailable)
assert(F.Favorite(pl,{id=100,value=false}).value==false)
assert(#StoreData.AvatarPlaza_FreeHighlights_v1['f_'..pl.UserId]==0 and not LastPrompt)
return 'favorites are persistent independent bookmarks, including expired highlights; unavailable items stay marked and can be removed; ranking and payments unchanged'
''')
case('native_validation_purchase_and_live_off_sale_check',FEATURE+r'''
for _,d in ipairs({{id=-1},{id=0/0},{id=100.5},{id=100,kind='Product'},{id=100,kind='Pass'}})do assert(not pcall(F.Check,pl,d))end
fixture60(200,'Imagem','AvatarBackground');assert(not pcall(F.Submit,pl,{id=200}))
F.Submit(pl,{id=100});NativeInfo60[100].IsForSale=false
assert(not pcall(F.Purchase,pl,{id=100})and LastPrompt==nil)
NativeInfo60[100].IsForSale=true;NativeInfo60[100].PriceInRobux=25
assert(F.Check(pl,{id=100}).Price==25);assert(F.Purchase(pl,{id=100}));assert(LastPrompt.kind=='asset'and LastPrompt.id==100)
assert(F.Purchase(pl,{id=102,kind='Bundle'}));assert(LastPrompt.kind=='bundle')
return 'only real avatar catalog items accepted, invalid numbers/products rejected; current availability and price checked before native asset/bundle purchase'
''')
case('bounded_global_pages_wrap_without_duplicates_or_paid_priority',module('09B8_FREE_HIGHLIGHTS')+r'''
local f=Modules['09B8_FREE_HIGHLIGHTS']
for i=1,137 do fixture60(1000+i,'Item '..i,i%2==0 and'Hat'or'Shirt');f.Submit({UserId=900+i},{id=1000+i})end
local all={};local n=0;local r;local calls=0
repeat advance60(1);r=f.Feed(pl,{next=calls>0});calls=calls+1;assert(#r.items<=45)
 for _,v in ipairs(r.items)do assert(not all[v.key]);all[v.key]=true;n=n+1 end
until r.finished or calls>10
assert(n==137 and calls<=5 and r.finished)
advance60(1);local a=f.Feed(pl,{});local other={UserId=51345};local b=f.Feed(other,{})
assert(#a.items==45 and #b.items==45 and a.items[1].key~=b.items[1].key)
advance60(1);local filtered=f.Feed(pl,{group='Acessórios'});for _,v in ipairs(filtered.items)do assert(v.item.group=='Acessórios')end
assert(MapReads60<30 and LastPrompt==nil)
return '137 global items traversed through bounded pages and circular native index; different viewers get different starts; no favoriting or spend rank'
''')
BG=module('07P8_BACKGROUND_RESOLVER')+module('07P7_ROBLOX_BACKGROUNDS')+r'''
local folder=Instance.new('Folder');folder.Name='LMShop_Remotes';folder.Parent=rep
local rpc=Instance.new('RemoteFunction');rpc.Name='Request';rpc.Parent=folder
function rpc:InvokeServer(action,args)
 assert(action=='PhotoBackground');local ok,d=pcall(Modules['07P8_BACKGROUND_RESOLVER'].Resolve,pl,args);return{ok=ok,data=ok and d or nil,error=not ok and d or nil}
end
for i=1,10 do fixture60(800+i,'Perfil '..i,'AvatarBackground');OwnedAssets[800+i]=true end
Inventory60={{}};for i=1,10 do Inventory60[1][i]={AssetId=800+i,Name='Perfil '..i}end
B=Modules['07P7_ROBLOX_BACKGROUNDS']
'''
case('native_owned_background_inventory_does_not_drop_entries',BG+r'''
local r=B.Inventory(false);assert(#r.items==6 and not r.finished and PermissionCalls60==1 and InventoryCalls60==1)
local image,e=B.Image(r.items[1],function()return true end);assert(image and image.source=='RobloxProfile'and image.image=='rbxassetid://8011')
assert(LastBackgroundContainer60.destroyed and LastBackgroundContainer60.Parent==nil)
local next=B.Inventory(true);assert(#next.items==4 and next.finished and next.items[1].id==807)
assert(PermissionCalls60==1 and InventoryCalls60==1)
assert(not B.Image({id=999,name='Invented',source='RobloxProfile'}))
return 'native permission and AvatarBackground filter; 10 inventory entries shown as 6+4 without loss; server resolves only owned profile assets and never parents/executes container'
''')
case('background_permissions_decode_failure_and_cancel_are_honest',BG+r'''
DenyInventory60=true;local r,e=B.Inventory(false);assert(not r and e:find('Autorize',1,true))
DenyInventory60=false;r=B.Inventory(false);OwnedAssets[801]=false;assert(not B.Image(r.items[1]))
OwnedAssets[801]=true;FailImage60=true;local p,e=B.Image(r.items[1],function()return true end)
assert(not p and e:find('fundo anterior',1,true)and not r.items[1].image)
FailImage60=false;assert(not B.Image(r.items[1],function()return false end))
assert(not pcall(Modules['07P8_BACKGROUND_RESOLVER'].Resolve,pl,{id=100}))
return 'denied inventory access, missing ownership, unavailable image and canceled requests never pretend a background was applied'
''')
LEGACY=THEME+DATA+module('09I0_ASSISTANT_CONFIG')+r'''
Account60={plan='Normal',collections={},prefs={},daily=10,count=1,owner=123,storageAvailable=true}
Reserve60=0;Health60=0
installModule('09I1_ASSISTANT_ACCOUNTS',[====[return {View=function()return deep(Account60)end,Reserve=function()Reserve60=Reserve60+1;return deep(Account60)end} ]====])
installModule('09I2_ASSISTANT_ENGINE',[====[return {Available=true,Checked=1,Language='en',Health=function()Health60=Health60+1;return true end,Summary=function()return 'native fixture'end} ]====])
installModule('09I3_OUTFIT_BUILDER',[====[return {}]====]);installModule('09B5_AVATAR_RUNTIME',[====[return {}]====])
loadModule([====['''+src('09I_ASSISTANT_SERVER')+r''']====],'LegacyServer');local rpc=rep:FindFirstChild('ACP_AssistantRemotes').Request
'''
case('retirement_blocks_new_sales_and_keeps_previous_plan',LEGACY+r'''
flush();assert(Health60==0)
local normal=rpc.OnServerInvoke(pl,'status',{});assert(normal.ok and normal.data.retired and not normal.data.available)
advance60(1);assert(not rpc.OnServerInvoke(pl,'ask',{text='Help'}).ok and Reserve60==0)
advance60(1);assert(not rpc.OnServerInvoke(pl,'prompt',{plan='Pro'}).ok and LastPrompt==nil)
Account60.plan='Pro';advance60(1);local paid=rpc.OnServerInvoke(pl,'status',{})
assert(paid.ok and paid.data.plan=='Pro'and not paid.data.retired and pl:GetAttribute('ACP_LegacyAIPlan')=='Pro');flush()
advance60(1);local ad=rpc.OnServerInvoke(pl,'ad',{});assert(ad.ok and ad.data.hidden)
Account60.plan='Normal';advance60(1);assert(rpc.OnServerInvoke(pl,'status',{}).data.retired and pl:GetAttribute('ACP_LegacyAIPlan')==nil)
return 'no native AI startup for free players; new prompts blocked before purchase; existing Pro plan still recognized until expiry, advertising hidden, receipts untouched'
''')
case('real_shop_server_routes_highlights_and_avatar_codes',THEME+DATA+module('07P8_BACKGROUND_RESOLVER')+module('09B8_FREE_HIGHLIGHTS')+SERVER+r'''
local rpc=RPC;fixture60(100,'Camisa Halloween','Shirt')
local r=rpc.OnServerInvoke(pl,'HighlightCheck',{id=100});assert(r.ok and r.data.Id==100)
local posted=rpc.OnServerInvoke(pl,'HighlightSubmit',{id=100});assert(posted.ok and posted.data.free)
advance60(1);local feed=rpc.OnServerInvoke(pl,'HighlightFeed',{});assert(feed.ok and #feed.data.items==1)
local look=rpc.OnServerInvoke(pl,'Code',{code='AV-321'});assert(look.ok and look.data.code=='AV-321'and look.data.body,look.error or'code')
local snapshot=rpc.OnServerInvoke(pl,'AvatarSnapshot',{});assert(snapshot.ok and snapshot.data.body,snapshot.error or'snapshot')
return 'actual RemoteFunction routes publish/feed/check and AV code to native appearance, retaining avatar snapshot endpoint'
''')
HERE.joinpath('feature_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
