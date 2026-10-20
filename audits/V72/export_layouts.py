"""Export source-built GuiObject geometry from Lua doubles, not the Roblox renderer."""
from test_support import *
from pathlib import Path
HERE.joinpath('layouts').mkdir(exist_ok=True)
DUMP=r'''
local function str(s)return '"'..tostring(s):gsub('\\','\\\\'):gsub('"','\\"'):gsub('\n','\\n'):gsub('\r','\\r'):gsub('\t','\\t')..'"'end
local function json(v)
 local t=type(v);if t=='string'then return str(v)elseif t=='boolean'then return v and'true'or'false'elseif t=='number'then return v==v and tostring(v)or'0'elseif t~='table'then return'null'end
 local out={};if #v>0 then for _,x in ipairs(v)do out[#out+1]=json(x)end;return'['..table.concat(out,',')..']'end
 for k,x in pairs(v)do out[#out+1]=str(k)..':'..json(x)end;return'{'..table.concat(out,',')..'}'
end
local function color(v)if not v or not v.R then return nil end;return{math.floor(v.R*255+.5),math.floor(v.G*255+.5),math.floor(v.B*255+.5)}end
local classes={Frame=true,TextLabel=true,TextBox=true,TextButton=true,ImageLabel=true,ImageButton=true,ScrollingFrame=true,ViewportFrame=true}
local function dump(o)
 if o.Visible==false or not classes[o.ClassName]then return end
 -- Native AbsolutePosition is relative to the core-safe origin; exported canvas is full-screen.
 local p,z=o.AbsolutePosition,o.AbsoluteSize;local n={name=o.Name,class=o.ClassName,x=p.X+(CORE_LEFT or 0),y=p.Y+(CORE_TOP or 0),w=z.X,h=z.Y,z=o.ZIndex,opacity=1-(o.BackgroundTransparency or 0),bg=color(o.BackgroundColor3),clip=o.ClipsDescendants==true,rotation=o.Rotation or 0}
 local corner=o:FindFirstChildOfClass('UICorner');if corner then n.radius=corner.CornerRadius.Scale*math.min(z.X,z.Y)+corner.CornerRadius.Offset end
 local stroke=o:FindFirstChildOfClass('UIStroke');if stroke then n.stroke=color(stroke.Color);n.strokeOpacity=1-(stroke.Transparency or 0);n.strokeWidth=stroke.Thickness or 1 end
 if o:IsA('TextLabel')or o:IsA('TextButton')or o:IsA('TextBox')then n.text=o.Text;n.placeholder=o.PlaceholderText;n.font=o.TextSize or 14;n.ink=color(o.TextColor3);n.bold=tostring(o.Font):find('Bold')~=nil;n.textOpacity=1-(o.TextTransparency or 0);n.wrap=o.TextWrapped==true;n.align=tostring(o.TextXAlignment);n.valign=tostring(o.TextYAlignment);n.scaled=o.TextScaled==true end
 if o.ClassName=='ImageLabel'or o.ClassName=='ImageButton'then n.image=o.Image end
 n.children={};for _,child in ipairs(o:GetChildren())do local row=dump(child);if row then n.children[#n.children+1]=row end end
 return n
end
pg:SetAttribute('ACP_HalloweenMode','Off');pg:SetAttribute('ACP_HalloweenEnabled',false);Modules['07UI_HALLOWEEN_THEME'].Start(pg);flush()
local nodes={};for _,o in ipairs(EXPORT_GUI:GetChildren())do local row=dump(o);if row then nodes[#nodes+1]=row end end
local file=assert(io.open(EXPORT_PATH,'w'));file:write(json({width=SCREEN_W,height=SCREEN_H,nodes=nodes,label=EXPORT_LABEL}));file:close()
return EXPORT_PATH
'''
SCENES={
'activities_home':(THEME+DATA+PREVIEW+module('09I16_ACTIVITY_UI'),"local u=Modules['09I16_ACTIVITY_UI'].Build(pl,function()end);u.Root.Visible=true;u.Render();EXPORT_GUI=u.Gui"),
'activities_collab':(THEME+DATA+PREVIEW+module('09I16_ACTIVITY_UI'),"local u=Modules['09I16_ACTIVITY_UI'].Build(pl,function()end);u.Root.Visible=true;u.SetState({kind='collab',settings={style='street',budget=100,palette='sea'},owner=123,members={{uid=123,name='Você',style='street'},{uid=2,name='Lia',style='casual'}},results={},look={name='Look em colaboração',body=A.Copy(S.Current),rig='R15',total=95,contributors={{id=123,name='Você'},{id=2,name='Lia'}}},revision=1});EXPORT_GUI=u.Gui"),
'activities_remix':(THEME+DATA+PREVIEW+module('09I16_ACTIVITY_UI'),"local u=Modules['09I16_ACTIVITY_UI'].Build(pl,function()end);u.Root.Visible=true;u.SetState({kind='remix',settings={style='emo',budget=100,palette='ink'},owner=123,members={{uid=123,name='Você',style='emo'}},results={},look={name='Remix autorizado',body=A.Copy(S.Current),rig='R15',total=55,remix={originalCreatorName='CriadorOriginal'}},revision=1});u.Code.Text='a174752f3d674ef5af14def2787da581';EXPORT_GUI=u.Gui"),
'catalog':(UI+DATA+PREVIEW+module('09C4_OUTFIT_LIBRARY')+module('09C3_CATALOG_FILTERS')+module('09C2_SHOP_CATALOG'),r"""local rows={};for i=1,35 do rows[i]=fixture60(500+i,'street shirt '..i,'Shirt')end
function Services.AvatarEditorService:SearchCatalogAsync()return{IsFinished=true,GetCurrentPage=function()return deep(rows)end}end
local ctl=Modules['09C2_SHOP_CATALOG'].Init({U=U,A=A,S=S,toast=function()end,call=function()return true end});U.Root.Visible=true;U.ShowPreview();ctl.Search();U.Layout();ctl.Resize();EXPORT_GUI=U.Gui"""),
'looks':(UI+DATA+PREVIEW+COMMUNITY+module('09C1_SHOP_LOOKS'),r"""local saved={};for i=1,12 do saved[i]={id='s'..i,name='Meu look '..i,body=A.Copy(S.Current),rig='R15'}end
local ctl=Modules['09C1_SHOP_LOOKS'].Init({U=U,A=A,S=S,call=function()return{skins=saved,persistent=true}end,toast=function()end,buyBody=function()end});U.Root.Visible=true;U.SetWide(true);U.LooksArea.Visible=true;ctl.Saved();U.Layout();EXPORT_GUI=U.Gui"""),
'games':(THEME+DATA+module('07K6_CARD_CATALOG')+module('07K7_CARD_STYLES')+module('07K0_TRUCO_RULES')+module('07H5_TRUCO_SETUP')+module('07H1_GAME_LOBBY'),"local d=Modules['07UI_DESIGN_SYSTEM'];local gui=d.New('ScreenGui',{ScreenInsets=Enum.ScreenInsets.None},pg);local u=Modules['07H1_GAME_LOBBY'].Build(gui);u.Root.Visible=true;u.Layout();EXPORT_GUI=gui"),
'board':(THEME+module('07H2_GAME_BOARD')+module('07A0_CHESS_RULES'),"local d=Modules['07UI_DESIGN_SYSTEM'];local gui=d.New('ScreenGui',{ScreenInsets=Enum.ScreenInsets.None},pg);local u=Modules['07H2_GAME_BOARD'].Build(gui);u.Root.Visible=true;u.Draw(Modules['07A0_CHESS_RULES'].New(),'Xadrez','W');u.SetTimes(296,300);u.Layout();EXPORT_GUI=gui"),
'truco':(THEME+DATA+module('07K6_CARD_CATALOG')+module('07K7_CARD_STYLES')+module('07K0_TRUCO_RULES')+module('07K15_TRUCO_TABLE')+module('07H8_PLAY_SESSION')+module('07K5_TRUCO_UI'),r"""local d=Modules['07UI_DESIGN_SYSTEM'];local gui=d.New('ScreenGui',{ScreenInsets=Enum.ScreenInsets.None},pg);local u=Modules['07K5_TRUCO_UI'].Build(gui,function()end);u.Root.Visible=true
local v={seat=1,variant='Paulista',score={1,2},phase='play',turn=1,hand={{rank='3',suit='S'},{rank='A',suit='H'},{rank='K',suit='D'}},players={{uid=123,name='Você'},{uid=-2,name='Nico'},{uid=-3,name='Lia'},{uid=-4,name='Dante'}},tableCards={{seat=2,card={rank='7',suit='C'}},{seat=3,card={rank='Q',suit='D'}}},tricks={},lastTrick={},counts={3,2,2,3},value=1,nextRaise=3,handNumber=1,remaining=10,dealer=4}
u.Update(v,{equipped='Classic'});u.Layout();EXPORT_GUI=gui"""),
'checkers':(THEME+module('07H2_GAME_BOARD')+module('07B0_CHECKERS_RULES'),"local d=Modules['07UI_DESIGN_SYSTEM'];local gui=d.New('ScreenGui',{ScreenInsets=Enum.ScreenInsets.None},pg);local u=Modules['07H2_GAME_BOARD'].Build(gui);u.Root.Visible=true;u.Title.Text='Damas';u.Draw(Modules['07B0_CHECKERS_RULES'].New(),'Damas','W');u.SetTimes(296,300);u.Layout();EXPORT_GUI=gui"),
'chat':(THEME+DATA+module('07H2_GAME_BOARD')+module('07A0_CHESS_RULES'),r"""local a=makePlayer(2);function Services.Players:GetPlayers()return{pl,a}end
local d=Modules['07UI_DESIGN_SYSTEM'];local gui=d.New('ScreenGui',{ScreenInsets=Enum.ScreenInsets.None},pg);local u=Modules['07H2_GAME_BOARD'].Build(gui);u.Root.Visible=true;u.Draw(Modules['07A0_CHESS_RULES'].New(),'Xadrez','W');u.Layout()
local name=Modules['07H9_MATCH_CHAT'].Open('export','Xadrez',{pl,a});flush();u.MatchChat.Bind();u.Chat.Activated:Fire()
for i,text in ipairs({'Boa partida!','Boa! Gostei do seu look.','Depois vamos criar uma combinação?'})do u.MatchChat.Receive({TextChannel=u.MatchChat.Channel,TextSource={UserId=i%2==0 and 123 or 2},Status=Enum.TextChatMessageStatus.Success,Text=text,MessageId=tostring(i)})end
EXPORT_GUI=gui"""),
'music':(THEME+module('07M1_MUSIC_UI'),"local u=Modules['07M1_MUSIC_UI'].Build(pl);u.Root.Visible=true;u.Track.Text='Música da praça';u.Layout();EXPORT_GUI=u.Gui"),
'assistant':(THEME+module('09I0_ASSISTANT_CONFIG')+module('09I4_ASSISTANT_UI'),"local u=Modules['09I4_ASSISTANT_UI'].Build(pl);u.Root.Visible=true;u.Health('Normal',true,false);u.Layout();EXPORT_GUI=u.Gui"),
'photo_tools':(THEME+module('07P4_STUDIO_UI'),"local u=Modules['07P4_STUDIO_UI'].Build(pl);u.Root.Visible=true;u.Layout();EXPORT_GUI=u.Gui")}
SCENES['catalog_home']=(UI+DATA+PREVIEW+module('09C16_CATALOG_HOME'),"local h=Modules['09C16_CATALOG_HOME'].Build({U=U,A=A,S=S,browse=function()end,showItem=function()end,call=function()return{items={}}end,toast=function()end});U.Root.Visible=true;U.ShowPreview();h.Open();U.Layout();EXPORT_GUI=U.Gui")
SCENES['assistant_form']=(THEME+module('09I0_ASSISTANT_CONFIG')+module('09I4_ASSISTANT_UI')+module('09I5_ASSISTANT_QUESTIONNAIRE'),"local u=Modules['09I4_ASSISTANT_UI'].Build(pl);u.Root.Visible=true;local q=Modules['09I5_ASSISTANT_QUESTIONNAIRE'].Build(u,function()end);q.Open('Pro','look emo preto ate 100 Robux');q.Step=2;q.Layout();flush();EXPORT_GUI=u.Gui")
SCENES['assistant_conversation']=(THEME+module('09I0_ASSISTANT_CONFIG')+module('09I4_ASSISTANT_UI'),"local u=Modules['09I4_ASSISTANT_UI'].Build(pl);u.Root.Visible=true;u.Add('Quero um look streetwear azul ate 100 Robux.',true);u.Add('Vamos definir seu look. No formulario, escolha o estilo, o limite por look e as pecas que quer mudar. Voce confere a combinacao antes de aplicar.',false);flush();EXPORT_GUI=u.Gui")
SCENES['music_library']=(THEME+module('07M1_MUSIC_UI'),"local u=Modules['07M1_MUSIC_UI'].Build(pl);u.Root.Visible=true;u.SavedOpen=true;u.Layout();for i,name in ipairs({'Fall in Love · bossa lounge','Sunday Jazz (B)','Mellow'})do Modules['07UI_DESIGN_SYSTEM'].Button(u.List,name,{Size=UDim2.new(1,-4,0,56),TextXAlignment=Enum.TextXAlignment.Left,TextSize=13,LayoutOrder=i})end;EXPORT_GUI=u.Gui")
SCENES['sponsor']=(UI+DATA+PREVIEW+module('07UI_PAN_GRID')+module('09C10_SPONSOR_DESIGN')+module('09C11_SPONSOR_FEED')+module('09C9_SPONSOR_PICKER')+module('09C12_DESTINATION_BROWSER')+module('09C5_UGC_STORES'),r"""
local rows={};for i=1,60 do local item=fixture60(1000+i,'Peça de estilo '..i,'Shirt');rows[#rows+1]={key='Asset:'..item.Id,item=item,temporary=false}end
function Services.AvatarEditorService:SearchCatalogAsync()return{IsFinished=true,GetCurrentPage=function()return{}end}end
local ctl=Modules['09C5_UGC_STORES'].Init({U=U,A=A,S=S,call=function(action)if action=='HighlightFeed'then return{items=rows,finished=true}end;return{}end,toast=function()end,showItem=function()end,openAssistant=function()end});U.Root.Visible=true;U.ActivePage='Stores';U.SetWide(false);U.StoresArea.Visible=true;for _,o in ipairs({U.Query,U.SearchGo,U.Filter,U.Sort,U.Groups.Parent,U.More,U.Grid,U.Status})do o.Visible=false end;ctl.Search();flush();U.Layout();Preview.Mount(U.Viewport,S.Current,S.Rig,{drag=true,floor=true});EXPORT_GUI=U.Gui
""")
SCENES['new_avatar']=(UI+DATA+PREVIEW+module('09I22_BODY_CHOOSER')+module('09C14_NEW_AVATAR'),"local w=Modules['09C14_NEW_AVATAR'].Build({U=U,call=function()return{}end,toast=function()end});U.Root.Visible=true;w.Open();EXPORT_GUI=U.Gui")
SCENES['assistant_confirm']=(THEME+module('09I4_ASSISTANT_UI')+module('09I5_ASSISTANT_QUESTIONNAIRE'),"local u=Modules['09I4_ASSISTANT_UI'].Build(pl);u.Root.Visible=true;local q=Modules['09I5_ASSISTANT_QUESTIONNAIRE'].Build(u,function()end);q.Open('Pro','12 looks emo preto ate 100 Robux');q.Step=4;q.Layout();EXPORT_GUI=u.Gui")
SCENES['photo_emotes']=(THEME+module('07P4_STUDIO_UI')+module('07P9_STUDIO_CATALOG'),"function Services.AvatarEditorService:SearchCatalogAsync()local rows={};for i=1,20 do rows[i]=fixture60(1000+i,'Emote '..i,'EmoteAnimation')end;return{IsFinished=true,GetCurrentPage=function()return rows end}end;local u=Modules['07P4_STUDIO_UI'].Build(pl);u.Root.Visible=true;u.Popup.Visible=true;Modules['07P9_STUDIO_CATALOG'].Open(u,'Animations',function()end,function()end,{pause=function()return true,true end,speed=function()end});flush();u.Layout();EXPORT_GUI=u.Gui")
SCENES['assistant_real']=(THEME+DATA+PREVIEW+module('09I0_ASSISTANT_CONFIG')+module('09I4_ASSISTANT_UI')+module('09I5_ASSISTANT_QUESTIONNAIRE')+module('09I6_ASSISTANT_RESULTS')+module('09I7_ASSISTANT_PROFILE'),r"""
local folder=Instance.new('Folder');folder.Name='ACP_AssistantRemotes';folder.Parent=rep;local rpc=Instance.new('RemoteFunction');rpc.Name='Request';rpc.Parent=folder;local event=Instance.new('RemoteEvent');event.Name='Progress';event.Parent=folder
function rpc:InvokeServer(action,args)
 if action=='status'then return{protocol=2,ok=true,data={plan='Normal',available=true,count=1,collections={},prefs={},expires=0,owner=123,members={},invites={}}}end
 if action=='chat.list'then return{protocol=2,ok=true,data={items={{id='a',title='Meu look streetwear',updated=os.time()},{id='b',title='Ideias para fotos',updated=os.time()}}}}end
 return{protocol=2,ok=true,data={hidden=true}}
end
"""+src('09I_ASSISTANT_CLIENT')+r"""
pg:SetAttribute('ACP_OpenAINonce',1);pg:GetAttributeChangedSignal('ACP_OpenAINonce'):Fire();flush();EXPORT_GUI=pg.ACP_Assistant
""")
for name,(pre,scene)in SCENES.items():
 for label,w,h,cut,bottom in [('desktop',1280,720,0,0),('phone',390,844,0,34),('landscape',851,392,44,21)]:
  l=Lua();path=HERE/'layouts'/f'{name}_{label}.json'
  try:
   setup=f'SCREEN_W,SCREEN_H,DEVICE_LEFT,DEVICE_RIGHT,DEVICE_BOTTOM,CORE_LEFT,CORE_RIGHT,CORE_TOP,CORE_BOTTOM={w},{h},{cut},{cut},{bottom},{cut},{cut},58,0\n'
   l.run(MOCK+setup+pre+'\n'+scene+f'\nEXPORT_PATH={q(str(path))};EXPORT_LABEL={q(name+" · "+label)}\n'+DUMP,name)
   print(path.name)
  finally:l.close()
