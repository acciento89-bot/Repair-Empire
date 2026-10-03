--!strict

local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local StarterPack = game:GetService("StarterPack")
local Workspace = game:GetService("Workspace")

local ServiceRegistry = require(script.core.ServiceRegistry)
local RemoteRegistry = require(script.core.RemoteRegistry)

local function sanitizeLegacyPlace()
	local terrain = Workspace:FindFirstChildOfClass("Terrain")
	if terrain then
		terrain:Clear()
	end

	for _, child in Workspace:GetChildren() do
		if not child:IsA("Terrain") and child.Name ~= "Camera" then
			child:Destroy()
		end
	end

	for _, child in ServerScriptService:GetChildren() do
		if child ~= script then
			child:Destroy()
		end
	end

	StarterPack:ClearAllChildren()
	StarterGui:ClearAllChildren()

	-- Do not clear StarterPlayerScripts or StarterCharacterScripts here.
	-- Roblox injects its default PlayerModule/camera/control stack through these
	-- containers. Deleting those scripts leaves the character spawned but the
	-- camera and controls detached. The canonical Rojo build owns our custom
	-- starter scripts, so runtime sanitization must preserve Roblox defaults.
end

sanitizeLegacyPlace()
print("[Repair Empire] Legacy place content sanitized")

RemoteRegistry.Initialize()

local registry = ServiceRegistry.new()

local servicesFolder = script:FindFirstChild("services")
if servicesFolder then
	for _, child in servicesFolder:GetChildren() do
		if child:IsA("ModuleScript") then
			local service = require(child)
			registry:Register(service)
		end
	end
end

registry:InitAll()
registry:StartAll()

if RunService:IsStudio() then
	if Workspace:GetAttribute("RepairEmpireE2E") == true then
		local StudioJourneyFixture = require(script.qa.StudioJourneyFixture)
		StudioJourneyFixture.Start()
	end

	task.spawn(function()
		task.wait(1)
		local WorldReachabilityProbe = require(script.qa.WorldReachabilityProbe)
		local reachabilityOk, reachabilityErr = pcall(WorldReachabilityProbe.Run)
		if not reachabilityOk then
			warn("[Repair Empire] WorldReachabilityProbe failed: " .. tostring(reachabilityErr))
		end

		local JobCatalogRuntimeProbe = require(script.qa.JobCatalogRuntimeProbe)
		local catalogOk, catalogErr = pcall(JobCatalogRuntimeProbe.Run)
		if not catalogOk then
			warn("[Repair Empire] JobCatalogRuntimeProbe failed: " .. tostring(catalogErr))
		end
	end)
end

print("[Repair Empire] Server initialized")
