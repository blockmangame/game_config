---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by wangpq.
--- DateTime: 2020/3/23 10:35

local playerCfg = {}
function Player:initPlayer()
    local attrInfo = self:getPlayerAttrInfo()
    playerCfg = self:cfg()
    if not playerCfg.ignorePlayerSkin then
        self:changeSkin(attrInfo.skin)
    end
    self:setData("mainInfo", attrInfo.mainInfo)

    local mainData = self:data("main")
    mainData.sex = attrInfo.sex==2 and 2 or 1
    mainData.team = attrInfo.team
    if mainData.sex==2 then
        mainData.actorName = "girl.actor"
    else
        mainData.actorName = "ninja_boy.actor"
    end

    self:initCurrency()
    self:tickLifeSteal()
end
---
---角色固有设定，定时回血
---
function Player:tickLifeSteal()
    if Game.GetState() == "GAME_GO" and self.curHp>0 then
        self:deltaHp((playerCfg.AutoReboundRate or 0.05)*self:getHealingPlu())
    end
    World.Timer((playerCfg.AutoReboundTime or 1)*20, function ()
        if self.removed then
            return
        end
        self:tickLifeSteal()
    end   )
end
---
---内部方法，释放一次增加锻炼值的技能
---后期可能推广位增加其他属性
local function castSetSkill(self,val)
    local packet = {}
  --  packet.pid = "CastSkill"
  --  packet.fromID = self and self.objID
    packet.name = "myplugin/action_add_exp"
    packet.val = val
    Skill.Cast(packet.name, packet, self)
end
---增加一次锻炼值
function Player:addCurExp()
    print("---------addExp---------------------")
    local newExp = self:getPerExpPlus()+self:getCurExp()
    local maxExp = self:getMaxExp()
    if self:isExpFull() and newExp>maxExp then
        newExp = maxExp
    end
    self:setCurExp(newExp)
   -- castSetSkill(self,newExp)
end
---
---重置锻炼值
function Player:resetExp()
    --castSetSkill(self,0)
    self:setCurExp( 0)
end
function Player:sellExp()
    self:addCurrency("gold", self:getCurExpToCoin(), "sell_exp")
    self:resetExp()
end
---开启锻炼值贩卖加成特权
function Player:openGold2Plus()
    self:setValue("gold2Plus",playerCfg.goldExchangePlus)
end
---开启锻炼值增幅额外加成特权
function Player:openPerExpPlus()
    self:setValue("perExpPlu",playerCfg.perExpPlus)
end
---开启最大血量加成特权
function Player:openHpMaxPlus()
    self:setValue("hpMaxPlus",playerCfg.hpMaxPlus)
end
---开启神圣伤害加成特权
function Player:setOpenRealDmg()
    self:deltaDmgRealPlu(World.cfg.realDmgPlus-1)
end
---开启移速加成特权
function Player:setMovePlus()
    --self:setValue("hpMaxPlus",playerCfg.hpMaxPlus)
end
---开启锻炼值无上限特权
function Player:setInfiniteExp()
    self:setValue("infiniteExp",true)
    self:setCurExp(self:getCurExp())--触发一次exp改变回调，刷新经验条显示效果
end

---
---更换装备
---
function Player:exchangeEquip(fullName)
    
    local item1 =  self:searchItem("fullName",fullName)
    if not item1 then
        self:addItem(fullName,1,nil,"exchange")
        item1 =  self:searchItem("fullName",fullName)
    end
    local tb = self:tray():query_trays(item1:cfg().tray)[1]
    local tray_2 = {}
    if tb then
        tray_2 = tb.tray 
    end
    local slot_1 = item1:slot()
	local tray_1 = self:tray():fetch_tray(item1:tid())
	if not Tray:check_switch(tray_1, slot_1, tray_2, 1) then
		return false
	end
    Tray:switch(tray_1, slot_1, tray_2, 1)
 --   self:switchItem(item1:tid(), item1:slot(),Define.TRAY_TYPE.EQUIP_1,1)

end
---
---操作血量变化
---当deltaVal绝对值大于1是认为是自然数
---当deltaVal绝对值小于1是认为是倍数，将乘以最大血量以计算
---负数代表扣血
---正数代表回血
---
function Player:deltaHp(deltaVal)
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
function Player:resetHp()
    self:setValue("curHp", self:getMaxHp())
end
function Player:setCurExp(val)
    print("---------setCurExp---------------------")
    self:setValue("curExp", val)
    if self:getCurHp()>self:getMaxHp() then--改变锻炼值造成血量上限低于当前血量时直接强制重置血量（无血壳）
       
        self:resetHp()
    end

end
function Player:addLevel()

--锻炼器材
--当前肌肉值、肌肉最大值
--连跳等级
--传送门状态
    self:setCurLevel(self:getCurLevel()+1)
     --   所持金币数
    self:payCurrency("gold", 0,true,false, "level_up")
    
    self:resetExp()
    print("--------------AsyncProcess-----------",Lib.v2s(AsyncProcess,3))
    AsyncProcess.ReportCurLevel(self,function (response)
        print("-------------------------",Lib.v2s(response,3))
    end)
    
end
function Player:enterArena()
    AsyncProcess.takeGroupStart(self, "g2030", "", function(isSuccess, userIds)
        if isSuccess then
            return
        end
        ---请求服务器失败，玩家全部传送回去出生点
        for _, userId in pairs(userIds) do
            local player = PlayerManager:getPlayerByUserId(userId)
            if player then
                --传送走玩家
                HostApi.resetPos(player.rakssid, GameConfig.initPos.x, GameConfig.initPos.y + 0.5, GameConfig.initPos.z)
                ---TODO 添加提示
            end
        end
    end)
end
---设置阵营
function Player:setTeam(id)
    Game.TryJoinTeam(self, id)
end

---获取阵营
function Player:getTeam()
    return Game.GetTeam(self:getTeamId())
end