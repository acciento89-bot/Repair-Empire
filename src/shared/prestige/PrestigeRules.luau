--!strict

local PrestigeRules = {}

function PrestigeRules.IsEligible(profile, config): boolean
	return profile.Level >= config.RequiredPlayerLevel
		and profile.CompanyLevel >= config.RequiredCompanyLevel
		and profile.WorkshopTier >= config.RequiredWorkshopTier
end

function PrestigeRules.ApplyReset(profile, timestamp: number)
	profile.PrestigeLevel += 1
	profile.Stats.Prestiges += 1

	profile.Level = 1
	profile.XP = 0
	profile.CompanyPoints = 0
	profile.CompanyLevel = 1
	profile.CompanyXP = 0
	profile.WorkshopTier = 1

	profile.SkillPoints = 0
	profile.Skills = {
		plumbing = 0,
		heating = 0,
		climate = 0,
		energy = 0,
	}

	profile.UnlockedDistricts = {
		residential = true,
	}

	profile.OwnedTools = {
		basic_wrench = true,
	}
	profile.EquippedTool = "basic_wrench"

	profile.OwnedVehicles = {
		old_compact_van = true,
	}
	profile.SelectedVehicle = "old_compact_van"

	profile.Employees = {}
	profile.LastPassiveTimestamp = timestamp

	return profile
end

return table.freeze(PrestigeRules)
