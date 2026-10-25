-- 07G1_HUB_SETTINGS | ModuleScript | ReplicatedStorage | V77 (SUBSTITUIR)
-- V60 (SUBSTITUIR): painel compacto, cores como acento e controles de toque preservados.
local Rep=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local D=require(Rep:WaitForChild("07UI_DESIGN_SYSTEM"));local C=D.Colors
local Worlds=require(Rep:WaitForChild("07G2_LOCAL_WORLDS"))
local Bounds=require(Rep:WaitForChild("07UI_SCREEN_BOUNDS"))
local Tools=require(Rep:WaitForChild("07G3_PERSONAL_TOOLS"))
local pl=game:GetService("Players").LocalPlayer;local Fx=require(Rep:WaitForChild('07UI_SURFACE_EFFECTS'))
local Theme=require(Rep:WaitForChild('07UI_HALLOWEEN_THEME'));local M={}
function M.Build(root,pg,onCompact,toast,bounds)
 Tools.OnNotice=toast;local U={Page="Home"};local safe=bounds or Bounds.Bind(root:FindFirstAncestorOfClass("ScreenGui"))
 U.Panel=D.Frame(root,{Name="SettingsPanel",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),BackgroundColor3=C.panel,Visible=false,ZIndex=40})
 local p=U.Panel;Fx.Surface(p,C.panel,C.bg,C.orange)
 U.Title=D.Text(p,"Configurações",{TextSize=20,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=41})
 U.Close=D.IconButton(p,"CloseCfg","close","Fechar configurações",{Size=UDim2.fromOffset(48,48),ZIndex=49})
 U.Back=D.Button(p,"‹ Voltar",{Size=UDim2.fromOffset(96,40),Visible=false,ZIndex=42})
 U.Body=D.Scroll(p,{Name="SettingsCategories",BackgroundTransparency=1,ZIndex=41,AutomaticCanvasSize=Enum.AutomaticSize.None,ScrollBarThickness=3})
 local pageButtons={};local go
 local function clear()
  for _,o in ipairs(U.Body:GetChildren())do o:Destroy()end;pageButtons={}
 end
 local function card(name,caption,note,color,fn)
  local b=D.Button(U.Body,"",{Name=name,BackgroundColor3=U.Page=="Home"and color or Color3.new(color.R*.38+.12,color.G*.38+.12,color.B*.38+.12),ZIndex=42});Fx.Button(b,color);D.New("Frame",{Name="CategoryAccent",Position=UDim2.fromOffset(0,10),Size=UDim2.new(0,3,1,-20),BackgroundColor3=color,BorderSizePixel=0,Active=false,ZIndex=43},b)
  D.Text(b,caption,{Position=UDim2.fromOffset(12,8),Size=UDim2.new(1,-24,0,26),TextSize=18,Font=Enum.Font.GothamBold,TextColor3=U.Page=="Home"and Color3.fromRGB(29,33,40)or C.white,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd,Active=false,ZIndex=43})
  D.Text(b,note,{Position=UDim2.fromOffset(12,38),Size=UDim2.new(1,-24,1,-46),TextSize=12,TextColor3=U.Page=="Home"and Color3.fromRGB(39,44,53)or C.muted,TextXAlignment=Enum.TextXAlignment.Left,Active=false,ZIndex=43})
  b.Activated:Connect(fn);table.insert(pageButtons,b);return b
 end
 go=function(page)
  U.Page=page;clear();U.Back.Visible=page~="Home"
  if page=="Home"then
   U.Title.Text="Configurações"
   card('Privacy','Jogador','Avatar e permissões',Color3.fromRGB(89,193,205),function()go('Privacy')end)
   card('ChangeWorld','Ambiente','Mundos da sua praça',Color3.fromRGB(208,101,153),function()go('World')end)
   card('Interface','Catálogo','Aparência e atalhos',Color3.fromRGB(115,190,99),function()go('Interface')end)
   card('Camera','Câmera e luz','Enquadramento',Color3.fromRGB(151,113,200),function()go('Camera')end)
   card('General','Geral','Comandos e assistente',Color3.fromRGB(221,165,67),function()go('General')end)
   card('Sound','Música e áudio','Biblioteca e volume',Color3.fromRGB(220,112,104),function()go('Sound')end)
  elseif page=='General'then
   U.Title.Text='Geral'
   card('Commands','Comandos','Ver os comandos disponíveis',C.cyan,function()go('Commands')end)
   card('Assistant','Assistente','Looks, ajuda e atividades',C.purple,function()p.Visible=false;pg:SetAttribute('ACP_OpenAINonce',(tonumber(pg:GetAttribute('ACP_OpenAINonce'))or 0)+1)end)
   card('ResetCfg','Restaurar configurações','Praça original, câmera e interface',C.yellow,function()Worlds.Apply('ORIGINAL');onCompact(false);if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView=70 end;pg:SetAttribute('ACP_MusicEnabled',true);go('Home');toast('Configurações restauradas.')end)
  elseif page=="World"then
   U.Title.Text="Mudar mundo"
   for _,s in ipairs(Worlds.Worlds)do card(s.id,s.name,(Worlds.Selected==s.id and"Selecionado • "or"")..s.note,s.color,function()
    local ok,err=Worlds.Apply(s.id);if ok then go("World");toast("Mundo alterado para você.")else toast(err)end
   end)end
  elseif page=="Sound"then
   U.Title.Text="Som"
   card("MusicToggle","Música",pg:GetAttribute("ACP_MusicEnabled")==false and"Desligada • toque para ligar"or"Ligada • toque para desligar",C.pink,function()
    pg:SetAttribute("ACP_MusicEnabled",pg:GetAttribute("ACP_MusicEnabled")==false);go("Sound")
   end)
   card("OpenMusic","Escolher música","Abra sua biblioteca de músicas",C.blue,function()p.Visible=false;pg:SetAttribute("ACP_OpenMusicNonce",(tonumber(pg:GetAttribute("ACP_OpenMusicNonce"))or 0)+1)end)
  elseif page=="Camera"then
   U.Title.Text="Câmera";local cam=workspace.CurrentCamera;local n=cam and cam.FieldOfView or 70
   for _,v in ipairs({60,70,80,90})do card("Fov"..v,v.."°",v==n and"Selecionado"or(v<70 and"Visão próxima"or"Visão ampla"),v==n and C.green or C.blue,function()if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView=v end;go("Camera")end)end
  elseif page=="Privacy"then
   U.Title.Text="Privacidade"
   local allowed=pl:GetAttribute("ACP_AllowAvatarCopy")==true
   card("AllowCopy",allowed and"Uso permitido"or"Uso do look bloqueado","Toque para mudar o uso dentro deste jogo",allowed and C.green or C.pink,function()local ok,e=Tools.Privacy(not allowed);toast(ok and"Preferência de uso salva."or e);if ok then go("Privacy")end end)
   card("CardView","Visuais das cartas","Escolha como as cartas da mesa aparecem",C.blue,function()
    local values={"mine","players","classic"};local labels={mine="Meu baralho",players="Visuais de cada jogador",classic="Clássico"};local now=pg:GetAttribute("ACP_CardView")or"mine";local n=table.find(values,now)or 1;local nextValue=values[n%3+1];pg:SetAttribute("ACP_CardView",nextValue);toast(labels[nextValue])
   end)
  elseif page=="Commands"then
   U.Title.Text='Comandos no chat'
   local list=D.Scroll(U.Body,{Name='PersonalCommandList',Size=UDim2.fromScale(1,1),ScrollBarThickness=3,ZIndex=42})
   D.New('UIListLayout',{Padding=UDim.new(0,6)},list)
   for i,definition in ipairs(Tools.Commands)do
    local b=D.Button(list,'',{Name='Command_'..definition.alias:sub(2),Size=UDim2.new(1,-4,0,58),LayoutOrder=i,ZIndex=43})
    D.Text(b,definition.alias..(definition.argument and(' '..definition.value)or''),{Position=UDim2.fromOffset(8,4),Size=UDim2.new(.34,-12,1,-8),TextSize=13,Font=Enum.Font.GothamBold,TextColor3=C.cyan,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=44})
    D.Text(b,definition.description,{Position=UDim2.new(.34,4,0,4),Size=UDim2.new(.66,-12,1,-8),TextSize=11,TextColor3=U.Page=="Home"and Color3.fromRGB(39,44,53)or C.muted,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=44})
    b.Activated:Connect(function()task.spawn(function()local d,e=Tools.Call(definition.key,definition.value);Tools.CommandResult({ok=d~=nil,data=d,error=e})end)end)
   end
  else
   U.Title.Text="Aparência"
   card("Automatic","Automática","Adapta os atalhos à tela",C.green,function()onCompact(false);toast("Interface automática.")end)
   card("Compact","Compacta","Atalhos menores",C.blue,function()onCompact(true);toast("Interface compacta.")end)
   local mode=pg:GetAttribute('ACP_HalloweenMode')or'Auto';local labels={Auto='Automático • até 31/10',On='Halloween • manter ligado',Off='Neutro • sem enfeites'}
   card('Theme','Tema: '..(mode=='Auto'and'Automático'or mode=='On'and'Halloween'or'Neutro'),labels[mode]..' • toque para trocar',C.orange,function()Theme.SetMode(pg,mode=='Auto'and'Off'or mode=='Off'and'On'or'Auto');go('Interface')end)
   card("Motion","Animações",pg:GetAttribute("ACP_ReducedMotion")==true and"Reduzidas • toque para ativar"or"Ativas • toque para reduzir",C.purple,function()pg:SetAttribute("ACP_ReducedMotion",pg:GetAttribute("ACP_ReducedMotion")~=true);go("Interface")end)
   card("ResetCfg","Restaurar","Praça original, câmera e interface",C.yellow,function()
    Worlds.Apply("ORIGINAL");onCompact(false);local cam=workspace.CurrentCamera;if cam then cam.FieldOfView=70 end;pg:SetAttribute("ACP_MusicEnabled",true);go("Home");toast("Configurações restauradas.")
   end)
  end
  U.Layout()
 end
 function U.Layout()
  local il,it,ir,ib,w,h=safe.Read();if w<1 or h<1 then return end
  local aw,ah=w-il-ir,h-it-ib;local pw=math.min(360,aw-12);local ph=math.min(U.Page=="Home"and 320 or 400,ah-12)
  Bounds.Rect(p,il+(aw-pw)/2,it+(ah-ph)/2,pw,ph)
  local pw,ph=p.Size.X.Offset,p.Size.Y.Offset
  Bounds.Rect(U.Close,pw-54,4,48,48)
  Bounds.Rect(U.Back,8,6,96,44)
  local start=U.Back.Visible and 112 or 12;Bounds.Rect(U.Title,start,4,pw-start-64,48);U.Title.TextSize=pw<400 and 18 or 23
  local y=58;Bounds.Rect(U.Body,8,y,pw-16,ph-y-8)
  local cols=U.Page=="Home"and 2 or 1;local rows=math.max(1,math.ceil(#pageButtons/cols))
  local bw,bh=(pw-16-(cols-1)*8)/cols,U.Page=="Home"and math.max(44,math.min(86,(ph-y-8-(rows-1)*8)/rows))or 70
  U.Body.CanvasSize=UDim2.fromOffset(0,rows*(bh+8));U.Body.ScrollingEnabled=rows*(bh+8)>ph-y-8
  for i,b in ipairs(pageButtons)do
   Bounds.Rect(b,(i-1)%cols*(bw+8),math.floor((i-1)/cols)*(bh+8),bw,bh)
   for _,label in ipairs(b:GetChildren())do if label:IsA('TextLabel')then
    if label.Font==Enum.Font.GothamBold then Bounds.Rect(label,10,6,bw-20,bh<57 and bh-12 or 22);label.TextSize=bw<170 and 13 or 15
    else label.Visible=bh>=57;Bounds.Rect(label,10,29,bw-20,math.max(1,bh-34));label.TextSize=11 end
   end end
  end
 end
 U.Close.Activated:Connect(function()p.Visible=false end)
 U.Back.Activated:Connect(function()go("Home")end)
 p:GetPropertyChangedSignal("Visible"):Connect(function()if p.Visible then go("Home");Fx.Enter(p)end;if U.OnVisibility then U.OnVisibility()end end)
 safe.Watch(U.Layout)
 local input=UIS.InputBegan:Connect(function(i,gp)if not gp and p.Visible and(i.KeyCode==Enum.KeyCode.Escape or i.KeyCode==Enum.KeyCode.ButtonB)then if U.Page=="Home"then p.Visible=false else go("Home")end end end)
 local privacy=pl:GetAttributeChangedSignal("ACP_AllowAvatarCopy"):Connect(function()if p.Visible and U.Page=="Privacy"then go("Privacy")end end)
 p.Destroying:Connect(function()input:Disconnect();privacy:Disconnect();Worlds.Destroy()end)
 go("Home");return U
end
return M
