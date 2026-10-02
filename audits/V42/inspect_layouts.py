"""Approximate layout review of actual GUI instances, not Roblox rendering."""
from pathlib import Path
import sys,json,math
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'audits/V42'))
from lua_runner import Lua
MOCK=(ROOT/'audits/V42/roblox_mock.lua').read_text()
def q(s):return '[====['+s+']====]'
def src(n):return (ROOT/('scripts/V41' if n in ['07UI_DESIGN_SYSTEM','08B_AVATAR_DATA','08D_SKIN_STATE'] else 'scripts/V42')/(n+'.lua')).read_text()
THEME="installModule('07UI_DESIGN_SYSTEM',"+q(src('07UI_DESIGN_SYSTEM'))+")\n"+"installModule('09A1_SHOP_LAYOUT',"+q(src('09A1_SHOP_LAYOUT'))+")\n"
THEME+="installModule('07UI_SCREEN_BOUNDS',"+q(src('07UI_SCREEN_BOUNDS'))+")\n"
SNAP=r'''
local function escape(s)return '"'..tostring(s):gsub('\\','\\\\'):gsub('"','\\"'):gsub('\n','\\n'):gsub('\r','\\r'):gsub('\t','\\t')..'"'end
local function json(x)
 if type(x)=='string'then return escape(x)elseif type(x)=='number'or type(x)=='boolean'then return tostring(x)elseif type(x)=='table'then
  local a={};for k,v in pairs(x)do a[#a+1]=escape(k)..':'..json(v)end;return '{'..table.concat(a,',')..'}'
 end;return 'null'
end
local function snapshot(o)
 if o:IsA('ScreenGui')and not o.Enabled or o:IsA('GuiObject')and not o.Visible then return end
 local items={};for _,c in ipairs(o:GetChildren())do local n=snapshot(c);if n then items[#items+1]=n end end
 table.sort(items,function(a,b)return a.z<b.z end)
 local x={name=o.Name,kind=o.ClassName,z=o.ZIndex or o.DisplayOrder or 1,children=items}
 if o:IsA('GuiObject')then
  local p,s=o.AbsolutePosition,o.AbsoluteSize;x.x=p.X;x.y=p.Y;x.w=s.X;x.h=s.Y;x.alpha=o.BackgroundTransparency or 0
  x.color=o.BackgroundColor3;x.text=o.Text;x.size=o.TextSize or 14;x.font=o.Font and o.Font.Name;x.ink=o.TextColor3
  x.align=o.TextXAlignment and o.TextXAlignment.Name or'Center';x.valign=o.TextYAlignment and o.TextYAlignment.Name or'Center'
  x.truncate=o.TextTruncate and o.TextTruncate.Name or'';x.wrap=o.TextWrapped~=false;x.rotation=o.Rotation or 0;x.clip=o.ClipsDescendants or false
  local corner=o:FindFirstChildOfClass('UICorner');x.round=corner and corner.CornerRadius.Offset or 0
  local stroke=o:FindFirstChildOfClass('UIStroke');x.stroke=stroke and stroke.Color or nil;x.outline=stroke and stroke.Thickness or 0;x.strokeAlpha=stroke and stroke.Transparency or 0
 end
 return x
end
return json(snapshot(SCENE))
'''
# Lua serializer uses string keys for children; turn numeric keys into an ordered list.
def kids(x):return [v for k,v in sorted(x.get('children',{}).items(),key=lambda kv:int(kv[0]))]
def color(c,fallback=(245,246,248)):
 if not c:return fallback
 return tuple(round(c[k]*255)for k in('R','G','B'))
fontroot=Path('/usr/share/fonts/truetype/dejavu')
def font(sz,bold=False):return ImageFont.truetype(str(fontroot/('DejaVuSans-Bold.ttf'if bold else'DejaVuSans.ttf')),max(9,int(sz)))
clipped=[]
def drawnode(canvas,o,clip=None):
 if 'x'in o:
  x,y,w,h=[int(round(o[k]))for k in('x','y','w','h')]
  if w<=0 or h<=0:return
  layer=Image.new('RGBA',canvas.size);dr=ImageDraw.Draw(layer)
  if o.get('alpha',1)<1:
   dr.rounded_rectangle((x,y,x+w,y+h),radius=min(int(o['round']),w//2,h//2),fill=color(o.get('color'),(163,163,163))+(round(255*(1-o['alpha'])),))
  if o.get('stroke'):
   dr.rounded_rectangle((x,y,x+w,y+h),radius=min(int(o['round']),w//2,h//2),outline=color(o['stroke'])+(round(255*(1-o['strokeAlpha'])),),width=math.ceil(o['outline']))
  if o['kind']=='ViewportFrame':
   dr.text((x+w//2,y+h//2),'Prévia do avatar',font=font(14),fill=(230,232,238),anchor='mm')
  if o.get('text'):
   f=font(o['size'],'Bold'in(o.get('font')or'')or'Black'in(o.get('font')or''));pad=8 if o['kind']in('TextButton','TextBox')else 0
   maxw=max(10,w-2*pad);lines=[]
   for paragraph in o['text'].split('\n'):
    line=''
    for word in paragraph.split():
     trial=(line+' '+word).strip()
     if o['wrap'] and dr.textlength(trial,font=f)>maxw and line:lines.append(line);line=word
     else:line=trial
    lines.append(line)
   if o['truncate']=='AtEnd':
    lines=[line if dr.textlength(line,font=f)<=maxw else line[:max(0,int(maxw/(o['size']*.6))-2)]+'…'for line in lines]
   lh=round(o['size']*1.2)
   if len(lines)*lh>h+2:clipped.append((o['name'],o['text'][:60],(w,h),len(lines)*lh))
   py=y+max(0,(h-len(lines)*lh)//2)
   if o.get('valign')=='Bottom':py=y+h-len(lines)*lh-8
   for line in lines:
    tw=dr.textlength(line,font=f);px=x+pad if o['align']=='Left'else x+w-tw-pad if o['align']=='Right'else x+(w-tw)/2
    dr.text((px,py),line,font=f,fill=color(o.get('ink'))+(255,),anchor='lt');py+=lh
  if clip and (clip[2]<clip[0] or clip[3]<clip[1]):return
  if clip:
   mask=Image.new('L',canvas.size);ImageDraw.Draw(mask).rectangle(clip,fill=255);layer.putalpha(Image.composite(layer.getchannel('A'),Image.new('L',canvas.size),mask))
  canvas.alpha_composite(layer)
  if o.get('clip'):
   bounds=(x,y,x+w,y+h)
   clip=bounds if not clip else(max(clip[0],x),max(clip[1],y),min(clip[2],x+w),min(clip[3],y+h))
 for c in kids(o):drawnode(canvas,c,clip)
out=Path(__file__).with_name('layout_previews');out.mkdir(exist_ok=True);reviews=[]
setup=THEME+"installModule('08B_AVATAR_DATA',"+q(src('08B_AVATAR_DATA'))+")\nHUM=setupAvatar();installModule('08D_SKIN_STATE',"+q(src('08D_SKIN_STATE'))+")\nS=Modules['08D_SKIN_STATE'];S.Init();A=Modules['08B_AVATAR_DATA'];Cart=installModule('09C4_OUTFIT_LIBRARY',"+q(src('09C4_OUTFIT_LIBRARY'))+")\n"
setup+="U=loadModule("+q(src('09A_SHOP_UI'))+",'Shop').Build(pl);flush();U.Root.Visible=true;U.ShowPreview();Cart.Init({U=U,A=A,S=S,pl=pl,toast=function()end,call=function()end,openUtility=function()end,closeUtility=function()end})\n"
setup+="local pages={IsFinished=true};function pages:GetCurrentPage()local o={};for i=1,36 do o[i]={Id=i,Name='Item do catálogo '..i,ItemType='Asset',Price=i*10}end;return o end;function Services.AvatarEditorService:SearchCatalogAsync()return pages end\n"
setup+="loadModule("+q(src('09C2_SHOP_CATALOG'))+",'Catalog').Init({U=U,A=A,S=S,pl=pl,toast=function()end,call=function()end}).Search();flush();SCENE=U.Gui\n"
for w,h,left,right,top,bottom in[(1920,1080,0,0,58,0),(844,390,44,44,58,22),(360,640,0,0,58,0)]:
 for name,tail in [('editor',''),('body','U.BodyWindow.Visible=true'),('cart','U.Root.Visible=false;U.CartPanel.Visible=true;Cart.Add({Id=100,Name="Camisa preta",ItemType="Asset",Price=100})'),('looks','U.SetWide(true);for _,o in ipairs({U.Grid,U.Status,U.More,U.Groups,U.SubToggle,U.Query,U.SearchGo,U.Filter,U.Sort})do o.Visible=false end;U.PageTitle.Text="Meus looks";U.PageTitle.Visible=true;U.LooksArea.Visible=true;local records={};for i=1,20 do records[i]={id=tostring(i),name="Look salvo "..i,rig="R15",body=A.Copy(S.Current)}end;loadModule('+q(src('09C1_SHOP_LOOKS'))+',"Looks").Init({U=U,A=A,S=S,toast=function()end,buyBody=function()end,call=function(a)if a=="List"then return{skins=records,persistent=true}end end}).Saved();flush()')]:
  l=Lua();raw=l.run(MOCK+f'\nSCREEN_W,SCREEN_H,CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM={w},{h},{left},{right},{top},{bottom}\n'+setup+tail+'\n'+SNAP);l.close()
  canvas=Image.new('RGBA',(w,h),(20,21,24,255));clipped=[];drawnode(canvas,json.loads(raw));canvas.convert('RGB').save(out/f'{name}_{w}.png');reviews.append(dict(scene=name,viewport=[w,h],vertical_text_overflows=clipped));print(name,w,'text review',clipped[:12])

game_setup=THEME+"local gui=Instance.new('ScreenGui');gui.ScreenInsets=Enum.ScreenInsets.None;gui.Parent=pg;L=loadModule("+q(src('07H1_GAME_LOBBY'))+",'Lobby').Build(gui);B=loadModule("+q(src('07H2_GAME_BOARD'))+",'Board').Build(gui);flush();L.Root.Visible=true;SCENE=gui\n"
photo_setup=THEME+"U=loadModule("+q(src('07P4_STUDIO_UI'))+",'PhotoUI').Build(pl);U.Root.Visible=true;U.Status.Text='Arraste para girar. Abra Pose para editar o corpo.';U.Popup.Visible=true;U.PoseFooter.Visible=true;U.PopupTitle.Text='Editor de pose';U.TextLine('Escolha uma articulação. Ajuste os ângulos e confirme.',1);U.Option('Ombro direito  ▾',2);U.Row('Inclinar · X',45,3);U.Row('Virar · Y',0,4);U.Row('Abrir / fechar · Z',0,5);U.Option('Restaurar esta articulação',6);U.Layout();flush();SCENE=U.Gui\n"
for w,h,left,right,top,bottom in [(1920,1080,0,0,58,0),(844,390,44,44,58,22),(360,640,0,0,58,0)]:
 for name,scene in [('games',game_setup+"L.ModeButtons.Friends.Activated:Fire()"),('board',game_setup+"L.Root.Visible=false;B.Root.Visible=true;B.Title.Text='Xadrez';B.Message.Text='Sua vez.';B.SetTurn('SUA VEZ',true)"),('photo_pose',photo_setup)]:
  l=Lua();raw=l.run(MOCK+f'\nSCREEN_W,SCREEN_H,CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM={w},{h},{left},{right},{top},{bottom}\n'+scene+'\n'+SNAP);l.close()
  canvas=Image.new('RGBA',(w,h),(100,110,125,255));clipped=[];drawnode(canvas,json.loads(raw));canvas.convert('RGB').save(out/f'{name}_{w}.png');reviews.append(dict(scene=name,viewport=[w,h],vertical_text_overflows=clipped));print(name,w,'text review',clipped[:6])

Path(__file__).with_name('layout_review.json').write_text(json.dumps(dict(method='Approximate actual GUI rectangles; DejaVu substitutes, placeholder viewports and no GPU/physics/native bars',reviews=reviews),ensure_ascii=False,indent=2)+'\n')
