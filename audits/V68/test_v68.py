from test_support import *
SIZES="{{320,568,0,0,0},{390,844,0,0,34},{568,320,0,0,0},{667,375,0,0,0},{851,392,44,44,21},{976,440,32,32,20},{1920,1080,0,0,0}}"
AI=THEME+DATA+module('09I0_ASSISTANT_CONFIG')+module('09I1_ASSISTANT_ACCOUNTS')+module('09I13_OUTFIT_SEARCH')+module('09I3_OUTFIT_BUILDER')+module('09I2_ASSISTANT_ENGINE')
case('current_message_overrides_previous_style_and_explicit_form_edits_win',AI+r'''
local e=Modules['09I2_ASSISTANT_ENGINE'];local a=e.Ask(pl,'Quero streetwear azul até 100 Robux',{style='emo',keyword='emo black',color='black'},'emo')
assert(a.keyword=='streetwear blue'and a.styleId=='street')
local edited=e.Ask(pl,'Quero streetwear azul',nil,'cottage',{confirmed=true,styleEdited=true,color='pink',scope='Tudo',budget=55,count=1,format='2D',excluded={}})
assert(edited.styleId=='cottage'and edited.keyword:find('pink',1,true)and not edited.keyword:find('streetwear',1,true))
local p=Modules['09I12_REQUEST_PLAN'].Parse('5 looks emo pretos 100 Robux sem chapéu');assert(p.count==5 and p.budget==100 and p.excluded[1]=='Hat')
return 'fresh text wins over stale menu selections; an intentional edit in the current confirmation form wins over inferred text; count/budget/exclusions are explicit'
''')
FORM=THEME+module('09I0_ASSISTANT_CONFIG')+module('09I4_ASSISTANT_UI')+module('09I5_ASSISTANT_QUESTIONNAIRE')
case('form_does_not_reuse_previous_style_color_exclusions_or_budget',FORM+r'''
local u=Modules['09I4_ASSISTANT_UI'].Build(pl);local q=Modules['09I5_ASSISTANT_QUESTIONNAIRE'].Build(u,function()end)
q.Open('Pro','5 looks emo preto até 100 Robux sem chapéu');assert(q.Options.style=='emo'and q.Options.count==5 and q.Options.excluded[1]=='Hat');q.CloseGuide()
q.Open('Normal','Quero um look streetwear azul até 250 Robux');assert(q.Options.style=='street'and q.Options.color=='blue'and #q.Options.excluded==0 and q.Options.count==1 and q.Budget.Text=='250')
q.CloseGuide();q.Open('Normal','Quero um look');assert(q.Options.style==nil and q.Options.color==''and q.Budget.Text=='100'and q.Options.keep==false)
return 'each request is parsed independently and a new unqualified request returns to full-look defaults instead of leaking the previous selection'
''')
case('desktop_menu_really_collapses_and_mobile_overlay_preserves_conversation_width',FORM+r'''
local u=Modules['09I4_ASSISTANT_UI'].Build(pl);SCREEN_W,SCREEN_H=1920,1080;u.MenuOpen=true;u.Layout();local narrow=u.Body.AbsoluteSize.X
u.Menu.Activated:Fire();assert(not u.Tabs.Visible and u.Body.AbsoluteSize.X>narrow+200);u.Select('Looks');assert(not u.Tabs.Visible)
SCREEN_W,SCREEN_H=390,844;u.Layout();local width=u.Body.AbsoluteSize.X;u.Menu.Activated:Fire();assert(u.Tabs.Visible and u.Body.AbsoluteSize.X==width);u.Select('Conversa');assert(not u.Tabs.Visible)
return 'desktop collapse releases the full sidebar width and stays collapsed across tabs; phone navigation overlays the conversation and closes after choosing a page'
''')
case('guided_budget_keyboard_uses_a_compact_nonoverlapping_confirmation',FORM+r'''
SCREEN_W,SCREEN_H=667,375;local u=Modules['09I4_ASSISTANT_UI'].Build(pl);local q=Modules['09I5_ASSISTANT_QUESTIONNAIRE'].Build(u,function()end);u.Root.Visible=true;q.Open('Normal','emo preto até 100 Robux')
Services.UserInputService.OnScreenKeyboardVisible=true;Services.UserInputService.OnScreenKeyboardPosition=Vector2.new(0,185);u.Layout();q.Layout();assert(not q.Title.Visible and q.BudgetField.Visible)
inside(q.Close,q.Root);inside(q.BudgetField,q.Root);if q.Confirm.Visible then inside(q.Confirm,q.Root);assert(not intersects(q.BudgetField,q.Confirm)and not intersects(q.Close,q.Confirm))end
Services.UserInputService.OnScreenKeyboardVisible=false;u.Layout();q.Layout();assert(q.Title.Visible and q.Scope.Visible and q.Confirm.Visible)
return 'on a landscape phone, the budget field and safe close remain above the keyboard without overlapping confirmation; dismissing the keyboard restores all guided choices'
''')
BUILDER_FIXTURE=r'''
Modules['08B4_AVATAR_LOAD'].Create=function()return Instance.new('Model')end
local B=Modules['09I3_OUTFIT_BUILDER'];local CatalogRows={};local CatalogCalls=0
function Services.AvatarEditorService:SearchCatalogAsync(params)
 CatalogCalls=CatalogCalls+1;local key=params.AssetTypes[1]and params.AssetTypes[1].Name or'BUNDLE';local rows=CatalogRows[key]or{};local index=1;local p={IsFinished=#rows<2}
 function p:GetCurrentPage()return deep(rows[index]or{})end
 function p:AdvanceToNextPageAsync()index=index+1;self.IsFinished=index>=#rows end;return p
end
local function add(kind,id,name,price,page)
 local r=fixture60(id,name,kind);r.Price=price;NativeItems60['Asset:'..id].Price=price;CatalogRows[kind]=CatalogRows[kind]or{{}};CatalogRows[kind][page or 1]=CatalogRows[kind][page or 1]or{};table.insert(CatalogRows[kind][page or 1],r)
end
'''
case('search_reads_second_page_to_complete_missing_upper_garment',AI+BUILDER_FIXTURE+r'''
CatalogRows.Shirt={{},{}};add('Shirt',801,'emo black shirt',5,2);add('Pants',802,'emo black pants',5)
local rows=assert(B.Build(pl,'emo black',B.Options({budget=10,color='black'},'Normal'),S.Current,function()end,function()return true end));assert(rows[1].body.props.Shirt==801 and rows[1].body.props.Pants==802 and rows[1].total==10)
return 'an empty first shirt page is not mistaken for an unavailable category; the second native page completes both garments within the budget'
''')
case('layered_builder_accepts_jacket_and_shorts_and_recovers_rejected_candidate',AI+BUILDER_FIXTURE+r'''
-- Native search can return alternatives from any requested type, not only the first enum.
CatalogRows.ShirtAccessory={{}};local jacket=fixture60(811,'emo black jacket','JacketAccessory');jacket.Price=10;NativeItems60['Asset:811'].Price=10;table.insert(CatalogRows.ShirtAccessory[1],jacket)
CatalogRows.PantsAccessory={{}};local shorts=fixture60(812,'emo black shorts','ShortsAccessory');shorts.Price=10;NativeItems60['Asset:812'].Price=10;table.insert(CatalogRows.PantsAccessory[1],shorts)
local rows=assert(B.Build(pl,'emo black',B.Options({budget=20,color='black',format='3D'},'Normal'),S.Current,function()end,function()return true end));local have={};for _,v in ipairs(rows[1].body.accessories)do have[v.type]=true end
assert(have.Jacket and have.Shorts and rows[1].complete and rows[1].rig=='R15')
return 'layered clothing supports verified jackets/sweaters/tees and shorts/skirts alternatives without silently switching a 3D request to classic clothing'
''')
case('outfits_obey_color_and_no_hat_without_spending_other_garment_budget',AI+BUILDER_FIXTURE+r'''
add('Shirt',821,'emo pink shirt',1);add('Shirt',822,'emo black shirt',10);add('Pants',823,'emo black pants',10);add('HairAccessory',824,'emo black hair',70);add('Hat',825,'emo black hat',1)
local rows=assert(B.Build(pl,'emo black',B.Options({budget=30,color='black',excluded={'Hat'}},'Normal'),S.Current,function()end,function()return true end));local r=rows[1]
assert(r.total<=30 and r.body.props.Shirt==822 and r.body.props.Pants==823 and r.complete)
for _,v in ipairs(r.body.accessories)do assert(v.type~='Hat')end
return 'cheap mismatched colors are rejected, hats are excluded from selection and preserved base accessories, and optional expensive hair cannot crowd out clothes'
''')
case('fresh_price_change_retries_a_different_complete_combination',AI+BUILDER_FIXTURE+r'''
add('Shirt',831,'emo black shirt A',5);add('Shirt',832,'emo black shirt B',5);add('Pants',833,'emo black pants',5)
local original=Services.AvatarEditorService.GetItemDetailsAsync;function Services.AvatarEditorService:GetItemDetailsAsync(id,kind)local d=original(self,id,kind);if id==831 then d.Price=90 end;return d end
local rows=assert(B.Build(pl,'emo black',B.Options({budget=10,color='black'},'Normal'),S.Current,function()end,function()return true end));assert(rows[1].body.props.Shirt==832 and rows[1].total==10)
return 'a stale cheap catalog price cannot bypass the confirmed total; the builder retries the remaining compatible garment instead of returning an overpriced outfit'
''')
case('failed_native_validation_recovers_without_repeating_the_failed_combination',AI+BUILDER_FIXTURE+r'''
add('Shirt',841,'emo black shirt A',5);add('Shirt',842,'emo black shirt B',5);add('Pants',843,'emo black pants',5)
local first;local checks=0;Modules['08B4_AVATAR_LOAD'].Create=function(d)checks=checks+1;if not first then first=d.Shirt;return nil,'Native appearance refusal'end;assert(d.Shirt~=first);return Instance.new('Model')end
local rows=assert(B.Build(pl,'emo black',B.Options({budget=10},'Normal'),S.Current,function()end,function()return true end));assert(checks==2 and rows[1].body.props.Shirt~=first)
return 'an avatar refused by native creation is discarded and a different complete combination is checked; the same failed signature is not retried repeatedly'
''')
case('novelty_survives_profile_reload_and_is_batched_in_existing_store',AI+BUILDER_FIXTURE+r'''
for i=1,6 do add('Shirt',850+i,'emo black shirt '..i,5);add('Pants',860+i,'emo black pants '..i,5)end
local a=Modules['09I1_ASSISTANT_ACCOUNTS'];assert(a.Read(pl.UserId));local writes=DSCalls64.writes
local first=assert(B.Build(pl,'emo black',B.Options({budget=10},'Normal'),S.Current,function()end,function()return true end))[1]
assert(a.Read(pl.UserId));local second=assert(B.Build(pl,'emo black',B.Options({budget=10},'Normal'),S.Current,function()end,function()return true end))[1]
assert(first.signature~=second.signature and DSCalls64.writes==writes);advance(31);assert(DSCalls64.writes==writes+1)
local saved=StoreData.ACP_AssistantProfiles_V55['u'..pl.UserId];assert(saved and #saved.recentLooks==2)
return 'a status/quota profile reload cannot erase pending outfit history; two searches produce different combinations and share one delayed persistence write'
''')
case('five_variations_each_have_their_own_budget_and_novelty_exhaustion_is_honest',AI+BUILDER_FIXTURE+r'''
for i=1,10 do add('Shirt',870+i,'emo black shirt '..i,5);add('Pants',890+i,'emo black pants '..i,5)end
local rows=assert(B.Build(pl,'emo black',B.Options({budget=10,count=5,plan='Pro'},'Pro'),S.Current,function()end,function()return true end));assert(#rows==5);local seen={}
for _,r in ipairs(rows)do assert(r.total==10 and r.complete and not seen[r.signature]);seen[r.signature]=true end
CatalogRows={};add('Shirt',910,'casual shirt',5);add('Pants',911,'casual pants',5)
local opts=B.Options({budget=10},'Normal');assert(B.Build(pl,'casual',opts,S.Current,function()end,function()return true end));local again,e=B.Build(pl,'casual',opts,S.Current,function()end,function()return true end);assert(not again and e:find('já foram mostradas',1,true))
return 'five returned outfits each fit the full per-look budget; when the only valid combination was already shown the result explicitly says so instead of pretending it is new'
''')
REFINE=THEME+DATA
case('accessory_adjustments_round_trip_and_identity_keeps_historical_signature',REFINE+r'''
local r=Modules['08B8_ACCESSORY_REFINEMENT'];assert(r.LoadRules());local n=Modules['08B2_BODY_DESCRIPTION'];local original=A.Copy(S.Current);local before=n.Key(A,original,'R15',false)
for _,v in ipairs(original.accessories)do if not v.layer then v.position={0,0,0};v.rotation={0,0,0};v.scale={1,1,1}end end
assert(n.Key(A,original,'R15',false)==before)
local row=original.accessories[1];row.position={.1,.2,-.1};row.rotation={10,20,0};row.scale={1.1,1.1,1.1}
local d=A.Unpack(original);local packed=A.Pack(d);local found;for _,v in ipairs(packed.accessories)do if v.id==row.id then found=v end end
assert(found.position[2]==.2 and found.rotation[2]==20 and found.scale[1]==1.1 and n.Key(A,packed,'R15',false)~=before)
local actual=A.Unpack(S.Current);local ok,e=r.Matches(d,actual);assert(not ok and e:find('não confirmou',1,true));d:Destroy();actual:Destroy()
return 'native position/rotation/scale survive serialization and reconstruction, neutral adjustments preserve old dedup keys and a silently dropped adjustment fails verification'
''')
case('refinement_limits_layered_items_and_nonfinite_input_are_rejected',REFINE+r'''
local r=Modules['08B8_ACCESSORY_REFINEMENT'];assert(r.LoadRules());local d=A.Copy(S.Current);local v=d.accessories[1];v.position={.26,0,0};assert(not A.Clean(d));v.position={0,0,0};v.layer=true;assert(not A.Clean(d));v.layer=false;v.position={0/0,0,0};assert(not A.Clean(d))
v.position=nil;v.scale={1,1,1};assert(A.Clean(d));local lo,hi=r.Bounds('Hair','position');assert(lo[1]==-.25 and hi[1]==.25)
return 'server data validation rejects native-bound overflows, adjustments to layered clothes and NaN; legitimate rigid accessory defaults remain valid'
''')
HOME=UI+DATA+PREVIEW+module('09C16_CATALOG_HOME')+module('09C15_AVATAR_TOOLS')
case('catalog_opens_on_categories_and_only_choice_or_search_enters_product_grid',HOME+r'''
U.Root.Visible=true;U.SetWide(false);local selected;local home=Modules['09C16_CATALOG_HOME'].Build({U=U,A=A,call=function()return{items={}}end,toast=function()end,browse=function(kind)selected=kind end,showItem=function()end})
home.Open();assert(home.Root.Visible and not U.Grid.Visible and not U.ItemStrip.Visible==false);home.Buttons[2].Activated:Fire();assert(selected=='Hair'and U.Grid.Visible and not home.Root.Visible)
home.Open();U.OnCatalogBrowse();assert(U.Grid.Visible and U.Groups.Parent.Visible)
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;U.Layout();home.Open();home.Layout();inside(home.Root,U.Main);inside(U.ItemStrip,U.Left);for _,b in ipairs(home.Buttons)do inside(b,home.Root);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44);for _,child in ipairs(b:GetChildren())do if child.Name:find('Icon_',1,true)then assert(child.Visible==(b.AbsoluteSize.Y>=65))end end end end
return 'category home retains the equipped-item strip and starts no search; category selection and explicit browse enter the grid and seven safe layouts keep cards reachable'
''')
case('avatar_tools_adjust_native_piece_undo_compare_and_scale_are_explicit',HOME+r'''
U.Root.Visible=true;U.SetWide(false);local comparisons=0;local tools=Modules['09C15_AVATAR_TOOLS'].Build({U=U,S=S,A=A,toast=function()end,call=function(a)if a=='AccessoryRules'then return RefinementRules68 end end,favorites=function()end,compare=function()comparisons=comparisons+1 end})
local before=S.Generation;tools.Compare.Activated:Fire();assert(comparisons==1 and S.Generation==before)
named(tools.Root,'RefineAccessory').Activated:Fire();flush();assert(tools.Adjust.Visible);local choose;for _,o in ipairs(tools.Adjust:GetChildren())do if o.Text=='Escolher peça ▾'then choose=o end end;choose.Activated:Fire();local choice=named(tools.Adjust,'Choice_'..S.Current.accessories[1].id);assert(choice);choice.Activated:Fire()
local plus,apply;for _,o in ipairs(tools.Adjust:GetChildren())do if o.Text=='+'then plus=o elseif o.Text=='Aplicar ajuste'then apply=o end end;plus.Activated:Fire();apply.Activated:Fire();assert(S.Current.accessories[1].position[2]==.01);assert(S.Undo())
local original=S.Current.scales.HeightScale;named(tools.Root,'TestScale110').Activated:Fire();assert(S.Current.scales.HeightScale>original);assert(S.Undo()and S.Current.scales.HeightScale==original)
return 'opening/using compare never applies another body; a chosen native accessory adjustment goes through skin state and Undo; the optional +10% height experiment is also reversible'
''')
case('graphite_preview_blocks_and_camera_stay_fixed_when_avatar_rotates',THEME+DATA+PREVIEW+r'''
local view=Instance.new('ViewportFrame');view.Size=UDim2.fromOffset(340,430);view.Parent=pg;local c=Preview.Mount(view,S.Current,'R15',{floor=true,drag=true});flush()
local block=named(view,'GraphiteStudioBlock');assert(block and block.Material==Enum.Material.SmoothPlastic);local before=block.CFrame;local camera=c.Camera.CFrame;local pivot=c.Model:GetPivot();c.Rotate(90)
assert(block.CFrame==before and(c.Camera.CFrame.Position-camera.Position).Magnitude<.0001 and(c.Camera.CFrame.LookVector-camera.LookVector).Magnitude<.0001 and(c.Model:GetPivot().LookVector-pivot.LookVector).Magnitude>.5 and view.BackgroundColor3.R<.3)
return 'the preview uses real local 3D geometry with a graphite backdrop; dragging rotates the avatar alone without orbiting the floor, camera or studio blocks'
''')
PHOTO=THEME+DATA+PREVIEW+module('07P0_STUDIO_PRESETS')+module('07P3_POSE_EDITOR')+module('07P6_STUDIO_SETS')+module('07P2_STUDIO_AVATAR')+module('07P4_STUDIO_UI')
case('photo_framing_uses_free_width_once_and_cleans_to_center',PHOTO+r'''
local s=Modules['07P2_STUDIO_AVATAR'];assert(s.Enter());local cam=s.Camera;cam.ViewportSize=Vector2.new(1000,500);s.Margins={80,54,320,8};s.Fit();local cf=s.CameraBounds.cf;local distance=(cam.CFrame.Position-cf.Position).Magnitude
local size=s.CameraBounds.size;local t=math.tan(math.rad(s.FOV)*.5);local oldWidth=1000-2*320;local oldDistance=math.max(size.Y*.5*1.08/(t*(500-62)/500),size.X*.5*1.08/(t*oldWidth/500))+size.Z*.5
assert(distance<oldDistance+1);s.SetMargins(0,0,0,0);assert(math.abs(s.Camera.CFrame.Position.X-cf.Position.X)<.001);s.Exit()
return 'the photo camera uses left/right available width once rather than twice; hiding the interface returns the composition to the actual center'
''')
case('photo_tools_collapse_and_catalog_emote_pause_speed_reuse_same_copy',PHOTO+module('07P11_EMOTE_RESOLVER')+r'''
local u=Modules['07P4_STUDIO_UI'].Build(pl);u.Root.Visible=true;u.Layout();assert(u.Nav.Visible);u.ToolsToggle.Activated:Fire();assert(not u.Nav.Visible);u.ToolsToggle.Activated:Fire();assert(u.Nav.Visible)
local s=Modules['07P2_STUDIO_AVATAR'];assert(s.Enter());local rpc=Instance.new('RemoteFunction');rpc.Name='Request';rpc.Parent=rep.LMShop_Remotes;emote66(501,7777);function rpc:InvokeServer(a,d)return{ok=true,data=Modules['07P11_EMOTE_RESOLVER'].Resolve(pl,d)}end
assert(s.PlayEmote(501));local copy=s.Model;local track=s.Track;assert(s.PauseEmote());assert(track.speed==0);s.SetEmoteSpeed(1.5);assert(track.speed==0);local ok,paused=s.PauseEmote();assert(ok and not paused and track.speed==1.5 and s.Model==copy);s.Exit()
return 'tools can be hidden independently and a real resolved emote pauses/resumes at the chosen speed on the same copied avatar'
''')
TRUCO=THEME+DATA+module('07K6_CARD_CATALOG')+module('07K7_CARD_STYLES')+module('07K0_TRUCO_RULES')+module('07K15_TRUCO_TABLE')+module('07H8_PLAY_SESSION')+module('07K5_TRUCO_UI')
case('truco_context_actions_keep_legal_responses_and_ten_second_decision',TRUCO+r'''
local actions={};local gui=D and D.New('ScreenGui',{},pg)or Instance.new('ScreenGui');gui.Parent=pg
local u=Modules['07K5_TRUCO_UI'].Build(gui,function(a,v)actions[#actions+1]={a,v}end)
local v={seat=1,variant='Paulista',score={1,2},phase='play',turn=1,hand={{rank='3',suit='S'},{rank='A',suit='H'},{rank='K',suit='D'}},players={{uid=123,name='Me'},{uid=2,name='Rival'},{uid=3,name='Partner'},{uid=4,name='Other'}},tableCards={},tricks={},lastTrick={},counts={3,3,3,3},value=1,nextRaise=3,handNumber=1,remaining=10,dealer=4}
u.Update(v,{equipped='Classic'});u.PlayOwned(3);assert(actions[#actions][1]=='play'and actions[#actions][2]==3)
u.MoreActions.Activated:Fire();assert(u.Secondary.Visible);u.Raise.Activated:Fire();assert(actions[#actions][1]=='raise')
v.phase='raise';v.pending={team=2,value=3};u.Update(v,{});assert(u.Dialog.Visible and not u.Secondary.Visible);local accept;for _,b in ipairs(u.Options:GetChildren())do if b.Text=='Aceitar'then accept=b end end;assert(accept);accept.Activated:Fire();assert(actions[#actions][1]=='respond'and actions[#actions][2]=='accept');advance60(11);u.Tick();assert(not accept.Active)
return 'the compact interface can play any owned card, raise and accept with unchanged rule actions; the contextual panel gives the real ten-second response window and then disables expired choices'
''')
PRIVATE=DATA+module('09B11_DATA_BUDGET')+module('09B12_PRIVATE_LOOKS')
case('saved_avatar_updates_do_not_drop_catalog_bookmarks',PRIVATE+r'''
StoreData.AvatarShop08_Private_v1.u_123={version=1,skins={{id='s',body=A.Copy(S.Current)}},catalogFavorites={{Id=1234,Name='A piece',ItemType='Asset'}}}
local p=Modules['09B12_PRIVATE_LOOKS'];local d=assert(p.Load(pl));assert(#d.catalogFavorites==1)
p.Update(pl,function(old)old.skins[1].name='Renamed';return old end);local saved=StoreData.AvatarShop08_Private_v1.u_123;assert(saved.catalogFavorites[1].Id==1234 and saved.skins[1].name=='Renamed')
return 'favorite pieces live in the existing private store and survive unrelated avatar save/rename operations without a new product or a new store'
''')
case('actual_shop_client_home_browse_emotes_and_utility_switch_close_new_panels',HOME+"installModule('09C4_OUTFIT_LIBRARY',[====[return {}]====])\n"+module('09C3_CATALOG_FILTERS')+module('09C2_SHOP_CATALOG')+module('09C10_CONFIRM_ACTION')+r'''
Modules['09A_SHOP_UI']={VERSION='V44_STUDIO_UI',Build=function()return U end};local obj=Instance.new('ModuleScript');obj.Name='09A_SHOP_UI';obj.Parent=rep
local function stub(name,value)Modules[name]=value;local o=rep:FindFirstChild(name);if not o then o=Instance.new('ModuleScript');o.Name=name;o.Parent=rep end end
stub('09C4_OUTFIT_LIBRARY',{VERSION='V58',Init=function()end,Add=function()end,Open=function()end})
stub('09C14_NEW_AVATAR',{Build=function()end});stub('09C1_SHOP_LOOKS',{Init=function()return{Saved=function()end,Community=function()end,ShowLook=function()end}end});stub('09C5_UGC_STORES',{Init=function()return{Search=function()end}end});stub('09C9_PLAYER_INSPECT',{Init=function()end})
local searches=0;function Services.AvatarEditorService:SearchCatalogAsync(params)searches=searches+1;return{IsFinished=true,GetCurrentPage=function()return{}end}end
local rpc=Instance.new('RemoteFunction');rpc.Name='Request';rpc.Parent=rep.LMShop_Remotes;function rpc:InvokeServer(a,d)return{ok=true,data=true}end
'''+src('09C_SHOP_CLIENT')+r'''
flush();U.OpenRequest:Fire('Catalog');flush();assert(U.CatalogHome.Visible and not U.Grid.Visible and searches==0)
named(U.CatalogHome,'HomeHair').Activated:Fire();flush();assert(not U.CatalogHome.Visible and U.Grid.Visible and searches==1)
U.ToolsButton.Activated:Fire();assert(U.AvatarTools.Visible);U.OpenRequest:Fire('Looks');assert(not U.AvatarTools.Visible and U.LooksArea.Visible)
U.OpenRequest:Fire('Catalog');assert(U.CatalogHome.Visible and searches==1);U.OpenRequest:Fire('Emotes');flush();assert(not U.CatalogHome.Visible and U.Grid.Visible and searches==2)
return 'the actual LocalScript opens categories without querying, browses the chosen category, preserves the direct emote route and closes the new tools when switching pages'
''')
case('photo_and_accessory_tools_have_safe_closes_and_minimum_touch_targets',PHOTO+r'''
local u=Modules['07P4_STUDIO_UI'].Build(pl);u.Root.Visible=true
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;u.Layout()
 for _,b in ipairs({u.Close,u.ToolsToggle,u.Buttons.Hide})do inside(b,u.Root);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44)end
 for key,b in pairs(u.Buttons)do if key~='Hide'then inside(b,u.Nav);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44)end end
 u.Popup.Visible=true;u.Layout();inside(u.PopupClose,u.Popup);assert(u.PopupClose.AbsoluteSize.X==48);u.Popup.Visible=false
end
return 'all seven photo tool entries, independent menu toggle and modal closes remain safe in portrait, landscape with cutouts and desktop layouts'
''')
HERE.joinpath('v68_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
