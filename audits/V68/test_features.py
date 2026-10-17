from test_support import *
SIZES="{{320,568,0,0,0},{390,844,0,0,34},{568,320,0,0,0},{667,375,0,0,0},{851,392,44,44,21},{1920,1080,0,0,0}}"
BG=DATA+module('07P8_BACKGROUND_RESOLVER')
case('background_uses_native_imageid_value_color_and_never_catalog_asset_as_image',BG+r'''
background66(501,'123456',Color3.fromRGB(120,140,180));local r=Modules['07P8_BACKGROUND_RESOLVER'].Resolve(pl,{id=501})
assert(r.image=='rbxassetid://123456'and r.image~='rbxassetid://501'and r.stage=='INSERT_IMAGE_VALUE');assert(r.color[1]==120/255 and r.color[3]==180/255)
assert(LastInserted66.destroyed and not LastInserted66.Parent and InsertCalls66==1)
local cached=Modules['07P8_BACKGROUND_RESOLVER'].Resolve(pl,{id=501});assert(cached.image==r.image and InsertCalls66==1)
return 'actual AvatarBackground/ImageId.Value and Color.Value contract resolves the internal image, preserves color, destroys the unparented container and caches the result'
''')
case('background_missing_reference_and_denied_insert_never_return_fake_success',BG+r'''
background66(501,'not an image');assert(not pcall(Modules['07P8_BACKGROUND_RESOLVER'].Resolve,pl,{id=501}));assert(LastInserted66.destroyed)
background66(502,'345678');DeniedAssets66[502]=true;assert(not pcall(Modules['07P8_BACKGROUND_RESOLVER'].Resolve,pl,{id=502}))
NativeInfo60[503]={Name='shirt',AssetTypeId=11,IsForSale=true};assert(not pcall(Modules['07P8_BACKGROUND_RESOLVER'].Resolve,pl,{id=503}));assert(InsertCalls66==2)
return 'malformed image references, inaccessible containers and non-background assets cannot be reported as decoded backgrounds'
''')
case('background_server_client_pair_decodes_image_and_preserves_on_refusal',BG+module('07P7_ROBLOX_BACKGROUNDS')+r'''
background66(501,'rbxassetid://123456');local rpc=Instance.new('RemoteFunction');rpc.Name='Request';rpc.Parent=rep.LMShop_Remotes
function rpc:InvokeServer(a,d)assert(a=='PhotoBackground');local ok,r=pcall(Modules['07P8_BACKGROUND_RESOLVER'].Resolve,pl,d);return{ok=ok,data=ok and r,error=not ok and r}end
local b=Modules['07P7_ROBLOX_BACKGROUNDS'];local selected={id=501};local value=assert(b.Image(selected,function()return true end));assert(value.image=='rbxassetid://123456'and value.color)
assert(not named(pg,'ACP_BackgroundProbe'))
background66(502,'777');DeniedAssets66[502]=true;local bad={id=502,image='previous'};assert(not b.Image(bad,function()return true end));assert(bad.image=='previous')
return 'real resolver/client pair uses the internal image, attaches and removes its invisible loading probe and leaves the previous selection intact when permission is refused'
''')
EMOTE=DATA+module('07P11_EMOTE_RESOLVER')
case('emote_resolver_extracts_clip_without_executing_or_parenting_container',EMOTE+r'''
emote66(501,7777);local r=Modules['07P11_EMOTE_RESOLVER'].Resolve(pl,{id=501});assert(r.animation=='rbxassetid://7777'and r.animation~='rbxassetid://501')
assert(LastInserted66.destroyed and not LastInserted66.Parent);assert(Modules['07P11_EMOTE_RESOLVER'].Resolve(pl,{id=501}).animation==r.animation and InsertCalls66==1)
advance60(1);NativeInfo60[502]={Name='not emote',AssetTypeId=11};assert(not pcall(Modules['07P11_EMOTE_RESOLVER'].Resolve,pl,{id=502}));assert(InsertCalls66==1)
return 'server validates EmoteAnimation and returns the contained AnimationId; nested script never enters the DataModel, repeated selections use cache and other asset types are rejected'
''')
STUDIO=THEME+DATA+PREVIEW+module('07P0_STUDIO_PRESETS')+module('07P6_STUDIO_SETS')+module('07P3_POSE_EDITOR')+module('07P11_EMOTE_RESOLVER')+module('07P2_STUDIO_AVATAR')
case('photo_emote_works_with_native_localplayer_restriction_and_same_copy',STUDIO+r'''
emote66(501,7777);local rpc=Instance.new('RemoteFunction');rpc.Name='Request';rpc.Parent=rep.LMShop_Remotes
function rpc:InvokeServer(a,d)assert(a=='PhotoEmote');local ok,r=pcall(Modules['07P11_EMOTE_RESOLVER'].Resolve,pl,d);return{ok=ok,data=ok and r,error=not ok and r}end
local m=Modules['07P2_STUDIO_AVATAR'];assert(m.Enter());local copy=m.Model
local native,why=pcall(function()copy.Humanoid:PlayEmoteAsync('PhotoEmote')end);assert(not native and tostring(why):find('LocalPlayer',1,true))
assert(m.PlayEmote(501));assert(m.Model==copy and m.Track.AnimationId=='rbxassetid://7777'and m.Track.IsPlaying and m.Pose.Playback)
m.SetEmoteSpeed(.5);assert(m.Track.speed==.5);m.SetLoop(false);assert(not m.Track.Looped);m.StopEmote();assert(not m.Track and not m.Pose.Playback)
local folder=m.Folder;m.Exit();assert(folder.destroyed and not m.Model and not m.Folder)
return 'the exact LocalPlayer-only restriction is enforced by the double; Photo Mode still loads the verified clip onto the same local copy through Animator, with stop/speed/loop working'
''')
case('preview_drag_rotates_model_with_camera_and_floor_stationary',DATA+PREVIEW+r'''
local view=Instance.new('ViewportFrame');view.Size=UDim2.fromOffset(300,380);view.Parent=pg
local p=Preview.Mount(view,S.Current,S.Rig,{drag=true,floor=true});flush();local camera=p.Camera.CFrame;local initial=p.Model:GetPivot();local floor=named(view,'StudioFloor');local floorCF=floor.CFrame
p.Rotate(90);assert((p.Camera.CFrame.Position-camera.Position).Magnitude<.0001 and(p.Camera.CFrame.LookVector-camera.LookVector).Magnitude<.0001)
assert((p.Model:GetPivot().LookVector-initial.LookVector).Magnitude>.5);assert(floor.CFrame==floorCF);p.Rotate(-90);assert((p.Model:GetPivot().LookVector-initial.LookVector).Magnitude<.0001)
return 'rotating the controller changes avatar orientation while the camera transform and studio floor remain fixed; reverse rotation restores the original orientation'
''')
case('many_styles_are_unique_searchable_accent_aware_and_use_real_queries',THEME+module('09I12_REQUEST_PLAN')+module('09I2_ASSISTANT_ENGINE')+r'''
local s=Modules['09I8_AVATAR_STYLES'];local seen={};assert(#s.Styles>=80)
for _,v in ipairs(s.Styles)do assert(not seen[v.id]and #v.query>0 and #v.note>0);seen[v.id]=true end
for text,key in pairs({['gótico']='goth',['jirai kei']='jirai',['dark academia']='darkacademia',['preppy clássico']='preppy',['preppy']='preppypastel',['decora']='decora',['streetwear']='street'})do assert(s.Find(text).id==key,text)end
local e=Modules['09I2_ASSISTANT_ENGINE'];local a=assert(e.Ask(pl,'quero roupa azul',nil,'cottage'));assert(a.keyword=='cottagecore blue');assert(#s.Search('J-fashion')>=5)
return 'over 80 distinct options have human descriptions and real catalog search terms; accents, long aliases, Japanese fashion and selected styles work rather than collapsing to emo'
''')
case('guide_answers_catalogue_and_all_major_game_topics_without_hallucinated_lookup',THEME+r'''
local g=Modules['09I9_GAME_GUIDE'];assert(#g.Topics>=30)
assert(g.Answer('Como usar o catálogo?'):find('subcategoria',1,true));assert(g.Answer('Como usar música?'):find('fila',1,true));assert(g.Answer('Como editar pose?'):find('articulação',1,true))
assert(g.Answer('Como jogar truco?'):find('dez segundos',1,true));assert(g.Answer('Como usar o avatar do zero?'):find('R15',1,true));assert(g.Answer('Como salvar meus looks?'):find('Recarregar',1,true))
assert(g.IsQuestion('Como usar o catálogo?')and not g.IsQuestion('Quero um look streetwear'))
return 'knowledge is feature-specific across more than 30 topics; normal questions are distinguished from outfit requests and concrete steps match the actual game'
''')
AI=THEME+DATA+module('09I0_ASSISTANT_CONFIG')+module('09I1_ASSISTANT_ACCOUNTS')+module('09I11_CONVERSATIONS')+module('09I12_REQUEST_PLAN')+module('09I2_ASSISTANT_ENGINE')+module('09I0_ASSISTANT_CONFIG')+module('09I1_ASSISTANT_ACCOUNTS')+module('09I13_OUTFIT_SEARCH')+module('09I3_OUTFIT_BUILDER')+r'''
Modules['09B5_AVATAR_RUNTIME']={Description=function()return HUM,HUM:GetAppliedDescription()end};local m=Instance.new('ModuleScript');m.Name='09B5_AVATAR_RUNTIME';m.Parent=rep
'''+src('09I_ASSISTANT_SERVER')
case('game_help_bypasses_look_quota_and_catalog_generation',AI+r'''
local rpc=rep.ACP_AssistantRemotes.Request;local before=rpc.OnServerInvoke(pl,'status',{}).data.messagesLeft;local native=NativeRequests60
for i=1,12 do advance60(1);assert(rpc.OnServerInvoke(pl,'ask',{text='Como usar o catálogo?',make=true,request='help'..i}).ok);flush()end
advance60(1);assert(rpc.OnServerInvoke(pl,'status',{}).data.messagesLeft==before and NativeRequests60==native)
local count=0;for _,sent in ipairs(rep.ACP_AssistantRemotes.Progress.sent)do local d=sent.kind;if type(d)=='table'and d.kind=='result'and d.data.help then count=count+1;assert(#d.data.looks==0 and d.data.answer:find('Catálogo',1,true))end end;assert(count==12)
return 'twelve automatic help questions complete without entering the eight-look interaction limit, reserving a generation slot or querying catalog assets'
''')
case('style_and_budget_radio_lists_select_without_sending_and_fit_six_screens',THEME+module('09I0_ASSISTANT_CONFIG')+module('09I4_ASSISTANT_UI')+module('09I5_ASSISTANT_QUESTIONNAIRE')+r'''
local u=Modules['09I4_ASSISTANT_UI'].Build(pl);u.Root.Visible=true;u.Input.Text='Quero streetwear até 250 Robux';local confirmed
local q=Modules['09I5_ASSISTANT_QUESTIONNAIRE'].Build(u,function(v)confirmed=v end)
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;u.Layout();q.Open('Pro');q.Layout()
 for _,b in ipairs({q.Style,q.Budget,q.BudgetList,q.Confirm,q.Close})do inside(b,q.Root);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44)end
 q.OpenStyles();inside(q.Choices.Close,q.Root);inside(q.Choices.Search,q.Root);q.Choices.Search.Text='Cottage';q.Choices.Search:GetPropertyChangedSignal('Text'):Fire();local option=named(q.Choices.Root,'Choice_cottage');assert(option);option.Activated:Fire();assert(q.Options.style=='cottage'and not confirmed)
 q.OpenBudget();named(q.Choices.Root,'Choice_55').Activated:Fire();assert(q.Budget.Text=='55');q.CloseGuide()
end
q.Open('Normal');q.OpenStyles();q.Choices.Search.Text='Cottage';q.Choices.Search:GetPropertyChangedSignal('Text'):Fire();named(q.Choices.Root,'Choice_cottage').Activated:Fire();q.OpenBudget();named(q.Choices.Root,'Choice_55').Activated:Fire();q.Confirm.Activated:Fire();assert(confirmed.style=='cottage'and confirmed.budget==55)
return 'style and total budget use searchable described radio choices, preserve an explicit confirmation and keep fields/close reachable in six portrait and landscape sizes'
''')
LOOKS=UI+DATA+PREVIEW+COMMUNITY+module('09C1_SHOP_LOOKS')
case('saved_looks_deletion_requires_confirmation_and_four_primary_actions_fit',LOOKS+r'''
U.Root.Visible=true;U.SetWide(true);U.LooksArea.Visible=true;local deleted=0
local ctl=Modules['09C1_SHOP_LOOKS'].Init({U=U,A=A,S=S,call=function(a)if a=='List'then return{skins={{id='one',name='My look',body=A.Copy(S.Current),rig='R15'}}}elseif a=='Delete'then deleted=deleted+1;return true end end,toast=function()end,buyBody=function()end});ctl.Saved();flush()
U.OutfitMore.Activated:Fire();assert(U.OutfitActionsMenu.Visible);U.OutfitDelete.Activated:Fire();assert(deleted==0 and named(U.Root,'ConfirmDeleteLook').Visible)
named(U.Root,'CloseDeleteLook').Activated:Fire();assert(deleted==0);U.OutfitDelete.Activated:Fire();named(U.Root,'ConfirmDeleteSavedLook').Activated:Fire();flush();assert(deleted==1)
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;U.Layout();U.LayoutLooks()
 for _,b in ipairs({U.OutfitApply,U.OutfitUpdate,U.OutfitBuy,U.OutfitMore})do inside(b,U.OutfitActions);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y==44)end
 assert(U.OutfitDelete.Parent==U.OutfitActionsMenu and U.OutfitRestore.Parent==U.OutfitActionsMenu)
end
return 'saved-look shelf has four primary actions and a separate menu; Delete never calls the server before confirmation and cancelling preserves the stored look'
''')
ZERO=UI+DATA+PREVIEW+module('09C14_NEW_AVATAR')
case('blank_avatar_bases_colors_cancel_and_confirmation_preserve_saved_state',ZERO+r'''
U.Root.Visible=true;U.LooksArea.Visible=true;local before=A.Copy(S.Current);local w=Modules['09C14_NEW_AVATAR'].Build({U=U,call=function()return true end,toast=function()end})
w.Open();flush();assert(S.Current.props.Shirt==before.props.Shirt and S.Current.accessories[1].id==before.accessories[1].id)
named(w.Controls,'NewAvatarBase_R6').Activated:Fire();named(w.Controls,'BodyColor_9').Activated:Fire();flush();w.Hide();assert(S.Current.props.Shirt==before.props.Shirt)
w.Open();flush();w.Confirm.Activated:Fire();assert(S.Rig=='R6'and S.Current.props.Shirt==0 and #S.Current.accessories==0 and S.Current.colors.HeadColor[3]==215/255)
assert(#S.History>0);assert(S.Undo());assert(S.Current.props.Shirt==before.props.Shirt)
return 'new R6 base and chosen color are previewed without mutation; cancel preserves the current avatar, confirmation creates a clean editable base and Undo restores the prior look'
''')
case('new_avatar_controls_safe_preview_and_entry_fit_six_screens',ZERO+r'''
U.Root.Visible=true;U.LooksArea.Visible=true;U.SetWide(true);local w=Modules['09C14_NEW_AVATAR'].Build({U=U,call=function()return true end,toast=function()end});w.Open();flush()
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;U.Layout();U.LayoutLooks();w.Layout()
 inside(w.Entry,U.SavedGridPanel);inside(w.Panel,U.Root);inside(w.Close,w.Panel);inside(w.Confirm,w.Panel);assert(w.Confirm.AbsoluteSize.X>=44 and w.Confirm.AbsoluteSize.Y>=44)
 assert(not intersects(w.Stage,w.Controls)and not intersects(w.Stage,w.Confirm));assert(w.View.AbsoluteSize.X>80 and w.View.AbsoluteSize.Y>80)
end
w.Hide()
return 'clean-avatar dialog has a visible preview, independent scrollable options, safe entry/close/confirmation and nonoverlapping content on six screens'
''')
WORLD=THEME+DATA+module('07G6_WORLD_DETAILS')+module('07G4_WORLD_SCENERY')+module('07G2_LOCAL_WORLDS')
case('world_switch_restores_clouds_only_after_removing_owned_clouds',WORLD+r'''
local terrain=Instance.new('Terrain');terrain.Name='Terrain';terrain.Parent=workspace
-- Reinstall after creating Terrain so the module captures the actual native surface.
'''+module('07G2_LOCAL_WORLDS')+r'''
local original=Instance.new('Clouds');original.Name='OriginalCloud';original.Parent=terrain
local world=Instance.new('Folder');world.Name='PracaAvatar_V2';world.Parent=workspace
local meta=getmetatable(terrain);local set=meta.__newindex;local peak=0
meta.__newindex=function(o,k,v)set(o,k,v);if k=='Parent'and o:IsA('Clouds')then local n=0;for _,c in ipairs(terrain:GetChildren())do if c:IsA('Clouds')then n=n+1 end end;peak=math.max(peak,n)end end
local w=Modules['07G2_LOCAL_WORLDS'];for _,id in ipairs({'ORIGINAL','ANIME','FOREST','COAST','HALLOWEEN','CLOUD'})do assert(w.Apply(id));flush()end;w.Destroy()
assert(peak<=1 and original.Parent==terrain)
return 'switching all six themes and restoring the original never has two Cloud instances parented to Terrain at once'
''')
MUSIC=THEME+module('07M1_MUSIC_UI')+r'''
local original=Modules['07M1_MUSIC_UI'].Build
Modules['07M1_MUSIC_UI'].Build=function(...)MusicUI66=original(...);return MusicUI66 end
local rpc=Instance.new('RemoteFunction');rpc.Name='ACP_MusicRequest';rpc.Parent=rep;local attempted={}
function rpc:InvokeServer(a,d)
 if a=='load'then return{ok=true,data={volume=.4,saved={},last=LastAudio66 or 0}}end
 if a=='search'then return{ok=true,data={items={{id=1001,name='Blocked'},{id=1002,name='Good A'},{id=1003,name='Good B'}},finished=true}}end
 if a=='audio'then attempted[#attempted+1]=d.id;if d.id==9999 then return{ok=false,error='permission denied'}end;return{ok=true,data={id=d.id,name='Music '..d.id}}end
 return{ok=true,data=true}
end
function Services.ContentProvider:PreloadAsync(list,callback)
 local s=list[1];local id=tonumber(s.SoundId:match('(%d+)'));s.IsLoaded=id~=1001 and id~=9998 and id~=119682972981199;s.TimeLength=s.IsLoaded and 120 or 0
 if callback then callback(s.SoundId,{Name=s.IsLoaded and'Success'or'Failure'})end
end
'''
case('manual_music_permission_and_content_failures_automatically_change_track',MUSIC+src('07M_MUSIC_CLIENT')+r'''
flush();local sound=Services.SoundService.ACP_PersonalMusic;assert(sound.IsPlaying and sound.SoundId=='rbxassetid://1002')
MusicUI66.ID.Text='9999';MusicUI66.Load.Activated:Fire();flush();assert(sound.IsPlaying and sound.SoundId~='rbxassetid://9999')
MusicUI66.ID.Text='9998';MusicUI66.Load.Activated:Fire();flush();assert(sound.IsPlaying and sound.SoundId~='rbxassetid://9998'and #attempted<=10)
return 'manual ID permission refusal and content failure both advance to another real library/queue item; failure never leaves the player stuck on the rejected track'
''')
case('saved_last_music_failure_also_falls_back_without_repeating_rejected_id',MUSIC+'LastAudio66=9999\n'+src('07M_MUSIC_CLIENT')+r'''
flush();local sound=Services.SoundService.ACP_PersonalMusic;assert(sound.IsPlaying and sound.SoundId=='rbxassetid://1002')
local denied=0;for _,id in ipairs(attempted)do if id==9999 then denied=denied+1 end end;assert(denied==1 and #attempted<=4)
return 'an inaccessible persisted last track falls back through the library, skips an unavailable suggestion and reaches a loaded track without repeating the denied saved ID'
''')
CLIENT=THEME+DATA+PREVIEW+module('09I0_ASSISTANT_CONFIG')+module('09I4_ASSISTANT_UI')+module('09I5_ASSISTANT_QUESTIONNAIRE')+module('09I6_ASSISTANT_RESULTS')+module('09I7_ASSISTANT_PROFILE')+r'''
local folder=Instance.new('Folder');folder.Name='ACP_AssistantRemotes';folder.Parent=rep
local rpc=Instance.new('RemoteFunction');rpc.Name='Request';rpc.Parent=folder
local event=Instance.new('RemoteEvent');event.Name='Progress';event.Parent=folder;local asks=0
function rpc:InvokeServer(a,d)
 if a=='chat.list'then return{protocol=2,ok=true,data={items={}}}end
 if a=='chat.save'then return{protocol=2,ok=true,data={id=d.id,title=d.title}}end
 if a=='status'then return{protocol=2,ok=true,data={plan='Normal',available=true,count=1,collections={},prefs={},daily=5,remaining=5,used=0,expires=0,owner=123,members={},invites={}}}end
 if a=='ask'then asks=asks+1;assert(d.make==false);task.defer(function()event.OnClientEvent:Fire({request=d.request,kind='result',data={answer=Modules['09I9_GAME_GUIDE'].Answer(d.text),looks={},plan='Normal',requested=0,count=0,help=true}})end);return{protocol=2,ok=true,data={request=d.request}}end
 return{protocol=2,ok=true,data=a=='ad'and{hidden=true}or true}
end
'''
case('actual_client_routes_game_questions_to_help_without_outfit_form',CLIENT+src('09I_ASSISTANT_CLIENT')+r'''
flush();pg:SetAttribute('ACP_OpenAINonce',1);pg:GetAttributeChangedSignal('ACP_OpenAINonce'):Fire();flush()
local gui=pg.ACP_Assistant;local input=named(gui,'MessageComposer'):FindFirstChildOfClass('TextBox');local form=named(gui,'LookQuestionnaire')
for i,text in ipairs({'Como usar o catálogo?','Como jogar truco?','Como usar música?'})do
 input.Text=text;named(gui,'SendMessage').Activated:Fire();flush();assert(asks==i and not form.Visible);named(gui,'NewConversation').Activated:Fire();flush()
end
return 'the real LocalScript recognizes catalogue, truco and music questions even in make-look mode, skips the outfit questionnaire and remains usable after each new chat'
''')
HERE.joinpath('feature_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
