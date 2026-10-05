local fs = require("@lune/fs")

return function()
	local retention = fs.readFile("src/server/services/RetentionService.luau")
	local hud = fs.readFile("src/client/ui/HudController.luau")

	assert(
		string.find(retention, 'return { ok = false, error = "profile_loading" }', 1, true),
		"retention status must fail gracefully while the profile is still loading"
	)
	assert(
		string.find(hud, 'player:GetAttribute("RepairEmpireLoaded") ~= true', 1, true),
		"HUD must wait for the authoritative profile-loaded attribute before requesting retention state"
	)
end
