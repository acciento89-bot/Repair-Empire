--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local InteractionController = {
	_instanceId = nil :: string?,
	_stage = nil,
	_button = nil :: TextButton?,
	_instantButton = nil :: TextButton?,
	_readyAt = 0,
}

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
	button.Text = if remaining <= 0 then ("Repair: %s"):format(stage.Action or "Continue") else ("Ready in %.1fs"):format(remaining)
end

local function perform()
	if InteractionController._instanceId == nil or InteractionController._stage == nil then
		return
	end
	if os.clock() < InteractionController._readyAt then
		return
	end

	local result = remoteFunction("PerformJobAction"):InvokeServer({
		instanceId = InteractionController._instanceId,
		action = InteractionController._stage.Action,
	})
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
	instant.Font = Enum.Font.GothamSemibold
	instant.TextSize = 14
	instant.Text = "Use Instant Finish"
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
			InteractionController._instanceId = payload.instanceId
			InteractionController._stage = payload.stage
			InteractionController._readyAt = os.clock() + ((payload.stage and payload.stage.MinimumSeconds) or 0)
			instant.Visible = (player:GetAttribute("InstantJobFinishes") or 0) > 0
		elseif payload.kind == "job_stage" then
			InteractionController._stage = payload.stage
			InteractionController._readyAt = os.clock() + ((payload.stage and payload.stage.MinimumSeconds) or 0)
		elseif payload.kind == "job_completed" or payload.kind == "job_abandoned" then
			InteractionController._instanceId = nil
			InteractionController._stage = nil
			instant.Visible = false
		end
		updateButton()
	end)

	player:GetAttributeChangedSignal("InstantJobFinishes"):Connect(function()
		instant.Visible = InteractionController._instanceId ~= nil and (player:GetAttribute("InstantJobFinishes") or 0) > 0
	end)

	task.spawn(function()
		while gui.Parent do
			updateButton()
			task.wait(0.1)
		end
	end)
end

return InteractionController
