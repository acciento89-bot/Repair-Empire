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
			local class = UiLayoutRules.Classify(viewport.X, viewport.Y, touch)
			openButton.AnchorPoint = Vector2.new(1, 0)
			openButton.Position = UDim2.new(1, -12, 0, if class == "small_phone" then 72 else if touch then 116 else 104)
			openButton.Size = if class == "small_phone" then UDim2.fromOffset(96, 38) else UDim2.fromOffset(124, 44)
			openButton.Text = if class == "small_phone" then "TABLET" else "▣  WORK TABLET"
			textConstraint(openButton, 11, 16)
		end
		if panel and panel:IsA("Frame") then
			local metrics = UiLayoutRules.GetMenuMetrics(viewport.X, viewport.Y, touch)
			panel.Size = UDim2.fromScale(metrics.PanelScaleX, metrics.PanelScaleY)
			local compactMenu = metrics.Class == "small_phone"
			local title = panel:FindFirstChild("Title")
			local subtitle = panel:FindFirstChild("Subtitle")
			local accentBar = panel:FindFirstChild("AccentBar")
			local close = panel:FindFirstChild("Close")
			local tabs = panel:FindFirstChild("Tabs")
			local content = panel:FindFirstChild("Content")
			if title and title:IsA("TextLabel") then
				title.Position = UDim2.fromOffset(14, if compactMenu then 8 else 12)
				title.TextSize = if compactMenu then 17 else 22
			end
			if subtitle and subtitle:IsA("TextLabel") then
				subtitle.Visible = not compactMenu
			end
			if accentBar and accentBar:IsA("Frame") then
				accentBar.Position = UDim2.fromOffset(14, if compactMenu then 40 else 64)
				accentBar.Size = UDim2.new(1, -28, 0, 3)
			end
			if close and close:IsA("TextButton") then
				close.Position = UDim2.new(1, -12, 0, if compactMenu then 7 else 14)
				close.Size = if compactMenu then UDim2.fromOffset(68, 32) else UDim2.fromOffset(82, 40)
			end
			if tabs and tabs:IsA("ScrollingFrame") then
				tabs.Position = UDim2.fromOffset(8, if compactMenu then 47 else 74)
				tabs.Size = UDim2.new(1, -16, 0, if compactMenu then 44 else 54)
			end
			if content and content:IsA("Frame") then
				content.Position = UDim2.fromOffset(10, if compactMenu then 96 else 136)
				content.Size = UDim2.new(1, -20, 1, if compactMenu then -106 else -148)
			end
			local sizeConstraint = panel:FindFirstChildOfClass("UISizeConstraint")
			if sizeConstraint then
				sizeConstraint.MinSize = Vector2.new(260, 300)
				sizeConstraint.MaxSize = Vector2.new(metrics.MaxWidth, metrics.MaxHeight)
			end

			if tabs and tabs:IsA("ScrollingFrame") then
				for _, child in tabs:GetChildren() do
					if child:IsA("TextButton") then
						child.Size = UDim2.fromOffset(metrics.TabWidth, if compactMenu then 40 else 48)
						textConstraint(child, 12, 16)
					end
				end
			end

			if content then
				for _, descendant in content:GetDescendants() do
					if descendant:IsA("TextButton") then
						if descendant:GetAttribute("ResponsiveSkipSize") ~= true then
							descendant.Size = UDim2.new(1, 0, 0, metrics.ButtonHeight)
						end
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
		local status = hud:FindFirstChild("Status")
		if status and status:IsA("Frame") then
			status.Size = UDim2.fromOffset(metrics.StatusWidth, metrics.StatusHeight)
			for _, descendant in status:GetDescendants() do
				if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
					textConstraint(descendant, 10, 18)
				end
			end
		end
		local tutorial = hud:FindFirstChild("Tutorial")
		if tutorial and tutorial:IsA("TextLabel") then
			tutorial.Position = UDim2.fromOffset(if metrics.Class == "small_phone" then 12 else 16, metrics.TutorialY)
			tutorial.Size = UDim2.fromOffset(metrics.TutorialWidth, metrics.TutorialHeight)
			tutorial.TextScaled = metrics.Class ~= "small_phone"
			tutorial.TextSize = if metrics.Class == "small_phone" then 11 else tutorial.TextSize
			textConstraint(tutorial, 10, 18)
		end
		local objective = hud:FindFirstChild("Objective")
		if objective and objective:IsA("TextLabel") then
			objective.Size = UDim2.fromOffset(metrics.ObjectiveWidth, metrics.ObjectiveHeight)
			if metrics.Class == "small_phone" then
				objective.Position = UDim2.new(0, 12, 0.5, 18)
				objective.TextScaled = false
				objective.TextSize = 13
			else
				objective.Position = UDim2.new(0, 16, 0.5, 0)
				objective.TextScaled = true
			end
			textConstraint(objective, 11, 20)
		end
	end

	local interaction = playerGui:FindFirstChild("RepairEmpireInteraction")
	if interaction and interaction:IsA("ScreenGui") then
		local metrics = UiLayoutRules.GetInteractionOffsets(viewport.X, viewport.Y, touch)
		local repair = interaction:FindFirstChild("RepairAction")
		if repair and repair:IsA("TextButton") then
			repair.Position = UDim2.new(1, -metrics.Right, 1, -metrics.Bottom)
			repair.Size = UDim2.fromOffset(metrics.Width, if UiLayoutRules.Classify(viewport.X, viewport.Y, touch) == "small_phone" then 52 else 64)
			textConstraint(repair, 13, 20)
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
			local class = UiLayoutRules.Classify(viewport.X, viewport.Y, touch)
			distance.Position = UDim2.new(0.5, 0, 1, if class == "small_phone" then -106 else if touch then -150 else -28)
			distance.Size = if class == "small_phone" then UDim2.fromOffset(210, 38) else UDim2.fromOffset(260, 48)
			textConstraint(distance, 11, 18)
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
	playerGui.ScreenOrientation = Enum.ScreenOrientation.Sensor
	playerGui.DescendantAdded:Connect(function()
		task.defer(apply)
	end)
end

return ResponsiveController
