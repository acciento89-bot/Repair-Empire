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

	local logo = Instance.new("Frame")
	logo.Name = "RepairEmpireLogo"
	logo.Position = UDim2.fromOffset(16, 10)
	logo.Size = UDim2.fromOffset(210, 72)
	logo.BackgroundTransparency = 1
	logo.Parent = screen

	local repairWord = Instance.new("TextLabel")
	repairWord.Name = "RepairWord"
	repairWord.Size = UDim2.fromOffset(150, 32)
	repairWord.BackgroundTransparency = 1
	repairWord.Font = Enum.Font.GothamBlack
	repairWord.Text = "REPAIR"
	repairWord.TextSize = 28
	repairWord.TextXAlignment = Enum.TextXAlignment.Left
	repairWord.TextColor3 = color(UiPalette.Accent)
	repairWord.TextStrokeColor3 = Color3.fromRGB(48, 34, 24)
	repairWord.TextStrokeTransparency = 0.42
	repairWord.Parent = logo

	local empireWord = Instance.new("TextLabel")
	empireWord.Name = "EmpireWord"
	empireWord.Position = UDim2.fromOffset(18, 26)
	empireWord.Size = UDim2.fromOffset(160, 34)
	empireWord.BackgroundTransparency = 1
	empireWord.Font = Enum.Font.GothamBlack
	empireWord.Text = "EMPIRE"
	empireWord.TextSize = 30
	empireWord.TextXAlignment = Enum.TextXAlignment.Left
	empireWord.TextColor3 = color(UiPalette.Text)
	empireWord.TextStrokeColor3 = color(UiPalette.Panel)
	empireWord.TextStrokeTransparency = 0.28
	empireWord.Parent = logo

	local logoTag = Instance.new("TextLabel")
	logoTag.Name = "Tagline"
	logoTag.Position = UDim2.fromOffset(2, 61)
	logoTag.Size = UDim2.fromOffset(208, 11)
	logoTag.BackgroundTransparency = 1
	logoTag.Font = Enum.Font.GothamBold
	logoTag.Text = "BUILD • REPAIR • GROW"
	logoTag.TextSize = 8
	logoTag.TextXAlignment = Enum.TextXAlignment.Left
	logoTag.TextColor3 = color(UiPalette.TextMuted)
	logoTag.Parent = logo

	local serviceProgress = Instance.new("Frame")
	serviceProgress.Name = "ServiceProgress"
	serviceProgress.AnchorPoint = Vector2.new(0.5, 0)
	serviceProgress.Position = UDim2.new(0.5, 0, 0, 14)
	serviceProgress.Size = UDim2.fromOffset(310, 52)
	serviceProgress.BackgroundColor3 = color(UiPalette.Hud)
	serviceProgress.BackgroundTransparency = 0.02
	serviceProgress.BorderSizePixel = 0
	serviceProgress.Parent = screen
	decoratePanel(serviceProgress)

	local progressText = Instance.new("TextLabel")
	progressText.Name = "ProgressText"
	progressText.Position = UDim2.fromOffset(10, 4)
	progressText.Size = UDim2.new(1, -20, 0, 24)
	progressText.BackgroundTransparency = 1
	progressText.Font = Enum.Font.GothamBold
	progressText.Text = "SERVICE LEVEL 1 / 100"
	progressText.TextSize = 11
	progressText.TextXAlignment = Enum.TextXAlignment.Center
	progressText.TextColor3 = color(UiPalette.Text)
	progressText.Parent = serviceProgress

	local progressTrack = Instance.new("Frame")
	progressTrack.Name = "ProgressTrack"
	progressTrack.Position = UDim2.fromOffset(12, 34)
	progressTrack.Size = UDim2.new(1, -24, 0, 10)
	progressTrack.BackgroundColor3 = color(UiPalette.ButtonDisabled)
	progressTrack.BorderSizePixel = 0
	progressTrack.ClipsDescendants = true
	progressTrack.Parent = serviceProgress
	local progressTrackCorner = Instance.new("UICorner")
	progressTrackCorner.CornerRadius = UDim.new(1, 0)
	progressTrackCorner.Parent = progressTrack

	local progressFill = Instance.new("Frame")
	progressFill.Name = "ProgressFill"
	progressFill.Size = UDim2.fromScale(0.01, 1)
	progressFill.BackgroundColor3 = color(UiPalette.Accent)
	progressFill.BorderSizePixel = 0
	progressFill.Parent = progressTrack
	local progressFillCorner = Instance.new("UICorner")
	progressFillCorner.CornerRadius = UDim.new(1, 0)
	progressFillCorner.Parent = progressFill

	local status = Instance.new("Frame")
	status.Name = "Status"
	status.Position = UDim2.fromOffset(16, 88)
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
	tutorial.Position = UDim2.fromOffset(16, 176)
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

	local conceptShowcase = Instance.new("Frame")
	conceptShowcase.Name = "ConceptShowcase"
	conceptShowcase.Size = UDim2.fromScale(1, 1)
	conceptShowcase.BackgroundTransparency = 1
	conceptShowcase.Visible = false
	conceptShowcase.Parent = screen

	local function gradient(panel: GuiObject, first: Color3, second: Color3, rotation: number?)
		local item = Instance.new("UIGradient")
		item.Rotation = rotation or 110
		item.Color = ColorSequence.new(first, second)
		item.Parent = panel
	end

	local function conceptLabel(
		parent: Instance,
		name: string,
		text: string,
		size: UDim2,
		position: UDim2,
		textSize: number,
		textColor: Color3,
		font: Enum.Font?
	): TextLabel
		local item = Instance.new("TextLabel")
		item.Name = name
		item.Size = size
		item.Position = position
		item.BackgroundTransparency = 1
		item.Font = font or Enum.Font.GothamMedium
		item.Text = text
		item.TextSize = textSize
		item.TextColor3 = textColor
		item.TextXAlignment = Enum.TextXAlignment.Left
		item.TextYAlignment = Enum.TextYAlignment.Center
		item.Parent = parent
		return item
	end

	local function conceptButton(parent: Instance, name: string, text: string, size: UDim2, position: UDim2, background: Color3): TextButton
		local item = Instance.new("TextButton")
		item.Name = name
		item.Size = size
		item.Position = position
		item.BackgroundColor3 = background
		item.BorderSizePixel = 0
		item.Font = Enum.Font.GothamBold
		item.Text = text
		item.TextSize = 10
		item.TextColor3 = color(UiPalette.TextOnAccent)
		item.Selectable = true
		item.AutoButtonColor = true
		item.Parent = parent
		local itemCorner = Instance.new("UICorner")
		itemCorner.CornerRadius = UDim.new(0, 9)
		itemCorner.Parent = item
		return item
	end

	local function openConceptTab(tab: string)
		local menu = playerGui:FindFirstChild("RepairEmpireMenu")
		local request = menu and menu:FindFirstChild("ConceptOpen")
		if request and request:IsA("BindableEvent") then
			request:Fire(tab)
		end
	end

	local conceptMetrics = Instance.new("Frame")
	conceptMetrics.Name = "ConceptMetrics"
	conceptMetrics.Position = UDim2.fromOffset(16, 88)
	conceptMetrics.Size = UDim2.fromOffset(360, 48)
	conceptMetrics.BackgroundColor3 = color(UiPalette.Hud)
	conceptMetrics.BackgroundTransparency = 0.02
	conceptMetrics.BorderSizePixel = 0
	conceptMetrics.Parent = conceptShowcase
	decoratePanel(conceptMetrics)
	gradient(conceptMetrics, color(UiPalette.SurfaceRaised), color(UiPalette.Hud))
	local conceptCash =
		conceptLabel(conceptMetrics, "Cash", "$0", UDim2.fromOffset(86, 34), UDim2.fromOffset(10, 7), 11, color(UiPalette.Text), Enum.Font.GothamBold)
	local conceptLevel =
		conceptLabel(conceptMetrics, "Level", "LV 1", UDim2.fromOffset(82, 34), UDim2.fromOffset(96, 7), 11, color(UiPalette.Accent), Enum.Font.GothamBold)
	local conceptCompany = conceptLabel(
		conceptMetrics,
		"Company",
		"COMPANY 1",
		UDim2.fromOffset(100, 34),
		UDim2.fromOffset(178, 7),
		10,
		Color3.fromRGB(88, 199, 219),
		Enum.Font.GothamBold
	)
	local conceptSkill =
		conceptLabel(conceptMetrics, "Skill", "SP 0", UDim2.fromOffset(66, 34), UDim2.fromOffset(284, 7), 10, color(UiPalette.Gold), Enum.Font.GothamBold)
	conceptSkill.TextXAlignment = Enum.TextXAlignment.Right

	local serviceHub = Instance.new("Frame")
	serviceHub.Name = "ServiceHubShowcase"
	serviceHub.AnchorPoint = Vector2.new(0, 1)
	serviceHub.Position = UDim2.new(0, 16, 1, -18)
	serviceHub.Size = UDim2.fromOffset(318, 212)
	serviceHub.BackgroundColor3 = color(UiPalette.Panel)
	serviceHub.BackgroundTransparency = 0.02
	serviceHub.BorderSizePixel = 0
	serviceHub.Parent = conceptShowcase
	decoratePanel(serviceHub)
	gradient(serviceHub, color(UiPalette.SurfaceRaised), color(UiPalette.Panel))
	conceptLabel(serviceHub, "Title", "SERVICE HUB", UDim2.fromOffset(180, 28), UDim2.fromOffset(15, 8), 17, color(UiPalette.Text), Enum.Font.GothamBlack)
	local hubHint =
		conceptLabel(serviceHub, "Hint", "QUICK ACCESS", UDim2.fromOffset(104, 20), UDim2.fromOffset(197, 11), 9, color(UiPalette.Gold), Enum.Font.GothamBold)
	hubHint.TextXAlignment = Enum.TextXAlignment.Right

	local hubItems = {
		{ Name = "JOBS", Tab = "Jobs", Accent = color(UiPalette.Accent), Icon = "!" },
		{ Name = "TOOLS", Tab = "Tools", Accent = Color3.fromRGB(88, 199, 219), Icon = "T" },
		{ Name = "FLEET", Tab = "Vehicles", Accent = color(UiPalette.Success), Icon = "V" },
	}
	for index, entry in hubItems do
		local card = Instance.new("Frame")
		card.Name = entry.Name .. "Card"
		card.Position = UDim2.fromOffset(14 + (index - 1) * 101, 44)
		card.Size = UDim2.fromOffset(91, 154)
		card.BackgroundColor3 = color(UiPalette.Surface)
		card.BorderSizePixel = 0
		card.Parent = serviceHub
		local cardCorner = Instance.new("UICorner")
		cardCorner.CornerRadius = UDim.new(0, 14)
		cardCorner.Parent = card
		local cardStroke = Instance.new("UIStroke")
		cardStroke.Color = entry.Accent
		cardStroke.Transparency = 0.35
		cardStroke.Thickness = 1.2
		cardStroke.Parent = card
		gradient(card, entry.Accent:Lerp(color(UiPalette.Surface), 0.76), color(UiPalette.Surface))

		local icon = Instance.new("Frame")
		icon.Name = "Icon"
		icon.Position = UDim2.fromOffset(9, 9)
		icon.Size = UDim2.fromOffset(73, 58)
		icon.BackgroundColor3 = color(UiPalette.Panel)
		icon.BorderSizePixel = 0
		icon.Parent = card
		local iconCorner = Instance.new("UICorner")
		iconCorner.CornerRadius = UDim.new(0, 11)
		iconCorner.Parent = icon
		local iconStroke = Instance.new("UIStroke")
		iconStroke.Color = entry.Accent
		iconStroke.Transparency = 0.15
		iconStroke.Thickness = 2
		iconStroke.Parent = icon
		local glyph = conceptLabel(icon, "Glyph", entry.Icon, UDim2.fromScale(1, 1), UDim2.new(), 24, entry.Accent, Enum.Font.GothamBlack)
		glyph.TextXAlignment = Enum.TextXAlignment.Center

		local title =
			conceptLabel(card, "CardTitle", entry.Name, UDim2.fromOffset(81, 26), UDim2.fromOffset(5, 72), 10, color(UiPalette.Text), Enum.Font.GothamBold)
		title.TextXAlignment = Enum.TextXAlignment.Center
		local sub = conceptLabel(
			card,
			"CardSub",
			if entry.Tab == "Jobs" then "SERVICE CALLS" elseif entry.Tab == "Tools" then "UPGRADES" else "GARAGE",
			UDim2.fromOffset(81, 18),
			UDim2.fromOffset(5, 98),
			8,
			color(UiPalette.TextMuted),
			Enum.Font.GothamBold
		)
		sub.TextXAlignment = Enum.TextXAlignment.Center
		local open = conceptButton(card, "Open", "OPEN", UDim2.fromOffset(71, 25), UDim2.fromOffset(10, 121), entry.Accent)
		open.Activated:Connect(function()
			openConceptTab(entry.Tab)
		end)
	end

	local rightColumn = Instance.new("Frame")
	rightColumn.Name = "ConceptRightColumn"
	rightColumn.AnchorPoint = Vector2.new(1, 0)
	rightColumn.Position = UDim2.new(1, -16, 0, 156)
	rightColumn.Size = UDim2.fromOffset(238, 372)
	rightColumn.BackgroundTransparency = 1
	rightColumn.Parent = conceptShowcase

	local conceptProgressCard = Instance.new("Frame")
	conceptProgressCard.Name = "ConceptProgressCard"
	conceptProgressCard.Size = UDim2.fromOffset(238, 88)
	conceptProgressCard.BackgroundColor3 = color(UiPalette.Panel)
	conceptProgressCard.BorderSizePixel = 0
	conceptProgressCard.Parent = rightColumn
	decoratePanel(conceptProgressCard)
	gradient(conceptProgressCard, color(UiPalette.SurfaceRaised), color(UiPalette.Panel))
	conceptLabel(
		conceptProgressCard,
		"Title",
		"SERVICE PROGRESS",
		UDim2.fromOffset(208, 20),
		UDim2.fromOffset(14, 7),
		13,
		color(UiPalette.Text),
		Enum.Font.GothamBlack
	)
	local conceptProgressText = conceptLabel(
		conceptProgressCard,
		"Progress",
		"LEVEL 1 / 100",
		UDim2.fromOffset(208, 18),
		UDim2.fromOffset(14, 29),
		9,
		color(UiPalette.TextMuted),
		Enum.Font.GothamBold
	)
	conceptProgressText.TextXAlignment = Enum.TextXAlignment.Center
	local conceptTrack = Instance.new("Frame")
	conceptTrack.Position = UDim2.fromOffset(14, 56)
	conceptTrack.Size = UDim2.fromOffset(210, 14)
	conceptTrack.BackgroundColor3 = color(UiPalette.ButtonDisabled)
	conceptTrack.BorderSizePixel = 0
	conceptTrack.ClipsDescendants = true
	conceptTrack.Parent = conceptProgressCard
	local conceptTrackCorner = Instance.new("UICorner")
	conceptTrackCorner.CornerRadius = UDim.new(1, 0)
	conceptTrackCorner.Parent = conceptTrack
	local conceptProgressFill = Instance.new("Frame")
	conceptProgressFill.Size = UDim2.fromScale(0.01, 1)
	conceptProgressFill.BackgroundColor3 = color(UiPalette.Accent)
	conceptProgressFill.BorderSizePixel = 0
	conceptProgressFill.Parent = conceptTrack
	local conceptFillCorner = Instance.new("UICorner")
	conceptFillCorner.CornerRadius = UDim.new(1, 0)
	conceptFillCorner.Parent = conceptProgressFill

	local conceptDailyRewards = Instance.new("Frame")
	conceptDailyRewards.Name = "ConceptDailyRewards"
	conceptDailyRewards.Position = UDim2.fromOffset(0, 98)
	conceptDailyRewards.Size = UDim2.fromOffset(238, 132)
	conceptDailyRewards.BackgroundColor3 = color(UiPalette.Panel)
	conceptDailyRewards.BorderSizePixel = 0
	conceptDailyRewards.Parent = rightColumn
	decoratePanel(conceptDailyRewards)
	gradient(conceptDailyRewards, color(UiPalette.SurfaceRaised), color(UiPalette.Panel))
	conceptLabel(
		conceptDailyRewards,
		"Title",
		"DAILY REWARDS",
		UDim2.fromOffset(208, 20),
		UDim2.fromOffset(14, 6),
		13,
		color(UiPalette.Text),
		Enum.Font.GothamBlack
	)
	local conceptDailyCaption = conceptLabel(
		conceptDailyRewards,
		"Caption",
		"OPEN DAILY TO CLAIM",
		UDim2.fromOffset(208, 16),
		UDim2.fromOffset(14, 27),
		8,
		color(UiPalette.TextMuted),
		Enum.Font.GothamBold
	)
	conceptDailyCaption.TextXAlignment = Enum.TextXAlignment.Center
	local dailyTiles = {}
	for index = 1, 5 do
		local tile = Instance.new("Frame")
		tile.Position = UDim2.fromOffset(10 + (index - 1) * 45, 49)
		tile.Size = UDim2.fromOffset(40, 69)
		tile.BackgroundColor3 = if index == 1 then Color3.fromRGB(43, 92, 72) else color(UiPalette.Surface)
		tile.BorderSizePixel = 0
		tile.Parent = conceptDailyRewards
		local tileCorner = Instance.new("UICorner")
		tileCorner.CornerRadius = UDim.new(0, 9)
		tileCorner.Parent = tile
		local day = conceptLabel(
			tile,
			"Day",
			("D%d"):format(index),
			UDim2.fromOffset(36, 14),
			UDim2.fromOffset(2, 4),
			8,
			color(UiPalette.TextMuted),
			Enum.Font.GothamBold
		)
		day.TextXAlignment = Enum.TextXAlignment.Center
		local reward = conceptLabel(
			tile,
			"Reward",
			if index == 1 then "✓" elseif index == 2 then "$" elseif index == 3 then "XP" elseif index == 4 then "CP" else "★",
			UDim2.fromOffset(36, 32),
			UDim2.fromOffset(2, 23),
			if index == 3 or index == 4 then 10 else 15,
			color(if index == 1 then UiPalette.Success else UiPalette.Gold),
			Enum.Font.GothamBlack
		)
		reward.TextXAlignment = Enum.TextXAlignment.Center
		table.insert(dailyTiles, tile)
	end
	local dailyOpen = conceptButton(conceptDailyRewards, "OpenDaily", "DAILY", UDim2.fromOffset(76, 22), UDim2.new(1, -84, 0, 6), color(UiPalette.Accent))
	dailyOpen.TextSize = 8
	dailyOpen.Activated:Connect(function()
		openConceptTab("Daily")
	end)

	local conceptVistaCard = Instance.new("Frame")
	conceptVistaCard.Name = "ConceptVistaCard"
	conceptVistaCard.Position = UDim2.fromOffset(0, 240)
	conceptVistaCard.Size = UDim2.fromOffset(238, 132)
	conceptVistaCard.BackgroundColor3 = color(UiPalette.Panel)
	conceptVistaCard.BorderSizePixel = 0
	conceptVistaCard.Parent = rightColumn
	decoratePanel(conceptVistaCard)
	gradient(conceptVistaCard, color(UiPalette.SurfaceRaised), color(UiPalette.Panel))
	conceptLabel(
		conceptVistaCard,
		"Title",
		"WORKSHOP PREVIEW",
		UDim2.fromOffset(208, 20),
		UDim2.fromOffset(14, 6),
		13,
		color(UiPalette.Text),
		Enum.Font.GothamBlack
	)
	local conceptViewport = Instance.new("ViewportFrame")
	conceptViewport.Name = "WorkshopPreview"
	conceptViewport.Position = UDim2.fromOffset(12, 31)
	conceptViewport.Size = UDim2.fromOffset(214, 89)
	conceptViewport.BackgroundColor3 = Color3.fromRGB(175, 215, 223)
	conceptViewport.BorderSizePixel = 0
	conceptViewport.Ambient = Color3.fromRGB(150, 165, 170)
	conceptViewport.LightColor = Color3.fromRGB(255, 224, 180)
	conceptViewport.LightDirection = Vector3.new(-1, -1, -0.4)
	conceptViewport.Parent = conceptVistaCard
	local viewportCorner = Instance.new("UICorner")
	viewportCorner.CornerRadius = UDim.new(0, 12)
	viewportCorner.Parent = conceptViewport
	local previewWorld = Instance.new("WorldModel")
	previewWorld.Parent = conceptViewport
	local previewCamera = Instance.new("Camera")
	previewCamera.CFrame = CFrame.lookAt(Vector3.new(13, 8, 15), Vector3.new(0, 1.6, 0))
	previewCamera.FieldOfView = 42
	previewCamera.Parent = conceptViewport
	conceptViewport.CurrentCamera = previewCamera
	local function previewPart(name: string, size: Vector3, position: Vector3, partColor: Color3, material: Enum.Material): Part
		local part = Instance.new("Part")
		part.Name = name
		part.Size = size
		part.Position = position
		part.Anchored = true
		part.CanCollide = false
		part.Color = partColor
		part.Material = material
		part.Parent = previewWorld
		return part
	end
	previewPart("Yard", Vector3.new(12, 0.4, 9), Vector3.new(0, 0, 0), Color3.fromRGB(117, 118, 112), Enum.Material.Concrete)
	previewPart("Workshop", Vector3.new(8, 4.8, 5), Vector3.new(-1, 2.5, -2), color(UiPalette.Panel), Enum.Material.Metal)
	previewPart("BayDoor", Vector3.new(4.2, 2.8, 0.25), Vector3.new(-1, 1.65, 0.58), color(UiPalette.Accent), Enum.Material.Metal)
	previewPart("VanBody", Vector3.new(4.0, 1.6, 2.0), Vector3.new(2.8, 1.0, 2.1), Color3.fromRGB(230, 235, 238), Enum.Material.Metal)
	previewPart("VanStripe", Vector3.new(4.05, 0.24, 2.04), Vector3.new(2.8, 1.1, 2.1), color(UiPalette.Accent), Enum.Material.Neon)

	task.spawn(function()
		if player:GetAttribute("RepairEmpireLoaded") ~= true then
			player:GetAttributeChangedSignal("RepairEmpireLoaded"):Wait()
		end
		if player:GetAttribute("RepairEmpireLoaded") ~= true then
			return
		end

		local remoteFolder = ReplicatedStorage:FindFirstChild("RepairEmpireRemotes")
		local request = remoteFolder and remoteFolder:FindFirstChild("RequestRetentionStatus")
		if not request or not request:IsA("RemoteFunction") then
			return
		end
		local ok, response = pcall(function()
			return request:InvokeServer()
		end)
		if not ok or type(response) ~= "table" or response.ok ~= true or type(response.login) ~= "table" then
			return
		end
		local login = response.login
		local streakValue = tonumber(login.Streak) or 0
		conceptDailyCaption.Text = if login.ClaimedToday == true
			then ("CLAIMED • STREAK %d"):format(streakValue)
			else ("DAY %d READY"):format(tonumber(login.PreviewStreak) or streakValue + 1)
		for index, tile in dailyTiles do
			tile.BackgroundColor3 = if index <= math.clamp(streakValue, 0, 5) then Color3.fromRGB(43, 92, 72) else color(UiPalette.Surface)
		end
	end)

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

		conceptShowcase.Visible = false
		logo.Visible = not phone
		serviceProgress.Visible = not phone
		status.Visible = true
		status.Position = UDim2.fromOffset(if phone then 12 else 16, if phone then 10 else 88)
		status.Size = UDim2.fromOffset(hudMetrics.StatusWidth, hudMetrics.StatusHeight)
		cashValue.Text = ("$%d"):format(player:GetAttribute("Cash") or 0)
		levelValue.Text = if xpNeeded == 0 then ("LV %d  ·  MAX"):format(level) else ("LV %d  ·  %s"):format(level, xpText)
		companyValue.Text = tostring(companyLevel)
		skillValue.Text = tostring(skillPoints)
		context.Text = ("%s  •  %s"):format(tool, nextDistrictText(level))
		xpFill.Size = UDim2.fromScale(if xpNeeded == 0 then 1 else math.clamp(xp / math.max(1, xpNeeded), 0, 1), 1)
		local serviceAlpha = math.clamp(level / ProgressionConfig.MaxPlayerLevel, 0, 1)
		progressText.Text = ("SERVICE LEVEL %d / %d"):format(level, ProgressionConfig.MaxPlayerLevel)
		progressFill.Size = UDim2.fromScale(serviceAlpha, 1)
		conceptCash.Text = ("$%d"):format(player:GetAttribute("Cash") or 0)
		conceptLevel.Text = ("LV %d"):format(level)
		conceptCompany.Text = ("COMPANY %d"):format(companyLevel)
		conceptSkill.Text = ("SP %d"):format(skillPoints)
		conceptProgressText.Text = ("LEVEL %d / %d"):format(level, ProgressionConfig.MaxPlayerLevel)
		conceptProgressFill.Size = UDim2.fromScale(serviceAlpha, 1)

		if phone then
			companyCard.Visible = false
			skillCard.Visible = false
			metricsRow.Position = UDim2.fromOffset(8, 5)
			metricsRow.Size = UDim2.new(1, -16, 0, 29)
			grid.FillDirectionMaxCells = 2
			grid.CellPadding = UDim2.fromOffset(5, 0)
			grid.CellSize = UDim2.new(0.5, -3, 1, 0)
			context.Position = UDim2.fromOffset(10, 36)
			context.Size = UDim2.new(1, -20, 0, 11)
			context.TextSize = 8
			xpTrack.Visible = false
			cashValue.TextSize = 11
			levelValue.TextSize = 11
		else
			companyCard.Visible = true
			skillCard.Visible = true
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

		if phone then
			tutorial.Position = UDim2.fromOffset(12, 72)
			tutorial.Size = UDim2.new(1, -24, 0, 48)
			objective.AnchorPoint = Vector2.new(0, 0.5)
			objective.Position = UDim2.new(0, 12, 0.5, 0)
			objective.Size = UDim2.fromOffset(248, 64)
		else
			tutorial.Position = UDim2.new(0.55, -190, 1, -158)
			tutorial.Size = UDim2.fromOffset(380, 48)
			objective.AnchorPoint = Vector2.new(0.5, 0.5)
			objective.Position = UDim2.new(0.55, 0, 1, -86)
			objective.Size = UDim2.fromOffset(360, 62)
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
