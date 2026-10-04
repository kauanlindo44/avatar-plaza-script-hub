"""Regressions for the failures reported in the V47 screenshots.

Roblox services, UI and geometry are doubles; this is not a native visual test.
"""
import ast
from test_support import *

def fixture(file,name):
 for node in ast.parse((HERE/file).read_text()).body:
  if isinstance(node,ast.Assign) and getattr(node.targets[0],'id','')==name:
   return eval(compile(ast.Expression(node.value),str(file),'eval'),globals())
 raise ValueError(name)

DISCOVERY=module('09B2_COSPLAY_METADATA')+module('09B1_AVATAR_DISCOVERY')+module('09B4_CURATED_LOOKS')
NATIVE=r'''
function Services.Players:GetHumanoidDescriptionFromUserIdAsync(id)
 local d=InitialDescription:Clone();d.Shirt=id*10+1;d.Pants=id*10+2;return d
end
function Services.AvatarEditorService:GetBatchItemDetailsAsync(ids)
 local out={};for _,id in ipairs(ids)do out[#out+1]={Id=id,Name='Street hoodie',Price=10}end;return out
end
task.wait=function(s)TEST_TIME=TEST_TIME+(s or .04);flush()end
'''
case('username_outage_still_loads_fifty_actual_player_outfits',UI+DATA+PREVIEW+COMMUNITY+DISCOVERY+NATIVE+r'''
local nameCalls=0;function Services.UserService:GetUserInfosByUserIdsAsync(ids)nameCalls=nameCalls+1;error('HTTP 429')end
local native=Modules['09B4_CURATED_LOOKS'];local ctl=Modules['09C7_COMMUNITY_FEED'].Init({U=U,A=A,toast=function()end,show=function()end,call=function(_,args)return native.Page(pl,args)end})
U.Root.Visible=true;U.CommunityArea.Visible=true;U.SetWide(true);ctl.Open('JOGADORES');flush()
assert(#ctl.Rows==50 and #ctl.Pending>0 and nameCalls==1,'optional names outage stopped real descriptions or hammered UserService')
local unknown=0;for _,r in ipairs(ctl.Rows)do
 assert(r.source=='Roblox'and r.body.props.Shirt==r.owner*10+1 and r.body.props.Pants==r.owner*10+2 and r.total>0)
 if not r.sourceUsername then unknown=unknown+1 end
end;assert(unknown>0 and not U.CommunityStatus.Text:find('ServerScriptService',1,true))
return 'HTTP 429 on optional usernames does not block fifty distinct native outfits; failed name service is queried once; no invented author or visible stack trace'
''')
case('name_budget_global_across_visitors_and_recovers_next_minute',DATA+DISCOVERY+NATIVE+r'''
local submitted=0;function Services.UserService:GetUserInfosByUserIdsAsync(ids)assert(#ids<=32);submitted=submitted+#ids;local out={};for _,id in ipairs(ids)do out[#out+1]={Id=id,Username='User'..id}end;return out end
local d=Modules['09B1_AVATAR_DISCOVERY'];local other=makePlayer(999)
for i=0,9 do local page=d.Page(i%2==0 and pl or other,{page=i});assert(#page.items>0)end
assert(submitted>100 and submitted<=180,'name budget was per visitor or unbounded')
local before=submitted;advance(61);assert(#d.Page(pl,{page=10}).items>0 and submitted>before)
return 'at most 180 IDs per minute shared across visitors, batches <=32 and name lookups resume after sixty seconds'
''')
case('description_service_failure_retry_is_not_cached_and_not_end_of_list',DATA+DISCOVERY+NATIVE+r'''
local native=Services.Players.GetHumanoidDescriptionFromUserIdAsync
function Services.Players:GetPlayers()return{}end
function Services.Players:GetHumanoidDescriptionFromUserIdAsync()error('native unavailable')end
local c=Modules['09B4_CURATED_LOOKS'];local first=c.Page(pl,{page=0});assert(first.retry and not first.finished and #first.items==0)
Services.Players.GetHumanoidDescriptionFromUserIdAsync=native;advance(1)
local retry=c.Page(pl,{page=0});assert(not retry.retry and #retry.items>0,'transient failure cached for three minutes')
local other=makePlayer(999);local page=c.Page(other,{page=1});assert(#page.items>0)
local d=Modules['09B1_AVATAR_DISCOVERY'];local r=d.Load(other,{id=page.items[1].owner});assert(r.body,'cached curated result bypassed visitor authorization')
return 'outage yields a retry rather than a false final page; recovery works immediately after the normal throttle; each visitor retains authorized native profiles'
''')
case('community_rpc_internal_source_paths_and_http_trace_are_hidden',DATA+SERVER+r'''
local d=Modules['09B1_AVATAR_DISCOVERY']
d.Page=function()error('ServerScriptService.09B4_CURATED_LOOKS:81: ServerScriptService.09B1_AVATAR_DISCOVERY:63: HTTP 429',0)end
local failed=RPC:InvokeServer('DiscoverPage',{});assert(not failed.ok and failed.error=='O serviço está ocupado. Tente novamente em instantes.')
failed=RPC:InvokeServer('CuratedPage',{});assert(not failed.ok and not failed.error:find('ServerScriptService',1,true)and not failed.error:find('HTTP',1,true))
return 'raw nested Script:line and HTTP errors remain on server logs; remote payload provides a short retry message'
''')
case('manual_feed_pending_tail_survives_last_page_and_stops_fetching',UI+DATA+PREVIEW+COMMUNITY+r'''
local calls=0;local ctl=Modules['09C7_COMMUNITY_FEED'].Init({U=U,A=A,toast=function()end,show=function()end,call=function(_,args)
 calls=calls+1;assert(args.page<3,'fetched beyond last page');local out={}
 for i=1,24 do local id=args.page*24+i+1;out[#out+1]={id='roblox:'..id,owner=id,body=A.Copy(S.Current),source='Roblox',signature=tostring(id),name='Look'}end
 return{items=out,finished=args.page==2}
end})
U.Root.Visible=true;U.CommunityArea.Visible=true;U.SetWide(true);ctl.Open();flush();assert(#ctl.Rows==50 and #ctl.Pending==22 and not ctl.Finished)
for _,n in ipairs({60,70,72})do U.ComMore.Activated:Fire();flush();assert(#ctl.Rows==n and calls==3)end
assert(ctl.Finished and not U.ComMore.Active and U.ComMore.Text=='Fim da lista');U.ComMore.Activated:Fire();flush();assert(calls==3)
return 'all 72 looks from three pages remain reachable; cached tails add ten then two; reaching the end disables requests without discarding pending looks'
''')
CARD=THEME+module('07K0_TRUCO_RULES')+module('07K6_CARD_CATALOG')+module('07K7_CARD_STYLES')+module('07K9_CARD_INVENTORY_UI')
case('atelier_validates_type_texture_cancel_timeout_and_latest_request',CARD+r'''
local gui=Instance.new('ScreenGui');gui.Parent=pg
local data={coins=0,owned={Classic=true},equipped='Classic',ateliers=true,boxes={},custom={image=0,zoom=1.2,x=0,y=0}};local u;local saved
u=Modules['07K9_CARD_INVENTORY_UI'].Build(gui,function(action,args)
 if action=='inventory'then return data elseif action=='store'then return{passes={},products={}}
 elseif action=='custom'then saved=deep(args);data.custom=deep(args);data.equipped='Custom';return true
 elseif action=='image'then
  if args.image==111 then u.CustomID.Text='222';u.LoadImage.Activated:Fire()
  elseif args.image==333 then return{image=333,texture=333,assetType=9}
  elseif args.image==444 then return nil,'ID indisponível.'
  elseif args.image==555 then advance(13)
  elseif args.image==666 then u.Close.Activated:Fire()end
  return{image=args.image,texture=args.image+8000,assetType=13}
 end
end,function()end)
u.Tab='Ateliê';u.Show();flush();u.CustomID.Text='111';u.LoadImage.Activated:Fire();flush()
assert(u.SaveCustom.Active and named(u.CustomPreview,'CustomArtwork').Image=='rbxassetid://8222','old request replaced latest texture')
u.SaveCustom.Activated:Fire();flush();assert(saved.image==222 and saved.texture==8222 and data.equipped=='Custom')
u.CustomFlip.Activated:Fire();flush();assert(named(u.CustomPreview,'CustomArtwork').Image=='rbxassetid://8222')
for _,id in ipairs({333,444,555})do
 u.CustomID.Text=tostring(id);u.LoadImage.Activated:Fire();flush();assert(not u.SaveCustom.Active and not named(u.CustomPreview,'CustomArtwork'))
 u.SaveCustom.Activated:Fire();assert(saved.image==222,'invalid image persisted')
end
assert(u.ImageStatus.Text:find('Recarregar',1,true));u.CustomID.Text='666';u.LoadImage.Activated:Fire();flush();assert(not u.Root.Visible and not named(u.CustomPreview,'CustomArtwork'))
return 'latest request wins; native decal texture is shown and saved on both faces; wrong type, unavailable ID and twelve-second metadata timeout never claim readiness; closing cancels late artwork'
''')
TRUCO=fixture('test_server_flows.py','TRUCO')
case('server_image_type_and_canonical_decal_texture_never_trust_client',TRUCO+r'''
local infoCalls,assetCalls=0,0;local asset;local resolved=6501
onProduct=function(id)infoCalls=infoCalls+1;if id==999 then error('offline')end;return{Name='Approved',AssetTypeId=id==501 and 13 or id==502 and 1 or 9}end
Services.AssetService={LoadAssetAsync=function(_,id)
 assetCalls=assetCalls+1;assert(id==501);asset=Instance.new('Model');assert(not asset.Parent)
 local decal=Instance.new('Decal');decal.Texture='rbxassetid://'..resolved;decal.Parent=asset
 local code=Instance.new('Script');code.Name='UnusedCode';code.Parent=asset;return asset
end}
local p=players[1];local first=ask(p,'image',{image=501});assert(first.ok and first.data.texture==6501 and asset.destroyed and not asset.Parent)
assert(not ask(p,'image',{image=503}).ok and not ask(p,'image',{image=999}).ok and not ask(p,'image',{image=-1}).ok)
assert(not ask(p,'custom',{image=501,texture=777}).ok,'custom saved without pass')
local i=Modules['07K8_CARD_INVENTORY'];assert(i.GrantPass(p.UserId,1951234105));assert(not i.Equip(p.UserId,'Custom'),'empty custom visual equipped')
assert(ask(p,'custom',{image=501,texture=777,zoom=1.5,x=.1,y=-.1}).ok)
local stored=i.View(p.UserId);assert(stored.custom.image==501 and stored.custom.texture==6501 and stored.equipped=='Custom'and assetCalls==1)
assert(ask(p,'image',{image=502}).data.texture==502)
resolved=6502;advance(181);assert(ask(p,'image',{image=501}).data.texture==6502 and assetCalls==2 and asset.destroyed)
return 'server rejects non-images and missing assets; pass gates saved custom visuals; decal wrapper destroyed and never inserted; forged texture ignored; canonical texture/crop persist and expired metadata can refresh'
''')
case('top_game_categories_compact_room_actions_and_waiting_lock',THEME+module('07H1_GAME_LOBBY')+r'''
local gui=Instance.new('ScreenGui');gui.Parent=pg;local u=Modules['07H1_GAME_LOBBY'].Build(gui);u.Root.Visible=true
for _,v in ipairs({{320,568,0,0,58,0},{390,844,0,0,58,0},{800,360,0,0,58,0},{844,390,44,44,58,22},{1920,1080,0,0,58,0}})do
 SCREEN_W,SCREEN_H,CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=table.unpack(v)
 for _,key in ipairs({'Xadrez','Damas','Truco'})do
  u.Reset();u.SetGame(key);u.ModeButtons.Friends.Activated:Fire();u.Layout();local row=u.GameButtons.Xadrez.AbsolutePosition.Y
  for _,b in pairs(u.GameButtons)do inside(b,u.Root);assert(b.AbsolutePosition.Y==row and b.AbsoluteSize.Y>=44 and b.AbsolutePosition.Y<u.Panel.AbsolutePosition.Y)end
  assert(u.Create.Text=='Criar sala de '..key and u.Inventory.Visible==(key=='Truco'))
  for _,b in ipairs({u.Create,u.Code,u.Join})do inside(b,u.Panel);assert(b.AbsoluteSize.Y>=44)end
  u.Code.Text='ABCD';u.SetBusy(true);u.GameButtons[key=='Truco'and'Xadrez'or'Truco'].Activated:Fire();assert(u.Selected==key and u.Code.Text=='ABCD')
  u.SetBusy(false);u.SetWaiting('ABCD');u.GameButtons.Truco.Activated:Fire();assert(u.Selected==key and u.CodeDisplay.Text=='ABCD')
  assert(not intersects(u.Cancel,u.CodeDisplay)and not intersects(u.Cancel,u.SelectCode),'waiting cancel blocked the code controls')
 end
end
return 'three categories share a top row in both orientations; compact create/join actions remain within the panel; matching room label and Truco-only inventory; category cannot change during a pending request or room'
''')
case('catalog_reclaims_core_bottom_gap_preserves_device_safe_area',UI+r'''
SCREEN_W,SCREEN_H,CORE_TOP,CORE_BOTTOM=844,390,58,100;CORE_LEFT,CORE_RIGHT=44,44
DEVICE_TOP,DEVICE_BOTTOM,DEVICE_LEFT,DEVICE_RIGHT=0,0,44,44
U.Root.Visible=true;U.SetWide(false);U.Layout();local il,it,ir,ib=U.SafeBounds.Read();assert(il==44 and ir==44 and it==58 and ib==0)
assert(U.Left.AbsoluteSize.Y==390 and U.Main.AbsoluteSize.Y==390,'unused core bottom band remains')
local large=U.Grid.AbsoluteSize.Y;inside(U.More,U.Main);inside(U.ItemStrip,U.Left)
DEVICE_BOTTOM=22;U.Layout();assert(U.SafeBounds.Read()==44 and U.Main.AbsoluteSize.Y==368 and U.Grid.AbsoluteSize.Y==large-22)
inside(U.More,U.Main);inside(U.ItemStrip,U.Left);assert(U.Close.AbsoluteSize.X==48 and U.Close.AbsoluteSize.Y==48)
U.Gui:Destroy();assert(not pg:FindFirstChild('AvatarShopGui_DeviceGuide'))
return '100px core inset no longer reserves an empty bottom band; real 22px hardware inset is retained; card grid/footer grow while native top and notch controls remain safe'
''')
PHOTO=THEME+DATA+PREVIEW+module('07P0_STUDIO_PRESETS')+module('07P3_POSE_EDITOR')+module('07P5_POSE_CANVAS')+module('07P6_STUDIO_SETS')+module('07P2_STUDIO_AVATAR')+"Studio=Modules['07P2_STUDIO_AVATAR']\n"+module('07P4_STUDIO_UI')
case('photo_sidebar_all_tools_emotes_camera_and_light_controls_fit',PHOTO+r'''
local u=Modules['07P4_STUDIO_UI'].Build(pl);u.Root.Visible=true
for _,v in ipairs({{320,568,0,0,58,0},{390,844,0,0,58,0},{800,360,0,0,58,0},{844,390,44,44,58,22},{1920,1080,0,0,58,0}})do
 SCREEN_W,SCREEN_H,CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=table.unpack(v);u.Popup.Visible=false;u.Layout()
 assert(u.Nav.ClassName=='Frame'and u.Nav.AbsoluteSize.X<u.Nav.AbsoluteSize.Y)
 for key,b in pairs(u.Buttons)do inside(b,key=='Hide'and u.Root or u.Nav);assert(b.AbsoluteSize.Y>=44)end
 for _,count in ipairs({6,9,10})do
  u.Clear();u.Popup.Visible=true;for i=1,count do u.Option('Opção '..i,i)end;u.Layout();inside(u.Popup,u.Root);inside(u.PopupClose,u.Popup)
  for _,b in ipairs(u.Content:GetChildren())do if b:IsA('GuiButton')then inside(b,u.Content);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44)end end
  assert(u.SceneMargins[2]+u.SceneMargins[4]<SCREEN_H-80,'panel covered the entire scene')
 end
 u.Clear();for i=1,5 do u.Row('Luz '..i,1,i)end;u.Pair('Luz','Restaurar',6);u.Layout()
 for _,row in ipairs(u.Content:GetChildren())do if row:IsA('Frame')then inside(row,u.Content);for _,b in ipairs(row:GetChildren())do if b:IsA('GuiButton')then inside(b,row);assert(b.AbsoluteSize.Y>=44)end end end end
 u.SetClean(true);assert(not u.Nav.Visible and u.Restore.Visible);u.SetClean(false)
end
return 'six lateral tools plus hide/restore; emote and camera controls remain >=44px; all environment +/- controls fit without scrolling; popup X remains separate and a scene area survives on five viewports'
''')
case('photo_delayed_native_emote_track_stop_and_failed_playback',PHOTO+r'''
local create=Services.Players.CreateHumanoidModelFromDescriptionAsync;local last;local mode='delay'
function Services.Players:CreateHumanoidModelFromDescriptionAsync(desc,rig)
 local model=create(self,desc,rig);local hum=model:FindFirstChildOfClass('Humanoid');local animator=hum:FindFirstChildOfClass('Animator');local polls=0;local tracks={};local playing=false
 local function track()local t={Stopped=Signal(),stopped=false};function t:Stop()self.stopped=true;self.Stopped:Fire()end;function t:AdjustSpeed(v)self.Speed=v end;return t end
 function animator:GetPlayingAnimationTracks()if not playing then return{}end;polls=polls+1;if polls==3 and mode=='delay'then last=track();tracks={last};self.AnimationPlayed:Fire(last)end;return tracks end
 function hum:PlayEmoteAsync(name)
  assert(name=='PhotoEmote'and desc:GetEmotes().PhotoEmote[1]==9000);playing=true
  if mode=='stop'then Studio.StopEmote();last=track();animator.AnimationPlayed:Fire(last)end
  return mode~='fail'
 end;return model
end
task.wait=function(s)TEST_TIME=TEST_TIME+(s or .05)end;Details[9000]={AssetType='EmoteAnimation'}
assert(Studio.Enter());assert(Studio.PlayEmote(9000)and Studio.Track==last and last.Looped and TEST_TIME>=.1)
last.Stopped:Fire();assert(not Studio.Track and not Studio.Pose.Playback)
mode='stop';assert(not Studio.PlayEmote(9000)and last.stopped and not Studio.Track and not Studio.Pose.Playback)
mode='fail';assert(not Studio.PlayEmote(9000)and not Studio.Track and not Studio.Pose.Playback);Studio.Exit()
return 'native track may arrive after PlayEmoteAsync returns; actual track receives loop/speed; natural stop restores manual pose; Stop during a native call cancels its late track; failed emote never claims playback'
''')
case('detailed_live_sets_bounded_motion_and_clear_full_rotation',PHOTO+r'''
assert(Studio.Enter());local minParts=999;local names={};local maximum=0
for _,p in ipairs(Modules['07P0_STUDIO_PRESETS'].Backgrounds)do
 assert(not names[p.name]);names[p.name]=true;assert(Studio.BuildSet(p.id));local scene=Studio.Scene
 assert(scene.Count>=40 and scene.Count<=200 and scene.AnimatedCount>0 and scene.AnimatedCount<=20)
 minParts=math.min(minParts,scene.Count);maximum=math.max(maximum,scene.Count)
 for _,yaw in ipairs({0,90,180,270})do
  Studio.SetYaw(yaw);Services.RunService.RenderStepped:Fire(.1);local cf=Preview.Bounds(Studio.Model);local dir=Studio.Camera.CFrame.LookVector
  for _,o in ipairs(Studio.SetFolder:GetDescendants())do if o:IsA('BasePart')and o.Name~='PhotoFloor'then
   for _,x in ipairs({-1,1})do for _,y in ipairs({-1,1})do for _,z in ipairs({-1,1})do
    local corner=o.CFrame*Vector3.new(x*o.Size.X/2,y*o.Size.Y/2,z*o.Size.Z/2);local delta=corner-cf.Position
    assert(delta.X*dir.X+delta.Y*dir.Y+delta.Z*dir.Z>8,'environment intersects avatar viewing plane')
   end end end
  end end
 end
 local moving;for _,o in ipairs(Studio.SetFolder:GetDescendants())do if o.Name=='Petal'or o.Name=='SkySpark'or o.Name=='GallerySculpture'or o.Name=='SunReflection'or o.Name=='CitySpark'then moving=o;break end end
 assert(moving);scene.SetAnimated(false);local before=moving.CFrame;Services.RunService.RenderStepped:Fire(1);assert(moving.CFrame==before)
end
Studio.Exit();assert(not Studio.Scene and not Studio.Model)
return 'five distinct detailed procedural sets; '..minParts..'–'..maximum..' parts, <=20 moving elements; all scenery corners behind avatar at four angles; pause and scene cleanup work'
''')
HERE.joinpath('fixes_results.json').write_text(json.dumps(results,indent=2,ensure_ascii=False)+'\n')
print('V47 FIXES',len(results),'PASS')
