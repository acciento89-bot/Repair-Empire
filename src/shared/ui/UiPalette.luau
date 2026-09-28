--!strict

local UiPalette = {
	Text = { 246, 249, 252 },
	TextMuted = { 178, 192, 207 },
	TextOnAccent = { 24, 30, 36 },

	Panel = { 18, 31, 43 },
	Surface = { 25, 43, 58 },
	SurfaceRaised = { 33, 55, 72 },
	Button = { 37, 61, 79 },
	ButtonDisabled = { 67, 78, 88 },
	Hud = { 14, 28, 40 },

	Accent = { 245, 151, 49 },
	AccentSoft = { 90, 59, 30 },
	Gold = { 249, 199, 79 },
	Success = { 75, 184, 124 },
	Warning = { 244, 185, 66 },
	Danger = { 224, 88, 88 },
	Stroke = { 79, 105, 126 },
	Shadow = { 8, 16, 24 },
}

local function channelToLinear(value: number): number
	local c = value / 255
	if c <= 0.04045 then
		return c / 12.92
	end
	return ((c + 0.055) / 1.055) ^ 2.4
end

function UiPalette.RelativeLuminance(rgb): number
	return 0.2126 * channelToLinear(rgb[1]) + 0.7152 * channelToLinear(rgb[2]) + 0.0722 * channelToLinear(rgb[3])
end

function UiPalette.ContrastRatio(a, b): number
	local la = UiPalette.RelativeLuminance(a)
	local lb = UiPalette.RelativeLuminance(b)
	local lighter = math.max(la, lb)
	local darker = math.min(la, lb)
	return (lighter + 0.05) / (darker + 0.05)
end

return table.freeze(UiPalette)
