-- 01A_HUB_CORE_ENV
-- Script | ServerScriptService
-- AVATAR PLAZA V36C - iluminação clara, alegre e leve para o Avatar World.
-- Preserva PracaKit/remotes existentes e recria apenas o mundo 3D.

local Rep=game:GetService("ReplicatedStorage")
local Lighting=game:GetService("Lighting")

local kit=Rep:FindFirstChild("PracaKit")
if not kit then
 kit=Instance.new("Folder")
 kit.Name="PracaKit"
 kit.Parent=Rep
end

local remotes=kit:FindFirstChild("Remotes")
if not remotes then
 remotes=Instance.new("Folder")
 remotes.Name="Remotes"
 remotes.Parent=kit
end
for _,name in ipairs({"HubGameUI","HubTeleport","FashionUI"})do
 if not remotes:FindFirstChild(name)then
  local e=Instance.new("RemoteEvent")
  e.Name=name
  e.Parent=remotes
 end
end

local oldWorld=workspace:FindFirstChild("PracaAvatar_V2")
if oldWorld then oldWorld:Destroy() end
local world=Instance.new("Folder")
world.Name="PracaAvatar_V2"
world.Parent=workspace

local O=Vector3.new(0,60,0)
kit:SetAttribute("OriginX",O.X)
kit:SetAttribute("OriginY",O.Y)
kit:SetAttribute("OriginZ",O.Z)
kit:SetAttribute("HubVersion","36C")
kit:SetAttribute("BaseReady",false)
kit:SetAttribute("ActivitiesReady",false)
kit:SetAttribute("FashionReady",false)
kit:SetAttribute("EnvironmentDefault","SKY")

Lighting.ClockTime=13.55
Lighting.Brightness=2.9
Lighting.GlobalShadows=true
Lighting.ShadowSoftness=.33
Lighting.ExposureCompensation=.10
Lighting.Ambient=Color3.fromRGB(164,182,196)
Lighting.OutdoorAmbient=Color3.fromRGB(214,228,238)
Lighting.EnvironmentDiffuseScale=.72
Lighting.EnvironmentSpecularScale=.76
Lighting.ColorShift_Top=Color3.fromRGB(236,247,255)
Lighting.ColorShift_Bottom=Color3.fromRGB(235,245,250)
pcall(function()Lighting.Technology=Enum.Technology.ShadowMap end)

for _,n in ipairs({"ACP_V36C_Atmosphere","ACP_V36C_Color","ACP_V35Atmosphere","ACP_V35Color","ACP_V34Atmosphere","ACP_V34Color","ACP_V34Bloom","ACP_V34Rays","ACP_MapAtmosphere","ACP_MapColor","ACP_MapBloom","ACP_MapSunRays"})do
 local x=Lighting:FindFirstChild(n)
 if x then x:Destroy() end
end

local a=Instance.new("Atmosphere")
a.Name="ACP_V36C_Atmosphere"
a.Density=.11
a.Offset=.01
a.Color=Color3.fromRGB(214,236,245)
a.Decay=Color3.fromRGB(181,211,223)
a.Haze=.36
a.Glare=.02
a.Parent=Lighting

local cc=Instance.new("ColorCorrectionEffect")
cc.Name="ACP_V36C_Color"
cc.Brightness=.02
cc.Contrast=.03
cc.Saturation=.045
cc.TintColor=Color3.fromRGB(247,251,255)
cc.Parent=Lighting

kit:SetAttribute("LightingReady",true)
kit:SetAttribute("CoreReady",true)
print("AVATAR PLAZA V36C: core do Avatar World carregado")
