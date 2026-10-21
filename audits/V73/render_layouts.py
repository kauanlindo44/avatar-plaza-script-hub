"""Rasterize exported GUI geometry for review. Illustrative assets; not native Roblox rendering."""
from pathlib import Path
import json,math,textwrap
from PIL import Image,ImageDraw,ImageFont
HERE=Path(__file__).parent;FOLDER=HERE/'layouts'
FONT='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf';BOLD='/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
def font(size,bold=False):return ImageFont.truetype(BOLD if bold else FONT,max(6,int(size)))
def rgba(c,a=1):return tuple(c or[36,52,63])+(int(max(0,min(1,a))*255),)
def text(draw,n):
 value=n.get('text')or n.get('placeholder')or''
 if not value:return
 x,y,w,h=[n[k]for k in('x','y','w','h')];size=n.get('font',14)
 if n.get('scaled'):size=max(10,min(h*.65,w/max(1,len(value))*1.5))
 f=font(size,n.get('bold'));width=max(1,w-8);lines=[]
 for paragraph in value.split('\n'):
  if not n.get('wrap'):lines.append(paragraph);continue
  current=''
  for word in paragraph.split(' '):
   if draw.textlength(current+(' 'if current else'')+word,font=f)>width and current:lines.append(current);current=word
   else:current+=(' 'if current else'')+word
  lines.append(current)
 lineh=size*1.18;total=lineh*len(lines);va=n.get('valign')or'';start=y if'Top'in va else y+h-total if'Bottom'in va else y+(h-total)/2
 ink=rgba(n.get('ink'),n.get('textOpacity',1));a=n.get('align')or''
 for i,line in enumerate(lines):
  yy=start+i*lineh
  if yy<y-2 or yy+lineh>y+h+3:continue
  tw=draw.textlength(line,font=f);xx=x+4 if'Left'in a else x+w-tw-4 if'Right'in a else x+(w-tw)/2
  draw.text((xx,yy),line,font=f,fill=ink,stroke_width=0)
def rounded(draw,rect,radius,**kwargs):
 try:draw.rounded_rectangle(rect,radius,**kwargs)
 except ValueError:draw.rectangle(rect,**kwargs)
def draw_node(canvas,n):
 x,y,w,h=[float(n[k])for k in('x','y','w','h')]
 if w<.5 or h<.5:return
 layer=Image.new('RGBA',canvas.size);d=ImageDraw.Draw(layer);rect=(x,y,x+w,y+h);radius=max(0,min(n.get('radius',0),w/2,h/2))
 if n.get('bg')and n.get('opacity',1)>0:rounded(d,rect,radius,fill=rgba(n['bg'],n.get('opacity',1)))
 if n.get('stroke')and n.get('strokeOpacity',0)>0 and min(w,h)>=3:rounded(d,rect,radius,outline=rgba(n['stroke'],n.get('strokeOpacity',1)),width=max(1,min(int(min(w,h)/3),int(n.get('strokeWidth',1)))))
 if n['class']=='ViewportFrame':
  d.rectangle(rect,fill=rgba(n.get('bg')or[61,65,73]));cx=x+w*.5;sy=y+h*.12;unit=min(w*.44,h*.65);head=unit*.25
  d.rounded_rectangle((cx-head/2,sy,cx+head/2,sy+head),max(2,head*.2),fill=(233,212,182,255))
  ty=sy+head+2;d.rounded_rectangle((cx-unit*.29,ty,cx+unit*.29,ty+unit*.43),4,fill=(77,105,135,255))
  ly=ty+unit*.43;d.rounded_rectangle((cx-unit*.24,ly,cx-2,ly+unit*.44),2,fill=(48,72,96,255));d.rounded_rectangle((cx+2,ly,cx+unit*.24,ly+unit*.44),2,fill=(48,72,96,255))
  if h>95:d.text((x+6,y+h-17),'Prévia 3D ilustrativa',font=font(9),fill=(45,69,78,255))
 elif n.get('image'):
  cx,cy=x+w/2,y+h/2;s=min(w,h)*.72;points=[(-.25,-.4),(-.5,-.2),(-.34,0),(-.25,-.08),(-.25,.45),(.25,.45),(.25,-.08),(.34,0),(.5,-.2),(.25,-.4),(.12,-.28),(-.12,-.28)]
  d.polygon([(cx+a*s,cy+b*s)for a,b in points],fill=(137,166,170,255),outline=(84,112,119,255))
 if n.get('text')or n.get('placeholder'):text(d,n)
 if n.get('rotation'):
  l,t,r,b=map(int,[max(0,x),max(0,y),min(canvas.width,x+w),min(canvas.height,y+h)])
  if r>l and b>t:
   part=layer.crop((l,t,r,b)).rotate(-n['rotation'],resample=Image.Resampling.BICUBIC,expand=False);layer.paste(part,(l,t))
 for c in sorted(n.get('children',[]),key=lambda v:v.get('z',1)):draw_node(layer,c)
 if n.get('clip'):
  cropped=Image.new('RGBA',canvas.size);l,t,r,b=map(int,[max(0,x),max(0,y),min(canvas.width,x+w),min(canvas.height,y+h)])
  if r>l and b>t:cropped.paste(layer.crop((l,t,r,b)),(l,t));canvas.alpha_composite(cropped)
 else:canvas.alpha_composite(layer)
for p in sorted(FOLDER.glob('*.json')):
 data=json.loads(p.read_text());im=Image.new('RGBA',(data['width'],data['height']),(237,243,244,255))
 for n in sorted(data['nodes'],key=lambda v:v.get('z',1)):draw_node(im,n)
 d=ImageDraw.Draw(im)
 for x,label in[(12,'▣'),(53,'☰'),(94,'▤')]:d.rounded_rectangle((x,8,x+34,42),15,fill=(36,52,63,255));d.text((x+8,14),label,font=font(16),fill='white')
 im.convert('RGB').save(p.with_suffix('.png'))
for screen in ['desktop','phone','landscape']:
 im=Image.open(FOLDER/('sponsor_'+screen+'.png')).convert('RGB')
 sheet=Image.new('RGB',(im.width,im.height+36),'#edf3f4');sheet.paste(im,(0,0));d=ImageDraw.Draw(sheet)
 d.text((8,im.height+9),'V73 · layout simulado · mídia ilustrativa · não é captura Roblox',font=font(10),fill='#24343f')
 sheet.save(HERE/('patrocinar_'+screen+'.jpg'),quality=92)
print('3 layouts simulados renderizados; mídia ilustrativa, sem renderização nativa do Roblox.')
