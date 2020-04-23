local EquipConfig = T(Config, "EquipConfig")
local PayEquipConfig = T(Config, "PayEquipConfig")
local BeltConfig = T(Config, "BeltConfig")
local AdvanceConfig = T(Config, "AdvanceConfig")
local TabType = Define.TabType
local BuyStatus = Define.BuyStatus

local function getMoneyIconByMoneyType(moneyType)
    local coinName = Coin:coinNameByCoinId(moneyType)
    assert(coinName, "Coin:coinNameByCoinId(moneyType) ：" .. tostring(moneyType).. " is not a exit")
    return Coin:iconByCoinName(coinName)
end
--local M = {}

function M:init()
    WinBase.init(self, "NinjaLegendsItemShop.json",false)
    self.isInitData = false
    self:onLoad()
end

function M:onLoad()
    self.tabList = {}--tab列表
    self.selectTab = TabType.Null--选中的tab类型
    self.selectItemId = -1 --选中的商品的Id
    self.itemsGridView = {}--商品列表
    self.islandLockId = -1

    self.siDetailValue = {}
    self.siDetailValueIcon = {}
    self.stDetailValueText = {}
    self.stDetailValueNum = {}

    self:initUI()
    self:initTabList()
    self:initEvent()
end

function M:initUI()
    self.stTitleText = self:child("NinjaLegendsItemShop-Name")
    self.stTitleText:SetText(Lang:toText("NinjaLegendsItemShop-Name"))
    self.btnClose = self:child("NinjaLegendsItemShop-Close")
    self.ltTabList = self:child("NinjaLegendsItemShop-TabList")
    self.llContentItemsGridView = self:child("NinjaLegendsItemShop-Content")
    self.gvItemsGridView = GUIWindowManager.instance:CreateGUIWindow1("GridView", "NinjaLegendsItemShop-gvItemsGridView")
    self.llContentItemsGridView:AddChildWindow(self.gvItemsGridView)
    self.gvItemsGridView:SetArea({ 0, 0 }, { 0, 0 }, { 1, 0 }, { 1, 0 })
    self.gvItemsGridView:InitConfig(12, 10, 4)

    self.siDetailBg = self:child("NinjaLegendsItemShop-Detail-Bg")
    self.stDetailTitle = self:child("NinjaLegendsItemShop-Detail-TitleText")
    self.siDetailItemBg = self:child("NinjaLegendsItemShop-Detail-ItemBg")
    self.siDetailItemIcon = self:child("NinjaLegendsItemShop-Detail-Item-Icon")
    self.siDetailItemLock = self:child("NinjaLegendsItemShop-Detail-Item-Lock")

    for i = 1, 3 do
        local strItemProperty = string.format("NinjaLegendsItemShop-Detail-Value%d", i)
        self.siDetailValue[i] = self:child(strItemProperty)
        local strPropertyIcon = string.format("NinjaLegendsItemShop-Detail-Value-Icon%d", i)
        self.siDetailValueIcon[i] = self:child(strPropertyIcon)
        local strPropertyText = string.format("NinjaLegendsItemShop-Detail-Value-Text%d", i)
        self.stDetailValueText[i] = self:child(strPropertyText)
        local strPropertyNum = string.format("NinjaLegendsItemShop-Detail-Value-Num%d", i)
        self.stDetailValueNum[i] = self:child(strPropertyNum)
    end
    self.stDetailDescribe = self:child("NinjaLegendsItemShop-Detail-Describe")
    self.siDetailGold = self:child("NinjaLegendsItemShop-Detail-Button-Gold")
    self.btnDetail = self:child("NinjaLegendsItemShop-Detail-Button")
    self.btnDetail:SetText(Lang:toText(""))
    self.stDetailText = self:child("NinjaLegendsItemShop-Detail-Text")
    self.btnBuyAll = self:child("NinjaLegendsItemShop-BuyAll")
    self.stBuyAll = self:child("NinjaLegendsItemShop-BuyAll-Text")
    self.stBuyAll:SetText(Lang:toText("gui_buy_all"))
end

function M:initEvent()
    self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
        self:onHide()
    end)
    self:subscribe(self.btnDetail, UIEvent.EventButtonClick, function()
        self:onDetailButton()
    end)
    self:subscribe(self.btnBuyAll, UIEvent.EventButtonClick, function()
        self:onBuyAll()
    end)
    Lib.subscribeEvent(Event.EVENT_ITEM_SHOP_UPDATE, function()
        self:updateItems(false)
    end)
end

function M:initTabList()
    local temp ={}
    for _, v in pairs(TabType) do
        table.insert(temp,v)
    end
    table.sort(temp, function(a, b)
        if a == nil or b == nil or a == b then
            return false
        end
        return a < b
    end)
    local tab = TabType.Equip
    for i, tabType in pairs(temp) do
        print("---------initTabList-----------")
        local shopTab = UIMgr:new_widget("itemShopTab")
        local area = {x = { 0, 0 }, y = { 0, i*106 }, w = { 0, 60 }, h = { 0, 106 }}
        shopTab:invoke("initTabByType", tabType, area)
        self.tabList[i] = shopTab
        self:subscribe(shopTab, UIEvent.EventWindowClick, function()
            self:onClickTab(tabType)
        end)
        self.ltTabList:AddItem(shopTab, true)
        if i == 1 then
            tab = tabType
        end
        if i == 3 then
            break
        end
    end
    self:onClickTab(tab)
end

--点击Tab
function M:onClickTab(type)
    print("---------onClickTab-----------")
    print("Type : "..type)
    for _, shopTab in pairs(self.tabList) do
        shopTab:invoke("onCheckClick", type)
    end
    if self.selectTab ~= type then
        self.selectTab = type
        self:updateItems(true)
    end
end

function M:addItemsGridView(isResetPos)
    print("<addItemsGridView:> isResetPos "..tostring(isResetPos))
    self.gvItemsGridView:RemoveAllItems()
    self.itemsGridView = {}
    if self.selectTab == TabType.Equip then
        self:addViewByConfig(EquipConfig, isResetPos)
    elseif self.selectTab == TabType.Belt then
        self:addViewByConfig(BeltConfig, isResetPos)
    elseif self.selectTab == TabType.Advance then
        self:addViewByConfig(AdvanceConfig, isResetPos)
    end
end

function M:addViewByConfig(Config, isResetPos)
    local allItem = {}
    if self.selectTab == TabType.Advance then
        allItem = Config:getSettings()
    else
        local items = Lib.copy(Config:getAllItemByPay(false))
        local items1 = Lib.copy(Config:getAllItemByPay(true))
        local row = #items
        local row1 = #items1
        if row1 > row then
            row = row1
        end
        local j = 0
        local k = 0
        for i = 1, row do
            if i % 4 == 0 then
                j = j + 1
                if items1[j] then
                    table.insert(allItem, i, items1[j])
                else
                    local Value1 = {
                        hide = true
                    }
                    table.insert(allItem, i, Value1)
                end
            else
                k = k + 1
                if items[k] then
                    table.insert(allItem, i, items[k])
                else
                    local Value1 = {
                        hide = true
                    }
                    table.insert(allItem, i, Value1)
                end
            end
        end
    end
    local clickItem
    for i, Value in ipairs(allItem) do
        if Value.hide then
            local shopItem = UIMgr:new_widget("itemShopItem")
            shopItem:invoke("hideGUIWindow")
            --shopItem:root():SetAlpha(0)
            self.gvItemsGridView:AddItem(shopItem)
            self.itemsGridView[i] = shopItem
        else
            local shopItem = UIMgr:new_widget("itemShopItem")
            local contentWidth = self.gvItemsGridView:GetWidth()[2]
            local contentHeight = self.gvItemsGridView:GetHeight()[2]
            --local area = self.gvContentItemsGridView:GetArea()
            --local Area = {r_x = area.min.x[1], r_y = area.min.y[1], r_width = area.max.x[1] - area.min.x[1], r_height = area.max.y[1] - area.min.y[1]}
            local itemWidth = (contentWidth - 0.1) / 4
            local itemHeight = (contentHeight - 0.1) / 3
            local area = {x = { 0, 0 }, y = { 0, 0 }, w = { itemWidth, 0 }, h = { itemWidth, 0 }}
            shopItem:invoke("initItem",self.selectTab, Value, area, self.islandLockId)
            --self.gvContentItemsGridView:AddItem1(shopItem, 0, index)
            if self.islandLockId == Value.id or Value.status ~= BuyStatus.Lock then
                self:subscribe(shopItem, UIEvent.EventWindowClick, function()
                    self:onClickItem(Value.id, Value.status)
                end)
            end
            self.gvItemsGridView:AddItem(shopItem)
            self.itemsGridView[i] = shopItem
            if i == 1 then
                clickItem = Value
            end
        end
    end
    if isResetPos and #self.itemsGridView >= 1 then
        self.gvItemsGridView:ResetPos()
        if clickItem then
            self.selectItemId = clickItem
            self:onClickItem(clickItem.id)
        else
            local curItem = Config:getItemById(self.selectItemId)
            if curItem then
                self:onClickItem(curItem.id)
            end
        end
    end
end

function M:onUpdateIslandLockId()
    local itemConfig = {}
    if self.selectTab == TabType.Equip then
        itemConfig = EquipConfig
    elseif self.selectTab == TabType.Belt then
        itemConfig = BeltConfig
    elseif self.selectTab == TabType.Advance then
        itemConfig = AdvanceConfig
    end
    print(" --- Me:getIslandLv() --- : "..tostring(Me:getIslandLv()))
    local item = itemConfig:getAllItemByPay(false)
    for i=#item, 1, -1 do
        if item[i].status ~= BuyStatus.Lock and item[i].status ~= BuyStatus.Unlock then
            local nextItem = itemConfig:getNextItemByPay(item[i].id, item[i].isPay)
            if nextItem and nextItem.status == BuyStatus.Lock then
                if nextItem.islandLv > Me:getIslandLv() then
                    print(" --- M:onFindIslandLockId(itemConfig) --- : "..tostring(nextItem.id))
                    self.islandLockId = nextItem.id
                end
            end
        end
    end
end

function M:onClickItem(itemId)
    if self.selectTab == TabType.Equip then
        self:onClickEquipItem(itemId)
    elseif self.selectTab == TabType.Belt then
        self:onClickBeltItem(itemId)
    elseif self.selectTab == TabType.Advance then
        self:onClickAdvancelItem(itemId)
    end
end

function M:changeAllItemClickStatus(itemId)
    for _, shopItem in pairs(self.itemsGridView) do
        shopItem:invoke("onCheckClick",itemId)
    end
end

function M:onClickEquipItem(itemId)
    local item = EquipConfig:getItemById(itemId)
    if not item then
        print("M:onClickEquipItem(itemId) : is not exit :"..tostring(itemId))
        return
    end
    print(string.format("onClickEquipItem(itemId) item : %s  status : %s",item.id,item.status))
    self.selectItemId = itemId
    print("<onClickEquipItem:> itemId "..tostring(itemId))
    self:changeAllItemClickStatus(itemId)
    self:choseUseDetailUi(item.isPay)
    if self.islandLockId == itemId then
        print("<onClickEquipItem:> islandLock "..tostring(itemId))
        self:lockItemDetail(true, item.islandIcon)
        return
    end
    if item.status == BuyStatus.Lock then
    else
        self:showItemDetail()
    end

    local fullName = string.format("myplugin/%s",  item.itemName)
    local item1 = Item.CreateItem(fullName)
    assert(item1:cfg(), "onClickEquipItem(itemId) : item:cfg() is not exit :"..tostring(itemId))
    local Cfg = Entity.BuffCfg(item1:cfg().equip_buff)
    assert(Cfg.perExp, "onClickEquipItem(itemId) : Cfg.perExp is not exit :"..tostring(itemId))

    local strItemPropertyNum1 = item.value1
    local payEquip = PayEquipConfig:getItemById(itemId)
    local strDetailDescribe = Lang:toText(item.desc)
    if item.isPay and payEquip then
        if item.status == BuyStatus.Buy or item.status == BuyStatus.Used then
            strDetailDescribe = Lang:toText(payEquip.efficiencyFixHugeDes) ----无限肌肉锻炼肌肉量固定值描述
            local specialNum = string.format("%s", tostring(BigInteger.Create(payEquip.efficiencyFixHuge)))----无限肌肉锻炼肌肉量固定值
            strItemPropertyNum1 =  tostring(BigInteger.Create(payEquip.efficiencyFixHuge))----无限肌肉锻炼肌肉量固定值
            strDetailDescribe = string.format(strDetailDescribe,specialNum)
        elseif tonumber(Me:getCurLevel()) <= payEquip.unlockAdvancedLevel  then----解锁需要的进阶等级
            strDetailDescribe = Lang:toText(item.desc)
            local specialStr = "+"..payEquip.efficiencyPercentage.."%" ------锻炼肌肉量百分比
            strItemPropertyNum1 = payEquip.efficiencyPercentage.."%"
            strDetailDescribe = string.format(strDetailDescribe,specialStr)
        elseif tonumber(Me:getCurLevel()) > payEquip.unlockAdvancedLevel then
            strDetailDescribe = Lang:toText(payEquip.efficiencyFixDes) ------锻炼肌肉量固定值描述
            if Me:getCurLevel() >= payEquip.invailedAdvancedLevel then ------失效的进阶等级
                local specialNum = string.format("%s", tostring(BigInteger.Create(payEquip.efficiencyFix)))----锻炼肌肉量固定值
                strItemPropertyNum1 = tostring(BigInteger.Create(payEquip.efficiencyFix))
                strDetailDescribe = string.format(strDetailDescribe,specialNum)
            else
                local specialStr = "+"..payEquip.efficiencyPercentage.."%"------锻炼肌肉量百分比
                strItemPropertyNum1 = payEquip.efficiencyPercentage.."%"
                strDetailDescribe = string.format(strDetailDescribe,specialStr)
            end
        end
    else
        strItemPropertyNum1 = Lang:toText(tostring(BigInteger.Create(Cfg.perExp.val, Cfg.perExp.bit)))
        strDetailDescribe = string.format(strDetailDescribe,strItemPropertyNum1)
    end
    self.stDetailTitle:SetText(Lang:toText(tostring(item.name)))
    self.siDetailItemIcon:SetImage(item.icon)
    self.stDetailValueText[1]:SetText(Lang:toText(tostring("gui_equip_text1")))

    self.stDetailValueNum[1]:SetText(tostring(BigInteger.Create(Cfg.perExp.val, Cfg.perExp.bit)))
    --self.stDetailValueNum[1]:SetText(tostring(strItemPropertyNum1))
    self.siDetailValue[2]:SetVisible(false)
    self.siDetailValue[3]:SetVisible(false)
    self.stDetailDescribe:SetArea({ 0, 0 }, { 0, 224 }, { 0, 258}, { 0, 152})
    self.stDetailDescribe:SetText(Lang:toText(strDetailDescribe))
    if item.status == BuyStatus.Unlock then
        self.stDetailText:SetArea({ 0, 70 }, { 0, 0 }, { 0, 110}, { 0, 50})
        self.stDetailText:SetTextColor({1, 1, 1, 1})
        local strMoneyIcon = getMoneyIconByMoneyType(item.moneyType)
        self.siDetailGold:SetImage(strMoneyIcon)
        self.stDetailText:SetText(tostring(item.price))
    end
    if item.status == BuyStatus.Buy then
        self.stDetailText:SetArea({ 0, 36 }, { 0, 0 }, { 0, 110}, { 0, 50})
        self.stDetailText:SetTextColor({213/255, 205/255, 47/255, 1})
        self.stDetailText:SetText(Lang:toText("gui_use"))
        self.siDetailGold:SetVisible(false)
        self.stDetailText:SetVisible(true)
    end
    if item.status == BuyStatus.Used then
        self.stDetailText:SetArea({ 0, 36 }, { 0, 0 }, { 0, 110}, { 0, 50})
        self.stDetailText:SetTextColor({213/255, 205/255, 47/255, 1})
        self.stDetailText:SetText(Lang:toText("gui_using"))
        self.siDetailGold:SetVisible(false)
        self.stDetailText:SetVisible(true)
    end
end

function M:onClickBeltItem(itemId)
    local item = BeltConfig:getItemById(itemId)
    if not item then
        print("M:onClickBeltItem(itemId) : is not exit :"..tostring(itemId))
        return
    end
    print(string.format("onClickBeltItem(itemId) item : %s  status : %s",item.id,item.status))
    self.selectItemId = itemId
    self:changeAllItemClickStatus(itemId)
    self:choseUseDetailUi(item.isPay)
    if item.status == BuyStatus.Lock then
        if self.islandLockId == itemId then
            print("<onClickBeltItem:> islandLock "..tostring(itemId))
            self:lockItemDetail(true, item.islandIcon)
        end
        return
    else
        self:showItemDetail()
    end
    self.stDetailTitle:SetText(Lang:toText(tostring(item.name)))
    self.siDetailItemIcon:SetImage(item.icon)
    self.stDetailValueText[1]:SetText(Lang:toText(tostring("gui_belt_text1")))

    local fullName = string.format("myplugin/%s",  item.itemName)
    local item1 = Item.CreateItem(fullName)
    assert(item1:cfg(), "onClickBeltItem(itemId) : item:cfg() is not exit :"..tostring(itemId))
    local Cfg = Entity.BuffCfg(item1:cfg().equip_buff)
    assert(Cfg.expMax, "onClickBeltItem(itemId) : Cfg.expMax is not exit :"..tostring(itemId))
    self.stDetailValueNum[1]:SetText(tostring(BigInteger.Create(Cfg.expMax.val, Cfg.expMax.bit)))
    self.siDetailValue[2]:SetVisible(false)
    self.siDetailValue[3]:SetVisible(false)
    self.stDetailDescribe:SetArea({ 0, 0 }, { 0, 224 }, { 0, 258}, { 0, 152})
    self.stDetailDescribe:SetText(Lang:toText(item.desc))
    if item.status == BuyStatus.Unlock then
        self.stDetailText:SetArea({ 0, 70 }, { 0, 0 }, { 0, 110}, { 0, 50})
        self.stDetailText:SetTextColor({1, 1, 1, 1})
        local strMoneyIcon = getMoneyIconByMoneyType(item.moneyType)
        self.siDetailGold:SetImage(strMoneyIcon)
        self.stDetailText:SetText(tostring(item.price))
    end
    if item.status == BuyStatus.Buy then
        self.stDetailText:SetArea({ 0, 36 }, { 0, 0 }, { 0, 110}, { 0, 50})
        self.stDetailText:SetTextColor({213/255, 205/255, 47/255, 1})
        self.stDetailText:SetText(Lang:toText("gui_use"))
        self.siDetailGold:SetVisible(false)
        self.stDetailText:SetVisible(true)
    end
    if item.status == BuyStatus.Used then
        self.stDetailText:SetArea({ 0, 36 }, { 0, 0 }, { 0, 110}, { 0, 50})
        self.stDetailText:SetTextColor({213/255, 205/255, 47/255, 1})
        self.stDetailText:SetText(Lang:toText("gui_using"))
        self.siDetailGold:SetVisible(false)
        self.stDetailText:SetVisible(true)
    end
end

function M:onClickAdvancelItem(itemId)
    local item = AdvanceConfig:getItemById(itemId)
    if not item then
        print("M:onClickAdvancelItem(itemId) : is not exit :"..tostring(itemId))
        return
    end
    print(string.format("onClickAdvancelItem(itemId) item : %s  status : %s",item.id,item.status))
    self.selectItemId = itemId
    self:changeAllItemClickStatus(itemId)
    self:choseUseDetailUi(item.isPay)
    if item.status == BuyStatus.Lock then
        if self.islandLockId == itemId then
            print("<onClickAdvancelItem:> islandLock "..tostring(itemId))
            self:lockItemDetail(true, item.islandIcon)
        end
        return
    else
        self:showItemDetail()
    end
    self.stDetailTitle:SetText(Lang:toText(tostring(item.name)))
    self.siDetailItemIcon:SetImage(item.icon)
    self.stDetailValueText[1]:SetText(Lang:toText(tostring("gui_advance_text1")))
    self.stDetailValueNum[1]:SetText("X"..tostring(BigInteger.Create(item.attack)))
    self.stDetailValueText[2]:SetText(Lang:toText(tostring("gui_advance_text2")))
    self.stDetailValueNum[2]:SetText("X"..tostring(BigInteger.Create(item.speed)))
    self.stDetailValueText[3]:SetText(Lang:toText(tostring("gui_advance_text3")))
    self.stDetailValueNum[3]:SetText("X"..tostring(BigInteger.Create(item.workout)))
    self.stDetailDescribe:SetArea({ 0, 0 }, { 0, 305 }, { 0, 258}, { 0, 71})
    self.stDetailDescribe:SetText(Lang:toText(item.desc))
    if item.status == BuyStatus.Unlock then
        self.stDetailText:SetArea({ 0, 70 }, { 0, 0 }, { 0, 110}, { 0, 50})
        self.stDetailText:SetTextColor({1, 1, 1, 1})
        local strMoneyIcon = getMoneyIconByMoneyType(item.moneyType)
        self.siDetailGold:SetImage(strMoneyIcon)
        self.stDetailText:SetText(tostring(item.price))
    end
    if item.status == BuyStatus.Buy then
        self.stDetailText:SetArea({ 0, 36 }, { 0, 0 }, { 0, 110}, { 0, 50})
        self.stDetailText:SetTextColor({213/255, 205/255, 47/255, 1})
        self.stDetailText:SetText(Lang:toText("gui_using"))
        self.stDetailText:SetVisible(true)
        self.btnDetail:SetVisible(false)
        self.stDetailText:SetVisible(false)
        self.siDetailGold:SetVisible(false)
    end
    if item.status == BuyStatus.Used then
        self.stDetailText:SetArea({ 0, 36 }, { 0, 0 }, { 0, 110}, { 0, 50})
        self.stDetailText:SetTextColor({213/255, 205/255, 47/255, 1})
        self.stDetailText:SetText(Lang:toText("gui_using"))
        self.stDetailText:SetVisible(true)
        self.btnDetail:SetVisible(false)
        self.stDetailText:SetVisible(false)
        self.siDetailGold:SetVisible(false)
    end
    self.selectItemId = itemId
end

function M:lockItemDetail(islandLock, islandIcon)
    self.siDetailItemLock:SetVisible(false)
    if islandLock then
        self.stDetailTitle:SetVisible(false)
        self.siDetailItemIcon:SetImage(islandIcon)
        self.stDetailDescribe:SetArea({ 0, 0 }, { 0, 224 }, { 0, 258}, { 0, 152})
        self.stDetailDescribe:SetText(Lang:toText("need_next_islands_unlocks"))
        self.stDetailDescribe:SetVisible(true)
    else
        self.stDetailDescribe:SetVisible(false)
    end
    for i = 1, 3 do
        self.siDetailValue[i]:SetVisible(false)
    end
    self.btnDetail:SetVisible(false)
    self.stDetailText:SetVisible(false)
    self.siDetailGold:SetVisible(false)
end

function M:showItemDetail()
    self.stDetailTitle:SetVisible(true)
    self.siDetailItemLock:SetVisible(false)
    self.stDetailDescribe:SetVisible(true)
    for i = 1, 3 do
        self.siDetailValue[i]:SetVisible(true)
    end
    self.btnDetail:SetVisible(true)
    self.stDetailText:SetVisible(true)
    self.siDetailGold:SetVisible(true)
end

function M:onHide()
    UI:closeWnd("itemShop")
end

function M:checkCanShow()
    if UI:isOpen(self) then
        return false
    end
    if not self.isInitData then
        self:initData()
        return true
    end
    return true
end

function M:onShow(isShow)
    if isShow then
        if self:checkCanShow() then
            UI:openWnd("itemShop")
        end
    else
        self:onHide()
    end
end

function M:onOpen()
    local toolBar = UI:getWnd("toolbar")
    toolBar:root():SetAlwaysOnTop(true)
    toolBar:root():SetLevel(2)
end

function M:onDetailButton()
    self:senderDetailButtonClick()
end

function M:onBuyAll()
    --UI:getWnd("payShop"):onBuyPropBagCapacity()
    self:senderBuyAll()
end

function M:senderBuyAll()
    print(string.format("<M:senderBuyAll:> TypeId: %s  ItemId: %s", tostring(self.selectTab), tostring(self.selectItemId)))
    if not self:checkCanSend(true) then
        return
    end
    local packet = {
        pid = "SyncItemShopBuyAll",
        tabId = self.selectTab,
    }
    Me:sendPacket(packet)
end

function M:senderDetailButtonClick()
    print(string.format("<M:senderDetailButtonClick:> TypeId: %s  ItemId: %s", tostring(self.selectTab), tostring(self.selectItemId)))
    if not self:checkCanSend(false) then
        return
    end
    local packet = {
        pid = "SyncItemShopOperation",
        tabId = self.selectTab,
        itemId = self.selectItemId
    }
    Me:sendPacket(packet)
end

function M:checkCanSend(notStatus)
    local isFlag = notStatus or false
    local itemConfig = {}
    if self.selectTab == TabType.Equip then
        itemConfig = EquipConfig
    elseif self.selectTab == TabType.Belt then
        itemConfig = BeltConfig
    elseif self.selectTab == TabType.Advance then
        itemConfig = AdvanceConfig
    end
    local item = itemConfig:getItemById(self.selectItemId)
    if not item then
        return
    end
    if not isFlag then
        if item.status == BuyStatus.Used then
            return false
        end
    end
    return self:checkItemMoney(item)
end

function M:checkItemMoney(item)
    if item.isPay then
        local wallet = Me:data("wallet")
        if wallet["gDiamonds"] then
            if wallet["gDiamonds"].count > item.price then
                return true
            end
        end
    else
        if Coin:countByCoinName(Me, Coin:coinNameByCoinId(item.moneyType)) > item.price then
            return true
        end
    end
    Lib.emitEvent(Event.EVENT_NOT_ENOUGH_MONEY)
    print("checkItemMoney item.moneyType : "..tostring(Coin:coinNameByCoinId(item.moneyType)).." item.price: "..tostring(item.price))
    return false
end

function M:updateItems(isReset)
    print("M:updateDate(self.selectTab) : "..tostring(self.selectTab))
    local itemConfig = {}
    local buyInfo = {}
    if self.selectTab == TabType.Equip then
        buyInfo = Me:getEquip()
        print("updateItems self.selectTab : "..tostring(self.selectTab).." getEquip  1:", Lib.v2s(buyInfo, 3))
        itemConfig = EquipConfig
    elseif self.selectTab == TabType.Belt then
        buyInfo = Me:getBelt()
        print("updateItems self.selectTab : "..tostring(self.selectTab).." getBelt  1:", Lib.v2s(buyInfo, 3))
        itemConfig = BeltConfig
    elseif self.selectTab == TabType.Advance then
        itemConfig = AdvanceConfig
        buyInfo = self:getAdvanceInfo()
        print("updateItems self.selectTab : "..tostring(self.selectTab).." getAdvanceInfo  1:", Lib.v2s(buyInfo, 3))
    end
    for _, item in pairs(itemConfig:getSettings()) do
        item.status = buyInfo[tostring(item.id)]  or BuyStatus.Lock
    end
    self:onUpdateIslandLockId()
    print("islandLockId "..tostring(self.islandLockId))
    self:addItemsGridView(isReset)
    self:onClickNextItem(itemConfig)
end

function M:onClickNextItem(itemConfig)
    local curItem = itemConfig:getItemById(self.selectItemId)
    if curItem then
        local nextItem = itemConfig:getNextItemByPay(self.selectItemId, curItem.isPay)
        if nextItem then
            if nextItem.status ~= BuyStatus.Lock or self.islandLockId == nextItem.id then
                self:onClickItem(nextItem.id)
            else
                self:onClickItem(curItem.id)
            end
            print(string.format("<onClickNextItem:> TypeId: %s  ItemId: %s self.selectItemId : %s", tostring(self.selectTab), tostring(self.selectItemId),tostring(nextItem.id)))
        end
    end
end

function M:getAdvanceInfo()
    local buyInfo = {}
    local curLevel = Me:getCurLevel()
    print("getAdvanceInfo Me:getCurLevel() : "..tostring(Me:getCurLevel()))
    local curId = -1
    for _, value in ipairs((AdvanceConfig:getSettings())) do
        if curLevel >= value.level then
            buyInfo[tostring(value.id)] = BuyStatus.Buy
            curId = value.id
        end
    end
    if curId ~= -1 then
        buyInfo[tostring(curId)] = BuyStatus.Used
        --if self.isFirstAdvance then
            local nextItem = AdvanceConfig:getNextItemByPay(curId, false)
            if nextItem and  Me:getIslandLv() >= nextItem.islandLv then
                buyInfo[tostring(nextItem.id)] = BuyStatus.Unlock
                --self.isFirstAdvance = false
            end
        --end
    end
    return buyInfo
end

function M:choseUseDetailUi(isPay)
    if isPay then
        self:useCostDetailUi()
        return
    end
    self:useCommonDetailUi()
end

function M:useCommonDetailUi()
    self.siDetailBg:SetImage("set:ninja_legends_itemshop.json image:detail_bg_common")
    self.siDetailItemBg:SetImage("set:ninja_legends_itemshop.json image:item_value_bg_common")
    for i = 1, 3 do
        self.siDetailValue[i]:SetImage("set:ninja_legends_itemshop.json image:item_value_bg_common")
    end
    self.btnDetail:SetNormalImage("set:ninja_legends_itemshop.json image:btn_blue")
    self.btnDetail:SetPushedImage("set:ninja_legends_itemshop.json image:btn_blue")
end

function M:useCostDetailUi()
    self.siDetailBg:SetImage("set:ninja_legends_itemshop.json image:detail_bg_cost")
    self.siDetailItemBg:SetImage("set:ninja_legends_itemshop.json image:item_value_bg_cost")
    for i = 1, 3 do
        self.siDetailValue[i]:SetImage("set:ninja_legends_itemshop.json image:item_value_bg_cost")
    end
    self.btnDetail:SetNormalImage("set:ninja_legends_itemshop.json image:btn_red")
    self.btnDetail:SetPushedImage("set:ninja_legends_itemshop.json image:btn_red")
end

function M:initData()
    local packet = {
        pid = "SyncItemShopInit"
    }
    Me:sendPacket(packet)
    self.isInitData = true
end