-- 09C9_PLAYER_INSPECT | ModuleScript | ReplicatedStorage | V44
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local M={}
function M.Init(ctx)
 local pl=Players.LocalPlayer;local last=0
 local c=UIS.InputBegan:Connect(function(input,processed)
  if processed or(input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch)then return end
  if ctx.U.Root.Visible or pl:GetAttribute("ACP_InGameRoom")or os.clock()-last<.8 then return end
  local camera=workspace.CurrentCamera;if not camera then return end
  local ray=camera:ViewportPointToRay(input.Position.X,input.Position.Y);local hit=workspace:Raycast(ray.Origin,ray.Direction*100)
  local model=hit and hit.Instance:FindFirstAncestorOfClass("Model");local other=model and Players:GetPlayerFromCharacter(model)
  if not other or other==pl then return end;last=os.clock()
  task.spawn(function()
   local r,e=ctx.call("InspectAvatar",{id=other.UserId});if not r then ctx.toast(e);return end
   ctx.open();ctx.show(r)
  end)
 end)
 return c
end
return M
