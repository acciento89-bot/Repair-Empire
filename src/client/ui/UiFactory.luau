--!strict

local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UiPalette = require(ReplicatedStorage.RepairEmpire.Shared.ui.UiPalette)

local function color(rgb)
	return Color3.fromRGB(rgb[1], rgb[2], rgb[3])
end

local UiFactory = {}

function UiFactory.Round(object: GuiObject, radius: number?)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 12)
	corner.Parent = object
end

function UiFactory.Stroke(object: GuiObject, rgb: { number }?, thickness: number?, transparency: number?)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color(rgb or UiPalette.Stroke)
	stroke.Thickness = thickness or 1
	stroke.Transparency = transparency or 0.25
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = object
end

function UiFactory.Button(parent: Instance, text: string, order: number?): TextButton
	local button = Instance.new("TextButton")
	button.Name = text:gsub("%W+", "") .. "Button"
	button.Size = UDim2.new(1, 0, 0, 52)
	button.BackgroundTransparency = 0
	button.BackgroundColor3 = color(UiPalette.Button)
	button.TextColor3 = color(UiPalette.Text)
	button.BorderSizePixel = 0
	button.AutoButtonColor = true
	button.Font = Enum.Font.GothamMedium
	button.TextSize = 16
	button.TextWrapped = true
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.Text = text
	button.LayoutOrder = order or 0
	button.Selectable = true
	button.Parent = parent

	UiFactory.Round(button, 12)
	UiFactory.Stroke(button)

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 16)
	padding.PaddingRight = UDim.new(0, 16)
	padding.Parent = button

	return button
end

function UiFactory.Label(parent: Instance, text: string, height: number?): TextLabel
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, height or 42)
	label.BackgroundTransparency = 1
	label.TextColor3 = color(UiPalette.Text)
	label.Font = Enum.Font.Gotham
	label.TextSize = 15
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = text
	label.Parent = parent
	return label
end

function UiFactory.SectionTitle(parent: Instance, text: string, order: number?): TextLabel
	local label = UiFactory.Label(parent, string.upper(text), 34)
	label.LayoutOrder = order or 0
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.TextColor3 = color(UiPalette.Gold)
	return label
end

function UiFactory.Scroll(parent: Instance): ScrollingFrame
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.fromScale(1, 1)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarImageColor3 = color(UiPalette.Accent)
	scroll.BorderSizePixel = 0
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new()
	scroll.ScrollBarThickness = 5
	scroll.ScrollingDirection = Enum.ScrollingDirection.Y
	scroll.Parent = parent

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroll

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 12)
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = scroll

	return scroll
end

function UiFactory.Focus(button: GuiButton?)
	if button and button.Visible then
		GuiService.SelectedObject = button
	end
end

return UiFactory
