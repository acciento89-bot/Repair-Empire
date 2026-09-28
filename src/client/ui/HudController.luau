--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage.RepairEmpire.Shared
local TutorialConfig = require(Shared.config.TutorialConfig)
local ProgressionConfig = require(Shared.config.ProgressionConfig)
local UiLayoutRules = require(Shared.ui.UiLayoutRules)
local UiPalette = require(Shared.ui.UiPalette)

local function color(rgb)
	return Color3.fromRGB(rgb[1], rgb[2], rgb[3])
end

local HudController = {
	_objectiveLabel = nil :: TextLabel?,
	_tutorialLabel = nil :: TextLabel?,
}

local function decorateCard(label: TextLabel, accent: boolean?)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = label

	local stroke = Instance.new("UIStroke")
	stroke.Color = color(if accent then UiPalette.Accent else UiPalette.Stroke)
	stroke.Thickness = if accent then 1.5 else 1
	stroke.Transparency = if accent then 0.08 else 0.3
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = label

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 14)
	padding.PaddingRight = UDim.new(0, 14)
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 8)
	padding.Parent = label
end

local function pretty(id: string): string
	local words = string.split(id, "_")
	for index, word in words do
		words[index] = word:sub(1, 1):upper() .. word:sub(2)
	end
	return table.concat(words, " ")
end

local function nextDistrictText(level: number): string
	if level < ProgressionConfig.DistrictUnlockLevels.downtown then
		return ("Next Downtown Lv%d"):format(ProgressionConfig.DistrictUnlockLevels.downtown)
	end
	if level < ProgressionConfig.DistrictUnlockLevels.industrial then
		return ("Next Industrial Lv%d"):format(ProgressionConfig.DistrictUnlockLevels.industrial)
	end
	return "All districts unlocked"
end

function HudController.SetObjective(text: string)
	if HudController._objectiveLabel then
		HudController._objectiveLabel.Text = "CURRENT JOB\n" .. text
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

	local status = Instance.new("TextLabel")
	status.Name = "Status"
	status.Position = UDim2.fromOffset(16, 16)
	status.Size = UDim2.fromOffset(720, 42)
	status.BackgroundTransparency = 0
	status.BackgroundColor3 = color(UiPalette.Hud)
	status.BorderSizePixel = 0
	status.TextScaled = true
	status.TextWrapped = true
	status.Font = Enum.Font.GothamMedium
	status.TextXAlignment = Enum.TextXAlignment.Left
	status.TextColor3 = color(UiPalette.Text)
	status.Parent = screen
	decorateCard(status, false)

	local tutorial = Instance.new("TextLabel")
	tutorial.Name = "Tutorial"
	tutorial.Position = UDim2.fromOffset(16, 68)
	tutorial.Size = UDim2.fromOffset(360, 54)
	tutorial.BackgroundTransparency = 0
	tutorial.BackgroundColor3 = color(UiPalette.Surface)
	tutorial.BorderSizePixel = 0
	tutorial.TextWrapped = true
	tutorial.TextScaled = true
	tutorial.Font = Enum.Font.GothamMedium
	tutorial.TextColor3 = color(UiPalette.TextMuted)
	tutorial.Parent = screen
	decorateCard(tutorial, false)
	HudController._tutorialLabel = tutorial

	local objective = Instance.new("TextLabel")
	objective.Name = "Objective"
	objective.AnchorPoint = Vector2.new(0, 0.5)
	objective.Position = UDim2.new(0, 16, 0.5, 0)
	objective.Size = UDim2.fromOffset(280, 72)
	objective.BackgroundTransparency = 0
	objective.BackgroundColor3 = color(UiPalette.SurfaceRaised)
	objective.BorderSizePixel = 0
	objective.TextWrapped = true
	objective.TextScaled = true
	objective.Font = Enum.Font.GothamBold
	objective.TextXAlignment = Enum.TextXAlignment.Left
	objective.TextColor3 = color(UiPalette.Text)
	objective.Text = "CURRENT JOB\nChoose a job"
	objective.Parent = screen
	decorateCard(objective, true)
	HudController._objectiveLabel = objective

	local function refresh()
		local level = player:GetAttribute("Level") or 1
		local xp = player:GetAttribute("XP") or 0
		local xpNeeded = if level >= ProgressionConfig.MaxPlayerLevel then 0 else ProgressionConfig.XpForNextLevel(level)
		local xpText = if xpNeeded == 0 then "MAX" else ("%d/%d XP"):format(xp, xpNeeded)
		local companyLevel = player:GetAttribute("CompanyLevel") or 1
		local skillPoints = player:GetAttribute("SkillPoints") or 0
		local tool = pretty(player:GetAttribute("EquippedTool") or "basic_wrench")

		local camera = Workspace.CurrentCamera
		local viewport = if camera then camera.ViewportSize else Vector2.new(1280, 720)
		local layoutClass = UiLayoutRules.Classify(viewport.X, viewport.Y, UserInputService.TouchEnabled)
		if layoutClass == "small_phone" then
			status.Text = ("$%d • Lv%d %s • Co%d • SP%d\n%s • %s"):format(
				player:GetAttribute("Cash") or 0,
				level,
				xpText,
				companyLevel,
				skillPoints,
				tool,
				nextDistrictText(level)
			)
		else
			status.Text = ("$%d  •  Lv%d %s  •  Company %d  •  SP %d  •  %s  •  %s"):format(
				player:GetAttribute("Cash") or 0,
				level,
				xpText,
				companyLevel,
				skillPoints,
				tool,
				nextDistrictText(level)
			)
		end

		local tutorialStep = player:GetAttribute("TutorialStep") or "first_job"
		local completed = player:GetAttribute("TutorialCompleted") == true
		tutorial.Visible = not completed
		tutorial.Text = if completed then "" else (TutorialConfig.Messages[tutorialStep] or "")
	end

	for _, attribute in { "Cash", "Level", "XP", "CompanyLevel", "SkillPoints", "EquippedTool", "TutorialStep", "TutorialCompleted" } do
		player:GetAttributeChangedSignal(attribute):Connect(refresh)
	end

	local camera = Workspace.CurrentCamera
	if camera then
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(refresh)
	end
	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		task.defer(refresh)
	end)
	refresh()
end

return HudController
