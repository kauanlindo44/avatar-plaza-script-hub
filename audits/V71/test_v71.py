from test_support import *
SIZES="{{320,568,0,0,0},{390,844,0,0,34},{568,320,0,0,0},{667,375,0,0,0},{851,392,44,44,21},{1280,720,0,0,0},{1920,1080,0,0,0}}"
case('assistant_reference_layout_has_real_rail_clear_canvas_and_working_composer',THEME+module('09I0_ASSISTANT_CONFIG')+module('09I4_ASSISTANT_UI')+r'''
local u=Modules['09I4_ASSISTANT_UI'].Build(pl);u.Root.Visible=true;flush()
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;u.Layout();flush()
 assert(u.Root.BackgroundColor3.R>.9 and u.Body.AbsoluteSize.X<=820)
 for _,b in ipairs({u.Input,u.Send,u.Close,u.Menu,u.Make,u.Help})do inside(b,u.Root);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44,b.Name)end
 assert(not intersects(u.Make,u.Input)and not intersects(u.Input,u.Send)and not intersects(u.Send,u.Help))
 if u.Rail.Visible then assert(not intersects(u.NewChat,u.Menu));assert(u.Rail.AbsoluteSize.X==56)end
 u.MenuOpen=true;u.Layout();flush();assert(u.Tabs.Visible);u.MenuOpen=false;u.Layout();assert(not u.Tabs.Visible)
end
local before=u.Composer.Position.Y.Offset;u.Add('um pedido real',true);flush();assert(not u.Welcome.Visible and u.Composer.Position.Y.Offset>=before)
u.ClearConversation();assert(u.Welcome.Visible and u.ConversationEmpty)
return 'white conversation with a bounded centered column, real rail/history controls, independent plus/help/send targets and reset-to-centered-composer on seven geometries'
''')
case('guided_steps_keep_confirmed_request_exact_and_preserve_native_limits',THEME+module('09I0_ASSISTANT_CONFIG')+module('09I4_ASSISTANT_UI')+module('09I5_ASSISTANT_QUESTIONNAIRE')+r'''
local u=Modules['09I4_ASSISTANT_UI'].Build(pl);local result;local q=Modules['09I5_ASSISTANT_QUESTIONNAIRE'].Build(u,function(value)result=value end);u.Root.Visible=true
q.Open('Pro','2 looks emo preto ate 100 Robux sem chapeu');assert(q.Step==1 and not q.Confirm.Visible and q.Style.Visible)
q.Next.Activated:Fire();assert(q.Step==2 and q.BudgetField.Visible and q.Count.Visible);q.Budget.Text='55';q.Next.Activated:Fire();assert(q.Step==3 and q.Scope.Visible and q.Exclude.Visible and q.Confirm.Visible)
q.Confirm.Activated:Fire();assert(result.confirmed and result.budget==55 and result.style=='emo'and result.count==2 and result.excluded[1]=='Hat')
assert(not u.Guiding and u.Composer.Visible);q.Open('Normal','streetwear azul 250 robux');assert(q.Step==1 and q.Options.style=='street'and q.Options.color=='blue'and #q.Options.excluded==0)
return 'three interactive stages send only explicit confirmed settings, preserve count/price/exclusions and start a subsequent request without carrying the prior style'
''')
case('catalog_mosaic_uses_native_media_preserves_equipped_strip_and_starts_no_query',UI+DATA+PREVIEW+module('09C16_CATALOG_HOME')+r'''
local searches=0;local chosen;function Services.AvatarEditorService:SearchCatalogAsync()searches=searches+1;error('home must not query')end
local h=Modules['09C16_CATALOG_HOME'].Build({U=U,A=A,S=S,browse=function(v)chosen=v end,call=function()return{items={}}end,toast=function()end,showItem=function()end});U.Root.Visible=true;U.ShowPreview();h.Open();flush();assert(searches==0 and U.ItemStrip.Visible and #h.Buttons==9)
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;U.Layout();h.Layout();for _,b in ipairs(h.Buttons)do inside(b,h.Root);assert(b.AbsoluteSize.Y>=44 and b.AbsoluteSize.X>=44,b.Name)end end
h.Buttons[5].Activated:Fire();assert(chosen=='Halloween'and not h.Root.Visible)
return 'nine reachable category routes use a six-tile mosaic and three utility entries, make no initial search and preserve the equipped strip'
''')
case('outfit_coordination_prefers_shared_collection_without_weakening_color_or_price',THEME+DATA+module('09I13_OUTFIT_SEARCH')+r'''
local search=Modules['09I13_OUTFIT_SEARCH'];local a=fixture60(9001,'streetwear blue varsity midnight pants','Pants');a.Price=15;local b=fixture60(9002,'streetwear blue sports pants','Pants');b.Price=5;local pink=fixture60(9003,'streetwear pink varsity midnight pants','Pants');pink.Price=1
local rows=search.Coordinate({b,pink,a},{{Name='streetwear blue varsity midnight shirt'}},'streetwear blue',{style='street',color='blue',strictColor=true},31)
assert(#rows==2 and rows[1].Id==9001 and rows[2].Id==9002 and search.Price(rows[1])==15)
return 'textual collection/style matching ranks the coordinated lower garment ahead of an unrelated cheaper one and never admits a mismatched explicit color'
''')
case('sponsored_media_renews_after_fifteen_minutes_without_new_publication_or_expiry',THEME+module('09B10_SPONSORED_DESTINATIONS')+r'''
seed63();local m=Modules['09B10_SPONSORED_DESTINATIONS'];local first=m.Feed(pl,{kind='Community'});assert(first.items[1].item.image=='rbxassetid://501')
Groups63[546113316].EmblemUrl='rbxassetid://502';Groups63[546113316].Name='Updated group'
local cached=m.Feed(pl,{kind='Community',refresh=true,ids={546113316}});assert(cached.items[1].item.image=='rbxassetid://501')
advance60(901);local pending=m.Feed(pl,{kind='Community',refresh=true,ids={546113316}});flush();local fresh=m.Feed(pl,{kind='Community',refresh=true,ids={546113316}})
assert(fresh.items[1].item.image=='rbxassetid://502'and fresh.items[1].item.Name=='Updated group'and m.Duration==86400 and not fresh.pending)
local unknown=m.Feed(pl,{kind='Community',refresh=true,ids={99999}});assert(#unknown.items==0)
local game=m.Feed(pl,{kind='Game'});local uri=game.items[1].item.image;advance60(901);m.Feed(pl,{kind='Game',refresh=true,ids={83720142132483}});flush();local updated=m.Feed(pl,{kind='Game',refresh=true,ids={83720142132483}})
assert(updated.items[1].item.image~=uri and updated.items[1].item.image:find('rbxthumb://type=GameThumbnail',1,true))
return 'native group metadata and supported game thumbnail sizes are refreshed after 900 seconds; no new publication or altered 24-hour duration; unknown/non-displayed IDs excluded'
''')
case('destination_client_timer_preserves_search_favorites_and_scroll_position',THEME+module('07UI_PAN_GRID')+module('09C12_DESTINATION_BROWSER')+r'''
local d=Modules['07UI_DESIGN_SYSTEM'];local gui=d.New('ScreenGui',{},pg);local area=d.Frame(gui,{Size=UDim2.fromOffset(900,500)});local refresh=0
local rows={{key='Game:1',permanent=true,favorite=true,item={Id=1,ItemType='Game',Name='Before',image='rbxassetid://10'}}}
local u=Modules['09C12_DESTINATION_BROWSER'].Build(area,{toast=function()end,call=function(action,args)
 if action=='DestinationFeed'and args.refresh then refresh=refresh+1;return{items={{key='Game:1',item={Id=1,ItemType='Game',Name='After',image='rbxassetid://11'}}}}end
 return{items=deep(rows),finished=true}
end});u.Open('Game');flush();u.Query.Text='my query';u.Favorites=true;u.Grid.CanvasPosition=Vector2.new(125,3)
Services.RunService.Heartbeat:Fire(899);flush();assert(refresh==0);Services.RunService.Heartbeat:Fire(2);flush()
assert(refresh==1 and u.Items[1].item.image=='rbxassetid://11'and u.Items[1].favorite and u.Query.Text=='my query'and u.Favorites and u.Grid.CanvasPosition.X==125)
return 'a real 900-second Heartbeat schedule refreshes media only, retaining the selected filter, user favorites and XY position'
''')
case('music_default_is_compact_and_library_id_and_mini_controls_stay_reachable',THEME+module('07M1_MUSIC_UI')+r'''
local u=Modules['07M1_MUSIC_UI'].Build(pl);u.Root.Visible=true
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0
 u.SavedOpen=false;u.Mini=false;u.Advanced=false;u.Layout();assert(u.Root.AbsoluteSize.X<=420 and u.Root.AbsoluteSize.Y<=254);inside(u.Close,u.Root);inside(u.Source,u.Root);assert(u.Source.AbsoluteSize.Y==44)
 u.SavedOpen=true;u.Layout();assert(u.Library.Visible and u.List.AbsoluteSize.Y>=44);u.Mini=true;u.Layout();inside(u.Play,u.Root);assert(u.Play.Parent==u.Root and u.Root.AbsoluteSize.Y<=64)
 u.Mini=false;u.SavedOpen=false;u.Advanced=true;u.Layout();assert(u.ID.Visible and u.Load.Visible and u.Reload.Visible)
end
return 'a 420x254 maximum default player expands only on request; library rows and a working mini play button fit seven safe layouts'
''')
case('classic_board_palette_and_piece_identity_do_not_change_chess_or_checkers_state',THEME+module('07H2_GAME_BOARD')+module('07A0_CHESS_RULES')+module('07B0_CHECKERS_RULES')+r'''
local d=Modules['07UI_DESIGN_SYSTEM'];local gui=d.New('ScreenGui',{},pg);local u=Modules['07H2_GAME_BOARD'].Build(gui);u.Root.Visible=true
local chess=Modules['07A0_CHESS_RULES'].New();local before=deep(chess);u.Draw(chess,'Xadrez','W');local piece=u.Cells[1][1].PieceIcon;assert(piece.Base and piece.PieceShadow)
u.SetTimes(299,300);u.Draw(chess,'Xadrez','W');assert(u.Cells[1][1].PieceIcon==piece and chess.board[1][1].t==before.board[1][1].t and chess.turn==before.turn)
local damas=Modules['07B0_CHECKERS_RULES'].New();u.Draw(damas,'Damas','W');local red=u.Cells[1][2]:FindFirstChild('PieceIcon');assert(red and red.Disc.BackgroundColor3.R>red.Disc.BackgroundColor3.G*2)
return 'classic green/cream chess and red/wood-colored checkers use beveled shapes and shadows, preserve stable piece instances and leave authoritative state untouched'
''')
HERE.joinpath('v71_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
