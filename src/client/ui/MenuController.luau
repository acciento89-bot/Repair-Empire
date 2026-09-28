--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage.RepairEmpire.Shared
local ToolDefinitions = require(Shared.tools.ToolDefinitions)
local VehicleDefinitions = require(Shared.vehicles.VehicleDefinitions)
local EmployeeDefinitions = require(Shared.company.EmployeeDefinitions)
local MonetizationConfig = require(Shared.config.MonetizationConfig)
local JobDefinitions = require(Shared.jobs.JobDefinitions)
local CoopContracts = require(Shared.coop.CoopContracts)
local SkillTreeConfig = require(Shared.progression.SkillTreeConfig)
local RetentionConfig = require(Shared.retention.RetentionConfig)
local UiFactory = require(script.Parent.UiFactory)
local MenuNavigation = require(Shared.ui.MenuNavigation)
local UiPalette = require(Shared.ui.UiPalette)

local function color(rgb)
	return Color3.fromRGB(rgb[1], rgb[2], rgb[3])
end

local MenuController = {
	_screen = nil :: ScreenGui?,
	_panel = nil :: Frame?,
	_content = nil :: Frame?,
	_openButton = nil :: TextButton?,
	_currentTab = "Jobs",
	_tabButtons = {} :: { [string]: TextButton },
}

local function remote(name: string): RemoteFunction
	local instance = ReplicatedStorage:WaitForChild("RepairEmpireRemotes"):WaitForChild(name)
	assert(instance:IsA("RemoteFunction"), name .. " must be a RemoteFunction")
	return instance
end

local function clear(parent: Instance)
	for _, child in parent:GetChildren() do
		if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
			child:Destroy()
		end
	end
end

local function getState()
	local result = remote("RequestPlayerState"):InvokeServer()
	if type(result) == "table" and result.ok then
		return result.state
	end
	return nil
end

local function robuxPrice(id: number?, infoType: Enum.InfoType, fallback: number): string
	if id == nil then
		return ("%d R$ hypothesis"):format(fallback)
	end

	local ok, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, id, infoType)
	if ok and type(info) == "table" and type(info.PriceInRobux) == "number" then
		return ("%d R$"):format(info.PriceInRobux)
	end
	return ("%d R$"):format(fallback)
end

local function pretty(id: string): string
	local words = string.split(id, "_")
	for index, word in words do
		words[index] = word:sub(1, 1):upper() .. word:sub(2)
	end
	return table.concat(words, " ")
end

local function formatDuration(totalSeconds: number): string
	local seconds = math.max(0, math.floor(totalSeconds))
	local minutes = math.floor(seconds / 60)
	local hours = math.floor(minutes / 60)
	minutes %= 60
	if hours > 0 then
		return ("%dh %02dm"):format(hours, minutes)
	end
	return ("%dm"):format(minutes)
end

local function renderJobs(content: Frame)
	local scroll = UiFactory.Scroll(content)
	local result = remote("RequestJobOffers"):InvokeServer()
	if type(result) ~= "table" or not result.ok then
		UiFactory.Label(scroll, "Jobs could not be loaded.")
		return
	end

	for order, offer in result.offers or {} do
		local job = offer.Job
		local text = ("%s • $%d • %d XP • Tier %d"):format(pretty(job.Id), job.BaseReward, job.XP, job.RequiredToolTier)
		local button = UiFactory.Button(scroll, text, order)
		button.Activated:Connect(function()
			local accepted = remote("AcceptJob"):InvokeServer(offer.OfferId)
			if type(accepted) == "table" and accepted.ok then
				MenuController.Close()
			else
				button.Text = "Cannot accept: " .. tostring(accepted and accepted.error or "unknown")
			end
		end)
	end
end

local function renderCoop(content: Frame)
	local scroll = UiFactory.Scroll(content)
	local discovery = remote("RequestCoopContracts"):InvokeServer()
	if type(discovery) ~= "table" or not discovery.ok then
		UiFactory.Label(scroll, "Co-op contracts could not be loaded.")
		return
	end

	if discovery.currentContractId ~= nil then
		local leave = UiFactory.Button(scroll, "Leave current co-op contract", 0)
		leave.Activated:Connect(function()
			local result = remote("LeaveCoopContract"):InvokeServer()
			if type(result) == "table" and result.ok then
				MenuController.Render("Co-op")
			else
				leave.Text = "Unable to leave contract"
			end
		end)
	end

	UiFactory.Label(scroll, "Start a large contract", 40).LayoutOrder = 1
	local order = 2
	for _, definition in JobDefinitions.List do
		if definition.Coop and CoopContracts[definition.Id] == true then
			local button = UiFactory.Button(
				scroll,
				("%s • Lv%d • Tier %d • $%d base"):format(
					pretty(definition.Id),
					definition.MinimumLevel,
					definition.RequiredToolTier,
					definition.BaseReward
				),
				order
			)
			button.Activated:Connect(function()
				local result = remote("CreateCoopContract"):InvokeServer(definition.Id)
				if type(result) == "table" and result.ok then
					MenuController.Close()
				else
					button.Text = "Unavailable: " .. tostring(result and result.error or "unknown")
				end
			end)
			order += 1
		end
	end

	UiFactory.Label(scroll, "Open contracts in this server", 40).LayoutOrder = order
	order += 1

	if #(discovery.contracts or {}) == 0 then
		local none = UiFactory.Label(scroll, "No open contracts right now.", 38)
		none.LayoutOrder = order
		return
	end

	for _, contract in discovery.contracts do
		local button = UiFactory.Button(
			scroll,
			("%s • %s • %d/%d players"):format(pretty(contract.Job.Id), contract.OwnerName, contract.Participants, contract.MaxParticipants),
			order
		)
		button.Activated:Connect(function()
			local result = remote("JoinCoopContract"):InvokeServer(contract.ContractId)
			if type(result) == "table" and result.ok then
				MenuController.Close()
			else
				button.Text = "Cannot join: " .. tostring(result and result.error or "unknown")
			end
		end)
		order += 1
	end
end

local function renderSkills(content: Frame)
	local state = getState()
	local scroll = UiFactory.Scroll(content)
	if state == nil then
		UiFactory.Label(scroll, "Player state unavailable.")
		return
	end

	UiFactory.Label(scroll, ("Available skill points: %d"):format(state.SkillPoints or 0), 40)

	local branchOrder = { "plumbing", "heating", "climate", "energy" }
	for order, branchId in branchOrder do
		local branch = SkillTreeConfig.Branches[branchId]
		local rank = state.Skills[branchId] or 0
		local speedBonus = rank * 2
		local cashBonus = rank
		local button = UiFactory.Button(
			scroll,
			("%s • Rank %d/%d • %d%% faster • +%d%% Cash/XP"):format(branch.DisplayName, rank, SkillTreeConfig.MaxRankPerBranch, speedBonus, cashBonus),
			order
		)
		button.Active = rank < SkillTreeConfig.MaxRankPerBranch and (state.SkillPoints or 0) > 0
		if button.Active then
			button.Text ..= " • Spend 1 point"
		elseif rank >= SkillTreeConfig.MaxRankPerBranch then
			button.Text ..= " • MAX"
		else
			button.Text ..= " • Next point every 5 levels"
		end
		button.Activated:Connect(function()
			if not button.Active then
				return
			end
			local result = remote("PurchaseSkill"):InvokeServer(branchId)
			if type(result) == "table" and result.ok then
				MenuController.Render("Skills")
			else
				button.Text = "Unavailable: " .. tostring(result and result.error or "unknown")
			end
		end)
	end
end

local function achievementProgress(state, definition): number
	if definition.Metric == "JobsCompleted" then
		return state.Stats and state.Stats.JobsCompleted or 0
	elseif definition.Metric == "Level" then
		return state.Level or 1
	elseif definition.Metric == "CompanyLevel" then
		return state.CompanyLevel or 1
	elseif definition.Metric == "PrestigeLevel" then
		return state.PrestigeLevel or 0
	end
	return 0
end

local function renderAchievements(content: Frame)
	local state = getState()
	local scroll = UiFactory.Scroll(content)
	if state == nil then
		UiFactory.Label(scroll, "Player state unavailable.")
		return
	end

	local ids = {}
	for achievementId in RetentionConfig.Achievements do
		table.insert(ids, achievementId)
	end
	table.sort(ids)

	for order, achievementId in ids do
		local definition = RetentionConfig.Achievements[achievementId]
		local status = state.Achievements[achievementId] or "locked"
		local progress = achievementProgress(state, definition)
		local button = UiFactory.Button(
			scroll,
			("%s • %d/%d • Reward $%d • %s"):format(
				pretty(achievementId),
				math.min(progress, definition.Threshold),
				definition.Threshold,
				definition.RewardCash,
				if status == "claimed" then "Claimed" else if status == "unlocked" then "Claim" else "Locked"
			),
			order
		)
		button.Active = status == "unlocked"
		button.Activated:Connect(function()
			if not button.Active then
				return
			end
			local result = remote("ClaimAchievement"):InvokeServer(achievementId)
			if type(result) == "table" and result.ok then
				MenuController.Render("Achievements")
			else
				button.Text = "Unavailable: " .. tostring(result and result.error or "unknown")
			end
		end)
	end
end

local function renderTools(content: Frame)
	local state = getState()
	local scroll = UiFactory.Scroll(content)
	if state == nil then
		UiFactory.Label(scroll, "Player state unavailable.")
		return
	end

	for order, definition in ToolDefinitions.List do
		local owned = state.OwnedTools[definition.Id] == true
		local equipped = state.EquippedTool == definition.Id
		local status = if equipped then "Equipped" elseif owned then "Equip" else ("Buy $%d"):format(definition.Cost)
		local button =
			UiFactory.Button(scroll, ("%s • T%d • Lv%d • %s"):format(pretty(definition.Id), definition.Tier, definition.MinimumLevel, status), order)
		button.Activated:Connect(function()
			local result
			if owned then
				result = remote("EquipTool"):InvokeServer(definition.Id)
			else
				result = remote("PurchaseTool"):InvokeServer(definition.Id)
			end
			if type(result) == "table" and result.ok then
				MenuController.Render("Tools")
			else
				button.Text = "Unavailable: " .. tostring(result and result.error or "unknown")
			end
		end)
	end
end

local function renderVehicles(content: Frame)
	local state = getState()
	local scroll = UiFactory.Scroll(content)
	if state == nil then
		UiFactory.Label(scroll, "Player state unavailable.")
		return
	end

	local spawn = UiFactory.Button(scroll, "Spawn selected vehicle", 0)
	spawn.Activated:Connect(function()
		remote("SpawnVehicle"):InvokeServer()
		MenuController.Close()
	end)

	for order, definition in VehicleDefinitions.List do
		local owned = state.OwnedVehicles[definition.Id] == true
		local selected = state.SelectedVehicle == definition.Id
		local status = if selected then "Selected" elseif owned then "Select" else ("Buy $%d"):format(definition.Cost)
		local button =
			UiFactory.Button(scroll, ("%s • T%d • Lv%d • %s"):format(pretty(definition.Id), definition.Tier, definition.MinimumLevel, status), order + 1)
		button.Activated:Connect(function()
			local result
			if owned then
				result = remote("SelectVehicle"):InvokeServer(definition.Id)
			else
				result = remote("PurchaseVehicle"):InvokeServer(definition.Id)
			end
			if type(result) == "table" and result.ok then
				MenuController.Render("Vehicles")
			else
				button.Text = "Unavailable: " .. tostring(result and result.error or "unknown")
			end
		end)
	end
end

local function renderWorkshop(content: Frame)
	remote("RecordFunnelEvent"):InvokeServer("company_system_opened")
	local state = getState()
	local scroll = UiFactory.Scroll(content)
	if state == nil then
		UiFactory.Label(scroll, "Player state unavailable.")
		return
	end

	UiFactory.Label(scroll, ("Workshop Tier %d • Company Level %d • Company Points %d"):format(state.WorkshopTier, state.CompanyLevel, state.CompanyPoints))

	local upgrade = UiFactory.Button(scroll, "Upgrade workshop", 1)
	upgrade.Activated:Connect(function()
		local result = remote("PurchaseUpgrade"):InvokeServer({ kind = "workshop" })
		if type(result) == "table" and result.ok then
			MenuController.Render("Workshop")
		else
			upgrade.Text = "Unavailable: " .. tostring(result and result.error or "unknown")
		end
	end)

	UiFactory.Label(scroll, "Workshop tiers increase employee capacity. Premium Workshop is cosmetic only and never gates progression.", 64).LayoutOrder = 2
end

local function renderEmployees(content: Frame)
	local state = getState()
	local scroll = UiFactory.Scroll(content)
	if state == nil then
		UiFactory.Label(scroll, "Player state unavailable.")
		return
	end

	UiFactory.Label(scroll, ("Company Level %d • Workshop Tier %d"):format(state.CompanyLevel, state.WorkshopTier))

	for order, definition in EmployeeDefinitions.List do
		local owned = state.Employees[definition.Id] or 0
		local button = UiFactory.Button(
			scroll,
			("%s • %s • %d/min • owned %d • Hire $%d"):format(
				pretty(definition.Id),
				pretty(definition.Role),
				definition.CashPerMinute,
				owned,
				definition.Cost
			),
			order + 1
		)
		button.Activated:Connect(function()
			local result = remote("HireEmployee"):InvokeServer(definition.Id)
			if type(result) == "table" and result.ok then
				MenuController.Render("Employees")
			else
				button.Text = "Unavailable: " .. tostring(result and result.error or "unknown")
			end
		end)
	end
end

local function renderDaily(content: Frame)
	local scroll = UiFactory.Scroll(content)
	local order = 0

	UiFactory.SectionTitle(scroll, "Daily login", order)
	order += 1

	local status = remote("RequestRetentionStatus"):InvokeServer()
	if type(status) ~= "table" or not status.ok then
		UiFactory.Label(scroll, "Retention status unavailable.", 42).LayoutOrder = order
		return
	end

	local login = status.login
	local loginText
	if login.ClaimedToday then
		loginText = ("CLAIMED TODAY • Streak %d"):format(login.Streak)
	else
		loginText = ("CLAIM $%d • Day %d streak"):format(login.Reward, login.PreviewStreak)
	end
	local claim = UiFactory.Button(scroll, loginText, order)
	claim.Active = not login.ClaimedToday
	order += 1
	claim.Activated:Connect(function()
		if not claim.Active then
			return
		end
		local result = remote("ClaimDailyReward"):InvokeServer()
		if type(result) == "table" and result.ok then
			MenuController.Render("Daily")
		else
			claim.Text = "Daily reward unavailable"
		end
	end)

	UiFactory.SectionTitle(scroll, "Daily jobs", order)
	order += 1
	local daily = remote("RequestDailyJobs"):InvokeServer()
	if type(daily) == "table" and daily.ok then
		local featured = UiFactory.Label(scroll, "Featured trade: " .. pretty(daily.featuredCategory), 34)
		featured.LayoutOrder = order
		featured.TextColor3 = color(UiPalette.Gold)
		order += 1

		for _, job in daily.jobs do
			local marker = if job.Completed then "COMPLETE" else "OPEN"
			local label =
				UiFactory.Label(scroll, ("%s • %s • +$%d • +%d CP"):format(pretty(job.Id), marker, job.RewardCash or 0, job.RewardCompanyPoints or 0), 42)
			label.LayoutOrder = order
			label.TextColor3 = color(if job.Completed then UiPalette.Success else UiPalette.Text)
			order += 1
		end
	end

	UiFactory.SectionTitle(scroll, "Online rewards", order)
	order += 1

	local played = UiFactory.Label(scroll, "Session + lifetime playtime: " .. formatDuration(status.playTimeSeconds or 0), 34)
	played.LayoutOrder = order
	played.TextColor3 = color(UiPalette.TextMuted)
	order += 1

	for _, reward in status.playtimeRewards or {} do
		local text
		if reward.Claimed then
			text = ("%s • $%d • CLAIMED"):format(formatDuration(reward.Seconds), reward.Cash)
		elseif reward.Ready then
			text = ("%s • $%d • CLAIM"):format(formatDuration(reward.Seconds), reward.Cash)
		else
			text = ("%s • $%d • ready in %s"):format(formatDuration(reward.Seconds), reward.Cash, formatDuration(reward.RemainingSeconds))
		end

		local button = UiFactory.Button(scroll, text, order)
		button.Active = reward.Ready == true
		if reward.Claimed then
			button.BackgroundColor3 = color(UiPalette.SurfaceRaised)
			button.TextColor3 = color(UiPalette.Success)
		elseif not reward.Ready then
			button.BackgroundColor3 = color(UiPalette.Surface)
			button.TextColor3 = color(UiPalette.TextMuted)
		end
		order += 1

		button.Activated:Connect(function()
			if not button.Active then
				return
			end
			local result = remote("ClaimPlaytimeReward"):InvokeServer(reward.Index)
			if type(result) == "table" and result.ok then
				MenuController.Render("Daily")
			else
				button.Text = "Reward unavailable"
			end
		end)
	end
end

local function renderShop(content: Frame)
	remote("RecordFunnelEvent"):InvokeServer("shop_opened")
	local scroll = UiFactory.Scroll(content)
	UiFactory.Label(scroll, "Game Passes", 38)

	local order = 1
	for key, config in MonetizationConfig.GamePasses do
		local configured = config.Id ~= nil
		local price = robuxPrice(config.Id, Enum.InfoType.GamePass, config.PriceRobux)
		local text = ("%s • %s • %s"):format(pretty(key), price, if configured then "Buy" else "Awaiting Roblox ID")
		local button = UiFactory.Button(scroll, text, order)
		button.Active = configured
		button.Activated:Connect(function()
			if configured then
				remote("PromptGamePass"):InvokeServer(key)
			end
		end)
		order += 1
	end

	UiFactory.Label(scroll, "Developer Products", 38).LayoutOrder = order
	order += 1
	for key, config in MonetizationConfig.DeveloperProducts do
		local configured = config.Id ~= nil
		local price = robuxPrice(config.Id, Enum.InfoType.Product, config.PriceRobux)
		local text = ("%s • %s • %s"):format(pretty(key), price, if configured then "Buy" else "Awaiting Roblox ID")
		local button = UiFactory.Button(scroll, text, order)
		button.Active = configured
		button.Activated:Connect(function()
			if configured then
				remote("PromptDeveloperProduct"):InvokeServer(key)
			end
		end)
		order += 1
	end
end

local function renderPrestige(content: Frame)
	local scroll = UiFactory.Scroll(content)
	local description = UiFactory.Label(
		scroll,
		"Prestige resets earned progression but keeps Cash, paid entitlements, consumables, boosts, achievements and lifetime stats.",
		84
	)
	description.TextWrapped = true

	local preview = UiFactory.Button(scroll, "Preview Prestige", 1)
	local confirmationToken = nil :: string?

	preview.Activated:Connect(function()
		if confirmationToken ~= nil then
			local confirmed = remote("RequestPrestige"):InvokeServer({
				action = "confirm",
				token = confirmationToken,
			})
			confirmationToken = nil
			if type(confirmed) == "table" and confirmed.ok then
				preview.Text = ("Prestige %d complete"):format(confirmed.prestigeLevel)
			else
				preview.Text = "Confirmation expired"
			end
			return
		end

		local result = remote("RequestPrestige"):InvokeServer({ action = "preview" })
		if type(result) ~= "table" or not result.ok then
			preview.Text = "Not eligible yet"
			return
		end

		confirmationToken = result.token
		preview.Text = ("Confirm Prestige %d → %d (x%.2f rewards)"):format(result.currentPrestige, result.nextPrestige, result.nextRewardMultiplier)
	end)
end

local renderers = {
	Jobs = renderJobs,
	["Co-op"] = renderCoop,
	Tools = renderTools,
	Skills = renderSkills,
	Achievements = renderAchievements,
	Vehicles = renderVehicles,
	Workshop = renderWorkshop,
	Employees = renderEmployees,
	Daily = renderDaily,
	Shop = renderShop,
	Prestige = renderPrestige,
}

local function refreshTabStyles()
	for id, button in MenuController._tabButtons do
		local selected = id == MenuController._currentTab
		button.BackgroundColor3 = color(if selected then UiPalette.Accent else UiPalette.SurfaceRaised)
		button.TextColor3 = color(if selected then UiPalette.TextOnAccent else UiPalette.TextMuted)
		button.Font = if selected then Enum.Font.GothamBold else Enum.Font.GothamMedium
		local stroke = button:FindFirstChildOfClass("UIStroke")
		if stroke then
			stroke.Color = color(if selected then UiPalette.Gold else UiPalette.Stroke)
			stroke.Transparency = if selected then 0.08 else 0.35
		end
	end
end

function MenuController.Render(tab: string)
	local content = MenuController._content
	if content == nil then
		return
	end
	clear(content)
	MenuController._currentTab = tab
	refreshTabStyles()
	local renderer = renderers[tab]
	if renderer then
		renderer(content)
	end
end

function MenuController.Open(selectForController: boolean?)
	local panel = MenuController._panel
	if panel == nil then
		return
	end
	panel.Visible = true
	MenuController.Render(MenuController._currentTab)
	if selectForController == true then
		GuiService.SelectedObject = MenuController._tabButtons[MenuController._currentTab]
	else
		GuiService.SelectedObject = nil
	end
end

function MenuController.Close()
	if MenuController._panel then
		MenuController._panel.Visible = false
	end
	GuiService.SelectedObject = nil
end

function MenuController.Start()
	local player = Players.LocalPlayer
	local screen = Instance.new("ScreenGui")
	screen.Name = "RepairEmpireMenu"
	screen.ResetOnSpawn = false
	screen.DisplayOrder = 30
	screen.Parent = player:WaitForChild("PlayerGui")
	MenuController._screen = screen

	local openButton = Instance.new("TextButton")
	openButton.Name = "OpenMenu"
	openButton.Position = UDim2.fromOffset(16, 68)
	openButton.Size = UDim2.fromOffset(132, 48)
	openButton.BackgroundColor3 = color(UiPalette.Accent)
	openButton.TextColor3 = color(UiPalette.TextOnAccent)
	openButton.BorderSizePixel = 0
	openButton.Font = Enum.Font.GothamBold
	openButton.TextSize = 16
	openButton.Text = "WORK TABLET"
	openButton.Selectable = true
	openButton.Parent = screen
	UiFactory.Round(openButton, 14)
	UiFactory.Stroke(openButton, UiPalette.Gold, 1.5, 0.08)
	MenuController._openButton = openButton

	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromScale(0.92, 0.86)
	panel.BackgroundTransparency = 0
	panel.BackgroundColor3 = color(UiPalette.Panel)
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.Parent = screen
	MenuController._panel = panel

	local size = Instance.new("UISizeConstraint")
	size.MinSize = Vector2.new(300, 360)
	size.MaxSize = Vector2.new(980, 760)
	size.Parent = panel

	UiFactory.Round(panel, 18)
	UiFactory.Stroke(panel, UiPalette.Stroke, 1.5, 0.1)

	local gradient = Instance.new("UIGradient")
	gradient.Rotation = 90
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color(UiPalette.Surface)),
		ColorSequenceKeypoint.new(1, color(UiPalette.Panel)),
	})
	gradient.Parent = panel

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Position = UDim2.fromOffset(18, 12)
	title.Size = UDim2.new(1, -120, 0, 28)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextSize = 22
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = color(UiPalette.Text)
	title.Text = "REPAIR EMPIRE"
	title.Parent = panel

	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.Position = UDim2.fromOffset(19, 39)
	subtitle.Size = UDim2.new(1, -130, 0, 20)
	subtitle.BackgroundTransparency = 1
	subtitle.Font = Enum.Font.GothamMedium
	subtitle.TextSize = 12
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.TextColor3 = color(UiPalette.TextMuted)
	subtitle.Text = "Jobs • Fleet • Workshop • Company"
	subtitle.Parent = panel

	local accentBar = Instance.new("Frame")
	accentBar.Name = "AccentBar"
	accentBar.Position = UDim2.fromOffset(18, 64)
	accentBar.Size = UDim2.new(1, -36, 0, 3)
	accentBar.BackgroundColor3 = color(UiPalette.Accent)
	accentBar.BorderSizePixel = 0
	accentBar.Parent = panel
	UiFactory.Round(accentBar, 2)

	local tabs = Instance.new("ScrollingFrame")
	tabs.Name = "Tabs"
	tabs.Size = UDim2.new(1, -16, 0, 54)
	tabs.Position = UDim2.fromOffset(8, 74)
	tabs.BackgroundTransparency = 1
	tabs.AutomaticCanvasSize = Enum.AutomaticSize.X
	tabs.CanvasSize = UDim2.new()
	tabs.ScrollBarThickness = 4
	tabs.ScrollingDirection = Enum.ScrollingDirection.X
	tabs.Parent = panel

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.Padding = UDim.new(0, 6)
	tabLayout.Parent = tabs

	for _, tab in MenuNavigation.Tabs do
		local button = Instance.new("TextButton")
		button.Name = tab.Id .. "Tab"
		button.Size = UDim2.fromOffset(116, 48)
		button.BackgroundColor3 = color(UiPalette.SurfaceRaised)
		button.TextColor3 = color(UiPalette.TextMuted)
		button.BorderSizePixel = 0
		button.Font = Enum.Font.GothamMedium
		button.TextSize = 14
		button.Text = tab.Label
		button.Selectable = true
		button.Parent = tabs
		UiFactory.Round(button, 10)
		UiFactory.Stroke(button, UiPalette.Stroke, 1, 0.35)
		MenuController._tabButtons[tab.Id] = button
		button.Activated:Connect(function()
			MenuController.Render(tab.Id)
		end)
	end

	local close = Instance.new("TextButton")
	close.Name = "Close"
	close.AnchorPoint = Vector2.new(1, 0)
	close.Position = UDim2.new(1, -16, 0, 14)
	close.Size = UDim2.fromOffset(82, 40)
	close.BackgroundColor3 = color(UiPalette.SurfaceRaised)
	close.TextColor3 = color(UiPalette.TextMuted)
	close.BorderSizePixel = 0
	close.Font = Enum.Font.GothamBold
	close.TextSize = 14
	close.Text = "CLOSE"
	close.Selectable = true
	close.Parent = panel
	UiFactory.Round(close, 10)
	UiFactory.Stroke(close, UiPalette.Stroke, 1, 0.3)

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Position = UDim2.fromOffset(12, 136)
	content.Size = UDim2.new(1, -24, 1, -148)
	content.BackgroundTransparency = 0
	content.BackgroundColor3 = color(UiPalette.Surface)
	content.BorderSizePixel = 0
	content.Parent = panel
	UiFactory.Round(content, 14)
	UiFactory.Stroke(content, UiPalette.Stroke, 1, 0.45)
	MenuController._content = content

	openButton.Activated:Connect(MenuController.Open)
	close.Activated:Connect(MenuController.Close)

	UserInputService.InputBegan:Connect(function(input, processed)
		if RunService:IsStudio() and input.UserInputType == Enum.UserInputType.Gamepad1 then
			print("[Repair Empire] StudioGamepadInput " .. tostring(input.KeyCode))
		end
		if processed then
			return
		end
		if input.KeyCode == Enum.KeyCode.M or input.KeyCode == Enum.KeyCode.ButtonY or input.KeyCode == Enum.KeyCode.ButtonStart then
			if panel.Visible then
				MenuController.Close()
			else
				MenuController.Open(true)
			end
		elseif
			panel.Visible
			and (
				input.KeyCode == Enum.KeyCode.Left
				or input.KeyCode == Enum.KeyCode.Right
				or input.KeyCode == Enum.KeyCode.DPadLeft
				or input.KeyCode == Enum.KeyCode.DPadRight
			)
		then
			local delta = if input.KeyCode == Enum.KeyCode.Left or input.KeyCode == Enum.KeyCode.DPadLeft then -1 else 1
			local nextTab = MenuNavigation.Move(MenuController._currentTab, delta)
			MenuController.Render(nextTab)
			GuiService.SelectedObject = MenuController._tabButtons[nextTab]
		elseif (input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB) and panel.Visible then
			MenuController.Close()
		end
	end)
end

return MenuController
