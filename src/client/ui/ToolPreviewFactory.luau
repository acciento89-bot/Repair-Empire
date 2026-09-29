--!strict

local ToolPreviewFactory = {}

local TIER_COLORS = {
	Color3.fromRGB(160, 166, 172),
	Color3.fromRGB(68, 145, 214),
	Color3.fromRGB(245, 151, 49),
	Color3.fromRGB(103, 177, 92),
}

local function piece(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = position
	p.Anchored = true
	p.CanCollide = false
	p.Material = material or Enum.Material.Metal
	p.Color = color
	p.Parent = parent
	return p
end

local function cylinder(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3): Part
	local p = piece(parent, name, size, position, color, Enum.Material.Metal)
	p.Shape = Enum.PartType.Cylinder
	return p
end

local function wrench(model: Model, accent: Color3)
	local shaft = piece(model, "Shaft", Vector3.new(0.55, 4.4, 0.35), Vector3.new(0, 0, 0), Color3.fromRGB(178, 183, 188))
	shaft.Orientation = Vector3.new(0, 0, -18)
	cylinder(model, "Handle", Vector3.new(0.55, 1.15, 1.15), Vector3.new(-0.68, -2.0, 0), accent)
	local jaw = piece(model, "Jaw", Vector3.new(1.6, 1.1, 0.38), Vector3.new(0.65, 2.0, 0), Color3.fromRGB(190, 195, 200))
	jaw.Orientation = Vector3.new(0, 0, -18)
	piece(model, "JawCut", Vector3.new(0.62, 0.75, 0.55), Vector3.new(0.95, 2.28, 0), Color3.fromRGB(32, 39, 45))
end

local function screwdriver(model: Model, accent: Color3)
	cylinder(model, "Handle", Vector3.new(2.5, 1.1, 1.1), Vector3.new(0, -1.4, 0), accent).Orientation = Vector3.new(0, 0, 90)
	local shaft = cylinder(model, "Shaft", Vector3.new(3.2, 0.28, 0.28), Vector3.new(0, 1.3, 0), Color3.fromRGB(180, 185, 190))
	shaft.Orientation = Vector3.new(0, 0, 90)
	piece(model, "Tip", Vector3.new(0.18, 0.7, 0.18), Vector3.new(0, 3.0, 0), Color3.fromRGB(120, 125, 130))
end

local function pliers(model: Model, accent: Color3)
	for _, side in { -1, 1 } do
		local handle = piece(model, "Handle", Vector3.new(0.65, 3.2, 0.55), Vector3.new(side * 0.65, -1.45, 0), accent)
		handle.Orientation = Vector3.new(0, 0, side * 12)
		local jaw = piece(model, "Jaw", Vector3.new(0.55, 2.0, 0.42), Vector3.new(side * 0.3, 1.2, 0), Color3.fromRGB(180, 185, 190))
		jaw.Orientation = Vector3.new(0, 0, -side * 12)
	end
	cylinder(model, "Pivot", Vector3.new(0.42, 0.72, 0.72), Vector3.new(0, 0.15, 0), Color3.fromRGB(85, 90, 95))
end

local function caseKit(model: Model, accent: Color3, labelText: string)
	local body = piece(model, "Case", Vector3.new(5.0, 3.3, 1.3), Vector3.new(0, 0, 0), Color3.fromRGB(45, 51, 57), Enum.Material.SmoothPlastic)
	piece(model, "AccentBand", Vector3.new(5.05, 0.5, 1.36), Vector3.new(0, -1.0, 0), accent, Enum.Material.SmoothPlastic)
	piece(model, "Handle", Vector3.new(2.1, 0.45, 0.55), Vector3.new(0, 1.95, 0), Color3.fromRGB(85, 90, 95), Enum.Material.Metal)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 32
	gui.Parent = body
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = accent
	label.Text = labelText
	label.Parent = gui
end

local function meter(model: Model, accent: Color3)
	local body = piece(model, "MeterBody", Vector3.new(3.0, 4.6, 1.1), Vector3.new(0, 0, 0), Color3.fromRGB(47, 52, 57), Enum.Material.SmoothPlastic)
	local display = piece(model, "Display", Vector3.new(2.25, 1.5, 0.16), Vector3.new(0, 0.9, -0.62), Color3.fromRGB(24, 38, 42), Enum.Material.Glass)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.Parent = display
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.TextScaled = true
	text.Font = Enum.Font.GothamBold
	text.TextColor3 = accent
	text.Text = "READY"
	text.Parent = gui
	for x = -1, 1 do
		cylinder(
			model,
			"ProbeJack",
			Vector3.new(0.3, 0.52, 0.52),
			Vector3.new(x * 0.72, -1.75, -0.58),
			if x < 0 then Color3.fromRGB(220, 70, 65) else Color3.fromRGB(50, 50, 52)
		)
	end
	body:SetAttribute("ToolBody", true)
end

local function drain(model: Model, accent: Color3)
	cylinder(model, "Drum", Vector3.new(1.8, 3.4, 3.4), Vector3.new(0, 0.3, 0), Color3.fromRGB(72, 78, 84)).Orientation = Vector3.new(0, 90, 0)
	cylinder(model, "Hub", Vector3.new(2.2, 0.75, 0.75), Vector3.new(0, 0.3, 0), accent).Orientation = Vector3.new(0, 90, 0)
	piece(model, "Grip", Vector3.new(0.65, 3.1, 0.65), Vector3.new(-2.3, -0.7, 0), accent)
	piece(model, "Guide", Vector3.new(3.2, 0.35, 0.35), Vector3.new(2.3, 0.3, 0), Color3.fromRGB(180, 185, 190))
end

function ToolPreviewFactory.Create(parent: Instance, definition, equipped: boolean): ViewportFrame
	local viewport = Instance.new("ViewportFrame")
	viewport.Name = "ToolPreview"
	viewport.Size = UDim2.fromOffset(118, 78)
	viewport.Position = UDim2.fromOffset(9, 9)
	viewport.BackgroundColor3 = Color3.fromRGB(18, 31, 43)
	viewport.BorderSizePixel = 0
	viewport.Ambient = Color3.fromRGB(185, 190, 198)
	viewport.LightColor = Color3.fromRGB(255, 244, 220)
	viewport.LightDirection = Vector3.new(-1, -1, -1)
	viewport.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = viewport
	local stroke = Instance.new("UIStroke")
	stroke.Color = if equipped then Color3.fromRGB(245, 151, 49) else Color3.fromRGB(79, 105, 126)
	stroke.Thickness = if equipped then 1.5 else 1
	stroke.Transparency = 0.18
	stroke.Parent = viewport

	local model = Instance.new("Model")
	model.Parent = viewport
	local accent = TIER_COLORS[math.clamp(definition.Tier, 1, 4)]

	if definition.Family == "wrench" then
		wrench(model, accent)
	elseif definition.Family == "screwdriver" then
		screwdriver(model, accent)
	elseif definition.Family == "pliers" then
		pliers(model, accent)
	elseif definition.Family == "drain" then
		drain(model, accent)
	elseif definition.Family == "diagnostic_meter" then
		meter(model, accent)
	else
		local short = string.upper(definition.Family:gsub("_service", ""):gsub("_diagnostic", ""))
		caseKit(model, accent, short)
	end

	local camera = Instance.new("Camera")
	camera.CFrame = CFrame.new(Vector3.new(6.8, 5.2, 8.2), Vector3.new(0, 0, 0))
	camera.FieldOfView = 34
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	return viewport
end

return ToolPreviewFactory
