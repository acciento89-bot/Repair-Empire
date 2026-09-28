return function()
	local RateLimiter = require("../src/server/security/RateLimiter")
	local limiter = RateLimiter.new()
	local player = { UserId = 42 }

	assert(limiter:Allow(player, "test", 2), "first request should pass")
	assert(limiter:Allow(player, "test", 2), "second request should pass")
	assert(not limiter:Allow(player, "test", 2), "third request inside window should be rejected")
	assert(limiter:Allow(player, "other", 1), "separate keys need separate buckets")
	assert(not limiter:Allow(player, "other", 1), "separate key limit must still apply")

	limiter:Clear(player)
	assert(limiter:Allow(player, "test", 2), "clear must reset user buckets")
end
