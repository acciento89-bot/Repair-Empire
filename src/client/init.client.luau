--!strict

local Players = game:GetService("Players")

local player = Players.LocalPlayer
assert(player ~= nil, "LocalPlayer unavailable")

print(("[Repair Empire] Client initialized for %s"):format(player.Name))
