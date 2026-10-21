from test_support import *
SIZES="{{320,568,0,0,0},{390,844,0,0,34},{568,320,0,0,0},{667,375,0,0,0},{851,392,44,44,21},{1280,720,0,0,0},{1920,1080,0,0,0}}"
case('private_channels_are_server_rostered_isolated_and_retired',THEME+DATA+r'''
local a,b,c=makePlayer(2),makePlayer(3),makePlayer(4);function Services.Players:GetPlayers()return{pl,a,b,c}end
local chat=Modules['07H9_MATCH_CHAT'];local one=chat.Open('match-A','Truco',{pl,a});local two=chat.Open('match-B','Xadrez',{b,c});assert(one~=two);flush()
local ch1=Services.TextChatService:FindFirstChild(one,true);local ch2=Services.TextChatService:FindFirstChild(two,true)
assert(ch1 and ch2 and ChatCalls69.direct==2 and ChatCalls69.add==4)
local function source(ch,id)for _,v in ipairs(ch:GetChildren())do if v:IsA('TextSource')and v.UserId==id then return v end end end
assert(ch1.ShouldDeliverCallback({TextSource=source(ch1,123)},source(ch1,2)))
assert(not ch1.ShouldDeliverCallback({TextSource=source(ch2,3)},source(ch1,2)))
assert(not ch1.ShouldDeliverCallback({TextSource=source(ch1,123)},source(ch2,4)))
chat.Close('match-A');assert(ch1.destroyed and pl:GetAttribute('ACP_MatchChat')==nil and b:GetAttribute('ACP_MatchChat')==two)
local nextName=chat.Open('match-A-next','Damas',{pl,a});flush();assert(nextName~=one and pl:GetAttribute('ACP_MatchChat')==nextName)
assert(not ch1.ShouldDeliverCallback({TextSource={UserId=123}},{UserId=2}))
return 'two simultaneous matches have distinct native channels; only their server-recorded members pass delivery; closing/rematching retires prior membership'
''')
case('chat_permission_failure_fails_closed_and_leaving_cancels_late_add',THEME+DATA+r'''
local a=makePlayer(2);function Services.Players:GetPlayers()return{pl,a}end
local chat=Modules['07H9_MATCH_CHAT'];ChatPermissionError69=true;chat.Open('denied','Damas',{pl,a});flush();assert(ChatCalls69.add==0 and pl:GetAttribute('ACP_MatchChatStatus'):find('permiss',1,true))
ChatPermissionError69=false;chat.Close('denied');chat.Open('late','Truco',{pl,a});chat.Close('late');flush();assert(ChatCalls69.add==0)
local name=chat.Open('leave','Xadrez',{pl,a});flush();local ch=Services.TextChatService:FindFirstChild(name,true);chat.Remove(a)
assert(a:GetAttribute('ACP_MatchChat')==nil and not ch.ShouldDeliverCallback({TextSource={UserId=123}},{UserId=2}))
chat.Close('leave');DirectPermission69['123:2']=false;chat.Open('blocked','Truco',{pl,a});flush();assert(ChatCalls69.add==2)
return 'permission query failure or direct-chat denial adds no source; a closed pending room never admits late users and departure immediately blocks delivery'
''')
case('custom_chat_only_renders_confirmed_current_channel_and_sends_natively',THEME+DATA+r'''
local a=makePlayer(2);function Services.Players:GetPlayers()return{pl,a}end
local d=Modules['07UI_DESIGN_SYSTEM'];local gui=d.New('ScreenGui',{ScreenInsets=Enum.ScreenInsets.None},pg);local root=d.New('Frame',{Size=UDim2.fromScale(1,1)},gui)
local button=d.Button(root,'Conversa',{Size=UDim2.fromOffset(120,44)});local ui=Modules['07H10_MATCH_CHAT_UI'].Build(root,button)
local name=Modules['07H9_MATCH_CHAT'].Open('ui','Truco',{pl,a});flush();ui.Bind();assert(ui.Channel)
local pending={TextChannel=ui.Channel,TextSource={UserId=2},Status=Enum.TextChatMessageStatus.Sending,Text='UNFILTERED',MessageId='one'}
ui.Receive(pending);assert(#ui.Rows==0);pending.Status=Enum.TextChatMessageStatus.Success;pending.Text='FILTERED';ui.Receive(pending);ui.Receive(pending);assert(#ui.Rows==1 and ui.Unread==1)
local label=ui.Rows[1]:GetChildren()[3];local found=false;for _,v in ipairs(ui.Rows[1]:GetChildren())do if v:IsA('TextLabel')and v.Text=='FILTERED'then found=true;assert(v.RichText==false)end end;assert(found)
pending.TextChannel=Instance.new('TextChannel');pending.MessageId='foreign';ui.Receive(pending);assert(#ui.Rows==1)
ui.Input.Text='my local message';ui.SendMessage();flush();assert(ChatCalls69.send==1 and #ui.Rows==1 and ui.Input.Text=='')
advance60(2);SendDenied69=true;ui.Input.Text='keep me';ui.SendMessage();flush();assert(ChatCalls69.send==2 and ui.Input.Text=='keep me'and #ui.Rows==1)
return 'sending/foreign/duplicate messages are excluded; only confirmed native filtered text is rendered without rich text; SendAsync is the sole transport and failures preserve the draft'
''')
case('private_chat_touch_targets_fit_phone_desktop_and_keyboard',THEME+r'''
local d=Modules['07UI_DESIGN_SYSTEM'];local gui=d.New('ScreenGui',{ScreenInsets=Enum.ScreenInsets.None},pg);local root=d.New('Frame',{Size=UDim2.fromScale(1,1)},gui)
local b=d.Button(root,'Conversa');local ui=Modules['07H10_MATCH_CHAT_UI'].Build(root,b)
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0
 ui.Open=true;ui.Panel.Visible=true;ui.Layout();inside(ui.Panel,root)
 for _,o in ipairs({ui.Close,ui.Input,ui.Send})do inside(o,ui.Panel);assert(o.AbsoluteSize.X>=44 and o.AbsoluteSize.Y>=44)end
 assert(not intersects(ui.Close,ui.Input)and not intersects(ui.Input,ui.Send))
end
SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=851,392,44,44,21;CORE_LEFT,CORE_RIGHT=44,44
Services.UserInputService.OnScreenKeyboardVisible=true;Services.UserInputService.OnScreenKeyboardPosition=Vector2.new(0,220);ui.Layout()
assert(ui.Panel.AbsolutePosition.Y+ui.Panel.AbsoluteSize.Y<=220)
return 'seven safe phone/tablet/desktop geometries preserve chat close, composer and send targets; a landscape keyboard is kept clear'
''')
case('vegetation_plan_is_composed_spaced_varied_and_deterministic',THEME+r'''
local p=Modules['07G8_VEGETATION_PLAN'];local count=0
for _,id in ipairs({'ORIGINAL','PLAIN','ANIME','FOREST','COAST','HALLOWEEN','CLOUD','ADVENTURE'})do
 local a,b=p.Build(id),p.Build(id);assert(#a==#b and #a>=4);local variants,groups={},{}
 for i,v in ipairs(a)do assert(v.x==b[i].x and v.z==b[i].z);assert(v.x*v.x+v.z*v.z>(id=='ADVENTURE'and 92 or 48)^2);variants[v.variant]=true;groups[v.group]=true
  for j=1,i-1 do local u=a[j];assert((v.x-u.x)^2+(v.z-u.z)^2>=15^2)end
 end
 local nv,ng=0,0;for _ in pairs(variants)do nv=nv+1 end;for _ in pairs(groups)do ng=ng+1 end;assert(nv>=3 and ng>=2);count=count+#a
end
return tostring(count)..' trees across eight authored cluster plans keep clear centers, minimum spacing, variant silhouettes and stable rebuilds'
''')
case('shared_palette_keeps_legible_contrast_and_seasonal_optional',THEME+r'''
local d=Modules['07UI_DESIGN_SYSTEM'];local c=d.Colors
local function lum(a)local function f(v)return v<=.04045 and v/12.92 or((v+.055)/1.055)^2.4 end;return f(a.R)*.2126+f(a.G)*.7152+f(a.B)*.0722 end
local function contrast(a,b)local x,y=lum(a),lum(b);return(math.max(x,y)+.05)/(math.min(x,y)+.05)end
assert(lum(c.bg)<.05 and contrast(c.white,c.bg)>=4.5 and contrast(c.muted,c.panel)>=4.5 and contrast(c.ink,c.green)>=4.5)
local gui=d.New('ScreenGui',{Name='ACP_Test'},pg);local f=d.Frame(gui,{BackgroundColor3=c.panel});local label=d.Text(f,'selected',{TextColor3=Color3.new(1,1,1)})
local theme=Modules['07UI_HALLOWEEN_THEME'];theme.Apply(label);assert(contrast(label.TextColor3,c.panel)>=4.5)
label.TextColor3=Color3.new(1,1,1);assert(contrast(label.TextColor3,c.panel)>=4.5)
theme.Decorate(f);pg:SetAttribute('ACP_HalloweenMode','Off');pg:SetAttribute('ACP_HalloweenEnabled',false);assert(not named(f,'HalloweenSceneAccent').Visible)
return 'shared main text, muted text and primary controls meet 4.5:1 mathematically; legacy pale labels are corrected and Halloween remains optional'
''')
ACT=THEME+DATA+module('09I0_ASSISTANT_CONFIG')+module('09I1_ASSISTANT_ACCOUNTS')+module('09B11_DATA_BUDGET')+module('09I17_REMIX_PERMISSIONS')+r'''
Body69={[pl.UserId]=A.Copy(S.Current)};Body69[pl.UserId].props.Shirt=11;Body69[pl.UserId].props.Pants=22
local a=makePlayer(2);local b=makePlayer(3);local c=makePlayer(4);local outsider=makePlayer(5)
for _,p in ipairs({a,b,c,outsider})do Body69[p.UserId]=A.Copy(Body69[pl.UserId])end
function Services.Players:GetPlayers()return{pl,a,b,c,outsider}end
Modules['09B5_AVATAR_RUNTIME']={Description=function(p)return{RigType=Enum.HumanoidRigType.R15},A.Unpack(Body69[p.UserId])end,
 Apply=function(p,desc)Body69[p.UserId]=A.Pack(desc);Applied69=(Applied69 or 0)+1;return{body=A.Copy(Body69[p.UserId]),liveRig='R15'}end}
BuildCalls69={};local build69=0
Modules['09I3_OUTFIT_BUILDER']={Options=function(raw,plan)local o=deep(raw);o.plan=plan;return o end,Build=function(p,keyword,opts,base,progress,alive)
 BuildCalls69[#BuildCalls69+1]={uid=p.UserId,keyword=keyword,opts=deep(opts),body=deep(base)};build69=build69+1
 if BuildHook69 then BuildHook69(p,alive)end;if FailBuild69 then return nil,'no verified clothes'end;if not alive()then return nil,'cancelled'end
 local body=deep(base);body.props.Shirt=100+build69;body.props.Pants=200+build69
 return{{name='Verified',body=body,rig='R15',total=10,budget=opts.budget,verified=true,complete=true,signature=tostring(build69),items={{Id=body.props.Shirt,Price=5},{Id=body.props.Pants,Price=5}}}}
end}
Modules['09B6_CART_RESOLVER']={Quote=function(p,items)local rows={};for _,v in ipairs(items)do rows[#rows+1]={id=v.id,price=UnknownPrice69 and nil or Cost69 or 5,name='Verified item'}end;return rows end}
''' +module('09I14_SOCIAL_ACTIVITIES')+r'''
local activity=Modules['09I14_SOCIAL_ACTIVITIES'];local push=Instance.new('RemoteEvent');activity.Bind(push);flush()
local consent=Modules['09I17_REMIX_PERMISSIONS']
'''
case('activity_invites_require_acceptance_capacity_and_membership',ACT+r'''
local s=assert(activity.Create(pl,{kind='duo',style='emo',budget=100,palette='sea'}));assert(#s.members==1)
assert(not activity.Answer(outsider,{id=s.id,accept=true}));assert(activity.Invite(pl,{uid=2}));assert(#activity.Status(a).invites==1 and activity.Status(a).session==nil)
assert(activity.Answer(a,{id=s.id,accept=true}));assert(#activity.Status(pl).session.members==2)
assert(not activity.Invite(a,{uid=3}));assert(not activity.Invite(pl,{uid=3}));assert(not activity.Contribute(outsider,{slot='top'}))
assert(activity.Leave(pl));assert(activity.Status(a).session==nil)
return 'invites expose no session data before explicit acceptance; only host can invite, duo capacity is enforced and ending removes memberships'
''')
case('collaboration_changes_only_chosen_slot_checks_price_and_credit',ACT+r'''
local s=assert(activity.Create(pl,{kind='collab',budget=100}));assert(activity.Invite(pl,{uid=2}));assert(activity.Answer(a,{id=s.id,accept=true}))
Body69[2].props.Shirt=44;Body69[2].props.Pants=99
local shared=assert(activity.Contribute(a,{slot='top',body={props={Shirt=999999}}}));assert(shared.look.body.props.Shirt==44 and shared.look.body.props.Pants==22 and shared.look.total==#shared.look.items*5)
assert(#shared.look.contributors==2);local before=shared.look.body.props.Shirt;Body69[2].props.Shirt=55;Cost69=90
assert(not activity.Contribute(a,{slot='top'}));assert(activity.Status(pl).session.look.body.props.Shirt==before)
assert(not activity.Publish(a));assert(not activity.Publish(pl));assert(activity.VoteRemix(pl,{allow=true}));assert(activity.VoteRemix(a,{allow=true}));assert(activity.Publish(pl))
Cost69=5;assert(activity.Contribute(a,{slot='bottom'}));assert(not activity.Publish(pl))
return 'contribution uses server avatar data, preserves unselected clothes, rolls back over-budget changes and requires every collaborator to authorize the exact publishable composition'
''')
case('duo_generates_individual_styles_with_shared_palette_and_saves_own',ACT+r'''
local s=assert(activity.Create(pl,{kind='duo',budget=100,style='emo',palette='sea'}));assert(activity.Invite(pl,{uid=2}));assert(activity.Answer(a,{id=s.id,accept=true}))
assert(activity.Configure(a,{style='street',budget=99999,palette='rose'}));local v=activity.Status(pl).session;assert(v.settings.budget==100 and v.settings.palette=='sea')
assert(activity.Generate(pl));flush();assert(activity.Generate(a));flush();assert(#BuildCalls69==2)
assert(BuildCalls69[1].keyword:find('emo')and BuildCalls69[2].keyword:find('street')and BuildCalls69[1].opts.color=='blue'and BuildCalls69[2].opts.color=='blue')
assert(BuildCalls69[1].opts.count==1 and BuildCalls69[2].opts.budget==100);local one=activity.Current(pl);local two=activity.Current(a);assert(one.body.props.Shirt~=two.body.props.Shirt)
assert(activity.Save(a));local profile=Modules['09I1_ASSISTANT_ACCOUNTS'].Read(2);assert(profile.collections[1].body.props.Shirt==two.body.props.Shirt)
assert(activity.Apply(a));assert(Applied69==1 and Body69[2].props.Shirt==two.body.props.Shirt)
return 'each participant keeps an independent style while palette/budget are shared; only their own verified result is saved or applied explicitly'
''')
case('failed_and_cancelled_activity_generation_refunds_once',ACT+r'''
local accounts=Modules['09I1_ASSISTANT_ACCOUNTS'];local s=assert(activity.Create(pl,{kind='collab'}));FailBuild69=true
assert(activity.Generate(pl));flush();local d=accounts.Read(123);assert(d.quota.used==0)
advance(50);d=accounts.Read(123);assert(d.quota.used==0)
FailBuild69=false;BuildHook69=function(p,alive)activity.Configure(p,{style='street',budget=200});assert(not alive())end
assert(activity.Generate(pl));flush();d=accounts.Read(123);assert(d.quota.used==0)
return 'catalog failure or an options change cancels the request and refunds its quota exactly once, including the later timeout'
''')
case('remix_defaults_private_rechecks_revocation_and_preserves_origin',ACT+r'''
local original=assert(consent.Create(pl,{body=Body69[123],rig='R15'}));assert(original.allow==false and not consent.Check(original.code,2))
assert(not consent.SetAllowed(a,original.code,true));assert(consent.SetAllowed(pl,original.code,true))
local s=assert(activity.Create(a,{kind='remix',code=original.code,style='street',budget=100}));assert(s.look.remix.originalCreatorId==123)
assert(activity.Generate(a));flush();local result=activity.Current(a);assert(result.remix.originalCreatorId==123 and result.remix.originalCreatorName==pl.Name)
assert(activity.Save(a));local saved=Modules['09I1_ASSISTANT_ACCOUNTS'].Read(2).collections[1];assert(saved.remix.originalCreatorId==123)
local derivative=assert(activity.Publish(a));assert(derivative.originalId==123 and derivative.owner==2 and derivative.parent==original.code)
assert(consent.SetAllowed(a,derivative.code,true));assert(consent.Check(derivative.code,3))
assert(consent.SetAllowed(pl,original.code,false));assert(not activity.Apply(a)and not activity.Save(a)and not consent.Check(derivative.code,3))
return 'sharing begins blocked; only owner authorizes; generated/saved derivatives retain the original identity; revoking a parent blocks further remix use throughout the chain'
''')
case('permission_changed_during_generation_rejects_result_and_refunds',ACT+r'''
local original=assert(consent.Create(pl,{body=Body69[123],rig='R15'}));assert(consent.SetAllowed(pl,original.code,true))
assert(activity.Create(a,{kind='remix',code=original.code,budget=100}));BuildHook69=function()assert(consent.SetAllowed(pl,original.code,false))end
assert(activity.Generate(a));flush();local look=activity.Current(a);assert(look.pricePending==true)
assert(Modules['09I1_ASSISTANT_ACCOUNTS'].Read(2).quota.used==0)
return 'consent is checked after search too: an in-flight revocation cannot yield a new approved remix and quota is refunded'
''')
case('unavailable_storage_does_not_grant_remix_permission',ACT+r'''
local original=assert(consent.Create(pl,{body=Body69[123],rig='R15'}));assert(consent.SetAllowed(pl,original.code,true));Budget64.StandardRead=0
assert(not consent.Check(original.code,2));assert(not consent.SetAllowed(pl,original.code,false));Budget64.StandardRead=100
assert(consent.Check(original.code,2));assert(not consent.Check('../../forged',2))
return 'unconfirmed reads/writes cannot authorize a remix, and malformed codes are rejected before storage access'
''')
ACTUI=THEME+DATA+PREVIEW+module('09I16_ACTIVITY_UI')
case('all_activity_screens_fit_safe_mobile_desktop_and_keep_explicit_actions',ACTUI+r'''
local ui=Modules['09I16_ACTIVITY_UI'].Build(pl,function()return true end);ui.Root.Visible=true
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0
 ui.Kind=nil;ui.Render();for _,b in ipairs(ui.HomeButtons)do inside(b,ui.Home);assert(b.AbsoluteSize.Y>=44 and b.AbsoluteSize.X>=44)end
 for _,kind in ipairs({'collab','duo','shoot','remix'})do
  ui.Kind=kind;ui.State={kind=kind,settings=ui.Draft,owner=123,members={{uid=123,name='Me',style='casual'}},results={},revision=1};ui.Render()
  for _,b in ipairs({ui.Close,ui.Back,ui.Inbox,ui.Start,ui.Apply,ui.Save})do inside(b,ui.Root);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44,kind..':'..b.Name)end
  assert(not intersects(ui.Start,ui.Apply)and not intersects(ui.Save,ui.Start))
  if ui.Stage.Visible then inside(ui.Stage,ui.Work);assert(ui.Stage.AbsoluteSize.Y>=40,kind..': preview too short '..ui.Stage.AbsoluteSize.Y)end
 end
end
return 'seven geometries cover all four activity screens, safe close/navigation/touch targets, compact action menus and a usable preview area'
''')
case('rehearsal_steps_act_on_studio_copy_and_do_not_apply_map_avatar',THEME+r'''
local d=Modules['07UI_DESIGN_SYSTEM'];local gui=d.New('ScreenGui',{ScreenInsets=Enum.ScreenInsets.None},pg);local root=d.New('Frame',{Size=UDim2.fromScale(1,1)},gui)
local calls={};local studio={SetFrame=function(v)calls.frame=v end,SetAvatarYaw=function(v)calls.yaw=v end,SetZoom=function(v)calls.zoom=v end}
local ui={Gui=gui,Root=root,Notify=function(v)calls.notice=v end};local cues=Modules['09I19_REHEARSAL_CUES'].Build(ui,studio,function()return true end)
function Services.HttpService:JSONDecode()return{style='street',palette='sea'}end
pg:SetAttribute('ACP_RehearsalSettings','settings');cues.Open();assert(calls.frame=='FULL'and calls.yaw==0 and calls.zoom==1)
cues.Next.Activated:Fire();assert(calls.yaw==55 and calls.zoom==1.1);cues.Next.Activated:Fire();assert(calls.yaw==340 and calls.zoom==1.05)
cues.Close();assert(not cues.Root.Visible)
return 'three explicit steps change only the Studio copy framing/rotation/zoom and show concrete posing advice; no map avatar application or purchase is invoked'
''')
case('board_redraw_preserves_still_piece_instances_and_native_state',THEME+module('07H2_GAME_BOARD')+module('07A0_CHESS_RULES')+r'''
local d=Modules['07UI_DESIGN_SYSTEM'];local gui=d.New('ScreenGui',{ScreenInsets=Enum.ScreenInsets.None},pg);local board=Modules['07H2_GAME_BOARD'].Build(gui);local rules=Modules['07A0_CHESS_RULES'];local state=rules.New()
board.Draw(state,'Xadrez','W');local old=board.Cells[8][1]:FindFirstChild('PieceIcon');board.Draw(state,'Xadrez','W');assert(board.Cells[8][1]:FindFirstChild('PieceIcon')==old)
local turn=state.turn;board.Draw(state,'Xadrez','W',{r=7,c=5},{});assert(state.turn==turn and state.board[8][1].t=='R')
return 'stationary pieces retain render instances across clock snapshots and selecting/animating never mutates the rules board or turn'
''')
case('board_server_owns_chat_lifecycle_without_waiting_for_permissions',THEME+DATA+module('07A0_CHESS_RULES')+module('07B0_CHECKERS_RULES')+r'''
local a=makePlayer(2);function Services.Players:GetPlayers()return{pl,a}end
Modules['07W_WINS_SERVICE']={RecordMatch=function()RecordedBoard69=true end}
local kit=Instance.new('Folder');kit.Name='PracaKit';kit.Parent=rep;local rem=Instance.new('Folder');rem.Name='Remotes';rem.Parent=kit
'''+module('07H7_BOARD_SESSIONS')+r'''
local board=Modules['07H7_BOARD_SESSIONS'];board.Bind();local before=ChatCalls69.add
local name=assert(board.Open({code='ABCD',game='Xadrez'},{pl,a}));assert(ChatCalls69.add==before)
local channel=pl:GetAttribute('ACP_MatchChat');assert(channel and channel==a:GetAttribute('ACP_MatchChat'));flush();assert(ChatCalls69.add==before+2)
assert(board.Action(pl,'resignGame',name));assert(pl:GetAttribute('ACP_MatchChat')==nil and a:GetAttribute('ACP_MatchChat')==nil)
local nextName=assert(board.Open({code='EFGH',game='Damas'},{pl,a}));assert(pl:GetAttribute('ACP_MatchChat')~=channel and nextName~=name)
return 'the actual board authority opens a private channel asynchronously and retires it on finish; a different game receives a different channel'
''')
case('actual_activity_client_opens_creates_and_yields_to_match_without_gui_lock',ACT+PREVIEW+module('09I16_ACTIVITY_UI')+r'''
local folder=Instance.new('Folder');folder.Name='ACP_ActivityRemotes';folder.Parent=rep
local rpc=Instance.new('RemoteFunction');rpc.Name='Request';rpc.Parent=folder
local event=Instance.new('RemoteEvent');event.Name='Update';event.Parent=folder
function rpc:InvokeServer(action,data)
 local handlers={status=activity.Status,create=activity.Create,configure=activity.Configure,generate=activity.Generate,leave=activity.Leave}
 local value,e=handlers[action](pl,data);return{ok=value~=nil,data=value,error=e}
end
local hud=Instance.new('ScreenGui');hud.Name='LimitedMarketHUD';hud.Enabled=true;hud.Parent=pg
'''+src('09I_ACTIVITIES_CLIENT')+r'''
pg:SetAttribute('ACP_OpenActivitiesNonce',1);flush();local root=pg.ACP_Activities.CreativeActivities;assert(root.Visible and hud.Enabled)
named(root,'Activity_collab').Activated:Fire();local start=named(root,'ActivityStart');assert(start.Text=='Criar atividade');start.Activated:Fire();flush()
assert(activity.Status(pl).session.kind=='collab'and start.Text=='Sugerir base')
pl:SetAttribute('ACP_InGameRoom',true);assert(not root.Visible and hud.Enabled)
return 'the real activity LocalScript launches from its entry point, creates a server session and closes for a match without rewriting other GUI Enabled states'
''')
case('activity_remote_endpoint_rejects_unsupported_text_transport_and_bad_args',ACT+r'''
local spawn=task.spawn;task.spawn=function()end
'''+src('09I_ACTIVITIES_SERVER')+r'''
task.spawn=spawn;local rpc=rep.ACP_ActivityRemotes.Request
assert(not rpc.OnServerInvoke(pl,'send',{text='not a chat transport'}).ok)
assert(not rpc.OnServerInvoke(pl,'create','bad args').ok)
local good=rpc.OnServerInvoke(pl,'create',{kind='duo',budget=100});assert(good.ok and good.data.owner==pl.UserId)
local blocked=rpc.OnServerInvoke(a,'configure',{style='emo'});assert(not blocked.ok)
return 'the actual RPC wrapper accepts structured activity actions and rejects chat messages, malformed arguments and non-member configuration'
''')
case('new_features_are_explained_by_the_existing_game_assistant',THEME+r'''
local g=Modules['09I9_GAME_GUIDE']
for _,name in ipairs({'look em colaboração','duplas com personalidade','ensaio temático','remix autorizado','chat do truco'})do local topic=g.Find(name);assert(topic and #topic.answer>120,name);assert(not g.IsLookRequest('Como usar '..name..'?'))end
return 'all four activities and private match chat are concrete guide topics, reachable through normal help questions without invoking outfit generation'
''')

HERE.joinpath('v69_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
