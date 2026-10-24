"""Defensive simulations against our own Lua sources; no external game is targeted."""
from test_support import *
GUARD=module('09I26_REQUEST_GUARD')
case('payload_rejects_nan_infinity_cycles_objects_deep_and_oversized_tables',GUARD+r'''
local g=Modules['09I26_REQUEST_GUARD'];local cycle={};cycle.self=cycle;local deep={};local v=deep;for i=1,12 do v.child={};v=v.child end
local wide={};for i=1,129 do wide['k'..i]=i end
for _,v in ipairs({{n=0/0},{n=math.huge},{n=-math.huge},cycle,deep,wide,{obj=Instance.new('Folder')},{text=string.rep('x',8193)},{text=string.char(255)},{[0]='bad'}})do assert(not g.Validate(v))end
local chat={messages={}};for i=1,16 do chat.messages[i]={role='assistant',text=string.rep('a',1200)}end;assert(g.Validate(chat))
local cart={items={}};for i=1,100 do cart.items[i]={id=1000+i,kind='Asset'}end;assert(g.Validate(cart))
assert(g.Validate({text='print("inert text"); require(123456789)',options={budget=100,count=12}}))
return '10 malformed payload families are rejected before handlers; valid 16-message history, 100-item cart and ordinary text remain accepted'
''')
case('one_thousand_rotating_actions_have_shared_rate_limit_and_recover',GUARD+r'''
local g=Modules['09I26_REQUEST_GUARD'].New();local actions={'status','ad','chat.list','chat.read','chat.save','chat.delete','chat.code','body.catalog','shared','more','pref','invite','save','delete','leave'}
local accepted=0;for i=1,1000 do if g.Check(pl,actions[(i-1)%#actions+1],{})then accepted=accepted+1 end end
assert(accepted<=12 and accepted>=1);assert(g.Check(pl,'cancel',{}));assert(not g.Check(pl,'cancel',{}))
advance60(4);assert(g.Check(pl,'status',{}));g.Forget(pl);assert(g.Check(pl,'status',{}))
return 'rotating 15 action names cannot bypass the 12-token burst; cancellation still works, refill restores access and leaving clears state'
''')
case('concurrent_calls_have_global_limit_and_idempotent_release',GUARD+DATA+r'''
local g=Modules['09I26_REQUEST_GUARD'].New();local releases={}
for i=1,24 do local p=makePlayer(1000+i);assert(g.Check(p,'status',{}));releases[i]=assert(g.Enter(p))end
local p=makePlayer(2000);assert(not g.Check(p,'status',{}));releases[1]();releases[1]();advance60(1)
assert(g.Check(p,'status',{}));local release=g.Enter(p);g.Forget(p);release()
for _,f in ipairs(releases)do f()end;advance60(1);assert(g.Check(pl,'status',{}))
return 'the 25th concurrent callback is rejected; releasing twice cannot corrupt capacity and player removal does not leak a slot'
''')
ACCOUNTS=module('09I0_ASSISTANT_CONFIG')+module('09I1_ASSISTANT_ACCOUNTS')
case('plus_pro_ids_are_exact_and_one_hundred_duplicate_receipts_grant_once',ACCOUNTS+r'''
local c=Modules['09I0_ASSISTANT_CONFIG'];local a=Modules['09I1_ASSISTANT_ACCOUNTS']
assert(c.Plans.Studio.product==3717699383 and c.Labels.Studio=='Plus'and c.Plans.Pro.product==3717699454)
local r={PlayerId=pl.UserId,ProductId=3717699383,PurchaseId='purchase-one'};assert(a.Receipt(r,'Studio'));local expiry=a.View(pl.UserId).expires
for i=1,100 do assert(a.Receipt(r,'Studio'))end;assert(a.View(pl.UserId).expires==expiry)
assert(not a.Receipt({PlayerId=pl.UserId,ProductId=3717699454,PurchaseId='purchase-one'},'Pro'));assert(a.View(pl.UserId).plan=='Studio')
local bad={{PlayerId=pl.UserId,ProductId=123,PurchaseId='other'},{PlayerId=0/0,ProductId=3717699383,PurchaseId='bad'},{PlayerId=pl.UserId,ProductId=3717699383},{PlayerId=pl.UserId,ProductId=3717699383,PurchaseId=''}}
for _,v in ipairs(bad)do assert(not a.Receipt(v,'Studio'))end
assert(a.View(pl.UserId).expires==expiry)
return 'Plus and Pro match the supplied IDs; 100 duplicate deliveries cannot extend the plan twice, and malformed or cross-plan receipts do not grant benefits'
''')
case('official_price_does_not_authorize_product_from_another_experience',THEME+r'''
local p=Modules['09I25_PLAN_PRODUCTS'];local calls=0
function Services.MarketplaceService:GetProductInfoAsync(id)calls=calls+1;return{IsForSale=true,PriceInRobux=15}end
function Services.MarketplaceService:GetDeveloperProductsAsync()return{IsFinished=true,GetCurrentPage=function()return{}end}end
assert(p.Check(3717699383,true).ready);local result=p.CheckForPurchase(3717699383);assert(not result.ready and result.stage=='PRODUTO_DE_OUTRA_EXPERIENCIA')
local n=calls;for i=1,100 do assert(not p.Check(999999,true).ready)end;assert(calls==n and not LastPrompt)
return 'a valid public product price is insufficient to open a purchase; ownership by this experience is required and unconfigured IDs never trigger native queries'
''')
case('purchase_lookup_reuses_bounded_official_product_list',THEME+r'''
local p=Modules['09I25_PLAN_PRODUCTS'];local details,lists=0,0
function Services.MarketplaceService:GetProductInfoAsync(id)details=details+1;return{IsForSale=true,PriceInRobux=id==3717699383 and 15 or 25}end
function Services.MarketplaceService:GetDeveloperProductsAsync()lists=lists+1;return{IsFinished=true,GetCurrentPage=function()return{{DeveloperProductId=3717699383},{DeveloperProductId=3717699454}}end}end
for i=1,100 do assert(p.CheckForPurchase(3717699383).experienceVerified);assert(p.CheckForPurchase(3717699454).experienceVerified)end
assert(details==2 and lists==1 and not LastPrompt)
return '200 purchase preflights use two detail queries and a single official current-experience listing; no preflight grants or charges anything'
''')
AI=THEME+DATA+module('09I0_ASSISTANT_CONFIG')+module('09I1_ASSISTANT_ACCOUNTS')+module('09I11_CONVERSATIONS')+module('09I2_ASSISTANT_ENGINE')+module('09I13_OUTFIT_SEARCH')+module('09I3_OUTFIT_BUILDER')+r'''
Modules['09B5_AVATAR_RUNTIME']={Description=function()return HUM,HUM:GetAppliedDescription()end};local o=Instance.new('ModuleScript');o.Name='09B5_AVATAR_RUNTIME';o.Parent=rep
'''+src('09I_ASSISTANT_SERVER')
case('real_ai_rpc_prompt_spam_and_forged_product_cannot_grant_plan',AI+r'''
local rpc=rep.ACP_AssistantRemotes.Request;local a=Modules['09I1_ASSISTANT_ACCOUNTS'];local prompts={}
function Services.MarketplaceService:GetProductInfoAsync()return{IsForSale=true,PriceInRobux=1}end
function Services.MarketplaceService:GetDeveloperProductsAsync()return{IsFinished=true,GetCurrentPage=function()return{{DeveloperProductId=3717699383},{DeveloperProductId=3717699454}}end}end
function Services.MarketplaceService:PromptProductPurchase(p,id)prompts[#prompts+1]=id end
assert(rpc.OnServerInvoke(pl,'prompt',{plan='Plus',product=999999,receipt='forged',price=0}).ok)
for i=1,1000 do assert(not rpc.OnServerInvoke(pl,'prompt',{plan='Pro'}).ok)end
assert(#prompts==1 and prompts[1]==3717699383 and a.View(pl.UserId).plan=='Normal')
advance60(6);assert(rpc.OnServerInvoke(pl,'prompt',{plan='Pro'}).ok and prompts[2]==3717699454);assert(a.View(pl.UserId).plan=='Normal')
assert(not rpc.OnServerInvoke(pl,'receipt',{ProductId=3717699454,PurchaseId='fake'}).ok)
return 'the real remote ignores a forged product/price, throttles 1,000 repeated prompts, has no receipt action and keeps the user free until an official receipt arrives'
''')
case('real_ai_rpc_rejects_nested_attack_without_storage_or_handler_work',AI+r'''
local rpc=rep.ACP_AssistantRemotes.Request;local cycle={};cycle.body=cycle;local before=DSCalls64.writes
for _,v in ipairs({cycle,{body={n=0/0}},{text=string.rep('a',8193)}})do advance60(1);assert(not rpc.OnServerInvoke(pl,'save',v).ok)end
assert(DSCalls64.writes==before);advance60(1);local r=rpc.OnServerInvoke(pl,'status',{owner=999999,plan='Pro'});assert(r.ok and r.data.owner==pl.UserId and r.data.plan=='Normal')
return 'cycles, NaN and oversized data are rejected without a write; spoofing owner/plan on a status request cannot cross the account boundary'
''')
SHOP_DOUBLES=r'''
installModule('09B9_GLOBAL_LOOKS',[====[return{BindDescribe=function()end,Start=function()end}]====])
installModule('09B8_FREE_HIGHLIGHTS',[====[return{Version='fixture',Changed=Instance.new('BindableEvent')}]====])
installModule('09B10_SPONSORED_DESTINATIONS',[====[return{Version='fixture',Changed=Instance.new('BindableEvent')}]====])
installModule('09B12_PRIVATE_LOOKS',[====[return{}]====])
installModule('07P8_BACKGROUND_RESOLVER',[====[return{Version='fixture'}]====])
'''
case('real_shop_rpc_throttles_feed_refresh_and_rejects_invalid_sponsor_payload',THEME+DATA+SHOP_DOUBLES+SERVER+r'''
local calls=0;Modules['09B8_FREE_HIGHLIGHTS'].Feed=function()calls=calls+1;return{items={},finished=true}end
assert(RPC:InvokeServer('HighlightFeed',{}).ok)
for i=1,1000 do assert(not RPC:InvokeServer('HighlightFeed',{}).ok)end;assert(calls==1)
advance60(4);local bad={};bad.self=bad;local before=DSCalls64.writes;assert(not RPC:InvokeServer('HighlightSubmit',bad).ok);assert(DSCalls64.writes==before)
advance60(1);assert(RPC:InvokeServer('HighlightFeed',{}).ok and calls==2)
return 'the real shop server performs one feed call for 1,001 repeated requests; cyclic sponsorship data never reaches storage and normal use resumes after cooldown'
''')
HERE.joinpath('security_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
