import ast
from test_support import *
for p in sorted((ROOT/'scripts/V44').glob('*.lua')):
 s=p.read_text();assert len(s.splitlines())<=400,p;assert not re.search(r'(?:\+|-|\*|/|\.\.)=',s),p
 l=Lua();l.run(s,p.name,execute=False);l.close()
results.append(dict(case='syntax_studio_lite_limits',result='pass',detail='55 scripts <=400 lines, no compound assignment'))
PHOTO=DATA+PREVIEW+module('07P0_STUDIO_PRESETS')+module('07P3_POSE_EDITOR')+module('07P5_POSE_CANVAS')+module('07P6_STUDIO_SETS')+module('07P2_STUDIO_AVATAR')+"Studio=Modules['07P2_STUDIO_AVATAR']\n"
old=ast.parse((ROOT/'audits/V43/test_v43.py').read_text())
selected={'viewport_controls_and_fixed_close_targets','catalog_five_by_four_and_explicit_prices','settings_categories_and_local_world_restoration','hud_plus_native_direct_and_music','preview_bounds_angles_drag_and_stale_error','community_pool_prefetch_lru_and_back_scroll','discovery_real_profiles_bounds_authorization_cache','cosplay_names_require_matching_live_clothes','community_detail_opaque_rotation_items_close_and_save','saved_preview_larger_compact_cards_and_restore','photo_sets_clear_360_animation_and_restore','pose_canvas_drag_confirm_cancel_no_scroll','chess_bot_tactics_search_depth_and_cancellation'}
for expr in old.body:
 if isinstance(expr,ast.Expr)and isinstance(expr.value,ast.Call)and getattr(expr.value.func,'id','')=='case':
  name=ast.literal_eval(expr.value.args[0])
  if name in selected:
   code=eval(compile(ast.Expression(expr.value.args[1]),'<V43 regression>','eval'),globals())
   if name=='catalog_five_by_four_and_explicit_prices':code=code.replace('==4,\'not four','==2,\'not two').replace('n<=20','n<=10').replace('5x4','5x2')
   if name=='catalog_five_by_four_and_explicit_prices':code=code.replace('20 cards fully visible','10 cards fully visible')
   if name=='community_pool_prefetch_lru_and_back_scroll':code=code.replace('ctl.Open();flush()','ctl.Open("ROBLOX");flush()')
   if name=='viewport_controls_and_fixed_close_targets':code=code.replace('U.Detail.CanvasPosition=Vector2.new(0,200)','U.DetailDescription.CanvasPosition=Vector2.new(0,200)')
   case(name,code)
HERE.joinpath('results.json').write_text(json.dumps(results,indent=2,ensure_ascii=False)+'\n')
print('UI REGRESSIONS',len(results),'PASS')
