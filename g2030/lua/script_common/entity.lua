-- 自动同步属性定义
local ValueDef		= T(Entity, "ValueDef")
local AdvanceConfig = T(Config, "AdvanceConfig")
local playerCfg = World.cfg
-- key				= {isCpp,	client,	toSelf,	toOther,	init,	                            saveDB}
ValueDef.jumpCount	= {false,	true,	false,	false,      1,                                   false}--跳跃数
ValueDef.maxJumpCount={false,	false,	true,	false,      1,		                            false}--最大跳跃数
ValueDef.curExp		= {false,	false,	true,	true,       BigInteger.Create(0),		        true}--当前锻炼值
ValueDef.maxExp		= {false,	false,	true,	true,       BigInteger.Create(1),	            true}--最大锻炼值
ValueDef.perExp 	= {false,	false,	true,	true,       BigInteger.Create(1),		        false}--每次攻击锻炼值增加
ValueDef.autoExp	= {false,	false,	true,	true,       0,		                            false}--自动锻炼间隔
ValueDef.perExpPlu	= {false,	false,	true,	true,       1,		                            false}--锻炼值加成加成比例（付费特权。双倍）
ValueDef.infiniteExp= {false,	false,	true,	true,       false,	                            false}--当前锻炼值
ValueDef.moveSpdRat = {false,	false,	true,	true,       1,  	                            false}--移动速度加成
ValueDef.curLevel	= {false,	false,	true,	true,       1,		                            true}--当前阶数
ValueDef.curHp		= {false,	false,	true,	true,       BigInteger.Create(playerCfg.baseHp),false}--当前血量
ValueDef.gold2Plus	= {false,	false,	true,	true,       1,                                   true}--额外金币转换加成系数（付费特权）
ValueDef.hpMaxPlus	= {false,	false,	true,	true,       1,                                   true}--生命上限加成系数（付费特权）
ValueDef.suckBlood	= {false,	false,	true,	true,       0,                                   false}--吸血比例
ValueDef.CDSub	    = {false,	false,	true,	true,       1,                                   false}--技能CD缩短比例
ValueDef.hurtSub	= {false,	false,	true,	true,       1,                                   false}    --受伤减免比例
ValueDef.dmgPlu	    = {false,	false,	true,	true,       1,                                   false}--伤害加成比例
ValueDef.dmgRealPlu	= {false,	false,	true,	true,       1,                                   false}--神圣伤害加成比例（付费特权。双倍）
ValueDef.healingVal	= {false,	false,	true,	true,       0,                                   false}--恢复量
ValueDef.healingPlu	= {false,	false,	true,	true,       1,                                   false}--恢复量加成
ValueDef.healingSpd	= {false,	false,	true,	true,       0,                                   false}--恢复速率（每隔多少s恢复一次）
ValueDef.WeaponId   = {false,	false,	true,	true,       1,                                   true}--当前武器id
ValueDef.SashId     = {false,	false,	true,	true,       10,                                  true}--当前腰带id
ValueDef.teamId		= {false,	true,	true,	true,       0,                                   true}--阵营Id
ValueDef.teamKills	= {false,	false,	false,	false,      0,                                  false}--个人阵营击杀数
ValueDef.equip      = {false,	false,	true,	false,      {},                                 true}--道具商店购买的装备列表
ValueDef.belt       = {false,	false,	true,	false,      {},                                 true}--道具商店购买的腰带列表
ValueDef.studySkill = {false,	false,	true,	false,      {},                                 true}--道具商店购买的装备列表
ValueDef.equipSkill = {false,	false,	true,	false,      {},                                 true}--道具商店购买的腰带列表
ValueDef.prop       = {false,	false,	true,	false,      {},                                 true}--付费商店购买的道具列表
ValueDef.resource   = {false,	false,	true,	false,      {},                                 true}--付费商店购买的资源列表
ValueDef.skin       = {false,	false,	true,	false,      {},                                 true}--付费商店购买的皮肤列表
ValueDef.privilege  = {false,	false,	true,	false,      {},                                 true}--付费商店购买的特权列表
ValueDef.boxData   = {false,	false,	true,	false,      {},                                 true}--箱子领取时间和状态
ValueDef.autoSellTime= {false,	false,	true,	false,   os.time(),                             true}--限时自动锻炼有效时间戳
ValueDef.islandLv   = {false,	true,	true,	false,       1,                                  true}--当前岛屿等级（商店临时解锁用）
ValueDef.ownTeamSkin= {false,   true,    true,  false,      {},                                  true}--已拥有的阵营皮肤
ValueDef.teamSkinId = {false,   true,    true,  false,       0,                                  true}--已装备的阵营皮肤id
ValueDef.unLockedIsland = { false, true, true, false,       {},                                  true }--已解锁的岛屿id
--=======================================================竞技场玩家相关数据=================================================================
ValueDef.arenaScore = {false,   true,    true,  true,       0,                                  false}--竞技场分数
--==============================================================NPC相关数据=================================================================
ValueDef.npcMaxHp = {false,   true,    true,  true,       BigInteger.Create(100000),             false }--npc最大血量
ValueDef.npcDmg = {false,   true,    true,  true,       BigInteger.Create(100),                 false }--npc基础伤害
--=======================================================宠物、式神相关数据=================================================================
ValueDef.petEquippedList= {false,   false,  true,   true,       {},                             true}--当前角色宠物装备表
ValueDef.plusPetEquippedIndex={false,false, true,   true,       0,                              true}--当前角色式神装备表
ValueDef.hadEntityNum   = {false,   false,  true,   false,      0,                              true}--当前角色获取过的宠物实体总数（不会减少）
ValueDef.allPetAttr     = {false,   false,  true,   true,       {},                             true}--宠物、式神相关数据
ValueDef.petPageNu      = {false,   false,  false,  false,      4,                              true}--当前玩家宠物背包页数量
--=======================================================充值相关数据=================================================================
ValueDef.topUpCount     = {false,	false,	true,	true,       0,                              true}--充值数
--====================世界boss相关数据================
ValueDef.bossHits       = {false,   true,    true,  false,      0,                              false }--boss击打数
ValueDef.combo          = {false,   true,    true,  false,      0,                              false }--boss连击数

--[[
宠物、式神相关数据存储索引说明：索引为createPet后返回的index，通过索引插入的AllPetAttr，该表不为序列，期间可能会出现nil
即强化（消耗）后相关索引项将置为nil
--]]
--[[相关数据(AllPetAttr)内容：
{ID = 0,              --宠物or式神的pluginID
 minorID = 0，        --式神副ID
 petType = 0,         --是宠物还是式神
 level = 0,           --当前强化等级
 timeLimit = -1,      --拥有的时限，-1为永久，否则按秒算
 getTime = 0,         --得到的时间（强化时改值会被继承）
 petCoinTransRate = 1,--该宠物Entity当前的金币增益
 petChiTransRate = 1, --该宠物Entity当前的气增益
 plusPetATKRate = 1}, --该式神Entity当前的攻击倍率增益
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
    local petPlus = 0
    local list = self:getPetEquippedList()
    for a,pet in pairs(list) do
        petPlus = petPlus+ self:getPetAttr(pet).exerciseRatio
    end
    ---TODO exp up calc func
    return self:getValue("perExp")*(AdvanceConfig:getExpPlusByLv(self:getCurLevel())+petPlus)*self:getValue("perExpPlu")--TODO 宠物加成
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
    local petPlus = 0
    for _,pet in pairs(self:getPetEquippedList()) do
        petPlus = petPlus+ self:getPetAttr(pet).coinTransRatio
    end
    return self:getCurExp()*playerCfg.baseExp2GoldVal*(1+petPlus)*self:getValue("gold2Plus")--TODO 宠物加成
end
---获取是否无锻炼值上限
function Entity:getIsInfiniteExp()
    return self:getValue("infiniteExp")
end
---设置最大锻炼值变化
function Entity:deltaExpMaxPlus(val)
  --  assert(tonumber(val), "invalid input:" .. val .. "is not a number")
    self:setValue("maxExp",self:getValue("maxExp")+val)
end
---锻炼值是否已满
function Entity:isExpFull()
    if self:getIsInfiniteExp() then
        return false
    end
    local isFull = self:getCurExp()>=self:getMaxExp()
    if isFull and self:getAutoSellTime() >= os.time() then
        self:sellExp()
        return false
    end
    return isFull
end
---获取当前阶数
function Entity:getCurLevel()
    return self:getValue("curLevel")
end
---设置当前阶数
function Entity:setCurLevel(lv)
    self:setValue("curLevel", lv)
end
---获取自动经验间隔，0为无自动
function Entity:getAutoExp()
    return self:getValue("autoExp")
end
---设置自动锻炼间隔
function Entity:setAutoExp(val)
    assert(tonumber(val), "invalid input:" .. val .. "is not a number")
    if val<0 then
        print("auto exp time must > 0")
        return
    end
    self:setValue("autoExp", val)
    
end



---战斗属性相关
---
---
---
---操作血量变化
---当deltaVal绝对值大于1是认为是自然数
---当deltaVal绝对值小于1是认为是倍数，将乘以最大血量以计算
---负数代表扣血
---正数代表回血
---
function Entity:deltaHp(deltaVal)
    if deltaVal>0 and deltaVal<1 or deltaVal<0 and deltaVal>-1 then
        deltaVal =self:getMaxHp()*deltaVal
    end
    if type(deltaVal) == 'number' then
        deltaVal = math.floor(deltaVal)
    end
    local curVal = math.min(math.max(self:getCurHp()+deltaVal,0),self:getMaxHp())
    if curVal ==self:getCurHp() then
        return
    end
    self:setValue("curHp", curVal)
    if curVal <=0  then
        self.curHp = 0
    end
    return curVal
end
---满血
function Entity:resetHp()
    self:setValue("curHp", self:getMaxHp())
end

---当前血量上限
function Entity:getMaxHp()
    ---TODO hp limit calc func
    if self.isPlayer then
        return (playerCfg.baseHp+self:getCurExp()*tonumber(playerCfg.baseExp2Hp))*self:getValue("hpMaxPlus")
    else
        return self:getValue("npcMaxHp")
    end
    
end
---
---当前血量
---
function Entity:getCurHp()
    return self:getValue("curHp")
end
---
---获取基础伤害值
---
function Entity:getCurDamage()
    if self.isPlayer then

        return BigInteger.Create(playerCfg.baseAtk)+self:getCurExp()*playerCfg.baseExp2Atk
    else
        return self:getValue("npcDmg")
    end
    
end

---初始化npc最大血量
function Entity:setNPCMaxHp(val)
    self:setValue("npcMaxHp",val)
    self:setValue("curHp",val)
end
---初始化npc基础伤害
function Entity:setNPCBaseDmg(val)
    self:setValue("npcDmg",val)
end

---
---获取伤害加成系数
---
function Entity:getDmgPlu()
    local petPlus = 0
    local list = self:getPetEquippedList()
    for _,pet in pairs(list) do
        petPlus = petPlus+ self:getPetAttr(pet).plusPetATKRate
    end
    print("-------------petPlus dmg-----------",petPlus)
    print("-------------lv dmg-----------",AdvanceConfig:getAtkPlusByLv(self:getCurLevel()))
    return math.max(self:getValue("dmgPlu")+AdvanceConfig:getAtkPlusByLv(self:getCurLevel()+petPlus),0)
end
---变化伤害加成系数
function Entity:deltaDmgPlu(val)
    assert(tonumber(val), "invalid input:" .. val .. "is not a number")
    self:setValue("dmgPlu",self:getValue("dmgPlu")+val)
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
---获取回复量加成系数
---
function Entity:getHealingPlu()
    return math.max(self:getValue("healingPlu"),0)
end
function Entity:deltaHealingPlu(val)
    assert(tonumber(val), "invalid input:" .. val .. "is not a number")
    self:setValue("healingPlu",self:getValue("healingPlu")+val)
end
---获取单次回复比例
function Entity:getHealingVal()
    return math.max(self:getValue("healingVal"),0)
end
---获取回复间隔时间
function Entity:getHealingSpd()
    return math.max(self:getValue("healingSpd"),0)
end
---设置持续回血参数
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
    if val >=1 then
        Lib.log("HurtSub cannot exceed 1!")
        return
    end
    self:setValue("hurtSub",self:getValue("hurtSub")-val)
end
---
---获取移速加成（衰减）比例
---
function Entity:getMoveSpdRat()
    return  math.max(self:getValue("moveSpdRat")+AdvanceConfig:getSpdPlusByLv(self:getCurLevel()),0)
end
---设置移速加成（衰减）变化
function Entity:deltaMoveSpdRat(val)
    assert(tonumber(val), "invalid input:" .. val .. "is not a number")
    self:setValue("moveSpdRat",self:getValue("moveSpdRat")+val)
    if self.isPlayer then
        self:setEntityProp("moveSpeed", tostring(self:getMoveSpdRat()))
    end
end
---
---获取竞技场分数
---
function Entity:getArenaScore()
    return math.max(self:getValue("arenaScore"),0)
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
    return self:getValue("equip")
end

---设置购买装备列表
function Entity:setEquip(data)
    self:setValue("equip", data)
end

---获取购买腰带列表
function Entity:getBelt()
    return self:getValue("belt")
end

---设置购买腰带列表
function Entity:setBelt(data)
    self:setValue("belt", data)
end

---获取购买付费道具列表
function Entity:getProp()
    return self:getValue("prop")
end

---设置购买付费道具列表
function Entity:setProp(data)
    self:setValue("prop", data)
end

---获取购买付费资源列表
function Entity:getResource()
    return self:getValue("resource")
end

---设置购买付费资源列表
function Entity:setResource(data)
    self:setValue("resource", data)
end

---获取购买付费皮肤列表
function Entity:getSkin()
    return self:getValue("skin")
end

---设置购买付费皮肤列表
function Entity:setSkin(data)
    self:setValue("skin", data)
end

---获取购买付费特权列表
function Entity:getPrivilege()
    return self:getValue("privilege")
end

---设置购买付费特权列表
function Entity:setPrivilege(data)
    self:setValue("privilege", data)
end

---获取箱子领取时间和状态
function Entity:getBoxData()
    return self:getValue("boxData")
end

---设置箱子领取时间和状态
function Entity:setBoxData(data)
    self:setValue("boxData", data)
end

---获取限时自动售卖时间戳
function Entity:getAutoSellTime()
    return self:getValue("autoSellTime")
end

---设置限时自动售卖时间戳
function Entity:setAutoSellTime(time)
    self:setValue("autoSellTime", time)
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

---获取购买技能列表
function Entity:getStudySkill()
    return Lib.copy(self:getValue("studySkill"))
end

---设置购买技能列表
function Entity:setStudySkill(data)
    self:setValue("studySkill", data)
end

---获取装备技能列表
function Entity:getEquipSkill()
    return Lib.copy(self:getValue("equipSkill"))
end

---设置装备技能列表
function Entity:setEquipSkill(data)
    self:setValue("equipSkill", data)
end

--check entity whether be in the state of Dizziness or not
function Entity:checkDizzinessState()
if self:getTypeBuff("fullName", "myplugin/player_dizziness_skill_buff") then
return true
end

return false
end

--check entity whether be in the state of grounded or not
function Entity:checkGroundedState()
    if self:getTypeBuff("fullName", "myplugin/player_grounded_skill_buff") then
        return true
    end

    return false
end

--get equipping pets
function Player:getAllEquippedPet()
    local petList, plusPetList
    for _, v in pairs(self.equipPetList) do
        local type = self:getPetAttr(v.index).petType
        if type == Define.petType.pet then
            table.insert(v)
        elseif type == Define.petType.plusPet then
            table.insert(plusPetList, v)
        end
    end
    return petList, plusPetList
end

function Entity:getPetEquippedList()
    return self:getValue("petEquippedList")
end

function Entity:setPetEquippedList(listTable)
    self:setValue("petEquippedList", listTable)
end

function Entity:getPlusPetEquippedIndex()
    return self:getValue("plusPetEquippedIndex")
end

function Entity:setPlusPetEquippedIndex(index)
    self:setValue("plusPetEquippedIndex", index)
end

function Entity:getHadEntityNum()
    return self:getValue("hadEntityNum")
end

function Entity:setHadEntityNum(allPetsNu)
    self:setValue("hadEntityNum", allPetsNu)
end

function Entity:getAllPetAttr()
    return self:getValue("allPetAttr")
end

function Entity:setAllPetAttr(allAttr)
    self:setValue("allPetAttr", allAttr)
end

function Entity:getPetPageNu()
    return self:getValue("petPageNu")
end

function Entity:setPetPageNu(nowPageNu)
    self:setValue("petPageNu", nowPageNu)
end

---获取boss击打数
function Entity:getBossHits()
    return self:getValue("bossHits") or 0
end

---增加boss击打数
function Entity:addBossHits(num)
    local old = self:getBossHits()
    self:setValue("bossHits", old + (num or 1))
end

---清空boss击打数
function Entity:clearBossHits()
    self:setValue("bossHits", 0)
end

---获取combo数
function Entity:getCombo()
    return self:getValue("combo") or 0
end

---增加combo数
function Entity:addCombo()
    local old = self:getCombo()
    self:setValue("combo", old + 1)
end

---清空combo数
function Entity:clearCombo()
    self:setValue("combo", 0)
end

---获取已解锁的岛屿id
function Entity:getUnLockedIsland()
    return self:getValue("unLockedIsland") or {}
end

---保存已解锁的岛屿id
function Entity:setUnLockedIsland(data)
    self:setValue("unLockedIsland", data)
end

