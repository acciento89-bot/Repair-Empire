return function()
	local navigation = require("../src/shared/ui/MenuNavigation")

	local expected = {
		"Jobs",
		"Co-op",
		"Tools",
		"Skills",
		"Vehicles",
		"Workshop",
		"Employees",
		"Daily",
		"Achievements",
		"Prestige",
		"Shop",
	}

	assert(#navigation.Tabs == #expected, "menu must expose the complete approved V1 hierarchy")

	for index, expectedId in expected do
		local tab = navigation.Tabs[index]
		assert(tab.Id == expectedId, ("unexpected menu tab at position %d"):format(index))
		assert(type(tab.Label) == "string" and #tab.Label > 0, ("menu tab %s needs a visible label"):format(expectedId))
	end

	assert(navigation.Tabs[4].Label == "Skill Tree", "skill navigation label must match product hierarchy")
	assert(navigation.Tabs[8].Label == "Daily Jobs", "daily navigation label must match product hierarchy")
end
