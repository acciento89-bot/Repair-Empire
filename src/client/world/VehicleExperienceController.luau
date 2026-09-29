--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local VehicleExperienceController = {
	_connection = nil,
	_seat = nil :: VehicleSeat?,
	_model = nil :: Model?,
	_speedLabel = nil :: TextLabel?,
	_statusLabel = nil :: TextLabel?,
	_gui = nil :: ScreenGui?,
	_fov = 70,
}

local function styleLabel(parent: Instance, name: string, size: UDim2, position: UDim2, textSize: number): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.AnchorPoint = Vector2.new(0.5, 1)
	label.Size = size
	label.Position = position
	label.BackgroundColor3 = Color3.fromRGB(18, 31, 43)
	label.BackgroundTransparency = 0.08
	label.BorderSizePixel = 0
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.fromRGB(244, 247, 249)
	label.TextSize = textSize
	label.Text = ""
	label.Visible = false
	label.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = label

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(245, 151, 49)
	stroke.Thickness = 1.2
	stroke.Transparency = 0.18
	stroke.Parent = label

	return label
end

local function findVehicleModel(seat: Seat): Model?
	local current: Instance? = seat
	while current do
		if current:IsA("Model") and current:GetAttribute("VehicleId") ~= nil then
			return current
		end
		current = current.Parent
	end
	return nil
end

local function setDrivingSeat(seatPart: BasePart?)
	VehicleExperienceController._seat = nil
	VehicleExperienceController._model = nil

	if seatPart and seatPart:IsA("VehicleSeat") then
		local model = findVehicleModel(seatPart)
		if model then
			VehicleExperienceController._seat = seatPart
			VehicleExperienceController._model = model
		end
	end

	local visible = VehicleExperienceController._seat ~= nil
	if VehicleExperienceController._speedLabel then
		VehicleExperienceController._speedLabel.Visible = visible
	end
	if VehicleExperienceController._statusLabel then
		VehicleExperienceController._statusLabel.Visible = visible
	end
end

local function bindCharacter(character: Model)
	local humanoid = character:WaitForChild("Humanoid")
	assert(humanoid:IsA("Humanoid"))

	humanoid.Seated:Connect(function(active, currentSeatPart)
		if active then
			setDrivingSeat(currentSeatPart)
		else
			setDrivingSeat(nil)
		end
	end)

	if humanoid.SeatPart then
		setDrivingSeat(humanoid.SeatPart)
	end
end

function VehicleExperienceController.Start()
	local player = Players.LocalPlayer
	local gui = Instance.new("ScreenGui")
	gui.Name = "RepairEmpireVehicleHUD"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 18
	gui.Parent = player:WaitForChild("PlayerGui")
	VehicleExperienceController._gui = gui

	local speed = styleLabel(gui, "Speed", UDim2.fromOffset(190, 46), UDim2.new(0.5, 0, 1, -30), 18)
	speed.Text = "0 • SERVICE VEHICLE"
	VehicleExperienceController._speedLabel = speed

	local status = styleLabel(gui, "Status", UDim2.fromOffset(250, 32), UDim2.new(0.5, 0, 1, -82), 13)
	status.TextColor3 = Color3.fromRGB(245, 199, 79)
	status.Text = "REPAIR EMPIRE FLEET"
	VehicleExperienceController._statusLabel = status

	if player.Character then
		bindCharacter(player.Character)
	end
	player.CharacterAdded:Connect(bindCharacter)

	VehicleExperienceController._connection = RunService.RenderStepped:Connect(function(dt)
		local camera = Workspace.CurrentCamera
		if not camera then
			return
		end

		local seat = VehicleExperienceController._seat
		local model = VehicleExperienceController._model
		local targetFov = 70

		if seat and model and seat.Parent and model.Parent then
			local throttle = math.abs(seat.ThrottleFloat)
			local steer = math.abs(seat.SteerFloat)
			local moving = model:GetAttribute("Driving") == true
			local maxSpeed = seat.MaxSpeed
			local displayedSpeed = math.floor(maxSpeed * throttle + 0.5)
			if throttle < 0.01 and moving and steer > 0.01 then
				displayedSpeed = math.floor(maxSpeed * 0.08)
			end

			if VehicleExperienceController._speedLabel then
				VehicleExperienceController._speedLabel.Text =
					("%d • %s"):format(displayedSpeed, string.upper(tostring(model:GetAttribute("VehicleId") or "SERVICE VEHICLE")))
			end
			if VehicleExperienceController._statusLabel then
				VehicleExperienceController._statusLabel.Text = if moving
					then "REPAIR EMPIRE FLEET • EN ROUTE"
					else "REPAIR EMPIRE FLEET • READY"
			end

			targetFov = if moving then 74 + math.min(4, throttle * 4) else 72
		end

		local alpha = 1 - math.exp(-dt * 5)
		VehicleExperienceController._fov += (targetFov - VehicleExperienceController._fov) * alpha
		camera.FieldOfView = VehicleExperienceController._fov
	end)
end

return VehicleExperienceController
