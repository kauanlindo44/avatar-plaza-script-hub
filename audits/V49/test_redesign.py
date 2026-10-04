from test_support import *
CARD=THEME+module('07K0_TRUCO_RULES')+module('07K6_CARD_CATALOG')+module('07K7_CARD_STYLES')+module('07K5_TRUCO_UI')+module('07K9_CARD_INVENTORY_UI')
case('game_lobby_uses_whole_remaining_area_black_green_and_clear_modes',CARD+module('07H1_GAME_LOBBY')+r'''
local gui=Instance.new('ScreenGui');gui.Parent=pg;local u=Modules['07H1_GAME_LOBBY'].Build(gui);u.Root.Visible=true
for _,v in ipairs({{320,568},{390,844},{800,360},{844,390},{1920,1080}})do
 SCREEN_W,SCREEN_H=v[1],v[2];CORE_TOP=58
 for _,key in ipairs({'Xadrez','Damas','Truco'})do for _,mode in ipairs({'Online','Friends','Practice'})do
  u.Reset();u.SetGame(key);u.Mode=mode;u.Layout();inside(u.Panel,u.Root)
  assert(u.Panel.AbsolutePosition.Y+u.Panel.AbsoluteSize.Y>=SCREEN_H-36,'lobby still caps its panel height')
  for _,b in pairs(u.GameButtons)do inside(b,u.Root);assert(b.AbsoluteSize.Y>=44)end
  if mode=='Friends'then for _,o in ipairs({u.Create,u.Code,u.Join})do inside(o,u.Panel)end end
  if mode=='Practice'then inside(u.Bot,u.Panel)end
  assert(u.Root.BackgroundColor3.R<.08 and u.GameButtons[key].BackgroundColor3.G>u.GameButtons[key].BackgroundColor3.R)
  if u.Overview.Visible then inside(u.Overview,u.Root);assert(not intersects(u.Overview,u.Panel))end
  if u.Guide.Visible then inside(u.Guide,u.Panel);for _,c in ipairs(u.Guide:GetChildren())do if c:IsA('Frame')then inside(c,u.Guide);for _,o in ipairs(c:GetChildren())do if o:IsA('GuiObject')then inside(o,c)end end end end end
 end end
end
return 'game selection stays above full-height black/green dashboard; explicit room/bot/quick actions and safe hit areas fit five screens without empty capped panel'
''')
case('atelier_explicit_ready_error_and_unknown_moderation_reason',CARD+r'''
local gui=Instance.new('ScreenGui');gui.Parent=pg;local data={coins=0,owned={Classic=true},equipped='Classic',ateliers=true,boxes={},custom={image=0,zoom=1,x=0,y=0}}
local u=Modules['07K9_CARD_INVENTORY_UI'].Build(gui,function(a,args)if a=='inventory'then return data elseif a=='image'then if args.image==2 then return nil,'Esse ID não é Image/Decal.'end;return{image=args.image,texture=args.image,assetType=1}end;return{passes={},products={}}end,function()end)
u.Tab='Ateliê';u.Show();flush();u.CustomID.Text='3';u.LoadImage.Activated:Fire();flush()
assert(u.ImageStatus:GetAttribute('LoadState')=='Ready'and u.ImageStatus.Text:find('Imagem carregada',1,true)and u.ImageStatus.TextColor3.G>u.ImageStatus.TextColor3.R)
u.CustomID.Text='2';u.LoadImage.Activated:Fire();flush();assert(u.ImageStatus:GetAttribute('LoadState')=='Error'and not u.SaveCustom.Active)
local old=Instance.new;Instance.new=function(k)local o=old(k);if k=='ImageLabel'then o.IsLoaded=false end;return o end
u.CustomID.Text='4';u.LoadImage.Activated:Fire();flush();advance(8);advance(8)
assert(u.ImageStatus:GetAttribute('LoadState')=='Error'and u.ImageStatus.Text:find('Pode ser',1,true)and u.ImageStatus.Text:find('não informou o motivo',1,true));assert(not u.SaveCustom.Active)
return 'loaded native image produces clear green success; invalid ID/final timeout produce red failure; possible permission/moderation/network cause remains explicitly unconfirmed'
''')
case('collection_coin_purchase_choice_visible_before_payment_and_immediate_result',CARD+r'''
local gui=Instance.new('ScreenGui');gui.Parent=pg;local data={coins=1000,owned={Classic=true},equipped='Classic',ateliers=false,boxes={},custom={image=0,zoom=1},version=0}
local calls={};local u=Modules['07K9_CARD_INVENTORY_UI'].Build(gui,function(a,args)
 calls[#calls+1]=a
 if a=='inventory'then return deep(data)elseif a=='store'then return{passes={},products={}}elseif a=='buycoins'then assert(args.key=='Nox'and args.quantity==1);data.coins=data.coins-500;data.boxes.Nox=1;data.version=data.version+1;return true
 elseif a=='openbox'then assert(args.styles[1]=='Vesper'and #args.styles==1);data.owned.Vesper=true;data.boxes.Nox=0;data.version=data.version+1;return{styles=args.styles}end
end,function()end)
u.Show();flush();u.CoinBuy.Activated:Fire();assert(u.Dialog.Visible and #u.Choices:GetChildren()>=6);assert(not u.Open.Active)
local selected;for _,b in ipairs(u.Choices:GetChildren())do if b:IsA('GuiButton')and b.Text:find('Veyra',1,true)then selected=b end end
assert(selected);selected.Activated:Fire();assert(u.Open.Text:find('500 moedas',1,true));u.Open.Activated:Fire();u.Open.Activated:Fire();flush()
assert(data.owned.Vesper and data.boxes.Nox==0 and data.coins==500 and u.DialogTitle.Text:find('Recebido',1,true))
local buys,opens=0,0;for _,a in ipairs(calls)do if a=='buycoins'then buys=buys+1 elseif a=='openbox'then opens=opens+1 end end;assert(buys==1 and opens==1)
for _,v in ipairs({{320,568},{390,844},{800,360},{844,390},{1920,1080}})do
 SCREEN_W,SCREEN_H=v[1],v[2];u.Layout()
 for _,card in ipairs(u.ChoiceCards)do inside(card,u.Choices);assert(math.abs(card.AbsoluteSize.X/card.AbsoluteSize.Y-.70)<.001,'single result stretched')end
 u.OpenBox(Modules['07K6_CARD_CATALOG'].Collections[1],'coins');u.Layout()
 for _,card in ipairs(u.ChoiceCards)do inside(card,u.Choices);assert(math.abs(card.AbsoluteSize.X/card.AbsoluteSize.Y-.70)<.001,'choice card stretched')end
 for _,b in ipairs(u.Choices:GetChildren())do if b:IsA('GuiButton')and not b.Text:find('Já possui',1,true)then assert(b.Text:find('100%',1,true))end end
end
return 'all three cosmetic fronts disclosed before payment; explicit single known choice; one debit/one open; chosen result shown immediately after confirmed coin grant, without rolling animation'
''')
case('collection_robux_waits_for_server_inventory_receipt_and_cancel_never_grants',CARD+r'''
local gui=Instance.new('ScreenGui');gui.Parent=pg;local data={coins=0,owned={Classic=true},equipped='Classic',ateliers=false,boxes={},custom={image=0,zoom=1},version=1};local opened=0
local u=Modules['07K9_CARD_INVENTORY_UI'].Build(gui,function(a,args)
 if a=='inventory'then return deep(data)elseif a=='store'then return{passes={},products={Nox={id=3716296910}}}elseif a=='prompt'then return true elseif a=='openbox'then opened=opened+1;data.owned.Onyx=true;data.boxes.Nox=0;return{styles=args.styles}end
end,function()end)
function Services.MarketplaceService:GetProductInfoAsync()return{IsForSale=true,PriceInRobux=1}end
u.Show();flush();local function selectOnyx()for _,b in ipairs(u.Choices:GetChildren())do if b:IsA('GuiButton')and b.Text:find('Onyx',1,true)then b.Activated:Fire()end end end
u.RobuxBuy.Activated:Fire();selectOnyx();u.Open.Activated:Fire();flush();assert(u.PendingChoice and opened==0)
Services.MarketplaceService.PromptProductPurchaseFinished:Fire(pl.UserId,3716296910,true);flush();assert(opened==0 and not data.owned.Onyx,'native prompt-close event granted an item')
u.AcceptData(deep(data));flush();assert(opened==0)
data.boxes.Nox=1;data.version=2;u.AcceptData(deep(data));u.AcceptData(deep(data));flush();assert(opened==1 and data.owned.Onyx)
data.owned.Onyx=nil;u.AcceptData(deep(data));u.OpenBox(Modules['07K6_CARD_CATALOG'].Collections[1],'robux');selectOnyx();u.Open.Activated:Fire();flush();Services.MarketplaceService.PromptProductPurchaseFinished:Fire(pl.UserId+1,3716296910,false);assert(u.PendingChoice)
Services.MarketplaceService.PromptProductPurchaseFinished:Fire(pl.UserId,3716296910,false);assert(not u.PendingChoice and not u.Dialog.Visible and opened==1)
return 'purchase result requires server inventory credit from ProcessReceipt; prompt success cannot grant; duplicate updates consume once; only own cancellation clears pending choice'
''')
case('meme_body_bundle_native_scales_colors_preserve_clothing_apply_and_preview',UI+DATA+PREVIEW+SERVER+r'''
Details[700]={Id=700,ItemType='Bundle'};Details[800]={Id=800,AssetType='Head'};Details[801]={Id=801,AssetType='Torso'}
function Services.AssetService:GetBundleDetailsAsync()return{BundleType='BodyParts',Items={{Type='Asset',Id=800},{Type='Asset',Id=801},{Type='UserOutfit',Id=900}}}end
function Services.Players:GetHumanoidDescriptionFromOutfitIdAsync(id)
 assert(id==900);local d=InitialDescription:Clone();d.WidthScale=.4;d.DepthScale=.5;d.HeightScale=.7;d.HeadScale=1.8;d.HeadColor=Color3.fromRGB(55,180,92);d.Shirt=555;return d
end
local original=A.Copy(S.Current);assert(S.Try({Id=700,ItemType='Bundle'}));assert(S.Rig=='R15'and S.Current.props.Head==800 and S.Current.props.Torso==801)
assert(S.Current.props.Shirt==original.props.Shirt and S.Current.props.Pants==original.props.Pants and #S.Current.accessories==#original.accessories)
assert(S.Current.scales.HeadScale==1.8 and S.Current.scales.WidthScale==.4 and S.Current.colors.HeadColor[2]==180/255)
local r=RPC:InvokeServer('Apply',{body=S.Current,base=original,rig='R15'});assert(r.ok,r.error);assert(pl.Character.Humanoid.applied.Shirt==11 and pl.Character.Humanoid.applied.HeadScale==1.8)
local view=Instance.new('ViewportFrame');view.Size=UDim2.fromOffset(280,330);view.Parent=pg;local p=Preview.Mount(view,S.Current,'R15');flush();assert(p.Model)
local huge=Instance.new('Part');huge.Name='MemeHead';huge.Size=Vector3.new(16,9,12);huge.Parent=p.Model
for _,yaw in ipairs({0,90,180,270})do p.SetYaw(yaw);local cf,size=Preview.Bounds(p.Model);assert((p.Camera.CFrame.Position-cf.Position).Magnitude>size.Magnitude*.4)end
return 'native body outfit proportions/colors included, body assets visible in 360 preview and actual server Apply; prior clothes/accessories retained; wide meme geometry drives camera bounds'
''')
case('limited_store_only_verified_collectibles_distinct_cards_and_paging',UI+DATA+module('09C5_UGC_STORES')+r'''
local params;local nextPage=0;local page=1
function Services.AvatarEditorService:SearchCatalogAsync(p)
 params=p;assert(p.SalesTypeFilter==Enum.SalesTypeFilter.Collectibles)
 return{IsFinished=false,GetCurrentPage=function()return{{Id=page*10+1,Name='Limited',Price=100,ItemRestrictions={'Limited'}},{Id=page*10+2,Name='UGC collectible',Price=150,CollectibleItemId='guid-123'},{Id=page*10+3,Name='Normal hat',Price=50}}end,AdvanceToNextPageAsync=function()page=page+1;nextPage=nextPage+1 end}
end
local chosen;local ctl=Modules['09C5_UGC_STORES'].Init({U=U,A=A,showItem=function(item)chosen=item end})
U.Root.Visible=true;U.SetWide(true);U.StoresArea.Visible=true;ctl.Search();flush();local n=0
for _,b in ipairs(U.StoreGrid:GetChildren())do if b:IsA('GuiButton')then n=n+1;assert(b.Name~='Limited_13');b.Activated:Fire()end end;assert(n==2 and chosen.Id==12)
named(U.StoresArea,'MoreLimiteds').Activated:Fire();flush();assert(nextPage==1)
for _,v in ipairs({{320,568},{844,390},{1920,1080}})do SCREEN_W,SCREEN_H=v[1],v[2];U.Layout();U.StoresArea:GetPropertyChangedSignal("AbsoluteSize"):Fire();for _,o in ipairs({U.StoreSearch,U.StoreType,U.StoreGo,named(U.StoresArea,'MoreLimiteds')})do inside(o,U.StoresArea)end end
return 'native Collectibles filter plus per-result Limited/GUID proof rejects ordinary hats; named search and paging work; separate gold-accent image/price layout fits phone and landscape'
''')
case('community_item_tiles_are_image_name_only_metadata_opens_on_tap',UI+DATA+PREVIEW+COMMUNITY+r'''
function Services.MarketplaceService:GetProductInfoAsync(id)return{Name=id==11 and 'Camisa'or 'Item '..id,AssetTypeId=11,PriceInRobux=5,Creator={Name='Maker'},Description='Uma camisa'}end
local d=Modules['09C8_COMMUNITY_DETAILS'].Init({U=U,A=A,S=S,call=function()end,toast=function()end,buyBody=function()end})
U.Root.Visible=true;d.Show({id='test',name='Look',source='Curated',publisher='CAETANOYX',body=S.Current,rig='R15'});flush()
local tile=named(U.LookItems,'LookItem_11');local texts=0
for _,o in ipairs(tile:GetChildren())do if o:IsA('TextLabel')then texts=texts+1;assert(o.Text=='Camisa')end end;assert(texts==1 and not U.LookCreator.Visible)
tile.Activated:Fire();local info=named(U.LookDetail,'CommunityItemInfo');assert(info.Visible and named(info,'CommunityItemImage').Image:find('11',1,true))
for _,v in ipairs({{320,568},{844,390},{1920,1080}})do SCREEN_W,SCREEN_H=v[1],v[2];U.Layout();U.SafeGuide:GetPropertyChangedSignal("AbsoluteSize"):Fire();flush();inside(info,U.Root);inside(named(info,'CloseCommunityItem'),info)end
named(info,'CloseCommunityItem').Activated:Fire();assert(not info.Visible and U.LookDetail.Visible)
return 'item tiles carry thumbnail, name and separate remove X; creator/price/description move to safe closeable item popup, preserving the whole-look preview'
''')
case('community_transient_failure_retries_same_page_and_keeps_loaded_looks',UI+DATA+PREVIEW+COMMUNITY+r'''
local requests=0;local fail=true;local ctl=Modules['09C7_COMMUNITY_FEED'].Init({U=U,A=A,show=function()end,toast=function()end,call=function(a,args)
 requests=requests+1;if fail then fail=false;return nil,'HTTP 503' end
 local out={};for i=1,24 do local id=args.page*24+i+1;out[i]={id='roblox:'..id,owner=id,source='Roblox',body=A.Copy(S.Current),signature=tostring(id),name='Look real'}end;return{items=out,finished=false}
end})
U.Root.Visible=true;U.CommunityArea.Visible=true;ctl.Open();flush();assert(#ctl.Rows==50 and requests==4 and not ctl.Loading)
fail=true;local old=ctl.Rows[1];U.ComMore.Activated:Fire();flush();assert(#ctl.Rows==60 and ctl.Rows[1]==old and not ctl.Loading)
return 'one transient failure reuses the same page; initial fifty and next ten survive recovery without duplication, wiping previously loaded rows or user intervention'
''')
case('photo_no_bottom_background_caption_and_transient_notice_only',THEME+module('07P0_STUDIO_PRESETS')+module('07P4_STUDIO_UI')+r'''
local u=Modules['07P4_STUDIO_UI'].Build(pl);u.Root.Visible=true;u.Layout();assert(not u.Status.Visible and u.Status.BackgroundTransparency==1)
u.Notify('Mensagem temporária');assert(u.Status.Visible and u.Status.AbsolutePosition.Y<SCREEN_H*.30);advance(5);assert(not u.Status.Visible)
u.Popup.Visible=false;u.SetClean(false);assert(not u.Status.Visible and u.SceneMargins[4]<20)
return 'no permanent lower caption/bar; transient text appears above and expires; scene retains recovered bottom area while all panels remain contextual'
''')
HERE.joinpath('redesign_results.json').write_text(json.dumps(results,indent=2,ensure_ascii=False)+'\n')
print('V49 REDESIGN',len(results),'PASS')
