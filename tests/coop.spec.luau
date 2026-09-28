return function()
	local contracts = require("../src/shared/coop/CoopContracts")
	local count = 0
	for _ in contracts do
		count += 1
	end
	assert(count == 4, "V1 must expose exactly four launch co-op contracts")
	assert(contracts.large_boiler_breakdown == true, "heating co-op contract missing")
	assert(contracts.multi_unit_climate_contract == true, "climate co-op contract missing")
end
