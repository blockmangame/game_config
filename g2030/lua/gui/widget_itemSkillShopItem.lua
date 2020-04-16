--- Created by lxm.

local widget_base = require "ui.widget.widget_base"
local M = Lib.derive(widget_base)


function M:init()
     widget_base.init(self, "skillShopItem.json")
    self:initWnd()
end

function M:initWnd()

    self.siBackground = self:child("skillShopItem-background")
    self.siSkillShopIcon = self:child("skillShopItem-icon")
    self.siSkillShopChecked = self:child("skillShopItem-checked")
    self.siSkillShopChecked:SetVisible(false)

    -- self:subscribe(self.btnSkillShopItem, UIEvent.EventRadioStateChanged, function()
    --     print("==========EventRadioStateChanged========---")

    --     UI:getWnd("skillControl"):resetShopChecked(self.itemId)
    --     self:onCheckClick()
    -- end)
end

function M:initItem(id,item,isPay)

    self.itemId = id

    if isPay then
        -- print("==========isPay========---")
        self.siBackground:SetImage("set:skillstore.json image:pay_skill_item_back")
    else
        -- print("==========not isPay========---")
        self.siBackground:SetImage("set:skillstore.json image:general_skill_item_back")
    end

    if item then
        self.siSkillShopIcon:SetImage(item.icon)
    else
        self.siSkillShopIcon:SetImage("")
    end
    
end

function M:onCheckClick()
    self.siSkillShopChecked:SetVisible(true)
    return self.itemId
end

function M:cancelCheckClick()
    self.siSkillShopChecked:SetVisible(false)
end


function M:onInvoke(key, ...)
    local fn = M[key]
    assert(type(fn) == "function", key)
    return fn(self, ...)
end




return M
