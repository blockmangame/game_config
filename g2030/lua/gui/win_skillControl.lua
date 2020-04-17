--- Created by lxm.

local skillShopConfig = T(Config, "skillShopConfig")

local skills = {}
skills.attack = {}
skills.defense = {}
skills.buff = {}
skills.Control = {}
skills.cure = {}

local equipPanelNum = 1

local equipPaneData = {}

local EquipCheckedId = 1

local PreviewUrl = ""

function M:init()
    WinBase.init(self, "skillControl.json",false)
    self.isInitData = false
    self:onLoad()
end

function M:onLoad()
    self:initItemConfig()
    self:initUI()
end

function M:initUI()

    -- main分页
    self.btnSkillStorePanel = self:child("skillControl-tab_SkillStorePanelBtn")
    self.btnSkillEquipPanel = self:child("skillControl-tab_SkillEquipPanelBtn")
    self.btnSkillStorePanel:SetSelected(true)

    --Store分页
    self.llStorePanel = self:child("skillControl-StorePanel")
    self.lttSkillItem = self:child("skillControl-SkillItemPanel")

    self.llCrossLine = self:child("skillControl-crossLine")


    self.llControlSkillItemView = self:child("skillControl-SkillItemView")
    self.gvItemsGridView = GUIWindowManager.instance:CreateGUIWindow1("GridView", "skillControl-gvItemsGridView")
    self.llControlSkillItemView:AddChildWindow(self.gvItemsGridView)
    self.gvItemsGridView:SetArea({ 0, 0 }, { 0, 0 }, { 1, 0 }, { 1, 0 })
    self.gvItemsGridView:InitConfig(22, 12, 5)

        --text
    self.stSkillItemName = self:child("skillControl-SkillItemName")
    self.stMuscleConsume = self:child("skillControl-MuscleConsumeText")
    self.stSkillItemDesc = self:child("skillControl-SkillItemDec")
    self.stBuyPrice = self:child("skillControl-BuyPrice")

    

        --image
    self.siCurrencyImg = self:child("skillControl-CurrencyImg")
    self.siIsBuySkillImg = self:child("skillControl-IsBuySkillImg")
    
        --btn
    self.btnClose = self:child("skillControl-close")
    self.btnPreview = self:child("skillControl-PreviewBtn")
    self.btnBuySkill = self:child("skillControl-BuySkillBtn")
    self.btnAttackSkill = self:child("skillControl-tab_AttackSkillBtn")
    self.btnAttackSkill:SetSelected(true)
    self.btnDefenseSkill = self:child("skillControl-tab_DefenseSkillBt")
    self.btnDisplacementSkill = self:child("skillControl-tab_DisplacementSkillBtn")
    self.btnControlSkill = self:child("skillControl-tab_ControlSkillBtn")
    self.btnRecoverSkill = self:child("skillControl-tab_RecoverSkillBtn")

    --Equip分页
        --list
    self.llEquipPanel = self:child("skillControl-EquipPanel")
    -- self.llEquipPanel:SetVisible(false)

    self.llEquipSkillItemList = self:child("skillControl-equipSkillItemsView")
    self.gvEquipItemsView = GUIWindowManager.instance:CreateGUIWindow1("GridView", "skillControl-equipGridView")
    self.llEquipSkillItemList:AddChildWindow(self.gvEquipItemsView)
    self.gvEquipItemsView:SetArea({ 0, 0 }, { 0, 0 }, { 1, 0 }, { 1, 0 })
    self.gvEquipItemsView:InitConfig(16, 14, 2)

        --btn
    self.btnEquipSlot1 = self:child("skillControl-EquipSlot_1")
    self.btnEquipSlot2 = self:child("skillControl-EquipSlot_2")
    self.btnEquipSlot3 = self:child("skillControl-EquipSlot_3")
    self.btnEquipSlot4 = self:child("skillControl-EquipSlot_4")

    self.btnEquipAttackSkill = self:child("skillControl-tab_equipAttackSkillBtn")
    self.btnEquipAttackSkill:SetSelected(true)
    self.btnEquipDefenseSkill = self:child("skillControl-tab_equipDefenseSkillBt")
    self.btnEquipDisplacementSkill = self:child("skillControl-tab_equipDisplacementSkillBtn")
    self.btnEquipControlSkill = self:child("skillControl-tab_equipControlSkillBtn")
    self.btnEquipRecoverSkill = self:child("skillControl-tab_equipRecoverSkillBtn")
    

 
    self:initEvent()
    --放初始分页的技能组
    self:addSkillShopItem(skills.attack)
    self:openSkillStore()
end

function M:initEvent()
    --Store
    self:subscribe(self.btnSkillStorePanel, UIEvent.EventRadioStateChanged, function(status)
        if status:IsSelected() then
            self:openSkillStore()
        end
    end)

    self:subscribe(self.btnAttackSkill, UIEvent.EventRadioStateChanged, function(status)
        if status:IsSelected() then
            self:addSkillShopItem(skills.attack)
        end
    end)
    self:subscribe(self.btnDefenseSkill, UIEvent.EventRadioStateChanged, function(status)
        if status:IsSelected() then
            self:addSkillShopItem(skills.defense)
        end
    end)
    self:subscribe(self.btnDisplacementSkill, UIEvent.EventRadioStateChanged, function(status)
        if status:IsSelected() then
            self:addSkillShopItem(skills.buff)
        end
    end)
    self:subscribe(self.btnControlSkill, UIEvent.EventRadioStateChanged, function(status)
        if status:IsSelected() then
            self:addSkillShopItem(skills.Control)
        end
    end)
    self:subscribe(self.btnRecoverSkill, UIEvent.EventRadioStateChanged, function(status)
        if status:IsSelected() then
            self:addSkillShopItem(skills.cure)
        end
    end)


    self:subscribe(self.btnPreview, UIEvent.EventButtonClick, function()
        -- 技能展示
        -- print("=======onWatchAudio========" .. tostring(PreviewUrl))

        Interface.callAppDataFunction("onWatchAudio", {url = PreviewUrl})
    end)

    self:subscribe(self.btnBuySkill, UIEvent.EventButtonClick, function()
        -- 技能购买
        if not self:checkItemMoney() then
            return
        end 
        -- print("============self.itemId======".. tostring(self.itemId))
        Me:sendPacket({
            pid = "skillShopBuyItem",
            itemId = self.itemId,
            status = 1
        })
    end)

    --Equip
    self:subscribe(self.btnSkillEquipPanel, UIEvent.EventRadioStateChanged, function(status)
        if status:IsSelected() then
            self:openSkillEquip()
            self:upDataSkillEquipItems()
            self:selectSeatGivEquip(1,false)
        end
    end)


    self:subscribe(self.btnEquipSlot1, UIEvent.EventButtonClick, function()
        self:selectSeatGivEquip(1,true)
    end)
    self:subscribe(self.btnEquipSlot2, UIEvent.EventButtonClick, function()
        self:selectSeatGivEquip(2,true)
    end)
    self:subscribe(self.btnEquipSlot3, UIEvent.EventButtonClick, function()
        self:selectSeatGivEquip(3,true)
    end)
    self:subscribe(self.btnEquipSlot4, UIEvent.EventButtonClick, function()
        self:selectSeatGivEquip(4,true)
    end)

    self:subscribe(self.btnEquipAttackSkill, UIEvent.EventRadioStateChanged, function(status)
        if status:IsSelected() then
            equipPanelNum = 1
            self:upDataSkillEquipItems()
            -- self:selectSeatGivEquip(1,false)
        end
    end)
    self:subscribe(self.btnEquipDefenseSkill, UIEvent.EventRadioStateChanged, function(status)
        if status:IsSelected() then
            equipPanelNum = 2
            self:upDataSkillEquipItems()
            -- self:selectSeatGivEquip(1,false)
        end
    end)
    self:subscribe(self.btnEquipDisplacementSkill, UIEvent.EventRadioStateChanged, function(status)
        if status:IsSelected() then
            equipPanelNum = 3
            self:upDataSkillEquipItems()
            -- self:selectSeatGivEquip(1,false)
        end
    end)
    self:subscribe(self.btnEquipControlSkill, UIEvent.EventRadioStateChanged, function(status)
        if status:IsSelected() then
            equipPanelNum = 4
            self:upDataSkillEquipItems()
            -- self:selectSeatGivEquip(1,false)
        end
    end)
    self:subscribe(self.btnEquipRecoverSkill, UIEvent.EventRadioStateChanged, function(status)
        if status:IsSelected() then
            equipPanelNum = 5
            self:upDataSkillEquipItems()
            -- self:selectSeatGivEquip(1,false)
        end
    end)


    self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
        self.onHide()
    end)
    

    Lib.subscribeEvent(Event.EVENT_ITEM_SKILL_SHOP_UPDATE, function()
        -- print("---upDataSkillShopItems------")
        self:upDataSkillShopItems()
    end)

    Lib.subscribeEvent(Event.EVENT_ITEM_SKILL_EQUIP_UPDATE, function()
        -- print("---upDataSkillEquipItems------")
        self:selectSeatGivEquip(1,false)
    end)

end

function M:checkItemMoney()
    if self.itemId then
        local item = skillShopConfig:getItemByItemId(self.itemId)
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
end


function M:onHide()
    UI:closeWnd("skillControl")
end

function M:onShow(isShow)
    if isShow and self.isInitData then
        if not UI:isOpen(self) then
            UI:openWnd("skillControl")
            else
                self:onHide()
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

function M:openSkillStore()
    self.llStorePanel:SetVisible(true)
    self.llEquipPanel:SetVisible(false)
end

function M:openSkillEquip()
    self.llStorePanel:SetVisible(false)
    self.llEquipPanel:SetVisible(true)
end

function M:selectSkillInfo()
    local buyInfo = Me:getStudySkill()
    -- print("---upDataSkillShopItems------".. Lib.v2s(buyInfo))
    local isExist = false
    for key, value in pairs(buyInfo or {}) do
        if tostring(self.itemId) == key then
            isExist = true
        end
    end
    for key, value in pairs(self.Items) do
        if self.itemId == value.id then
            self.stSkillItemName:SetText(value.name)
            self.stMuscleConsume:SetText("  ".. value.muscle.."K  Muscle")
            self.stSkillItemDesc:SetText(value.desc)

            PreviewUrl = value.url
            print("---previewUrl------".. Lib.v2s(value))
            if PreviewUrl == "" then
                self.btnPreview:SetVisible(false)
            else
                self.btnPreview:SetVisible(true)   
            end

            if value.moneyType == 0 then
                self.siCurrencyImg:SetImage("set:diamond.json image:Diamond-icon2.png") 
            else
                self.siCurrencyImg:SetImage("set:skillstore.json image:power")
            end
            self.stBuyPrice:SetText(value.price)
            if isExist then
                self.btnBuySkill:SetVisible(false)
                self.siIsBuySkillImg:SetVisible(true)
            else
                self.btnBuySkill:SetVisible(true)
                self.siIsBuySkillImg:SetVisible(false)
            end
        end
    end

end

function M:addSkillShopItem(data)
    self.gvItemsGridView:RemoveAllItems()

    -- self:upDataSkillShopItems()

    local payCount =  0
    local isPayArr = {}
    local notPayArr = {}
    for _, value in pairs(data or {}) do
        if value.moneyType == 0 then
            payCount  = payCount + 1
            table.insert(isPayArr,value)
        else
            table.insert(notPayArr,value)
        end
    end

    local row = math.ceil(#data / 5) > payCount and  math.ceil(#data / 5) or payCount
    local ItemCount = row * 5 
    ItemCount = ItemCount < 20 and 20 or ItemCount

    local index = 1
    for i = 1, ItemCount do
        local skillItem = UIMgr:new_widget("itemSkillShopItem")
        local isPay = false
        if i % 5 == 0 then
            local PayId = 0
            if isPayArr[i/5] then --无技能item没有点击监听
                isPay = isPayArr[i/5].isPay
                PayId = isPayArr[i/5].id
                self:subscribe(skillItem, UIEvent.EventButtonClick, function()
                    self:resetShopChecked()
                    self.itemId = skillItem:invoke("onCheckClick")
                    self:selectSkillInfo()
                end)
            end
            skillItem:invoke("initItem",PayId,isPayArr[i/5],isPay)
        else
            local PayId = 0
            if notPayArr[index] then --无技能item没有点击监听
                isPay = notPayArr[index].isPay
                PayId = notPayArr[index].id
                self:subscribe(skillItem, UIEvent.EventButtonClick, function()
                    self:resetShopChecked()
                    self.itemId = skillItem:invoke("onCheckClick")
                    self:selectSkillInfo()
                end)
            end
            skillItem:invoke("initItem",PayId,notPayArr[index],isPay)
            index = index + 1
        end
        local initClick = 1
        if #notPayArr == 0 then
            initClick = 5   
        end
        if i == initClick then --刷新时默认选择第一个
            self.itemId = skillItem:invoke("onCheckClick")
            self:selectSkillInfo()
        end
        self.gvItemsGridView:AddItem(skillItem)

    end

    self.gvItemsGridView:ResetPos()
end 

function M:addSkillEquipItem(data)
    self.gvEquipItemsView:RemoveAllItems()
    -- self:upDataSkillShopItems()

    for _, value in pairs(data or {}) do
        local skillItem = UIMgr:new_widget("itemSkillEquipItem")

        skillItem:invoke("initItem",value)

        self.gvEquipItemsView:AddItem(skillItem)
    end
    self.gvEquipItemsView:ResetPos()
end 

function M:resetShopChecked()
    local count = self.gvItemsGridView:GetItemCount() - 1
    for i = 0, count do
        self.gvItemsGridView:GetItem(i):invoke("cancelCheckClick")
    end
end

function M:resetSkillEquipChecked()
    return EquipCheckedId
end

function M:resetEquipChecked(data)
    local StudyInfo = Me:getStudySkill()
    local EquipInfo = Me:getEquipSkill()

    for sId, sv in pairs(StudyInfo or {}) do
        for eId, ev in pairs(EquipInfo or {}) do
            if sId == eId then
                sv.status = ev.status
            end
        end
    end

    for _, dv in pairs(data or {}) do
        for sId, sv in pairs(StudyInfo or {}) do
            if tostring(dv.id) == sId then
                dv.status = sv.status
            end
        end
    end
    table.sort(data or {}, function(a, b)
        return a.status > b.status
    end)

    return data
end

function M:upDataSkillShopItems()
    self:selectSkillInfo()
end

function M:upDataSkillEquipItems()
    if equipPanelNum == 1 then
        equipPaneData = skills.attack
    elseif equipPanelNum == 2 then
        equipPaneData = skills.defense
    elseif equipPanelNum == 3 then
        equipPaneData = skills.buff
    elseif equipPanelNum == 4 then
        equipPaneData = skills.Control
    elseif equipPanelNum == 5 then
        equipPaneData = skills.cure
    end
    print("--------------------223 ".. tostring(equipPanelNum))
    equipPaneData= self:resetEquipChecked(equipPaneData)
    self:addSkillEquipItem(equipPaneData)
end

function M:initItemConfig()

    self.Items = Lib.copy(skillShopConfig:getItems())
    -- print("--!!!!skillShopConfig--initConfig----------- " .. Lib.v2s(self.Items))
    for _, config in pairs(self.Items) do
        if config.tabId == 1 then
            table.insert(skills.attack, config)
        elseif config.tabId == 2  then
            table.insert(skills.defense, config)
        elseif  config.tabId == 3 then
            table.insert(skills.buff, config)
        elseif  config.tabId == 4 then
            table.insert(skills.Control, config)
        elseif  config.tabId == 5 then
            table.insert(skills.cure, config)
        end
    end

    self.isInitData = true
end

function M:selectSeatGivEquip(id, isBtn)

    local EquipInfo = Me:getEquipSkill()
    -- print("---------EquipInfo--------------1 ".. Lib.v2s(EquipInfo))

    self:placeSkillIcon(EquipInfo)
    local counts = {}
    local isReset = false
    -- print("---------id--------------2 ".. tostring(#EquipInfo))

    if next(EquipInfo) then
        for _, value in pairs(EquipInfo or {}) do
            table.insert(counts, value.placeId)
            if value.placeId == id then
                isReset = true
                if isBtn then
                    return
                end
            end
        end

        table.sort(counts, function(a, b)
            return a < b
        end)
    end

    if isReset then
        id = 1
        for i = 1, #counts do
            if id == counts[i] then
                id = id + 1
            end
        end
    end

    self:resetSeatGivEquip(id)
end

function M:resetSeatGivEquip(id)
    for i = 1, 4 do
        if i == id then
            self:child(string.format("skillControl-equipChecked_%d", i)):SetVisible(true)
            EquipCheckedId = id
        else
            self:child(string.format("skillControl-equipChecked_%d", i)):SetVisible(false)
        end
    end
end

function M:placeSkillIcon(data)
    for i = 1, 4 do
        self:child(string.format("skillControl-equipIcon_%d", i)):SetImage()
    end
    for i = 1, 4 do
        for key, value in pairs(data or {}) do
            if value.placeId == i then
                self:child(string.format("skillControl-equipIcon_%d", i)):SetImage(value.icon)
                break
            end
        end
    end
end
