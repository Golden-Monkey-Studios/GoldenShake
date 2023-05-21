local Util = {}

--[[
Parameters: {
    item: Instance
}
Returns: String

Returns a string associated with the ClassName of the provided item that groups certain ClassNames
into similar groups (For example, if item is an ImageLabel or ImageButton, "ImageObject" will be
returned)
--]]
function Util:GetItemClassType(item)
    if typeof(item) == "Instance" then
        if item:IsA("BasePart") then
            return "BasePart"
        elseif item:IsA("Camera") then
            return "Camera"
        elseif item:IsA("TextLabel") or item:IsA("TextButton") then
            return "TextObject"
        elseif item:IsA("ImageLabel") or item:IsA("ImageButton") then
            return "ImageObject"
        elseif item:IsA("Frame") or item:IsA("CanvasGroup") then
            return "Frame"
        end
    end

    return nil
end



return Util
