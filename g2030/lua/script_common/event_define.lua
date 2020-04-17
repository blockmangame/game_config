---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by bell.
--- DateTime: 2020/3/25 22:21
---
Event.register("EVENT_EXP_CHANGE")
Event.register("EVENT_HP_CHANGE")
Event.register("EVENT_LEVEL_CHANGE")
Event.register("EVENT_SCENE_SKILL_TOUCH_MOVE_BEGIN")
Event.register("EVENT_SCENE_SKILL_TOUCH_MOVE")
Event.register("EVENT_SCENE_SKILL_TOUCH_MOVE_END")
Event.register("EVENT_NOT_ENOUGH_MONEY")
Event.register("EVENT_RECHARGE_SKILL_UPDATE")
Event.register("EVENT_RECHARGE_SKILL_REMOVE")
Event.register("EVENT_RECHARGE_SKILL_CAST")
Event.register("EVENT_RECHARGE_SKILL_RESET")
Event.register("EVENT_ALL_RECHARGE_SKILL_RESET")
Event.register("EVENT_TELEPORT_SHADER_ENABLE")
Event.register("EVENT_TELEPORT_SHADER_DISABLE")
Event.register("EVENT_REGION_ENTER")
Event.register("EVENT_REGION_LEAVE")

if World.isClient then
    Event.register("EVENT_SHOW_BOTTOM_MESSAGE")
    Event.register("EVENT_TEAM_SHOP_REFRESH")
    Event.register("EVENT_ITEM_SHOP_UPDATE")
    Event.register("EVENT_PAY_SHOP_UPDATE")
    Event.register("EVENT_PLAY_GLIDING_EFFECT")
    Event.register("EVENT_ITEM_SKILL_SHOP_UPDATE")
    Event.register("EVENT_ITEM_SKILL_EQUIP_UPDATE")
else
    --TODO
end