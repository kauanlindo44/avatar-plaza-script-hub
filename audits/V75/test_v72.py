from test_support import *
SIZES="{{320,568,0,0,0},{390,844,0,0,34},{568,320,0,0,0},{667,375,0,0,0},{851,392,44,44,21},{1280,720,0,0,0},{1920,1080,0,0,0}}"
CONTRACT=module('09I0_ASSISTANT_CONFIG')+module('09I21_LOOK_CONTRACT')
case('plans_effort_and_mandatory_body_contract_cannot_be_bypassed',CONTRACT+r'''
local c=Modules['09I21_LOOK_CONTRACT'];assert(c.Options({count=99,effort='Max'},'Normal').count==1 and c.Effort('Max','Normal').id=='Padrao');assert(c.Options({count=99},'Studio').requestedCount==5)
local p=c.Options({count=12,bodyMode='bundle',bodyId=123,effort='Max'},'Pro');assert(p.count==5 and p.requestedCount==12 and p.bodyRequired and p.effort=='Max'and c.Check(p))
p.bodyId=0;assert(not c.Check(p));p.bodyMode='search';assert(not c.Check(p));p=c.Options({bodyMode='blank',baseRig='R6',topType='ShirtAccessory'},'Pro');assert(not c.Check(p))
p=c.Options({hairMode='none',fixed={hair=999}},'Pro');assert(not c.Check(p));p=c.Options({hairMode='required'},'Pro');p.excluded={'HairAccessory'};assert(not c.Check(p));p=c.Options({fixed={top=600}},'Pro');p.scope='Cabelo';assert(not c.Check(p));assert(Modules['09I0_ASSISTANT_CONFIG'].Seconds==30*24*60*60)
return 'server sanitizes each plan, restricts paid effort, rejects unconfirmed bodies and incompatible R6/layers or contradictory required pieces; existing products and 30-day duration retained'
''')
AI=THEME+DATA+CONTRACT+module('09I1_ASSISTANT_ACCOUNTS')+module('09I13_OUTFIT_SEARCH')+module('09I3_OUTFIT_BUILDER')
FIX=r'''
local B=Modules['09I3_OUTFIT_BUILDER'];local calls=0;local pool={}
Modules['08B4_AVATAR_LOAD'].Create=function()return Instance.new('Model')end
function Services.AvatarEditorService:SearchCatalogAsync(p)calls=calls+1;local key=p.AssetTypes[1].Name;return{IsFinished=true,GetCurrentPage=function()return deep(pool[key]or{})end}end
local function piece(kind,id,name,price)local row=fixture60(id,name,kind);row.Price=price;pool[kind]=pool[kind]or{};pool[kind][#pool[kind]+1]=row;return row end
'''
case('exact_body_is_required_reserved_in_budget_and_never_silently_replaced',AI+FIX+r'''
local body=A.Copy(S.Current);body.props.Torso=777;local n=0
Modules['09B14_AVATAR_BASES'].Catalog=function(pl,args)n=n+1;assert(args.id==500);return{id=500,name='Exact body',price=60,body=body,rig='R15'}end
fixture60(500,'Exact body',nil,'Bundle').Price=60;piece('Shirt',501,'blue shirt',20);piece('Pants',502,'blue pants',20)
local opts=B.Options({bodyMode='bundle',bodyId=500,budget=100,color='blue',count=1},'Normal');local stage={};local rows=assert(B.Build(pl,'blue',opts,S.Current,function(n,t,s)if s then stage[s.part]=s.state end end,function()return true end))
assert(rows[1].body.props.Torso==777 and rows[1].total==100 and rows[1].bodyId==500 and stage.body=='done'and stage.top=='done'and stage.hair=='skipped')
opts.budget=50;local old=calls;assert(not B.Build(pl,'blue',opts,S.Current,function()end,function()return true end));assert(calls==old)
Modules['09B14_AVATAR_BASES'].Catalog=function()return nil,'body unavailable'end;assert(not B.Build(pl,'blue',opts,S.Current,function()end,function()return true end))
return 'the confirmed bundle is resolved before garments, retains its body parts, consumes its real 60-Robux cost and fails explicitly when missing or over budget; absent optional hair is never marked complete'
''')
case('exact_clothing_id_type_and_piece_query_do_not_fall_back_to_another_request',AI+FIX+r'''
piece('Shirt',601,'blue ordinary shirt',5);piece('Pants',602,'blue pants',5);fixture60(603,'blue exact tee','TShirt').Price=5
local opts=B.Options({budget=10,topType='TShirt',fixed={top=603},color='blue'},'Normal');local rows=assert(B.Build(pl,'blue',opts,S.Current,function()end,function()return true end));assert(rows[1].body.props.GraphicTShirt==603 and rows[1].body.props.Shirt==0)
opts=B.Options({budget=10,topType='Shirt',fixed={top=603}},'Normal');assert(not B.Build(pl,'blue',opts,S.Current,function()end,function()return true end))
opts=B.Options({budget=10,pieceQueries={top='naruto'}},'Normal');local r,e=B.Build(pl,'blue',opts,S.Current,function()end,function()return true end);assert(not r and e:find('parte de cima',1,true))
return 'a required classic tee is a GraphicTShirt rather than a Shirt; a wrong exact type or missing specific per-piece subject fails instead of filling with an unrelated garment'
''')
case('four_step_form_confirms_body_and_advanced_type_without_automatic_send',THEME+DATA+PREVIEW+module('09I4_ASSISTANT_UI')+module('09I5_ASSISTANT_QUESTIONNAIRE')+r'''
local u=Modules['09I4_ASSISTANT_UI'].Build(pl);u.Root.Visible=true;local sent;local exact=A.Copy(S.Current);exact.props.Torso=888
local q=Modules['09I5_ASSISTANT_QUESTIONNAIRE'].Build(u,function(v)sent=v end,function(action,args)assert(action=='body.catalog');if args.id then return{id=700,name='My chosen body',price=40,body=exact,rig='R15'}end;return{{id=700,name='My chosen body',price=40}}end)
q.Open('Pro','12 looks streetwear azul até 100 Robux');assert(q.CustomCount.Text=='12'and q.Options.requestedCount==12 and not sent and q.Step==1)
q.Body.Activated:Fire();flush();named(q.BodyChooser.Grid,'ChooseBody_700').Activated:Fire();flush();q.BodyChooser.Confirm.Activated:Fire();assert(q.Options.bodyMode=='bundle'and q.Options.bodyId==700)
q.Step=4;q.Advanced=true;q.Layout();q.Top.Activated:Fire();named(q.Choices.Root,'Choice_TShirt').Activated:Fire();q.Fixed.top.Text='900';q.Confirm.Activated:Fire()
assert(sent and sent.bodyId==700 and sent.confirmed and sent.requestedCount==12 and sent.topType=='TShirt'and sent.fixed.top==900 and sent.color=='blue'and not q.Shade.Visible)
return 'visual body selection and advanced exact clothing IDs survive confirmation of all four stages; no catalog generation starts before the explicit confirmation'
''')
SERVERAI=AI+module('09I11_CONVERSATIONS')+module('09I2_ASSISTANT_ENGINE')+r'''
Modules['09B5_AVATAR_RUNTIME']={Description=function()return HUM,HUM:GetAppliedDescription()end};local o=Instance.new('ModuleScript');o.Name='09B5_AVATAR_RUNTIME';o.Parent=rep
local reserves,refunds=0,0;local plan='Pro';local sizes={};local acct=Modules['09I1_ASSISTANT_ACCOUNTS'];acct.View=function()return{plan=plan,owner=123,storageAvailable=true}end;acct.Reserve=function()reserves=reserves+1;return{plan=plan,owner=123}end;acct.Refund=function()refunds=refunds+1;return true end
Modules['09I3_OUTFIT_BUILDER'].Build=function(pl,word,opts,body,progress,alive)local out={};sizes[#sizes+1]=opts.count;for i=1,opts.count do out[#out+1]={name='look',body=A.Copy(body),rig='R15',items={},missing={}}end;return out end
'''+src('09I_ASSISTANT_SERVER')+r'''
local rpc=rep.ACP_AssistantRemotes.Request;local function rpcCall(a,d)advance60(1);local r=rpc.OnServerInvoke(pl,a,d or{});flush();return r end
local function lastResult()local r;for _,sent in ipairs(rep.ACP_AssistantRemotes.Progress.sent)do local p=type(sent.kind)=='table'and sent.kind or sent.data;if p and p.kind=='result'then r=p.data end end;return r end
'''
case('pro_continues_requested_quantity_in_five_five_two_without_extra_daily_charge',SERVERAI+r'''
assert(rpcCall('ask',{text='Quero 12 looks azuis',make=true,request='one',options={budget=100,count=12,confirmed=true,color='blue'}}).ok);local r=lastResult();assert(r.count==5 and r.target==12 and r.completed==5 and r.batch)
assert(rpcCall('more',{batch=r.batch,request='two'}).ok);r=lastResult();assert(r.completed==10 and r.batch)
assert(rpcCall('more',{batch=r.batch,request='three'}).ok);r=lastResult();assert(r.completed==12 and r.count==2 and not r.batch and reserves==1 and refunds==0 and sizes[3]==2)
return 'the actual remote server creates 5 + 5 + 2, charges one request, never reverts the last batch to five and gives each result a session-bound key'
''')
case('pro_continuation_rejects_expired_access_or_cancelled_job_and_prompt_does_not_grant',SERVERAI+r'''
assert(rpcCall('ask',{text='Quero 12 looks',make=true,request='one',options={budget=100,count=12,confirmed=true}}).ok);local r=lastResult();plan='Normal';assert(not rpcCall('more',{batch=r.batch,request='blocked'}).ok)
plan='Pro';assert(rpcCall('ask',{text='Quero 12 looks',make=true,request='new',options={budget=100,count=12,confirmed=true}}).ok);r=lastResult();assert(rpcCall('newchat').ok);assert(not rpcCall('more',{batch=r.batch,request='old'}).ok)
local products={};function Services.MarketplaceService:GetProductInfoAsync(id,kind)return{IsForSale=true,PriceInRobux=1}end;function Services.MarketplaceService:PromptProductPurchase(p,id)products[#products+1]=id end
assert(rpcCall('prompt',{plan='Plus'}).ok and products[1]==3717699383 and plan=='Pro');assert(not rpcCall('prompt',{plan='Invented'}).ok)
return 'a batch belongs to a live Pro entitlement and current conversation; cancellation invalidates it; an upgrade uses the existing product and cannot grant access from the prompt callback'
''')
case('new_avatar_wizard_is_preview_only_until_final_step_and_hair_is_real_accessory',UI+DATA+PREVIEW+module('09I22_BODY_CHOOSER')+module('09C14_NEW_AVATAR')+r'''
U.Root.Visible=true;local before=A.Copy(S.Current);local w=Modules['09C14_NEW_AVATAR'].Build({U=U,call=function()return true end,toast=function()end});w.Open();named(w.Controls,'Base_R6').Activated:Fire();named(w.Controls,'Tone_9').Activated:Fire();assert(S.Current.props.Shirt==before.props.Shirt)
for i=1,3 do w.Confirm.Activated:Fire()end;assert(w.Step==4 and S.Current.props.Shirt==before.props.Shirt);w.Confirm.Activated:Fire();assert(S.Rig=='R6'and S.Current.props.Shirt==0);assert(S.Undo())
w.Open();w.Hair=987;w.Base='R15';w.Render();w.Step=4;w.Confirm.Activated:Fire();local found=false;for _,a in ipairs(S.Current.accessories)do if a.id==987 and a.type=='Hair'then found=true end end;assert(found)
return 'body/tone/hair/scale form keeps drafts separate, only the fourth-step confirmation calls skin state, Undo restores the previous look and hair uses the native accessory schema'
''')
SAVE=UI+DATA+PREVIEW+module('09C18_AVATAR_SAVE')
case('save_outfit_and_account_prompts_report_only_native_completed_result',SAVE+r'''
U.Root.Visible=true;local notices={};local w=Modules['09C18_AVATAR_SAVE'].Build({U=U,A=A,S=S,call=function()return true end,toast=function(v)notices[#notices+1]=v end,buyBody=function()end})
w.Open();named(w.Options,'AvatarSaveChoice2').Activated:Fire();assert(Services.AvatarEditorService.LastOutfit and not w.Note.Text:find('salva na',1,true));Services.AvatarEditorService.PromptCreateOutfitCompleted:Fire(Enum.AvatarPromptResult.PermissionDenied);assert(w.Note.Text:find('não confirmou',1,true))
named(w.Options,'AvatarSaveChoice3').Activated:Fire();assert(Services.AvatarEditorService.LastSave);Services.AvatarEditorService.PromptSaveAvatarCompleted:Fire(Enum.AvatarPromptResult.Success);assert(w.Note.Text:find('atualizado',1,true))
return 'outfit creation and saving the Roblox account avatar are distinct native prompts; denied/cancelled requests never say saved, while only Success confirms completion'
''')
case('catalog_purchase_history_requires_native_completion_and_ownership_and_batches_writes',DATA+r'''
local m=Modules['09B13_PURCHASE_HISTORY'];m.Start();function Services.MarketplaceService:PlayerOwnsAssetAsync(p,id)return id==44 end
Services.MarketplaceService.PromptPurchaseFinished:Fire(pl,43,true);Services.MarketplaceService.PromptPurchaseFinished:Fire(pl,44,false);flush();assert(#m.List(pl).rows==0)
local before=DSCalls64.writes;Services.MarketplaceService.PromptPurchaseFinished:Fire(pl,44,true);flush();assert(#m.List(pl).rows==1 and DSCalls64.writes==before);Services.RunService.Heartbeat:Fire(46);flush();assert(DSCalls64.writes==before+1)
local other=makePlayer(456);assert(#m.List(other).rows==0)
return 'server records only a completed and ownership-confirmed native catalog purchase, isolates users and batches persistence instead of writing on each UI open'
''')
PHOTO=THEME+DATA+PREVIEW+module('07P0_STUDIO_PRESETS')+module('07P6_STUDIO_SETS')+module('07P3_POSE_EDITOR')+module('07P2_STUDIO_AVATAR')+module('07P4_STUDIO_UI')
case('animation_pack_resolves_specific_native_clip_and_reuses_copied_avatar',PHOTO+module('07P11_EMOTE_RESOLVER')+r'''
emote66(901,11001);emote66(902,11002);NativeInfo60[901].AssetTypeId=Enum.AvatarAssetType.IdleAnimation.Value;NativeInfo60[902].AssetTypeId=Enum.AvatarAssetType.WalkAnimation.Value
NativeItems60['Bundle:900']={BundleType='Animations',Items={{Id=901,Type='Asset'},{Id=902,Type='Asset'}}}
local m=Modules['07P11_EMOTE_RESOLVER'];local one=m.Resolve(pl,{id=900,bundle=true,slot='IdleAnimation'});advance60(1);local two=m.Resolve(pl,{id=900,bundle=true,slot='WalkAnimation'});assert(one.animation=='rbxassetid://11001'and two.animation=='rbxassetid://11002')
local rpc=Instance.new('RemoteFunction');rpc.Name='Request';rpc.Parent=rep.LMShop_Remotes;function rpc:InvokeServer(a,args)advance60(1);return{ok=true,data=m.Resolve(pl,args)}end
local s=Modules['07P2_STUDIO_AVATAR'];assert(s.Enter());local model=s.Model;assert(s.PlayEmote(900,{bundle=true,slot='IdleAnimation'}));assert(s.PlayEmote(900,{bundle=true,slot='WalkAnimation'})and s.Model==model and s.AnimationUri==two.animation);s.Exit()
return 'a real bundle is validated as Animations, idle/walk use separate cache keys and tracks change on the same photo clone instead of rebuilding the avatar'
''')
case('photo_background_selection_survives_reopen_and_visual_effects_are_local',PHOTO+r'''
local s=Modules['07P2_STUDIO_AVATAR'];assert(s.Enter());local main=pl.Character;assert(s.BuildSet({id=12,source='RobloxCatalog',preview=true,image='rbxassetid://12'}));s.HidePart('Head');assert(pl.Character==main);function s.Model:Clone()return Services.Players:CreateHumanoidModelFromDescriptionAsync(HUM:GetAppliedDescription(),Enum.HumanoidRigType.R15)end;assert(s.CloneAvatar());s.Exit();assert(s.Enter()and s.Background==12 and #s.Copies==0);s.Exit()
return 'the selected approved Roblox background is restored next time; head/body effects and clones live only in the disposable photo scene and never change the map avatar'
''')
case('photo_catalog_is_real_grid_and_click_targets_test_copy_or_prompt_purchase',PHOTO+module('07P9_STUDIO_CATALOG')+r'''
local u=Modules['07P4_STUDIO_UI'].Build(pl);u.Root.Visible=true;u.Popup.Visible=true;local selected;function Services.AvatarEditorService:SearchCatalogAsync(p)return{IsFinished=true,GetCurrentPage=function()return{fixture60(980,'Dance','EmoteAnimation')}end}end
Modules['07P9_STUDIO_CATALOG'].Open(u,'Animations',function(v)selected=v end,function()end,{pause=function()return true,true end,speed=function()end});flush();local list=named(u.Content,'StudioCatalogItems');assert(named(list,'StudioCatalog_980').AbsoluteSize.X>=44);named(list,'StudioCatalog_980').Activated:Fire();assert(selected.Id==980 and not selected.IsAnimationPack)
local buy=named(u.Content,'BuySelectedStudioItem');buy.Activated:Fire();flush();assert(LastPrompt.id==980)
return 'catalog data comes from native search, five-column cards test the copied avatar; the independent selected-item purchase opens the official prompt'
''')
case('preview_width_and_two_row_shelves_fit_seven_safe_geometries',UI+DATA+PREVIEW+r'''
U.Root.Visible=true;U.ShowPreview()
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;U.Layout()
 assert(U.Viewport.AbsoluteSize.X>=U.PreviewShell.AbsoluteSize.X-1 and U.ItemStrip.Visible);inside(U.ToolsButton or U.Apply,U.Root);assert(U.ItemStrip.AbsoluteSize.Y>=44)
 for _,b in ipairs({U.Apply,U.Save,U.Reset,U.BuyLook,U.BodyToggle})do inside(b,U.Actions);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44)end
end
return 'preview no longer sacrifices a 48–96-pixel rail; the full-width avatar, five actions and equipped strip remain inside the safe layout on seven sizes'
''')
case('assistant_progress_stop_and_sidebar_upgrade_remain_reachable',THEME+DATA+PREVIEW+module('09I4_ASSISTANT_UI')+r'''
local u=Modules['09I4_ASSISTANT_UI'].Build(pl);u.Root.Visible=true;local p=Modules['09I23_REQUEST_PROGRESS'].Build(u);local cancelled=false;u.OnCancelRequest=function()cancelled=true end
p.Busy(true);p.Update({label='Procurando cabelo',stage={part='hair',state='searching'}});assert(p.Rows.hair.Text:sub(1,3)~='✓');p.Update({label='Cabelo confirmado',stage={part='hair',state='done'}});assert(p.Rows.hair.Text:find('✓',1,true));p.Stop.Activated:Fire();assert(cancelled)
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;u.MenuOpen=true;u.Layout();if u.Upgrade.Visible then inside(u.Upgrade,u.Tabs);assert(not intersects(u.Upgrade,u.TabButtons.Perfil))end end
return 'stage success reflects an explicit done event, stop dispatches cancellation and Plus/Pro is reachable at the sidebar footer without covering the account button'
''')
case('request_novelty_survives_batches_without_unbounded_signature_storage',AI+FIX+r'''
for i=1,5 do piece('Shirt',100+i,'blue shirt '..i,5);piece('Pants',200+i,'blue pants '..i,5)end
local seen={};local first=assert(B.Build(pl,'blue',B.Options({budget=10},'Normal'),S.Current,function()end,function()return true end,seen))[1]
Modules['09I1_ASSISTANT_ACCOUNTS'].Novelty=function()return{}end
local second=assert(B.Build(pl,'blue',B.Options({budget=10},'Normal'),S.Current,function()end,function()return true end,seen))[1];assert(first.signature~=second.signature)
local a,b=0,0;for _ in pairs(seen.a)do a=a+1 end;for _ in pairs(seen.b)do b=b+1 end;assert(a<=8191 and b<=8179)
return 'two batches cannot repeat the same outfit even if the recent-account history is absent; the request uses bounded duplicate filters rather than an unlimited array of all results'
''')
SPONSOR=UI+DATA+PREVIEW+module('07UI_PAN_GRID')+module('09C10_SPONSOR_DESIGN')+module('09C11_SPONSOR_FEED')+module('09C9_SPONSOR_PICKER')+module('09C12_DESTINATION_BROWSER')+module('09C5_UGC_STORES')
HERE.joinpath('v72_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
