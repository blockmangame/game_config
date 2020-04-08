local sceneIndicator, sceneIndicatorPoint
local indicatorRange, indicatorPointRange
local indicatorEffect_normal, indicatorEffect_activation
local indicatorPointEffect_normal, indicatorPointEffect_activation

local function resetProp()
    sceneIndicator,sceneIndicatorPoint = nil, nil
    indicatorRange, indicatorPointRange = 1, 1
    indicatorEffect_normal, indicatorEffect_activation = nil, nil
    indicatorPointEffect_normal, indicatorPointEffect_activation = nil, nil
end

--[[
    "sceneIndicatorProp": {
        "range": {
            "indicatorRange": 5,
            "indicatorPointRange": 1
        },
        "_range": "场景指示器的范围/大小(半径) 和 指示点的范围/大小(半径)",
        "cfg": {
            "indicatorEntityCfg": "myplugin/indicatorEntity",
            "_indicatorEntityCfg": "指示器的entity",
            "indicatorPointEntityCfg": "myplugin/indicatorEntity",
            "_indicatorPointEntityCfg": "指示器的落点entity，不配则没有指示器落点"
        },
        "_cfg": "场景指示器是 entity 带上场景指示器特效做成的。entity一般是用一个透明actor的entity即可。",
        "effect": {
            "indicatorEffect_normal": "myplugin/sceneIndicator_blue_base_buff",
            "indicatorPointEffect_normal": "myplugin/sceneIndicatorPoint_blue_base_buff",
            "indicatorEffect_activation": "myplugin/sceneIndicator_red_base_buff",
            "indicatorPointEffect_activation": "myplugin/sceneIndicatorPoint_red_base_buff"
        },
        "_effect": "场景指示器特效，包括正常状态下的指示器和落点以及特殊(激活)状态下的指示器和落点四个特效"
    },
    "_sceneIndicatorProp": "场景指示器的相关属性"
]]
Lib.subscribeEvent(Event.EVENT_SCENE_SKILL_TOUCH_MOVE_BEGIN, function(params)
    if sceneIndicator then
        sceneIndicator:destroy()
    end
    if sceneIndicatorPoint then
        sceneIndicatorPoint:destroy()
    end
    resetProp()
    local skillCfg = params.skillCfg
    if not skillCfg then
        return
    end
    local sceneIndicatorProp = skillCfg.sceneIndicatorProp or {}

    local sceneIndicatorProp_range = sceneIndicatorProp.range or {}
    indicatorRange = sceneIndicatorProp_range.indicatorRange
    indicatorPointRange = sceneIndicatorProp_range.indicatorPointRange

    local sceneIndicatorProp_effect = sceneIndicatorProp.effect or {}
    indicatorEffect_normal = sceneIndicatorProp_effect.indicatorEffect_normal
    indicatorPointEffect_normal = sceneIndicatorProp_effect.indicatorPointEffect_normal
    indicatorEffect_activation = sceneIndicatorProp_effect.indicatorEffect_activation
    indicatorPointEffect_activation = sceneIndicatorProp_effect.indicatorPointEffect_activation
    
    local sceneIndicatorProp_cfg = sceneIndicatorProp.cfg or {}
    if sceneIndicatorProp_cfg.indicatorEntityCfg then
        sceneIndicator = EntityClient.CreateClientEntity({cfgName = sceneIndicatorProp_cfg.indicatorEntityCfg})
        if indicatorEffect_normal then
            sceneIndicator:addClientBuff(indicatorEffect_normal)
        end
    end
    if sceneIndicatorProp_cfg.indicatorPointEntityCfg then
        sceneIndicatorPoint = EntityClient.CreateClientEntity({cfgName = sceneIndicatorProp_cfg.indicatorPointEntityCfg})
        if indicatorPointEffect_normal then
            sceneIndicatorPoint:addClientBuff(indicatorPointEffect_normal)
        end
    end
end)

local function resetClientBuff(obj, isActivion, activionBuff, normalBuff)
    if isActivion then
        if activionBuff and not obj:getTypeBuff("fullName", activionBuff) then
            obj:addClientBuff(activionBuff)
        end
        if normalBuff and obj:getTypeBuff("fullName", normalBuff) then
            obj:removeClientTypeBuff("fullName", normalBuff)
        end
    else
        if activionBuff and obj:getTypeBuff("fullName", activionBuff) then
            obj:removeClientTypeBuff("fullName", activionBuff)
        end
        if normalBuff and not obj:getTypeBuff("fullName", normalBuff) then
            obj:addClientBuff(normalBuff)
        end
    end
end

Lib.subscribeEvent(Event.EVENT_SCENE_SKILL_TOUCH_MOVE, function(params)
    if not sceneIndicator then
        return
    end
    local targetPos = params.targetPos
    local isActivion = params.isActivion 
    local isReclacTargetPos = params.isReclacTargetPos
    
    if isReclacTargetPos then -- CLAC targetPos
        local MePos = Me:getPosition()
        if Lib.getPosDistance(MePos, targetPos) < indicatorRange then
            local yaw = Lib.v3AngleXZ(Lib.v3cut(targetPos, MePos))
            local tempV3 = {x = 0, y = 0, z = indicatorRange}
            tempV3 = Lib.posAroundYaw(tempV3, yaw)
            targetPos.x = MePos.x + tempV3.x
            targetPos.z = MePos.z + tempV3.z
        end
    end

    if sceneIndicator then
        sceneIndicator:setPosition(targetPos)
        resetClientBuff(sceneIndicator, isActivion, indicatorEffect_activation, indicatorEffect_normal)
    end
    if sceneIndicatorPoint then
        if isReclacTargetPos then
            local yaw = Lib.v3AngleXZ(Lib.v3cut(Me:getPosition(), targetPos))
            local tempV3 = {x = 0, y = 0, z = indicatorRange - indicatorPointRange}
            tempV3 = Lib.posAroundYaw(tempV3, yaw)
            sceneIndicatorPoint:setPosition(Lib.v3add(targetPos, tempV3))
        else
            sceneIndicatorPoint:setPosition(targetPos)
        end
        resetClientBuff(sceneIndicatorPoint, isActivion, indicatorPointEffect_activation, indicatorPointEffect_normal)
    end
end)

Lib.subscribeEvent(Event.EVENT_SCENE_SKILL_TOUCH_MOVE_END, function()
    if sceneIndicator then
        sceneIndicator:destroy()
    end
    if sceneIndicatorPoint then
        sceneIndicatorPoint:destroy()
    end
    resetProp()
end)