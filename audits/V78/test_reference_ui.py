from test_support import *
SIZES='{{320,568,0,0,0},{390,844,0,0,34},{568,320,0,0,0},{667,375,0,0,0},{851,392,44,44,21},{1066,480,0,0,0},{1280,720,0,0,0}}'
HUD=THEME+module('07G6_WORLD_DETAILS')+module('07G4_WORLD_SCENERY')+module('07G7_ADVENTURE_WORLD')+module('07G2_LOCAL_WORLDS')+module('07G1_HUB_SETTINGS')
case('v77_hud_geometry',HUD+src('07G_HUB_UI')+r'''
flush();local root=named(pg.LimitedMarketHUD,'HudRoot')
local names={'TopCatalog','TopStores','Community','Emotes','Looks','Loader','Effects','Body','CurrentlyWearing','RestoreAvatar','Games','Photo','Commands','Cfg','AvatarTools','HideUI','Undo','Redo','TopMusic','Cart','RemoveItems','NewAvatar','SaveRoblox','Assistant'}
for _,touch in ipairs({false,true})do Services.UserInputService.TouchEnabled=touch
 for _,sz in ipairs('''+SIZES+r''')do
 SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0
 root:GetPropertyChangedSignal('AbsoluteSize'):Fire();flush();local visible={}
 for _,n in ipairs(names)do local b=named(pg.LimitedMarketHUD,n)or named(pg.AvatarShopLauncherGui,n)
 if b.Visible then local ok,err=pcall(inside,b,pg.LimitedMarketHUD);assert(ok,tostring(err).." screen="..SCREEN_W..","..SCREEN_H.." hud="..pg.LimitedMarketHUD.AbsoluteSize.X..","..pg.LimitedMarketHUD.AbsoluteSize.Y);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44,n)
 for _,o in ipairs(visible)do assert(not intersects(b,o),n..' overlaps '..o.Name..' at '..SCREEN_W..'x'..SCREEN_H..' touch '..tostring(touch))end;visible[#visible+1]=b end end
 if touch then local jump=Instance.new('Frame');jump.Position=UDim2.fromOffset(SCREEN_W-(sz[4]or 0)-150,SCREEN_H-(sz[5]or 0)-150);jump.Size=UDim2.fromOffset(150,150);jump.Parent=pg.LimitedMarketHUD;for _,b in ipairs(visible)do assert(not intersects(b,jump),b.Name..' covers jump')end;jump:Destroy()end
 end
end
return '24 HUD destinations; 14 safe geometries; no mutual overlap; 44px minimum'
''')
PHOTO=THEME+module('07P4_STUDIO_UI')+module('07P9_STUDIO_CATALOG')
case('v77_photo_reference_bar_and_grid',PHOTO+r'''
local u=Modules['07P4_STUDIO_UI'].Build(pl);u.Root.Visible=true
function Services.AvatarEditorService:SearchCatalogAsync()local rows={};for i=1,30 do rows[i]={Id=8000+i,Name='Item '..i}end;return{IsFinished=true,GetCurrentPage=function()return rows end}end
for _,sz in ipairs('''+SIZES+r''')do
 SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0
 for _,mode in ipairs({'Background','Animations'})do u.Popup.Visible=true
 Modules['07P9_STUDIO_CATALOG'].Open(u,mode,function()end,function()end);flush();u.Layout();flush()
 inside(u.Popup,u.Gui);inside(u.Nav,u.Gui);assert(not intersects(u.Popup,u.Nav))
 for _,v in ipairs(u.SceneMargins)do assert(v==0)end
 for _,b in ipairs({u.Close,u.Buttons.Background,u.Buttons.Animations,u.Rotate,u.Buttons.Hide})do inside(b,u.Nav);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44)end
 for _,n in ipairs({'PreviousEmotePage','NextEmotePage','StudioCatalogOptions','SearchStudioCatalog'})do local b=named(u.Content,n);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44,n);inside(b,u.Popup)end
 local list=named(u.Content,'StudioCatalogItems');local cards=list:GetChildren();assert(#cards>=3 and #cards<=9 and #cards%3==0,mode.." cards="..#cards.." "..SCREEN_W.."x"..SCREEN_H.." host="..list.Parent.AbsoluteSize.X..","..list.Parent.AbsoluteSize.Y)
 for i,c in ipairs(cards)do inside(c,u.Popup);assert(c.AbsoluteSize.X>=44 and c.AbsoluteSize.Y>=44,mode.." card size "..c.AbsoluteSize.X..","..c.AbsoluteSize.Y.." "..SCREEN_W);assert(c.Position.X.Offset==cards[(i-1)%3+1].Position.X.Offset)end
 end
end
return 'five primary actions, panels separate from toolbar, three columns, avatar margins zero'
''')
case('v77_catalog_home_six_tiles',UI+DATA+module('09C16_CATALOG_HOME')+r'''
local home=Modules['09C16_CATALOG_HOME'].Build({U=U,A=A,browse=function()end,call=function()return{items={}}end,toast=function()end});home.Open()
for _,sz in ipairs('''+SIZES+r''')do
 SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP=sz[3],sz[4],58
 U.SetWide(false);U.Layout();home.Layout();inside(U.Main,U.Gui);inside(U.Left,U.Gui)
 for _,control in ipairs({U.LoaderClose,U.LoaderQuery,U.LoaderMine,U.LoaderSearch,U.LoaderUseR6,U.LoaderUse})do inside(control,U.LoaderCard);assert(control.AbsoluteSize.X>=44 and control.AbsoluteSize.Y>=44)end
 for i,b in ipairs(home.Buttons)do assert(b.Visible==(i<=6));if i<=6 then inside(b,home.Root)end end
end
return 'six reference categories; bounded preview/catalog; extra destinations retained outside mosaic'
''')
case('v77_removal_preview_and_confirm',UI+DATA+PREVIEW+module('09C20_AVATAR_REMOVAL')+r'''
S.Current.props.Shirt=123;S.Current.accessories={{id=22,type='Hair'},{id=33,type='Hat'},{id=44,type='Jacket',layer=true}}
local original=A.Copy(S.Current);local r=Modules['09C20_AVATAR_REMOVAL'].Build({U=U,A=A,S=S,toast=function()end});U.Root.Visible=true;r.Open()
named(r.Panel,'Remove_Hair').Activated:Fire();assert(#S.Current.accessories==3 and S.Current.props.Shirt==123)
local filtered=Modules['09C20_AVATAR_REMOVAL'].Filter(A,S.Current,{Hair=true});assert(#filtered.accessories==2 and #S.Current.accessories==3)
r.Close();assert(#S.Current.accessories==3);r.Open();named(r.Panel,'Remove_All').Activated:Fire();named(r.Panel,'ConfirmRemoval').Activated:Fire();assert(#S.Current.accessories==0 and S.Current.props.Shirt==0);assert(S.Undo())
assert(#S.Current.accessories==3)
return 'selection changes only preview; cancel preserves state; confirmation uses current body and supports undo'
''')
case('v77_hud_actions_and_assistant_menu',HUD+r'''
local shop=Instance.new('ScreenGui');shop.Name='AvatarShop08Gui';shop.Parent=pg;local sent={}
for _,n in ipairs({'OpenRequest','HudAction'})do local e=Instance.new('BindableEvent');e.Name=n;e.Parent=shop;e.Event:Connect(function(a)sent[#sent+1]=n..':'..a end)end
'''+src('07G_HUB_UI')+r'''
flush();local hud=pg.LimitedMarketHUD;local launch=pg.AvatarShopLauncherGui
for _,v in ipairs({{'TopCatalog','OpenRequest:Catalog'},{'TopStores','OpenRequest:Stores'},{'Community','OpenRequest:Community'},{'Emotes','OpenRequest:Emotes'},{'Looks','OpenRequest:Looks'},{'Loader','OpenRequest:Loader'},{'CurrentlyWearing','HudAction:Wearing'},{'RestoreAvatar','HudAction:Reset'},{'RemoveItems','HudAction:RemoveItems'},{'Undo','HudAction:Undo'},{'Redo','HudAction:Redo'},{'NewAvatar','HudAction:Blank'},{'SaveRoblox','HudAction:SaveRoblox'},{'HideUI','HudAction:CleanUI'}})do
 (named(hud,v[1])or named(launch,v[1])).Activated:Fire();flush();assert(sent[#sent]==v[2],v[1])
end
named(hud,'AvatarTools').Activated:Fire();local assistant=named(hud,'Assistant');assert(assistant and assistant.Active)
assistant.Activated:Fire();assert(pg:GetAttribute('ACP_OpenAINonce')==1)
for i=1,50 do assistant.Activated:Fire()end;assert(pg:GetAttribute('ACP_OpenAINonce')==1)
named(hud,'Cfg').Activated:Fire();local categories=named(hud,'SettingsCategories');assert(#categories:GetChildren()==6)
return 'all primary destinations route correctly; assistant is accessible from More; 50 repeat taps cannot toggle it repeatedly; six settings categories'
''')
case('v77_catalog_quick_actions_require_explicit_user_choice',UI+DATA+PREVIEW+module('09C4_OUTFIT_LIBRARY')+module('09C3_CATALOG_FILTERS')+module('09C2_SHOP_CATALOG')+r'''
SCREEN_W,SCREEN_H,CORE_TOP=1280,720,58
local row=fixture60(9001,'Reference Shirt','Shirt');local purchases=0;local tries=0;local oldTry=S.Try
S.Try=function(item)tries=tries+1;return true end
function Services.AvatarEditorService:SearchCatalogAsync()return{IsFinished=true,GetCurrentPage=function()return{row}end}end
local ctl=Modules['09C2_SHOP_CATALOG'].Init({U=U,A=A,S=S,toast=function()end,call=function(action,data)if action=='PurchaseItem'then purchases=purchases+1;assert(data.id==9001)end;return true end})
U.Root.Visible=true;U.ShowPreview();ctl.Search();flush();U.Layout();ctl.Resize();local slot=ctl.Pool[1];assert(slot.canQuick and slot.quickTry.Visible==false and slot.quickBuy.Visible==false)
slot.root.Activated:Fire();assert(slot.quickTry.Visible and slot.quickBuy.Visible and purchases==0 and tries==0)
slot.quickTry.Activated:Fire();assert(tries==1 and purchases==0)
slot.quickBuy.Activated:Fire();assert(purchases==1)
S.Try=oldTry
return 'selecting reveals TRY/BUY; preview never buys; explicit buy reaches existing server purchase action'
''')
case('v77_avatar_modal_preview_never_overlaps_footer',UI+DATA+PREVIEW+module('09C18_AVATAR_SAVE')+r'''
local save=Modules['09C18_AVATAR_SAVE'].Build({U=U,A=A,S=S,call=function()return true end,toast=function()end,buyBody=function()end})
U.Root.Visible=false
for _,sz in ipairs('''+SIZES+r''')do
 SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP=sz[3],sz[4],58
 save.Wearing();flush();save.Layout();assert(not U.Root.Visible and save.Shade.Parent==U.Gui)
 inside(save.Panel,U.Gui);inside(save.Stage,save.Panel);inside(save.Footer,save.Panel)
 assert(not intersects(save.Stage,save.Footer)and not intersects(save.Options,save.Footer))
 U.HudAction:Fire('Undo');assert(not save.Shade.Visible)
end
return 'wearing opens independently of catalog; preview/components and action footer never overlap across seven geometries; another HUD action closes it'
''')
HERE.joinpath('reference_ui_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
