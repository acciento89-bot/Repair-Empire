return function()
	local config = require("../src/shared/prestige/PrestigeConfig")
	local rules = require("../src/shared/prestige/PrestigeRules")
	local ProfileSchema = require("../src/shared/data/ProfileSchema")

	local profile = ProfileSchema.NewProfile()
	assert(not rules.IsEligible(profile, config), "fresh profile must not be prestige eligible")
	profile.Level = config.RequiredPlayerLevel
	profile.CompanyLevel = config.RequiredCompanyLevel
	profile.WorkshopTier = config.RequiredWorkshopTier
	assert(rules.IsEligible(profile, config), "fully progressed profile must be prestige eligible")

	profile.Cash = 123_456
	profile.Consumables.InstantJobFinishes = 7
	profile.Boosts.CashMultiplierUntil = 99_999
	profile.Achievements.first_prestige = "unlocked"
	profile.ProcessedReceipts["receipt-paid-1"] = 123
	profile.AnalyticsFlags.first_purchase = true
	profile.Daily.ClaimStreak = 4
	profile.Tutorial.Completed = true

	profile.Level = 100
	profile.XP = 88
	profile.CompanyPoints = 9_000
	profile.CompanyLevel = 10
	profile.CompanyXP = 77
	profile.WorkshopTier = 5
	profile.SkillPoints = 11
	profile.Skills.plumbing = 5
	profile.Skills.energy = 4
	profile.UnlockedDistricts.downtown = true
	profile.UnlockedDistricts.industrial = true
	profile.OwnedTools.master_wrench = true
	profile.EquippedTool = "master_wrench"
	profile.OwnedVehicles.service_truck = true
	profile.SelectedVehicle = "service_truck"
	profile.Employees.crew_lead_energy = 1

	profile.Stats.JobsCompleted = 250
	profile.Stats.MoneyEarned = 999_000
	profile.Stats.MoneySpent = 555_000
	profile.Stats.PlayTimeSeconds = 77_777
	profile.Stats.PassiveCashEarned = 44_000
	profile.PrestigeLevel = 2
	profile.Stats.Prestiges = 2

	rules.ApplyReset(profile, 12_345)

	assert(profile.PrestigeLevel == 3, "prestige level must increment exactly once")
	assert(profile.Stats.Prestiges == 3, "lifetime prestige stat must increment exactly once")
	assert(profile.Level == 1 and profile.XP == 0, "player progression must reset")
	assert(profile.CompanyLevel == 1 and profile.CompanyPoints == 0 and profile.CompanyXP == 0, "company progression must reset")
	assert(profile.WorkshopTier == 1, "workshop tier must reset")
	assert(profile.SkillPoints == 0 and profile.Skills.plumbing == 0 and profile.Skills.energy == 0, "skill tree must reset")
	assert(profile.UnlockedDistricts.residential == true, "residential district must remain unlocked")
	assert(profile.UnlockedDistricts.downtown == nil and profile.UnlockedDistricts.industrial == nil, "higher districts must reset")
	assert(profile.OwnedTools.basic_wrench == true and profile.OwnedTools.master_wrench == nil, "tool progression must reset")
	assert(profile.EquippedTool == "basic_wrench", "basic wrench must be re-equipped")
	assert(profile.OwnedVehicles.old_compact_van == true and profile.OwnedVehicles.service_truck == nil, "vehicle progression must reset")
	assert(profile.SelectedVehicle == "old_compact_van", "starter vehicle must be selected")
	assert(next(profile.Employees) == nil, "employees must reset")
	assert(profile.LastPassiveTimestamp == 12_345, "passive timestamp must reset to prestige time")

	assert(profile.Cash == 123_456, "Cash must survive Prestige")
	assert(profile.Consumables.InstantJobFinishes == 7, "paid consumables must survive Prestige")
	assert(profile.Boosts.CashMultiplierUntil == 99_999, "active paid boosts must survive Prestige")
	assert(profile.Achievements.first_prestige == "unlocked", "achievement state must survive Prestige")
	assert(profile.ProcessedReceipts["receipt-paid-1"] == 123, "receipt history must survive Prestige")
	assert(profile.AnalyticsFlags.first_purchase == true, "analytics dedupe state must survive Prestige")
	assert(profile.Daily.ClaimStreak == 4, "daily retention state must survive Prestige")
	assert(profile.Tutorial.Completed == true, "completed tutorial must not restart after Prestige")
	assert(profile.Stats.JobsCompleted == 250, "lifetime job count must survive Prestige")
	assert(profile.Stats.MoneyEarned == 999_000, "lifetime earned Cash must survive Prestige")
	assert(profile.Stats.MoneySpent == 555_000, "lifetime spent Cash must survive Prestige")
	assert(profile.Stats.PlayTimeSeconds == 77_777, "lifetime playtime must survive Prestige")
	assert(profile.Stats.PassiveCashEarned == 44_000, "lifetime passive Cash must survive Prestige")
end
