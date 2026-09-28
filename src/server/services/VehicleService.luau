--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local VehicleDefinitions = require(ReplicatedStorage.RepairEmpire.Shared.vehicles.VehicleDefinitions)

local VehicleService = {
	Name = "VehicleService",
	Dependencies = { "PlayerDataService", "EconomyService", "SecurityService" },
	_spawned = {},
}

local function remote(name: string): RemoteFunction
	local instance = ReplicatedStorage:WaitForChild("RepairEmpireRemotes"):WaitForChild(name)
	assert(instance:IsA("RemoteFunction"), name .. " must be a RemoteFunction")
	return instance
end

local function buildPlaceholderVehicle(player: Player, definition)
	local model = Instance.new("Model")
	model.Name = ("Vehicle_%d"):format(player.UserId)
	model:SetAttribute("OwnerUserId", player.UserId)
	model:SetAttribute("VehicleId", definition.Id)

	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(7, 2.4, 12)
	body.Anchored = true
	body.CanCollide = true
	body.Position = Vector3.new(0, 4, 0)
	body.Parent = model

	local seat = Instance.new("VehicleSeat")
	seat.Name = "DriverSeat"
	seat.Size = Vector3.new(2, 1, 2)
	seat.Anchored = true
	seat.CanCollide = false
	seat.Position = body.Position + Vector3.new(0, 1.8, 1)
	seat.MaxSpeed = definition.Speed
	seat.Parent = model

	for index, offset in
		{
			Vector3.new(-3.4, -1.1, -4),
			Vector3.new(3.4, -1.1, -4),
			Vector3.new(-3.4, -1.1, 4),
			Vector3.new(3.4, -1.1, 4),
		}
	do
		local wheel = Instance.new("Part")
		wheel.Name = ("Wheel_%d"):format(index)
		wheel.Shape = Enum.PartType.Cylinder
		wheel.Size = Vector3.new(1.4, 2.2, 2.2)
		wheel.Anchored = true
		wheel.CanCollide = false
		wheel.CFrame = CFrame.new(body.Position + offset) * CFrame.Angles(0, 0, math.rad(90))
		wheel.Parent = model
	end

	model.PrimaryPart = body
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
	local entry = self._spawned[userId]
	if entry and entry.Model and entry.Model.Parent then
		entry.Model:Destroy()
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

	self:_DestroySpawned(player.UserId)

	local model, seat = buildPlaceholderVehicle(player, definition)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") and model.PrimaryPart then
		model:PivotTo(root.CFrame * CFrame.new(8, 1.5, -12))
	end

	self._spawned[player.UserId] = {
		Model = model,
		Seat = seat,
		Definition = definition,
	}
	return { ok = true }
end

function VehicleService:_Step(dt: number)
	for ownerUserId, entry in self._spawned do
		local model = entry.Model
		local seat = entry.Seat
		if model.Parent == nil or seat.Parent == nil then
			self._spawned[ownerUserId] = nil
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
