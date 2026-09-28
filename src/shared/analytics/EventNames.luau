--!strict

local EventNames = {
	SessionStart = "session_start",
	TutorialStart = "tutorial_start",
	FirstJobAccepted = "first_job_accepted",
	FirstJobCompleted = "first_job_completed",
	FirstUpgradeBought = "first_upgrade_bought",
	District2Unlocked = "district_2_unlocked",
	CompanySystemOpened = "company_system_opened",
	FirstEmployeeHired = "first_employee_hired",
	FirstCoopJobCompleted = "first_coop_job_completed",
	PrestigeAvailable = "prestige_available",
	PrestigeCompleted = "prestige_completed",
	JobAccepted = "job_accepted",
	JobCompleted = "job_completed",
	JobAbandoned = "job_abandoned",
	PurchaseGranted = "purchase_granted",
}

return table.freeze(EventNames)
