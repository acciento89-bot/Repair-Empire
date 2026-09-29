return function()
	local catalog = require("../src/shared/audio/AudioCatalog")
	local tools = require("../src/shared/tools/ToolDefinitions")

	for name, soundId in catalog.BuiltIn do
		assert(type(soundId) == "string" and soundId:match("^rbxasset://sounds/"), "invalid built-in audio path for " .. name)
		assert(not soundId:find("bass%.wav"), "removed/unavailable bass.wav must not return")
	end

	for _, definition in tools.List do
		local audio = catalog.ToolFamily[definition.Family]
		assert(audio ~= nil, "missing tool-family audio for " .. definition.Family)
		assert(type(audio.Sound) == "string", "tool-family audio missing sound for " .. definition.Family)
		assert(audio.Volume > 0 and audio.Volume <= 0.3, "tool-family audio volume out of range")
		assert(audio.PlaybackSpeed >= 0.4 and audio.PlaybackSpeed <= 2.0, "tool-family audio pitch out of range")
	end

	assert(catalog.Vehicle.Engine ~= catalog.Vehicle.Road, "engine and road layers must be distinct")
end
