--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")

local Config = {}

-- ⬇CHANGE THESE⬇
Config.ShakeModuleLocation = Packages:FindFirstChild("Shake") -- Where the Shake module can be found (path to the ModuleScript "Shake")

Config.UI_MOTION_BLUR_DEFAULT = false -- Whether all calls to GoldenShake will include Motion Blur if not provided in arguments [Default = false]
Config.CAMERA_MOTION_BLUR_DEFAULT = true
Config.SHAKE_ROTATION_CLAMP_DEFAULT = 15 -- How much rotation can change from a shake. (for example, if the value is 15, GoldenShake will only modify the rotation to be from -15 to 15) [Default = 15]
Config.CAMERA_MOTION_BLUR_MAX_DEFAULT = 8
Config.CAMERA_MOTION_BLUR_MAX_INFLUENCE = 0.2
Config.OBJECT_RETURN_DEFAULT = false -- Whether 3D objects (Including Camera) should return to original CFrame after shaken by default
Config.UI_RETURN_DEFAULT = true -- Whether by default, shaken UI objects should return to original position and rotation

return Config