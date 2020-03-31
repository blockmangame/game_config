---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by wangpq.
--- DateTime: 2020/3/23 10:35
---
function Player:initPlayer()
    local attrInfo = self:getPlayerAttrInfo()
    if not self:cfg().ignorePlayerSkin then
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
end

---
---内部方法，释放一次增加锻炼值的技能
---后期可能推广位增加其他属性
local function castSetSkill(self,val)
    local packet = {}
    packet.pid = "CastSkill"
    packet.fromID = self and self.objID
    packet.name = "myplugin/action_add_exp"
    packet.val = val
    Skill.Cast(packet.name, packet, self)
end
---增加一次锻炼值
function Player:addExp()
    print("in addExp")
    local newExp = self:getPerExpPlus()+self:getCurExp()
    local maxExp = self:getMaxExp()
    if newExp>maxExp then
        newExp = maxExp
    end
    -- self:setCurExp(newExp)
    castSetSkill(self,newExp)
end
---
---重置锻炼值
function Player:resetExp()
    castSetSkill(self,0)
end

function Player:setCurExp(val)
    self:setValue("curExp", val)

end