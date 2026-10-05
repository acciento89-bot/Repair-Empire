--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage.RepairEmpire.Shared
local VehicleDefinitions = require(Shared.vehicles.VehicleDefinitions)
local VehicleInputRules = require(Shared.vehicles.VehicleInputRules)
local PassRules = require(Shared.monetization.PassRules)
local MutationGuard = require(script.Parent.Parent.security.MutationGuard)

local VehicleService = {
	Name = "VehicleService",
	Dependencies = { "PlayerDataService", "EconomyService", "SecurityService", "EntitlementService" },
	_spawned = {},
}

local function remote(name: string): RemoteFunction
	local instance = ReplicatedStorage:WaitForChild("RepairEmpireRemotes"):WaitForChild(name)
	assert(instance:IsA("RemoteFunction"), name .. " must be a RemoteFunction")
	return instance
end

local function remoteEvent(name: string): RemoteEvent
	local instance = ReplicatedStorage:WaitForChild("RepairEmpireRemotes"):WaitForChild(name)
	assert(instance:IsA("RemoteEvent"), name .. " must be a RemoteEvent")
	return instance
end

local VEHICLE_COLORS = {
	compact_van = Color3.fromRGB(59, 89, 110),
	service_van = Color3.fromRGB(54, 126, 173),
	long_van = Color3.fromRGB(49, 112, 153),
	premium_van = Color3.fromRGB(38, 48, 58),
	pickup = Color3.fromRGB(188, 119, 55),
	crew_van = Color3.fromRGB(55, 126, 92),
	truck = Color3.fromRGB(108, 112, 116),
	elite = Color3.fromRGB(25, 31, 38),
}

local function createVehiclePart(name: string, size: Vector3, cframe: CFrame, parent: Instance): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.CanCollide = name == "Chassis" or name == "CargoBody" or name == "Cabin"
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function createVehicleWedge(name: string, size: Vector3, cframe: CFrame, parent: Instance): WedgePart
	local part = Instance.new("WedgePart")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.CanCollide = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function buildProceduralVehicle(player: Player, definition, slotIndex: number)
	local model = Instance.new("Model")
	model.Name = ("Vehicle_%d_%d"):format(player.UserId, slotIndex)
	model:SetAttribute("OwnerUserId", player.UserId)
	model:SetAttribute("VehicleId", definition.Id)
	model:SetAttribute("VehicleStyle", definition.Style)

	local width = definition.BodySize[1]
	local height = definition.BodySize[2]
	local length = definition.BodySize[3]
	local origin = Vector3.new(0, 4, 0)

	local bodyColor = VEHICLE_COLORS[definition.Style] or Color3.fromRGB(120, 135, 150)
	local compactVan = definition.Style == "compact_van"

	local chassis = createVehiclePart("Chassis", Vector3.new(width, 1.0, length), CFrame.new(origin), model)
	chassis.Material = Enum.Material.Metal
	chassis.Color = Color3.fromRGB(48, 52, 58)

	local collisionHull = createVehiclePart(
		"DriveCollision",
		Vector3.new(math.max(4.4, width * 0.82), 1.0, math.max(7.0, length * 0.72)),
		chassis.CFrame * CFrame.new(0, -1.27, 0),
		model
	)
	collisionHull.Transparency = 1
	collisionHull.CanCollide = true
	collisionHull.CanQuery = true
	collisionHull.CanTouch = true

	local cabinLength = if compactVan then math.max(3.7, length * 0.34) else math.max(4.2, length * 0.38)
	local cabinHeight = height * 0.82
	local cabinCenterZ = -length / 2 + cabinLength / 2 + 0.4
	local cabin = createVehiclePart(
		"Cabin",
		Vector3.new(width * 0.88, cabinHeight, cabinLength),
		CFrame.new(origin + Vector3.new(0, cabinHeight / 2 + 0.48, cabinCenterZ)),
		model
	)
	cabin.Material = Enum.Material.SmoothPlastic
	cabin.Color = bodyColor

	local roofCap = createVehiclePart(
		"CabinRoof",
		Vector3.new(width * 0.80, 0.24, cabinLength * 0.68),
		CFrame.new(origin + Vector3.new(0, cabinHeight + 0.58, cabinCenterZ + cabinLength * 0.10)),
		model
	)
	roofCap.Material = Enum.Material.SmoothPlastic
	roofCap.Color = bodyColor:Lerp(Color3.new(1, 1, 1), 0.06)
	roofCap.CanCollide = false

	local hoodLength = if compactVan then math.max(0.90, cabinLength * 0.22) else math.max(1.8, cabinLength * 0.34)
	local hoodHeight = if compactVan then height * 0.22 else height * 0.42
	local hood = createVehicleWedge(
		"Hood",
		Vector3.new(width * 0.86, hoodHeight, hoodLength),
		CFrame.new(origin + Vector3.new(0, height * 0.2 + 0.35, -length / 2 + hoodLength / 2 - 0.1)) * CFrame.Angles(0, math.pi, 0),
		model
	)
	hood.Material = Enum.Material.SmoothPlastic
	hood.Color = bodyColor

	local cargoLength = math.max(3.2, length - cabinLength - 1.0)
	local cargoHeight = if definition.Style == "pickup"
		then height * 0.45
		else if definition.Style == "truck" then height * 1.15 else if definition.Style == "compact_van" then height * 0.78 else height * 0.70
	local cargoCenterZ = length / 2 - cargoLength / 2 - 0.3
	local cargo = createVehiclePart(
		"CargoBody",
		Vector3.new(width * 0.94, cargoHeight, cargoLength),
		CFrame.new(origin + Vector3.new(0, cargoHeight / 2 + 0.5, cargoCenterZ)),
		model
	)
	cargo.Material = if definition.Style == "truck" then Enum.Material.Metal else Enum.Material.SmoothPlastic
	cargo.Color = bodyColor

	if definition.Style ~= "pickup" and definition.Style ~= "truck" then
		local roofHeight = math.max(cabinHeight, cargoHeight)
		local roofSkin = createVehiclePart(
			"RoofSkin",
			Vector3.new(width * 0.78, 0.18, math.max(cabinLength + cargoLength - 1.35, 4.8)),
			CFrame.new(origin + Vector3.new(0, roofHeight + 0.60, 0.24)),
			model
		)
		roofSkin.Material = Enum.Material.SmoothPlastic
		roofSkin.Color = bodyColor:Lerp(Color3.new(1, 1, 1), 0.04)
		roofSkin.CanCollide = false

		for _, side in { -1, 1 } do
			local roofEdge = createVehiclePart(
				"RoofEdge",
				Vector3.new(0.16, 0.16, math.max(cabinLength + cargoLength - 1.55, 4.6)),
				CFrame.new(origin + Vector3.new(side * width * 0.395, roofHeight + 0.48, 0.24)),
				model
			)
			roofEdge.Material = Enum.Material.Metal
			roofEdge.Color = bodyColor:Lerp(Color3.new(0, 0, 0), 0.18)
			roofEdge.CanCollide = false
		end

		for _, side in { -1, 1 } do
			local belt = createVehiclePart(
				"BodyBelt",
				Vector3.new(0.12, 0.28, length * 0.72),
				CFrame.new(origin + Vector3.new(side * width * 0.475, 0.95, length * 0.08)),
				model
			)
			belt.Material = Enum.Material.Metal
			belt.Color = Color3.fromRGB(42, 48, 54)
			belt.CanCollide = false
		end

		local rearDoorLeft = createVehiclePart(
			"RearDoorLeft",
			Vector3.new(width * 0.43, math.max(1.5, cargoHeight * 0.78), 0.12),
			CFrame.new(origin + Vector3.new(-width * 0.225, cargoHeight * 0.52, length / 2 + 0.32)),
			model
		)
		rearDoorLeft.Material = Enum.Material.SmoothPlastic
		rearDoorLeft.Color = bodyColor
		rearDoorLeft.CanCollide = false

		local rearDoorRight = rearDoorLeft:Clone()
		rearDoorRight.Name = "RearDoorRight"
		rearDoorRight.CFrame = CFrame.new(origin + Vector3.new(width * 0.225, cargoHeight * 0.52, length / 2 + 0.32))
		rearDoorRight.Parent = model

		local rearSeam = createVehiclePart(
			"RearDoorSeam",
			Vector3.new(0.08, math.max(1.4, cargoHeight * 0.72), 0.14),
			CFrame.new(origin + Vector3.new(0, cargoHeight * 0.52, length / 2 + 0.40)),
			model
		)
		rearSeam.Material = Enum.Material.Metal
		rearSeam.Color = Color3.fromRGB(52, 58, 64)
		rearSeam.CanCollide = false
	end

	if definition.Style == "premium_van" or definition.Style == "elite" then
		local roof = createVehiclePart(
			"RoofModule",
			Vector3.new(width * 0.6, 0.4, cabinLength * 0.55),
			CFrame.new(origin + Vector3.new(0, cabinHeight + 0.72, cabinCenterZ)),
			model
		)
		roof.Material = Enum.Material.Metal
		roof.Color = Color3.fromRGB(238, 170, 66)
	end

	local windscreen = createVehiclePart(
		"Windscreen",
		Vector3.new(if compactVan then width * 0.74 else width * 0.70, if compactVan then cabinHeight * 0.46 else cabinHeight * 0.40, 0.16),
		CFrame.new(origin + Vector3.new(0, cabinHeight * 0.67, cabinCenterZ - cabinLength / 2 - 0.16))
			* CFrame.Angles(math.rad(if compactVan then -12 else -18), 0, 0),
		model
	)
	windscreen.Material = Enum.Material.Glass
	windscreen.Color = Color3.fromRGB(38, 65, 80)
	windscreen.Transparency = 0.08
	windscreen.CanCollide = false

	local windscreenHeader = createVehiclePart(
		"WindscreenHeader",
		Vector3.new(if compactVan then width * 0.77 else width * 0.74, 0.20, 0.22),
		CFrame.new(origin + Vector3.new(0, cabinHeight + 0.34, cabinCenterZ - cabinLength / 2 + 0.04)) * CFrame.Angles(math.rad(-18), 0, 0),
		model
	)
	windscreenHeader.Material = Enum.Material.SmoothPlastic
	windscreenHeader.Color = bodyColor:Lerp(Color3.new(0, 0, 0), 0.08)
	windscreenHeader.CanCollide = false

	for _, side in { -1, 1 } do
		local pillar = createVehiclePart(
			"APillar",
			Vector3.new(0.18, cabinHeight * 0.46, 0.18),
			CFrame.new(origin + Vector3.new(side * width * 0.385, cabinHeight * 0.69, cabinCenterZ - cabinLength / 2 - 0.09))
				* CFrame.Angles(math.rad(if compactVan then -12 else -18), 0, 0),
			model
		)
		pillar.Material = Enum.Material.SmoothPlastic
		pillar.Color = bodyColor:Lerp(Color3.new(0, 0, 0), 0.12)
		pillar.CanCollide = false
	end

	local lowerCladding =
		createVehiclePart("LowerBodyCladding", Vector3.new(width * 0.93, 0.62, length * 0.82), CFrame.new(origin + Vector3.new(0, -0.02, length * 0.05)), model)
	lowerCladding.Material = Enum.Material.SmoothPlastic
	lowerCladding.Color = Color3.fromRGB(42, 49, 56)
	lowerCladding.CanCollide = false

	local frontApron = createVehicleWedge(
		"FrontApron",
		if compactVan then Vector3.new(width * 0.74, 0.46, 0.78) else Vector3.new(width * 0.82, 0.72, 1.25),
		CFrame.new(origin + Vector3.new(0, 0.22, -length / 2 + 0.42)) * CFrame.Angles(0, math.pi, 0),
		model
	)
	frontApron.Material = Enum.Material.SmoothPlastic
	frontApron.Color = bodyColor:Lerp(Color3.new(0, 0, 0), 0.08)

	for _, side in { -1, 1 } do
		local sideWindow = createVehiclePart(
			"SideWindow",
			Vector3.new(0.16, if compactVan then cabinHeight * 0.42 else cabinHeight * 0.34, if compactVan then cabinLength * 0.60 else cabinLength * 0.46),
			CFrame.new(
				origin + Vector3.new(side * width * 0.455, if compactVan then cabinHeight * 0.65 else cabinHeight * 0.67, cabinCenterZ - cabinLength * 0.10)
			),
			model
		)
		sideWindow.Material = Enum.Material.Glass
		sideWindow.Color = Color3.fromRGB(41, 70, 84)
		sideWindow.Transparency = 0.09
		sideWindow.CanCollide = false

		local mirror = createVehiclePart(
			"Mirror",
			if compactVan then Vector3.new(0.34, 0.50, 0.58) else Vector3.new(0.45, 0.72, 0.9),
			CFrame.new(origin + Vector3.new(side * width * 0.55, cabinHeight * 0.64, cabinCenterZ - cabinLength * 0.42)),
			model
		)
		mirror.Material = Enum.Material.Metal
		mirror.Color = Color3.fromRGB(38, 42, 46)
		mirror.CanCollide = false
	end

	local frontBumper = createVehiclePart(
		"FrontBumper",
		if compactVan then Vector3.new(width * 0.84, 0.34, 0.44) else Vector3.new(width * 0.92, 0.5, 0.55),
		CFrame.new(origin + Vector3.new(0, -0.15, -length / 2 - 0.2)),
		model
	)
	frontBumper.Material = Enum.Material.Metal
	frontBumper.Color = Color3.fromRGB(52, 56, 60)
	frontBumper.CanCollide = false

	local rearBumper = createVehiclePart(
		"RearBumper",
		if compactVan then Vector3.new(width * 0.84, 0.34, 0.44) else Vector3.new(width * 0.92, 0.5, 0.55),
		CFrame.new(origin + Vector3.new(0, -0.15, length / 2 + 0.2)),
		model
	)
	rearBumper.Material = Enum.Material.Metal
	rearBumper.Color = Color3.fromRGB(52, 56, 60)
	rearBumper.CanCollide = false

	local grilleWidth = if compactVan then width * 0.34 else width * 0.48
	local grilleHeight = if compactVan then 0.48 else 0.9
	local grille = createVehiclePart(
		"FrontGrille",
		Vector3.new(grilleWidth, grilleHeight, 0.16),
		CFrame.new(origin + Vector3.new(0, if compactVan then 0.42 else 0.55, -length / 2 - 0.3)),
		model
	)
	grille.Material = Enum.Material.Metal
	grille.Color = Color3.fromRGB(31, 36, 41)
	grille.CanCollide = false

	if compactVan then
		local badge = createVehiclePart("FrontBadge", Vector3.new(0.42, 0.20, 0.12), CFrame.new(origin + Vector3.new(0, 0.83, -length / 2 - 0.31)), model)
		badge.Material = Enum.Material.Metal
		badge.Color = Color3.fromRGB(245, 151, 49)
		badge.CanCollide = false
	end

	local grilleSlots = if compactVan then { -1, 0, 1 } else { -2, -1, 0, 1, 2 }
	for _, slot in grilleSlots do
		local slat = createVehiclePart(
			"GrilleSlat",
			Vector3.new(0.10, grilleHeight * 0.78, 0.20),
			grille.CFrame * CFrame.new(slot * grilleWidth * 0.20, 0, -0.05),
			model
		)
		slat.Material = Enum.Material.Metal
		slat.Color = Color3.fromRGB(104, 111, 117)
		slat.CanCollide = false
	end

	local plate = createVehiclePart("RearPlate", Vector3.new(2.2, 0.56, 0.14), CFrame.new(origin + Vector3.new(0, 0.34, length / 2 + 0.31)), model)
	plate.Material = Enum.Material.SmoothPlastic
	plate.Color = Color3.fromRGB(238, 238, 231)
	plate.CanCollide = false

	local plateGui = Instance.new("SurfaceGui")
	plateGui.Face = Enum.NormalId.Back
	plateGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	plateGui.PixelsPerStud = 40
	plateGui.Parent = plate
	local plateText = Instance.new("TextLabel")
	plateText.Size = UDim2.fromScale(1, 1)
	plateText.BackgroundTransparency = 1
	plateText.Font = Enum.Font.GothamBold
	plateText.TextScaled = true
	plateText.TextColor3 = Color3.fromRGB(30, 32, 34)
	plateText.Text = "RE • " .. string.upper(definition.Id:sub(1, 3))
	plateText.Parent = plateGui

	if definition.Style ~= "pickup" and definition.Style ~= "truck" then
		local rearDoorSeam = createVehiclePart(
			"RearDoorSeam",
			Vector3.new(0.07, math.max(1.0, cargoHeight * 0.82), 0.10),
			CFrame.new(origin + Vector3.new(0, cargoHeight * 0.63, length / 2 + 0.40)),
			model
		)
		rearDoorSeam.Material = Enum.Material.Metal
		rearDoorSeam.Color = bodyColor:Lerp(Color3.new(0, 0, 0), 0.35)
		rearDoorSeam.CanCollide = false

		for _, side in { -1, 1 } do
			local rearWindow = createVehiclePart(
				"RearWindow",
				Vector3.new(width * 0.32, math.max(0.72, cargoHeight * 0.38), 0.14),
				CFrame.new(origin + Vector3.new(side * width * 0.19, cargoHeight * 0.62, length / 2 + 0.39)),
				model
			)
			rearWindow.Material = Enum.Material.Glass
			rearWindow.Color = Color3.fromRGB(36, 62, 75)
			rearWindow.Transparency = 0.08
			rearWindow.CanCollide = false

			local rearHandle = createVehiclePart(
				"RearDoorHandle",
				Vector3.new(0.34, 0.16, 0.10),
				CFrame.new(origin + Vector3.new(side * width * 0.12, 0.82, length / 2 + 0.42)),
				model
			)
			rearHandle.Material = Enum.Material.Metal
			rearHandle.Color = Color3.fromRGB(54, 59, 64)
			rearHandle.CanCollide = false
		end

		for _, side in { -1, 1 } do
			local slidingDoorLine = createVehiclePart(
				"SlidingDoorLine",
				Vector3.new(0.10, math.max(1.0, cargoHeight * 0.72), 0.08),
				CFrame.new(origin + Vector3.new(side * width * 0.474, cargoHeight * 0.54, cargoCenterZ - cargoLength * 0.18)),
				model
			)
			slidingDoorLine.Material = Enum.Material.Metal
			slidingDoorLine.Color = bodyColor:Lerp(Color3.new(0, 0, 0), 0.28)
			slidingDoorLine.CanCollide = false
		end
	end

	for _, side in { -1, 1 } do
		local handle = createVehiclePart(
			"DoorHandle",
			Vector3.new(0.12, 0.22, 1.0),
			CFrame.new(origin + Vector3.new(side * width * 0.475, height * 0.55, cabinCenterZ - cabinLength * 0.05)),
			model
		)
		handle.Material = Enum.Material.Metal
		handle.Color = Color3.fromRGB(56, 60, 64)
		handle.CanCollide = false
	end

	local dashboard =
		createVehiclePart("Dashboard", Vector3.new(width * 0.72, 0.55, 1.1), CFrame.new(origin + Vector3.new(0, 1.45, cabinCenterZ - cabinLength * 0.3)), model)
	dashboard.Material = Enum.Material.SmoothPlastic
	dashboard.Color = Color3.fromRGB(36, 40, 44)
	dashboard.CanCollide = false

	local steeringWheel = createVehiclePart(
		"SteeringWheel",
		Vector3.new(0.28, 1.35, 1.35),
		CFrame.new(origin + Vector3.new(-width * 0.2, 1.85, cabinCenterZ - cabinLength * 0.22)),
		model
	)
	steeringWheel.Shape = Enum.PartType.Cylinder
	steeringWheel.Orientation = Vector3.new(0, 90, 0)
	steeringWheel.Material = Enum.Material.SmoothPlastic
	steeringWheel.Color = Color3.fromRGB(28, 30, 32)
	steeringWheel.CanCollide = false

	for _, side in { -1, 1 } do
		local stripe = createVehiclePart(
			"CompanyStripe",
			Vector3.new(0.10, 0.26, cargoLength * 0.72),
			CFrame.new(origin + Vector3.new(side * width * 0.476, math.max(0.95, cargoHeight * 0.48), cargoCenterZ)),
			model
		)
		stripe.Material = Enum.Material.SmoothPlastic
		stripe.Color = Color3.fromRGB(245, 151, 49)
		stripe.CanCollide = false
	end

	local brandPanel = createVehiclePart(
		"BrandPanel",
		Vector3.new(width * 0.62, 0.38, 0.14),
		CFrame.new(origin + Vector3.new(0, math.max(1.55, cargoHeight * 0.96), cargoCenterZ + cargoLength / 2 + 0.10)),
		model
	)
	brandPanel.Material = Enum.Material.SmoothPlastic
	brandPanel.Color = Color3.fromRGB(20, 34, 46)
	brandPanel.CanCollide = false
	local brandGui = Instance.new("SurfaceGui")
	brandGui.Face = Enum.NormalId.Back
	brandGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	brandGui.PixelsPerStud = 28
	brandGui.Parent = brandPanel
	local brandText = Instance.new("TextLabel")
	brandText.Size = UDim2.fromScale(1, 1)
	brandText.BackgroundTransparency = 1
	brandText.Font = Enum.Font.GothamBold
	brandText.TextScaled = true
	brandText.TextColor3 = Color3.fromRGB(245, 151, 49)
	brandText.Text = "REPAIR EMPIRE"
	brandText.Parent = brandGui

	for _, side in { -1, 1 } do
		local headlight = createVehiclePart(
			"Headlight",
			if compactVan then Vector3.new(0.72, 0.30, 0.16) else Vector3.new(1.0, 0.55, 0.18),
			CFrame.new(origin + Vector3.new(side * width * 0.29, if compactVan then 0.54 else 0.5, -length / 2 - 0.1)),
			model
		)
		headlight.Material = Enum.Material.Neon
		headlight.Color = Color3.fromRGB(255, 240, 188)
		headlight.CanCollide = false

		local beam = Instance.new("SpotLight")
		beam.Name = "HeadlightBeam"
		beam.Face = Enum.NormalId.Front
		beam.Angle = 54
		beam.Brightness = 1.4
		beam.Range = 28
		beam.Color = Color3.fromRGB(255, 236, 194)
		beam.Shadows = false
		beam.Parent = headlight
	end

	for _, side in { -1, 1 } do
		local tailLight =
			createVehiclePart("TailLight", Vector3.new(0.44, 1.10, 0.18), CFrame.new(origin + Vector3.new(side * width * 0.39, 0.78, length / 2 + 0.1)), model)
		tailLight.Material = Enum.Material.Neon
		tailLight.Color = Color3.fromRGB(205, 56, 49)
		tailLight.CanCollide = false

		local rearGlow = Instance.new("PointLight")
		rearGlow.Name = "TailGlow"
		rearGlow.Brightness = 0.35
		rearGlow.Range = 7
		rearGlow.Color = Color3.fromRGB(220, 62, 52)
		rearGlow.Shadows = false
		rearGlow.Parent = tailLight
	end

	if definition.Style == "service_van" or definition.Style == "long_van" or definition.Style == "premium_van" or definition.Style == "elite" then
		for _, x in { -width * 0.3, width * 0.3 } do
			local rail = createVehiclePart(
				"RoofRail",
				Vector3.new(0.22, 0.28, cargoLength * 0.85),
				CFrame.new(origin + Vector3.new(x, cargoHeight + 1.0, cargoCenterZ)),
				model
			)
			rail.Material = Enum.Material.Metal
			rail.Color = Color3.fromRGB(74, 78, 82)
			rail.CanCollide = false
		end
		for rung = -2, 2 do
			local rack = createVehiclePart(
				"RoofRack",
				Vector3.new(width * 0.7, 0.2, 0.2),
				CFrame.new(origin + Vector3.new(0, cargoHeight + 1.08, cargoCenterZ + rung * cargoLength * 0.18)),
				model
			)
			rack.Material = Enum.Material.Metal
			rack.Color = Color3.fromRGB(84, 88, 92)
			rack.CanCollide = false
		end
	end

	if definition.Style == "pickup" then
		for _, side in { -1, 1 } do
			local bedRail = createVehiclePart(
				"PickupBedRail",
				Vector3.new(0.25, 1.0, cargoLength * 0.9),
				CFrame.new(origin + Vector3.new(side * width * 0.45, cargoHeight + 0.9, cargoCenterZ)),
				model
			)
			bedRail.Material = Enum.Material.Metal
			bedRail.Color = Color3.fromRGB(78, 70, 60)
			bedRail.CanCollide = false
		end
	end

	if definition.Style == "truck" then
		for _, side in { -1, 1 } do
			local box = createVehiclePart(
				"SideToolbox",
				Vector3.new(1.1, 1.4, cargoLength * 0.52),
				CFrame.new(origin + Vector3.new(side * width * 0.54, 1.0, cargoCenterZ)),
				model
			)
			box.Material = Enum.Material.Metal
			box.Color = Color3.fromRGB(92, 96, 100)
			box.CanCollide = false
		end
	end

	local exhaust =
		createVehiclePart("ExhaustPipe", Vector3.new(0.45, 0.45, 2.2), CFrame.new(origin + Vector3.new(width * 0.34, -0.35, length / 2 + 0.8)), model)
	exhaust.Shape = Enum.PartType.Cylinder
	exhaust.Orientation = Vector3.new(90, 0, 0)
	exhaust.Material = Enum.Material.Metal
	exhaust.Color = Color3.fromRGB(64, 68, 71)
	exhaust.CanCollide = false

	local exhaustEmitter = Instance.new("ParticleEmitter")
	exhaustEmitter.Name = "Exhaust"
	exhaustEmitter.Rate = 0
	exhaustEmitter.Lifetime = NumberRange.new(0.45, 0.8)
	exhaustEmitter.Speed = NumberRange.new(0.6, 1.2)
	exhaustEmitter.Acceleration = Vector3.new(0, 0.6, 0)
	exhaustEmitter.SpreadAngle = Vector2.new(18, 18)
	exhaustEmitter.Color = ColorSequence.new(Color3.fromRGB(165, 170, 174))
	exhaustEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 0.6),
	})
	exhaustEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.55),
		NumberSequenceKeypoint.new(1, 1),
	})
	exhaustEmitter.Parent = exhaust

	local seat = Instance.new("VehicleSeat")
	seat.Name = "DriverSeat"
	seat.Size = Vector3.new(2, 1, 2)
	seat.Anchored = true
	seat.CanCollide = false
	seat.CFrame = CFrame.new(origin + Vector3.new(-width * 0.2, 1.45, cabinCenterZ))
	seat.MaxSpeed = definition.Speed
	seat.Parent = model

	local passengerCount = math.max(0, definition.Seats - 1)
	for passengerIndex = 1, passengerCount do
		local passenger = Instance.new("Seat")
		passenger.Name = ("PassengerSeat_%d"):format(passengerIndex)
		passenger.Size = Vector3.new(2, 1, 2)
		passenger.Anchored = true
		passenger.CanCollide = false
		local row = math.floor((passengerIndex - 1) / 2)
		local side = if passengerIndex % 2 == 1 then 1 else -1
		passenger.CFrame = CFrame.new(origin + Vector3.new(side * width * 0.2, 1.45, cabinCenterZ + row * 2.1))
		passenger.Parent = model
	end

	local axleCount = definition.Axles
	local wheelDiameter = if compactVan then 2.08 else 2.2
	local wheelWidth = if compactVan then 0.90 else 1.2
	local wheelY = if compactVan then -0.73 else -0.65
	local rimDiameter = if compactVan then 1.10 else 1.15
	for axleIndex = 1, axleCount do
		local alpha = if axleCount == 1 then 0.5 else (axleIndex - 1) / (axleCount - 1)
		local z = -length * 0.36 + alpha * length * 0.72
		for _, side in { -1, 1 } do
			local wheel = createVehiclePart(
				("Wheel_%d_%d"):format(axleIndex, side),
				Vector3.new(wheelWidth, wheelDiameter, wheelDiameter),
				CFrame.new(origin + Vector3.new(side * width * 0.50, wheelY, z)),
				model
			)
			wheel.Shape = Enum.PartType.Cylinder
			wheel.Material = Enum.Material.SmoothPlastic
			wheel.Color = Color3.fromRGB(25, 28, 31)

			local rim = createVehiclePart(
				("Rim_%d_%d"):format(axleIndex, side),
				Vector3.new(wheelWidth + 0.04, rimDiameter, rimDiameter),
				CFrame.new(origin + Vector3.new(side * width * 0.505, wheelY, z)),
				model
			)
			rim.Shape = Enum.PartType.Cylinder
			rim.Material = Enum.Material.Metal
			rim.Color = if compactVan then Color3.fromRGB(96, 105, 112) else Color3.fromRGB(145, 150, 155)
			rim.CanCollide = false

			local archTrim = createVehiclePart(
				("WheelArchTrim_%d_%d"):format(axleIndex, side),
				Vector3.new(0.18, 0.30, wheelDiameter + 0.44),
				CFrame.new(origin + Vector3.new(side * width * 0.505, 0.24, z)),
				model
			)
			archTrim.Material = Enum.Material.SmoothPlastic
			archTrim.Color = bodyColor
			archTrim.CanCollide = false
		end
	end

	for _, side in { -1, 1 } do
		local skirt = createVehiclePart(
			"SideSkirt",
			Vector3.new(0.28, 0.5, length * 0.52),
			CFrame.new(origin + Vector3.new(side * width * 0.505, -0.15, length * 0.05)),
			model
		)
		skirt.Material = Enum.Material.Metal
		skirt.Color = Color3.fromRGB(55, 59, 63)
		skirt.CanCollide = false

		local step = createVehiclePart(
			"CabStep",
			Vector3.new(0.65, 0.22, cabinLength * 0.58),
			CFrame.new(origin + Vector3.new(side * width * 0.56, -0.4, cabinCenterZ)),
			model
		)
		step.Material = Enum.Material.Metal
		step.Color = Color3.fromRGB(74, 78, 81)
		step.CanCollide = false
	end

	model.PrimaryPart = chassis
	model.Parent = Workspace
	return model, seat, exhaustEmitter, chassis
end

local function activatePhysicalAssembly(model: Model, chassis: BasePart): AlignOrientation
	-- A server-PivotTo vehicle replicates as discrete transform updates and looks
	-- visibly choppy on clients. Weld the authored model into one physics assembly
	-- so Roblox can interpolate replicated motion between server snapshots.
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = descendant.Name == "DriveCollision"
			if descendant ~= chassis then
				descendant.Massless = true
				local weld = Instance.new("WeldConstraint")
				weld.Name = "DriveWeld"
				weld.Part0 = chassis
				weld.Part1 = descendant
				weld.Parent = descendant
			end
		end
	end

	local steeringAttachment = Instance.new("Attachment")
	steeringAttachment.Name = "DriveOrientationAttachment"
	steeringAttachment.Parent = chassis

	local steering = Instance.new("AlignOrientation")
	steering.Name = "DriveOrientation"
	steering.Mode = Enum.OrientationAlignmentMode.OneAttachment
	steering.Attachment0 = steeringAttachment
	steering.CFrame = chassis.CFrame.Rotation
	steering.RigidityEnabled = false
	steering.Responsiveness = 28
	steering.MaxTorque = 2_000_000
	steering.MaxAngularVelocity = math.rad(120)
	steering.Parent = chassis

	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = false
		end
	end

	-- Keep simulation authoritative on the server while still using Roblox's
	-- built-in physics interpolation on clients.
	local canSet = chassis:CanSetNetworkOwnership()
	if canSet then
		chassis:SetNetworkOwner(nil)
	end
	chassis.AssemblyLinearVelocity = Vector3.zero
	chassis.AssemblyAngularVelocity = Vector3.zero
	return steering
end

function VehicleService:Purchase(player: Player, vehicleId: any)
	local security = require(script.Parent.SecurityService)
	if not security:Allow(player, "PurchaseVehicle") then
		return { ok = false, error = "rate_limited" }
	end
	if type(vehicleId) ~= "string" then
		return { ok = false, error = "invalid_vehicle" }
	end
	local definition = VehicleDefinitions.ById[vehicleId]
	if definition == nil then
		return { ok = false, error = "invalid_vehicle" }
	end

	local entered, result = MutationGuard.TryRun(player.UserId, "profile_value_mutation", function()
		local dataService = require(script.Parent.PlayerDataService)
		local profile = dataService:RequireProfile(player)
		if profile.OwnedVehicles[vehicleId] then
			return { ok = false, error = "already_owned" }
		end
		if profile.Level < definition.MinimumLevel then
			return { ok = false, error = "level_locked" }
		end

		local economy = require(script.Parent.EconomyService)
		if not economy:Spend(player, "cash", definition.Cost, "vehicle:" .. vehicleId) then
			return { ok = false, error = "insufficient_funds" }
		end

		profile.OwnedVehicles[vehicleId] = true
		dataService:Publish(player)
		return { ok = true }
	end)
	if not entered then
		return { ok = false, error = "mutation_in_progress" }
	end
	return result
end

function VehicleService:Select(player: Player, vehicleId: any)
	local security = require(script.Parent.SecurityService)
	if not security:Allow(player, "SelectVehicle") then
		return { ok = false, error = "rate_limited" }
	end
	if type(vehicleId) ~= "string" then
		return { ok = false, error = "invalid_vehicle" }
	end
	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	if profile.OwnedVehicles[vehicleId] ~= true or VehicleDefinitions.ById[vehicleId] == nil then
		return { ok = false, error = "not_owned" }
	end
	profile.SelectedVehicle = vehicleId
	dataService:Publish(player)
	return { ok = true }
end

function VehicleService:_DestroySpawned(userId: number): number
	local entries = self._spawned[userId]
	local removed = 0
	if entries then
		for _, entry in entries do
			if entry.Model and entry.Model.Parent then
				entry.Model:Destroy()
				removed += 1
			end
		end
	end
	self._spawned[userId] = nil
	return removed
end

function VehicleService:Despawn(player: Player)
	local security = require(script.Parent.SecurityService)
	if not security:Allow(player, "DespawnVehicle") then
		return { ok = false, error = "rate_limited" }
	end
	local removed = self:_DestroySpawned(player.UserId)
	return { ok = true, removed = removed }
end

function VehicleService:Spawn(player: Player)
	local security = require(script.Parent.SecurityService)
	if not security:Allow(player, "SpawnVehicle") then
		return { ok = false, error = "rate_limited" }
	end
	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	local definition = VehicleDefinitions.ById[profile.SelectedVehicle]
	if definition == nil then
		return { ok = false, error = "invalid_selected_vehicle" }
	end

	local entitlement = require(script.Parent.EntitlementService)
	local maxVehicles = PassRules.VehicleSlots(entitlement:HasPass(player, "extra_vehicle_slot"))
	local entries = self._spawned[player.UserId] or {}

	while #entries >= maxVehicles do
		local oldest = table.remove(entries, 1)
		if oldest and oldest.Model and oldest.Model.Parent then
			oldest.Model:Destroy()
		end
	end

	local slotIndex = #entries + 1
	local model, seat, exhaustEmitter, chassis = buildProceduralVehicle(player, definition, slotIndex)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if model.PrimaryPart then
		local world = Workspace:FindFirstChild("RepairEmpireWorld")
		local bay = world and world:FindFirstChild(("VehicleSpawn_%d"):format(slotIndex), true)
		local targetCFrame
		if bay and bay:IsA("BasePart") then
			targetCFrame = bay.CFrame
		elseif root and root:IsA("BasePart") then
			local lateralOffset = if slotIndex == 1 then 8 else -8
			targetCFrame = root.CFrame * CFrame.new(lateralOffset, 0, -12)
		else
			targetCFrame = CFrame.new(0, 0, 0)
		end

		local excluded = { model }
		if character then
			table.insert(excluded, character)
		end
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = excluded

		local result = Workspace:Raycast(targetCFrame.Position + Vector3.new(0, 24, 0), Vector3.new(0, -80, 0), params)
		local fallbackY = if bay and bay:IsA("BasePart") then bay.Position.Y - 0.5 else if root and root:IsA("BasePart") then root.Position.Y - 3 else 0
		local groundY = if result then result.Position.Y else fallbackY
		local chassisY = groundY + 1.8
		model:PivotTo(CFrame.new(targetCFrame.Position.X, chassisY, targetCFrame.Position.Z) * targetCFrame.Rotation)
	end

	local steering = activatePhysicalAssembly(model, chassis)
	local _, spawnYaw, _ = chassis.CFrame:ToOrientation()

	table.insert(entries, {
		Model = model,
		Seat = seat,
		Chassis = chassis,
		Steering = steering,
		Yaw = spawnYaw,
		Definition = definition,
		ExhaustEmitter = exhaustEmitter,
		Input = {
			Throttle = 0,
			Steer = 0,
			UpdatedAt = 0,
		},
	})
	self._spawned[player.UserId] = entries
	return { ok = true, activeVehicles = #entries, maxVehicles = maxVehicles }
end

function VehicleService:UpdateInput(player: Player, payload: any)
	local security = require(script.Parent.SecurityService)
	if not security:Allow(player, "UpdateVehicleInput") then
		return
	end

	local normalized = VehicleInputRules.Normalize(payload)
	if normalized == nil then
		security:RecordAnomaly(player, "invalid_vehicle_input", typeof(payload))
		return
	end

	local entries = self._spawned[player.UserId]
	if not entries then
		return
	end

	for index = #entries, 1, -1 do
		local entry = entries[index]
		local seat = entry.Seat
		if seat and seat.Parent then
			local occupant = seat.Occupant
			local driver = occupant and Players:GetPlayerFromCharacter(occupant.Parent)
			if driver == player then
				entry.Input = {
					Throttle = normalized.Throttle,
					Steer = normalized.Steer,
					UpdatedAt = os.clock(),
				}
				return
			end
		end
	end
end

local function setDriveAttribute(model: Model, name: string, value: any)
	if model:GetAttribute(name) ~= value then
		model:SetAttribute(name, value)
	end
end

local function setExhaustRate(entry, rate: number)
	local emitter = entry.ExhaustEmitter
	if emitter and emitter.Rate ~= rate then
		emitter.Rate = rate
	end
end

local function brakeAssembly(entry, dt: number)
	local chassis = entry.Chassis
	if not chassis or not chassis.Parent then
		return
	end
	local velocity = chassis.AssemblyLinearVelocity
	local horizontal = Vector3.new(velocity.X, 0, velocity.Z)
	local alpha = 1 - math.exp(-10 * math.max(0, dt))
	horizontal = horizontal:Lerp(Vector3.zero, alpha)
	chassis.AssemblyLinearVelocity = Vector3.new(horizontal.X, velocity.Y, horizontal.Z)
end

function VehicleService:_Step(dt: number)
	for ownerUserId, entries in self._spawned do
		for index = #entries, 1, -1 do
			local entry = entries[index]
			local model = entry.Model
			local seat = entry.Seat
			local chassis = entry.Chassis
			local steering = entry.Steering
			if model.Parent == nil or seat.Parent == nil or not chassis or chassis.Parent == nil then
				table.remove(entries, index)
				continue
			end

			local occupant = seat.Occupant
			if occupant == nil then
				setDriveAttribute(model, "Driving", false)
				setDriveAttribute(model, "DriveThrottle", 0)
				setDriveAttribute(model, "DriveSteer", 0)
				setExhaustRate(entry, 0)
				brakeAssembly(entry, dt)
				continue
			end

			local driver = Players:GetPlayerFromCharacter(occupant.Parent)
			if driver == nil or driver.UserId ~= ownerUserId then
				occupant.Sit = false
				setDriveAttribute(model, "Driving", false)
				setDriveAttribute(model, "DriveThrottle", 0)
				setDriveAttribute(model, "DriveSteer", 0)
				setExhaustRate(entry, 0)
				brakeAssembly(entry, dt)
				continue
			end

			local throttle = seat.ThrottleFloat
			local steer = seat.SteerFloat
			local input = entry.Input
			if input and os.clock() - input.UpdatedAt <= 0.45 then
				throttle = input.Throttle
				steer = input.Steer
			end

			local moving = math.abs(throttle) >= 0.01 or math.abs(steer) >= 0.01
			setDriveAttribute(model, "Driving", moving)
			setDriveAttribute(model, "DriveThrottle", throttle)
			setDriveAttribute(model, "DriveSteer", steer)
			setExhaustRate(entry, if moving then 7 + math.abs(throttle) * 7 else 2)

			local turnRate = math.rad(55) * (0.35 + math.abs(throttle) * 0.65)
			entry.Yaw -= steer * turnRate * dt
			if steering and steering.Parent then
				steering.CFrame = CFrame.Angles(0, entry.Yaw, 0)
			end

			local targetForward = CFrame.Angles(0, entry.Yaw, 0).LookVector
			local targetHorizontal = targetForward * (throttle * entry.Definition.Speed)
			local velocity = chassis.AssemblyLinearVelocity
			local currentHorizontal = Vector3.new(velocity.X, 0, velocity.Z)
			local response = if math.abs(throttle) >= 0.01 then 5.5 else 9.0
			local alpha = 1 - math.exp(-response * math.max(0, dt))
			local nextHorizontal = currentHorizontal:Lerp(targetHorizontal, alpha)
			chassis.AssemblyLinearVelocity = Vector3.new(nextHorizontal.X, velocity.Y, nextHorizontal.Z)

			if RunService:IsStudio() and model:GetAttribute("StudioDriveVerified") ~= true and moving then
				model:SetAttribute("StudioDriveVerified", true)
				print(
					("[Repair Empire] VehiclePhysicsDriveObserved id=%s throttle=%.2f steer=%.2f speed=%.2f"):format(
						entry.Definition.Id,
						throttle,
						steer,
						nextHorizontal.Magnitude
					)
				)
			end
		end

		if #entries == 0 then
			self._spawned[ownerUserId] = nil
		end
	end
end

function VehicleService:Init()
	remote("PurchaseVehicle").OnServerInvoke = function(player, vehicleId)
		return self:Purchase(player, vehicleId)
	end
	remote("SelectVehicle").OnServerInvoke = function(player, vehicleId)
		return self:Select(player, vehicleId)
	end
	remote("SpawnVehicle").OnServerInvoke = function(player)
		return self:Spawn(player)
	end
	remote("DespawnVehicle").OnServerInvoke = function(player)
		return self:Despawn(player)
	end
	remoteEvent("UpdateVehicleInput").OnServerEvent:Connect(function(player, payload)
		self:UpdateInput(player, payload)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:_DestroySpawned(player.UserId)
	end)
end

function VehicleService:Start()
	RunService.Heartbeat:Connect(function(dt)
		self:_Step(math.min(dt, 0.1))
	end)
end

return VehicleService
