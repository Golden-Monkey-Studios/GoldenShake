--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")

local Config = {}

-- ⬇CHANGE THESE⬇
Config.ShakeModuleLocation = Packages:FindFirstChild("Shake") -- Where the Shake module can be found (path to the ModuleScript "Shake")

Config.UI_MOTION_BLUR_DEFAULT = false -- Whether all calls to GoldenShake as UI will include Motion Blur if not provided in arguments [Default = false as this is experimental]
Config.CAMERA_MOTION_BLUR_DEFAULT = true
Config.SHAKE_ROTATION_CLAMP_DEFAULT = Vector2.new(-15, 15) -- How much rotation can change from a shake. (for example, if the value is 15, GoldenShake will only modify the rotation to be from -15 to 15) [Default = 15]
Config.CAMERA_MOTION_BLUR_MAX_DEFAULT = 8
Config.CAMERA_MOTION_BLUR_MAX_INFLUENCE = 0.2

Config.OBJECT_RETURN_DEFAULT = false -- Whether 3D objects (Including Camera) should return to original CFrame after shaken by default
Config.UI_RETURN_DEFAULT = true -- Whether by default, shaken UI objects should return to original position and rotation

Config.BASEPART_AMPLITUDE_DEFAULT = 5
Config.UI_AMPLITUDE_DEFAULT = 75

Config.BASEPART_FREQUENCY_DEFAULT = 0.1
Config.UI_FREQUENCY_DEFAULT = 0.1

Config.BASEPART_FADEINTIME_DEFAULT = 1
Config.UI_FADEINTIME_DEFAULT = 0.5

Config.BASEPART_FADEOUTTIME_DEFAULT = 1
Config.UI_FADEOUTTIME_DEFAULT = 0.5

Config.BASEPART_ROTATIONINFLUENCE_DEFAULT = Vector3.new(0.1, 0.1, 0.1)
Config.UI_ROTATIONINFLUENCE_DEFAULT = Vector3.new(0.1, 0.1, 0.1)

Config.BASEPART_POSITIONINFLUENCE_DEFAULT = Vector3.one
Config.UI_POSITIONINFLUENCE_DEFAULT = Vector3.one


return Config