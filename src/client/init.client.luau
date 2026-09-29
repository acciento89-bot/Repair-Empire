--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local HudController = require(script.ui.HudController)
local NavigationController = require(script.ui.NavigationController)
local InteractionController = require(script.ui.InteractionController)
local MenuController = require(script.ui.MenuController)
local ResponsiveController = require(script.ui.ResponsiveController)
local FeedbackController = require(script.ui.FeedbackController)
local PassCosmeticsController = require(script.ui.PassCosmeticsController)
local PerformanceProbe = require(script.PerformanceProbe)
local RepairSceneController = require(script.world.RepairSceneController)
local WorkshopVisualController = require(script.world.WorkshopVisualController)
local ToolAnimationController = require(script.world.ToolAnimationController)
local RepairAudioController = require(script.audio.RepairAudioController)

local player = Players.LocalPlayer
assert(player ~= nil, "LocalPlayer unavailable")

local function disableLegacyBackpack()
	for _ = 1, 10 do
		local ok = pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		end)
		if ok then
			return
		end
		task.wait(0.25)
	end
end

task.spawn(disableLegacyBackpack)
player.CharacterAdded:Connect(function()
	task.defer(disableLegacyBackpack)
end)

local function pretty(id: string): string
	local words = string.split(id, "_")
	for index, word in words do
		words[index] = word:sub(1, 1):upper() .. word:sub(2)
	end
	return table.concat(words, " ")
end

HudController.Start()
NavigationController.Start()
InteractionController.Start()
MenuController.Start()
ResponsiveController.Start()
FeedbackController.Start()
RepairAudioController.Start()
PassCosmeticsController.Start()
PerformanceProbe.Start()
WorkshopVisualController.Start()
ToolAnimationController.Start()

local remotes = ReplicatedStorage:WaitForChild("RepairEmpireRemotes")
local stateUpdated = remotes:WaitForChild("StateUpdated")
assert(stateUpdated:IsA("RemoteEvent"), "StateUpdated must be a RemoteEvent")

stateUpdated.OnClientEvent:Connect(function(payload)
	if type(payload) ~= "table" then
		return
	end

	if payload.kind == "job_started" then
		local job = payload.job
		local stage = payload.stage
		HudController.SetObjective(("%s\n%s"):format(pretty(job and job.Id or "job"), pretty(stage and stage.Action or "start")))
		if typeof(payload.targetPosition) == "Vector3" then
			NavigationController.SetTarget(payload.targetPosition)
			RepairSceneController.Begin(job, stage, payload.targetPosition)
		end
	elseif payload.kind == "job_stage" then
		HudController.SetObjective(pretty(payload.stage and payload.stage.Action or "continue_job"))
		RepairSceneController.Update(payload.stage)
	elseif payload.kind == "coop_started" then
		local job = payload.job
		local stage = payload.stage
		HudController.SetObjective(("CO-OP • %s\n%s"):format(pretty(job and job.Id or "contract"), pretty(stage and stage.Action or "start")))
		if typeof(payload.targetPosition) == "Vector3" then
			NavigationController.SetTarget(payload.targetPosition)
			RepairSceneController.Begin(job, stage, payload.targetPosition)
		end
	elseif payload.kind == "coop_stage" then
		HudController.SetObjective(("CO-OP\n%s"):format(pretty(payload.stage and payload.stage.Action or "continue")))
		RepairSceneController.Update(payload.stage)
	elseif payload.kind == "job_completed" then
		HudController.SetObjective(("Job complete +$%d"):format(payload.reward or 0))
		NavigationController.SetTarget(nil)
		RepairSceneController.Complete()
	elseif payload.kind == "coop_completed" then
		if payload.contributed then
			HudController.SetObjective(("Co-op complete +$%d"):format(payload.reward or 0))
		else
			HudController.SetObjective("Co-op complete • no contribution reward")
		end
		NavigationController.SetTarget(nil)
		RepairSceneController.Complete()
	elseif payload.kind == "job_abandoned" or payload.kind == "coop_left" then
		HudController.SetObjective("Choose a job")
		NavigationController.SetTarget(nil)
		RepairSceneController.Clear()
	end
end)

print(("[Repair Empire] Client initialized for %s"):format(player.Name))
