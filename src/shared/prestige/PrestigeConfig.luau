--!strict

local PrestigeConfig = {
	RequiredPlayerLevel = 100,
	RequiredCompanyLevel = 10,
	RequiredWorkshopTier = 5,
	RewardBonusPerPrestige = 0.05,
	MaxRewardBonus = 0.50,
	ConfirmationLifetimeSeconds = 60,
}

function PrestigeConfig.GetRewardMultiplier(prestigeLevel: number): number
	local bonus = math.min(prestigeLevel * PrestigeConfig.RewardBonusPerPrestige, PrestigeConfig.MaxRewardBonus)
	return 1 + bonus
end

return table.freeze(PrestigeConfig)
