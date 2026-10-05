"""V51 failure paths and native-coordinate geometry; no real Roblox rendering."""
from test_support import *
RUNTIME=module('09B5_AVATAR_RUNTIME')+"Runtime=Modules['09B5_AVATAR_RUNTIME']\n"
BOOT=DATA+RUNTIME+"Runtime.Start();flush();HUM=pl.Character.Humanoid\n"
case('published_body_metadata_survives_preview_save_apply_and_respawn',UI+DATA+PREVIEW+SERVER+r'''
local native=InitialDescription:Clone();bodyChild(native,'Head',9201,'Original-Shape');bodyChild(native,'Torso',9202);native.StaticFacialAnimation=true;native.MoodAnimation=9301
native:SetAccessories({{AssetId=9401,AccessoryType=Enum.AccessoryType.Eyebrow,IsLayered=true,Order=3}})
function Services.Players:GetHumanoidDescriptionFromOutfitIdAsync(id)assert(id==555);return native:Clone()end
Bundles[501]={BundleType='DynamicHeadAvatar',Items={{Id=555,Type='UserOutfit'},{Id=9201,Type='Asset'},{Id=9202,Type='Asset'},{Id=9401,Type='Asset'},{Id=9402,Type='Asset'}}}
-- Both catalog metadata and a nonessential extra are offline. Native description suffices.
function Services.AvatarEditorService:GetItemDetailsAsync()error('HTTP 503')end
local original=A.Copy(S.Current);local ok,err=S.Try({Id=501,ItemType='Bundle'});assert(ok,err)
assert(S.Current.bodyParts.Head.shape=='Original-Shape'and S.Current.facial==true)
assert(S.Current.props.Shirt==11 and S.Current.props.Pants==12 and #S.Current.accessories==4 and S.Current.props.MoodAnimation==9301)
local view=Instance.new('ViewportFrame');view.Size=UDim2.fromOffset(240,330);view.Parent=pg
local p=Preview.Mount(view,S.Current,'R15');flush();assert(p.Model)
local pd=p.Model.Humanoid:GetAppliedDescription();assert(A.Pack(pd).bodyParts.Head.shape=='Original-Shape'and pd.StaticFacialAnimation)
local result=RPC:InvokeServer('Apply',{body=S.Current,base=original,rig='R15'});assert(result.ok,result.error)
assert(result.data.body.bodyParts.Head.shape=='Original-Shape')
local saved=RPC:InvokeServer('Save',{body=result.data.body,name='Corpo',rig='R15'});assert(saved.ok and saved.data.skin.body.bodyParts.Head.shape=='Original-Shape')
pl:LoadCharacterAsync();flush();local snapshot=RPC:InvokeServer('AvatarSnapshot',{});assert(snapshot.ok and snapshot.data.body.bodyParts.Head.shape=='Original-Shape')
return 'native package metadata, mood/static face and bundled eyebrows survive preview, confirmed server apply, save and respawn; outfit accessories augment existing clothing; catalog outage/optional extra do not block native body'
''')
case('single_asset_remove_does_not_resurrect_old_head_metadata',DATA+r'''
local d=InitialDescription:Clone();bodyChild(d,'Head',9201,'Meme');bodyChild(d,'Torso',9202)
local packed=A.Pack(d);local removed=A.Remove(packed,9201);assert(removed.props.Head==0 and not removed.bodyParts.Head)
local rebuilt=A.Unpack(removed,d);assert(rebuilt.Head==0 and A.Pack(rebuilt).bodyParts.Head==nil)
Details[9501]={Id=9501,AssetType='DynamicHead'};assert(S.Set(packed));assert(S.Try(Details[9501]));assert(S.Current.props.Head==9501 and not S.Current.bodyParts.Head)
assert(S.Current.bodyParts.Torso.id==9202)
return 'separate X removes the selected mesh and its metadata; replacing only a head clears its old shape without deleting torso or clothes'
''')
case('legacy_saved_looks_and_forged_native_fields_are_handled',DATA+r'''
local old=A.Copy(S.Current);old.bodyParts=nil;old.facial=nil;assert(A.Clean(old));assert(A.Unpack(old).Shirt==11)
local raw=A.Copy(old);raw.bodyParts={Backpack={id=100,shape=''}};assert(not A.Clean(raw))
raw.bodyParts={Head={id=0/0,shape=''}};assert(not A.Clean(raw))
raw.bodyParts={Head={id=14,shape='bad\nshape'}};assert(not A.Clean(raw))
raw.bodyParts={Head={id=9999,shape='Unrelated'}};local clean=A.Clean(raw);assert(clean and not clean.bodyParts.Head and clean.props.Head==14)
raw.facial='true';assert(not A.Clean(raw))
return 'old saved bodies load with defaults; invalid IDs/types/shapes rejected; unrelated native IDs cannot override canonical selected parts'
''')
case('live_native_edit_preserved_when_only_clothing_changes',DATA+SERVER+r'''
local baseline=RPC:InvokeServer('AvatarSnapshot',{}).data.body
bodyChild(pl.Character.Humanoid.applied,'Head',9601,'Live-Shape');pl.Character.Humanoid.applied.StaticFacialAnimation=true
local changed=A.Copy(baseline);changed.props.Shirt=9602
local result=RPC:InvokeServer('Apply',{body=changed,base=baseline,rig='R15'});assert(result.ok,result.error)
assert(result.data.body.props.Head==9601 and result.data.body.bodyParts.Head.shape=='Live-Shape'and result.data.body.facial==true)
assert(result.data.body.props.Shirt==9602 and result.data.body.props.Pants==12)
local actual=pl.Character.Humanoid:GetAppliedDescription();assert(actual:GetEmotes().Dance[1]==31)
return 'three-way clothing merge preserves newer live head metadata/static expression and named emotes'
''')
case('changed_head_shape_and_removed_shape_rebuild_and_read_back',BOOT+r'''
local d=InitialDescription:Clone();bodyChild(d,'Head',14,'Shape-A');local before=pl.Character
local a=Runtime.Apply(pl,d,'R15');assert(a.applied and pl.Character~=before and a.body.bodyParts.Head.shape=='Shape-A')
local desired=A.Copy(a.body);desired.bodyParts.Head.shape='Shape-B';local b=Runtime.Apply(pl,A.Unpack(desired), 'R15');assert(b.body.bodyParts.Head.shape=='Shape-B')
desired.bodyParts={};local old=pl.Character;local c=Runtime.Apply(pl,A.Unpack(desired),'R15');assert(c.applied and pl.Character~=old and not c.body.bodyParts.Head)
return 'shape changes and clearing shape trigger verified reconstruction even when head asset ID remains the same'
''')
case('native_body_and_preview_transient_build_retry',BOOT+PREVIEW+r'''
local factory=Services.Players.CreateHumanoidModelFromDescriptionAsync;local calls=0
function Services.Players:CreateHumanoidModelFromDescriptionAsync(d,rig,verification)
 calls=calls+1;assert(verification==Enum.AssetTypeVerification.Always)
 if calls%2==1 then error('temporary body download outage')end;return factory(self,d,rig)
end
local d=InitialDescription:Clone();d.Torso=9701;local result=Runtime.Apply(pl,d,'R15');assert(result.applied and calls==2)
local view=Instance.new('ViewportFrame');view.Size=UDim2.fromOffset(240,330);view.Parent=pg
local failed=false;local p=Preview.Mount(view,result.body,'R15',{failed=function()failed=true end});flush();assert(p.Model and not failed and calls==4)
return 'native body and preview each recover from one transient creation error, with catalog-only asset verification'
''')
case('unconfirmed_preview_never_displays_generic_body_as_success',DATA+PREVIEW+r'''
WrongBuild=true;local ready=0;local errorText
local view=Instance.new('ViewportFrame');view.Size=UDim2.fromOffset(240,330);view.Parent=pg
local p=Preview.Mount(view,S.Current,'R15',{ready=function()ready=ready+1 end,failed=function(e)errorText=e end});flush()
assert(not p.Model and ready==0 and errorText and errorText:find('Torso',1,true))
WrongBuild=false;p=Preview.Mount(view,S.Current,'R15');flush();assert(p.Model)
return 'native factory returning a generic/wrong torso fails visibly instead of claiming readiness; retry can then load the actual model'
''')
case('complete_outfit_failure_is_atomic_and_retry_keeps_generation',DATA+r'''
local count=0
function Services.Players:GetHumanoidDescriptionFromOutfitIdAsync()count=count+1;error('outfit unavailable')end
Bundles[502]={BundleType='BodyParts',Items={{Id=555,Type='UserOutfit'},{Id=9201,Type='Asset'}}}
Details[9201]={Id=9201,AssetType='Head'};local g=S.Generation
local ok,e=S.Try({Id=502,ItemType='Bundle'});assert(not ok and count==2 and S.Generation==g and S.Current.props.Head==14)
return 'two failed complete-outfit attempts leave prior body/history untouched and return actionable retry text'
''')
case('documented_core_origin_reclaims_exact_phantom_margin',UI+r'''
SCREEN_W,SCREEN_H=851,392;CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=59,59,58,21
DEVICE_LEFT,DEVICE_RIGHT,DEVICE_TOP,DEVICE_BOTTOM=59,59,0,21;TOPBAR_LEFT=223
U.SetWide(false);U.Layout();local il,it,ir,ib,w,h=U.SafeBounds.Read()
assert(il==59 and it==58 and ir==59 and ib==21 and w==851 and h==392)
assert(U.Root.AbsolutePosition.X==-59 and U.Root.AbsolutePosition.Y==-58)
assert(U.Main.AbsoluteSize.Y==371 and U.Left.AbsoluteSize.Y==371)
local bar=U.SafeBounds.Topbar();assert(bar.X==223 and bar.Y==0 and bar.Right==792 and bar.Bottom==58)
NoInsetAPI=true;U.Layout();local a,b,c,d=U.SafeBounds.Read();assert(a==il and b==it and c==ir and d==ib)
return 'official -59/-58 origin produces true 59/58/59/21 margins, not a phantom 79px bottom; native-guide fallback agrees'
''')
case('landscape_topbar_free_space_cards_prices_and_bottom_safe',UI+DATA+module('09C4_OUTFIT_LIBRARY')+module('09C2_SHOP_CATALOG')+r'''
function Services.AvatarEditorService:SearchCatalogAsync()return{IsFinished=false,GetCurrentPage=function()local out={};for i=1,20 do out[i]={Id=7000+i,Name='Item',Price=i==10 and 1234567 or 41,ItemType='Asset'}end;return out end}end
local ctl=Modules['09C2_SHOP_CATALOG'].Init({U=U,A=A,S=S,toast=function()end});ctl.Search();flush()
for _,v in ipairs({{935,420,0,0,0},{844,390,44,44,21},{851,392,59,59,21},{1024,600,0,0,20},{1920,1080,0,0,0}})do
 SCREEN_W,SCREEN_H,CORE_LEFT,CORE_RIGHT,DEVICE_BOTTOM=table.unpack(v);CORE_TOP=58;CORE_BOTTOM=120;DEVICE_TOP=0;DEVICE_LEFT=CORE_LEFT;DEVICE_RIGHT=CORE_RIGHT;TOPBAR_LEFT=223
 U.SetWide(false);U.Layout();ctl.Resize();flush()
 local root=U.Root.AbsolutePosition;local d,_,bar=U.SafeBounds.Areas();local q=U.Query.AbsolutePosition
 assert(q.Y-root.Y<58 and q.X-root.X>=bar.X and q.Y-root.Y>=bar.Y)
 for _,o in ipairs({U.Query,U.SearchGo,U.Filter,U.Sort,U.Close})do inside(o,U.Root);assert(o.AbsoluteSize.Y>=44);assert(o.AbsolutePosition.X-root.X>=bar.X)end
 for _,o in ipairs({U.Left,U.Main,U.BodyWindow})do inside(o,U.Root);assert(o.AbsolutePosition.Y-root.Y+o.AbsoluteSize.Y<=d.Bottom)end
 assert(U.GridLayout.FillDirectionMaxCells==5)
 local n=0
 for _,c in ipairs(U.Grid:GetChildren())do if c:IsA('GuiButton')then n=n+1
  local im,price=c.ItemImage,c.ItemPrice
  assert(im.AbsoluteSize.X>=c.AbsoluteSize.X-4 and im.AbsoluteSize.Y>=c.AbsoluteSize.Y-24)
  assert(price.AbsolutePosition.Y>=im.AbsolutePosition.Y+im.AbsoluteSize.Y and price.AbsoluteSize.Y<=20 and not price.TextWrapped)
  assert(not intersects(im,price));inside(im,c);inside(price,c)
  if n<=10 then inside(c,U.Grid)end
 end end
 assert(U.Viewport.AbsoluteSize.Y>=180)
end
return 'five full-width images by two visible rows, tiny below-image price footer, free topbar header and real hardware bottom across five landscape/tablet screens; no native control overlap'
''')
case('orientation_native_controls_changes_and_accessible_popup_bounds',UI+r'''
for _,v in ipairs({{320,568,0,0,0,0},{390,844,0,0,44,34},{568,320,0,0,0,0},{800,360,0,0,0,21},{844,390,44,44,0,21}})do
 SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_TOP,DEVICE_BOTTOM=table.unpack(v);CORE_LEFT,CORE_RIGHT=DEVICE_LEFT,DEVICE_RIGHT;CORE_TOP=math.max(58,DEVICE_TOP);CORE_BOTTOM=100
 TOPBAR_LEFT=180;U.SetWide(false);U.Layout();local d,c,bar=U.SafeBounds.Areas();local root=U.Root.AbsolutePosition
 for _,o in ipairs({U.ViewLeft,U.ViewRight,U.ZoomIn,U.ZoomOut})do inside(o,U.PreviewShell);assert(o.AbsoluteSize.X>=44 and o.AbsoluteSize.Y>=44 and not intersects(o,U.Viewport))end
 for _,o in ipairs({U.Apply,U.Save,U.Reset,U.BuyLook,U.BodyToggle})do inside(o,U.Actions);assert(o.AbsoluteSize.Y>=44)end
 for _,o in ipairs({U.BodyClose,U.CartClose,U.LoaderClose,U.CloseFilter,U.DetailClose})do inside(o,U.Root);assert(o.AbsoluteSize.X>=48 and o.AbsoluteSize.Y>=48)end
 inside(U.ItemStrip,U.Left);assert(U.ItemStrip.AbsoluteSize.Y>=64)
 local previous=U.Query.Position.Y.Offset;TOPBAR_LEFT=SCREEN_W-200;U.SafeGuide:GetPropertyChangedSignal('AbsolutePosition'):Fire();assert(U.Query.Position.Y.Offset>=previous)
 U.StopEmote.Visible=true;U.Layout();inside(U.StopEmote,U.PreviewShell);assert(not intersects(U.StopEmote,U.Viewport));U.StopEmote.Visible=false
end
return 'both orientations/notches/cutouts recalculate safe header; four 44px controls and active emote stop sit outside preview; 48px popup exits and equipped-item row stay inside device-safe bounds'
''')
case('camera_default_fits_all_body_corners_at_arbitrary_yaw',DATA+PREVIEW+r'''
local view=Instance.new('ViewportFrame');view.Size=UDim2.fromOffset(230,300);view.Parent=pg
local p=Preview.Mount(view,S.Current,'R15');flush();local huge=Instance.new('Part');huge.Name='WideMeme';huge.Size=Vector3.new(10,15,9);huge.Position=Vector3.new(0,5,0);huge.Parent=p.Model
for _,shape in ipairs({{230,300},{170,200},{480,280},{220,700}})do
 view.Size=UDim2.fromOffset(shape[1],shape[2])
 for yaw=0,345,15 do p.SetYaw(yaw);p.SetZoom(1.02);local cf,size=Preview.Bounds(p.Model)
  local tan=math.tan(math.rad(p.Camera.FieldOfView*.5));local aspect=shape[1]/shape[2]
  for _,x in ipairs({-1,1})do for _,y in ipairs({-1,1})do for _,z in ipairs({-1,1})do
   local corner=cf.Position+Vector3.new(x*size.X*.5,y*size.Y*.5,z*size.Z*.5);local camera=p.Camera.CFrame:PointToObjectSpace(corner)
   assert(camera.Z<0 and math.abs(camera.Y)/(-camera.Z*tan)<=1.001 and math.abs(camera.X)/(-camera.Z*tan*aspect)<=1.001,'body cropped at yaw '..yaw)
  end end end
 end
end
return 'all eight body-box corners remain visible at 24 yaw angles and four tall/wide viewports with the catalog default zoom; huge meme geometry does not depend on a square frame'
''')
case('native_part_roles_allow_complete_meshes_with_custom_names',BOOT+r'''
local factory=Services.Players.CreateHumanoidModelFromDescriptionAsync
function Services.Players:CreateHumanoidModelFromDescriptionAsync(d,rig)
 local m=factory(self,d,rig);local h=m.Humanoid
 for _,p in ipairs(m:GetChildren())do if p:IsA('BasePart')and p.Name~='HumanoidRootPart'then p.role=p.Name;p.Name='Native_'..p.Name end end
 function h:GetBodyPartR15(p)return p.role and Enum.BodyPartR15[p.role]or Enum.BodyPartR15.Unknown end
 return m
end
local d=InitialDescription:Clone();d.Torso=9801;local r=Runtime.Apply(pl,d,'R15');assert(r.applied and r.body.props.Torso==9801 and pl.Character.Native_UpperTorso)
return 'native body-part roles validate a full R15 skeleton without forcing mesh instance names; missing roles still fail structural verification'
''')
CLIENT=UI+DATA+PREVIEW+SERVER+module('09C4_OUTFIT_LIBRARY')+module('09C10_CONFIRM_ACTION')+module('09C9_PLAYER_INSPECT')+r'''
Modules['09A_SHOP_UI']={VERSION='V44_STUDIO_UI',Build=function()return U end};local ui=Instance.new('ModuleScript');ui.Name='09A_SHOP_UI';ui.Parent=rep
for _,n in ipairs({'09C2_SHOP_CATALOG','09C1_SHOP_LOOKS','09C5_UGC_STORES'})do local o=Instance.new('ModuleScript');o.Name=n;o.Parent=rep;Modules[n]={Init=function()return{Search=function()end,Saved=function()end,Community=function()end}end}end
'''+src('09C_SHOP_CLIENT')+'\nflush()\n'
case('catalog_retry_button_recovers_visible_native_preview_failure',CLIENT+r'''
FailBuild=true;U.OpenRequest:Fire('Catalog');flush()
assert(U.PreviewError.Visible and U.PreviewRetry.Visible and not Preview.Get(U.Viewport).Model)
FailBuild=false;U.PreviewRetry.Activated:Fire();flush()
assert(Preview.Get(U.Viewport).Model and not U.PreviewError.Visible and not U.PreviewRetry.Visible)
local torso=S.Current.props.Torso;U.ViewLeft.Activated:Fire();U.ZoomIn.Activated:Fire();assert(S.Current.props.Torso==torso)
return 'actual catalog controller exposes readable load failure and retry; retry creates the correct preview, clears error and retains body while rotating/zooming'
''')
case('confirmed_same_appearance_does_not_cancel_pending_or_repeat_body_load',CLIENT+r'''
local factory=Services.Players.CreateHumanoidModelFromDescriptionAsync;local calls=0;local nested=false
function Services.Players:CreateHumanoidModelFromDescriptionAsync(d,rig,v)
 calls=calls+1
 if not nested then nested=true;S.AcceptApplied(A.Copy(S.Current),S.Generation,S.Rig)end
 return factory(self,d,rig,v)
end
U.OpenRequest:Fire('Catalog');flush();assert(calls==1 and Preview.Get(U.Viewport).Model)
S.AcceptApplied(A.Copy(S.Current),S.Generation,S.Rig);flush();assert(calls==1)
local changed=A.Copy(S.Current);changed.props.Shirt=9901;S.Set(changed,false,nil,true);flush();assert(calls==2)
U.Close.Activated:Fire();changed=A.Copy(S.Current);changed.props.Shirt=9902;S.Set(changed,false,nil,true);flush();assert(calls==2)
U.OpenRequest:Fire('Catalog');flush();assert(calls==3 and Preview.Get(U.Viewport).Model)
return 'confirmation of identical appearance retains an in-flight or loaded preview instead of canceling/reloading native assets; real clothing change loads once; hidden catalog does not load meshes'
''')
HERE.joinpath('native_mobile_results.json').write_text(json.dumps(results,indent=2,ensure_ascii=False)+'\n')
print('V51 NATIVE/MOBILE',len(results),'PASS')
