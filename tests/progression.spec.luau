return function()
	local progression = require("../src/shared/config/ProgressionConfig")
	local first = progression.XpForNextLevel(1)
	local tenth = progression.XpForNextLevel(10)
	assert(first > 0, "first XP threshold must be positive")
	assert(tenth > first, "XP thresholds must increase")
	assert(progression.DistrictUnlockLevels.residential == 1, "residential unlock changed")
	assert(progression.DistrictUnlockLevels.downtown > 1, "downtown must not start unlocked")
end
