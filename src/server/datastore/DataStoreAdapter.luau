--!strict

local DataStoreService = game:GetService("DataStoreService")

local STORE_NAME = "RepairEmpirePlayerData_v1"
local MAX_ATTEMPTS = 5

local store = DataStoreService:GetDataStore(STORE_NAME)

local DataStoreAdapter = {}

local function retry(operationName: string, callback)
	local lastError
	for attempt = 1, MAX_ATTEMPTS do
		local ok, result = pcall(callback)
		if ok then
			return true, result
		end
		lastError = result
		warn(("[Repair Empire] %s failed (attempt %d/%d): %s"):format(
			operationName,
			attempt,
			MAX_ATTEMPTS,
			tostring(result)
		))
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

return DataStoreAdapter
