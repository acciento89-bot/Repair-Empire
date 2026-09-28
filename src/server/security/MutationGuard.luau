--!strict

local MutationGuard = {}

local active: { [number]: { [string]: boolean } } = {}

function MutationGuard.IsBusy(userId: number, key: string): boolean
	local user = active[userId]
	return user ~= nil and user[key] == true
end

function MutationGuard.TryBegin(userId: number, key: string): boolean
	assert(type(userId) == "number", "userId must be numeric")
	assert(type(key) == "string" and #key > 0, "mutation key required")

	local user = active[userId]
	if user == nil then
		user = {}
		active[userId] = user
	end
	if user[key] == true then
		return false
	end
	user[key] = true
	return true
end

function MutationGuard.Finish(userId: number, key: string)
	local user = active[userId]
	if user == nil then
		return
	end
	user[key] = nil
	if next(user) == nil then
		active[userId] = nil
	end
end

function MutationGuard.Clear(userId: number)
	active[userId] = nil
end

function MutationGuard.TryRun(userId: number, key: string, callback)
	if not MutationGuard.TryBegin(userId, key) then
		return false, nil
	end

	local ok, result = pcall(callback)
	MutationGuard.Finish(userId, key)
	if not ok then
		error(result, 0)
	end
	return true, result
end

return MutationGuard
