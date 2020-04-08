---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by luo.
--- DateTime: 2020/2/28 16:22
---

local playerEventEngineHandler = L("playerEventEngineHandler", player_event)
local events = {}

function player_event(player, event, ...)
    playerEventEngineHandler(player, event, ...)
    local func = events[event]
    if func then
        func(player, ...)
    end
end

function events:sendSpawn(id)
    local entity = self.world:getEntity(id)
    if entity and entity:cfg().autoChangeSkin then
        self:sendPacket({ pid = "AddEntityAutoChangeSkin", objID = entity.objID })
    end
end

function events:sendRemove(id)
    local entity = self.world:getEntity(id)
    if entity and entity:cfg().autoChangeSkin then
        self:sendPacket({ pid = "RemoveEntityAutoChangeSkin", objID = entity.objID })
    end
end
