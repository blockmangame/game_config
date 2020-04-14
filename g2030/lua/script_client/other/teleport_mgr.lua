local mmax = math.max

local teleportBeginTimer = nil
local teleportEndTimer = nil

local teleportProps = World.cfg.teleportProps or {}

local STATIC_TELEPORT_TIME = 20
local STATIC_TELEPORT_COLOR = {0,0,0,1}
local STATIC_TELEPORT_TYPE = {teleportType = "center", teleportTime = 20, teleportImage = "teleport.png", teleportColor = {0,0,0,1}}
local function getTeleportType(type)
    if not type then
        return STATIC_TELEPORT_TYPE
    end
    return teleportProps[type]
end

local function resetBeginTimer()
    if teleportBeginTimer then
        teleportBeginTimer()
        teleportBeginTimer = nil
    end
end

local function resetEndTimer()
    if teleportEndTimer then
        teleportEndTimer()
        teleportEndTimer = nil
    end
end

local function beginShader(teleportProp, window)
    local size = window:root():GetPixelSize()
    local x2, y2 = size.x/2, size.y/2
    local r = mmax(y2, x2)
    local count = teleportProp.teleportTime or STATIC_TELEPORT_TIME
    local teleportColor = teleportProp.teleportColor or STATIC_TELEPORT_COLOR
    local tr = r / count
    local uCount = 0
    teleportBeginTimer = World.Timer(1, function()
        window:updateMask(x2, y2, r - tr * uCount, teleportColor)
        if uCount >= count then
            resetBeginTimer()
            Me:sendPacket({pid = "TeleportBeginFinsh", objId = Me.objID})
            return false
        end
        uCount = uCount + 1
        return true
    end)
end

Lib.subscribeEvent(Event.EVENT_TELEPORT_SHADER_ENABLE, function(type)
    local window = UI:openWnd("teleport_mask")
    if not window then
        return
    end
    resetBeginTimer()
    resetEndTimer()
    local teleportProp = getTeleportType(type)
    if teleportProp.teleportImage then
        window:updateMaskImage(teleportProp.teleportImage)
    end
    if teleportProp.teleportType == "center" then
        beginShader(teleportProp, window)
    end
end)

local function endShader(teleportProp, window)
    local size = window:root():GetPixelSize()
    local x2, y2 = size.x/2, size.y/2
    local r = mmax(y2, x2)
    local count = teleportProp.teleportTime or STATIC_TELEPORT_TIME
    local teleportColor = teleportProp.teleportColor or STATIC_TELEPORT_COLOR
    local tr = r / count
    local uCount = count
    teleportEndTimer = World.Timer(1, function()
        window:updateMask(x2, y2, r - tr * uCount, teleportColor)
        if uCount <= 0 then
            UI:closeWnd("teleport_mask")
            Me:sendPacket({pid = "TeleportEndFinsh", objId = Me.objID})
            resetEndTimer()
            return false
        end
        uCount = uCount - 1
        return true
    end)
end

Lib.subscribeEvent(Event.EVENT_TELEPORT_SHADER_DISABLE, function(type)
    local window = UI:openWnd("teleport_mask")
    if not window then
        return
    end
    resetBeginTimer()
    resetEndTimer()
    local teleportProp = getTeleportType(type)
    if teleportProp.teleportImage then
        window:updateMaskImage(teleportProp.teleportImage)
    end
    if teleportProp.teleportType == "center" then
        endShader(teleportProp, window)
    end
end)