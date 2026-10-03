return function()
	local rules = require("../src/shared/ui/UiLayoutRules")

	assert(rules.Classify(390, 844, true) == "small_phone", "phone portrait classification failed")
	assert(rules.Classify(844, 390, true) == "small_phone", "phone landscape classification failed")
	assert(rules.Classify(1024, 1366, true) == "tablet", "tablet classification failed")
	assert(rules.Classify(1920, 1080, false) == "desktop", "desktop classification failed")

	local phoneMenu = rules.GetMenuMetrics(390, 844, true)
	assert(phoneMenu.PanelScaleX <= 0.96 and phoneMenu.PanelScaleY <= 0.92, "phone menu exceeds viewport guardrails")
	assert(phoneMenu.MaxWidth <= 374, "phone menu maximum width ignores safe margin")

	local phoneHud = rules.GetHudMetrics(844, 390, true)
	assert(phoneHud.StatusWidth <= 500, "phone status must leave substantial gameplay space")
	assert(phoneHud.StatusHeight >= 48, "phone status must support two readable lines")
	assert(phoneHud.TutorialY >= 62, "phone tutorial must sit below compact status")

	local phoneInteraction = rules.GetInteractionOffsets(390, 844, true)
	assert(phoneInteraction.Bottom >= 180, "phone repair action risks overlapping default jump control")
	assert(phoneInteraction.Width <= 220, "phone repair action is oversized")

	local desktopInteraction = rules.GetInteractionOffsets(1920, 1080, false)
	assert(desktopInteraction.Bottom < phoneInteraction.Bottom, "desktop controls should not use mobile jump clearance")
end
