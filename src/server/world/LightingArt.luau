--!strict

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LightingArt = {}

function LightingArt.Apply()
	Lighting.ClockTime = 14.15
	Lighting.Brightness = 2.15
	Lighting.ExposureCompensation = -0.08
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.3
	Lighting.EnvironmentDiffuseScale = 0.5
	Lighting.EnvironmentSpecularScale = 0.46
	Lighting.Ambient = Color3.fromRGB(78, 87, 97)
	Lighting.OutdoorAmbient = Color3.fromRGB(133, 139, 148)
	Lighting.ColorShift_Top = Color3.fromRGB(255, 244, 228)
	Lighting.ColorShift_Bottom = Color3.fromRGB(215, 226, 235)

	local colorCorrection = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
	if colorCorrection == nil then
		colorCorrection = Instance.new("ColorCorrectionEffect")
		colorCorrection.Name = "RepairEmpireColor"
		colorCorrection.Parent = Lighting
	end
	colorCorrection.Brightness = 0.015
	colorCorrection.Contrast = 0.12
	colorCorrection.Saturation = 0.05
	colorCorrection.TintColor = Color3.fromRGB(255, 247, 235)

	local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
	if bloom == nil then
		bloom = Instance.new("BloomEffect")
		bloom.Name = "RepairEmpireBloom"
		bloom.Parent = Lighting
	end
	bloom.Intensity = 0.1
	bloom.Size = 16
	bloom.Threshold = 1.95

	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosphere == nil then
		atmosphere = Instance.new("Atmosphere")
		atmosphere.Name = "RepairEmpireAtmosphere"
		atmosphere.Parent = Lighting
	end
	atmosphere.Density = 0.18
	atmosphere.Offset = 0.03
	atmosphere.Glare = 0.05
	atmosphere.Haze = 0.9
	atmosphere.Color = Color3.fromRGB(216, 228, 237)
	atmosphere.Decay = Color3.fromRGB(124, 139, 151)

	local sunRays = Lighting:FindFirstChildOfClass("SunRaysEffect")
	if sunRays == nil then
		sunRays = Instance.new("SunRaysEffect")
		sunRays.Name = "RepairEmpireSunRays"
		sunRays.Parent = Lighting
	end
	sunRays.Intensity = 0.025
	sunRays.Spread = 0.68

	local terrain = Workspace:FindFirstChildOfClass("Terrain")
	if terrain then
		local clouds = terrain:FindFirstChildOfClass("Clouds")
		if clouds == nil then
			clouds = Instance.new("Clouds")
			clouds.Name = "RepairEmpireClouds"
			clouds.Parent = terrain
		end
		clouds.Cover = 0.16
		clouds.Density = 0.28
		clouds.Color = Color3.fromRGB(238, 242, 245)
	end
end

return LightingArt
