local fs = require("@lune/fs")

return function()
	local hud = fs.readFile("src/client/ui/HudController.luau")
	local menu = fs.readFile("src/client/ui/MenuController.luau")
	local art = fs.readFile("docs/ART-DIRECTION.md")

	assert(string.find(hud, "conceptShowcase.Visible = false", 1, true), "concept montage must stay hidden in gameplay")
	assert(not string.find(hud, "conceptShowcase.Visible = not phone", 1, true), "desktop must not force the concept montage visible")
	assert(string.find(hud, "status.Visible = true", 1, true), "compact gameplay status must remain available on desktop")
	assert(string.find(menu, "panel.Visible = false", 1, true), "main menu must stay hidden until opened")
	assert(string.find(menu, "backdrop.Visible = false", 1, true), "menu backdrop must stay hidden until opened")
	assert(string.find(menu, 'conceptRequest.Name = "ConceptOpen"', 1, true), "contextual tab bridge must remain available")
	assert(string.find(art, "feature montage", 1, true), "art direction must define the concept image as a feature montage")
end
