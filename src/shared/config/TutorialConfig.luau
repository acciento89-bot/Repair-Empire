--!strict

local TutorialConfig = {
	Steps = {
		"first_job",
		"first_repair",
		"first_reward",
		"first_upgrade",
		"company_intro",
		"complete",
	},
	Messages = {
		first_job = "Open Jobs and accept your first plumbing repair.",
		first_repair = "Travel to the marker and complete the first repair step.",
		first_reward = "Finish the repair and collect your first reward.",
		first_upgrade = "Open Tools and buy your first upgrade.",
		company_intro = "Open Company to see your workshop and future crew.",
		complete = "",
	},
}

return table.freeze(TutorialConfig)
