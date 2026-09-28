--!strict

local FeedbackRules = {}

local tones = table.freeze({
	job_stage = { Pitch = 1.35, Volume = 0.22 },
	coop_stage = { Pitch = 1.35, Volume = 0.22 },
	job_completed = { Pitch = 1.05, Volume = 0.32 },
	coop_completed = { Pitch = 1.05, Volume = 0.32 },
	job_abandoned = { Pitch = 0.78, Volume = 0.24 },
	coop_left = { Pitch = 0.78, Volume = 0.24 },
	daily_job_completed = { Pitch = 1.12, Volume = 0.3 },
	daily_reward = { Pitch = 1.18, Volume = 0.34 },
	playtime_reward = { Pitch = 1.22, Volume = 0.34 },
	achievement_claimed = { Pitch = 1.28, Volume = 0.36 },
})

function FeedbackRules.ForKind(kind: string)
	return tones[kind]
end

return FeedbackRules
