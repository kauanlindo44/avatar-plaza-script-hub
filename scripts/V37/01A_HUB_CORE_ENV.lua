-- 01A_HUB_CORE_ENV
-- Script | ServerScriptService
-- AVATAR PLAZA V37 - core/iluminação do Catalog Field refinado.
-- Recria o mundo 3D, preserva PracaKit/remotes e evita o clarão da V36C.

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
  local e=Instance.new("RemoteEvent")
  e.Name=name
  e.Parent=rem
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
kit:SetAttribute("HubVersion","37")
kit:SetAttribute("BaseReady",false)
kit:SetAttribute("ActivitiesReady",false)
kit:SetAttribute("FashionReady",false)
kit:SetAttribute("EnvironmentDefault","ORIGINAL")

-- Opcional: se no futuro existir um game pass PLUS próprio do jogo,
-- basta colocar o ID neste atributo no Studio. Com 0, o botão PLUS tenta Roblox Premium.
if kit:GetAttribute("PlusGamePassId")==nil then
 kit:SetAttribute("PlusGamePassId",0)
end

Lighting.ClockTime=13.6
Lighting.Brightness=2.25
Lighting.GlobalShadows=true
Lighting.ShadowSoftness=.38
Lighting.ExposureCompensation=-.03
Lighting.Ambient=Color3.fromRGB(138,146,158)
Lighting.OutdoorAmbient=Color3.fromRGB(188,199,211)
Lighting.EnvironmentDiffuseScale=.68
Lighting.EnvironmentSpecularScale=.70
Lighting.ColorShift_Top=Color3.fromRGB(229,239,248)
Lighting.ColorShift_Bottom=Color3.fromRGB(214,224,231)
pcall(function()
 Lighting.Technology=Enum.Technology.ShadowMap
end)

for _,name in ipairs({
 "ACP_V37_Atmosphere","ACP_V37_Color",
 "ACP_V36D_Atmosphere","ACP_V36D_Color",
 "ACP_V36C_Atmosphere","ACP_V36C_Color",
 "ACP_V35Atmosphere","ACP_V35Color"
})do
 local x=Lighting:FindFirstChild(name)
 if x then x:Destroy()end
end

local atmosphere=Instance.new("Atmosphere")
atmosphere.Name="ACP_V37_Atmosphere"
atmosphere.Density=.16
atmosphere.Offset=.015
atmosphere.Color=Color3.fromRGB(197,220,232)
atmosphere.Decay=Color3.fromRGB(129,151,166)
atmosphere.Haze=.32
atmosphere.Glare=.012
atmosphere.Parent=Lighting

local color=Instance.new("ColorCorrectionEffect")
color.Name="ACP_V37_Color"
color.Brightness=.005
color.Contrast=.045
color.Saturation=.035
color.TintColor=Color3.fromRGB(244,248,251)
color.Parent=Lighting

kit:SetAttribute("LightingReady",true)
kit:SetAttribute("CoreReady",true)
print("AVATAR PLAZA V37: core Catalog Field carregado")
