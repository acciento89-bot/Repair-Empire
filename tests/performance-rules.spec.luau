return function()
	local rules = require("../src/shared/performance/PerformanceRules")

	local summary = rules.SummarizeFrameTimes({ 0.010, 0.020, 0.030, 0.040 })
	assert(summary.SampleCount == 4, "sample count changed")
	assert(math.abs(summary.AverageFrameMs - 25) < 0.0001, "average frame time changed")
	assert(math.abs(summary.ApproxFps - 40) < 0.0001, "average FPS changed")
	assert(math.abs(summary.P95FrameMs - 40) < 0.0001, "p95 frame time changed")

	local single = rules.SummarizeFrameTimes({ 0.016 })
	assert(math.abs(single.P95FrameMs - 16) < 0.0001, "single-sample p95 changed")

	local emptyOk = pcall(function()
		rules.SummarizeFrameTimes({})
	end)
	assert(not emptyOk, "empty performance sample set must reject")
end
