--!strict

local BackdropArt = {}

local function part(parent: Instance, className: string, name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?): BasePart
	local p = Instance.new(className)
	assert(p:IsA("BasePart"), "backdrop class must be a BasePart")
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

local function treeCluster(parent: Instance, position: Vector3, scale: number)
	for offset = -2, 2 do
		local x = position.X + offset * 5.5 * scale
		local z = position.Z + math.abs(offset % 2) * 3.5 * scale
		part(
			parent,
			"Part",
			"BackdropTrunk",
			Vector3.new(1.2 * scale, 8 * scale, 1.2 * scale),
			CFrame.new(x, 4 * scale, z),
			Color3.fromRGB(78, 62, 47),
			Enum.Material.Wood
		)
		local crown = part(
			parent,
			"Part",
			"BackdropCrown",
			Vector3.new(8 * scale, 8 * scale, 8 * scale),
			CFrame.new(x, 10 * scale, z),
			Color3.fromRGB(65, 108, 62),
			Enum.Material.Grass
		)
		crown.Shape = Enum.PartType.Ball
	end
end

local function hill(parent: Instance, position: Vector3, size: Vector3, color: Color3)
	local mass = part(parent, "Part", "BackdropHill", size, CFrame.new(position), color, Enum.Material.Grass)
	mass.Shape = Enum.PartType.Ball
end

local function skylineBlock(parent: Instance, x: number, z: number, width: number, height: number, depth: number, shade: number)
	local building = part(
		parent,
		"Part",
		"DistantBuilding",
		Vector3.new(width, height, depth),
		CFrame.new(x, height / 2, z),
		Color3.fromRGB(shade, shade + 4, shade + 8),
		Enum.Material.Concrete
	)

	for level = 1, math.max(2, math.floor(height / 10)) do
		local band = part(
			parent,
			"Part",
			"DistantWindowBand",
			Vector3.new(width * 0.76, 1.4, 0.14),
			building.CFrame * CFrame.new(0, -height / 2 + level * 8, -depth / 2 - 0.08),
			Color3.fromRGB(82, 135, 157),
			Enum.Material.Glass
		)
		band.Transparency = 0.38
	end
end

local function utilityPylon(parent: Instance, x: number, z: number)
	for _, side in { -1, 1 } do
		part(
			parent,
			"Part",
			"PylonLeg",
			Vector3.new(0.75, 28, 0.75),
			CFrame.new(x + side * 4.5, 14, z) * CFrame.Angles(0, 0, math.rad(-side * 7)),
			Color3.fromRGB(82, 86, 89),
			Enum.Material.Metal
		)
	end
	for level = 0, 2 do
		local y = 18 + level * 5
		part(parent, "Part", "PylonCrossbar", Vector3.new(17 - level * 2, 0.65, 0.65), CFrame.new(x, y, z), Color3.fromRGB(82, 86, 89), Enum.Material.Metal)
	end
end

local function roadSign(parent: Instance, position: Vector3, text: string)
	local post = part(
		parent,
		"Part",
		"WayfindingPost",
		Vector3.new(0.45, 5.8, 0.45),
		CFrame.new(position + Vector3.new(0, 2.9, 0)),
		Color3.fromRGB(72, 76, 80),
		Enum.Material.Metal
	)
	local sign = part(
		parent,
		"Part",
		"WayfindingSign",
		Vector3.new(8.2, 2.4, 0.35),
		post.CFrame * CFrame.new(0, 2.2, 0),
		Color3.fromRGB(25, 47, 61),
		Enum.Material.Metal
	)

	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 34
	gui.Parent = sign
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(245, 151, 49)
	label.Text = text
	label.Parent = gui
end

function BackdropArt.Add(world: Instance, worldConfig)
	local model = Instance.new("Model")
	model.Name = "WorldBackdrop"
	model.Parent = world

	local first = worldConfig.Districts[worldConfig.DistrictOrder[1]]
	local last = worldConfig.Districts[worldConfig.DistrictOrder[#worldConfig.DistrictOrder]]
	local minX = first.Center[1] - first.GroundSize[1] / 2
	local maxX = last.Center[1] + last.GroundSize[1] / 2
	local span = maxX - minX
	local midX = (minX + maxX) / 2

	for _, side in { -1, 1 } do
		local z = side * 205
		for index = 0, 8 do
			local x = minX + index * (span / 8)
			hill(
				model,
				Vector3.new(x, -5 + (index % 3) * 2, z + side * ((index % 2) * 12)),
				Vector3.new(110, 38 + (index % 3) * 9, 62),
				if side > 0 then Color3.fromRGB(69, 105, 63) else Color3.fromRGB(75, 112, 68)
			)
			if index % 2 == 0 then
				treeCluster(model, Vector3.new(x + 28, 0, z - side * 18), 0.85)
			end
		end
	end

	local skylineZ = -170
	for index = 0, 8 do
		local x = first.Center[1] + 330 + index * 34
		skylineBlock(model, x, skylineZ, 22 + (index % 3) * 6, 28 + (index % 4) * 10, 18, 72 + (index % 3) * 7)
	end

	local farLayer = Instance.new("Folder")
	farLayer.Name = "FarCityLayer"
	farLayer.Parent = model
	for index = 0, 10 do
		local x = first.Center[1] + 285 + index * 42
		local height = 44 + (index % 5) * 14
		local tower = part(
			farLayer,
			"Part",
			"FarCityTower",
			Vector3.new(18 + (index % 3) * 5, height, 18 + (index % 2) * 4),
			CFrame.new(x, height / 2 - 10, -245 - (index % 2) * 18),
			Color3.fromRGB(63 + index, 73 + index, 86 + index),
			if index % 3 == 0 then Enum.Material.Glass else Enum.Material.Concrete
		)
		if index % 3 == 0 then
			tower.Transparency = 0.18
		end
		local crown = part(
			farLayer,
			"Part",
			"FarCityCrown",
			Vector3.new(math.max(8, tower.Size.X - 4), 0.35, 0.24),
			tower.CFrame * CFrame.new(0, height / 2 + 0.35, -tower.Size.Z / 2 - 0.08),
			if index % 2 == 0 then Color3.fromRGB(245, 151, 49) else Color3.fromRGB(88, 173, 201),
			Enum.Material.Neon
		)
		crown.Transparency = 0.42
	end

	for index = 0, 4 do
		utilityPylon(model, last.Center[1] - 120 + index * 58, 168)
	end

	roadSign(model, Vector3.new(first.Center[1] + 175, 0, -17), "DOWNTOWN →")
	roadSign(model, Vector3.new(last.Center[1] - 190, 0, 17), "← CITY  •  INDUSTRIAL")

	local horizon = part(
		model,
		"Part",
		"BackdropGroundBand",
		Vector3.new(span + 320, 1.0, 50),
		CFrame.new(midX, -0.5, 186),
		Color3.fromRGB(75, 106, 66),
		Enum.Material.Ground
	)
	horizon.Transparency = 0.05
end

return BackdropArt
