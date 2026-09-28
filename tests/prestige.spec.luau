return function()
	local config = require("../src/shared/prestige/PrestigeConfig")
	assert(config.GetRewardMultiplier(0) == 1, "prestige zero must not grant a bonus")
	assert(config.GetRewardMultiplier(1) > 1, "first prestige must grant a bonus")
	assert(config.GetRewardMultiplier(100) <= 1.5, "prestige reward bonus must remain capped")
	assert(config.ConfirmationLifetimeSeconds <= 60, "prestige confirmation must expire quickly")
end
