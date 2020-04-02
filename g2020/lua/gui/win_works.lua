---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by luo.
--- DateTime: 2019/11/8 17:01
---
---
local TabView = {
    PERSON = 1,
    APPRECIATE = 2,
    EXCELLENT = 3,
    COLLECT = 4,
}

local ViewData = {
    PERSON = "works_person",
    APPRECIATE = "works_appreciate",
    EXCELLENT = "works_excellent",
    COLLECT = "works_collect",
}

function M:init()
    WinBase.init(self, "Works.json", true)
    self.maxWorksArchiveNum = World.cfg.maxWorksArchiveNum or 27
    self:initMain()
end

function M:onOpen()
    self.viewData[TabView.EXCELLENT] = UI:getRemoterData(ViewData.EXCELLENT) or {}
    self.viewData[TabView.APPRECIATE] = UI:getRemoterData(ViewData.APPRECIATE) or {}
    if self.curTabView then
        self:updateLike(self.curTabView)
    end
end

function M:initMain()
    self.tabs = {}
    self.tabsIcon = {}
    self.viewData = {}
    local tabName = {}

    tabName[TabView.PERSON] = "works_person"
    tabName[TabView.APPRECIATE] = "works_appreciate"
    tabName[TabView.EXCELLENT] = "works_excellent"
    tabName[TabView.COLLECT] = "works_collect"

    self.tabs[TabView.PERSON] =  self:child("Works-Tab1")
    self.tabs[TabView.APPRECIATE] =  self:child("Works-Tab2")
    self.tabs[TabView.EXCELLENT] =  self:child("Works-Tab3")
    self.tabs[TabView.COLLECT] =  self:child("Works-Tab4")

    self.tabsIcon[TabView.PERSON] =  self:child("Works-Tab1-Icon")
    self.tabsIcon[TabView.APPRECIATE] =  self:child("Works-Tab2-Icon")
    self.tabsIcon[TabView.EXCELLENT] =  self:child("Works-Tab3-Icon")
    self.tabsIcon[TabView.COLLECT] =  self:child("Works-Tab4-Icon")

    self:child("Works-Title-Text"):SetText(Lang:getMessage("works"))

    for k, _ in pairs(self.tabs) do
        self.tabsIcon[k]:SetTextHorzAlign(0)
        self.tabsIcon[k]:SetText(Lang:getMessage(tabName[k]))
        self:subscribe(self.tabsIcon[k], UIEvent.EventCheckStateChanged, function()
            self:onCheckChanged(k)
        end)
        self:subscribe(self.tabs[k], UIEvent.EventRadioStateChanged, function()
            self:onRadioChanged(k)
        end)
    end

    self.curTabView = TabView.PERSON
    self.tabs[TabView.PERSON]:SetSelected(true)

    self:subscribe(self:child("Works-Close"), UIEvent.EventButtonClick, function()
        UI:closeWnd(self)
    end)

    Lib.subscribeEvent(Event.EVENT_UPDATE_UI_DATA, function (uiName)
        if uiName == ViewData.PERSON then
            self:loadWorks()
            return
        end

        if uiName == ViewData.COLLECT then
            self:loadCollectWorks()
            return
        end

        for k, v in pairs(ViewData)  do
            if v == uiName then
                self.viewData[k] = UI:getRemoterData(v)
                self:updateLike(k)
                break
            end
        end
    end)

    if self.rows == nil or self.columns == nil  then
        local config = Lib.readGameJson("palette_config.json").Sketchpad
        self.rows =  config.rows
        self.columns =  config.columns
    end

    self:loadWorks()
    self:loadCollectWorks()
end

function M:onRadioChanged(viewId)
    self.tabsIcon[viewId]:SetChecked(self.tabs[viewId]:IsSelected())
    if self.tabs[viewId]:IsSelected() then
        self:child("Works-Items"):ResetPos()
        self.curTabView = viewId
        self:initItems()
        if self.curTabView == TabView.COLLECT then
            self:loadCollectWorks()
        end
    end
end

function M:onCheckChanged(viewId)
    self.tabsIcon[viewId]:SetTextColor(self.tabsIcon[viewId]:GetChecked() and { 1, 1, 1, 1} or {75/255, 198/255, 208/255, 1})
end

function M:onUpdate(tabView)
    if (tabView == self.curTabView) and UI:isOpen(self) then
        self:initItems()
    end
end

function M:initItems()
    self.gvList = self:child("Works-Items")
    self.gvList:InitConfig(24, 3, 3)
    self.gvList:RemoveAllItems()
    self.gvList:SetAutoColumnCount(false)

    local itemX = (self.gvList:GetPixelSize().x - 24 * 2) / 3
    local itemY = (203 * itemX) / 271

    local data = self.viewData[self.curTabView] or {}

    local itemX2 = itemX / self.gvList:GetPixelSize().x
    local itemY2 = itemY / self.gvList:GetPixelSize().y

    for _, v in ipairs(data) do
        local itemView = GUIWindowManager.instance:LoadWindowFromJSON("WorksItem.json")
        itemView:SetArea({ 0, 0}, { 0, 0 }, { itemX2, 0 }, { itemY2, 0 })
        self.gvList:AddItem(itemView)
        self:itemUpdate(itemView, v)
    end

    if self.curTabView == TabView.PERSON then
        local lackNum = Me:getWorksArchiveNum() - #data
        if lackNum > 0 then
            for _ = 1, lackNum do
                local itemView = GUIWindowManager.instance:LoadWindowFromJSON("WorksItemEmpty.json")
                itemView:SetArea({ 0, 0}, { 0, 0 }, { itemX2, 0 }, { itemY2, 0 })
                itemView:SetBackImage("set:win_works.json image:empty")
                self:subscribe(itemView, UIEvent.EventWindowTouchUp, function()
                    UI:openWnd("palette")
                end)
                self.gvList:AddItem(itemView)
            end
        end

        if self.maxWorksArchiveNum > Me:getWorksArchiveNum() then
            local itemView = GUIWindowManager.instance:LoadWindowFromJSON("WorksItemEmpty.json")
            itemView:SetArea({ 0, 0}, { 0, 0 }, { itemX2, 0 }, { itemY2, 0 })
            itemView:SetBackImage("set:win_works.json image:lock")
            self:subscribe(itemView, UIEvent.EventWindowTouchUp, function()
                Me:sendTrigger(Me, "SHOW_BYU_WORKS_ARCHIVE_UI_2", Me)
            end)
            self.gvList:AddItem(itemView)
        end
    end

end

function M:itemUpdate(view, info)
    local panelWnd = view:child("WorksItem-Panel")
    UI:setViewTexture(info.picUrl, panelWnd)
    view:child("WorksItem-Praise-Num"):SetTextHorzAlign(0)
    view:child("WorksItem-Name"):SetText(info.nickName or "")

    view:child("WorksItem-Praise-Num"):SetText(info.praiseNumber or 0)
    view:child("WorksItem-Like"):SetVisible(self.curTabView ~= TabView.PERSON and Me.platformUserId ~= info.userId)
    view:child("WorksItem-Comment"):SetVisible(self.curTabView ~= TabView.PERSON)
    view:child("WorksItem-Show"):SetVisible(self.curTabView == TabView.PERSON and info.isPublish ~= 1)
    view:child("WorksItem-Delete"):SetVisible(self.curTabView == TabView.PERSON or self.curTabView == TabView.COLLECT)
    view:child("WorksItem-Like"):SetCheckedNoEvent(info.isPraise)

    self:unsubscribe(view:child("WorksItem-Comment"), UIEvent.EventButtonClick)
    self:unsubscribe(view:child("WorksItem-Delete"), UIEvent.EventButtonClick)
    self:unsubscribe(view:child("WorksItem-Like"), UIEvent.EventCheckStateChanged)

    view:child("WorksItem-Like"):SetNormalImage(self.curTabView == TabView.COLLECT and "set:win_works.json image:delete" or "set:win_works.json image:praise_nor")
    view:child("WorksItem-Like"):SetPushedImage(self.curTabView == TabView.COLLECT and "set:win_works.json image:delete" or "set:win_works.json image:praise_pre")

    local x = panelWnd:GetPixelSize().x
    local y = panelWnd:GetPixelSize().y

    if (x/y) < (self.rows / self.columns) then
        y = x / self.rows * self.columns
    else
        x = y * self.rows / self.columns
    end

    panelWnd:SetArea( { 0, 0 }, { 0, 9 }, { 0, x }, { 0, y})

    self:subscribe(view:child("WorksItem-Like"), UIEvent.EventCheckStateChanged, function(itemView)
        itemView:SetEnabled(false)
        self:onClickLike(info)
    end)

    self:subscribe(view:child("WorksItem-Comment"), UIEvent.EventButtonClick, function()
        self:onClickComment(info)
    end)

    self:subscribe(view:child("WorksItem-Delete"), UIEvent.EventButtonClick, function(itemView)
        itemView:SetEnabled(false)
        self:onClickDelete(info)
    end)

    self:subscribe(view:child("WorksItem-Panel"), UIEvent.EventWindowClick, function()
        self:onClickPreview(info)
    end)

    self:subscribe(view:child("WorksItem-Show"), UIEvent.EventButtonClick, function(itemView)
        itemView:SetEnabled(false)
        Me:timer(30, function ()
            itemView:SetEnabled(true)
            return false
        end)
        self:onClickPublish(info)
    end)

end

function M:onClickPublish(info)
    Me:sendTrigger(Me, "SHOW_PUBLISH_WORKS_UI",   Me , nil, {worksId = info.graffitiId})
end

function M:onClickComment(info)
    UI:openWnd("msgBoard", info.graffitiId or 1)
end

function M:onClickPreview(info)
    UI:openWnd("worksPreview", info)
end

function M:onClickDelete(info)
    AsyncProcess.DeleteWorks(info.graffitiId, function (response)
        if info.isPraise then
            self:loadCollectWorks()
        end

        if response.code == 1 then
            self:loadWorks()
        end
    end)
end

function M:onClickLike(info)
    AsyncProcess.PraiseWorks(info.graffitiId, function (response)
        if response.code == 1 then
            self:praise(not info.isPraise, info.graffitiId)
            self:loadCollectWorks()
        end
    end)
end

function M:loadWorks()
    AsyncProcess.LoadWorks(function (response)
        local data = response.code == 1 and response.data or {}
        self.viewData[TabView.PERSON] = data
        self:updateLike(TabView.PERSON)
    end)
end

function M:loadCollectWorks()
    AsyncProcess.LoadCollectWorks(function (response)
        self.viewData[TabView.COLLECT] = response.code == 1 and response.data or {}
        self:updateLike(TabView.COLLECT)
        self:updateLike(TabView.EXCELLENT)
        self:updateLike(TabView.APPRECIATE)
    end)
end

function M:praise(isPraise, worksId)
    for _, tab in pairs(TabView)  do
        for _, v in pairs(self.viewData[tab] or {}) do
            if v.graffitiId == worksId then
                if isPraise then
                    v.praiseNumber = v.praiseNumber + 1
                    v.isPraise = true
                else
                    v.praiseNumber = v.praiseNumber - 1
                    v.isPraise = false
                end
            end
        end
    end
end

function M:updateLike(tabView)
    if tabView == TabView.COLLECT then
        for _, v in pairs(self.viewData[TabView.COLLECT] or {}) do
            v.isPraise = true
        end
    else
        for _, v in pairs(self.viewData[tabView] or {}) do
            local isPraise = false
            for _, v2 in pairs(self.viewData[TabView.COLLECT] or {}) do
                if v.graffitiId == v2.graffitiId then
                    isPraise = true
                    v.praiseNumber = v2.praiseNumber
                    break
                end
            end
            v.isPraise = isPraise
        end
    end


    self:onUpdate(tabView)
end

return M