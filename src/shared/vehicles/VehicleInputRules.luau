--!strict

local VehicleInputRules = {}

export type Input = {
	Throttle: number,
	Steer: number,
}

local function validAxis(value: any): boolean
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge and value >= -1 and value <= 1
end

function VehicleInputRules.Normalize(payload: any): Input?
	if type(payload) ~= "table" then
		return nil
	end
	if not validAxis(payload.throttle) or not validAxis(payload.steer) then
		return nil
	end
	return {
		Throttle = payload.throttle,
		Steer = payload.steer,
	}
end

return table.freeze(VehicleInputRules)
