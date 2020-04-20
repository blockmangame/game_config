---
---忍者项目竞技场排名item
---zhuyayi 20200420
---
local widget_base = require "ui.widget.widget_base"
local M = Lib.derive(widget_base)

function M:init()
    widget_base.init(self, "NinjaArenaItem.json")

    self.lytBg = self:child("NinjaArenaItem")
    self.txtRank = self:child("NinjaArenaItem-Rank")
    self.txtName = self:child("NinjaArenaItem-Name")
    self.txtKill = self:child("NinjaArenaItem-Kill")
    self.txtScore = self:child("NinjaArenaItem-Score")
    self.txtLevel = self:child("NinjaArenaItem-Level")
end

function M:onClickItem(id)
end

function M:setItemData(stageId, rank, name, kill,score,level)
    self.lytBg:SetBackImage("set:ninja_arena.json image:block_stage"..stageId.."_4")
    self.txtRank:SetText(rank)
    self.txtName:SetText(name)
    self.txtKill:SetText(kill)
    self.txtScore:SetText(score)
    self.txtLevel:SetText(level)
end

function M:initItem(index)
    self.index = index
end

function M:onInvoke(key, ...)
    local fn = M[key]
    assert(type(fn) == "function", key)
    return fn(self, ...)
end

return M