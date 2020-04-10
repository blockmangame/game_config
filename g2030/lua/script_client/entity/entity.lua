local ClientBuffId = L("ClientBuffId", 0)

function Entity.ValueFunc:curHp(value)
    Lib.emitEvent(Event.EVENT_HP_CHANGE)
end
function Entity.ValueFunc:curExp(value)
    Lib.emitEvent(Event.EVENT_EXP_CHANGE)
end
function Entity.ValueFunc:maxExp(value)
    Lib.emitEvent(Event.EVENT_EXP_CHANGE)
end

function Entity.ValueFunc:jumpCount(value)
    print("Entity.ValueFunc:jumpCount " .. value)
end

function EntityClient:addClientBuff(name, id, time)
    if not id then
        id = ClientBuffId - 1
        ClientBuffId = id
    end
    local buff = {
        cfg = Entity.BuffCfg(name),
        id = id,
        owner = self,
        time = time
    }

    for _, nm in ipairs(buff.cfg.avoidBuff or {}) do
        if not nm:find("/") then
            nm = buff.cfg.plugin .. "/" .. nm
        end
        if self:getTypeBuff("fullName", nm) then
            return nil
        end
    end

    for _, nm in ipairs(buff.cfg.removeBuff or {}) do
        if not nm:find("/") then
            nm = buff.cfg.plugin .. "/" .. nm
        end
        self:removeTypeBuff("fullName", nm)
    end

    self:data("buff")[id] = buff
    self:calcBuff(buff, true)
    if self.isMainPlayer then
        Lib.emitEvent(Event.DRAW_BUFFICON,buff)
        Lib.emitEvent(Event.FETCH_ENTITY_INFO,true) -- 更新buff后需要更新entity的属性视图
    end
    return buff
end

function EntityClient:removeTypeBuff(key, value)
    for id, buff in pairs(self:data("buff")) do
        if buff.cfg[key] == value then
            self:removeClientBuff(buff)
        end
    end
end