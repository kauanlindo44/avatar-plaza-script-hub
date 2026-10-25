from test_support import *
case('v77_thirteen_low_poly_worlds',THEME+module('07G11_REFERENCE_WORLDS')+r'''
local ref=Modules['07G11_REFERENCE_WORLDS'];local total=0
for _,id in ipairs({'CLOUD','ICE','LAVA','PYRAMID','ANIME','CANDY','GRAVEYARD','CRYSTAL','CITY','GEARS','DIGITAL','LUMINOUS','PORTAL'})do
 local list={};local n=ref.Build(id,Vector3.zero,function(name,size,pos,color,shape,mat)local p=Instance.new(shape=='Wedge'and'WedgePart'or'Part');p.Name=name;p.Size=size;p.Position=pos;p.Color=color;p.Material=mat;list[#list+1]=p;return p end,function()return true end)
 assert(n==#list and n>0 and n<=96);for _,p in ipairs(list)do assert(p.CastShadow==false);local near=math.sqrt(p.Position.X^2+p.Position.Z^2);assert(near-math.max(p.Size.X,p.Size.Z)/2>=92,'center blocked '..id..' '..p.Name)end;total=total+n
 assert(ref.Build(id,Vector3.zero,function()error('cancelled build created part')end,function()return false end)==0)
end
return total..' primitive parts across 13 worlds; <=96 each, center free, cancellation respected'
''')
case('v77_editorial_catalog_is_not_fake_assets',THEME+module('09I27_STYLE_CATALOG')+r'''
local catalog=Modules['09I27_STYLE_CATALOG'];local count=0
for _,style in ipairs(Modules['09I8_AVATAR_STYLES'].Styles)do local rows=catalog.Concepts(style.id);assert(#rows==20);local seen={}
 for _,r in ipairs(rows)do assert(r.referenceOnly and r.Id==nil and not seen[r.key]);seen[r.key]=true;count=count+1 end end
assert(#catalog.Concepts('missing')==0)
assert(catalog.Score({Name='formal classic suit'},'formal')>catalog.Score({Name='cyber robot'},'formal'))
return count..' local editorial concepts; no invented asset IDs or claim of verified looks'
''')
case('v77_assistant_bounded_window',THEME+module('09I4_ASSISTANT_UI')+r'''
local u=Modules['09I4_ASSISTANT_UI'].Build(pl);u.Root.Visible=true
for _,size in ipairs({{390,844},{568,320},{851,392},{1066,480},{1280,720}})do SCREEN_W,SCREEN_H=size[1],size[2];CORE_TOP=58;u.Layout();inside(u.Window,u.Gui);inside(u.Composer,u.Window);inside(u.Close,u.Window)
 assert(u.Root.BackgroundTransparency==1);if SCREEN_W>=1000 then assert(u.Window.AbsolutePosition.X>SCREEN_W/2)end
end
return 'assistant leaves the avatar center clear on desktop; composer and closing control stay inside the window'
''')
HERE.joinpath('worlds_ai_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
