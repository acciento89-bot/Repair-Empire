--!strict

local ProfileSchema = require(script.Parent.ProfileSchema)

local ProfileMigrationRules = {}

local migrations = {
	[0] = function(profile)
		profile.SchemaVersion = 1
		return profile
	end,
}

function ProfileMigrationRules.Migrate(profile)
	local version = tonumber(profile.SchemaVersion) or 0
	assert(version <= ProfileSchema.CurrentVersion, "Profile schema is newer than this build")

	while version < ProfileSchema.CurrentVersion do
		local migrate = migrations[version]
		assert(migrate ~= nil, ("Missing profile migration from version %d"):format(version))
		profile = migrate(profile)
		version = tonumber(profile.SchemaVersion) or (version + 1)
	end

	return ProfileSchema.ApplyDefaults(profile)
end

return ProfileMigrationRules
