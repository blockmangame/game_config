local ItemShop = Store.ItemShop
local TabType = Store.ItemShop.TabType
local BuyStatus = Store.ItemShop.BuyStatus
local EquipConfig = ItemShop.EquipConfig
local PayEquipConfig = ItemShop.PayEquipConfig
local BeltConfig = ItemShop.BeltConfig
local AdvanceConfig = ItemShop.AdvanceConfig
--local M = {}
function M:init()
    print("M:init() 999999999999999999999999")
    --Lib.log_1(ItemShop.EquipConfig)
    WinBase.init(self, "NinjaLegendsItemShop.json",false)
    self.isInitData = false
    self:onLoad()
end

function M:onLoad()
    self.tabList = {}--tab列表
    self.selectTab = TabType.Equip--选中的tab类型
    self.selectItemId = 0 --选中的商品的Id
    self.itemsGridView = {}--商品列表

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
            self.selectTab = tabType
            --self.selectItemId = Value.id
            print("M:M:initTabList()(tabType) :"..tostring(tabType))
            self.tabList[i]:invoke("onCheckClick", tabType)
            self:addItemsGridView(true)
        end
    end
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
        self:addItemsGridView(true)
    end
end

function M:addItemsGridView(isResetPos)
    print("---------addItemsGridView-----------")
    print("flag ： "..tostring(isResetPos))
    self.gvItemsGridView:RemoveAllItems()
    if self.selectTab == TabType.Equip then
        self:addViewByConfig(EquipConfig, isResetPos)
    elseif self.selectTab == TabType.Belt then
        self:addViewByConfig(BeltConfig, isResetPos)
    elseif self.selectTab == TabType.Advance then
        self:addViewByConfig(AdvanceConfig, isResetPos)
    end
    print("<addItemsGridView:> isResetPos "..tostring(isResetPos))
end

function M:addViewByConfig(Config, isResetPos)
    local clickItemId = 0
    for i, Value in pairs(Config) do
        local ItemIcon = "set:LiftingSimulatorShop1.json image:equipOrSkillBg"
        print("<addViewByConfig:> kind "..tostring(self.selectTab))
        print("<addViewByConfig:> Value.Icon "..tostring(Value.icon))
        local shopItem = UIMgr:new_widget("itemShopItem")
        local contentWidth = self.gvItemsGridView:GetWidth()[2]
        local contentHeight = self.gvItemsGridView:GetHeight()[2]
        --local area = self.gvContentItemsGridView:GetArea()
        --local Area = {r_x = area.min.x[1], r_y = area.min.y[1], r_width = area.max.x[1] - area.min.x[1], r_height = area.max.y[1] - area.min.y[1]}
        local itemWidth = (contentWidth - 0.1) / 4
        local itemHeight = (contentHeight - 0.1) / 3
        local area = {x = { 0, 0 }, y = { 0, 0 }, w = { itemWidth, 0 }, h = { itemWidth, 0 }}
        --Lib.log_1 (area)
        shopItem:invoke("initItem",self.selectTab, Value, area)
        --self.gvContentItemsGridView:AddItem1(shopItem, 0, index)
        self:subscribe(shopItem, UIEvent.EventWindowClick, function()
            self:onClickItem(Value.id)
        end)
        self.gvItemsGridView:AddItem(shopItem)
        self.itemsGridView[i] = shopItem
        if i == 1 then
            clickItemId = Value.id
        end
    end
    if isResetPos and #self.itemsGridView >= 1 then
        self.gvItemsGridView:ResetPos()
        if clickItemId > 0  then
            self.selectItemId = clickItemId
            self:onClickItem(clickItemId)
        end
    end
end

function M:onClickItem(itemId)
    print("M:onClickItem() self.itemId "..tostring(itemId).." self.selectTab : "..tostring(self.selectTab))
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
    local item = EquipConfig[itemId]
    if not item then
        print("M:onClickEquipItem(itemId) : is not exit :"..tonumber(itemId))
        return
    end
    self.selectItemId = itemId
    print("<onClickEquipItem:> itemId "..tostring(itemId))
    print("<onClickEquipItem:> equip.Status "..tostring(item.Status))
    self:changeAllItemClickStatus(itemId)
    self:choseUseDetailUi(item.moneyType)
    if item.status == BuyStatus.Lock then
        self:lockItemDetail()
        return
    else
        self:showItemDetail()
    end
    local strItemPropertyNum1 = item.value1
    local payFitnessEquip = PayEquipConfig[itemId]
    local strDetailDescribe = Lang:toText(item.desc)
    if "gDiamonds" == Coin:coinNameByCoinId(item.moneyType) and payFitnessEquip then
        if item.status == BuyStatus.Buy or item.Status == BuyStatus.Used then
            strDetailDescribe = Lang:toText(payFitnessEquip.efficiencyFixHugeDes)
            local specialNum = string.format("%.0f", payFitnessEquip.efficiencyFixHuge)
            strItemPropertyNum1 =  tostring(payFitnessEquip.efficiencyFixHuge)
            strDetailDescribe = string.format(strDetailDescribe,specialNum)
        elseif tonumber(Me:getCurLevel()) <= payFitnessEquip.unlockAdvancedLevel  then
            strDetailDescribe = Lang:toText(item.Desc)
            local specialStr = "+"..payFitnessEquip.efficiencyPercentage.."%"
            strItemPropertyNum1 = payFitnessEquip.efficiencyPercentage.."%"
            strDetailDescribe = string.format(strDetailDescribe,specialStr)
        elseif tonumber(Me:getCurLevel()) > payFitnessEquip.unlockAdvancedLevel then
            strDetailDescribe = Lang:toText(payFitnessEquip.efficiencyFixDes)
            if Me:getCurLevel() >= payFitnessEquip.invailedAdvancedLevel then
                local specialNum = string.format("%.0f", payFitnessEquip.efficiencyFix)
                strItemPropertyNum1 = tostring(payFitnessEquip.efficiencyFix)
                strDetailDescribe = string.format(strDetailDescribe,specialNum)
            else
                local specialStr = "+"..payFitnessEquip.efficiencyPercentage.."%"
                strItemPropertyNum1 = payFitnessEquip.efficiencyPercentage.."%"
                strDetailDescribe = string.format(strDetailDescribe,specialStr)
            end
        end
    else
        strItemPropertyNum1 = tostring(item.Efficiency)
        strDetailDescribe = string.format(strDetailDescribe,strItemPropertyNum1)
    end
    self.stDetailTitle:SetText(Lang:toText(tostring(item.name)))
    self.siDetailItemIcon:SetImage(item.icon)
    self.stDetailValueText[1]:SetText(Lang:toText(tostring("ValueText1")))
    self.stDetailValueNum[1]:SetText(tonumber(strItemPropertyNum1))
    self.stDetailValueText[2]:SetText(Lang:toText(tostring("ValueText2")))
    self.stDetailValueNum[2]:SetText(tonumber(item.value2))
    self.stDetailValueText[3]:SetText(Lang:toText(tostring("ValueText3")))
    self.stDetailValueNum[3]:SetText(tonumber(item.value3))
    self.siDetailValue[2]:SetVisible(false)
    self.siDetailValue[3]:SetVisible(false)
    self.stDetailDescribe:SetArea({ 0, 0 }, { 0, 224 }, { 0, 258}, { 0, 152})
    self.stDetailDescribe:SetText(Lang:toText(strDetailDescribe))
    if item.status == BuyStatus.Unlock then
        self.stDetailText:SetArea({ 0, 70 }, { 0, 0 }, { 0, 110}, { 0, 50})
        self.stDetailText:SetTextColor({1, 1, 1, 1})
        local strMoneyIcon = ItemShop:getMoneyIconByMoneyType(item.moneyType)
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
    local item = BeltConfig[itemId]
    if not item then
        print("M:onClickBeltItem(itemId) : is not exit :"..tonumber(itemId))
        return
    end
    self.selectItemId = itemId
    print("<onClickEquipItem:> itemId "..tostring(itemId))
    print("<onClickEquipItem:> equip.Status "..tostring(item.Status))
    self:changeAllItemClickStatus(itemId)
    self:choseUseDetailUi(item.moneyType)
    if item.status == BuyStatus.Lock then
        self:lockItemDetail()
        return
    else
        self:showItemDetail()
    end
    self.stDetailTitle:SetText(Lang:toText(tostring(item.name)))
    self.siDetailItemIcon:SetImage(item.icon)
    self.stDetailValueText[1]:SetText(Lang:toText(tostring("ValueText1")))
    self.stDetailValueNum[1]:SetText(tonumber(item.value1))
    self.stDetailValueText[2]:SetText(Lang:toText(tostring("ValueText2")))
    self.stDetailValueNum[2]:SetText(tonumber(item.value2))
    self.stDetailValueText[3]:SetText(Lang:toText(tostring("ValueText3")))
    self.stDetailValueNum[3]:SetText(tonumber(item.value3))
    self.siDetailValue[2]:SetVisible(false)
    self.siDetailValue[3]:SetVisible(false)
    self.stDetailDescribe:SetArea({ 0, 0 }, { 0, 224 }, { 0, 258}, { 0, 152})
    self.stDetailDescribe:SetText(Lang:toText(item.desc))
    if item.status == BuyStatus.Unlock then
        local strMoneyIcon = ItemShop:getMoneyIconByMoneyType(item.moneyType)
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
    local item = AdvanceConfig[itemId]
    if not item then
        print("M:onClickAdvancelItem(itemId) : is not exit :"..tonumber(itemId))
        return
    end
    self.selectItemId = itemId
    print("<onClickEquipItem:> itemId "..tostring(itemId))
    print("<onClickEquipItem:> equip.Status "..tostring(item.Status))
    self:changeAllItemClickStatus(itemId)
    self:choseUseDetailUi(item.moneyType)
    if item.status == BuyStatus.Lock then
        self:lockItemDetail()
        return
    else
        self:showItemDetail()
    end
    self.stDetailTitle:SetText(Lang:toText(tostring(item.name)))
    self.siDetailItemIcon:SetImage(item.icon)
    self.stDetailValueText[1]:SetText(Lang:toText(tostring("ValueText1")))
    self.stDetailValueNum[1]:SetText(tonumber(item.value1))
    self.stDetailValueText[2]:SetText(Lang:toText(tostring("ValueText2")))
    self.stDetailValueNum[2]:SetText(tonumber(item.value2))
    self.stDetailValueText[3]:SetText(Lang:toText(tostring("ValueText3")))
    self.stDetailValueNum[3]:SetText(tonumber(item.value3))
    --self.siDetailValue[2]:SetVisible(false)
    --self.siDetailValue[3]:SetVisible(false)
    self.stDetailDescribe:SetArea({ 0, 0 }, { 0, 305 }, { 0, 258}, { 0, 71})
    self.stDetailDescribe:SetText(Lang:toText(item.desc))
    if item.status == BuyStatus.Unlock then
        local strMoneyIcon = ItemShop:getMoneyIconByMoneyType(item.moneyType)
        self.siDetailGold:SetImage(strMoneyIcon)
        self.stDetailText:SetText(tostring(item.price))
    end
    if item.status == BuyStatus.Buy then
        self.stDetailText:SetArea({ 0, 36 }, { 0, 0 }, { 0, 110}, { 0, 50})
        self.stDetailText:SetTextColor({213/255, 205/255, 47/255, 1})
        self.stDetailText:SetText(Lang:toText("gui_using"))
        self.siDetailGold:SetVisible(false)
        self.stDetailText:SetVisible(true)
        self.btnDetail:SetVisible(false)
        self.stDetailText:SetVisible(false)
        self.siDetailGold:SetVisible(false)
    end
    if item.status == BuyStatus.Used then
        self.stDetailText:SetArea({ 0, 36 }, { 0, 0 }, { 0, 110}, { 0, 50})
        self.stDetailText:SetTextColor({213/255, 205/255, 47/255, 1})
        self.stDetailText:SetText(Lang:toText("gui_using"))
        self.siDetailGold:SetVisible(false)
        self.stDetailText:SetVisible(true)
        self.btnDetail:SetVisible(true)
        self.stDetailText:SetVisible(true)
        self.siDetailGold:SetVisible(false)
    end
    self.selectItemId = itemId
end

function M:lockItemDetail()
    --self.siDetailItemLock:SetVisible(true)
    --self.stDetailDescribe:SetVisible(false)
    --for i = 1, 3 do
    --    self.siDetailValue[i]:SetVisible(false)
    --end
    self.btnDetail:SetVisible(false)
    self.stDetailText:SetVisible(false)
    self.siDetailGold:SetVisible(false)
end

function M:showItemDetail()
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

function M:onShow(isShow)
    if isShow and self.isInitData then
        if not UI:isOpen(self) then
            UI:openWnd("itemShop")
        end
    else
        self:onHide()
    end
end

function M:onDetailButton()
    print("<onDetailButton:> self.selectTab "..tostring(self.selectTab))
    print("<onDetailButton:> self.selectItemId "..tostring(self.selectItemId))
    self:senderDetailButtonClick()
end

function M:onBuyAll()
    print("<onBuyAll:> self.selectTab "..tostring(self.selectTab))
    print("<onBuyAll:> self.selectItemId "..tostring(self.selectItemId))
    --self:senderDetailButtonClick()
end

function M:senderDetailButtonClick()
    print(string.format("<M:senderDetailButtonClick:> TypeId: %s  ItemId: %s", tostring(self.selectTab), tostring(self.selectItemId)))
    if not self:checkItemStatus() then
        return
    end
    local packet = {
        pid = "SyncItemShopOperation",
        tabId = self.selectTab,
        itemId = self.selectItemId
    }
    Me:sendPacket(packet)
end

function M:checkItemStatus()
    if self.selectTab == TabType.Equip then
        if(EquipConfig[self.selectItemId].status == BuyStatus.Used) then
            return false
        end
    elseif self.selectTab == TabType.Belt then
        if(BeltConfig[self.selectItemId].status == BuyStatus.Used) then
            return false
        end
    elseif self.selectTab == TabType.Advance then
        if(AdvanceConfig[self.selectItemId].status == BuyStatus.Used) then
            return false
        end
    end
    return true
end

function M:initItemShop(data)
    print("M:initItemShop(data)")
    if not next(data) then
        return
    end
    for tab, items in pairs(data) do
        for _, v in pairs(TabType) do
            if tab == v then
                self:updateItemShopByTab(tab, items)
            end
        end
    end
    self.isInitData = true
end

function M:updateItemShopByTab(tabId, itemDate)
    print(string.format("M:updateItemShopByTab(tabId, itemDate):> TypeId: %s", tostring(tabId)))
    if tabId == TabType.Equip then
        self:updateItem(EquipConfig, itemDate)
    elseif tabId == TabType.Belt then
        self:updateItem(BeltConfig, itemDate)
    elseif tabId == TabType.Advance then
        self:updateItem(AdvanceConfig, itemDate)
    else
        return
    end
end

function M:updateItem(configTable, itemDate)
    print(string.format("updateItem:> TypeId: %s", tostring(self.selectTab)))
    local nextId = self:getNextId(EquipConfig)
    for id, status in pairs(itemDate) do
        if configTable[id] then
            configTable[id].status = status
            --nextId = id
        end
    end
    if self.selectTab == TabType.Equip then
        self:addItemsGridView(false)
        self:onClickEquipItem(nextId)
    elseif self.selectTab == TabType.Belt then
        self:addItemsGridView(false)
        self:onClickBeltItem(nextId)
    elseif self.selectTab == TabType.Advance then
        self:addItemsGridView(false)
        self:onClickAdvancelItem(nextId)
    end
end

function M:getNextId(itemConfig)
    --if EquipConfig[self.selectItemId].status ~= BuyStatus.Unlock then
    --    return self.selectItemId
    --end
    local curId = self.selectItemId
    --local key = #itemConfig
    --if curId == key then
    --    return curId
    --end
    --for i = curId + 1, key do
    --    if itemConfig[curId].moneyType == itemConfig[i].moneyType then
    --        return itemConfig[i].id
    --    end
    --end
    return curId + 1
end

function M:choseUseDetailUi(moneyType)
    if "gDiamonds" == Coin:coinNameByCoinId(moneyType) then
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

function M:isInitItemData()
   return self.isInitData
end