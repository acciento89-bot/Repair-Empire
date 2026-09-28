return function()
	local rules = require("../src/shared/data/ProfileMigrationRules")

	local legacy = {
		SchemaVersion = 0,
		Level = 7,
		Cash = 321,
	}
	local migrated = rules.Migrate(legacy)

	assert(migrated.SchemaVersion == 1, "legacy profile did not migrate to schema v1")
	assert(migrated.Level == 7, "migration must preserve existing level")
	assert(migrated.Cash == 321, "migration must preserve existing cash")
	assert(migrated.CompanyLevel == 1, "migration must apply missing defaults")
	assert(migrated.UnlockedDistricts.residential == true, "migration must restore required default unlock")
end
