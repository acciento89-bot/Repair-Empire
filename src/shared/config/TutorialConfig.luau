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
		first_repair = "Follow the glowing ground arrows and beacon to the JOB SITE. At the target, use DO REPAIR to complete each repair step.",
		first_reward = "Finish every repair step. Your cash and XP reward is added automatically when the job is complete.",
		first_upgrade = "Open Tools and buy the Basic Screwdriver upgrade.",
		second_job = "Open Jobs and take the Running Toilet job. Follow the arrows to its new location.",
		second_repair = "Follow the route, reach the marker, then complete every repair step.",
		company_intro = "Open Company to see your workshop and future crew.",
		complete = "",
	},
}

return table.freeze(TutorialConfig)