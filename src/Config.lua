--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")

local Config = {}

-- ⬇CHANGE THESE⬇
Config.UI_MOTION_BLUR_DEFAULT = false -- Whether all calls to GoldenShake will include Motion Blur if not provided in provided arguments [Default = false]
Config.CAMERA_MOTION_BLUR_DEFAULT = true
Config.SHAKE_ROTATION_CLAMP_DEFAULT = 15 -- How much rotation can change from a shake. (for example, if the value is 15, GoldenShake will only modify the rotation to be from -15 to 15) [Default = 15]
Config.CAMERA_MOTION_BLUR_MAX_DEFAULT = 8
Config.CAMERA_MOTION_BLUR_MAX_INFLUENCE = 0.2
Config.ShakeModuleLocation = Packages:FindFirstChild("Shake") -- Where the Shake module can be found (path to the ModuleScript "Shake")


return Config