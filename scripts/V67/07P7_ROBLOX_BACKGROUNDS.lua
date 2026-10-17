-- 07P7_ROBLOX_BACKGROUNDS | ModuleScript | ReplicatedStorage | V67 (SUBSTITUIR)
-- A prova deve entrar no render: fora da tela/transparência 1 mantém IsLoaded falso.
local Content=game:GetService('ContentProvider');local Rep=game:GetService('ReplicatedStorage')
local M={Version='V67',Protocol=2}
local function valid(uri)return type(uri)=='string'and(uri:match('^rbxassetid://%d+$')or uri:match('^rbxasset://textures/[%w_%.%/%-]+$'))end
function M.Image(background,alive)
 local id=background and tonumber(background.id);if not id or id%1~=0 or id<=0 then return nil,'Escolha um fundo da loja Roblox.'end
 local rem=Rep:FindFirstChild('LMShop_Remotes');local rpc=rem and rem:FindFirstChild('Request');if not rpc then return nil,'Servidor de fundos desconectado.'end
 local done=false;local ok,r;task.spawn(function()ok,r=pcall(function()return rpc:InvokeServer('PhotoBackground',{id=id})end);done=true end)
 local deadline=os.clock()+15;while not done and os.clock()<deadline and(not alive or alive())do task.wait(.05)end
 if alive and not alive()then return nil,'Seleção cancelada.'end
 if not done then return nil,'A consulta do fundo demorou. Tente novamente.'end
 if not ok or type(r)~='table'or not r.ok then return nil,type(r)=='table'and r.error or'O servidor não confirmou esse fundo.'end
 local v=r.data;if type(v)~='table'or v.id~=id or v.source~='RobloxCatalog'or v.preview~=true then return nil,'Servidor de fundos incompatível. Confira a instalação V67.'end
 local images=v.images or{v.image};local host=Instance.new('ScreenGui');host.Name='ACP_BackgroundProbe';host.ResetOnSpawn=false;host.Enabled=true;host.IgnoreGuiInset=true;host.DisplayOrder=230
 host.Parent=game:GetService('Players').LocalPlayer:WaitForChild('PlayerGui')
 local probe=Instance.new('ImageLabel');probe.Name='RenderProbe';probe.Size=UDim2.fromOffset(32,32);probe.AnchorPoint=Vector2.new(.5,.5);probe.Position=UDim2.fromScale(.5,.5)
 probe.BackgroundTransparency=1;probe.ImageTransparency=.99;probe.Visible=true;probe.Active=false;probe.Parent=host
 local attempt=0;local selected,stage;local overall=os.clock()+16;local lastStatus='NotStarted'
 for i,uri in ipairs(images)do if i>4 or os.clock()>=overall then break end
  if valid(uri)then
   attempt=i;probe.Image=uri;local finished=false;local success=false;local called=false;local mine=i
   task.spawn(function()
    local worked,cause=pcall(function()Content:PreloadAsync({probe},function(_,status)
     if mine~=attempt then return end;called=true;lastStatus=status.Name;success=status.Name=='Success'
    end)end);if not worked then lastStatus=tostring(cause)end;finished=true
   end)
   local untilTime=math.min(overall,os.clock()+8)
   while(not finished or not probe.IsLoaded)and os.clock()<untilTime and(not alive or alive())do task.wait(.05)end
   if finished and probe.IsLoaded and(not called or success)then selected=uri;stage='RENDER_CONFIRMED';break end
  end
 end
 host:Destroy();if alive and not alive()then return nil,'Seleção cancelada.'end
 if not selected then
  warn('[Photo V67] BACKGROUND_RENDER | id='..id..' | resolver='..tostring(v.version)..' | fetch='..lastStatus)
  return nil,'A imagem não terminou de renderizar. O fundo anterior foi mantido; confira BACKGROUND_RENDER no Output.'
 end
 background.image=selected;background.color=v.color;background.name=v.name;background.preview=true;background.source='RobloxCatalog';background.quality=stage
 return background
end
return M
