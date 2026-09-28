--!strict

local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WorldConfig = require(ReplicatedStorage.RepairEmpire.Shared.world.WorldConfig)

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

local function addDistrictSign(parent: Instance, center: Vector3, displayName: string)
	local sign = createPart("DistrictSign", Vector3.new(18, 6, 1), CFrame.new(center + Vector3.new(0, 5, -8)), parent)
	sign.Material = Enum.Material.Metal

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
	label.Text = displayName
	label.Parent = surface
end

local function addStreetFurniture(parent: Instance, center: Vector3, spacing: number)
	for index = -2, 2 do
		local x = center.X + index * spacing
		for _, zOffset in { -14, 14 } do
			local pole = createPart("StreetLightPole", Vector3.new(0.6, 9, 0.6), CFrame.new(x, 4.5, center.Z + zOffset), parent)
			pole.Material = Enum.Material.Metal
			local lamp = createPart("StreetLight", Vector3.new(2.4, 0.5, 1.2), CFrame.new(x, 9, center.Z + zOffset), parent)
			lamp.Material = Enum.Material.Neon
		end
	end
end

local function addResidentialWorkshop(parent: Instance, center: Vector3, groundSize)
	local model = Instance.new("Model")
	model.Name = "PlayerWorkshop"
	model:SetAttribute("IsWorkshop", true)
	model.Parent = parent

	local x = center.X - groundSize[1] / 2 + 38
	local z = center.Z + groundSize[2] / 2 - 34

	local pad = createPart("WorkshopPad", Vector3.new(52, 0.5, 44), CFrame.new(x, 0.25, z), model)
	pad.Material = Enum.Material.Concrete

	local building = createPart("WorkshopBuilding", Vector3.new(34, 12, 28), CFrame.new(x - 6, 6, z), model)
	building.Material = Enum.Material.Brick

	local door = createPart("GarageDoor", Vector3.new(12, 7, 0.6), CFrame.new(x - 6, 3.5, z - 14.3), model)
	door.Material = Enum.Material.Metal

	local signAnchor = Vector3.new(x - 6, 11, z - 14.7)
	addDistrictSign(model, signAnchor, "REPAIR EMPIRE")

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "MainSpawn"
	spawn.Size = Vector3.new(10, 1, 10)
	spawn.CFrame = CFrame.new(x + 20, 0.5, z)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.AllowTeamChangeOnTouch = false
	spawn.Transparency = 0.35
	spawn.Parent = model
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
	base.Material = Enum.Material.Concrete

	local mainRoad = createPart("MainRoad", Vector3.new(groundX, 0.4, WorldConfig.RoadWidth), CFrame.new(center + Vector3.new(0, 0.2, 0)), folder)
	mainRoad.Material = Enum.Material.Asphalt

	addDistrictSign(folder, center + Vector3.new(-groundX / 2 + 18, 0, 0), config.DisplayName)
	addStreetFurniture(folder, center, config.Spacing)

	if districtId == "residential" then
		addResidentialWorkshop(folder, center, config.GroundSize)
	end

	for index = 1, config.BuildingCount do
		local col = (index - 1) % 5
		local row = math.floor((index - 1) / 5)
		local x = center.X + (col - 2) * config.Spacing
		local z = center.Z + (row * 2 - 1) * config.Spacing
		local height = config.HeightBase + ((index * 7) % config.HeightVariance)

		local building = Instance.new("Model")
		building.Name = ("Building_%02d"):format(index)
		building:SetAttribute("DistrictId", districtId)
		building.Parent = folder

		local shell = createPart("Shell", Vector3.new(config.BuildingSize[1], height, config.BuildingSize[2]), CFrame.new(x, height / 2, z), building)
		if districtId == "industrial" then
			shell.Material = Enum.Material.Metal
		elseif districtId == "downtown" then
			shell.Material = Enum.Material.Concrete
		else
			shell.Material = Enum.Material.Brick
		end

		if districtId == "downtown" and index % 2 == 0 then
			local crown =
				createPart("TowerCrown", Vector3.new(config.BuildingSize[1] * 0.7, 5, config.BuildingSize[2] * 0.7), CFrame.new(x, height + 2.5, z), building)
			crown.Material = Enum.Material.Glass
		elseif districtId == "industrial" and index % 2 == 1 then
			local tank = createPart("ServiceTank", Vector3.new(8, 12, 8), CFrame.new(x + 15, 6, z), building)
			tank.Shape = Enum.PartType.Cylinder
			tank.CFrame *= CFrame.Angles(0, 0, math.rad(90))
			tank.Material = Enum.Material.Metal
		end

		for categoryIndex, categoryId in CATEGORIES do
			local offsetAngle = (categoryIndex - 1) * (math.pi / 2)
			local offset = Vector3.new(math.cos(offsetAngle) * config.AnchorRadius, 2, math.sin(offsetAngle) * config.AnchorRadius)
			local anchor = createPart("JobAnchor", Vector3.new(4, 4, 4), CFrame.new(Vector3.new(x, 2, z) + offset), building)
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
	return (root.Position - anchor.Position).Magnitude <= WorldConfig.AnchorInteractionDistance
end

function WorldService:Init()
	local existing = Workspace:FindFirstChild("RepairEmpireWorld")
	if existing then
		existing:Destroy()
	end

	self._anchorsById = {}
	self._anchorsByDistrictCategory = {}

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
end

function WorldService:Start() end

return WorldService
