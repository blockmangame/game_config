---
---自定义伤害公式
---因为要用ValueDef的血量和伤害替换掉引擎自带的curHp和damage
---此处由于curHp在许多地方用作死亡条件判断，故保留，当ValueDef的血量为0时将cur设置为0，否则设置为1
---
function EntityServer:getDamageProps(info)
    local skill = info.skill

    local attackProps = setmetatable({}, {
        __index = function(t, name)
            if name == "atk" then
                local value = self:getCurDamage()
                return value-- + (skill and skill[name] or 0)
            elseif name == "dmgFactor" then
                return self:getDmgPlu()
            elseif name == "dmgRealPlu" then
                return self:getDmgRealPlu()
            elseif name == "dmgBaseRat" then
                return (skill and skill["dmgRat"] or World.cfg.normalAtkRat)
            elseif name == "dmgBase" then
                return (skill and skill["dmgBase"] or 0)
            end
        end,
        __newindex = function(...) error("not allowed set prop value") end
    })
    local target = assert(info.target, "need target")
    local defenseProps = setmetatable({}, {
        __index = function(t, name)
            if name == "hurtSub" then
                return target:getHurtSub()
            else
                return 1
            end
        end,
        __newindex = function(...) error("not allowed set prop value") end
    })
    return attackProps,defenseProps
end
function EntityServer:doAttack(info)
    local attackProps,defenseProps = self:getDamageProps(info)
    --ocal damage = math.max(attackProps.damage * attackProps.dmgFactor - defenseProps.defense, 0) * attackProps.damagePct
    local damage = math.floor(math.max(attackProps.dmgBase* attackProps.atk*(attackProps.dmgFactor+ attackProps.dmgBaseRat)*attackProps.dmgRealPlu*defenseProps.hurtSub, 1))
    info.target:doDamage({
        from = self,
        damage = damage,
        skillName = info.originalSkillName,
        damageIsCrit = false,
        cause = info.cause or "NORMAL_ATTACK",
    })
end
---
---治疗方法
---当玩家add了回血buff->HealingSpd变为正数->调用doHealing()->立即进行一次治疗->判断HealingSpd是否为0->开启计时器->loop
---当玩家remove了回血
---
function EntityServer:doHealing()
    
    local healVal =self:getMaxHp() *self:getHealingVal()* self:getHealingPlu()
    print("--------doHealing-----getMaxHp---------",self:getMaxHp())
    print("--------doHealing-----getHealingVal---------",self:getHealingVal())
    print("--------doHealing----- self:getHealingPlu()---------", self:getHealingPlu())
    -- print("=========doHealing==========",healVal)
    -- print("=========doHealing=spd=========",self:getHealingSpd())

    if healVal <=0 then
        return
    end
    if self:deltaHp(healVal) then
        print("--------doHealing--------------",healVal)
        print("--------doHealing--------------",Lib.v2s(healVal,3))
        self:ShowFlyNum(healVal)
    end


    local nextTime = self:getHealingSpd() *20;
    if nextTime>=0 then
        self:timer(nextTime, function ()
            self:doHealing()
        end   )
    end
end
function EntityServer:doDamage(info)
    local damage, from, isRebound = info.damage, info.from, info.isRebound
    local damageCause = assert(info.cause, "must have a cause of doDamage")

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

    self:ShowFlyNum(-damage)
    --function Actions.ShowNumberUIOnEntity(data, params, context)
    --
    --end
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
        self:onDead({
            from = from,
            skillName = info.skillName,
            cause = damageCause or "ENGINE_DODAMAGE",
        })
    end
end

---
---显示伤害飘字(全服广播)
---@TODO 后续可优化为视域范围内广播
---
function EntityServer:ShowFlyNum(deltaHp)
    if self and self.isPlayer then
        WorldServer.BroadcastPacket({
            pid = "ShowNumberUIOnEntity",
            beginOffsetPos =Lib.v3(0, 1, 0),
            FollowObjID = self.objID,
            number = deltaHp,
            distance = 2,
            imgset = deltaHp<0 and "red_numbers" or "green_numbers",
            imageWidth = 40,
            imageHeight = 40,
            isBigNum = true
        })
    end
end


---
---以下为添加EntityProp function类成员
---

---
---回复血量buff
---每隔rHpPct.time秒恢复总血量的rHpPct.pct倍
---
function Entity.EntityProp:healingPct(value, add, buff)
    print(value, add)
    if self.curHp <= 0 then
        return
    end
    local useVal = {}
    useVal.pct =  (add and value.pct or -value.pct)--(rHpPct.pct or 0) + (add and value or -value)
    useVal.spd =  (add and value.spd or 0)
    self:setHealing(useVal.pct,useVal.spd)
    if add then
        self:doHealing()
    end

end
---
---回复血量buff
---
function Entity.EntityProp:healingPlusPct(value, add, buff)
    print(value, add)
    if self.curHp <= 0 then
        return
    end
    local val = add and value or -value
    self:deltaHealingPlu(val)
end

---
---吸血buff
---
function Entity.EntityProp:suckHpPct(value, add, buff)
    print(value, add)
    if self.curHp <= 0 then
        return
    end
    local val = add and value or -value
    self:deltaSuckBlood(val)
end
---
---减伤buff
---收到他人伤害时，该伤害变为原来的（1-hSubPct）倍
---
function Entity.EntityProp:hurtSubPct(value, add, buff)
    print(value, add)
    if self.curHp <= 0 then
        return
    end
    local val = add and value or -value
    self:deltaHurtSub(val)
end
---
---阵营buff
---阵营对配置属性的加成
---
function Entity.EntityProp:teamProp(value, add, buff)
    local team = Game.GetTeam(value.teamId)
    local lv = 0
    if not team then
        return
    end
    if add then
        lv = team:getLevel()
    end
    for _, prop in ipairs(value.props) do
        local var = team:getLevelCfg(lv, prop)
        if var then
            self.EntityProp[prop](self, tonumber(var), add)
        end
    end
end
---
---最大锻炼值加成buff，自然数
---
function Entity.EntityProp:expMax(value, add, buff)
    print(value, add)
    if self.curHp <= 0 then
        return
    end
    local useVal = {}
    useVal.val =  (add and value.val or -value.val)--(rHpPct.pct or 0) + (add and value or -value)
    useVal.bit =  value.bit or 0
    self:deltaExpMaxPlus(BigInteger.Create(useVal.val,useVal.bit))
end
---
---最大锻炼值加成buff，自然数
---
function Entity.EntityProp:perExp(value, add, buff)
    print(value, add)
    if self.curHp <= 0 then
        return
    end
    local useVal = {}
    useVal.val =  (add and value.val or -value.val)--(rHpPct.pct or 0) + (add and value or -value)
    useVal.bit =  value.bit or 0
    self:deltaPerExpPlus(BigInteger.Create(useVal.val,useVal.bit))
end

function Entity.ValueFunc:curLevel(value)
    Lib.emitEvent(Event.EVENT_LEVEL_CHANGE,value)
end


