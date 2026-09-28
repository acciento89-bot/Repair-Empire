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
	UiFactory.SectionTitle(scroll, "Available service calls", 0)
	local result = remote("RequestJobOffers"):InvokeServer()
	if type(result) ~= "table" or not result.ok then
		UiFactory.Label(scroll, "Jobs could not be loaded.")
		return
	end

	for index, offer in result.offers or {} do
		local job = offer.Job
		local stepCount = job.StageCount or 0
		local text = ("%s\n%s • %s • %d steps • ~%ds • $%d • %d XP • Tool T%d"):format(
			pretty(job.Id),
			pretty(job.Category),
			pretty(job.District),
			stepCount,
			job.ExpectedDurationSeconds or 0,
			job.BaseReward,
			job.XP,
			job.RequiredToolTier
		)
		local button = UiFactory.Button(scroll, text, index + 1)
		button.Size = UDim2.new(1, 0, 0, 68)
		button.Font = Enum.Font.GothamMedium
		button.TextSize = 14
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

	UiFactory.SectionTitle(scroll, "Start a large contract", 1)
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

	UiFactory.SectionTitle(scroll, "Open contracts in this server", order)
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

	UiFactory.SectionTitle(scroll, "Skill Tree", 0)
	local skillSummary = UiFactory.Label(scroll, ("Available skill points: %d"):format(state.SkillPoints or 0), 40)
	skillSummary.LayoutOrder = 1
	skillSummary.TextColor3 = color(UiPalette.Gold)

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

	UiFactory.SectionTitle(scroll, "Achievements", 0)
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

	UiFactory.SectionTitle(scroll, "Tool locker", 0)
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

local VEHICLE_COLORS = {
	compact_van = Color3.fromRGB(188, 198, 207),
	service_van = Color3.fromRGB(73, 142, 188),
	long_van = Color3.fromRGB(66, 126, 167),
	premium_van = Color3.fromRGB(38, 48, 58),
	pickup = Color3.fromRGB(188, 119, 55),
	crew_van = Color3.fromRGB(55, 126, 92),
	truck = Color3.fromRGB(108, 112, 116),
	elite = Color3.fromRGB(25, 31, 38),
}

local function previewPart(parent: Instance, name: string, size: Vector3, position: Vector3, partColor: Color3): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.SmoothPlastic
	part.Color = partColor
	part.Parent = parent
	return part
end

local function createVehiclePreview(parent: Instance, definition, selected: boolean): ViewportFrame
	local viewport = Instance.new("ViewportFrame")
	viewport.Name = "VehiclePreview"
	viewport.Size = UDim2.fromOffset(150, 86)
	viewport.Position = UDim2.fromOffset(10, 10)
	viewport.BackgroundColor3 = color(UiPalette.Hud)
	viewport.BackgroundTransparency = 0
	viewport.BorderSizePixel = 0
	viewport.Ambient = Color3.fromRGB(190, 195, 205)
	viewport.LightColor = Color3.fromRGB(255, 244, 220)
	viewport.LightDirection = Vector3.new(-1, -1, -1)
	viewport.Parent = parent
	UiFactory.Round(viewport, 10)
	UiFactory.Stroke(viewport, if selected then UiPalette.Accent else UiPalette.Stroke, if selected then 1.5 else 1, 0.2)

	local model = Instance.new("Model")
	model.Name = "PreviewModel"
	model.Parent = viewport

	local width = definition.BodySize[1]
	local height = definition.BodySize[2]
	local length = definition.BodySize[3]
	local bodyColor = VEHICLE_COLORS[definition.Style] or Color3.fromRGB(120, 135, 150)

	local chassis = previewPart(model, "Chassis", Vector3.new(width, 0.8, length), Vector3.new(0, 0, 0), Color3.fromRGB(58, 62, 68))
	local cabinLength = math.max(4.2, length * 0.38)
	local cabinZ = -length / 2 + cabinLength / 2 + 0.4
	previewPart(model, "Cabin", Vector3.new(width * 0.92, height, cabinLength), Vector3.new(0, height / 2 + 0.4, cabinZ), bodyColor)

	local cargoLength = math.max(3.2, length - cabinLength - 1.0)
	local cargoHeight = if definition.Style == "pickup" then height * 0.45 else if definition.Style == "truck" then height * 1.15 else height * 0.9
	local cargoZ = length / 2 - cargoLength / 2 - 0.3
	previewPart(model, "Cargo", Vector3.new(width * 0.94, cargoHeight, cargoLength), Vector3.new(0, cargoHeight / 2 + 0.4, cargoZ), bodyColor)

	local windscreen = previewPart(
		model,
		"Windscreen",
		Vector3.new(width * 0.72, height * 0.45, 0.18),
		Vector3.new(0, height * 0.68, cabinZ - cabinLength / 2 - 0.1),
		Color3.fromRGB(91, 158, 188)
	)
	windscreen.Material = Enum.Material.Glass
	windscreen.Transparency = 0.15

	for axle = 1, definition.Axles do
		local alpha = if definition.Axles == 1 then 0.5 else (axle - 1) / (definition.Axles - 1)
		local z = -length * 0.36 + alpha * length * 0.72
		for _, side in { -1, 1 } do
			local wheel = previewPart(model, "Wheel", Vector3.new(1.0, 1.8, 1.8), Vector3.new(side * width * 0.52, -0.55, z), Color3.fromRGB(25, 27, 30))
			wheel.Shape = Enum.PartType.Cylinder
			wheel.Orientation = Vector3.new(0, 0, 90)
		end
	end

	model.PrimaryPart = chassis
	local camera = Instance.new("Camera")
	camera.CFrame = CFrame.new(Vector3.new(width * 1.6, height * 1.6 + 2, length * 1.25), Vector3.new(0, height * 0.45, 0))
	camera.FieldOfView = 35
	camera.Parent = viewport
	viewport.CurrentCamera = camera

	return viewport
end

local function createVehicleCard(scroll: ScrollingFrame, definition, owned: boolean, selected: boolean, order: number): TextButton
	local card = Instance.new("Frame")
	card.Name = definition.Id .. "Card"
	card.Size = UDim2.new(1, 0, 0, 106)
	card.BackgroundColor3 = color(if selected then UiPalette.AccentSoft else UiPalette.SurfaceRaised)
	card.BorderSizePixel = 0
	card.LayoutOrder = order
	card.Parent = scroll
	UiFactory.Round(card, 14)
	UiFactory.Stroke(card, if selected then UiPalette.Accent else UiPalette.Stroke, if selected then 1.5 else 1, 0.22)

	createVehiclePreview(card, definition, selected)

	local action = Instance.new("TextButton")
	action.Name = definition.Id .. "Action"
	action.Position = UDim2.fromOffset(170, 10)
	action.Size = UDim2.new(1, -180, 1, -20)
	action.BackgroundTransparency = 1
	action.TextXAlignment = Enum.TextXAlignment.Left
	action.TextYAlignment = Enum.TextYAlignment.Center
	action.TextWrapped = true
	action.Font = Enum.Font.GothamMedium
	action.TextSize = 14
	action.TextColor3 = color(UiPalette.Text)
	action.Selectable = true
	action:SetAttribute("ResponsiveSkipSize", true)
	local status = if selected then "SELECTED" elseif owned then "SELECT" else ("BUY $%d"):format(definition.Cost)
	action.Text = ("%s\nTier %d • Lv%d • Speed %d • %d seats • %s"):format(
		pretty(definition.Id),
		definition.Tier,
		definition.MinimumLevel,
		definition.Speed,
		definition.Seats,
		status
	)
	action.Parent = card
	return action
end

local function renderVehicles(content: Frame)
	local state = getState()
	local scroll = UiFactory.Scroll(content)
	if state == nil then
		UiFactory.Label(scroll, "Player state unavailable.")
		return
	end

	UiFactory.SectionTitle(scroll, "Company garage", 0)
	local selectedDefinition = VehicleDefinitions.ById[state.SelectedVehicle]
	local spawn = UiFactory.Button(scroll, ("SPAWN %s"):format(if selectedDefinition then pretty(selectedDefinition.Id) else "SELECTED VEHICLE"), 1)
	spawn.BackgroundColor3 = color(UiPalette.Accent)
	spawn.TextColor3 = color(UiPalette.TextOnAccent)
	spawn.Activated:Connect(function()
		local result = remote("SpawnVehicle"):InvokeServer()
		if type(result) == "table" and result.ok then
			MenuController.Close()
		else
			spawn.Text = "Vehicle spawn unavailable"
		end
	end)

	local despawn = UiFactory.Button(scroll, "DESPAWN ACTIVE VEHICLES", 2)
	despawn.BackgroundColor3 = color(UiPalette.SurfaceRaised)
	despawn.TextColor3 = color(UiPalette.TextMuted)
	despawn.Activated:Connect(function()
		local result = remote("DespawnVehicle"):InvokeServer()
		if type(result) == "table" and result.ok then
			despawn.Text = ("DESPAWNED %d"):format(result.removed or 0)
		else
			despawn.Text = "Vehicle despawn unavailable"
		end
	end)

	for index, definition in VehicleDefinitions.List do
		local owned = state.OwnedVehicles[definition.Id] == true
		local selected = state.SelectedVehicle == definition.Id
		local button = createVehicleCard(scroll, definition, owned, selected, index + 2)
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

	UiFactory.SectionTitle(scroll, "Workshop", 0)
	local summary = UiFactory.Label(
		scroll,
		("Workshop Tier %d • Company Level %d • Company Points %d"):format(state.WorkshopTier, state.CompanyLevel, state.CompanyPoints),
		44
	)
	summary.LayoutOrder = 1
	summary.TextColor3 = color(UiPalette.Gold)

	local upgrade = UiFactory.Button(scroll, "UPGRADE WORKSHOP", 2)
	upgrade.BackgroundColor3 = color(UiPalette.Accent)
	upgrade.TextColor3 = color(UiPalette.TextOnAccent)
	upgrade.Activated:Connect(function()
		local result = remote("PurchaseUpgrade"):InvokeServer({ kind = "workshop" })
		if type(result) == "table" and result.ok then
			MenuController.Render("Workshop")
		else
			upgrade.Text = "Unavailable: " .. tostring(result and result.error or "unknown")
		end
	end)

	local note = UiFactory.Label(scroll, "Workshop tiers increase employee capacity. Premium Workshop is cosmetic only and never gates progression.", 64)
	note.LayoutOrder = 3
	note.TextColor3 = color(UiPalette.TextMuted)
end

local function renderEmployees(content: Frame)
	local state = getState()
	local scroll = UiFactory.Scroll(content)
	if state == nil then
		UiFactory.Label(scroll, "Player state unavailable.")
		return
	end

	UiFactory.SectionTitle(scroll, "Employees", 0)
	local employeeSummary = UiFactory.Label(scroll, ("Company Level %d • Workshop Tier %d"):format(state.CompanyLevel, state.WorkshopTier), 40)
	employeeSummary.LayoutOrder = 1
	employeeSummary.TextColor3 = color(UiPalette.Gold)

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

	local played = UiFactory.Label(scroll, "Today online: " .. formatDuration(status.playTimeSeconds or 0), 34)
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
	UiFactory.SectionTitle(scroll, "Game Passes", 0)

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

	UiFactory.SectionTitle(scroll, "Developer Products", order)
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
	UiFactory.SectionTitle(scroll, "Prestige", 0)
	local description = UiFactory.Label(
		scroll,
		"Prestige resets earned progression but keeps Cash, paid entitlements, consumables, boosts, achievements and lifetime stats.",
		84
	)
	description.TextWrapped = true
	description.LayoutOrder = 1
	description.TextColor3 = color(UiPalette.TextMuted)

	local preview = UiFactory.Button(scroll, "PREVIEW PRESTIGE", 2)
	preview.BackgroundColor3 = color(UiPalette.Accent)
	preview.TextColor3 = color(UiPalette.TextOnAccent)
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
