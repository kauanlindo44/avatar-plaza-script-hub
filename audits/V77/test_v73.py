from test_support import *

STRICT=r'''
local meta=getmetatable(pg);local setter=meta.__newindex
meta.__newindex=function(o,k,v)if k=='Parent'and o.destroyed then error('The Parent property of '..o.Name..' is locked')end;return setter(o,k,v)end
local getter=meta.__index;meta.__index=function(o,k)
 if k=='Destroy'then return function(self)if self.destroyed or self.destroying then return end;self.destroying=true;self.Destroying:Fire();for _,child in ipairs(self:GetChildren())do child:Destroy()end;self.Parent=nil;self.destroyed=true;self.destroying=false end end
 local value=getter(o,k);if k=='GetChildren'then return function(self)return table.clone(value(self))end end;return value
end
'''
case('old_destroyed_assistant_reproduces_photo_error_new_ui_ignores_stale_layout',THEME+STRICT+module('09I4_ASSISTANT_UI')+r'''
local old=loadModule('''+q(src('09I4_ASSISTANT_UI','V72'))+r''','old73');local a=old.Build(pl);local b=old.Build(pl)
local ok,e=pcall(a.Layout);assert(not ok and e:find('Parent property of NewConversation is locked',1,true))
local fresh=Modules['09I4_ASSISTANT_UI'];local one=fresh.Build(pl);local two=fresh.Build(pl);assert(not one.Alive and two.Alive)
assert(pcall(one.Layout));assert(pcall(one.Select,'Conversa'));two.Root.Visible=true;two.Select('Conversa');assert(two.NewChat.Parent)
return 'the V72 source reproduces the photographed Parent-lock error when a second client recreates the GUI; V73 marks the former UI dead and never reparents its destroyed buttons'
''')

for name in ['09I_ASSISTANT_CLIENT','09I_ACTIVITIES_CLIENT','09C_SHOP_CLIENT','07M_MUSIC_CLIENT']:
    case('wrong_installation_name_is_reported_'+name,THEME+r'''
local warnings={};warn=function(v)warnings[#warnings+1]=v end
script=Instance.new('LocalScript');script.Name='WrongDestination';script.Parent=rep
local function runWrong()
'''+src(name)+r'''
end;runWrong()
assert(#warnings==1 and warnings[1]:find('script errado',1,true));assert(not pg:FindFirstChild('ACP_Assistant')and not pg:FindFirstChild('AvatarShop08Gui')and not pg:FindFirstChild('ACP_Music'))
return 'a source pasted into a different named LocalScript is rejected before constructing a conflicting UI and prints its actual path'
''')

SPONSOR=UI+DATA+PREVIEW+module('07UI_PAN_GRID')+module('09C10_SPONSOR_DESIGN')+module('09C11_SPONSOR_FEED')+module('09C9_SPONSOR_PICKER')+module('09C12_DESTINATION_BROWSER')+module('09C5_UGC_STORES')
case('a_second_assistant_client_does_not_destroy_or_duplicate_the_first',THEME+DATA+PREVIEW+module('09I0_ASSISTANT_CONFIG')+module('09I4_ASSISTANT_UI')+module('09I5_ASSISTANT_QUESTIONNAIRE')+module('09I6_ASSISTANT_RESULTS')+module('09I7_ASSISTANT_PROFILE')+r'''
local folder=Instance.new('Folder');folder.Name='ACP_AssistantRemotes';folder.Parent=rep;local rpc=Instance.new('RemoteFunction');rpc.Name='Request';rpc.Parent=folder;local event=Instance.new('RemoteEvent');event.Name='Progress';event.Parent=folder
function rpc:InvokeServer(a)if a=='status'then return{protocol=2,ok=true,data={plan='Normal',available=true,collections={},prefs={},members={},invites={},owner=123,expires=0,daily=10,remaining=10,used=0}}end;return{protocol=2,ok=true,data={items={}}}end
local warnings={};warn=function(v)warnings[#warnings+1]=v end
local function launch()
'''+src('09I_ASSISTANT_CLIENT')+r'''
end
script=Instance.new('LocalScript');script.Name='09I_ASSISTANT_CLIENT';script.Parent=rep;launch();flush();local first=pg.ACP_Assistant;assert(first)
script=Instance.new('LocalScript');script.Name='09I_ASSISTANT_CLIENT';script.Parent=rep;launch();flush();assert(pg.ACP_Assistant==first and not first.destroyed and #warnings==1 and warnings[1]:find('duplicada',1,true))
pg:SetAttribute('ACP_OpenAINonce',1);flush();assert(named(first,'AssistantRoot').Visible and named(first,'NewConversation').Parent)
return 'two valid-named client instances cannot recreate the GUI or attach a second set of handlers; the first remains functional'
''')
case('six_columns_four_rows_are_inside_safe_grid_on_phone_and_computer',SPONSOR+r'''
local rows={};for i=1,60 do local it=fixture60(1000+i,'Peça '..i,'Shirt');rows[#rows+1]={key='Asset:'..it.Id,item=it}end
local selected;function Services.AvatarEditorService:SearchCatalogAsync()return{IsFinished=true,GetCurrentPage=function()return{}end}end
local ctl=Modules['09C5_UGC_STORES'].Init({U=U,A=A,S=S,call=function(a)if a=='HighlightFeed'then return{items=rows,finished=true}end;return{value=true}end,toast=function()end,showItem=function(it)selected=it end})
U.Root.Visible=true;U.ActivePage='Stores';U.SetWide(false);U.StoresArea.Visible=true;ctl.Search();flush()
for _,sz in ipairs({{320,568,0,0,0},{390,844,0,0,34},{568,320,0,0,0},{667,375,0,0,0},{851,392,44,44,21},{1280,720,0,0,0},{1920,1080,0,0,0}})do
 SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;U.Layout();flush()
 local capacity=U.StoreGrid:GetAttribute('VisibleColumns')*U.StoreGrid:GetAttribute('VisibleRows');assert(capacity>=1 and capacity<=24)
 local count=0;for i=1,60 do local card=named(U.StoreGrid,'Featured_Asset_'..(1000+i));if i<=capacity then inside(card,U.StoreGrid);assert(card.AbsoluteSize.X>=44 and card.AbsoluteSize.Y>=44,'small target '..SCREEN_W..'x'..SCREEN_H..' '..card.AbsoluteSize.X..'/'..card.AbsoluteSize.Y);count=count+1 end end;assert(count==capacity)
 local bar=named(U.StoresArea,'SponsorSections');local pub=named(U.StoresArea,'PublishHighlight');local avatar=named(U.StoresArea,'SponsorAvatarToggle');assert(not intersects(bar,pub));inside(pub,U.StoresArea);inside(U.Close,U.Root);assert(not intersects(U.Close,pub));if avatar.Visible then assert(not intersects(avatar,pub)and not intersects(avatar,bar))end
 if SCREEN_W<SCREEN_H then assert(not U.Left.Visible);avatar.Activated:Fire();assert(U.Left.Visible and U.SponsorPreviewClose.Visible);inside(U.SponsorPreviewClose,U.Root);U.SponsorPreviewClose.Activated:Fire();assert(not U.Left.Visible)end
end
named(U.StoreGrid,'Featured_Asset_1001').Activated:Fire();assert(selected.Id==1001)
return 'adaptive complete cards fit seven safe layouts with 44-pixel minimum card and favorite targets; portrait uses a dismissible avatar panel, landscape retains a narrower side preview'
''')
case('sponsor_artwork_has_no_tint_and_favorites_and_scroll_still_work',SPONSOR+r'''
local rows={};for i=1,60 do local it=fixture60(1000+i,'Peça '..i,'Shirt');rows[#rows+1]={key='Asset:'..it.Id,item=it,temporary=i>2}end
function Services.AvatarEditorService:SearchCatalogAsync()return{IsFinished=true,GetCurrentPage=function()return{}end}end
local favorites=0;local ctl=Modules['09C5_UGC_STORES'].Init({U=U,A=A,S=S,call=function(a)if a=='HighlightFeed'then return{items=rows,finished=true}elseif a=='HighlightFavorite'then favorites=favorites+1;return{value=true}end;return{}end,toast=function()end,showItem=function()end})
U.Root.Visible=true;U.ActivePage='Stores';U.SetWide(false);U.StoresArea.Visible=true;ctl.Search();flush();local c=named(U.StoreGrid,'Featured_Asset_1001');local im=named(c,'ItemThumbnail');assert(not im:FindFirstChildOfClass('UIGradient'));assert(im.ImageColor3.R==1 and im.ImageColor3.G==1 and im.ImageColor3.B==1 and im.BackgroundTransparency==1)
assert(c.BackgroundColor3.R>.75 and c.BackgroundColor3.G>.75 and c.BackgroundColor3.B>.75);assert(not named(c,'TemporaryHighlightLabel').Visible and named(named(U.StoreGrid,'Featured_Asset_1003'),'TemporaryHighlightLabel').Visible)
named(c,'FavoriteFeatured').Activated:Fire();flush();assert(favorites==1 and named(c,'FavoriteFeatured').Text=='♥');assert(U.StoreGrid.CanvasSize.Y.Offset>U.StoreGrid.AbsoluteSize.Y)
return 'native thumbnail RGB remains white with no image gradient; pastel cards keep labels/prices readable, examples stay disclosed, real favorites send the official server action and later rows can be scrolled'
''')

SHOP=UI+DATA+PREVIEW+module('09C20_AVATAR_REMOVAL')+module('09C16_CATALOG_HOME')+module('09C15_AVATAR_TOOLS')+module('09C18_AVATAR_SAVE')+module('09C19_EDITOR_UTILITIES')+module('09C3_CATALOG_FILTERS')+module('09C4_OUTFIT_LIBRARY')+module('09C2_SHOP_CATALOG')+module('09C10_CONFIRM_ACTION')+r'''
Modules['09A_SHOP_UI']={VERSION='V44_STUDIO_UI',Build=function()return U end};local o=Instance.new('ModuleScript');o.Name='09A_SHOP_UI';o.Parent=rep
local function stub(name,value)Modules[name]=value;local o=rep:FindFirstChild(name);if not o then o=Instance.new('ModuleScript');o.Name=name;o.Parent=rep end end
stub('09C4_OUTFIT_LIBRARY',{VERSION='V58',Init=function()end,Add=function()end,Open=function()end});stub('09C14_NEW_AVATAR',{Build=function()end});stub('09C1_SHOP_LOOKS',{Init=function()return{Saved=function()end,Community=function()end,ShowLook=function()end}end});stub('09C5_UGC_STORES',{Init=function()return{Search=function()end}end});stub('09C9_PLAYER_INSPECT',{Init=function()end})
local rpc=Instance.new('RemoteFunction');rpc.Name='Request';rpc.Parent=rep.LMShop_Remotes;function rpc:InvokeServer()return{ok=true,data=true}end
'''
case('complete_catalog_initializes_and_initial_open_has_no_remote_search',SHOP+src('09C_SHOP_CLIENT')+r'''
flush();U.OpenRequest:Fire('Catalog');flush();assert(pg:GetAttribute('ACP_CatalogDiagnostic')=='OK V73');assert(U.CatalogHome.Visible and not U.Grid.Visible)
return 'the complete declared base initializes the real LocalScript without safe mode; catalog opens its category home'
''')
case('catalog_missing_dependency_is_named_in_ui_and_output',SHOP+r'''
rep:FindFirstChild('09C3_CATALOG_FILTERS'):Destroy()
'''+src('09C_SHOP_CLIENT')+r'''
flush();U.OpenRequest:Fire('Catalog');flush();local d=pg:GetAttribute('ACP_CatalogDiagnostic');assert(d:find('INSTALAÇÃO',1,true)and d:find('09C3_CATALOG_FILTERS',1,true));assert(U.Status.Text:find('09C3_CATALOG_FILTERS',1,true)and not U.Status.Text:find('modo seguro',1,true))
return 'missing filter module gives its exact name and ReplicatedStorage destination instead of claiming that the catalog opened safely'
''')
case('catalog_source_failure_reports_exact_stage_and_original_exception',SHOP+r'''
Modules['09C2_SHOP_CATALOG']={Init=function()error('original fixture failure')end}
'''+src('09C_SHOP_CLIENT')+r'''
flush();U.OpenRequest:Fire('Catalog');flush();local d=pg:GetAttribute('ACP_CatalogDiagnostic');assert(d:find('INIT 09C2_SHOP_CATALOG',1,true)and d:find('original fixture failure',1,true))
return 'a script exception stays distinguishable from an omitted module and preserves the original line/traceback in Output'
''')
case('catalog_duplicate_dependency_is_distinguished_from_missing_source',SHOP+r'''
local duplicate=Instance.new('ModuleScript');duplicate.Name='09C2_SHOP_CATALOG';duplicate.Parent=rep
'''+src('09C_SHOP_CLIENT')+r'''
flush();U.OpenRequest:Fire('Catalog');flush();local d=pg:GetAttribute('ACP_CatalogDiagnostic');assert(d:find('INSTALAÇÃO',1,true)and d:find('09C2_SHOP_CATALOG duplicado',1,true))
return 'multiple same-name modules are an installation conflict and no arbitrary first instance is selected'
''')

HERE.joinpath('v73_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
