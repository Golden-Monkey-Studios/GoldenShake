--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")

local Config = {}

-- ⬇CHANGE THESE⬇
Config.MOTION_BLUR_DEFAULT = false -- Whether all calls to GoldenShake will include Motion Blur if not provided in provided arguments [Default = false]
Config.SHAKE_ROTATION_CLAMP_DEFAULT = 15 -- How much rotation can change from a shake. (for example, if the value is 15, GoldenShake will only modify the rotation to be from -15 to 15) [Default = 15]
Config.ShakeModuleLocation = Packages:FindFirstChild("Shake") -- Where the Shake module can be found (path to the ModuleScript "Shake")


return Config