return function()
	local guardrails = require("../src/shared/balance/BalanceGuardrails")
	local tools = require("../src/shared/tools/ToolDefinitions")
	local vehicles = require("../src/shared/vehicles/VehicleDefinitions")
	local company = require("../src/shared/config/CompanyConfig")
	local employees = require("../src/shared/company/EmployeeDefinitions")
	local prestige = require("../src/shared/prestige/PrestigeConfig")

	local vehicleCosts = {}
	for _, definition in vehicles.List do
		if definition.Cost > 0 then
			table.insert(vehicleCosts, definition.Cost)
		end
	end
	assert(guardrails.IsStrictlyIncreasing(vehicleCosts), "vehicle costs must increase with progression")

	local toolFamilyCosts = {}
	for _, family in { "wrench", "screwdriver", "pliers", "drain", "diagnostic" } do
		local costs = {}
		for _, definition in tools.List do
			if definition.Family == family then
				table.insert(costs, definition.Cost)
			end
		end
		toolFamilyCosts[family] = costs
		assert(guardrails.IsStrictlyIncreasing(costs), family .. " costs must increase by tier")
	end

	local maxPassiveRate = 0
	for _, definition in employees.List do
		maxPassiveRate = math.max(maxPassiveRate, definition.CashPerMinute)
	end
	local cappedOfflineValue = guardrails.PassiveCapValue(maxPassiveRate, company.OfflinePassiveCapMinutes)
	assert(cappedOfflineValue < 100_000, "single-employee offline cap is too large for launch economy")
	assert(prestige.GetRewardMultiplier(100) <= 1.5, "prestige multiplier must stay bounded")
end
