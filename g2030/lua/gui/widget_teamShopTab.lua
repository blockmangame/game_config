---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by JY-032.
--- DateTime: 2020/3/30 15:26
---
local widget_base = require "ui.widget.widget_base"
local M = Lib.derive(widget_base)

---initTab类型
local TabTeamKind = {
    TeamSkill = 1, --技能
    TeamSkin = 2, --阵营皮肤
}
--选中状态
local TabSelectStatus = {
    NotSelect = 1,
    Select = 2,
}

function M:init()
    widget_base.init(self, "CampStoreTab.json")

    self.tabId = 0
    self.ivTabsBg = self:child("CampStoreTab-Bg")
    self.ivTabsIcon = self:child("CampStoreTab-Icon")
    self.tvTabsText = self:child("CampStoreTab-Name")
    --self.tvTabsText = self:child("CampStoreTab-Name_c")
end

function M:initTab(TabId, Kind, Bg, Icon, Text)
    self.tabId = TabId
    self.kind = Kind
    --self.ivTabsBg:SetImage(Bg)
    self.ivTabsIcon:SetImage(Icon)
    self.tvTabsText:SetText(Lang:toText(Text))
end

function M:changeSelectStatus(Bg, SelectMode)
    self.ivTabsIcon:SetImage(Bg)
    self.selectMode = SelectMode
end

function M:onCheckClick(id, type)
    if self.tabId == id then
        self.selectMode = TabSelectStatus.Select
        if type == TabTeamKind.TeamSkill then
            self.ivTabsIcon:SetImage("set:camp_store.json image:tag_skill_selected")
        elseif type == TabTeamKind.TeamSkin then
            self.ivTabsIcon:SetImage("set:camp_store.json image:tag_skin_selected")
        end
    else
        self.selectMode = TabSelectStatus.NotSelect
        if type == TabTeamKind.TeamSkill then
            self.ivTabsIcon:SetImage("set:camp_store.json image:tag_skin_unselected")
        elseif type == TabTeamKind.TeamSkin then
            self.ivTabsIcon:SetImage("set:camp_store.json image:tag_skill_unselected")
        end
    end
end

function M:onInvoke(key, ...)
    local fn = M[key]
    assert(type(fn) == "function", key)
    return fn(self, ...)
end

return M
