-- 07P10_VIDEO_MOTION | ModuleScript | ReplicatedStorage | V62 (NOVO)
-- Movimento contínuo da câmera/cópia, com aceleração suave e enquadramento estável.
local Run=game:GetService('RunService');local Rep=game:GetService('ReplicatedStorage');local D=require(Rep:WaitForChild('07UI_DESIGN_SYSTEM'));local B=require(Rep:WaitForChild('07UI_SCREEN_BOUNDS'))
local M={Version='V62'}
M.Motions={{'ORBIT','Órbita 360°'},{'SWAY','Arco suave'},{'DOLLY','Aproximação'},{'CRANE','Subida suave'},{'PAN','Travelling'},{'FIGURE8','Percurso em oito'},{'REVEAL','Revelar look'},{'ROLL','Inclinação leve'},{'AVATAR','Giro do avatar'}}
function M.New(studio,alive)
 local self={Speed=1,Strength=1,Paused=false};local connection;local elapsed=0;local selected;local anchor;local blend=0
 function self.Stop(restore)
  if connection then connection:Disconnect();connection=nil end
  if restore and anchor then studio.SetMotionFrame(anchor);studio.SetAvatarYaw(anchor.avatar)end
  selected=nil;self.Paused=false
 end
 function self.Start(id)
  local found=false;for _,v in ipairs(M.Motions)do if v[1]==id then found=true end end;if not found then return false end
  self.Stop(false);elapsed=0;blend=0;selected=id;anchor={yaw=studio.Yaw,pitch=studio.Pitch or 0,zoom=studio.Zoom,pan=studio.Pan or 0,vertical=studio.Vertical or 0,roll=studio.Roll or 0,avatar=studio.AvatarYaw or 0}
  connection=Run.RenderStepped:Connect(function(dt)
   if not alive()then self.Stop(false);return end;if self.Paused then return end
   dt=math.min(dt,.1);elapsed=elapsed+dt*self.Speed;blend=math.min(1,blend+dt/1.1);local ramp=blend*blend*(3-2*blend)
   local a=elapsed*math.pi/8;local strength=self.Strength*ramp;local frame={yaw=anchor.yaw,pitch=anchor.pitch,zoom=anchor.zoom,pan=anchor.pan,vertical=anchor.vertical,roll=anchor.roll}
   if id=='ORBIT'then frame.yaw=anchor.yaw+elapsed*18*ramp
   elseif id=='SWAY'then frame.yaw=anchor.yaw+math.sin(a)*22*strength;frame.pitch=anchor.pitch+math.sin(a*.5)*3*strength
   elseif id=='DOLLY'then frame.zoom=anchor.zoom+math.sin(a)*.13*strength
   elseif id=='CRANE'then frame.vertical=anchor.vertical+math.sin(a)*.7*strength;frame.pitch=anchor.pitch+math.sin(a)*4*strength
   elseif id=='PAN'then frame.pan=anchor.pan+math.sin(a)*.85*strength
   elseif id=='FIGURE8'then frame.pan=anchor.pan+math.sin(a)*.65*strength;frame.vertical=anchor.vertical+math.sin(a*2)*.24*strength;frame.yaw=anchor.yaw+math.sin(a)*10*strength
   elseif id=='REVEAL'then frame.yaw=anchor.yaw+28*(1-math.cos(a))*strength;frame.zoom=anchor.zoom+.07*(1-math.cos(a))*strength
   elseif id=='ROLL'then frame.roll=anchor.roll+math.sin(a)*2.4*strength;frame.zoom=anchor.zoom+math.sin(a*.5)*.035*strength
   elseif id=='AVATAR'then studio.SetAvatarYaw(anchor.avatar+elapsed*20*ramp)end
   studio.SetMotionFrame(frame)
  end);return true
 end
 function self.Panel(U,notify)
  U.Clear();U.CatalogMode=true;U.PopupTitle.Text='Movimentos para vídeo';local host=D.New('Frame',{Name='VideoMotionControls',BackgroundTransparency=1,ZIndex=32,LayoutOrder=1},U.Content)
  local pause=D.Button(host,'Pausar',{Name='PauseVideoMotion',ZIndex=33});local reset=D.Button(host,'Restaurar',{Name='ResetVideoMotion',ZIndex=33})
  local list=D.Scroll(host,{Name='VideoMotionPresets',ZIndex=33,ScrollBarThickness=3});local grid=D.New('UIGridLayout',{CellPadding=UDim2.fromOffset(6,6),SortOrder=Enum.SortOrder.LayoutOrder},list)
  local speed=D.Button(host,'Velocidade 1×',{Name='VideoMotionSpeed',TextSize=12,ZIndex=33});local strength=D.Button(host,'Intensidade 1×',{Name='VideoMotionStrength',TextSize=12,ZIndex=33})
  local buttons={}
  local function layout()
   local w,h=host.AbsoluteSize.X,host.AbsoluteSize.Y;B.Rect(pause,0,0,(w-6)/2,44);B.Rect(reset,(w+6)/2,0,(w-6)/2,44)
   B.Rect(list,0,50,w,math.max(44,h-100));B.Rect(speed,0,h-44,(w-6)/2,44);B.Rect(strength,(w+6)/2,h-44,(w-6)/2,44)
   grid.FillDirectionMaxCells=2;grid.CellSize=UDim2.fromOffset((w-12)/2,44)
  end
  for i,v in ipairs(M.Motions)do local b=D.Button(list,v[2],{Name='Motion_'..v[1],LayoutOrder=i,TextSize=12,ZIndex=34});buttons[v[1]]=b
   b.Activated:Connect(function()self.Start(v[1]);pause.Text='Pausar';for key,button in pairs(buttons)do button.BackgroundColor3=key==v[1]and D.Colors.orange or D.Colors.card end;notify(v[2]..' • na câmera/cópia • fundo fixo')end)
  end
  pause.Activated:Connect(function()self.Paused=not self.Paused;pause.Text=self.Paused and'Continuar'or'Pausar'end)
  reset.Activated:Connect(function()self.Stop(true);pause.Text='Pausar';notify('Movimento restaurado. O emote continua independente.')end)
  local speeds={.5,1,1.5,2};local si=2;speed.Activated:Connect(function()si=si%#speeds+1;self.Speed=speeds[si];speed.Text='Velocidade '..self.Speed..'×'end)
  local strengths={.5,1,1.5};local vi=2;strength.Activated:Connect(function()vi=vi%#strengths+1;self.Strength=strengths[vi];strength.Text='Intensidade '..self.Strength..'×'end)
  host:GetPropertyChangedSignal('AbsoluteSize'):Connect(layout);layout();U.Layout()
 end
 return self
end
return M
