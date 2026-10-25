from test_support import *
case('v77_board_player_strips_moves_and_safe_layout',THEME+module('07H2_GAME_BOARD')+r'''
local gui=Instance.new('ScreenGui');gui.Parent=pg;local b=Modules['07H2_GAME_BOARD'].Build(gui)
for _,size in ipairs({{320,568},{390,844},{568,320},{851,392},{1066,480},{1280,720}})do
 SCREEN_W,SCREEN_H=size[1],size[2];CORE_TOP=58;b.Layout()
 for _,o in ipairs({b.Grid,b.Side,b.PlayerTop,b.PlayerBottom})do inside(o,gui)end
 assert(not intersects(b.Grid,b.PlayerTop)and not intersects(b.Grid,b.PlayerBottom)and not intersects(b.Grid,b.Side))
 for _,kind in ipairs({'Xadrez','Damas'})do for _,side in ipairs({'W','B'})do
 b.SetPlayers({W={name='Alice',id=44},B={name='Bruno',id=55}},side)
 b.Draw({board={},turn='W'},kind,side,nil,{})
 assert(b.PlayerNames[b.PlayerBottom].Text==(side=='W'and'Alice'or'Bruno'));b.SetTimes(123,100)
 local mine=side=='W'and b.WhiteClock or b.BlackClock;assert(mine.Parent==b.PlayerBottom)
 end end
end
b.RecordMove({fr=7,fc=5,tr=5,tc=5},'W');assert(#b.Sheet.Rows==1 and b.Sheet.Rows[1].Text:find('e2–e4',1,true));b.ResetLog();assert(#b.Sheet.Rows==0)
return 'six screen sizes, two games and two orientations; clocks adjacent to players, board unobstructed; coordinate log resets'
''')
case('v77_score_sheet_bounds_and_invalid_moves',module('07H12_SCORE_SHEET')+r'''
local sheet=Modules['07H12_SCORE_SHEET'];local rows={}
for i=1,500 do assert(sheet.Append(rows,{fr=7,fc=5,tr=5,tc=5},'W',i))end
assert(#rows==120 and rows[1].ply==381 and rows[120].ply==500)
for _,bad in ipairs({{}, {fr=0,fc=1,tr=2,tc=2},{fr=1,fc=1.5,tr=2,tc=2},{fr=1,fc=1,tr=9,tc=2}})do assert(not sheet.Append(rows,bad,'W',1))end
assert(#rows==120)
return '500 appends bounded to 120; out-of-range/fractional/missing coordinates rejected'
''')
case('v77_server_move_log_only_records_accepted_authoritative_moves',THEME+DATA+module('07A0_CHESS_RULES')+module('07B0_CHECKERS_RULES')+r'''
local opponent=makePlayer(2);local outsider=makePlayer(3);Modules['07W_WINS_SERVICE']={RecordMatch=function()end}
'''+module('07H7_BOARD_SESSIONS')+r'''
local board=Modules['07H7_BOARD_SESSIONS'];board.Bind()
local name=assert(board.Open({code='LOG1',game='Xadrez'},{pl,opponent}))
local event=rep.PracaKit.Remotes.HubGameUI
local function last()for i=#event.sent,1,-1 do local p=event.sent[i];if p.kind=='boardState'then return p.data end end end
local snap=last();assert(snap and #snap.log==0)
assert(not board.Action(outsider,'boardTap',name,7,5,0))
assert(board.Action(pl,'boardTap',name,7,5,0));advance60(.1)
assert(board.Action(pl,'boardTap',name,5,5,0));snap=last();assert(#snap.log==1 and snap.log[1].text=='e2–e4')
for i=1,100 do board.Action(pl,'boardTap',name,5,5,0)end;assert(#last().log==1)
assert(not board.Action(opponent,'boardTap',name,2,5,0));assert(#last().log==1)
advance60(.1);assert(board.Action(opponent,'boardTap',name,2,5,1));advance60(.1);assert(board.Action(opponent,'boardTap',name,4,5,1))
assert(#last().log==2 and last().log[2].text=='e7–e5');assert(last().players.W.id==pl.UserId)
return 'legal accepted moves produce one history entry; spectators, old revisions and 100 repeated taps cannot forge entries'
''')
HERE.joinpath('board_ui_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
