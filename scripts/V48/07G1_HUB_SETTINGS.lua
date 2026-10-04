-- 07G1_HUB_SETTINGS | ModuleScript | ReplicatedStorage
-- V44: categorias coloridas, comandos pessoais e privacidade com X fixo.
local Rep=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local D=require(Rep:WaitForChild("07UI_DESIGN_SYSTEM"));local C=D.Colors
local Worlds=require(Rep:WaitForChild("07G2_LOCAL_WORLDS"))
local Tools=require(Rep:WaitForChild("07G3_PERSONAL_TOOLS"))
local pl=game:GetService("Players").LocalPlayer
local M={}
function M.Build(root,pg,onCompact,toast)
 local U={Page="Home"}
 U.Panel=D.Frame(root,{Name="Settings",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),BackgroundColor3=C.panel,Visible=false,ZIndex=40})
 local p=U.Panel
 U.Title=D.Text(p,"Configurações",{TextSize=24,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=41})
 U.Close=D.IconButton(p,"CloseCfg","close","Fechar configurações",{Size=UDim2.fromOffset(48,48),ZIndex=49})
 U.Back=D.Button(p,"‹ Voltar",{Size=UDim2.fromOffset(96,40),Visible=false,ZIndex=42})
 U.Body=D.New("Frame",{Name="SettingsCategories",BackgroundTransparency=1,ZIndex=41},p)
 local pageButtons={};local go
 local function clear()
  for _,o in ipairs(U.Body:GetChildren())do o:Destroy()end;pageButtons={}
 end
 local function card(name,caption,note,color,fn)
  local b=D.Button(U.Body,"",{Name=name,BackgroundColor3=color,ZIndex=42})
  D.Text(b,caption,{Position=UDim2.fromOffset(12,8),Size=UDim2.new(1,-24,0,26),TextSize=18,Font=Enum.Font.GothamBold,TextColor3=C.bg,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd,Active=false,ZIndex=43})
  D.Text(b,note,{Position=UDim2.fromOffset(12,38),Size=UDim2.new(1,-24,1,-46),TextSize=13,TextColor3=C.bg,TextXAlignment=Enum.TextXAlignment.Left,Active=false,ZIndex=43})
  b.Activated:Connect(fn);table.insert(pageButtons,b);return b
 end
 go=function(page)
  U.Page=page;clear();U.Back.Visible=page~="Home"
  if page=="Home"then
   U.Title.Text="Configurações"
   card("ChangeWorld","Mudar mundo","Escolha o visual da sua praça",C.blue,function()go("World")end)
   card("Sound","Som","Música e ambiente",C.pink,function()go("Sound")end)
   card("Camera","Câmera","Distância do seu campo de visão",C.green,function()go("Camera")end)
   card("Interface","Interface","Tamanho dos atalhos",C.yellow,function()go("Interface")end)
   card("Privacy","Privacidade","Controle o uso do seu avatar",C.purple,function()go("Privacy")end)
   card("Commands","Comandos","Movimento apenas do seu personagem",C.cyan,function()go("Commands")end)
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
   U.Title.Text="Comandos pessoais";local d=Tools.Call("get")or{speed=16,jump=50,size=1,fly=false}
   local function set(key,value)local ok,e=Tools.Call(key,value);toast(ok and"Ajuste aplicado ao seu personagem."or e);go("Commands")end
   card("Speed","Correr",d.speed>16 and"Rápido • toque para normal"or"Normal • toque para rápido",C.blue,function()set("speed",d.speed>16 and 16 or 28)end)
   card("Jump","Pular",d.jump>50 and"Alto • toque para normal"or"Normal • toque para alto",C.green,function()set("jump",d.jump>50 and 50 or 72)end)
   card("Fly","Voar",d.fly and"Ligado • toque para pousar"or"Desligado • use pulo para subir",C.purple,function()set("fly",not d.fly)end)
   card("Size","Tamanho",d.size>1 and"Ampliado • toque para normal"or"Normal • ampliar até 10%",C.yellow,function()set("size",d.size>1 and 1 or 1.1)end)
   card("ResetCommands","Restaurar","Limites normais • sem afetar outros",C.pink,function()set("reset")end)
  else
   U.Title.Text="Interface"
   card("Automatic","Automática","Adapta os atalhos à tela",C.green,function()onCompact(false);toast("Interface automática.")end)
   card("Compact","Compacta","Atalhos menores",C.blue,function()onCompact(true);toast("Interface compacta.")end)
   card("ResetCfg","Restaurar","Praça original, câmera e interface",C.yellow,function()
    Worlds.Apply("ORIGINAL");onCompact(false);local cam=workspace.CurrentCamera;if cam then cam.FieldOfView=70 end;pg:SetAttribute("ACP_MusicEnabled",true);go("Home");toast("Configurações restauradas.")
   end)
  end
  U.Layout()
 end
 function U.Layout()
  local w,h=root.AbsoluteSize.X,root.AbsoluteSize.Y;if w<1 or h<1 then return end
  local pw,ph=math.min(760,w-16),math.min(482,h-16);p.Size=UDim2.fromOffset(pw,ph)
  U.Title.Position=UDim2.fromOffset(16,8);U.Title.Size=UDim2.new(1,-84,0,44)
  U.Close.Position=UDim2.new(1,-56,0,6)
  U.Back.Position=UDim2.fromOffset(12,58)
  local y=U.Back.Visible and 106 or 64;U.Body.Position=UDim2.fromOffset(12,y);U.Body.Size=UDim2.fromOffset(pw-24,ph-y-12)
  local cols=U.Page=="World"and pw>=600 and 3 or 2;local rows=math.max(1,math.ceil(#pageButtons/cols))
  local bw,bh=(pw-24-(cols-1)*8)/cols,(ph-y-12-(rows-1)*8)/rows
  for i,b in ipairs(pageButtons)do b.Position=UDim2.fromOffset((i-1)%cols*(bw+8),math.floor((i-1)/cols)*(bh+8));b.Size=UDim2.fromOffset(bw,bh)end
 end
 U.Close.Activated:Connect(function()p.Visible=false end)
 U.Back.Activated:Connect(function()go("Home")end)
 p:GetPropertyChangedSignal("Visible"):Connect(function()if p.Visible then go("Home")end;if U.OnVisibility then U.OnVisibility()end end)
 root:GetPropertyChangedSignal("AbsoluteSize"):Connect(U.Layout)
 local input=UIS.InputBegan:Connect(function(i,gp)if not gp and p.Visible and(i.KeyCode==Enum.KeyCode.Escape or i.KeyCode==Enum.KeyCode.ButtonB)then if U.Page=="Home"then p.Visible=false else go("Home")end end end)
 local privacy=pl:GetAttributeChangedSignal("ACP_AllowAvatarCopy"):Connect(function()if p.Visible and U.Page=="Privacy"then go("Privacy")end end)
 p.Destroying:Connect(function()input:Disconnect();privacy:Disconnect();Worlds.Destroy()end)
 go("Home");return U
end
return M
