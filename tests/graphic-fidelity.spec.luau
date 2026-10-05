local fs = require("@lune/fs")

return function()
	local yard = fs.readFile("src/server/world/WorkshopYardArt.luau")
	local backdrop = fs.readFile("src/server/world/BackdropArt.luau")
	local art = fs.readFile("docs/ART-DIRECTION.md")

	assert(string.find(yard, '"WorkshopCanopy"', 1, true), "service-HQ canopy missing")
	assert(string.find(yard, '"HqMarker"', 1, true), "HQ marker missing")
	assert(string.find(yard, '"CanopyLamp"', 1, true), "canopy lamp missing")
	assert(string.find(backdrop, 'farLayer.Name = "FarCityLayer"', 1, true), "far city layer missing")
	assert(string.find(backdrop, '"FarCityTower"', 1, true), "far city tower missing")
	assert(string.find(art, "service-city identity", 1, true), "service-city identity missing")
end
