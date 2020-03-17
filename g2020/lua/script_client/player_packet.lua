local setting = require "common.setting"
local handles = Player.PackageHandlers

local GuideHome = require "script_client.guideHome"

function handles:ShowHomeGuide(packet)
	GuideHome.resetDoor(packet.pos)
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
    local obj = World.CurWorld:getObject(packet.objID)
    if obj then
        Lib.emitEvent(Event.EVENT_SHOW_PROGRESS_FOLLOW_OBJ, packet)
    end
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
            Me:doCallBack("ItemDetail", "no", packet.regId)
            return
        end
        Me:doCallBack("ItemDetail", "sure", packet.regId)
    end, packet.coinId, packet.price, packet.desc, packet.tip)
end

function handles:UpdateUIData(packet)
    UI:setRemoterData(packet.ui, packet.data)
    Lib.emitEvent(Event.EVENT_UPDATE_UI_DATA, packet.ui, packet.data or {})
end

function handles:WorksWallsOperation(packet)
    Lib.emitEvent(Event.EVENT_WORKS_WALLS_OPERATION, packet.isOpen)
end

function handles:SetWorksArchiveNum(packet)
    Me:data("main").worksArchiveNum = packet.num
end

function handles:ShowDialogTip(packet)
    local args = packet.args
    Lib.emitEvent(Event.EVENT_SHOW_DIALOG_TIP, packet.tipType, packet.dialogContinuedTime, 
        packet.regId, packet.modName, table.unpack(args))
end

function handles:ShowInviteTipByScript(packet)
    Lib.emitEvent(Event.EVENT_SHOW_INVITE_TIP_BY_SCRIPT, packet)
end

function handles:SyncStatesData(packet)
    Lib.emitEvent(Event.EVENT_SYNC_STATES_DATA, packet)
end

--TRADE
function handles:RequestTrade(packet) --接到请求交易
    local showArgs = {
        titleText = "TRADE",
	    msgText = {"gui_request_trade", packet.playerName}
    }
    local callback = function(sure)
        if not sure then
            return
        end
        UILib.openChoiceDialog(showArgs, function(isLeft)
            if not isLeft then
                Me:sendPacket({pid = "AcceptTrade", sessionId = packet.sessionId})
            else 
                Me:sendPacket({pid = "RefuseTrade", sessionId = packet.sessionId})
            end
        end)
    end
    UI:openWnd("tradeHint", {text = "gui.trade.risk.hint"}, callback)
end

local showTop = 1
function handles:TradeRefused(packet)--对方拒绝
	Client.ShowTip(showTop, "gui_trade_refuse", 50)
end

function handles:TradeSucceed(packet) -- 交易成功提示
    Client.ShowTip(showTop, "gui_request_accomplish", 50)
    self:clearTrade()
    Lib.emitEvent(Event.EVENT_TRADE_SUCCEED, packet.tradeID)
end

function handles:StartTrade(packet)--交易开始：
	self:StartTrade(packet)
end

function handles:TradeClose(packet) --一些非正常关闭
    local showType = {
		showCenter = 2,
		keepTime = 40,
		textKey = "gui.trade." .. packet.reason
	}
    Client.ShowTip(showType.showCenter, showType.textKey, showType.keepTime)
    self:clearTrade()
end

--function handles:TradePlayerConfirm(packet) --对方确认, 不需要重写

--function handles:TradeItemChange(packet) --对方选择改变， 不需要重写

function handles:TradePlayerCancel(packet) --对方中途取消
    Client.ShowTip(1, "gui.trade.close", 40)
    self:clearTrade()
    UI:closeWnd("tradeUI")
end

function handles:ShowRewardDialog(packet)
    Lib.emitEvent(Event.EVENT_SHOW_REWARD_DIALOG, packet)
end

function handles:ShowWarmPrompt(packet)
    local callback = function(sure)
        local type = sure and "sure" or "no"
        Me:doCallBack("ShowWarmPrompt", type, packet.regId)
    end
    local ui = UI:openWnd("tradeHint", {text = packet.text, btnText = packet.btnText, disableClose = packet.disableClose}, callback)
    ui:root():SetAlwaysOnTop(true)
	ui:root():SetLevel(0)
end

function handles:ShowGuidePop(packet)
    local callback = function(sure)
        Me:doCallBack("ShowGuidePop", "sure", packet.regId)
    end
    local ui = UI:openWnd("guidePop", {texts = packet.texts}, callback)
end

function handles:OpenMainExtension(packet)
    local ui = UI:getWnd("mainExtension")
    if packet.open then
        ui:openLayout()
    else
        ui:hideLayout()
    end
end

function handles:SetGPSButton(packet)
    local ui = UI:getWnd("workTask")
    if ui then
        ui.forceClose = not packet.show     
        ui.closeGpsBtn:SetVisible(packet.show)
    end
end

function handles:ShowWhiteScreen(packet)
    UI:openWnd("whiteScreen")
    Lib.emitEvent(Event.EVENT_SHOW_WHITE_SCREEN, packet)
end