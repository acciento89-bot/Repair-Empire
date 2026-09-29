--!strict

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RepairSceneCatalog = require(ReplicatedStorage.RepairEmpire.Shared.jobs.RepairSceneCatalog)

local RepairSceneController = {
	_model = nil :: Model?,
	_category = nil :: string?,
	_stageIndex = 0,
	_animationConnection = nil,
	_elapsed = 0,
}

local TRADE_COLORS = {
	plumbing = Color3.fromRGB(68, 145, 214),
	heating = Color3.fromRGB(230, 112, 55),
	climate = Color3.fromRGB(76, 188, 202),
	energy = Color3.fromRGB(103, 177, 92),
}

local function part(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Material = material or Enum.Material.SmoothPlastic
	p.Color = color
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function cylinder(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?): Part
	local p = part(parent, name, size, cf, color, material)
	p.Shape = Enum.PartType.Cylinder
	return p
end

local function serviceLabel(parent: BasePart, text: string, tradeColor: Color3)
	parent.Transparency = 1
	local gui = Instance.new("BillboardGui")
	gui.Name = "ServiceLabel"
	gui.Adornee = parent
	gui.Size = UDim2.fromOffset(250, 82)
	gui.StudsOffset = Vector3.new(0, 0.4, 0)
	gui.AlwaysOnTop = true
	gui.Parent = parent

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.fromRGB(24, 34, 43)
	frame.BackgroundTransparency = 0.06
	frame.BorderSizePixel = 0
	frame.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = tradeColor
	stroke.Thickness = 1.4
	stroke.Transparency = 0.1
	stroke.Parent = frame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -16, 0, 48)
	title.Position = UDim2.fromOffset(8, 4)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextScaled = true
	title.TextColor3 = tradeColor
	title.Text = text
	title.Parent = frame

	local action = Instance.new("TextLabel")
	action.Name = "ActionText"
	action.Size = UDim2.new(1, -16, 0, 23)
	action.Position = UDim2.fromOffset(8, 54)
	action.BackgroundTransparency = 1
	action.Font = Enum.Font.GothamMedium
	action.TextScaled = true
	action.TextColor3 = Color3.fromRGB(241, 244, 246)
	action.Text = "INSPECT"
	action.Parent = frame
end

local function surfaceLabel(parent: BasePart, text: string, textColor: Color3)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "EquipmentLabel"
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 38
	gui.Parent = parent

	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.BorderSizePixel = 0
	t.Font = Enum.Font.GothamBold
	t.TextScaled = true
	t.TextColor3 = textColor
	t.Text = text
	t.Parent = gui
end

local function baseRig(model: Model, origin: CFrame, title: string, tradeColor: Color3)
	local mat = part(model, "ServiceMat", Vector3.new(11, 0.12, 6), origin * CFrame.new(0, 0.06, 0), Color3.fromRGB(48, 52, 56), Enum.Material.Rubber)
	local border = part(model, "SafetyStripe", Vector3.new(11, 0.08, 0.35), origin * CFrame.new(0, 0.13, 2.72), tradeColor, Enum.Material.Neon)
	border.Transparency = 0.08

	local labelAnchor = part(model, "ServiceLabelAnchor", Vector3.new(0.2, 0.2, 0.2), origin * CFrame.new(0, 6.4, 0), tradeColor, Enum.Material.SmoothPlastic)
	serviceLabel(labelAnchor, title, tradeColor)

	local lamp = part(model, "StatusLight", Vector3.new(0.7, 0.7, 0.7), origin * CFrame.new(4.6, 0.65, 2.2), Color3.fromRGB(225, 74, 74), Enum.Material.Neon)
	lamp.Shape = Enum.PartType.Ball
	lamp:SetAttribute("RepairStatusLight", true)
	return mat
end

local function addPipe(parent: Instance, name: string, length: number, cf: CFrame, color: Color3)
	local p = cylinder(parent, name, Vector3.new(length, 0.42, 0.42), cf * CFrame.Angles(0, 0, math.rad(90)), color, Enum.Material.Metal)
	return p
end

local function buildPlumbing(model: Model, origin: CFrame)
	local trade = TRADE_COLORS.plumbing
	baseRig(model, origin, "PLUMBING SERVICE", trade)
	part(model, "Cabinet", Vector3.new(5.5, 3.3, 2.4), origin * CFrame.new(0, 1.65, 0.7), Color3.fromRGB(214, 218, 220))
	part(model, "Basin", Vector3.new(6.2, 0.55, 2.9), origin * CFrame.new(0, 3.6, 0.45), Color3.fromRGB(238, 241, 242), Enum.Material.Marble)
	local faucet = addPipe(model, "FaucetStem", 1.6, origin * CFrame.new(0, 4.6, 1.0), Color3.fromRGB(165, 170, 175))
	faucet.Material = Enum.Material.Metal
	addPipe(model, "ColdPipe", 3.1, origin * CFrame.new(-1.1, 1.35, -0.65), trade)
	addPipe(model, "HotPipe", 3.1, origin * CFrame.new(1.1, 1.35, -0.65), Color3.fromRGB(205, 78, 64))
	cylinder(
		model,
		"Trap",
		Vector3.new(1.6, 0.75, 0.75),
		origin * CFrame.new(0, 1.5, -0.25) * CFrame.Angles(0, 0, math.rad(90)),
		Color3.fromRGB(145, 150, 154),
		Enum.Material.Metal
	)
	for side = -1, 1, 2 do
		cylinder(model, "Valve", Vector3.new(0.35, 1.2, 1.2), origin * CFrame.new(side * 1.1, 1.55, -0.7), Color3.fromRGB(190, 190, 190), Enum.Material.Metal)
	end
	local leak = part(model, "FaultEffect", Vector3.new(0.5, 0.5, 0.5), origin * CFrame.new(0, 0.7, -0.25), trade, Enum.Material.Neon)
	leak.Shape = Enum.PartType.Ball
	leak:SetAttribute("FaultEffect", true)
	local water = Instance.new("ParticleEmitter")
	water.Name = "WaterLeak"
	water.Rate = 9
	water.Lifetime = NumberRange.new(0.35, 0.65)
	water.Speed = NumberRange.new(2.5, 4)
	water.Acceleration = Vector3.new(0, -8, 0)
	water.SpreadAngle = Vector2.new(18, 18)
	water.Color = ColorSequence.new(Color3.fromRGB(95, 181, 245))
	water.Size = NumberSequence.new(0.16)
	water.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.12),
		NumberSequenceKeypoint.new(1, 0.8),
	})
	water.Parent = leak
end

local function buildHeating(model: Model, origin: CFrame)
	local trade = TRADE_COLORS.heating
	baseRig(model, origin, "HEATING SERVICE", trade)
	part(model, "RadiatorBack", Vector3.new(7.4, 4.2, 0.6), origin * CFrame.new(0, 2.35, 0.9), Color3.fromRGB(224, 226, 225), Enum.Material.Metal)
	for i = -4, 4 do
		part(model, "RadiatorFin", Vector3.new(0.42, 3.8, 0.95), origin * CFrame.new(i * 0.72, 2.35, 0.45), Color3.fromRGB(239, 240, 238), Enum.Material.Metal)
	end
	addPipe(model, "FlowPipe", 2.4, origin * CFrame.new(-3.3, 1.25, -0.15), Color3.fromRGB(205, 78, 64))
	addPipe(model, "ReturnPipe", 2.4, origin * CFrame.new(3.3, 1.25, -0.15), Color3.fromRGB(78, 121, 190))
	cylinder(model, "ThermostatValve", Vector3.new(0.9, 1.25, 1.25), origin * CFrame.new(-3.3, 2.3, -0.1), Color3.fromRGB(185, 190, 192), Enum.Material.Metal)
	local warning =
		part(model, "FaultEffect", Vector3.new(1.1, 1.1, 0.35), origin * CFrame.new(3.0, 4.25, 0.2), Color3.fromRGB(235, 84, 70), Enum.Material.Neon)
	warning:SetAttribute("FaultEffect", true)
	local heatLight = Instance.new("PointLight")
	heatLight.Name = "HeatGlow"
	heatLight.Color = Color3.fromRGB(255, 139, 74)
	heatLight.Range = 8
	heatLight.Brightness = 1.1
	heatLight.Parent = warning
	local steam = Instance.new("ParticleEmitter")
	steam.Name = "Steam"
	steam.Rate = 5
	steam.Lifetime = NumberRange.new(0.8, 1.4)
	steam.Speed = NumberRange.new(0.7, 1.4)
	steam.Acceleration = Vector3.new(0, 1.7, 0)
	steam.Color = ColorSequence.new(Color3.fromRGB(225, 228, 230))
	steam.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.25),
		NumberSequenceKeypoint.new(1, 0.75),
	})
	steam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.45),
		NumberSequenceKeypoint.new(1, 1),
	})
	steam.Parent = warning
end

local function buildClimate(model: Model, origin: CFrame)
	local trade = TRADE_COLORS.climate
	baseRig(model, origin, "CLIMATE SERVICE", trade)
	part(model, "OutdoorUnit", Vector3.new(7.3, 4.6, 2.3), origin * CFrame.new(0, 2.45, 0.6), Color3.fromRGB(218, 224, 226), Enum.Material.Metal)
	local grille = cylinder(
		model,
		"FanGrille",
		Vector3.new(0.4, 3.2, 3.2),
		origin * CFrame.new(0, 2.55, -0.65) * CFrame.Angles(0, math.rad(90), 0),
		Color3.fromRGB(72, 78, 82),
		Enum.Material.Metal
	)
	grille.Transparency = 0.12
	local hub = cylinder(
		model,
		"FanHub",
		Vector3.new(0.55, 0.65, 0.65),
		origin * CFrame.new(0, 2.55, -0.9) * CFrame.Angles(0, math.rad(90), 0),
		trade,
		Enum.Material.Metal
	)
	for i = 0, 5 do
		local angle = math.rad(i * 60)
		part(
			model,
			"FanBlade",
			Vector3.new(0.42, 1.9, 0.22),
			origin * CFrame.new(math.cos(angle) * 0.8, 2.55 + math.sin(angle) * 0.8, -1.02) * CFrame.Angles(0, 0, -angle),
			Color3.fromRGB(95, 102, 106),
			Enum.Material.Metal
		)
	end
	addPipe(model, "RefrigerantLine", 3.1, origin * CFrame.new(-2.2, 1.2, -0.7), Color3.fromRGB(181, 136, 70))
	addPipe(model, "CondensateLine", 3.1, origin * CFrame.new(2.2, 1.2, -0.7), trade)
	local fault =
		part(model, "FaultEffect", Vector3.new(1.2, 0.5, 0.35), origin * CFrame.new(2.6, 4.15, -0.62), Color3.fromRGB(235, 84, 70), Enum.Material.Neon)
	fault:SetAttribute("FaultEffect", true)
	hub:SetAttribute("SpinTarget", true)
	for index = -1, 1 do
		local airflow = part(model, "Airflow", Vector3.new(0.22, 0.22, 4.5), origin * CFrame.new(index * 1.1, 2.55, -3.15), trade, Enum.Material.Neon)
		airflow.Transparency = 0.68
		airflow:SetAttribute("AirflowEffect", true)
	end
end

local function buildEnergy(model: Model, origin: CFrame)
	local trade = TRADE_COLORS.energy
	baseRig(model, origin, "ENERGY SERVICE", trade)
	part(model, "HeatPumpBody", Vector3.new(7.5, 5.2, 2.5), origin * CFrame.new(0, 2.75, 0.55), Color3.fromRGB(208, 215, 216), Enum.Material.Metal)
	local panel = part(model, "Controller", Vector3.new(2.2, 1.6, 0.22), origin * CFrame.new(2.2, 3.7, -0.82), Color3.fromRGB(35, 45, 51), Enum.Material.Glass)
	surfaceLabel(panel, "SYSTEM", trade)
	local grille = cylinder(
		model,
		"Fan",
		Vector3.new(0.35, 2.9, 2.9),
		origin * CFrame.new(-1.5, 2.8, -0.85) * CFrame.Angles(0, math.rad(90), 0),
		Color3.fromRGB(75, 82, 85),
		Enum.Material.Metal
	)
	grille.Transparency = 0.1
	addPipe(model, "PrimaryFlow", 3.0, origin * CFrame.new(-2.4, 1.2, -0.65), Color3.fromRGB(205, 78, 64))
	addPipe(model, "PrimaryReturn", 3.0, origin * CFrame.new(2.4, 1.2, -0.65), Color3.fromRGB(78, 121, 190))
	for i = -1, 1 do
		local cable = part(
			model,
			"Cable",
			Vector3.new(0.18, 2.4, 0.18),
			origin * CFrame.new(3.2 + i * 0.35, 1.4, -0.72),
			Color3.fromRGB(38, 40, 43),
			Enum.Material.Rubber
		)
		cable:SetAttribute("Cable", true)
	end
	local fault = part(model, "FaultEffect", Vector3.new(0.7, 0.7, 0.3), origin * CFrame.new(2.2, 3.7, -0.98), Color3.fromRGB(235, 84, 70), Enum.Material.Neon)
	fault:SetAttribute("FaultEffect", true)
	local sparks = Instance.new("Sparkles")
	sparks.Name = "EnergySparks"
	sparks.SparkleColor = trade
	sparks.Parent = fault
	local glow = Instance.new("PointLight")
	glow.Name = "ControllerGlow"
	glow.Color = trade
	glow.Range = 7
	glow.Brightness = 1.2
	glow.Parent = fault
end

local function buildToilet(model: Model, origin: CFrame)
	local trade = TRADE_COLORS.plumbing
	baseRig(model, origin, "SANITARY SERVICE", trade)
	part(model, "Cistern", Vector3.new(3.5, 3.1, 1.9), origin * CFrame.new(0, 3.0, 1.25), Color3.fromRGB(236, 239, 239), Enum.Material.Marble)
	local bowl = part(model, "Bowl", Vector3.new(3.8, 2.2, 3.4), origin * CFrame.new(0, 1.15, -0.2), Color3.fromRGB(240, 242, 242), Enum.Material.Marble)
	bowl.Shape = Enum.PartType.Ball
	local seat = cylinder(
		model,
		"Seat",
		Vector3.new(0.35, 3.15, 3.15),
		origin * CFrame.new(0, 2.1, -0.35) * CFrame.Angles(0, math.rad(90), 0),
		Color3.fromRGB(214, 217, 217),
		Enum.Material.SmoothPlastic
	)
	seat.Transparency = 0.08
	addPipe(model, "SupplyPipe", 2.2, origin * CFrame.new(-1.9, 1.0, 0.9), Color3.fromRGB(165, 170, 175))
	local valve =
		cylinder(model, "ShutoffValve", Vector3.new(0.45, 1.1, 1.1), origin * CFrame.new(-1.9, 1.65, 0.9), Color3.fromRGB(180, 184, 188), Enum.Material.Metal)
	valve:SetAttribute("RepairDetail", true)
	local fault = part(model, "FaultEffect", Vector3.new(0.55, 0.55, 0.55), origin * CFrame.new(-1.1, 0.45, -0.5), trade, Enum.Material.Neon)
	fault.Shape = Enum.PartType.Ball
	fault:SetAttribute("FaultEffect", true)
end

local function buildPipeService(model: Model, origin: CFrame)
	local trade = TRADE_COLORS.plumbing
	baseRig(model, origin, "PIPEWORK SERVICE", trade)
	for _, y in { 1.6, 3.2 } do
		local pipe = cylinder(
			model,
			"PipeRun",
			Vector3.new(8.2, 0.8, 0.8),
			origin * CFrame.new(0, y, 0) * CFrame.Angles(0, 0, math.rad(90)),
			Color3.fromRGB(155, 162, 166),
			Enum.Material.Metal
		)
		pipe:SetAttribute("RepairDetail", true)
	end
	for _, x in { -2.4, 2.4 } do
		cylinder(model, "Coupling", Vector3.new(0.9, 1.15, 1.15), origin * CFrame.new(x, 2.4, 0), Color3.fromRGB(103, 108, 112), Enum.Material.Metal)
	end
	local valve =
		cylinder(model, "IsolationValve", Vector3.new(0.55, 1.6, 1.6), origin * CFrame.new(0, 3.2, 0), Color3.fromRGB(207, 80, 64), Enum.Material.Metal)
	valve.Orientation = Vector3.new(0, 90, 0)
	local fault = part(model, "FaultEffect", Vector3.new(0.7, 0.7, 0.7), origin * CFrame.new(0.5, 1.6, -0.55), trade, Enum.Material.Neon)
	fault.Shape = Enum.PartType.Ball
	fault:SetAttribute("FaultEffect", true)
end

local function buildShowerMixer(model: Model, origin: CFrame)
	local trade = TRADE_COLORS.plumbing
	baseRig(model, origin, "SHOWER SERVICE", trade)
	part(model, "TileWall", Vector3.new(8.4, 5.6, 0.6), origin * CFrame.new(0, 2.8, 1.5), Color3.fromRGB(198, 205, 207), Enum.Material.Marble)
	addPipe(model, "ColdFeed", 3.6, origin * CFrame.new(-1.3, 2.0, 1.0), Color3.fromRGB(68, 145, 214))
	addPipe(model, "HotFeed", 3.6, origin * CFrame.new(1.3, 2.0, 1.0), Color3.fromRGB(205, 78, 64))
	local mixer = part(model, "MixerBody", Vector3.new(3.6, 1.1, 0.9), origin * CFrame.new(0, 2.7, 0.8), Color3.fromRGB(165, 171, 175), Enum.Material.Metal)
	for _, x in { -1.1, 1.1 } do
		local knob = cylinder(
			model,
			"MixerKnob",
			Vector3.new(0.55, 0.95, 0.95),
			mixer.CFrame * CFrame.new(x, 0, -0.65),
			Color3.fromRGB(187, 191, 194),
			Enum.Material.Metal
		)
		knob.Orientation = Vector3.new(0, 90, 0)
	end
	addPipe(model, "Riser", 3.2, origin * CFrame.new(0, 4.4, 0.9), Color3.fromRGB(170, 175, 179))
	local head = cylinder(
		model,
		"ShowerHead",
		Vector3.new(0.5, 2.2, 2.2),
		origin * CFrame.new(0, 5.6, 0.0) * CFrame.Angles(0, math.rad(90), 0),
		Color3.fromRGB(170, 175, 179),
		Enum.Material.Metal
	)
	head:SetAttribute("RepairDetail", true)
	local fault = part(model, "FaultEffect", Vector3.new(0.6, 0.6, 0.4), origin * CFrame.new(0, 2.7, 0.25), Color3.fromRGB(235, 84, 70), Enum.Material.Neon)
	fault:SetAttribute("FaultEffect", true)
end

local function buildBoiler(model: Model, origin: CFrame)
	local trade = TRADE_COLORS.heating
	baseRig(model, origin, "BOILER SERVICE", trade)
	local body = part(model, "BoilerBody", Vector3.new(6.2, 6.2, 2.6), origin * CFrame.new(0, 3.15, 0.6), Color3.fromRGB(224, 226, 225), Enum.Material.Metal)
	local display =
		part(model, "BoilerDisplay", Vector3.new(2.3, 1.15, 0.18), body.CFrame * CFrame.new(0, 0.8, -1.38), Color3.fromRGB(33, 46, 51), Enum.Material.Glass)
	surfaceLabel(display, "72 C", trade)
	for _, x in { -2.1, -0.7, 0.7, 2.1 } do
		addPipe(model, "BoilerPipe", 2.2, origin * CFrame.new(x, 1.0, -0.7), if x < 0 then Color3.fromRGB(205, 78, 64) else Color3.fromRGB(78, 121, 190))
	end
	local gauge = cylinder(
		model,
		"PressureGauge",
		Vector3.new(0.35, 1.2, 1.2),
		origin * CFrame.new(2.0, 4.7, -0.8) * CFrame.Angles(0, math.rad(90), 0),
		Color3.fromRGB(238, 238, 232),
		Enum.Material.Metal
	)
	gauge:SetAttribute("RepairDetail", true)
	local fault =
		part(model, "FaultEffect", Vector3.new(0.7, 0.7, 0.25), origin * CFrame.new(-2.1, 4.7, -0.85), Color3.fromRGB(235, 84, 70), Enum.Material.Neon)
	fault:SetAttribute("FaultEffect", true)
end

local function buildPump(model: Model, origin: CFrame)
	local trade = TRADE_COLORS.heating
	baseRig(model, origin, "PUMP SERVICE", trade)
	addPipe(model, "FlowHeader", 7.8, origin * CFrame.new(0, 2.4, 0.4), Color3.fromRGB(205, 78, 64))
	local housing = cylinder(
		model,
		"PumpHousing",
		Vector3.new(2.5, 3.2, 3.2),
		origin * CFrame.new(0, 2.4, 0.1) * CFrame.Angles(0, math.rad(90), 0),
		Color3.fromRGB(74, 84, 90),
		Enum.Material.Metal
	)
	housing:SetAttribute("SpinTarget", true)
	part(model, "PumpMotor", Vector3.new(3.0, 2.2, 2.2), origin * CFrame.new(0, 2.4, 2.2), Color3.fromRGB(60, 66, 72), Enum.Material.Metal)
	for _, x in { -2.5, 2.5 } do
		cylinder(model, "Flange", Vector3.new(0.5, 1.5, 1.5), origin * CFrame.new(x, 2.4, 0.4), Color3.fromRGB(105, 110, 114), Enum.Material.Metal)
	end
	local fault = part(model, "FaultEffect", Vector3.new(0.65, 0.65, 0.35), origin * CFrame.new(0, 3.8, -1.4), Color3.fromRGB(235, 84, 70), Enum.Material.Neon)
	fault:SetAttribute("FaultEffect", true)
end

local function buildIndoorClimate(model: Model, origin: CFrame)
	local trade = TRADE_COLORS.climate
	baseRig(model, origin, "INDOOR UNIT SERVICE", trade)
	local body =
		part(model, "IndoorUnit", Vector3.new(8.6, 3.2, 1.8), origin * CFrame.new(0, 3.5, 0.7), Color3.fromRGB(224, 230, 232), Enum.Material.SmoothPlastic)
	for index = -4, 4 do
		local vent = part(
			model,
			"VentLouver",
			Vector3.new(0.55, 0.18, 1.0),
			body.CFrame * CFrame.new(index * 0.85, -1.05, -0.55),
			Color3.fromRGB(86, 94, 99),
			Enum.Material.Metal
		)
		vent.Orientation = Vector3.new(-18, 0, 0)
	end
	local filter =
		part(model, "Filter", Vector3.new(5.8, 1.7, 0.18), body.CFrame * CFrame.new(0, 0.2, -1.0), Color3.fromRGB(98, 155, 166), Enum.Material.Fabric)
	filter.Transparency = 0.18
	local fault =
		part(model, "FaultEffect", Vector3.new(0.75, 0.45, 0.25), body.CFrame * CFrame.new(3.1, 0.75, -1.02), Color3.fromRGB(235, 84, 70), Enum.Material.Neon)
	fault:SetAttribute("FaultEffect", true)
end

local function buildCommercialClimate(model: Model, origin: CFrame)
	local trade = TRADE_COLORS.climate
	baseRig(model, origin, "COMMERCIAL COOLING", trade)
	local body =
		part(model, "CommercialUnit", Vector3.new(9.2, 5.0, 3.2), origin * CFrame.new(0, 2.55, 0.6), Color3.fromRGB(188, 197, 201), Enum.Material.Metal)
	for _, x in { -2.4, 2.4 } do
		local fan = cylinder(
			model,
			"CommercialFan",
			Vector3.new(0.42, 2.8, 2.8),
			body.CFrame * CFrame.new(x, 0.3, -1.72) * CFrame.Angles(0, math.rad(90), 0),
			Color3.fromRGB(67, 75, 79),
			Enum.Material.Metal
		)
		fan:SetAttribute("SpinTarget", true)
	end
	for _, x in { -3.5, 0, 3.5 } do
		part(model, "CoilSection", Vector3.new(2.4, 2.8, 0.2), body.CFrame * CFrame.new(x, -1.0, -1.75), trade, Enum.Material.Metal).Transparency = 0.35
	end
	local fault =
		part(model, "FaultEffect", Vector3.new(0.75, 0.75, 0.3), body.CFrame * CFrame.new(0, 1.8, -1.8), Color3.fromRGB(235, 84, 70), Enum.Material.Neon)
	fault:SetAttribute("FaultEffect", true)
end

local function buildEnergyController(model: Model, origin: CFrame)
	local trade = TRADE_COLORS.energy
	baseRig(model, origin, "CONTROL SYSTEM", trade)
	local cabinet = part(model, "ControlCabinet", Vector3.new(6.5, 5.7, 2.2), origin * CFrame.new(0, 2.9, 0.7), Color3.fromRGB(75, 82, 87), Enum.Material.Metal)
	local display =
		part(model, "ControlDisplay", Vector3.new(3.5, 1.7, 0.18), cabinet.CFrame * CFrame.new(0, 0.9, -1.2), Color3.fromRGB(24, 43, 43), Enum.Material.Glass)
	surfaceLabel(display, "FAULT 07", Color3.fromRGB(235, 84, 70))
	for row = -1, 1 do
		for col = -2, 2 do
			local led = part(
				model,
				"StatusLED",
				Vector3.new(0.28, 0.28, 0.12),
				cabinet.CFrame * CFrame.new(col * 0.55, -1.2 + row * 0.5, -1.18),
				if col == 0 and row == 0 then Color3.fromRGB(235, 84, 70) else trade,
				Enum.Material.Neon
			)
			led.Shape = Enum.PartType.Ball
		end
	end
	local fault =
		part(model, "FaultEffect", Vector3.new(0.7, 0.7, 0.25), cabinet.CFrame * CFrame.new(2.4, 1.8, -1.2), Color3.fromRGB(235, 84, 70), Enum.Material.Neon)
	fault:SetAttribute("FaultEffect", true)
end

local function buildSolar(model: Model, origin: CFrame)
	local trade = TRADE_COLORS.energy
	baseRig(model, origin, "SOLAR THERMAL", trade)
	for _, x in { -2.4, 2.4 } do
		local panel = part(
			model,
			"SolarCollector",
			Vector3.new(4.2, 0.35, 5.2),
			origin * CFrame.new(x, 2.8, 0.3) * CFrame.Angles(math.rad(-28), 0, 0),
			Color3.fromRGB(40, 78, 93),
			Enum.Material.Glass
		)
		panel.Transparency = 0.06
		for stripe = -1, 1 do
			part(
				model,
				"CollectorPipe",
				Vector3.new(0.12, 0.4, 4.3),
				panel.CFrame * CFrame.new(stripe * 0.9, -0.25, 0),
				Color3.fromRGB(181, 102, 66),
				Enum.Material.Metal
			)
		end
	end
	local station = part(model, "PumpStation", Vector3.new(2.8, 3.4, 1.8), origin * CFrame.new(0, 1.7, -2.0), Color3.fromRGB(72, 78, 84), Enum.Material.Metal)
	surfaceLabel(station, "SOLAR", trade)
	local fault =
		part(model, "FaultEffect", Vector3.new(0.6, 0.6, 0.25), station.CFrame * CFrame.new(0.8, 0.8, -1.0), Color3.fromRGB(235, 84, 70), Enum.Material.Neon)
	fault:SetAttribute("FaultEffect", true)
end

local function buildHybrid(model: Model, origin: CFrame)
	local trade = TRADE_COLORS.energy
	baseRig(model, origin, "HYBRID SYSTEM", trade)
	local boiler =
		part(model, "HybridBoiler", Vector3.new(4.0, 5.4, 2.3), origin * CFrame.new(-2.4, 2.75, 0.7), Color3.fromRGB(220, 223, 222), Enum.Material.Metal)
	local heatPump =
		part(model, "HybridHeatPump", Vector3.new(4.6, 4.3, 2.5), origin * CFrame.new(2.4, 2.2, 0.6), Color3.fromRGB(194, 204, 206), Enum.Material.Metal)
	surfaceLabel(boiler, "BOILER", TRADE_COLORS.heating)
	surfaceLabel(heatPump, "HP", trade)
	addPipe(model, "HybridFlow", 4.0, origin * CFrame.new(0, 1.1, -0.7), Color3.fromRGB(205, 78, 64))
	addPipe(model, "HybridReturn", 4.0, origin * CFrame.new(0, 0.6, -0.7), Color3.fromRGB(78, 121, 190))
	local fault = part(model, "FaultEffect", Vector3.new(0.75, 0.75, 0.3), origin * CFrame.new(0, 3.8, -0.9), Color3.fromRGB(235, 84, 70), Enum.Material.Neon)
	fault:SetAttribute("FaultEffect", true)
end

local function prettyAction(id: string): string
	local words = string.split(id, "_")
	for index, word in words do
		words[index] = string.upper(word)
	end
	return table.concat(words, " ")
end

local BUILDERS = {
	sink = buildPlumbing,
	toilet = buildToilet,
	pipe = buildPipeService,
	shower = buildShowerMixer,
	radiator = buildHeating,
	boiler = buildBoiler,
	pump = buildPump,
	indoor = buildIndoorClimate,
	outdoor = buildClimate,
	commercial = buildCommercialClimate,
	heat_pump = buildEnergy,
	controller = buildEnergyController,
	solar = buildSolar,
	hybrid = buildHybrid,
}

local function setState(model: Model, state: string)
	local trade = RepairSceneController._category or "plumbing"
	local tradeColor = TRADE_COLORS[trade] or Color3.fromRGB(245, 151, 49)
	for _, item in model:GetDescendants() do
		if item:IsA("BasePart") then
			if item:GetAttribute("FaultEffect") == true then
				item.Transparency = if state == "completed" then 1 else if state == "active" then 0.08 else 0.2
				item.Color = if state == "completed" then Color3.fromRGB(76, 188, 112) else Color3.fromRGB(235, 84, 70)
			elseif item:GetAttribute("RepairStatusLight") == true then
				item.Color = if state == "completed"
					then Color3.fromRGB(76, 188, 112)
					else if state == "active" then tradeColor else Color3.fromRGB(235, 84, 70)
			end
		end
	end
end

local function startAnimation(model: Model)
	if RepairSceneController._animationConnection then
		RepairSceneController._animationConnection:Disconnect()
	end
	RepairSceneController._elapsed = 0
	RepairSceneController._animationConnection = RunService.RenderStepped:Connect(function(dt)
		if RepairSceneController._model ~= model or model.Parent == nil then
			return
		end
		RepairSceneController._elapsed += dt
		local pulse = (math.sin(RepairSceneController._elapsed * 4) + 1) * 0.5

		for _, item in model:GetDescendants() do
			if item:IsA("BasePart") then
				if item:GetAttribute("SpinTarget") == true then
					item.CFrame *= CFrame.Angles(0, 0, dt * 2.2)
				elseif item:GetAttribute("FaultEffect") == true and item.Transparency < 1 then
					item.Transparency = 0.08 + pulse * 0.18
				elseif item:GetAttribute("RepairStatusLight") == true then
					item.Material = Enum.Material.Neon
				end
			end
		end
	end)
end

function RepairSceneController.Clear()
	if RepairSceneController._animationConnection then
		RepairSceneController._animationConnection:Disconnect()
		RepairSceneController._animationConnection = nil
	end
	if RepairSceneController._model then
		RepairSceneController._model:Destroy()
	end
	RepairSceneController._model = nil
	RepairSceneController._category = nil
	RepairSceneController._stageIndex = 0
end

function RepairSceneController.Begin(job, stage, targetPosition: Vector3)
	RepairSceneController.Clear()
	local category = job and job.Category or "plumbing"
	local jobId = if job and type(job.Id) == "string" then job.Id else "unknown"
	local scene = RepairSceneCatalog.Get(jobId, category)
	local builder = BUILDERS[scene.Variant] or buildPlumbing
	local model = Instance.new("Model")
	model.Name = "RepairEmpireLocalJobScene"
	model:SetAttribute("JobId", job and job.Id or "unknown")
	model:SetAttribute("Category", category)
	model.Parent = workspace
	local origin = CFrame.new(targetPosition.X, 0, targetPosition.Z)
	builder(model, origin)
	RepairSceneController._model = model
	RepairSceneController._category = category
	RepairSceneController._stageIndex = 1
	model:SetAttribute("CurrentAction", if stage and stage.Action then stage.Action else "inspect")
	setState(model, "faulty")
	startAnimation(model)
end

function RepairSceneController.Update(stage)
	local model = RepairSceneController._model
	if not model then
		return
	end
	RepairSceneController._stageIndex += 1
	local action = if stage and stage.Action then stage.Action else "repair"
	model:SetAttribute("CurrentAction", action)
	local actionText = model:FindFirstChild("ActionText", true)
	if actionText and actionText:IsA("TextLabel") then
		actionText.Text = prettyAction(action)
	end
	setState(model, "active")
	local light = model:FindFirstChild("StatusLight", true)
	if light and light:IsA("BasePart") then
		light.Transparency = 0
		TweenService:Create(light, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(1.35, 0.6, 0.38),
		}):Play()
		task.delay(0.22, function()
			if light.Parent then
				TweenService:Create(light, TweenInfo.new(0.2), { Size = Vector3.new(1.0, 0.45, 0.3) }):Play()
			end
		end)
	end
end

function RepairSceneController.Complete()
	local model = RepairSceneController._model
	if not model then
		return
	end
	model:SetAttribute("CurrentAction", "completed")
	local actionText = model:FindFirstChild("ActionText", true)
	if actionText and actionText:IsA("TextLabel") then
		actionText.Text = "JOB COMPLETE"
		actionText.TextColor3 = Color3.fromRGB(120, 226, 151)
	end
	setState(model, "completed")
	for _, item in model:GetDescendants() do
		if item:IsA("ParticleEmitter") or item:IsA("Sparkles") then
			item.Enabled = false
		end
	end
	task.delay(2.5, function()
		if RepairSceneController._model == model then
			RepairSceneController.Clear()
		end
	end)
end

return RepairSceneController
