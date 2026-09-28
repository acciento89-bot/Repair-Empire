--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local UiLayoutRules = require(ReplicatedStorage.RepairEmpire.Shared.ui.UiLayoutRules)

local ResponsiveController = {}

local function textConstraint(object: Instance, minSize: number, maxSize: number)
	if not object:IsA("TextLabel") and not object:IsA("TextButton") then
		return
	end
	local existing = object:FindFirstChildOfClass("UITextSizeConstraint")
	if existing == nil then
		existing = Instance.new("UITextSizeConstraint")
		existing.Parent = object
	end
	existing.MinTextSize = minSize
	existing.MaxTextSize = maxSize
end

local function apply()
	local camera = Workspace.CurrentCamera
	if camera == nil then
		return
	end

	local viewport = camera.ViewportSize
	local touch = UserInputService.TouchEnabled
	local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
	if playerGui == nil then
		return
	end

	local menuGui = playerGui:FindFirstChild("RepairEmpireMenu")
	if menuGui and menuGui:IsA("ScreenGui") then
		local panel = menuGui:FindFirstChild("Panel")
		local openButton = menuGui:FindFirstChild("OpenMenu")
		if openButton and openButton:IsA("TextButton") then
			openButton.AnchorPoint = Vector2.new(1, 0)
			openButton.Position = UDim2.new(1, -16, 0, 16)
			textConstraint(openButton, 13, 18)
		end
		if panel and panel:IsA("Frame") then
			local metrics = UiLayoutRules.GetMenuMetrics(viewport.X, viewport.Y, touch)
			panel.Size = UDim2.fromScale(metrics.PanelScaleX, metrics.PanelScaleY)
			local sizeConstraint = panel:FindFirstChildOfClass("UISizeConstraint")
			if sizeConstraint then
				sizeConstraint.MinSize = Vector2.new(260, 300)
				sizeConstraint.MaxSize = Vector2.new(metrics.MaxWidth, metrics.MaxHeight)
			end

			local tabs = panel:FindFirstChild("Tabs")
			if tabs and tabs:IsA("ScrollingFrame") then
				for _, child in tabs:GetChildren() do
					if child:IsA("TextButton") then
						child.Size = UDim2.fromOffset(metrics.TabWidth, 48)
						textConstraint(child, 12, 16)
					end
				end
			end

			local content = panel:FindFirstChild("Content")
			if content then
				for _, descendant in content:GetDescendants() do
					if descendant:IsA("TextButton") then
						descendant.Size = UDim2.new(1, 0, 0, metrics.ButtonHeight)
						textConstraint(descendant, 12, 18)
					elseif descendant:IsA("TextLabel") then
						textConstraint(descendant, 12, 18)
					end
				end
			end
		end
	end

	local hud = playerGui:FindFirstChild("RepairEmpireHUD")
	if hud and hud:IsA("ScreenGui") then
		local metrics = UiLayoutRules.GetHudMetrics(viewport.X, viewport.Y, touch)
		local tutorial = hud:FindFirstChild("Tutorial")
		if tutorial and tutorial:IsA("TextLabel") then
			tutorial.Size = UDim2.fromOffset(metrics.TutorialWidth, 54)
			textConstraint(tutorial, 12, 18)
		end
		local objective = hud:FindFirstChild("Objective")
		if objective and objective:IsA("TextLabel") then
			objective.Size = UDim2.fromOffset(metrics.ObjectiveWidth, metrics.ObjectiveHeight)
			textConstraint(objective, 12, 20)
		end
	end

	local interaction = playerGui:FindFirstChild("RepairEmpireInteraction")
	if interaction and interaction:IsA("ScreenGui") then
		local metrics = UiLayoutRules.GetInteractionOffsets(viewport.X, viewport.Y, touch)
		local repair = interaction:FindFirstChild("RepairAction")
		if repair and repair:IsA("TextButton") then
			repair.Position = UDim2.new(1, -metrics.Right, 1, -metrics.Bottom)
			repair.Size = UDim2.fromOffset(metrics.Width, 64)
			textConstraint(repair, 14, 20)
		end
		local instant = interaction:FindFirstChild("InstantFinish")
		if instant and instant:IsA("TextButton") then
			instant.Position = UDim2.new(1, -metrics.Right, 1, -(metrics.Bottom + metrics.InstantGap))
			instant.Size = UDim2.fromOffset(metrics.Width, 48)
			textConstraint(instant, 12, 16)
		end
	end

	local navigation = playerGui:FindFirstChild("RepairEmpireNavigation")
	if navigation and navigation:IsA("ScreenGui") then
		local distance = navigation:FindFirstChild("Distance")
		if distance and distance:IsA("TextLabel") then
			distance.Position = UDim2.new(0.5, 0, 1, if touch then -150 else -28)
			textConstraint(distance, 13, 18)
		end
	end
end

function ResponsiveController.Start()
	apply()

	local camera = Workspace.CurrentCamera
	if camera then
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(apply)
	end

	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		task.defer(apply)
	end)

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	playerGui.DescendantAdded:Connect(function()
		task.defer(apply)
	end)
end

return ResponsiveController
