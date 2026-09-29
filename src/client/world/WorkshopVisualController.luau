--!strict

local Players = game:GetService("Players")

local WorkshopVisualController = {
	_model = nil :: Model?,
	_connection = nil,
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
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function addRack(model: Model, cf: CFrame, accent: Color3)
	for y = 0, 2 do
		part(model, "Shelf", Vector3.new(7, 0.28, 2.1), cf * CFrame.new(0, y * 1.7, 0), Color3.fromRGB(77, 82, 87), Enum.Material.Metal)
	end
	for _, x in { -3.1, 3.1 } do
		part(model, "ShelfPost", Vector3.new(0.35, 4.2, 0.35), cf * CFrame.new(x, 1.7, 0), Color3.fromRGB(65, 69, 74), Enum.Material.Metal)
	end
	for i = -2, 2 do
		part(
			model,
			"PartsBin",
			Vector3.new(1.0, 0.85, 1.45),
			cf * CFrame.new(i * 1.25, 2.0, -0.2),
			if i % 2 == 0 then accent else Color3.fromRGB(48, 61, 72),
			Enum.Material.SmoothPlastic
		)
	end
end

local function addCompressor(model: Model, cf: CFrame)
	local tank = part(model, "CompressorTank", Vector3.new(4.2, 1.8, 1.8), cf, Color3.fromRGB(185, 72, 65), Enum.Material.Metal)
	tank.Shape = Enum.PartType.Cylinder
	tank.Orientation = Vector3.new(0, 0, 90)
	part(model, "CompressorMotor", Vector3.new(1.8, 1.4, 1.6), cf * CFrame.new(0, 1.55, 0), Color3.fromRGB(65, 70, 76), Enum.Material.Metal)
	for _, x in { -1.5, 1.5 } do
		local wheel =
			part(model, "CompressorWheel", Vector3.new(0.45, 0.9, 0.9), cf * CFrame.new(x, -1.0, 0), Color3.fromRGB(28, 30, 32), Enum.Material.SmoothPlastic)
		wheel.Shape = Enum.PartType.Cylinder
		wheel.Orientation = Vector3.new(0, 90, 0)
	end
end

local function addToolCabinet(model: Model, cf: CFrame, accent: Color3)
	local body = part(model, "ToolCabinet", Vector3.new(5.5, 4.8, 2.0), cf, Color3.fromRGB(45, 51, 57), Enum.Material.Metal)
	for row = -1, 1 do
		local drawer = part(model, "Drawer", Vector3.new(4.8, 0.9, 0.16), cf * CFrame.new(0, row * 1.2, -1.05), accent, Enum.Material.SmoothPlastic)
		drawer.Transparency = 0.08
	end
	body:SetAttribute("WorkshopProductionArt", true)
end

local function addOffice(model: Model, cf: CFrame, accent: Color3)
	part(model, "OfficeModule", Vector3.new(12, 6.5, 7), cf, Color3.fromRGB(38, 48, 58), Enum.Material.Metal)
	local window = part(model, "OfficeWindow", Vector3.new(6.5, 3.0, 0.18), cf * CFrame.new(0, 0.6, -3.55), Color3.fromRGB(104, 174, 203), Enum.Material.Glass)
	window.Transparency = 0.18
	local sign = part(model, "OfficeSign", Vector3.new(8, 1.2, 0.2), cf * CFrame.new(0, 2.7, -3.65), accent, Enum.Material.Neon)
	sign.Transparency = 0.05
end

local function rebuild()
	if WorkshopVisualController._model then
		WorkshopVisualController._model:Destroy()
		WorkshopVisualController._model = nil
	end

	local player = Players.LocalPlayer
	local tier = math.clamp(player:GetAttribute("WorkshopTier") or 1, 1, 5)
	local world = workspace:FindFirstChild("RepairEmpireWorld")
	if not world then
		return
	end
	local workshop = world:FindFirstChild("PlayerWorkshop", true)
	if not workshop or not workshop:IsA("Model") then
		return
	end
	local building = workshop:FindFirstChild("WorkshopBuilding")
	if not building or not building:IsA("BasePart") then
		return
	end

	local accent = Color3.fromRGB(245, 151, 49)
	local model = Instance.new("Model")
	model.Name = "LocalWorkshopTierVisuals"
	model:SetAttribute("WorkshopTier", tier)
	model.Parent = workshop
	WorkshopVisualController._model = model

	local base = building.CFrame

	if tier >= 2 then
		addRack(model, base * CFrame.new(17, -4.1, -2), accent)
		addToolCabinet(model, base * CFrame.new(13, -3.0, 6), accent)
		for _, side in { -1, 1 } do
			part(model, "BayLamp", Vector3.new(2.4, 0.35, 0.7), base * CFrame.new(side * 7.5, 4.6, -14.6), Color3.fromRGB(255, 231, 174), Enum.Material.Neon)
		end
	end

	if tier >= 3 then
		addCompressor(model, base * CFrame.new(18, -4.3, 7))
		addRack(model, base * CFrame.new(17, -4.1, 2), Color3.fromRGB(68, 145, 214))
		part(model, "ServiceCanopy", Vector3.new(18, 0.5, 9), base * CFrame.new(15, 4.5, -8), Color3.fromRGB(43, 51, 58), Enum.Material.Metal)
		for _, side in { -1, 1 } do
			part(model, "CanopyPost", Vector3.new(0.65, 8.5, 0.65), base * CFrame.new(15 + side * 7.8, 0.1, -8), accent, Enum.Material.Metal)
		end
	end

	if tier >= 4 then
		addOffice(model, base * CFrame.new(15, -1.7, 15), accent)
		for i = -2, 2 do
			part(model, "RoofSolar", Vector3.new(5.5, 0.25, 3.0), base * CFrame.new(i * 5.0, 7.5, 2), Color3.fromRGB(39, 74, 95), Enum.Material.Glass)
		end
	end

	if tier >= 5 then
		local mast = part(model, "CompanyMast", Vector3.new(0.8, 10, 0.8), base * CFrame.new(20, 0, -11), Color3.fromRGB(70, 75, 80), Enum.Material.Metal)
		local sign =
			part(model, "CompanyLightbox", Vector3.new(9, 3.2, 0.55), mast.CFrame * CFrame.new(0, 4.2, 0), Color3.fromRGB(20, 34, 46), Enum.Material.Metal)
		local gui = Instance.new("SurfaceGui")
		gui.Face = Enum.NormalId.Front
		gui.Parent = sign
		local text = Instance.new("TextLabel")
		text.Size = UDim2.fromScale(1, 1)
		text.BackgroundTransparency = 1
		text.Font = Enum.Font.GothamBold
		text.TextScaled = true
		text.TextColor3 = accent
		text.Text = "REPAIR EMPIRE\nHQ"
		text.Parent = gui
	end
end

function WorkshopVisualController.Start()
	local player = Players.LocalPlayer
	task.spawn(function()
		local deadline = os.clock() + 15
		while not workspace:FindFirstChild("RepairEmpireWorld") and os.clock() < deadline do
			task.wait(0.2)
		end
		rebuild()
	end)
	WorkshopVisualController._connection = player:GetAttributeChangedSignal("WorkshopTier"):Connect(rebuild)
end

return WorkshopVisualController
