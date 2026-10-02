"""V42 behavior and geometry with Lua 5.4 doubles; no Roblox runtime/rendering."""
from pathlib import Path
import json,re
from lua_runner import Lua
ROOT=Path(__file__).resolve().parents[2]
MOCK=Path(__file__).with_name('roblox_mock.lua').read_text()
def src(n,v='V42'):return (ROOT/'scripts'/v/(n+'.lua')).read_text()
def q(s):return '[====['+s+']====]'
def module(n,v='V42'):return "installModule('"+n+"',"+q(src(n,v))+")\n"
THEME=module('07UI_DESIGN_SYSTEM','V41')+module('07UI_SCREEN_BOUNDS')+module('09A1_SHOP_LAYOUT')
UI=THEME+"U=loadModule("+q(src('09A_SHOP_UI'))+",'Shop').Build(pl);flush()\n"
DATA=module('08B_AVATAR_DATA','V41')+"A=Modules['08B_AVATAR_DATA'];HUM=setupAvatar()\n"+module('08D_SKIN_STATE','V41')+"S=Modules['08D_SKIN_STATE']\n"
SERVER="setupServer("+q(src('09B_SHOP_SERVER'))+")\n"
CART=module('09C4_OUTFIT_LIBRARY')+"Cart=Modules['09C4_OUTFIT_LIBRARY']\n"
results=[]
def case(name,code):
 l=Lua()
 try:
  detail=l.run(MOCK+code,name);print('PASS',name,detail or'');results.append(dict(case=name,result='pass',detail=detail))
 except Exception:
  Path("/workspace/scratch/ec6f584177a3/analysis/v41_failed_case.lua").write_text(MOCK+code);raise
 finally:l.close()
for p in sorted((ROOT/'scripts/V42').glob('*.lua')):
 s=p.read_text();assert len(s.splitlines())<=400,p;assert not re.search(r'(?:\+|-|\*|/|\.\.)=',s),p
 l=Lua();l.run(s,p.name,execute=False);l.close()
results.append(dict(case='syntax_and_limits',result='pass',detail='20 scripts <=400 lines; no compound assignments'))
case('full_viewport_editor_geometry',UI+r'''
for _,v in ipairs({{320,568,0,0,58,0},{360,640,0,0,58,0},{390,844,0,0,58,22},{800,360,0,0,58,0},{844,390,44,44,58,22},{1460,821,0,0,58,0},{1920,1080,0,0,58,0}})do
 SCREEN_W,SCREEN_H,CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=table.unpack(v);U.SetWide(false);flush()
 assert(U.Root.AbsolutePosition.Y==0 and U.Root.AbsoluteSize.Y==SCREEN_H,'reserved root strip')
 assert(U.Left.Visible,'preview hidden by default');assert(U.Viewport.AbsoluteSize.Y>=128,'preview too short: '..U.Viewport.AbsoluteSize.Y)
 for _,o in ipairs({U.Left,U.Main,U.Viewport,U.EditorFooter,U.Query,U.SearchGo,U.Filter,U.Sort,U.Grid,U.Close,U.BodyWindow})do inside(o,U.Root)end
 for _,o in ipairs({U.Apply,U.Save,U.Reset,U.BuyLook})do inside(o,U.Left)end
 assert(not intersects(U.Viewport,U.Actions));assert(not intersects(U.Query,U.SearchGo));assert(not intersects(U.Filter,U.Sort));assert(not intersects(U.Grid,U.Groups))
 assert(U.ItemStrip.AbsoluteSize.Y>=44,'equipped items too short: '..U.ItemStrip.AbsoluteSize.Y)
 for _,o in ipairs({U.LoaderQuery,U.LoaderSearch,U.LoaderMine,U.LoaderThumb,U.LoaderName,U.LoaderStatus,U.LoaderUse,U.LoaderUseR6})do inside(o,U.Loader)end
 assert(not intersects(U.LoaderThumb,U.LoaderName));assert(not intersects(U.LoaderThumb,U.LoaderStatus));assert(not intersects(U.LoaderUse,U.LoaderUseR6))
 for _,o in ipairs({U.CartList,U.CartClose,U.CartBuySelected,U.CartClear,U.CartTotal,U.PlusClose,U.PlusContent,U.PlusStatus,U.PlusPrice,U.PlusBuy})do inside(o,U.Gui)end
 assert(not intersects(U.CartClear,U.CartBuySelected));assert(not intersects(U.CartTotal,U.CartBuySelected));assert(not intersects(U.PlusPrice,U.PlusBuy))
 for _,o in ipairs({U.CartPanel,U.PlusPanel,U.Loader})do assert(o.Parent==U.Gui and o.Size.X.Scale==1 and o.Size.Y.Scale==1,'utility is not independent fullscreen')end
 U.SetWide(true);flush();assert(not U.Left.Visible);assert(not intersects(U.Close,U.StoreGo));inside(U.SavedPreview,U.Gui)
end
return '7 viewports, notches/native bars, preview >=128 px and exclusive full-screen roots'
''')
case('module_contract_and_dynamic_topbar',UI+r'''
for _,key in ipairs({'AnimateMode','Apply','ApplyFilter','Blank','BodyClose','BodyControls','BodyNote','BodyReset','BodyToggle','BodyWindow','Button','Buy','BuyLook','CancelSave','CartBuySelected','CartClear','CartClose','CartCount','CartList','CartPanel','CartTotal','ClearFilter','Close','CloseFilter','Colors','ComCount','ComFeatured','ComFeaturedCreator','ComFeaturedEyebrow','ComFeaturedMeta','ComFeaturedName','ComFeaturedOpen','ComFeaturedPreview','ComGridTitle','ComMore','ComMyOutfits','ComRefresh','ComSearch','ComSearchGo','ComTabButtons','CommunityArea','CommunityGrid','CommunityStatus','Creator','CreatorType','Detail','DetailClose','DetailImage','DetailName','DetailPrice','Favorite','Filter','FilterPanel','Form2D','Form3D','FormAll','FormClassic','Grid','GridLayout','Groups','HudAction','ItemStrip','LimAll','LimNo','LimOnly','Loader','LoaderClose','LoaderMine','LoaderName','LoaderQuery','LoaderSearch','LoaderStatus','LoaderThumb','LoaderUse','LoaderUseR6','LookBuy','LookClose','LookCodeBox','LookCopy','LookCreator','LookDetail','LookFav','LookItems','LookMeta','LookName','LookPreview','LookSearch','LookTotal','LookTry','LooksArea','Max','Min','More','New','OffSale','OpenRequest','OutfitActions','OutfitApply','OutfitBuy','OutfitDelete','OutfitPublish','OutfitRestore','OutfitSaveNew','OutfitSelected','OutfitUpdate','PageTitle','PlusBuy','PlusClose','PlusDescription','PlusName','PlusPanel','PlusPrice','PlusStatus','PreviewInfo','PreviewToggle','PublishBox','PublishCancel','PublishClose','PublishConfirm','PublishName','Query','Redo','Reset','RigBox','RigCancel','RigClose','RigR15','RigR6','RigToR15','Root','Round','Save','SaveBox','SaveClose','SaveName','SaveR15','SaveR6','SaveRoblox','SavedCount','SavedGrid','SavedItems','SavedLeft','SavedPreview','SavedRight','SavedZoomIn','SavedZoomOut','SearchGo','SetWide','ShowPreview','Sort','Status','StopEmote','StoreGo','StoreGrid','StoreSearch','StoreStatus','StoreType','StoresArea','SubToggle','Subs','SubsLayout','SubsPopup','Text','Toast','Total','Try','Undo','ViewLeft','ViewRight','Viewport','ZoomIn','ZoomOut'})do assert(U[key]~=nil,'missing UI export '..key)end
SCREEN_W,SCREEN_H,CORE_TOP=844,390,58;U.SetWide(false);assert(U.Query.Position.Y.Offset==4)
TOPBAR_OCCUPIED=500;Services.GuiService:GetPropertyChangedSignal('TopbarInset'):Fire();assert(U.Query.Position.Y.Offset==64,'header must avoid expanded native controls')
TOPBAR_OCCUPIED=164;Services.GuiService:GetPropertyChangedSignal('TopbarInset'):Fire();assert(U.Query.Position.Y.Offset==4,'free native topbar space unused')
U.BodyWindow.Visible=true;assert(not intersects(U.BodyWindow,U.Viewport),'body popup obscures live preview')
return 'all controller UI fields exist; free top space reused and native resizing handled; body preserves preview'
''')
case('hud_high_buttons_and_no_tooltips',module('07UI_DESIGN_SYSTEM','V41')+"local kit=Instance.new('Folder');kit.Name='PracaKit';kit.Parent=rep\n"+src('07G_HUB_UI','V41')+r'''
flush();local r=pg.LimitedMarketHUD.HudRoot;local top=pg.AvatarShopLauncherGui.Launcher
for _,v in ipairs({{320,568},{360,640},{800,360},{844,390},{1460,821}})do
 SCREEN_W,SCREEN_H=v[1],v[2];r:GetPropertyChangedSignal('AbsoluteSize'):Fire();flush()
 assert(r.Plus.Visible,'Plus absent on mobile')
 for _,p in ipairs({r,top})do for _,b in ipairs(p:GetChildren())do if b:IsA('GuiButton')and b.Visible then
  inside(b,p);b.MouseEnter:Fire();b.SelectionGained:Fire()
  for _,c in ipairs(b:GetDescendants())do assert(c.ClassName~='TextLabel','tooltip label exists')end
 end end end
 assert(not intersects(top.TopCatalog,top.TopStores));assert(not intersects(top.TopCatalog,top.TopMusic));assert(not intersects(top.TopStores,top.TopMusic))
 if SCREEN_W>=700 then assert(top.TopCatalog.Position.Y.Offset==4)end
end
local shop=Instance.new('ScreenGui');shop.Name='AvatarShop08Gui';shop.Parent=pg
local e=Instance.new('BindableEvent');e.Name='OpenRequest';e.Parent=shop;local opened;e.Event:Connect(function(a)opened=a end)
r.Plus.Activated:Fire();flush();assert(opened=='Plus','Plus opened another mode')
return 'higher launcher, 5 mobile shortcuts and no popup labels on hover/focus'
''')
case('apply_single_clothing_preserves_live_avatar',DATA+SERVER+r'''
local function fetch(action,args)local r=RPC:InvokeServer(action,args);return r.ok and r.data or nil,r.error end
assert(S.Init(fetch));assert(not S.Replace and S.Base.props.Shirt==11)
Details[50]={Id=50,ItemType='Asset',AssetType='Shirt'};assert(S.Try(Details[50]))
assert(S.Current.props.Shirt==50 and S.Current.props.Pants==12 and S.Current.props.Face==13 and #S.Current.accessories==3)
-- Another appearance change happened after the editor took its snapshot.
HUM.applied.Face=77;local acc=HUM.applied:GetAccessories(true);acc[#acc+1]={AssetId=88,AccessoryType=Enum.AccessoryType.Back,IsLayered=false};HUM.applied:SetAccessories(acc,true)
local response=RPC:InvokeServer('Apply',{body=S.Current,base=S.Base,replace=S.Replace,rig=S.Rig});assert(response.ok,response.error)
local applied=HUM.applied;assert(applied.Shirt==50 and applied.Pants==12 and applied.Face==77 and applied.Head==14 and applied.Torso==15)
assert(applied.WidthScale==.85 and applied.HeightScale==1.02 and applied.HeadColor.R==.6)
assert(#applied:GetAccessories(true)==4 and applied.StaticFacialAnimation==true);assert(applied:GetEmotes().Dance[1]==31)
S.AcceptApplied(response.data.body,S.Generation);assert(S.Current.props.Face==77 and #S.Current.accessories==4 and not S.Replace)
assert(S.Remove(21));response=RPC:InvokeServer('Apply',{body=S.Current,base=S.Base,replace=S.Replace,rig=S.Rig});assert(response.ok,response.error)
local kept={};for _,a in ipairs(HUM.applied:GetAccessories(true))do kept[a.AssetId]=true end
assert(not kept[21]and kept[22]and kept[23]and kept[88],'X removed unrelated accessories')
return 'shirt applied while pants, body, colors, hair/accessories, emotes and newer live changes survive; X removes one item'
''')
case('blank_outfit_restore_history_and_body_limits',DATA+SERVER+r'''
local function fetch(a,b)local r=RPC:InvokeServer(a,b);return r.ok and r.data or nil,r.error end
assert(S.Init(fetch));Details[50]={Id=50,ItemType='Asset',AssetType='Shirt'};assert(S.Try(Details[50]))
assert(S.SetScale('HeightScale',2));assert(S.GetScale('HeightScale')==1.05);assert(S.SetScale('WidthScale',0));assert(S.GetScale('WidthScale')==.70)
assert(S.SetRig('R6'));assert(not S.SetScale('HeightScale',1));assert(S.Undo()and S.Rig=='R15')
assert(S.Blank()and S.Replace and #S.Current.accessories==0 and S.Current.props.Shirt==0)
assert(S.Undo()and not S.Replace and S.Current.props.Shirt==50);assert(S.Redo()and S.Replace)
local response=RPC:InvokeServer('Apply',{body=S.Current,base=S.Base,replace=S.Replace,rig=S.Rig});assert(response.ok and HUM.applied.Shirt==0 and #HUM.applied:GetAccessories(true)==0)
S.AcceptApplied(response.data.body,S.Generation);assert(S.Reset()and S.Replace and S.Current.props.Shirt==11)
local outfit=A.Copy(S.Current);outfit.props.Shirt=111;outfit.props.Pants=112;outfit.accessories={}
assert(S.Set(outfit,false,'R15')and S.Replace)
response=RPC:InvokeServer('Apply',{body=S.Current,base=S.Base,replace=S.Replace,rig=S.Rig});assert(response.ok and HUM.applied.Pants==112 and #HUM.applied:GetAccessories(true)==0)
local generation=S.Generation;assert(S.SetScale('HeightScale',.99));S.AcceptApplied(response.data.body,generation);assert(S.Current.scales.HeightScale==.99,'late apply discarded newer edit')
return 'explicit complete outfits/blank replace, restore/history work, R15 limits and pending edits remain correct'
''')
case('bundle_only_adds_its_pieces_and_rejects_stale_try',DATA+r'''
assert(S.Init())
Details[200]={Id=200,ItemType='Bundle',BundleType='BodyParts'}
Details[201]={Id=201,ItemType='Asset',AssetType='Torso'};Details[202]={Id=202,ItemType='Asset',AssetType='Head'}
Bundles[200]={Items={{Id=999,Type='UserOutfit'},{Id=201,Type='Asset'},{Id=202,Type='Asset'}}}
Services.Players.GetHumanoidDescriptionFromOutfitId=function()error('must not replace with complete outfit')end
assert(S.Try(Details[200]));assert(S.Current.props.Torso==201 and S.Current.props.Head==202)
assert(S.Current.props.Shirt==11 and S.Current.props.Pants==12 and S.Current.props.Face==13 and #S.Current.accessories==3 and not S.Replace)
Details[50]={Id=50,ItemType='Asset',AssetType='Shirt'}
onDetails=function()S.Remove(22)end;local ok=S.Try(Details[50]);assert(not ok and S.Current.props.Shirt==11)
onDetails=nil;Details[202]=nil;local old=S.Current.props.Torso;assert(not S.Try(Details[200])and S.Current.props.Torso==old)
return 'bundle changes body pieces only, no outfit wipe or partial apply; stale network result cannot overwrite edits'
''')
case('appearance_not_ready_cannot_initialize_or_apply',DATA+SERVER+r'''
pl.appearance=false;assert(not S.Init());assert(not RPC:InvokeServer('AvatarSnapshot',{}).ok)
local raw=A.Pack(InitialDescription);local r=RPC:InvokeServer('Apply',{body=raw,base=raw,rig='R15'});assert(not r.ok and HUM.applyCount==0)
pl.appearance=true;r=RPC:InvokeServer('Apply',{body=raw,rig='R15'});assert(not r.ok and HUM.applyCount==0,'missing baseline silently wiped avatar')
return 'not-yet-loaded avatar and missing edit baseline fail without changing the live skin'
''')
CLIENT=UI+DATA+SERVER+CART+r'''
local kit=Instance.new('Folder');kit.Name='PracaKit';kit:SetAttribute('PlusGamePassId',0);kit.Parent=rep
local h=Instance.new('ScreenGui');h.Name='LimitedMarketHUD';h.Parent=pg
local launcher=Instance.new('ScreenGui');launcher.Name='AvatarShopLauncherGui';launcher.Parent=pg;U.LauncherGui=launcher
Modules['09A_SHOP_UI']={VERSION='V42_STUDIO_UI',Build=function()return U end};local ui=Instance.new('ModuleScript');ui.Name='09A_SHOP_UI';ui.Parent=rep
for _,name in ipairs({'09C2_SHOP_CATALOG','09C1_SHOP_LOOKS','09C5_UGC_STORES'})do
 local o=Instance.new('ModuleScript');o.Name=name;o.Parent=rep
 Modules[name]={Init=function()return{Search=function()end,Preset=function()end,Saved=function()end,Community=function()end}end}
end
'''+src('09C_SHOP_CLIENT')+'\nflush()\n'
case('client_exclusive_pages_and_focus_restore',CLIENT+r'''
assert(S.Current and PreviewRequests and #PreviewRequests>0)
U.HudAction:Fire('Cart');assert(U.CartPanel.Visible and not U.Root.Visible and not U.Loader.Visible and not U.PlusPanel.Visible)
assert(not pg.LimitedMarketHUD.Enabled and not pg.AvatarShopLauncherGui.Enabled)
U.CartClose.Activated:Fire();assert(not U.CartPanel.Visible and not U.Root.Visible and pg.LimitedMarketHUD.Enabled and pg.AvatarShopLauncherGui.Enabled)
U.OpenRequest:Fire('Plus');flush();assert(U.PlusPanel.Visible and not U.Root.Visible and not U.CartPanel.Visible)
assert(U.PlusBuy.Text=='VER PLANOS'and U.PlusBuy.Active);U.PlusClose.Activated:Fire();assert(pg.LimitedMarketHUD.Enabled)
U.OpenRequest:Fire('Catalog');flush();assert(U.Root.Visible and U.Left.Visible)
U.BodyToggle.Activated:Fire();assert(U.BodyWindow.Visible);U.BodyClose.Activated:Fire();assert(not U.BodyWindow.Visible)
U.BuyLook.Activated:Fire();assert(U.CartPanel.Visible and not U.Root.Visible);U.CartClose.Activated:Fire();assert(U.Root.Visible and U.Left.Visible)
U.Close.Activated:Fire();U.OpenRequest:Fire('Loader');assert(U.Loader.Visible and not U.Root.Visible and not U.CartPanel.Visible)
U.LoaderQuery.Text='@Example';U.LoaderSearch.Activated:Fire();flush();assert(U.LoaderUse.Visible and U.LoaderUseR6.Visible)
U.LoaderClose.Activated:Fire();assert(not U.Loader.Visible and not U.LoaderUse.Visible and pg.LimitedMarketHUD.Enabled)
Details[50]={Id=50,ItemType='Asset',AssetType='Shirt'};S.Try(Details[50]);U.OpenRequest:Fire('Catalog');U.Apply.Activated:Fire();flush()
assert(HUM.applied.Shirt==50 and HUM.applied.Pants==12 and S.Base.props.Shirt==50)
local row=U.ItemStrip:FindFirstChild('Equipped_21');assert(row and row.RemoveItem.Size.X.Offset==32);row.RemoveItem.Activated:Fire();flush()
assert(not U.ItemStrip:FindFirstChild('Equipped_21')and U.ItemStrip:FindFirstChild('Equipped_22'))
return 'real client: HUD/cart/Plus/loader isolation, proper return view/focus, body X and applying/removing clothing'
''')
case('roblox_plus_official_subscription_prompt',CLIENT+r'''
local purchase=0
function Services.MarketplaceService:PromptGamePassPurchase()error('Plus must not be a pass')end
function Services.MarketplaceService:PromptRobloxSubscriptionPurchase(player)assert(player==pl);purchase=purchase+1 end
U.OpenRequest:Fire('Plus');flush();assert(not U.Root.Visible and U.PlusBuy.Active and U.PlusName.Text=='Roblox Plus')
assert(U.PlusPrice.Text=='Preço no Roblox');U.PlusBuy.Activated:Fire();assert(purchase==1)
Services.MarketplaceService.PromptRobloxSubscriptionPurchaseFinished:Fire(pl,true);flush()
assert(U.PlusBuy.Active,'closing native prompt is not subscription confirmation')
pl.HasRobloxSubscription=true;pl:GetPropertyChangedSignal('HasRobloxSubscription'):Fire();flush()
assert(not U.PlusBuy.Active and U.PlusPrice.Text=='PLUS ATIVO');U.PlusBuy.Activated:Fire();assert(purchase==1)
return 'official Plus prompt with server subscription status; no game-pass ID, fake price or assumed purchase'
''')
case('cart_selection_total_clear_remove_purchase',CLIENT+r'''
local a={Id=501,Name='Camisa',ItemType='Asset',Price=100};local b={Id=502,Name='Pacote',ItemType='Bundle'}
assert(Cart.Add(a)and Cart.Add(a)and Cart.Add(b)and Cart.Count()==2);assert(U.CartTotal.Text=='SUBTOTAL: 100 Robux')
Cart.Open();assert(not U.Root.Visible);local rows={};for _,r in ipairs(U.CartList:GetChildren())do if r:IsA('Frame')then rows[#rows+1]=r end end
local check;for _,v in ipairs(rows[1]:GetChildren())do if v:IsA('GuiButton')and v.Text=='ON'then check=v end end;check.Activated:Fire();assert(U.CartCount.Text:find('1 selecionados'))
local lines;function Services.MarketplaceService:PromptBulkPurchase(_,items)lines=items end
U.CartBuySelected.Activated:Fire();assert(lines and #lines==1 and lines[1].Type==Enum.MarketplaceProductType.AvatarBundle and lines[1].Id=='502')
U.CartClear.Activated:Fire();assert(Cart.Count()==0 and U.CartTotal.Text=='TOTAL: 0 Robux')
return 'no duplicates, selection, unknown-price subtotal, official mixed-item cart request and clearing'
''')
case('catalog_adaptive_grid_price_and_pagination',UI+DATA+CART+r'''
S.Init();Cart.Init({U=U,A=A,S=S,pl=pl,toast=function()end,call=function()end,openUtility=function()end,closeUtility=function()end})
local index=1;local pages={IsFinished=false}
local items={{Id=51,Name='Camisa',ItemType='Asset',AssetType='Shirt',Price=1234},{Id=52,Name='Calça',ItemType='Asset',AssetType='Pants',Price=80}}
function pages:GetCurrentPage()return index==1 and items or{{Id=53,Name='Acessório',ItemType='Asset',AssetType='Hat',Price=100}}end
function pages:AdvanceToNextPageAsync()index=index+1;self.IsFinished=true end
function Services.AvatarEditorService:SearchCatalogAsync()index=1;pages.IsFinished=false;return pages end
local C=loadModule('CATALOG_SOURCE','Catalog').Init({U=U,A=A,S=S,pl=pl,toast=function()end,call=function()end,preview=function()end})
for _,v in ipairs({{360,640},{844,390},{1460,821},{1920,1080},{2560,1440}})do
 SCREEN_W,SCREEN_H=v[1],v[2];U.SetWide(false);C.Resize()
 local cell=U.GridLayout.CellSize;local cols=U.GridLayout.FillDirectionMaxCells
 assert(cols>=1 and cols<=5 and cell.X.Offset>=124 and cell.Y.Offset>=116)
 local rows=math.floor((U.Grid.AbsoluteSize.Y+6)/(cell.Y.Offset+6));assert(rows<=6)
 if SCREEN_W==1920 then assert(cols==5 and rows==6,'expected 5x6 at 1080p')end
end
U.Root.Visible=true;U.Grid.Visible=true;C.Search();flush();assert(guiCards(U.Grid)==2)
local priceFound=false
for _,c in ipairs(U.Grid:GetChildren())do if c:IsA('GuiButton')then for _,t in ipairs(c:GetChildren())do if t:IsA('TextLabel')and t.Text=='1.234 Robux'then priceFound=t.TextSize>=15 end end end end
assert(priceFound);U.More.Activated:Fire();flush();assert(guiCards(U.Grid)==3 and not U.More.Visible)
return 'grid capped at 5x6, >=124x116px cells, explicit grouped Robux prices, complete next page'
'''.replace("'CATALOG_SOURCE'",q(src('09C2_SHOP_CATALOG'))))
Path(__file__).with_name('results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
print('Validated',len(results),'cases')
