--!strict

local FeedbackRules = {}

local tones = table.freeze({
	job_stage = { Pitch = 1.35, Volume = 0.22 },
	coop_stage = { Pitch = 1.35, Volume = 0.22 },
	job_completed = { Pitch = 1.05, Volume = 0.32 },
	coop_completed = { Pitch = 1.05, Volume = 0.32 },
	job_abandoned = { Pitch = 0.78, Volume = 0.24 },
	coop_left = { Pitch = 0.78, Volume = 0.24 },
})

function FeedbackRules.ForKind(kind: string)
	return tones[kind]
end

return FeedbackRules
