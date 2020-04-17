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
    print("onBlockChanged ", oldId, newId)
end

function events:inBlockChanged(oldId, newId)
    print("inBlockChanged ", oldId, newId)
end