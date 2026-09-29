--!strict

local UrbanUtilityArt = {}

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

local function manhole(parent: Instance, position: Vector3)
	local cover = part(
		parent,
		"ManholeCover",
		Vector3.new(0.12, 3.1, 3.1),
		CFrame.new(position + Vector3.new(0, 0.43, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color3.fromRGB(67, 69, 71),
		Enum.Material.Metal
	)
	cover.Shape = Enum.PartType.Cylinder
	for ring = 1, 2 do
		local inner = part(
			parent,
			"ManholeRing",
			Vector3.new(0.14, 2.5 - ring * 0.6, 2.5 - ring * 0.6),
			cover.CFrame * CFrame.new(0, 0.02 * ring, 0),
			Color3.fromRGB(88, 90, 92),
			Enum.Material.Metal
		)
		inner.Shape = Enum.PartType.Cylinder
	end
end

local function drain(parent: Instance, position: Vector3)
	local base =
		part(parent, "StormDrain", Vector3.new(3.4, 0.1, 1.6), CFrame.new(position + Vector3.new(0, 0.45, 0)), Color3.fromRGB(54, 57, 59), Enum.Material.Metal)
	for slot = -3, 3 do
		part(
			parent,
			"DrainSlot",
			Vector3.new(0.18, 0.06, 1.25),
			base.CFrame * CFrame.new(slot * 0.42, 0.07, 0),
			Color3.fromRGB(27, 29, 31),
			Enum.Material.Metal
		)
	end
end

local function utilityCabinet(parent: Instance, position: Vector3, accent: Color3)
	local cabinet = part(
		parent,
		"UtilityCabinet",
		Vector3.new(2.5, 4.2, 1.5),
		CFrame.new(position + Vector3.new(0, 2.1, 0)),
		Color3.fromRGB(74, 80, 84),
		Enum.Material.Metal
	)
	local door = part(
		parent,
		"UtilityCabinetDoor",
		Vector3.new(2.15, 3.45, 0.12),
		cabinet.CFrame * CFrame.new(0, 0, -0.82),
		Color3.fromRGB(89, 95, 99),
		Enum.Material.Metal
	)
	local indicator = part(parent, "UtilityIndicator", Vector3.new(0.28, 0.28, 0.08), door.CFrame * CFrame.new(0.7, 1.1, -0.08), accent, Enum.Material.Neon)
	indicator.Shape = Enum.PartType.Ball
end

local function roadSign(parent: Instance, position: Vector3, symbol: string, accent: Color3)
	local post = part(
		parent,
		"RoadSignPost",
		Vector3.new(0.32, 5.4, 0.32),
		CFrame.new(position + Vector3.new(0, 2.7, 0)),
		Color3.fromRGB(70, 74, 78),
		Enum.Material.Metal
	)
	local face =
		part(parent, "RoadSignFace", Vector3.new(3.2, 3.2, 0.18), post.CFrame * CFrame.new(0, 2.1, 0), Color3.fromRGB(237, 239, 238), Enum.Material.Metal)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 36
	gui.Parent = face
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = accent
	label.Text = symbol
	label.Parent = gui
end

function UrbanUtilityArt.Add(parent: Instance, districtId: string, center: Vector3, config, roadWidth: number)
	local model = Instance.new("Model")
	model.Name = "UrbanUtilityDetails"
	model.Parent = parent

	for index = -3, 3 do
		local x = center.X + index * (config.GroundSize[1] / 8)
		if index % 2 == 0 then
			manhole(model, Vector3.new(x, 0, center.Z))
		end
		drain(model, Vector3.new(x + 6, 0, center.Z - roadWidth / 2 + 1.1))
		drain(model, Vector3.new(x - 6, 0, center.Z + roadWidth / 2 - 1.1))
	end

	if districtId == "residential" then
		for side = -1, 1, 2 do
			utilityCabinet(model, Vector3.new(center.X + side * 58, 0, center.Z + roadWidth / 2 + 7), Color3.fromRGB(68, 145, 214))
		end
		roadSign(model, Vector3.new(center.X - 108, 0, center.Z - roadWidth / 2 - 8), "30", Color3.fromRGB(58, 86, 111))
	elseif districtId == "downtown" then
		for side = -1, 1, 2 do
			utilityCabinet(model, Vector3.new(center.X + side * 82, 0, center.Z - roadWidth / 2 - 8), Color3.fromRGB(245, 151, 49))
			roadSign(model, Vector3.new(center.X + side * 105, 0, center.Z + roadWidth / 2 + 8), "P", Color3.fromRGB(44, 102, 168))
		end
	elseif districtId == "industrial" then
		for index = -2, 2 do
			utilityCabinet(
				model,
				Vector3.new(center.X + index * 48, 0, center.Z + roadWidth / 2 + 9),
				if index % 2 == 0 then Color3.fromRGB(230, 112, 55) else Color3.fromRGB(103, 177, 92)
			)
		end
		roadSign(model, Vector3.new(center.X - 135, 0, center.Z - roadWidth / 2 - 9), "20", Color3.fromRGB(218, 90, 61))
	end
end

return UrbanUtilityArt
