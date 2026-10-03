"""Reuse existing avatar/cart regressions and exercise complete V43 controllers."""
import ast
from test_support import *
DATA=DATA.replace(';S.Init()','')
CART=module('09C4_OUTFIT_LIBRARY')+"Cart=Modules['09C4_OUTFIT_LIBRARY']\n"
old=ast.parse((ROOT/'audits/V42/test_revision.py').read_text())
selected={'apply_single_clothing_preserves_live_avatar','blank_outfit_restore_history_and_body_limits','bundle_only_adds_its_pieces_and_rejects_stale_try','appearance_not_ready_cannot_initialize_or_apply'}
for expr in old.body:
 if isinstance(expr,ast.Expr)and isinstance(expr.value,ast.Call)and getattr(expr.value.func,'id','')=='case':
  name=ast.literal_eval(expr.value.args[0])
  if name in selected:case(name,eval(compile(ast.Expression(expr.value.args[1]),'<V42 regression>','eval'),globals()))
CLIENT=UI+DATA+PREVIEW+SERVER+CART+r'''
local kit=Instance.new('Folder');kit.Name='PracaKit';kit.Parent=rep
local hud=Instance.new('ScreenGui');hud.Name='LimitedMarketHUD';hud.Enabled=true;hud.Parent=pg
local launcher=Instance.new('ScreenGui');launcher.Name='AvatarShopLauncherGui';launcher.Parent=pg;U.LauncherGui=launcher
Modules['09A_SHOP_UI']={VERSION='V43_STUDIO_UI',Build=function()return U end};local ui=Instance.new('ModuleScript');ui.Name='09A_SHOP_UI';ui.Parent=rep
for _,name in ipairs({'09C2_SHOP_CATALOG','09C1_SHOP_LOOKS','09C5_UGC_STORES'})do
 local o=Instance.new('ModuleScript');o.Name=name;o.Parent=rep
 Modules[name]={Init=function()return{Search=function()end,Preset=function()end,Saved=function()end,Community=function()end}end}
end
local prompts=0;function Services.MarketplaceService:PromptRobloxSubscriptionPurchase(p)assert(p==pl);prompts=prompts+1 end
'''+src('09C_SHOP_CLIENT')+'\nflush()\n'
for expr in old.body:
 if isinstance(expr,ast.Expr)and isinstance(expr.value,ast.Call)and getattr(expr.value.func,'id','')=='case'and ast.literal_eval(expr.value.args[0])=='cart_selection_total_clear_remove_purchase':
  case('cart_selection_total_clear_remove_purchase',eval(compile(ast.Expression(expr.value.args[1]),'<V42 regression>','eval'),globals()))
case('client_native_plus_exclusive_cart_and_loader_close',CLIENT+r'''
U.OpenRequest:Fire('Catalog');flush();assert(U.Root.Visible and not pg.LimitedMarketHUD.Enabled)
U.OpenRequest:Fire('Cart');flush();assert(U.CartPanel.Visible and not U.Root.Visible and not U.Loader.Visible)
U.CartClose.Activated:Fire();flush();assert(U.Root.Visible)
U.OpenRequest:Fire('Plus');flush();assert(prompts==1 and not U.PlusPanel.Visible and not U.CartPanel.Visible)
U.OpenRequest:Fire('Loader');flush();assert(U.Loader.Visible and not U.Root.Visible and U.LoaderQuery.focused)
U.LoaderQuery.Text='333';U.LoaderSearch.Activated:Fire();flush();assert(U.LoaderUse.Visible and U.LoaderName.Text:find('Display 333',1,true)and UserBatches[#UserBatches][1]==333,U.LoaderStatus.Text)
U.LoaderClose.Activated:Fire();flush();assert(not U.Loader.Visible and U.Root.Visible and not U.LoaderQuery.focused)
U.OpenRequest:Fire('Loader');U.LoaderClose.Activated:Fire();flush();assert(not U.Loader.Visible and not U.LoaderQuery.focused,'deferred focus reopened keyboard')
U.Close.Activated:Fire();flush();assert(not U.Root.Visible and pg.LimitedMarketHUD.Enabled)
return 'direct Plus, cart/loader exclusivity, current UserService lookup and closing restores HUD and keyboard'
''')
PHOTO=THEME+DATA+"S.Init()\n"+PREVIEW+module('07P0_STUDIO_PRESETS')+module('07P3_POSE_EDITOR')+module('07P5_POSE_CANVAS')+module('07P6_STUDIO_SETS')+module('07P2_STUDIO_AVATAR')+"Studio=Modules['07P2_STUDIO_AVATAR']\n"+module('07P4_STUDIO_UI')
case('full_photo_controller_pose_capture_and_exit_races',PHOTO+r'''
Modules['07P1_CAPTURE_ENGINE']={TakePhoto=function(_,callback)PHOTO_CALLBACK=callback;return true end,SaveLast=function()return false,'Sem foto'end,ShareLast=function()return false,'Sem foto'end}
local mod=Instance.new('ModuleScript');mod.Name='07P1_CAPTURE_ENGINE';mod.Parent=rep
local hud=Instance.new('ScreenGui');hud.Name='LimitedMarketHUD';hud.Enabled=true;hud.Parent=pg
local hidden=Instance.new('ScreenGui');hidden.Name='AlreadyHidden';hidden.Enabled=false;hidden.Parent=pg
'''+src('07P_PHOTO_MODE')+r'''
flush();pg:SetAttribute('ACP_OpenPhotoNonce',1);flush();local gui=pg.ACP_PhotoMode;local root=gui.PhotoStudio
assert(root.Visible and Studio.Model and not hud.Enabled and not hidden.Enabled)
local nav=root:FindFirstChildOfClass('ScrollingFrame');local tools=named(root,'PhotoTools')
local poseButton;for _,b in ipairs(nav:GetChildren())do if b.Text=='Pose'then poseButton=b end end
poseButton.Activated:Fire();flush();assert(Studio.Pose.Editing and named(tools,'PoseCanvas'))
local shoulder=named(tools,'Pose_RightShoulder');local p,s=shoulder.AbsolutePosition,shoulder.AbsoluteSize
local pointer={UserInputType=Enum.UserInputType.Touch,Position=Vector3.new(p.X+s.X*.5,p.Y+s.Y*.5,0)};shoulder.InputBegan:Fire(pointer)
pointer.Position=Vector3.new(p.X+s.X*.5+40,p.Y+s.Y*.5,0);Services.UserInputService.InputChanged:Fire(pointer);Services.UserInputService.InputEnded:Fire(pointer)
assert(Studio.Pose.Values.RightShoulder[3]~=0)
local confirm;for _,o in ipairs(tools:GetDescendants())do if o.Text=='Aplicar'then confirm=o end end;confirm.Activated:Fire();flush();local saved=Studio.Pose.Values.RightShoulder[3]
assert(not Studio.Pose.Editing and not tools.Visible)
poseButton.Activated:Fire();flush();Studio.Pose.Set('RightShoulder',3,0);named(tools,'CloseTools').Activated:Fire();flush();assert(Studio.Pose.Values.RightShoulder[3]==saved)
local photo;for _,b in ipairs(nav:GetChildren())do if b.Text=='Foto'then photo=b end end;photo.Activated:Fire();flush()
local capture;for _,o in ipairs(tools:GetDescendants())do if o.Text=='Tirar foto'then capture=o end end;capture.Activated:Fire();flush();assert(not gui.Enabled)
named(root,'ClosePhoto').Activated:Fire();assert(not root.Visible and hud.Enabled and not hidden.Enabled)
PHOTO_CALLBACK(true);flush();assert(not root.Visible and not Studio.Model)
pg:SetAttribute('ACP_OpenPhotoNonce',2);pg:SetAttribute('ACP_OpenPhotoNonce',3);flush();assert(not Studio.Model and not root.Visible)
return 'confirmed pose persists; cancel restores; capture/enter callbacks after exit cannot resurrect the studio'
''')
oldGames=ast.parse((ROOT/'audits/V42/test_games.py').read_text())
for expr in oldGames.body:
 if isinstance(expr,(ast.Assign,ast.AugAssign)):
  name=getattr(expr.targets[0]if isinstance(expr,ast.Assign)else expr.target,'id','')
  if name=='GAME_ENV':exec(compile(ast.Module(body=[expr],type_ignores=[]),'<game fixture>','exec'),globals())
 if isinstance(expr,ast.For)and 'GAME_ENV' in ast.unparse(expr):exec(compile(ast.Module(body=[expr],type_ignores=[]),'<game fixture>','exec'),globals())
GAME_ENV=GAME_ENV.replace(src('07H_GAME_UI'),module('07H4_BOT_ENGINE')+src('07H_GAME_UI'))
for expr in oldGames.body:
 if isinstance(expr,ast.Expr)and isinstance(expr.value,ast.Call)and getattr(expr.value.func,'id','')=='case':
  name=ast.literal_eval(expr.value.args[0])
  if name in {'game_controller_room_contract_and_failures','online_potato_overlay_and_leave'}:case(name,eval(compile(ast.Expression(expr.value.args[1]),'<game regression>','eval'),globals()))
case('potato_reveal_lock_real_levels_and_stale_turn',GAME_ENV+r'''
pg:SetAttribute('ACP_OpenGamesNonce',1);flush();GL.SetGame('Batata');GL.ModeButtons.Practice.Activated:Fire();GL.Bot.Activated:Fire();flush()
local red=0;for _,b in ipairs(GB.PotatoButtons)do if b.BackgroundColor3==Modules['07UI_DESIGN_SYSTEM'].Colors.red then red=red+1 end;assert(not b.Active)end;assert(red==3)
local before=GB.PotatoButtons[1].Text;GB.PotatoButtons[1].Activated:Fire();assert(GB.PotatoButtons[1].Text==before,'choice accepted during reveal')
advance(3);for _,b in ipairs(GB.PotatoButtons)do assert(b.Active)end
GB.Resign.Activated:Fire();GL.Bot.Activated:Fire();GB.Resign.Activated:Fire();advance(4);assert(GL.Root.Visible and not GB.Root.Visible,'old reveal reopened cancelled training')
return 'three shared visible poisons, locked reveal, timed hide and no stale cancelled bot callbacks'
''')
case('published_page_capacity_and_authorized_lookup',DATA+SERVER+r'''
local community=Modules['08L_COMMUNITY'];local lookups=0
function community.ByCode(_,args)lookups=lookups+1;return{id=args.code,code=args.code,body=A.Copy(A.Pack(InitialDescription)),rig='R15'}end
local codes={};for i=1,47 do codes[i]='AP-'..i end
local r=RPC:InvokeServer('PublicPage',{codes=codes});assert(r.ok and #r.data.items==47 and lookups==47)
advance(1);local bad={};for i=1,51 do bad[i]='AP-'..i end;r=RPC:InvokeServer('PublicPage',{codes=bad});assert(not r.ok and lookups==47)
return 'legacy filtered pages up to 47 records reload completely; oversized requests are rejected'
''')
case('published_virtual_gallery_week_trend_and_reload',UI+DATA+"S.Init()\n"+PREVIEW+COMMUNITY+r'''
local mode='pages';local page=0;local reloads=0;local body=A.Copy(S.Current)
local f=Modules['09C7_COMMUNITY_FEED'].Init({U=U,A=A,toast=function()end,show=function()end,call=function(action,args)
 if action=='PublicPage'then reloads=reloads+1;local rows={};for i,code in ipairs(args.codes)do rows[i]={id=code,code=code,body=body,rig='R15',name=code,username='Author',updated=os.time()}end;return{items=rows}end
 assert(action=='Feed');if not args.next then page=0 else page=page+1 end
 if mode=='week'then return{finished=true,items={{id='old',code='AP-OLD',name='Old',body=body,updated=os.time()-700000,likes=200},{id='week',code='AP-WEEK',name='This week',body=body,updated=os.time()-60,likes=3}}}end
 if mode=='trend'then return{finished=true,items={{id='old',code='AP-OLD',name='Old',body=body,updated=os.time()-2592000,likes=200},{id='fresh',code='AP-FRESH',name='Fresh',body=body,updated=os.time(),likes=25}}}end
 local rows={};for i=1,47 do local code='AP-'..page..'_'..i;rows[i]={id=code,code=code,name=code,body=body,rig='R15',username='Author',updated=os.time()}end;return{items=rows}
end})
SCREEN_W,SCREEN_H=1460,821;U.SetWide(true);U.Root.Visible=true;U.CommunityArea.Visible=true;U.Layout();f.Open('NOVOS');flush();assert(#f.Cache[0]==47)
for i=1,24 do local row=math.floor((f.End-10)/5);local step=f.Pool[1].root.AbsoluteSize.Y+6;U.CommunityGrid.CanvasPosition=Vector2.new(0,row*step);flush();assert(guiCards(U.CommunityGrid)==50 and #f.Order<=12)end
assert(f.Highest>12 and not f.Cache[0]);U.CommunityGrid.CanvasPosition=Vector2.zero;flush();assert(reloads>0 and #f.Cache[0]==47)
mode='week';f.Open('LOOK DA SEMANA');flush();assert(#f.Cache[0]==1 and f.Cache[0][1].id=='week')
mode='trend';f.Open('EM ALTA');flush();assert(f.Cache[0][1].id=='fresh')
local last=mode;mode='pages';f.Open('NOVOS');f.Open('ROBLOX');f.Open('NOVOS');flush();assert(f.Mode=='NOVOS'and f.Highest==0 and #f.Cache[0]==47,'stale requests entered new feed')
U.Root.Visible=false;flush();for _,slot in ipairs(f.Pool)do assert(not slot.root.Visible and not slot.view:FindFirstChildOfClass('WorldModel'))end
return 'published 3D cards recycle, 47-code pages reload, week filters dates, trend decays likes and stale modes are discarded'
''')
HERE.joinpath('regression_results.json').write_text(json.dumps(results,indent=2,ensure_ascii=False)+'\n')
print('REGRESSIONS',len(results),'PASS')
