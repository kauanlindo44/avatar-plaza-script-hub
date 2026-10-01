-- 01A_HUB_CORE_ENV
-- Script | ServerScriptService
-- AVATAR PLAZA V38.1 - ambiente limpo para campo de avatares.
-- O ceu, a luz e o chao usam a mesma familia fria/sage sem neon excessivo.

local Rep=game:GetService("ReplicatedStorage")
local Lighting=game:GetService("Lighting")
local Terrain=workspace:FindFirstChildOfClass("Terrain")

local kit=Rep:FindFirstChild("PracaKit")
if not kit then
 kit=Instance.new("Folder")
 kit.Name="PracaKit"
 kit.Parent=Rep
end

local rem=kit:FindFirstChild("Remotes")
if not rem then
 rem=Instance.new("Folder")
 rem.Name="Remotes"
 rem.Parent=kit
end

for _,name in ipairs({"HubGameUI","HubTeleport","FashionUI"})do
 if not rem:FindFirstChild(name)then
  local event=Instance.new("RemoteEvent")
  event.Name=name
  event.Parent=rem
 end
end

local old=workspace:FindFirstChild("PracaAvatar_V2")
if old then old:Destroy()end

local world=Instance.new("Folder")
world.Name="PracaAvatar_V2"
world.Parent=workspace

local O=Vector3.new(0,60,0)
kit:SetAttribute("OriginX",O.X)
kit:SetAttribute("OriginY",O.Y)
kit:SetAttribute("OriginZ",O.Z)
kit:SetAttribute("HubVersion","38.1")
kit:SetAttribute("BaseReady",false)
kit:SetAttribute("ActivitiesReady",false)
kit:SetAttribute("FashionReady",false)
kit:SetAttribute("EnvironmentDefault","FIELD")
if kit:GetAttribute("PlusGamePassId")==nil then
 kit:SetAttribute("PlusGamePassId",0)
end

Lighting.ClockTime=13.2
Lighting.Brightness=2.0
Lighting.GlobalShadows=true
Lighting.ShadowSoftness=.48
Lighting.ExposureCompensation=-.05
Lighting.Ambient=Color3.fromRGB(139,158,156)
Lighting.OutdoorAmbient=Color3.fromRGB(184,205,202)
Lighting.EnvironmentDiffuseScale=.72
Lighting.EnvironmentSpecularScale=.58
Lighting.ColorShift_Top=Color3.fromRGB(224,239,236)
Lighting.ColorShift_Bottom=Color3.fromRGB(191,213,208)
pcall(function()
 Lighting.Technology=Enum.Technology.ShadowMap
end)

for _,obj in ipairs(Lighting:GetChildren())do
 if obj.Name:match("^ACP_V")then
  obj:Destroy()
 end
end

local atmosphere=Instance.new("Atmosphere")
atmosphere.Name="ACP_V38_1_Atmosphere"
atmosphere.Density=.18
atmosphere.Offset=.04
atmosphere.Color=Color3.fromRGB(183,215,213)
atmosphere.Decay=Color3.fromRGB(105,137,140)
atmosphere.Haze=.38
atmosphere.Glare=.01
atmosphere.Parent=Lighting

local color=Instance.new("ColorCorrectionEffect")
color.Name="ACP_V38_1_Color"
color.Brightness=.005
color.Contrast=.025
color.Saturation=-.06
color.TintColor=Color3.fromRGB(242,249,246)
color.Parent=Lighting

if Terrain then
 local clouds=Terrain:FindFirstChild("ACP_V38_1_Clouds")
 if not clouds then
  clouds=Instance.new("Clouds")
  clouds.Name="ACP_V38_1_Clouds"
  clouds.Parent=Terrain
 end
 clouds.Color=Color3.fromRGB(227,239,235)
 clouds.Cover=.22
 clouds.Density=.28
end

kit:SetAttribute("LightingReady",true)
kit:SetAttribute("CoreReady",true)
print("AVATAR PLAZA V38.1: ambiente carregado")
