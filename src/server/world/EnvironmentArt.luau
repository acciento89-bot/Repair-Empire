--!strict

local EnvironmentArt = {}

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

local function addHydrant(parent: Instance, position: Vector3)
	local body =
		part(parent, "HydrantBody", Vector3.new(1.0, 2.2, 1.0), CFrame.new(position + Vector3.new(0, 1.1, 0)), Color3.fromRGB(204, 67, 53), Enum.Material.Metal)
	body.Shape = Enum.PartType.Cylinder
	local cap = part(
		parent,
		"HydrantCap",
		Vector3.new(0.45, 1.3, 1.3),
		CFrame.new(position + Vector3.new(0, 2.35, 0)),
		Color3.fromRGB(228, 83, 58),
		Enum.Material.Metal
	)
	cap.Shape = Enum.PartType.Cylinder
	for _, side in { -1, 1 } do
		local outlet = part(
			parent,
			"HydrantOutlet",
			Vector3.new(0.5, 0.65, 0.65),
			CFrame.new(position + Vector3.new(side * 0.72, 1.45, 0)),
			Color3.fromRGB(188, 191, 190),
			Enum.Material.Metal
		)
		outlet.Shape = Enum.PartType.Cylinder
		outlet.Orientation = Vector3.new(0, 0, 90)
	end
end

local function addBench(parent: Instance, position: Vector3)
	part(parent, "BenchSeat", Vector3.new(5.2, 0.35, 1.5), CFrame.new(position + Vector3.new(0, 1.55, 0)), Color3.fromRGB(123, 87, 57), Enum.Material.Wood)
	part(parent, "BenchBack", Vector3.new(5.2, 2.0, 0.35), CFrame.new(position + Vector3.new(0, 2.45, 0.65)), Color3.fromRGB(123, 87, 57), Enum.Material.Wood)
	for _, side in { -1, 1 } do
		part(
			parent,
			"BenchLeg",
			Vector3.new(0.35, 1.5, 0.8),
			CFrame.new(position + Vector3.new(side * 1.9, 0.75, 0)),
			Color3.fromRGB(62, 65, 68),
			Enum.Material.Metal
		)
	end
end

local function addPlanter(parent: Instance, position: Vector3)
	part(parent, "Planter", Vector3.new(3.2, 1.35, 3.2), CFrame.new(position + Vector3.new(0, 0.68, 0)), Color3.fromRGB(110, 105, 98), Enum.Material.Concrete)
	local shrub = part(
		parent,
		"PlanterShrub",
		Vector3.new(3.3, 2.4, 3.3),
		CFrame.new(position + Vector3.new(0, 2.15, 0)),
		Color3.fromRGB(68, 118, 67),
		Enum.Material.Grass
	)
	shrub.Shape = Enum.PartType.Ball
end

local function addParkingMeter(parent: Instance, position: Vector3)
	part(
		parent,
		"ParkingMeterPost",
		Vector3.new(0.32, 3.4, 0.32),
		CFrame.new(position + Vector3.new(0, 1.7, 0)),
		Color3.fromRGB(75, 80, 85),
		Enum.Material.Metal
	)
	local head = part(
		parent,
		"ParkingMeter",
		Vector3.new(1.0, 1.5, 0.7),
		CFrame.new(position + Vector3.new(0, 3.55, 0)),
		Color3.fromRGB(52, 60, 66),
		Enum.Material.Metal
	)
	local screen = part(
		parent,
		"ParkingMeterScreen",
		Vector3.new(0.65, 0.6, 0.08),
		head.CFrame * CFrame.new(0, 0.18, -0.39),
		Color3.fromRGB(91, 164, 185),
		Enum.Material.Glass
	)
	screen.Transparency = 0.12
end

local function addDumpster(parent: Instance, position: Vector3)
	part(parent, "Dumpster", Vector3.new(6.0, 3.4, 3.4), CFrame.new(position + Vector3.new(0, 1.7, 0)), Color3.fromRGB(59, 91, 70), Enum.Material.Metal)
	for _, side in { -1, 1 } do
		part(
			parent,
			"DumpsterLid",
			Vector3.new(2.8, 0.24, 3.5),
			CFrame.new(position + Vector3.new(side * 1.5, 3.5, 0)),
			Color3.fromRGB(42, 58, 48),
			Enum.Material.Metal
		)
	end
	for _, x in { -2.2, 2.2 } do
		local wheel = part(
			parent,
			"DumpsterWheel",
			Vector3.new(0.5, 0.8, 0.8),
			CFrame.new(position + Vector3.new(x, 0.3, 1.25)),
			Color3.fromRGB(28, 30, 32),
			Enum.Material.SmoothPlastic
		)
		wheel.Shape = Enum.PartType.Cylinder
		wheel.Orientation = Vector3.new(0, 90, 0)
	end
end

local function addPalletStack(parent: Instance, position: Vector3)
	for level = 0, 2 do
		for plank = -2, 2 do
			part(
				parent,
				"PalletPlank",
				Vector3.new(5.2, 0.25, 0.65),
				CFrame.new(position + Vector3.new(0, level * 0.65 + 0.2, plank * 0.72)),
				Color3.fromRGB(145, 106, 67),
				Enum.Material.WoodPlanks
			)
		end
	end
end

local function addServiceCone(parent: Instance, position: Vector3)
	local cone = part(
		parent,
		"ServiceCone",
		Vector3.new(0.9, 2.1, 0.9),
		CFrame.new(position + Vector3.new(0, 1.05, 0)),
		Color3.fromRGB(242, 126, 44),
		Enum.Material.SmoothPlastic
	)
	cone.Shape = Enum.PartType.Cylinder
	part(
		parent,
		"ConeStripe",
		Vector3.new(0.96, 0.35, 0.96),
		CFrame.new(position + Vector3.new(0, 1.25, 0)),
		Color3.fromRGB(236, 236, 226),
		Enum.Material.SmoothPlastic
	).Shape =
		Enum.PartType.Cylinder
	part(parent, "ConeBase", Vector3.new(1.7, 0.18, 1.7), CFrame.new(position + Vector3.new(0, 0.09, 0)), Color3.fromRGB(42, 45, 48), Enum.Material.Rubber)
end

local function addMailBox(parent: Instance, position: Vector3)
	part(parent, "MailboxPost", Vector3.new(0.35, 2.7, 0.35), CFrame.new(position + Vector3.new(0, 1.35, 0)), Color3.fromRGB(78, 80, 82), Enum.Material.Metal)
	local box =
		part(parent, "Mailbox", Vector3.new(1.4, 1.0, 2.0), CFrame.new(position + Vector3.new(0, 2.75, 0)), Color3.fromRGB(50, 83, 111), Enum.Material.Metal)
	local flag =
		part(parent, "MailboxFlag", Vector3.new(0.15, 1.25, 0.15), box.CFrame * CFrame.new(0.82, 0.45, 0), Color3.fromRGB(205, 70, 56), Enum.Material.Metal)
	flag:SetAttribute("EnvironmentDetail", true)
end

function EnvironmentArt.DecorateDistrict(parent: Instance, districtId: string, center: Vector3, config, roadWidth: number)
	assert(type(roadWidth) == "number" and roadWidth > 0, "roadWidth must be positive")
	local roadEdge = roadWidth / 2 + 7
	if districtId == "residential" then
		for index = -2, 2 do
			local x = center.X + index * config.Spacing
			addMailBox(parent, Vector3.new(x + 7, 0, center.Z - roadEdge))
			if index % 2 == 0 then
				addHydrant(parent, Vector3.new(x - 7, 0, center.Z + roadEdge))
			end
		end
		addBench(parent, Vector3.new(center.X + config.Spacing * 0.5, 0, center.Z + roadEdge + 4))
		for i = 0, 2 do
			addServiceCone(parent, Vector3.new(center.X - 18 + i * 4, 0, center.Z - roadEdge - 3))
		end
	elseif districtId == "downtown" then
		for index = -3, 3 do
			local x = center.X + index * (config.GroundSize[1] / 8)
			addParkingMeter(parent, Vector3.new(x, 0, center.Z - roadEdge))
			if index % 2 == 0 then
				addPlanter(parent, Vector3.new(x, 0, center.Z + roadEdge + 4))
			end
		end
		addBench(parent, Vector3.new(center.X - 30, 0, center.Z + roadEdge + 4))
		addBench(parent, Vector3.new(center.X + 30, 0, center.Z + roadEdge + 4))
	else
		addDumpster(parent, Vector3.new(center.X - config.GroundSize[1] * 0.28, 0, center.Z + config.GroundSize[2] * 0.32))
		addDumpster(parent, Vector3.new(center.X + config.GroundSize[1] * 0.25, 0, center.Z - config.GroundSize[2] * 0.32))
		for i = -2, 2 do
			addPalletStack(parent, Vector3.new(center.X + i * 18, 0, center.Z + config.GroundSize[2] * 0.35))
		end
		for i = 0, 3 do
			addServiceCone(parent, Vector3.new(center.X - 16 + i * 5, 0, center.Z - roadEdge - 4))
		end
	end
end

return EnvironmentArt
