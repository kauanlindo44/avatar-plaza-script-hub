-- BC_HUD | ModuleScript | ReplicatedStorage | V78 (SUBSTITUIR)
local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'))
local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'));local C=require(Rep:WaitForChild('BC_Config'));local P=C.Palette
local M={}
function M.Build(gui)
 local U={data={},Spectating=false,scoreRows={}};local N,R=D.New,Bounds.Rect;local safe=Bounds.Bind(gui)
 local function text(p,t,q)q=q or{};q.TextColor3=q.TextColor3 or P.Ink;return D.Text(p,t,q)end
 local function button(p,t,q)q=q or{};q.BackgroundColor3=q.BackgroundColor3 or P.Surface;q.TextColor3=P.Ink;return D.Button(p,t,q)end
 U.Queue=N('Frame',{Name='BC_QueueScreen',BackgroundColor3=Color3.fromRGB(237,229,207),Size=UDim2.fromScale(1,1),Visible=false},gui)
 U.Title=text(U.Queue,'Botão do Caos',{Font=Enum.Font.GothamBold,TextSize=28,TextXAlignment=Enum.TextXAlignment.Left})
 U.Brand=text(U.Queue,'UM JOGO NOSSO · AVATAR CATALOG & GAMES',{TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=Color3.fromRGB(66,84,114)})
 U.Close=D.IconButton(U.Queue,'BC_CloseQueue','close','Voltar ao catálogo',{TextColor3=P.Ink,BackgroundColor3=P.Surface})
 U.Art=D.Frame(U.Queue,{Name='BC_Artwork',BackgroundColor3=Color3.fromRGB(217,211,181)})
 local disk=D.Frame(U.Art,{Name='ButtonBaseArt',BackgroundColor3=P.Ink,Position=UDim2.fromScale(.18,.60),Size=UDim2.fromScale(.64,.21)})
 local cap=D.Frame(U.Art,{Name='ButtonArt',BackgroundColor3=P.Gold,Position=UDim2.fromScale(.25,.28),Size=UDim2.fromScale(.50,.40)})
 D.Stroke(cap,Color3.fromRGB(164,114,25),.35,2);text(cap,'APERTE!',{Size=UDim2.fromScale(1,1),TextSize=24,Font=Enum.Font.GothamBold})
 U.Panel=D.Frame(U.Queue,{Name='BC_QueuePanel',BackgroundColor3=P.Surface})
 U.Count=text(U.Panel,'0 na fila · 2 a 8 na arena',{TextSize=20,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left})
 U.Description=text(U.Panel,'CORRA · APERTE · SOBREVIVA\n\nAproxime-se do botão e toque em Apertar. Cada ativação vale 1 ponto e sorteia um dos 12 efeitos. Aproxime-se para empurrar. Cuidado: cair da plataforma elimina você.\n\nVence o último sobrevivente. Se o tempo acabar, vence a maior pontuação entre os vivos.',{TextSize=16,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top})
 U.QueueStatus=text(U.Panel,'Aguardando pelo menos mais 1 jogador',{TextSize=16,TextColor3=Color3.fromRGB(60,83,113),TextXAlignment=Enum.TextXAlignment.Left})
 U.Join=button(U.Panel,'Participar',{Name='BC_Join',BackgroundColor3=P.Cyan,TextSize=18})
 U.Training=button(U.Panel,'Treinar sozinho · 90 s',{Name='BC_Training'})
 U.LeaveQueue=button(U.Panel,'Sair da fila',{Name='BC_LeaveQueue',Visible=false})
 U.Back=button(U.Panel,'Voltar ao catálogo',{Name='BC_Back'})
 U.Hud=N('Frame',{Name='BC_MatchHUD',BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Visible=false},gui)
 U.Top=D.Frame(U.Hud,{BackgroundColor3=P.Ink,BackgroundTransparency=.06})
 U.Score=text(U.Hud,'0 PONTOS',{TextXAlignment=Enum.TextXAlignment.Left,TextSize=17,Font=Enum.Font.GothamBold,BackgroundColor3=P.Surface});D.Round(U.Score)
 U.Time=text(U.Top,'02:30',{TextSize=24,TextScaled=true,TextWrapped=false,Font=Enum.Font.GothamBold})
 N('UITextSizeConstraint',{MinTextSize=16,MaxTextSize=24},U.Time)
 U.Phase=text(U.Top,'DISPUTA',{TextSize=11,Font=Enum.Font.GothamBold})
 U.Alive=text(U.Top,'8 vivos',{TextSize=15,TextXAlignment=Enum.TextXAlignment.Right})
 U.Health=text(U.Hud,'♥ 100',{TextSize=15,BackgroundColor3=P.Surface,BackgroundTransparency=.03});D.Round(U.Health)
 U.Effect=text(U.Hud,'Nenhum efeito ainda',{TextSize=14,BackgroundColor3=P.Surface,BackgroundTransparency=.06});D.Round(U.Effect)
 U.Exit=button(U.Hud,'Sair',{Name='BC_Exit',TextSize=14})
 U.Reduce=button(U.Hud,'Efeitos: suaves',{Name='BC_ReduceFX',TextSize=14})
 U.Skill=text(U.Hud,'',{TextSize=14,BackgroundColor3=P.Surface,BackgroundTransparency=.04,Visible=false});D.Round(U.Skill)
 U.Push=button(U.Hud,'Empurrar',{Name='BC_PushAction',BackgroundColor3=P.Gold,TextSize=14,Visible=false})
 U.Fire=button(U.Hud,'DISPARAR',{Name='BC_Fire',BackgroundColor3=P.Cyan,TextSize=18,Visible=false})
 for _,label in ipairs({U.Time,U.Phase,U.Alive})do label.TextColor3=Color3.fromRGB(242,247,248)end
 U.Effect.BackgroundColor3=Color3.fromRGB(68,88,62);U.Effect.TextColor3=Color3.fromRGB(242,247,248)
 U.Reticle=N('Frame',{Name='BC_Reticle',BackgroundTransparency=1,Visible=false},U.Hud)
 for _,size in ipairs({Vector2.new(20,2),Vector2.new(2,20)})do
  local line=N('Frame',{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(size.X,size.Y),BorderSizePixel=0,BackgroundColor3=P.Surface},U.Reticle);D.Stroke(line,P.Ink,0,1)
 end
 U.Notice=D.Frame(U.Hud,{Name='BC_Announcement',BackgroundColor3=P.Surface,Visible=false,ZIndex=60})
 U.NoticeTitle=text(U.Notice,'',{Font=Enum.Font.GothamBold,TextSize=20,ZIndex=61});U.NoticeBody=text(U.Notice,'',{TextSize=14,ZIndex=61})
 U.Spectator=D.Frame(U.Hud,{Name='BC_Spectator',BackgroundColor3=P.Surface,Visible=false})
 U.Eliminated=text(U.Spectator,'Você foi eliminado',{TextSize=18,Font=Enum.Font.GothamBold})
 U.Watch=button(U.Spectator,'Assistir',{Name='BC_Watch',BackgroundColor3=P.Cyan});U.Next=button(U.Spectator,'Próximo',{Name='BC_NextSpectator',Visible=false})
 U.SpectatorBack=button(U.Spectator,'Catálogo',{Name='BC_SpectatorBack'})
 U.Result=N('Frame',{Name='BC_Result',BackgroundColor3=Color3.fromRGB(237,229,207),Size=UDim2.fromScale(1,1),Visible=false,ZIndex=70},gui)
 U.ResultTitle=text(U.Result,'Resultado',{TextSize=28,Font=Enum.Font.GothamBold,ZIndex=71})
 U.ResultSub=text(U.Result,'Retorno ao catálogo em 10 s',{TextSize=15,ZIndex=71})
 U.ResultList=D.Scroll(U.Result,{Name='BC_Scores',ZIndex=71,ScrollBarImageColor3=P.Ink})
 U.Continue=button(U.Result,'Continuar · entrar na próxima fila',{Name='BC_Continue',BackgroundColor3=P.Cyan,ZIndex=72})
 U.ResultBack=button(U.Result,'Voltar ao catálogo',{Name='BC_ResultBack',ZIndex=72})
 U.Confirm=D.Frame(gui,{Name='BC_ExitConfirmation',BackgroundColor3=P.Surface,Visible=false,ZIndex=100});D.Stroke(U.Confirm,P.Ink,.7)
 U.ConfirmTitle=text(U.Confirm,'Sair desta rodada?',{TextSize=22,Font=Enum.Font.GothamBold,ZIndex=101})
 U.ConfirmText=text(U.Confirm,'Você volta ao catálogo e não poderá retornar a esta mesma rodada.',{TextSize=15,ZIndex=101})
 U.Yes=button(U.Confirm,'Sair da partida',{BackgroundColor3=P.Danger,ZIndex=102});U.No=button(U.Confirm,'Continuar jogando',{BackgroundColor3=P.Cyan,ZIndex=102})
 local noticeToken=0
 function U.Announce(data)
  noticeToken=noticeToken+1;local token=noticeToken;U.NoticeTitle.Text=tostring(data.title or'');U.NoticeBody.Text=tostring(data.text or'');U.Notice.Visible=U.Hud.Visible
  task.delay(math.clamp(tonumber(data.seconds)or 2,1,3),function()if token==noticeToken and U.Notice.Parent then U.Notice.Visible=false end end)
 end
 function U.Layout()
  local il,it,ir,ib,w,h=safe.Read();local aw=w-il-ir;local ah=h-it-ib;local wide=aw>=650 and ah>=250
  local top=safe.Heading(U.Title,U.Close);R(U.Brand,il+12,top,aw-24,22);top=top+30
  local bottom=h-ib-10;local ph=bottom-top;local artW=wide and math.floor(aw*.34)or 0
  U.Art.Visible=wide;R(U.Art,il+10,top,math.max(1,artW-16),ph)
  local px=il+10+artW;local pw=aw-20-artW;R(U.Panel,px,top,pw,ph);R(U.Count,14,8,pw-28,32)
  local short=ph<300;R(U.Description,14,short and 42 or 48,pw-28,short and 40 or math.max(1,ph-214));U.Description.Visible=ph>=200
  U.Description.Text=short and'Corra até o botão e toque em Apertar. Sobreviva; no tempo limite, os pontos decidem.'or'CORRA · APERTE · SOBREVIVA\n\nAproxime-se do botão e toque em Apertar. Cada ativação vale 1 ponto e sorteia um dos 12 efeitos. Aproxime-se para empurrar. Cuidado: cair da plataforma elimina você.\n\nVence o último sobrevivente. Se o tempo acabar, vence a maior pontuação entre os vivos.'
  U.Description.TextSize=short and 14 or 16
  R(U.QueueStatus,14,short and ph-133 or math.max(42,ph-162),pw-28,short and 26 or 48);U.QueueStatus.TextSize=short and 14 or 16
  local bw=(pw-34)/2;R(U.Join,14,ph-104,bw,46);R(U.LeaveQueue,14,ph-104,bw,46);R(U.Training,20+bw,ph-104,bw,46);R(U.Back,14,ph-52,pw-28,44)
  local panelW=math.min(260,aw-132);local px=il+(aw-panelW)/2
  R(U.Top,px,it+4,panelW,44);R(U.Time,0,0,panelW*.40,28);R(U.Phase,0,28,panelW*.40,14)
  R(U.Alive,panelW*.40,4,panelW*.28,36);U.Alive.TextSize=12
  R(U.Score,px+panelW*.70,it+8,panelW*.30-4,34);U.Score.Text=tostring(U.data.score or 0)..' pts'
  U.Score.TextSize=12;U.Score.TextColor3=P.Gold;U.Score.BackgroundTransparency=1
  R(U.Health,il+6,it+4,54,44);R(U.Exit,w-ir-54,it+4,48,44)
  R(U.Effect,il+6,it+54,math.min(250,aw-72),30);R(U.Reduce,w-ir-54,it+54,48,44);U.Reduce.Text='FX';U.Reduce:SetAttribute('ActionLabel','Alternar efeitos suaves ou completos')
  local jump=gui.Parent and gui.Parent:FindFirstChild('TouchGui');jump=jump and jump:FindFirstChild('JumpButton',true)
  local jumpTop=jump and jump.AbsolutePosition.Y-gui.AbsolutePosition.Y or h-ib-110
  local controlY=math.max(it+100,math.min(h-ib-54,jumpTop-54));local controlX=w-ir-158
  R(U.Fire,controlX,controlY,74,48);R(U.Push,controlX+80,controlY,72,48)
  if not U.Fire.Visible then R(U.Push,w-ir-112,controlY,106,48)end
  U.Fire.TextSize=12;U.Push.TextSize=12
  R(U.Skill,il+8,h-ib-42,math.min(300,aw-172),32);U.Skill.TextSize=12
  R(U.Reticle,w*.5-14,h*.5-14,28,28)
  local compact=ah<420;local nw=math.min(260,aw-80);R(U.Notice,w-ir-nw-62,it+106,nw,50)
  R(U.NoticeTitle,6,2,nw-12,22);R(U.NoticeBody,6,24,nw-12,22);U.NoticeTitle.TextSize=14;U.NoticeBody.TextSize=12
  local sw=math.min(360,aw-24);local low=h-ib-120
  R(U.Spectator,il+(aw-sw)/2,low,sw,104);R(U.Eliminated,8,4,sw-16,30)
  R(U.Watch,8,44,(sw-24)/2,48);R(U.Next,8,44,(sw-24)/2,48);R(U.SpectatorBack,16+(sw-24)/2,44,(sw-24)/2,48)
  R(U.ResultTitle,il+12,it+4,aw-24,44);R(U.ResultSub,il+12,it+50,aw-24,30)
  R(U.ResultList,il+12,it+88,aw-24,math.max(44,ah-206));R(U.Continue,il+12,h-ib-108,aw-24,48);R(U.ResultBack,il+12,h-ib-54,aw-24,44)
  for i,row in ipairs(U.scoreRows)do R(row,0,(i-1)*46,U.ResultList.Size.X.Offset-8,42)end
  U.ResultList.CanvasSize=UDim2.fromOffset(0,#U.scoreRows*46)
  local cw=math.min(420,aw-24);R(U.Confirm,il+(aw-cw)/2,it+math.max(4,(ah-210)/2),cw,210)
  R(U.ConfirmTitle,12,8,cw-24,38);R(U.ConfirmText,16,50,cw-32,64);R(U.Yes,12,140,(cw-30)/2,52);R(U.No,18+(cw-30)/2,140,(cw-30)/2,52)
 end
 local resultKey
 function U.Set(data)
  U.data=data;local phase=data.phase;local playing=phase=='ACTIVE'or phase=='COUNTDOWN';local result=phase=='RESULTS'
  U.Hud.Visible=playing;U.Result.Visible=result;U.Queue.Visible=not data.matchId
  U.Count.Text=tostring(data.queue or 0)..' na fila · 2 a 8 na arena'
  U.Join.Visible=not data.queued;U.LeaveQueue.Visible=data.queued==true;D.SetEnabled(U.Training,not data.queued and not data.arenaBusy and(data.queue or 0)==0)
  U.QueueStatus.Text=data.queued and('Você está na fila · posição '..tostring(data.position))or(data.queue or 0)==0 and'Entre na fila para disputar uma rodada.'or'Aguardando pelo menos mais 1 jogador'
  if data.arenaBusy then U.QueueStatus.Text=data.queued and'Inscrito para a próxima rodada. A arena está ocupada.'or'Rodada em andamento. Entre na próxima fila.'
  elseif phase=='INTERMISSION'then U.QueueStatus.Text='Partida começando em '..tostring(data.remaining)..' s'end
  local sec=data.remaining or 0;U.Time.Text=phase=='COUNTDOWN'and tostring(sec)or string.format('%02d:%02d',math.floor(sec/60),sec%60)
  U.Time.TextSize=phase=='COUNTDOWN'and 18 or 24;U.Score.Text=tostring(data.score or 0)..' PONTOS';U.Alive.Text=tostring(data.aliveCount or 0)..' vivos';U.Health.Text='♥ '..tostring(data.health or 0)
  U.Phase.Text=phase=='COUNTDOWN'and'PREPARAÇÃO'or data.training and'TREINAMENTO'or'DISPUTA'
  U.Effect.Visible=playing and(data.nuclear~=nil or data.lastEffect~=nil and data.lastEffect~='Nenhum efeito ainda')
  U.Effect.Text=data.nuclear and('☢ '..data.nuclear.name..' · '..data.nuclear.remaining..' s')or data.lastEffect or'Nenhum efeito ainda'
  local skills={};for _,e in ipairs(data.effects or{})do skills[#skills+1]=e.name..' '..e.remaining..' s'end
  if data.weapon then skills[#skills+1]=(data.weapon.name=='Blaster de energia'and'Blaster'or'Bomba de espuma')..' · '..data.weapon.ammo..' uso(s) · '..data.weapon.remaining..' s'end
  U.Skill.Text=table.concat(skills,'  •  ');U.Skill.Visible=playing and data.alive==true and #skills>0
  U.Push.Visible=phase=='ACTIVE'and data.alive==true
  local cooldown=math.ceil(data.pushCooldown or 0);U.Push.Text=cooldown>0 and('Espera '..cooldown..'s')or'Empurrar';D.SetEnabled(U.Push,cooldown==0)
  U.Fire.Visible=phase=='ACTIVE'and data.alive==true and data.weapon~=nil;U.Reticle.Visible=U.Fire.Visible
  U.Fire.Text=data.weapon and(data.weapon.name=='Bomba de espuma'and'ARREMESSAR'or'DISPARAR')or'DISPARAR'
  U.Spectator.Visible=playing and data.alive==false;U.Watch.Visible=not U.Spectating;U.Next.Visible=U.Spectating
  if result then
   U.ResultTitle.Text=data.training and'Treinamento concluído'or data.noWinner and'Partida sem vencedor'or data.winner and'VITÓRIA!'or'Fim de rodada'
   U.ResultSub.Text='Retorno ao catálogo em '..sec..' s'..(data.training and' · sem vitórias persistentes'or' · vitória: +5 pontos')
   U.Continue.Text=data.continueNext and'✓ Próxima fila confirmada'or'Continuar · entrar na próxima fila';D.SetEnabled(U.Continue,not data.continueNext)
   local key=data.matchId..':'..tostring(#(data.roster or{}))
   if resultKey~=key then
    resultKey=key;for _,row in ipairs(U.scoreRows)do row:Destroy()end;U.scoreRows={}
    for i,p in ipairs(data.roster or{})do U.scoreRows[i]=text(U.ResultList,(p.winner and'★ 'or'')..p.name..'  ·  '..p.score..' pontos'..(p.left and' · saiu'or not p.alive and' · eliminado'or''),{Name='Score_'..p.id,TextSize=16,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=0,BackgroundColor3=P.Surface,ZIndex=72})end
   end
  else resultKey=nil end
  U.Layout()
 end
 safe.Watch(U.Layout);U.Layout();return U
end
return M
