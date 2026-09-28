--!strict

local UserInputService = game:GetService("UserInputService")

local ResponsiveUi = {}

function ResponsiveUi.GetInputMode(): string
	if UserInputService.GamepadEnabled and not UserInputService.TouchEnabled then
		return "gamepad"
	end
	if UserInputService.TouchEnabled then
		return "touch"
	end
	return "keyboard_mouse"
end

function ResponsiveUi.ApplySafeSize(frame: GuiObject)
	local constraint = frame:FindFirstChildOfClass("UISizeConstraint")
	if constraint == nil then
		constraint = Instance.new("UISizeConstraint")
		constraint.MinSize = Vector2.new(120, 44)
		constraint.MaxSize = Vector2.new(720, 900)
		constraint.Parent = frame
	end
end

return ResponsiveUi
