"""Approximate actual Roblox GUI geometry; no native rendering."""
from test_support import *
import math
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

out=HERE/'layout_previews';out.mkdir(exist_ok=True);reviews=[]
SHOP=UI+DATA+PREVIEW+COMMUNITY+r"""
U.Root.Visible=true;U.ShowPreview();local Cart=Modules['09C4_OUTFIT_LIBRARY'];Cart.Init({U=U,A=A,S=S,pl=pl,toast=function()end,call=function()end})
local pages={IsFinished=true};function pages:GetCurrentPage()local o={};for i=1,30 do o[i]={Id=i,Name='Item do catálogo '..i,AssetType='Shirt',ItemType='Asset',Price=1234}end;return o end
function Services.AvatarEditorService:SearchCatalogAsync()return pages end
local Catalog=loadModule(CATALOG_SOURCE,'Catalog').Init({U=U,A=A,S=S,pl=pl,toast=function()end});Catalog.Search();flush();SCENE=U.Gui
""".replace('CATALOG_SOURCE',q(src('09C2_SHOP_CATALOG')))
LOOKS=module('09C1_SHOP_LOOKS')+r"""
U.SetWide(true);for _,o in ipairs({U.Grid,U.Status,U.More,U.Groups,U.SubToggle,U.Query,U.SearchGo,U.Filter,U.Sort})do o.Visible=false end
U.PageTitle.Text='Meus looks';U.PageTitle.Visible=true;U.LooksArea.Visible=true
local records={};for i=1,30 do records[i]={id=tostring(i),name='Look salvo '..i,rig='R15',body=A.Copy(S.Current)}end
Modules['09C1_SHOP_LOOKS'].Init({U=U,A=A,S=S,toast=function()end,buyBody=function()end,call=function(a)if a=='List'then return{skins=records,persistent=true}end end}).Saved();flush()
"""
DETAIL=r"""
U.SetWide(true);for _,o in ipairs({U.Grid,U.Status,U.More,U.Groups,U.SubToggle,U.Query,U.SearchGo,U.Filter,U.Sort})do o.Visible=false end
U.PageTitle.Text='Comunidade';U.CommunityArea.Visible=true
Modules['09C8_COMMUNITY_DETAILS'].Init({U=U,A=A,S=S,toast=function()end,buyBody=function()end,call=function()end}).Show({id='roblox:333',source='Roblox',publisher='CAETANOYX',sourceUsername='User333',owner=333,name='Avatar de @User333',body=A.Copy(S.Current),rig='R15'});flush()
"""
SETTINGS=THEME+module('07G2_LOCAL_WORLDS')+module('07G1_HUB_SETTINGS')+r"""
local gui=Instance.new('ScreenGui');gui.Name='SettingsPreview';gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;gui.Parent=pg
local root=Instance.new('Frame');root.Size=UDim2.fromScale(1,1);root.Parent=gui
local c=Modules['07G1_HUB_SETTINGS'].Build(root,pg,function()end,function()end);c.Panel.Visible=true;c.Layout();SCENE=gui
"""
PHOTO=THEME+DATA+module('07P3_POSE_EDITOR')+module('07P5_POSE_CANVAS')+module('07P4_STUDIO_UI')+r"""
local U=Modules['07P4_STUDIO_UI'].Build(pl);U.Root.Visible=true;U.Status.Text='Toque e arraste o manequim.';U.Popup.Visible=true;U.PoseMode=true;U.PoseFooter.Visible=true;U.PopupTitle.Text='Editar pose'
local desc=A.Unpack(S.Current);local model=Services.Players:CreateHumanoidModelFromDescriptionAsync(desc,Enum.HumanoidRigType.R15);desc:Destroy();local pose=Modules['07P3_POSE_EDITOR'].Bind(model);pose.Begin()
U.PoseEditor=Modules['07P5_POSE_CANVAS'].Build(U.Popup,pose,function()end);U.Layout();flush();SCENE=U.Gui
"""
FEED=r"""
U.SetWide(true);for _,o in ipairs({U.Grid,U.Status,U.More,U.Groups,U.SubToggle,U.Query,U.SearchGo,U.Filter,U.Sort})do o.Visible=false end
U.PageTitle.Text='Comunidade';U.CommunityArea.Visible=true
local f=Modules['09C7_COMMUNITY_FEED'].Init({U=U,A=A,S=S,toast=function()end,show=function()end,call=function(a,args)
 local records={};for i=1,50 do local id=args.page*50+i;records[i]={id='roblox:'..id,name='Avatar de @User'..id,owner=id,source='Roblox',sourceUsername='User'..id,publisher='CAETANOYX',thumbnail='rbxthumb://type=Avatar&id='..id..'&w=420&h=420'}end
 return{items=records}
end});f.Open();flush()
"""
for w,h,left,right,top,bottom in[(1920,1080,0,0,58,0),(768,432,0,0,58,0),(800,360,0,0,58,0),(844,390,44,44,58,22),(360,640,0,0,58,0)]:
 for name,scene in [('catalog',SHOP),('looks',SHOP+LOOKS),('look_selected',SHOP+LOOKS+'U.SavedPreviewToggle.Activated:Fire();flush()'),('community',SHOP+FEED),('community_detail',SHOP+DETAIL),('settings',SETTINGS),('worlds',SETTINGS+"named(c.Panel,'ChangeWorld').Activated:Fire()"),('photo_pose',PHOTO)]:
  l=Lua()
  try:raw=l.run(MOCK+f'\nSCREEN_W,SCREEN_H,CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM={w},{h},{left},{right},{top},{bottom}\n'+scene+'\n'+SNAP)
  finally:l.close()
  canvas=Image.new('RGBA',(w,h),(95,105,120,255));clipped=[];drawnode(canvas,json.loads(raw));canvas.convert('RGB').save(out/f'{name}_{w}.png')
  reviews.append(dict(scene=name,viewport=[w,h],vertical_text_overflows=clipped));print(name,w,'text review',clipped[:8])
HERE.joinpath('layout_review.json').write_text(json.dumps(dict(method='Approximate actual GUI rectangles; DejaVu substitutes, placeholder viewports and no GPU/physics/native bars',reviews=reviews),ensure_ascii=False,indent=2)+'\n')
