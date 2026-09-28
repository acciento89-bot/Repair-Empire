--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TutorialConfig = require(ReplicatedStorage.RepairEmpire.Shared.config.TutorialConfig)

local TutorialService = {
	Name = "TutorialService",
	Dependencies = { "PlayerDataService", "AnalyticsService" },
}

function TutorialService:Init() end
function TutorialService:Start() end

function TutorialService:GetStep(player: Player)
	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	return profile.Tutorial.Step
end

function TutorialService:Advance(player: Player, expectedStep: string)
	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	if profile.Tutorial.Step ~= expectedStep then
		return false
	end

	local index = table.find(TutorialConfig.Steps, expectedStep)
	if index == nil then
		return false
	end

	local nextStep = TutorialConfig.Steps[index + 1] or "complete"
	profile.Tutorial.Step = nextStep
	profile.Tutorial.Completed = nextStep == "complete"
	dataService:Publish(player)
	local analytics = require(script.Parent.AnalyticsService)
	analytics:LogOnboardingStep(player, index, expectedStep)
	return true
end

return TutorialService
