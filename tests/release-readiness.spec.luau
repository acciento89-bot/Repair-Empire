return function()
	local rules = require("../src/shared/release/ReadinessRules")

	local blocked = rules.Evaluate(
		{
			UniverseId = nil,
			ProductionStartPlaceId = nil,
			DevelopmentPlaceIds = {},
		},
		{
			GamePasses = {
				double_cash = { Id = nil },
			},
			DeveloperProducts = {
				small_cash = { Id = nil },
			},
		}
	)
	assert(not blocked.ReadyForSandbox, "missing Roblox IDs must block sandbox readiness")
	assert(#blocked.Blockers == 5, "unexpected readiness blocker count")

	local ready = rules.Evaluate(
		{
			UniverseId = 1,
			ProductionStartPlaceId = 2,
			DevelopmentPlaceIds = { 3 },
		},
		{
			GamePasses = {
				double_cash = { Id = 4 },
			},
			DeveloperProducts = {
				small_cash = { Id = 5 },
			},
		}
	)
	assert(ready.ReadyForSandbox, "complete platform IDs should pass sandbox readiness")
	assert(#ready.Blockers == 0, "ready configuration still reports blockers")
end
