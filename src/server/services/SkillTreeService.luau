--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SkillTreeConfig = require(ReplicatedStorage.RepairEmpire.Shared.progression.SkillTreeConfig)

local SkillTreeService = {
	Name = "SkillTreeService",
	Dependencies = { "PlayerDataService", "SecurityService" },
}

local function remote(name: string): RemoteFunction
	local instance = ReplicatedStorage:WaitForChild("RepairEmpireRemotes"):WaitForChild(name)
	assert(instance:IsA("RemoteFunction"), name .. " must be a RemoteFunction")
	return instance
end

function SkillTreeService:GetRank(player: Player, categoryId: string): number
	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	return profile.Skills[categoryId] or 0
end

function SkillTreeService:GetSpeedMultiplier(player: Player, categoryId: string): number
	return SkillTreeConfig.SpeedMultiplier(self:GetRank(player, categoryId))
end

function SkillTreeService:GetCashMultiplier(player: Player, categoryId: string): number
	return SkillTreeConfig.CashMultiplier(self:GetRank(player, categoryId))
end

function SkillTreeService:GetXPMultiplier(player: Player, categoryId: string): number
	return SkillTreeConfig.XPMultiplier(self:GetRank(player, categoryId))
end

function SkillTreeService:Purchase(player: Player, categoryId: any)
	local security = require(script.Parent.SecurityService)
	if not security:Allow(player, "PurchaseSkill") then
		return { ok = false, error = "rate_limited" }
	end
	if type(categoryId) ~= "string" or SkillTreeConfig.Branches[categoryId] == nil then
		return { ok = false, error = "invalid_branch" }
	end

	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	local currentRank = profile.Skills[categoryId] or 0
	if currentRank >= SkillTreeConfig.MaxRankPerBranch then
		return { ok = false, error = "max_rank" }
	end
	if profile.SkillPoints <= 0 then
		return { ok = false, error = "no_skill_points" }
	end

	profile.SkillPoints -= 1
	profile.Skills[categoryId] = currentRank + 1
	dataService:Publish(player)

	return {
		ok = true,
		category = categoryId,
		rank = profile.Skills[categoryId],
		skillPoints = profile.SkillPoints,
	}
end

function SkillTreeService:Init()
	remote("PurchaseSkill").OnServerInvoke = function(player, categoryId)
		return self:Purchase(player, categoryId)
	end
end

function SkillTreeService:Start() end

return SkillTreeService
