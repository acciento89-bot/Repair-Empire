local fs = require("@lune/fs")

return function()
	local controller = fs.readFile("src/client/ui/VisualPolishController.luau")

	assert(string.find(controller, "local base = instance.BackgroundColor3", 1, true), "global visual polish must preserve authored button colors")
	assert(not string.find(controller, "instance.BackgroundColor3 = accent", 1, true), "visual polish must not repaint every button with a global accent")
	assert(not string.find(controller, "local function buttonColor", 1, true), "generic name-based button recoloring must stay removed")
	assert(string.find(controller, "VisualTheme.Colors.Accent2", 1, true), "secondary cyan accent should remain available for restrained chrome")
end
