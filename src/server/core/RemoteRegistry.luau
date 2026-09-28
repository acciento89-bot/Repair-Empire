--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("RepairEmpire"):WaitForChild("Shared")
local RemoteDefinitions = require(Shared.remotes.RemoteDefinitions)

local RemoteRegistry = {}

function RemoteRegistry.Initialize(): Folder
	local root = ReplicatedStorage:FindFirstChild("RepairEmpireRemotes")
	if root == nil then
		root = Instance.new("Folder")
		root.Name = "RepairEmpireRemotes"
		root.Parent = ReplicatedStorage
	end

	for _, definition in RemoteDefinitions.List do
		if root:FindFirstChild(definition.Name) == nil then
			local remote
			if definition.Kind == "Event" then
				remote = Instance.new("RemoteEvent")
			else
				remote = Instance.new("RemoteFunction")
			end
			remote.Name = definition.Name
			remote.Parent = root
		end
	end

	return root :: Folder
end

return RemoteRegistry
