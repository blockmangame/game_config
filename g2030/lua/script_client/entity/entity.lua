function Entity.ValueFunc:curHp(value)
    Lib.emitEvent(Event.EVENT_HP_CHANGE)
end