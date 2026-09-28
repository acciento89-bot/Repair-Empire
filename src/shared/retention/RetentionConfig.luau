--!strict

local RetentionConfig = {
	DailyJobCount = 3,
	DailyJobBonusCash = 250,
	DailyJobBonusCompanyPoints = 8,
	LoginRewards = {
		100,
		150,
		225,
		300,
		400,
		550,
		800,
	},
	Achievements = {
		first_job = { Metric = "JobsCompleted", Threshold = 1, RewardCash = 200 },
		jobs_10 = { Metric = "JobsCompleted", Threshold = 10, RewardCash = 750 },
		jobs_50 = { Metric = "JobsCompleted", Threshold = 50, RewardCash = 2_500 },
		jobs_250 = { Metric = "JobsCompleted", Threshold = 250, RewardCash = 10_000 },
		level_10 = { Metric = "Level", Threshold = 10, RewardCash = 600 },
		level_25 = { Metric = "Level", Threshold = 25, RewardCash = 1_800 },
		level_50 = { Metric = "Level", Threshold = 50, RewardCash = 6_000 },
		company_5 = { Metric = "CompanyLevel", Threshold = 5, RewardCash = 3_000 },
		company_10 = { Metric = "CompanyLevel", Threshold = 10, RewardCash = 12_000 },
		first_prestige = { Metric = "PrestigeLevel", Threshold = 1, RewardCash = 5_000 },
	},
	FeaturedCategories = {
		"plumbing",
		"heating",
		"climate",
		"energy",
	},
}

function RetentionConfig.GetDayNumber(timestamp: number?): number
	return math.floor((timestamp or DateTime.now().UnixTimestamp) / 86_400)
end

function RetentionConfig.GetFeaturedCategory(dayNumber: number): string
	local index = (dayNumber % #RetentionConfig.FeaturedCategories) + 1
	return RetentionConfig.FeaturedCategories[index]
end

return table.freeze(RetentionConfig)
