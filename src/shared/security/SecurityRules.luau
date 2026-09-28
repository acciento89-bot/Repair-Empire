--!strict

local SecurityRules = {}

function SecurityRules.ValidateId(value: any): string?
	if type(value) ~= "string" or #value == 0 or #value > 100 or string.match(value, "^[a-z0-9_]+$") == nil then
		return nil
	end
	return value
end

function SecurityRules.IsPayloadTable(value: any): boolean
	return type(value) == "table"
end

function SecurityRules.IsValidRateLimit(limitPerSecond: any): boolean
	return type(limitPerSecond) == "number" and limitPerSecond >= 1 and limitPerSecond <= 60 and limitPerSecond % 1 == 0
end

return SecurityRules
