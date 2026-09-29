--!strict

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local WorldConfig = require(ReplicatedStorage.RepairEmpire.Shared.world.WorldConfig)

local WorldVerticalLayerProbe = {}

local MAX_PLAYABLE_GROUND_Y = 1.5

local function raycastSurface(position: Vector3, excluded: { Instance }): RaycastResult?
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = excluded
	params.IgnoreWater = false
	return Workspace:Raycast(Vector3.new(position.X, 40, position.Z), Vector3.new(0, -80, 0), params)
end

local function collectSamples(world: Instance)
	local samples = {}

	local spawn = world:FindFirstChild("MainSpawn", true)
	assert(spawn and spawn:IsA("SpawnLocation"), "MainSpawn missing")
	table.insert(samples, {
		Name = "spawn",
		Position = spawn.Position,
		Exclude = { spawn },
	})

	for _, districtId in WorldConfig.DistrictOrder do
		local config = WorldConfig.Districts[districtId]
		local center = Vector3.new(config.Center[1], 0, config.Center[3])
		table.insert(samples, {
			Name = districtId .. "_road_center",
			Position = center,
			Exclude = {},
		})
		for _, offset in { -config.Spacing, config.Spacing } do
			table.insert(samples, {
				Name = ("%s_road_%d"):format(districtId, offset),
				Position = center + Vector3.new(offset, 0, 0),
				Exclude = {},
			})
		end
	end

	for _, tagged in CollectionService:GetTagged("RepairEmpireJobAnchor") do
		if tagged:IsA("BasePart") then
			table.insert(samples, {
				Name = "anchor_" .. tostring(tagged:GetAttribute("AnchorId")),
				Position = tagged.Position,
				Exclude = { tagged },
			})
		end
	end

	return samples
end

local function findSuspiciousBroadPlatforms(world: Instance)
	local result = {}
	for _, item in world:GetDescendants() do
		if item:IsA("BasePart") and item.CanCollide then
			local topY = item.Position.Y + item.Size.Y / 2
			local veryBroad = item.Size.X >= 40 and item.Size.Z >= 40
			local broadGrass = item.Material == Enum.Material.Grass and item.Size.X >= 20 and item.Size.Z >= 20
			if topY > MAX_PLAYABLE_GROUND_Y and (veryBroad or broadGrass) then
				table.insert(result, ("%s(top=%.2f,size=%.0fx%.0f)"):format(item:GetFullName(), topY, item.Size.X, item.Size.Z))
			end
		end
	end
	return result
end

local function findForeignBroadPlatforms(world: Instance)
	local result = {}
	for _, item in Workspace:GetDescendants() do
		if item:IsA("BasePart") and item ~= Workspace.Terrain and not item:IsDescendantOf(world) and item.CanCollide then
			local ownerModel = item:FindFirstAncestorOfClass("Model")
			local isCharacter = ownerModel ~= nil and ownerModel:FindFirstChildOfClass("Humanoid") ~= nil
			local isVehicle = ownerModel ~= nil and ownerModel:GetAttribute("OwnerUserId") ~= nil
			if not isCharacter and not isVehicle then
				local topY = item.Position.Y + item.Size.Y / 2
				if topY > -2 and item.Size.X >= 20 and item.Size.Z >= 20 then
					table.insert(result, ("%s(top=%.2f,size=%.0fx%.0f)"):format(item:GetFullName(), topY, item.Size.X, item.Size.Z))
				end
			end
		end
	end
	return result
end

local SAMPLE_OFFSETS = {
	Vector3.new(0, 0, 0),
	Vector3.new(5, 0, 0),
	Vector3.new(-5, 0, 0),
	Vector3.new(0, 0, 5),
	Vector3.new(0, 0, -5),
	Vector3.new(4, 0, 4),
	Vector3.new(-4, 0, 4),
	Vector3.new(4, 0, -4),
	Vector3.new(-4, 0, -4),
}

function WorldVerticalLayerProbe.Run(): boolean
	if not RunService:IsStudio() then
		return false
	end

	local world = Workspace:FindFirstChild("RepairEmpireWorld")
	assert(world ~= nil, "RepairEmpireWorld missing")

	local broadPlatforms = findSuspiciousBroadPlatforms(world)
	assert(#broadPlatforms == 0, "suspicious elevated broad collision surfaces: " .. table.concat(broadPlatforms, ","))

	local foreignPlatforms = findForeignBroadPlatforms(world)
	assert(#foreignPlatforms == 0, "foreign broad collision surfaces outside RepairEmpireWorld: " .. table.concat(foreignPlatforms, ","))

	local failures = {}
	local samples = collectSamples(world)
	local rayCount = 0
	for _, sample in samples do
		local excluded = {}
		for _, instance in sample.Exclude do
			table.insert(excluded, instance)
		end
		for offsetIndex, offset in SAMPLE_OFFSETS do
			rayCount += 1
			local hit = raycastSurface(sample.Position + offset, excluded)
			if hit == nil then
				table.insert(failures, ("%s[%d]:no_surface"):format(sample.Name, offsetIndex))
			elseif hit.Position.Y > MAX_PLAYABLE_GROUND_Y then
				table.insert(failures, ("%s[%d]:y=%.2f:%s"):format(sample.Name, offsetIndex, hit.Position.Y, hit.Instance:GetFullName()))
			end
		end
	end

	assert(#failures == 0, "unexpected elevated playable surfaces: " .. table.concat(failures, ","))

	print(
		("[Repair Empire] WorldVerticalLayerProbe passed samples=%d rays=%d elevatedBroadSurfaces=0 foreignBroadSurfaces=0 maxGroundY=%.1f"):format(
			#samples,
			rayCount,
			MAX_PLAYABLE_GROUND_Y
		)
	)
	return true
end

return WorldVerticalLayerProbe
