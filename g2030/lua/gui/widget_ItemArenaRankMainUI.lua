
---
---忍者项目主界面竞技场排名item
---zhuyayi 20200423
---
local widget_base = require "ui.widget.widget_base"
local M = Lib.derive(widget_base)

function M:init()
    widget_base.init(self, "ArenaRankMainUIItem.json")
    self.lytBg = self:child("ArenaRankMainUIItem-Bg")
    self.txtRank = self:child("ArenaRankMainUIItem-Rank")
                            --ArenaRankMainUIItem-Rank
    self.txtName = self:child("ArenaRankMainUIItem-Name")
    self.txtKill = self:child("ArenaRankMainUIItem-Kill")
    self.txtMuscle = self:child("ArenaRankMainUIItem-Muscle")
end

function M:onClickItem(id)
end

function M:setItemData(rank, name, kill)
  --  self.lytBg:SetImage("set:ninja_arena.json image:block_stage"..stageId.."_4")
    self.txtRank:SetText(rank)
    self.txtName:SetText(name)
    self.txtKill:SetText(kill)
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