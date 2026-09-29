--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ToolAnimationController = {
	_busy = false,
}

local function findArmMotor(character: Model): Motor6D?
	local upperTorso = character:FindFirstChild("UpperTorso")
	if upperTorso then
		local shoulder = upperTorso:FindFirstChild("RightShoulder")
		if shoulder and shoulder:IsA("Motor6D") then
			return shoulder
		end
	end

	local torso = character:FindFirstChild("Torso")
	if torso then
		local shoulder = torso:FindFirstChild("Right Shoulder")
		if shoulder and shoulder:IsA("Motor6D") then
			return shoulder
		end
	end
	return nil
end

local function findWaist(character: Model): Motor6D?
	local lowerTorso = character:FindFirstChild("LowerTorso")
	if lowerTorso then
		local waist = lowerTorso:FindFirstChild("Waist")
		if waist and waist:IsA("Motor6D") then
			return waist
		end
	end
	return nil
end

local function poseForAction(action: string): (CFrame, CFrame)
	if action:find("inspect") or action:find("test") or action:find("measure") or action:find("diagnose") then
		return CFrame.Angles(math.rad(-35), math.rad(8), math.rad(18)), CFrame.Angles(0, math.rad(-6), 0)
	elseif action:find("replace") or action:find("install") or action:find("tighten") or action:find("repair") then
		return CFrame.Angles(math.rad(-72), math.rad(5), math.rad(28)), CFrame.Angles(0, math.rad(-10), math.rad(-3))
	elseif action:find("clean") or action:find("flush") or action:find("clear") then
		return CFrame.Angles(math.rad(-58), math.rad(-6), math.rad(34)), CFrame.Angles(0, math.rad(-8), 0)
	end
	return CFrame.Angles(math.rad(-48), 0, math.rad(24)), CFrame.Angles(0, math.rad(-7), 0)
end

local function playAction(action: string)
	if ToolAnimationController._busy then
		return
	end

	local character = Players.LocalPlayer.Character
	if not character then
		return
	end
	local shoulder = findArmMotor(character)
	if not shoulder then
		return
	end

	ToolAnimationController._busy = true
	local waist = findWaist(character)
	local shoulderOrigin = shoulder.Transform
	local waistOrigin = if waist then waist.Transform else CFrame.new()
	local shoulderPose, waistPose = poseForAction(action)

	local windup = TweenService:Create(
		shoulder,
		TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Transform = shoulderOrigin * shoulderPose }
	)
	windup:Play()
	if waist then
		TweenService:Create(
			waist,
			TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Transform = waistOrigin * waistPose }
		):Play()
	end
	windup.Completed:Wait()

	for pulse = 1, 2 do
		local direction = if pulse % 2 == 0 then -1 else 1
		local workPose = shoulderOrigin
			* shoulderPose
			* CFrame.Angles(math.rad(10 * direction), 0, math.rad(8 * direction))
		local work = TweenService:Create(
			shoulder,
			TweenInfo.new(0.11, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{ Transform = workPose }
		)
		work:Play()
		work.Completed:Wait()
	end

	local recover = TweenService:Create(
		shoulder,
		TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Transform = shoulderOrigin }
	)
	recover:Play()
	if waist then
		TweenService:Create(
			waist,
			TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Transform = waistOrigin }
		):Play()
	end
	recover.Completed:Wait()
	ToolAnimationController._busy = false
end

function ToolAnimationController.Start()
	local event = ReplicatedStorage:WaitForChild("RepairEmpireRemotes"):WaitForChild("StateUpdated")
	assert(event:IsA("RemoteEvent"), "StateUpdated must be a RemoteEvent")

	event.OnClientEvent:Connect(function(payload)
		if type(payload) ~= "table" then
			return
		end
		if payload.kind ~= "job_stage" and payload.kind ~= "coop_stage" then
			return
		end

		local stage = payload.stage
		local action = if type(stage) == "table" and type(stage.Action) == "string" then stage.Action else "repair"
		task.spawn(playAction, action)
	end)
end

return ToolAnimationController
