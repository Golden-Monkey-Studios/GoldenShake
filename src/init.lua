--[=[
    @class CustomShakeController

    ### ⏲Release Version:
    v0.1.0-alpha

    ### 📃Description:
    Creates customized shakes originating from Sleitnick's Shake module

]=]

--Modules
local Util = require(script.Util)
local Config = require(script.Config)
local Shake = require(Config.ShakeModuleLocation)

local CustomShakeController = {}

--[=[
@within init
@method Shake
@since v0.1.0-alpha

@param toShake Instance
@param frequency number
@param amplitude number
@param fadeInTime number
@param priority Enum
@param rotInfluence Vector3
@param rotClamp number
@param motionBlurEnabled bool

A custom function using Knit's Shake module 
]=]
function CustomShakeController:Shake(toShake, frequency, amplitude, fadeInTime, priority, rotInfluence, rotClamp, motionBlurEnabled)
    local SHAKE_ROTATION_CLAMP_DEFAULT = Config.SHAKE_ROTATION_CLAMP_DEFAULT
    local MOTION_BLUR_DEFAULT = Config.MOTION_BLUR_DEFAULT

    if not motionBlurEnabled then
        motionBlurEnabled = MOTION_BLUR_DEFAULT
    end

    if not rotClamp then
        rotClamp = SHAKE_ROTATION_CLAMP_DEFAULT
    end

    local motionBlurCount = 1
    
    local shake = Shake.new()
    local classType = Util:GetItemClassType(toShake)

    if classType == "BasePart" or classType == "Camera" then
        shake.FadeInTime = fadeInTime or 0
        shake.Frequency = frequency or 0.1
        shake.Amplitude = amplitude or 5
        shake.RotationInfluence = rotInfluence or Vector3.new(0.1, 0.1, 0.1)
    elseif classType == "TextObject" or classType == "ImageObject" or classType == "Frame" then
        -- print("Is UI Object")
        shake.FadeInTime = fadeInTime or 0
        shake.Frequency = frequency or 0.1
        shake.Amplitude = amplitude or 75
        shake.RotationInfluence = rotInfluence or Vector3.new(0.1, 0.1, 0.1)
    end

    local renderPriority = priority or Enum.RenderPriority.Last.Value



    shake:Start()

    shake:BindToRenderStep(Shake.NextRenderName(), renderPriority, function(pos, rot, isDone)

        if classType == "BasePart" or classType == "Camera" then
            toShake.CFrame *= CFrame.new(pos) * CFrame.Angles(rot.X, rot.Y, rot.Z)
        elseif classType == "TextObject" or classType == "ImageObject" or classType == "Frame" then
            toShake.Position = UDim2.new(toShake.Position.X.Scale, pos.X, toShake.Position.Y.Scale, pos.Y)
            toShake.Rotation = math.clamp(rot.Y, -rotClamp, rotClamp)
            
            if motionBlurEnabled then
                for _, motionBlur in pairs(toShake.Parent:GetChildren()) do
                    if motionBlur:GetAttribute("Count") and motionBlur:GetAttribute("Count") + 1 < motionBlurCount then
                        -- print("Destroying")
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

        if isDone then
            -- print("Done")
            for _, motionBlur in pairs(toShake.Parent:GetChildren()) do
                if motionBlur:IsA("CanvasGroup") and motionBlur.Name == "MotionBlur" then
                    motionBlur:Destroy()
                end
            end
        end
    end)
end


return CustomShakeController
