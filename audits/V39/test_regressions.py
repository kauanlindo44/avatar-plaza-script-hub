"""Behavior tests with service doubles. Run: python audits/V39/test_regressions.py.

This checks Lua-compatible syntax and selected logic; it is not a Roblox playtest.
Optional AVATAR_DATA_FIXTURE points at the installed 08B source for integration.
"""
from pathlib import Path
import json
import os
import re
from lua_runner import Lua

ROOT = Path(__file__).resolve().parents[2]
MOCK = Path(__file__).with_name("roblox_mock.lua").read_text()

def quote(source):
    assert "]====]" not in source
    return "[====[" + source + "]====]"

def src(name, version="V39"):
    return (ROOT / "scripts" / version / (name + ".lua")).read_text()

DATA = """
A={Groups={{name='TODOS',subs={{'TUDO'},{'DESTAQUES'}}},
 {name='ROUPAS',subs={{'ROUPAS',assets={'Shirt'}}}},
 {name='ANIMAÇÕES',subs={{'ANIMAÇÕES'},{'PACOTES'},{'EMOTES'}}}},Sorts={1,2,3,4,5,6}}
function A.Copy(t)local c={};for k,v in pairs(t)do c[k]=type(v)=='table'and A.Copy(v)or v end;return c end
function A.Price(i)return i.Price end
function A.ItemType(i)return i.ItemType or 'Asset'end
function A.Thumbnail()return 'thumbnail'end
function A.AssetThumb()return 'asset'end
function A.Entries()return{}end
function A.Clean(t)return t end
A.MaxSaved=40
function A.PostFilter()return true end
function A.BuildParams(gi,si,q,sort,lo,hi)
 return {SearchKeyword=q,AssetTypes=A.Groups[gi].subs[si].assets,MinPrice=tonumber(lo)or 0,MaxPrice=tonumber(hi)or 9999},A.Groups[gi].subs[si],{}
end
"""
fixture = os.environ.get("AVATAR_DATA_FIXTURE")
if fixture:
    DATA = "A=loadModule(" + quote(Path(fixture).read_text()) + ",'08B fixture')\n"

UI = "U=loadModule(" + quote(src("09A_SHOP_UI")) + ",'09A').Build(pl);flush()\n"
STATE = """
S={Rig='R15',Current={},Changed=Instance.new('BindableEvent'),ScaleRules=function()return{}end,
 GetScale=function()return 1 end,Try=function()return true end}
toasts={};function toast(t)toasts[#toasts+1]=t end
"""
results = []

def run_case(name, code, prefix=MOCK):
    runtime = Lua()
    try:
        message = runtime.run(prefix + code, name)
        results.append({"case": name, "result": "pass", "detail": message})
        print("PASS", name, message or "")
    finally:
        runtime.close()

for path in sorted((ROOT / "scripts/V39").glob("*.lua")):
    code = path.read_text()
    assert len(code.splitlines()) <= 400, path
    assert not re.search(r"(?:\+|-|\*|/|\.\.)=", code), path
    runtime = Lua()
    runtime.run(code, path.name, execute=False)
    runtime.close()
results.append({"case": "syntax_and_limits", "result": "pass", "detail": "9 scripts, <=400 lines, no compound assignments"})
old_exports = set(re.findall(r"\bU\.(\w+)\s*=", src("09A_SHOP_UI", "V38_1")))
new_exports = set(re.findall(r"\bU\.(\w+)\s*=", src("09A_SHOP_UI")))
assert not old_exports - new_exports, old_exports - new_exports
assert 'V39_STUDIO_UI' in src('09C_SHOP_CLIENT')

run_case('hud_compact_and_settings', "local kit=Instance.new('Folder');kit.Name='PracaKit';kit.Parent=rep;workspace={CurrentCamera={FieldOfView=70}}\n" + src('07G_HUB_UI') + """
flush()
local hud=pg:FindFirstChild('LimitedMarketHUD');local root=hud:FindFirstChild('HudRoot')
local top=pg:FindFirstChild('AvatarShopLauncherGui'):GetChildren()[1]
local drawer=root:FindFirstChild('ActionMenu');local settings=root:FindFirstChild('Settings')
local function inside(o,p)
 local a,b,c,d=o.AbsolutePosition,o.AbsoluteSize,p.AbsolutePosition,p.AbsoluteSize
 assert(a.X>=c.X-1 and a.Y>=c.Y-1 and a.X+b.X<=c.X+d.X+1 and a.Y+b.Y<=c.Y+d.Y+1,o.Name..' outside')
end
for _,s in ipairs({{360,604},{800,324},{1600,684}})do
 SCREEN_W,SCREEN_H=s[1],s[2];root:GetPropertyChangedSignal('AbsoluteSize'):Fire()
 if top:FindFirstChild('Menu').Visible then top:FindFirstChild('Menu').Activated:Fire()end
 for _,rail in ipairs(drawer:GetChildren())do if rail:IsA('Frame')then
  for _,b in ipairs(rail:GetChildren())do if b:IsA('GuiButton')then inside(b,drawer)end end
 end end
 inside(top:FindFirstChild('TopCatalog'),root);inside(top:FindFirstChild('TopStores'),root)
end
local cfg=drawer:FindFirstChild('RightRail'):FindFirstChild('Cfg')
cfg.Activated:Fire();assert(settings.Visible and not top.Visible);inside(settings,root)
settings:FindFirstChild('CloseCfg').Activated:Fire();assert(not settings.Visible and top.Visible)
assert(top:FindFirstChild('TopMusic'),'music compatibility hook missing')
return 'compact drawer bounds, launcher actions and settings focus'
""")

run_case("shop_layout", UI + """
local function rect(o)local p,s=o.AbsolutePosition,o.AbsoluteSize;return p.X,p.Y,s.X,s.Y end
local function inside(o,parent,label)
 local x,y,w,h=rect(o);local px,py,pw,ph=rect(parent)
 assert(w>0 and h>0,label..' empty')
 assert(x>=px-1 and y>=py-1 and x+w<=px+pw+1 and y+h<=py+ph+1,label..' outside')
end
local function apart(a,b,label)
 local x,y,w,h=rect(a);local xx,yy,ww,hh=rect(b)
 assert(x+w<=xx or xx+ww<=x or y+h<=yy or yy+hh<=y,label..' overlap')
end
for _,size in ipairs({{360,604},{390,808},{800,324},{1600,684},{320,532}})do
 SCREEN_W,SCREEN_H=size[1],size[2]
 U.SetWide(false)
 for _,key in ipairs({'Query','SearchGo','Filter','Sort','Grid','Close'})do inside(U[key],U.Main,key)end
 apart(U.Query,U.SearchGo,'search');apart(U.Sort,U.PreviewToggle,'sort/avatar')
 U.ShowPreview()
 inside(U.Viewport,U.Left,'preview');inside(U.EditorTabs,U.Left,'tabs');inside(U.EditorArea,U.Left,'editor')
 inside(U.Apply,U.Left,'apply');inside(U.Reset,U.Left,'reset')
 apart(U.Viewport,U.EditorTabs,'preview/tabs');apart(U.EditorArea,U.Apply.Parent,'editor/actions')
 apart(U.HidePreview,U.StopEmote,'back/stop');apart(U.CartClear,U.CartBuySelected,'cart actions')
 apart(U.CartTotal,U.CartBuySelected,'cart subtotal')
 assert(U.ItemStrip.AbsoluteSize.Y>=36,'equipped items clipped')
 for _,mode in ipairs({'CORPO','ITENS','EMOTES'})do U.LayoutEditor(mode);inside(U.EditorArea,U.Left,mode)end
 U.SetWide(true);U.LayoutLooks()
 inside(U.SavedPreview,U.SavedPreviewPanel,'saved preview');inside(U.SavedItems,U.SavedPreviewPanel,'saved items')
 apart(U.SavedItems,U.OutfitActions,'saved items/actions')
end
return '5 screen sizes; search, preview, editor, saved looks and cart bounds'
""")

def bot_functions(version):
    code = src("07H_GAME_UI", version)
    return code[code.index("local function allMoves"):code.index("local function botResult")]

run_case("bot_sort_regression", """
local rules={Legal=function(_,r,c)local m={};if r==1 and c==1 then for i=1,80 do m[i]={tr=4,tc=4,index=i}end end;return m end}
local board={};for r=1,8 do board[r]={}end
local bs={rules=rules,state={board=board},game='Damas',diff='DIFICIL'}
math.randomseed(42)
""" + bot_functions("V38_1") + """
local failures=0
for i=1,1000 do local ok=pcall(chooseBot,bs);if not ok then failures=failures+1 end end
assert(failures>0,'baseline defect not reproduced')
""" + bot_functions("V39") + """
for i=1,5000 do assert(chooseBot(bs))end
local random=math.random;local calls=0;math.random=function(...)calls=calls+1;return random(...)end
chooseBot(bs);assert(calls==80,'randomness must be evaluated once per move')
math.random=random
return 'baseline failed '..failures..' times; V39 passed 5000 sorts'
""")

run_case("bot_real_rules", "local Chess=loadModule(" + quote(src("07A0_CHESS_RULES", "V37")) + ",'chess');local Checkers=loadModule(" + quote(src("07B0_CHECKERS_RULES", "V37")) + ",'checkers')\n" + bot_functions("V39") + """
math.randomseed(39)
local moves=0
for _,g in ipairs({{'Xadrez',Chess},{'Damas',Checkers}})do
 for _,diff in ipairs({'FACIL','MEDIO','DIFICIL'})do
  for round=1,3 do
   local bs={game=g[1],rules=g[2],state=g[2].New(),diff=diff}
   for ply=1,80 do
    if bs.rules.Result(bs.state)then break end
    local legal=allMoves(bs.rules,bs.state);local m=chooseBot(bs);assert(m,'no chosen move')
    local found=false;for _,v in ipairs(legal)do if v.fr==m.fr and v.fc==m.fc and v.tr==m.tr and v.tc==m.tc then found=true end end
    assert(found,'illegal bot move');assert(bs.rules.Apply(bs.state,m,'Q'));moves=moves+1
   end
  end
 end
end
return moves..' legal moves across chess/checkers and three difficulties'
""")

PAGES = """
requests={};responses={}
function page(items,nextItems)
 local p={IsFinished=nextItems==nil,items=items}
 function p:GetCurrentPage()return self.items end
 function p:AdvanceToNextPageAsync()assert(not self.IsFinished);self.items=nextItems;self.IsFinished=true end
 return p
end
function Services.AvatarEditorService:SearchCatalogAsync(params)
 requests[#requests+1]=params;return table.remove(responses,1)or page({})
end
"""
run_case("catalog_search_and_pages", DATA + UI + STATE + PAGES + """
Modules['09C4_OUTFIT_LIBRARY']={Add=function()end,Open=function()end}
""" + "local C=loadModule(" + quote(src("09C2_SHOP_CATALOG")) + ",'catalog').Init({U=U,A=A,S=S,toast=toast})\n" + """
U.SetWide(false);U.Root.Visible=true;U.Grid.Visible=true
local shirt;for _,b in ipairs(U.Groups:GetChildren())do if b.Text=='ROUPAS'then shirt=b end end
assert(shirt);shirt.Activated:Fire();flush()
U.Query.Text='blue';C.Search();flush()
local q=requests[#requests];assert(q.SearchKeyword=='blue');assert(q.AssetTypes and #q.AssetTypes>0,'category lost during keyword search')
assert(q.MinPrice==1,'paid discovery default')
U.Max.Text='0';C.Search();flush();assert(requests[#requests].MinPrice==0,'explicit free ceiling');U.Max.Text=''
local first,second={},{}
for i=1,24 do first[#first+1]={Id=i,Name='Dance '..i,AssetType=Enum.AvatarAssetType.EmoteAnimation,Price=10}end
second={{Id=24,AssetType=Enum.AvatarAssetType.EmoteAnimation,Price=10},{Id=25,AssetType=Enum.AvatarAssetType.EmoteAnimation,Price=10},{Id=26,AssetType=Enum.AvatarAssetType.Hat,Price=10}}
responses={page(first,second)};C.Preset('Emotes');flush()
assert(guiCards(U.Grid)==24,'emotes truncated');assert(U.More.Visible)
U.More.Activated:Fire();flush();assert(guiCards(U.Grid)==25,'pagination or dedup/filter failed');assert(not U.More.Visible)
local old={Id=100,Name='OLD',Price=10,AssetType=Enum.AvatarAssetType.EmoteAnimation};local fresh={Id=200,Name='NEW',Price=10,AssetType=Enum.AvatarAssetType.EmoteAnimation}
responses={page({fresh}),page({old})};U.Query.Text='old';C.Search();U.Query.Text='new';C.Search();flush(2)
assert(guiCards(U.Grid)==1,'old response appended');assert(U.Status.Text:find('1 itens'))
U.Min.Text='invalid';local before=#requests;C.Search();flush();assert(#requests==before,'invalid prices called API')
return 'keyword/category, free ceiling, 24 emotes + pagination, deduplication, stale response, invalid price'
""")

run_case("cart_selection_and_prices", DATA + UI + STATE + """
local purchases=0
""" + "local Cart=loadModule(" + quote(src("09C4_OUTFIT_LIBRARY")) + ",'cart').Init({U=U,A=A,S=S,toast=toast,call=function(_,args)purchases=purchases+1;return{count=#args.items}end})\n" + """
assert(Cart.Add({Id=1,Name='Unknown'}));Cart.Add({Id=1,Name='Unknown'})
assert(Cart.Count()==1,'duplicate cart item');assert(U.CartTotal.Text=='SUBTOTAL: 0 Robux','unknown shown free')
Cart.Add({Id=2,Name='Paid',Price=25});assert(U.CartTotal.Text=='SUBTOTAL: 25 Robux')
for id=3,21 do Cart.Add({Id=id,Name='Item',Price=10})end
U.CartBuySelected.Activated:Fire();assert(purchases==0,'silently truncated selection over 20')
U.CartClear.Activated:Fire();assert(Cart.Count()==0);assert(U.CartTotal.Text=='TOTAL: 0 Robux')
for id=1,20 do Cart.Add({Id=id,Name='Item',Price=10})end
U.CartBuySelected.Activated:Fire();assert(purchases==1)
assert(not Cart.Add({Id=-1}));assert(not Cart.Add({Id=1.5}))
return 'deduplication, unknown subtotal, explicit 20-item limit and valid purchase'
""")

run_case("server_update_and_purchase", DATA + """
local data={version=1,skins={{id='skin1',name='Before',body={},rig='R15'}}}
local transforming=false;local filters=0;local purchases=0;local lastLines
Services.DataStoreService={GetDataStore=function()return{
 GetAsync=function()return data end,
 UpdateAsync=function(_,_,fn)transforming=true;local out=fn(A.Copy(data));out=fn(A.Copy(data));transforming=false;data=out;return out end}end}
Services.TextService={FilterStringAsync=function(_,name)
 assert(not transforming,'TextService yielded inside UpdateAsync callback');filters=filters+1
 return{GetNonChatStringForBroadcastAsync=function()return name..' filtered'end}
end}
Services.HttpService={GenerateGUID=function()return 'new'end}
Services.Players.PlayerRemoving=Signal()
function Services.MarketplaceService:PromptBulkPurchase(_,lines)lastLines=lines;purchases=purchases+1 end
Modules['08B_AVATAR_DATA']=A
Modules['08L_COMMUNITY']={SetResolver=function()end,Publish=function()end}
""" + src("09B_SHOP_SERVER") + """
local rpc=rep:FindFirstChild('LMShop_Remotes'):FindFirstChild('Request')
local r=rpc.OnServerInvoke(pl,'Update',{id='skin1',name='New'})
assert(r.ok,r.error);assert(filters==1);assert(data.skins[1].name=='New filtered')
local many={};for i=1,21 do many[i]={id=i,kind='Asset'}end
assert(not rpc.OnServerInvoke(pl,'CartPurchase',{items=many}).ok);assert(purchases==0)
for _,id in ipairs({-1,1.5,math.huge,0/0})do assert(not rpc.OnServerInvoke(pl,'CartPurchase',{items={{id=id}}}).ok)end
assert(not rpc.OnServerInvoke(pl,'CartPurchase',{items={{id=1,kind='Other'}}}).ok)
r=rpc.OnServerInvoke(pl,'CartPurchase',{items={{id=1},{id=1},{id=1,kind='Bundle'}}})
assert(r.ok,r.error);assert(#lastLines==2 and purchases==1,'asset/bundle deduplication')
return 'filter once outside retryable transform; invalid/over-limit purchases rejected'
""")

run_case("ugc_creator_search", DATA + UI + PAGES + """
U.StoresArea.Visible=true
""" + "local Store=loadModule(" + quote(src("09C5_UGC_STORES")) + ",'stores').Init({U=U,A=A,toast=function()end,showItem=function()end})\n" + """
assert(#requests==0,'unrequested background search')
U.StoreSearch.Text='Designer';Store.Search();flush();assert(requests[#requests].CreatorName=='Designer');assert(requests[#requests].CreatorType==Enum.CreatorTypeFilter.User)
U.StoreType.Activated:Fire();flush();assert(requests[#requests].CreatorType==Enum.CreatorTypeFilter.Group)
responses={page({{Id=2,Price=10}}),page({{Id=1,Price=10}})};Store.Search();Store.Search();flush(2)
assert(guiCards(U.StoreGrid)==1,'stale store response')
return 'on-demand creator/group requests and stale-response cancellation'
""")

Path(__file__).with_name("results.json").write_text(json.dumps({"runtime": "liblua5.4 + service doubles; no Roblox engine", "cases": results}, indent=2, ensure_ascii=False) + "\n")
print(f"{len(results)} cases passed")
