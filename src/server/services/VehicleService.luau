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
	compact_van = Color3.fromRGB(188, 198, 207),
	service_van = Color3.fromRGB(73, 142, 188),
	long_van = Color3.fromRGB(66, 126, 167),
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

	local chassis = createVehiclePart("Chassis", Vector3.new(width, 1.0, length), CFrame.new(origin), model)
	chassis.Material = Enum.Material.Metal
	chassis.Color = Color3.fromRGB(48, 52, 58)

	local cabinLength = math.max(4.2, length * 0.38)
	local cabinCenterZ = -length / 2 + cabinLength / 2 + 0.4
	local cabin =
		createVehiclePart("Cabin", Vector3.new(width * 0.92, height, cabinLength), CFrame.new(origin + Vector3.new(0, height / 2 + 0.5, cabinCenterZ)), model)
	cabin.Material = Enum.Material.SmoothPlastic
	cabin.Color = bodyColor

	local hoodLength = math.max(1.8, cabinLength * 0.34)
	local hood = createVehicleWedge(
		"Hood",
		Vector3.new(width * 0.9, height * 0.42, hoodLength),
		CFrame.new(origin + Vector3.new(0, height * 0.2 + 0.35, -length / 2 + hoodLength / 2 - 0.1)) * CFrame.Angles(0, math.pi, 0),
		model
	)
	hood.Material = Enum.Material.SmoothPlastic
	hood.Color = bodyColor

	local cargoLength = math.max(3.2, length - cabinLength - 1.0)
	local cargoHeight = if definition.Style == "pickup" then height * 0.45 else if definition.Style == "truck" then height * 1.15 else height * 0.9
	local cargoCenterZ = length / 2 - cargoLength / 2 - 0.3
	local cargo = createVehiclePart(
		"CargoBody",
		Vector3.new(width * 0.94, cargoHeight, cargoLength),
		CFrame.new(origin + Vector3.new(0, cargoHeight / 2 + 0.5, cargoCenterZ)),
		model
	)
	cargo.Material = if definition.Style == "truck" then Enum.Material.Metal else Enum.Material.SmoothPlastic
	cargo.Color = bodyColor

	if definition.Style == "premium_van" or definition.Style == "elite" then
		local roof = createVehiclePart(
			"RoofModule",
			Vector3.new(width * 0.6, 0.4, cabinLength * 0.55),
			CFrame.new(origin + Vector3.new(0, height + 1.0, cabinCenterZ)),
			model
		)
		roof.Material = Enum.Material.Metal
		roof.Color = Color3.fromRGB(238, 170, 66)
	end

	local windscreen = createVehiclePart(
		"Windscreen",
		Vector3.new(width * 0.72, height * 0.44, 0.18),
		CFrame.new(origin + Vector3.new(0, height * 0.7, cabinCenterZ - cabinLength / 2 - 0.1)),
		model
	)
	windscreen.Material = Enum.Material.Glass
	windscreen.Color = Color3.fromRGB(91, 158, 188)
	windscreen.Transparency = 0.18
	windscreen.CanCollide = false

	for _, side in { -1, 1 } do
		local sideWindow = createVehiclePart(
			"SideWindow",
			Vector3.new(0.18, height * 0.38, cabinLength * 0.52),
			CFrame.new(origin + Vector3.new(side * width * 0.47, height * 0.7, cabinCenterZ - cabinLength * 0.08)),
			model
		)
		sideWindow.Material = Enum.Material.Glass
		sideWindow.Color = Color3.fromRGB(79, 137, 164)
		sideWindow.Transparency = 0.2
		sideWindow.CanCollide = false

		local mirror = createVehiclePart(
			"Mirror",
			Vector3.new(0.45, 0.72, 0.9),
			CFrame.new(origin + Vector3.new(side * width * 0.58, height * 0.66, cabinCenterZ - cabinLength * 0.42)),
			model
		)
		mirror.Material = Enum.Material.Metal
		mirror.Color = Color3.fromRGB(38, 42, 46)
		mirror.CanCollide = false
	end

	local frontBumper =
		createVehiclePart("FrontBumper", Vector3.new(width * 0.92, 0.5, 0.55), CFrame.new(origin + Vector3.new(0, -0.15, -length / 2 - 0.2)), model)
	frontBumper.Material = Enum.Material.Metal
	frontBumper.Color = Color3.fromRGB(52, 56, 60)
	frontBumper.CanCollide = false

	local rearBumper =
		createVehiclePart("RearBumper", Vector3.new(width * 0.92, 0.5, 0.55), CFrame.new(origin + Vector3.new(0, -0.15, length / 2 + 0.2)), model)
	rearBumper.Material = Enum.Material.Metal
	rearBumper.Color = Color3.fromRGB(52, 56, 60)
	rearBumper.CanCollide = false

	local grille = createVehiclePart("FrontGrille", Vector3.new(width * 0.48, 0.9, 0.18), CFrame.new(origin + Vector3.new(0, 0.55, -length / 2 - 0.3)), model)
	grille.Material = Enum.Material.Metal
	grille.Color = Color3.fromRGB(36, 40, 44)
	grille.CanCollide = false

	for slot = -2, 2 do
		local slat = createVehiclePart("GrilleSlat", Vector3.new(0.12, 0.72, 0.22), grille.CFrame * CFrame.new(slot * width * 0.07, 0, -0.06), model)
		slat.Material = Enum.Material.Metal
		slat.Color = Color3.fromRGB(108, 114, 118)
		slat.CanCollide = false
	end

	local plate = createVehiclePart("RearPlate", Vector3.new(2.6, 0.8, 0.14), CFrame.new(origin + Vector3.new(0, 0.72, length / 2 + 0.31)), model)
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

	local stripe = createVehiclePart(
		"CompanyStripe",
		Vector3.new(width * 0.96, 0.35, cargoLength * 0.8),
		CFrame.new(origin + Vector3.new(0, math.max(1.0, cargoHeight * 0.55), cargoCenterZ + width * 0.48)),
		model
	)
	stripe.Material = Enum.Material.SmoothPlastic
	stripe.Color = Color3.fromRGB(245, 151, 49)
	stripe.CanCollide = false

	local brandPanel = createVehiclePart(
		"BrandPanel",
		Vector3.new(width * 0.82, math.max(1.1, cargoHeight * 0.38), 0.18),
		CFrame.new(origin + Vector3.new(0, math.max(1.2, cargoHeight * 0.62), cargoCenterZ + cargoLength / 2 + 0.08)),
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
		local headlight =
			createVehiclePart("Headlight", Vector3.new(1.0, 0.55, 0.18), CFrame.new(origin + Vector3.new(side * width * 0.28, 0.5, -length / 2 - 0.1)), model)
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
			createVehiclePart("TailLight", Vector3.new(0.8, 0.65, 0.18), CFrame.new(origin + Vector3.new(side * width * 0.3, 0.55, length / 2 + 0.1)), model)
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
	for axleIndex = 1, axleCount do
		local alpha = if axleCount == 1 then 0.5 else (axleIndex - 1) / (axleCount - 1)
		local z = -length * 0.36 + alpha * length * 0.72
		for _, side in { -1, 1 } do
			local wheel = createVehiclePart(
				("Wheel_%d_%d"):format(axleIndex, side),
				Vector3.new(1.2, 2.2, 2.2),
				CFrame.new(origin + Vector3.new(side * width * 0.52, -0.65, z)) * CFrame.Angles(0, 0, math.rad(90)),
				model
			)
			wheel.Shape = Enum.PartType.Cylinder
			wheel.Material = Enum.Material.SmoothPlastic
			wheel.Color = Color3.fromRGB(28, 30, 33)

			local rim = createVehiclePart(
				("Rim_%d_%d"):format(axleIndex, side),
				Vector3.new(1.24, 1.15, 1.15),
				CFrame.new(origin + Vector3.new(side * width * 0.525, -0.65, z)) * CFrame.Angles(0, 0, math.rad(90)),
				model
			)
			rim.Shape = Enum.PartType.Cylinder
			rim.Material = Enum.Material.Metal
			rim.Color = Color3.fromRGB(145, 150, 155)
			rim.CanCollide = false

			local archTrim = createVehiclePart(
				("WheelArchTrim_%d_%d"):format(axleIndex, side),
				Vector3.new(0.22, 0.38, 2.8),
				CFrame.new(origin + Vector3.new(side * width * 0.515, 0.38, z)),
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
	return model, seat, exhaustEmitter
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
	local model, seat, exhaustEmitter = buildProceduralVehicle(player, definition, slotIndex)
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

	table.insert(entries, {
		Model = model,
		Seat = seat,
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

function VehicleService:_Step(dt: number)
	for ownerUserId, entries in self._spawned do
		for index = #entries, 1, -1 do
			local entry = entries[index]
			local model = entry.Model
			local seat = entry.Seat
			if model.Parent == nil or seat.Parent == nil then
				table.remove(entries, index)
				continue
			end

			local occupant = seat.Occupant
			if occupant == nil then
				model:SetAttribute("Driving", false)
				model:SetAttribute("DriveThrottle", 0)
				model:SetAttribute("DriveSteer", 0)
				if entry.ExhaustEmitter then
					entry.ExhaustEmitter.Rate = 0
				end
				continue
			end

			local driver = Players:GetPlayerFromCharacter(occupant.Parent)
			if driver == nil or driver.UserId ~= ownerUserId then
				occupant.Sit = false
				model:SetAttribute("Driving", false)
				model:SetAttribute("DriveThrottle", 0)
				model:SetAttribute("DriveSteer", 0)
				if entry.ExhaustEmitter then
					entry.ExhaustEmitter.Rate = 0
				end
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
			model:SetAttribute("Driving", moving)
			model:SetAttribute("DriveThrottle", throttle)
			model:SetAttribute("DriveSteer", steer)
			if entry.ExhaustEmitter then
				entry.ExhaustEmitter.Rate = if moving then 7 + math.abs(throttle) * 7 else 2
			end
			if not moving then
				continue
			end

			local current = model:GetPivot()
			local turnRate = math.rad(55) * (0.35 + math.abs(throttle) * 0.65)
			local rotated = current * CFrame.Angles(0, -steer * turnRate * dt, 0)
			local distance = throttle * entry.Definition.Speed * dt
			model:PivotTo(rotated * CFrame.new(0, 0, -distance))

			if RunService:IsStudio() and model:GetAttribute("StudioDriveVerified") ~= true then
				model:SetAttribute("StudioDriveVerified", true)
				print(
					("[Repair Empire] VehicleDriveObserved id=%s throttle=%.2f steer=%.2f stepDistance=%.3f"):format(
						entry.Definition.Id,
						throttle,
						steer,
						math.abs(distance)
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
