from test_support import *
UX=THEME+DATA+PREVIEW+module('09I0_ASSISTANT_CONFIG')+module('09I4_ASSISTANT_UI')+module('09I5_ASSISTANT_QUESTIONNAIRE')+module('09I6_ASSISTANT_RESULTS')+module('07M1_MUSIC_UI')+module('07P4_STUDIO_UI')
case('responsive_conversation_music_photo_controls_and_inline_choices',UX+r'''
local ai=Modules['09I4_ASSISTANT_UI'].Build(pl)
local q=Modules['09I5_ASSISTANT_QUESTIONNAIRE'].Build(ai,function()end)
local results=Modules['09I6_ASSISTANT_RESULTS'].Build(ai,function()return true end,function()end);ai.OnLayout=results.Layout
local music=Modules['07M1_MUSIC_UI'].Build(pl);local photo=Modules['07P4_STUDIO_UI'].Build(pl)
for _,size in ipairs({{320,568,0,0,0},{390,844,0,0,34},{568,320,0,0,0},{667,375,0,0,0},{851,392,44,44,21},{1920,1080,0,0,0}})do
 SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(size);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM,DEVICE_TOP=size[3],size[4],58,120,0
 ai.Root.Visible=true;ai.Select('Conversa');ai.Health('Pro',false,false);q.Open('Pro')
 for _,o in ipairs({ai.Body,ai.Composer,ai.Make,ai.Help,ai.Connection,ai.Notice})do inside(o,ai.Root)end
 for _,o in ipairs({ai.Close,ai.Send,ai.Make,ai.Help,ai.Connection,q.Close,q.Confirm,q.Format,q.Keep,q.Count,q.Budget,q.Scope,q.Tool,q.Color,q.Piece,q.Body})do
  inside(o,o.Parent);assert(o.AbsoluteSize.X>=44 and o.AbsoluteSize.Y>=44,o.Name..' small touch target at '..size[1]..'x'..size[2])
 end
 assert(not intersects(ai.Make,ai.Help)and not intersects(ai.Help,ai.Connection))
 assert(q.Shade.Parent==ai.Chat and not intersects(q.Confirm,q.Fields),'questionnaire must be an inline card, not a fullscreen overlay')
 ai.Menu.Activated:Fire();inside(ai.Tabs,ai.Root);for _,b in pairs(ai.TabButtons)do inside(b,ai.Tabs)end
 music.Root.Visible=true;photo.Root.Visible=true
 for _,saved in ipairs({false,true})do
  music.SavedOpen=saved;music.Layout();inside(music.Root,music.Gui)
  for _,o in ipairs({music.Close,music.Load,music.Play,music.Reload,music.Keep,music.Minus,music.Volume,music.Plus,music.Favorites})do inside(o,music.Root);assert(o.AbsoluteSize.X>=44 and o.AbsoluteSize.Y>=44)end
  assert(not intersects(music.Favorites,music.Close));assert(not intersects(music.List,music.Volume)or not music.List.Visible)
 end
 for _,open in ipairs({false,true})do
  photo.Popup.Visible=open;photo.Layout()
  for _,o in ipairs({photo.Close,photo.DragMode,photo.PopupClose,photo.PoseConfirm,photo.PoseCancel,photo.PoseReset})do inside(o,o.Parent);assert(o.AbsoluteSize.X>=44 and o.AbsoluteSize.Y>=44)end
  inside(photo.Popup,photo.Root);assert(not intersects(photo.DragMode,photo.Buttons.Hide));assert(not intersects(photo.Close,photo.DragMode))
 end
end
return 'six sizes/cutouts: safe 44px controls, compact music and inline creation form; retry and camera/avatar controls do not overlap'
''')
case('inline_results_and_detail_item_actions_stay_usable',UX+r'''
local ai=Modules['09I4_ASSISTANT_UI'].Build(pl);ai.Root.Visible=true
local calls={};local r=Modules['09I6_ASSISTANT_RESULTS'].Build(ai,function(a,d)calls[#calls+1]={a=a,d=d};return true end,function()end);ai.OnLayout=r.Layout
local look={name='Emo',folder='Favoritos',body=A.Copy(S.Current),rig='R15',total=35,items={}}
r.Accept({plan='Pro',looks={deep(look),deep(look),deep(look),deep(look),deep(look)}});r.SetSaved({deep(look)});flush()
assert(r.Inline.Parent==ai.Chat and #r.InlineViews==5 and ai.Tab=='Conversa')
for _,size in ipairs({{320,568},{390,844},{568,320},{667,375},{851,392},{1920,1080}})do
 SCREEN_W,SCREEN_H=size[1],size[2];ai.Select('Looks');ai.Layout()
 for _,v in ipairs({r.Live,r.Saved})do
  for _,o in ipairs({v.Stage,v.Items,v.Actions,v.Pager})do inside(o,o.Parent)end
  for _,o in ipairs({v.Apply,v.Save,v.Cart,v.Compare,v.Prev,v.Next})do inside(o,o.Parent);assert(o.AbsoluteSize.X>=44 and o.AbsoluteSize.Y>=44)end
  assert(not intersects(v.Items,v.Actions));if v.Folder.Visible then assert(not intersects(v.Folder,v.Items))end
 end
end
r.Resume();flush();local before=#A.Entries(r.Rows[1].body);local item=r.Live.Items:GetChildren()[2];local remove=item:FindFirstChildWhichIsA('TextButton')
remove.Activated:Fire();assert(#A.Entries(r.Rows[1].body)==before-1)
r.Live.Save.Activated:Fire();flush();assert(calls[#calls].d.body and #A.Entries(calls[#calls].d.body)==before-1)
r.Accept({plan='Pro',looks={}});assert(#r.Rows==5,'a help answer must not erase generated looks')
return 'five inline results keep latest indices consistent; details retain items/X/apply/save/cart; a help-only answer preserves previous looks'
''')
case('photo_all_context_choices_fit_without_scroll',THEME+module('07P4_STUDIO_UI')+r'''
local u=Modules['07P4_STUDIO_UI'].Build(pl);u.Root.Visible=true;u.Popup.Visible=true
for _,size in ipairs({{568,320},{851,392},{390,844},{320,568}})do
 SCREEN_W,SCREEN_H=size[1],size[2];CORE_TOP=58;DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=0,0,0
 for _,count in ipairs({4,6,7,10})do
  u.Clear();for i=1,count do u.Option('Escolha '..i,i)end;u.Layout()
  for _,b in ipairs(u.Content:GetChildren())do if b:IsA('GuiButton')then inside(b,u.Content);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44,'choice '..count..' at '..size[1]..'x'..size[2])end end
  assert(not u.DragMode.Visible,'drag selector cannot overlay the open contextual panel')
 end
end
return 'all 4/6/7/10 photo menu choices remain visible with 44px targets and no scrolling on narrow landscape and portrait'
''')
HERE.joinpath('layout_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')

