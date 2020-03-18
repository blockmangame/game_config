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
            Lib.emitEvent(Event[clickEvent], objID)
        end
    end
    context.callback = callback
end

function Player:interactionEventHandler(name, ...)
    local func = handles[name]
    if not func then
        print("not definded handle: ", name)
        return
    end
    func(self, ...)
end