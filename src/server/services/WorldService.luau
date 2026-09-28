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

	local center = config.Center
	local base = createPart(
		"DistrictBase",
		Vector3.new(config.Spacing * 6, 1, config.Spacing * 4),
		CFrame.new(center + Vector3.new(0, -0.5, 0)),
		folder
	)
	base.Material = Enum.Material.Concrete

	for index = 1, config.BuildingCount do
		local col = (index - 1) % 5
		local row = math.floor((index - 1) / 5)
		local x = center.X + (col - 2) * config.Spacing
		local z = center.Z + (row * 2 - 1) * config.Spacing
		local height = 20 + ((index * 7) % 28)

		local building = Instance.new("Model")
		building.Name = ("Building_%02d"):format(index)
		building.Parent = folder

		local shell = createPart(
			"Shell",
			Vector3.new(28, height, 28),
			CFrame.new(x, height / 2, z),
			building
		)
		shell.Material = if districtId == "industrial" then Enum.Material.Metal else Enum.Material.Brick

		for categoryIndex, categoryId in CATEGORIES do
			local offsetAngle = (categoryIndex - 1) * (math.pi / 2)
			local offset = Vector3.new(math.cos(offsetAngle) * 18, 2, math.sin(offsetAngle) * 18)
			local anchor = createPart(
				"JobAnchor",
				Vector3.new(4, 4, 4),
				CFrame.new(Vector3.new(x, 2, z) + offset),
				building
			)
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

	local world = Instance.new("Folder")
	world.Name = "RepairEmpireWorld"
	world.Parent = Workspace

	for districtId, config in WorldConfig.Districts do
		self:_BuildDistrict(world, districtId, config)
	end
end

function WorldService:Start() end

return WorldService
