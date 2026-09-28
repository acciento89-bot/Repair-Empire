return function()
	local palette = require("../src/shared/ui/UiPalette")

	local required = {
		"Text",
		"TextMuted",
		"TextOnAccent",
		"Panel",
		"Surface",
		"SurfaceRaised",
		"Button",
		"Hud",
		"Accent",
		"Gold",
		"Success",
		"Warning",
		"Danger",
		"Stroke",
	}

	for _, key in required do
		local value = palette[key]
		assert(type(value) == "table" and #value == 3, ("missing visual token %s"):format(key))
	end

	assert(palette.ContrastRatio(palette.Text, palette.Panel) >= 4.5, "panel text contrast must meet WCAG AA")
	assert(palette.ContrastRatio(palette.Text, palette.Surface) >= 4.5, "surface text contrast must meet WCAG AA")
	assert(palette.ContrastRatio(palette.Text, palette.Button) >= 4.5, "button text contrast must meet WCAG AA")
	assert(palette.ContrastRatio(palette.TextOnAccent, palette.Accent) >= 4.5, "accent button text contrast must meet WCAG AA")
end
