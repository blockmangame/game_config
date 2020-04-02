local sceneIndicator = nil
local sceneIndicatorAerial = nil
Lib.subscribeEvent(Event.EVENT_SCENE_SKILL_TOUCH_MOVE_BEGIN, function(params)
    if sceneIndicatorAerial or sceneIndicator then
        return
    end
    local skillCfg = params.skillCfg

    -- Test Code ↓
	sceneIndicator = EntityClient.CreateClientEntity({cfgName = "myplugin/player1"}) -- TODO DEL when commit --此人物用于展示用，接入场景指示器后删除
	Entity.setHeadText(sceneIndicator, 0, 0, "此人物用于展示场景指示器用，接入场景指示器后删除相关代码") -- TODO DEL when commit
    -- Test Code ↑
    
end)

Lib.subscribeEvent(Event.EVENT_SCENE_SKILL_TOUCH_MOVE, function(params)
    local targetPos = params.targetPos
    local isTouchCancle = params.isTouchCancle
    
    if sceneIndicator then

        -- Test Code ↓
        sceneIndicator:setPosition(targetPos) -- TODO DEL when commit
        -- Test Code ↑

    end

end)

Lib.subscribeEvent(Event.EVENT_SCENE_SKILL_TOUCH_MOVE_END, function()
    if sceneIndicator then

        -- Test Code ↓
        sceneIndicator:destroy()
        -- Test Code ↑

    end
    if sceneIndicatorAerial then
    
    end
    sceneIndicator = nil
    sceneIndicatorAerial = nil
end)