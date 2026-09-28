--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TutorialConfig = require(ReplicatedStorage.RepairEmpire.Shared.config.TutorialConfig)

local HudController = {
	_objectiveLabel = nil :: TextLabel?,
	_tutorialLabel = nil :: TextLabel?,
}

local function createLabel(parent: Instance, name: string, position: UDim2): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.AnchorPoint = Vector2.new(0, 0)
	label.Position = position
	label.Size = UDim2.fromOffset(180, 42)
	label.BackgroundTransparency = 0.18
	label.TextScaled = true
	label.Font = Enum.Font.GothamMedium
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Parent = parent
	return label
end

function HudController.SetObjective(text: string)
	if HudController._objectiveLabel then
		HudController._objectiveLabel.Text = text
	end
end

function HudController.Start()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local screen = Instance.new("ScreenGui")
	screen.Name = "RepairEmpireHUD"
	screen.ResetOnSpawn = false
	screen.IgnoreGuiInset = false
	screen.DisplayOrder = 10
	screen.Parent = playerGui

	local cash = createLabel(screen, "Cash", UDim2.fromOffset(16, 16))
	local level = createLabel(screen, "Level", UDim2.fromOffset(208, 16))

	local tutorial = Instance.new("TextLabel")
	tutorial.Name = "Tutorial"
	tutorial.Position = UDim2.fromOffset(16, 68)
	tutorial.Size = UDim2.fromOffset(360, 54)
	tutorial.BackgroundTransparency = 0.18
	tutorial.TextWrapped = true
	tutorial.TextScaled = true
	tutorial.Font = Enum.Font.GothamMedium
	tutorial.TextColor3 = Color3.new(1, 1, 1)
	tutorial.Parent = screen
	HudController._tutorialLabel = tutorial

	local objective = Instance.new("TextLabel")
	objective.Name = "Objective"
	objective.AnchorPoint = Vector2.new(0, 0.5)
	objective.Position = UDim2.new(0, 16, 0.5, 0)
	objective.Size = UDim2.fromOffset(280, 72)
	objective.BackgroundTransparency = 0.18
	objective.TextWrapped = true
	objective.TextScaled = true
	objective.Font = Enum.Font.GothamMedium
	objective.TextColor3 = Color3.new(1, 1, 1)
	objective.Text = "Choose a job"
	objective.Parent = screen
	HudController._objectiveLabel = objective

	local function refresh()
		cash.Text = ("$ %d"):format(player:GetAttribute("Cash") or 0)
		level.Text = ("Level %d"):format(player:GetAttribute("Level") or 1)

		local tutorialStep = player:GetAttribute("TutorialStep") or "first_job"
		local completed = player:GetAttribute("TutorialCompleted") == true
		tutorial.Visible = not completed
		tutorial.Text = if completed then "" else (TutorialConfig.Messages[tutorialStep] or "")
	end

	player:GetAttributeChangedSignal("Cash"):Connect(refresh)
	player:GetAttributeChangedSignal("Level"):Connect(refresh)
	player:GetAttributeChangedSignal("TutorialStep"):Connect(refresh)
	player:GetAttributeChangedSignal("TutorialCompleted"):Connect(refresh)
	refresh()
end

return HudController
