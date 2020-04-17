local entityEventEngineHandler = L("entityEventEngineHandler", entity_event)

local events = {}

function entity_event(entity, event, ...)
    entityEventEngineHandler(entity, event, ...)
    local func = events[event]
    if func then
        func(entity, ...)
    end
end

function events:onBlockChanged(oldId, newId)
    --print("onBlockChanged ", oldId, newId)
end

function events:inBlockChanged(oldId, newId)
    print("inBlockChanged ", oldId, newId)

    if not self.isPlayer then
        return
    end

    if self.objID ~= Me.objID then
        return
    end

    if oldId == newId then
        return
    end

    local RegionBlock = require "script_client.world.region.region_block"

    local RegionConfig = T(Config, "RegionConfig") ---@type RegionConfig
    local leaveRegionConfig = RegionConfig:getRegionConfigByBlockId(oldId)
    if leaveRegionConfig then
        RegionBlock:onEntityLeave(self, leaveRegionConfig)
    end

    local enterRegionConfig = RegionConfig:getRegionConfigByBlockId(newId)
    if enterRegionConfig then
        RegionBlock:onEntityEnter(self, enterRegionConfig)
    end
end