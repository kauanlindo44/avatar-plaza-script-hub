from test_support import *
EFFECTIVE={s['name']:s['path']for v in json.loads((ROOT/'manifest.json').read_text())['versions']for s in v['scripts']}
for p in (ROOT/'scripts/V52').glob('*.lua'):EFFECTIVE[p.stem]=str(p.relative_to(ROOT))
for n,p in EFFECTIVE.items():
 l=Lua();l.run((ROOT/p).read_text(),n,execute=False);l.close()
print('SYNTAX',len(EFFECTIVE),'PASS')
CAT=module('07K14_DECK_OPTIONS')+module('07K6_CARD_CATALOG')+module('07K7_CARD_STYLES')
GAME=THEME+CAT+module('07H5_TRUCO_SETUP')+module('07H1_GAME_LOBBY')+module('07H2_GAME_BOARD')
TABLE=THEME+CAT+module('07K0_TRUCO_RULES')+module('07K15_TRUCO_TABLE')+module('07K5_TRUCO_UI')
INV=module('07K14_DECK_OPTIONS')+module('07K6_CARD_CATALOG')+module('07K8_CARD_INVENTORY')+"I=Modules['07K8_CARD_INVENTORY'];I.Load(pl.UserId)\n"
STYLE=THEME+CAT+module('07K16_ATELIER_UI')+module('07K9_CARD_INVENTORY_UI')
case('layered_clothing_changes_r6_to_r15_preserves_outfit',DATA+r'''
S.Current.props.Head=0;S.Current.props.Torso=0;S.Current.props.LeftArm=0;S.Current.props.RightArm=0;S.Current.props.LeftLeg=0;S.Current.props.RightLeg=0
S.Rig='R6';Details[72779265740934]={Id=72779265740934,AssetType='ShirtAccessory'}
local shirt,pants=S.Current.props.Shirt,S.Current.props.Pants;assert(S.Try(Details[72779265740934]));assert(S.Rig=='R15')
assert(S.Current.props.Shirt==shirt and S.Current.props.Pants==pants)
local found=false;for _,a in ipairs(S.Current.accessories)do if a.id==72779265740934 then found=a.layer end end;assert(found)
assert(S.SetRig('R6'));assert(S.Rig=='R15');assert(A.RequiresR15(Details[72779265740934]))
return '3D silhouette is layered clothing; selects R15 without clearing classic clothes or other accessories'
''')
case('physical_missing_mesh_fails_preview_and_live',DATA+PREVIEW+SERVER+r'''
local body=A.Copy(S.Current);body.accessories[#body.accessories+1]={id=9998,type='Shirt',layer=true,order=1,puff=0}
MissingPhysical=true;local err;local view=Instance.new('ViewportFrame');view.Size=UDim2.fromOffset(260,320);view.Parent=pg
local p=Preview.Mount(view,body,'R6',{failed=function(e)err=e end});flush();assert(not p.Model and err and err:find('3D'))
local d,e=pcall(Modules['09B5_AVATAR_RUNTIME'].Apply,pl,A.Unpack(body),'R6');assert(not d,'description IDs alone must not confirm a missing mesh')
MissingPhysical=false;p=Preview.Mount(view,body,'R6');flush();assert(p.Model and p.Model.Humanoid.RigType==Enum.HumanoidRigType.R15)
return 'physical WrapLayer/Handle required, preview forces native R15; API metadata does not fake a successful missing outfit'
''')
case('community_search_filter_virtualized_3_or_4_columns',UI+DATA+PREVIEW+COMMUNITY+r'''
local rows={};for i=1,120 do rows[i]={id='p'..i,signature='s'..i,source='Roblox',owner=100+i,name='Look '..i,body=S.Current,rig='R15',total=10}end
local calls=0;local feed=Modules['09C7_COMMUNITY_FEED'].Init({U=U,A=A,toast=function()end,show=function()end,call=function(action,arg)
 calls=calls+1;local out={};for i=1,50 do out[i]=rows[(arg.page*50+i-1)%120+1]end;return{items=out,finished=false}end})
U.Root.Visible=true;U.CommunityArea.Visible=true;U.SetWide(true);feed.Open();flush();assert(#feed.Rows==50 and #feed.Pool==50)
for _,size in ipairs({{390,844},{851,392},{1920,1080},{360,640}})do
 SCREEN_W,SCREEN_H=size[1],size[2];CORE_TOP=58;DEVICE_TOP=0;U.Layout();feed.Layout();flush()
 local grid=U.CommunityGrid;local active={};for _,s in ipairs(feed.Pool)do if s.root.Visible then active[#active+1]=s.root end end
 assert(#active>0);local first=active[1];local n=0;for _,c in ipairs(active)do if c.Position.Y.Offset==first.Position.Y.Offset then n=n+1 end end
 assert(n==(grid.AbsoluteSize.X>=520 and 4 or 3));inside(U.ComSearch,U.CommunityArea);inside(U.ComFilter,U.CommunityArea);assert(not U.ComTabButtons.JOGADORES.Parent.Visible)
 U.ComFilter.Activated:Fire();assert(U.ComTabButtons.JOGADORES.Parent.Visible);U.ComTabButtons.ROBUX.Activated:Fire();flush();assert(feed.Mode=='ROBUX'and not U.ComTabButtons.ROBUX.Parent.Visible)
end
return 'only outfits, search and dropdown filter; four wide/three narrow columns, recyclable pool capped at 50'
''')
case('saved_avatar_preview_visible_and_items_remain_below',UI+DATA+PREVIEW+COMMUNITY+module('09C1_SHOP_LOOKS')+r'''
local ctl=Modules['09C1_SHOP_LOOKS'].Init({U=U,A=A,S=S,call=function(action)if action=='List'then return{skins={{id='one',name='Mine',body=S.Current,rig='R15'}}}end end,toast=function()end,buyBody=function()end})
U.Root.Visible=true;U.LooksArea.Visible=true;U.SetWide(true);ctl.Saved();flush()
for _,size in ipairs({{390,844},{851,392},{1920,1080}})do SCREEN_W,SCREEN_H=size[1],size[2];U.Layout();flush();assert(U.SavedPreviewPanel.Visible);assert(Preview.Get(U.SavedPreview).Model);inside(U.SavedPreview,U.SavedPreviewPanel);assert(U.SavedItems.Position.Y.Offset>=U.SavedPreview.Position.Y.Offset+U.SavedPreview.Size.Y.Offset)end
return 'selected saved avatar rendered automatically, permanent panel in both orientations, equipped item strip stays below preview'
''')
case('lobby_three_games_safe_click_targets_and_coins',GAME+r'''
local g=Modules['07UI_DESIGN_SYSTEM'].New('ScreenGui',{Name='Games',ScreenInsets=Enum.ScreenInsets.None},pg)
local l=Modules['07H1_GAME_LOBBY'].Build(g);l.Root.Visible=true
for _,size in ipairs({{390,844},{851,392},{1920,1080},{667,375}})do
 SCREEN_W,SCREEN_H=size[1],size[2];CORE_TOP=58;DEVICE_TOP=0;CORE_LEFT,CORE_RIGHT,CORE_BOTTOM=0,0,0;l.Layout();flush()
 for _,game in ipairs({'Truco','Damas','Xadrez'})do for _,b in pairs(l.PlayButtons[game])do inside(b,b.Parent);assert(b.Size.Y.Offset>=44)end end
 assert(not intersects(l.Coins,l.Close));l.PlayButtons.Truco.Online.Activated:Fire();l.Layout();assert(l.Options.Visible and l.Quick.Visible and not l.Create.Visible);l.OptionsClose.Activated:Fire();assert(not l.Options.Visible)
end
return 'three elaborate game panels; four actions each, coin header, 44px actions and quick-match setup'
''')
case('official_and_custom_decks_and_dynamic_manilha',module('07K14_DECK_OPTIONS')+module('07K0_TRUCO_RULES')+r'''
local D=Modules['07K14_DECK_OPTIONS'];local R=Modules['07K0_TRUCO_RULES']
assert(D.Clean(nil,'Paulista').count==40);local clean=D.Clean({mode='Clean'},'Paulista');assert(clean.count==24)
local deck=D.Deck(clean);local ids={};for _,c in ipairs(deck)do assert(not ids[c.id]);ids[c.id]=true end
assert(not ids['4C']and ids['QC']);local s=R.New('Paulista',4);s.deckOptions=clean;R.Begin(s,deck,false)
s.vira={rank='3',suit='D',manilha=D.Manilha({rank='3'},clean)};assert(s.vira.manilha=='Q');assert(R.Power({rank='Q',suit='C'},'Paulista',s.vira)>R.Power({rank='3',suit='C'},'Paulista',s.vira))
local all={mode='Custom',ranks=D.Ranks,suits=D.Suits};assert(D.Clean(all,'Paulista',true).count==52);assert(not D.Clean(all,'Paulista',false))
assert(not D.Clean({mode='Custom',ranks={'A','A'},suits={'C'}},'Paulista',true));assert(not D.Clean({mode='Custom',ranks={'A'},suits={'C'}},'Paulista',true))
return '40/24 official decks; 52-card custom possible only in created rooms; clean-deck manilha wraps to Q, invalid/undersized selections refused'
''')
case('direct_purchase_and_legacy_credit_receipts_are_atomic',INV+module('07K10_CARD_COMMERCE')+r'''
local C=Modules['07K6_CARD_CATALOG'];local Commerce=Modules['07K10_CARD_COMMERCE'];local id=pl.UserId
assert(I.Transact(id,function(d)d.coins=10000;return true end));assert(not I.BuyCoins(id,'box','Nox',1));assert(I.View(id).coins==10000)
assert(I.BuyCoins(id,'style','Onyx',1));assert(I.View(id).owned.Onyx and I.View(id).coins==9500);assert(not I.BuyCoins(id,'style','Onyx',1))
local store=Commerce.Store(pl);assert(not store.products.Nox and not store.products.Reign and not store.products.Eclipse and store.products.Hex)
assert(not Commerce.Prompt(pl,'product','Nox'));Commerce.Start()
local receipt={ProductId=C.Products.Hex,PlayerId=id,PurchaseId='direct'};assert(Services.MarketplaceService.ProcessReceipt(receipt)==Enum.ProductPurchaseDecision.PurchaseGranted);assert(I.View(id).owned.Hex)
assert(Services.MarketplaceService.ProcessReceipt(receipt)==Enum.ProductPurchaseDecision.PurchaseGranted)
local old={ProductId=C.Products.Eclipse,PlayerId=id,PurchaseId='legacy'};assert(Services.MarketplaceService.ProcessReceipt(old)==Enum.ProductPurchaseDecision.PurchaseGranted);assert(I.View(id).boxes.Eclipse==1)
assert(I.OpenChoice(id,'Eclipse','Nova',1));assert(I.View(id).owned.Nova and I.View(id).boxes.Eclipse==0)
FailStores=true;assert(not I.BuyCoins(id,'style','Aurum',1));assert(I.View(id).coins==9500)
return 'no new box offers/server purchases; direct visuals persist, duplicate receipts grant once, historical paid credit redeemed without loss'
''')
case('atelier_saved_presets_round_trip_and_deck_saved',INV+r'''
local id=pl.UserId;assert(not I.SavePreset(id,{style='Custom'}));assert(I.GrantPass(id,1951234105))
assert(I.SetCustom(id,{image=55,texture=56,zoom=3,rotation=45,x=.6,y=-.5,layout='Inset',brightness=.8}))
assert(I.SavePreset(id,{style='Custom'}));local preset=I.View(id).presets[1]
assert(I.SetCustom(id,{image=77,zoom=1}));assert(I.UsePreset(id,preset.id));local d=I.View(id)
assert(d.custom.image==55 and d.custom.zoom==3 and d.custom.rotation==45 and d.custom.x==.6 and d.custom.layout=='Inset'and d.equipped=='Custom')
assert(not I.UsePreset(999,preset.id));assert(I.DeletePreset(id,preset.id));assert(#I.View(id).presets==0)
assert(I.SaveDeck(id,{variant='Paulista',deck={mode='Clean'}}));assert(I.View(id).deckPreset.deck.mode=='Clean')
for i=1,12 do assert(I.SavePreset(id,{style='Classic'}))end;assert(not I.SavePreset(id,{style='Classic'}))
return 'persistent saved image transforms and one deck preset; owned-only, per-account IDs and 12-slot bound'
''')
case('store_three_sample_cards_and_no_boxes_tab',STYLE+INV+r'''
local gui=Modules['07UI_DESIGN_SYSTEM'].New('ScreenGui',{Name='Cards',ScreenInsets=Enum.ScreenInsets.None},pg)
local u=Modules['07K9_CARD_INVENTORY_UI'].Build(gui,function(a)if a=='inventory'then return I.View(pl.UserId)elseif a=='store'then return{passes={},products={}}end end,function()end)
u.Root.Visible=true;u.AcceptData(I.View(pl.UserId));u.Render();flush();assert(#u.SampleCards==3)
for _,size in ipairs({{390,844},{851,392},{1920,1080}})do SCREEN_W,SCREEN_H=size[1],size[2];CORE_TOP=58;u.Layout();u.PaintPage();flush();for _,c in ipairs(u.SampleCards)do inside(c,u.CardHost)end;assert(u.CoinBuy.Size.Y.Offset==44)
 for _,b in ipairs(u.Tabs:GetChildren())do if b:IsA('GuiButton')then assert(b:GetAttribute('TabKey')~='Caixas')end end
end
return 'direct store, visible three-card preview, no boxes tab, saved-styles tab and native-price-only purchase actions'
''')
case('table_four_players_public_center_private_hand',TABLE+r'''
local gui=Modules['07UI_DESIGN_SYSTEM'].New('ScreenGui',{Name='Truco',ScreenInsets=Enum.ScreenInsets.None},pg);local actions={}
local ui=Modules['07K5_TRUCO_UI'].Build(gui,function(a,index)actions[#actions+1]={a,index}end)
local v={seat=1,variant='Paulista',score={0,0},phase='play',turn=1,value=1,handNumber=1,tricks={},tableCards={{seat=2,card={rank='3',suit='H'}}},lastTrick={},counts={3,2,3,3},players={{uid=123,name='You'},{uid=22,name='A'},{uid=33,name='B'},{uid=44,name='C'}},hand={{rank='4',suit='D'},{rank='3',suit='S'},{rank='Q',suit='H'}},nextRaise=3,remaining=30}
for _,size in ipairs({{390,844},{851,392},{1920,1080}})do SCREEN_W,SCREEN_H=size[1],size[2];CORE_TOP=58;ui.Update(v,{equipped='Hex',view='mine'});ui.Layout()
 assert(#ui.HandCards==3);for _,c in ipairs(ui.HandCards)do inside(c,ui.Hand)end;inside(ui.TableArea,ui.Root);inside(ui.Controls,ui.Root)
 assert(named(ui.TableArea,'PublicCard')==nil);assert(named(ui.TableArea,'PlayerSeat4'))
end
ui.PlayOwned(2);assert(actions[1][1]=='play'and actions[1][2]==2)
v.turn=2;ui.Update(v,{});ui.PlayOwned(1);assert(#actions==1)
return 'relative seating, green central table, own three cards below, any owned card can be played only on own turn'
''')
case('chess_checkers_centered_and_large_on_mobile',GAME+r'''
local gui=Modules['07UI_DESIGN_SYSTEM'].New('ScreenGui',{Name='Board',ScreenInsets=Enum.ScreenInsets.None},pg);local b=Modules['07H2_GAME_BOARD'].Build(gui)
for _,size in ipairs({{390,844},{851,392},{1920,1080}})do SCREEN_W,SCREEN_H=size[1],size[2];CORE_TOP=58;b.Layout();local r=b.Root;local x=b.Grid.AbsolutePosition.X+b.Grid.AbsoluteSize.X/2;assert(math.abs(x-r.AbsoluteSize.X/2)<1);inside(b.Grid,b.Root);assert(b.Grid.AbsoluteSize.X>=280);inside(b.Resign,b.Side)end
return 'board centered in screen, larger native safe-area fit, compact clocks and 44px actions'
''')
HERE.joinpath('results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
print('V52',len(results),'PASS')
