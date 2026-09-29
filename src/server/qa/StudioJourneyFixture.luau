--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local ProfileSchema = require(ReplicatedStorage.RepairEmpire.Shared.data.ProfileSchema)

local StudioJourneyFixture = {}

local function copyInto(target, source)
	for key in target do
		target[key] = nil
	end
	for key, value in source do
		target[key] = value
	end
end

local function waitForProfile(player: Player)
	local dataService = require(script.Parent.Parent.services.PlayerDataService)
	for _ = 1, 100 do
		local profile = dataService:GetProfile(player)
		if profile ~= nil then
			return dataService, profile
		end
		task.wait(0.1)
	end
	error("Studio E2E profile did not load")
end

local function findOwnedVehicle(player: Player): Model?
	for _, child in Workspace:GetChildren() do
		if child:IsA("Model") and child:GetAttribute("OwnerUserId") == player.UserId then
			return child
		end
	end
	return nil
end

local function prepare(player: Player)
	local dataService, profile = waitForProfile(player)
	copyInto(profile, ProfileSchema.NewProfile())
	dataService:Publish(player)
	player:SetAttribute("StudioE2EReady", true)
	print("[Repair Empire E2E] FIXTURE fresh profile ready")

	task.spawn(function()
		while player.Parent and profile.Stats.JobsCompleted < 1 do
			task.wait(0.2)
		end
		if not player.Parent then
			return
		end
		local economy = require(script.Parent.Parent.services.EconomyService)
		economy:Grant(player, "cash", 20_000, "studio_e2e_fixture")
		player:SetAttribute("StudioE2ECashReady", true)
		print("[Repair Empire E2E] FIXTURE post-job cash ready")
	end)

	task.spawn(function()
		while player.Parent and findOwnedVehicle(player) == nil do
			task.wait(0.2)
		end
		if not player.Parent then
			return
		end
		local model = findOwnedVehicle(player)
		local seat = model and model:FindFirstChild("DriverSeat", true)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		assert(seat and seat:IsA("VehicleSeat"), "Studio E2E driver seat missing")
		assert(humanoid ~= nil, "Studio E2E humanoid missing")
		seat:Sit(humanoid)
		for _ = 1, 30 do
			if seat.Occupant == humanoid then
				player:SetAttribute("StudioE2EVehicleSeated", true)
				print("[Repair Empire E2E] FIXTURE vehicle seated")
				return
			end
			task.wait(0.1)
		end
		error("Studio E2E could not seat player")
	end)

	task.spawn(function()
		while player.Parent and (profile.WorkshopTier < 2 or (profile.Employees.apprentice_plumbing or 0) < 1) do
			task.wait(0.2)
		end
		if not player.Parent then
			return
		end
		local previous = player.Character
		player:LoadCharacter()
		for _ = 1, 50 do
			local nextCharacter = player.Character
			if nextCharacter ~= nil and nextCharacter ~= previous then
				player:SetAttribute("StudioE2ERespawned", true)
				print("[Repair Empire E2E] FIXTURE respawn complete")
				return
			end
			task.wait(0.1)
		end
		error("Studio E2E respawn did not produce a new character")
	end)
end

function StudioJourneyFixture.Start()
	if not RunService:IsStudio() or Workspace:GetAttribute("RepairEmpireE2E") ~= true then
		return
	end

	for _, player in Players:GetPlayers() do
		task.spawn(prepare, player)
	end
	Players.PlayerAdded:Connect(function(player)
		task.spawn(prepare, player)
	end)
end

return StudioJourneyFixture