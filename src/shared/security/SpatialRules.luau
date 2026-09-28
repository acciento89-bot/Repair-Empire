--!strict

local SpatialRules = {}

local function finite(value: number): boolean
	return value == value and value > -math.huge and value < math.huge
end

function SpatialRules.IsWithinDistance(px: number, py: number, pz: number, ax: number, ay: number, az: number, maxDistance: number): boolean
	if maxDistance < 0 then
		return false
	end
	if not (finite(px) and finite(py) and finite(pz) and finite(ax) and finite(ay) and finite(az) and finite(maxDistance)) then
		return false
	end
	local dx = px - ax
	local dy = py - ay
	local dz = pz - az
	return dx * dx + dy * dy + dz * dz <= maxDistance * maxDistance
end

return table.freeze(SpatialRules)
