from test_support import *
SIZES="{{320,568,0,0,0},{390,844,0,0,34},{568,320,0,0,0},{667,375,0,0,0},{851,392,44,44,21},{1920,1080,0,0,0}}"
MOTION=DATA+module('08B6_AVATAR_MOVEMENT')
case('different_body_height_preserves_floor_and_discards_tilt_and_momentum',MOTION+r'''
local motion=Modules['08B6_AVATAR_MOVEMENT'];local old=pl.Character;old.PrimaryPart=old.HumanoidRootPart;old.Humanoid.HipHeight=2;old:PivotTo(CFrame.new(4,3,8)*CFrame.Angles(.9,.7,.4))
local d=HUM:GetAppliedDescription();local new=Services.Players:CreateHumanoidModelFromDescriptionAsync(d,Enum.HumanoidRigType.R15);new.Humanoid.HipHeight=6
local expected=6+new.HumanoidRootPart.Size.Y*.5
local a=Instance.new('Accessory');a.Parent=new;local handle=Instance.new('Part');handle.Size=Vector3.new(100,100,100);handle.Anchored=true;handle.CanCollide=true;handle.Parent=a
local joint=Instance.new('AnimationConstraint');joint.IsKinematic=false;joint.Parent=new;new.HumanoidRootPart.AssemblyLinearVelocity=Vector3.new(0,-90,200)
assert(motion.Place(new,old));assert(math.abs(new.HumanoidRootPart.Position.Y-(expected+.08))<.001);assert(new.HumanoidRootPart.CFrame.UpVector.Y>.999)
assert(new.HumanoidRootPart.AssemblyLinearVelocity.Magnitude==0 and new.HumanoidRootPart.AssemblyAngularVelocity.Magnitude==0)
assert(joint.IsKinematic and not handle.CanCollide and not handle.Anchored and handle.Massless)
assert(motion.Clearance(new)==expected and Raycasts65[1].params.RespectCanCollide)
new.Humanoid.HipHeight=0/0;assert(not motion.Prepare(new))
return 'native support height adapts to a taller body, a huge suit is not mistaken for a leg, old pitch/roll/velocity are discarded and invalid native height is rejected'
''')
case('airborne_swap_keeps_foot_height_and_settle_repairs_only_penetration',MOTION+r'''
local m=Modules['08B6_AVATAR_MOVEMENT'];local old=pl.Character;old.PrimaryPart=old.HumanoidRootPart;old:PivotTo(CFrame.new(0,30,0));NoFloor65=true
local d=HUM:GetAppliedDescription();local fresh=Services.Players:CreateHumanoidModelFromDescriptionAsync(d,Enum.HumanoidRigType.R15);fresh.Humanoid.HipHeight=4;assert(m.Place(fresh,old));assert(math.abs(fresh.HumanoidRootPart.Position.Y-(30+m.Clearance(fresh)-m.Clearance(old)))<.001)
NoFloor65=false;fresh.Parent=workspace;fresh:PivotTo(CFrame.new(0,4,0));local notes=0;m.Settle(fresh,function()return true end,function()notes=notes+1 end);advance(1.1);assert(math.abs(fresh.HumanoidRootPart.Position.Y-(m.Clearance(fresh)+.08))<.001 and notes==1)
local before=fresh.HumanoidRootPart.Position.Y;m.Settle(fresh,function()return false end,function()error('stale avatar')end);advance(1.1);assert(fresh.HumanoidRootPart.Position.Y==before)
return 'an airborne swap does not snap to a floor; delayed checks lift penetration once and ignore a superseded character'
''')
case('runtime_rebuild_confirms_native_appearance_and_rolls_back_failed_geometry',MOTION+module('09B7_LAST_AVATAR')+module('09B5_AVATAR_RUNTIME')+r'''
local m=Modules['09B5_AVATAR_RUNTIME'];pl.Character.PrimaryPart=pl.Character.HumanoidRootPart;pl.Character:PivotTo(CFrame.new(0,3,0));pl:SetAttribute('ACP_PersonalSpeed',16)
local d=HUM:GetAppliedDescription();d.Torso=987;local result=m.Apply(pl,d,'R15');assert(result.applied and pl.Character.Humanoid.WalkSpeed==16);flush()
local current=pl.Character;d.Torso=988;WrongStructure=true;local ok=pcall(m.Apply,pl,d,'R15');assert(not ok and pl.Character==current and not current.destroyed)
return 'actual runtime uses placement in a verified body rebuild; an incomplete later native rig is rejected without replacing the last good character'
''')
case('pose_playback_keeps_modern_joints_kinematic_and_leaves_animator_transform',module('07P3_POSE_EDITOR')+r'''
local model=Instance.new('Model');model.Parent=workspace;local a=Instance.new('Part');a.Name='UpperTorso';a.Parent=model;local b=Instance.new('Part');b.Name='RightUpperArm';b.Parent=model
local j=Instance.new('AnimationConstraint');j.Name='RightShoulder';j.Part0=a;j.Part1=b;j.Parent=model
local p=Modules['07P3_POSE_EDITOR'].Bind(model);p.Begin();assert(p.Set('RightShoulder',3,30));p.SetPlayback(true);assert(j.IsKinematic)
local animated=CFrame.Angles(.2,.4,.1);j.Transform=animated;p.Apply();assert(j.Transform==animated)
p.SetPlayback(false);assert(j.IsKinematic);p.Destroy();assert(j.IsKinematic)
return 'pose and emote playback use native kinematic constraints; playback stops editor writes so the Animator can move the same copy'
''')
STUDIO=THEME+DATA+PREVIEW+module('07P0_STUDIO_PRESETS')+module('07P6_STUDIO_SETS')+module('07P3_POSE_EDITOR')+module('07P2_STUDIO_AVATAR')+"emoteRpc66()\n"
case('studio_can_enter_before_editor_and_emote_reuse_does_not_rebuild',STUDIO+r'''
local studio=Modules['07P2_STUDIO_AVATAR'];S.Current=nil;assert(studio.Enter());local old=studio.Model
fixture60(123456,'Dance','EmoteAnimation');assert(studio.PlayEmote(123456));local ready=studio.Model;assert(ready==old and studio.Track and studio.Track.Length>0)
studio.StopEmote();assert(studio.PlayEmote(123456));assert(studio.Model==ready and studio.Pose.Playback)
studio.Exit();assert(not studio.Model and not studio.Folder and workspace.CurrentCamera.CameraType==Enum.CameraType.Custom)
return 'Photo Mode can use the actual map avatar before the catalog is opened; a loaded emote replays on the same model and closing restores the camera'
''')
case('emote_rejection_and_zero_length_keep_current_copy_and_pose',STUDIO+r'''
local studio=Modules['07P2_STUDIO_AVATAR'];assert(studio.Enter());local old=studio.Model;fixture60(123456,'Dance','EmoteAnimation')
RejectEmote66=true;local ok,err=studio.PlayEmote(123456);assert(not ok and err:find('rejected',1,true)and studio.Model==old and not old.destroyed)
RejectEmote66=false;EmoteZeroLength65=true;local t=os.clock();assert(not studio.PlayEmote(123456));assert(os.clock()-t>=5 and studio.Model==old)
studio.Exit()
return 'native refusal and a track which never loads cannot produce a false success or destroy the previous avatar/pose; track loading has a bounded deadline'
''')
case('fallback_starts_with_broken_animate_then_yields_to_native_tracks',DATA+r'''
pl.Character:SetAttribute('ACP_AvatarManaged',true);local animate=Instance.new('LocalScript');animate.Name='Animate';animate.Parent=pl.Character
local a=Instance.new('Animator');a.Parent=HUM
'''+src('09C11_AVATAR_CHARACTER')+r'''
flush();advance60(2);HUM.Running:Fire(200);assert(#a.loaded>0);local fallback=a.loaded[#a.loaded];assert(fallback.IsPlaying and fallback.speed<=1.6)
local native=track65('nativeWalk');native.Priority=Enum.AnimationPriority.Movement;native:Play();a.playing[#a.playing+1]=native;Services.RunService.Heartbeat:Fire(.3);assert(not fallback.IsPlaying)
return 'presence of a broken Animate script no longer blocks fallback; playback rate is bounded and real native animation takes over without competing tracks'
''')
case('outfit_budget_prioritizes_both_garments_and_rejects_hair_only',THEME+DATA+module('09I0_ASSISTANT_CONFIG')+module('09I0_ASSISTANT_CONFIG')+module('09I1_ASSISTANT_ACCOUNTS')+module('09I13_OUTFIT_SEARCH')+module('09I3_OUTFIT_BUILDER')+r'''
local emptyPants=false
function Services.AvatarEditorService:SearchCatalogAsync(params)
 local k=params.AssetTypes[1].Name;if k=='Pants'and emptyPants then return{GetCurrentPage=function()return{}end}end
 local id=({HairAccessory=111,Shirt=112,Pants=113,Hat=114})[k];local v=fixture60(id,'emo '..k,k);v.Price=k=='Shirt'and 10 or k=='Pants'and 10 or 70;NativeItems60['Asset:'..id].Price=v.Price;return{GetCurrentPage=function()return{deep(v)}end}
end
Modules['08B4_AVATAR_LOAD'].Create=function()return Instance.new('Model')end
local b=Modules['09I3_OUTFIT_BUILDER'];local opts=b.Options({budget=100,keep=false},'Normal');local rows=assert(b.Build(pl,'emo',opts,S.Current,function()end,function()return true end))
assert(rows[1].complete and rows[1].body.props.Shirt==112 and rows[1].body.props.Pants==113 and rows[1].total<=100)
emptyPants=true;assert(not b.Build(pl,'emo missing',opts,S.Current,function()end,function()return true end))
return 'a 100-Robux search buys shirt and pants before a 70-Robux optional piece; an unavailable lower garment cannot be presented as a complete outfit'
''')
DEST=THEME+module('07UI_PAN_GRID')+module('09C12_DESTINATION_BROWSER')
case('destination_xy_two_rows_mouse_drag_does_not_activate_and_close_fits',DEST+r'''
local D=Modules['07UI_DESIGN_SYSTEM'];local area=D.New('Frame',{Size=UDim2.fromOffset(900,420)},pg);local feed={}
for i=1,80 do feed[i]={key='Game:'..i,item={Id=i,Name='Native '..i,ItemType='Game',description='desc'}}end
local u=Modules['09C12_DESTINATION_BROWSER'].Build(area,{toast=function()end,call=function(a)if a=='DestinationFeed'then return{items=feed,finished=true}elseif a=='DestinationCheck'then return feed[1].item end end});u.Open('Game');flush()
assert(u.Grid.CanvasSize.X.Offset>u.Grid.AbsoluteSize.X and u.Grid.CanvasSize.Y.Offset>u.Grid.AbsoluteSize.Y)
local first=named(u.Grid,'Destination_1');local second=named(u.Grid,'Destination_2');assert(first.Position.X.Offset==second.Position.X.Offset and second.Position.Y.Offset>first.Position.Y.Offset)
local start=u.Grid.AbsolutePosition+Vector2.new(160,40);local io={UserInputType=Enum.UserInputType.MouseButton1,Position=start};Services.UserInputService.InputBegan:Fire(io)
Services.UserInputService.InputChanged:Fire({UserInputType=Enum.UserInputType.MouseMovement,Position=start-Vector2.new(100,20)});Services.UserInputService.InputEnded:Fire(io)
assert(u.Grid.CanvasPosition.X>=90);first.Activated:Fire();assert(not named(u.Root,'DestinationShade').Visible)
advance60(.3);first.Activated:Fire();flush();assert(named(u.Root,'DestinationShade').Visible);inside(named(u.Root,'CloseDestination'),named(u.Root,'DestinationDetails'))
return '80 real destination fixtures have a true two-axis canvas and two visible rows; mouse dragging scrolls without opening a card and the details close stays reachable'
''')
LOBBY=THEME+module('07K6_CARD_CATALOG')+module('07K7_CARD_STYLES')+module('07H5_TRUCO_SETUP')+module('07H1_GAME_LOBBY')
case('game_lobby_modes_and_all_bot_profiles_fit_six_safe_geometries',LOBBY+r'''
local D=Modules['07UI_DESIGN_SYSTEM'];local gui=D.New('ScreenGui',{IgnoreGuiInset=true},pg);local u=Modules['07H1_GAME_LOBBY'].Build(gui);u.Root.Visible=true
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0
 for _,game in ipairs({'Truco','Xadrez','Damas'})do u.SetGame(game);u.Layout();inside(u.Close,u.Root)
  for _,b in pairs(u.GameButtons)do inside(b,u.Root)end
  for _,b in pairs(u.PlayButtons[game])do inside(b,u.Hero);assert(b.AbsoluteSize.Y>=44 and b.AbsoluteSize.X>=44)end
  u.Mode='Practice';u.Options.Visible=true
  for _,difficulty in ipairs({'FACIL','MEDIO','DIFICIL'})do u.Difficulty=difficulty;u.Layout();inside(u.Bot,u.Options);inside(u.OptionsClose,u.Options)
   for _,b in pairs(u.DiffButtons)do inside(b,u.Options);assert(b.AbsoluteSize.Y>=44 and b.AbsoluteSize.X>=44);assert(not intersects(b,u.Bot),'bot action overlaps profile')end
  end
 end
end
return 'all three game tabs, four clear entry actions and each selected bot profile retain reachable touch targets in portrait, landscape and desktop'
''')
SETTINGS=THEME+DATA+module('07G6_WORLD_DETAILS')+module('07G4_WORLD_SCENERY')+module('07G2_LOCAL_WORLDS')+module('07G1_HUB_SETTINGS')
case('compact_settings_home_world_close_and_gear_touch_targets_fit',SETTINGS+r'''
local D=Modules['07UI_DESIGN_SYSTEM'];local gui=D.New('ScreenGui',{IgnoreGuiInset=true},pg);local root=D.New('Frame',{Size=UDim2.fromScale(1,1)},gui)
pl:SetAttribute('ACP_LegacyAIPlan',true);local u=Modules['07G1_HUB_SETTINGS'].Build(root,pg,function()end,function()end);u.Panel.Visible=true
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;u.Panel:GetPropertyChangedSignal('Visible'):Fire();u.Layout()
 inside(u.Panel,root);inside(u.Close,u.Panel);assert(u.Close.AbsoluteSize.X>=44);assert(u.Panel.AbsoluteSize.X<=540)
 for _,b in ipairs(u.Body:GetChildren())do if b:IsA('GuiButton')then inside(b,u.Body);assert(b.AbsoluteSize.Y>=44)end end
 named(u.Body,'ChangeWorld').Activated:Fire();u.Layout();for _,b in ipairs(u.Body:GetChildren())do if b:IsA('GuiButton')then inside(b,u.Body);assert(b.AbsoluteSize.Y>=44)end end
end
return 'settings remains compact with a reachable close, readable categories and eight world choices without shrinking touch areas below 44px'
''')
MUSIC=THEME+module('07M1_MUSIC_UI')+r'''
local rpc=Instance.new('RemoteFunction');rpc.Name='ACP_MusicRequest';rpc.Parent=rep
local attempted={};local blockAll=false
function rpc:InvokeServer(a,d)
 if a=='load'then return{ok=true,data={volume=.4,saved={},last=0}}end
 if a=='search'then local rows={};for i=1,8 do rows[i]={id=1000+i,name='Music '..i}end;return{ok=true,data={items=rows,finished=true}}end
 if a=='audio'then attempted[#attempted+1]=d.id;return{ok=true,data={id=d.id,name='Music '..d.id}}end
 return{ok=true,data=true}
end
function Services.ContentProvider:PreloadAsync(list,callback)
 local s=list[1];local id=tonumber(s.SoundId:match('(%d+)'));s.IsLoaded=not blockAll and id~=1001 and id~=119682972981199;s.TimeLength=s.IsLoaded and 120 or 0
 if callback then callback(s.SoundId,{Name=s.IsLoaded and'Success'or'Failure'})end
end
'''
case('music_default_queue_skips_blocked_track_and_stops_after_bounded_failures',MUSIC+src('07M_MUSIC_CLIENT')+r'''
flush();local sound=Services.SoundService.ACP_PersonalMusic;assert(sound.IsPlaying and sound.SoundId=='rbxassetid://1002'and sound.Volume==.4);assert(#attempted==3)
return 'the real client does not stall forever on a blocked first recommendation; it tries the second suggested track and starts only after actual content readiness'
''')
case('music_all_recommendations_fail_without_false_playback_or_retry_loop',MUSIC+r'''
blockAll=true
'''+src('07M_MUSIC_CLIENT')+r'''
flush();local sound=Services.SoundService.ACP_PersonalMusic;assert(not sound.IsPlaying and #attempted==9);local u=pg.ACP_Music
assert(named(u,'ReloadAudio')and named(u,'MusicPopup'));local text='';for _,v in ipairs(u:GetDescendants())do if v:IsA('TextLabel')then text=text..v.Text end end;assert(text:find('pôde tocar',1,true))
return 'eight blocked default suggestions make exactly eight attempts, leave no audio playing and expose the reload/failure state instead of an endless loading loop'
''')
case('music_floating_controls_and_library_fit_six_safe_geometries',THEME+module('07M1_MUSIC_UI')+r'''
local u=Modules['07M1_MUSIC_UI'].Build(pl);u.Root.Visible=true
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;u.Layout();inside(u.Root,u.Root.Parent)
 for _,b in ipairs({u.Close,u.Minimize,u.Mute,u.Favorites})do inside(b,u.Root);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44)end
 assert(u.Library.Visible and u.List.AbsoluteSize.Y>=44,'library must show a row');assert(u.Track.Visible)
 u.Mini=true;u.Layout();inside(u.Close,u.Root);assert(not u.Content.Visible and not u.Library.Visible);u.Mini=false
end
return 'floating player keeps title, volume, library, close and minimization reachable; an actual library row remains visible even in phone landscape'
''')
case('destination_search_and_details_fit_actual_safe_store_surface',UI+DATA+module('07UI_PAN_GRID')+module('09C12_DESTINATION_BROWSER')+r'''
U.Root.Visible=true;U.SetWide(true);U.StoresArea.Visible=true
local row={key='Game:1',item={Id=1,Name='Own game',ItemType='Game',description='test'}}
local u=Modules['09C12_DESTINATION_BROWSER'].Build(U.StoresArea,{toast=function()end,call=function(a)if a=='DestinationFeed'then return{items={row},finished=true}else return row.item end end});u.Open('Game');flush()
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;U.Layout();U.StoresArea:GetPropertyChangedSignal('AbsoluteSize'):Fire();flush()
 for _,b in ipairs({u.Query,u.Search,u.FavoritesButton,u.Publish,u.More})do inside(b,u.Root);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44)end
 named(u.Grid,'Destination_1').Activated:Fire();flush();inside(named(u.Root,'CloseDestination'),named(u.Root,'DestinationDetails'));named(u.Root,'CloseDestination').Activated:Fire()
end
return 'destination search reuses the existing topbar space in landscape, preserves touch targets in the actual shop area and keeps details close on all six sizes'
''')
case('hud_removes_cryptic_restore_shortcut_and_retains_editor_launcher',SETTINGS+r'''
'''+src('07G_HUB_UI')+r'''
flush();local hud=pg.LimitedMarketHUD;assert(not named(hud,'Reset')and named(hud,'Avatar'))
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;Services.GuiService:GetPropertyChangedSignal('TopbarInset'):Fire();flush()
 local gear=named(hud,'Cfg');inside(gear,named(hud,'HudRoot'));assert(gear.AbsoluteSize.X>=44 and gear.AbsoluteSize.X<=48)
 gear.Activated:Fire();assert(named(hud,'SettingsPanel').Visible);named(hud,'CloseCfg').Activated:Fire()
end
return 'the ambiguous reset icon is absent from the HUD; editor remains accessible and a smaller real gear retains a 44px touch target on six sizes'
''')
SPONSOR=UI+DATA+module('07UI_PAN_GRID')+module('09C11_SPONSOR_FEED')+module('09C12_DESTINATION_BROWSER')+module('09C10_SPONSOR_DESIGN')+module('09C9_SPONSOR_PICKER')+module('09C5_UGC_STORES')+r'''
U.Root.Visible=true;U.SetWide(true);U.StoresArea.Visible=true;local nativeRows={};local actions={};local real=false
for i=1,60 do nativeRows[i]={Id=100+i,Name='Example '..i,ItemType='Asset',AssetType='Shirt',Price=i%5==0 and 0 or 5}end
function Services.AvatarEditorService:SearchCatalogAsync(p)assert(p.MinPrice==1 and not p.IncludeOffSale);return{IsFinished=true,GetCurrentPage=function()return deep(nativeRows)end}end
local function call(a,d)
 actions[#actions+1]={a=a,d=d}
 if a=='HighlightFeed'then return{items=real and{{item=deep(nativeRows[1]),key='Asset:101'}}or{},emptyGlobal=not real,finished=true}
 elseif a=='HighlightStatus'then return{nextAllowed=TIME60}
 elseif a=='HighlightCheck'then return deep(nativeRows[1])
 elseif a=='HighlightSubmit'then real=true;return{free=true}
 elseif a=='HighlightFavorite'then return{value=d.value}end
end
local ctl=Modules['09C5_UGC_STORES'].Init({U=U,A=A,call=call,toast=function()end,showItem=function()end,openAssistant=function()end});ctl.Search();flush()
'''
case('paid_sponsor_grid_scrolls_down_and_keeps_category_controls_safe',SPONSOR+r'''
assert(U.StoreGrid.ScrollingEnabled and U.StoreGrid.ScrollingDirection==Enum.ScrollingDirection.XY)
local cards=guiCards(U.StoreGrid);assert(cards==48,'paid cards '..cards)
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;U.SetWide(true);U.StoresArea:GetPropertyChangedSignal('AbsoluteSize'):Fire();flush()
 assert(U.StoreGrid.CanvasSize.Y.Offset>U.StoreGrid.AbsoluteSize.Y)
 for _,n in ipairs({'SponsorTab','AssistantTab','PublishHighlight','MoreHighlights'})do local b=named(U.StoresArea,n);inside(b,U.StoresArea);assert(b.AbsoluteSize.Y>=44 and b.AbsoluteSize.X>=44,n)end
 assert(not intersects(named(U.StoresArea,'SponsorTab'),U.StoreSearch))
end
named(U.StoresArea,'HighlightFilter_3').Activated:Fire();flush();assert(actions[#actions].d.group=='Roupas 3D')
assert(named(U.StoresArea,'Featured_Asset_101').ItemPrice.Text:find('Exemplo',1,true))
real=true;shop61.HighlightChanged.OnClientEvent:Fire();flush();assert(guiCards(U.StoreGrid)==48);assert(not named(U.StoresArea,'Featured_Asset_101').ItemPrice.Text:find('Exemplo',1,true))
return 'paid cards scroll horizontally and vertically; filters work; one real submission preserves the other temporary examples; six safe geometries keep controls clickable'
''')
HERE.joinpath('delta_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
