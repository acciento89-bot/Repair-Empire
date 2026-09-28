--!strict

local ProfileSchema
if script ~= nil then
	ProfileSchema = require(script.Parent.ProfileSchema)
else
	ProfileSchema = require("./ProfileSchema")
end

local ProfileMigrationRules = {}

local migrations = {
	[0] = function(profile)
		profile.SchemaVersion = 1
		return profile
	end,
	[1] = function(profile)
		profile.Skills = profile.Skills or {
			plumbing = 0,
			heating = 0,
			climate = 0,
			energy = 0,
		}
		profile.SchemaVersion = 2
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
