--!strict

local PerformanceRules = {}

function PerformanceRules.SummarizeFrameTimes(samples: { number })
	assert(#samples > 0, "at least one frame sample is required")

	local sorted = table.clone(samples)
	table.sort(sorted)

	local total = 0
	for _, value in sorted do
		assert(value >= 0, "frame time must be non-negative")
		total += value
	end

	local averageSeconds = total / #sorted
	local p95Index = math.max(1, math.ceil(#sorted * 0.95))
	local p95Seconds = sorted[p95Index]

	return {
		SampleCount = #sorted,
		AverageFrameMs = averageSeconds * 1000,
		ApproxFps = if averageSeconds > 0 then 1 / averageSeconds else math.huge,
		P95FrameMs = p95Seconds * 1000,
	}
end

return table.freeze(PerformanceRules)
