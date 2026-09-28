--!strict

local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
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

		local viewport = if Workspace.CurrentCamera then Workspace.CurrentCamera.ViewportSize else Vector2.new(0, 0)
		local pingMs = -1
		local pingOk, pingValue = pcall(function()
			local network = Stats:FindFirstChild("Network")
			local serverStats = network and network:FindFirstChild("ServerStatsItem")
			local ping = serverStats and serverStats:FindFirstChild("Data Ping")
			if ping and ping:IsA("StatsItem") then
				return ping:GetValue()
			end
			return nil
		end)
		if pingOk and type(pingValue) == "number" then
			pingMs = pingValue
		end

		print(
			("[Repair Empire] StudioClientBaseline viewport=%dx%d touch=%s samples=%d avgFrameMs=%.2f p95FrameMs=%.2f approxFps=%.1f memoryMb=%.1f pingMs=%.1f"):format(
				viewport.X,
				viewport.Y,
				tostring(UserInputService.TouchEnabled),
				summary.SampleCount,
				summary.AverageFrameMs,
				summary.P95FrameMs,
				summary.ApproxFps,
				memoryMb,
				pingMs
			)
		)
	end)
end

return PerformanceProbe
