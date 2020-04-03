function Entity.ValueFunc:curHp(value)
    Lib.emitEvent(Event.EVENT_HP_CHANGE)
end

function Entity.ValueFunc:jumpCount(value)
    print("Entity.ValueFunc:jumpCount " .. value)
end