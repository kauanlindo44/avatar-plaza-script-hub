from test_support import *
from chaos_fixture import BASE
SIZES='{{320,568,0,0,0},{390,844,0,0,34},{568,320,0,0,0},{667,375,0,0,0},{851,392,44,44,21},{1280,720,0,0,0},{1920,1080,0,0,0}}'
HUD=THEME+module('07G6_WORLD_DETAILS')+module('07G4_WORLD_SCENERY')+module('07G7_ADVENTURE_WORLD')+module('07G2_LOCAL_WORLDS')+module('07G1_HUB_SETTINGS')
AI=THEME+DATA+PREVIEW+module('09I0_ASSISTANT_CONFIG')+module('09I4_ASSISTANT_UI')+module('09I6_ASSISTANT_RESULTS')
PHOTO=THEME+DATA+PREVIEW+module('07P4_STUDIO_UI')+module('07P9_STUDIO_CATALOG')
case('hud_center_corridor_and_all_buttons_are_clear_on_seven_screens',HUD+src('07G_HUB_UI')+r'''
flush();local root=named(pg.LimitedMarketHUD,'HudRoot');local launch=pg.AvatarShopLauncherGui
for _,sz in ipairs('''+SIZES+r''')do
 SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0
 root:GetPropertyChangedSignal('AbsoluteSize'):Fire();flush()
 local center=Modules['07UI_DESIGN_SYSTEM'].New('Frame',{Position=UDim2.fromOffset(SCREEN_W*.36,120),Size=UDim2.fromOffset(SCREEN_W*.28,math.max(1,SCREEN_H-190-(sz[5]or 0)))},pg.LimitedMarketHUD)
 local controls={named(launch,'TopCatalog')};for _,n in ipairs({'Games','Assistant','TopStores','Community','Looks','AvatarTools','Photo','TopMusic','Cart','Cfg'})do controls[#controls+1]=named(root,n)end
 for i,b in ipairs(controls)do
  assert(b and b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44);inside(b,pg.LimitedMarketHUD);assert(not intersects(b,center),b.Name..' blocks avatar corridor '..SCREEN_W..'x'..SCREEN_H..' y='..b.AbsolutePosition.Y..' center='..center.AbsolutePosition.Y..' h='..center.AbsoluteSize.Y)
  for j=1,i-1 do assert(not intersects(b,controls[j]),b.Name..' overlaps '..controls[j].Name)end
 end;center:Destroy()
end
return 'all eleven controls fit safe bounds and avoid each other and the center corridor on seven screen geometries'
''')
case('avatar_actions_use_distinct_tinted_surfaces_and_help_opens_command_window',HUD+src('07G_HUB_UI')+r'''
flush();local root=named(pg.LimitedMarketHUD,'HudRoot');named(root,'AvatarTools').Activated:Fire()
for _,name in ipairs({'Loader','CurrentlyWearing','RestoreAvatar'})do local b=named(root,name);local c=b.BackgroundColor3;assert(c.R+c.G+c.B>1.5 and(math.abs(c.R-c.B)>.01))end
named(root,'Commands').Activated:Fire();local panel=named(root,'CommandWindow');assert(panel.Visible and not named(root,'AvatarShortcuts').Visible)
assert(#named(panel,'PersonalCommandList'):GetChildren()>=14);inside(panel,pg.LimitedMarketHUD)
named(panel,'CloseCommands').Activated:Fire();assert(not panel.Visible and named(root,'Games').Visible)
Modules['07G3_PERSONAL_TOOLS'].CommandResult({ok=true,data={help=true}});pg:GetAttributeChangedSignal('ACP_OpenCommandsNonce'):Fire();assert(panel.Visible)
return 'load/wearing/restore have tinted colors; Avatar → Comandos and the server help response open the same readable list'
''')
case('missing_plan_module_does_not_block_assistant_profile_or_chat',AI+module('09I7_ASSISTANT_PROFILE')+r'''
Modules['09I25_PLAN_PRODUCTS']=nil;local o=rep:FindFirstChild('09I25_PLAN_PRODUCTS');if o then o:Destroy()end
local u=Modules['09I4_ASSISTANT_UI'].Build(pl);local p=Modules['09I7_ASSISTANT_PROFILE'].Build(u,function()end,function()end,function()end,function()end)
u.Root.Visible=true;u.Add('Quero criar um look',true);p.Render({plan='Normal',prefs={},expires=0});assert(u.Root.Visible)
p.Page='Planos';p.Render({plan='Normal',prefs={},expires=0});flush()
local unavailable=0;for _,v in ipairs(u.Profile:GetChildren())do if v:IsA('TextButton')and v:GetAttribute('ProductDiagnostic')=='module_missing'then assert(not v.Active);unavailable=unavailable+1 end end
assert(unavailable==2);u.Select('Conversa');assert(u.Chat.Visible)
return 'the exact dependency absent in photo 2 disables only price/purchase buttons; profile and conversation remain usable'
''')
case('assistant_look_tiles_are_small_and_never_exceed_five_per_column',AI+r'''
local u=Modules['09I4_ASSISTANT_UI'].Build(pl);u.Root.Visible=true;u.ConversationEmpty=false;u.Layout()
local r=Modules['09I6_ASSISTANT_RESULTS'].Build(u,function()return true end,function()end)
for _,count in ipairs({1,5,6,12,25,50})do
 local looks={};for i=1,count do looks[i]={name='Look '..i,total=10,body=A.Copy(S.Current),rig='R15'}end
 r.Accept({looks=looks,plan='Pro'});flush();r.Layout(600,500)
 local columns={};for _,entry in ipairs(r.InlineViews)do
  local c=entry.Card;local col=c:GetAttribute('OutfitColumn');local row=c:GetAttribute('OutfitRow');columns[col]=(columns[col]or 0)+1
  assert(row<=5 and c.AbsoluteSize.X==148 and c.AbsoluteSize.Y==192 and entry.View.AbsoluteSize.Y<100)
 end
 assert(#r.InlineViews==count);for _,n in pairs(columns)do assert(n<=5)end
 assert(r.InlineScroll.CanvasSize.X.Offset<=math.ceil(count/5)*156)
end
r.ClearInline();assert(#r.InlineViews==0)
return '1–50 generated looks use 148×192 tiles with compact previews, column-first order, at most five rows and horizontal overflow'
''')
case('emote_catalog_three_columns_and_separate_purchase',PHOTO+r'''
SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM,CORE_LEFT,CORE_RIGHT,CORE_TOP=851,392,44,44,21,44,44,58
local u=Modules['07P4_STUDIO_UI'].Build(pl);u.Root.Visible=true;u.Popup.Visible=true
local chosen;local rows={};for i=1,30 do rows[i]=fixture60(2000+i,'Dance '..i,'EmoteAnimation')end
function Services.AvatarEditorService:SearchCatalogAsync()return{IsFinished=true,GetCurrentPage=function()return rows end}end
Modules['07P9_STUDIO_CATALOG'].Open(u,'Animations',function(v)chosen=v end,function()end,{pause=function()return true,true end,speed=function()end});flush();u.Layout();flush()
local list=named(u.Content,'StudioCatalogItems');local cards=list:GetChildren();assert(#cards==6,'expected 6, got '..#cards)
for i,c in ipairs(cards)do assert(c.AbsoluteSize.X>=44 and c.AbsoluteSize.Y>=44);inside(c,u.Popup);assert(c.Position.Y.Offset==cards[math.floor((i-1)/3)*3+1].Position.Y.Offset)end
local old=LastPrompt;cards[1].Activated:Fire();assert(chosen.Id==2001 and LastPrompt==old)
named(u.Content,'BuySelectedStudioItem').Activated:Fire();flush();assert(LastPrompt.id==2001)
named(u.Content,'NextEmotePage').Activated:Fire();assert(#list:GetChildren()==6 and list:GetChildren()[1]:GetAttribute('AssetId')==2007);named(u.Content,'PreviousEmotePage').Activated:Fire();assert(#list:GetChildren()==6)
return '851×392 safe landscape shows three columns and two rows of emotes with ≥44px targets, a second page and explicit independent purchase'
''')
case('photo_panels_keep_zero_scene_margins_on_every_size',THEME+module('07P4_STUDIO_UI')+r'''
local u=Modules['07P4_STUDIO_UI'].Build(pl);u.Root.Visible=true
for _,sz in ipairs('''+SIZES+r''')do
 SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP=sz[3],sz[4],58
 for _,catalog in ipairs({false,true})do for _,visible in ipairs({false,true})do
  u.CatalogMode=catalog;u.Popup.Visible=visible;u.Layout()
  for _,n in ipairs(u.SceneMargins)do assert(n==0)end
 end end
end
return 'opening emotes/background/pose panels never reallocates the camera viewport or moves its optical center'
''')
case('negative_colors_do_not_become_requested_colors_or_substring_matches',THEME+DATA+module('09I13_OUTFIT_SEARCH')+module('09I2_ASSISTANT_ENGINE')+r'''
local p=Modules['09I12_REQUEST_PLAN'];local s=Modules['09I13_OUTFIT_SEARCH'];local v=p.Parse('quero casual sem vermelho')
assert(v.color==''and v.excludedColors[1]=='red');v=p.Parse('casual azul sem rosa');assert(v.color=='blue'and v.excludedColors[1]=='pink')
assert(s.Allowed({Name='Featured blouse',AssetType='Shirt'},{excludedColors={'red'}}))
assert(not s.Allowed({Name='Pink blouse',AssetType='Shirt'},{excludedColors={'pink'}}))
assert(not s.Allowed({Name='Featured blouse',AssetType='Shirt'},{color='red'}))
assert(s.Allowed({Name='Camisa vermelha',AssetType='Shirt'},{color='red'}))
local E=Modules['09I2_ASSISTANT_ENGINE'];local help=E.Help('O catalogo nao abre');assert(help:find('Catálogo',1,true)and not help:find('Acesse IA de looks',1,true));local ai=E.Help('IA nao abre');assert(ai:find('Reconectar',1,true))
return 'negative colors and word boundaries are respected, and a catalog failure is not misdiagnosed as an IA failure'
''')
case('chaos_arena_is_one_finite_green_rectangle_and_two_button_parts',BASE+r'''
assert(arena.Floor.Size.X==128 and arena.Floor.Size.Z==88);local count=0
for _,p in ipairs(arena.Model:GetDescendants())do if p:IsA('BasePart')then count=count+1;assert(p.Name=='BC_Floor'or p.Name=='BC_Button'or p.Name=='BC_ButtonBase')end end
assert(count==3 and C.Palette.Floor.G>C.Palette.Floor.R and C.Palette.Floor.G>C.Palette.Floor.B)
local p,q=start(2);local s=at(p,Vector3.new(65,arena.Top+3,0));tick(.1);assert(s.root.Position.X==65 and s.alive)
at(p,Vector3.new(65,arena.Top-17,0));tick(.1);assert(not s.alive)
return 'exactly three parts; 128×88 green floor, open sides and no invisible rollback; a real fall eliminates'
''')
case('push_selects_near_opponent_and_cannot_be_forged_or_spammed',BASE+r'''
local p,q,third=start(3);local r=G.round;local s=at(p,Vector3.new(0,arena.Top+4,0));local t=at(q,Vector3.new(0,arena.Top+4,-4));at(third,Vector3.new(30,arena.Top+4,0))
s.root.CFrame=CFrame.lookAt(s.root.Position,t.root.Position);assert(G.Request(p,'push',{target=third.UserId,force=999999}))
assert(t.root.lastImpulse and t.root.AssemblyLinearVelocity.Magnitude<=27 and not r.players[third].root.lastImpulse)
assert(not G.Request(p,'push'));assert(G.Snapshot(p).pushCooldown>2.9)
local outsider=add(999);assert(not G.Request(outsider,'push'));tick(3)
at(q,Vector3.new(0,arena.Top+4,-8));assert(not G.Request(p,'push'))
return 'the server chooses the real nearby opponent, ignores client target/force, enforces 3 seconds, 6 studs and membership'
''')
case('push_rejects_behind_obstacle_frozen_and_shielded_targets',BASE+r'''
local p,q,third=start(3);local r=G.round;local s=at(p,Vector3.new(0,arena.Top+4,0));local t=at(q,Vector3.new(0,arena.Top+4,-4));at(third,Vector3.new(30,arena.Top+4,0))
s.root.CFrame=CFrame.lookAt(s.root.Position,t.root.Position)
BC_RAY=function()return{Instance=arena.Floor}end;assert(not G.Request(p,'push'));BC_RAY=nil
s.effects.freeze={untilAt=clock+2};assert(not G.Request(p,'push'));s.effects.freeze=nil
t.shield=clock+12;assert(not G.Request(p,'push'));assert(t.shield==0 and not t.root.lastImpulse)
tick(3);at(q,Vector3.new(0,arena.Top+4,4));assert(not G.Request(p,'push'))
return 'line of sight, frozen actor, facing direction and shield all prevent illegal impulses'
''')
case('chaos_controls_leave_jump_and_the_middle_view_free',THEME+module('BC_Config')+module('BC_HUD')+r'''
local gui=Modules['07UI_DESIGN_SYSTEM'].New('ScreenGui',{Name='BC_GameGui'},pg);local u=Modules.BC_HUD.Build(gui)
for _,sz in ipairs('''+SIZES+r''')do
 SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP=sz[3],sz[4],58
 u.Set({phase='ACTIVE',matchId='m',alive=true,health=100,score=2,remaining=45,aliveCount=5,pushCooldown=0,effects={},weapon={name='Blaster de energia',ammo=3,remaining=5}})
 for _,b in ipairs({u.Fire,u.Push,u.Exit,u.Reduce})do inside(b,u.Hud);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44)end
 assert(not intersects(u.Fire,u.Push)and not intersects(u.Health,u.Top)and not intersects(u.Top,u.Exit))
 assert(u.Push.Position.Y.Offset+u.Push.Size.Y.Offset<=SCREEN_H-(sz[5]or 0)-110)
 assert(u.Top.AbsoluteSize.Y==44 and not u.Effect.Visible)
end
return 'four touch controls and a 44px header fit seven sizes; the push/fire row ends above the native jump fallback region'
''')
case('nuclear_effect_explodes_at_floor_and_eliminates_exactly_one_target',BASE+r'''
local p,q,third=start(3);G.effects.Execute(G.round,p,C.Effects[3]);local target=G.round.nuclear.target;tick(3.99)
for _,m in ipairs(messages)do assert(m.k~='nuclear')end;tick(.02)
local found=false;for _,m in ipairs(messages)do if m.k=='nuclear'then assert(m.d.at.Y==arena.Top+.3 and m.d.user==target);found=true end end
local dead=0;for _,s in pairs(G.round.players)do if not s.alive then dead=dead+1 end end;assert(found and dead==1)
return 'no premature detonation; explosion position is the ground under the fixed target, with exactly one elimination'
''')
case('sound_and_music_focus_are_local_and_reversible',THEME+r'''
local d=Modules['07UI_DESIGN_SYSTEM'];local a=Modules['07UI_GAME_AUDIO'];local root=d.New('Frame',{Visible=false},pg);a.Bind(root)
root.Visible=true;root:GetPropertyChangedSignal('Visible'):Fire();assert(pg:GetAttribute('ACP_GameAudioFocus'))
root.Visible=false;root:GetPropertyChangedSignal('Visible'):Fire();assert(pg:GetAttribute('ACP_GameAudioFocus')==false)
pg:SetAttribute('ACP_EffectsEnabled',false);assert(not a.Play('explosion',Vector3.zero));pg:SetAttribute('ACP_EffectsEnabled',true)
assert(a.Play('explosion',Vector3.zero,.3));assert(not a.Play('explosion',Vector3.zero,.3));assert(not a.Play('forged_sound'))
assert(Services.SoundService.ACP_GameAudio and not workspace:FindFirstChildOfClass('Explosion'))
return 'game focus restores music preference, SFX can be muted, repeated/unknown sounds are rejected and no physical Explosion is created'
''')
case('explosion_audio_survives_result_transition_but_stops_on_leave',THEME+module('BC_Config')+module('BC_VisualEffects')+r'''
local calls,stops=0,0;Modules['07UI_GAME_AUDIO'].Play=function(key)if key=='explosion'then calls=calls+1 end end;Modules['07UI_GAME_AUDIO'].StopAll=function()stops=stops+1 end
local v=Modules.BC_VisualEffects.New();v.Reconcile({matchId='r',phase='ACTIVE',alive=true,roster={}})
v.Handle('nuclear',{at=Vector3.new(0,6001,0),user=123});assert(calls==1)
v.Handle('clearFx',{});v.Reconcile({matchId='r',phase='RESULTS',alive=true,roster={}});assert(stops==0)
v.Clear();assert(stops==1);v.Destroy()
return 'the last elimination cannot cut off its own explosion sound when results open; explicit return still cancels trailing audio'
''')
HERE.joinpath('v75_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
