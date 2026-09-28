--!strict

local PassRules = {}

function PassRules.CashMultiplier(hasDoubleCash: boolean, boostActive: boolean): number
	if hasDoubleCash or boostActive then
		return 2
	end
	return 1
end

function PassRules.EmployeeSlots(baseSlots: number, hasExtraEmployeeSlot: boolean): number
	return baseSlots + (if hasExtraEmployeeSlot then 1 else 0)
end

function PassRules.VehicleSlots(hasExtraVehicleSlot: boolean): number
	return if hasExtraVehicleSlot then 2 else 1
end

return table.freeze(PassRules)
