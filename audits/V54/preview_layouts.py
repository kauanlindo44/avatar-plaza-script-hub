# Diagnostic reconstructions from actual Lua UI bounds, not native Roblox screenshots.
from test_support import *
import ast,math,json
from PIL import Image,ImageDraw,ImageFont
source=(ROOT/'audits/V51/preview_layouts.py').read_text();tree=ast.parse(source)
nodes=[]
for n in tree.body:
 if isinstance(n,ast.FunctionDef):nodes.append(n)
 elif isinstance(n,ast.Assign)and isinstance(n.targets[0],ast.Name)and n.targets[0].id in {'SNAP','fontroot'}:nodes.append(n)
exec(compile(ast.Module(body=nodes,type_ignores=[]),'<geometry renderer>','exec'),globals())
SNAP=SNAP.replace("x.font=o.Font and o.Font.Name", "x.scaled=o.TextScaled;local g=o:FindFirstChildOfClass('UIGradient');x.gradient=g and g.Color;x.font=o.Font and o.Font.Name")
BASE=THEME+module('07K6_CARD_CATALOG')+module('07K7_CARD_STYLES')
GAMES=BASE+module('07H5_TRUCO_SETUP')+module('07H1_GAME_LOBBY')
TRUCO=BASE+module('07K0_TRUCO_RULES')+module('07K15_TRUCO_TABLE')+module('07K5_TRUCO_UI')
CARDS=BASE+module('07K16_ATELIER_UI')+module('07K9_CARD_INVENTORY_UI')
setup={
 'lobby':GAMES+"SCENE=Instance.new('ScreenGui');SCENE.ScreenInsets=Enum.ScreenInsets.None;SCENE.Parent=pg;local u=Modules['07H1_GAME_LOBBY'].Build(SCENE);u.Root.Visible=true;u.Layout();flush();",
 'bots':GAMES+"SCENE=Instance.new('ScreenGui');SCENE.ScreenInsets=Enum.ScreenInsets.None;SCENE.Parent=pg;local u=Modules['07H1_GAME_LOBBY'].Build(SCENE);u.Root.Visible=true;u.Mode='Practice';u.Options.Visible=true;u.Layout();flush();",
 'truco':TRUCO+"""SCENE=Instance.new('ScreenGui');SCENE.ScreenInsets=Enum.ScreenInsets.None;SCENE.Parent=pg;local u=Modules['07K5_TRUCO_UI'].Build(SCENE,function()end);u.Update({seat=1,variant='Paulista',score={3,6},phase='play',turn=1,value=3,handNumber=2,tricks={},tableCards={{seat=1,card={rank='A',suit='D'}},{seat=2,card={rank='3',suit='H'}},{seat=3,card={rank='Q',suit='C'}},{seat=4,card={rank='K',suit='S'}}},lastTrick={},counts={2,2,2,2},players={{uid=123,name='Você'},{uid=22,name='Lucas'},{uid=33,name='Ana'},{uid=44,name='Pedro'}},hand={{rank='7',suit='D'},{rank='3',suit='S'},{rank='Q',suit='H'}},nextRaise=6,remaining=30,vira={rank='4',suit='C'}},{equipped='Hex',view='mine'});u.Layout();flush();""",
 'cards':CARDS+"""SCENE=Instance.new('ScreenGui');SCENE.ScreenInsets=Enum.ScreenInsets.None;SCENE.Parent=pg;local u=Modules['07K9_CARD_INVENTORY_UI'].Build(SCENE,function()end,function()end);u.Root.Visible=true;u.AcceptData({coins=1450,owned={Classic=true},boxes={},ateliers=true,presets={},custom={image=0,zoom=1,x=0,y=0}});u.Render();flush();"""}
UTILITY=UI+DATA+PREVIEW+COMMUNITY+module('09C1_SHOP_LOOKS')+"""
U.Root.Visible=true;U.SetWide(true)
local skins={};for i=1,20 do skins[i]={id='demo'..i,name='Look salvo '..i,body=A.Copy(S.Current),rig='R15'}end
local function call(a,args)
 if a=='List'then return{skins=skins,persistent=true}end
 if a=='OutfitQuote'then local items={};for i=1,6 do items[i]={id=400+i,name='Item do look '..i,price=41+i,known=true,kind='Asset'}end;return{items=items}end
 return{items={},finished=true}
end
Modules['09C4_OUTFIT_LIBRARY'].Init({U=U,A=A,S=S,pl=pl,toast=function()end,call=call})
local looks=Modules['09C1_SHOP_LOOKS'].Init({U=U,A=A,S=S,pl=pl,toast=function()end,call=call,buyBody=function()end})
"""
setup['saved']=UTILITY+"U.LooksArea.Visible=true;U.CommunityArea.Visible=false;looks.Saved();flush();U.Layout();SCENE=U.Gui"
setup['cart']=UTILITY+"U.LooksArea.Visible=false;U.CommunityArea.Visible=false;Modules['09C4_OUTFIT_LIBRARY'].Open(S.Current);flush();U.Layout();SCENE=U.Gui"
setup['save']=UTILITY+"U.LooksArea.Visible=false;U.CommunityArea.Visible=false;U.SaveBox.Visible=true;U.SaveName.Text='Meu novo look';flush();U.Layout();SCENE=U.Gui"
setup['community']=UI+DATA+PREVIEW+COMMUNITY+"""
U.Root.Visible=true;U.SetWide(true);U.LooksArea.Visible=false;U.CommunityArea.Visible=true
local feed=Modules['09C7_COMMUNITY_FEED'].Init({U=U,A=A,toast=function()end,show=function()end,call=function(a,args)
 local out={};for i=1,50 do out[i]={id='sample'..i,signature='body'..i,body=A.Copy(S.Current),rig='R15',source='Roblox',owner=1000+i,name='Outfit '..i,total=41+i}end
 return{items=out,finished=true}
end});feed.Open();flush();U.Layout();feed.Layout();flush();SCENE=U.Gui
"""
setup.pop('cards')
out=ROOT.parent/'analysis/v54_previews';out.mkdir(exist_ok=True,parents=True)
summary=[]
for name,code in setup.items():
 for w,h in [(851,392),(390,844),(568,320)]:
  l=Lua();raw=l.run(MOCK+f'\nSCREEN_W,SCREEN_H,CORE_TOP,DEVICE_TOP={w},{h},58,0\n'+code+SNAP);l.close();scene=json.loads(raw);shift(scene,0,58)
  def scale(node):
   if node.get('scaled'):node['size']=max(9,min(node['h']/(1.3*max(1,len((node.get('text')or'').split('\n')))),node['w']/(.7*max(1,max(map(len,(node.get('text')or'').split('\n')))))))
   for c in kids(node):scale(c)
  scale(scene);canvas=Image.new('RGBA',(w,h),(12,20,23,255));clipped=[];drawnode(canvas,scene)
  dr=ImageDraw.Draw(canvas);dr.rounded_rectangle((8,4,168,52),radius=10,fill=(28,29,31));dr.text((88,28),'ROBLOX',font=font(13),fill=(220,222,226),anchor='mm')
  canvas.convert('RGB').save(out/f'{name}_{w}.png');summary.append({'view':name,'size':[w,h],'text_review':clipped});print(name,w,clipped[:5])
(out/'review.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2))
