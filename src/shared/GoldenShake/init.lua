--[=[
@class GoldenShake
@ignore

Creates customized shakes originating from Sleitnick's Shake module
]=]

local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local Util = require(script.Util)
local Config = require(script.Config)
local Shake = require(Config.ShakeModuleLocation)

local GoldenShake = {}
GoldenShake.__index = GoldenShake

--[=[
    @within GoldenShake
    @method Create

    @param toShake Instance
    @param shakeParams table -- Info below

    @return Instance -- Shake object

    shakeParams: {

        Amplitude number -- Magnitude of the shake (larger number = larger shake)
        FadeInTime number
        FadeOutTime number
        Frequency number -- Speed of the shake
        InfluencePart BasePart -- Shake based on distance from this part
        PosInfluence Vector3 -- Similar to Amplitude, but multiplies against each axis of the resultant shake vector, and only affects the position vector
        RotInfluence Vector3 -- Multiplies against shake vector to control final amplitude of rotation
        Sustain bool -- If true, shake sustains indefinitely
        SustainTime number -- How long the shake sustains itself for after fading in and before fading out
        MotionBlurEnabled bool
        RotClamp Vector2 -- A minimum (X) and maximum (Y) value to limit UI rotation changes by
        ShouldReturn bool -- Whether the object should tween back to its original position and rotation (Defaults to ON for UI, OFF for Cameras/Parts)
        RenderPriority Enum

    }

    A custom function using Sleitnick's Shake module
    (
        All of these arguments have default values based on toShake's ClassName,
        and most are used for Shake's creation. Learn more at
        https://sleitnick.github.io/RbxUtil/api/Shake/
    )
]=]
--[[
    Parameters: {
        toShake: Instance
        shakeParams: table {
            Amplitude number -- Magnitude of the shake (larger number = larger shake)
            FadeInTime number
            FadeOutTime number
            Frequency number -- Speed of the shake
            InfluencePart BasePart -- Shake based on distance from this part
            PosInfluence Vector3 -- Similar to Amplitude, but multiplies against each axis of the resultant shake vector, and only affects the position vector
            RotInfluence Vector3 -- Multiplies against shake vector to control final amplitude of rotation
            Sustain bool -- If true, shake sustains indefinitely
            SustainTime number -- How long the shake sustains itself for after fading in and before fading out

            MotionBlurEnabled bool
            RotClamp Vector2 -- A minimum (X) and maximum (Y) value to limit UI rotation changes by
            ShouldReturn bool -- Whether the object should tween back to its original position and rotation (Defaults to ON for UI, OFF for Cameras/Parts)
            RenderPriority Enum

        }
    }

    Returns: Instance (Shake object)

    A custom function using Sleitnick's Shake module
    (
        All of these arguments have default values based on toShake's ClassName,
        and most are used for Shake's creation. Learn more at
        https://sleitnick.github.io/RbxUtil/api/Shake/
    )
--]]
function GoldenShake:Create(toShake: Instance, shakeParams: table)
    local shake = Shake.new()

    -- Local definitions here need to be their corresponding defaults value if one isn't provided
    local rotClamp =
        shakeParams["RotationClamp"] == nil
        and Config.SHAKE_ROTATION_CLAMP_DEFAULT
        or shakeParams["RotationClamp"]

    local motionBlurEnabled =
        shakeParams["MotionBlurEnabled"]
        or nil -- Set to default later based on toShake's type

    local cameraMotionBlurMax =
        shakeParams["CameraMotionBlurMax"] == nil
        and Config.CAMERA_MOTION_BLUR_MAX_DEFAULT
        or shakeParams["CameraMotionBlurMax"]

	local amplitude = shakeParams["Amplitude"] or nil
	local fadeInTime = shakeParams["FadeInTime"] or nil
	local fadeOutTime = shakeParams["FadeOutTime"] or nil
    local frequency = shakeParams["Frequency"] or nil
    local positionInfluence = shakeParams["PositionInfluence"] or nil
    local rotationInfluence = shakeParams["RotationInfluence"] or nil
    local sustain = shakeParams["Sustain"] or nil
    local sustainTime = shakeParams["SustainTime"] or nil
    local shouldReturn = shakeParams["ShouldReturn"] or nil
    local renderPriority = shakeParams["RenderPriority"] or nil


    local uiMotionBlurCount = 1 -- Identifier for ui CanvasGroup clones (blur objects) to assist automatic deletion

    local origPos, origRot, origCF -- Original values help the toShake object be returned to that point (If parameter says to)

    local classType = Util:GetItemClassType(toShake)

    if
        classType == "BasePart"
        or classType == "Camera"
    then
        origCF = toShake.CFrame

        if shouldReturn == nil then
            shouldReturn = Config.OBJECT_RETURN_DEFAULT
        end
        if amplitude == nil then
            amplitude = Config.BASEPART_AMPLITUDE_DEFAULT
        end
        if frequency == nil then
            frequency = Config.BASEPART_FREQUENCY_DEFAULT
        end
        if fadeInTime == nil then
            fadeInTime = Config.BASEPART_FADEINTIME_DEFAULT
        end
        if fadeOutTime == nil then
            fadeOutTime = Config.BASEPART_FADEOUTTIME_DEFAULT
        end
        if rotationInfluence == nil then
            rotationInfluence = Config.BASEPART_ROTATIONINFLUENCE_DEFAULT
        end
        if positionInfluence == nil then
            positionInfluence = Config.BASEPART_POSITIONINFLUENCE_DEFAULT
        end
    elseif
        classType == "TextObject"
        or classType == "ImageObject"
        or classType == "Frame"
    then
        if motionBlurEnabled == nil then
            motionBlurEnabled = Config.UI_MOTION_BLUR_DEFAULT
        end

        origPos, origRot = toShake.Position, toShake.Rotation

        if shouldReturn == nil then
            shouldReturn = Config.UI_RETURN_DEFAULT
        end
        if amplitude == nil then
            amplitude = Config.UI_AMPLITUDE_DEFAULT
        end
        if frequency == nil then
            frequency = Config.UI_FREQUENCY_DEFAULT
        end
        if fadeInTime == nil then
            fadeInTime = Config.UI_FADEINTIME_DEFAULT
        end
        if fadeOutTime == nil then
            fadeOutTime = Config.UI_FADEOUTTIME_DEFAULT
        end
        if rotationInfluence == nil then
            rotationInfluence = Config.UI_ROTATIONINFLUENCE_DEFAULT
        end
        if positionInfluence == nil then
            positionInfluence = Config.UI_POSITIONINFLUENCE_DEFAULT
        end
    end

    if classType == "Camera" then
        if motionBlurEnabled == nil then
            motionBlurEnabled = Config.CAMERA_MOTION_BLUR_DEFAULT
        end
        if renderPriority == nil then
            print("Render priority nil")
            -- renderPriority = Enum.RenderPriority.Camera.Value
        end
    end

    if sustainTime then
        shake.SustainTime = sustainTime
    end
    if amplitude then
        shake.Amplitude = amplitude
    end
    if frequency then
        shake.Frequency = frequency
    end
    if fadeInTime then
        shake.FadeInTime = fadeInTime
    end
    if fadeOutTime then
        shake.FadeOutTime = fadeOutTime
    end
    if rotationInfluence then
        shake.RotationInfluence = rotationInfluence
    end
    if positionInfluence then
        shake.PositionInfluence = positionInfluence
    end
    if sustain then
        shake.Sustain = sustain
    end
    if renderPriority == nil then
        -- Without this assignment, the shake:BindToRenderStep would error
        -- if not set earlier, as the render priority is a required parameter
        renderPriority = Enum.RenderPriority.Last.Value
    end

    print(shake)

    shake:Start() -- All parameters of the shake need to be loaded before it starts

    shake:BindToRenderStep(Shake.NextRenderName(), renderPriority, function(pos, rot, isDone)
		if not isDone then
			if classType == "BasePart" or classType == "Camera" then
                if shakeParams["InfluencePart"] then
                    local distance = (toShake.CFrame.Position - shakeParams["InfluencePart"].CFrame.Position).Magnitude
                    pos = Shake.InverseSquare(pos, distance)
                    rot = Shake.InverseSquare(rot, distance)
                end

				toShake.CFrame *= CFrame.new(pos) * CFrame.Angles(rot.X, rot.Y, rot.Z)
			elseif classType == "TextObject" or classType == "ImageObject" or classType == "Frame" then
				toShake.Position = UDim2.new(toShake.Position.X.Scale, pos.X, toShake.Position.Y.Scale, pos.Y)
				toShake.Rotation = origRot + math.clamp(rot.Y, rotClamp.X, rotClamp.Y)

				if motionBlurEnabled then
					for _, motionBlur in pairs(toShake.Parent:GetChildren()) do
						if
							motionBlur:GetAttribute("Count")
							and motionBlur:GetAttribute("Count") + 1 < uiMotionBlurCount
						then
							motionBlur:Destroy()
						else
							motionBlur.Position = toShake.Position
						end
					end

					uiMotionBlurCount += 1
					local motionBlur = Instance.new("CanvasGroup")
					local toShakeClone = toShake:Clone()

					motionBlur:SetAttribute("Count", uiMotionBlurCount)
					motionBlur.Size = toShake.Size
					motionBlur.Position = toShake.Position
					motionBlur.AnchorPoint = toShake.AnchorPoint
					motionBlur.Name = "MotionBlur"
					motionBlur.GroupTransparency = 0.7
					motionBlur.BorderSizePixel = 0
					motionBlur.BackgroundColor3 = toShakeClone.BackgroundColor3
					motionBlur.BackgroundTransparency = toShakeClone.BackgroundTransparency

                    for _, child in pairs(toShakeClone:GetChildren()) do
                        if child:IsA("UICorner") then
                            child.Parent = motionBlur
                        end
                    end

					toShakeClone.Size = UDim2.new(1, 0, 1, 0)
					toShakeClone.Parent = motionBlur

					motionBlur.Parent = toShake.Parent
				end
			end

			if classType == "Camera" and motionBlurEnabled then
				local motionBlur = Lighting:FindFirstChild("MotionBlur")

				if not motionBlur then
					motionBlur = Instance.new("BlurEffect")
					motionBlur.Name = "MotionBlur"
					motionBlur.Size = 0
					motionBlur.Parent = Lighting
				end

				motionBlur.Size = math.clamp((pos.X + pos.Y + pos.Z) / 3 * 10, 0, cameraMotionBlurMax)
			end
        else
			for _, motionBlur in pairs(toShake.Parent:GetChildren()) do
				if motionBlur:IsA("CanvasGroup") and motionBlur.Name == "MotionBlur" then
					motionBlur:Destroy()
				end
			end

            if motionBlurEnabled then
                local camMotionBlur = Lighting:FindFirstChild("MotionBlur")
                if camMotionBlur then
                    camMotionBlur:Destroy()
                end
            end

            if shouldReturn then
                if classType == "Camera" or classType == "BasePart" then
                    local returnTween = TweenService:Create(
                        toShake,
                        TweenInfo.new(.1),
                        {CFrame = origCF}
                    )

                    returnTween:Play()

                    task.wait(.5)
                    print(toShake.CFrame)
                    print("Break")
                    print(origCF)
                else
                    print("Returning UI")
                    local returnTween = TweenService:Create(
                        toShake,
                        TweenInfo.new(.1),
                        {
                            Position = origPos,
                            Rotation = origRot
                        }
                    )

                    returnTween:Play()
                end
            end
		end
    end)
    return shake
end


-- function GoldenShake:StopSustain(shake)
--     shake:StopSustain()
--     print("Stopped")
-- end


return GoldenShake
