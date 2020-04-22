local GMItem = GM:createGMItem()

GMItem["g2030/增加跳跃次数"] = function(self)
    self:setValue("maxJumpCount", self:getValue("maxJumpCount") + 1);
    self:setValue("jumpCount", self:getValue("maxJumpCount") + 1);
end
GMItem["g2030/减少跳跃次数"] = function(self)
    self:setValue("maxJumpCount", self:getValue("maxJumpCount") - 1);
    self:setValue("jumpCount", self:getValue("maxJumpCount") - 1);
end

GMItem["g2030/放置区域方块"] = function(self)
    local pos = Lib.v3(self:getPosition().x, self:getPosition().y, self:getPosition().z):blockPos()
    self.map:setBlockConfigId(pos, 2000)
end

GMItem["g2030/清空当前修炼值"] = function(self)
    self:resetExp()
end
GMItem["g2030/addBuff"] = function(self)
    self:addBuff("myplugin/example", -1)
end
GMItem["g2030/花钱！"] = function(self)
    self:payCurrency("gold",  BigInteger.Create(6,9),false,false, "test")
    self:payCurrency("chi",  3,false,false, "test")
end
GMItem["g2030/掙錢！"] = function(self)
    self:addCurrency("gold", BigInteger.Create(23,10), "test")
    self:addCurrency("chi",  3, "test")
end
GMItem["g2030/搞个boss玩玩"] = function(self)
    local entity = EntityServer.Create({cfgName = "myplugin/enemy_base", pos = World.cfg.initPos, map = "map001"})
end

GMItem["g2030/自动锻炼buff"] = function(self)
    self:addBuff("myplugin/autoExp_s",200)
end
GMItem["g2030/无上限特权"] = function(self)
    self:setInfiniteExp()
end
GMItem["g2030/发送测试弹窗"] = function(self)
    self:showCommonNotice("GM发送的测试提示信息，啦啦啦~")
end

GMItem["g2030/神圣攻击加成特权"] = function(self)
    self:setOpenRealDmg()
end
GMItem["g2030/添加ExpMaxbuff"] = function(self)
    self:addBuff("myplugin/sash_buff_simple",200)
end
GMItem["g2030/添加回血buff"] = function(self)
    self:addBuff("myplugin/healing_s",40)
end
GMItem["g2030/自动售卖buff_1"] = function(self)
    self:addBuff("myplugin/auto_sell",100)
end
GMItem["g2030/自动售卖buff_2"] = function(self)
    self:addBuff("myplugin/auto_sell",200)
end
GMItem["g2030/自动普攻buff_1"] = function(self)
    self:addBuff("myplugin/auto_normalatk",100)
end
GMItem["g2030/自动普攻buff_2"] = function(self)
    self:addBuff("myplugin/auto_normalatk",200)
end

GMItem["g2030/添加回血加成buff"] = function(self)
    self:addBuff("myplugin/healing_plus",40)
end
GMItem["g2030/添加减伤buff"] = function(self)
    self:addBuff("myplugin/hurtSub_s")
end
GMItem["g2030/濒死"] = function(self)
    self:setValue("curHp", 1)
end
GMItem["g2030/升阶"] = function(self)
    self:addLevel()
end

-----------------------------------Pet Model Test----------------------------------
local Entity
GMItem["g2030Pet/发放宠物"] = function(self)
    self:getNewPet(2);
    self:getNewPet(3);
    self:getNewPet(4);
    self:getNewPet(5);
    self:getNewPet(6);
    self:getNewPet(1);
    self:getNewPet(8);
end
GMItem["g2030Pet/发放式神"] = function(self)
    self:getNewPlusPet(1, 0)
    self:getNewPlusPet(2, 1)
    self:getNewPlusPet(4, 0)
end
GMItem["g2030Pet/clear"] = function(self)
    self:setValue("petEquippedList", {});
    self:setValue("plusPetEquippedIndex", 0);
    self:setValue("hadEntityNum", 0);
    self:setValue("allPetAttr", {});
end
GMItem["g2030Pet/移除"] = function(self)
    self:recallPet(1);
end
GMItem["g2030Pet/查看当前角色宠物数据"] = function(self)
    print(self);
    print("开始打印宠物数据")
    print("当前所获取过的宠物数量", self:getValue("hadEntityNum"))
    print("当前背包内所有宠物式神信息：")
    for k,v in pairs(self:getAllPetAttr()) do
        print ("\t", k)
        print(Lib.v2s(v))
    end
    print("当前装备的宠物信息：", Lib.v2s(self:getValue("petEquippedList")))
    print("当前装备的式神信息：", self:getValue(("plusPetEquippedIndex")))
    print("===End===")
end
-----------------------------------Pet Model Test End-------------------------------

---阵营
GMItem["g2030/加入Team_1"] = function(self)
    self:setTeam(1)
end

GMItem["g2030/加入Team_2"] = function(self)
    self:setTeam(2)
end

GMItem["g2030/加入Team_3"] = function(self)
    self:setTeam(3)
end

GMItem["g2030/升级Team_2"] = function(self)
    local team = Game.GetTeam(2)
    team:addTeamKills(10)
    print("阵营等级：" .. team:getLevel())
end

GMItem["g2030/升级Team_3"] = function(self)
    local team = Game.GetTeam(3)
    team:addTeamKills(10)
    print("阵营等级：" .. team:getLevel())
end

GMItem["g2030/玩家伤害减免"] = function(self)
    print("伤害减免：" .. self:getHurtSub())
end

GMItem["g2030/玩家治疗加成"] = function(self)
    print("治疗加成：" .. self:getHealingPlu())
end

GMItem["g2030/升级岛屿1"] = function(self)
    self:setValue("islandLv", self:getValue("islandLv") + 1);
    print("岛屿升级到：" .. self:getValue("islandLv"))
    Store.ItemShop:upgradeIslandToUnlock(self)
end

return GMItem