from test_support import *
case('builder_readonly_arrays_complete_real_selections_and_validation',THEME+DATA+module('09I0_ASSISTANT_CONFIG')+module('09I3_OUTFIT_BUILDER')+r'''
local calls=0;local loader=Modules['08B4_AVATAR_LOAD'];local base=A.Copy(S.Current)
function Services.AvatarEditorService:SearchCatalogAsync(params)
 local k=params.AssetTypes[1].Name;local id=({HairAccessory=111,Shirt=112,Pants=113,Hat=114})[k];local item=fixture60(id,'Real '..k,k);item.Price=5;NativeItems60['Asset:'..id].Price=5
 return{GetCurrentPage=function()return{deep(item)}end}
end
loader.Create=function(d,rig)calls=calls+1;return Instance.new('Model')end
local builder=Modules['09I3_OUTFIT_BUILDER'];local opts=builder.Options({budget=25,format='2D'},'Normal')
local rows=assert(builder.Build(pl,'emo',opts,base,function()end,function()return true end));assert(#rows==1 and rows[1].total==20 and calls==1)
assert(S.Current.props.Shirt==base.props.Shirt and builder.Protocol==2)
return 'strict native readonly params still produce four real selections, fresh price confirmation and appearance validation, with original skin preserved'
''')
case('exact_one_for_one_sponsor_replacement_expiration_and_dedup',module('09C11_SPONSOR_FEED')+r'''
local examples={};for i=1,60 do examples[i]={key='Asset:'..i,item={Id=i,Price=5},temporary=true}end
local real={{key='Asset:101',item={Id=101,Price=5}}};local merge=Modules['09C11_SPONSOR_FEED'].Merge
local first=merge(real,examples,60);assert(#first==60);local temporary=0;for _,r in ipairs(first)do if r.temporary then temporary=temporary+1 end end;assert(temporary==59)
real[2]={key='Asset:102',item={Id=102,Price=5}};local second=merge(real,examples,60);temporary=0;for _,r in ipairs(second)do if r.temporary then temporary=temporary+1 end end;assert(#second==60 and temporary==58)
real[3]=real[1];assert(#merge(real,examples,60)==60)
local restored=merge({},examples,60);for _,r in ipairs(restored)do assert(r.temporary)end
return 'one and two publications replace exactly one and two temporary cards; duplicate keys do not consume cards and expired publications restore the examples'
''')
DEST=module('09B10_SPONSORED_DESTINATIONS')+r"Dests=Modules['09B10_SPONSORED_DESTINATIONS'];seed63()"+'\n'
case('destination_seed_lists_native_metadata_only_no_temporary_games',DEST+r'''
local games=Dests.Feed(pl,{kind='Game'});assert(#games.items==1 and games.items[1].item.Id==83720142132483 and games.items[1].permanent and games.items[1].item.verified)
local groups=Dests.Feed(pl,{kind='Community'});assert(#groups.items==1 and groups.items[1].item.Id==546113316 and groups.items[1].item.Name=='Own Community')
assert(not games.items[1].temporary and not groups.items[1].temporary)
assert(#Dests.Feed(pl,{kind='Game',search='does not exist'}).items==0)
return 'only the two supplied permanent seeds are present in their own categories, name/description/image come from mocked native metadata and no filler game/community is generated'
''')
case('destination_slots_validation_repair_favorites_and_expiration',DEST+r'''
NativeInfo60[701]={AssetTypeId=9,Name='Native Game',Description='test'};NativeInfo60[702]={AssetTypeId=11,Name='not a place'}
assert(not pcall(Dests.Submit,pl,{kind='Game',id=702}));assert(not StoreData.AvatarPlaza_Destinations_v1.u_Game_123)
FailMemory60=true;assert(not pcall(Dests.Submit,pl,{kind='Game',id=701}));FailMemory60=false
local fixed=Dests.Submit(pl,{kind='Game',id=701});assert(fixed.ready and fixed.expires==TIME60+86400)
local feed=Dests.Feed(pl,{kind='Game'});assert(#feed.items==2)
assert(Dests.Reaction(pl,{kind='Game',id=701,action='favorite',value=true}).value)
assert(Dests.Reaction(pl,{kind='Game',id=701,action='like',value=true}).scope=='Vitrine deste jogo')
local favorites=Dests.Feed(pl,{kind='Game',favorites=true});assert(#favorites.items==1 and favorites.items[1].liked)
advance60(86401);assert(#Dests.Feed(pl,{kind='Game'}).items==1)
return 'non-place IDs cannot consume slots; pending index saves can be repaired without extending the deadline; own likes/favorites persist and expired submissions leave only the seed'
''')
case('destination_pagination_keeps_unconsumed_rows_between_pages',DEST+r'''
local map=Services.MemoryStoreService:GetSortedMap('AvatarPlaza_Destinations_v1')
for i=1,150 do map:SetAsync('Game_'..i,{item={Id=1000+i,ItemType='Game',Name='Game '..i},key='Game:'..(1000+i),active=true,ready=true,expires=TIME60+600},600,TIME60+i)end
local seen={};local total=0;local nextPage=false
for i=1,4 do local page=Dests.Feed(pl,{kind='Game',next=nextPage});nextPage=true;for _,r in ipairs(page.items)do assert(not seen[r.key]);seen[r.key]=true;total=total+1 end;if page.finished then break end end
assert(total==151,total)
return '150 real publications and the own seed are paginated without losing the remaining rows in a 100-entry native index page'
''')
case('virtual_truco_pool_has_no_district_seats_or_character_movement',DATA+module('07K4_TRUCO_TABLES')+r'''
local world=Instance.new('Folder');world.Name='PracaAvatar_V2';world.Parent=workspace
local t=Modules['07K4_TRUCO_TABLES'];local pool=t.Build(world);assert(#pool==24 and not world:FindFirstChild('ChallengeDistrict'))
local before=pl.Character:GetPivot();local r={table=pool[1],players={[1]=pl},code='ABCD'};assert(t.Seat(r,pl,1));t.Release(r,pl);assert(pl.Character:GetPivot()==before)
for _,o in ipairs(world:GetDescendants())do assert(not o:IsA('BasePart')and not o:IsA('Seat'))end
return 'Truco allocates 24 virtual rooms directly under the hub, can assign/release a player and creates neither physical seats nor a removed district dependency'
''')
case('gameplay_goals_count_legal_changes_and_dont_reward_enemy_moves',module('07A0_CHESS_RULES')+module('07H8_PLAY_SESSION')+r'''
local rules=Modules['07A0_CHESS_RULES'];local state=rules.New();local s=Modules['07H8_PLAY_SESSION'].New('Xadrez','W');s.Board(state.board)
local function move(fr,fc,tr,tc)local found;for _,m in ipairs(rules.Legal(state,fr,fc))do if m.tr==tr and m.tc==tc then found=m end end;assert(found);assert(rules.Apply(state,found));s.Board(state.board)end
move(7,5,5,5);assert(s.moves==1 and s.captures==0);move(2,4,4,4);assert(s.moves==1);move(5,5,4,4);assert(s.moves==2 and s.captures==1 and s.milestones.capture)
s.Board(state.board);assert(s.moves==2);s.Finish();s.Finish();assert(s.complete and s.milestones.complete)
local t=Modules['07H8_PLAY_SESSION'].New('Truco');t.Truco({phase='play',hand={1,2,3},tricks={}},1);t.Truco({phase='play',hand={1,2},tricks={1}},1);assert(t.moves==1 and t.captures==1)
return 'goals use actual legal chess board changes, count only own moves and captures once, and accept the real numeric team-win representation used by Truco rules'
''')
case('ai_server_request_finishes_with_verified_look_and_protocol',THEME+DATA+module('09I0_ASSISTANT_CONFIG')+module('09I1_ASSISTANT_ACCOUNTS')+module('09I2_ASSISTANT_ENGINE')+module('09I3_OUTFIT_BUILDER')+r'''
Modules['09B5_AVATAR_RUNTIME']={Description=function()return HUM,HUM:GetAppliedDescription()end};local o=Instance.new('ModuleScript');o.Name='09B5_AVATAR_RUNTIME';o.Parent=rep
function Services.AvatarEditorService:SearchCatalogAsync(params)
 local k=params.AssetTypes[1].Name;local id=({HairAccessory=211,Shirt=212,Pants=213,Hat=214})[k];local item=fixture60(id,'Real '..k,k)
 return{GetCurrentPage=function()return{deep(item)}end}
end
Modules['08B4_AVATAR_LOAD'].Create=function()return Instance.new('Model')end
'''+src('09I_ASSISTANT_SERVER')+r'''
local rpc=rep.ACP_AssistantRemotes.Request;local st=rpc.OnServerInvoke(pl,'status',{});assert(st.ok and st.protocol==2 and st.data.available)
advance60(1);local accepted=rpc.OnServerInvoke(pl,'ask',{text='Quero um look emo preto',request='native-test',options={budget=25,format='2D'}});assert(accepted.ok);flush()
local result;for _,sent in ipairs(rep.ACP_AssistantRemotes.Progress.sent)do local payload=type(sent.kind)=='table'and sent.kind or sent.data;if payload and payload.kind=='result'then result=payload end end
assert(result and #result.data.looks==1 and result.data.looks[1].total==20 and not LastAIRequest)
return 'actual IA RemoteFunction accepts a protocol-2 request and the real readonly-safe builder completes native catalog selection, fresh price/appearance verification and result delivery without an HTTP generator'
''')
case('hub_respawn_uses_explicit_spawn_and_restores_a_fallen_character',THEME+DATA+r'''
local world=Instance.new('Folder');world.Name='PracaAvatar_V2';world.Parent=workspace;rep.PracaKit:SetAttribute('CoreReady',true);local home=Instance.new('RemoteEvent');home.Name='HubTeleport';home.Parent=rem61;home.OnServerEvent=Signal()
local waits=0;local oldWait=task.wait
function task.wait(n)if n==.3 then waits=waits+1;if waits>1 then world.Parent=nil end end;return oldWait(n)end
'''+src('01B_HUB_WORLD')+r'''
flush();local spawn=world.SpawnCentral;assert(spawn and pl.RespawnLocation==spawn)
local fresh=Instance.new('Model');local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Size=Vector3.new(2,2,1);root.Position=Vector3.new(0,1,0);root.Parent=fresh;local hum=Instance.new('Humanoid');hum.HipHeight=3;hum.Parent=fresh;fresh:SetAttribute('ACP_AvatarManaged',false);fresh.Parent=workspace;pl.Character=fresh;pl.CharacterAdded:Fire(fresh);flush();assert(fresh:GetPivot().Position.Y>=65)
assert(world.AvatarFieldGround:FindFirstChild('GroundChunk_0:0'))
return 'actual hub script sets RespawnLocation explicitly, builds the physical origin floor and places a newly spawned/fallen character above it'
''')
HERE.joinpath('regression_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
