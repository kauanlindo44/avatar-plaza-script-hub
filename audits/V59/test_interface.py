from test_support import *
UX=THEME+module('09I0_ASSISTANT_CONFIG')+module('09I4_ASSISTANT_UI')
case('retry_close_header_and_all_tabs_preserve_safe_touch_targets',UX+r'''
local ai=Modules['09I4_ASSISTANT_UI'].Build(pl);ai.Root.Visible=true
for _,size in ipairs({{320,568,0,0,0},{390,844,0,0,34},{568,320,0,0,0},{667,375,0,0,0},{851,392,44,44,21},{1920,1080,0,0,0}})do
 SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=table.unpack(size);CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM,DEVICE_TOP=size[3],size[4],58,120,0
 for _,tab in ipairs({'Conversa','Looks','Salvos','Perfil'})do for _,available in ipairs({true,false})do
  ai.Select(tab);ai.Health('Pro',available,false)
  for _,o in ipairs({ai.Body,ai.Close,ai.Menu,ai.Plan,ai.Connection,ai.Make,ai.Help,ai.Composer,ai.Notice})do if o.Visible then inside(o,ai.Root)end end
  for _,o in ipairs({ai.Close,ai.Menu,ai.Connection,ai.Make,ai.Help})do if o.Visible then assert(o.AbsoluteSize.X>=44 and o.AbsoluteSize.Y>=44,o.Name)end end
  assert(not intersects(ai.Connection,ai.Close),'reload over X at '..SCREEN_W..' '..tab)
  for _,pair in ipairs({{ai.Menu,ai.Title},{ai.Title,ai.Close},{ai.Title,ai.Plan},{ai.Title,ai.Connection},{ai.Make,ai.Help},{ai.Make,ai.Close},{ai.Help,ai.Close},{ai.Make,ai.Connection},{ai.Help,ai.Connection},{ai.Body,ai.Connection},{ai.Body,ai.Make},{ai.Body,ai.Help},{ai.Connection,ai.Notice}})do
   if pair[1].Visible and pair[2].Visible then assert(not intersects(pair[1],pair[2]),pair[1].Name..' overlaps '..pair[2].Name..' at '..SCREEN_W..' '..tab)end
  end
 end end
end
return 'six safe sizes x four tabs x two connection states; retry never covers close/heading/actions/body/notice; narrow non-chat tabs reserve a retry row'
''')
case('user_messages_keep_right_alignment_after_new_conversation',UX+r'''
local ai=Modules['09I4_ASSISTANT_UI'].Build(pl)
for _,size in ipairs({{320,568},{851,392},{1920,1080}})do
 SCREEN_W,SCREEN_H=size[1],size[2];ai.Select('Conversa');ai.ClearConversation()
 local user=ai.Add('Create an emo avatar look',true);local answer=ai.Add('Style emo. Choose black.',false);flush()
 assert(user.Parent.Name=='YourMessageRow'and answer.Parent.Name=='AIResponseRow')
 assert(user.AnchorPoint.X==1 and user.Position.X.Scale==1 and user.Size.X.Scale==.78)
 assert(answer.AnchorPoint.X==0 and answer.Position.X.Scale==0)
 assert(math.abs(user.AbsolutePosition.X+user.AbsoluteSize.X-user.Parent.AbsolutePosition.X-user.Parent.AbsoluteSize.X)<1)
 assert(user.AbsolutePosition.X>answer.AbsolutePosition.X)
 local declared=false;for _,o in ipairs(answer:GetChildren())do if o:IsA('TextLabel')and o.Text:find('inglês',1,true)then declared=true end end;assert(declared)
 ai.ClearConversation();assert(ai.Welcome.Visible and not ai.Progress.Visible and not ai.Chat:FindFirstChild('YourMessageRow'))
end
return 'actual message row fills list width, user bubble right edge stays fixed, AI remains left, compatibility language is labeled and reset restores welcome'
''')
case('keyboard_keeps_send_and_reload_inside_visible_area',UX+r'''
local ai=Modules['09I4_ASSISTANT_UI'].Build(pl);ai.Root.Visible=true
SCREEN_W,SCREEN_H=390,844;CORE_TOP=58;DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM=0,0,0
Services.UserInputService.OnScreenKeyboardVisible=true;Services.UserInputService.OnScreenKeyboardPosition=Vector2.new(0,340)
ai.Select('Conversa');ai.Health('Normal',false,false)
assert(not ai.Make.Visible and not ai.Help.Visible and ai.Composer.Visible and ai.Connection.Visible)
for _,o in ipairs({ai.Send,ai.Connection,ai.Body,ai.Composer,ai.Notice})do assert(o.AbsolutePosition.Y+o.AbsoluteSize.Y<=336)end
assert(not intersects(ai.Connection,ai.Body)and not intersects(ai.Connection,ai.Composer))
Services.UserInputService.OnScreenKeyboardVisible=false;ai.Layout();assert(ai.Make.Visible and ai.Help.Visible)
return 'typing hides only creation-mode controls, leaving send and recovery above keyboard; mode controls return after dismissal'
''')
case('real_client_discloses_english_and_recovers_after_native_error',THEME+DATA+PREVIEW+module('09I0_ASSISTANT_CONFIG')+module('09I4_ASSISTANT_UI')+module('09I5_ASSISTANT_QUESTIONNAIRE')+module('09I6_ASSISTANT_RESULTS')+module('09I7_ASSISTANT_PROFILE')+r'''
local folder=Instance.new('Folder');folder.Name='ACP_AssistantRemotes';folder.Parent=rep
local rpc=Instance.new('RemoteFunction');rpc.Name='Request';rpc.Parent=folder
local event=Instance.new('RemoteEvent');event.Name='Progress';event.Parent=folder
local captured;local account={plan='Normal',available=true,checking=false,language='en',diagnostic='ASSISTENTE OK',count=1,daily=10,owner=123,expires=0,prefs={theme='Halloween',motion=true},collections={},members={},invites={}}
function rpc:InvokeServer(action,d)
 if action=='status'then return{ok=true,data=account}elseif action=='ask'then captured=d;return{ok=true,data={request=d.request}}elseif action=='ad'then return{ok=true,data={hidden=true}}end;return{ok=true,data=true}
end
local build=Modules['09I4_ASSISTANT_UI'].Build;local u;Modules['09I4_ASSISTANT_UI'].Build=function(...)u=build(...);return u end
'''+src('09I_ASSISTANT_CLIENT')+r'''
pg:SetAttribute('ACP_OpenAINonce',1);flush();assert(u.Root.Visible and u.Plan.Text:find('verificada',1,true)and u.Notice.Text:find('inglês',1,true))
u.Suggestions[1].Activated:Fire();assert(u.Input.Text=='Create an emo avatar look')
u.Help.Activated:Fire();u.Input.Text='Help with Photo Mode';u.Send.Activated:Fire();flush();assert(captured)
account.available=false;account.connectionError='HTTP 400';account.diagnostic='REFERÊNCIA OK | ASSISTENTE HTTP 400'
event.OnClientEvent:Fire({kind='error',request=captured.request,available=false,error='IA Roblox: HTTP 400'});flush()
assert(not u.Available and u.Connection.Visible and u.Send.Active and not u.Progress.Visible)
assert(u.Notice.Text:find('REFERÊNCIA OK',1,true))
account.available=true;account.connectionError=nil;u.Connection.Activated:Fire();flush();assert(u.Available and not u.Connection.Visible)
u.Input.Text='Help';u.Send.Activated:Fire();flush()
event.OnClientEvent:Fire({kind='result',request=captured.request,data={answer='A native English answer.',language='en',plan='Normal',count=0,requested=1,looks={}}});flush()
local shown=false;for _,o in ipairs(u.Chat:GetDescendants())do if o:IsA('TextLabel')and o.Text=='A native English answer.'then shown=true end end;assert(shown)
u.NewChat.Activated:Fire();assert(u.Welcome.Visible and u.Tab=='Conversa')
return 'actual LocalScript shows true connection failure and diagnostic, sends English suggestion, reload recovers, native response stays unchanged and new chat returns to welcome'
''')
HERE.joinpath('interface_results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
