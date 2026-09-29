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
		local clock = part(parent, "ClockFace", Vector3.new(4.4, 4.4, 0.18), CFrame.new(x, 16.2, z + face * 3.35), Color3.fromRGB(235, 231, 211), Enum.Material.SmoothPlastic)
		clock.Shape = Enum.PartType.Cylinder
		clock.Orientation = Vector3.new(90, 0, 0)
	end
	local light = part(parent, "ClockBeacon", Vector3.new(1.2, 1.2, 1.2), crown.CFrame * CFrame.new(0, 2.2, 0), Color3.fromRGB(245, 151, 49), Enum.Material.Neon)
	light.Shape = Enum.PartType.Ball
end

local function industrial(parent: Instance, center: Vector3, config)
	local x = center.X + config.GroundSize[1] * 0.3
	local z = center.Z + config.GroundSize[2] * 0.3

	for _, side in { -1, 1 } do
		local tank = part(parent, "TankFarmTank", Vector3.new(9, 13, 13), CFrame.new(x + side * 9, 6.5, z), Color3.fromRGB(134, 139, 142), Enum.Material.Metal)
		tank.Shape = Enum.PartType.Cylinder
		tank.Orientation = Vector3.new(0, 0, 90)
		part(parent, "TankBand", Vector3.new(9.1, 13.2, 0.8), CFrame.new(x + side * 9, 6.5, z), Color3.fromRGB(77, 82, 86), Enum.Material.Metal).Shape =
			Enum.PartType.Cylinder
	end

	for _, side in { -1, 1 } do
		part(parent, "PipeRackPost", Vector3.new(0.8, 9, 0.8), CFrame.new(x + side * 13, 4.5, z - 14), Color3.fromRGB(70, 74, 78), Enum.Material.Metal)
	end
	part(parent, "PipeRackBeam", Vector3.new(27, 0.8, 0.8), CFrame.new(x, 8.5, z - 14), Color3.fromRGB(70, 74, 78), Enum.Material.Metal)
	for lane = -1, 1 do
		local pipe = part(parent, "OverheadPipe", Vector3.new(26, 0.75, 0.75), CFrame.new(x, 7.3 + lane * 1.0, z - 14), if lane == 0 then Color3.fromRGB(230, 112, 55) else Color3.fromRGB(68, 145, 214), Enum.Material.Metal)
		pipe.Shape = Enum.PartType.Cylinder
		pipe.Orientation = Vector3.new(0, 0, 90)
	end

	local sign = part(parent, "IndustrialLandmarkSign", Vector3.new(16, 3.0, 0.3), CFrame.new(x, 11, z - 14), Color3.fromRGB(28, 35, 41), Enum.Material.Metal)
	textSign(sign, "INDUSTRIAL", Color3.fromRGB(245, 151, 49))
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
