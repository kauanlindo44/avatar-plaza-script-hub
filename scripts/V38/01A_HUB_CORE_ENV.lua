-- 01A_HUB_CORE_ENV
-- Script | ServerScriptService
-- AVATAR PLAZA V38 - core visual limpo e neutro para o Avatar Field.
-- Recria o mundo principal, preserva PracaKit/remotes e prepara um ambiente claro sem estourar cores.

local Rep=game:GetService("ReplicatedStorage")
local Lighting=game:GetService("Lighting")

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
kit:SetAttribute("HubVersion","38")
kit:SetAttribute("BaseReady",false)
kit:SetAttribute("ActivitiesReady",false)
kit:SetAttribute("FashionReady",false)
kit:SetAttribute("EnvironmentDefault","FIELD")
if kit:GetAttribute("PlusGamePassId")==nil then kit:SetAttribute("PlusGamePassId",0)end

Lighting.ClockTime=13.8
Lighting.Brightness=2.15
Lighting.GlobalShadows=true
Lighting.ShadowSoftness=.42
Lighting.ExposureCompensation=-.06
Lighting.Ambient=Color3.fromRGB(146,153,163)
Lighting.OutdoorAmbient=Color3.fromRGB(188,198,208)
Lighting.EnvironmentDiffuseScale=.70
Lighting.EnvironmentSpecularScale=.66
Lighting.ColorShift_Top=Color3.fromRGB(236,243,249)
Lighting.ColorShift_Bottom=Color3.fromRGB(221,228,233)
pcall(function()Lighting.Technology=Enum.Technology.ShadowMap end)

for _,obj in ipairs(Lighting:GetChildren())do
 if obj.Name:match("^ACP_V3%d_")or obj.Name:match("^ACP_V2%d_")then obj:Destroy()end
end

local atmosphere=Instance.new("Atmosphere")
atmosphere.Name="ACP_V38_Atmosphere"
atmosphere.Density=.13
atmosphere.Offset=.02
atmosphere.Color=Color3.fromRGB(205,224,234)
atmosphere.Decay=Color3.fromRGB(146,163,174)
atmosphere.Haze=.22
atmosphere.Glare=.008
atmosphere.Parent=Lighting

local color=Instance.new("ColorCorrectionEffect")
color.Name="ACP_V38_Color"
color.Brightness=0
color.Contrast=.035
color.Saturation=-.025
color.TintColor=Color3.fromRGB(248,250,252)
color.Parent=Lighting

kit:SetAttribute("LightingReady",true)
kit:SetAttribute("CoreReady",true)
print("AVATAR PLAZA V38: core visual carregado")
