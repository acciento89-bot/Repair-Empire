--!strict

local ProgressionConfig = {}

ProgressionConfig.MaxPlayerLevel = 100

function ProgressionConfig.XpForNextLevel(level: number): number
	return math.floor(100 + (level - 1) * 35 + ((level - 1) ^ 1.35) * 8)
end

ProgressionConfig.CompanyLevelThresholds = {
	0,
	500,
	1_500,
	3_500,
	7_000,
	12_000,
	20_000,
	32_000,
	48_000,
	70_000,
}

ProgressionConfig.DistrictUnlockLevels = {
	residential = 1,
	downtown = 15,
	industrial = 40,
}

return table.freeze(ProgressionConfig)
