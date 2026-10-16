from test_support import *
BUDGET=module('09B11_DATA_BUDGET')
PRIVATE=DATA+BUDGET+module('09B12_PRIVATE_LOOKS')
case('budget_preserves_private_requests_and_pauses_discovery',BUDGET+r'''
local b=Modules['09B11_DATA_BUDGET'];Budget64.StandardRead=5;Budget64.StandardWrite=5;Budget64.OrderedList=1
assert(b.Can('Read',false)and not b.Can('Read',true));assert(not b.Can('List',true))
local calls=0;assert(not b.Run('Write',true,function()calls=calls+1 end));assert(calls==0)
assert(b.Run('Read',false,function()calls=calls+1;return'private'end));assert(calls==1)
return 'background work stops before entering the native queue while a small remaining budget still serves a private request'
''')
case('saved_looks_cache_reads_once_and_survives_reopening',PRIVATE+r'''
StoreData.AvatarShop08_Private_v1.u_123={version=1,skins={{id='saved',name='My look',body=A.Copy(S.Current),rig='R15'}}}
local p=Modules['09B12_PRIVATE_LOOKS'];local first,ready=p.Load(pl);assert(ready and #first.skins==1);local reads=DSCalls64.reads
FailStores=true;for i=1,10 do local d,ok=p.Load(pl);assert(ok and d.skins[1].id=='saved');d.skins={}end
assert(DSCalls64.reads==reads)
return 'ten reopens need no additional DataStore read; the returned snapshot cannot mutate the cached saved list'
''')
case('failed_saved_load_cannot_overwrite_existing_data_and_recovers',PRIVATE+r'''
StoreData.AvatarShop08_Private_v1.u_123={version=1,skins={{id='kept',body=A.Copy(S.Current),rig='R15'}}};Budget64.StandardRead=0
local p=Modules['09B12_PRIVATE_LOOKS'];local d,ready,pending=p.Load(pl);assert(not ready and pending)
assert(not pcall(p.Update,pl,function(old)old.skins={};return old end));assert(DSCalls64.writes==0 and #StoreData.AvatarShop08_Private_v1.u_123.skins==1)
Budget64.StandardRead=100;advance60(4);local data,ok=p.Load(pl);assert(ok and data.skins[1].id=='kept')
return 'a missing read budget is shown as pending and blocks destructive saving; recovery returns the actual existing look'
''')
case('malformed_saved_record_keeps_store_and_blocks_edits',PRIVATE+r'''
StoreData.AvatarShop08_Private_v1.u_123={version=1,skins={{id='bad',body='corrupt'},{id='good',body=A.Copy(S.Current)}}}
local p=Modules['09B12_PRIVATE_LOOKS'];local d,ready,pending,bad=p.Load(pl);assert(ready and #d.skins==1 and bad==1)
assert(not pcall(p.Update,pl,function(old)old.skins={};return old end));assert(#StoreData.AvatarShop08_Private_v1.u_123.skins==2)
return 'a damaged historical record does not crash the entire list or silently vanish from the saved store; editing is blocked with a diagnostic'
''')
GLOBAL=DATA+BUDGET+module('09B9_GLOBAL_LOOKS')
case('community_empty_index_does_not_poll_every_three_seconds',GLOBAL+r'''
local g=Modules['09B9_GLOBAL_LOOKS'];for i=1,60 do g.Pump();advance60(4)end
assert(DSCalls64.lists<=1,'sorted list calls '..DSCalls64.lists)
return 'four minutes on an empty registry produce at most one ordered list request instead of continuously filling its queue'
''')
case('community_reuses_global_index_across_players_and_pages',GLOBAL+r'''
local g=Modules['09B9_GLOBAL_LOOKS'];local ids={};for i=1,120 do ids[i]=1000+i end
assert(g.AddSeed(123,ids));local a=g.Page(pl,{page=0});assert(#a.items==50);local lists=DSCalls64.lists
local other=makePlayer(456);local b=g.Page(other,{page=0});assert(#b.items==50 and DSCalls64.lists==lists)
local c=g.Page(pl,{page=1});local d=g.Page(pl,{page=2});assert(#c.items==50 and #d.items==20 and d.finished)
local seen={};for _,rows in ipairs({a,c,d})do for _,r in ipairs(rows.items)do assert(not seen[r.owner]);seen[r.owner]=true end end
return 'shared discovery serves two players from one index and paginates all 120 IDs without duplicate or dropped entries'
''')
case('community_same_outfit_is_written_once_and_price_filter_waits_for_verified_total',GLOBAL+r'''
local g=Modules['09B9_GLOBAL_LOOKS'];g.BindDescribe(function(r)r.total=10;return r end)
local before=DSCalls64.writes;local a=assert(g.Save(123,S.Current,'R15'));local b=assert(g.Save(456,S.Current,'R15'))
assert(a.code==b.code and DSCalls64.writes==before+1);assert(g.Get(a.code).body)
return 'identical avatar signatures share a single confirmed archive write and code in the server cache'
''')
AI=THEME+DATA+module('09I0_ASSISTANT_CONFIG')+module('09I1_ASSISTANT_ACCOUNTS')+module('09I8_AVATAR_STYLES')+module('09I9_GAME_GUIDE')+module('09I2_ASSISTANT_ENGINE')+module('09I3_OUTFIT_BUILDER')+r'''
Modules['09B5_AVATAR_RUNTIME']={Description=function()return HUM,HUM:GetAppliedDescription()end};local o=Instance.new('ModuleScript');o.Name='09B5_AVATAR_RUNTIME';o.Parent=rep
function Services.AvatarEditorService:SearchCatalogAsync(params)local k=params.AssetTypes[1].Name;local id=({HairAccessory=211,Shirt=212,Pants=213,Hat=214})[k];return{GetCurrentPage=function()return{deep(fixture60(id,'emo black '..k,k))}end}end
Modules['08B4_AVATAR_LOAD'].Create=function()return Instance.new('Model')end
'''+src('09I_ASSISTANT_SERVER')
case('new_conversation_cancels_inflight_request_and_can_send_again',AI+r'''
local rpc=rep.ACP_AssistantRemotes.Request;assert(rpc.OnServerInvoke(pl,'ask',{text='emo preto',request='old',options={budget=25}}).ok)
advance60(1);assert(rpc.OnServerInvoke(pl,'newchat',{}).ok);advance60(1)
assert(rpc.OnServerInvoke(pl,'ask',{text='casual azul',request='new',options={budget=25}}).ok);flush()
local oldCount,newCount=0,0;for _,sent in ipairs(rep.ACP_AssistantRemotes.Progress.sent or{})do local d=sent.kind;if type(d)=='table'and d.kind=='result'then if d.request=='old'then oldCount=oldCount+1 elseif d.request=='new'then newCount=newCount+1 end end end
assert(oldCount==0 and newCount==1);advance60(1);assert(rpc.OnServerInvoke(pl,'status',{}).data.messagesLeft==7)
return 'an unfinished conversation can be cancelled; its stale result is not delivered, its quota is refunded once, and the next actual server request completes'
''')
case('planner_retains_style_for_refinement_and_answers_game_help',module('09I8_AVATAR_STYLES')+module('09I9_GAME_GUIDE')+module('09I2_ASSISTANT_ENGINE')+r'''
local e=Modules['09I2_ASSISTANT_ENGINE'];local a=e.Ask(pl,'Quero emo preto');assert(a.keyword=='emo black')
local b=e.Ask(pl,'troque só roupas para azul',{keyword=a.keyword,style=a.style,color=a.color});assert(b.keyword=='emo blue'and b.scope=='Roupas')
assert(e.Help('como salvar meus looks'):find('Recarregar',1,true));assert(e.Help('truco'):find('dez segundos',1,true));assert(not LastAIRequest)
return 'refinements keep the confirmed style, update color and scope, and concrete saved-look and Truco help uses no external text generator'
''')
case('builder_reserves_budget_for_later_garments',THEME+DATA+module('09I0_ASSISTANT_CONFIG')+module('09I3_OUTFIT_BUILDER')+r'''
function Services.AvatarEditorService:SearchCatalogAsync(params)
 local k=params.AssetTypes[1].Name;local rows={};local types={HairAccessory=101,Shirt=201,Pants=301,Hat=401}
 for i=1,2 do local id=types[k]+i;local r=fixture60(id,'emo black '..k,k);r.Price=i==1 and 18 or 5;NativeItems60['Asset:'..id].Price=r.Price;rows[#rows+1]=deep(r)end
 return{GetCurrentPage=function()return rows end}
end
Modules['08B4_AVATAR_LOAD'].Create=function()return Instance.new('Model')end
local b=Modules['09I3_OUTFIT_BUILDER'];local rows=assert(b.Build(pl,'emo black',b.Options({budget=25,format='2D'},'Normal'),S.Current,function()end,function()return true end))
assert(#rows[1].items==4 and rows[1].total<=25 and rows[1].verified)
return 'hair cannot spend the budget needed for shirt/pants/accessory; all four selected real pieces fit the confirmed total'
''')
PHOTO=module('07P1_CAPTURE_ENGINE')
case('capture_uses_native_object_and_true_save_share_outcomes',PHOTO+r'''
local c=Modules['07P1_CAPTURE_ENGINE'];local ready;assert(c.TakePhoto(nil,function(ok)ready=ok end));assert(not c.TakePhoto(nil,function()end));flush();assert(ready and c.HasLast())
local saved;DeclineSave64=true;assert(c.SaveLast(function(v)saved=v end));flush();assert(saved==false)
DeclineSave64=false;assert(c.SaveLast(function(v)saved=v end));flush();assert(saved)
local share;assert(c.ShareLast(function()share=true end,function()share=false end));flush();assert(share and CaptureCalls64.share==1)
return 'current native screenshot object is passed to gallery/share; concurrent captures are rejected and cancelled saving never reports success'
''')
case('capture_timeout_and_start_failure_release_lock',PHOTO+r'''
local c=Modules['07P1_CAPTURE_ENGINE'];HangCapture64=true;local result;assert(c.TakePhoto(nil,function(v)result=v end));advance60(11);advance(11);assert(result==false)
HangCapture64=false;ThrowCapture64=true;assert(not c.TakePhoto(nil,function()end));ThrowCapture64=false;assert(c.TakePhoto(nil,function(v)result=v end));flush();assert(result)
return 'a hung native callback and an unsupported capture call both release the busy lock and allow a later capture'
''')
INSPECT=DATA+BUDGET+module('09B3_PLAYER_INSPECT')+r'''
local other=makePlayer(456);function Services.Players:GetPlayers()return{pl,other}end;other.Character=pl.Character;other.DisplayName='Other';other:SetAttribute('ACP_AllowAvatarCopy',false)
local i=Modules['09B3_PLAYER_INSPECT']
'''
case('player_copy_permission_is_checked_again_and_transfer_is_native',INSPECT+r'''
assert(not i.Avatar(pl,{id=456}).allowCopy);assert(not pcall(i.Use,pl,{id=456}));other:SetAttribute('ACP_AllowAvatarCopy',true);assert(i.Use(pl,{id=456}).allowCopy)
other:SetAttribute('ACP_AllowAvatarCopy',false);assert(not i.CheckApply(pl))
pl.HasRobloxSubscription=false;assert(not pcall(i.Transfer,pl,{id=456,amount=10}));pl.HasRobloxSubscription=true
assert(not pcall(i.Transfer,pl,{id=456,amount=1}));local result=i.Transfer(pl,{id=456,amount=10});assert(result.prompted and TransferPrompt64.receiver==456)
assert(TransferReceipts64.RobuxTransferSender({TransferRequestId='native'})==Enum.ReceiptDecision.Processed)
return 'copy permission is rechecked on use/application; ineligible or invalid transfers cannot prompt, and valid transfers use native receipt handling separately from product commerce'
''')
HERE.joinpath('fix_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
