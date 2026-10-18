-- 09I19_REHEARSAL_CUES | ModuleScript | ReplicatedStorage | V69 (NOVO)
-- Roteiro acionado explicitamente; enquadra a cópia e mantém o controle do jogador.
local Rep=game:GetService('ReplicatedStorage');local Http=game:GetService('HttpService')
local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local B=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'))
local Rules=require(Rep:WaitForChild('09I15_ACTIVITY_RULES'));local M={}
function M.Build(U,Studio,active)
 local pg=game:GetService('Players').LocalPlayer:WaitForChild('PlayerGui');local safe=B.Bind(U.Gui)
 local R={Index=1,Steps={}};R.Root=D.Frame(U.Root,{Name='RehearsalCue',Visible=false,BackgroundColor3=D.Colors.panel,BackgroundTransparency=.03,ZIndex=60})
 R.Title=D.Text(R.Root,'',{Font=Enum.Font.GothamBold,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=61})
 R.Prev=D.Button(R.Root,'‹',{TextSize=24,ZIndex=62});R.Next=D.Button(R.Root,'Próxima',{TextSize=14,ZIndex=62})
 R.CloseButton=D.IconButton(R.Root,'CloseRehearsal','close','Ocultar roteiro',{Size=UDim2.fromOffset(44,44),ZIndex=62})
 function R.Layout()
  local il,it,ir,ib,w,h=safe.Read();local width=math.min(440,w-il-ir-16)
  B.Rect(R.Root,w-ir-width-8,h-ib-112,width,54);B.Rect(R.Prev,4,5,44,44)
  B.Rect(R.Next,width-144,5,92,44);B.Rect(R.CloseButton,width-48,5,44,44);B.Rect(R.Title,54,6,math.max(30,width-202),42)
 end
 function R.Show(index)
  if not active()or #R.Steps==0 then return end;R.Index=math.clamp(index,1,#R.Steps);local s=R.Steps[R.Index]
  Studio.SetFrame(s.frame);Studio.SetAvatarYaw(s.yaw);Studio.SetZoom(s.zoom)
  R.Title.Text=s.title;R.Next.Text=R.Index==#R.Steps and'Recomeçar'or'Próxima';U.Notify(s.text);R.Root.Visible=true;R.Layout()
 end
 function R.Open()
  local raw=pg:GetAttribute('ACP_RehearsalSettings');local ok,v=pcall(function()return Http:JSONDecode(raw or'{}')end)
  if not ok then return end;R.Steps=Rules.Rehearsal(Rules.Settings(v));R.Show(1)
 end
 function R.Close()R.Root.Visible=false;R.Steps={}end
 R.Next.Activated:Connect(function()R.Show(R.Index%#R.Steps+1)end);R.Prev.Activated:Connect(function()R.Show(math.max(1,R.Index-1))end)
 R.CloseButton.Activated:Connect(R.Close);safe.Watch(R.Layout);return R
end
return M
