--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UiPalette = require(ReplicatedStorage.RepairEmpire.Shared.ui.UiPalette)

local function color(rgb)
	return Color3.fromRGB(rgb[1], rgb[2], rgb[3])
end

local NavigationController = {
	_target = nil :: Vector3?,
	_connection = nil,
	_marker = nil :: BasePart?,
	_routeFolder = nil :: Folder?,
}

local ROUTE_ARROW_COUNT = 7
local ROUTE_MIN_DISTANCE = 8
local ROUTE_MAX_DISTANCE = 52

local function destroyMarker()
	local marker = NavigationController._marker
	if marker and marker.Parent then
		marker:Destroy()
	end
	NavigationController._marker = nil
end

local function destroyRoute()
	local folder = NavigationController._routeFolder
	if folder and folder.Parent then
		folder:Destroy()
	end
	NavigationController._routeFolder = nil
end

local function createMarker(position: Vector3)
	destroyMarker()

	local marker = Instance.new("Part")
	marker.Name = "RepairEmpireJobSiteMarker"
	marker.Size = Vector3.new(7, 0.2, 7)
	marker.CFrame = CFrame.new(position.X, math.max(0.15, position.Y - 1.35), position.Z)
	marker.Anchored = true
	marker.CanCollide = false
	marker.CanQuery = false
	marker.CanTouch = false
	marker.Material = Enum.Material.Neon
	marker.Color = color(UiPalette.Accent)
	marker.Transparency = 0.12
	marker.Parent = workspace

	local beam = Instance.new("Part")
	beam.Name = "JobSiteBeacon"
	beam.Size = Vector3.new(0.8, 18, 0.8)
	beam.CFrame = CFrame.new(marker.Position + Vector3.new(0, 9, 0))
	beam.Anchored = true
	beam.CanCollide = false
	beam.CanQuery = false
	beam.CanTouch = false
	beam.Material = Enum.Material.Neon
	beam.Color = color(UiPalette.Accent)
	beam.Transparency = 0.35
	beam.Parent = marker

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "JobSiteLabel"
	billboard.Adornee = marker
	billboard.Size = UDim2.fromOffset(210, 56)
	billboard.StudsOffset = Vector3.new(0, 5.5, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 500
	billboard.Parent = marker

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = color(UiPalette.Hud)
	label.BackgroundTransparency = 0.04
	label.BorderSizePixel = 0
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = color(UiPalette.Text)
	label.Text = "JOB SITE\nFOLLOW THE ARROWS"
	label.Parent = billboard

	local labelCorner = Instance.new("UICorner")
	labelCorner.CornerRadius = UDim.new(0, 10)
	labelCorner.Parent = label

	local stroke = Instance.new("UIStroke")
	stroke.Color = color(UiPalette.Accent)
	stroke.Thickness = 1.5
	stroke.Transparency = 0.08
	stroke.Parent = label

	NavigationController._marker = marker
end

local function createArrow(parent: Instance): Model
	local model = Instance.new("Model")
	model.Name = "RouteArrow"
	model.Parent = parent

	local shaft = Instance.new("Part")
	shaft.Name = "Shaft"
	shaft.Size = Vector3.new(1.4, 0.12, 3.2)
	shaft.Anchored = true
	shaft.CanCollide = false
	shaft.CanTouch = false
	shaft.CanQuery = false
	shaft.Material = Enum.Material.Neon
	shaft.Color = color(UiPalette.Accent)
	shaft.Transparency = 0.15
	shaft.Parent = model

	local head = Instance.new("WedgePart")
	head.Name = "Head"
	head.Size = Vector3.new(3.2, 0.12, 2.4)
	head.Anchored = true
	head.CanCollide = false
	head.CanTouch = false
	head.CanQuery = false
	head.Material = Enum.Material.Neon
	head.Color = color(UiPalette.Accent)
	head.Transparency = 0.05
	head.Parent = model

	model.PrimaryPart = shaft
	return model
end

local function ensureRouteFolder(): Folder
	local existing = NavigationController._routeFolder
	if existing and existing.Parent then
		return existing
	end
	local folder = Instance.new("Folder")
	folder.Name = "RepairEmpireNavigationRoute"
	folder.Parent = workspace
	NavigationController._routeFolder = folder
	for _ = 1, ROUTE_ARROW_COUNT do
		createArrow(folder)
	end
	return folder
end

local function updateRoute(rootPosition: Vector3, target: Vector3)
	local flatDelta = Vector3.new(target.X - rootPosition.X, 0, target.Z - rootPosition.Z)
	local distance = flatDelta.Magnitude
	if distance < ROUTE_MIN_DISTANCE then
		destroyRoute()
		return
	end

	local direction = flatDelta.Unit
	local folder = ensureRouteFolder()
	local visibleDistance = math.min(distance - 4, ROUTE_MAX_DISTANCE)
	local spacing = math.max(6, visibleDistance / ROUTE_ARROW_COUNT)

	local index = 0
	for _, model in folder:GetChildren() do
		if model:IsA("Model") and model.PrimaryPart then
			index += 1
			local routeDistance = math.min(visibleDistance, 5 + spacing * index)
			local position = rootPosition + direction * routeDistance
			local yaw = math.atan2(-direction.X, -direction.Z)
			local base = CFrame.new(position.X, math.max(0.62, target.Y - 0.8), position.Z) * CFrame.Angles(0, yaw, 0)
			local shaft = model:FindFirstChild("Shaft")
			local head = model:FindFirstChild("Head")
			if shaft and shaft:IsA("BasePart") and head and head:IsA("BasePart") then
				shaft.CFrame = base
				head.CFrame = base * CFrame.new(0, 0, -2.6) * CFrame.Angles(math.rad(90), 0, 0)
			end
		end
	end
end

function NavigationController.SetTarget(position: Vector3?)
	NavigationController._target = position
	if position then
		createMarker(position)
	else
		destroyMarker()
		destroyRoute()
	end
end

function NavigationController.Start()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local gui = Instance.new("ScreenGui")
	gui.Name = "RepairEmpireNavigation"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 11
	gui.Parent = playerGui

	local label = Instance.new("TextLabel")
	label.Name = "Distance"
	label.AnchorPoint = Vector2.new(0.5, 1)
	label.Position = UDim2.new(0.5, 0, 1, -28)
	label.Size = UDim2.fromOffset(260, 48)
	label.BackgroundTransparency = 0
	label.BackgroundColor3 = color(UiPalette.SurfaceRaised)
	label.BorderSizePixel = 0
	label.Font = Enum.Font.GothamMedium
	label.TextScaled = true
	label.TextColor3 = color(UiPalette.Text)
	label.Visible = false
	label.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = label

	local stroke = Instance.new("UIStroke")
	stroke.Color = color(UiPalette.Accent)
	stroke.Thickness = 1.5
	stroke.Transparency = 0.12
	stroke.Parent = label

	NavigationController._connection = RunService.RenderStepped:Connect(function()
		local target = NavigationController._target
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if target == nil or root == nil or not root:IsA("BasePart") then
			label.Visible = false
			destroyRoute()
			return
		end

		local distance = (root.Position - target).Magnitude
		label.Visible = true
		label.Text = ("FOLLOW ARROWS • %d studs"):format(math.floor(distance))
		updateRoute(root.Position, target)
	end)
end

return NavigationController