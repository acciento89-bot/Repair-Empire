--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local Shared = ReplicatedStorage.RepairEmpire.Shared
local ToolDefinitions = require(Shared.tools.ToolDefinitions)
local VehicleDefinitions = require(Shared.vehicles.VehicleDefinitions)
local EmployeeDefinitions = require(Shared.company.EmployeeDefinitions)
local MonetizationConfig = require(Shared.config.MonetizationConfig)
local JobDefinitions = require(Shared.jobs.JobDefinitions)
local CoopContracts = require(Shared.coop.CoopContracts)
local UiFactory = require(script.Parent.UiFactory)

local MenuController = {
	_screen = nil :: ScreenGui?,
	_panel = nil :: Frame?,
	_content = nil :: Frame?,
	_openButton = nil :: TextButton?,
	_currentTab = "Jobs",
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

local function pretty(id: string): string
	local words = string.split(id, "_")
	for index, word in words do
		words[index] = word:sub(1, 1):upper() .. word:sub(2)
	end
	return table.concat(words, " ")
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
			("%s • %s • %d/%d players"):format(
				pretty(contract.Job.Id),
				contract.OwnerName,
				contract.Participants,
				contract.MaxParticipants
			),
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

local function renderCompany(content: Frame)
	remote("RecordFunnelEvent"):InvokeServer("company_system_opened")
	local state = getState()
	local scroll = UiFactory.Scroll(content)
	if state == nil then
		UiFactory.Label(scroll, "Player state unavailable.")
		return
	end

	UiFactory.Label(scroll, ("Workshop Tier %d • Company Level %d"):format(state.WorkshopTier, state.CompanyLevel))
	local upgrade = UiFactory.Button(scroll, "Upgrade workshop", 1)
	upgrade.Activated:Connect(function()
		local result = remote("PurchaseUpgrade"):InvokeServer({ kind = "workshop" })
		if type(result) == "table" and result.ok then
			MenuController.Render("Company")
		else
			upgrade.Text = "Unavailable: " .. tostring(result and result.error or "unknown")
		end
	end)

	for order, definition in EmployeeDefinitions.List do
		local owned = state.Employees[definition.Id] or 0
		local button = UiFactory.Button(
			scroll,
			("%s • %d/min • owned %d • Hire $%d"):format(pretty(definition.Id), definition.CashPerMinute, owned, definition.Cost),
			order + 1
		)
		button.Activated:Connect(function()
			local result = remote("HireEmployee"):InvokeServer(definition.Id)
			if type(result) == "table" and result.ok then
				MenuController.Render("Company")
			else
				button.Text = "Unavailable: " .. tostring(result and result.error or "unknown")
			end
		end)
	end
end

local function renderDaily(content: Frame)
	local scroll = UiFactory.Scroll(content)
	local claim = UiFactory.Button(scroll, "Claim daily login reward", 0)
	claim.Activated:Connect(function()
		local result = remote("ClaimDailyReward"):InvokeServer()
		if type(result) == "table" and result.ok then
			claim.Text = ("Claimed $%d • streak %d"):format(result.reward, result.streak)
		else
			claim.Text = "Already claimed or unavailable"
		end
	end)

	local result = remote("RequestDailyJobs"):InvokeServer()
	if type(result) == "table" and result.ok then
		UiFactory.Label(scroll, "Featured: " .. pretty(result.featuredCategory), 38)
		for index, job in result.jobs do
			local marker = if job.Completed then "Completed" else "Open"
			UiFactory.Label(scroll, ("%s • %s"):format(pretty(job.Id), marker), 38).LayoutOrder = index + 2
		end
	end
end

local function renderShop(content: Frame)
	remote("RecordFunnelEvent"):InvokeServer("shop_opened")
	local scroll = UiFactory.Scroll(content)
	UiFactory.Label(scroll, "Game Passes", 38)

	local order = 1
	for key, config in MonetizationConfig.GamePasses do
		local configured = config.Id ~= nil
		local text = ("%s • %d R$ • %s"):format(pretty(key), config.PriceHypothesis, if configured then "Buy" else "Awaiting Roblox ID")
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
		local text = ("%s • %d R$ • %s"):format(pretty(key), config.PriceHypothesis, if configured then "Buy" else "Awaiting Roblox ID")
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
	Vehicles = renderVehicles,
	Company = renderCompany,
	Daily = renderDaily,
	Shop = renderShop,
	Prestige = renderPrestige,
}

function MenuController.Render(tab: string)
	local content = MenuController._content
	if content == nil then
		return
	end
	clear(content)
	MenuController._currentTab = tab
	local renderer = renderers[tab]
	if renderer then
		renderer(content)
	end
end

function MenuController.Open()
	local panel = MenuController._panel
	if panel == nil then
		return
	end
	panel.Visible = true
	MenuController.Render(MenuController._currentTab)
	GuiService.SelectedObject = nil
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
	openButton.Font = Enum.Font.GothamBold
	openButton.TextSize = 16
	openButton.Text = "Menu"
	openButton.Selectable = true
	openButton.Parent = screen
	MenuController._openButton = openButton

	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromScale(0.92, 0.86)
	panel.BackgroundTransparency = 0.04
	panel.Visible = false
	panel.Parent = screen
	MenuController._panel = panel

	local size = Instance.new("UISizeConstraint")
	size.MinSize = Vector2.new(300, 360)
	size.MaxSize = Vector2.new(980, 760)
	size.Parent = panel

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = panel

	local tabs = Instance.new("ScrollingFrame")
	tabs.Name = "Tabs"
	tabs.Size = UDim2.new(1, -16, 0, 56)
	tabs.Position = UDim2.fromOffset(8, 8)
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

	for _, tab in { "Jobs", "Co-op", "Tools", "Vehicles", "Company", "Daily", "Shop", "Prestige" } do
		local button = Instance.new("TextButton")
		button.Name = tab .. "Tab"
		button.Size = UDim2.fromOffset(116, 48)
		button.Font = Enum.Font.GothamMedium
		button.TextSize = 14
		button.Text = tab
		button.Selectable = true
		button.Parent = tabs
		button.Activated:Connect(function()
			MenuController.Render(tab)
		end)
	end

	local close = Instance.new("TextButton")
	close.Name = "Close"
	close.AnchorPoint = Vector2.new(1, 0)
	close.Position = UDim2.new(1, -10, 0, 70)
	close.Size = UDim2.fromOffset(72, 42)
	close.Font = Enum.Font.GothamBold
	close.TextSize = 14
	close.Text = "Close"
	close.Selectable = true
	close.Parent = panel

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Position = UDim2.fromOffset(8, 120)
	content.Size = UDim2.new(1, -16, 1, -128)
	content.BackgroundTransparency = 1
	content.Parent = panel
	MenuController._content = content

	openButton.Activated:Connect(MenuController.Open)
	close.Activated:Connect(MenuController.Close)

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		if input.KeyCode == Enum.KeyCode.M or input.KeyCode == Enum.KeyCode.ButtonStart then
			if panel.Visible then
				MenuController.Close()
			else
				MenuController.Open()
			end
		elseif input.KeyCode == Enum.KeyCode.Escape and panel.Visible then
			MenuController.Close()
		end
	end)
end

return MenuController
