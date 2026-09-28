--!strict

local TutorialConfig = {
	Steps = {
		"first_job",
		"first_repair",
		"first_reward",
		"first_upgrade",
		"second_job",
		"second_repair",
		"company_intro",
		"complete",
	},
	Messages = {
		first_job = "Open Jobs and accept your first plumbing repair.",
		first_repair = "Travel to the marker and complete the first repair step.",
		first_reward = "Finish the repair and collect your first reward.",
		first_upgrade = "Open Tools and buy the Basic Screwdriver upgrade.",
		second_job = "Open Jobs and take the Running Toilet job to try a new repair.",
		second_repair = "Complete the Running Toilet repair.",
		company_intro = "Open Company to see your workshop and future crew.",
		complete = "",
	},
}

return table.freeze(TutorialConfig)
