--!strict

local ProfileSchema = {}

ProfileSchema.CurrentVersion = 1

local DEFAULT_PROFILE = {
	SchemaVersion = ProfileSchema.CurrentVersion,
	Level = 1,
	XP = 0,
	Cash = 0,
	CompanyPoints = 0,
	CompanyLevel = 1,
	CompanyXP = 0,
	WorkshopTier = 1,
	PrestigeLevel = 0,
	SkillPoints = 0,
	UnlockedDistricts = {
		residential = true,
	},
	OwnedTools = {
		basic_wrench = true,
	},
	EquippedTool = "basic_wrench",
	OwnedVehicles = {
		old_compact_van = true,
	},
	SelectedVehicle = "old_compact_van",
	Employees = {},
	LastPassiveTimestamp = 0,
	ProcessedReceipts = {},
	Boosts = {
		CashMultiplierUntil = 0,
	},
	Consumables = {
		InstantJobFinishes = 0,
	},
	Tutorial = {
		Step = "first_job",
		Completed = false,
	},
	Achievements = {},
	Daily = {
		LastClaimDay = 0,
		ClaimStreak = 0,
		ActiveJobDay = 0,
		CompletedDailyJobs = {},
	},
	Stats = {
		JobsCompleted = 0,
		MoneyEarned = 0,
		MoneySpent = 0,
		PlayTimeSeconds = 0,
		Prestiges = 0,
		PassiveCashEarned = 0,
	},
}

local function deepCopy(value)
	if type(value) ~= "table" then
		return value
	end

	local result = {}
	for key, nested in value do
		result[key] = deepCopy(nested)
	end
	return result
end

function ProfileSchema.Clone(profile)
	return deepCopy(profile)
end

function ProfileSchema.NewProfile()
	return deepCopy(DEFAULT_PROFILE)
end

function ProfileSchema.ApplyDefaults(profile)
	local function merge(target, defaults)
		for key, defaultValue in defaults do
			if target[key] == nil then
				target[key] = deepCopy(defaultValue)
			elseif type(defaultValue) == "table" and type(target[key]) == "table" then
				merge(target[key], defaultValue)
			end
		end
	end

	merge(profile, DEFAULT_PROFILE)
	return profile
end

return table.freeze(ProfileSchema)
