return function()
	local guard = require("../src/server/security/MutationGuard")

	assert(guard.TryBegin(1, "profile_purchase"), "first mutation must acquire")
	assert(guard.IsBusy(1, "profile_purchase"), "acquired mutation must report busy")
	assert(not guard.TryBegin(1, "profile_purchase"), "second simultaneous mutation must reject")
	assert(guard.TryBegin(1, "other"), "different mutation key may acquire")

	guard.Finish(1, "profile_purchase")
	assert(not guard.IsBusy(1, "profile_purchase"), "finished mutation must release")
	assert(guard.TryBegin(1, "profile_purchase"), "released mutation must reacquire")
	guard.Clear(1)
	assert(not guard.IsBusy(1, "profile_purchase"), "clear must remove player locks")
	assert(not guard.IsBusy(1, "other"), "clear must remove every player lock")

	local entered, result = guard.TryRun(2, "profile_purchase", function()
		return "ok"
	end)
	assert(entered and result == "ok", "TryRun must return callback result")
	assert(not guard.IsBusy(2, "profile_purchase"), "TryRun must release after success")

	local errored = pcall(function()
		guard.TryRun(3, "profile_purchase", function()
			error("expected")
		end)
	end)
	assert(not errored, "TryRun must propagate callback errors")
	assert(not guard.IsBusy(3, "profile_purchase"), "TryRun must release after error")
end
