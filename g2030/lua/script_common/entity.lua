-- 自动同步属性定义
local ValueDef		= T(Entity, "ValueDef")
local playerCfg = World.cfg
print("======BigInteger==========:",Lib.v2s(BigInteger,3))
-- key				= {isCpp,	client,	toSelf,	toOther,	init,	saveDB}
ValueDef.jumpCount	= {false,	true,	false,	false,      1,		false}
ValueDef.maxJumpCount={false,	false,	true,	false,      1,		false}
ValueDef.curExp		= {false,	false,	true,	true,       BigInteger.Create(0),		true}--当前锻炼值
ValueDef.maxExp		= {false,	false,	true,	true,       BigInteger.Create(1,8),	true}--最大锻炼值
ValueDef.perExp 	= {false,	false,	true,	true,       BigInteger.Create(1,5),		false}--每次攻击锻炼值增加
ValueDef.perExpPlu	= {false,	false,	true,	true,       1,		false}--锻炼值加成加成比例（付费特权。双倍）
ValueDef.curLevel	= {false,	false,	true,	true,       1,		true}--当前阶数
ValueDef.curHp		= {false,	false,	true,	true,       BigInteger.Create(playerCfg.baseHp),		false}--当前血量
ValueDef.gold2Plus	= {false,	false,	true,	true,       1,		true}--额外金币转换加成系数（付费特权）
ValueDef.hpMaxPlus	= {false,	false,	true,	true,       1,		true}--生命上限加成系数（付费特权）
ValueDef.suckBlood	= {false,	false,	true,	true,       0,		false}--吸血比例
ValueDef.CDSub	    = {false,	false,	true,	true,       1,		false}--技能CD缩短比例
ValueDef.hurtSub	= {false,	false,	true,	true,       1,		false}    --受伤减免比例
ValueDef.dmgPlu	    = {false,	false,	true,	true,       1,		false}--伤害加成比例
ValueDef.dmgRealPlu	= {false,	false,	true,	true,       1,		false}--神圣伤害加成比例（付费特权。双倍）
ValueDef.healingVal	= {false,	false,	true,	true,       0,		false}--恢复量
ValueDef.healingPlu	= {false,	false,	true,	true,       1,		false}--恢复量加成
ValueDef.healingSpd	= {false,	false,	true,	true,       0,		false}--恢复速率（每隔多少s恢复一次）
ValueDef.WeaponId   = {false,	false,	true,	true,       1,		true}--当前武器id
ValueDef.SashId     = {false,	false,	true,	true,       10,		true}--当前腰带id
ValueDef.teamId		= {false,	true,	true,	true,       0,		true}--阵营Id
ValueDef.teamKills	= {false,	false,	false,	false,       0,		false}--个人阵营击杀数
ValueDef.equip      = {false,	false,	true,	false,      {},		true}--道具商店购买的装备列表
ValueDef.belt       = {false,	false,	true,	false,      {},		true}--道具商店购买的腰带列表
ValueDef.islandLv   = {false,	false,	true,	false,       1,		true}--当前岛屿等级（商店临时解锁用）
ValueDef.ownTeamSkin= {false,   true,    true,  false,      {},     true }--已拥有的阵营皮肤
ValueDef.teamSkinId = {false,   true,    true,  false,       0,     true }--已装备的阵营皮肤id

--====================宠物、式神相关数据================
ValueDef.petEquippedList= {false,   false,  true,   true,       {},    true}--当前角色宠物装备表
ValueDef.plusPetEquippedIndex={false,false, true,   true,       0,      true}--当前角色式神装备表
ValueDef.hadEntityNum   = {false,   false,  true,   false,      0,      true}--当前角色获取过的宠物实体总数（不会减少）
ValueDef.allPetAttr     = {false,   false,  true,   true,       {},    true}--宠物、式神相关数据
--[[
宠物、式神相关数据存储索引说明：索引为createPet后返回的index，通过索引插入的AllPetAttr，该表不为序列，期间可能会出现nil
即强化（消耗）后相关索引项将置为nil
--]]
--[[相关数据(AllPetAttr)内容：
{id = 0,               --宠物or式神的pluginID
 petType = 0,         --是宠物还是式神
 petCoinTransRage = 0,--该宠物Entity当前的金币增益
 petChiTransRate = 0, --该宠物Entity当前的气增益
 plusPetATKRate = 0}, --该式神Entity当前的攻击倍率增益
--]]
--========================END========================

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
    return self:getValue("maxJumpCount") or 1
end

---获取每次锻炼增幅
function Entity:getPerExpPlus()
    ---TODO exp up calc func
    return self:getValue("perExp")*(self:getCurLevel())*self:getValue("perExpPlu")--TODO 宠物加成
end
---设置每次攻击锻炼增幅值变化
function Entity:deltaPerExpPlus(val)
    --assert(tonumber(val), "invalid input:" .. val .. "is not a number")
    self:setValue("perExp",self:getValue("perExp")+val)
end
---获取当前锻炼值
function Entity:getCurExp()
    return self:getValue("curExp")
end
---设置当前锻炼值上限
function Entity:getMaxExp()
    return self:getValue("maxExp")
end
---当前锻炼值可兑换货币
function Entity:getCurExpToCoin()
    return self:getCurExp()*playerCfg.baseExp2GoldVal*(1)*self:getValue("gold2Plus")--TODO 宠物加成
end
---设置最大锻炼值变化
function Entity:deltaExpMaxPlus(val)
  --  assert(tonumber(val), "invalid input:" .. val .. "is not a number")
    self:setValue("maxExp",self:getValue("maxExp")+val)
end
---锻炼值是否已满
function Entity:isExpFull()
    return false--self:getCurExp()>=self:getMaxExp()
end
---获取当前阶数
function Entity:getCurLevel()
    return self:getValue("curLevel")
end
---设置当前阶数
function Entity:setCurLevel(lv)
    return self:setValue("curLevel", lv)
end



---战斗属性相关
---
---

---当前血量上限
function Entity:getMaxHp()
    ---TODO hp limit calc func
    print("-------------getMaxHp------------------",(playerCfg.baseHp+self:getCurExp()*playerCfg.baseExp2Hp)*self:getValue("hpMaxPlus"))
    return (playerCfg.baseHp+self:getCurExp()*playerCfg.baseExp2Hp)*self:getValue("hpMaxPlus")
end
---
---当前血量
---
function Entity:getCurHp()
    return self:getValue("curHp")
end
function Entity:getCurDamage()
  --  return 1+self:getCurExp()*5*self:getDmgPlu()*self:getDmgRealPlu()
    return playerCfg.baseAtk+self:getCurExp()*playerCfg.baseExp2Atk
end
---
---获取伤害加成系数
---
function Entity:getDmgPlu()
    return math.max(self:getValue("dmgPlu"),0)
end
function Entity:deltaDmgPlu(val)
    assert(tonumber(val), "invalid input:" .. val .. "is not a number")
    self:setValue("dmgRealPlu",self:getValue("dmgPlu")+val)
end
---
---获取神圣伤害加成系数
---
function Entity:getDmgRealPlu()
    return math.max(self:getValue("dmgRealPlu"),0)
end
function Entity:deltaDmgRealPlu(val)
    assert(tonumber(val), "invalid input:" .. val .. "is not a number")
    self:setValue("dmgRealPlu",self:getValue("dmgRealPlu")+val)
end
---
---获取吸血系数
---
function Entity:getSuckBlood()
    return math.max(self:getValue("suckBlood"),0)
end
function Entity:deltaSuckBlood(val)
    assert(tonumber(val), "invalid input:" .. val .. "is not a number")
    self:setValue("suckBlood",self:getValue("suckBlood")+val)
end
---
---当前技能CD减免
---
function Entity:getCDSub()
    return math.max(self:getValue("CDSub"),0)
end
function Entity:deltaCDSub(val)
    assert(tonumber(val), "invalid input:" .. val .. "is not a number")
    if val >1 then
        Lib.log("cdSub cannot exceed 1!")
        return
    end
    self:setValue("CDSub",self:getValue("CDSub")-val)
end
---
---获取回复量
---
function Entity:getHealingPlu()
    return math.max(self:getValue("healingPlu"),0)
end
function Entity:deltaHealingPlu(val)
    assert(tonumber(val), "invalid input:" .. val .. "is not a number")
    self:setValue("healingPlu",self:getValue("healingPlu")+val)
end

function Entity:getHealingVal()
    return math.max(self:getValue("healingVal"),0)
end
function Entity:getHealingSpd()
    return math.max(self:getValue("healingSpd"),0)
end
function Entity:setHealing(val,time)
    assert(tonumber(val), "invalid input:" .. val .. "is not a number")
    assert(tonumber(time), "invalid input:" .. val .. "is not a number")

    self:setValue("healingVal",self:getValue("healingVal")+val)
    self:setValue("healingSpd",time)

end
---
---获取伤害减免
---
function Entity:getHurtSub()
    return math.max(self:getValue("hurtSub"),0)
end
function Entity:deltaHurtSub(val)
    assert(tonumber(val), "invalid input:" .. val .. "is not a number")
    if val >1 then
        Lib.log("HurtSub cannot exceed 1!")
        return
    end
    self:setValue("hurtSub",self:getValue("hurtSub")-val)
end

---设置阵营Id
function Entity:setTeamId(id)
    self:setValue("teamId", id)
end

---获取阵营Id
function Entity:getTeamId()
    return self:getValue("teamId") or 0
end

---获取个人阵营击杀数
function Entity:getTeamKills()
    return self:getValue("teamKills") or 0
end

---增加个人阵营击杀数
function Entity:addTeamKills(num)
    local old = self:getTeamKills()
    self:setValue("teamKills", old + (num or 1))
    local team = self:getTeam()
    if team then
        team:addTeamKills(num or 1)
    end
end

---清空个人阵营击杀数（切换阵营时清空）
function Entity:clearTeamKills()
    self:setValue("teamKills", 0)
end

---获取购买装备列表
function Entity:getEquip()
    return Lib.copy(self:getValue("equip"))
end

---设置购买装备列表
function Entity:setEquip(data)
    self:setValue("equip", data)
end

---获取购买腰带列表
function Entity:getBelt()
    return Lib.copy(self:getValue("belt"))
end

---设置购买腰带列表
function Entity:setBelt(data)
    self:setValue("belt", data)
end

---获取已解锁岛屿等级
function Entity:getIslandLv()
    return self:getValue("islandLv")
end

---设置已解锁岛屿等级
function Entity:setIslandLv(lv)
    self:setValue("islandLv", lv)
end

---获取已拥有的阵营皮肤
function Entity:getOwnTeamSkin()
    return self:getValue("ownTeamSkin") or {}
end

---设置已拥有的阵营皮肤
function Entity:setOwnTeamSkin(data)
    self:setValue("ownTeamSkin", data)
end

---获取已装备的阵营皮肤id
function Entity:getTeamSkinId()
    return self:getValue("teamSkinId") or 0
end

---设置已装备的阵营皮肤id
function Entity:setTeamSkinId(id)
    self:setValue("teamSkinId", id)
end