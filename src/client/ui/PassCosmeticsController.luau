--!strict

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UiPalette = require(ReplicatedStorage.RepairEmpire.Shared.ui.UiPalette)

local function color(rgb)
	return Color3.fromRGB(rgb[1], rgb[2], rgb[3])
end

local PassCosmeticsController = {}

local function premiumMarkerSize(): UDim2
	local camera = Workspace.CurrentCamera
	if camera ~= nil and math.min(camera.ViewportSize.X, camera.ViewportSize.Y) < 600 then
		return UDim2.fromOffset(112, 34)
	end
	return UDim2.fromOffset(180, 38)
end

local function updatePremiumMarkerLayout(marker: Instance)
	if not marker:IsA("BillboardGui") then
		return
	end
	marker.Size = premiumMarkerSize()
	local label = marker:FindFirstChild("Label")
	if label and label:IsA("TextLabel") then
		label.TextScaled = true
		local constraint = label:FindFirstChildOfClass("UITextSizeConstraint")
		if constraint == nil then
			constraint = Instance.new("UITextSizeConstraint")
			constraint.MinTextSize = 9
			constraint.MaxTextSize = 15
			constraint.Parent = label
		end
	end
end

local function applyVipBadge(player: Player)
	local playerGui = player:FindFirstChild("PlayerGui")
	if playerGui == nil then
		return
	end
	local hud = playerGui:FindFirstChild("RepairEmpireHUD")
	if hud == nil or not hud:IsA("ScreenGui") then
		return
	end

	local badge = hud:FindFirstChild("VIPBadge")
	if badge == nil then
		badge = Instance.new("TextLabel")
		badge.Name = "VIPBadge"
		badge.AnchorPoint = Vector2.new(1, 0)
		badge.Position = UDim2.new(1, -16, 0, 72)
		badge.Size = UDim2.fromOffset(72, 32)
		badge.BackgroundTransparency = 0.04
		badge.BackgroundColor3 = color(UiPalette.Hud)
		badge.TextColor3 = color(UiPalette.Gold)
		badge.BorderSizePixel = 0
		badge.Font = Enum.Font.GothamBold
		badge.TextSize = 15
		badge.Text = "VIP"
		badge.Visible = false
		badge.Parent = hud

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = badge
	end

	if badge:IsA("TextLabel") then
		badge.Visible = player:GetAttribute("HasVIP") == true
	end
end

local function applyPremiumWorkshop(player: Player)
	local world = Workspace:FindFirstChild("RepairEmpireWorld")
	local residential = world and world:FindFirstChild("residential")
	local workshop = residential and residential:FindFirstChild("PlayerWorkshop")
	if workshop == nil then
		return
	end

	local premium = player:GetAttribute("HasPremiumWorkshop") == true
	local building = workshop:FindFirstChild("WorkshopBuilding")
	local garageDoor = workshop:FindFirstChild("GarageDoor")

	if building and building:IsA("BasePart") then
		if premium then
			building.Material = Enum.Material.Metal
			building.Color = Color3.fromRGB(35, 46, 57)
		else
			building.Material = Enum.Material.Brick
			building.Color = Color3.fromRGB(144, 99, 73)
		end
	end

	if garageDoor and garageDoor:IsA("BasePart") then
		if premium then
			garageDoor.Material = Enum.Material.Metal
			garageDoor.Color = Color3.fromRGB(245, 151, 49)
		else
			garageDoor.Material = Enum.Material.Metal
			garageDoor.Color = Color3.fromRGB(95, 98, 105)
		end
	end

	local roof = workshop:FindFirstChild("WorkshopRoof")
	local awning = workshop:FindFirstChild("WorkshopAwning")
	if roof and roof:IsA("BasePart") then
		roof.Color = if premium then Color3.fromRGB(23, 29, 35) else Color3.fromRGB(61, 64, 70)
	end
	if awning and awning:IsA("BasePart") then
		awning.Color = if premium then Color3.fromRGB(245, 151, 49) else Color3.fromRGB(217, 126, 48)
	end

	local marker = workshop:FindFirstChild("PremiumMarker")
	if premium and marker == nil and building and building:IsA("BasePart") then
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "PremiumMarker"
		billboard.Adornee = building
		billboard.Size = premiumMarkerSize()
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 9, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = workshop

		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 0.04
		label.BackgroundColor3 = color(UiPalette.Hud)
		label.TextColor3 = color(UiPalette.Text)
		label.BorderSizePixel = 0
		label.Font = Enum.Font.GothamBold
		label.TextSize = 15
		label.TextScaled = true
		label.Text = "PREMIUM WORKSHOP"
		label.Parent = billboard
		local constraint = Instance.new("UITextSizeConstraint")
		constraint.MinTextSize = 9
		constraint.MaxTextSize = 15
		constraint.Parent = label
	elseif premium and marker then
		updatePremiumMarkerLayout(marker)
	elseif not premium and marker then
		marker:Destroy()
	end
end

local function apply(player: Player)
	applyVipBadge(player)
	applyPremiumWorkshop(player)
end

function PassCosmeticsController.Start()
	local player = Players.LocalPlayer

	player:GetAttributeChangedSignal("HasVIP"):Connect(function()
		applyVipBadge(player)
	end)
	player:GetAttributeChangedSignal("HasPremiumWorkshop"):Connect(function()
		applyPremiumWorkshop(player)
	end)

	local playerGui = player:WaitForChild("PlayerGui")
	playerGui.ChildAdded:Connect(function()
		task.defer(function()
			apply(player)
		end)
	end)

	local function bindCamera(camera: Camera?)
		if camera == nil then
			return
		end
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			local world = Workspace:FindFirstChild("RepairEmpireWorld")
			local residential = world and world:FindFirstChild("residential")
			local workshop = residential and residential:FindFirstChild("PlayerWorkshop")
			local marker = workshop and workshop:FindFirstChild("PremiumMarker")
			if marker then
				updatePremiumMarkerLayout(marker)
			end
		end)
	end
	bindCamera(Workspace.CurrentCamera)
	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		bindCamera(Workspace.CurrentCamera)
	end)

	Workspace.ChildAdded:Connect(function(child)
		if child.Name == "RepairEmpireWorld" then
			task.defer(function()
				applyPremiumWorkshop(player)
			end)
		end
	end)

	task.defer(function()
		apply(player)
	end)
end

return PassCosmeticsController
