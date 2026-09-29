--!strict

local AudioCatalog = {}

AudioCatalog.BuiltIn = table.freeze({
	PlasticTool = "rbxasset://sounds/action_footsteps_plastic.mp3",
	GetUp = "rbxasset://sounds/action_get_up.mp3",
	Falling = "rbxasset://sounds/action_falling.ogg",
	Swim = "rbxasset://sounds/action_swim.mp3",
	WaterImpact = "rbxasset://sounds/impact_water.mp3",
	VolumeSlider = "rbxasset://sounds/volume_slider.ogg",
	ElectronicPing = "rbxasset://sounds/electronicpingshort.wav",
})

AudioCatalog.ToolFamily = table.freeze({
	wrench = { Sound = AudioCatalog.BuiltIn.PlasticTool, PlaybackSpeed = 1.35, Volume = 0.16 },
	screwdriver = { Sound = AudioCatalog.BuiltIn.VolumeSlider, PlaybackSpeed = 1.55, Volume = 0.12 },
	pliers = { Sound = AudioCatalog.BuiltIn.GetUp, PlaybackSpeed = 1.75, Volume = 0.1 },
	drain = { Sound = AudioCatalog.BuiltIn.Swim, PlaybackSpeed = 1.3, Volume = 0.12 },
	diagnostic_meter = { Sound = AudioCatalog.BuiltIn.VolumeSlider, PlaybackSpeed = 1.8, Volume = 0.1 },
	heating_service = { Sound = AudioCatalog.BuiltIn.PlasticTool, PlaybackSpeed = 1.1, Volume = 0.16 },
	pressure_service = { Sound = AudioCatalog.BuiltIn.WaterImpact, PlaybackSpeed = 1.2, Volume = 0.12 },
	climate_service = { Sound = AudioCatalog.BuiltIn.Falling, PlaybackSpeed = 1.45, Volume = 0.09 },
	energy_diagnostic = { Sound = AudioCatalog.BuiltIn.VolumeSlider, PlaybackSpeed = 1.9, Volume = 0.11 },
})

AudioCatalog.Vehicle = table.freeze({
	Engine = AudioCatalog.BuiltIn.VolumeSlider,
	Road = AudioCatalog.BuiltIn.Falling,
	Workshop = AudioCatalog.BuiltIn.VolumeSlider,
})

return table.freeze(AudioCatalog)
