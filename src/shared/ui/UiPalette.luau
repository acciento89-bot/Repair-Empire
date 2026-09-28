--!strict

local UiPalette = {
	Text = { 245, 247, 250 },
	TextMuted = { 204, 210, 218 },
	Panel = { 30, 33, 39 },
	Button = { 50, 55, 64 },
	ButtonDisabled = { 72, 76, 84 },
	Hud = { 22, 25, 30 },
	Accent = { 70, 145, 205 },
	Gold = { 242, 199, 76 },
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
