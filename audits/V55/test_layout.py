from test_support import *
UI55=THEME+module('09I0_ASSISTANT_CONFIG')+module('09I4_ASSISTANT_UI')+module('09I5_ASSISTANT_QUESTIONNAIRE')+module('07M1_MUSIC_UI')+module('07P4_STUDIO_UI')
case('new_assistant_questionnaire_music_and_photo_safe_controls',UI55+r'''
local d=Modules['07UI_DESIGN_SYSTEM'];local ai=Modules['09I4_ASSISTANT_UI'].Build(pl)
local q=Modules['09I5_ASSISTANT_QUESTIONNAIRE'].Build(ai,function()end)
local music=Modules['07M1_MUSIC_UI'].Build(pl);local photo=Modules['07P4_STUDIO_UI'].Build(pl)
local sizes={{320,568,0,0,0},{390,844,0,0,34},{568,320,0,0,0},{667,375,0,0,0},{851,392,44,44,21},{1920,1080,0,0,0}}
for _,size in ipairs(sizes)do
 SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(size);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM,DEVICE_TOP=size[3],size[4],58,120,0
 ai.Root.Visible=true;ai.Select('Conversa');ai.Layout();q.Open('Pro');music.Root.Visible=true;music.Layout();photo.Root.Visible=true;photo.Popup.Visible=true;photo.Layout()
 for _,o in ipairs({ai.Tabs,ai.Body,ai.Composer,ai.Notice,q.Root,music.Root,photo.Nav,photo.Popup})do inside(o,o.Parent)end
 for _,o in ipairs({ai.Close,ai.Send,ai.Make,ai.Help,q.Close,q.Confirm,q.Format,q.Keep,q.Count,q.Budget,q.Tool,q.Color,q.Piece,q.Body,music.Close,music.Load,music.Play,music.Reload,music.Keep,music.Minus,music.Volume,music.Plus,photo.Close,photo.PopupClose,photo.PoseConfirm,photo.PoseCancel,photo.PoseReset})do
  inside(o,o.Parent);assert(o.AbsoluteSize.X>=44 and o.AbsoluteSize.Y>=44,o.Name..' touch too small at '..size[1]..'x'..size[2])
 end
 assert(not intersects(ai.Input,ai.Send));assert(not intersects(ai.Make,ai.Help));assert(not intersects(q.Confirm,q.Fields))
 assert(not intersects(music.Load,music.ID)and not intersects(music.List,music.Status))
 assert(music.Root.AbsoluteSize.X<SCREEN_W and music.Root.AbsoluteSize.Y<SCREEN_H,'music must remain a popup')
end
return 'six portrait/landscape sizes: compact music, questionnaire and photo popup inside safe bounds; important actions at least 44px; adjacent buttons do not intersect'
''')
case('community_five_across_two_rows_and_items_survive_utility_failure',UI+DATA+PREVIEW+COMMUNITY+r'''
local cart=Modules['09C4_OUTFIT_LIBRARY'];local old=Modules['09A4_UTILITY_SKIN'].Bind;Modules['09A4_UTILITY_SKIN'].Bind=function()error('utility init interrupted')end
local ok=pcall(cart.Init,{U=U,A=A,S=S,pl=pl,toast=function()end,call=function()return{items={}}end});assert(not ok)
assert(named(U.ItemStrip,'Equipped_11'));S.Remove(11);assert(not named(U.ItemStrip,'Equipped_11'))
Modules['09A4_UTILITY_SKIN'].Bind=old;U.Root.Visible=true;U.CommunityArea.Visible=true;U.SetWide(true)
local feed=Modules['09C7_COMMUNITY_FEED'].Init({U=U,A=A,toast=function()end,show=function()end,call=function(a,args)
 local out={};for i=1,50 do local id=(args.page or 0)*50+i;out[i]={id='p'..id,signature='b'..id,body=A.Copy(S.Current),rig='R15',source='Roblox',owner=1000+id,name='Look '..id,total=41}end;return{items=out,finished=false}
end});feed.Open();flush()
for _,size in ipairs({{390,844},{851,392},{568,320},{1920,1080}})do
 SCREEN_W,SCREEN_H=size[1],size[2];U.Layout();feed.Layout();flush();local cols=size[1]>size[2]and 5 or 2
 local first,second,below=feed.Pool[1],feed.Pool[cols],feed.Pool[cols+1]
 assert(first.root.AbsolutePosition.Y==second.root.AbsolutePosition.Y)
 assert(below.root.AbsolutePosition.Y>first.root.AbsolutePosition.Y and below.root.AbsolutePosition.X==first.root.AbsolutePosition.X)
 for i=1,cols*2 do inside(feed.Pool[i].root,U.CommunityGrid);inside(feed.Pool[i].stage,feed.Pool[i].root)end
end
for _=1,14 do U.ComMore.Activated:Fire();flush()end;assert(#feed.Rows<=100 and feed.Evicted>0 and #feed.Pool==50)
return 'landscape has ten visible outfits in 5x2, portrait two columns, bounded 100 data/50 reusable cards; equipped items stay functional even when cart initialization fails'
''')
case('closed_catalog_still_applies_pineapple_on_map',UI+DATA+PREVIEW+SERVER+module('09C4_OUTFIT_LIBRARY')+module('09C10_CONFIRM_ACTION')+module('09C9_PLAYER_INSPECT')+r'''
Modules['09A_SHOP_UI']={VERSION='V44_STUDIO_UI',Build=function()return U end};local ui=Instance.new('ModuleScript');ui.Name='09A_SHOP_UI';ui.Parent=rep
for _,n in ipairs({'09C2_SHOP_CATALOG','09C1_SHOP_LOOKS'})do local o=Instance.new('ModuleScript');o.Name=n;o.Parent=rep;Modules[n]={Init=function()return{Search=function()end,Saved=function()end,Community=function()end}end}end
'''+src('09C_SHOP_CLIENT')+r'''
flush();U.OpenRequest:Fire('Catalog');flush();local old=pl.Character
Details[72779265740934]={Id=72779265740934,AssetType='ShirtAccessory'};assert(S.Try(Details[72779265740934]));U.Close.Activated:Fire();assert(not U.Root.Visible)
advance(.5);flush();assert(pl.Character~=old,'layer change must use the same native fresh-model path as preview')
local h,description=Modules['09B5_AVATAR_RUNTIME'].Description(pl);local body=A.Pack(description);description:Destroy();local found=false
for _,a in ipairs(body.accessories)do if a.id==72779265740934 then found=true end end
assert(found and body.props.Torso==S.Current.props.Torso and body.props.Shirt==S.Current.props.Shirt)
return 'closing the catalog during the debounce cannot cancel the selected shirt; live character is freshly validated and retains original body and clothes'
''')
HERE.joinpath('layout_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
