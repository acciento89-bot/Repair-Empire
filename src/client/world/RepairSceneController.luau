--!strict

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

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

local function label(parent: BasePart, text: string, tradeColor: Color3)
	parent.Transparency = 1
	local gui = Instance.new("BillboardGui")
	gui.Name = "ServiceLabel"
	gui.Adornee = parent
	gui.Size = UDim2.fromOffset(230, 58)
	gui.StudsOffset = Vector3.new(0, 0.4, 0)
	gui.AlwaysOnTop = true
	gui.Parent = parent

	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundColor3 = Color3.fromRGB(24, 34, 43)
	t.BackgroundTransparency = 0.06
	t.BorderSizePixel = 0
	t.Font = Enum.Font.GothamBold
	t.TextScaled = true
	t.TextColor3 = tradeColor
	t.Text = text
	t.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = t

	local stroke = Instance.new("UIStroke")
	stroke.Color = tradeColor
	stroke.Thickness = 1.4
	stroke.Transparency = 0.1
	stroke.Parent = t
end

local function baseRig(model: Model, origin: CFrame, title: string, tradeColor: Color3)
	local mat = part(model, "ServiceMat", Vector3.new(11, 0.12, 6), origin * CFrame.new(0, 0.06, 0), Color3.fromRGB(48, 52, 56), Enum.Material.Rubber)
	local border = part(model, "SafetyStripe", Vector3.new(11, 0.08, 0.35), origin * CFrame.new(0, 0.13, 2.72), tradeColor, Enum.Material.Neon)
	border.Transparency = 0.08

	local labelAnchor = part(model, "ServiceLabelAnchor", Vector3.new(0.2, 0.2, 0.2), origin * CFrame.new(0, 6.2, 0), tradeColor, Enum.Material.SmoothPlastic)
	label(labelAnchor, title, tradeColor)

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
end

local function buildEnergy(model: Model, origin: CFrame)
	local trade = TRADE_COLORS.energy
	baseRig(model, origin, "ENERGY SERVICE", trade)
	part(model, "HeatPumpBody", Vector3.new(7.5, 5.2, 2.5), origin * CFrame.new(0, 2.75, 0.55), Color3.fromRGB(208, 215, 216), Enum.Material.Metal)
	local panel = part(model, "Controller", Vector3.new(2.2, 1.6, 0.22), origin * CFrame.new(2.2, 3.7, -0.82), Color3.fromRGB(35, 45, 51), Enum.Material.Glass)
	label(panel, "SYSTEM", trade)
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
end

local BUILDERS = {
	plumbing = buildPlumbing,
	heating = buildHeating,
	climate = buildClimate,
	energy = buildEnergy,
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
	local builder = BUILDERS[category] or buildPlumbing
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
	model:SetAttribute("CurrentAction", if stage and stage.Action then stage.Action else "repair")
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
	setState(model, "completed")
	task.delay(2.5, function()
		if RepairSceneController._model == model then
			RepairSceneController.Clear()
		end
	end)
end

return RepairSceneController
