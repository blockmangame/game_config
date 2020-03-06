local setting = require "common.setting"
local handles = Player.PackageHandlers

local GuideHome = require "script_client.guideHome"

function handles:ShowHomeGuide(packet)
	GuideHome.showHomeUI(packet.pos)
end

function handles:SendInteractionEnd(packet)
    self:setInteractingPlayer()
end

function handles:SendInteractionBegin(packet)
    self:setInteractingPlayer(packet.targetID, packet.skillName)
end

function handles:UpdateEntityDate(packet)
    local obj = World.CurWorld:getObject(packet.objId)
    if obj then
        obj[packet.key] = packet.value
    end
end

function handles:SyncItemUse(packet)
	self:setItemUse(packet.tid, packet.slot, packet.isUse, true)
end

function handles:ShowSingleTeamUI(packet)
    Lib.emitEvent(Event.EVENT_SHOW_SINGLE_TEAM, packet.show, packet.info)
end

function handles:ShowTeamUI(packet)
    Lib.emitEvent(Event.EVENT_SHOW_TEAM, packet.show, packet.info)
end

function handles:ShowProgressFollowObj(packet)
    Lib.emitEvent(Event.EVENT_SHOW_PROGRESS_FOLLOW_OBJ, packet)
end

function handles:ShowDetails(packet)
    Lib.emitEvent(Event.EVENT_SHOW_DETAILS, packet)
end

function handles:SetLoadSectionMaxInterval(packet)
    if packet.value and packet.value > 0 then
        Blockman.instance.gameSettings:setAsynLoadSectionMaxInterval(packet.value)
    end
end

function handles:ShopItemDetail(packet)
    UILib.openShopBuy(packet.hintImage, function(selectedLeft)
        if not selectedLeft then
            return
        end
        Me:doCallBack("ItemDetail", "sure", packet.regId)
    end,packet.coinId, packet.price, packet.desc, packet.tip) 
end

function handles:WorksWallsOperation(packet)
    Lib.emitEvent(Event.EVENT_WORKS_WALLS_OPERATION, packet.isOpen)
end

function handles:SetWorksArchiveNum(packet)
    Me:data("main").worksArchiveNum = packet.num
end

function handles:ShowDialogTip(packet)
    local args = packet.args
    Lib.emitEvent(Event.EVENT_SHOW_DIALOG_TIP, packet.tipType, packet.regId, table.unpack(args))
end