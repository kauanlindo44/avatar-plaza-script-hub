-- 01A_HUB_CORE_ENV
-- Script | ServerScriptService
-- AVATAR PLAZA V36D - core do Catalog Studio Plaza.
-- Iluminação neutra, sem clarão; preserva PracaKit/remotes e recria apenas o mundo 3D.

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
kit:SetAttribute("HubVersion","36D")
kit:SetAttribute("BaseReady",false)
kit:SetAttribute("ActivitiesReady",false)
kit:SetAttribute("FashionReady",false)
kit:SetAttribute("EnvironmentDefault","CYAN")

Lighting.ClockTime=14.15
Lighting.Brightness=2.15
Lighting.GlobalShadows=true
Lighting.ShadowSoftness=.48
Lighting.ExposureCompensation=-.08
Lighting.Ambient=Color3.fromRGB(126,132,145)
Lighting.OutdoorAmbient=Color3.fromRGB(170,179,193)
Lighting.EnvironmentDiffuseScale=.62
Lighting.EnvironmentSpecularScale=.68
Lighting.ColorShift_Top=Color3.fromRGB(220,230,240)
Lighting.ColorShift_Bottom=Color3.fromRGB(188,199,211)
pcall(function()Lighting.Technology=Enum.Technology.ShadowMap end)

for _,n in ipairs({
 "ACP_V36D_Atmosphere","ACP_V36D_Color",
 "ACP_V36C_Atmosphere","ACP_V36C_Color",
 "ACP_V35Atmosphere","ACP_V35Color",
 "ACP_V34Atmosphere","ACP_V34Color","ACP_V34Bloom","ACP_V34Rays",
 "ACP_MapAtmosphere","ACP_MapColor","ACP_MapBloom","ACP_MapSunRays"
})do
 local x=Lighting:FindFirstChild(n)
 if x then x:Destroy() end
end

local a=Instance.new("Atmosphere")
a.Name="ACP_V36D_Atmosphere"
a.Density=.19
a.Offset=.03
a.Color=Color3.fromRGB(190,207,220)
a.Decay=Color3.fromRGB(112,128,145)
a.Haze=.45
a.Glare=.01
a.Parent=Lighting

local cc=Instance.new("ColorCorrectionEffect")
cc.Name="ACP_V36D_Color"
cc.Brightness=-.015
cc.Contrast=.065
cc.Saturation=.04
cc.TintColor=Color3.fromRGB(238,242,248)
cc.Parent=Lighting

kit:SetAttribute("LightingReady",true)
kit:SetAttribute("CoreReady",true)
print("AVATAR PLAZA V36D: core Catalog Studio Plaza carregado")
