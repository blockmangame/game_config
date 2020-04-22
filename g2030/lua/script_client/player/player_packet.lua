---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by KH5C.
--- DateTime: 2020/4/1 10:09
---

local handles = T(Player, "PackageHandlers")

function handles:itemShopRegion(packet)
    local itemShop = UI:getWnd("itemShop")
    if itemShop then
        itemShop:onShow(packet.isShow)
    end
end

function handles:payShopRegion(packet)
    local payShop = UI:getWnd("payShop")
    if payShop then
        payShop:onShow(packet.isShow)
    end
end

function handles:exchangeWeapon(packet)
    self:setHandItem(packet.weapon)
end

function handles:PetList(packet)
    self.equipPetList = {}
    for index, entityInfo in pairs(packet.list) do
        self.equipPetList[index] = entityInfo;
    end
    if UI:getWnd("petPackage"):visible() then
        UI:getWnd("petPackage"):refreshPetLeftDetailInfo()      --防止延迟造成的数据显示错误
    end
end

function handles:AttrValuePro(packet)
    local entity = World.CurWorld:getEntity(packet.objID)
    if packet.isBigInteger then
        packet.value = BigInteger.Recover(packet.value)
    end
    entity:doSetValue(packet.key, packet.value)
    UI:getWnd("petEvolution"):evoluteSuccess(packet.oldIndex, packet.newIndex)
end

function handles:ResetEntityRechargeSkill(packet)
    Lib.emitEvent(Event.EVENT_ALL_RECHARGE_SKILL_RESET)
end

function handles:PortalUIData(packet)
    local pos = packet.pos
    UI:openWnd("ninjaCommonDialog"):initView(
            {
                content = Lang:toText("gui_go_island_notice"),
                contentCenter = true,
                txtTitle = Lang:toText("gui_tip"),
                hideClose = false,
                leftTxt = Lang:toText("gui_cancel"),
                rightTxt = Lang:toText("gui_sure"),
                leftCb = function()
                end,
                rightCb = function()
                    Me:setPosition(pos)
                end
            }
    )
end

function handles:TeleportBegin(packet)
    Lib.emitEvent(Event.EVENT_TELEPORT_SHADER_ENABLE, packet.type)
end

function handles:TeleportEnd(packet)
    Lib.emitEvent(Event.EVENT_TELEPORT_SHADER_DISABLE, packet.type)
end

function handles:ShowGauntlet(packet)
    if Me:getTeamId() == Define.Team.Neutrality then
        return
    end
    if packet.isShow then
        UI:openWnd("gauntlet", packet.key)
    else
        UI:closeWnd("gauntlet")
    end
end
function handles:CommonNotice(packet)
    if packet and packet.content then
        Lib.emitEvent(Event.EVENT_COMMON_NOTICE,packet.content)
    end
end