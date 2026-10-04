local fs = require("@lune/fs")

return function()
	local hud = fs.readFile("src/client/ui/HudController.luau")
	local yard = fs.readFile("src/server/world/WorkshopYardArt.luau")

	assert(string.find(hud, 'logo.Name = "RepairEmpireLogo"', 1, true), "HUD needs Repair Empire branding")
	assert(string.find(hud, 'serviceProgress.Name = "ServiceProgress"', 1, true), "HUD needs service-level concept progress")
	assert(string.find(hud, 'progressFill.Name = "ProgressFill"', 1, true), "service progress needs a visible fill")
	assert(string.find(yard, '"REPAIR EMPIRE  •  SERVICE HQ"', 1, true), "workshop needs branded service-HQ landmark")
	assert(string.find(yard, '"YardVanBrand"', 1, true), "workshop yard needs branded service vehicle art")
end
