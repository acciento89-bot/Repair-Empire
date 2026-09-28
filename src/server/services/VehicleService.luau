--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage.RepairEmpire.Shared
local VehicleDefinitions = require(Shared.vehicles.VehicleDefinitions)
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

	local stripe = createVehiclePart(
		"CompanyStripe",
		Vector3.new(width * 0.96, 0.35, cargoLength * 0.8),
		CFrame.new(origin + Vector3.new(0, math.max(1.0, cargoHeight * 0.55), cargoCenterZ + width * 0.48)),
		model
	)
	stripe.Material = Enum.Material.SmoothPlastic
	stripe.Color = Color3.fromRGB(245, 151, 49)
	stripe.CanCollide = false

	for _, side in { -1, 1 } do
		local headlight = createVehiclePart(
			"Headlight",
			Vector3.new(1.0, 0.55, 0.18),
			CFrame.new(origin + Vector3.new(side * width * 0.28, 0.5, -length / 2 - 0.1)),
			model
		)
		headlight.Material = Enum.Material.Neon
		headlight.Color = Color3.fromRGB(255, 240, 188)
		headlight.CanCollide = false
	end

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
		end
	end

	model.PrimaryPart = chassis
	model.Parent = Workspace
	return model, seat
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

function VehicleService:_DestroySpawned(userId: number)
	local entries = self._spawned[userId]
	if entries then
		for _, entry in entries do
			if entry.Model and entry.Model.Parent then
				entry.Model:Destroy()
			end
		end
	end
	self._spawned[userId] = nil
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
	local model, seat = buildProceduralVehicle(player, definition, slotIndex)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") and model.PrimaryPart then
		local lateralOffset = if slotIndex == 1 then 8 else -8
		model:PivotTo(root.CFrame * CFrame.new(lateralOffset, 1.5, -12))
	end

	table.insert(entries, {
		Model = model,
		Seat = seat,
		Definition = definition,
	})
	self._spawned[player.UserId] = entries
	return { ok = true, activeVehicles = #entries, maxVehicles = maxVehicles }
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
				continue
			end

			local driver = Players:GetPlayerFromCharacter(occupant.Parent)
			if driver == nil or driver.UserId ~= ownerUserId then
				occupant.Sit = false
				continue
			end

			local throttle = seat.ThrottleFloat
			local steer = seat.SteerFloat
			if math.abs(throttle) < 0.01 and math.abs(steer) < 0.01 then
				continue
			end

			local current = model:GetPivot()
			local turnRate = math.rad(55) * (0.35 + math.abs(throttle) * 0.65)
			local rotated = current * CFrame.Angles(0, -steer * turnRate * dt, 0)
			local distance = throttle * entry.Definition.Speed * dt
			model:PivotTo(rotated * CFrame.new(0, 0, -distance))
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
