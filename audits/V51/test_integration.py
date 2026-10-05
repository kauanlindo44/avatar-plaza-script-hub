import ast
from test_support import *
DATA=DATA.replace(';S.Init()','')
CART=module('09C4_OUTFIT_LIBRARY')+"Cart=Modules['09C4_OUTFIT_LIBRARY']\n"
old=ast.parse((ROOT/'audits/V42/test_revision.py').read_text())
selected={'apply_single_clothing_preserves_live_avatar','blank_outfit_restore_history_and_body_limits'}
for expr in old.body:
 if isinstance(expr,ast.Expr)and isinstance(expr.value,ast.Call)and getattr(expr.value.func,'id','')=='case':
  name=ast.literal_eval(expr.value.args[0])
  if name in selected:
   code=eval(compile(ast.Expression(expr.value.args[1]),'<V42 regression>','eval'),globals())
   if name=='appearance_not_ready_cannot_initialize_or_apply':code=code.replace('pl.appearance=false;', 'local previous=HUM.applyCount;pl.appearance=false;').replace('HUM.applyCount==0','HUM.applyCount==previous')
   case(name,code)
CLIENT=UI+DATA+PREVIEW+SERVER+CART+module('09C10_CONFIRM_ACTION')+module('09C9_PLAYER_INSPECT')+r'''
local kit=Instance.new('Folder');kit.Name='PracaKit';kit.Parent=rep
local hud=Instance.new('ScreenGui');hud.Name='LimitedMarketHUD';hud.Enabled=true;hud.Parent=pg
local launcher=Instance.new('ScreenGui');launcher.Name='AvatarShopLauncherGui';launcher.Parent=pg;U.LauncherGui=launcher
Modules['09A_SHOP_UI']={VERSION='V44_STUDIO_UI',Build=function()return U end};local ui=Instance.new('ModuleScript');ui.Name='09A_SHOP_UI';ui.Parent=rep
for _,name in ipairs({'09C2_SHOP_CATALOG','09C1_SHOP_LOOKS','09C5_UGC_STORES'})do
 local o=Instance.new('ModuleScript');o.Name=name;o.Parent=rep
 Modules[name]={Init=function()return{Search=function()end,Preset=function()end,Saved=function()end,Community=function()end}end}
end
local prompts=0;function Services.MarketplaceService:PromptRobloxSubscriptionPurchase(p)assert(p==pl);prompts=prompts+1 end
'''+src('09C_SHOP_CLIENT')+'\nflush()\n'
case('shop_full_controller_exclusive_utilities_confirmed_reset',CLIENT+r'''
U.OpenRequest:Fire('Catalog');flush();assert(U.Root.Visible and not pg.LimitedMarketHUD.Enabled)
U.OpenRequest:Fire('Cart');flush();assert(U.CartPanel.Visible and not U.Root.Visible and not U.Loader.Visible)
U.CartClose.Activated:Fire();flush();assert(U.Root.Visible)
U.OpenRequest:Fire('Plus');flush();assert(prompts==1 and not U.PlusPanel.Visible and not U.CartPanel.Visible)
U.OpenRequest:Fire('Loader');flush();assert(U.Loader.Visible and not U.Root.Visible and U.LoaderQuery.focused)
U.LoaderClose.Activated:Fire();flush();assert(not U.Loader.Visible and U.Root.Visible and not U.LoaderQuery.focused)
local old=S.Current.props.Shirt;Details[50]={Id=50,ItemType='Asset',AssetType='Shirt'};assert(S.Try(Details[50]));flush()
U.Reset.Activated:Fire();assert(S.Current.props.Shirt==50,'reset did not ask confirmation');local confirm=named(U.Gui,'ConfirmRestore');assert(confirm.Visible)
local cancel,yes;for _,b in ipairs(confirm:GetDescendants())do if b.Text=='Continuar editando'then cancel=b elseif b.Text=='Restaurar'then yes=b end end
cancel.Activated:Fire();assert(S.Current.props.Shirt==50);U.Reset.Activated:Fire();yes.Activated:Fire();assert(S.Current.props.Shirt==old)
U.Close.Activated:Fire();flush();assert(not U.Root.Visible and pg.LimitedMarketHUD.Enabled)
return 'V45 version guards, direct Plus, independent utilities, reachable loader close, cancel/confirm restore and HUD state preservation'
''')
case('cart_outfit_selection_owned_filter_and_batch_purchase',UI+DATA+"S.Init()\n"+SERVER+CART+r'''
Cart.Init({U=U,A=A,S=S,pl=pl,toast=function()end,call=function(a,args)local r=RPC:InvokeServer(a,args);return r.ok and r.data or nil,r.error end,openUtility=function()U.CartPanel.Visible=true end})
assert(Cart.Add({Id=101,Name='Shirt',Price=25,ItemType='Asset'}));assert(Cart.Add({Id=102,Name='Pants',Price=30,ItemType='Asset'}))
OwnedAssets[101]=true;onProduct=function(id)return{Name='Live '..id,PriceInRobux=40}end
Cart.Open();flush();assert(U.CartTotal.Text=='TOTAL: 40 Robux');U.CartBuySelected.Activated:Fire();assert(#LastBulk==1 and LastBulk[1].Id=='102')
U.CartOutfit.Activated:Fire();flush();assert(U.CartCount.Text:find('no outfit',1,true));assert(#A.Entries(S.Current)>0);local before=#A.Entries(S.Current)
local row=U.CartList:GetChildren()[2];local x;for _,b in ipairs(row:GetChildren())do if b.Text=='×'then x=b end end;x.Activated:Fire();assert(#A.Entries(S.Current)==before,'cart removal wiped preview')
local items={};for i=1,30 do items[i]={id=1000+i,kind='Asset'}end
local response=RPC:InvokeServer('CartPurchase',{items=items});assert(response.ok and response.data.count==20 and response.data.remaining==10 and #LastBulk==20)
OwnedAssets[102]=true;Services.MarketplaceService.PromptBulkPurchaseFinished:Fire(pl);flush();U.CartSelected.Activated:Fire();flush();assert(U.CartTotal.Text=='TOTAL: 0 Robux')
assert(not RPC:InvokeServer('CartPurchase',{items={{id=-1,kind='Asset'}}}).ok)
return 'selected/outfit tabs; current Roblox prices; already owned assets excluded; batch of 20 with explicit remainder; item deselection never resets avatar'
''')
case('catalog_detail_page_fixed_actions_bundle_metadata',UI+DATA+"S.Init()\n"+PREVIEW+CART+r'''
local items={{Id=202,Name='Bundle',ItemType='Bundle',Price=200},{Id=203,Name='Shirt',ItemType='Asset',Price=20}}
Details[202]={Name='Bundle',Description='Bundle description',CreatorName='Studio',Price=200}
function Services.AvatarEditorService:SearchCatalogAsync()return{IsFinished=true,GetCurrentPage=function()return items end}end
local ctl=loadModule('CATALOG','Catalog').Init({U=U,A=A,S=S,toast=function()end});ctl.Search();flush();local button
for _,c in ipairs(U.Grid:GetChildren())do if c:IsA('GuiButton')then button=c;break end end
button.Activated:Fire();flush();assert(U.Detail.Visible and U.Detail.ClassName=='Frame'and U.Detail.BackgroundTransparency==0)
assert(U.DetailDescription.Text=='Bundle description' and not U.DetailCreator.Visible)
for _,v in ipairs({{320,568},{390,844},{800,360},{844,390},{1920,1080}})do
 SCREEN_W,SCREEN_H,CORE_TOP=v[1],v[2],58;U.Layout();flush();for _,o in ipairs({U.DetailImage,U.DetailName,U.DetailPrice,U.Try,U.Buy,U.DetailClose})do inside(o,U.Root)end
 assert(U.Try.AbsoluteSize.Y>=44 and U.DetailClose.AbsoluteSize.X>=48);assert(not intersects(U.DetailClose,U.DetailImage));assert(not intersects(U.Try,U.DetailDescription))
end
U.DetailClose.Activated:Fire();assert(not U.Detail.Visible)
return 'compact item popover preserves the avatar preview; native metadata and fixed Buy/Try/close actions'
'''.replace("'CATALOG'",q(src('09C2_SHOP_CATALOG'))))
case('player_avatar_privacy_revocation_and_unique_likes',DATA+module('09B3_PLAYER_INSPECT')+r'''
local other=makePlayer(456);function other.Character:FindFirstChildOfClass()return HUM end
function Services.Players:GetPlayers()return{pl,other}end
local inspect=Modules['09B3_PLAYER_INSPECT'];local record=inspect.Avatar(pl,{id=456});assert(not record.allowCopy and record.body.props.Shirt==11)
assert(not pcall(inspect.Use,pl,{id=456}));other:SetAttribute('ACP_AllowAvatarCopy',true);assert(inspect.Use(pl,{id=456}));assert(inspect.CheckApply(pl))
other:SetAttribute('ACP_AllowAvatarCopy',false);assert(not inspect.CheckApply(pl));inspect.Clear(pl);assert(inspect.CheckApply(pl))
assert(inspect.Like(pl,{id=456}).likes==1);assert(inspect.Like(pl,{id=456}).likes==1);assert(not pcall(inspect.Like,pl,{id=123}))
return 'default copy disabled, explicit owner permission, revocation checked on Apply and one persistent like per visitor'
''')
case('community_real_players_exact_outfits_prices_diversity_and_no_defaults',DATA+module('09B2_COSPLAY_METADATA')+module('09B1_AVATAR_DISCOVERY')+module('09B4_CURATED_LOOKS')+r'''
local known={};local descriptions=0;local batchCalls=0
function Services.Players:GetHumanoidDescriptionFromUserIdAsync(id)
 descriptions=descriptions+1;local d=InitialDescription:Clone()
 d.Shirt=id*10+1;d.Pants=id*10+2;d:SetAccessories({{AssetId=id*10+3,AccessoryType=Enum.AccessoryType.Hair,IsLayered=false},{AssetId=id*10+4,AccessoryType=Enum.AccessoryType.Hat,IsLayered=false}})
 known[d.Shirt]=id;known[d.Pants]=id;return d
end
function Services.AvatarEditorService:SearchCatalogAsync()error('catalog composition is forbidden')end
function Services.AvatarEditorService:GetBatchItemDetailsAsync(ids,kind)
 assert(kind==Enum.AvatarItemType.Asset);batchCalls=batchCalls+1;local out={}
 for _,id in ipairs(ids)do local owner=known[id];local free=owner and owner%2==0 or id%10>=3
  local name=owner and (owner%3==0 and 'Naruto Uzumaki' or owner%3==1 and 'Anya Forger' or 'Tanjiro Kamado') or 'Accessory'
  out[#out+1]={Id=id,Name=name,Price=free and 0 or 5,PriceStatus=free and 'Free' or 'On Sale'}
 end;return out
end
task.wait=function(s)TEST_TIME=TEST_TIME+(s or 0);flush()end;local m=Modules['09B4_CURATED_LOOKS'];local data=m.Page(pl,{page=0,budget='paid'});assert(#data.items>=10)
local signatures={};local characters={}
for _,r in ipairs(data.items)do
 assert(r.owner>1 and r.body.props.Shirt==r.owner*10+1 and r.body.props.Pants==r.owner*10+2,'real outfit was synthesized')
 assert(r.source=='Roblox'and (r.sourceUsername==nil or r.sourceUsername==(r.owner==pl.UserId and pl.Name or 'User'..r.owner)) and r.publisher=='CAETANOYX'and r.total>0 and r.budget~='free')
 assert(not signatures[r.signature]);signatures[r.signature]=true;characters[r.character.name]=true
end
local n=0;for _ in pairs(characters)do n=n+1 end;assert(n==3 and #Modules['09B2_COSPLAY_METADATA'].Characters==16)
local before=descriptions;m.Page(pl,{page=0,budget='paid'});assert(before==descriptions,'page cache not used')
advance(1);local free=m.Page(pl,{page=0,budget='free'});assert(#free.items>0)
for _,r in ipairs(free.items)do assert(r.total==0 and r.budget=='free')end
assert(batchCalls>0 and descriptions<=33)
function Services.AvatarEditorService:GetBatchItemDetailsAsync()error('metadata offline')end
advance(181);local unavailable=m.Page(pl,{page=0,budget='free'});assert(#unavailable.items==0,'unknown price was marked free')
assert(not pcall(m.Page,pl,{page=0/0})and not pcall(m.Page,pl,{page=10000}))
return 'actual user descriptions preserved exactly; 16 supported references with multiple characters in a page; paid/free filters require confirmed native prices; unknown metadata never claims free; Roblox/default account excluded; bounded caches and no synthetic catalog outfits'
''')
CARD_UI=THEME+module('07K0_TRUCO_RULES')+module('07K6_CARD_CATALOG')+module('07K7_CARD_STYLES')+module('07K5_TRUCO_UI')+module('07K9_CARD_INVENTORY_UI')+module('07K12_TOURNAMENT_UI')+module('07H1_GAME_LOBBY')
case('card_shop_client_prices_renamed_choices_and_late_close',CARD_UI+r'''
local catalog=Modules['07K6_CARD_CATALOG'];local gui=Instance.new('ScreenGui');gui.Parent=pg
local data={coins=5000,owned={Classic=true},equipped='Classic',ateliers=false,boxes={Nox=1},custom={image=0,zoom=1}}
local request;local u;local price=1;local failed;local closeOnQuery=false;local queries={}
function Services.MarketplaceService:GetProductInfoAsync(id,kind)
 assert(id~=3716300364,'excluded Ether was queried');queries[#queries+1]={id=id,kind=kind}
 if closeOnQuery then closeOnQuery=false;u.Close.Activated:Fire()end
 if id==failed then error('offline')end
 return{Name='Translated native title',PriceInRobux=price,IsForSale=true}
end
local function registry()
 local s={passes={},products={}}
 for _,id in ipairs({1951234105,1962433436,1966813498})do s.passes[tostring(id)]={id=id,price=999,sale=true}end
 for key,id in pairs(catalog.Products)do s.products[key]={id=id,price=999,sale=true}end
 return s
end
u=Modules['07K9_CARD_INVENTORY_UI'].Build(gui,function(action,args)
 if action=='inventory'then return data elseif action=='store'then return registry()
 elseif action=='prompt'then request=deep(args);return true
 elseif action=='openbox'then request=deep(args);for _,key in ipairs(args.styles)do data.owned[key]=true end;data.boxes[args.key]=data.boxes[args.key]-#args.styles;return{styles=args.styles}end
end,function()end)
local function button(parent,text)for _,o in ipairs(parent:GetDescendants())do if o:IsA('GuiButton')and o.Text:sub(1,#text)==text then return o end end end
u.Tab='Loja';u.Show()
for _,entry in pairs(u.Store.products)do assert(entry.price==nil and not entry.sale,'server price leaked before client metadata')end
flush();assert(#queries==13);assert(u.Store.products.Aether.price==1 and u.Store.passes['1951234105'].price==1)
for _,q in ipairs(queries)do local pass=q.id==1951234105 or q.id==1962433436 or q.id==1966813498;assert(q.kind==(pass and Enum.InfoType.GamePass or Enum.InfoType.Product))end
local vaelis=named(u.List,'Aether');assert(vaelis);vaelis.Activated:Fire();local rb=u.RobuxBuy;assert(rb.Text=='Comprar · 1 Robux'and rb.Active and rb.AutoLocalize==false)
rb.Activated:Fire();assert(request.kind=='product'and request.key=='Aether'and catalog.Products[request.key]==3716300668)
u.SetPreview('Aether');assert(u.PreviewName.Text=='Vaelis'and not u.PreviewName.AutoLocalize and u.Style=='Aether')
u.OpenBox(catalog.Collections[1]);local veyra=button(u.Choices,'Veyra');local nyxar=button(u.Choices,'Nyxar');assert(veyra and nyxar and not veyra.AutoLocalize and not nyxar.AutoLocalize)
veyra.Activated:Fire();assert(u.Style=='Vesper'and u.PreviewName.Text=='Veyra');u.Open.Activated:Fire()
assert(request.key=='Nox'and request.styles[1]=='Vesper'and data.owned.Vesper and data.boxes.Nox==0)
u.DialogClose.Activated:Fire();price=9;advance(31);u.Show();flush();assert(u.RobuxBuy.Text=='Comprar · 9 Robux')
failed=catalog.Products.Aether;advance(31);u.Show();flush();assert(not u.Store.products.Aether.sale and u.Store.products.Aether.price==nil)
assert(not u.RobuxBuy.Active,'metadata failure kept a purchasable/stale regional price')
failed=nil;advance(31);closeOnQuery=true;u.Show();flush();assert(not u.Root.Visible)
for _,entry in pairs(u.Store.products)do assert(not entry.sale,'late client price updated a closed view')end
return '13 client-side native queries use correct product/pass type, 1-to-9 Robux refresh, no 999 server fallback, renamed choices keep saved/receipt keys, unavailable metadata disables purchase and late close is respected'
''')
case('games_inventory_tournament_screen_geometry_and_exit_confirmation',CARD_UI+r'''
local gui=Instance.new('ScreenGui');gui.ScreenInsets=Enum.ScreenInsets.None;gui.Parent=pg
local lobby=Modules['07H1_GAME_LOBBY'].Build(gui);local exited=0
local match=Modules['07K5_TRUCO_UI'].Build(gui,function()end);match.OnLeave=function()exited=exited+1 end
local cards=Modules['07K9_CARD_INVENTORY_UI'].Build(gui,function(a)if a=='inventory'then return{coins=1000,owned={Classic=true},equipped='Classic',boxes={Nox=1},custom={image=0,zoom=1}}end;return{passes={},products={}}end,function()end)
local cups=Modules['07K12_TOURNAMENT_UI'].Build(gui,function()return{}end,function()end,function()end)
for _,v in ipairs({{320,568,0,0,58,0},{360,640,0,0,58,0},{800,360,0,0,58,0},{844,390,44,44,58,22},{1920,1080,0,0,58,0}})do
 SCREEN_W,SCREEN_H,CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=table.unpack(v);lobby.SetGame('Truco');lobby.Root.Visible=true
 for _,mode in ipairs({'Online','Friends','Practice'})do lobby.Mode=mode;lobby.Layout();for _,o in ipairs({lobby.Close,lobby.Inventory,lobby.Cups,lobby.VariantButton,lobby.TeamButton,lobby.ManualButton})do inside(o,lobby.Root)end
  if mode=='Friends'then inside(lobby.Create,lobby.Root);inside(lobby.Code,lobby.Root);inside(lobby.Join,lobby.Root)elseif mode=='Practice'then inside(lobby.Bot,lobby.Root)else inside(lobby.Quick,lobby.Root)end
 end
 lobby.SetWaiting('A7KD',false,true,2);inside(lobby.Cancel,lobby.Root);lobby.Reset()
 cards.Show();cups.Layout();cards.Layout();for _,o in ipairs({cards.Close,cards.List,cups.Close,cups.List})do inside(o,gui);assert(cards.Close.AbsoluteSize.X==48)end
 cards.OpenBox(Modules['07K6_CARD_CATALOG'].Collections[1]);for _,o in ipairs({cards.Dialog,cards.DialogClose,cards.Open})do inside(o,gui)end
end
local r=Modules['07K0_TRUCO_RULES'];local s=r.New('Paulista',4);r.Begin(s,r.Deck(),false);local view=r.View(s,1);view.players={{name='A'},{name='B'},{name='C'},{name='D'}}
match.Update(view,{equipped='Classic'});match.Close.Activated:Fire();assert(exited==0 and match.Dialog.Visible)
for _,b in ipairs(match.Options:GetChildren())do if b.Text=='Continuar'then b.Activated:Fire()end end;assert(exited==0)
match.Close.Activated:Fire();for _,b in ipairs(match.Options:GetChildren())do if b.Text=='Desistir'then b.Activated:Fire()end end;assert(exited==1)
return 'fixed create/join/training/waiting controls at five sizes, notches, 48px exit targets, choice dialog and confirmed live-match resignation'
''')
case('atelier_mobile_preview_crop_drag_zoom_save_and_face_toggle',CARD_UI+r'''
local gui=Instance.new('ScreenGui');gui.ScreenInsets=Enum.ScreenInsets.None;gui.Parent=pg
local saved;local data={coins=0,owned={Classic=true},equipped='Custom',ateliers=true,boxes={},custom={image=6789,zoom=1.3,x=.1,y=0}}
local u=Modules['07K9_CARD_INVENTORY_UI'].Build(gui,function(action,args)
 if action=='inventory'then return data elseif action=='image'then return{image=args.image,texture=args.image,assetType=1}elseif action=='custom'then saved=deep(args);data.custom=deep(args);return true end
 return{passes={},products={}}
end,function()end)
u.Show();u.Tab='Ateliê';u.Render();flush()
for _,v in ipairs({{320,568},{390,844},{844,390},{1920,1080}})do
 SCREEN_W,SCREEN_H,CORE_TOP=v[1],v[2],58;u.Layout();local inline=u.CustomPreview;assert(inline and inline.AbsoluteSize.X>70 and inline.AbsoluteSize.Y>100);inside(inline,inline.Parent)
end
SCREEN_W,SCREEN_H=320,568;u.Layout();assert(u.Atelier.Visible and not u.List.Visible)
local inline=u.CustomPreview;local id=u.CustomID;assert(id.Text=='6789')
local touch={UserInputType=Enum.UserInputType.Touch,Position=Vector3.new(10,10,0)};inline.InputBegan:Fire(touch);touch.Position=Vector3.new(80,40,0);Services.UserInputService.InputChanged:Fire(touch);Services.UserInputService.InputEnded:Fire(touch)
u.SaveCustom.Activated:Fire()
assert(saved and saved.image==6789 and saved.x>0 and saved.x<=.151 and saved.y>0 and saved.y<=.151)
u.SetPreview('Regent');assert(named(u.CardHost,'CardFace'));u.Flip.Activated:Fire();assert(not named(u.CardHost,'CardFace'))
return 'inline card remains available on phone; direct crop dragging, bounded zoom/offset saving and front/back preview'
''')
case('personal_commands_serial_rpc_refresh_avoids_rate_limit',THEME+r'''
local kit=Instance.new('Folder');kit.Name='PracaKit';kit.Parent=rep;local rem=Instance.new('Folder');rem.Name='Remotes';rem.Parent=kit
local rpc=Instance.new('RemoteFunction');rpc.Name='PersonalSettings';rpc.Parent=rem;local last=-100;local speed=16;local calls=0
function rpc:InvokeServer(key,value)assert(TEST_TIME-last>=.2,'refresh rejected by server rate limit');last=TEST_TIME;calls=calls+1;if key=='speed'then speed=value end;return{ok=true,data={speed=speed}}end
task.wait=function(seconds)TEST_TIME=TEST_TIME+seconds end
local tools=Modules['07G3_PERSONAL_TOOLS'];assert(tools.Call('get').speed==16);assert(tools.Call('speed',28));assert(tools.Call('get').speed==28 and calls==3)
return 'set then refresh serializes calls with the real server minimum interval'
''')
PHOTO=THEME+DATA+"S.Init()\n"+PREVIEW+module('07P0_STUDIO_PRESETS')+module('07P3_POSE_EDITOR')+module('07P5_POSE_CANVAS')+module('07P6_STUDIO_SETS')+module('07P2_STUDIO_AVATAR')+"Studio=Modules['07P2_STUDIO_AVATAR']\n"+module('07P4_STUDIO_UI')
old=ast.parse((ROOT/'audits/V43/test_regressions.py').read_text())
for expr in old.body:
 if isinstance(expr,ast.Expr)and isinstance(expr.value,ast.Call)and getattr(expr.value.func,'id','')=='case'and ast.literal_eval(expr.value.args[0])=='full_photo_controller_pose_capture_and_exit_races':
  code=eval(compile(ast.Expression(expr.value.args[1]),'<photo regression>','eval'),globals()).replace("root:FindFirstChildOfClass('ScrollingFrame')","root:FindFirstChild('PhotoSidebar')")
  case('full_photo_controller_pose_capture_and_exit_races',code)
case('photo_environment_all_controls_and_modern_pose_undo',PHOTO+r'''
local u=Modules['07P4_STUDIO_UI'].Build(pl)
for _,v in ipairs({{320,568},{360,640},{800,360},{844,390},{1920,1080}})do
 SCREEN_W,SCREEN_H,CORE_TOP=v[1],v[2],58;u.Root.Visible=true;u.Popup.Visible=true;u.Clear()
 for i=1,5 do u.Row('Control '..i,'1.00',i)end;u.Pair('Luz','Restaurar',6);u.Layout();assert(u.Content.ClassName=='Frame')
 for _,o in ipairs(u.Content:GetChildren())do if o:IsA('GuiObject')then inside(o,u.Content);for _,b in ipairs(o:GetChildren())do if b:IsA('GuiButton')then inside(b,o);assert(b.AbsoluteSize.Y>=44,'small environment touch target')end end end end
end
local model=Instance.new('Model');local torso=Instance.new('Part');torso.Name='Torso';torso.Parent=model;local arm=Instance.new('Part');arm.Name='RightUpperArm';arm.Parent=model
local joint=Instance.new('AnimationConstraint');joint.Name='NewJointName';joint.Part0=torso;joint.Part1=arm;joint.Transform=CFrame.new();joint.IsKinematic=false;joint.Parent=model
local p=Modules['07P3_POSE_EDITOR'].Bind(model);assert(p.Values.RightShoulder and joint.IsKinematic);p.Begin();p.Checkpoint();assert(p.Set('RightShoulder',3,50));assert(p.Undo()and p.Values.RightShoulder[3]==0);assert(p.Redo()and p.Values.RightShoulder[3]==50)
p.Confirm();p.Begin();p.Set('RightShoulder',3,10);p.Cancel();assert(p.Values.RightShoulder[3]==50);p.Destroy();assert(not joint.IsKinematic)
return 'environment never scrolls, seven controls fully visible with >=44px buttons, modern joint discovery by body part, undo/redo, confirm/cancel and restored kinematic mode'
''')
HERE.joinpath('integration_results.json').write_text(json.dumps(results,indent=2,ensure_ascii=False)+'\n')
print('INTEGRATION',len(results),'PASS')
