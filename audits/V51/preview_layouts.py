from pathlib import Path
import sys,json,math
from PIL import Image,ImageDraw,ImageFont
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
def kids(x):return [v for k,v in sorted(x.get('children',{}).items(),key=lambda kv:int(kv[0]))]
def color(c,fallback=(245,246,248)):
 if not c:return fallback
 return tuple(round(c[k]*255)for k in('R','G','B'))
fontroot=Path('/usr/share/fonts/truetype/dejavu')
def font(sz,bold=False):return ImageFont.truetype(str(fontroot/('DejaVuSans-Bold.ttf'if bold else'DejaVuSans.ttf')),max(9,int(sz)))
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
import sys
sys.path.insert(0,str(Path(__file__).parent))
from test_support import *
out=ROOT.parent/'analysis/v51_previews';out.mkdir(exist_ok=True)
setup=UI+DATA+module('09C4_OUTFIT_LIBRARY')+module('09C2_SHOP_CATALOG')+"""
U.Root.Visible=true;U.SetWide(false)
Modules['09C4_OUTFIT_LIBRARY'].Init({U=U,A=A,S=S,pl=pl,toast=function()end,call=function()end})
function Services.AvatarEditorService:SearchCatalogAsync()return{IsFinished=false,GetCurrentPage=function()local items={};for i=1,20 do items[i]={Id=500+i,Name='Corpo ou roupa '..i,ItemType='Asset',Price=i==10 and 1234567 or 41+i}end;return items end}end
local ctl=Modules['09C2_SHOP_CATALOG'].Init({U=U,A=A,S=S,toast=function()end});ctl.Search();flush();U.Layout();ctl.Resize();SCENE=U.Gui
"""
def shift(o,x,y):
 if 'x'in o:o['x']+=x;o['y']+=y
 for c in kids(o):shift(c,x,y)
for w,h,il,ir,ib in [(935,420,0,0,0),(844,390,44,44,21),(390,844,0,0,34),(568,320,0,0,0)]:
 l=Lua();raw=l.run(MOCK+f'\nSCREEN_W,SCREEN_H,CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_TOP,DEVICE_BOTTOM,TOPBAR_LEFT={w},{h},{il},{ir},58,120,{il},{ir},0,{ib},180\n'+setup+SNAP);l.close()
 scene=json.loads(raw);shift(scene,il,58)
 canvas=Image.new('RGBA',(w,h),(20,21,24,255));clipped=[];drawnode(canvas,scene)
 dr=ImageDraw.Draw(canvas);dr.rectangle((il,0,180,58),fill=(28,29,31,255));dr.text((il+8,8),'ROBLOX',font=font(13),fill=(220,222,226))
 canvas.convert('RGB').save(out/f'catalog_{w}.png');print(w,'text review',clipped[:8])
