--!strict

local ServerScriptService = game:GetService("ServerScriptService")
local StarterGui = game:GetService("StarterGui")
local StarterPack = game:GetService("StarterPack")
local StarterPlayer = game:GetService("StarterPlayer")
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

	for _, child in StarterPlayer.StarterPlayerScripts:GetChildren() do
		if child.Name ~= "RepairEmpireClient" then
			child:Destroy()
		end
	end
	StarterPlayer.StarterCharacterScripts:ClearAllChildren()
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

print("[Repair Empire] Server initialized")
