-- 09C9_PLAYER_INSPECT | ModuleScript | ReplicatedStorage | V64 (SUBSTITUIR)
-- Painel pequeno, avatar visível imediato e quatro ações com consentimento.
local Players=game:GetService('Players');local UIS=game:GetService('UserInputService');local Rep=game:GetService('ReplicatedStorage')
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local Bounds=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'))
local Preview=require(Rep:WaitForChild('09C6_AVATAR_PREVIEW'));local Fx=require(Rep:WaitForChild('07UI_SURFACE_EFFECTS'));local C=D.Colors;local M={Version='V64'}
function M.Init(ctx)
 local pl=Players.LocalPlayer;local pg=pl:WaitForChild('PlayerGui');local last=0;local selected,record;local revision=0
 local old=pg:FindFirstChild('ACP_PlayerCard');if old then old:Destroy()end
 local gui=D.New('ScreenGui',{Name='ACP_PlayerCard',ResetOnSpawn=false,DisplayOrder=198,IgnoreGuiInset=true,ScreenInsets=Enum.ScreenInsets.None,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
 local safe=Bounds.Bind(gui);local panel=D.Frame(gui,{Name='PlayerCard',Visible=false,BackgroundColor3=C.panel});Fx.Surface(panel,Color3.fromRGB(28,37,47),Color3.fromRGB(47,34,46),C.orange)
 local title=D.Text(panel,'',{TextSize=16,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd})
 local close=D.IconButton(panel,'ClosePlayerCard','close','Fechar avatar',{ZIndex=20})
 local stage=Fx.Stage(panel,'PlayerPreview',1);local view=D.New('ViewportFrame',{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ZIndex=2},stage);view:SetAttribute('V54_Stage',true)
 local info=D.Text(panel,'',{TextSize=11,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left})
 local buttons={};for i,name in ipairs({'Ver roupa','Curtir','Usar look','Enviar Robux'})do buttons[i]=D.Button(panel,name,{Name='PlayerAction'..i,TextSize=12});Fx.Button(buttons[i],C.orange)end
 local transfer=D.Frame(panel,{Name='TransferConfirmation',Visible=false,ZIndex=30,BackgroundColor3=C.panel})
 local amount=D.Box(transfer,'10 a 500 Robux',{Text='10',TextSize=13,ZIndex=31})
 local confirm=D.Button(transfer,'Abrir no Roblox',{TextSize=12,ZIndex=31,BackgroundColor3=C.orange,TextColor3=C.bg})
 local back=D.Button(transfer,'Voltar',{TextSize=12,ZIndex=31})
 local disclosure=D.Text(transfer,'Roblox Plus • 90% para o jogador e 10% para a experiência. O Roblox confirma a compra.',{TextSize=11,TextColor3=C.muted,ZIndex=31})
 local function hide()revision=revision+1;panel.Visible=false;transfer.Visible=false;Preview.Unmount(view);selected=nil;record=nil end
 local function layout()
  local il,it,ir,ib,w,h=safe.Read();local aw=w-il-ir;local pw=math.min(550,aw-16);local ph=math.min(276,h-it-ib-16)
  Bounds.Rect(panel,il+(aw-pw)/2,it+(h-it-ib-ph)/2,pw,ph)
  Bounds.Rect(title,12,4,pw-76,44);Bounds.Rect(close,pw-54,2,48,48)
  local vw=math.floor(pw*.36);Bounds.Rect(stage,8,54,vw,ph-62)
  local x=vw+16;local rw=pw-x-8;Bounds.Rect(info,x,54,rw,math.max(26,ph-166))
  for i,b in ipairs(buttons)do Bounds.Rect(b,x+(i-1)%2*(rw+6)/2,ph-102+math.floor((i-1)/2)*50,(rw-6)/2,44)end
  Bounds.Rect(transfer,x,54,rw,ph-62);Bounds.Rect(disclosure,6,2,rw-12,math.max(44,ph-164))
  Bounds.Rect(amount,6,ph-156,rw-12,44);Bounds.Rect(back,6,ph-106,(rw-18)/2,44);Bounds.Rect(confirm,(rw+6)/2,ph-106,(rw-18)/2,44)
 end
 local function show(other)
  revision=revision+1;local mine=revision;selected=other;record=nil;panel.Visible=true;transfer.Visible=false;title.Text=other.DisplayName
  info.Text='Carregando informações…';layout();for _,b in ipairs(buttons)do D.SetEnabled(b,false)end
  local hum=other.Character and other.Character:FindFirstChildOfClass('Humanoid')
  if hum then local desc=hum:GetAppliedDescription();local body=ctx.A.Pack(desc);desc:Destroy();Preview.Mount(view,body,hum.RigType==Enum.HumanoidRigType.R6 and'R6'or'R15',{clone=other.Character,drag=true,floor=false})end
  task.spawn(function()
   local r,e=ctx.call('InspectAvatar',{id=other.UserId});if mine~=revision then return end
   if not r then info.Text=e or'O avatar não carregou.';return end;record=r
   info.Text='@'..other.Name..'\n'..(r.allowCopy and'Permite usar o look'or'O dono desativou cópias')..' • '..tostring(r.likes or 0)..' curtidas'
   for _,b in ipairs(buttons)do D.SetEnabled(b,true)end;D.SetEnabled(buttons[3],r.allowCopy==true)
  end)
 end
 close.Activated:Connect(hide);back.Activated:Connect(function()transfer.Visible=false end)
 buttons[1].Activated:Connect(function()if record then local r=record;hide();ctx.open();ctx.show(r)end end)
 buttons[2].Activated:Connect(function()if not selected then return end;local id=selected.UserId;local mine=revision;task.spawn(function()local r,e=ctx.call('InspectLike',{id=id});if mine~=revision then return end;if r then buttons[2].Text='♥ '..r.likes else ctx.toast(e)end end)end)
 buttons[3].Activated:Connect(function()
  if not selected or not record or not record.allowCopy then return end;local id=selected.UserId;local mine=revision
  task.spawn(function()local r,e=ctx.call('InspectUse',{id=id});if mine~=revision then return end;if not r then ctx.toast(e);return end;local ok,why=ctx.S.Set(r.body,false,r.rig);ctx.toast(ok and'Look carregado. O dono mantém o controle de cópia.'or why);if ok then hide()end end)
 end)
 buttons[4].Activated:Connect(function()transfer.Visible=true end)
 confirm.Activated:Connect(function()
  local n=tonumber(amount.Text);if not n or n%1~=0 or n<10 or n>500 then ctx.toast('Escolha entre 10 e 500 Robux.');return end
  if not selected then return end;local id=selected.UserId;local mine=revision;D.SetEnabled(confirm,false)
  task.spawn(function()local r,e=ctx.call('InspectTransfer',{id=id,amount=n});D.SetEnabled(confirm,true);if mine~=revision then return end;ctx.toast(r and'Pedido aberto no Roblox. O recibo confirma a transferência.'or e);transfer.Visible=false end)
 end)
 local c=UIS.InputBegan:Connect(function(input,processed)
  if processed or(input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch)then return end
  if panel.Visible then local p,s=panel.AbsolutePosition,panel.AbsoluteSize;local q=input.Position;if q.X>=p.X and q.X<=p.X+s.X and q.Y>=p.Y and q.Y<=p.Y+s.Y then return end;hide()end
  if ctx.U.Root.Visible or pl:GetAttribute('ACP_InGameRoom')or os.clock()-last<.8 then return end
  local camera=workspace.CurrentCamera;if not camera then return end
  local ray=camera:ViewportPointToRay(input.Position.X,input.Position.Y);local hit=workspace:Raycast(ray.Origin,ray.Direction*100)
  local model=hit and hit.Instance:FindFirstAncestorOfClass('Model');local other=model and Players:GetPlayerFromCharacter(model)
  if other and other~=pl then last=os.clock();show(other)end
 end)
 Players.PlayerRemoving:Connect(function(other)if other==selected then hide()end end)
 ctx.U.Root:GetPropertyChangedSignal('Visible'):Connect(function()if ctx.U.Root.Visible then hide()end end)
 safe.Watch(layout);return{Connection=c,Show=show,Close=hide,Panel=panel,Buttons=buttons,Preview=view}
end
return M
