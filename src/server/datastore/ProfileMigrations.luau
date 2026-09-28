--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileSchema = require(ReplicatedStorage.RepairEmpire.Shared.data.ProfileSchema)

local ProfileMigrations = {}

local migrations = {
	[0] = function(profile)
		profile.SchemaVersion = 1
		return profile
	end,
}

function ProfileMigrations.Migrate(profile)
	local version = tonumber(profile.SchemaVersion) or 0
	assert(version <= ProfileSchema.CurrentVersion, "Profile schema is newer than this server")

	while version < ProfileSchema.CurrentVersion do
		local migrate = migrations[version]
		assert(migrate ~= nil, ("Missing profile migration from version %d"):format(version))
		profile = migrate(profile)
		version = tonumber(profile.SchemaVersion) or (version + 1)
	end

	return ProfileSchema.ApplyDefaults(profile)
end

return ProfileMigrations
