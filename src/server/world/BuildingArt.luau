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
