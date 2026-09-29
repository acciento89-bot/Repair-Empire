--!strict

local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local WorldAudioController = {
	_connection = nil,
	_vehicleSound = nil :: Sound?,
	_roadSound = nil :: Sound?,
}

local ENGINE_SOUND = "rbxasset://sounds/volume_slider.ogg"
local ROAD_SOUND = "rbxasset://sounds/action_falling.ogg"
local WORKSHOP_SOUND = "rbxasset://sounds/volume_slider.ogg"

local function configure3dSound(parent: Instance, name: string, soundId: string, volume: number, playbackSpeed: number, maxDistance: number): Sound
	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = soundId
	sound.Looped = true
	sound.Volume = volume
	sound.PlaybackSpeed = playbackSpeed
	sound.RollOffMode = Enum.RollOffMode.InverseTapered
	sound.RollOffMinDistance = 8
	sound.RollOffMaxDistance = maxDistance
	sound.Parent = parent
	return sound
end

local function findVehicleModel(seat: Seat): Model?
	local current: Instance? = seat
	while current do
		if current:IsA("Model") and current:GetAttribute("OwnerUserId") ~= nil then
			return current
		end
		current = current.Parent
	end
	return nil
end

local function attachWorkshopAmbience(): Sound?
	local world = workspace:FindFirstChild("RepairEmpireWorld")
	local workshop = world and world:FindFirstChild("PlayerWorkshop", true)
	local building = workshop and workshop:FindFirstChild("WorkshopBuilding")
	if not building or not building:IsA("BasePart") then
		return nil
	end

	local existing = building:FindFirstChild("WorkshopAmbientHum")
	if existing and existing:IsA("Sound") then
		if not existing.IsPlaying then
			existing:Play()
		end
		return existing
	end

	local sound = configure3dSound(building, "WorkshopAmbientHum", WORKSHOP_SOUND, 0.025, 0.42, 62)
	sound:Play()
	return sound
end

local function stopVehicleSound()
	for _, sound in { WorldAudioController._vehicleSound, WorldAudioController._roadSound } do
		if sound then
			sound:Stop()
			sound:Destroy()
		end
	end
	WorldAudioController._vehicleSound = nil
	WorldAudioController._roadSound = nil
end

local function bindVehicleSound(seatPart: BasePart?)
	stopVehicleSound()
	if not seatPart or not seatPart:IsA("VehicleSeat") then
		return
	end

	local model = findVehicleModel(seatPart)
	if not model or not model.PrimaryPart then
		return
	end

	local engine = configure3dSound(model.PrimaryPart, "LocalVehicleEngineHum", ENGINE_SOUND, 0.035, 0.48, 48)
	local road = configure3dSound(model.PrimaryPart, "LocalVehicleRoadNoise", ROAD_SOUND, 0.0, 0.62, 44)
	engine:Play()
	road:Play()
	WorldAudioController._vehicleSound = engine
	WorldAudioController._roadSound = road

	if RunService:IsStudio() then
		task.spawn(function()
			local ok = pcall(ContentProvider.PreloadAsync, ContentProvider, { engine, road })
			print("[Repair Empire] VehicleAudio preload=" .. tostring(ok))
		end)
	end
end

function WorldAudioController.Start()
	local player = Players.LocalPlayer

	task.spawn(function()
		local deadline = os.clock() + 15
		while not workspace:FindFirstChild("RepairEmpireWorld") and os.clock() < deadline do
			task.wait(0.2)
		end

		local workshopSound = attachWorkshopAmbience()
		if RunService:IsStudio() and workshopSound then
			print("[Repair Empire] WorldAudio workshopActive=true")
			task.spawn(function()
				local ok = pcall(ContentProvider.PreloadAsync, ContentProvider, { workshopSound })
				print("[Repair Empire] WorldAudio preload=" .. tostring(ok))
			end)
		end
	end)

	local function bindCharacter(character: Model)
		local humanoid = character:WaitForChild("Humanoid")
		assert(humanoid:IsA("Humanoid"))

		humanoid.Seated:Connect(function(active, currentSeatPart)
			if active then
				bindVehicleSound(currentSeatPart)
			else
				stopVehicleSound()
			end
		end)

		if humanoid.SeatPart then
			bindVehicleSound(humanoid.SeatPart)
		end
	end

	if player.Character then
		bindCharacter(player.Character)
	end
	player.CharacterAdded:Connect(bindCharacter)

	WorldAudioController._connection = RunService.RenderStepped:Connect(function()
		local engine = WorldAudioController._vehicleSound
		local road = WorldAudioController._roadSound
		if not engine or not engine.Parent then
			return
		end

		local model = engine.Parent:FindFirstAncestorOfClass("Model")
		local moving = model ~= nil and model:GetAttribute("Driving") == true
		local throttle = if model then math.abs(model:GetAttribute("DriveThrottle") or 0) else 0

		engine.Volume = if moving then 0.045 + throttle * 0.085 else 0.022
		engine.PlaybackSpeed = if moving then 0.48 + throttle * 0.42 else 0.42

		if road and road.Parent then
			road.Volume = if moving then 0.015 + throttle * 0.045 else 0
			road.PlaybackSpeed = 0.58 + throttle * 0.22
		end
	end)
end

return WorldAudioController
