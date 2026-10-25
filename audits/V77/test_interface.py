from test_support import *
SIZES="{{320,568,0,0,0},{390,844,0,0,34},{568,320,0,0,0},{667,375,0,0,0},{851,392,44,44,21},{1920,1080,0,0,0}}"
case('assistant_full_safe_chat_and_form_fit_six_geometries',THEME+module('09I0_ASSISTANT_CONFIG')+module('09I4_ASSISTANT_UI')+module('09I5_ASSISTANT_QUESTIONNAIRE')+r'''
local u=Modules['09I4_ASSISTANT_UI'].Build(pl);u.Root.Visible=true;local q=Modules['09I5_ASSISTANT_QUESTIONNAIRE'].Build(u,function()end)
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;u.Health('Normal',true,false);u.Layout()
 for _,b in ipairs({u.Close,u.Menu,u.Send,u.Input})do inside(b,u.Root);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44,b.Name)end
 assert((not u.Make.Visible or not intersects(u.Input,u.Make))and(not u.Help.Visible or not intersects(u.Input,u.Help))and not intersects(u.Close,u.Sponsor));inside(u.Composer,u.Window)
 for _,plan in ipairs({'Normal','Pro'})do q.Open(plan);for step=1,3 do q.Step=step;q.Layout();inside(q.Close,q.Root);inside(q.Confirm,q.Root)
  local controls={q.Style,q.BudgetField,q.Format,q.Count,q.Scope,q.Color,q.Exclude,q.More}
  for _,b in ipairs(controls)do if b.Visible then assert(b.AbsoluteSize.Y>=44 and b.AbsoluteSize.X>=44);assert(not intersects(q.Fields,q.Confirm),'confirm overlap '..b.Name)end end;end
  q.CloseGuide();assert(u.Composer.Visible)
 end
end
return 'conversation width uses the safe surface; guided form choices, close and confirmation remain visible and clickable on six portrait/landscape/desktop sizes'
''')
case('chat_reset_keeps_form_alive_and_disposes_inline_previews',THEME+DATA+PREVIEW+module('09I0_ASSISTANT_CONFIG')+module('09I4_ASSISTANT_UI')+module('09I5_ASSISTANT_QUESTIONNAIRE')+module('09I6_ASSISTANT_RESULTS')+r'''
local u=Modules['09I4_ASSISTANT_UI'].Build(pl);u.Root.Visible=true
local q=Modules['09I5_ASSISTANT_QUESTIONNAIRE'].Build(u,function()end);local r=Modules['09I6_ASSISTANT_RESULTS'].Build(u,function()end,function()end)
for i=1,3 do q.Open('Normal');q.CloseGuide();u.Add('message',true);r.Accept({looks={{name='emo',total=5,body=A.Copy(S.Current),rig='R15'}},plan='Normal'});flush()
 r.NewConversation();u.ClearConversation();assert(q.Shade.Parent==u.Root and #r.InlineViews==0 and r.Inline==nil);q.Open('Normal');assert(q.Shade.Visible);q.CloseGuide()end
return 'three full create/result/reset cycles preserve the actual form instance and remove model controllers/inline view references before destroying chat rows'
''')
case('saved_looks_reload_is_visible_and_pending_keeps_current_cards',UI+DATA+PREVIEW+COMMUNITY+module('09C1_SHOP_LOOKS')+r'''
U.Root.Visible=true;U.SetWide(true);U.LooksArea.Visible=true;local pending=false;local calls=0;local message
local ctl=Modules['09C1_SHOP_LOOKS'].Init({U=U,A=A,S=S,call=function(a)if a=='List'then calls=calls+1;return pending and{loading=true,skins={}}or{skins={{id='saved',name='My outfit',body=A.Copy(S.Current),rig='R15'}},persistent=true}end end,toast=function(v)message=v end,buyBody=function()end})
ctl.Saved();flush();assert(named(U.SavedGrid,'SavedLook_saved')~=nil);pending=true;ctl.Saved();flush();assert(named(U.SavedGrid,'SavedLook_saved')~=nil and message:find('continuam',1,true))
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;U.Layout();flush();local b=named(U.SavedGridPanel,'ReloadSavedLooks');inside(b,U.SavedGridPanel);assert(b.AbsoluteSize.X==44 and b.AbsoluteSize.Y==44);assert(not intersects(b,U.LookSearch))end
return 'a pending read preserves the existing saved card; its independent reload button fits six safe layouts and does not overlap search'
''')
case('compact_player_popup_has_immediate_preview_four_actions_and_safe_close',THEME+DATA+PREVIEW+module('09C9_PLAYER_INSPECT')+r'''
local D=Modules['07UI_DESIGN_SYSTEM'];local root=D.New('Frame',{Visible=false},pg);local other=makePlayer(456);other.Character=pl.Character;other.DisplayName='Other';other.Name='Other'
function Services.Players:GetPlayers()return{pl,other}end
local clones=0;other.Character.Archivable=false;function other.Character:Clone()clones=clones+1;return Services.Players:CreateHumanoidModelFromDescriptionAsync(HUM:GetAppliedDescription(),Enum.HumanoidRigType.R15)end
local calls={};local ctl=Modules['09C9_PLAYER_INSPECT'].Init({U={Root=root},A=A,S=S,call=function(a,d)calls[#calls+1]=a;if a=='InspectAvatar'or a=='InspectUse'then return{body=A.Copy(S.Current),rig='R15',allowCopy=true,likes=3}end;return{likes=4}end,toast=function()end,open=function()end,show=function()end})
ctl.Show(other);flush();assert(Preview.Get(ctl.Preview).Model and #ctl.Buttons==4 and clones==1 and other.Character.Archivable==false)
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;Services.GuiService:GetPropertyChangedSignal('TopbarInset'):Fire();flush()
 inside(ctl.Panel,ctl.Panel.Parent);assert(ctl.Panel.AbsoluteSize.X<=550 and ctl.Panel.AbsoluteSize.Y<=276)
 for _,b in ipairs(ctl.Buttons)do inside(b,ctl.Panel);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y==44)end;inside(named(ctl.Panel,'ClosePlayerCard'),ctl.Panel)
end
ctl.Buttons[2].Activated:Fire();flush();assert(ctl.Buttons[2].Text=='♥ 4');ctl.Close();assert(not ctl.Panel.Visible and not Preview.Get(ctl.Preview))
return 'the actual visible character is cloned immediately into a bounded small popup with four actions, a working like counter and a reachable close button'
''')
case('world_finish_uses_native_materials_bounded_geometry_and_restores_sky',THEME+DATA+module('07G6_WORLD_DETAILS')+module('07G4_WORLD_SCENERY')+module('07G2_LOCAL_WORLDS')+r'''
local world=Instance.new('Folder');world.Name='PracaAvatar_V2';world.Parent=workspace;local lighting=Services.Lighting;lighting.ClockTime=13;lighting.EnvironmentDiffuseScale=.4;lighting.EnvironmentSpecularScale=.2
local m=Modules['07G2_LOCAL_WORLDS'];local stats={}
for _,id in ipairs({'ORIGINAL','ANIME','FOREST','COAST','HALLOWEEN','CLOUD'})do assert(m.Apply(id));flush();local folder=workspace.ACP_LocalWorldVisuals;assert(folder:GetAttribute('Ready'));local n=folder:GetAttribute('SceneryParts');assert(n>=1 and n<=300,id..':'..tostring(n));stats[id]=n
 local shadows,lights=0,0;for _,p in ipairs(folder:GetDescendants())do if p:IsA('BasePart')then assert(not p.CanCollide and not p.CanQuery);if p.CastShadow then shadows=shadows+1 end end;if p:IsA('PointLight')then lights=lights+1 end end;assert(shadows<=70 and lights<=8)
 assert(named(lighting,'ACP_Sky_'..id));
end
m.Destroy();assert(lighting.ClockTime==13 and lighting.EnvironmentDiffuseScale==.4 and lighting.EnvironmentSpecularScale==.2)
return 'six themes use bounded low detail scenery, native materials and limited lights; restore lighting when closed'
''')
TRUCO=THEME+DATA+module('07K6_CARD_CATALOG')+module('07K7_CARD_STYLES')+module('07K0_TRUCO_RULES')+module('07K15_TRUCO_TABLE')+module('07H8_PLAY_SESSION')+module('07K5_TRUCO_UI')
case('truco_cards_teams_timeline_and_actions_fit_without_overlay',TRUCO+r'''
local d=Modules['07UI_DESIGN_SYSTEM'];local g=d.New('ScreenGui',{IgnoreGuiInset=true},pg);local u=Modules['07K5_TRUCO_UI'].Build(g,function()end)
local v={seat=1,variant='Paulista',score={3,2},phase='play',turn=1,hand={{rank='3',suit='S'},{rank='A',suit='H'},{rank='K',suit='D'}},players={{uid=123,name='Me'},{uid=2,name='Rival'},{uid=3,name='Partner'},{uid=4,name='Other'}},tableCards={},tricks={},lastTrick={},counts={3,3,3,3},value=1,nextRaise=3,handNumber=1,remaining=30,dealer=4}
u.Update(v,{equipped='Classic'})
for _,sz in ipairs('''+SIZES+r''')do SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(sz);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM=sz[3],sz[4],58,0;u.Layout()
 for _,b in ipairs({u.Close,u.Raise,u.Cover,u.Run,u.Shouts})do inside(b,u.Root);assert(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44)end
 inside(u.Hand,u.TableArea);assert(not intersects(u.TableArea,u.Controls));assert(not intersects(u.Status,u.TrickProgress))
end
v.hand={v.hand[1],v.hand[2]};v.tricks={1};v.lastTrick={{seat=1,card={rank='3',suit='S'}}};u.Update(v,{equipped='Classic'});assert(u.TrickDots[1].Text=='♥'and u.Moment.Visible)
return 'private hand, smaller table cards, explicit team score, real vaza timeline and bottom controls fit six devices, with nonblocking feedback for a won vaza'
''')
case('catalog_keeps_equipped_strip_two_rows_and_readable_prices',UI+DATA+PREVIEW+module('09C4_OUTFIT_LIBRARY')+module('09C3_CATALOG_FILTERS')+module('09C2_SHOP_CATALOG')+r'''
local rows={};for i=1,35 do rows[i]=fixture60(500+i,'emo shirt '..i,'Shirt')end
function Services.AvatarEditorService:SearchCatalogAsync(p)assert(p.MinPrice==1);return{IsFinished=true,GetCurrentPage=function()return deep(rows)end}end
local ctl=Modules['09C2_SHOP_CATALOG'].Init({U=U,A=A,S=S,toast=function()end,call=function()return true end});U.Root.Visible=true;U.ShowPreview();ctl.Search();flush()
SCREEN_W,SCREEN_H,CORE_TOP=851,392,58;DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=44,44,21;CORE_LEFT,CORE_RIGHT=44,44;U.Layout();ctl.Resize();flush()
assert(U.ItemStrip.Visible and U.ItemStrip.AbsoluteSize.Y>=44);assert(U.GridLayout.FillDirectionMaxCells==5);assert(U.GridLayout.CellSize.Y.Offset*2<=U.Grid.AbsoluteSize.Y)
local slot=ctl.Pool[1];assert(slot.root.Visible and slot.price.Text:find('Robux',1,true));inside(slot.price,slot.root);assert(slot.image.AbsoluteSize.Y>slot.price.AbsoluteSize.Y)
return 'catalog retains the useful equipped-item strip, five landscape columns and two visible rows; artwork takes the card body and compact Robux labels stay inside'
''')
case('actual_ia_client_reopens_questionnaire_after_new_conversation',THEME+DATA+PREVIEW+module('09I0_ASSISTANT_CONFIG')+module('09I4_ASSISTANT_UI')+module('09I5_ASSISTANT_QUESTIONNAIRE')+module('09I6_ASSISTANT_RESULTS')+module('09I7_ASSISTANT_PROFILE')+r'''
local folder=Instance.new('Folder');folder.Name='ACP_AssistantRemotes';folder.Parent=rep
local rpc=Instance.new('RemoteFunction');rpc.Name='Request';rpc.Parent=folder
local event=Instance.new('RemoteEvent');event.Name='Progress';event.Parent=folder
local newChats=0;local asks=0
function rpc:InvokeServer(a,d)
 if a=='chat.list'then return{protocol=2,ok=true,data={items={}}}end
 if a=='chat.save'then return{protocol=2,ok=true,data={id=d.id,title=d.title}}end
 if a=='status'then return{protocol=2,ok=true,data={plan='Normal',available=true,count=1,collections={},prefs={},daily=5,remaining=5,used=0,expires=0,owner=123,members={},invites={},disclosure='test'}}end
 if a=='newchat'then newChats=newChats+1;return{protocol=2,ok=true,data=true}end
 if a=='ask'then asks=asks+1;task.defer(function()event.OnClientEvent:Fire({request=d.request,kind='result',data={answer='Ready',looks={{body=A.Copy(S.Current),rig='R15',name='emo',total=5}},plan='Normal',requested=1,count=1}})end);return{protocol=2,ok=true,data={request=d.request}}end
 return{protocol=2,ok=true,data={hidden=true}}
end
'''+src('09I_ASSISTANT_CLIENT')+r'''
flush();pg:SetAttribute('ACP_OpenAINonce',1);pg:GetAttributeChangedSignal('ACP_OpenAINonce'):Fire();flush()
local gui=pg.ACP_Assistant;local input=named(gui,'MessageComposer'):FindFirstChildOfClass('TextBox');local send=named(gui,'SendMessage');local form=named(gui,'LookQuestionnaire');local new=named(gui,'NewConversation')
for i=1,3 do
 input.Text='emo preto';send.Activated:Fire();assert(form.Visible and form.Parent)
 local confirm;for _,o in ipairs(form:GetChildren())do if o.Text=='Confirmar e criar'then confirm=o end end;assert(confirm);named(form,'RequestStep4').Activated:Fire();confirm.Activated:Fire();flush();assert(asks==i)
 new.Activated:Fire();flush();assert(form.Parent and newChats==i and not named(gui,'InlineLooks'))
end
return 'the real LocalScript sends three guided requests and resets between them; each new conversation preserves the reusable form and discards stale inline cards'
''')
case('repeated_truco_snapshot_preserves_collect_animation',TRUCO+r'''
local d=Modules['07UI_DESIGN_SYSTEM'];local parent=d.New('Frame',{Size=UDim2.fromOffset(780,230)},pg);local t=Modules['07K15_TRUCO_TABLE'].Build(parent);t.Root.Size=UDim2.fromScale(1,1)
local v={seat=1,players={{uid=123,name='Me'},{uid=2,name='Rival'},{uid=3,name='Partner'},{uid=4,name='Rival'}},counts={2,2,2,2},turn=1,phase='play',handNumber=1,tricks={1},tableCards={},lastTrick={{seat=1,card={rank='3',suit='S'}}},value=1}
t.Update(v,{equipped='Classic'});local generation=t.Generation;local card=t.Slots[1].card
for i=1,4 do t.Update(v,{equipped='Classic'});assert(t.Generation==generation and t.Slots[1].card==card)end
advance(1.7);advance(.5);assert(not next(t.Slots));assert(named(t.Discard,'CollectedCards'))
return 'identical server snapshots do not rebuild visible cards or cancel the vaza collection timer; the same cards are collected after their readable pause'
''')
HERE.joinpath('interface_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
