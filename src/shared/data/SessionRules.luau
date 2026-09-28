--!strict

local SessionRules = {}

function SessionRules.CanAcquire(lock, now: number): boolean
	if lock == nil then
		return true
	end
	if type(lock) ~= "table" or type(lock.Token) ~= "string" or type(lock.ExpiresAt) ~= "number" then
		return true
	end
	return lock.ExpiresAt <= now
end

function SessionRules.Create(token: string, now: number, ttlSeconds: number)
	assert(#token > 0, "session token required")
	assert(ttlSeconds > 0, "session TTL must be positive")
	return {
		Token = token,
		ExpiresAt = now + ttlSeconds,
	}
end

function SessionRules.Owns(lock, token: string): boolean
	return type(lock) == "table" and lock.Token == token
end

function SessionRules.CanWrite(lock, token: string): boolean
	if lock == nil then
		return true
	end
	return SessionRules.Owns(lock, token)
end

return SessionRules
