--!strict

local UiLayoutRules = {}

function UiLayoutRules.Classify(width: number, height: number, touchEnabled: boolean): string
	local shortest = math.min(width, height)
	if touchEnabled and shortest < 600 then
		return "small_phone"
	end
	if touchEnabled then
		return "tablet"
	end
	return "desktop"
end

function UiLayoutRules.GetMenuMetrics(width: number, height: number, touchEnabled: boolean)
	local class = UiLayoutRules.Classify(width, height, touchEnabled)
	if class == "small_phone" then
		return {
			Class = class,
			PanelScaleX = 0.96,
			PanelScaleY = 0.92,
			MaxWidth = math.max(300, width - 16),
			MaxHeight = math.max(300, height - 16),
			TabWidth = 102,
			ButtonHeight = 52,
		}
	elseif class == "tablet" then
		return {
			Class = class,
			PanelScaleX = 0.88,
			PanelScaleY = 0.86,
			MaxWidth = math.min(920, width - 32),
			MaxHeight = math.min(760, height - 32),
			TabWidth = 112,
			ButtonHeight = 52,
		}
	end

	return {
		Class = class,
		PanelScaleX = 0.78,
		PanelScaleY = 0.82,
		MaxWidth = math.min(980, width - 48),
		MaxHeight = math.min(760, height - 48),
		TabWidth = 116,
		ButtonHeight = 50,
	}
end

function UiLayoutRules.GetInteractionOffsets(width: number, height: number, touchEnabled: boolean)
	local class = UiLayoutRules.Classify(width, height, touchEnabled)
	if class == "small_phone" then
		return {
			Right = 18,
			Bottom = 210,
			InstantGap = 70,
			Width = math.min(220, math.floor(width * 0.46)),
		}
	elseif class == "tablet" then
		return {
			Right = 24,
			Bottom = 180,
			InstantGap = 70,
			Width = 220,
		}
	end

	return {
		Right = 24,
		Bottom = 92,
		InstantGap = 72,
		Width = 220,
	}
end

function UiLayoutRules.GetHudMetrics(width: number, height: number, touchEnabled: boolean)
	local class = UiLayoutRules.Classify(width, height, touchEnabled)
	if class == "small_phone" then
		return {
			TutorialWidth = math.min(330, width - 32),
			ObjectiveWidth = math.min(260, width - 32),
			ObjectiveHeight = 68,
			MenuTop = 16,
		}
	end

	return {
		TutorialWidth = math.min(380, width - 48),
		ObjectiveWidth = math.min(320, width - 48),
		ObjectiveHeight = 72,
		MenuTop = 16,
	}
end

return table.freeze(UiLayoutRules)
