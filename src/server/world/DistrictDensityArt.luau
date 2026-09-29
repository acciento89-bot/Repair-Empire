--!strict

local DistrictDensityArt = {}

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

local function tree(parent: Instance, position: Vector3, scale: number)
	local trunk = part(parent, "StreetTreeTrunk", Vector3.new(0.8 * scale, 4.2 * scale, 0.8 * scale), CFrame.new(position + Vector3.new(0, 2.1 * scale, 0)), Color3.fromRGB(104, 77, 52), Enum.Material.Wood)
	local crown = part(parent, "StreetTreeCrown", Vector3.new(4.7 * scale, 4.7 * scale, 4.7 * scale), CFrame.new(position + Vector3.new(0, 5.3 * scale, 0)), Color3.fromRGB(69, 123, 68), Enum.Material.Grass)
	crown.Shape = Enum.PartType.Ball
	trunk.CanCollide = false
end

local function fenceRun(parent: Instance, start: Vector3, length: number, alongX: boolean)
	local count = math.max(2, math.floor(length / 7))
	for index = 0, count do
		local alpha = index / count
		local offset = (alpha - 0.5) * length
		local pos = start + if alongX then Vector3.new(offset, 0, 0) else Vector3.new(0, 0, offset)
		part(parent, "FencePost", Vector3.new(0.35, 3.2, 0.35), CFrame.new(pos + Vector3.new(0, 1.6, 0)), Color3.fromRGB(74, 78, 81), Enum.Material.Metal)
	end
	for railY = 0.9, 2.5, 1.6 do
		part(
			parent,
			"FenceRail",
			if alongX then Vector3.new(length, 0.16, 0.16) else Vector3.new(0.16, 0.16, length),
			CFrame.new(start + Vector3.new(0, railY, 0)),
			Color3.fromRGB(86, 90, 93),
			Enum.Material.Metal
		)
	end
end

local function parkedCar(parent: Instance, position: Vector3, yaw: number, bodyColor: Color3)
	local cf = CFrame.new(position) * CFrame.Angles(0, math.rad(yaw), 0)
	local body = part(parent, "ParkedVehicleBody", Vector3.new(6.8, 1.8, 11), cf * CFrame.new(0, 1.25, 0), bodyColor, Enum.Material.SmoothPlastic)
	part(parent, "ParkedVehicleCabin", Vector3.new(5.8, 2.3, 5.1), cf * CFrame.new(0, 2.7, -0.4), Color3.fromRGB(72, 108, 126), Enum.Material.Glass).Transparency = 0.12
	for _, x in { -2.9, 2.9 } do
		for _, z in { -3.7, 3.7 } do
			local wheel = part(parent, "ParkedVehicleWheel", Vector3.new(0.8, 1.7, 1.7), cf * CFrame.new(x, 0.65, z), Color3.fromRGB(29, 31, 33), Enum.Material.SmoothPlastic)
			wheel.Shape = Enum.PartType.Cylinder
			wheel.Orientation = Vector3.new(0, 0, 90)
		end
	end
	body:SetAttribute("EnvironmentDetail", true)
end

local function container(parent: Instance, position: Vector3, color: Color3)
	local body = part(parent, "FreightContainer", Vector3.new(16, 7.5, 7.5), CFrame.new(position + Vector3.new(0, 3.75, 0)), color, Enum.Material.Metal)
	for stripe = -3, 3 do
		part(parent, "ContainerRib", Vector3.new(0.18, 6.8, 7.65), body.CFrame * CFrame.new(stripe * 2.1, 0, 0), Color3.fromRGB(75, 78, 82), Enum.Material.Metal)
	end
end

local function loadingDock(parent: Instance, position: Vector3)
	local pad = part(parent, "LoadingDockPad", Vector3.new(34, 0.35, 22), CFrame.new(position + Vector3.new(0, 0.18, 0)), Color3.fromRGB(100, 102, 104), Enum.Material.Concrete)
	pad.CanCollide = false
	for bay = -1, 1 do
		local door = part(parent, "LoadingDoor", Vector3.new(8, 7.5, 0.5), CFrame.new(position + Vector3.new(bay * 10, 4, 10.7)), Color3.fromRGB(68, 72, 77), Enum.Material.Metal)
		for stripe = -2, 2 do
			part(parent, "DoorRib", Vector3.new(7.4, 0.15, 0.12), door.CFrame * CFrame.new(0, stripe * 1.25, -0.3), Color3.fromRGB(103, 107, 110), Enum.Material.Metal)
		end
		part(parent, "DockBumper", Vector3.new(8.2, 0.65, 0.8), CFrame.new(position + Vector3.new(bay * 10, 0.8, 10.2)), Color3.fromRGB(235, 181, 55), Enum.Material.Rubber)
	end
end

local function residential(parent: Instance, center: Vector3, config, roadWidth: number)
	local vergeZ = roadWidth / 2 + 15
	for rowSide in { -1, 1 } do
		for i = -3, 3 do
			local x = center.X + i * (config.GroundSize[1] / 8)
			local z = center.Z + rowSide * (vergeZ + 22)
			local driveway = part(parent, "Driveway", Vector3.new(13, 0.18, 22), CFrame.new(x, 0.1, z), Color3.fromRGB(132, 134, 135), Enum.Material.Concrete)
			driveway.CanCollide = false
			if i % 2 == 0 then
				tree(parent, Vector3.new(x + 10, 0, z + rowSide * 4), 0.78)
			end
		end
	end

	for side in { -1, 1 } do
		local parkZ = center.Z + side * (config.GroundSize[2] / 2 - 28)
		local lawn = part(parent, "PocketPark", Vector3.new(42, 0.16, 24), CFrame.new(center.X + side * 62, 0.09, parkZ), Color3.fromRGB(78, 128, 72), Enum.Material.Grass)
		lawn.CanCollide = false
		for i = -1, 1 do
			tree(parent, Vector3.new(center.X + side * 62 + i * 11, 0, parkZ), 0.85)
		end
	end
end

local function downtown(parent: Instance, center: Vector3, config, roadWidth: number)
	local roadEdge = roadWidth / 2 + 9

	for side in { -1, 1 } do
		local parking = part(
			parent,
			"DowntownParkingLane",
			Vector3.new(config.GroundSize[1] * 0.84, 0.22, 18),
			CFrame.new(center.X, 0.12, center.Z + side * (roadEdge + 17)),
			Color3.fromRGB(66, 68, 71),
			Enum.Material.Asphalt
		)
		parking.CanCollide = false

		for slot = -5, 5 do
			local x = center.X + slot * 19
			part(parent, "ParkingLine", Vector3.new(0.18, 0.08, 14), CFrame.new(x, 0.27, center.Z + side * (roadEdge + 17)), Color3.fromRGB(218, 218, 210), Enum.Material.SmoothPlastic)
			if slot % 3 == 0 then
				parkedCar(parent, Vector3.new(x + 7, 0, center.Z + side * (roadEdge + 17)), if side > 0 then 90 else -90, if slot % 2 == 0 then Color3.fromRGB(70, 108, 145) else Color3.fromRGB(146, 74, 65))
			end
		end
	end

	local plaza = part(parent, "DowntownPlaza", Vector3.new(72, 0.2, 38), CFrame.new(center.X + 82, 0.11, center.Z + config.GroundSize[2] * 0.32), Color3.fromRGB(178, 178, 174), Enum.Material.Pavement)
	plaza.CanCollide = false
	for i = -2, 2 do
		tree(parent, Vector3.new(center.X + 82 + i * 13, 0, center.Z + config.GroundSize[2] * 0.32), 0.65)
	end

	for bollard = -5, 5 do
		part(parent, "CityBollard", Vector3.new(0.5, 2.3, 0.5), CFrame.new(center.X + bollard * 16, 1.15, center.Z + roadEdge + 7), Color3.fromRGB(56, 60, 63), Enum.Material.Metal)
	end
end

local function industrial(parent: Instance, center: Vector3, config, roadWidth: number)
	local yardZ = center.Z + config.GroundSize[2] * 0.31
	local yard = part(parent, "IndustrialServiceYard", Vector3.new(config.GroundSize[1] * 0.7, 0.22, 54), CFrame.new(center.X, 0.12, yardZ), Color3.fromRGB(93, 95, 96), Enum.Material.Concrete)
	yard.CanCollide = false

	for lane = -2, 2 do
		part(parent, "YardLane", Vector3.new(0.2, 0.08, 46), CFrame.new(center.X + lane * 25, 0.27, yardZ), Color3.fromRGB(225, 190, 74), Enum.Material.SmoothPlastic)
	end

	loadingDock(parent, Vector3.new(center.X - 92, 0, yardZ))
	loadingDock(parent, Vector3.new(center.X + 92, 0, yardZ))

	container(parent, Vector3.new(center.X - 45, 0, yardZ + 8), Color3.fromRGB(63, 101, 126))
	container(parent, Vector3.new(center.X - 27, 0, yardZ + 8), Color3.fromRGB(137, 70, 56))
	container(parent, Vector3.new(center.X + 35, 0, yardZ + 8), Color3.fromRGB(79, 112, 72))

	local fenceZ = center.Z - config.GroundSize[2] * 0.38
	fenceRun(parent, Vector3.new(center.X, 0, fenceZ), config.GroundSize[1] * 0.78, true)
	for side in { -1, 1 } do
		fenceRun(parent, Vector3.new(center.X + side * config.GroundSize[1] * 0.39, 0, center.Z), config.GroundSize[2] * 0.72, false)
	end

	for i = -3, 3 do
		part(parent, "PipeRackPost", Vector3.new(0.55, 7.5, 0.55), CFrame.new(center.X + i * 18, 3.75, center.Z - roadWidth / 2 - 25), Color3.fromRGB(66, 70, 73), Enum.Material.Metal)
	end
	for y = 5.2, 7.2, 2 do
		part(parent, "PipeRackPipe", Vector3.new(116, 0.55, 0.55), CFrame.new(center.X, y, center.Z - roadWidth / 2 - 25), if y < 6 then Color3.fromRGB(68, 145, 214) else Color3.fromRGB(230, 112, 55), Enum.Material.Metal).Shape = Enum.PartType.Cylinder
	end
end

function DistrictDensityArt.Add(parent: Instance, districtId: string, center: Vector3, config, roadWidth: number)
	local model = Instance.new("Model")
	model.Name = "DistrictProductionDensity"
	model:SetAttribute("DistrictId", districtId)
	model.Parent = parent

	if districtId == "residential" then
		residential(model, center, config, roadWidth)
	elseif districtId == "downtown" then
		downtown(model, center, config, roadWidth)
	elseif districtId == "industrial" then
		industrial(model, center, config, roadWidth)
	end
end

return DistrictDensityArt
