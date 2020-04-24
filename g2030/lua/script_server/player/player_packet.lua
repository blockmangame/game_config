---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by KH5C.
--- DateTime: 2020/4/1 10:10
---

-- 调用具体看  handle_packet@player.player_packet
-- 此处packet使用只需要在sendPacket的pid字段传入想要调用的函数名即可，方法内的self是发包的player。

local handles = T(Player, "PackageHandlers")

--[[        目前弃用、不打算给予客户端任何创建一个宠物的机会。（防止作弊）
function handles:getNewPet(packet)
    self:getNewPet(packet.ID, packet.coinTransRatio, packet.chiTransRatio);
end

function handles:getNewPlusPet(packet)
    self:getNewPlusPet(packet.ID, packet.plusPetATKRate);
end
--]]
function handles:callPet(packet)
    self:callPet(packet.index, packet.ridePoint);
end

function handles:recallPet(packet)
    self:recallPet(packet.index);
end

function handles:petEvolution(packet)
    self:petEvolution(packet)
end

function handles:plusPetEvolution(packet)
    self:plusPetEvolution(packet)
end

function handles:SyncItemShopOperation(packet)
    Store.ItemShop:operationByType(self, packet.tabId, packet.itemId)
end
function handles:SellExp(packet)
    self:sellExp(packet.resetPos)
end
function handles:ExchangeEquip(packet)
    self:exchangeEquip(packet.fullName)
end

function handles:teamShopBuyItem(packet)
    local teamShop = require "script_server.shop.teamShop"
    local itemId = packet.itemId
    local status = packet.status
    teamShop:onButtonClick(self, itemId, status)
end

---请求排行榜的数据库离线数据
function handles:getKill(packet)
    local DBHandler = require "dbhandler"
    if not packet.userId then
        return
    end
    for i, userId in pairs(packet.userId) do
        DBHandler:getDataByUserId(userId, 1, function(userId, txt)
            local seri = require "seri"
            local misc = require "misc"
            local data = nil
            if txt and txt ~= "" then
                data = seri.deseristring_string(misc.base64_decode(txt))
            end
            local killNum = data.rankScoreRecord["kill.hist"]
            local muscle = data.rankScoreRecord["muscle.hist"]
            local integral = data.rankScoreRecord["integral.hist"]

            self:sendPacket({
                pid = "getKill",
                userId = userId,
                killNum = killNum,
                muscle = muscle,
                integral = integral
            })
        end)
    end
end

function handles:skillShopBuyItem(packet)
    local skillShop = require "script_server.skill.skillShop"
    local itemId = packet.itemId
    local status = packet.status
    if status == 1 then
        skillShop:onButtonClick(self, itemId, status)
    else
        local placeId = packet.placeId
        print("============packet======".. tostring(placeId))
        skillShop:onButtonClick(self, itemId, status, placeId)
    end
end

function handles:syncSkillEquip(packet)
    local skillShop = require "script_server.skill.skillShop"
    skillShop:syncSkillMap(self)
end


function handles:SyncItemShopBuyAll(packet)
    Store.ItemShop:BuyAll(self, packet.tabId)
end

function handles:TeleportBeginFinsh(packet)
    local entity = World.CurWorld:getObject(packet.objId)
    if not entity then
        return
    end
    Trigger.CheckTriggers(entity:cfg(), "TELEPORT_BEGIN_FINSH", {obj1=entity})
end

function handles:TeleportEndFinsh(packet)
    local entity = World.CurWorld:getObject(packet.objId)
    if not entity then
        return
    end
    Trigger.CheckTriggers(entity:cfg(), "TELEPORT_END_FINSH", {obj1=entity})
end

function handles:SyncItemShopInit(packet)
    Store.ItemShop:initAllItem(self)
end

function handles:SyncPayShopInit(packet)
    Store.PayShop:initAllItem(self)
end

function handles:SyncPayShopOperation(packet)
    Store.PayShop:operationByType(self, packet.tabId, packet.itemId)
end

function handles:ConfirmGauntlet(packet)
    local entity = World.CurWorld:getObject(packet.objId)
    if not entity then
        return
    end
    if not Game.EntityJoinProcess(packet.key, entity) then
        if entity.isPlayer then
            self:showCommonNotice("加入阵营战失败")
        end
    end
end
function handles:MatchArena(packet)
    local entity = World.CurWorld:getObject(packet.objId)
    if not entity then
        return
    end
    if not Game.EntityJoinProcess(packet.key, entity) then
        if entity.isPlayer then
            self:showCommonNotice("进入竞技场失败")
        end
    end
end
function handles:LeaveArena(packet)
    local entity = World.CurWorld:getObject(packet.objId)
    if not entity then
        return
    end
    Game.EntityLeaveProcess(packet.key, entity)
end
