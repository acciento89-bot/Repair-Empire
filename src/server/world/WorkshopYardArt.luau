--!strict

local WorkshopYardArt = {}

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

local function serviceVan(parent: Instance, cf: CFrame)
	local navy = Color3.fromRGB(38, 52, 64)
	local orange = Color3.fromRGB(245, 151, 49)
	local chassis = part(parent, "YardVanChassis", Vector3.new(7.2, 1.0, 13.5), cf * CFrame.new(0, 1.0, 0), Color3.fromRGB(48, 52, 56), Enum.Material.Metal)
	local body = part(parent, "YardVanBody", Vector3.new(6.8, 5.2, 8.0), cf * CFrame.new(0, 3.4, 2.0), navy, Enum.Material.Metal)
	local cab = part(parent, "YardVanCab", Vector3.new(6.6, 4.4, 4.4), cf * CFrame.new(0, 3.0, -4.0), navy, Enum.Material.Metal)
	local screen = part(
		parent,
		"YardVanWindscreen",
		Vector3.new(5.3, 2.0, 0.18),
		cab.CFrame * CFrame.new(0, 0.7, -2.28),
		Color3.fromRGB(76, 132, 156),
		Enum.Material.Glass
	)
	screen.Transparency = 0.18
	part(parent, "YardVanStripe", Vector3.new(6.85, 0.55, 7.2), body.CFrame * CFrame.new(0, -1.0, 0.1), orange, Enum.Material.SmoothPlastic)

	for _, x in { -3.25, 3.25 } do
		for _, z in { -4.6, 4.2 } do
			local wheel =
				part(parent, "YardVanWheel", Vector3.new(0.8, 1.8, 1.8), cf * CFrame.new(x, 0.75, z), Color3.fromRGB(25, 27, 30), Enum.Material.SmoothPlastic)
			wheel.Shape = Enum.PartType.Cylinder
			wheel.Orientation = Vector3.new(0, 0, 90)
		end
	end

	local labelPanel =
		part(parent, "YardVanBrand", Vector3.new(5.5, 2.1, 0.14), body.CFrame * CFrame.new(0, 0.6, 4.08), Color3.fromRGB(20, 34, 46), Enum.Material.Metal)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Back
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 32
	gui.Parent = labelPanel
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = orange
	label.Text = "REPAIR EMPIRE"
	label.Parent = gui
	chassis:SetAttribute("WorkshopYardArt", true)
end

local function pipeRack(parent: Instance, cf: CFrame)
	local frameColor = Color3.fromRGB(70, 75, 80)
	for _, side in { -1, 1 } do
		part(parent, "PipeRackPost", Vector3.new(0.45, 5.5, 0.45), cf * CFrame.new(side * 4.4, 2.75, 0), frameColor, Enum.Material.Metal)
	end
	for y = 1.2, 4.8, 1.8 do
		part(parent, "PipeRackRail", Vector3.new(9.2, 0.28, 1.0), cf * CFrame.new(0, y, 0), frameColor, Enum.Material.Metal)
	end
	for index = -3, 3 do
		local pipe = part(
			parent,
			"StoredPipe",
			Vector3.new(8.2, 0.45, 0.45),
			cf * CFrame.new(0, 1.35 + (math.abs(index) % 2) * 1.8, index * 0.52),
			if index % 2 == 0 then Color3.fromRGB(174, 120, 70) else Color3.fromRGB(160, 166, 171),
			Enum.Material.Metal
		)
		pipe.Shape = Enum.PartType.Cylinder
		pipe.Orientation = Vector3.new(0, 0, 90)
	end
end

local function pallet(parent: Instance, cf: CFrame, boxColor: Color3)
	for plank = -2, 2 do
		part(parent, "YardPallet", Vector3.new(5.4, 0.25, 0.7), cf * CFrame.new(0, 0.2, plank * 0.75), Color3.fromRGB(142, 103, 65), Enum.Material.WoodPlanks)
	end
	for x = -1, 1 do
		part(parent, "YardBox", Vector3.new(2.0, 2.2, 2.4), cf * CFrame.new(x * 1.3, 1.5, 0), boxColor, Enum.Material.SmoothPlastic)
	end
end

local function outdoorUnit(parent: Instance, cf: CFrame)
	local body = part(parent, "YardOutdoorUnit", Vector3.new(4.6, 3.6, 2.4), cf * CFrame.new(0, 1.8, 0), Color3.fromRGB(190, 198, 201), Enum.Material.Metal)
	local fan =
		part(parent, "YardUnitFan", Vector3.new(0.25, 2.2, 2.2), body.CFrame * CFrame.new(0, 0.1, -1.32), Color3.fromRGB(67, 75, 79), Enum.Material.Metal)
	fan.Shape = Enum.PartType.Cylinder
	fan.Orientation = Vector3.new(0, 90, 0)
end

local function fence(parent: Instance, center: Vector3, length: number, alongX: boolean)
	local postCount = math.max(2, math.floor(length / 7))
	for index = 0, postCount do
		local alpha = index / postCount
		local offset = (alpha - 0.5) * length
		local pos = center + if alongX then Vector3.new(offset, 0, 0) else Vector3.new(0, 0, offset)
		part(parent, "YardFencePost", Vector3.new(0.35, 3.2, 0.35), CFrame.new(pos + Vector3.new(0, 1.6, 0)), Color3.fromRGB(66, 71, 75), Enum.Material.Metal)
	end
	for y = 0.9, 2.5, 1.6 do
		part(
			parent,
			"YardFenceRail",
			if alongX then Vector3.new(length, 0.18, 0.18) else Vector3.new(0.18, 0.18, length),
			CFrame.new(center + Vector3.new(0, y, 0)),
			Color3.fromRGB(82, 87, 90),
			Enum.Material.Metal
		)
	end
end

local function serviceCharger(parent: Instance, cf: CFrame)
	local body = part(parent, "ServiceCharger", Vector3.new(2.2, 4.6, 1.4), cf * CFrame.new(0, 2.3, 0), Color3.fromRGB(37, 48, 57), Enum.Material.Metal)
	local screen =
		part(parent, "ChargerScreen", Vector3.new(1.35, 1.1, 0.12), body.CFrame * CFrame.new(0, 0.7, -0.76), Color3.fromRGB(67, 154, 166), Enum.Material.Glass)
	screen.Transparency = 0.12
	local light =
		part(parent, "ChargerStatus", Vector3.new(1.4, 0.28, 0.12), body.CFrame * CFrame.new(0, -0.45, -0.76), Color3.fromRGB(103, 177, 92), Enum.Material.Neon)
	light.Transparency = 0.05
	part(parent, "ChargerCable", Vector3.new(0.22, 2.9, 0.22), body.CFrame * CFrame.new(1.35, -0.2, 0), Color3.fromRGB(30, 32, 34), Enum.Material.Rubber)
end

local function drumStack(parent: Instance, cf: CFrame)
	local colors = {
		Color3.fromRGB(56, 92, 120),
		Color3.fromRGB(205, 111, 58),
		Color3.fromRGB(78, 112, 72),
	}
	for index = 1, 6 do
		local row = math.floor((index - 1) / 3)
		local col = (index - 1) % 3
		local drum = part(
			parent,
			"ServiceDrum",
			Vector3.new(2.2, 2.8, 2.2),
			cf * CFrame.new((col - 1) * 2.5, 1.4 + row * 2.9, 0),
			colors[((index - 1) % #colors) + 1],
			Enum.Material.Metal
		)
		drum.Shape = Enum.PartType.Cylinder
	end
end

local function wasteZone(parent: Instance, cf: CFrame)
	local bin = part(parent, "WasteContainer", Vector3.new(6.5, 3.6, 3.8), cf * CFrame.new(0, 1.8, 0), Color3.fromRGB(59, 91, 70), Enum.Material.Metal)
	for _, side in { -1, 1 } do
		part(parent, "WasteLid", Vector3.new(3.1, 0.28, 3.9), bin.CFrame * CFrame.new(side * 1.6, 1.95, 0), Color3.fromRGB(42, 58, 48), Enum.Material.Metal)
	end
end

local function flagMast(parent: Instance, cf: CFrame)
	part(parent, "CompanyFlagMast", Vector3.new(0.42, 12, 0.42), cf * CFrame.new(0, 6, 0), Color3.fromRGB(177, 181, 184), Enum.Material.Metal)
	local flag = part(parent, "CompanyFlag", Vector3.new(4.5, 2.3, 0.12), cf * CFrame.new(2.1, 10.1, 0), Color3.fromRGB(20, 34, 46), Enum.Material.Fabric)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.Parent = flag
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.GothamBold
	text.TextScaled = true
	text.TextColor3 = Color3.fromRGB(245, 151, 49)
	text.Text = "RE"
	text.Parent = gui
end

function WorkshopYardArt.Decorate(parent: Instance, x: number, z: number)
	local model = Instance.new("Model")
	model.Name = "WorkshopYardProductionArt"
	model.Parent = parent

	serviceVan(model, CFrame.new(x + 24, 0, z - 3) * CFrame.Angles(0, math.rad(-90), 0))
	pipeRack(model, CFrame.new(x + 33, 0, z + 2))
	pallet(model, CFrame.new(x + 27, 0, z + 23), Color3.fromRGB(56, 92, 120))
	pallet(model, CFrame.new(x + 34, 0, z + 23), Color3.fromRGB(205, 111, 58))
	outdoorUnit(model, CFrame.new(x + 23, 0, z + 23))
	outdoorUnit(model, CFrame.new(x + 18, 0, z + 23))

	for bay = -2, 1 do
		part(
			model,
			"BayNumberMarker",
			Vector3.new(6.6, 0.08, 1.0),
			CFrame.new(x + bay * 10 + 5, 0.58, z - 19),
			if bay % 2 == 0 then Color3.fromRGB(245, 151, 49) else Color3.fromRGB(225, 225, 218),
			Enum.Material.SmoothPlastic
		)
	end

	fence(model, Vector3.new(x, 0, z + 33), 86, true)
	fence(model, Vector3.new(x - 45, 0, z + 7), 52, false)
	fence(model, Vector3.new(x + 45, 0, z + 7), 52, false)
	fence(model, Vector3.new(x - 31, 0, z - 23), 24, true)
	fence(model, Vector3.new(x + 31, 0, z - 23), 24, true)

	for _, side in { -1, 1 } do
		part(model, "GatePost", Vector3.new(0.8, 4.5, 0.8), CFrame.new(x + side * 17, 2.25, z - 23), Color3.fromRGB(245, 151, 49), Enum.Material.Metal)
	end

	serviceCharger(model, CFrame.new(x + 38, 0, z - 12))
	drumStack(model, CFrame.new(x + 36, 0, z + 26))
	wasteZone(model, CFrame.new(x - 36, 0, z + 26))
	flagMast(model, CFrame.new(x - 38, 0, z - 15))

	local gateLine = part(model, "GateEntryLine", Vector3.new(28, 0.08, 0.7), CFrame.new(x, 0.58, z - 22.5), Color3.fromRGB(245, 151, 49), Enum.Material.Neon)
	gateLine.Transparency = 0.08
end

return WorkshopYardArt
