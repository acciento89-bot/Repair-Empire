--!strict

local CollectionService = game:GetService("CollectionService")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local WorldReachabilityProbe = {}

local CATEGORIES = { "plumbing", "heating", "climate", "energy" }
local DISTRICTS = { "residential", "downtown", "industrial" }

local function raycastGround(anchor: BasePart)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { anchor }
	params.IgnoreWater = false
	return Workspace:Raycast(anchor.Position + Vector3.new(0, 12, 0), Vector3.new(0, -30, 0), params)
end

local function serviceAreaClear(anchor: BasePart): boolean
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { anchor }

	local parts = Workspace:GetPartBoundsInBox(
		CFrame.new(anchor.Position + Vector3.new(0, 2.8, 0)),
		Vector3.new(7.5, 5.0, 7.5),
		params
	)

	for _, candidate in parts do
		if candidate.CanCollide and candidate.Transparency < 0.95 then
			local top = candidate.Position.Y + candidate.Size.Y / 2
			if top > 1.1 then
				return false
			end
		end
	end
	return true
end

local function representativeAnchors()
	local result = {}
	for _, districtId in DISTRICTS do
		for _, categoryId in CATEGORIES do
			local selected = nil
			for _, anchor in CollectionService:GetTagged("RepairEmpireJobAnchor") do
				if anchor:IsA("BasePart")
					and anchor:GetAttribute("DistrictId") == districtId
					and anchor:GetAttribute("CategoryId") == categoryId
				then
					selected = anchor
					break
				end
			end
			assert(selected ~= nil, ("missing representative anchor %s/%s"):format(districtId, categoryId))
			table.insert(result, selected)
		end
	end
	return result
end

local function pathExists(startPosition: Vector3, targetPosition: Vector3): boolean
	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		AgentCanClimb = false,
		WaypointSpacing = 6,
	})
	local ok = pcall(function()
		path:ComputeAsync(startPosition, targetPosition)
	end)
	return ok and path.Status == Enum.PathStatus.Success and #path:GetWaypoints() >= 2
end

function WorldReachabilityProbe.Run(): boolean
	if not RunService:IsStudio() then
		return false
	end

	local world = Workspace:FindFirstChild("RepairEmpireWorld")
	assert(world ~= nil, "RepairEmpireWorld missing")
	local spawn = world:FindFirstChild("MainSpawn", true)
	assert(spawn and spawn:IsA("SpawnLocation"), "MainSpawn missing")

	local anchors = CollectionService:GetTagged("RepairEmpireJobAnchor")
	assert(#anchors >= 30, "job anchor catalog unexpectedly small")

	local groundFailures = {}
	local clearanceFailures = {}
	for _, instance in anchors do
		if instance:IsA("BasePart") then
			local ground = raycastGround(instance)
			if ground == nil or math.abs(ground.Position.Y) > 1.2 then
				table.insert(groundFailures, tostring(instance:GetAttribute("AnchorId")))
			end
			if not serviceAreaClear(instance) then
				table.insert(clearanceFailures, tostring(instance:GetAttribute("AnchorId")))
			end
		end
	end

	assert(#groundFailures == 0, "anchors without valid ground: " .. table.concat(groundFailures, ","))
	assert(#clearanceFailures == 0, "anchors blocked by collidable geometry: " .. table.concat(clearanceFailures, ","))

	local routeFailures = {}
	local start = spawn.Position + Vector3.new(0, 2, 0)
	for _, anchor in representativeAnchors() do
		if not pathExists(start, anchor.Position) then
			table.insert(
				routeFailures,
				("%s/%s"):format(tostring(anchor:GetAttribute("DistrictId")), tostring(anchor:GetAttribute("CategoryId")))
			)
		end
	end
	assert(#routeFailures == 0, "unreachable representative job routes: " .. table.concat(routeFailures, ","))

	print(
		("[Repair Empire] WorldReachabilityProbe passed anchors=%d ground=ok clearance=ok representativeRoutes=%d"):format(
			#anchors,
			#DISTRICTS * #CATEGORIES
		)
	)
	return true
end

return WorldReachabilityProbe
