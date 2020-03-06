function M:init()
    WinBase.init(self, "FamilyAlbum.json", true)

    self.itemPool = {}

    self:initWnd()

end

function M:onOpen()

end

function M:onClose()
    self.selectItemIndex = nil
end

function M:initWnd()
    self:child("FamilyAlbum-Title-Text"):SetText(Lang:toText("ui_family_album"))
    self:child("FamilyAlbum-DeleteBtn"):SetText(Lang:toText("ui_delete"))
    self:child("FamilyAlbum-CheckBtn"):SetText(Lang:toText("ui_check"))

    self:subscribe(self:child("FamilyAlbum-CloseBtn"), UIEvent.EventButtonClick, function()
        UI:closeWnd(self)
    end)

    self:subscribe(self:child("FamilyAlbum-DeleteBtn"), UIEvent.EventButtonClick, function()
        self:onDeleteItem()
    end)

    self:subscribe(self:child("FamilyAlbum-CheckBtn"), UIEvent.EventButtonClick, function()
        self:onCheckItem()
    end)

    Lib.subscribeEvent(Event.EVENT_UPDATE_UI_DATA, function(UIName)
        if UIName == "win_familyAlbum" then
            self:updateItemsGrid()
        end
    end)

    Lib.subscribeEvent(Event.EVENT_UPDATE_UI_DATA, function(UIName)
        if UIName == "win_familyAlbumRename" then
            self:updateItem()
        end
    end)

    self:initCheckLargerView()
    self:initItemsGrid()
    self:updateItemsGrid()
end

function M:initItemsGrid()
    self.gvItems = self:child("FamilyAlbum-Items")
    self.gvItems:InitConfig(2, 2, 3)
end

function M:initCheckLargerView()
    self.checkLargerView = GUIWindowManager.instance:LoadWindowFromJSON("CheckLargerView.json")
    self.checkLargerView:SetArea({0, 0}, {0, 0}, {0.85, 0}, {0.85, 0})
    self.checkLargerView:SetVisible(false)
    self:subscribe(self.checkLargerView:child("CheckLargerView-Back"), UIEvent.EventButtonClick, function()
        self:onBackFamilyAlbum()
    end)
    self:subscribe(self.checkLargerView:child("CheckLargerView-Close"), UIEvent.EventWindowTouchUp, function()
        self:onBackFamilyAlbum()
    end)
    self._root:AddChildWindow(self.checkLargerView)
end

function M:updateItemsGrid()
    local gvItems = self.gvItems
    gvItems:ResetPos()
    gvItems:RemoveAllItems()

    self.itemPool = {}
    self.selectItemIndex = nil

    local data = UI:getRemoterData("win_familyAlbum") or {}
    local x = (gvItems:GetPixelSize().x - 2 * 2) / 3
    local y = 205 * x / 301

    for i, v in ipairs(data) do
        local itemView = GUIWindowManager.instance:LoadWindowFromJSON("FamilyAlbumItem.json")
        itemView:SetArea({0, 0}, {0, 0}, {0, x}, {0, y})
        self:setItem(v, itemView, i)
        gvItems:AddItem(itemView)
        if not self.selectItemIndex and i == 1 then
            self.selectItemIndex = i
        end
    end
    if self.selectItemIndex then
        self:onClickItem(self.selectItemIndex)
    end
end

function M:setItem(itemDate, itemView, index)
    self.itemPool[index] = {data = itemDate, view = itemView, index = index}

    itemView:child("FamilyAlbumItem-Img"):SetImageUrl(itemDate.image)
    itemView:child("FamilyAlbumItem-Name"):SetText(Lang:toText(itemDate.name))
    local inputBox = itemView:child("FamilyAlbumItem-Input-Box")
    inputBox:SetTextVertAlign(1)
    inputBox:SetTextHorzAlign(1)

    self:subscribe(itemView, UIEvent.EventWindowTouchUp, function()
        self:onClickItem(index)
    end)

    self:subscribe(inputBox, UIEvent.EventEditTextInput, function()
        self:onClickChangeItemName(index, inputBox)
    end)
end

function M:updateItem()
    local data = UI:getRemoterData("win_familyAlbumRename") or {}
    if data then
        local item = self.itemPool[data.index]
        if item then
            item.view:child("FamilyAlbumItem-Name"):SetText(data.name)
            item.data.name = data.name
        end
    end
end

function M:onClickItem(index)
    self.selectItemIndex = index
    for _, v in pairs(self.itemPool) do
        v.view:SetBackImage(index == v.index and "set:family_album.json image:item_bg_choose" or "set:family_album.json image:item_bg")
    end
end

function M:onClickChangeItemName(index, inputBox)
    local item = self.itemPool[index]
    if item then
        local editText = inputBox:GetPropertyString("Text","")
        inputBox:SetProperty("Text","")
        if editText == "" or editText == item.data.name then
            return
        end
        Me:sendTrigger(Me, "RENAME_FAMILY_ALBUM", Me, nil, { index = index, name = editText })
    end
end

function M:onDeleteItem()
    if self.selectItemIndex then
        Me:sendTrigger(Me, "DELETE_FAMILY_ALBUM", Me, nil, { index = self.selectItemIndex })
    end
end

function M:onCheckItem()
    if self.selectItemIndex then
        local item = self.itemPool[self.selectItemIndex]
        if item then
            self.checkLargerView:child("CheckLargerView-Image"):SetImageUrl(item.data.image)
            self.checkLargerView:SetVisible(true)
        end
    end
end

function M:onBackFamilyAlbum()
    self.checkLargerView:SetVisible(false)
end