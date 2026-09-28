return function()
	local rules = require("../src/shared/data/SessionRules")

	assert(rules.CanAcquire(nil, 100), "missing lock must be acquirable")
	assert(rules.CanAcquire({ Token = "a", ExpiresAt = 99 }, 100), "expired lock must be acquirable")
	assert(rules.CanAcquire({ Token = "a", ExpiresAt = 100 }, 100), "lock expiring now must be acquirable")
	assert(not rules.CanAcquire({ Token = "a", ExpiresAt = 101 }, 100), "active lock must block acquisition")

	local lock = rules.Create("session-a", 1_000, 180)
	assert(lock.Token == "session-a", "session token changed")
	assert(lock.ExpiresAt == 1_180, "session expiration calculation changed")
	assert(rules.Owns(lock, "session-a"), "owner token must match")
	assert(not rules.Owns(lock, "session-b"), "foreign token must not own lock")
	assert(rules.CanWrite(lock, "session-a"), "owning session must be allowed to save")
	assert(not rules.CanWrite(lock, "session-b"), "foreign session must never overwrite an active lock")
	assert(rules.CanWrite(nil, "session-a"), "missing persisted lock must not block the current loaded session")

	assert(rules.CanAcquire({ Unexpected = true }, 100), "malformed legacy lock must not permanently brick profile loading")
end
