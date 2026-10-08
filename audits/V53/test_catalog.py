from test_support import *
CART=module('09C4_OUTFIT_LIBRARY')
CATALOG=CART+module('09C2_SHOP_CATALOG')
case('full_outfit_resolves_package_and_deduplicates_parts',DATA+module('09B6_CART_RESOLVER')+r'''
local Resolver=Modules['09B6_CART_RESOLVER']
function Services.MarketplaceService:GetProductInfoAsync(id)return{Name='Asset '..id,PriceInRobux=10,IsForSale=id~=14 and id~=15}end
Details[500]={Id=500,Name='Corpo completo',Price=80,ItemType='Bundle',IsForSale=true}
Bundles[500]={Items={{Type='Asset',Id=14},{Type='Asset',Id=15}}}
function Services.AvatarEditorService:GetBundlesByAssetIdAsync(id,limit)assert(limit==10);return{GetCurrentPage=function()if id==14 or id==15 then return{{Id=500}}end;return{}end}end
local items=Resolver.Outfit(pl,S.Current);local bundles=0
for _,v in ipairs(items)do assert(v.id~=14 and v.id~=15);if v.kind=='Bundle'then assert(v.id==500);bundles=bundles+1 end end
assert(bundles==1)
OwnedBundles[500]=true;local quote=Resolver.Quote(pl,items);for _,v in ipairs(quote)do if v.id==500 then assert(v.owned)end end
return 'two non-sale body pieces become one native purchasable bundle; duplicate pieces excluded and ownership refreshed'
''')
case('cart_quote_does_not_guess_price_or_ownership',DATA+module('09B6_CART_RESOLVER')+r'''
function Services.MarketplaceService:GetProductInfoAsync(id)if id==77 then error('offline')end;return{Name='Off',IsForSale=false,PriceInRobux=19}end
function Services.MarketplaceService:PlayerOwnsAssetAsync()error('offline')end
local rows=Modules['09B6_CART_RESOLVER'].Quote(pl,{{id=77,kind='Asset'},{id=88,kind='Asset'}})
assert(rows[1].owned==nil and rows[1].price==nil and not rows[1].known)
assert(rows[2].owned==nil and rows[2].price==nil and rows[2].unavailable)
return 'metadata/ownership failures remain unknown; off-sale price is not counted as a buyable item'
''')
case('server_cart_rejects_bad_ids_and_excludes_owned_or_unavailable',DATA+SERVER+r'''
function Services.MarketplaceService:GetProductInfoAsync(id)return{Name='Item '..id,IsForSale=id~=88,PriceInRobux=12}end
OwnedAssets[91]=true;Details[500]={Id=500,Price=80,IsForSale=true}
local r=RPC:InvokeServer('CartPurchase',{items={{id=88},{id=91},{id=92},{id=500,kind='Bundle'},{id=500,kind='Bundle'}}})
assert(r.ok and r.data.count==2,r.error);assert(#LastBulk==2)
for _,v in ipairs(LastBulk)do assert(v.Id=='92'or v.Id=='500')end
assert(not RPC:InvokeServer('CartPurchase',{items={{id=0/0}}}).ok)
assert(not RPC:InvokeServer('CartPurchase',{items={{id=2,kind='Product'}}}).ok)
return 'native bulk prompt includes unique valid asset and bundle only; owned/off-sale and forged IDs excluded on server'
''')
case('cart_resolves_before_buy_and_keeps_selection',UI+DATA+CART+r'''
local calls={};local cart=Modules['09C4_OUTFIT_LIBRARY']
cart.Init({U=U,A=A,S=S,pl=pl,toast=function()end,openUtility=function()U.CartPanel.Visible=true end,closeUtility=function()U.CartPanel.Visible=false end,call=function(a,args)
 calls[#calls+1]={a=a,args=args}
 if a=='OutfitQuote'then return{items={{id=500,kind='Bundle',name='A Bundle',price=80,known=true},{id=11,kind='Asset',name='Owned',owned=true,price=10},{id=88,kind='Asset',name='Off sale',unavailable=true},{id=99,kind='Asset',name='Unknown'}}}end
 if a=='CartQuote'then return{items={}}end
 if a=='CartPurchase'then return{count=#args.items}end
end})
cart.Open(S.Current);assert(not U.CartBuySelected.Active);U.CartBuySelected.Activated:Fire();assert(#calls==0)
flush();assert(U.CartBuySelected.Active and U.CartTotal.Text=='SUBTOTAL: 80 Robux')
U.CartBuySelected.Activated:Fire();assert(calls[#calls].a=='CartPurchase'and #calls[#calls].args.items==2)
local bundleRow=U.CartList:GetChildren()[2];for _,row in ipairs(U.CartList:GetChildren())do if row:IsA('Frame')then
 for _,b in ipairs(row:GetChildren())do if b:IsA('GuiButton')and b.Text=='ON'then b.Activated:Fire();bundleRow=nil;break end end;if not bundleRow then break end
end end
U.CartBuySelected.Activated:Fire();assert(#calls[#calls].args.items==1 and calls[#calls].args.items[1].id==99)
cart.Close();local n=#calls;S.Changed:Fire();flush();assert(#calls==n,'closed cart queried on every avatar edit')
cart.Open();flush();U.CartBuySelected.Activated:Fire();assert(#calls[#calls].args.items==1 and calls[#calls].args.items[1].id==99)
return 'checkout disabled until bundle resolution; known subtotal honest; unchecked bundle remains unchecked after refresh; closed cart does not flood requests'
''')
case('catalog_reuses_slots_and_clicks_current_item',UI+DATA+CATALOG+r'''
local pgIndex=1
function Services.AvatarEditorService:SearchCatalogAsync()
 pgIndex=1;local page={IsFinished=false}
 function page:GetCurrentPage()local out={};for i=1,50 do local id=(pgIndex-1)*50+i;out[i]={Id=7000+id,Name='Item '..id,Price=41,ItemType='Asset',AssetType='Hat'}end;return out end
 function page:AdvanceToNextPageAsync()pgIndex=pgIndex+1;self.IsFinished=pgIndex==8 end
 return page
end
local cart=Modules['09C4_OUTFIT_LIBRARY'];cart.Init({U=U,A=A,S=S,pl=pl,toast=function()end,call=function()return{items={}}end})
local ctl=Modules['09C2_SHOP_CATALOG'].Init({U=U,A=A,S=S,pl=pl,toast=function()end,call=function()return true end})
U.Root.Visible=true;U.Grid.Visible=true;ctl.Search();flush()
for i=1,7 do U.More.Activated:Fire();flush()end
assert(#ctl.GetRows()==400 and #ctl.Pool<=40)
U.Grid.CanvasPosition=Vector2.new(0,U.GridLayout.CellSize.Y.Offset*10);U.Grid:GetPropertyChangedSignal('CanvasPosition'):Fire();flush()
local slot=ctl.Pool[1];local id=slot.item.Id;slot.root.Activated:Fire();flush();assert(U.DetailName.Text==slot.item.Name)
local old=A.Copy(S.Current);local before=cart.Count();U.Favorite.Activated:Fire();assert(cart.Count()==before+1)
assert(S.Current.props.Shirt==old.props.Shirt and S.Current.props.Torso==old.props.Torso and #S.Current.accessories==#old.accessories)
Details[id]={Id=id,AssetType='Hat'};U.Try.Activated:Fire();assert(cart.Count()==before+1)
local found=false;for _,a in ipairs(S.Current.accessories)do if a.id==id then found=true end end;assert(found)
ctl.Search();flush();assert(#ctl.GetRows()==50 and #ctl.Pool<=40)
return '400 catalog items use at most 40 GUI cards; recycled click maps to current item; cart button keeps avatar; trying item adds it once'
''')
HERE.joinpath('catalog_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')

