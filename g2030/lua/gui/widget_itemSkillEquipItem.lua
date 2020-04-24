--- Created by lxm.

local widget_base = require "ui.widget.widget_base"
local M = Lib.derive(widget_base)


function M:init()
     widget_base.init(self, "skillEquipItem.json")
    self:initWnd()
end

function M:initWnd()
    self.stSkillName = self:child("skillEquipItem-SkillName")
    self.sitSkillIcon = self:child("skillEquipItem-SkillImg")

    self.btnEquip = self:child("skillEquipItem-equipBtn")
    self.btnUnEquip = self:child("skillEquipItem-unEquipBtn")
    self.btnNotLearn = self:child("skillEquipItem-notLearnBtn")
 

    self:subscribe(self.btnEquip, UIEvent.EventButtonClick, function()
        self:onEquipBtnClick()
    end)
    self:subscribe(self.btnUnEquip, UIEvent.EventButtonClick, function()
        self:onUnEquipBtnClick()
    end)
    -- self:subscribe(self.btnNotLearn, UIEvent.EventButtonClick, function()

    -- end)

end

function M:initItem(item)
    self.itemId = item.id
    self.stSkillName:SetText(Lang:toText(item.name))
    self.sitSkillIcon:SetImage(item.icon)
    -- print("-------initItem--------"..tostring(item.status))
    if item.status == Define.SkillStatus.NoStudy then
        self.btnEquip:SetVisible(false)
        self.btnUnEquip:SetVisible(false)
        self.btnNotLearn:SetVisible(true)
    elseif item.status == Define.SkillStatus.Study then
        self.btnEquip:SetVisible(true)
        self.btnUnEquip:SetVisible(false)
        self.btnNotLearn:SetVisible(false)
    elseif item.status == Define.SkillStatus.Equip then
        self.btnEquip:SetVisible(false)
        self.btnUnEquip:SetVisible(true)
        self.btnNotLearn:SetVisible(false)
    end
end

function M:upDataSKillPlace(placeId)
    -- print("-------initItem--------111 "..tostring(placeId))
    self.placeId = placeId
end

function M:onEquipBtnClick()
    local EquipInfo = Me:getEquipSkill()
    local count = 0
    for k,v in pairs(EquipInfo) do
        count = count + 1
    end
    if count >= 4 then return end
    self.placeId = UI:getWnd("skillControl"):resetSkillEquipChecked()

    Me:sendPacket({
        pid = "skillShopBuyItem",
        itemId = self.itemId,
        status = 2,
        placeId = self.placeId
    })

end

function M:onUnEquipBtnClick()
    -- self.btnEquip:SetVisible(true)
    -- self.btnUnEquip:SetVisible(false)
    self.placeId = UI:getWnd("skillControl"):resetSkillEquipChecked()

    Me:sendPacket({
        pid = "skillShopBuyItem",
        itemId = self.itemId,
        status = 3,
        placeId = self.placeId
    })

end

function M:onInvoke(key, ...)
    local fn = M[key]
    assert(type(fn) == "function", key)
    return fn(self, ...)
end




return M
