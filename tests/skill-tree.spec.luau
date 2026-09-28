return function()
	local config = require("../src/shared/progression/SkillTreeConfig")

	local branchCount = 0
	for _ in config.Branches do
		branchCount += 1
	end
	assert(branchCount == 4, "skill tree must contain four category branches")
	assert(config.MaxRankPerBranch == 5, "each skill branch must contain five launch ranks")
	assert(config.TotalPointsByLevel(4) == 0, "skill point granted too early")
	assert(config.TotalPointsByLevel(5) == 1, "first skill point must arrive at level 5")
	assert(config.TotalPointsByLevel(100) == 20, "level 100 must provide enough points to max all launch branches")
	assert(config.SpeedMultiplier(5) == 0.9, "max skill speed bonus changed")
	assert(config.CashMultiplier(5) == 1.05, "max skill cash bonus changed")
	assert(config.XPMultiplier(5) == 1.05, "max skill XP bonus changed")
end
