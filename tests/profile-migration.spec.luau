return function()
	local rules = require("../src/shared/data/ProfileMigrationRules")

	local legacy = {
		SchemaVersion = 0,
		Level = 7,
		Cash = 321,
	}
	local migrated = rules.Migrate(legacy)

	assert(migrated.SchemaVersion == 2, "legacy profile did not migrate to current schema")
	assert(migrated.Level == 7, "migration must preserve existing level")
	assert(migrated.Cash == 321, "migration must preserve existing cash")
	assert(migrated.CompanyLevel == 1, "migration must apply missing defaults")
	assert(migrated.UnlockedDistricts.residential == true, "migration must restore required default unlock")
	assert(migrated.Skills.plumbing == 0, "migration must add plumbing skill branch")
	assert(migrated.Skills.energy == 0, "migration must add energy skill branch")

	local v1 = {
		SchemaVersion = 1,
		Level = 20,
		SkillPoints = 4,
	}
	local migratedV1 = rules.Migrate(v1)
	assert(migratedV1.SchemaVersion == 2, "v1 profile did not migrate to schema v2")
	assert(migratedV1.SkillPoints == 4, "skill point balance must survive schema migration")
	assert(migratedV1.Skills.heating == 0, "v1 migration must initialize branch ranks")
end
