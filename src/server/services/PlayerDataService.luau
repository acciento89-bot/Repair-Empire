--!strict

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileSchema = require(ReplicatedStorage.RepairEmpire.Shared.data.ProfileSchema)
local ReceiptRules = require(ReplicatedStorage.RepairEmpire.Shared.data.ReceiptRules)
local SessionRules = require(ReplicatedStorage.RepairEmpire.Shared.data.SessionRules)
local DataStoreAdapter = require(script.Parent.Parent.datastore.DataStoreAdapter)
local ProfileMigrations = require(script.Parent.Parent.datastore.ProfileMigrations)

local AUTOSAVE_SECONDS = 60
local SESSION_LOCK_SECONDS = 180

local PlayerDataService = {
	Name = "PlayerDataService",
	Dependencies = { "SecurityService", "AnalyticsService" },
	_profiles = {},
	_sessionTokens = {},
	_loadedAt = {},
}

local function unixNow(): number
	return DateTime.now().UnixTimestamp
end

local function publishSummary(player: Player, profile)
	player:SetAttribute("RepairEmpireLoaded", true)
	player:SetAttribute("Level", profile.Level)
	player:SetAttribute("XP", profile.XP)
	player:SetAttribute("Cash", profile.Cash)
	player:SetAttribute("CompanyPoints", profile.CompanyPoints)
	player:SetAttribute("CompanyLevel", profile.CompanyLevel)
	player:SetAttribute("WorkshopTier", profile.WorkshopTier)
	player:SetAttribute("PrestigeLevel", profile.PrestigeLevel)
	player:SetAttribute("InstantJobFinishes", profile.Consumables.InstantJobFinishes)
	player:SetAttribute("TutorialStep", profile.Tutorial.Step)
	player:SetAttribute("TutorialCompleted", profile.Tutorial.Completed)
end

function PlayerDataService:GetProfile(player: Player)
	return self._profiles[player.UserId]
end

function PlayerDataService:RequireProfile(player: Player)
	local profile = self:GetProfile(player)
	assert(profile ~= nil, "Player profile is not loaded")
	return profile
end

function PlayerDataService:Publish(player: Player)
	local profile = self:GetProfile(player)
	if profile then
		publishSummary(player, profile)
	end
end

function PlayerDataService:GetSafeState(player: Player)
	local profile = self:RequireProfile(player)
	return {
		Level = profile.Level,
		XP = profile.XP,
		Cash = profile.Cash,
		CompanyPoints = profile.CompanyPoints,
		CompanyLevel = profile.CompanyLevel,
		WorkshopTier = profile.WorkshopTier,
		PrestigeLevel = profile.PrestigeLevel,
		OwnedTools = ProfileSchema.Clone(profile.OwnedTools),
		EquippedTool = profile.EquippedTool,
		OwnedVehicles = ProfileSchema.Clone(profile.OwnedVehicles),
		SelectedVehicle = profile.SelectedVehicle,
		Employees = ProfileSchema.Clone(profile.Employees),
		Achievements = ProfileSchema.Clone(profile.Achievements),
		InstantJobFinishes = profile.Consumables.InstantJobFinishes,
		TutorialStep = profile.Tutorial.Step,
		TutorialCompleted = profile.Tutorial.Completed,
	}
end

function PlayerDataService:_Load(player: Player)
	local sessionToken = HttpService:GenerateGUID(false)
	local now = unixNow()

	local ok, loaded = DataStoreAdapter.UpdateUser(player.UserId, function(existing)
		local profile = existing or ProfileSchema.NewProfile()
		local lock = profile.SessionLock
		if not SessionRules.CanAcquire(lock, now) then
			return nil
		end

		profile = ProfileMigrations.Migrate(profile)
		profile.SessionLock = SessionRules.Create(sessionToken, now, SESSION_LOCK_SECONDS)
		return profile
	end)

	if not ok or loaded == nil then
		warn(("[Repair Empire] Could not acquire profile session for %s"):format(player.Name))
		player:Kick("Your data could not be loaded safely. Please rejoin.")
		return
	end

	self._profiles[player.UserId] = loaded
	self._sessionTokens[player.UserId] = sessionToken
	self._loadedAt[player.UserId] = os.clock()
	publishSummary(player, loaded)
	local analytics = require(script.Parent.AnalyticsService)
	analytics:LogOnce(player, "session_start", 1)
	if loaded.Tutorial.Completed ~= true then
		analytics:LogOnce(player, "tutorial_start", 1)
	end
end

function PlayerDataService:_Save(player: Player, releaseLock: boolean)
	local profile = self._profiles[player.UserId]
	local sessionToken = self._sessionTokens[player.UserId]
	if profile == nil or sessionToken == nil then
		return true
	end

	local now = unixNow()
	profile.Stats.PlayTimeSeconds += math.max(0, math.floor(os.clock() - (self._loadedAt[player.UserId] or os.clock())))
	self._loadedAt[player.UserId] = os.clock()

	local ok = DataStoreAdapter.UpdateUser(player.UserId, function(existing)
		if existing and existing.SessionLock and not SessionRules.Owns(existing.SessionLock, sessionToken) then
			error("Session lock ownership changed; refusing to overwrite")
		end

		local toSave = profile
		if releaseLock then
			toSave.SessionLock = nil
		else
			toSave.SessionLock = SessionRules.Create(sessionToken, now, SESSION_LOCK_SECONDS)
		end
		return toSave
	end)

	return ok
end

function PlayerDataService:ApplyReceipt(player: Player, receiptId: string, mutator): (boolean, string)
	local current = self:RequireProfile(player)
	local ok, reason, candidate, changed, detail = ReceiptRules.BuildCandidate(current, receiptId, unixNow(), ProfileSchema.Clone, mutator)

	if not ok then
		if detail then
			warn("[Repair Empire] Receipt candidate failed: " .. detail)
		end
		return false, reason
	end
	if not changed then
		return true, reason
	end

	self._profiles[player.UserId] = candidate
	local saved = self:_Save(player, false)
	if not saved then
		self._profiles[player.UserId] = current
		self:Publish(player)
		return false, "save_failed"
	end

	self:Publish(player)
	return true, reason
end

function PlayerDataService:_Release(player: Player)
	self:_Save(player, true)
	self._profiles[player.UserId] = nil
	self._sessionTokens[player.UserId] = nil
	self._loadedAt[player.UserId] = nil
end

function PlayerDataService:Init()
	local stateRemote = ReplicatedStorage:WaitForChild("RepairEmpireRemotes"):WaitForChild("RequestPlayerState")
	assert(stateRemote:IsA("RemoteFunction"), "RequestPlayerState must be a RemoteFunction")
	stateRemote.OnServerInvoke = function(player)
		local security = require(script.Parent.SecurityService)
		if not security:Allow(player, "RequestPlayerState") then
			return { ok = false, error = "rate_limited" }
		end
		return { ok = true, state = self:GetSafeState(player) }
	end

	Players.PlayerAdded:Connect(function(player)
		self:_Load(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:_Release(player)
	end)

	for _, player in Players:GetPlayers() do
		task.spawn(function()
			self:_Load(player)
		end)
	end
end

function PlayerDataService:Start()
	task.spawn(function()
		while true do
			task.wait(AUTOSAVE_SECONDS)
			for _, player in Players:GetPlayers() do
				task.spawn(function()
					self:_Save(player, false)
				end)
			end
		end
	end)

	game:BindToClose(function()
		local pending = 0
		for _, player in Players:GetPlayers() do
			pending += 1
			task.spawn(function()
				self:_Release(player)
				pending -= 1
			end)
		end

		local deadline = os.clock() + 25
		while pending > 0 and os.clock() < deadline do
			task.wait(0.1)
		end
	end)
end

return PlayerDataService
