local PropConfig = T(Config, "PropConfig")
local ResourceConfig = T(Config, "ResourceConfig")
local SkinConfig = T(Config, "SkinConfig")
local PrivilegeConfig = T(Config, "PrivilegeConfig")

local BuyStatus = Define.BuyStatus
local TabType = {
    Prop = Define.TabType.Prop,
    Resource = Define.TabType.Resource,
    Skin = Define.TabType.Skin,
    Privilege = Define.TabType.Privilege,
}

local SelectStatus = {
    NotSelect = 1,
    Select = 2,
}

local function getMoneyIconByMoneyType(moneyType)
    local coinName = Coin:coinNameByCoinId(moneyType)
    assert(coinName, "Coin:coinNameByCoinId(moneyType) ：" .. tostring(moneyType).. " is not a exit")
    return Coin:iconByCoinName(coinName)
end
--local M = {}

function M:init()
    print("M:init() 77777777777777777777")
    ----Lib.log_1(ItemShop.EquipConfig)
    WinBase.init(self, "NinjaLegendsPayShop.json",false)
    self.isInitData = false
    self:onLoad()
end

function M:onLoad()
    self.tabList = {}--tab列表
    self.selectTab = nil --选中的tab类型
    self.selectItemId = 0 --选中的商品的Id
    self.itemsGridView = {}--商品列表

    self:initUI()
    self:initEvent()
end

function M:initUI()
    self.stTitleText = self:child("NinjaLegendsPayShop-Name")
    self.stTitleText:SetText(Lang:toText("NinjaLegendsPayShop-Name"))
    self.btnClose = self:child("NinjaLegendsPayShop-Close")
    self.llContentItemsGridView = self:child("NinjaLegendsPayShop-Content")
    self.gvItemsGridView = GUIWindowManager.instance:CreateGUIWindow1("GridView", "NinjaLegendsPayShop-gvItemsGridView")
    self.llContentItemsGridView:AddChildWindow(self.gvItemsGridView)
    self.gvItemsGridView:SetArea({ 0, 0 }, { 0, 0 }, { 1, 0 }, { 1, 0 })
    self.gvItemsGridView:InitConfig(20, 16, 4)
    self.siTabIcon = self:child("NinjaLegendsPayShop-Tab-Icon")
    self.atTabModel = self:child("NinjaLegendsPayShop-Tab-Model")
    self:initTabList()
end

function M:initEvent()
    self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
        self:onHide()
    end)
    Lib.subscribeEvent(Event.EVENT_PAY_SHOP_UPDATE, function(tabId)
        --print(" === Event.EVENT_PAY_SHOP_UPDATE == 1")
        self:updateItems(tabId,false)
        --print(" === Event.EVENT_PAY_SHOP_UPDATE == 2")
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
        self.tabList[i] = {}
        self.tabList[i].type = tabType
        local str = string.format("NinjaLegendsPayShop-Tab%d", i)
        self.tabList[i].bg = self:child(str)
        self:subscribe(self.tabList[i].bg, UIEvent.EventWindowClick, function()
            self:onClickTab(tabType)
        end)
        local str1 = string.format("NinjaLegendsPayShop-Tab-Icon%d", i)
        self.tabList[i].icon = self:child(str1)
        self.tabList[i].notSelectIcon = self:onChoseTabIcon(tabType, SelectStatus.NotSelect)
        self.tabList[i].selectIcon = self:onChoseTabIcon(tabType, SelectStatus.Select)
    end
    self:onClickTab(TabType.Prop)
end

--点击Tab
function M:onClickTab(type)
    print("---------onClickTab-----------Type : "..type)
    if self.selectTab ~= type then
        self.selectTab = type
        self:updateItems(type, true)
    end
    self:onUpdateTab(type)
end

function M:onUpdateTab(type)
    for i, v in pairs(self.tabList) do
        if v.type == type then
            v.icon:SetImage(v.selectIcon)
        else
            v.icon:SetImage(v.notSelectIcon)
        end
    end
    local isShow = false
    if TabType.Skin == type then
        isShow = true
    end
    self.siTabIcon:SetVisible(not isShow)
    self.atTabModel:SetVisible(isShow)
end

function M:addItemsGridView(isResetPos)
    print("addItemsGridView self.selectTab : "..tostring(self.selectTab).." isResetPos: "..tostring(isResetPos))
    self.gvItemsGridView:RemoveAllItems()
    self.itemsGridView = {}
    if self.selectTab == TabType.Prop then
        self:addViewByConfig(PropConfig, isResetPos)
    elseif self.selectTab == TabType.Resource then
        self:addViewByConfig(ResourceConfig, isResetPos)
    elseif self.selectTab == TabType.Skin then
        self:addViewByConfig(SkinConfig, isResetPos)
   elseif self.selectTab == TabType.Privilege then
        self:addViewByConfig(PrivilegeConfig, isResetPos)
    end
end

function M:addViewByConfig(Config, isResetPos)
    local clickItem = nil
    for i, Value in pairs(Config:getSettings()) do
        local shopItem = UIMgr:new_widget("payShopItem")
        shopItem:invoke("initItem",self.selectTab, Value)
        self:subscribe(shopItem, UIEvent.EventWindowClick, function()
            self:onClickItem(Value.id, Value.status)
        end)
        self:subscribe(shopItem:child("NinjaLegendsPayShopItem-Item-Btn"), UIEvent.EventButtonClick, function()
            self:onClickButtonItem(Value.id, Value.status)
        end)
        self.gvItemsGridView:AddItem(shopItem)
        self.itemsGridView[i] = shopItem
        if i == 1 then
            clickItem = Value
        end
    end
    if #self.itemsGridView >= 1 then
        if isResetPos and clickItem then
            self.gvItemsGridView:ResetPos()
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

function M:onClickButtonItem(itemId, status)
    print(string.format("<M:onClickButtonItem:> TypeId: %s  ItemId: %s  status: %s", tostring(self.selectTab), tostring(itemId),tostring(status)))
    self.selectItemId = itemId
    self:changeAllItemClickStatus(itemId)
    local itemConfig = {}
    if self.selectTab == TabType.Prop then
        itemConfig = PropConfig
    elseif self.selectTab == TabType.Resource then
        itemConfig = ResourceConfig
    elseif self.selectTab == TabType.Skin then
        itemConfig = SkinConfig
    elseif self.selectTab == TabType.Privilege then
        itemConfig = PrivilegeConfig
    end
    local item = itemConfig:getItemById(itemId)
    if item then
        if self:checkItemStatus(status) and self:checkItemMoney(item) then
            self:senderClickItemBuy()
        end
    end
end

function M:checkItemStatus(status)
    if status == BuyStatus.Used and self.selectTab ~= TabType.Skin then
        return false
    end
    return true
end

function M:senderClickItemBuy()
    print(string.format("<M:senderClickItemBuy:> TypeId: %s  ItemId: %s", tostring(self.selectTab), tostring(self.selectItemId)))
    local packet = {
        pid = "SyncPayShopOperation",
        tabId =  self.selectTab,
        itemId = self.selectItemId,
    }
    Me:sendPacket(packet)
end

function M:onClickItem(itemId, status)
    print("payItem:onClickItem() self.itemId "..tostring(itemId).." self.selectTab : "..tostring(self.selectTab))
    if self.selectTab == TabType.Prop then
        self:onClickPropItem(itemId,status)
    elseif self.selectTab == TabType.Resource then
        self:onClickResourceItem(itemId, status)
    elseif self.selectTab == TabType.Skin then
        self:onClickSkinItem(itemId, status)
    elseif self.selectTab == TabType.Privilege then
        self:onClickPrivilegeItem(itemId, status)
    end
end

function M:changeAllItemClickStatus(itemId)
    for _, shopItem in pairs(self.itemsGridView) do
        shopItem:invoke("onCheckClick",itemId)
    end
end

function M:onClickPropItem(itemId)
    --Lib.log_1(PrivilegeConfig:getSettings(), "PrivilegeConfig:getSettings()")
    local item = PropConfig:getItemById(itemId)
    if not item then
        print("M:onClickPropItem(itemId) : is not exit :"..tostring(itemId))
        return
    end
    --print("onClickPropItem ：", Lib.v2s(item))
    self.selectItemId = itemId
    print("<onClickPropItem:> itemId "..tostring(itemId))
    self:changeAllItemClickStatus(itemId)
    --self:senderClickItemBuy(tabId, itemId)
end

function M:onClickResourceItem(itemId)
    local item = ResourceConfig:getItemById(itemId)
    --Lib.log_1(item, "onClickEquipItem")
    if not item then
        print("M:onClickResourceItem(itemId) : is not exit :"..tostring(itemId))
        return
    end
    self.selectItemId = itemId
    print("<onClickResourceItem:> itemId "..tostring(itemId))
    self:changeAllItemClickStatus(itemId)
end

function M:onClickSkinItem(itemId)
    local item = SkinConfig:getItemById(itemId)
    if not item then
        print("M:onClickSkinItem(itemId) : is not exit :"..tonumber(itemId))
        return
    end
    self.selectItemId = itemId
    print("<onClickSkinItem:> itemId "..tostring(itemId))
    print("<onClickSkinItem:> equip.status "..tostring(item.status))
    self:changeAllItemClickStatus(itemId)
end

function M:onClickPrivilegeItem(itemId)
    local item = PrivilegeConfig:getItemById(itemId)
    if not item then
        print("M:onClickPrivilegeItem(itemId) : is not exit :"..tonumber(itemId))
        return
    end
    self.selectItemId = itemId
    print("<onClickPrivilegeItem:> itemId "..tostring(itemId))
    print("<onClickPrivilegeItem:> equip.status "..tostring(item.status))
    self:changeAllItemClickStatus(itemId)
end

function M:onHide()
    --self:hide()
    UI:closeWnd("PayShop")
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
            UI:openWnd("PayShop")
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

function M:checkItemMoney(item)
    local wallet = Me:data("wallet")
    if wallet["gDiamonds"] then
        if wallet["gDiamonds"].count > item.price then
            return true
        end
    end
    Lib.emitEvent(Event.EVENT_NOT_ENOUGH_MONEY)
    return false
end

function M:updateItems(type, isReset)
    print("updateItems self.selectTab 000: "..tostring(self.selectTab))
    print("updateItems type 000: "..tostring(type))
    if not type or self.selectTab ~= type then
        return
    end
    --self.selectTab = type
    local itemConfig = {}
    local buyInfo = {}
    if self.selectTab == TabType.Prop then
        buyInfo = Me:getProp()
        itemConfig = PropConfig
        print("updateItems self.selectTab : "..tostring(self.selectTab).." getProp  1:", Lib.v2s(buyInfo))
    elseif self.selectTab == TabType.Resource then
        buyInfo = Me:getResource()
        itemConfig = ResourceConfig
        print("updateItems self.selectTab : "..tostring(self.selectTab).." getResource  1:", Lib.v2s(buyInfo))
    elseif self.selectTab == TabType.Skin then
        buyInfo = Me:getSkin()
        itemConfig = SkinConfig
        print("updateItems self.selectTab : "..tostring(self.selectTab).." getSkin  1:", Lib.v2s(buyInfo))
    elseif self.selectTab == TabType.Privilege then
        buyInfo = Me:getPrivilege()
        itemConfig = PrivilegeConfig
        print("updateItems self.selectTab : "..tostring(self.selectTab).." getPrivilege  1:", Lib.v2s(buyInfo))
    else
        return
    end
    for _, item in pairs(itemConfig:getSettings()) do
        item.status = buyInfo[tostring(item.id)]  or BuyStatus.Lock
    end
    print("11111111111")
    self:addItemsGridView(isReset)
    print("2222222222")
end

function M:onChoseTabIcon(type ,isSelect)
    if isSelect == SelectStatus.NotSelect then
        if TabType.Prop == type then
            return "set:ninja_legends_payshop.json image:tab_item_1"
        elseif TabType.Resource == type then
            return "set:ninja_legends_payshop.json image:tab_res_1"
        elseif TabType.Skin == type then
            return "set:ninja_legends_payshop.json image:tab_skin_1"
        elseif TabType.Privilege == type then
            return "set:ninja_legends_payshop.json image:tab_privilege_1"
        end
    elseif isSelect == SelectStatus.Select then
        if TabType.Prop == type then
            return "set:ninja_legends_payshop.json image:tab_item_2"
        elseif TabType.Resource == type then
            return "set:ninja_legends_payshop.json image:tab_res_2"
        elseif TabType.Skin == type then
            return "set:ninja_legends_payshop.json image:tab_skin_2"
        elseif TabType.Privilege == type then
            return "set:ninja_legends_payshop.json image:tab_privilege_2"
        end
    end
end

function M:initData()
    local packet = {
        pid = "SyncPayShopInit"
    }
    Me:sendPacket(packet)
    self.isInitData = true
    print("initData self.isInitData = "..tostring(self.isInitData))
end