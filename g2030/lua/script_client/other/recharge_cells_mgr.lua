local cellsMgr = L("cellsMgr", {})

local function resetRechargeTimer(info)
    if info.rechargeTimer then
        info.rechargeTimer()
        info.rechargeTimer = nil
    end
end

local function resetCellRechargeTimer(cell)
    if not cell then
        return
    end
    cell:invoke("RESET_RECHARGE")
end

local function updateCellCount(cell, count)
    if not cell then
        return
    end
    cell:invoke("COUNT", count)
end

local function cellRecharge(skillRCellInfo)
    updateCellCount(skillRCellInfo.cell, skillRCellInfo.curRechargeCount)
    resetRechargeTimer(skillRCellInfo)
    resetCellRechargeTimer(skillRCellInfo.cell)
    if skillRCellInfo.curRechargeCount >= skillRCellInfo.maxRechargeCount then
        return false
    end
    
    if skillRCellInfo.cell then
        skillRCellInfo.cell:invoke("RECHARGE", 
            skillRCellInfo.startTimerTick, skillRCellInfo.updateTimerTick, skillRCellInfo.stopTimerTick)
    end
    skillRCellInfo.rechargeTimer = World.Timer(skillRCellInfo.stopTimerTick - skillRCellInfo.updateTimerTick, function()
        skillRCellInfo.curRechargeCount = skillRCellInfo.curRechargeCount + 1
        local now = World.Now()
        skillRCellInfo.startTimerTick = now
        skillRCellInfo.updateTimerTick = now
        skillRCellInfo.stopTimerTick = now + skillRCellInfo.rechargeTime
        cellRecharge(skillRCellInfo)
    end)
end

local function initCellData(cell, now, maxRechargeCount, rechargeTime)
    return {
        maxRechargeCount = maxRechargeCount,
        curRechargeCount = maxRechargeCount,
        cell = cell,
        startTimerTick = now,
        updateTimerTick = now,
        stopTimerTick = now,
        rechargeTime = rechargeTime,
        rechargeTimer = nil
    }
end

Lib.subscribeEvent(Event.EVENT_RECHARGE_SKILL_UPDATE, function(fullName, cell)
    local cfg = Skill.Cfg(fullName)
    local skillRCell = cellsMgr[fullName]
    local now = World.Now()
    if not skillRCell then
        skillRCell = initCellData(cell, now, cfg.maxRechargeCount, cfg.rechargeTime)
        cellsMgr[fullName] = skillRCell
    else
        skillRCell.updateTimerTick = now
        skillRCell.cell = cell
    end
    cellRecharge(skillRCell)
end)

Lib.subscribeEvent(Event.EVENT_RECHARGE_SKILL_REMOVE, function(fullName)
    local skillRCell = cellsMgr[fullName]
    if not skillRCell then
        return
    end
    resetCellRechargeTimer(skillRCell.cell)
    skillRCell.cell = nil
end)

Lib.subscribeEvent(Event.EVENT_RECHARGE_SKILL_CAST, function(params)
    local fullName = params.name
    local _curRechargeCount = params.curRechargeCount
    local _beginRechargeTime = params.beginRechargeTime 
    local _updateRechargeTime = params.updateRechargeTime
    local skillRCell = cellsMgr[fullName]
    if not skillRCell then
        return
    end
    skillRCell.curRechargeCount = _curRechargeCount
    skillRCell.cell:invoke("COUNT", skillRCell.curRechargeCount > 0 and skillRCell.curRechargeCount or 0)

    skillRCell.startTimerTick = _beginRechargeTime
    skillRCell.updateTimerTick = _updateRechargeTime
    skillRCell.stopTimerTick = _beginRechargeTime + skillRCell.rechargeTime
    cellRecharge(skillRCell)
end)

local function resetSkillRCell(skillRCell)
    local now = World.Now()
    resetRechargeTimer(skillRCell)
    resetCellRechargeTimer(skillRCell.cell)
    updateCellCount(skillRCell.cell, skillRCell.maxRechargeCount)
    skillRCell.startTimerTick = now
    skillRCell.updateTimerTick = now
    skillRCell.stopTimerTick = now
    
    skillRCell.curRechargeCount = skillRCell.maxRechargeCount
end

Lib.subscribeEvent(Event.EVENT_RECHARGE_SKILL_RESET, function(fullName)
    local skillRCell = cellsMgr[fullName]
    if not skillRCell then
        return
    end
    resetSkillRCell(skillRCell)
end)

Lib.subscribeEvent(Event.EVENT_ALL_RECHARGE_SKILL_RESET, function()
    local now = World.Now()
    for fullName, skillRCell in pairs(cellsMgr) do
        resetSkillRCell(skillRCell)
    end
end)