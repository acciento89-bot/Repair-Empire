--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HudController = require(script.ui.HudController)
local NavigationController = require(script.ui.NavigationController)
local InteractionController = require(script.ui.InteractionController)
local MenuController = require(script.ui.MenuController)

local player = Players.LocalPlayer
assert(player ~= nil, "LocalPlayer unavailable")

HudController.Start()
NavigationController.Start()
InteractionController.Start()
MenuController.Start()

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
		HudController.SetObjective(("%s: %s"):format(job and job.Id or "Job", stage and stage.Action or "Start"))
		if typeof(payload.targetPosition) == "Vector3" then
			NavigationController.SetTarget(payload.targetPosition)
		end
	elseif payload.kind == "job_stage" then
		HudController.SetObjective(payload.stage and payload.stage.Action or "Continue job")
	elseif payload.kind == "job_completed" then
		HudController.SetObjective(("Job complete +$%d"):format(payload.reward or 0))
		NavigationController.SetTarget(nil)
	elseif payload.kind == "job_abandoned" then
		HudController.SetObjective("Choose a job")
		NavigationController.SetTarget(nil)
	end
end)

print(("[Repair Empire] Client initialized for %s"):format(player.Name))
