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
}

local function destroyMarker()
	local marker = NavigationController._marker
	if marker and marker.Parent then
		marker:Destroy()
	end
	NavigationController._marker = nil
end

local function createMarker(position: Vector3)
	destroyMarker()

	local marker = Instance.new("Part")
	marker.Name = "RepairEmpireJobSiteMarker"
	marker.Size = Vector3.new(6, 0.18, 6)
	marker.CFrame = CFrame.new(position.X, math.max(0.12, position.Y - 1.4), position.Z)
	marker.Anchored = true
	marker.CanCollide = false
	marker.CanQuery = false
	marker.CanTouch = false
	marker.Material = Enum.Material.Neon
	marker.Color = color(UiPalette.Accent)
	marker.Transparency = 0.2
	marker.Parent = workspace

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "JobSiteLabel"
	billboard.Adornee = marker
	billboard.Size = UDim2.fromOffset(180, 48)
	billboard.StudsOffset = Vector3.new(0, 4, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = marker

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = color(UiPalette.Hud)
	label.BackgroundTransparency = 0.08
	label.BorderSizePixel = 0
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = color(UiPalette.Text)
	label.Text = "JOB SITE"
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

function NavigationController.SetTarget(position: Vector3?)
	NavigationController._target = position
	if position then
		createMarker(position)
	else
		destroyMarker()
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
	label.Size = UDim2.fromOffset(220, 44)
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
			return
		end
		label.Visible = true
		label.Text = ("JOB SITE • %d studs"):format(math.floor((root.Position - target).Magnitude))
	end)
end

return NavigationController
