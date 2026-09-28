--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local VehicleDefinitions = require(ReplicatedStorage.RepairEmpire.Shared.vehicles.VehicleDefinitions)

local VehicleService = {
	Name = "VehicleService",
	Dependencies = { "PlayerDataService", "EconomyService" },
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

	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(7, 2.4, 12)
	body.Anchored = false
	body.Position = Vector3.new(0, 6, 0)
	body.Parent = model

	local seat = Instance.new("VehicleSeat")
	seat.Name = "DriverSeat"
	seat.Size = Vector3.new(2, 1, 2)
	seat.Position = body.Position + Vector3.new(0, 1.8, 0)
	seat.MaxSpeed = definition.Speed
	seat.Parent = model

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = body
	weld.Part1 = seat
	weld.Parent = seat

	model.PrimaryPart = body
	model.Parent = Workspace
	return model
end

function VehicleService:Purchase(player: Player, vehicleId: any)
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

function VehicleService:Spawn(player: Player)
	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	local definition = VehicleDefinitions.ById[profile.SelectedVehicle]
	if definition == nil then
		return { ok = false, error = "invalid_selected_vehicle" }
	end

	local previous = self._spawned[player.UserId]
	if previous and previous.Parent then
		previous:Destroy()
	end

	local model = buildPlaceholderVehicle(player, definition)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") and model.PrimaryPart then
		model:PivotTo(root.CFrame * CFrame.new(8, 0, -12))
	end

	self._spawned[player.UserId] = model
	return { ok = true }
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
end

function VehicleService:Start() end

return VehicleService
