--!strict

local SkillTreeConfig = {
	PointEveryLevels = 5,
	MaxRankPerBranch = 5,
	Branches = {
		plumbing = {
			DisplayName = "Plumbing",
		},
		heating = {
			DisplayName = "Heating",
		},
		climate = {
			DisplayName = "Climate",
		},
		energy = {
			DisplayName = "Energy",
		},
	},
}

function SkillTreeConfig.TotalPointsByLevel(level: number): number
	return math.floor(math.max(0, level) / SkillTreeConfig.PointEveryLevels)
end

function SkillTreeConfig.SpeedMultiplier(rank: number): number
	return math.max(0.9, 1 - math.clamp(rank, 0, SkillTreeConfig.MaxRankPerBranch) * 0.02)
end

function SkillTreeConfig.CashMultiplier(rank: number): number
	return 1 + math.clamp(rank, 0, SkillTreeConfig.MaxRankPerBranch) * 0.01
end

function SkillTreeConfig.XPMultiplier(rank: number): number
	return 1 + math.clamp(rank, 0, SkillTreeConfig.MaxRankPerBranch) * 0.01
end

return table.freeze(SkillTreeConfig)
