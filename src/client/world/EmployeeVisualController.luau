--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local EmployeeDefinitions = require(ReplicatedStorage.RepairEmpire.Shared.company.EmployeeDefinitions)

local EmployeeVisualController = {
	_model = nil :: Model?,
	_animation = nil,
	_time = 0,
}

local TRADE_COLORS = {
	plumbing = Color3.fromRGB(68, 145, 214),
	heating = Color3.fromRGB(230, 112, 55),
	climate = Color3.fromRGB(76, 188, 202),
	energy = Color3.fromRGB(103, 177, 92),
}

local ROLE_LABELS = {
	apprentice = "APPRENTICE",
	technician = "TECHNICIAN",
	specialist = "SPECIALIST",
	senior_technician = "SENIOR TECH",
	crew_lead = "CREW LEAD",
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

local function tradeFromId(employeeId: string): string
	for trade in TRADE_COLORS do
		if employeeId:find(trade, 1, true) then
			return trade
		end
	end
	return "plumbing"
end

local function worker(parent: Instance, definition, index: number, baseCf: CFrame): Model
	local model = Instance.new("Model")
	model.Name = ("Employee_%02d_%s"):format(index, definition.Id)
	model:SetAttribute("EmployeeId", definition.Id)
	model:SetAttribute("Role", definition.Role)
	model.Parent = parent

	local trade = tradeFromId(definition.Id)
	local accent = TRADE_COLORS[trade]
	local skin = if index % 3 == 0 then Color3.fromRGB(116, 83, 64) else if index % 2 == 0 then Color3.fromRGB(197, 151, 112) else Color3.fromRGB(225, 184, 145)
	local uniform = Color3.fromRGB(31, 48, 61)

	local torso = part(model, "Torso", Vector3.new(2.4, 3.0, 1.3), baseCf * CFrame.new(0, 4.5, 0), uniform)
	torso:SetAttribute("EmployeeTorso", true)

	local vestFront = part(model, "VestFront", Vector3.new(1.9, 2.5, 0.12), torso.CFrame * CFrame.new(0, 0, -0.72), accent)
	vestFront.Material = Enum.Material.Fabric

	local head = part(model, "Head", Vector3.new(1.65, 1.65, 1.65), baseCf * CFrame.new(0, 7.0, 0), skin)
	head.Shape = Enum.PartType.Ball

	local hardHat = part(model, "HardHat", Vector3.new(1.95, 0.55, 1.95), baseCf * CFrame.new(0, 8.0, 0), accent)
	hardHat.Shape = Enum.PartType.Cylinder
	hardHat.Orientation = Vector3.new(0, 0, 90)
	part(model, "HatBrim", Vector3.new(2.2, 0.18, 2.0), baseCf * CFrame.new(0, 7.75, -0.25), accent)

	for _, side in { -1, 1 } do
		local arm = part(model, if side < 0 then "LeftArm" else "RightArm", Vector3.new(0.75, 3.0, 0.75), baseCf * CFrame.new(side * 1.65, 4.45, 0), uniform)
		arm:SetAttribute("EmployeeArm", side)

		part(
			model,
			if side < 0 then "LeftLeg" else "RightLeg",
			Vector3.new(0.9, 3.1, 0.95),
			baseCf * CFrame.new(side * 0.62, 1.5, 0),
			Color3.fromRGB(46, 50, 55),
			Enum.Material.Fabric
		)

		local boot =
			part(model, "Boot", Vector3.new(1.0, 0.6, 1.6), baseCf * CFrame.new(side * 0.62, 0.15, -0.25), Color3.fromRGB(35, 31, 29), Enum.Material.Leather)
		boot:SetAttribute("EmployeeBoot", true)
	end

	local belt = part(model, "ToolBelt", Vector3.new(2.7, 0.42, 1.55), baseCf * CFrame.new(0, 3.1, 0), Color3.fromRGB(98, 69, 43), Enum.Material.Leather)
	for slot = -1, 1 do
		part(
			model,
			"BeltTool",
			Vector3.new(0.26, 1.0, 0.26),
			belt.CFrame * CFrame.new(slot * 0.75, -0.5, -0.92),
			if slot == 0 then accent else Color3.fromRGB(170, 175, 180),
			Enum.Material.Metal
		)
	end

	local labelAnchor = part(model, "LabelAnchor", Vector3.new(0.1, 0.1, 0.1), baseCf * CFrame.new(0, 9.3, 0), accent)
	labelAnchor.Transparency = 1
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(145, 38)
	gui.AlwaysOnTop = true
	gui.Adornee = labelAnchor
	gui.Parent = labelAnchor
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundColor3 = Color3.fromRGB(20, 31, 40)
	text.BackgroundTransparency = 0.12
	text.BorderSizePixel = 0
	text.Font = Enum.Font.GothamBold
	text.TextScaled = true
	text.TextColor3 = accent
	text.Text = ("%s • T%d"):format(ROLE_LABELS[definition.Role] or string.upper(definition.Role), definition.Tier)
	text.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = text

	model.PrimaryPart = torso
	return model
end

local function findWorkshop(): Model?
	local world = workspace:FindFirstChild("RepairEmpireWorld")
	local workshop = world and world:FindFirstChild("PlayerWorkshop", true)
	if workshop and workshop:IsA("Model") then
		return workshop
	end
	return nil
end

local function requestState()
	local remotes = ReplicatedStorage:WaitForChild("RepairEmpireRemotes")
	local remote = remotes:WaitForChild("RequestPlayerState")
	if not remote:IsA("RemoteFunction") then
		return nil
	end
	local result = remote:InvokeServer()
	if type(result) == "table" and result.ok and type(result.state) == "table" then
		return result.state
	end
	return nil
end

local function rebuild()
	if EmployeeVisualController._model then
		EmployeeVisualController._model:Destroy()
		EmployeeVisualController._model = nil
	end

	local state = requestState()
	if not state or type(state.Employees) ~= "table" then
		return
	end
	local workshop = findWorkshop()
	if not workshop then
		return
	end
	local building = workshop:FindFirstChild("WorkshopBuilding")
	if not building or not building:IsA("BasePart") then
		return
	end

	local root = Instance.new("Model")
	root.Name = "LocalCompanyEmployees"
	root.Parent = workshop
	EmployeeVisualController._model = root

	local ordered = {}
	for _, definition in EmployeeDefinitions.List do
		local count = state.Employees[definition.Id] or 0
		for _ = 1, count do
			table.insert(ordered, definition)
		end
	end

	local maxVisible = math.min(#ordered, 8)
	for index = 1, maxVisible do
		local definition = ordered[index]
		local row = math.floor((index - 1) / 4)
		local col = (index - 1) % 4
		local x = -10 + col * 6.5
		local z = -11 + row * 8
		worker(root, definition, index, building.CFrame * CFrame.new(x, -6.5, z) * CFrame.Angles(0, math.rad(180), 0))
	end
end

local function startIdleAnimation()
	if EmployeeVisualController._animation then
		EmployeeVisualController._animation:Disconnect()
	end
	EmployeeVisualController._animation = RunService.RenderStepped:Connect(function(dt)
		EmployeeVisualController._time += dt
		local model = EmployeeVisualController._model
		if not model then
			return
		end
		for index, employee in model:GetChildren() do
			if employee:IsA("Model") then
				local pulse = math.sin(EmployeeVisualController._time * 1.5 + index) * 0.08
				for _, item in employee:GetChildren() do
					if item:IsA("BasePart") and item:GetAttribute("EmployeeArm") then
						item.Orientation = Vector3.new(pulse * 18, 0, tonumber(item:GetAttribute("EmployeeArm")) * 4)
					end
				end
			end
		end
	end)
end

function EmployeeVisualController.Start()
	task.spawn(function()
		local player = Players.LocalPlayer
		if player:GetAttribute("RepairEmpireLoaded") ~= true then
			player:GetAttributeChangedSignal("RepairEmpireLoaded"):Wait()
		end
		task.wait(0.5)
		rebuild()
	end)

	local event = ReplicatedStorage:WaitForChild("RepairEmpireRemotes"):WaitForChild("StateUpdated")
	if event:IsA("RemoteEvent") then
		event.OnClientEvent:Connect(function(payload)
			if type(payload) == "table" and payload.kind == "company_changed" then
				task.defer(rebuild)
			end
		end)
	end
	startIdleAnimation()
end

return EmployeeVisualController
