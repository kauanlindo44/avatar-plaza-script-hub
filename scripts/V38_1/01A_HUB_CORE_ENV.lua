-- 01A_HUB_CORE_ENV
-- Script | ServerScriptService
-- AVATAR PLAZA V38.1 - ambiente mint/sky limpo e consistente.

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
  local e=Instance.new("RemoteEvent")
  e.Name=name
  e.Parent=rem
 end
end

local oldWorld=workspace:FindFirstChild("PracaAvatar_V2")
if oldWorld then oldWorld:Destroy()end
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
kit:SetAttribute("EnvironmentDefault","MINT_FIELD")
if kit:GetAttribute("PlusGamePassId")==nil then
 kit:SetAttribute("PlusGamePassId",0)
end

for _,obj in ipairs(Lighting:GetChildren())do
 if obj.Name:match("^ACP_")then obj:Destroy()end
end
if Terrain then
 local oldClouds=Terrain:FindFirstChild("ACP_Clouds")
 if oldClouds then oldClouds:Destroy()end
end

Lighting.ClockTime=14.2
Lighting.Brightness=2.05
Lighting.ExposureCompensation=-0.08
Lighting.GlobalShadows=true
Lighting.ShadowSoftness=0.48
Lighting.Ambient=Color3.fromRGB(135,153,151)
Lighting.OutdoorAmbient=Color3.fromRGB(186,206,201)
Lighting.EnvironmentDiffuseScale=0.72
Lighting.EnvironmentSpecularScale=0.58
Lighting.ColorShift_Top=Color3.fromRGB(225,242,238)
Lighting.ColorShift_Bottom=Color3.fromRGB(203,225,218)
pcall(function()
 Lighting.Technology=Enum.Technology.ShadowMap
end)

local atmosphere=Instance.new("Atmosphere")
atmosphere.Name="ACP_V381_Atmosphere"
atmosphere.Density=0.18
atmosphere.Offset=0.04
atmosphere.Color=Color3.fromRGB(199,226,221)
atmosphere.Decay=Color3.fromRGB(128,164,160)
atmosphere.Haze=0.32
atmosphere.Glare=0.012
atmosphere.Parent=Lighting

local color=Instance.new("ColorCorrectionEffect")
color.Name="ACP_V381_Color"
color.Brightness=0.005
color.Contrast=0.035
color.Saturation=-0.055
color.TintColor=Color3.fromRGB(242,250,247)
color.Parent=Lighting

if Terrain then
 local clouds=Instance.new("Clouds")
 clouds.Name="ACP_Clouds"
 clouds.Color=Color3.fromRGB(239,248,246)
 clouds.Cover=0.30
 clouds.Density=0.42
 clouds.Parent=Terrain
end

kit:SetAttribute("LightingReady",true)
kit:SetAttribute("CoreReady",true)
print("AVATAR PLAZA V38.1: ambiente mint/sky carregado")
