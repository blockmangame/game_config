local function entityValueDefInit(entity,cfg)
    if cfg.entityMaxHp then
        entity:setNPCMaxHp(BigInteger.Create(cfg.entityMaxHp[1],cfg.entityMaxHp[2]))
    end
    if cfg.entityBaseDmg then
        entity:setNPCBaseDmg(BigInteger.Create(cfg.entityMaxHp[1],cfg.entityMaxHp[2]))
    end
end
---
---重写创建Entity方法，加入npc血量和攻击力
---
function EntityServer.Create(params)
    local cfg = Entity.GetCfg(params.cfgName)
	if cfg == nil then return end
    assert(cfg.id, params.cfgName)	-- 没填id_mapping？
    local entity = EntityServer.CreateEntity(cfg.id)
    if params.name then
        entity.name = params.name
    end
	entity:invokeCfgPropsCallback()
    entity:resetData()
	if params.pos then
		entity:setMapPos(params.map or params.pos.map, params.pos, params.ry, params.rp)
	end
	local mainData = entity:data("main")
	if not entity.isPlayer or (cfg.reviveTime or -1) > 0 then
		entity:setRebirthPos(params.pos)
	end
	if params.enableAI or params.aiData or cfg.enableAI then
		mainData.enableAI = true
		local enableStateMachine = params.enableAIStateMachine
		if enableStateMachine == nil then
			enableStateMachine = cfg.enableAIStateMachine
		end
		for key, value in pairs(params.aiData or {}) do
			entity:setAiData(key, value)
		end
		entity:data("aiData").enableStateMachine = enableStateMachine ~= false
		entity:startAI()	
	end
	if params.owner then
		entity:setValue("ownerId", params.owner.objID)
	end
	entity:setValue("level", params.level or 1, true)
	entity:setValue("camp", params.camp or cfg.clique or cfg.camp or 0, true)
    local entityData = params.entityData or {}
    for k, v in pairs(entityData.vars or params.vars or {}) do
        entity.vars[k] = v
    end
	for key, value in pairs(cfg.passiveBuffs or {}) do
		entity:addBuff(value.name, value.time)
    end
    entityValueDefInit(entity,cfg)
    return entity
end
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
---
---重写【是否可攻击】方法
---
function EntityServer:canAttack(target)
	if not Entity.canAttack(self, target) then
		return false
    end
    if target.isPlayer then
        return true
    end
    if target:cfg().invincible then
        return false
    end
	return true
end
function EntityServer:doAttack(info)
    local attackProps,defenseProps = self:getDamageProps(info)
    --ocal damage = math.max(attackProps.damage * attackProps.dmgFactor - defenseProps.defense, 0) * attackProps.damagePct
    -- print("---------doAttack------damage-1-----------------",attackProps.dmgBase)
    -- print("---------doAttack------damage--2----------------",attackProps.dmgBaseRat)
    -- print("---------doAttack------damage--3----------------",attackProps.dmgFactor)
    -- print("---------doAttack------damage--4----------------",attackProps.atk)
    -- print("---------doAttack------damage--5----------------",attackProps.dmgRealPlu)
    -- print("---------doAttack------damage--6----------------",defenseProps.hurtSub)
    local damage =  math.max(attackProps.dmgBase+ attackProps.atk*(attackProps.dmgFactor+ attackProps.dmgBaseRat)*attackProps.dmgRealPlu*defenseProps.hurtSub, 1)
    -- print("---------doAttack------damage------------------",damage)
    info.target:doDamage({
        from = self,
        damage = damage,
        skillName = info.originalSkillName,
        damageIsCrit = false,
        cause = info.cause or "NORMAL_ATTACK",
    })
end
---
---自动锻炼方法
---
function EntityServer:doAutoExp()
    self:addCurExp()
    local nextTime = self:getAutoExp() *20;
    if nextTime>0 then
        self:timer(nextTime, function ()
            self:doAutoExp()
        end   )
    end
    
end
---
---治疗方法
---当玩家add了回血buff->HealingSpd变为正数->调用doHealing()->立即进行一次治疗->判断HealingSpd是否为0->开启计时器->loop
---当玩家remove了回血
---
function EntityServer:doHealing()
    
    local healVal =self:getMaxHp() *self:getHealingVal()* self:getHealingPlu()

    if healVal>0 and  self:deltaHp(healVal) then
        self:ShowFlyNum(healVal)
    end


    local nextTime = self:getHealingSpd() *20;
    if nextTime>0 then
        self:timer(nextTime, function ()
            self:doHealing()
        end   )
    end
end
-- function EntityServer:doDropDamage(speed)
--     print("------------drop------")
-- 	self:doDamage({
-- 		damage = self:getMaxHp(),
-- 		cause = "ENGINE_DO_DROP_DAMAGE",
-- 	})
-- end
function player_touchdown(entity)
	entity:doDamage({
		damage = entity:getMaxHp(),
		cause = "ENGINE_TOUCHDOWN",
	})
end
function EntityServer:doDamage(info)
    
    local damage, from, isRebound = info.damage, info.from, info.isRebound
    local damageCause = assert(info.cause, "must have a cause of doDamage")
    print("---------------damageCause-----------------",damageCause)
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
        self:sendPacketToTracking({
            pid = "ShowNumberUIOnEntity",
            beginOffsetPos =Lib.v3(0, 1, 0),
            FollowObjID = self.objID,
            number = deltaHp,
            distance = 2,
            imgset = deltaHp<0 and "red_numbers" or "green_numbers",
            imageWidth = 40,
            imageHeight = 40,
            isBigNum = true
        },true)
  --      WorldServer.BroadcastPacket()
    end
end

---
---当玩家add了自动售卖buff
---
function EntityServer:doAutoSellExp(buff)
    if buff.removed then	--可能被叠加规则、超时等情况清除掉了
        return
    end
    self:timer(20, function ()
        if Game.GetState() == "GAME_GO" and self.curHp>0 then
            if self:isExpFull() then
                self:sellExp()
                self:doAutoSellExp(buff)
            end
        end
    end   )
end

---
---当玩家add了自动普攻buff
---
function EntityServer:doAutoNormalAtk(buff)
    if buff.removed then	--可能被叠加规则、超时等情况清除掉了
        return
    end
    self:timer(20, function ()
        if Game.GetState() == "GAME_GO" and self.curHp>0 then
            self:addCurExp()
            self:doAutoNormalAtk(buff)
        end
    end   )
end

local function entityPlayAction(entity, actionName, actionTime, includeSelf)
    if not entity or not actionName then
        return false
    end

    local packet = {
        pid = "EntityPlayAction",
        objID = entity.objID,
        action = actionName,
        time = actionTime,
    }
    entity:sendPacketToTracking(packet, includeSelf)
    return true
end

local function entityForceTargetPos(entity, targetPos, includeSelf)
    if not entity then
        return false
    end

    local packet = {
        pid = "EntityForceTargetPos",
        objID = entity.objID,
        targetPos = targetPos,
    }
    entity:sendPacketToTracking(packet, includeSelf)
    return true
end

local function getTargetPos(position, from)
    local yaw = (360 - from:getRotationYaw() + 90) % 360
    local pos = Lib.tov3(Lib.copy(position))
    local new_off_x, new_off_y = pos.x, pos.z
    local arc1 = math.atan(new_off_y, -new_off_x)
    local deg1 = math.deg(arc1)
    local deg2 = yaw - (360 - deg1 + 90) % 360
    local arc2 = math.rad(deg2)
    local len = (new_off_x ^ 2 + new_off_y ^ 2) ^ 0.5
    local offx = len * math.cos(arc2)
    local offy = len * math.sin(arc2)
    pos.x = -offx
    pos.z = offy

    local targrtpos = from:getPosition() + pos
    return targrtpos
end

function Entity:beHitBack(backPos, falldowanAc, falldownAcTime, getupAc)
    if not backPos then
        return
    end
    local falldownTime = falldownAcTime
    local targetPos = getTargetPos(backPos, self)
    if falldowanAc then
        entityPlayAction(self, falldowanAc, falldownTime, true)
    end
    if targetPos then
        self.forceTargetPos = targetPos
        self.forceTime = 5

        entityForceTargetPos(self, targetPos, true)
    end

    local entity = self
    local fun = function(entity, Pos, ac)
        falldownTime = falldownTime - 1
        local distance = Lib.getPosDistance(entity:getPosition(), Pos)
        if distance <= 0.01 then
            entityPlayAction(entity, ac, -1, true)
            return false
        end

        if falldownTime <= 0 then
            return false
        end
        return true
    end
    self.hitBackTimer = World.Timer(2, fun, entity, targetPos, getupAc)
end

function EntityServer:stopHitBack()
    if self.hitBackTimer then
        self.hitBackTimer = nil
        entityPlayAction(self, "getup", -1, true)
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
---重写持续伤害buff
---
function Entity.EntityProp:continueDamage(value, add, buff)
    if add and self.curHp <= 0 then
        return
    end
    local from = buff.from
	local continueDamage = self:data("continueDamage")
  --  continueDamage.damage = (continueDamage.damage or 0) + (add and value or -value)
    continueDamage.dmgRat = value.dmgRat
    continueDamage.dmgBase = BigInteger.Create(value.dmgBase[1],value.dmgBase[2])
    continueDamage.spd =  (add and value.spd or 0)
    if add then
        if from and from.isPlayer then
            from:doAttack({target = self, skill = {dmgRat = continueDamage.dmgRat,dmgBase = continueDamage.dmgBase}, originalSkillName = buff.fullName, cause = continueDamage.spd==0 and "ENGINE_PROP_ONCE_DAMAGE" or "ENGINE_PROP_CONTINUE_DAMAGE"})
        end
    end
	if not continueDamage.timer then
        continueDamage.timer = self:timer(continueDamage.spd*20, function()
            if from and from.isPlayer then
                from:doAttack({target = self, skill = {dmgRat = continueDamage.dmgRat,dmgBase = continueDamage.dmgBase}, originalSkillName = buff.fullName, cause = "ENGINE_PROP_CONTINUE_DAMAGE"})
            end
            if continueDamage.spd <= 0 then
				continueDamage.timer = nil
				return false
			end
			return true
		end)
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
---
---自动锻炼buff，每间隔value秒加一次效率锻炼值
---
function Entity.EntityProp:autoExp(value, add, buff)
    print(value, add)
    if self.curHp <= 0 then
        return
    end
    local val = add and value or 0
    self:setAutoExp(val)
    if add then
        self:doAutoExp()
    end
    
end

function Entity.ValueFunc:curLevel(value)
    Lib.emitEvent(Event.EVENT_LEVEL_CHANGE,value)
end

---
---自动售卖
---
function Entity.EntityProp:autoSellExp(value, add, buff)
    if add then
        self:doAutoSellExp(buff)
    end
end

---
---自动普攻
---
function Entity.EntityProp:autoNormalAtk(value, add, buff)
    if add then
        self:doAutoNormalAtk(buff)
    end
end
