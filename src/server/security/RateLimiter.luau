--!strict

local RateLimiter = {}
RateLimiter.__index = RateLimiter

function RateLimiter.new()
	return setmetatable({
		_buckets = {},
	}, RateLimiter)
end

function RateLimiter:Allow(player: Player, key: string, limitPerSecond: number): boolean
	local userId = player.UserId
	local now = os.clock()
	local userBuckets = self._buckets[userId]
	if userBuckets == nil then
		userBuckets = {}
		self._buckets[userId] = userBuckets
	end

	local bucket = userBuckets[key]
	if bucket == nil or now - bucket.WindowStart >= 1 then
		userBuckets[key] = {
			WindowStart = now,
			Count = 1,
		}
		return true
	end

	if bucket.Count >= limitPerSecond then
		return false
	end

	bucket.Count += 1
	return true
end

function RateLimiter:Clear(player: Player)
	self._buckets[player.UserId] = nil
end

return RateLimiter
