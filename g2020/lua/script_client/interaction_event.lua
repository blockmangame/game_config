local interactionEventEngineHandler = interaction_event
local handles = {}

function handles:ButtonDisplay(objID, context)
    local canHide, btn = context.canHide, context.btnCfg
    local checkCanHide, checkCanShow = btn.checkCanHide, btn.checkCanShow
    if btn.ridePosIndex then
        checkCanHide = { funcName = "checkRideOnIndex", index = btn.ridePosIndex }
    end
    if checkCanHide then
        canHide = not not Me:checkCond(checkCanHide, objID)
    elseif checkCanShow then
        canHide = not Me:checkCond(checkCanShow, objID)
    end
    if not canHide and Me.customCheckCond then
        local customCheckCanHide, customCheckCanShow = btn.customCheckCanHide, btn.customCheckCanShow
        if customCheckCanHide then
            canHide = not not Me:customCheckCond(customCheckCanHide, objID)
        elseif customCheckCanShow then
            canHide = not Me:customCheckCond(customCheckCanShow, objID)
        end
    end
    context.canHide = canHide
end

function handles:NewButton(objID, context)
    local btn = context.btnCfg
    if btn.showName then
        local object = World.CurWorld:getObject(objID)
        btn.text = object.name or ""
    end
    if btn.showInteractingPlayerName then
        local text = "nil"
        if Me.interactingPlayer then
            local object = World.CurWorld:getObject(Me.interactingPlayer)
            text = object.name
        end
        btn.text = text
    end
end

function handles:ShowSingleUI(objID, context)
    local cfg = context.cfg
    local followParams = cfg.followParams or {
        followScenePos = false,
    }
    local object = World.CurWorld:getObject(objID)
    local offsets = object:cfg().interactionUiFollowOffset
    local centerBtns, aroundBtns, cfgKey = cfg.centerBtns, cfg.aroundBtns, cfg.cfgKey
    local btnCfgs = centerBtns or aroundBtns
    local ridePosIndex = next(btnCfgs) and btnCfgs[1].ridePosIndex
    if ridePosIndex and offsets then
        local offset = offsets[tostring(ridePosIndex)]
        followParams.offset = offset or {x = 0, y = 0.5, z = 0}
    end
    cfg.followParams = followParams
end

function handles:ButtonSetClickAction(objID, context)
    local btnCfg, callback = context.btnCfg, context.callback
    local nextCfgKey = btnCfg.nextCfgKey
    if nextCfgKey then
        callback = function ()
            Me:updateObjectInteractionUI({
                objID = objID,
                show = true,
                cfgKey = nextCfgKey,
            })
        end
    end
    local clickEvent = btnCfg.event
    if clickEvent and Event[clickEvent] then
        callback = function()
            Lib.emitEvent(Event[clickEvent], objID, btnCfg)
        end
    end
    context.callback = callback
end

function interaction_event(name, ...)
    interactionEventEngineHandler(name, ...)
    local func = handles[name]
    if not func then
        return
    end
    func(Me, ...)
end