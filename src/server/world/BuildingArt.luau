--!strict

local BuildingArt = {}

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

local function surfaceText(host: BasePart, text: string, textColor: Color3)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 36
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

local function residential(building: Model, x: number, z: number, width: number, depth: number, height: number, index: number, frontSign: number)
	local facadeZ = z + frontSign * (depth / 2 + 0.3)

	local foundation = part(
		building,
		"FoundationTrim",
		Vector3.new(width + 0.5, 0.8, depth + 0.5),
		CFrame.new(x, 0.4, z),
		Color3.fromRGB(104, 101, 95),
		Enum.Material.Concrete
	)
	foundation.CanCollide = false

	local doorFrame =
		part(building, "DoorFrame", Vector3.new(5.4, 6.8, 0.25), CFrame.new(x, 3.4, facadeZ + frontSign * 0.1), Color3.fromRGB(72, 78, 82), Enum.Material.Wood)
	doorFrame.CanCollide = false

	local number = part(
		building,
		"HouseNumber",
		Vector3.new(1.5, 0.9, 0.12),
		CFrame.new(x + width * 0.22, 5.1, facadeZ + frontSign * 0.28),
		Color3.fromRGB(36, 42, 47),
		Enum.Material.Metal
	)
	surfaceText(number, tostring(10 + index * 2), Color3.fromRGB(242, 239, 225))

	for _, side in { -1, 1 } do
		local hedge = part(
			building,
			"FrontHedge",
			Vector3.new(width * 0.23, 2.0, 2.2),
			CFrame.new(x + side * width * 0.32, 1.0, z + frontSign * (depth / 2 + 3.4)),
			if index % 2 == 0 then Color3.fromRGB(64, 113, 65) else Color3.fromRGB(77, 124, 70),
			Enum.Material.Grass
		)
		hedge.CanCollide = false
	end

	local gutter = part(
		building,
		"FrontGutter",
		Vector3.new(width * 0.92, 0.28, 0.34),
		CFrame.new(x, height + 1.0, z + frontSign * (depth / 2 + 0.75)),
		Color3.fromRGB(72, 76, 80),
		Enum.Material.Metal
	)
	gutter.CanCollide = false

	local downspout = part(
		building,
		"Downspout",
		Vector3.new(0.35, height * 0.72, 0.35),
		CFrame.new(x + width * 0.42, height * 0.36, z + frontSign * (depth / 2 + 0.7)),
		Color3.fromRGB(78, 82, 86),
		Enum.Material.Metal
	)
	downspout.CanCollide = false

	for _, side in { -1, 1 } do
		for windowIndex = -1, 1 do
			local sideWindow = part(
				building,
				"HouseSideWindow",
				Vector3.new(0.2, 3.1, 3.8),
				CFrame.new(x + side * (width / 2 + 0.16), math.min(height - 3.0, 5.8 + math.abs(windowIndex) * 3.8), z + windowIndex * depth * 0.24),
				Color3.fromRGB(115, 171, 196),
				Enum.Material.Glass
			)
			sideWindow.Transparency = 0.22
		end
	end

	for _, side in { -1, 1 } do
		part(
			building,
			"HouseSideTrim",
			Vector3.new(0.28, height * 0.82, 0.28),
			CFrame.new(x + side * (width / 2 + 0.22), height * 0.45, z),
			Color3.fromRGB(83, 72, 64),
			Enum.Material.Wood
		)
	end
end

local DOWNTOWN_NAMES = { "MARKET", "CAFE", "OFFICE", "STUDIO", "SERVICE" }

local function downtown(building: Model, x: number, z: number, width: number, depth: number, height: number, index: number, frontSign: number)
	local facadeZ = z + frontSign * (depth / 2 + 0.35)
	local sign = part(
		building,
		"StoreSign",
		Vector3.new(width * 0.58, 1.7, 0.22),
		CFrame.new(x, 7.5, facadeZ + frontSign * 0.12),
		if index % 2 == 0 then Color3.fromRGB(34, 67, 88) else Color3.fromRGB(106, 64, 42),
		Enum.Material.Metal
	)
	surfaceText(sign, DOWNTOWN_NAMES[((index - 1) % #DOWNTOWN_NAMES) + 1], Color3.fromRGB(245, 151, 49))

	for mullion = -2, 2 do
		part(
			building,
			"StorefrontMullion",
			Vector3.new(0.18, 5.0, 0.18),
			CFrame.new(x + mullion * width * 0.075, 3.0, facadeZ + frontSign * 0.2),
			Color3.fromRGB(56, 61, 65),
			Enum.Material.Metal
		)
	end

	local hvac = part(
		building,
		"RoofHVAC",
		Vector3.new(5.5, 2.3, 4.2),
		CFrame.new(x + width * 0.2, height + 1.55, z - depth * 0.15),
		Color3.fromRGB(115, 120, 124),
		Enum.Material.Metal
	)
	local grille =
		part(building, "RoofHVACGrille", Vector3.new(3.6, 0.18, 2.8), hvac.CFrame * CFrame.new(0, 1.22, 0), Color3.fromRGB(65, 70, 74), Enum.Material.Metal)
	grille.CanCollide = false

	local floorCount = math.max(2, math.min(6, math.floor(height / 8)))
	for _, side in { -1, 1 } do
		for floorIndex = 1, floorCount do
			local sideBand = part(
				building,
				"DowntownSideWindowBand",
				Vector3.new(0.2, 2.45, depth * 0.68),
				CFrame.new(x + side * (width / 2 + 0.16), math.min(height - 2.4, floorIndex * 7), z),
				Color3.fromRGB(90, 149, 180),
				Enum.Material.Glass
			)
			sideBand.Transparency = 0.26
		end

		part(
			building,
			"DowntownSidePier",
			Vector3.new(0.32, height * 0.88, 0.46),
			CFrame.new(x + side * (width / 2 + 0.2), height * 0.47, z - depth * 0.4),
			Color3.fromRGB(58, 66, 74),
			Enum.Material.Metal
		)
		part(
			building,
			"DowntownSidePier",
			Vector3.new(0.32, height * 0.88, 0.46),
			CFrame.new(x + side * (width / 2 + 0.2), height * 0.47, z + depth * 0.4),
			Color3.fromRGB(58, 66, 74),
			Enum.Material.Metal
		)
	end

	part(
		building,
		"DowntownRoofCornice",
		Vector3.new(width + 1.1, 0.65, depth + 1.1),
		CFrame.new(x, height + 0.72, z),
		Color3.fromRGB(54, 62, 69),
		Enum.Material.Metal
	)
end

local function industrial(building: Model, x: number, z: number, width: number, depth: number, height: number, index: number, frontSign: number)
	local facadeZ = z + frontSign * (depth / 2 + 0.34)
	local serviceBox = part(
		building,
		"WallServiceBox",
		Vector3.new(3.2, 4.0, 0.8),
		CFrame.new(x + width * 0.32, 3.0, facadeZ + frontSign * 0.32),
		Color3.fromRGB(71, 78, 82),
		Enum.Material.Metal
	)
	local status = part(
		building,
		"ServiceStatus",
		Vector3.new(0.55, 0.55, 0.12),
		serviceBox.CFrame * CFrame.new(0.8, 0.9, -0.46 * frontSign),
		if index % 2 == 0 then Color3.fromRGB(85, 188, 112) else Color3.fromRGB(236, 171, 57),
		Enum.Material.Neon
	)
	status.CanCollide = false

	local hazard = part(
		building,
		"HazardStripe",
		Vector3.new(width * 0.5, 0.55, 0.18),
		CFrame.new(x, 0.75, facadeZ + frontSign * 0.35),
		Color3.fromRGB(238, 181, 55),
		Enum.Material.Neon
	)
	hazard.Transparency = 0.08

	local stack = part(
		building,
		"ExhaustStack",
		Vector3.new(1.4, 7.0, 1.4),
		CFrame.new(x - width * 0.28, height + 3.5, z),
		Color3.fromRGB(86, 91, 95),
		Enum.Material.Metal
	)
	stack.Shape = Enum.PartType.Cylinder

	local cap = part(
		building,
		"ExhaustCap",
		Vector3.new(2.2, 0.5, 2.2),
		CFrame.new(x - width * 0.28, height + 7.15, z),
		Color3.fromRGB(63, 67, 70),
		Enum.Material.Metal
	)
	cap.Shape = Enum.PartType.Cylinder

	for rib = -3, 3 do
		local wallRib = part(
			building,
			"IndustrialWallRib",
			Vector3.new(0.28, height * 0.78, 0.22),
			CFrame.new(x + rib * width * 0.1, height * 0.48, facadeZ + frontSign * 0.22),
			Color3.fromRGB(83, 88, 93),
			Enum.Material.Metal
		)
		wallRib.CanCollide = false
	end

	for windowIndex = -1, 1 do
		local highWindow = part(
			building,
			"IndustrialHighWindow",
			Vector3.new(width * 0.18, 2.0, 0.2),
			CFrame.new(x + windowIndex * width * 0.25, math.min(height - 3, 9), facadeZ + frontSign * 0.24),
			Color3.fromRGB(89, 145, 166),
			Enum.Material.Glass
		)
		highWindow.Transparency = 0.24
		highWindow.CanCollide = false
	end

	local canopy = part(
		building,
		"LoadingCanopy",
		Vector3.new(width * 0.52, 0.45, 5.0),
		CFrame.new(x, 8.1, z + frontSign * (depth / 2 + 2.2)),
		Color3.fromRGB(54, 59, 64),
		Enum.Material.Metal
	)
	canopy.CanCollide = false

	for _, side in { -1, 1 } do
		local flood = part(
			building,
			"IndustrialFloodLight",
			Vector3.new(1.4, 0.35, 0.8),
			CFrame.new(x + side * width * 0.32, 9.5, facadeZ + frontSign * 0.45),
			Color3.fromRGB(255, 234, 182),
			Enum.Material.Neon
		)
		flood.CanCollide = false
	end

	local plinth = part(
		building,
		"IndustrialPlinth",
		Vector3.new(width + 0.8, 1.1, depth + 0.8),
		CFrame.new(x, 0.55, z),
		Color3.fromRGB(66, 70, 73),
		Enum.Material.Concrete
	)
	plinth.CanCollide = false

	part(
		building,
		"IndustrialRoofParapet",
		Vector3.new(width + 1.0, 1.0, depth + 1.0),
		CFrame.new(x, height + 0.8, z),
		Color3.fromRGB(60, 65, 69),
		Enum.Material.Metal
	)

	for _, side in { -1, 1 } do
		local sideX = x + side * (width / 2 + 0.16)
		for windowIndex = -1, 1 do
			local sideWindow = part(
				building,
				"IndustrialSideWindow",
				Vector3.new(0.2, 2.25, depth * 0.18),
				CFrame.new(sideX, math.min(height - 3, 8.2), z + windowIndex * depth * 0.26),
				Color3.fromRGB(83, 139, 158),
				Enum.Material.Glass
			)
			sideWindow.Transparency = 0.22
		end

		for bandIndex = -1, 1 do
			part(
				building,
				"IndustrialSideCladding",
				Vector3.new(0.24, 0.38, depth * 0.78),
				CFrame.new(sideX + side * 0.03, 4.2 + bandIndex * 4.1, z),
				if bandIndex == 0 then Color3.fromRGB(219, 153, 54) else Color3.fromRGB(72, 78, 83),
				Enum.Material.Metal
			)
		end
	end

	local sideSign = part(
		building,
		"IndustrialSideSign",
		Vector3.new(0.28, 3.0, math.min(15, depth * 0.45)),
		CFrame.new(x + width / 2 + 0.32, math.min(height - 4, 12), z) * CFrame.Angles(0, math.rad(90), 0),
		Color3.fromRGB(28, 35, 41),
		Enum.Material.Metal
	)
	surfaceText(sideSign, "SERVICE BAY " .. tostring(index), Color3.fromRGB(245, 151, 49))
end

function BuildingArt.Decorate(
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
	if districtId == "residential" then
		residential(building, x, z, width, depth, height, index, frontSign)
	elseif districtId == "downtown" then
		downtown(building, x, z, width, depth, height, index, frontSign)
	elseif districtId == "industrial" then
		industrial(building, x, z, width, depth, height, index, frontSign)
	end
end

return BuildingArt
