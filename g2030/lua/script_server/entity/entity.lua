---
---自定义伤害公式
---因为要用ValueDef的血量和伤害替换掉引擎自带的curHp和damage
---此处由于curHp在许多地方用作死亡条件判断，故保留，当ValueDef的血量为0时将cur设置为0，否则设置为1
---
function EntityServer:getDamageProps(info)
    local skill = info.skill

    local attackProps = setmetatable({}, {
        __index = function(t, name)
            if name == "damage" then
                local value = self:getCurDamage()
                return value + (skill and skill[name] or 0)
            elseif name == "dmgFactor" then
                return 1
            end
        end,
        __newindex = function(...) error("not allowed set prop value") end
    })
    local target = assert(info.target, "need target")
    local defenseProps = setmetatable({}, {
        __index = function(t, name)
            if name == "defFactor" then
                return 1
            else
                return 1
            end
        end,
        __newindex = function(...) error("not allowed set prop value") end
    })
    return attackProps,defenseProps
end
function EntityServer:doAttack(info)
    print("===================doAttack==========",info)
    local attackProps,defenseProps = self:getDamageProps(info)
   -- local damage = math.max(attackProps.damage * attackProps.dmgFactor - defenseProps.defense, 0) * attackProps.damagePct
    local damage = math.max(attackProps.damage * attackProps.dmgFactor, 0)*defenseProps.defFactor
    info.target:doDamage({
        from = self,
        damage = damage,
        skillName = info.originalSkillName,
        damageIsCrit = false,
        cause = info.cause or "NORMAL_ATTACK",
    })
end

function EntityServer:doDamage(info)
    local damage, from, isRebound = info.damage, info.from, info.isRebound
    local damageCause = assert(info.cause, "must have a cause of doDamage")

    --if self:prop("undamageable")>0 then
    --    return
    --else
    print("===================damage==========",damage)
    print("===================curHp==========",self.curHp)
    if damage <= 0 then
        return
    elseif self.curHp <= 0 then
        return
    elseif isRebound then
        local curHp = self:deltaHp(-damage)
        if curHp <= 0 then
            self:onDead({
                from = from,
                cause = damageCause or "ENGINE_DO_DAMAGE_REBOUND",
            })
        end
        return
    end

    self:deltaHp(-damage)
    --self.curHp = 0


    Trigger.CheckTriggers(self:cfg(), "ENTITY_DAMAGE", {obj1=self, obj2=from, damageIsCrit = info.damageIsCrit or false, damage=damage, skillName = info.skillName})
    if from then
        Trigger.CheckTriggers(from:cfg(), "ENTITY_DODAMAGE", {obj1 = from, obj2 = self, damageIsCrit = info.damageIsCrit or false, damage=damage, skillName = info.skillName})
    end
    if from and from ~= self then
        if damage > 0 then
            local lifeSteal = from:prop("lifeSteal") * damage
            if lifeSteal > 0 then
                self:deltaHp(lifeSteal)
            end
            local dmgRebound = self:prop("dmgRebound") * damage
            if dmgRebound > 0 then
                from:doDamage({
                    damage = dmgRebound,
                    from = self,
                    isRebound = true,
                    cause = "ENGINE_DO_DAMAGE_REBOUND",
                })
            end
        end
        if from.curHp > 0 then
            self:handleAIEvent("onHurt", from, damage)
        end
    end

    if self.curHp <= 0 then
        print("====================go die=====================")
        self:onDead({
            from = from,
            skillName = info.skillName,
            cause = damageCause or "ENGINE_DODAMAGE",
        })
    end
end