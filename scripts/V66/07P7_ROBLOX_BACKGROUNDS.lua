-- 07P7_ROBLOX_BACKGROUNDS | ModuleScript | ReplicatedStorage | V66 (SUBSTITUIR)
-- Loja de fundos Roblox e imagem confirmada antes de substituir o fundo.
local Avatar=game:GetService('AvatarEditorService');local Content=game:GetService('ContentProvider');local Rep=game:GetService('ReplicatedStorage')
local M={Version='V66',Protocol=2}
function M.Image(background,alive)
 local id=background and tonumber(background.id)
 if not id or id%1~=0 or id<=0 then return nil,'Escolha um fundo da consulta nativa do Roblox.'end
 local rem=Rep:FindFirstChild('LMShop_Remotes');local rpc=rem and rem:FindFirstChild('Request')
 if not rpc then return nil,'O servidor de fundos ainda não conectou.'end
 local done=false;local ok,r;task.spawn(function()ok,r=pcall(function()return rpc:InvokeServer('PhotoBackground',{id=id})end);done=true end)
 local waitUntil=os.clock()+15;while not done and os.clock()<waitUntil and(not alive or alive())do task.wait(.05)end
 if not done then return nil,'O servidor de fundos demorou. O fundo anterior foi mantido; toque novamente para tentar.'end
 if alive and not alive()then return nil,'Seleção cancelada.'end
 if not ok or not r or not r.ok then return nil,r and r.error or'O Roblox não confirmou esse fundo.'end
 local value=r.data;if not value or value.source~='RobloxCatalog'or value.preview~=true or not tostring(value.image):match('^rbxassetid://%d+$')then return nil,'A referência do fundo não foi confirmada.'end
 local host=Instance.new('ScreenGui');host.Name='ACP_BackgroundProbe';host.ResetOnSpawn=false;host.DisplayOrder=-50;host.Parent=game:GetService('Players').LocalPlayer:WaitForChild('PlayerGui')
 local probe=Instance.new('ImageLabel');probe.Size=UDim2.fromOffset(1,1);probe.Position=UDim2.fromOffset(-4096,-4096);probe.ImageTransparency=1;probe.Active=false;probe.Parent=host;probe.Image=value.image
 local fetched=false;local finished=false;local loaded;task.spawn(function()loaded=pcall(function()Content:PreloadAsync({probe},function(_,status)fetched=status==Enum.AssetFetchStatus.Success end)end);finished=true end)
 local deadline=os.clock()+8
 while(not finished or not probe.IsLoaded)and os.clock()<deadline and(not alive or alive())do task.wait(.05)end
 local success=finished and loaded and fetched and probe.IsLoaded;probe:Destroy()
 if not success and(not alive or alive())and tostring(value.thumbnail):match('^rbxthumb://type=Asset&id=%d+&w=420&h=420$')then
  local expected='rbxthumb://type=Asset&id='..string.format('%.0f',id)..'&w=420&h=420'
  if value.thumbnail==expected then
   local thumb=Instance.new('ImageLabel');thumb.Size=UDim2.fromOffset(1,1);thumb.ImageTransparency=1;thumb.Position=UDim2.fromOffset(-4096,-4096);thumb.Active=false;thumb.Parent=host;thumb.Image=value.thumbnail;local ready=false;local got=false
   task.spawn(function()got=pcall(function()Content:PreloadAsync({thumb})end);ready=true end)
   local untilTime=os.clock()+6;while(not ready or not thumb.IsLoaded)and os.clock()<untilTime and(not alive or alive())do task.wait(.05)end
   success=ready and got and thumb.IsLoaded;thumb:Destroy();if success then value.image=value.thumbnail;value.stage='STORE_THUMBNAIL'end
  end
 end
 host:Destroy()
 if alive and not alive()then return nil,'Seleção cancelada.'end
 if not success then warn('[Photo V66] BACKGROUND_DECODE id='..id..' etapa=IMAGE_DECODE resolver='..tostring(value.stage));return nil,'O Roblox reconheceu o fundo, mas não liberou uma imagem utilizável neste jogo. O fundo anterior foi mantido.'end
 background.color=value.color;background.image=value.image;background.name=value.name;background.preview=true;background.source='RobloxCatalog';background.quality=value.stage;return background
end
return M
