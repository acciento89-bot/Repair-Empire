--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ToolDefinitions = require(ReplicatedStorage.RepairEmpire.Shared.tools.ToolDefinitions)

local ToolVisualService = {
	Name = "ToolVisualService",
	Dependencies = { "PlayerDataService" },
	_connections = {},
}

local TIER_COLORS = {
	Color3.fromRGB(158, 165, 171),
	Color3.fromRGB(68, 145, 214),
	Color3.fromRGB(245, 151, 49),
	Color3.fromRGB(103, 177, 92),
}

local function part(model: Model, name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Anchored = false
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Massless = true
	p.Material = material or Enum.Material.Metal
	p.Color = color
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = model
	return p
end

local function weld(root: BasePart, child: BasePart)
	if child == root then
		return
	end
	local joint = Instance.new("WeldConstraint")
	joint.Part0 = root
	joint.Part1 = child
	joint.Parent = root
end

local function buildWrench(model: Model, origin: CFrame, accent: Color3): BasePart
	local handle = part(model, "Handle", Vector3.new(0.42, 3.5, 0.28), origin, Color3.fromRGB(184, 188, 192))
	handle.CFrame *= CFrame.Angles(0, 0, math.rad(-18))
	local grip = part(model, "Grip", Vector3.new(0.58, 1.3, 0.38), origin * CFrame.new(-0.42, -1.55, 0), accent, Enum.Material.Rubber)
	local jaw = part(model, "Jaw", Vector3.new(1.25, 0.85, 0.34), origin * CFrame.new(0.48, 1.62, 0), Color3.fromRGB(194, 198, 202))
	weld(handle, grip)
	weld(handle, jaw)
	return handle
end

local function buildScrewdriver(model: Model, origin: CFrame, accent: Color3): BasePart
	local handle = part(model, "Handle", Vector3.new(0.95, 2.25, 0.95), origin, accent, Enum.Material.Rubber)
	local shaft = part(model, "Shaft", Vector3.new(0.22, 2.8, 0.22), origin * CFrame.new(0, 2.35, 0), Color3.fromRGB(190, 194, 198))
	local tip = part(model, "Tip", Vector3.new(0.14, 0.5, 0.14), origin * CFrame.new(0, 4.0, 0), Color3.fromRGB(112, 116, 120))
	weld(handle, shaft)
	weld(handle, tip)
	return handle
end

local function buildPliers(model: Model, origin: CFrame, accent: Color3): BasePart
	local pivot = part(model, "Pivot", Vector3.new(0.7, 0.45, 0.7), origin, Color3.fromRGB(95, 99, 103))
	pivot.Shape = Enum.PartType.Cylinder
	pivot.Orientation = Vector3.new(90, 0, 0)
	for _, side in { -1, 1 } do
		local handle = part(model, "Grip", Vector3.new(0.55, 2.8, 0.48), origin * CFrame.new(side * 0.52, -1.55, 0), accent, Enum.Material.Rubber)
		handle.CFrame *= CFrame.Angles(0, 0, math.rad(side * 12))
		local jaw = part(model, "Jaw", Vector3.new(0.45, 1.7, 0.34), origin * CFrame.new(side * 0.26, 1.1, 0), Color3.fromRGB(185, 190, 194))
		jaw.CFrame *= CFrame.Angles(0, 0, math.rad(-side * 12))
		weld(pivot, handle)
		weld(pivot, jaw)
	end
	return pivot
end

local function buildMeter(model: Model, origin: CFrame, accent: Color3): BasePart
	local body = part(model, "MeterBody", Vector3.new(2.0, 2.8, 0.75), origin, Color3.fromRGB(45, 50, 55), Enum.Material.SmoothPlastic)
	local screen = part(model, "MeterScreen", Vector3.new(1.45, 0.8, 0.1), origin * CFrame.new(0, 0.65, -0.43), Color3.fromRGB(30, 53, 57), Enum.Material.Glass)
	screen.Color = accent
	screen.Transparency = 0.15
	for _, x in { -0.45, 0.45 } do
		local jack = part(
			model,
			"ProbeJack",
			Vector3.new(0.28, 0.35, 0.35),
			origin * CFrame.new(x, -0.95, -0.42),
			if x < 0 then Color3.fromRGB(210, 67, 60) else Color3.fromRGB(35, 36, 38),
			Enum.Material.Metal
		)
		jack.Shape = Enum.PartType.Cylinder
		jack.Orientation = Vector3.new(0, 90, 0)
		weld(body, jack)
	end
	weld(body, screen)
	return body
end

local function buildDrainTool(model: Model, origin: CFrame, accent: Color3): BasePart
	local drum = part(model, "Drum", Vector3.new(1.5, 2.4, 2.4), origin, Color3.fromRGB(70, 75, 80), Enum.Material.Metal)
	drum.Shape = Enum.PartType.Cylinder
	drum.Orientation = Vector3.new(0, 90, 0)
	local hub = part(model, "Hub", Vector3.new(1.7, 0.55, 0.55), origin, accent, Enum.Material.Metal)
	hub.Shape = Enum.PartType.Cylinder
	hub.Orientation = Vector3.new(0, 90, 0)
	local grip = part(model, "Grip", Vector3.new(0.5, 2.4, 0.5), origin * CFrame.new(-1.75, -0.7, 0), accent, Enum.Material.Rubber)
	weld(drum, hub)
	weld(drum, grip)
	return drum
end

local function buildServiceKit(model: Model, origin: CFrame, accent: Color3): BasePart
	local body = part(model, "ServiceCase", Vector3.new(3.5, 2.4, 0.95), origin, Color3.fromRGB(43, 49, 55), Enum.Material.SmoothPlastic)
	local stripe = part(model, "CaseStripe", Vector3.new(3.55, 0.42, 1.0), origin * CFrame.new(0, -0.72, 0), accent, Enum.Material.SmoothPlastic)
	local grip = part(model, "CaseHandle", Vector3.new(1.5, 0.35, 0.45), origin * CFrame.new(0, 1.5, 0), Color3.fromRGB(92, 96, 100), Enum.Material.Metal)
	weld(body, stripe)
	weld(body, grip)
	return body
end

local function clearVisual(character: Model)
	local existing = character:FindFirstChild("RepairEmpireEquippedTool")
	if existing then
		existing:Destroy()
	end
end

local function rebuild(player: Player)
	local character = player.Character
	if not character then
		return
	end
	clearVisual(character)

	local toolId = player:GetAttribute("EquippedTool")
	if type(toolId) ~= "string" then
		return
	end
	local definition = ToolDefinitions.ById[toolId]
	if not definition then
		return
	end

	local hand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
	if not hand or not hand:IsA("BasePart") then
		return
	end

	local model = Instance.new("Model")
	model.Name = "RepairEmpireEquippedTool"
	model:SetAttribute("ToolId", toolId)
	model:SetAttribute("Tier", definition.Tier)
	model.Parent = character

	local accent = TIER_COLORS[math.clamp(definition.Tier, 1, 4)]
	local origin = hand.CFrame * CFrame.new(0, -1.3, -0.35) * CFrame.Angles(math.rad(-18), 0, math.rad(8))
	local root
	if definition.Family == "wrench" then
		root = buildWrench(model, origin, accent)
	elseif definition.Family == "screwdriver" then
		root = buildScrewdriver(model, origin, accent)
	elseif definition.Family == "pliers" then
		root = buildPliers(model, origin, accent)
	elseif definition.Family == "drain" then
		root = buildDrainTool(model, origin, accent)
	elseif definition.Family == "diagnostic_meter" then
		root = buildMeter(model, origin, accent)
	else
		root = buildServiceKit(model, origin, accent)
	end

	local handWeld = Instance.new("WeldConstraint")
	handWeld.Name = "HandWeld"
	handWeld.Part0 = hand
	handWeld.Part1 = root
	handWeld.Parent = root
end

local function bindPlayer(player: Player)
	local connections = {}
	table.insert(
		connections,
		player:GetAttributeChangedSignal("EquippedTool"):Connect(function()
			rebuild(player)
		end)
	)
	table.insert(
		connections,
		player.CharacterAdded:Connect(function()
			task.defer(function()
				rebuild(player)
			end)
		end)
	)
	ToolVisualService._connections[player] = connections
	task.defer(function()
		rebuild(player)
	end)
end

local function unbindPlayer(player: Player)
	local connections = ToolVisualService._connections[player]
	if connections then
		for _, connection in connections do
			connection:Disconnect()
		end
	end
	ToolVisualService._connections[player] = nil
end

function ToolVisualService:Init()
	Players.PlayerAdded:Connect(bindPlayer)
	Players.PlayerRemoving:Connect(unbindPlayer)
	for _, player in Players:GetPlayers() do
		bindPlayer(player)
	end
end

function ToolVisualService:Start() end

return ToolVisualService
