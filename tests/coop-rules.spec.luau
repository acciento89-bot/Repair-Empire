return function()
	local rules = require("../src/shared/coop/CoopRules")

	local participants = {
		[42] = true,
		[7] = true,
		[19] = true,
	}
	assert(rules.ParticipantCount(participants) == 3, "participant count changed")
	assert(rules.NextOwner(participants) == 7, "owner transfer must choose a remaining participant deterministically")
	assert(rules.CanJoin(participants, 6), "party with free slots must accept joins")
	assert(not rules.CanJoin(participants, 3), "full party must reject joins")

	assert(not rules.HasContribution(nil), "missing contribution must not count")
	assert(not rules.HasContribution(0), "zero contribution must not count")
	assert(rules.HasContribution(1), "positive contribution must count")

	assert(rules.RewardShare(0, 5) == 0, "zero-contribution player must receive zero share")
	assert(rules.RewardShare(2, 0) == 0, "invalid total contribution must yield zero share")
	assert(math.abs(rules.RewardShare(2, 5) - 0.4) < 0.000001, "reward share changed")
end
