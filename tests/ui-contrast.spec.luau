return function()
	local palette = require("../src/shared/ui/UiPalette")

	local pairsToCheck = {
		{ "text/panel", palette.Text, palette.Panel },
		{ "text/button", palette.Text, palette.Button },
		{ "text/hud", palette.Text, palette.Hud },
		{ "muted/panel", palette.TextMuted, palette.Panel },
		{ "gold/hud", palette.Gold, palette.Hud },
	}

	for _, item in pairsToCheck do
		local ratio = palette.ContrastRatio(item[2], item[3])
		assert(ratio >= 4.5, ("%s contrast %.2f is below 4.5:1"):format(item[1], ratio))
	end
end
