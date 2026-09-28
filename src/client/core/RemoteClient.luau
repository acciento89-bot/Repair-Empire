--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteClient = {}

function RemoteClient.Get(name: string): RemoteEvent | RemoteFunction
	local root = ReplicatedStorage:WaitForChild("RepairEmpireRemotes")
	local remote = root:WaitForChild(name)
	assert(remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction"), "Invalid remote: " .. name)
	return remote
end

return RemoteClient
