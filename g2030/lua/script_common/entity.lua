-- 自动同步属性定义
local ValueDef		= T(Entity, "ValueDef")
-- key				= {isCpp,	client,	toSelf,	toOther,	init,	saveDB}
ValueDef.jumpCount	= {false,	true,	false,	false,      1,		false}
ValueDef.curExp		= {false,	false,	true,	true,       0,		true}--当前锻炼值
ValueDef.curLevel	= {false,	false,	true,	true,       1,		true}--当前阶数
ValueDef.curHp		= {false,	false,	true,	true,       1,		false}--当前血量
ValueDef.WeaponId   = {false,	false,	true,	true,       1,		true}--当前武器id
ValueDef.SashId     = {false,	false,	true,	true,       10,		true}--当前腰带id
ValueDef.teamId		= {false,	true,	true,	true,       0,		true}--阵营Id

---获得跳跃次数
function Entity:getJumpCount()
    return self:getValue("jumpCount") or 1
end

---减少跳跃次数
function Entity:decJumpCount()
    local jumpCount = self:getValue("jumpCount")
    if jumpCount > 0 then
        self:setValue("jumpCount", jumpCount - 1)
    end
end

---获得最大跳跃次数
function Entity:getMaxJumpCount()
    --TODO
    return 6
end

---获取每次锻炼增幅
function Entity:getPerExpPlus()
    ---TODO exp up calc func
    return 1*self:getValue("WeaponId")
end
---获取当前锻炼值
function Entity:getCurExp()
    return self:getValue("curExp")
end
---设置当前锻炼值上限
function Entity:getMaxExp()
    ---TODO exp limit calc func
    return 1*self:getValue("SashId")
end


---
---
---当前血量上限
function Entity:getMaxHp()
    ---TODO hp limit calc func
    return 100+self:getCurExp()*5
end
---
---当前血量
function Entity:getCurHp()
    ---TODO hp limit calc func
    return self:getValue("curHp")
end
function Entity:getCurDamage()
    ---TODO hp limit calc func
    return 1+self:getCurExp()*5
end
---
---当前伤害减免
function Entity:getDefFactor()
    ---TODO hp limit calc func
    return 1+self:getCurExp()*5
end

---获取阵营Id
function Entity:getTeamId()
    return self:getValue("teamId") or 0
end

---设置阵营Id
function Entity:setTeamId(id)
    self:setValue("teamId", id)
end