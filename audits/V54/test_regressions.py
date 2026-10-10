"""Run selected historical cases with effective V54 sources and V54 doubles."""
import ast
from test_support import *
RUNTIME=module('09B7_LAST_AVATAR')+module('09B5_AVATAR_RUNTIME')+"Runtime=Modules['09B5_AVATAR_RUNTIME']\n"
BOOT=DATA+RUNTIME+"Runtime.Start();flush();HUM=pl.Character.Humanoid\n"
CLIENT=UI+DATA+PREVIEW+SERVER+module('09C4_OUTFIT_LIBRARY')+module('09C10_CONFIRM_ACTION')+module('09C9_PLAYER_INSPECT')+r'''
Modules['09A_SHOP_UI']={VERSION='V44_STUDIO_UI',Build=function()return U end};local ui=Instance.new('ModuleScript');ui.Name='09A_SHOP_UI';ui.Parent=rep
for _,n in ipairs({'09C2_SHOP_CATALOG','09C1_SHOP_LOOKS','09C5_UGC_STORES'})do local o=Instance.new('ModuleScript');o.Name=n;o.Parent=rep;Modules[n]={Init=function()return{Search=function()end,Saved=function()end,Community=function()end}end}end
'''+src('09C_SHOP_CLIENT')+'\nflush()\n'
RULES=module('07K14_DECK_OPTIONS')+module('07K0_TRUCO_RULES')+"R=Modules['07K0_TRUCO_RULES']\n"+module('07K1_TRUCO_AI')+"AI=Modules['07K1_TRUCO_AI']\n"
CATALOG=module('07K14_DECK_OPTIONS')+module('07K6_CARD_CATALOG')+"C=Modules['07K6_CARD_CATALOG']\n"
INVENTORY=CATALOG+module('07K8_CARD_INVENTORY')+"I=Modules['07K8_CARD_INVENTORY']\n"
PROGRESS=INVENTORY+module('07K11_GAMES_PROGRESS')+"P=Modules['07K11_GAMES_PROGRESS']\n"
CUPS=PROGRESS+module('07K13_TOURNAMENT_SERVICE')+"T=Modules['07K13_TOURNAMENT_SERVICE']\n"
STYLE=THEME+CATALOG+module('07K7_CARD_STYLES')+module('07K16_ATELIER_UI')+module('07K9_CARD_INVENTORY_UI')
def replay(file,names):
 tree=ast.parse((ROOT/file).read_text())
 for expr in tree.body:
  if isinstance(expr,ast.Expr)and isinstance(expr.value,ast.Call)and getattr(expr.value.func,'id','')=='case':
   name=ast.literal_eval(expr.value.args[0])
   if name in names:case(name,eval(compile(ast.Expression(expr.value.args[1]),'<V53 regression>','eval'),globals()))
replay('audits/V51/test_native_mobile.py',{
 'published_body_metadata_survives_preview_save_apply_and_respawn','single_asset_remove_does_not_resurrect_old_head_metadata',
 'legacy_saved_looks_and_forged_native_fields_are_handled','live_native_edit_preserved_when_only_clothing_changes',
 'changed_head_shape_and_removed_shape_rebuild_and_read_back','native_body_and_preview_transient_build_retry',
 'unconfirmed_preview_never_displays_generic_body_as_success','complete_outfit_failure_is_atomic_and_retry_keeps_generation',
 'documented_core_origin_reclaims_exact_phantom_margin','orientation_native_controls_changes_and_accessible_popup_bounds',
 'camera_default_fits_all_body_corners_at_arbitrary_yaw','native_part_roles_allow_complete_meshes_with_custom_names',
 'catalog_retry_button_recovers_visible_native_preview_failure','confirmed_same_appearance_does_not_cancel_pending_or_repeat_body_load'})
replay('audits/V51/test_games_commerce.py',{'truco_real_rank_profiles_and_private_cards','truco_bot_complete_games_all_variants_levels','progress_reward_and_weekly_rank_deduplication','tournaments_consent_checkin_ten_seeds_and_rematches'})
replay('audits/V52/test_extended.py',{'atelier_load_errors_success_edit_and_save_guard','atelier_and_custom_room_controls_fit_both_orientations'})
case('incomplete_rebuild_leaves_live_character_unchanged',BOOT+r'''
local original=pl.Character;local old=Runtime.Description(pl);local wanted=InitialDescription:Clone();wanted.Torso=9805;WrongStructure=true
local ok,e=pcall(Runtime.Apply,pl,wanted,'R15');assert(not ok and e:find('incompleto'));assert(pl.Character==original and original.Parent==workspace)
WrongStructure=false;assert(Runtime.Apply(pl,wanted,'R15').applied)
return 'native body rebuild missing a required limb rejected before character replacement; previous character retained and retry succeeds'
''')
GUARDCLIENT=CLIENT.replace(module('09B7_LAST_AVATAR'),module('09B7_LAST_AVATAR')+r'''
local guarded=A.Copy(S.Current);guarded.props.Torso=9605
StoreData.AvatarPlaza_LastApplied_v1['u_'..pl.UserId]={version=1,session='old',body=guarded,rig='R15'}
local originalFactory=Services.Players.CreateHumanoidModelFromDescriptionAsync
function Services.Players:CreateHumanoidModelFromDescriptionAsync(d,...)
 if d.Torso==9605 then error('Saved avatar asset deliberately unavailable')end
 return originalFactory(self,d,...)
end
''')
case('opening_catalog_does_not_save_profile_over_failed_restoration',GUARDCLIENT+r'''
local store=StoreData.AvatarPlaza_LastApplied_v1;local key='u_'..pl.UserId
assert(pl:GetAttribute('ACP_AvatarRestoreError')and store[key].body.props.Torso==9605)
U.OpenRequest:Fire('Catalog');flush();advance(2)
assert(store[key].body.props.Torso==9605 and not pl:GetAttribute('ACP_AvatarSaveState'),'opening must not autosave the fallback profile')
local edited=A.Copy(S.Current);edited.props.Shirt=9901;S.Set(edited,false,nil,true);advance(2);advance(1)
assert(store[key].body.props.Shirt==9901 and pl:GetAttribute('ACP_AvatarSaveState')=='saved')
return 'a failed stored-body restore remains in storage when the catalog is only opened; an intentional new appearance change is confirmed, applied and saved'
''')
HERE.joinpath('regression_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')

