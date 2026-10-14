from test_support import *
AUDIO=DATA+module('07M0_MUSIC_PREFS')+module('07M2_AUDIO_LIBRARY')
case('audio_shared_cache_warm_returns_without_waiting_for_native_search',AUDIO+r'''
Audio61={{{Id=910,Title='Soft Lofi'},{Id=911,Title='Studio Walk'}},{{Id=912,Title='After Hours'}}}
local m=Modules['07M2_AUDIO_LIBRARY'];local first=m.Search(pl,{});assert(first.pending);flush();local ready=m.Search(pl,{});assert(#ready.items==2 and ready.cached)
local other=makePlayer(456);assert(#m.Search(other,{}).items==2 and AudioSearchCount62==1)
local pending=m.Search(pl,{next=true});assert(pending.pending);flush();local page=m.Search(pl,{});assert(page.items[1].id==912 and page.finished)
assert(m.Metadata(910).name=='Soft Lofi')
return 'music RPC returns pending immediately, native searches are coalesced across players and verified native metadata/pagination are cached'
''')
case('audio_failure_backoff_keeps_manual_id_route_independent',AUDIO+src('07M_MUSIC_SERVER')+r'''
FailAudio61=true;flush();local rpc=rep.ACP_MusicRequest;local library=rpc.OnServerInvoke(pl,'search',{search='restricted query'});assert(library.ok and library.data.pending);flush()
advance60(1);local unavailable=rpc.OnServerInvoke(pl,'search',{search='restricted query'});assert(not unavailable.ok)
fixture60(120,'Audio');NativeInfo60[120].AssetTypeId=3
local audio=rpc.OnServerInvoke(pl,'audio',{id=120});assert(audio.ok and audio.data.id==120)
return 'search failure/backoff does not serialize or block a simultaneous manual audio lookup; API failure is shown instead of indefinite loading'
''')
SPONSOR=module('09B8_FREE_HIGHLIGHTS')+"F=Modules['09B8_FREE_HIGHLIGHTS'];fixture60(100,'Camisa Halloween','Shirt');fixture60(101,'Jacket','JacketAccessory');fixture60(102,'Hat','Hat')\n"
case('sponsor_rejects_free_and_unknown_prices_without_consuming_slot',SPONSOR+r'''
NativeInfo60[100].PriceInRobux=0;assert(not pcall(F.Submit,pl,{id=100}));assert(not StoreData.AvatarPlaza_FreeHighlights_v1.u_123)
NativeInfo60[100].PriceInRobux=nil;assert(not pcall(F.Check,pl,{id=100}));NativeInfo60[100].PriceInRobux=5
assert(F.Submit(pl,{id=100}).free and not LastPrompt)
return 'only confirmed paid items may be sponsored; publication remains free; invalid/free items do not consume the 24-hour slot'
''')
case('sponsor_classic_and_layered_categories_filter_server_index',SPONSOR+r'''
F.Submit(pl,{id=100});F.Submit({UserId=456},{id=101});F.Submit({UserId=789},{id=102});advance60(1)
local a=F.Feed(pl,{group='Roupas 2D'});assert(#a.items==1 and a.items[1].item.Id==100);advance60(1)
local b=F.Feed(pl,{group='Roupas 3D'});assert(#b.items==1 and b.items[1].item.Id==101);advance60(1)
local c=F.Feed(pl,{group='Acessórios',search='Hat'});assert(#c.items==1 and c.items[1].item.Id==102)
return 'server filters use real classic/layered/accessory categories and name search; no free record leaks into the feed'
''')
RULES=module('07A0_CHESS_RULES')+module('07B0_CHECKERS_RULES')+r'''
local wins={count=0};function wins.RecordMatch(...)wins.count=wins.count+1 end;Modules['07W_WINS_SERVICE']=wins;local o=Instance.new('ModuleScript');o.Name='07W_WINS_SERVICE';o.Parent=rep
'''+module('07H7_BOARD_SESSIONS')
case('real_2d_chess_sends_64_dense_cells_and_preserves_both_piece_sets',DATA+RULES+r'''
local e=Modules['07H7_BOARD_SESSIONS'];e.Bind();local other=makePlayer(456);local before=HUM.Parent:GetPivot();local name=assert(e.Open({game='Xadrez',code='ABCD'},{pl,other}));local event=rem61.HubGameUI
local function latest(player)local out;for _,sent in ipairs(event.sent)do if sent.player==player and sent.kind=='boardState'then out=sent.data end end;return out end
local function count(board)local n=0;for r=1,8 do assert(#board[r]==8);for c=1,8 do assert(board[r][c]~=nil);if board[r][c]then n=n+1 end end end;return n end
assert(count(latest(pl).board)==32 and latest(other).side=='B')
assert(e.Action(pl,'boardTap',name,7,5,0));advance60(.1);assert(e.Action(pl,'boardTap',name,5,5,0));assert(count(latest(pl).board)==32)
assert(latest(pl).board[7][5]==false and latest(other).board[5][5].t=='P'and latest(pl).revision==1)
advance60(.1);assert(not e.Action(pl,'boardTap',name,7,1,1));assert(e.Action(other,'boardTap',name,2,5,1));advance60(.1);assert(e.Action(other,'boardTap',name,4,5,1))
assert(count(latest(pl).board)==32 and count(latest(other).board)==32)
assert(HUM.Parent:GetPivot()==before and not Teleported)
return 'actual server chess preserves all 32 pieces across alternating moves and sends a dense false-for-empty 8x8 board to both players, with no character movement'
''')
case('real_2d_damas_stale_moves_and_resignation_are_authoritative',DATA+RULES+r'''
local e=Modules['07H7_BOARD_SESSIONS'];e.Bind();local other=makePlayer(456);local name=assert(e.Open({game='Damas',code='EFGH'},{pl,other}))
assert(e.Action(pl,'boardTap',name,6,1,0));advance60(.1);assert(e.Action(pl,'boardTap',name,5,2,0));advance60(.1)
assert(not e.Action(other,'boardTap',name,3,2,0));assert(e.Action(other,'boardTap',name,3,2,1));advance60(.1);assert(e.Action(other,'boardTap',name,4,1,1))
local finished; e.Finished.Event:Connect(function(code,summary)finished=summary end);assert(e.Action(pl,'resignGame',name));assert(finished.winner=='B'and finished.moves==2 and wins.count==1)
assert(not e.Action(pl,'boardTap',name,5,2,2))
return 'damas alternates only legal moves, rejects stale board revisions and finalizes a resignation once; completed matches cannot still mutate'
''')
case('rooms_pair_and_rematch_without_assents_or_teleports',DATA+RULES+src('01C_HUB_CHALLENGES')+r'''
local other=makePlayer(456);local before=HUM.Parent:GetPivot();local rpc=rem61.GameRoomRequest;local a=rpc.OnServerInvoke(pl,'quick','Xadrez');advance60(1)
local b=rpc.OnServerInvoke(other,'join',a.code);assert(b.ok and b.matched and not b.teleporting);assert(pl:GetAttribute('ACP_RoomCode')==other:GetAttribute('ACP_RoomCode'))
local e=Modules['07H7_BOARD_SESSIONS'];assert(e.Action(pl,'resignGame',b.tableName));local tickets={};for _,sent in ipairs(rem61.GameRoomPush.sent)do if sent.kind=='postMatch'then tickets[sent.player.UserId]=sent.data end end
advance60(1);assert(rpc.OnServerInvoke(pl,'rematch',{token=tickets[123].token}).waiting);advance60(1);assert(rpc.OnServerInvoke(other,'rematch',{token=tickets[456].token}).matched)
assert(HUM.Parent:GetPivot()==before and not Teleported and not workspace:FindFirstChild('ChallengeDistrict',true))
return 'actual room server starts two-player UI sessions and consented rematch with no seats, physical room creation or teleport'
''')
case('old_ai_engine_is_identified_before_any_daily_reservation',THEME+DATA+module('09I0_ASSISTANT_CONFIG')+module('09I1_ASSISTANT_ACCOUNTS')+module('09I3_OUTFIT_BUILDER')+r'''
Modules['09I2_ASSISTANT_ENGINE']={Summary=function()return'old HTTP generator'end,Available=false};local o=Instance.new('ModuleScript');o.Name='09I2_ASSISTANT_ENGINE';o.Parent=rep
Modules['09B5_AVATAR_RUNTIME']={};local n=Instance.new('ModuleScript');n.Name='09B5_AVATAR_RUNTIME';n.Parent=rep
'''+src('09I_ASSISTANT_SERVER')+r'''
local rpc=rep.ACP_AssistantRemotes.Request;local r=rpc.OnServerInvoke(pl,'ask',{text='Quero emo'});assert(not r.ok and r.error:find('09I2_ASSISTANT_ENGINE',1,true));assert(not LastAIRequest)
assert(not StoreData.ACP_AssistantProfiles_V55.u123)
return 'mixed V59/V62 AI installation reports the exact old module before making HTTP calls or reserving/refunding any daily request'
''')
case('current_ai_planner_has_protocol_and_no_http_generator',module('09I2_ASSISTANT_ENGINE')+r'''
local e=Modules['09I2_ASSISTANT_ENGINE'];assert(e.Protocol==2 and e.Version=='V62');assert(e.Ask(pl,'Quero um look emo preto').keyword=='emo black');assert(not LastAIRequest)
return 'current look planner identifies V62/protocol 2 and searches styles without a text-generator HTTP dependency'
''')
case('old_free_sponsor_can_be_replaced_by_a_paid_item',SPONSOR+r'''
StoreData.AvatarPlaza_FreeHighlights_v1=StoreData.AvatarPlaza_FreeHighlights_v1 or{}
StoreData.AvatarPlaza_FreeHighlights_v1.u_123={owner=123,key='Asset:199',item={Id=199,ItemType='Asset',Price=0},active=true,ready=true,expires=TIME60+86400,token='old'}
local status=F.Status(pl);assert(status.item==nil and status.nextAllowed==TIME60 and status.paidOnly)
assert(F.Submit(pl,{id=100}).item.item.Price>0)
return 'a legacy free-item publication is removed from the paid-only index and can be replaced without trapping the owner in the obsolete cooldown'
''')
case('store_background_version_type_image_and_failure_are_confirmed',module('07P8_BACKGROUND_RESOLVER')+module('07P7_ROBLOX_BACKGROUNDS')+r'''
fixture60(801,'Store Background','AvatarBackground');OwnedAssets[801]=false;shop61:SetAttribute('PhotoResolverVersion','V62')
local rpc=Instance.new('RemoteFunction');rpc.Name='Request';rpc.Parent=shop61
function rpc:InvokeServer(a,d)local ok,v=pcall(Modules['07P8_BACKGROUND_RESOLVER'].Resolve,pl,d);return{ok=ok,data=ok and v,error=not ok and v}end
local value,e=Modules['07P7_ROBLOX_BACKGROUNDS'].Image({id=801,source='RobloxCatalog'});assert(value,e);assert(value.preview and not OwnedAssets[801])
shop61:SetAttribute('PhotoResolverVersion','antigo');local value,why=Modules['07P7_ROBLOX_BACKGROUNDS'].Image({id=801});assert(value,why)
return 'an on-sale native store background can be confirmed without inventory/ownership; a stale/missing version label no longer blocks a compatible real response and confirmed image'
''')
HERE.joinpath('feature_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
