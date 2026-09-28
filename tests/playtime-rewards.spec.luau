return function()
	local rewards = require("../src/shared/retention/PlaytimeRewards")

	local none = rewards.GetClaimable(299, {})
	assert(#none == 0, "5-minute reward must stay locked before threshold")

	local first = rewards.GetClaimable(300, {})
	assert(#first == 1 and first[1].Cash == 150, "5-minute reward must become claimable")

	local claimed = { ["1"] = true }
	local nextReward = rewards.Next(300, claimed)
	assert(nextReward ~= nil and nextReward.Index == 2, "next unclaimed reward must advance")
	assert(nextReward.Ready == false and nextReward.RemainingSeconds == 600, "remaining time must be deterministic")

	local later = rewards.GetClaimable(3600, claimed)
	assert(#later == 3, "60 minutes should unlock 15/30/60 rewards after first is claimed")
end
