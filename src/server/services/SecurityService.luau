--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteDefinitions = require(ReplicatedStorage.RepairEmpire.Shared.remotes.RemoteDefinitions)
local RateLimiter = require(script.Parent.Parent.security.RateLimiter)

local SecurityService = {
	Name = "SecurityService",
	Dependencies = {},
	_limiter = RateLimiter.new(),
	_anomalyCounts = {},
}

local KICK_THRESHOLD = 40

function SecurityService:Init()
	Players.PlayerRemoving:Connect(function(player)
		self._limiter:Clear(player)
		self._anomalyCounts[player.UserId] = nil
	end)
end

function SecurityService:Start() end

function SecurityService:RecordAnomaly(player: Player, code: string, detail: string?)
	local userId = player.UserId
	local count = (self._anomalyCounts[userId] or 0) + 1
	self._anomalyCounts[userId] = count

	warn(("[Repair Empire][Security] user=%d code=%s count=%d detail=%s"):format(
		userId,
		code,
		count,
		detail or ""
	))

	if count >= KICK_THRESHOLD then
		player:Kick("Too many invalid requests.")
	end
end

function SecurityService:Allow(player: Player, remoteName: string): boolean
	local definition = RemoteDefinitions.ByName[remoteName]
	if definition == nil then
		self:RecordAnomaly(player, "unknown_remote", remoteName)
		return false
	end

	local allowed = self._limiter:Allow(player, remoteName, definition.RateLimitPerSecond)
	if not allowed then
		self:RecordAnomaly(player, "rate_limit", remoteName)
	end
	return allowed
end

function SecurityService:ValidateId(player: Player, value: any, code: string): string?
	if type(value) ~= "string" or #value == 0 or #value > 100 or string.match(value, "^[a-z0-9_]+$") == nil then
		self:RecordAnomaly(player, code, tostring(value))
		return nil
	end
	return value
end

function SecurityService:ValidatePayloadTable(player: Player, value: any, code: string)
	if type(value) ~= "table" then
		self:RecordAnomaly(player, code, typeof(value))
		return nil
	end
	return value
end

return SecurityService
