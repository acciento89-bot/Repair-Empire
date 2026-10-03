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

local MOBILE_TUTORIAL_MESSAGES = {
	first_job = "Open Jobs and accept your first repair.",
	first_repair = "Follow the arrows to the job site.",
	first_reward = "Job complete — cash and XP are added automatically.",
	first_upgrade = "Open Tools and buy the Basic Screwdriver.",
	second_job = "Take the next job and follow the route.",
	second_repair = "Reach the marker and finish each repair step.",
	company_intro = "Open Company to view workshop progression.",
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

local function decoratePanel(frame: Frame)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = color(UiPalette.Stroke)
	stroke.Thickness = 1
	stroke.Transparency = 0.22
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = frame
end

local function makeMetric(parent: Instance, name: string, titleText: string): (Frame, TextLabel)
	local card = Instance.new("Frame")
	card.Name = name
	card.BackgroundColor3 = color(UiPalette.Surface)
	card.BackgroundTransparency = 0
	card.BorderSizePixel = 0
	card.Parent = parent
	decoratePanel(card)

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Position = UDim2.fromOffset(10, 5)
	title.Size = UDim2.new(1, -20, 0, 12)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextSize = 10
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = color(UiPalette.TextMuted)
	title.Text = titleText
	title.Parent = card

	local value = Instance.new("TextLabel")
	value.Name = "Value"
	value.Position = UDim2.fromOffset(10, 17)
	value.Size = UDim2.new(1, -20, 1, -20)
	value.BackgroundTransparency = 1
	value.Font = Enum.Font.GothamBold
	value.TextSize = 15
	value.TextXAlignment = Enum.TextXAlignment.Left
	value.TextColor3 = color(UiPalette.Text)
	value.Text = "—"
	value.Parent = card
	return card, value
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

	local status = Instance.new("Frame")
	status.Name = "Status"
	status.Position = UDim2.fromOffset(16, 16)
	status.Size = UDim2.fromOffset(720, 78)
	status.BackgroundTransparency = 0
	status.BackgroundColor3 = color(UiPalette.Hud)
	status.BorderSizePixel = 0
	status.Parent = screen
	decoratePanel(status)

	local accent = Instance.new("Frame")
	accent.Name = "Accent"
	accent.Position = UDim2.fromOffset(0, 12)
	accent.Size = UDim2.fromOffset(4, 54)
	accent.BackgroundColor3 = color(UiPalette.Accent)
	accent.BorderSizePixel = 0
	accent.Parent = status
	local accentCorner = Instance.new("UICorner")
	accentCorner.CornerRadius = UDim.new(1, 0)
	accentCorner.Parent = accent

	local metricsRow = Instance.new("Frame")
	metricsRow.Name = "Metrics"
	metricsRow.Position = UDim2.fromOffset(12, 8)
	metricsRow.Size = UDim2.new(1, -24, 0, 42)
	metricsRow.BackgroundTransparency = 1
	metricsRow.Parent = status

	local grid = Instance.new("UIGridLayout")
	grid.Name = "MetricGrid"
	grid.FillDirection = Enum.FillDirection.Horizontal
	grid.FillDirectionMaxCells = 4
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.CellPadding = UDim2.fromOffset(6, 0)
	grid.CellSize = UDim2.new(0.25, -5, 1, 0)
	grid.Parent = metricsRow

	local cashCard, cashValue = makeMetric(metricsRow, "Cash", "CASH")
	cashCard.LayoutOrder = 1
	local levelCard, levelValue = makeMetric(metricsRow, "Level", "LEVEL / XP")
	levelCard.LayoutOrder = 2
	local companyCard, companyValue = makeMetric(metricsRow, "Company", "COMPANY")
	companyCard.LayoutOrder = 3
	local skillCard, skillValue = makeMetric(metricsRow, "SkillPoints", "SKILL PTS")
	skillCard.LayoutOrder = 4

	local xpTrack = Instance.new("Frame")
	xpTrack.Name = "XpTrack"
	xpTrack.Position = UDim2.new(0, 10, 1, -7)
	xpTrack.Size = UDim2.new(1, -20, 0, 3)
	xpTrack.BackgroundColor3 = color(UiPalette.ButtonDisabled)
	xpTrack.BorderSizePixel = 0
	xpTrack.Parent = levelCard
	local xpTrackCorner = Instance.new("UICorner")
	xpTrackCorner.CornerRadius = UDim.new(1, 0)
	xpTrackCorner.Parent = xpTrack

	local xpFill = Instance.new("Frame")
	xpFill.Name = "Fill"
	xpFill.Size = UDim2.fromScale(0, 1)
	xpFill.BackgroundColor3 = color(UiPalette.Accent)
	xpFill.BorderSizePixel = 0
	xpFill.Parent = xpTrack
	local xpFillCorner = Instance.new("UICorner")
	xpFillCorner.CornerRadius = UDim.new(1, 0)
	xpFillCorner.Parent = xpFill

	local context = Instance.new("TextLabel")
	context.Name = "Context"
	context.Position = UDim2.fromOffset(16, 54)
	context.Size = UDim2.new(1, -32, 0, 18)
	context.BackgroundTransparency = 1
	context.Font = Enum.Font.GothamMedium
	context.TextSize = 11
	context.TextXAlignment = Enum.TextXAlignment.Left
	context.TextColor3 = color(UiPalette.TextMuted)
	context.Text = "Basic Wrench"
	context.Parent = status

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
		local hudMetrics = UiLayoutRules.GetHudMetrics(viewport.X, viewport.Y, UserInputService.TouchEnabled)
		local phone = hudMetrics.Class == "small_phone"

		status.Position = UDim2.fromOffset(if phone then 12 else 16, if phone then 10 else 16)
		status.Size = UDim2.fromOffset(hudMetrics.StatusWidth, hudMetrics.StatusHeight)
		cashValue.Text = ("$%d"):format(player:GetAttribute("Cash") or 0)
		levelValue.Text = if xpNeeded == 0 then ("LV %d  ·  MAX"):format(level) else ("LV %d  ·  %s"):format(level, xpText)
		companyValue.Text = tostring(companyLevel)
		skillValue.Text = tostring(skillPoints)
		context.Text = ("%s  •  %s"):format(tool, nextDistrictText(level))
		xpFill.Size = UDim2.fromScale(if xpNeeded == 0 then 1 else math.clamp(xp / math.max(1, xpNeeded), 0, 1), 1)

		if phone then
			metricsRow.Position = UDim2.fromOffset(8, 6)
			metricsRow.Size = UDim2.new(1, -16, 0, 32)
			grid.FillDirectionMaxCells = 4
			grid.CellPadding = UDim2.fromOffset(4, 0)
			grid.CellSize = UDim2.new(0.25, -3, 1, 0)
			context.Position = UDim2.fromOffset(12, 40)
			context.Size = UDim2.new(1, -24, 0, 14)
			context.TextSize = 9
			xpTrack.Visible = false
			for _, value in { cashValue, levelValue, companyValue, skillValue } do
				value.TextSize = 12
			end
		else
			metricsRow.Position = UDim2.fromOffset(12, 8)
			metricsRow.Size = UDim2.new(1, -24, 0, 42)
			grid.FillDirectionMaxCells = 4
			grid.CellPadding = UDim2.fromOffset(6, 0)
			grid.CellSize = UDim2.new(0.25, -5, 1, 0)
			context.Position = UDim2.fromOffset(16, 54)
			context.Size = UDim2.new(1, -32, 0, 18)
			context.TextSize = 11
			xpTrack.Visible = true
		end

		local tutorialStep = player:GetAttribute("TutorialStep") or "first_job"
		local completed = player:GetAttribute("TutorialCompleted") == true
		tutorial.Visible = not completed
		tutorial.Text = if completed
			then ""
			else if phone then (MOBILE_TUTORIAL_MESSAGES[tutorialStep] or "") else (TutorialConfig.Messages[tutorialStep] or "")
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
