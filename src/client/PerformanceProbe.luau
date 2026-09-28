--!strict

local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PerformanceRules = require(ReplicatedStorage.RepairEmpire.Shared.performance.PerformanceRules)

local PerformanceProbe = {}

function PerformanceProbe.Start()
	if not RunService:IsStudio() then
		return
	end

	task.spawn(function()
		task.wait(2)

		local samples = {}
		for _ = 1, 120 do
			local dt = RunService.RenderStepped:Wait()
			table.insert(samples, dt)
		end

		local summary = PerformanceRules.SummarizeFrameTimes(samples)
		local memoryMb = -1
		local ok, result = pcall(function()
			return Stats:GetTotalMemoryUsageMb()
		end)
		if ok and type(result) == "number" then
			memoryMb = result
		end

		print(
			("[Repair Empire] StudioClientBaseline samples=%d avgFrameMs=%.2f p95FrameMs=%.2f approxFps=%.1f memoryMb=%.1f"):format(
				summary.SampleCount,
				summary.AverageFrameMs,
				summary.P95FrameMs,
				summary.ApproxFps,
				memoryMb
			)
		)
	end)
end

return PerformanceProbe
