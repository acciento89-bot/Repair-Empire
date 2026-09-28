--!strict

local ReadinessRules = {}

local function add(blockers, code: string, detail: string)
	table.insert(blockers, {
		Code = code,
		Detail = detail,
	})
end

function ReadinessRules.Evaluate(platformConfig, monetizationConfig)
	local blockers = {}

	if platformConfig.UniverseId == nil then
		add(blockers, "missing_universe_id", "Production Universe ID is not configured.")
	end
	if platformConfig.ProductionStartPlaceId == nil then
		add(blockers, "missing_production_place_id", "Production Start Place ID is not configured.")
	end
	if #platformConfig.DevelopmentPlaceIds == 0 then
		add(blockers, "missing_development_place", "No development/test Place ID is configured.")
	end

	for key, config in monetizationConfig.GamePasses do
		if config.Id == nil then
			add(blockers, "missing_gamepass_id:" .. key, "Game Pass ID is not configured for " .. key .. ".")
		end
	end

	for key, config in monetizationConfig.DeveloperProducts do
		if config.Id == nil then
			add(blockers, "missing_product_id:" .. key, "Developer Product ID is not configured for " .. key .. ".")
		end
	end

	return {
		ReadyForSandbox = #blockers == 0,
		Blockers = blockers,
	}
end

return ReadinessRules
