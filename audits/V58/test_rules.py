from test_support import *
CHECKERS=module('07B0_CHECKERS_RULES')+r'''
R=Modules['07B0_CHECKERS_RULES']
function empty(turn)local s=R.New();for i=1,8 do s.board[i]={}end;s.turn=turn or'W';s.repetition={};return s end
function put(s,r,c,color,king)s.board[r][c]={c=color,k=king==true}end
function move(s,r,c,tr,tc)local legal=R.Legal(s,r,c);for _,m in ipairs(legal)do if m.tr==tr and m.tc==tc then return R.Apply(s,m)end end;error('expected legal move '..r..','..c..'->'..tr..','..tc)end
'''
CHESS=module('07A0_CHESS_RULES')+r'''
R=Modules['07A0_CHESS_RULES']
function move(s,r,c,tr,tc,promo)for _,m in ipairs(R.Legal(s,r,c))do if m.tr==tr and m.tc==tc then assert(R.Apply(s,m,promo));return end end;error('illegal chess fixture')end
function empty(turn)local s=R.New();for i=1,8 do s.board[i]={}end;s.turn=turn or'W';s.castle={W={K=false,Q=false},B={K=false,Q=false}};s.repetition={};return s end
'''
case('brazilian_stone_promotes_only_at_end_of_capture_chain',CHECKERS+r'''
local s=empty();put(s,3,2,'W');put(s,2,3,'B');put(s,2,5,'B')
local ok,phase=move(s,3,2,1,4);assert(ok and phase=='continue'and not s.board[1][4].k and s.board[2][3]and s.turn=='W')
ok,phase=move(s,1,4,3,6);assert(ok and phase=='turn'and not s.board[3][6].k and not s.board[2][3]and not s.board[2][5]and s.turn=='B')
s=empty();put(s,3,2,'W');put(s,2,3,'B');assert(move(s,3,2,1,4));assert(s.board[1][4].k)
return 'passing the back rank during a chain does not crown early; finishing on it crowns; victims remain until the chain is complete'
''')
case('tema_turco_blocks_reverse_path_through_captured_piece',CHECKERS+r'''
local s=empty();put(s,5,4,'W',true);put(s,4,3,'B');put(s,6,5,'B')
local legal=R.Legal(s,5,4);assert(#legal>0);for _,m in ipairs(legal)do assert(m.depth==1)end
local ok,phase=move(s,5,4,3,2);assert(ok and phase=='turn'and s.board[6][5]and not s.board[4][3])
return 'a flying king cannot return through a still-blocking captured piece to take a second enemy on the same diagonal'
''')
case('capture_majority_backwards_capture_and_invalid_move_rejection',CHECKERS+r'''
local s=empty();put(s,6,1,'W');put(s,7,8,'W');put(s,5,2,'B');put(s,3,4,'B');put(s,6,7,'B')
assert(#R.Legal(s,7,8)==0);local legal=R.Legal(s,6,1);assert(#legal==1 and legal[1].depth==2)
assert(not R.Apply(s,{fr=7,fc=8,tr=6,tc=7})and s.board[7][8])
s=empty();put(s,3,2,'W');put(s,4,3,'B');assert(move(s,3,2,5,4));assert(s.board[5][4]and not s.board[4][3])
return 'the path taking most pieces is compulsory across all pieces; stones can capture backwards; unlisted moves cannot alter the board'
''')
case('twenty_king_moves_reset_on_stone_and_reduced_endgame_clock',CHECKERS+r'''
local s=empty();put(s,8,1,'W',true);for _,c in ipairs({2,4,6,8})do put(s,1,c,'B',true)end;s.quiet=39
move(s,8,1,7,2);local result,why=R.Result(s);assert(result=='draw'and why:find('20'))
s=empty();put(s,6,1,'W');put(s,1,8,'B',true);s.quiet=39;move(s,6,1,5,2);assert(s.quiet==0 and R.Result(s)==nil)
s=empty();put(s,8,1,'W',true);put(s,1,8,'B',true);s.endgame=9;move(s,8,1,7,2);assert(s.endgame==10);result,why=R.Result(s);assert(result=='draw'and why:find('cinco'))
s=empty();put(s,5,4,'W',true);put(s,4,3,'B',true);put(s,1,8,'B',true);s.endgame=9;move(s,5,4,3,2);assert(s.endgame==10 and R.Result(s)=='draw')
return '40 half-moves of kings trigger the 20-moves-each rule; a stone resets the ordinary counter; five-moves-each reduced endings use ten plies and do not reset after a capture'
''')
case('all_cbjd_reduced_finals_and_stone_moves_keep_the_clock',CHECKERS+r'''
local s=empty();put(s,8,1,'W',true);put(s,8,3,'W',true);put(s,1,6,'B',true);put(s,1,8,'B',true);s.endgame=9
move(s,8,1,7,2);assert(s.endgame==10 and R.Result(s)=='draw')
s=empty();put(s,8,1,'W',true);put(s,8,3,'W',true);put(s,1,8,'B',true);put(s,2,7,'B');s.endgame=9
move(s,8,1,7,2);assert(s.endgame==10 and R.Result(s)=='draw')
s=empty('B');put(s,8,1,'W',true);put(s,1,8,'B',true);put(s,2,7,'B');s.endgame=9
move(s,2,7,3,6);assert(s.quiet==0 and s.endgame==10 and R.Result(s)=='draw')
s=empty();put(s,8,1,'W',true);for _,c in ipairs({2,4,6})do put(s,1,c,'B',true)end;s.endgame=8
move(s,8,1,7,2);assert(s.endgameActive and s.endgame==9)
move(s,1,4,2,5);assert(s.endgame==10 and R.Result(s)=='draw')
return 'two kings vs two kings, two kings vs king+stone and the listed three-piece endings on the main diagonal count five turns each; stone moves retain the reduced counter'
''')
case('chess_checkmate_takes_precedence_over_seventy_five_moves',CHESS+r'''
local s=R.New();move(s,7,6,6,6);move(s,2,5,4,5);move(s,7,7,5,7);s.halfmove=149;move(s,1,4,5,8)
assert(s.halfmove==150);local winner,why=R.Result(s);assert(winner=='B'and why=='Xeque-mate')
return 'a mating 150th reversible half-move wins rather than incorrectly becoming an automatic 75-move draw'
''')
case('chess_pawn_promotion_resets_halfmove_and_supports_underpromotion',CHESS+r'''
for _,piece in ipairs({'Q','R','B','N'})do local s=empty();s.board[8][5]={c='W',t='K'};s.board[1][5]={c='B',t='K'};s.board[2][1]={c='W',t='P'};s.halfmove=149
 move(s,2,1,1,1,piece);assert(s.board[1][1].t==piece and s.halfmove==0)
end
return 'each of the four promotion choices works; promotion is still a pawn move and resets the 50/75-move counter'
''')
case('irrelevant_en_passant_is_ignored_in_repetition_but_legal_ep_counts',CHESS+r'''
local s=R.New();move(s,7,1,5,1)
local hashes={};for h in pairs(s.repetition)do if h:sub(-1)=='-'then hashes[#hashes+1]=h end end;assert(#hashes==2)
-- A legal en-passant right changes the set of legal moves and therefore the repetition key.
s=empty('B');s.board[8][5]={c='W',t='K'};s.board[1][5]={c='B',t='K'};s.board[4][5]={c='W',t='P'};s.board[2][4]={c='B',t='P'}
move(s,2,4,4,4);local suffix;for h in pairs(s.repetition)do suffix=h:sub(-5)end;assert(suffix=='3.0:4'or suffix:find('3:4'))
local legal=R.Legal(s,4,5);local has=false;for _,m in ipairs(legal)do if m.enPassant then has=true end end;assert(has)
return 'an uncapturable double-pawn step does not produce a spurious repetition difference; a legally capturable en-passant square does'
''')
HERE.joinpath('rules_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
