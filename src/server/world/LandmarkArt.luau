--!strict

local LandmarkArt = {}

local function part(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function textSign(host: BasePart, text: string, textColor: Color3)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 34
	gui.Parent = host
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = textColor
	label.Text = text
	label.Parent = gui
end

local function residential(parent: Instance, center: Vector3, config)
	local x = center.X + config.GroundSize[1] * 0.37
	local z = center.Z + config.GroundSize[2] * 0.33

	for _, side in { -1, 1 } do
		part(parent, "WaterTowerLeg", Vector3.new(0.8, 16, 0.8), CFrame.new(x + side * 3, 8, z), Color3.fromRGB(80, 84, 88), Enum.Material.Metal)
		part(parent, "WaterTowerBrace", Vector3.new(7, 0.45, 0.45), CFrame.new(x, 6 + side * 3, z), Color3.fromRGB(92, 96, 100), Enum.Material.Metal)
	end

	local tank = part(parent, "WaterTowerTank", Vector3.new(7.2, 9.4, 9.4), CFrame.new(x, 17, z), Color3.fromRGB(145, 154, 160), Enum.Material.Metal)
	tank.Shape = Enum.PartType.Cylinder
	tank.Orientation = Vector3.new(0, 0, 90)

	local band = part(parent, "WaterTowerBand", Vector3.new(7.35, 9.65, 1.0), CFrame.new(x, 17, z), Color3.fromRGB(68, 145, 214), Enum.Material.Metal)
	band.Shape = Enum.PartType.Cylinder
	band.Orientation = Vector3.new(0, 0, 90)

	local sign = part(parent, "WaterTowerSign", Vector3.new(5.8, 2.0, 0.2), CFrame.new(x, 17, z - 4.8), Color3.fromRGB(25, 39, 50), Enum.Material.Metal)
	textSign(sign, "RESIDENTIAL", Color3.fromRGB(241, 244, 246))
end

local function downtown(parent: Instance, center: Vector3, config)
	local x = center.X
	local z = center.Z + config.GroundSize[2] * 0.36
	local base = part(parent, "CityPlazaBase", Vector3.new(32, 0.6, 24), CFrame.new(x, 0.3, z), Color3.fromRGB(155, 156, 154), Enum.Material.Concrete)
	base.CanCollide = false

	for _, side in { -1, 1 } do
		part(parent, "PlazaBench", Vector3.new(7.5, 0.45, 1.6), CFrame.new(x + side * 9, 1.4, z + 5), Color3.fromRGB(114, 83, 58), Enum.Material.Wood)
	end

	part(parent, "ClockTower", Vector3.new(6.5, 18, 6.5), CFrame.new(x, 9, z), Color3.fromRGB(80, 86, 92), Enum.Material.Concrete)
	local crown = part(parent, "ClockCrown", Vector3.new(8.3, 3.0, 8.3), CFrame.new(x, 19.5, z), Color3.fromRGB(43, 50, 57), Enum.Material.Metal)
	for _, face in { -1, 1 } do
		local clock = part(
			parent,
			"ClockFace",
			Vector3.new(4.4, 4.4, 0.18),
			CFrame.new(x, 16.2, z + face * 3.35),
			Color3.fromRGB(235, 231, 211),
			Enum.Material.SmoothPlastic
		)
		clock.Shape = Enum.PartType.Cylinder
		clock.Orientation = Vector3.new(90, 0, 0)
	end
	local light =
		part(parent, "ClockBeacon", Vector3.new(1.2, 1.2, 1.2), crown.CFrame * CFrame.new(0, 2.2, 0), Color3.fromRGB(245, 151, 49), Enum.Material.Neon)
	light.Shape = Enum.PartType.Ball
end

local function industrial(parent: Instance, center: Vector3, config)
	local x = center.X + config.GroundSize[1] * 0.16
	local z = center.Z + config.GroundSize[2] * 0.26

	local plantPad = part(parent, "ProcessPlantPad", Vector3.new(96, 0.45, 68), CFrame.new(x, 0.23, z), Color3.fromRGB(102, 104, 106), Enum.Material.Concrete)
	plantPad.CanCollide = false

	for tankIndex = -1, 1 do
		local tankX = x + tankIndex * 22
		local tank = part(parent, "TankFarmTank", Vector3.new(11, 16, 16), CFrame.new(tankX, 8.0, z + 12), Color3.fromRGB(142, 148, 151), Enum.Material.Metal)
		tank.Shape = Enum.PartType.Cylinder
		tank.Orientation = Vector3.new(0, 0, 90)
		for bandIndex = -1, 1 do
			local band = part(
				parent,
				"TankBand",
				Vector3.new(11.15, 16.25, 0.65),
				CFrame.new(tankX + bandIndex * 2.8, 8.0, z + 12),
				Color3.fromRGB(77, 82, 86),
				Enum.Material.Metal
			)
			band.Shape = Enum.PartType.Cylinder
			band.Orientation = Vector3.new(0, 0, 90)
		end
		local ladder = part(parent, "TankLadder", Vector3.new(0.5, 12, 0.55), CFrame.new(tankX, 7.5, z + 20.2), Color3.fromRGB(71, 74, 77), Enum.Material.Metal)
		ladder.CanCollide = false
	end

	for _, side in { -1, 1 } do
		part(parent, "PipeRackPost", Vector3.new(1.0, 11, 1.0), CFrame.new(x + side * 38, 5.5, z - 17), Color3.fromRGB(70, 74, 78), Enum.Material.Metal)
	end
	for post = -3, 3 do
		part(parent, "PipeRackMidPost", Vector3.new(0.65, 9.5, 0.65), CFrame.new(x + post * 12, 4.75, z - 17), Color3.fromRGB(78, 82, 86), Enum.Material.Metal)
	end
	part(parent, "PipeRackBeam", Vector3.new(80, 0.9, 0.9), CFrame.new(x, 9.4, z - 17), Color3.fromRGB(70, 74, 78), Enum.Material.Metal)
	for lane = -2, 2 do
		local pipe = part(
			parent,
			"OverheadPipe",
			Vector3.new(78, 0.8, 0.8),
			CFrame.new(x, 7.2 + lane * 0.8, z - 17),
			if lane % 2 == 0 then Color3.fromRGB(230, 112, 55) else Color3.fromRGB(68, 145, 214),
			Enum.Material.Metal
		)
		pipe.Shape = Enum.PartType.Cylinder
		pipe.Orientation = Vector3.new(0, 0, 90)
	end

	for towerIndex = -1, 1, 2 do
		local tower =
			part(parent, "ProcessTower", Vector3.new(7, 28, 7), CFrame.new(x + towerIndex * 31, 14, z - 3), Color3.fromRGB(119, 124, 128), Enum.Material.Metal)
		tower.Shape = Enum.PartType.Cylinder
		for ring = 1, 4 do
			local platform = part(
				parent,
				"TowerPlatform",
				Vector3.new(9.5, 0.45, 9.5),
				CFrame.new(x + towerIndex * 31, ring * 5.5, z - 3),
				Color3.fromRGB(70, 74, 78),
				Enum.Material.Metal
			)
			platform.Shape = Enum.PartType.Cylinder
		end
		local beacon =
			part(parent, "TowerBeacon", Vector3.new(0.9, 0.9, 0.9), tower.CFrame * CFrame.new(0, 14.7, 0), Color3.fromRGB(225, 70, 61), Enum.Material.Neon)
		beacon.Shape = Enum.PartType.Ball
	end

	local sign =
		part(parent, "IndustrialLandmarkSign", Vector3.new(22, 3.4, 0.35), CFrame.new(x, 12.5, z - 21), Color3.fromRGB(28, 35, 41), Enum.Material.Metal)
	textSign(sign, "INDUSTRIAL SERVICES", Color3.fromRGB(245, 151, 49))
end

function LandmarkArt.Add(parent: Instance, districtId: string, center: Vector3, config)
	local model = Instance.new("Model")
	model.Name = "Landmark"
	model:SetAttribute("DistrictId", districtId)
	model.Parent = parent

	if districtId == "residential" then
		residential(model, center, config)
	elseif districtId == "downtown" then
		downtown(model, center, config)
	elseif districtId == "industrial" then
		industrial(model, center, config)
	end
end

return LandmarkArt
