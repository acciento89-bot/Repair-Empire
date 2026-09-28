--!strict

local BalanceConfig = {
	Version = "v1-prelaunch-001",
	MaxPlayerLevel = 100,
	BaseJobReward = 100,
	BaseJobXp = 20,
	DistrictRewardMultipliers = {
		residential = 1.0,
		downtown = 1.8,
		industrial = 3.0,
	},
	DistrictUnlockLevels = {
		residential = 1,
		downtown = 15,
		industrial = 40,
	},
}

return table.freeze(BalanceConfig)
