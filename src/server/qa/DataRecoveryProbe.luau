--!strict

local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ProfileMigrations = require(script.Parent.Parent.datastore.ProfileMigrations)
local DataStoreAdapter = require(script.Parent.Parent.datastore.DataStoreAdapter)
local SessionRules = require(ReplicatedStorage.RepairEmpire.Shared.data.SessionRules)
local ProfileSchema = require(ReplicatedStorage.RepairEmpire.Shared.data.ProfileSchema)

local DataRecoveryProbe = {}

local function now(): number
	return DateTime.now().UnixTimestamp
end

function DataRecoveryProbe.Run(): boolean
	if not RunService:IsStudio() then
		return false
	end

	local store = DataStoreService:GetDataStore(DataStoreAdapter.GetStoreName())
	local key = "qa:recovery:" .. HttpService:GenerateGUID(false)
	local passed = false

	local ok, err = pcall(function()
		local legacy = {
			SchemaVersion = 1,
			Level = 7,
			XP = 321,
			Cash = 456,
			CompanyLevel = 2,
			UnlockedDistricts = { residential = true },
			OwnedTools = { basic_wrench = true },
			EquippedTool = "basic_wrench",
			OwnedVehicles = { old_compact_van = true },
			SelectedVehicle = "old_compact_van",
		}
		store:SetAsync(key, legacy)

		local migrated = store:UpdateAsync(key, function(existing)
			assert(existing ~= nil, "legacy fixture missing")
			return ProfileMigrations.Migrate(existing)
		end)
		assert(migrated.SchemaVersion == ProfileSchema.CurrentVersion, "legacy profile did not migrate")
		assert(migrated.Skills ~= nil and migrated.Skills.plumbing == 0, "migration defaults missing")
		assert(migrated.Cash == 456 and migrated.Level == 7, "migration changed preserved values")

		local expiredToken = "expired-session"
		local expiredAt = now() - 10
		store:UpdateAsync(key, function(existing)
			existing.SessionLock = {
				Token = expiredToken,
				ExpiresAt = expiredAt,
			}
			return existing
		end)

		local acquiredToken = "recovery-session"
		local acquired = false
		local acquiredProfile = store:UpdateAsync(key, function(existing)
			if not SessionRules.CanAcquire(existing.SessionLock, now()) then
				return nil
			end
			acquired = true
			existing.SessionLock = SessionRules.Create(acquiredToken, now(), 180)
			return existing
		end)
		assert(acquired, "expired lock was not acquired")
		assert(acquiredProfile.SessionLock.Token == acquiredToken, "replacement lock token missing")

		local blockedAcquire = false
		store:UpdateAsync(key, function(existing)
			if not SessionRules.CanAcquire(existing.SessionLock, now()) then
				blockedAcquire = true
				return nil
			end
			error("active foreign lock should not be acquirable")
		end)
		assert(blockedAcquire, "active foreign lock acquisition was not blocked")

		local before = store:GetAsync(key)
		local writeBlocked = false
		store:UpdateAsync(key, function(existing)
			if not SessionRules.CanWrite(existing.SessionLock, "foreign-session") then
				writeBlocked = true
				return nil
			end
			existing.Cash = 999999
			return existing
		end)
		local after = store:GetAsync(key)
		assert(writeBlocked, "foreign-lock write was not blocked")
		assert(after.Cash == before.Cash, "blocked foreign write changed persisted value")
		assert(after.SessionLock.Token == acquiredToken, "blocked write changed lock ownership")

		passed = true
	end)

	local cleanupOk, cleanupErr = pcall(function()
		store:RemoveAsync(key)
	end)
	if not cleanupOk then
		warn("[Repair Empire] DataRecoveryProbe cleanup failed: " .. tostring(cleanupErr))
	end

	if not ok then
		warn("[Repair Empire] DataRecoveryProbe failed: " .. tostring(err))
		return false
	end

	if passed then
		print(
			("[Repair Empire] DataRecoveryProbe passed store=%s migration=v%d expiredLock=acquired foreignAcquire=blocked foreignWrite=blocked cleanup=%s"):format(
				DataStoreAdapter.GetStoreName(),
				ProfileSchema.CurrentVersion,
				tostring(cleanupOk)
			)
		)
	end
	return passed
end

return DataRecoveryProbe
