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
case('audio_library_initial_results_pagination_cache_and_failure',DATA+module('07M2_AUDIO_LIBRARY')+r'''
Audio61={{{Id=910,Title='Soft Lofi',Artist='Roblox music',Duration=90},{Id=911,Title='Night Studio',Duration=120}},{{Id=912,Title='Cloud Walk',Duration=140}}}
local lib=Modules['07M2_AUDIO_LIBRARY'];local first=assert(lib.Search(pl,{}));assert(#first.items==2 and first.items[1].name=='Soft Lofi');advance60(2)
local nextPage=assert(lib.Search(pl,{next=true}));assert(nextPage.items[1].id==912 and nextPage.finished)
local other=makePlayer(901);local cached=assert(lib.Search(other,{}));assert(cached.cached and #cached.items==2);advance60(2)
local third=assert(lib.Search(other,{next=true}));assert(third.items[1].id==912)
advance60(2);assert(lib.Search(pl,{}).cached);advance60(2);assert(lib.Search(pl,{next=true}).items[1].id==912)
FailAudio61=true;advance60(2);local bad,e=lib.Search(pl,{search='unknown track'});assert(not bad and e)
return 'native music subtype search populates the initial library; cached first page still advances; transport failure reports recovery, not invented songs'
''')
case('global_friend_registry_merges_two_people_and_survives_reload',DATA+module('09B9_GLOBAL_LOOKS')+r'''
local registry=Modules['09B9_GLOBAL_LOOKS'];local a,b={},{}
for i=1,200 do a[#a+1]=10000+i end;for i=201,700 do b[#b+1]=10000+i end
assert(registry.AddSeed(300,a));assert(registry.AddSeed(400,b));assert(registry.AddSeed(300,a))
assert(#StoreData.ACP_GlobalLooks_V61.seed_300.ids==200 and #StoreData.ACP_GlobalLooks_V61.seed_400.ids==500)
'''+module('09B9_GLOBAL_LOOKS')+r'''
registry=Modules['09B9_GLOBAL_LOOKS'];local seen={};local page=0;local finished=false
repeat local r=registry.Page(pl,{page=page});for _,v in ipairs(r.items)do assert(not seen[v.owner]);seen[v.owner]=true end;page=page+1;finished=r.finished until finished or page>40
local count=0;for _ in pairs(seen)do count=count+1 end;assert(count==700,count);assert(page<40)
return '200 plus 500 discovered accounts persist globally, are deduplicated across entrants and remain pageable after a module/server reload; no 700-card client allocation'
''')
case('archive_snapshot_code_dedup_and_write_failure',DATA+module('09B9_GLOBAL_LOOKS')+r'''
local g=Modules['09B9_GLOBAL_LOOKS'];local body=A.Copy(S.Current);body.props.Shirt=1011
local a=assert(g.Save(123,body,'R15'));local b=assert(g.Save(999,body,'R15'));assert(a.code==b.code and #a.code==19)
local retrieved=assert(g.Get(a.code));assert(retrieved.body.props.Shirt==1011)
body.colors.HeadColor={.1,.2,.3};local c=assert(g.Save(123,body,'R15'));assert(c.code~=a.code)
FailStores=true;body.props.Shirt=1012;local bad,e=g.Save(123,body,'R15');assert(not bad and e);FailStores=false
assert(g.Get(a.code).body.props.Shirt==1011)
return 'verified look snapshots have stable searchable codes; identical looks share one record; visual changes get a new code; failed writes retain prior data'
''')
case('archive_background_job_retries_and_checkpoints_progress',DATA+module('09B9_GLOBAL_LOOKS')+r'''
local g=Modules['09B9_GLOBAL_LOOKS'];assert(g.AddSeed(123,{201,202}));local body=A.Copy(S.Current);body.props.Shirt=1101
function Services.Players:GetHumanoidDescriptionFromUserIdAsync(id)local d=A.Unpack(body);d.Shirt=1100+id;return d end
FailStores=true;advance60(4);assert(not g.Pump());assert(StoreData.ACP_GlobalLooks_V61.seed_123.cursor==1)
FailStores=false;advance60(4);assert(g.Pump());advance60(4);assert(g.Pump());assert(StoreData.ACP_GlobalLooks_V61.seed_123.cursor==3)
local r=g.Page(pl,{page=0});assert(#r.items==2 and r.items[1].snapshotCode)
return 'background appearance work retries storage failure and only advances the durable checkpoint after actual snapshots are written'
''')
case('archive_queue_reaches_seed_owners_beyond_first_global_page',DATA+module('09B9_GLOBAL_LOOKS')+r'''
local g=Modules['09B9_GLOBAL_LOOKS'];for i=1,70 do assert(g.AddSeed(40000+i,{50000+i}))end
'''+module('09B9_GLOBAL_LOOKS')+r'''
g=Modules['09B9_GLOBAL_LOOKS'];function Services.Players:GetHumanoidDescriptionFromUserIdAsync(id)local d=A.Unpack(S.Current);d.Shirt=id;return d end
local done=0;for i=1,130 do advance60(4);if g.Pump()then done=done+1 end end;assert(done==70,'processed '..done)
local found,page,finished={},0,false
repeat local r=g.Page(pl,{page=page});for _,v in ipairs(r.items)do assert(v.snapshotCode);found[v.owner]=true end;finished=r.finished;page=page+1 until finished or page>30
local count=0;for _ in pairs(found)do count=count+1 end;assert(count==70,count)
return 'durable appearance work processes 70 seed owners across global index pages after a restart; cache eviction preserves completed snapshot metadata and browsing'
''')
case('unowned_store_background_type_sale_and_image_are_checked',module('07P8_BACKGROUND_RESOLVER')+module('07P7_ROBLOX_BACKGROUNDS')+r'''
fixture60(801,'Store Background','AvatarBackground');OwnedAssets[801]=false
local rpc=Instance.new('RemoteFunction');rpc.Name='Request';rpc.Parent=shop61
function rpc:InvokeServer(a,d)local ok,v=pcall(Modules['07P8_BACKGROUND_RESOLVER'].Resolve,pl,d);return{ok=ok,data=ok and v,error=not ok and v}end
local bg=assert(Modules['07P7_ROBLOX_BACKGROUNDS'].Image({id=801,source='RobloxCatalog'}));assert(bg.preview and bg.source=='RobloxCatalog')
assert(not LastBackgroundContainer60.Parent)
NativeInfo60[801].IsForSale=false;assert(not pcall(Modules['07P8_BACKGROUND_RESOLVER'].Resolve,pl,{id=801}));NativeInfo60[801].IsForSale=true
FailImage60=true;local bad,e=Modules['07P7_ROBLOX_BACKGROUNDS'].Image({id=801});assert(not bad and e)
fixture60(802,'Shirt','Shirt');assert(not pcall(Modules['07P8_BACKGROUND_RESOLVER'].Resolve,pl,{id=802}))
return 'a real on-sale profile background can be tested without owning it; other asset types/off-sale assets and unavailable raw/thumbnail images are rejected'
''')
case('look_planner_filters_text_and_never_claims_general_ai',module('09I2_ASSISTANT_ENGINE')+r'''
local e=Modules['09I2_ASSISTANT_ENGINE'];local r=assert(e.Ask(pl,'Quero um look emo preto grátis'));assert(r.keyword=='emo black'and r.free and r.language=='pt')
assert(e.Health()and not LastAIRequest);assert(e.Help('/fly'):find('/unfly',1,true));assert(e.Help('assunto externo'):find('limitadas',1,true))
return 'the catalog planner recognizes style/color/free intent in Portuguese and identifies its limited help scope without claiming a language-model response'
''')
case('builder_requires_fresh_price_and_a_valid_avatar_before_results',THEME+DATA+module('09I0_ASSISTANT_CONFIG')+module('09I3_OUTFIT_BUILDER')+r'''
local calls=0;local loader=Modules['08B4_AVATAR_LOAD'];local base=A.Copy(S.Current)
function Services.AvatarEditorService:SearchCatalogAsync(params)
 local k=params.AssetTypes[1].Name;local id=({HairAccessory=111,Shirt=112,Pants=113,Hat=114})[k];local item=fixture60(id,'Real '..k,k);item.Price=5;NativeItems60['Asset:'..id].Price=5
 return{GetCurrentPage=function()return{deep(item)}end}
end
loader.Create=function(d,rig)calls=calls+1;if FailAppearance61 then return nil,'content failed'end;return Instance.new('Model')end
local builder=Modules['09I3_OUTFIT_BUILDER'];local opts=builder.Options({budget=25,format='2D'},'Normal')
local rows=assert(builder.Build(pl,'emo',opts,base,function()end,function()return true end));assert(#rows==1 and rows[1].total==20 and calls==1)
assert(S.Current.props.Shirt==base.props.Shirt)
FailAppearance61=true;assert(not builder.Build(pl,'emo',opts,base,function()end,function()return true end));FailAppearance61=false
for id=111,114 do if NativeItems60['Asset:'..id]then NativeItems60['Asset:'..id].Price=100 end end
assert(not builder.Build(pl,'emo',opts,base,function()end,function()return true end))
return 'real catalog selections are repriced and passed to avatar validation; unavailable appearance or price above budget yields no look and does not apply anything'
''')
case('real_chat_commands_are_personal_and_competition_safe',DATA+module('07G5_CHAT_COMMANDS')+src('07G_SETTINGS_SERVER')+r'''
local fly=Services.TextChatService:FindFirstChild('ACP_Command_fly');assert(fly and fly.PrimaryAlias=='/fly')
fly.Triggered:Fire({UserId=pl.UserId},'/fly');assert(pl:GetAttribute('ACP_PersonalFly')==true)
advance60(1);Services.TextChatService.ACP_Command_unfly.Triggered:Fire({UserId=pl.UserId},'/unfly');assert(pl:GetAttribute('ACP_PersonalFly')==false)
advance60(1);Services.TextChatService.ACP_Command_speed.Triggered:Fire({UserId=pl.UserId},'/speed 999');assert(HUM.WalkSpeed==32)
pl:SetAttribute('ACP_InGameRoom',true);advance60(1);fly.Triggered:Fire({UserId=pl.UserId},'/fly');assert(not pl:GetAttribute('ACP_PersonalFly')and HUM.WalkSpeed==16)
assert(rem61.PersonalCommand.sent[#rem61.PersonalCommand.sent].player==pl)
return 'real TextChatCommand aliases operate on the originating player, clamp arguments and restore/block movement during games'
''')
ACCOUNTS=module('09I0_ASSISTANT_CONFIG')+module('09I1_ASSISTANT_ACCOUNTS')
GLOBAL=module('09B9_GLOBAL_LOOKS')+module('07P8_BACKGROUND_RESOLVER')+module('09B8_FREE_HIGHLIGHTS')
case('real_shop_routes_mix_publications_and_player_discovery',THEME+DATA+GLOBAL+SERVER+r'''
flush();local community=Modules['08L_COMMUNITY'];community.Feed=function()return{items={{id='saved-public',code='AP-123',name='Publicado',body=A.Copy(S.Current),rig='R15'}},finished=true}end
advance60(2);local r=RPC.OnServerInvoke(pl,'CommunityPage',{page=0});assert(r.ok,r.error)
local native,published=false,false;for _,v in ipairs(r.data.items)do if v.source=='Roblox'then native=true elseif v.code=='AP-123'then published=true end end;assert(native and published)
advance60(2);assert(not RPC.OnServerInvoke(pl,'CommunityPage',{min=-2}).ok)
local saved=assert(Modules['09B9_GLOBAL_LOOKS'].Save(pl.UserId,S.Current,'R15'));advance60(2);local found=RPC.OnServerInvoke(pl,'Code',{code=saved.code});assert(found.ok and found.data.code==saved.code)
return 'actual ShopRPC combines manual published looks with public-player discovery, validates price filters and resolves immutable LK archive codes'
''')
case('free_assistant_route_no_text_generator_and_preserves_legacy_quota',THEME+DATA+GLOBAL+SERVER+ACCOUNTS+module('09I2_ASSISTANT_ENGINE')+module('09I3_OUTFIT_BUILDER')+src('09I_ASSISTANT_SERVER')+r'''
flush();local rpc=rep.ACP_AssistantRemotes.Request
advance60(2);local v=rpc.OnServerInvoke(pl,'status',{});assert(v.ok and v.data.plan=='Normal'and v.data.available and not v.data.retired)
assert(not LastAIRequest);advance60(2);assert(not rpc.OnServerInvoke(pl,'prompt',{plan='Pro'}).ok)
for i=1,8 do advance60(2);assert(rpc.OnServerInvoke(pl,'ask',{text='Como usar Photo Mode?',make=false,request='help-'..i}).ok);flush()end
advance60(2);local bad=rpc.OnServerInvoke(pl,'ask',{text='Outra pergunta',make=false});assert(not bad.ok)
assert(not StoreData.ACP_AssistantProfiles_V55.u123.messages and not StoreData.ACP_AssistantProfiles_V55.u123.password)
return 'the real free route opens and answers supported game help without HTTP text generation, retains session/quota limits, blocks new sales and stores no conversation or credentials'
''')
case('board_room_rematch_requires_both_players_and_keeps_session_score',DATA+r'''
local other=makePlayer(456);function Services.Players:GetPlayers()return{pl,other}end
kit61:SetAttribute('BaseReady',true);local world=Instance.new('Folder');world.Name='PracaAvatar_V2';world.Parent=workspace
local directory={};local seq=0
function directory.Bind()end;function directory.Close()end;function directory.Available()return false end;function directory.Cancel()end;function directory.Forget()end
function directory.Reserve(room)seq=seq+1;room.code=string.char(64+seq)..'AAA';room.expires=TIME60+120;room.token='t'..seq;return true end
Modules['07H3_CROSS_SERVER_ROOMS']=directory;local object=Instance.new('ModuleScript');object.Name='07H3_CROSS_SERVER_ROOMS';object.Parent=rep
function methods:Sit(h)self.Occupant=h;h.Sit=true end
'''+src('01C_HUB_CHALLENGES')+r'''
local rpc=rem61.GameRoomRequest
advance60(1);local first=rpc.OnServerInvoke(pl,'quick','Xadrez');assert(first.ok and not first.matched)
advance60(1);local joined=rpc.OnServerInvoke(other,'join',first.code);assert(joined.ok and joined.matched,joined.error or'no match')
local finished=rep:FindFirstChild('ACP_BoardFinished');assert(finished);finished:Fire(first.code,{id='match-one',winnerUID=pl.UserId})
local tickets={};for _,sent in ipairs(rem61.GameRoomPush.sent)do if sent.kind=='postMatch'then tickets[sent.player.UserId]=sent.data end end
assert(tickets[123].yours==1 and tickets[456].theirs==1)
advance60(1);local vote=rpc.OnServerInvoke(pl,'rematch',{token=tickets[123].token});assert(vote.ok and vote.waiting and not pl:GetAttribute('ACP_RoomCode'))
advance60(1);local replay=rpc.OnServerInvoke(other,'rematch',{token=tickets[456].token});assert(replay.ok and replay.matched,replay.error or'no replay')
assert(pl:GetAttribute('ACP_RoomCode')==other:GetAttribute('ACP_RoomCode')and pl:GetAttribute('ACP_RoomCode')~=first.code)
advance60(1);assert(not rpc.OnServerInvoke(pl,'rematch',{token='forged'}).ok)
return 'the actual board-room server preserves session result and launches a new room only after both original participants consent; unrelated/stale tokens cannot start it'
''')
case('physical_floor_moves_without_unbounded_parts_or_horizontal_teleport',DATA+r'''
kit61:SetAttribute('CoreReady',true);local world=Instance.new('Folder');world.Name='PracaAvatar_V2';world.Parent=workspace
local teleport=Instance.new('RemoteEvent');teleport.Name='HubTeleport';teleport.Parent=rem61
local root=HUM.Parent.HumanoidRootPart;root.Position=Vector3.new(15000,65,15000)
local waits=0;local previousWait=task.wait
function task.wait(n)
 previousWait(n);waits=waits+1;if waits>3 then world.Parent=nil end
end
'''+src('01B_HUB_WORLD')+r'''
flush();local g=world:FindFirstChild('AvatarFieldGround');assert(g)
local floor=0;for _,p in ipairs(g:GetChildren())do if p.Name:find('GroundChunk_',1,true)then floor=floor+1;assert(p.CanCollide and not p.CanTouch)end end
assert(floor<=18,floor);assert(root.Position.X==15000 and root.Position.Z==15000);assert(not world:FindFirstChild('InvisibleBounds'))
return 'the real world script retains only spawn/player physical chunk neighbourhoods and no longer teleports a walking avatar back at the old 385-stud edge'
''')
HERE.joinpath('feature_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
