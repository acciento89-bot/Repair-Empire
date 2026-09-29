--!strict

local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local WorldAudioController = {
	_connection = nil,
	_vehicleSound = nil :: Sound?,
}

local HUM_SOUND = "rbxasset://sounds/bass.wav"

local function configure3dSound(parent: Instance, name: string, volume: number, playbackSpeed: number, maxDistance: number): Sound
	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = HUM_SOUND
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

	local sound = configure3dSound(building, "WorkshopAmbientHum", 0.035, 0.58, 62)
	sound:Play()
	return sound
end

local function stopVehicleSound()
	if WorldAudioController._vehicleSound then
		WorldAudioController._vehicleSound:Stop()
		WorldAudioController._vehicleSound:Destroy()
		WorldAudioController._vehicleSound = nil
	end
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

	local sound = configure3dSound(model.PrimaryPart, "LocalVehicleEngineHum", 0.045, 0.58, 48)
	sound:Play()
	WorldAudioController._vehicleSound = sound
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
		local sound = WorldAudioController._vehicleSound
		if not sound or not sound.Parent then
			return
		end

		local parent = sound.Parent
		local model = parent:FindFirstAncestorOfClass("Model")
		local moving = model ~= nil and model:GetAttribute("Driving") == true
		local seat = model and model:FindFirstChild("DriverSeat", true)
		local throttle = if seat and seat:IsA("VehicleSeat") then math.abs(seat.ThrottleFloat) else 0

		sound.Volume = if moving then 0.06 + throttle * 0.09 else 0.035
		sound.PlaybackSpeed = if moving then 0.62 + throttle * 0.34 else 0.54
	end)
end

return WorldAudioController
