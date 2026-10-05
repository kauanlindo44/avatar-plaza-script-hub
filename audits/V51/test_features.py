from test_support import *
import ast
CARD_UI=THEME+module('07K0_TRUCO_RULES')+module('07K6_CARD_CATALOG')+module('07K7_CARD_STYLES')+module('07K5_TRUCO_UI')+module('07K9_CARD_INVENTORY_UI')+module('07K12_TOURNAMENT_UI')+module('07H1_GAME_LOBBY')
def fixture(file,name):
 tree=ast.parse((HERE/file).read_text())
 for n in tree.body:
  if isinstance(n,ast.Assign)and any(isinstance(t,ast.Name)and t.id==name for t in n.targets):return eval(compile(ast.Expression(n.value),'<fixture>','eval'),globals())
TRUCO=fixture('test_changes.py','TRUCO')
case('truco_2d_public_cards_four_seats_and_hidden_identity',fixture('test_changes.py','TRUCO')+r'''
local tableArea=named(gui,'TableView');local hand=named(gui,'PrivateHand');local controls=named(gui,'TurnControls');local choices=named(gui,'ChooseAnyCard')
for _,screen in ipairs({{320,568,0,0,58,0},{800,360,0,0,58,0},{844,390,44,44,58,22},{768,432,0,0,58,0},{1600,720,0,0,58,0}})do
 SCREEN_W,SCREEN_H,CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=table.unpack(screen)
 for seat=1,4 do
  view.seat=seat;view.turn=seat;view.hand={{rank='3',suit='S'},{rank='4',suit='D'},{rank='2',suit='S'}}
  view.tableCards={{seat=1,card={rank='A',suit='S'}},{seat=2,card={covered=true}},{seat=3,card={rank='K',suit='D'}},{seat=4,card={rank='7',suit='C'}}}
  push.OnClientEvent:Fire('match',view);flush()
  for _,o in ipairs({tableArea,hand,controls,choices,named(gui,'LeaveTruco')})do inside(o,gui)end
  assert(not intersects(tableArea,hand)and not intersects(hand,choices)and not intersects(choices,controls))
  local slots=named(gui,'PublicTableCards');local n=0
  for _,slot in ipairs(slots:GetChildren())do if slot:IsA('Frame')then n=n+1;inside(slot,slots);local card=named(slot,'PlayingCard')or named(slot,'PublicCard'..slot:GetAttribute('Seat'));inside(card,tableArea);assert(card.AbsoluteSize.X>=42 and card.AbsoluteSize.Y>=60)
   if slot:GetAttribute('Seat')==2 then assert(not named(card,'RankAndSuit'),'covered public card leaked rank')else assert(named(card,'RankAndSuit'))end
  end end;assert(n==4)
  for i=1,3 do inside(named(gui,'OwnedCard'..i),hand);assert(named(gui,'ChooseCard'..i).AbsoluteSize.Y==44)end
 end
end
lastAction=nil;named(gui,'ChooseCard2').Activated:Fire();assert(lastAction.arg==2,'any-card choice was lost')
return 'four public seats and three private cards remain separated/readable in five sizes and every seat; covered identity stays hidden; button choice preserves weakest-card freedom'
''')
case('truco_bot_reading_time_weaker_card_legal_and_traditional_calls',module('07K0_TRUCO_RULES')+module('07K1_TRUCO_AI')+module('07K2_TRUCO_MATCH')+r'''
local r,m=Modules['07K0_TRUCO_RULES'],Modules['07K2_TRUCO_MATCH'];local s=r.New('Paulista',4);r.Begin(s,r.Deck(),false)
s.vira={rank='7',suit='D',id='7D'};s.hands[1]={{rank='3',suit='S',id='3S'},{rank='4',suit='D',id='4D'},{rank='2',suit='S',id='2S'}};assert(r.Power(s.hands[1][2],s.variant,s.vira)<r.Power(s.hands[1][1],s.variant,s.vira));assert(r.Play(s,1,2));assert(s.tableCards[1].card.rank=='4')
local room={training=true,difficulty='Fácil',players={{UserId=123},{UserId=-2},{UserId=-3},{UserId=-4}},match=s};s.deadline=100;m.Pace(room,s,0,false)
assert(not m.Step(room,2.79)and #s.tableCards==1);assert(m.Step(room,2.81)and #s.tableCards==2);assert(not m.Step(room,5.60));assert(m.Step(room,5.62));assert(not m.Step(room,8.40));assert(m.Step(room,8.44));assert(#s.tricks==1);local turn=s.turn
assert(not m.Step(room,11.50)and s.turn==turn,'completed trick did not remain visible')
for points,name in pairs({[3]='TRUCO!',[4]='TRUCO!',[6]='SEIS!',[9]='NOVE!',[10]='DEZ!',[12]='DOZE!'})do assert(r.CallName(points)==name)end
return 'a weaker chosen card is legal; bots wait 2.8s per action; completed trick remains 3.2s; raise names match each documented profile'
''')
case('community_manual_fifty_bounded_hundred_recycle_and_retry',UI+DATA+PREVIEW+COMMUNITY+r'''
local calls=0;local fail=false;local ctl=Modules['09C7_COMMUNITY_FEED'].Init({U=U,A=A,toast=function()end,show=function()end,call=function(action,args)
 calls=calls+1;if fail then return nil,'Temporariamente indisponível · tente novamente'end
 local out={};for i=1,24 do local id=args.page*24+i+1;out[i]={id='roblox:'..id,owner=id,body=A.Copy(S.Current),source='Roblox',signature=tostring(id),name='Look real',total=10}end;return{items=out,finished=false}
end})
U.Root.Visible=true;U.CommunityArea.Visible=true;U.SetWide(true);ctl.Open('JOGADORES');flush();assert(#ctl.Rows==50 and #ctl.Pool==50 and calls==3)
U.CommunityGrid.CanvasPosition=Vector2.new(0,10000);U.CommunityGrid:GetPropertyChangedSignal('CanvasPosition'):Fire();flush();assert(calls==3,'scroll auto requested another batch')
for _=1,30 do U.ComMore.Activated:Fire();flush();assert(#ctl.Rows<=100 and #ctl.History<=600 and #ctl.Pool==50)end
assert(ctl.Evicted>0);local before=calls;local evicted=ctl.Evicted;U.ComMore.Activated:Fire();flush();assert(calls<=before+1 and ctl.Evicted==evicted+10,'ten-item batch fetched unnecessary pages or lost pending looks')
while #ctl.Pending>0 do U.ComMore.Activated:Fire();flush()end
fail=true;U.ComMore.Activated:Fire();flush();assert(not ctl.Loading and U.ComMore.Active and U.CommunityStatus.Text:find('Carregar mais',1,true))
fail=false;U.ComMore.Activated:Fire();flush();assert(#ctl.Rows>0 and not ctl.Loading)
return 'first batch capped at 50 real distinct descriptions; scroll does not fetch; manual batches recycle oldest rows in tens after 100; 50 GUI slots and 600 seen-signature bound; transient failure can retry'
''')
# The controller fixture uses the actual server RPC and actual skin state.
DATA=DATA.replace(';S.Init()','')
CART=module('09C4_OUTFIT_LIBRARY')+"Cart=Modules['09C4_OUTFIT_LIBRARY']\n"
CLIENT=fixture('test_integration.py','CLIENT')
case('catalog_auto_applies_debounced_clothes_body_and_external_look',CLIENT+r'''
U.OpenRequest:Fire('Catalog');flush();advance(.5);local before=HUM.applyCount
Details[7001]={Id=7001,ItemType='Asset',AssetType='Shirt'};Details[7002]={Id=7002,ItemType='Asset',AssetType='Pants'}
assert(S.Try(Details[7001]));assert(S.Try(Details[7002]));flush();assert(HUM.applyCount==before);advance(.41);assert(HUM.applyCount==before+1 and HUM.applied.Shirt==7001 and HUM.applied.Pants==7002 and #HUM.applied:GetAccessories()==3)
local settled=HUM.applyCount;advance(2);assert(HUM.applyCount==settled,'AcceptApplied caused a feedback loop')
assert(S.SetScale('HeightScale',1.04));advance(.41);assert(HUM.applied.HeightScale==1.04)
U.OpenRequest:Fire('Community');local look=A.Copy(S.Current);look.props.Shirt=7003;assert(S.Set(look));advance(.5);assert(HUM.applied.Shirt~=7003)
U.OpenRequest:Fire('Catalog');advance(.41);assert(HUM.applied.Shirt==7003 and HUM.applied.Pants==7002)
return 'two rapid clothing choices produce one native Apply; untouched accessories preserved; body applies automatically; no AcceptApplied feedback loop; a look chosen outside the catalog applies on returning'
''')
case('body_paid_default_free_option_real_bundle_search',UI+DATA+"S.Init()\n"+PREVIEW+CART+module('09C2_SHOP_CATALOG')+r'''
local last;function Services.AvatarEditorService:SearchCatalogAsync(params)last=params;return{IsFinished=true,GetCurrentPage=function()return{{Id=302,Name='Body',ItemType='Bundle',Price=params.MinPrice==0 and 0 or 25}}end}end
local ctl=Modules['09C2_SHOP_CATALOG'].Init({U=U,A=A,S=S,toast=function()end});U.Root.Visible=true;for _,b in ipairs(U.Groups:GetChildren())do if b:IsA('GuiButton')and b.Text=='CORPO'then b.Activated:Fire();break end end;flush()
assert(last and #last.BundleTypes==2 and (not last.AssetTypes or #last.AssetTypes==0) and last.MinPrice==1,'body search still targets individual off-sale torso parts')
assert(last.BundleTypes[1]==Enum.BundleType.BodyParts and last.BundleTypes[2]==Enum.BundleType.DynamicHeadAvatar)
local n=0;for _,o in ipairs(U.Grid:GetChildren())do if o:IsA('GuiButton')then n=n+1 end end;assert(n==1)
for _,b in ipairs(U.Subs:GetChildren())do if b:IsA('GuiButton')and b.Text=='CORPOS GRÁTIS'then b.Activated:Fire()end end;flush();assert(last.MinPrice==0 and last.MaxPrice==0)
return 'Corpo starts with paid native body bundles; explicit free subcategory queries zero-priced bundles; results remain real'
''')
PHOTO=THEME+DATA+"S.Init()\n"+PREVIEW+module('07P0_STUDIO_PRESETS')+module('07P3_POSE_EDITOR')+module('07P5_POSE_CANVAS')+module('07P6_STUDIO_SETS')+module('07P2_STUDIO_AVATAR')+"Studio=Modules['07P2_STUDIO_AVATAR']\n"
case('photo_real_scene_animation_freeze_pose_drag_gizmos_and_late_exit',PHOTO+r'''
local create=Services.Players.CreateHumanoidModelFromDescriptionAsync;local lastTrack
function Services.Players:CreateHumanoidModelFromDescriptionAsync(desc,rig)
 local model=create(self,desc,rig);local hum=model:FindFirstChildOfClass('Humanoid');local anim=hum:FindFirstChildOfClass('Animator');local tracks={}
 function anim:GetPlayingAnimationTracks()return tracks end
 function hum:PlayEmoteAsync(name)
  assert(name=='PhotoEmote'and desc:GetEmotes().PhotoEmote[1]==9000);if CloseWhilePlaying then Studio.Exit();return true end
  local t={Looped=false,Speed=1,stopped=false,Stopped=Signal()};function t:AdjustSpeed(s)self.Speed=s end;function t:Stop()self.stopped=true;self.Stopped:Fire()end;tracks={t};lastTrack=t
  for _,j in ipairs(model:GetDescendants())do if j:IsA('Motor6D')then j.Transform=CFrame.new(.1,.2,0)*CFrame.Angles(.3,.4,.5)end end;return true
 end;return model
end
Details[9000]={Id=9000,AssetType='EmoteAnimation'};assert(Studio.Enter());local original=Studio.Model;assert(Studio.PlayEmote(9000));assert(Studio.Model~=original and original.Parent==nil and Studio.Model.Parent==Studio.Folder and Studio.Pose.Playback and lastTrack.Looped)
Studio.SetEmoteSpeed(.5);assert(lastTrack.Speed==.5);local joint=Studio.Model.Torso:FindFirstChild('RightShoulder');local cf=joint.Transform
assert(Studio.FreezeEmote()and lastTrack.stopped and not Studio.Track and not Studio.Pose.Playback);assert((joint.Transform.Position-cf.Position).Magnitude<.0001 and (joint.Transform.LookVector-cf.LookVector).Magnitude<.0001,'freezing distorted the joint')
local arm=Instance.new('Part');arm.Name='RightUpperArm';arm.Parent=Studio.Model;Studio.Pose.Parts.RightUpperArm='RightShoulder';Studio.Pose.Begin()
local host=Instance.new('Frame');host.Size=UDim2.fromScale(1,1);host.Parent=pg;local tools=Instance.new('Frame');tools.Position=UDim2.fromOffset(1100,58);tools.Size=UDim2.fromOffset(400,600);tools.Parent=host
local p=Modules['07P5_POSE_CANVAS'].Build(tools,Studio.Pose,function()end,{model=Studio.Model,camera=Studio.Camera,gizmoParent=host});TEST_RAY_HIT={Instance=arm};local touch={UserInputType=Enum.UserInputType.Touch,Position=Vector3.new(650,350,0)}
Services.UserInputService.InputBegan:Fire(touch,true);assert(not Studio.Model:FindFirstChild('SelectedPosePart'));Services.UserInputService.InputBegan:Fire(touch,false);assert(Studio.Model.SelectedPosePart.Adornee==arm)
local old=Studio.Pose.Values.RightShoulder[3];touch.Position=Vector3.new(600,300,0);Services.UserInputService.InputChanged:Fire(touch);assert(Studio.Pose.Values.RightShoulder[3]~=old);Services.UserInputService.InputEnded:Fire(touch);Services.RunService.RenderStepped:Fire(1/60);assert(p.Gizmo and named(p.Gizmo,'PoseAxisX').AbsoluteSize.X==44)
p.Destroy();assert(not host:FindFirstChild('PoseHandles')and not Studio.Model:FindFirstChild('SelectedPosePart'))
CloseWhilePlaying=true;local ok,message=Studio.PlayEmote(9000);assert(not ok and message=='Emote cancelado.'and not Studio.Model and not Studio.Track)
return 'emote executes on the scene rig with native PlayEmoteAsync; speed/loop and freeze preserve a mixed-axis pose; direct body ray selection/drag with 44px handles; UI clicks ignored; overlay cleanup and exit during native playback cannot resurrect avatar'
''')
case('community_native_friend_profiles_four_request_concurrency_and_exact_description',DATA+"S.Init()\n"+module('09B2_COSPLAY_METADATA')+module('09B1_AVATAR_DISCOVERY')+module('09B4_CURATED_LOOKS')+r'''
local jobs={};local active,peak,descriptions,friends=0,0,0,0
function task.spawn(fn,...)jobs[#jobs+1]={co=coroutine.create(fn),args={...}}end;task.defer=task.spawn
function task.wait(seconds)
 local co,main=coroutine.running();if not main then return coroutine.yield(seconds)end
 TEST_TIME=TEST_TIME+(seconds or .04);local count=#jobs
 for _=1,count do local job=table.remove(jobs,1);local ok,message=coroutine.resume(job.co,table.unpack(job.args));job.args={};assert(ok,message);if coroutine.status(job.co)~='dead'then jobs[#jobs+1]=job end end
end
function Services.Players:GetFriendsAsync(seed)
 friends=friends+1;local rows={};for i=1,50 do rows[i]={Id=seed+1000+i,Username='Friend'..i}end
 return{IsFinished=true,GetCurrentPage=function()return rows end}
end
function Services.Players:GetHumanoidDescriptionFromUserIdAsync(id)
 active=active+1;peak=math.max(peak,active);assert(active<=4,'unbounded native avatar requests');task.wait(.2)
 descriptions=descriptions+1;local d=InitialDescription:Clone();d.Shirt=id*10+1;d.Pants=id*10+2;active=active-1;return d
end
function Services.AvatarEditorService:GetBatchItemDetailsAsync(ids)local out={};for _,id in ipairs(ids)do out[#out+1]={Id=id,Name='Meme hoodie',Price=0,PriceStatus='Free'}end;return out end
local data=Modules['09B4_CURATED_LOOKS'].Page(pl,{page=0,budget='all'});assert(peak==4 and active==0 and descriptions==32 and friends==1 and #data.items==24)
for _,r in ipairs(data.items)do assert(r.body.props.Shirt==r.owner*10+1 and r.body.props.Pants==r.owner*10+2 and r.name=='Meme · look de jogador'and r.total==0)end
return 'native friend pages reused from cache; four yielding native description calls maximum; 32 candidates bounded; actual outfit preserved; cautious style label derived from native item metadata'
''')
HERE.joinpath('features_results.json').write_text(json.dumps(results,indent=2,ensure_ascii=False)+'\n')
print('V49 FEATURES',len(results),'PASS')
