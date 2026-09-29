--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local CharacterCameraController = {}

local CAMERA_DISTANCE = 11.5
local CAMERA_HEIGHT = 5.8
local FOCUS_HEIGHT = 2.6
local FOLLOW_SPEED = 12
local SNAP_DISTANCE = 28
local COLLISION_PADDING = 0.65

local player = Players.LocalPlayer
local character: Model? = nil
local humanoid: Humanoid? = nil
local root: BasePart? = nil

local function bindCharacter(nextCharacter: Model)
	character = nextCharacter

	local foundHumanoid = nextCharacter:WaitForChild("Humanoid", 10)
	local foundRoot = nextCharacter:WaitForChild("HumanoidRootPart", 10)

	if not foundHumanoid or not foundHumanoid:IsA("Humanoid") or not foundRoot or not foundRoot:IsA("BasePart") then
		humanoid = nil
		root = nil
		return
	end

	humanoid = foundHumanoid
	root = foundRoot
end

local function desiredCameraCFrame(currentRoot: BasePart, currentCharacter: Model): (CFrame, CFrame)
	local focusPosition = currentRoot.Position + Vector3.new(0, FOCUS_HEIGHT, 0)
	local flatLook = Vector3.new(currentRoot.CFrame.LookVector.X, 0, currentRoot.CFrame.LookVector.Z)
	if flatLook.Magnitude < 0.01 then
		flatLook = Vector3.new(0, 0, -1)
	else
		flatLook = flatLook.Unit
	end

	local desiredPosition = focusPosition - flatLook * CAMERA_DISTANCE + Vector3.new(0, CAMERA_HEIGHT, 0)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { currentCharacter }
	params.IgnoreWater = true

	local direction = desiredPosition - focusPosition
	local result = Workspace:Raycast(focusPosition, direction, params)
	if result then
		desiredPosition = result.Position + result.Normal * COLLISION_PADDING
	end

	return CFrame.lookAt(desiredPosition, focusPosition), CFrame.new(focusPosition)
end

local function updateCamera(dt: number)
	local currentCharacter = character
	local currentHumanoid = humanoid
	local currentRoot = root
	local camera = Workspace.CurrentCamera

	if
		camera == nil
		or currentCharacter == nil
		or currentHumanoid == nil
		or currentRoot == nil
		or currentHumanoid.Health <= 0
		or not currentCharacter.Parent
		or not currentRoot.Parent
	then
		return
	end

	camera.CameraType = Enum.CameraType.Scriptable
	camera.CameraSubject = currentHumanoid

	local targetCFrame, targetFocus = desiredCameraCFrame(currentRoot, currentCharacter)
	local distance = (camera.CFrame.Position - targetCFrame.Position).Magnitude

	if distance >= SNAP_DISTANCE then
		camera.CFrame = targetCFrame
	else
		local alpha = 1 - math.exp(-FOLLOW_SPEED * math.max(dt, 0))
		camera.CFrame = camera.CFrame:Lerp(targetCFrame, alpha)
	end
	camera.Focus = targetFocus
end

function CharacterCameraController.Start()
	if player.Character then
		bindCharacter(player.Character)
	end

	player.CharacterAdded:Connect(function(nextCharacter)
		bindCharacter(nextCharacter)
	end)

	player.CharacterRemoving:Connect(function(removingCharacter)
		if character == removingCharacter then
			character = nil
			humanoid = nil
			root = nil
		end
	end)

	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		local camera = Workspace.CurrentCamera
		if camera and humanoid then
			camera.CameraType = Enum.CameraType.Scriptable
			camera.CameraSubject = humanoid
		end
	end)

	RunService:UnbindFromRenderStep("RepairEmpireCharacterCamera")
	RunService:BindToRenderStep("RepairEmpireCharacterCamera", Enum.RenderPriority.Camera.Value + 1, updateCamera)
end

return CharacterCameraController