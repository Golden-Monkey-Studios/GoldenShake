--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--Modules
local common = ReplicatedStorage:WaitForChild("Common")
local GoldenShake = require(common:WaitForChild("GoldenShake"))

-- ScreenGui
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local shakeGui = playerGui:WaitForChild("Shake")
local toShakeLabel = shakeGui:WaitForChild("ToShake")

repeat
    task.wait()
until workspace.CurrentCamera
local camera = workspace.CurrentCamera

while true do
    GoldenShake:Shake(toShakeLabel, {})
    GoldenShake:Shake(camera, {
        ["CameraMotionBlurEnabled"] = false
    })
    task.wait(1)
end