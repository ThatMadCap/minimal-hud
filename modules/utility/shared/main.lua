local utility = {}
local config = lib.require("config.shared")

---@param value number
---@return number
utility.convertRpmToPercentage = function(value)
    local percentage = math.ceil(value * 10000 - 2001) / 80
    return math.max(0, math.min(percentage, 100))
end

---@param num number
---@param numDecimalPlaces number?
---@return integer
utility.round = function(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num + 0.5 * mult)
end

utility.convertEngineHealthToPercentage = function(value)
    -- Engine health ranges from 1000 (perfect) to 0 (about to catch fire)
    -- Values below 0 are just shown as 0% since they're critically damaged
    local clampedValue = math.max(0, math.min(value, 1000))

    local percentage = (clampedValue / 1000) * 100

    percentage = math.floor(percentage + 0.5)

    return percentage
end

---@return {width: number, height: number, left: number, top: number}
utility.calculateMinimapSizeAndPosition = function()
    SetBigmapActive(false, false)
    local minimap = {}
    local resX, resY = GetActiveScreenResolution()

    local aspectRatio = GetAspectRatio(false)
    local minimapRawX, minimapRawY

    SetScriptGfxAlign(string.byte("L"), string.byte("B"))

    if IsBigmapActive() then
        minimapRawX, minimapRawY = GetScriptGfxPosition(-0.00, 0.022 + -0.435416666)
        minimap.width = resX / (2.52 * aspectRatio)
        minimap.height = resY / 2.4374
        goto continue
    end

    minimapRawX, minimapRawY = GetScriptGfxPosition(0.000, 0.002 + -0.229888)
    minimap.width = resX / (3.48 * aspectRatio)
    minimap.height = resY / 5.55

    ::continue::

    ResetScriptGfxAlign()

    minimap.leftX = minimapRawX
    minimap.rightX = minimapRawX + minimap.width
    minimap.topY = minimapRawY
    minimap.bottomY = minimapRawY + minimap.height
    minimap.X = minimapRawX + (minimap.width / 2)
    minimap.Y = minimapRawY + (minimap.height / 2)

    minimap.webLeft = minimapRawX * resX
    minimap.webTop = minimapRawY * resY
    minimap.webWidth = (minimap.width / resX) * resX
    minimap.webHeight = (minimap.height / resY) * resY

    return {
        top = minimap.webTop,
        left = minimap.webLeft,
        height = minimap.webHeight,
        width = minimap.webWidth,
    }
end

--- Checks whether the specified framework is valid.
---@return boolean
utility.isFrameworkValid = function()
    local framework = config.framework and config.framework:lower() or nil

    if not framework then
        lib.print.info("(utility:isFrameworkValid) No framework specified, defaulting to 'none'.")
        return false
    end

    local validFrameworks = {
        esx = true,
        qb = true,
        ox = true,
        custom = true,
    }

    lib.print.verbose("(utility:isFrameworkValid) Checking if framework is valid: ", validFrameworks[framework] ~= nil)
    return validFrameworks[framework] ~= nil
end

-- Prevents the bigmap from staying active after the minimap is closed, since sometimes the bigmap is still active and stuck on the screen
utility.preventBigmapFromStayingActive = function()
    local timeout = 0
    while true do
        lib.print.debug("(utility:preventBigmapFromStayingActive) Running, timeout: ", timeout)

        SetBigmapActive(false, false)

        if timeout >= 10000 then
            return
        end

        timeout = timeout + 1000
        Wait(1000)
    end
end

utility.setupMinimap = function()
    lib.print.debug("(utility:setupMinimap) Setting up minimap.")
    local defaultAspectRatio = 1920 / 1080
    local resolutionX, resolutionY = GetActiveScreenResolution()
    local aspectRatio = resolutionX / resolutionY
    local minimapOffset = 0

    if aspectRatio > defaultAspectRatio then
        minimapOffset = ((defaultAspectRatio - aspectRatio) / 3.6) - 0.008
    end

    RequestStreamedTextureDict("squaremap", false)

    while not HasStreamedTextureDictLoaded("squaremap") do
        Wait(100)
    end

    SetMinimapClipType(0)
    AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "squaremap", "radarmasksm")
    AddReplaceTexture("platform:/textures/graphics", "radarmask1g", "squaremap", "radarmasksm")

    SetMinimapComponentPosition("minimap", "L", "B", 0.0 + minimapOffset, -0.047, 0.1638, 0.183)
    SetMinimapComponentPosition("minimap_mask", "L", "B", 0.0 + minimapOffset, 0.0, 0.128, 0.20)
    SetMinimapComponentPosition("minimap_blur", "L", "B", -0.01 + minimapOffset, 0.025, 0.262, 0.300)

    SetBlipAlpha(GetNorthRadarBlip(), 0)
    SetBigmapActive(true, false)
    SetMinimapClipType(0)
    CreateThread(utility.preventBigmapFromStayingActive)

    if not _G.minimapVisible then
        DisplayRadar(false)
    end
end

-- Removes the default health and armor bars from the HUD
utility.removeHealthArmorBars = CreateThread(function()
    local minimap = RequestScaleformMovie("minimap")
    SetRadarBigmapEnabled(false, false)
    while true do
        Wait(0)
        BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()
    end
end)

---@param coords vector3
---@return boolean
---@return table
utility.get2DCoordFrom3DCoord = function(coords)
    if not coords then
        return false, {}
    end
    local onScreen, x, y = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)
    return onScreen, { left = tostring(x * 100) .. "%", top = tostring(y * 100) .. "%" }
end

return utility
