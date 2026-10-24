from test_support import *
SIZES="{{320,568,0,0,0},{390,844,0,0,34},{568,320,0,0,0},{667,375,0,0,0},{851,392,44,44,21},{1920,1080,0,0,0}}"
BG=DATA+module('07P8_BACKGROUND_RESOLVER')
case('visible_probe_reproduces_v66_false_failure_and_v67_loads_same_asset',BG+module('old',v='V66') if False else BG+"installModule('OldBackground',"+q(src('07P7_ROBLOX_BACKGROUNDS','V66'))+")\n"+module('07P7_ROBLOX_BACKGROUNDS')+r'''
background66(501,'rbxassetid://123456');local rpc=Instance.new('RemoteFunction');rpc.Name='Request';rpc.Parent=rep.LMShop_Remotes
function rpc:InvokeServer(a,d)return{ok=true,data=Modules['07P8_BACKGROUND_RESOLVER'].Resolve(pl,d)}end
local old,errorText=Modules.OldBackground.Image({id=501},function()return true end);assert(not old and errorText:find('imagem utilizável',1,true))
local fresh=assert(Modules['07P7_ROBLOX_BACKGROUNDS'].Image({id=501},function()return true end));assert(fresh.image=='rbxassetid://123456'and fresh.quality=='RENDER_CONFIRMED')
assert(not named(pg,'ACP_BackgroundProbe'))
return 'with actual culling conditions enforced, the old offscreen transparent probe rejects a valid image while V67 renders and accepts the same internal image; the temporary GUI is removed'
''')
case('background_real_refusal_keeps_previous_and_native_texture_uri_is_supported',BG+module('07P7_ROBLOX_BACKGROUNDS')+r'''
background66(501,'rbxasset://textures/SpawnLocation.png');local rpc=Instance.new('RemoteFunction');rpc.Name='Request';rpc.Parent=rep.LMShop_Remotes
function rpc:InvokeServer(a,d)return{ok=true,data=Modules['07P8_BACKGROUND_RESOLVER'].Resolve(pl,d)}end
local r=assert(Modules['07P7_ROBLOX_BACKGROUNDS'].Image({id=501},function()return true end));assert(r.image=='rbxasset://textures/SpawnLocation.png')
ImageDenied67=true;local previous={id=501,image='kept'};assert(not Modules['07P7_ROBLOX_BACKGROUNDS'].Image(previous,function()return true end));assert(previous.image=='kept'and not named(pg,'ACP_BackgroundProbe'))
return 'native texture references resolve without inventing an image ID; a real fetch/render refusal still preserves the prior selected background and cleans its probe'
''')
case('support_height_uses_rig_feet_and_survives_late_native_recalculation',DATA+module('08B6_AVATAR_MOVEMENT')+r'''
local model=Instance.new('Model');model.Parent=workspace;local h=Instance.new('Humanoid');h.HipHeight=2;h.RigType=Enum.HumanoidRigType.R15;h.Health=100;h.Parent=model
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Size=Vector3.new(2,2,1);root.CFrame=CFrame.new(0,6,0);root.Parent=model;model.PrimaryPart=root
for _,name in ipairs({'LeftFoot','RightFoot'})do local f=Instance.new('Part');f.Name=name;f.Size=Vector3.new(1,2,1);f.CFrame=CFrame.new(0,0,0);f.Parent=model end
local hat=Instance.new('Accessory');hat.Parent=model;local p=Instance.new('Part');p.Size=Vector3.new(200,200,200);p.CFrame=CFrame.new(0,-20,0);p.Parent=hat
local m=Modules['08B6_AVATAR_MOVEMENT'];assert(m.Prepare(model));assert(h.HipHeight==6 and m.Clearance(model)==7 and model:GetAttribute('ACP_SupportHeight')==7)
h.HipHeight=2;m.Settle(model,function()return true end);advance(1.1);assert(h.HipHeight==6 and root.Position.Y>=7)
return 'a low native HipHeight is corrected from the two actual feet, a huge accessory is excluded and later automatic scaling cannot immediately reset the saved support height'
''')
ANIMS=DATA+module('08B7_AVATAR_ANIMATIONS')
case('avatar_animation_resolver_reads_owned_description_and_normalizes_actual_clips',ANIMS+r'''
function HUM:GetAppliedDescription()local d=Instance.new('HumanoidDescription');d.WalkAnimation=501;d.IdleAnimation=502;return d end
Assets66[501]=function()local m=Instance.new('Model');local a=Instance.new('Animation');a.AnimationId='http://www.roblox.com/asset/?id=7777';a.Parent=m;return m end
Assets66[502]=function()local m=Instance.new('Model');for i=1,2 do local a=Instance.new('Animation');a.AnimationId='rbxassetid://'..(8000+i);a.Parent=m end;return m end
local r=Modules['08B7_AVATAR_ANIMATIONS'].Resolve(pl);assert(r.clips.WalkAnimation[1]=='rbxassetid://7777'and #r.clips.IdleAnimation==2)
local calls=InsertCalls66;Modules['08B7_AVATAR_ANIMATIONS'].Resolve(pl);assert(InsertCalls66==calls)
return 'movement items are read from the server character description, not a client-selected ID; HTTP and rbxassetid clip references work and repeat reads use cache'
''')
case('fallback_refreshes_animate_configuration_and_uses_equipped_walk_clip',DATA+r'''
pl.Character:SetAttribute('ACP_AvatarManaged',true);local animator=Instance.new('Animator');animator.Parent=HUM
local animate=Instance.new('LocalScript');animate.Name='Animate';animate.Parent=pl.Character;local walk=Instance.new('Folder');walk.Name='walk';walk.Parent=animate
local a=Instance.new('Animation');a.AnimationId='old';a.Parent=walk
local rpc=Instance.new('RemoteFunction');rpc.Name='Request';rpc.Parent=rep.LMShop_Remotes
function rpc:InvokeServer(action)assert(action=='AvatarAnimations');return{ok=true,data={clips={WalkAnimation={'rbxassetid://7777'}}}}end
'''+src('09C11_AVATAR_CHARACTER')+r'''
flush();advance60(2);HUM.Running:Fire(12);assert(a.AnimationId=='rbxassetid://7777');local found=false
for _,t in ipairs(animator.loaded)do if t.AnimationId=='rbxassetid://7777'and t.IsPlaying then found=true end end;assert(found)
return 'the real character controller updates a copied Animate configuration and its fallback uses the actual equipped walk clip instead of forcing the generic cycle'
''')
case('animation_config_retries_when_apply_rpc_is_still_busy',DATA+r'''
pl.Character:SetAttribute('ACP_AvatarManaged',true);local animator=Instance.new('Animator');animator.Parent=HUM
local animate=Instance.new('LocalScript');animate.Name='Animate';animate.Parent=pl.Character;local walk=Instance.new('Folder');walk.Name='walk';walk.Parent=animate
local a=Instance.new('Animation');a.AnimationId='old';a.Parent=walk
local rpc=Instance.new('RemoteFunction');rpc.Name='Request';rpc.Parent=rep.LMShop_Remotes
local calls=0;function rpc:InvokeServer(action)calls=calls+1;assert(action=='AvatarAnimations');if calls<3 then return{ok=false,error='Apply busy'}end;return{ok=true,data={clips={WalkAnimation={'rbxassetid://7777'}}}}end
'''+src('09C11_AVATAR_CHARACTER')+r'''
flush();advance60(2);HUM.Running:Fire(12);assert(calls==3 and a.AnimationId=='rbxassetid://7777');local found=false
for _,t in ipairs(animator.loaded)do if t.AnimationId=='rbxassetid://7777'and t.IsPlaying then found=true end end;assert(found)
return 'the movement request retries two Apply-in-progress refusals and then installs the verified walk clip instead of silently remaining on the fallback'
''')
shop=src('09C_SHOP_CLIENT');start=shop.index('local function playPreviewEmote(id)');end=shop.index('local function refit()',start);actual_play=shop[start:end]
case('catalogue_emote_test_uses_verified_clip_on_current_preview',THEME+DATA+PREVIEW+module('07P11_EMOTE_RESOLVER')+r'''
local view=Instance.new('ViewportFrame');view.Size=UDim2.fromOffset(300,380);view.Parent=pg;local controller=Preview.Mount(view,S.Current,'R15',{drag=true});flush()
local previewModel=controller.Model;local previewTrack;local gen=1;local pendingPreviewEmote;local U={RigBox=Instance.new('Frame'),StopEmote=Instance.new('TextButton')}
local function vis(o,v)o.Visible=v end
local function render()error('existing preview must not be rebuilt')end
local function stopEmote()if previewTrack then previewTrack:Stop(0);previewTrack:Destroy();previewTrack=nil end end
emote66(501,7777)
local function call(action,args)assert(action=='PhotoEmote');return Modules['07P11_EMOTE_RESOLVER'].Resolve(pl,args)end
'''+actual_play+r'''
assert(playPreviewEmote(501));assert(previewModel==controller.Model and previewTrack.AnimationId=='rbxassetid://7777'and previewTrack.IsPlaying and U.StopEmote.Visible)
S.Rig='R6';local ok=playPreviewEmote(501);assert(not ok and U.RigBox.Visible)
return 'the actual catalog function succeeds despite the LocalPlayer-only emote restriction, plays the verified animation on the existing preview and explains R6 incompatibility'
''')
WORLD=THEME+DATA+module('07G7_ADVENTURE_WORLD')+module('07G6_WORLD_DETAILS')+module('07G4_WORLD_SCENERY')+module('07G2_LOCAL_WORLDS')
case('eight_worlds_include_stylized_adventure_with_bounded_detail',WORLD+r'''
local world=Instance.new('Folder');world.Name='PracaAvatar_V2';world.Parent=workspace;local w=Modules['07G2_LOCAL_WORLDS'];assert(#w.Worlds==8)
for _,v in ipairs(w.Worlds)do assert(v.material==Enum.Material.SmoothPlastic or v.material==Enum.Material.Grass or v.material==Enum.Material.Sand)end
assert(w.Apply('ADVENTURE'));flush();local root=workspace.ACP_LocalWorldVisuals;local n=root:GetAttribute('SceneryParts');assert(n>20 and n<=80)
assert(named(root,'AdventureHill')and named(root,'AdventureLake'))
for _,p in ipairs(root:GetDescendants())do if p:IsA('BasePart')then assert(not p.CanCollide and not p.CanQuery)end end
w.Destroy()
return 'all eight worlds use coherent native materials; the separate adventure scene adds composed varied trees, a lake and distant hills with a clear central area and a fixed 80-part budget'
''')
case('halloween_automatic_brasilia_end_manual_override_and_off',THEME+r'''
local t=Modules['07UI_HALLOWEEN_THEME'];pg:SetAttribute('ACP_HalloweenMode','Auto');pg:SetAttribute('ACP_HalloweenEnabled',true)
assert(t.EndsAt==1793502000 and t.Enabled(pg,t.EndsAt-1)and not t.Enabled(pg,t.EndsAt))
t.SetMode(pg,'Off');assert(not t.Enabled(pg,t.EndsAt-100));t.SetMode(pg,'On');assert(t.Enabled(pg,t.EndsAt+86400))
return 'automatic decoration ends exactly on 1 November 2026 at 00:00 Sao Paulo; disabling works before that date and an explicit manual choice can keep it enabled afterward'
''')
CHATS=THEME+DATA+module('09I0_ASSISTANT_CONFIG')+module('09I1_ASSISTANT_ACCOUNTS')+module('09I11_CONVERSATIONS')
case('chat_history_private_bounded_and_writes_batched',CHATS+r'''
local c=Modules['09I11_CONVERSATIONS'];local writes=DSCalls64.writes
for i=1,10 do assert(c.Handle(pl,'chat.save',{id='one',title='Chat '..i,messages={{role='user',text='private '..i}}}))end
assert(DSCalls64.writes==writes);advance(21);assert(DSCalls64.writes==writes+1)
local other=makePlayer(456);assert(not c.Handle(other,'chat.read',{id='one'}));local record=c.Handle(pl,'chat.read',{id='one'});assert(record.messages[1].text=='private 10')
local many={};for i=1,30 do many[i]={role='user',text=tostring(i)}end;c.Handle(pl,'chat.save',{id='one',messages=many});assert(#c.Handle(pl,'chat.read',{id='one'}).messages==16)
return 'history belongs to the requesting Roblox user, ten edits produce one delayed profile write and only the last sixteen messages are persisted per conversation'
''')
case('chat_share_requires_confirmation_and_broadcast_filter_before_public_code',CHATS+r'''
local c=Modules['09I11_CONVERSATIONS'];c.Handle(pl,'chat.save',{id='one',messages={{role='user',text='secret private raw'}}})
assert(not c.Handle(pl,'chat.share',{id='one'}))
local filtered=0;function Services.TextService:FilterStringAsync(text,user)assert(user==pl.UserId);filtered=filtered+1;return{GetNonChatStringForBroadcastAsync=function()return'FILTERED'end}end
function Services.HttpService:GenerateGUID()return'12345678-1234-1234-1234-123456789012'end
local shared=assert(c.Handle(pl,'chat.share',{id='one',confirm=true}));assert(filtered==1 and shared.code:match('^CH%-'))
local other=makePlayer(456);local view=assert(c.Handle(other,'chat.code',{code=shared.code}));assert(view.messages[1].text=='FILTERED'and not view.owner and not view.id)
assert(not c.Handle(other,'chat.read',{id='one'}));assert(not c.Handle(pl,'chat.share',{id='one',confirm=true}))
return 'no share is created without confirmation; only a filtered textual snapshot is readable by code, the original remains private and repeated sharing is rate limited'
''')
case('chat_share_filter_failure_cannot_publish_unfiltered_text',CHATS+r'''
local c=Modules['09I11_CONVERSATIONS'];c.Handle(pl,'chat.save',{id='one',messages={{role='user',text='raw'}}})
function Services.TextService:FilterStringAsync()error('filter unavailable')end
local result,why=c.Handle(pl,'chat.share',{id='one',confirm=true});assert(not result and why:find('filtro',1,true))
assert(c.Handle(pl,'chat.read',{id='one'}).messages[1].text=='raw')
return 'filter service failure refuses public sharing and leaves the private conversation intact'
''')
case('assistant_sidebar_settings_share_and_guided_form_fit_six_sizes',CHATS+module('09I4_ASSISTANT_UI')+module('09I5_ASSISTANT_QUESTIONNAIRE')+r'''
local u=Modules['09I4_ASSISTANT_UI'].Build(pl);u.Root.Visible=true
local nav=Modules['09I10_CHAT_NAV'].Build(u,function(a,d)return Modules['09I11_CONVERSATIONS'].Handle(pl,a,d or{})end,function()end)
local q=Modules['09I5_ASSISTANT_QUESTIONNAIRE'].Build(u,function()end)
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;u.MenuOpen=true;u.Layout();nav.Layout()
 for _,b in ipairs({u.Share,u.Close,u.Menu})do inside(b,u.Root);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44)end;assert(not intersects(u.Share,u.Close)and not intersects(u.Share,u.Sponsor))
 u.Select('Perfil');inside(u.SettingsWindow,u.Root);inside(u.SettingsClose,u.SettingsWindow);assert(u.SettingsShade.Visible and u.Chat.Visible)
 u.SettingsClose.Activated:Fire();u.Share.Activated:Fire();nav.Layout();inside(named(u.Root,'ShareConversationPanel'),u.Root);inside(named(u.Root,'CloseShareConversation'),named(u.Root,'ShareConversationPanel'));named(u.Root,'CloseShareConversation').Activated:Fire()
 q.Open('Normal');inside(q.Confirm,q.Root);inside(q.Close,q.Root);q.CloseGuide()
end
u.Add('Como usar o catálogo?',true);u.Add('Abra Catálogo.',false);nav.Save();flush();assert(#Modules['09I11_CONVERSATIONS'].Handle(pl,'chat.list',{}).items==1)
return 'desktop/sidebar navigation, settings modal, explicit sharing dialog and guided creation keep safe reachable closes and 44px header targets in six screen sizes; real navigation saves a two-message private chat'
''')
TRUCO=THEME+DATA+module('07K6_CARD_CATALOG')+module('07K7_CARD_STYLES')+module('07K0_TRUCO_RULES')+module('07K15_TRUCO_TABLE')+module('07H8_PLAY_SESSION')+module('07K5_TRUCO_UI')
case('reference_truco_composition_keeps_avatars_private_hand_and_public_cards_separate',TRUCO+r'''
local d=Modules['07UI_DESIGN_SYSTEM'];local gui=d.New('ScreenGui',{IgnoreGuiInset=true},pg);local u=Modules['07K5_TRUCO_UI'].Build(gui,function()end)
local v={seat=1,variant='Paulista',score={0,0},phase='play',turn=1,hand={{rank='3',suit='S'},{rank='A',suit='H'},{rank='K',suit='D'}},players={{uid=123,name='Me'},{uid=2,name='Rival'},{uid=3,name='Partner'},{uid=4,name='Other'}},tableCards={},tricks={},lastTrick={},counts={3,3,3,3},value=1,nextRaise=3,handNumber=1,remaining=30,dealer=4}
for i=1,4 do v.tableCards[i]={seat=i,card={rank='3',suit='S'}}end;u.Update(v,{equipped='Classic'})
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;u.Layout();inside(u.Hand,u.TableArea)
 for _,slot in pairs(u.TableView.Slots)do inside(slot.card,u.TableArea);assert(not intersects(slot.card,u.Hand),'public card covers private hand')end
 for _,p in ipairs(u.TableView.Players)do inside(p.root,u.TableArea);assert(p.relation.Text~=''and p.thumb:FindFirstChildOfClass('UICorner'))end
 for _,b in ipairs({u.Raise,u.MoreActions})do inside(b,u.Controls);assert(b.AbsoluteSize.Y>=44)end;for _,b in ipairs({u.Cover,u.Run})do inside(b,u.Secondary);assert(b.AbsoluteSize.Y>=44)end
end
assert(#u.HandCards==3 and named(u.TableArea,'FeltEmblem'))
return 'the oval dark-rimmed green table surrounds four avatar badges; three fanned private cards, separate smaller public cards, team labels and compact bottom controls remain distinct on six screens'
''')
case('sponsored_game_and_community_duration_stays_exactly_one_day',module('09B10_SPONSORED_DESTINATIONS')+r'''
assert(Modules['09B10_SPONSORED_DESTINATIONS'].Duration==24*60*60)
return 'both destination categories retain the authoritative 86400-second expiry; a view or reload cannot extend it'
''')
case('assistant_conversation_routes_greetings_and_remembers_help_topic',THEME+module('09I12_REQUEST_PLAN')+module('09I2_ASSISTANT_ENGINE')+r'''
local e=Modules['09I2_ASSISTANT_ENGINE'];assert(e.IsHelp('oi')and e.IsHelp('tudo bem')and e.IsHelp('Como usar o catálogo?'))
assert(not e.IsHelp('streetwear azul até 100 Robux'));assert(e.Help('oi'):find('orçamento',1,true))
local answer,topic=e.Help('Como usar o catálogo?');assert(topic=='catalog')
local again=e.Help('e como faz isso?',topic);assert(again:find('subcategoria',1,true))
local refined=e.Ask(pl,'troca só o cabelo azul',{keyword='emo black',style='emo',color='black'});assert(refined.keyword=='emo blue'and refined.scope=='Cabelo')
return 'greetings and questions avoid outfit generation; a short follow-up retains the help subject and a hair/color refinement preserves the original style'
''')
case('chat_archive_rename_delete_survive_a_batched_flush',CHATS+r'''
local c=Modules['09I11_CONVERSATIONS'];c.Handle(pl,'chat.save',{id='one',title='Original',messages={{role='user',text='hello'}}})
local d=c.Handle(pl,'chat.read',{id='one'});d.title='Renamed';d.archived=true;c.Handle(pl,'chat.save',d)
local rows=c.Handle(pl,'chat.list',{}).items;assert(#rows==1 and rows[1].title=='Renamed'and rows[1].archived)
c.Handle(pl,'chat.delete',{id='one'});advance(21);assert(#c.Handle(pl,'chat.list',{}).items==0 and not c.Handle(pl,'chat.read',{id='one'}))
return 'renaming and archiving persist as separate history metadata and a confirmed deletion remains deleted after the delayed storage write'
''')
case('highlight_feed_repeated_refresh_reuses_result_and_change_invalidates_it',DATA+module('09B8_FREE_HIGHLIGHTS')+r'''
local f=Modules['09B8_FREE_HIGHLIGHTS'];local a=f.Feed(pl,{search='',group='Todos'});local b=f.Feed(pl,{search='',group='Todos'});assert(a==b)
f.Withdraw(pl);local c=f.Feed(pl,{search='',group='Todos'});assert(c~=b)
return 'the duplicated feed refresh shown in the server photo is served from the short cache, while a real publication/withdrawal invalidates it immediately'
''')
case('direct_animation_asset_is_not_misread_as_catalogue_container',ANIMS+r'''
function HUM:GetAppliedDescription()local d=Instance.new('HumanoidDescription');d.WalkAnimation=503;return d end
NativeInfo60[503]={Name='Native clip',AssetTypeId=Enum.AssetType.Animation.Value}
local result=Modules['08B7_AVATAR_ANIMATIONS'].Resolve(pl);assert(result.clips.WalkAnimation[1]=='rbxassetid://503'and InsertCalls66==0)
return 'a description which already contains a verified Animation asset uses it directly; it is not sent through InsertService as if it were a catalog animation package'
''')
HERE.joinpath('v67_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
