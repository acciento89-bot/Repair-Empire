--!strict

local ServiceRegistry = require(script.core.ServiceRegistry)
local RemoteRegistry = require(script.core.RemoteRegistry)

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
