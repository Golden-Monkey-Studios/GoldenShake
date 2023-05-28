local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local common = ReplicatedStorage:WaitForChild("Common")
local GoldenShake = require(common:WaitForChild("GoldenShake"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local shakeGui = playerGui:WaitForChild("Shake")
local toShakeLabel = shakeGui:WaitForChild("ToShake")

repeat
    task.wait()
until workspace.CurrentCamera
local camera = workspace.CurrentCamera

while true do
    local shake1 = GoldenShake:Create(toShakeLabel, {
        ["Sustain"] = true,
        ["MotionBlurEnabled"] = true,
        -- ["PositionInfluence"] = Vector3.new(0,0,0)
    })
    task.wait(5)
    print(shake1)
    shake1:StopSustain()

    local shake2 = GoldenShake:Create(camera, {
        ["InfluencePart"] = game.Workspace:WaitForChild("InfluencePart"),
        ["Sustain"] = true,
    })
    task.wait(5)
end