return function()
	local ProfileSchema = require("../src/shared/data/ProfileSchema")
	local ReceiptRules = require("../src/shared/data/ReceiptRules")

	local profile = ProfileSchema.NewProfile()
	local ok, reason, granted, changed = ReceiptRules.BuildCandidate(profile, "receipt-1", 123, ProfileSchema.Clone, function(candidate)
		candidate.Cash += 500
	end)

	assert(ok and reason == "granted" and changed, "first receipt must produce a grant candidate")
	assert(profile.Cash == 0, "receipt candidate construction must not mutate the source profile")
	assert(granted.Cash == 500, "receipt grant mutation was not applied")
	assert(granted.ProcessedReceipts["receipt-1"] == 123, "receipt ID was not marked on candidate")

	local duplicateCalls = 0
	local duplicateOk, duplicateReason, duplicateProfile, duplicateChanged =
		ReceiptRules.BuildCandidate(granted, "receipt-1", 456, ProfileSchema.Clone, function(candidate)
			duplicateCalls += 1
			candidate.Cash += 500
		end)
	assert(duplicateOk and duplicateReason == "already_processed", "duplicate receipt must resolve idempotently")
	assert(not duplicateChanged and duplicateCalls == 0, "duplicate receipt must not execute the grant mutator")
	assert(duplicateProfile.Cash == 500, "duplicate receipt changed persistent value")

	local failedOk, failedReason, failedProfile, failedChanged = ReceiptRules.BuildCandidate(granted, "receipt-2", 789, ProfileSchema.Clone, function(candidate)
		candidate.Cash += 1_000
		error("simulated grant failure")
	end)
	assert(not failedOk and failedReason == "grant_failed", "grant failure must remain unresolved")
	assert(not failedChanged, "failed grant must not produce a save candidate")
	assert(failedProfile.Cash == 500, "failed grant mutated the source profile")
	assert(failedProfile.ProcessedReceipts["receipt-2"] == nil, "failed grant incorrectly consumed receipt ID")
end
