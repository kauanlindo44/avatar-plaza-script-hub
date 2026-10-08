from test_support import *
CAT=module('07K6_CARD_CATALOG')+module('07K7_CARD_STYLES')
GAME=THEME+CAT+module('07H5_TRUCO_SETUP')+module('07H1_GAME_LOBBY')+module('07H2_GAME_BOARD')
TABLE=THEME+CAT+module('07K0_TRUCO_RULES')+module('07K15_TRUCO_TABLE')+module('07K5_TRUCO_UI')
case('selected_game_profiles_and_safe_mobile_controls',GAME+r'''
local g=Modules['07UI_DESIGN_SYSTEM'].New('ScreenGui',{Name='Games',ScreenInsets=Enum.ScreenInsets.None},pg)
local l=Modules['07H1_GAME_LOBBY'].Build(g);l.Root.Visible=true
for _,size in ipairs({{390,844},{851,392},{667,375},{568,320},{320,568},{1920,1080}})do
 SCREEN_W,SCREEN_H=size[1],size[2];CORE_TOP=58;DEVICE_TOP=0;CORE_LEFT,CORE_RIGHT,CORE_BOTTOM,DEVICE_BOTTOM=0,0,0,0;l.Reset();l.Layout();flush()
 for _,game in ipairs({'Truco','Damas','Xadrez'})do
  l.SetGame(game);assert(l.Selected==game)
  for _,b in pairs(l.PlayButtons[game])do inside(b,l.Hero);assert(b.AbsoluteSize.Y>=44)end
  assert(not intersects(l.Inventory,l.HeroTitle)and not intersects(l.Inventory,l.Cups));inside(l.Close,l.Root);assert(not intersects(l.Coins,l.Close))
  l.PlayButtons[game].Practice.Activated:Fire();l.Layout()
  for i,key in ipairs({'FACIL','MEDIO','DIFICIL'})do
   local b=l.DiffButtons[key];inside(b,l.Options);assert(b.Visible and b.AbsoluteSize.Y>=44);assert(not intersects(b,l.Bot)and not intersects(b,l.OptionsClose))
   if i>1 then assert(not intersects(b,l.DiffButtons[({'FACIL','MEDIO','DIFICIL'})[i-1]]))end
  end
  l.DiffButtons.DIFICIL.Activated:Fire();assert(l.Bot.Text=='Jogar com Dante');l.OptionsClose.Activated:Fire()
 end
end
return 'one selected game/four actions; named vertical virtual profiles; six sizes including 568x320 preserve 44px controls, header and close'
''')
case('dupla_roster_ready_and_friend_reservation_fit',GAME+r'''
local g=Modules['07UI_DESIGN_SYSTEM'].New('ScreenGui',{Name='Rooms'},pg);local l=Modules['07H1_GAME_LOBBY'].Build(g)
for _,size in ipairs({{390,844},{851,392},{568,320},{320,568}})do
 SCREEN_W,SCREEN_H=size[1],size[2];CORE_TOP=58;DEVICE_TOP,DEVICE_BOTTOM,CORE_LEFT,CORE_RIGHT=0,0,0,0
 l.SetRoom({code='ABCD',count=4,owner=pl.UserId,ready=true,players={{name='Ana',ready=true},{name='Bruno'},{name='Carla',ready=true},{name='Davi'}}})
 for _,b in ipairs({l.OptionsClose,l.Ready,l.Cancel,l.SelectCode,l.Partner})do inside(b,l.Options);assert(b.AbsoluteSize.Y>=44)end
 for _,b in ipairs(l.RoomSlots)do inside(b,l.Options);assert(not intersects(b,l.Ready)and not intersects(b,l.Cancel))end
 assert(l.IsReady and l.IsOwner and l.Ready.Text:find('cancelar'))
 l.Partner.Activated:Fire();for _,b in ipairs({l.FriendBox,l.Reserve,l.PartnerClose})do inside(b,l.PartnerPanel)end
 assert(not intersects(l.Reserve,l.FriendBox));l.PartnerClose.Activated:Fire();assert(not l.PartnerPanel.Visible)
end
return 'opposite seats form two readable duplas; ready toggle, copying code and 2-minute friend reservation remain on-screen'
''')
case('table_public_cards_names_and_three_direct_hand_cards',TABLE+r'''
local g=Modules['07UI_DESIGN_SYSTEM'].New('ScreenGui',{Name='Truco'},pg);local actions={}
local ui=Modules['07K5_TRUCO_UI'].Build(g,function(a,arg)actions[#actions+1]={a,arg}end)
local v={seat=1,variant='Paulista',score={0,0},phase='play',turn=1,value=1,handNumber=1,tricks={},tableCards={},lastTrick={},counts={3,2,3,3},players={{uid=123,name='You'},{uid=22,name='Ana'},{uid=33,name='Bruno'},{uid=44,name='Carla'}},hand={{rank='4',suit='D'},{rank='3',suit='S'},{rank='Q',suit='H'}},nextRaise=3,remaining=30}
for i=1,4 do v.tableCards[i]={seat=i,card={rank='3',suit='H'}}end
for _,size in ipairs({{390,844},{851,392},{667,375},{568,320},{320,568},{1920,1080}})do
 SCREEN_W,SCREEN_H=size[1],size[2];CORE_TOP=58;DEVICE_TOP,DEVICE_BOTTOM,CORE_LEFT,CORE_RIGHT=0,0,0,0
 ui.Update(v,{equipped='Hex',view='mine'});ui.Layout()
 assert(#ui.HandCards==3 and not ui.CardChoices.Visible)
 for _,c in ipairs(ui.HandCards)do inside(c,ui.Hand);assert(not intersects(c,ui.Controls));assert(c.AbsoluteSize.Y>=64);assert(c.PlayCard.AbsoluteSize.Y>=64)end
 inside(ui.TableArea,ui.Root);inside(ui.Controls,ui.Root);assert(not intersects(ui.TableArea,ui.Hand))
 local host=named(ui.TableArea,'TrickCards');local cards={};for _,c in ipairs(host:GetChildren())do if c:IsA('GuiObject')then cards[#cards+1]=c;inside(c,host);assert(c.AbsoluteSize.Y>=40)end end;assert(#cards==4)
 for i=1,4 do inside(named(ui.TableArea,'PlayerSeat'..i),ui.TableArea)end
 for _,b in ipairs({ui.Raise,ui.Run,ui.Cover,ui.Shouts})do inside(b,ui.Controls);assert(b.AbsoluteSize.Y>=44)end
end
ui.HandCards[2].PlayCard.Activated:Fire();assert(actions[1][1]=='play'and actions[1][2]==2)
v.turn=2;ui.Update(v,{});ui.HandCards[1].PlayCard.Activated:Fire();assert(#actions==1)
return 'four public cards at least 40px high on larger 2D felt; three private tappable cards above one footer; six screen sizes; any owned card can be played on own turn'
''')
case('truco_ten_seconds_and_legal_mineiro_counter_raise',TABLE+r'''
local g=Modules['07UI_DESIGN_SYSTEM'].New('ScreenGui',{Name='Truco'},pg);local actions={}
local ui=Modules['07K5_TRUCO_UI'].Build(g,function(a,arg)actions[#actions+1]={a,arg}end)
local v={seat=2,variant='Mineiro',score={0,0},phase='raise',turn=1,value=2,handNumber=1,tricks={},tableCards={},lastTrick={},counts={3,3,3,3},players={{uid=1,name='A'},{uid=2,name='B'},{uid=3,name='C'},{uid=4,name='D'}},hand={{rank='4',suit='D'}},nextRaise=4,pending={team=1,value=4},remaining=10}
ui.Update(v,{});local labels={};for _,b in ipairs(ui.Options:GetChildren())do if b:IsA('GuiButton')then labels[b.Text]=b end end
assert(labels['SEIS!']and not labels['TRUCO!']);labels['SEIS!'].Activated:Fire();assert(actions[1][1]=='respond'and actions[1][2]=='raise')
advance(10);ui.Tick();assert(ui.Message.Text:find('tempo encerrado'));for _,b in pairs(labels)do assert(not b.Active)end
v.phase='finished';v.winner=1;v.rematchCount=1;ui.Update(v,{});local rematch
for _,b in ipairs(ui.Options:GetChildren())do if b.Text=='Revanche'then rematch=b end end;assert(rematch);rematch.Activated:Fire();assert(actions[#actions][1]=='rematch')
v.cup=true;ui.Update(v,{});assert(not ui.Raise.Active)
return '10s visible countdown disables expired controls; Mineiro 4 raises to 6; rematch visible in finished dialog and excluded from cup'
''')
HERE.joinpath('game_ui_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')

