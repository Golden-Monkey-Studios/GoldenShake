--[=[
@class GoldenShake

### ⏲Release Version:
v0.1.0-alpha

### 📃Description:
Creates customized shakes originating from Sleitnick's Shake module
]=]

--Roblox Services
local Lighting = game:GetService("Lighting")

--Modules
local Util = require(script.Util)
local Config = require(script.Config)
local Shake = require(Config.ShakeModuleLocation)

local GoldenShake = {}

--[=[
@within GoldenShake
@method Shake
@since v0.1.0-alpha

@param toShake Instance -- The instance to shake
@param shakeParams table --[[ A table of parameters to be used by the shake {
    @param frequency number -- Speed of the Shake
    @param amplitude number -- Magnitude of the shake (larger number = larger shake)
    @param fadeInTime number -- Fade-in time before max amplitude shake
    @param priority Enum -- Render priority of shake (probably best to leave this nil for default)
    @param rotInfluence Vector3 -- Multiplies against shake vector to control final amplitude of rotation
} --]]
@param rotClamp number -- Limiter for how much the rotation can change (more info in Config)
@param motionBlurEnabled bool -- Whether to enable motion blur (more info in Config)

A custom function using Sleitnick's Shake module

(All of these arguments have default values based on toShake's ClassName, and most are used for Shake's creation. Learn more at https://sleitnick.github.io/RbxUtil/api/Shake/)
]=]
function GoldenShake:Shake(toShake, shakeParams)
    -- local rotClamp, cameraMotionBlurEnabled, cameraMotionBlurMax, uiMotionBlurEnabled

    -- if shakeParams["RotationClamp"] == nil then
    --     rotClamp = Config.SHAKE_ROTATION_CLAMP_DEFAULT
    -- else
    --     rotClamp = shakeParams["RotationClamp"]
    -- end
    
    local rotClamp = shakeParams["RotationClamp"] == nil and Config.CAMERA_MOTION_BLUR_DEFAULT or
    shakeParams["RotationClamp"]

    local cameraMotionBlurEnabled = shakeParams["CameraMotionBlurEnabled"] == nil and
    Config.CAMERA_MOTION_BLUR_DEFAULT or
    shakeParams["CameraMotionBlurEnabled"]

    local cameraMotionBlurMax = shakeParams["CameraMotionBlurMax"] == nil and
    Config.CAMERA_MOTION_BLUR_MAX_DEFAULT or
    shakeParams["CameraMotionBlurMax"]


    local uiMotionBlurEnabled = shakeParams["UIMotionBlurEnabled"] == nil and
    Config.UI_MOTION_BLUR_DEFAULT or
    shakeParams["UIMotionBlurEnabled"]

    local motionBlurCount = 1

    local origPos, origRot, origCF
    
    local shake = Shake.new()
    local classType = Util:GetItemClassType(toShake)

    if classType == "BasePart" or classType == "Camera" then
        origCF = toShake.CFrame

        shake.FadeInTime = shakeParams["FadeInTime"] or 0
        shake.Frequency = shakeParams["Frequency"] or 0.1
        shake.Amplitude = shakeParams["Amplitude"] or 5
        shake.RotationInfluence = shakeParams["RotationInfluence"] or Vector3.new(0.1, 0.1, 0.1)
    elseif classType == "TextObject" or classType == "ImageObject" or classType == "Frame" then
        origPos, origRot = toShake.Position, toShake.Rotation

        shake.FadeInTime = shakeParams["FadeInTime"] or 0
        shake.Frequency = shakeParams["Frequency"] or 0.1
        shake.Amplitude = shakeParams["Amplitude"] or 75
        shake.RotationInfluence = shakeParams["RotationInfluence"] or Vector3.new(0.1, 0.1, 0.1)
    end

    local renderPriority = shakeParams["RenderPriority"] or Enum.RenderPriority.Last.Value



    shake:Start()

    shake:BindToRenderStep(Shake.NextRenderName(), renderPriority, function(pos, rot, isDone)

        if classType == "BasePart" or classType == "Camera" then
            toShake.CFrame *= CFrame.new(pos) * CFrame.Angles(rot.X, rot.Y, rot.Z)
        elseif classType == "TextObject" or classType == "ImageObject" or classType == "Frame" then
            toShake.Position = UDim2.new(toShake.Position.X.Scale, pos.X, toShake.Position.Y.Scale, pos.Y)
            toShake.Rotation = origRot + math.clamp(rot.Y, -rotClamp, rotClamp)
            
            if uiMotionBlurEnabled then
                for _, motionBlur in pairs(toShake.Parent:GetChildren()) do
                    if motionBlur:GetAttribute("Count") and motionBlur:GetAttribute("Count") + 1 < motionBlurCount then
                        motionBlur:Destroy()
                    else
                        motionBlur.Position = toShake.Position
                    end
                end
                
                local canvasGroup = Instance.new("CanvasGroup")
                local toShakeClone = toShake:Clone()
                
                canvasGroup:SetAttribute("Count", motionBlurCount)
                motionBlurCount += 1
                canvasGroup.Size = toShake.Size
                canvasGroup.Position = toShake.Position
                canvasGroup.AnchorPoint = toShake.AnchorPoint
                canvasGroup.Name = "MotionBlur"
                canvasGroup.GroupTransparency = 0.7
                canvasGroup.BorderSizePixel = 0
                canvasGroup.BackgroundColor3 = toShakeClone.BackgroundColor3
                canvasGroup.BackgroundTransparency = toShakeClone.BackgroundTransparency

                toShakeClone.Size = UDim2.new(1, 0, 1, 0)
                toShakeClone.Parent = canvasGroup

                canvasGroup.Parent = toShake.Parent
            end
        end

        if classType == "Camera" and cameraMotionBlurEnabled then
            local motionBlur = Lighting:FindFirstChild("MotionBlur")

            if not motionBlur then
                motionBlur = Instance.new("BlurEffect")
                motionBlur.Name = "MotionBlur"
                motionBlur.Size = 0
                motionBlur.Parent = Lighting
            end

            motionBlur.Size = math.clamp((pos.X + pos.Y + pos.Z) / 3 * 10, 0, cameraMotionBlurMax)
            print(motionBlur.Size)
        end

        if isDone then
            for _, motionBlur in pairs(toShake.Parent:GetChildren()) do
                if motionBlur:IsA("CanvasGroup") and motionBlur.Name == "MotionBlur" then
                    motionBlur:Destroy()
                end
            end

            local camMotionBlur = Lighting:FindFirstChild("MotionBlur")
            if camMotionBlur then
                camMotionBlur:Destroy()
            end
        end
    end)
end


return GoldenShake
