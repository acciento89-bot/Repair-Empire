--!strict

local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage.RepairEmpire.Shared
local ToolDefinitions = require(Shared.tools.ToolDefinitions)
local RepairAudioRules = require(Shared.audio.RepairAudioRules)
local AudioCatalog = require(Shared.audio.AudioCatalog)

local RepairAudioController = {}

local CATEGORY_AUDIO = {
	plumbing = {
		Sound = AudioCatalog.BuiltIn.WaterImpact,
		Volume = 0.18,
		PlaybackSpeed = 1.45,
	},
	heating = {
		Sound = AudioCatalog.BuiltIn.VolumeSlider,
		Volume = 0.2,
		PlaybackSpeed = 0.82,
	},
	climate = {
		Sound = AudioCatalog.BuiltIn.Swim,
		Volume = 0.12,
		PlaybackSpeed = 1.75,
	},
	energy = {
		Sound = AudioCatalog.BuiltIn.ElectronicPing,
		Volume = 0.2,
		PlaybackSpeed = 1.3,
	},
}

local TOOL_AUDIO = AudioCatalog.ToolFamily

local STAGE_SOUND = AudioCatalog.BuiltIn.PlasticTool
local COMPLETE_SOUND = AudioCatalog.BuiltIn.ElectronicPing

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

	local tradeSound = createSound(folder, "TradeCue", CATEGORY_AUDIO.plumbing.Sound)
	local stageSound = createSound(folder, "ToolCue", STAGE_SOUND)
	local completeSound = createSound(folder, "CompletionCue", COMPLETE_SOUND)

	stageSound.Volume = 0.16
	stageSound.PlaybackSpeed = 1.7
	completeSound.Volume = 0.26
	completeSound.PlaybackSpeed = 1.12

	if RunService:IsStudio() then
		task.spawn(function()
			local preload = { tradeSound, stageSound, completeSound }
			local seen = {}
			for _, config in CATEGORY_AUDIO do
				if seen[config.Sound] ~= true then
					seen[config.Sound] = true
					local probe = createSound(folder, "PreloadTrade", config.Sound)
					probe.Volume = 0
					table.insert(preload, probe)
				end
			end
			for _, config in TOOL_AUDIO do
				if seen[config.Sound] ~= true then
					seen[config.Sound] = true
					local probe = createSound(folder, "PreloadTool", config.Sound)
					probe.Volume = 0
					table.insert(preload, probe)
				end
			end
			local ok = pcall(ContentProvider.PreloadAsync, ContentProvider, preload)
			print("[Repair Empire] RepairAudio ready=" .. tostring(ok) .. " assets=" .. tostring(#preload))
			for index = 4, #preload do
				preload[index]:Destroy()
			end
		end)
	end

	local currentCategory = "plumbing"

	local function configureToolCue(action: string)
		local toolId = Players.LocalPlayer:GetAttribute("EquippedTool")
		local definition = if type(toolId) == "string" then ToolDefinitions.ById[toolId] else nil
		local config = if definition then TOOL_AUDIO[definition.Family] else nil
		config = config or {
			Sound = STAGE_SOUND,
			PlaybackSpeed = 1.55,
			Volume = 0.16,
		}
		local actionProfile = RepairAudioRules.ForAction(action)
		stageSound.SoundId = actionProfile.SoundId or config.Sound
		stageSound.PlaybackSpeed = config.PlaybackSpeed + actionProfile.PlaybackOffset
		stageSound.Volume = config.Volume * actionProfile.VolumeMultiplier
	end

	local function playTrade(category: string, stageBoost: number?)
		local config = CATEGORY_AUDIO[category] or CATEGORY_AUDIO.plumbing
		tradeSound.SoundId = config.Sound
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
			local stage = payload.stage
			local action = if type(stage) == "table" and type(stage.Action) == "string" then stage.Action else "repair"
			configureToolCue(action)
			stageSound.TimePosition = 0
			stageSound.PlaybackSpeed += math.min(0.12, math.random() * 0.08)
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
