from test_support import *
LAST=module('09B7_LAST_AVATAR')+"Last=Modules['09B7_LAST_AVATAR']\n"
RUNTIME=LAST+module('09B5_AVATAR_RUNTIME')+"Runtime=Modules['09B5_AVATAR_RUNTIME'];Runtime.Start();flush()\n"
case('only_successfully_applied_avatar_survives_new_session',DATA+RUNTIME+r'''
local key='u_'..pl.UserId;local store=StoreData.AvatarPlaza_LastApplied_v1
assert(store[key]and not store[key].body,'profile load must not overwrite a saved choice')
local wanted=InitialDescription:Clone();wanted.Torso=9605;wanted.HeightScale=1.04;wanted.MoodAnimation=451;wanted.StaticFacialAnimation=true
bodyChild(wanted,'Head',9713,'Classic');wanted:SetEmotes({Dance={31},Wave={32}})
local result=Runtime.Apply(pl,wanted,'R15');assert(result.applied and result.saveState=='pending');advance(1)
assert(pl:GetAttribute('ACP_AvatarSaveState')=='saved'and store[key].body.props.Torso==9605)
local record=deep(store[key]);assert(record.body.bodyParts.Head.shape=='Classic'and record.body.props.MoodAnimation==451)
local failed=InitialDescription:Clone();failed.Torso=9998;FailBuild=true
assert(not pcall(Runtime.Apply,pl,failed,'R15'));FailBuild=false;assert(store[key].body.props.Torso==9605)
Services.Players.PlayerRemoving:Fire(pl)
-- Simulate a different server: fresh services' lifecycle signals and module-local state.
pl.CharacterAdded=Signal();pl.CharacterAppearanceLoaded=Signal();Services.Players.PlayerAdded=Signal();Services.Players.PlayerRemoving=Signal()
local fresh=Services.Players:CreateHumanoidModelFromDescriptionAsync(InitialDescription,Enum.HumanoidRigType.R15);fresh.Parent=workspace;pl.Character=fresh
Modules['09B7_LAST_AVATAR']=loadModule('''+q(src('09B7_LAST_AVATAR'))+r''','NewLastSession')
local NewRuntime=loadModule('''+q(src('09B5_AVATAR_RUNTIME'))+r''','NewAvatarSession');NewRuntime.Start();flush()
local hum,actual=NewRuntime.Description(pl);local body=A.Pack(actual);actual:Destroy()
assert(body.props.Torso==9605 and body.props.MoodAnimation==451 and body.bodyParts.Head.shape=='Classic')
assert(#body.accessories==#record.body.accessories and body.scales.HeightScale==1.04 and body.facial==true)
local ids={};for _,id in ipairs(body.emotes)do ids[id]=true end;assert(ids[31]and ids[32])
return 'fresh profile load never saves itself; confirmed live native metadata/layers/scales/emotes survive a fresh session; failed body cannot replace the persisted choice'
''')
case('rapid_applies_coalesce_and_leave_flushes_newest_revision',DATA+LAST+r'''
Last.Start();local b=A.Copy(S.Current);assert(Last.Read(pl)==nil)
for i=1,25 do b.props.Shirt=1000+i;assert(Last.Remember(pl,b,'R15'))end
advance(1);local store=StoreData.AvatarPlaza_LastApplied_v1;local key='u_'..pl.UserId
assert(store[key].body.props.Shirt==1025 and pl:GetAttribute('ACP_AvatarSaveState')=='saved')
b.props.Shirt=2000;Last.Remember(pl,b,'R15');advance(1);assert(store[key].body.props.Shirt==1025)
b.props.Shirt=3000;Last.Remember(pl,b,'R15');Services.Players.PlayerRemoving:Fire(pl)
assert(store[key].body.props.Shirt==3000)
return '25 rapid edits coalesce to the newest body; ordinary writes are spaced eight seconds; leaving bypasses the delay and flushes the latest pending skin'
''')
case('new_session_prevents_old_server_overwrite',DATA+LAST+r'''
Last.Read(pl);local b=A.Copy(S.Current);b.props.Shirt=777;Last.Remember(pl,b,'R15');advance(1)
b.props.Shirt=888;Last.Remember(pl,b,'R15')
local newer=loadModule('''+q(src('09B7_LAST_AVATAR'))+r''','OtherServer');local saved,ok=newer.Read(pl);assert(ok and saved.body.props.Shirt==777)
assert(not Last.Flush(pl)and pl:GetAttribute('ACP_AvatarSaveState')=='superseded')
assert(StoreData.AvatarPlaza_LastApplied_v1['u_'..pl.UserId].body.props.Shirt==777)
return 'atomic session token blocks a late flush from an older server from overwriting the newer session'
''')
case('storage_outage_never_overwrites_record_with_profile_defaults',DATA+LAST+r'''
local key='u_'..pl.UserId;local original=A.Copy(S.Current);original.props.Shirt=1999
StoreData.AvatarPlaza_LastApplied_v1[key]={version=1,session='old',body=original,rig='R15'}
FailStores=true;local saved,ok=Last.Read(pl);assert(not saved and not ok and pl:GetAttribute('ACP_AvatarSaveState')=='unavailable')
assert(StoreData.AvatarPlaza_LastApplied_v1[key].body.props.Shirt==1999)
FailStores=false;saved,ok=Last.Read(pl);assert(ok and saved.body.props.Shirt==1999)
local edited=A.Copy(saved.body);edited.props.Shirt=2999;Last.Remember(pl,edited,'R15');FailStores=true;advance(1)
assert(pl:GetAttribute('ACP_AvatarSaveState')=='unavailable'and StoreData.AvatarPlaza_LastApplied_v1[key].body.props.Shirt==1999)
FailStores=false;assert(Last.Flush(pl));assert(StoreData.AvatarPlaza_LastApplied_v1[key].body.props.Shirt==2999)
return 'read/write outage is visible; existing data remains intact; retry and final flush recover the intended skin without profile fallback overwrites'
''')
case('shutdown_flush_and_update_callback_retry_are_idempotent',DATA+LAST+r'''
Last.Start();StoreRetry=true;Last.Read(pl);local body=A.Copy(S.Current);body.props.Shirt=3456;Last.Remember(pl,body,'R15')
assert(#CloseCallbacks==1);CloseCallbacks[1]();flush()
assert(StoreData.AvatarPlaza_LastApplied_v1['u_'..pl.UserId].body.props.Shirt==3456)
return 'BindToClose waits for pending saves; repeated UpdateAsync transform execution has no yielding calls or external side effects'
''')
HERE.joinpath('persistence_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
