--!strict

local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local StarterPack = game:GetService("StarterPack")
local Stats = game:GetService("Stats")

local WorldConfig = require(ReplicatedStorage.RepairEmpire.Shared.world.WorldConfig)
local WorldLayoutRules = require(ReplicatedStorage.RepairEmpire.Shared.world.WorldLayoutRules)
local SpatialRules = require(ReplicatedStorage.RepairEmpire.Shared.security.SpatialRules)

local CATEGORIES = { "plumbing", "heating", "climate", "energy" }

local WorldService = {
	Name = "WorldService",
	Dependencies = {},
	_anchorsById = {},
	_anchorsByDistrictCategory = {},
}

local function createPart(name: string, size: Vector3, cframe: CFrame, parent: Instance): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function vectorFromArray(values): Vector3
	return Vector3.new(values[1], values[2], values[3])
end

local function clearLegacyPlaceContent()
	local terrain = Workspace:FindFirstChildOfClass("Terrain")
	if terrain then
		terrain:Clear()
	end

	for _, name in WorldConfig.LegacyWorkspaceRoots do
		local legacy = Workspace:FindFirstChild(name)
		if legacy and not legacy:IsA("Terrain") then
			legacy:Destroy()
		end
	end

	StarterPack:ClearAllChildren()
	for _, child in StarterGui:GetChildren() do
		child:Destroy()
	end
end

local function addDistrictSign(parent: Instance, center: Vector3, displayName: string)
	local sign = createPart("DistrictSign", Vector3.new(18, 6, 1), CFrame.new(center + Vector3.new(0, 5, -8)), parent)
	sign.Material = Enum.Material.Metal
	sign.Color = Color3.fromRGB(45, 48, 54)

	local surface = Instance.new("SurfaceGui")
	surface.Name = "Label"
	surface.Face = Enum.NormalId.Front
	surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surface.PixelsPerStud = 36
	surface.Parent = sign

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(245, 245, 245)
	label.Text = displayName
	label.Parent = surface
end

local function addStreetFurniture(parent: Instance, center: Vector3, spacing: number)
	for index = -2, 2 do
		local x = center.X + index * spacing
		for _, zOffset in { -14, 14 } do
			local pole = createPart("StreetLightPole", Vector3.new(0.6, 9, 0.6), CFrame.new(x, 4.5, center.Z + zOffset), parent)
			pole.Material = Enum.Material.Metal
			pole.Color = Color3.fromRGB(70, 72, 76)

			local lamp = createPart("StreetLight", Vector3.new(2.4, 0.5, 1.2), CFrame.new(x, 9, center.Z + zOffset), parent)
			lamp.Material = Enum.Material.Neon
			lamp.Color = Color3.fromRGB(255, 236, 190)
		end
	end
end

local function addRoadDetails(parent: Instance, center: Vector3, groundX: number)
	for _, side in { -1, 1 } do
		local sidewalk =
			createPart("Sidewalk", Vector3.new(groundX, 0.5, 5), CFrame.new(center + Vector3.new(0, 0.25, side * (WorldConfig.RoadWidth / 2 + 2.5))), parent)
		sidewalk.Material = Enum.Material.Concrete
		sidewalk.Color = Color3.fromRGB(165, 165, 165)
	end

	local dashCount = math.floor(groundX / 18)
	for index = 1, dashCount do
		local x = center.X - groundX / 2 + index * 18
		local dash = createPart("LaneDash", Vector3.new(8, 0.08, 0.35), CFrame.new(x, 0.43, center.Z), parent)
		dash.Material = Enum.Material.SmoothPlastic
		dash.Color = Color3.fromRGB(240, 222, 120)
		dash.CanCollide = false
	end
end

local function addTree(parent: Instance, position: Vector3, scale: number)
	local trunk = createPart("TreeTrunk", Vector3.new(1.2 * scale, 5 * scale, 1.2 * scale), CFrame.new(position + Vector3.new(0, 2.5 * scale, 0)), parent)
	trunk.Material = Enum.Material.Wood
	trunk.Color = Color3.fromRGB(104, 77, 52)

	local crown = createPart("TreeCrown", Vector3.new(6 * scale, 6 * scale, 6 * scale), CFrame.new(position + Vector3.new(0, 7 * scale, 0)), parent)
	crown.Shape = Enum.PartType.Ball
	crown.Material = Enum.Material.Grass
	crown.Color = Color3.fromRGB(75, 132, 70)
	crown.CanCollide = false
end

local function addResidentialWorkshop(parent: Instance, config)
	local model = Instance.new("Model")
	model.Name = "PlayerWorkshop"
	model:SetAttribute("IsWorkshop", true)
	model.Parent = parent

	local x, z = WorldLayoutRules.GetWorkshopCenter(config, WorldConfig.WorkshopReservedBuildingIndex, WorldConfig.WorkshopReservedBuildingSlots)

	local pad = createPart("WorkshopPad", Vector3.new(92, 0.5, 58), CFrame.new(x, 0.25, z + 4), model)
	pad.Material = Enum.Material.Concrete
	pad.Color = Color3.fromRGB(112, 116, 120)

	for stripeIndex = -2, 1 do
		local stripe = createPart("ServiceBayStripe", Vector3.new(1.4, 0.08, 18), CFrame.new(x + stripeIndex * 10 + 5, 0.55, z - 11), model)
		stripe.Material = Enum.Material.SmoothPlastic
		stripe.Color = Color3.fromRGB(245, 151, 49)
		stripe.CanCollide = false
	end

	local building = createPart("WorkshopBuilding", Vector3.new(44, 13, 28), CFrame.new(x - 12, 6.5, z + 16), model)
	building.Material = Enum.Material.Brick
	building.Color = Color3.fromRGB(144, 99, 73)

	local roof = createPart("WorkshopRoof", Vector3.new(46, 1.2, 30), CFrame.new(x - 12, 13.6, z + 16), model)
	roof.Material = Enum.Material.Metal
	roof.Color = Color3.fromRGB(61, 64, 70)

	local door = createPart("GarageDoor", Vector3.new(14, 8, 0.6), CFrame.new(x - 12, 4, z + 1.7), model)
	door.Material = Enum.Material.Metal
	door.Color = Color3.fromRGB(95, 98, 105)

	for windowIndex = -1, 1, 2 do
		local window = createPart("WorkshopWindow", Vector3.new(5.5, 3.5, 0.4), CFrame.new(x - 12 + windowIndex * 12, 6.4, z + 1.65), model)
		window.Material = Enum.Material.Glass
		window.Color = Color3.fromRGB(110, 178, 210)
		window.Transparency = 0.2
		window.CanCollide = false
	end

	local awning = createPart("WorkshopAwning", Vector3.new(20, 0.5, 4), CFrame.new(x - 12, 10, z), model)
	awning.Material = Enum.Material.Metal
	awning.Color = Color3.fromRGB(245, 151, 49)

	local brandSign = createPart("WorkshopBrandSign", Vector3.new(22, 4.5, 0.5), CFrame.new(x - 12, 11, z + 1.3), model)
	brandSign.Material = Enum.Material.Metal
	brandSign.Color = Color3.fromRGB(20, 34, 46)
	local brandGui = Instance.new("SurfaceGui")
	brandGui.Face = Enum.NormalId.Front
	brandGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	brandGui.PixelsPerStud = 42
	brandGui.Parent = brandSign
	local brandText = Instance.new("TextLabel")
	brandText.Size = UDim2.fromScale(1, 1)
	brandText.BackgroundTransparency = 1
	brandText.Font = Enum.Font.GothamBold
	brandText.TextScaled = true
	brandText.TextColor3 = Color3.fromRGB(245, 151, 49)
	brandText.Text = "REPAIR EMPIRE"
	brandText.Parent = brandGui

	for _, side in { -1, 1 } do
		local bollard = createPart("SafetyBollard", Vector3.new(0.8, 3.2, 0.8), CFrame.new(x - 12 + side * 9, 1.6, z - 1.2), model)
		bollard.Material = Enum.Material.Metal
		bollard.Color = Color3.fromRGB(245, 151, 49)
	end

	local toolRack = createPart("ToolRack", Vector3.new(10, 5, 1), CFrame.new(x + 31, 2.5, z + 12), model)
	toolRack.Material = Enum.Material.Metal
	toolRack.Color = Color3.fromRGB(42, 52, 60)
	for toolIndex = -2, 2 do
		local tool = createPart("DisplayTool", Vector3.new(0.35, 3.2, 0.35), CFrame.new(x + 31 + toolIndex * 1.4, 2.8, z + 11.4), model)
		tool.Material = Enum.Material.Metal
		tool.Color = if toolIndex % 2 == 0 then Color3.fromRGB(245, 151, 49) else Color3.fromRGB(186, 196, 205)
		tool.CanCollide = false
	end

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "MainSpawn"
	spawn.Size = Vector3.new(10, 1, 10)
	spawn.CFrame = CFrame.new(x + 14, 0.5, z - 15)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.AllowTeamChangeOnTouch = false
	spawn.Transparency = 0.45
	spawn.Material = Enum.Material.SmoothPlastic
	spawn.Color = Color3.fromRGB(75, 160, 210)
	spawn.Parent = model

	for index, offset in { Vector3.new(-26, 0, -12), Vector3.new(-28, 0, 14), Vector3.new(26, 0, 15) } do
		addTree(model, Vector3.new(x, 0, z) + offset, 0.9 + index * 0.08)
	end
end

local function addBuildingDetails(
	building: Model,
	districtId: string,
	x: number,
	z: number,
	width: number,
	depth: number,
	height: number,
	index: number,
	frontSign: number
)
	local roof = createPart("Roof", Vector3.new(width + 1.2, 0.8, depth + 1.2), CFrame.new(x, height + 0.4, z), building)
	roof.Material = Enum.Material.Metal
	roof.Color = Color3.fromRGB(68, 70, 76)

	local entrance = createPart("Entrance", Vector3.new(4.5, 6, 0.45), CFrame.new(x, 3, z + frontSign * (depth / 2 + 0.25)), building)
	entrance.Material = Enum.Material.Glass
	entrance.Color = Color3.fromRGB(86, 142, 170)
	entrance.Transparency = 0.2
	entrance.CanCollide = false

	if districtId == "residential" then
		for _, side in { -1, 1 } do
			local window = createPart(
				"FrontWindow",
				Vector3.new(6, 4, 0.35),
				CFrame.new(x + side * width * 0.24, math.min(height - 4, 7), z + frontSign * (depth / 2 + 0.2)),
				building
			)
			window.Material = Enum.Material.Glass
			window.Color = Color3.fromRGB(120, 180, 205)
			window.Transparency = 0.25
			window.CanCollide = false
		end
	elseif districtId == "downtown" then
		local floors = math.max(2, math.floor(height / 8))
		for floorIndex = 1, floors do
			local y = math.min(height - 2, floorIndex * 7)
			for _, faceZ in { -1, 1 } do
				local band = createPart("WindowBand", Vector3.new(width * 0.78, 2.6, 0.28), CFrame.new(x, y, z + faceZ * (depth / 2 + 0.16)), building)
				band.Material = Enum.Material.Glass
				band.Color = Color3.fromRGB(98, 150, 180)
				band.Transparency = 0.3
				band.CanCollide = false
			end
		end
	elseif districtId == "industrial" then
		local vent = createPart("RoofVent", Vector3.new(5, 4, 5), CFrame.new(x + width * 0.22, height + 2.4, z), building)
		vent.Material = Enum.Material.Metal
		vent.Color = Color3.fromRGB(90, 92, 96)

		if index % 2 == 0 then
			local pipe = createPart("ServicePipe", Vector3.new(1.2, 10, 1.2), CFrame.new(x - width / 2 - 1, 5, z + depth * 0.2), building)
			pipe.Shape = Enum.PartType.Cylinder
			pipe.Material = Enum.Material.Metal
			pipe.Color = Color3.fromRGB(156, 116, 72)
		end
	end
end

local function addServiceWalkway(parent: Instance, config, buildingX: number, buildingZ: number)
	local walkwayZ, walkwayLength = WorldLayoutRules.GetServiceWalkway({
		Center = config.Center,
		BuildingSize = config.BuildingSize,
		RoadWidth = WorldConfig.RoadWidth,
	}, buildingZ)
	local walkway = createPart("ServiceWalkway", Vector3.new(6, 0.22, walkwayLength), CFrame.new(buildingX, 0.11, walkwayZ), parent)
	walkway.Material = Enum.Material.Concrete
	walkway.Color = Color3.fromRGB(186, 188, 190)
end

local function addConnectorRoad(parent: Instance, fromCenter: Vector3, toCenter: Vector3)
	local from = Vector3.new(fromCenter.X, 0.2, fromCenter.Z)
	local to = Vector3.new(toCenter.X, 0.2, toCenter.Z)
	local delta = to - from
	local distance = delta.Magnitude
	if distance <= 0 then
		return
	end

	local midpoint = (from + to) / 2
	local road = createPart("ConnectorRoad", Vector3.new(WorldConfig.ConnectorRoadWidth, 0.4, distance), CFrame.lookAt(midpoint, to), parent)
	road.Material = Enum.Material.Asphalt
	road.Color = Color3.fromRGB(55, 57, 60)

	local dashCount = math.floor(distance / 20)
	local direction = delta.Unit
	for index = 1, dashCount do
		local position = from + direction * (index * 20)
		local dash = createPart("ConnectorDash", Vector3.new(0.35, 0.08, 8), CFrame.lookAt(position + Vector3.new(0, 0.23, 0), to), parent)
		dash.Material = Enum.Material.SmoothPlastic
		dash.Color = Color3.fromRGB(240, 222, 120)
		dash.CanCollide = false
	end
end

function WorldService:_RegisterAnchor(anchor: BasePart, districtId: string, categoryId: string, anchorId: string)
	anchor.Name = "JobAnchor"
	anchor.Transparency = 1
	anchor.CanCollide = false
	anchor.CanQuery = true
	anchor:SetAttribute("AnchorId", anchorId)
	anchor:SetAttribute("DistrictId", districtId)
	anchor:SetAttribute("CategoryId", categoryId)
	CollectionService:AddTag(anchor, "RepairEmpireJobAnchor")

	self._anchorsById[anchorId] = anchor
	self._anchorsByDistrictCategory[districtId] = self._anchorsByDistrictCategory[districtId] or {}
	local district = self._anchorsByDistrictCategory[districtId]
	district[categoryId] = district[categoryId] or {}
	table.insert(district[categoryId], anchor)
end

function WorldService:_BuildDistrict(world: Folder, districtId: string, config)
	local folder = Instance.new("Folder")
	folder.Name = districtId
	folder.Parent = world

	local center = vectorFromArray(config.Center)
	local groundX = config.GroundSize[1]
	local groundZ = config.GroundSize[2]
	local base = createPart("DistrictBase", Vector3.new(groundX, 1, groundZ), CFrame.new(center + Vector3.new(0, -0.5, 0)), folder)
	base.Material = if districtId == "residential" then Enum.Material.Grass else Enum.Material.Concrete
	base.Color = if districtId == "residential"
		then Color3.fromRGB(104, 142, 87)
		else if districtId == "downtown" then Color3.fromRGB(130, 132, 136) else Color3.fromRGB(112, 111, 105)

	local mainRoad = createPart("MainRoad", Vector3.new(groundX, 0.4, WorldConfig.RoadWidth), CFrame.new(center + Vector3.new(0, 0.2, 0)), folder)
	mainRoad.Material = Enum.Material.Asphalt
	mainRoad.Color = Color3.fromRGB(54, 56, 59)

	addRoadDetails(folder, center, groundX)
	addDistrictSign(folder, center + Vector3.new(-groundX / 2 + 18, 0, 0), config.DisplayName)
	addStreetFurniture(folder, center, config.Spacing)

	if districtId == "residential" then
		addResidentialWorkshop(folder, config)
		for _, offset in { Vector3.new(-90, 0, 72), Vector3.new(88, 0, 75), Vector3.new(95, 0, -72), Vector3.new(-92, 0, -70) } do
			addTree(folder, center + offset, 1)
		end
	end

	for index = 1, config.BuildingCount do
		if WorldLayoutRules.IsReservedBuildingSlot(districtId, index, WorldConfig.WorkshopReservedBuildingIndex, WorldConfig.WorkshopReservedBuildingSlots) then
			continue
		end

		local x, z = WorldLayoutRules.GetBuildingPosition(config, index)
		local height = config.HeightBase + ((index * 7) % config.HeightVariance)

		local building = Instance.new("Model")
		building.Name = ("Building_%02d"):format(index)
		building:SetAttribute("DistrictId", districtId)
		building.Parent = folder

		local shell = createPart("Shell", Vector3.new(config.BuildingSize[1], height, config.BuildingSize[2]), CFrame.new(x, height / 2, z), building)
		if districtId == "industrial" then
			shell.Material = Enum.Material.Metal
			shell.Color = if index % 2 == 0 then Color3.fromRGB(118, 122, 128) else Color3.fromRGB(101, 106, 112)
		elseif districtId == "downtown" then
			shell.Material = Enum.Material.Concrete
			shell.Color = if index % 2 == 0 then Color3.fromRGB(132, 142, 154) else Color3.fromRGB(155, 148, 140)
		else
			shell.Material = Enum.Material.Brick
			shell.Color = if index % 2 == 0 then Color3.fromRGB(156, 113, 86) else Color3.fromRGB(177, 145, 105)
		end

		local frontSign = if z > center.Z then -1 else 1
		addBuildingDetails(building, districtId, x, z, config.BuildingSize[1], config.BuildingSize[2], height, index, frontSign)
		addServiceWalkway(building, config, x, z)

		if districtId == "downtown" and index % 2 == 0 then
			local crown =
				createPart("TowerCrown", Vector3.new(config.BuildingSize[1] * 0.7, 5, config.BuildingSize[2] * 0.7), CFrame.new(x, height + 3.3, z), building)
			crown.Material = Enum.Material.Glass
			crown.Color = Color3.fromRGB(92, 142, 174)
			crown.Transparency = 0.25
		elseif districtId == "industrial" and index % 2 == 1 then
			local tank = createPart("ServiceTank", Vector3.new(8, 12, 8), CFrame.new(x + 15, 6, z), building)
			tank.Shape = Enum.PartType.Cylinder
			tank.CFrame *= CFrame.Angles(0, 0, math.rad(90))
			tank.Material = Enum.Material.Metal
			tank.Color = Color3.fromRGB(148, 150, 150)
		end

		for categoryIndex, categoryId in CATEGORIES do
			local anchorX, anchorZ = WorldLayoutRules.GetJobAnchorPosition(config, x, z, categoryIndex)
			local anchor = createPart("JobAnchor", Vector3.new(3, 3, 3), CFrame.new(anchorX, 1.5, anchorZ), building)
			local anchorId = ("%s_%02d_%s"):format(districtId, index, categoryId)
			self:_RegisterAnchor(anchor, districtId, categoryId, anchorId)
		end
	end
end

function WorldService:GetAnchor(anchorId: string): BasePart?
	return self._anchorsById[anchorId]
end

function WorldService:AssignAnchor(districtId: string, categoryId: string)
	local district = self._anchorsByDistrictCategory[districtId]
	local candidates = district and district[categoryId]
	if candidates == nil or #candidates == 0 then
		return nil
	end
	return candidates[math.random(1, #candidates)]
end

function WorldService:IsPlayerNearAnchor(player: Player, anchorId: string): boolean
	local anchor = self:GetAnchor(anchorId)
	if anchor == nil then
		return false
	end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root == nil or not root:IsA("BasePart") then
		return false
	end
	return SpatialRules.IsWithinDistance(
		root.Position.X,
		root.Position.Y,
		root.Position.Z,
		anchor.Position.X,
		anchor.Position.Y,
		anchor.Position.Z,
		WorldConfig.AnchorInteractionDistance
	)
end

local function logStudioWorldBaseline(world: Folder)
	if not RunService:IsStudio() then
		return
	end

	task.spawn(function()
		local partCount = 0
		for _, descendant in world:GetDescendants() do
			if descendant:IsA("BasePart") then
				partCount += 1
			end
		end

		local memoryMb = 0
		local memoryOk, memoryValue = pcall(function()
			return Stats:GetTotalMemoryUsageMb()
		end)
		if memoryOk then
			memoryMb = memoryValue
		end

		local elapsed = 0
		for _ = 1, 120 do
			elapsed += RunService.Heartbeat:Wait()
		end
		local averageHeartbeat = elapsed / 120
		local approximateFps = if averageHeartbeat > 0 then 1 / averageHeartbeat else 0

		print(
			("[Repair Empire] StudioWorldBaseline streaming=%s parts=%d descendants=%d memoryMb=%.1f heartbeatMs=%.2f approxFps=%.1f"):format(
				tostring(Workspace.StreamingEnabled),
				partCount,
				#world:GetDescendants(),
				memoryMb,
				averageHeartbeat * 1000,
				approximateFps
			)
		)
	end)
end

function WorldService:Init()
	clearLegacyPlaceContent()

	local existing = Workspace:FindFirstChild("RepairEmpireWorld")
	if existing then
		existing:Destroy()
	end

	self._anchorsById = {}
	self._anchorsByDistrictCategory = {}

	Lighting.ClockTime = 14
	Lighting.Brightness = 2
	Lighting.EnvironmentDiffuseScale = 0.45
	Lighting.EnvironmentSpecularScale = 0.35
	Lighting.OutdoorAmbient = Color3.fromRGB(145, 145, 155)

	local colorCorrection = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
	if colorCorrection == nil then
		colorCorrection = Instance.new("ColorCorrectionEffect")
		colorCorrection.Parent = Lighting
	end
	colorCorrection.Brightness = 0.02
	colorCorrection.Contrast = 0.08
	colorCorrection.Saturation = 0.05
	colorCorrection.TintColor = Color3.fromRGB(255, 248, 238)

	local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
	if bloom == nil then
		bloom = Instance.new("BloomEffect")
		bloom.Parent = Lighting
	end
	bloom.Intensity = 0.12
	bloom.Size = 18
	bloom.Threshold = 1.8

	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosphere == nil then
		atmosphere = Instance.new("Atmosphere")
		atmosphere.Parent = Lighting
	end
	atmosphere.Density = 0.24
	atmosphere.Offset = 0.05
	atmosphere.Glare = 0.08
	atmosphere.Haze = 1.4
	atmosphere.Color = Color3.fromRGB(205, 222, 235)

	local world = Instance.new("Folder")
	world.Name = "RepairEmpireWorld"
	world.Parent = Workspace

	for districtId, config in WorldConfig.Districts do
		self:_BuildDistrict(world, districtId, config)
	end

	for index = 1, #WorldConfig.DistrictOrder - 1 do
		local fromConfig = WorldConfig.Districts[WorldConfig.DistrictOrder[index]]
		local toConfig = WorldConfig.Districts[WorldConfig.DistrictOrder[index + 1]]
		addConnectorRoad(world, vectorFromArray(fromConfig.Center), vectorFromArray(toConfig.Center))
	end

	logStudioWorldBaseline(world)
end

function WorldService:Start() end

return WorldService
