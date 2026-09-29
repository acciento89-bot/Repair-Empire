--!strict

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local CharacterCameraController = {}

local REFOCUS_DISTANCE = 32
local CAMERA_HEIGHT = 6
local CAMERA_DISTANCE = 12

local function focusCharacter(character: Model)
	local humanoid = character:WaitForChild("Humanoid", 10)
	local root = character:WaitForChild("HumanoidRootPart", 10)
	if not humanoid or not humanoid:IsA("Humanoid") or not root or not root:IsA("BasePart") then
		return
	end

	local camera = Workspace.CurrentCamera
	if camera == nil then
		Workspace:GetPropertyChangedSignal("CurrentCamera"):Wait()
		camera = Workspace.CurrentCamera
	end
	if camera == nil then
		return
	end

	camera.CameraType = Enum.CameraType.Custom
	camera.CameraSubject = humanoid

	local distanceFromCharacter = (camera.CFrame.Position - root.Position).Magnitude
	if distanceFromCharacter > REFOCUS_DISTANCE then
		local target = root.Position + Vector3.new(0, 2.5, 0)
		local behind = -root.CFrame.LookVector * CAMERA_DISTANCE
		local cameraPosition = target + behind + Vector3.new(0, CAMERA_HEIGHT, 0)
		camera.CFrame = CFrame.lookAt(cameraPosition, target)
		camera.Focus = CFrame.new(target)
	end
end

function CharacterCameraController.Start()
	local player = Players.LocalPlayer
	if player == nil then
		return
	end

	if player.Character then
		task.defer(focusCharacter, player.Character)
	end

	player.CharacterAdded:Connect(function(character)
		task.defer(focusCharacter, character)
	end)
end

return CharacterCameraController
