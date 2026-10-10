from test_support import *
CART=PREVIEW+module('09C4_OUTFIT_LIBRARY')
case('safe_cart_looks_and_save_actions_use_all_available_space',UI+DATA+CART+r'''
local cart=Modules['09C4_OUTFIT_LIBRARY'];cart.Init({U=U,A=A,S=S,pl=pl,toast=function()end,call=function()return{items={}}end})
U.Root.Visible=true;U.SetWide(true);U.OutfitActions.Visible=true
local sizes={{390,844,0,0,34},{851,392,44,44,21},{667,375,0,0,0},{568,320,0,0,0},{320,568,0,0,0},{1920,1080,0,0,0}}
for _,size in ipairs(sizes)do
 SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=size[1],size[2],size[3],size[4],size[5]
 CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM,DEVICE_TOP=size[3],size[4],58,120,0;U.Layout()
 local il,it,ir,ib,w,h=U.SafeBounds.Read();local root=U.Root.AbsolutePosition
 local function safe(o,topbar)
  local p,s=o.AbsolutePosition,o.AbsoluteSize;local y=it
  if topbar then local b=U.SafeBounds.Topbar();y=b.Y;assert(p.X-root.X>=b.X-1 and p.X+s.X-root.X<=b.Right+1)end
  assert(p.X-root.X>=il-1 and p.X+s.X-root.X<=w-ir+1 and p.Y-root.Y>=y-1 and p.Y+s.Y-root.Y<=h-ib+1,o.Name..' unsafe')
 end
 for _,o in ipairs({U.CartList,U.CartSummary,U.SavedPreviewPanel,U.SavedGridPanel,U.SaveStage,U.SaveName,U.SaveR15,U.SaveR6,U.CancelSave})do safe(o,false)end
 assert(math.abs(U.CartSummary.AbsolutePosition.Y+U.CartSummary.AbsoluteSize.Y-root.Y-(h-ib-6))<1)
 for _,b in ipairs({U.CartClose,U.CartSelected,U.CartOutfit,U.CartClear,U.CartBuySelected,U.CartRefresh,U.OutfitSaveNew,U.LookSearch,U.SaveClose,U.SaveR15,U.SaveR6,U.CancelSave})do
  inside(b,b.Parent);assert(b.AbsoluteSize.Y>=44 and b.AbsoluteSize.X>=44,b.Name..' small')
 end
 for i,b in ipairs({U.OutfitApply,U.OutfitUpdate,U.OutfitRestore,U.OutfitBuy,U.OutfitDelete,U.OutfitPublish})do
  inside(b,U.OutfitActions);assert(b.AbsoluteSize.Y>=44);if i>1 then assert(not intersects(b,({U.OutfitApply,U.OutfitUpdate,U.OutfitRestore,U.OutfitBuy,U.OutfitDelete,U.OutfitPublish})[i-1]))end
 end
 assert(not U.OutfitActions.ScrollingEnabled and not intersects(U.SavedGrid,U.OutfitActions))
 inside(U.SavedPreview,U.SavedStage);assert(U.SavedPreview.AbsoluteSize.Y>=80)
 assert(not intersects(U.SaveR15,U.SaveR6)and not intersects(U.SaveName,U.SaveR15)and not intersects(U.CancelSave,U.SaveR15))
end
return 'six phone/desktop sizes with real core-origin/cutout arithmetic; checkout reaches safe bottom; six look actions and save form fit without scrolling; 44px touch controls'
''')
case('community_has_two_columns_and_reuses_real_avatar_slots',UI+DATA+PREVIEW+COMMUNITY+r'''
U.Root.Visible=true;U.CommunityArea.Visible=true;U.SetWide(true)
local feed=Modules['09C7_COMMUNITY_FEED'].Init({U=U,A=A,toast=function()end,show=function()end,call=function(a,args)
 local out={};for i=1,50 do local id=(args.page or 0)*50+i;out[i]={id='player'..id,signature='body'..id,body=A.Copy(S.Current),rig='R15',source='Roblox',owner=1000+id,name='Look '..id,total=41}end
 return{items=out,finished=false}
end})
feed.Open();flush();assert(#feed.Rows==50 and #feed.Pool==50)
for _,size in ipairs({{390,844},{851,392},{568,320},{1920,1080}})do
 SCREEN_W,SCREEN_H=size[1],size[2];U.Layout();feed.Layout();U.CommunityGrid:GetPropertyChangedSignal('AbsoluteSize'):Fire();flush()
 local first,second,third=feed.Pool[1],feed.Pool[2],feed.Pool[3]
 assert(first.root.Visible and second.root.Visible and third.root.Visible)
 assert(first.root.AbsolutePosition.Y==second.root.AbsolutePosition.Y)
 assert(third.root.AbsolutePosition.Y>first.root.AbsolutePosition.Y and third.root.AbsolutePosition.X==first.root.AbsolutePosition.X)
 inside(first.stage,first.root);assert(first.image.BackgroundTransparency==1 and first.image.ZIndex>first.stage.ZIndex)
 assert(U.ComSearchGo.Text==''and named(U.ComSearchGo,'Icon_search'))
end
for _=1,12 do U.ComMore.Activated:Fire();flush()end;assert(#feed.Rows<=100 and feed.Evicted>0)
U.CommunityGrid.CanvasPosition=Vector2.new(0,2000);U.CommunityGrid:GetPropertyChangedSignal('CanvasPosition'):Fire();flush()
local id=feed.Pool[1].record.id;U.CommunityGrid.CanvasPosition=Vector2.zero;U.CommunityGrid:GetPropertyChangedSignal('CanvasPosition'):Fire();flush();assert(feed.Pool[1].record.id~=id)
return 'exactly two outfit columns, light stages behind real-player thumbnails; 50 reused slots and at most 100 buffered outfits; forward/backward scroll rebinds records'
''')
case('saved_look_item_x_does_not_cover_thumbnail_and_small_errors_stay_compact',UI+DATA+PREVIEW+COMMUNITY+module('09C1_SHOP_LOOKS')+r'''
FailVisual=true;U.Root.Visible=true;U.LooksArea.Visible=true;U.SetWide(true)
local ctl=Modules['09C1_SHOP_LOOKS'].Init({U=U,A=A,S=S,toast=function()end,buyBody=function()end,call=function(a)
 if a=='List'then return{skins={{id='one',name='Meu gato',body=A.Copy(S.Current),rig='R15'}},persistent=true}end;return{items={},finished=true}
end})
ctl.Saved();flush()
local item=named(U.SavedItems,'SavedItem_11');local image=named(item,'ItemThumbnail');local remove=named(item,'RemoveSavedItem')
assert(remove.AbsoluteSize.X==44 and remove.AbsoluteSize.Y==44 and not intersects(remove,image))
local slot=named(U.SavedGrid,'SavedLook_one');local mini=named(slot,'PreviewLoadStatus');assert(mini.Text=='Prévia indisponível'and mini.AbsoluteSize.Y==22)
assert(U.SavedPreview.RetryAvatar.Visible);FailVisual=false;U.SavedPreview.RetryAvatar.Activated:Fire();flush();assert(Preview.Get(U.SavedPreview).Model)
remove.Activated:Fire();flush();assert(not named(U.SavedItems,'SavedItem_11'))
return 'main preview can retry; thumbnail error is one compact line; each item has a separate 44px X and removal affects only that draft item'
''')
case('cart_quote_failure_can_reload_without_changing_avatar',UI+DATA+CART+r'''
local fail=true;local before=A.Copy(S.Current);local bought=0
local cart=Modules['09C4_OUTFIT_LIBRARY'];cart.Init({U=U,A=A,S=S,pl=pl,toast=function()end,call=function(a)
 if a=='OutfitQuote'and fail then return nil,'Roblox indisponível · Recarregar'end
 if a=='OutfitQuote'then return{items={{id=1234,kind='Asset',price=41,name='Camisa',known=true}}}end
 if a=='CartPurchase'then bought=bought+1;return{count=1}end
 return{items={}}
end})
cart.Open(S.Current);flush();assert(U.CartHint.Text:find('indisponível')and U.CartRefresh.Active and U.CartBuySelected.Text~='Consultando…')
fail=false;U.CartRefresh.Activated:Fire();flush();assert(U.CartTotal.Text=='Estimativa: 41 Robux'and U.CartBuySelected.Active)
U.CartBuySelected.Activated:Fire();assert(bought==1)
assert(S.Current.props.Shirt==before.props.Shirt and S.Current.props.Torso==before.props.Torso and #S.Current.accessories==#before.accessories)
return 'failed full-look quote releases controls; reload succeeds, authoritative purchase is available, and opening or buying never resets the preview'
''')
case('gradient_preserves_designed_colors_and_text_contrast',THEME+r'''
local fx=Modules['07UI_SURFACE_EFFECTS'];local d=Modules['07UI_DESIGN_SYSTEM'];local f=d.Frame(pg,{})
local lo,hi=Color3.fromRGB(14,23,35),Color3.fromRGB(23,58,58);fx.Surface(f,lo,hi)
local g=f:FindFirstChild('V54Gradient');for i,expected in ipairs({lo,hi})do for _,channel in ipairs({'R','G','B'})do assert(math.abs(f.BackgroundColor3[channel]*g.Color[i][channel]-expected[channel])<.00001)end end
assert(f.BackgroundColor3.R<.1 and f.BackgroundColor3.G<.25,'full-screen backdrop must stay dark')
local text=d.Text(pg,'SUA DUPLA',{TextColor3=fx.Colors.gold});fx.Surface(text,lo,hi);local tg=text:FindFirstChild('V54Gradient');assert(tg.Color[1].R==1 and tg.Color[2].R>=.9)
local b=d.Button(pg,'Jogar');fx.Button(b);b.BackgroundColor3=fx.Colors.jade;local bg=b:FindFirstChild('V54ButtonLight');assert(bg.Color[1].R==1 and bg.Color[2].G>=.9)
return 'surface endpoints reproduce intended navy/jade colors after Roblox gradient multiplication; score and buttons retain bright readable text; native backdrop remains dark'
''')
HERE.joinpath('utility_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
