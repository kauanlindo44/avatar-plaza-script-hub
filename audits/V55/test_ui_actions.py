from test_support import *
RESULT=THEME+DATA+PREVIEW+module('09I0_ASSISTANT_CONFIG')+module('09I4_ASSISTANT_UI')+module('09I6_ASSISTANT_RESULTS')+module('09I7_ASSISTANT_PROFILE')
case('ai_generated_and_saved_looks_keep_visible_actions_on_mobile',RESULT+r'''
local u=Modules['09I4_ASSISTANT_UI'].Build(pl);u.Root.Visible=true;u.Select('Looks')
local calls={};local r=Modules['09I6_ASSISTANT_RESULTS'].Build(u,function(a,d)calls[#calls+1]={a=a,d=d};return true end,function()end)
u.OnLayout=r.Layout;local look={name='Emo',folder='Emo',body=A.Copy(S.Current),rig='R15',total=35,items={}}
r.Accept({plan='Pro',looks={deep(look),deep(look),deep(look),deep(look),deep(look)}});r.SetSaved({deep(look)});r.Resume();flush()
for _,size in ipairs({{320,568},{390,844},{568,320},{667,375},{851,392},{1920,1080}})do
 SCREEN_W,SCREEN_H=size[1],size[2];u.Layout();r.Layout(u.Body.AbsoluteSize.X,u.Body.AbsoluteSize.Y)
 for _,v in ipairs({r.Live,r.Saved})do
  for _,o in ipairs({v.Stage,v.Name,v.Price,v.Items,v.Actions,v.Pager})do inside(o,o.Parent)end
  for _,o in ipairs({v.Apply,v.Save,v.Cart,v.Compare,v.Prev,v.Next})do inside(o,o.Parent);assert(o.AbsoluteSize.Y>=44 and o.AbsoluteSize.X>=44)end
  assert(not intersects(v.Items,v.Actions),'items overlap actions at '..size[1]..'x'..size[2])
  if v.Folder.Visible then assert(not intersects(v.Folder,v.Items))end
 end
end
local item=r.Live.Items:GetChildren()[2];local remove=item and item:FindFirstChildWhichIsA('TextButton');local before=#A.Entries(r.Rows[1].body)
assert(remove);remove.Activated:Fire();assert(#A.Entries(r.Rows[1].body)==before-1)
r.Live.Save.Activated:Fire();flush();assert(calls[#calls].a=='save'and calls[#calls].d.body and #A.Entries(calls[#calls].d.body)==before-1)
r.Live.Apply.Activated:Fire();assert(#A.Entries(S.Current)==before-1)
return 'live and saved results in six sizes retain explicit actions/items; item X edits the chosen look; edited appearance is sent for saving and applying'
''')
case('salem_prints_real_face_identity_and_traditional_card_theme',THEME+module('07K6_CARD_CATALOG')+module('07K7_CARD_STYLES')+r'''
local styles=Modules['07K7_CARD_STYLES'];local c=Modules['07K6_CARD_CATALOG']
for key in pairs(c.Styles)do
 local face=styles.Render(pg,{rank='7',suit='H'},key,{Size=UDim2.fromOffset(90,128)});assert(named(face,'RankAndSuit').Text=='7\n♥');assert(face:GetAttribute('TraditionalPaperFace'))
 assert(named(face,'PipField'));assert(named(face,'SuitPip6'));assert(named(face,'OddSuitPip'))
 local back=styles.Render(pg,nil,key,{Size=UDim2.fromOffset(90,128)});assert(not named(back,'CardFace'))
end
local salem=styles.Render(pg,{rank='A',suit='S'},'Salem',{Size=UDim2.fromOffset(100,142)});assert(named(salem,'SalemPumpkin')and named(salem,'Suit'))
return 'all themes keep ranks, correct suits and traditional number pips; Salem has distinct autumn artwork on a paper face; backs disclose no card identity'
''')
HERE.joinpath('ui_action_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
