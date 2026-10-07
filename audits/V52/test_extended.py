import ast
from test_support import *
RULES=module('07K14_DECK_OPTIONS')+module('07K0_TRUCO_RULES')+"R=Modules['07K0_TRUCO_RULES']\n"+module('07K1_TRUCO_AI')+"AI=Modules['07K1_TRUCO_AI']\n"
CATALOG=module('07K14_DECK_OPTIONS')+module('07K6_CARD_CATALOG')+"C=Modules['07K6_CARD_CATALOG']\n"
INVENTORY=CATALOG+module('07K8_CARD_INVENTORY')+"I=Modules['07K8_CARD_INVENTORY']\n"
PROGRESS=INVENTORY+module('07K11_GAMES_PROGRESS')+"P=Modules['07K11_GAMES_PROGRESS']\n"
CUPS=PROGRESS+module('07K13_TOURNAMENT_SERVICE')+"T=Modules['07K13_TOURNAMENT_SERVICE']\n"
base=ast.parse((ROOT/'audits/V51/test_games_commerce.py').read_text())
for expr in base.body:
 if isinstance(expr,ast.Expr)and isinstance(expr.value,ast.Call)and getattr(expr.value.func,'id','')=='case':
  n=ast.literal_eval(expr.value.args[0])
  if n in {'truco_real_rank_profiles_and_private_cards','truco_bot_complete_games_all_variants_levels','progress_reward_and_weekly_rank_deduplication','tournaments_consent_checkin_ten_seeds_and_rematches'}:
   case(n,eval(compile(ast.Expression(expr.value.args[1]),'<regression>','eval'),globals()))
base=ast.parse((ROOT/'audits/V51/test_native_mobile.py').read_text())
for expr in base.body:
 if isinstance(expr,ast.Expr)and isinstance(expr.value,ast.Call)and getattr(expr.value.func,'id','')=='case':
  n=ast.literal_eval(expr.value.args[0])
  if n in {'published_body_metadata_survives_preview_save_apply_and_respawn','single_asset_remove_does_not_resurrect_old_head_metadata','legacy_saved_looks_and_forged_native_fields_are_handled','live_native_edit_preserved_when_only_clothing_changes','complete_outfit_failure_is_atomic_and_retry_keeps_generation','documented_core_origin_reclaims_exact_phantom_margin'}:
   case(n,eval(compile(ast.Expression(expr.value.args[1]),'<body regression>','eval'),globals()))
base=ast.parse((ROOT/'audits/V51/test_server_flows.py').read_text())
for expr in base.body:
 if isinstance(expr,ast.Assign)and getattr(expr.targets[0],'id','')=='TRUCO':exec(compile(ast.Module(body=[expr],type_ignores=[]),'<server fixture>','exec'),globals())
TRUCO=module('07K14_DECK_OPTIONS')+TRUCO
case('quick_match_partitions_full_and_clean_and_blocks_custom',TRUCO+r'''
local full=ask(players[1],'quick',{variant='Paulista',deck={mode='Full'}});assert(full.ok,full.error)
local clean=ask(players[2],'quick',{variant='Paulista',deck={mode='Clean'}});assert(clean.ok and clean.data.code~=full.data.code)
local nextFull=ask(players[3],'quick',{variant='Paulista',deck={mode='Full'}});assert(nextFull.ok and nextFull.data.code==full.data.code)
local invalid=ask(players[4],'quick',{variant='Paulista',deck={mode='Custom',ranks={'A'},suits={'C'}}});assert(not invalid.ok)
return 'server quick queue separated by variant + canonical deck key; custom/undersized selection never joins a standard room'
''')
case('server_custom_deck_saved_configuration_and_image_validation',TRUCO+r'''
local D=Modules['07K14_DECK_OPTIONS'];local custom={mode='Custom',ranks=D.Ranks,suits=D.Suits}
local saved=ask(players[1],'savedeck',{variant='Mineiro',deck=custom});assert(saved.ok,saved.error)
local inv=ask(players[1],'inventory');assert(inv.data.deckPreset.variant=='Mineiro')
local room=ask(players[1],'create',{variant='Paulista',deck=custom,manual=true});assert(room.ok)
for i=2,4 do assert(ask(players[i],'join',{code=room.data.code}).ok)end
local v=latest(players[1]);assert(v.deckInfo.custom and not v.manual and #v.hand==3 and not v.deck)
local result=ask(players[1],'custom',{image=11,zoom=2});assert(not result.ok)
return 'real server RPC saves deck preferences; 52-card room automatic, public options only, no unowned Ateliê save'
''')
STYLE=THEME+CATALOG+module('07K7_CARD_STYLES')+module('07K16_ATELIER_UI')+module('07K9_CARD_INVENTORY_UI')
case('atelier_load_errors_success_edit_and_save_guard',STYLE+r'''
local root=Instance.new('Frame');root.Size=UDim2.fromOffset(800,500);root.Parent=pg
local actions={};local fail=false
local editor=Modules['07K16_ATELIER_UI'].Build(root,function(action,arg)
 actions[#actions+1]=action;if action=='image'then if fail then return nil,'Não é uma imagem.'end;return{image=arg.image,texture=arg.image,assetType=1}end;return true
end,function()end,function()end,function()end)
editor.Root.Visible=true;editor.SetData({ateliers=true,custom={image=0,zoom=1,x=0,y=0}},{passes={}});editor.ID.Text='42';editor.Load.Activated:Fire();flush();assert(editor.Ready and editor.Status:GetAttribute('LoadState')=='Ready')
editor.Plus.Activated:Fire();editor.Right.Activated:Fire();assert(editor.Editor.zoom>1 and editor.Editor.rotation==15);editor.Keep.Activated:Fire();assert(actions[#actions]=='savepreset')
fail=true;editor.ID.Text='77';editor.Reload.Activated:Fire();flush();assert(not editor.Ready and editor.Status:GetAttribute('LoadState')=='Error');local n=#actions;editor.Save.Activated:Fire();assert(#actions==n)
return 'real image/decal metadata, IsLoaded success gate, invalid ID visible error, edits kept and save forbidden after failed load'
''')
case('atelier_and_custom_room_controls_fit_both_orientations',STYLE+module('07H5_TRUCO_SETUP')+module('07H1_GAME_LOBBY')+r'''
local g=Modules['07UI_DESIGN_SYSTEM'].New('ScreenGui',{Name='Test',ScreenInsets=Enum.ScreenInsets.None},pg)
local inv=Modules['07K9_CARD_INVENTORY_UI'].Build(g,function(a)if a=='image'then return nil,'error'end end,function()end)
inv.Root.Visible=true;inv.Tab='Ateliê';inv.AcceptData({coins=0,ateliers=true,owned={Classic=true},presets={},custom={image=0,zoom=1,x=0,y=0}});inv.Render();flush()
local lobby=Modules['07H1_GAME_LOBBY'].Build(g)
for _,size in ipairs({{390,844},{851,392},{667,375},{568,320}})do
 SCREEN_W,SCREEN_H=size[1],size[2];CORE_TOP=58;inv.Layout();local a=inv.Atelier
 for _,b in ipairs({a.Load,a.Reload,a.Save,a.Keep,a.Minus,a.Plus,a.Left,a.Right,a.Center,a.Brightness,a.Format,a.Flip})do inside(b,a.Root);assert(not intersects(b,a.Save)or b==a.Save,'overlap '..b.Text..' '..SCREEN_W..'x'..SCREEN_H)end
 lobby.Selected='Truco';lobby.Mode='Create';lobby.Deck={mode='Custom',ranks=Modules['07K14_DECK_OPTIONS'].Ranks,suits={'D','S','H','C'}};lobby.Options.Visible=true;lobby.Layout()
 local ranks=named(lobby.Options,'CustomRanks');local presets=named(lobby.Options,'DeckPresets')
 for _,b in ipairs(ranks:GetChildren())do if b:IsA('GuiButton')then inside(b,lobby.Options);assert(b.Size.X.Offset>=44);assert(not intersects(b,lobby.Create))
  for _,p in ipairs(presets:GetChildren())do if p:IsA('GuiButton')then assert(not intersects(b,p),'rank/preset overlap '..SCREEN_W..'x'..SCREEN_H)end end
 end end
 for _,b in ipairs(presets:GetChildren())do if b:IsA('GuiButton')then inside(b,lobby.Options);assert(not intersects(b,lobby.Create))end end
end
return 'all editable image and deck-rank buttons on-screen; mobile landscape controls avoid apply/create buttons'
''')
HERE.joinpath('extended_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n');print('EXTENDED',len(results),'PASS')
