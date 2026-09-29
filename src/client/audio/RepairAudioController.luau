--!strict

local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local RepairAudioController = {}

local CATEGORY_AUDIO = {
	plumbing = {
		SoundId = "rbxasset://sounds/impact_water.mp3",
		Volume = 0.18,
		PlaybackSpeed = 1.45,
	},
	heating = {
		SoundId = "rbxasset://sounds/volume_slider.ogg",
		Volume = 0.2,
		PlaybackSpeed = 0.82,
	},
	climate = {
		SoundId = "rbxasset://sounds/action_swim.mp3",
		Volume = 0.12,
		PlaybackSpeed = 1.75,
	},
	energy = {
		SoundId = "rbxasset://sounds/electronicpingshort.wav",
		Volume = 0.2,
		PlaybackSpeed = 1.3,
	},
}

local STAGE_SOUND = "rbxasset://sounds/action_footsteps_plastic.mp3"
local COMPLETE_SOUND = "rbxasset://sounds/electronicpingshort.wav"

local function createSound(parent: Instance, name: string, id: string): Sound
	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = id
	sound.RollOffMode = Enum.RollOffMode.InverseTapered
	sound.Volume = 0.18
	sound.Parent = parent
	return sound
end

function RepairAudioController.Start()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	local folder = Instance.new("Folder")
	folder.Name = "RepairEmpireRepairAudio"
	folder.Parent = playerGui

	local tradeSound = createSound(folder, "TradeCue", CATEGORY_AUDIO.plumbing.SoundId)
	local stageSound = createSound(folder, "ToolCue", STAGE_SOUND)
	local completeSound = createSound(folder, "CompletionCue", COMPLETE_SOUND)

	stageSound.Volume = 0.16
	stageSound.PlaybackSpeed = 1.7
	completeSound.Volume = 0.26
	completeSound.PlaybackSpeed = 1.12

	if RunService:IsStudio() then
		task.spawn(function()
			local preload = { tradeSound, stageSound, completeSound }
			local ok = pcall(ContentProvider.PreloadAsync, ContentProvider, preload)
			print("[Repair Empire] RepairAudio ready=" .. tostring(ok))
		end)
	end

	local currentCategory = "plumbing"

	local function playTrade(category: string, stageBoost: number?)
		local config = CATEGORY_AUDIO[category] or CATEGORY_AUDIO.plumbing
		tradeSound.SoundId = config.SoundId
		tradeSound.Volume = config.Volume
		tradeSound.PlaybackSpeed = config.PlaybackSpeed + (stageBoost or 0)
		tradeSound.TimePosition = 0
		tradeSound:Play()
	end

	local event = ReplicatedStorage:WaitForChild("RepairEmpireRemotes"):WaitForChild("StateUpdated")
	assert(event:IsA("RemoteEvent"), "StateUpdated must be a RemoteEvent")

	event.OnClientEvent:Connect(function(payload)
		if type(payload) ~= "table" then
			return
		end

		if payload.kind == "job_started" or payload.kind == "coop_started" then
			local job = payload.job
			if type(job) == "table" and type(job.Category) == "string" then
				currentCategory = job.Category
			end
			playTrade(currentCategory, -0.08)
		elseif payload.kind == "job_stage" or payload.kind == "coop_stage" then
			stageSound.TimePosition = 0
			stageSound.PlaybackSpeed = 1.55 + math.min(0.35, math.random() * 0.22)
			stageSound:Play()
			task.delay(0.08, function()
				playTrade(currentCategory, 0.06)
			end)
		elseif payload.kind == "job_completed" or payload.kind == "coop_completed" then
			completeSound.TimePosition = 0
			completeSound:Play()
			task.delay(0.1, function()
				playTrade(currentCategory, 0.16)
			end)
		elseif payload.kind == "job_abandoned" or payload.kind == "coop_left" then
			tradeSound:Stop()
			stageSound:Stop()
		end
	end)
end

return RepairAudioController
