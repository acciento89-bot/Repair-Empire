--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local UiPalette = require(ReplicatedStorage.RepairEmpire.Shared.ui.UiPalette)

local function color(rgb)
	return Color3.fromRGB(rgb[1], rgb[2], rgb[3])
end

local InteractionController = {
	_instanceId = nil :: string?,
	_mode = nil :: string?,
	_stage = nil,
	_button = nil :: TextButton?,
	_instantButton = nil :: TextButton?,
	_readyAt = 0,
}

local function prettyAction(id: string): string
	local words = string.split(id, "_")
	for index, word in words do
		words[index] = word:sub(1, 1):upper() .. word:sub(2)
	end
	return table.concat(words, " ")
end

local function remoteFunction(name: string): RemoteFunction
	local instance = ReplicatedStorage:WaitForChild("RepairEmpireRemotes"):WaitForChild(name)
	assert(instance:IsA("RemoteFunction"), name .. " must be a RemoteFunction")
	return instance
end

local function updateButton()
	local button = InteractionController._button
	if button == nil then
		return
	end

	local stage = InteractionController._stage
	local active = InteractionController._instanceId ~= nil and stage ~= nil
	button.Visible = active
	if not active then
		return
	end

	local remaining = math.max(0, InteractionController._readyAt - os.clock())
	button.Active = remaining <= 0
	button.Text = if remaining <= 0
		then ("DO REPAIR\n%s"):format(prettyAction(stage.Action or "continue"))
		else ("PREPARING\n%.1fs"):format(remaining)
end

local function perform()
	if InteractionController._instanceId == nil or InteractionController._stage == nil then
		return
	end
	if os.clock() < InteractionController._readyAt then
		return
	end

	local result
	if InteractionController._mode == "coop" then
		result = remoteFunction("PerformCoopAction"):InvokeServer({
			action = InteractionController._stage.Action,
		})
	else
		result = remoteFunction("PerformJobAction"):InvokeServer({
			instanceId = InteractionController._instanceId,
			action = InteractionController._stage.Action,
		})
	end
	if type(result) == "table" and result.ok and result.completed ~= true and result.stage then
		InteractionController._stage = result.stage
		InteractionController._readyAt = os.clock() + (result.stage.MinimumSeconds or 0)
	end
	updateButton()
end

local function onAction(_name: string, state: Enum.UserInputState)
	if state == Enum.UserInputState.Begin then
		perform()
	end
	return Enum.ContextActionResult.Sink
end

function InteractionController.Start()
	local player = Players.LocalPlayer
	local gui = Instance.new("ScreenGui")
	gui.Name = "RepairEmpireInteraction"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 20
	gui.Parent = player:WaitForChild("PlayerGui")

	local button = Instance.new("TextButton")
	button.Name = "RepairAction"
	button.AnchorPoint = Vector2.new(1, 1)
	button.Position = UDim2.new(1, -24, 1, -92)
	button.Size = UDim2.fromOffset(220, 64)
	button.BackgroundColor3 = color(UiPalette.Accent)
	button.TextColor3 = color(UiPalette.TextOnAccent)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.TextSize = 18
	button.TextWrapped = true
	button.Visible = false
	button.Selectable = true
	button.Parent = gui
	InteractionController._button = button

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = button
	button.Activated:Connect(perform)

	local instant = Instance.new("TextButton")
	instant.Name = "InstantFinish"
	instant.AnchorPoint = Vector2.new(1, 1)
	instant.Position = UDim2.new(1, -24, 1, -164)
	instant.Size = UDim2.fromOffset(220, 48)
	instant.BackgroundColor3 = color(UiPalette.SurfaceRaised)
	instant.TextColor3 = color(UiPalette.Gold)
	instant.BorderSizePixel = 0
	instant.Font = Enum.Font.GothamMedium
	instant.TextSize = 14
	instant.Text = "INSTANT FINISH"
	instant.Visible = false
	instant.Selectable = true
	instant.Parent = gui
	InteractionController._instantButton = instant

	local instantCorner = Instance.new("UICorner")
	instantCorner.CornerRadius = UDim.new(0, 12)
	instantCorner.Parent = instant

	instant.Activated:Connect(function()
		local result = remoteFunction("UseInstantJobFinish"):InvokeServer()
		if type(result) == "table" and result.ok then
			instant.Visible = false
		end
	end)

	ContextActionService:BindAction("RepairEmpireInteract", onAction, false, Enum.KeyCode.E, Enum.KeyCode.ButtonX)

	local stateUpdated = ReplicatedStorage:WaitForChild("RepairEmpireRemotes"):WaitForChild("StateUpdated")
	assert(stateUpdated:IsA("RemoteEvent"), "StateUpdated must be a RemoteEvent")
	stateUpdated.OnClientEvent:Connect(function(payload)
		if type(payload) ~= "table" then
			return
		end

		if payload.kind == "job_started" then
			InteractionController._mode = "solo"
			InteractionController._instanceId = payload.instanceId
			InteractionController._stage = payload.stage
			InteractionController._readyAt = os.clock() + ((payload.stage and payload.stage.MinimumSeconds) or 0)
			instant.Visible = (player:GetAttribute("InstantJobFinishes") or 0) > 0
		elseif payload.kind == "job_stage" or payload.kind == "coop_stage" then
			InteractionController._stage = payload.stage
			InteractionController._readyAt = os.clock() + ((payload.stage and payload.stage.MinimumSeconds) or 0)
		elseif payload.kind == "coop_started" then
			InteractionController._mode = "coop"
			InteractionController._instanceId = payload.contractId
			InteractionController._stage = payload.stage
			InteractionController._readyAt = os.clock() + ((payload.stage and payload.stage.MinimumSeconds) or 0)
			instant.Visible = false
		elseif payload.kind == "job_completed" or payload.kind == "job_abandoned" or payload.kind == "coop_completed" or payload.kind == "coop_left" then
			InteractionController._mode = nil
			InteractionController._instanceId = nil
			InteractionController._stage = nil
			instant.Visible = false
		end
		updateButton()
	end)

	player:GetAttributeChangedSignal("InstantJobFinishes"):Connect(function()
		instant.Visible = InteractionController._mode == "solo"
			and InteractionController._instanceId ~= nil
			and (player:GetAttribute("InstantJobFinishes") or 0) > 0
	end)

	task.spawn(function()
		while gui.Parent do
			updateButton()
			task.wait(0.1)
		end
	end)
end

return InteractionController
