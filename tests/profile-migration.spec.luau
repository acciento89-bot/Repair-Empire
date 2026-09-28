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
		Cash = 12_345,
		Boosts = {
			CashMultiplierUntil = 88_888,
		},
		Consumables = {
			InstantJobFinishes = 6,
		},
		ProcessedReceipts = {
			["paid-receipt"] = 777,
		},
		Achievements = {
			first_job = "claimed",
		},
		Stats = {
			JobsCompleted = 9,
			MoneyEarned = 50_000,
			MoneySpent = 20_000,
			PlayTimeSeconds = 5_000,
			Prestiges = 1,
			PassiveCashEarned = 8_000,
		},
	}
	local migratedV1 = rules.Migrate(v1)
	assert(migratedV1.SchemaVersion == 2, "v1 profile did not migrate to schema v2")
	assert(migratedV1.SkillPoints == 4, "skill point balance must survive schema migration")
	assert(migratedV1.Skills.heating == 0, "v1 migration must initialize branch ranks")
	assert(migratedV1.Cash == 12_345, "Cash must survive schema migration")
	assert(migratedV1.Boosts.CashMultiplierUntil == 88_888, "paid boost state must survive schema migration")
	assert(migratedV1.Consumables.InstantJobFinishes == 6, "paid consumables must survive schema migration")
	assert(migratedV1.ProcessedReceipts["paid-receipt"] == 777, "receipt history must survive schema migration")
	assert(migratedV1.Achievements.first_job == "claimed", "achievement state must survive schema migration")
	assert(migratedV1.Stats.MoneyEarned == 50_000, "lifetime statistics must survive schema migration")

	local futureOk = pcall(function()
		rules.Migrate({
			SchemaVersion = 999,
			Cash = 1_000_000,
		})
	end)
	assert(not futureOk, "future schema must fail closed instead of being downgraded")
end
