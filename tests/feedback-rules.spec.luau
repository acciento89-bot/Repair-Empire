return function()
	local rules = require("../src/shared/ui/FeedbackRules")

	local stage = rules.ForKind("job_stage")
	assert(stage ~= nil and stage.Pitch > 1, "stage feedback must use a distinct positive cue")

	local complete = rules.ForKind("job_completed")
	assert(complete ~= nil and complete.Volume > stage.Volume, "completion cue must be stronger than stage cue")

	local abandoned = rules.ForKind("job_abandoned")
	assert(abandoned ~= nil and abandoned.Pitch < 1, "abandon cue must be audibly distinct")
	assert(rules.ForKind("unknown") == nil, "unknown events must not invent feedback")
end
