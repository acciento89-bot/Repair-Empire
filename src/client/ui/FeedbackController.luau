--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FeedbackController = {}

local function messageFor(payload): string?
	if payload.kind == "job_completed" then
		return ("Job complete • +$%d • +%d XP"):format(payload.reward or 0, payload.xp or 0)
	elseif payload.kind == "coop_completed" then
		if payload.contributed then
			return ("Co-op complete • +$%d • +%d XP"):format(payload.reward or 0, payload.xp or 0)
		end
		return "Co-op complete • no contribution reward"
	elseif payload.kind == "job_abandoned" then
		return "Job abandoned"
	elseif payload.kind == "coop_left" then
		return "Left co-op contract"
	end
	return nil
end

function FeedbackController.Start()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	local gui = Instance.new("ScreenGui")
	gui.Name = "RepairEmpireFeedback"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 40
	gui.Parent = playerGui

	local toast = Instance.new("TextLabel")
	toast.Name = "Toast"
	toast.AnchorPoint = Vector2.new(0.5, 0)
	toast.Position = UDim2.new(0.5, 0, 0, 20)
	toast.Size = UDim2.fromOffset(420, 54)
	toast.BackgroundTransparency = 0.08
	toast.Font = Enum.Font.GothamBold
	toast.TextSize = 17
	toast.TextWrapped = true
	toast.Visible = false
	toast.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = toast

	local textConstraint = Instance.new("UITextSizeConstraint")
	textConstraint.MinTextSize = 12
	textConstraint.MaxTextSize = 18
	textConstraint.Parent = toast

	local generation = 0
	local function show(text: string)
		generation += 1
		local current = generation
		toast.Text = text
		toast.Visible = true
		task.delay(2.5, function()
			if generation == current then
				toast.Visible = false
			end
		end)
	end

	local event = ReplicatedStorage:WaitForChild("RepairEmpireRemotes"):WaitForChild("StateUpdated")
	assert(event:IsA("RemoteEvent"), "StateUpdated must be a RemoteEvent")
	event.OnClientEvent:Connect(function(payload)
		if type(payload) ~= "table" then
			return
		end
		local text = messageFor(payload)
		if text then
			show(text)
		end
	end)
end

return FeedbackController
