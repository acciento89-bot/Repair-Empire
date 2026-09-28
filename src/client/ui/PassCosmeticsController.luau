--!strict

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UiPalette = require(ReplicatedStorage.RepairEmpire.Shared.ui.UiPalette)

local function color(rgb)
	return Color3.fromRGB(rgb[1], rgb[2], rgb[3])
end

local PassCosmeticsController = {}

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
			building.Material = Enum.Material.SmoothPlastic
			building.Color = Color3.fromRGB(214, 176, 74)
		else
			building.Material = Enum.Material.Brick
			building.Color = Color3.fromRGB(163, 162, 165)
		end
	end

	if garageDoor and garageDoor:IsA("BasePart") then
		if premium then
			garageDoor.Material = Enum.Material.Metal
			garageDoor.Color = Color3.fromRGB(36, 36, 42)
		else
			garageDoor.Material = Enum.Material.Metal
			garageDoor.Color = Color3.fromRGB(163, 162, 165)
		end
	end

	local marker = workshop:FindFirstChild("PremiumMarker")
	if premium and marker == nil and building and building:IsA("BasePart") then
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "PremiumMarker"
		billboard.Adornee = building
		billboard.Size = UDim2.fromOffset(180, 38)
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 9, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = workshop

		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 0.04
		label.BackgroundColor3 = color(UiPalette.Hud)
		label.TextColor3 = color(UiPalette.Text)
		label.BorderSizePixel = 0
		label.Font = Enum.Font.GothamBold
		label.TextSize = 15
		label.Text = "PREMIUM WORKSHOP"
		label.Parent = billboard
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
