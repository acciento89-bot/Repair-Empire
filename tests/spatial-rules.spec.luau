return function()
	local rules = require("../src/shared/security/SpatialRules")

	assert(rules.IsWithinDistance(0, 0, 0, 3, 4, 0, 5), "boundary distance must pass")
	assert(not rules.IsWithinDistance(0, 0, 0, 3.01, 4, 0, 5), "outside boundary must reject")
	assert(rules.IsWithinDistance(10, -5, 2, 10, -5, 2, 0), "same position with zero range must pass")
	assert(not rules.IsWithinDistance(0, 0, 0, 0, 0, 0, -1), "negative interaction range must reject")

	local nan = 0 / 0
	assert(not rules.IsWithinDistance(nan, 0, 0, 0, 0, 0, 5), "NaN player coordinate must fail closed")
	assert(not rules.IsWithinDistance(0, 0, 0, math.huge, 0, 0, 5), "infinite anchor coordinate must fail closed")
	assert(not rules.IsWithinDistance(1e100, 0, 0, 0, 0, 0, 5), "extreme spoofed coordinate must reject")
end
