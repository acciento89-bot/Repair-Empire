--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local NavigationController = {
	_target = nil :: Vector3?,
	_connection = nil,
}

function NavigationController.SetTarget(position: Vector3?)
	NavigationController._target = position
end

function NavigationController.Start()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local gui = Instance.new("ScreenGui")
	gui.Name = "RepairEmpireNavigation"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 11
	gui.Parent = playerGui

	local label = Instance.new("TextLabel")
	label.Name = "Distance"
	label.AnchorPoint = Vector2.new(0.5, 1)
	label.Position = UDim2.new(0.5, 0, 1, -28)
	label.Size = UDim2.fromOffset(220, 44)
	label.BackgroundTransparency = 0.2
	label.Font = Enum.Font.GothamMedium
	label.TextScaled = true
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Visible = false
	label.Parent = gui

	NavigationController._connection = RunService.RenderStepped:Connect(function()
		local target = NavigationController._target
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if target == nil or root == nil or not root:IsA("BasePart") then
			label.Visible = false
			return
		end
		label.Visible = true
		label.Text = ("%d studs to job"):format(math.floor((root.Position - target).Magnitude))
	end)
end

return NavigationController
