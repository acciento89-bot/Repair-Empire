return function()
	local config = require("../src/shared/retention/RetentionConfig")
	assert(config.DailyJobCount == 3, "launch daily job count changed")
	assert(#config.LoginRewards == 7, "login reward cycle must contain seven entries")
	assert(config.GetFeaturedCategory(0) == "plumbing", "rotation order changed")
	assert(config.GetFeaturedCategory(1) == "heating", "rotation order changed")
end
