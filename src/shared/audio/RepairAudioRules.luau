--!strict

local RepairAudioRules = {}

export type ActionProfile = {
	Kind: string,
	SoundId: string?,
	PlaybackOffset: number,
	VolumeMultiplier: number,
}

local DIAGNOSTIC = {
	Kind = "diagnostic",
	SoundId = "rbxasset://sounds/electronicpingshort.wav",
	PlaybackOffset = 0.18,
	VolumeMultiplier = 0.82,
}

local FLUID = {
	Kind = "fluid",
	SoundId = "rbxasset://sounds/impact_water.mp3",
	PlaybackOffset = 0.08,
	VolumeMultiplier = 0.86,
}

local MECHANICAL = {
	Kind = "mechanical",
	SoundId = nil,
	PlaybackOffset = -0.06,
	VolumeMultiplier = 1.0,
}

local GENERAL = {
	Kind = "general",
	SoundId = nil,
	PlaybackOffset = 0,
	VolumeMultiplier = 0.92,
}

local function contains(action: string, token: string): boolean
	return string.find(action, token, 1, true) ~= nil
end

function RepairAudioRules.ForAction(action: string): ActionProfile
	local normalized = string.lower(action)

	if contains(normalized, "inspect")
		or contains(normalized, "test")
		or contains(normalized, "measure")
		or contains(normalized, "diagnose")
		or contains(normalized, "check")
	then
		return DIAGNOSTIC
	end

	if contains(normalized, "flush")
		or contains(normalized, "clean")
		or contains(normalized, "clear")
		or contains(normalized, "drain")
		or contains(normalized, "bleed")
	then
		return FLUID
	end

	if contains(normalized, "replace")
		or contains(normalized, "install")
		or contains(normalized, "tighten")
		or contains(normalized, "repair")
		or contains(normalized, "remove")
		or contains(normalized, "fit")
	then
		return MECHANICAL
	end

	return GENERAL
end

return table.freeze(RepairAudioRules)
