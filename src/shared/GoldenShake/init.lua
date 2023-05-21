--[=[
@class GoldenShake

### ⏲Release Version:
v0.1.0-alpha

### 📃Description:
Creates customized shakes originating from Sleitnick's Shake module
]=]

local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

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
    @param amplitude number -- Magnitude of the shake (larger number = larger shake)
    @param fadeInTime number -- Fade-in time before max amplitude shake
    @param fadeOutTime number -- How long it takes for the shake to fade out, in seconds
    @param frequency number -- Speed of the Shake
    @param posInfluence Vector3 -- Similar to Amplitude, but multiplies against each axis of the resultant shake vector, and only affects the position vector
    @param rotInfluence Vector3 -- Multiplies against shake vector to control final amplitude of rotation
    @param Sustain bool -- If true, shake sustains indefinitely
    @param SustainTime number -- How long the shake sustains inself for after fading in and before fading out
} --]]
@param motionBlurEnabled bool -- Whether to enable motion blur (more info in Config)
@param rotClamp number -- Limiter for how much the rotation can change (more info in Config)
@param shouldReturn bool -- Whether or not the object should tween back to its original position and rotation (Defaults to ON for UI, OFF for Cameras/Parts)
@param renderPriority Enum -- Render priority of shake (probably best to leave this nil for default)

A custom function using Sleitnick's Shake module

(All of these arguments have default values based on toShake's ClassName, and most are used for Shake's creation. Learn more at https://sleitnick.github.io/RbxUtil/api/Shake/)
]=]
function GoldenShake:Shake(toShake: Instance, shakeParams: table)
    local rotClamp =
        shakeParams["RotationClamp"] == nil
        and Config.SHAKE_ROTATION_CLAMP_DEFAULT
        or shakeParams["RotationClamp"]

    local cameraMotionBlurEnabled =
        shakeParams["CameraMotionBlurEnabled"] == nil
        and Config.CAMERA_MOTION_BLUR_DEFAULT
        or shakeParams["CameraMotionBlurEnabled"]

    local cameraMotionBlurMax =
        shakeParams["CameraMotionBlurMax"] == nil
        and Config.CAMERA_MOTION_BLUR_MAX_DEFAULT
        or shakeParams["CameraMotionBlurMax"]


    local uiMotionBlurEnabled =
        shakeParams["UIMotionBlurEnabled"] == nil
        and Config.UI_MOTION_BLUR_DEFAULT
        or shakeParams["UIMotionBlurEnabled"]

    local motionBlurCount = 1

    local origPos, origRot, origCF
    local renderPriority
    local shouldReturn
    
    local shake = Shake.new()
    local classType = Util:GetItemClassType(toShake)

    if classType == "BasePart" or classType == "Camera" then
        origCF = toShake.CFrame
        renderPriority = shakeParams["RenderPriority"] or Enum.RenderPriority.Last.Value
        shouldReturn =
            shakeParams["ShouldReturn"] == nil
            and Config.OBJECT_RETURN_DEFAULT
            or shakeParams["ShouldReturn"]

        shake.FadeInTime = shakeParams["FadeInTime"] or 0
        shake.Frequency = shakeParams["Frequency"] or 0.1
        shake.Amplitude = shakeParams["Amplitude"] or 5
        shake.RotationInfluence = shakeParams["RotationInfluence"] or Vector3.new(0.1, 0.1, 0.1)
    elseif classType == "TextObject" or classType == "ImageObject" or classType == "Frame" then
        origPos, origRot = toShake.Position, toShake.Rotation
        renderPriority = shakeParams["RenderPriority"] or Enum.RenderPriority.Last.Value
        shouldReturn =
            shakeParams["ShouldReturn"] == nil
            and Config.UI_RETURN_DEFAULT
            or shakeParams["ShouldReturn"]

        shake.FadeInTime = shakeParams["FadeInTime"] or 0
        shake.Frequency = shakeParams["Frequency"] or 0.1
        shake.Amplitude = shakeParams["Amplitude"] or 75
        shake.RotationInfluence = shakeParams["RotationInfluence"] or Vector3.new(0.1, 0.1, 0.1)
    end

    if classType == "Camera" then
        renderPriority = shakeParams["RenderPriority"] or Enum.RenderPriority.Camera.Value
    end




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
		end

		if isDone then
			for _, motionBlur in pairs(toShake.Parent:GetChildren()) do
				if motionBlur:IsA("CanvasGroup") and motionBlur.Name == "MotionBlur" then
					motionBlur:Destroy()
				end
			end

            if cameraMotionBlurEnabled then
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

    --Return shake for possible stop sustain
end


return GoldenShake
