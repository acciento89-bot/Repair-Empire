return function()
	local rules = require("../src/shared/audio/RepairAudioRules")

	assert(rules.ForAction("inspect_filter").Kind == "diagnostic", "inspect must use diagnostic audio")
	assert(rules.ForAction("measure_pressure").Kind == "diagnostic", "measure must use diagnostic audio")
	assert(rules.ForAction("flush_system").Kind == "fluid", "flush must use fluid audio")
	assert(rules.ForAction("bleed_radiator").Kind == "fluid", "bleed must use fluid audio")
	assert(rules.ForAction("tighten_fitting").Kind == "mechanical", "tighten must use mechanical audio")
	assert(rules.ForAction("replace_pump").Kind == "mechanical", "replace must use mechanical audio")
	assert(rules.ForAction("continue").Kind == "general", "unknown action must use general audio")
end
