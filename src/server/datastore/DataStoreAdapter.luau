--!strict

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local PlatformConfig = require(ReplicatedStorage.RepairEmpire.Shared.config.PlatformConfig)

local BASE_STORE_NAME = "RepairEmpirePlayerData_v1"
local MAX_ATTEMPTS = 5

local environment = PlatformConfig.EnvironmentForPlace(game.PlaceId, RunService:IsStudio())
local storeName = ("%s_%s"):format(BASE_STORE_NAME, environment)
local store = DataStoreService:GetDataStore(storeName)

local DataStoreAdapter = {}

local function retry(operationName: string, callback)
	local lastError
	for attempt = 1, MAX_ATTEMPTS do
		local ok, result = pcall(callback)
		if ok then
			return true, result
		end
		lastError = result
		warn(("[Repair Empire] %s failed (attempt %d/%d): %s"):format(operationName, attempt, MAX_ATTEMPTS, tostring(result)))
		if attempt < MAX_ATTEMPTS then
			task.wait(math.min(2 ^ (attempt - 1), 8))
		end
	end
	return false, lastError
end

function DataStoreAdapter.UpdateUser(userId: number, transform)
	local key = ("player:%d"):format(userId)
	return retry("UpdateAsync", function()
		return store:UpdateAsync(key, transform)
	end)
end

function DataStoreAdapter.GetStoreName(): string
	return storeName
end

return DataStoreAdapter
