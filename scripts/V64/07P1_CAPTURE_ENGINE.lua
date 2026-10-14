-- 07P1_CAPTURE_ENGINE | ModuleScript | ReplicatedStorage | V64 (SUBSTITUIR)
-- Captura nativa atual, callback único, timeout e confirmação real do salvamento.
local Capture=game:GetService('CaptureService');local M={Version='V64'};local last;local active=false;local token=0;local prompt=false
function M.TakePhoto(image,onReady)
 if active or prompt then return false,'Uma captura já está em andamento.'end
 active=true;token=token+1;local mine=token
 local function done(ok,capture)
  if mine~=token or not active then return end;active=false
  if ok and capture then last=capture end
  if onReady then onReady(ok==true and capture~=nil)end
 end
 local ok,e=pcall(function()Capture:TakeScreenshotCaptureAsync(function(result,screenshot)
  done(result==Enum.ScreenshotCaptureResult.Success,screenshot)
 end,{UICaptureMode=Enum.UICaptureMode.None})end)
 if not ok then active=false;warn('[Photo V64] CAPTURE_START '..tostring(e));return false,'A captura nativa não está disponível. Atualize o Roblox ou teste no aplicativo publicado.'end
 task.delay(10,function()if mine==token and active then warn('[Photo V64] CAPTURE_TIMEOUT');done(false)end end)
 return true
end
local function finishPrompt(callback)
 local called=false
 return function(...)
  if called then return end;called=true;prompt=false;if callback then callback(...)end
 end
end
function M.SaveLast(callback)
 if not last then return false,'Tire uma foto antes de salvar.'end;if active or prompt then return false,'Aguarde o pedido atual.'end;prompt=true
 local done=finishPrompt(callback)
 local ok,e=pcall(function()Capture:PromptSaveCapturesToGallery({last},function(results)
  local saved=false;for _,value in pairs(type(results)=='table'and results or{})do if value==true then saved=true end end;done(saved)
 end)end)
 if not ok then done(false);warn('[Photo V64] SAVE_PROMPT '..tostring(e));return false,'A galeria do Roblox não abriu neste dispositivo.'end
 task.delay(30,function()done(false)end);return true
end
function M.ShareLast(accepted,denied)
 if not last then return false,'Tire uma foto antes de compartilhar.'end;if active or prompt then return false,'Aguarde o pedido atual.'end
 local ok,content=pcall(function()return Content.fromObject(last)end)
 if not ok or not content then return false,'Esta captura não pode ser compartilhada. Salve-a na galeria.'end
 prompt=true;local done=finishPrompt(function(value)if value then if accepted then accepted()end elseif denied then denied()end end)
 local opened,e=pcall(function()Capture:PromptShareCapture(content,'',function()done(true)end,function()done(false)end)end)
 if not opened then done(false);warn('[Photo V64] SHARE_PROMPT '..tostring(e));return false,'O Roblox não abriu o compartilhamento.'end
 task.delay(30,function()done(false)end);return true
end
function M.HasLast()return last~=nil end
return M
