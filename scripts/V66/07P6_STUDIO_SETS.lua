-- 07P6_STUDIO_SETS | ModuleScript | ReplicatedStorage | V66 (SUBSTITUIR)
-- Plano de imagem do Roblox atrás da cópia; sem cenários decorativos criados por script.
local M={}
function M.Build(folder,center,floorY,preset)
 local room=Instance.new('Model');room.Name='RobloxProfileBackdrop';room.Parent=folder
 local plane=Instance.new('Part');plane.Name='ProfileImagePlane';plane.Anchored=true;plane.CanCollide=false;plane.CanTouch=false;plane.CanQuery=false;plane.CastShadow=false;plane.Transparency=1;plane.Parent=room
 local gui=Instance.new('SurfaceGui');gui.Name='ProfileImageSurface';gui.Adornee=plane;gui.Face=Enum.NormalId.Front;gui.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize;gui.CanvasSize=Vector2.new(1600,900);gui.LightInfluence=0;gui.AlwaysOnTop=false;gui.Parent=plane
 local image=Instance.new('ImageLabel');image.Name='RobloxProfileImage';image.Size=UDim2.fromScale(1,1);image.BorderSizePixel=0;image.BackgroundColor3=preset and type(preset.color)=='table'and Color3.new(table.unpack(preset.color))or Color3.fromRGB(113,122,139);image.Image=preset and preset.image or'';image.ScaleType=Enum.ScaleType.Crop;image.Active=false;image.Parent=gui
 local S={Alive=true,Backdrop=plane,Model=room,Image=image,Animated=false,Count=1}
 function S.Update(camera)
  if not S.Alive or not camera then return end
  local distance=(camera.CFrame.Position-center).Magnitude+60;local h=2*distance*math.tan(math.rad(camera.FieldOfView)*.5)*1.03
  local aspect=math.max(1,camera.ViewportSize.X)/math.max(1,camera.ViewportSize.Y)
  plane.Size=Vector3.new(h*aspect,h,.1);plane.CFrame=camera.CFrame*CFrame.new(0,0,-distance)*CFrame.Angles(0,math.pi,0)
 end
 function S.SetAnimated()end
 function S.Destroy()if not S.Alive then return end;S.Alive=false;if S.Connection then S.Connection:Disconnect()end;room:Destroy()end
 S.Connection=folder.Destroying:Connect(S.Destroy);return S
end
return M
