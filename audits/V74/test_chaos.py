from test_support import *
BASE=THEME+DATA+module('08B6_AVATAR_MOVEMENT')+module('BC_Config')+r'''BCSetup()'''
for name in ['BC_Queue','BC_ArenaBuilder','BC_PlayerState','BC_Integration','BC_EffectRegistry','BC_Combat','BC_EffectExecutor','BC_ButtonController','BC_RoundManager']:
 BASE+="BCInstall('"+name+"',"+q(src(name))+")\n"
BASE+=r'''
local C=Modules.BC_Config;local arena=Modules.BC_ArenaBuilder.Build();local rng=BCRandom();local clock=0;local messages={}
local G=Modules.BC_RoundManager.New({arena=arena,now=function()return clock end,random=rng,serverId='test-server',ready=function(p)return not p:GetAttribute('AvatarBusyFixture')end,push=function(p,k,d)messages[#messages+1]={p=p,k=k,d=d}end})
local function add(id,rig)local p=BCPlayer(id,rig);BC_PLAYERS[#BC_PLAYERS+1]=p;return p end
local function tick(n)clock=clock+(n or .1);G.Tick()end
local function start(n)
 local out={};for i=1,n do out[i]=add(100+i);assert(G.Join(out[i]))end
 tick(0);tick(12);assert(G.round and G.round.phase=='COUNTDOWN');tick(5);assert(G.round.phase=='ACTIVE');return table.unpack(out)
end
local function at(p,v)local s=G.round.players[p];s.char:PivotTo(CFrame.new(v-s.root.Position)*s.char:GetPivot());return s end
local function button(p)at(p,arena.Cap.Position+Vector3.new(0,2.4,0));return G.button.Press(p)end
'''
case('T01_one_player_waits_then_explicit_training_ends_at_90_seconds',BASE+r'''
local p=add(1);assert(G.Join(p));tick(50);assert(not G.round and G.queue.Count()==1 and not G.prep)
assert(not G.Training(p));assert(G.Leave(p));assert(G.Training(p));tick(5);local r=G.round;assert(r.training)
tick(89.9);assert(r.phase=='ACTIVE');tick(.1);assert(r.phase=='RESULTS'and not r.players[p].winner)
return 'one player never auto-starts competitive play; explicit solo training runs exactly 90 seconds with no victory bonus'
''')
case('T02_two_players_timing_button_and_original_avatar_are_preserved',BASE+r'''
local p,q=start(2);local r=G.round;local s=r.players[p];local char=s.char;assert(p.Character==char and s.hum.Health==100 and s.hum.WalkSpeed==16)
assert(r.deadline-clock==150 and G.button.state=='REPOSICIONANDO');tick(3.9);assert(G.button.state~='DISPONÍVEL');tick(.1);assert(G.button.state=='DISPONÍVEL')
assert(button(p));assert(s.score==1 and s.weapon and s.weapon.ammo==3);assert(p.Character==char)
tick(7.9);assert(G.button.state~='DISPONÍVEL');tick(.1);assert(G.button.state=='DISPONÍVEL')
return '12-second FIFO preparation, 5-second freeze, 150-second clock, first button after 4 seconds and next after 8; entry never recreates the selected avatar'
''')
case('T03_T04_eight_slots_and_ninth_waits_in_fifo_order',BASE+r'''
local all={};for i=1,9 do all[i]=add(i);assert(G.Join(all[i]))end
assert(not G.queue.Add(all[1]));tick(0);tick(12);local n=0;for p in pairs(G.round.players)do n=n+1;assert(p.UserId<=8)end
assert(n==8 and G.queue.Position(all[9])==1 and all[9]:GetAttribute('BC_Queued'))
assert(all[1]:GetAttribute('BC_MatchId')and not all[9]:GetAttribute('BC_MatchId'))
return 'exactly eight distinct spawns and participants; the ninth keeps first position for the following round'
''')
case('T05_T06_first_valid_prompt_wins_dead_far_outsider_and_late_presses_fail',BASE+r'''
local p,q=start(2);local outsider=add(3);tick(4);at(p,arena.Cap.Position+Vector3.new(0,2.4,0));at(q,arena.Cap.Position+Vector3.new(0,2.4,0));assert(not G.button.Press(outsider))
assert(G.button.Press(p));assert(not G.button.Press(q));assert(G.round.players[p].score==1 and G.round.players[q].score==0)
tick(8);at(q,C.Center+Vector3.new(40,5,0));assert(not G.button.Press(q));G.Eliminate(p);assert(not button(p));clock=G.round.deadline;assert(not button(q))
return 'atomic server claim gives only one point; outsiders, eliminated players, distant characters and packets at the expired deadline cannot press'
''')
case('button_timeout_moves_without_points_and_never_repeats_position',BASE+r'''
local p,q=start(2);tick(4);local index=G.button.lastIndex;local serial=G.button.serial
tick(15);assert(G.button.serial==serial+1 and G.button.lastIndex~=index);assert(G.round.players[p].score==0 and G.round.players[q].score==0)
return 'untouched button relocates after 15 seconds without drawing an effect or awarding a point'
''')
case('T07_T08_damage_cadence_ammo_raycast_roster_and_shield_are_server_owned',BASE+r'''
local p,q=start(2);local outsider=add(500);local r=G.round;local s=r.players[p];local t=r.players[q]
at(p,Vector3.new(0,arena.Top+4,30));at(q,Vector3.new(0,arena.Top+4,15))
assert(G.combat.Grant(r,s,'E01'));local token=s.weapon.token
assert(not G.combat.Shoot(r,p,{token=token,direction=Vector3.new(0/0,0,0)}));assert(s.weapon.ammo==3)
assert(not G.combat.Shoot(r,p,{token='forged',direction=Vector3.new(0,0,-1)}));assert(s.weapon.ammo==3)
BC_RAY=function()return{Instance=outsider.Character.HumanoidRootPart,Position=outsider.Character.HumanoidRootPart.Position}end
assert(G.combat.Shoot(r,p,{token=token,direction=Vector3.new(0,0,-1)}));assert(outsider.Character.Humanoid.Health==100)
BC_RAY=function()return{Instance=t.root,Position=t.root.Position}end
assert(not G.combat.Shoot(r,p,{token=token,direction=Vector3.new(0,0,-1)}));tick(.901)
t.shield=clock+12;assert(G.combat.Shoot(r,p,{token=token,direction=Vector3.new(0,0,-1)}));assert(t.hum.Health==100 and t.shield==0)
tick(.901);assert(G.combat.Shoot(r,p,{token=token,direction=Vector3.new(0,0,-1)}));assert(t.hum.Health==65 and not s.weapon)
assert(not G.combat.Shoot(r,p,{token=token,direction=Vector3.new(0,0,-1)}))
return 'NaN/forged token/cadence rejected; only same-round ray hits damage, shield consumes one event, ammo is exactly three and the server deletes the spent tool'
''')
case('T09_nuke_single_target_four_seconds_shield_and_no_reselection',BASE+r'''
local p,q,third=start(3);local r=G.round;local effect=C.Effects[3]
r.players[q].shield=clock+12;rng.integer=1;G.effects.Execute(r,p,effect);local target=r.nuclear.target;assert(target==q.UserId and r.nuclear.name==q.DisplayName and r.nuclearUsed)
tick(3.9);assert(r.players[q].alive);tick(.1);assert(r.players[q].alive and r.players[q].shield==0 and r.players[third].hum.Health==100)
G.effects.Execute(r,p,effect);q.Parent=nil;G.Eliminate(q);tick(4);assert(r.players[third].alive and r.players[third].hum.Health==100)
return 'one fixed marked target, four-second warning, shield blocks the targeted elimination; departure cancels rather than selecting a different victim'
''')
case('effect_draw_has_exact_weights_filters_targets_and_avoids_repeats',BASE+r'''
local p,q=start(2);local r=G.round;local list,total=Modules.BC_EffectRegistry.Eligible(r,p);assert(#list==12 and total==100)
local sum=0;for _,e in ipairs(list)do rng.draw=(sum+.01)/100;assert(Modules.BC_EffectRegistry.Draw(r,p,rng).id==e.id);sum=sum+e.weight end
r.lastEffect='E01';r.nuclearUsed=true;list,total=Modules.BC_EffectRegistry.Eligible(r,p);assert(#list==10 and total==82)
G.Eliminate(q);list,total=Modules.BC_EffectRegistry.Eligible(r,p)
for _,e in ipairs(list)do assert(not e.target and e.id~='E01')end;assert(total==52)
return 'all cumulative weight intervals map to the documented 100%; consecutive repeat and reused nuke excluded, solo target effects removed with proportional remaining weights'
''')
case('freeze_slow_speed_jump_heal_and_timers_recalculate_and_restore',BASE+r'''
local p,q=start(2);local r=G.round;local s=r.players[p];local t=r.players[q]
G.effects.Execute(r,p,C.Effects[5]);assert(s.hum.WalkSpeed==24);G.effects.Execute(r,p,C.Effects[10]);assert(s.hum.WalkSpeed==9)
G.effects.Execute(r,q,C.Effects[4]);assert(s.hum.WalkSpeed==0);tick(3);assert(s.hum.WalkSpeed==9);tick(2);assert(s.hum.WalkSpeed==24);tick(4);assert(s.hum.WalkSpeed==16)
s.hum.Health=60;G.effects.Execute(r,p,C.Effects[11]);assert(s.hum.Health==100);local score=s.score;G.effects.Execute(r,p,C.Effects[11]);assert(s.hum.Health==100 and s.score==score)
G.effects.Execute(r,p,C.Effects[8]);assert(math.abs(s.hum.JumpPower-50*math.sqrt(1.8))<.001);tick(8);assert(s.hum.JumpPower==50)
s.original.usePower=false;G.effects.Execute(r,p,C.Effects[8]);assert(s.hum.JumpHeight==7.2*1.8 and not s.hum.UseJumpPower);tick(8);assert(s.hum.JumpHeight==7.2)
return 'freeze > slow > speed compose and expire correctly; heal caps at 100, superjump respects both native jump systems and is fully temporary'
''')
case('swap_checks_safety_and_grants_only_short_damage_immunity',BASE+r'''
local p,q=start(2);local r=G.round;local s=r.players[p];local t=r.players[q]
local a,b=s.root.Position,t.root.Position;G.effects.Execute(r,p,C.Effects[7]);assert((s.root.Position-b).Magnitude<.001 and(t.root.Position-a).Magnitude<.001)
assert(not G.combat.Damage(r,q,p,35,'weapon'));tick(.75);assert(G.combat.Damage(r,q,p,35,'weapon')and s.hum.Health==65)
at(q,Vector3.new(100,arena.Top+4,0));a=s.root.Position;G.effects.Execute(r,p,C.Effects[7]);assert((s.root.Position-a).Magnitude<.001)
return 'safe destinations swap exact character transforms with 0.75-second immunity; unsafe outside destination cancels without replacement effect'
''')
case('foam_detonates_in_1_8_seconds_can_hit_self_and_zero_survivors_has_no_winner',BASE+r'''
local p,q=start(2);local r=G.round;local s=r.players[p];local t=r.players[q]
at(p,Vector3.new(30,arena.Top+3,30));at(q,Vector3.new(32,arena.Top+3,30));s.hum.Health=40;t.hum.Health=40
BC_RAY=function()return{Position=Vector3.new(31,arena.Top,30)}end
assert(G.combat.Grant(r,s,'E02'));local token=s.weapon.token;assert(G.combat.Shoot(r,p,{token=token,direction=Vector3.new(1,0,0)}))
tick(1.79);assert(s.alive and t.alive);tick(.02);assert(not s.alive and not t.alive and r.phase=='RESULTS'and r.noWinner)
assert(s.score==2 and not s.winner and not t.winner)
return 'foam is not immediate, uses the server 1.8-second fuse and nine-stud radius, includes self; all victims resolve before zero-survivor winner calculation'
''')
case('T10_T11_disconnect_reset_eliminated_spectator_cannot_rejoin_same_round',BASE+r'''
local p,q,third=start(3);local r=G.round;local old=r.players[p].char;local new=Services.Players:CreateHumanoidModelFromDescriptionAsync(InitialDescription,Enum.HumanoidRigType.R15);new.Parent=workspace;p.Character=new;p.CharacterAdded:Fire(new)
assert(not r.players[p].alive and p:GetAttribute('BC_Live')==false);assert(not G.Join(p));assert(not G.combat.Shoot(r,p,{}))
assert(G.Leave(q));assert(not q:GetAttribute('BC_MatchId'));tick(.1);assert(r.phase=='RESULTS'and r.players[third].winner)
return 'reset and leave eliminate, spectator remains ineligible, chosen avatar runtime may respawn without arena reentry; last connected survivor wins'
''')
case('T12_clock_winners_use_survivor_score_before_plus_five_and_no_auto_queue',BASE+r'''
local p,q,third=start(3);local r=G.round;r.players[p].score=4;r.players[q].score=4;r.players[third].score=30;G.Eliminate(third)
clock=r.deadline;G.Tick();assert(r.phase=='RESULTS'and r.players[p].winner and r.players[q].winner and not r.players[third].winner)
assert(r.players[p].score==9 and r.players[q].score==9 and r.players[third].score==30)
assert(G.Continue(p));tick(10);assert(not G.round and G.queue.Count()==1 and G.queue.Position(p)==1 and not q:GetAttribute('BC_Queued'))
return 'expired clock chooses tied surviving leaders before +5 bonus, ignores a dead higher score; only explicit Continue opts into the next FIFO queue'
''')
case('T13_T14_T15_return_cleanup_two_rounds_gear_and_r6_r15_identity',BASE+r'''
local p=add(1,'R6');local q=add(2);local original=p.Character;local pivot=original:GetPivot();local pack=p:FindFirstChildOfClass('Backpack');local item=Instance.new('Tool');item.Name='ExistingCatalogTool';item.Parent=pack
assert(G.Join(p)and G.Join(q));tick(0);tick(12);tick(5);local r=G.round;assert(item.Parent~=pack and p.Character==original)
G.effects.Execute(r,p,C.Effects[5]);assert(G.combat.Grant(r,r.players[p],'E01'));assert(G.Leave(p));assert(p.Character==original and item.Parent==pack)
assert(original.Humanoid.WalkSpeed==16 and not p:GetAttribute('BC_MatchId')and not p.focus and(original:GetPivot().Position-pivot.Position).Magnitude<.001)
G.Leave(q);tick(.1);tick(10);assert(not G.round);assert(G.Join(p)and G.Join(q));tick(0);tick(12);tick(5)
assert(G.round.id~=r.id and G.round.players[p].score==0 and not G.round.players[p].weapon and G.button.lastIndex==0)
G.Shutdown();assert(item.Parent==pack and not p:GetAttribute('BC_MatchId')and not q:GetAttribute('BC_MatchId'))
return 'R6/R15 keep the same character and body, stashed catalog tool returns, effects/camera focus/attributes clear and the second round has a fresh identifier and no prior powers'
''')
case('T16_effect_exception_cannot_deadlock_button_or_reverse_earned_point',BASE+r'''
local p,q=start(2);tick(4);local r=G.round;G.effects.Execute=function()error('fixture effect failure')end
assert(button(p));assert(r.players[p].score==1 and G.button.state=='REPOSICIONANDO');tick(8);assert(G.button.state=='DISPONÍVEL')
return 'injected execution error is logged, the accepted press retains +1 and the next button becomes available after eight seconds'
''')
case('T17_other_room_members_cannot_join_and_an_escaping_avatar_is_returned_inside',BASE+r'''
local p=add(1);p:SetAttribute('ACP_BoardWaiting','ROOM');assert(not G.Join(p));p:SetAttribute('ACP_BoardWaiting',nil);p:SetAttribute('ACP_TrucoRoom','TRUC');assert(not G.Join(p));p:SetAttribute('ACP_TrucoRoom',nil)
local q=add(2);assert(G.Join(p)and G.Join(q));tick(0);tick(12);tick(5);local s=G.round.players[p];at(p,Vector3.new(500,arena.Top+4,500));tick(.1);assert(arena.Inside(s.root.Position,1))
return 'cross-game membership is exclusive; out-of-arena movement is corrected to the last valid transform rather than falling through the catalog or attacking outsiders'
''')
case('wave_heal_blackout_and_weapon_expiry_have_bounded_effects',BASE+r'''
local p,q=start(2);local r=G.round;local s=r.players[p];local t=r.players[q]
at(p,Vector3.new(30,arena.Top+4,30));at(q,Vector3.new(35,arena.Top+4,30));local before=t.root.Position
G.effects.Execute(r,p,C.Effects[9]);assert(t.hum.Health==100 and(t.root.Position-before).Magnitude>0 and arena.Inside(t.root.Position,1))
at(p,Vector3.new(30,arena.Top+4,30));at(q,Vector3.new(43,arena.Top+4,30));G.effects.Execute(r,p,C.Effects[9]);assert(arena.Inside(t.root.Position,1))
G.effects.Execute(r,p,C.Effects[12]);assert(G.Snapshot(p).blackout==5);tick(5);assert(G.Snapshot(p).blackout==0)
assert(G.combat.Grant(r,s,'E01'));local tool=s.weapon.tool;tick(12);assert(not s.weapon and tool.destroyed)
assert(G.combat.Grant(r,s,'E02'));tick(10);assert(not s.weapon and #G.combat.pending==0)
return 'wave displaces within the walls with zero damage; blackout is a five-second per-match state and unused weapons expire after 12/10 seconds'
''')
case('nuke_kill_points_and_environmental_death_do_not_leak_rewards',BASE+r'''
local p,q,third=start(3);local r=G.round;rng.integer=1;G.effects.Execute(r,p,C.Effects[3]);tick(4)
assert(not r.players[q].alive and r.players[p].score==2 and r.players[third].hum.Health==100)
r.players[third].hum.Health=0;tick(.1);assert(r.phase=='RESULTS'and r.players[p].winner and r.players[p].score==7)
return 'nuke awards exactly +2 for its one enemy; unrelated environmental death gives no kill points and survivor bonus is calculated only at the end'
''')
case('leaving_preparation_cancels_start_and_queue_never_overwrites_catalog_inventory',BASE+r'''
local p,q=add(1),add(2);local tool=Instance.new('Tool');tool.Parent=p:FindFirstChildOfClass('Backpack');local char=p.Character
assert(G.Join(p)and G.Join(q));tick(0);assert(G.prep);G.Leave(q);tick(12)
assert(not G.round and not G.prep and G.queue.Count()==1 and p.Character==char and tool.Parent==p:FindFirstChildOfClass('Backpack'))
return 'queue and cancelled preparation do not move the avatar, stash gear, alter health, or persist any minigame score'
''')
case('inaccessible_button_is_logged_disabled_and_relocated_to_a_clear_site',BASE+r'''
local p,q=start(2);tick(4);local old=G.button.lastIndex;local block=Instance.new('Part');block.Name='UnexpectedObstacle';block.Size=Vector3.new(5,5,5);block.CFrame=CFrame.new(arena.ButtonPositions[old]);block.CanCollide=true;block.Parent=arena.Model
local warned={};warn=function(message)warned[#warned+1]=message end;tick(.6)
assert(G.button.state=='DISPONÍVEL'and G.button.lastIndex~=old and #warned>=1);assert(G.round.players[p].score==0)
return 'a new collidable obstacle disables the old button, reports its precise location and selects a different reachable location without awarding points'
''')
case('native_avatar_must_finish_loading_before_queue_or_round_entry',BASE+r'''
local p,q=add(1),add(2);p:SetAttribute('AvatarBusyFixture',true);local ok,why=G.Join(p);assert(not ok and why:find('avatar',1,true))
p:SetAttribute('AvatarBusyFixture',nil);assert(G.Join(p)and G.Join(q));tick(0);q:SetAttribute('AvatarBusyFixture',true);tick(12)
assert(not G.round and G.queue.Position(p)==1 and not p:GetAttribute('BC_MatchId')and not q:GetAttribute('BC_Queued'))
return 'queue entry waits for native avatar confirmation; an in-flight body edit at transport time cancels that entry without replacing or stranding either avatar'
''')
case('catalog_tools_survive_a_missing_native_backpack_during_respawn',BASE+r'''
local p,q=add(1),add(2);local tool=Instance.new('Tool');tool.Name='OriginalGear';tool.Parent=p.Backpack
assert(G.Join(p)and G.Join(q));tick(0);tick(12);tick(5);local s=G.round.players[p]
s.hum.Health=0;p.Backpack=nil;assert(G.Leave(p));assert(not tool.destroyed and tool.Parent and tool.Parent.Parent==Services.ServerStorage and p:GetAttribute('BC_Returning'))
p.Character=Services.Players:CreateHumanoidModelFromDescriptionAsync(InitialDescription,Enum.HumanoidRigType.R15);p.Character.Parent=workspace;p.Backpack=Instance.new('Backpack');p.ChildAdded:Fire(p.Backpack);p.CharacterAdded:Fire(p.Character);flush()
assert(tool.Parent==p.Backpack and not tool.destroyed and not p:GetAttribute('BC_Returning'))
return 'an absent respawn backpack never deletes original catalog tools; a native backpack/character event completes the pending return and releases the entry lock'
''')
BOOT=BASE[:BASE.index('local C=Modules.BC_Config')]
case('actual_server_endpoints_rate_limits_duplicate_guard_and_recovery_reconnect_button',BOOT+r'''
Random={new=BCRandom};local p=BCPlayer(1);local q=BCPlayer(2);BC_PLAYERS={p,q}
Modules['09B5_AVATAR_RUNTIME']={Description=function(player)return player.Character.Humanoid,player.Character.Humanoid:GetAppliedDescription()end}
local runtime=Instance.new('ModuleScript');runtime.Name='09B5_AVATAR_RUNTIME';runtime.Parent=rep
local engines={};local factory=Modules.BC_RoundManager.New;Modules.BC_RoundManager.New=function(ctx)local g=factory(ctx);engines[#engines+1]=g;return g end
script=Instance.new('Script');script.Name='BC_Server';script.Parent=rep
'''+src('BC_Server')+r'''
local rem=rep.PracaKit.Remotes;local rpc=rem.BC_Request;local fire=rem.BC_Fire;local function call(player,a)return rpc.OnServerInvoke(player,a,{})end
assert(rep.PracaKit:GetAttribute('BC_ServerRunning')and #engines==1)
assert(call(p,'join').ok and not call(p,'join').ok and call(q,'join').ok);assert(not call(p,'fire').ok)
local function tick(seconds)advance60(seconds);Services.RunService.Heartbeat:Fire(.2)end
tick(.1);tick(12);tick(5);tick(4);local g=engines[1];local a=workspace.BC_Arena;local st=g.round.players[p];st.char:PivotTo(CFrame.new(a.BC_Button.Position+Vector3.new(0,2.4,0)-st.root.Position)*st.char:GetPivot());a.BC_Button.BC_Press.Triggered:Fire(p);assert(st.score==1)
fire.OnServerEvent:Fire(p,{token='forged',direction=Vector3.new(0,0,-1),damage=10000});assert(q.Character.Humanoid.Health==100)
g.Tick=function()error('injected server tick fault')end;tick(.2);assert(#engines==2 and not p:GetAttribute('BC_MatchId')and a.destroyed)
tick(.3);assert(call(p,'join').ok and call(q,'join').ok);tick(.1);tick(12);tick(5);tick(4)
g=engines[2];a=workspace.BC_Arena;st=g.round.players[p];st.char:PivotTo(CFrame.new(a.BC_Button.Position+Vector3.new(0,2.4,0)-st.root.Position)*st.char:GetPivot());a.BC_Button.BC_Press.Triggered:Fire(p);assert(st.score==1)
local function duplicate()
'''+src('BC_Server')+r'''
end;duplicate();assert(#engines==2)
return 'actual bootstrap wires native prompt/RPC/event contracts, rate-limits requests, ignores forged damage, rejects duplicate servers and rebuilds a connected working button after an injected tick failure'
''')
(HERE/'chaos_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
