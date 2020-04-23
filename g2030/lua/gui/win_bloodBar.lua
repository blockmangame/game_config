---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2020/4/22 16:52
---
local WorldBossRewardConfig = T(Config, "WorldBossRewardConfig")
local LuaTimer = T(Lib, "LuaTimer") ---@type LuaTimer
local lastWin = nil
local timer = nil

local function getRewards(type)
    local rewards = {}
    if type == Define.BossType.WorldBoss then
        rewards = WorldBossRewardConfig:getRewardByHits(Me:getBossHits())
    end
    return rewards
end

function M:init()
    WinBase.init(self, "NinjaBloodBar.json", false)
    self:initWnd()
end

function M:initWnd()
    self.boss = {}
    self.bossType = ""
    self.rewards = {
        self:child("NinjaBloodBar-Reward1"),
        self:child("NinjaBloodBar-Reward2")
    }
    self.icon = self:child("NinjaBloodBar-Icon")
    self.pgsHp = self:child("NinjaBloodBar-Blood-Bar")
end

function M:updateReward()
    self:hideRewards()
    local rewards = getRewards(self.bossType)
    for i, v in pairs(rewards) do
        if i > #self.rewards then
            return
        end
        local icon = "set:ninja_blood_bar.json image:ic_" .. v.rewardType
        if v.rewardType == Define.RewardType.TeamStone then
            icon = icon .. "_" .. Me:getTeamId()
        end
        local num = v.rewardNum
        self:child("NinjaBloodBar-Reward" .. i .. "-Icon"):SetImage(icon)
        self:child("NinjaBloodBar-Reward" .. i .. "-Num"):SetText(tostring(BigInteger.Create(num)))
        self.rewards[i]:SetVisible(true)
    end
end

function M:hideRewards()
    for i, win in pairs(self.rewards) do
        win:SetVisible(false)
    end
end

function M:updateHp()
    local entity = World.CurWorld:getEntity(self.boss)
    if not entity then
        UI:closeWnd(self)
        return
    end
    self.pgsHp:SetProgress(entity:getCurHp() / entity:getMaxHp())
end

function M:onOpen(objID)
    local entity = World.CurWorld:getEntity(objID)
    if not entity then
        UI:closeWnd(self)
        return
    end
    self.boss = objID
    local icon = entity:cfg().icon
    self.bossType = entity:cfg().type
    if icon then
        self.icon:SetImage(icon)
    end
    self:update(Me.objID)
end

function M:update(from)
    if not self:isvisible() then
        return
    end
    self:updateHp()
    if from and from == Me.objID then
        self:updateReward()
        self:updateCombo()
    end
end

function M:updateCombo()
    local combo = Me:getCombo()
    if combo <= 0 then
        return
    end
    local desktop = GUISystem.instance:GetRootWindow()
    if lastWin then
        desktop:RemoveChildWindow1(lastWin)
        if timer then
            LuaTimer:cancel(timer)
        end
    end

    local number = combo .. "h"
    local beginOffsetPos = Lib.v3(0, 2, 0)
    local width = 50
    local height = 50
    local win = UILib.makeNumbersGrid("showComboUi", number, "combo_num")
    local len = string.len(tostring(number))
    win:SetArea({0, 0}, {0, 0}, {0, width * len}, {0, height})
    desktop:AddChildWindow(win)
    UILib.uiFollowObject(win, Me.objID, {offset = beginOffsetPos})
    local time = World.cfg.comboTime or 2
    lastWin = win
    timer = LuaTimer:schedule(function(objID)
        desktop:RemoveChildWindow1(win)
        local player = World.CurWorld:getEntity(objID)
        if player and player.isPlayer then
            player:clearCombo()
        end
    end, time * 1000, nil, Me.objID)
end