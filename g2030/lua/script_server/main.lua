---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by bell.
--- DateTime: 2020/3/21 22:39
---
require "script_server.entity.entity"
require "script_server.player.player"
require "script_server.player.player_event"
require "script_server.trigger_handlers"
require "script_server.skill.skill_normal_atk"
require "script_server.skill.skill_addExp"
require "script_server.skill.multistage"
require "script_server.skill.timeLine"

local main = {}

function main:init()
    self:initLog()

    Lib.log("main:init")

    --TODO
end

function main:initLog()
    Lib.setDebugLog(EngineVersionSetting:canUseCmd())
end

main:init()