---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by bell.
--- DateTime: 2020/3/21 22:39
---
require "script_client.entity.entity"
require "script_client.entity.entity_event"

require "script_client.ui.ui_schedule"
require "script_client.world.region"
require "script_client.world.region.region_block"

require "script_client.other.scene_indicator"
require "script_client.other.recharge_cells_mgr"
require "script_client.other.teleport_mgr"

require "script_client.player.player"
require "script_client.player.player_event"
require "script_client.player.player_packet"
require "script_client.player.player_control"
require "script_client.player.player_pet_manager"

require "script_client.skill.base"
require "script_client.skill.skill_normal_atk"
require "script_client.skill.skill_addExp"
require "script_client.skill.scene_skill"
require "script_client.skill.recharge_skill"
require "script_client.skill.roundup_skill"
require "script_client.skill.control_skill"

local main = {}

function main:init()
    self:initLog()

    Lib.log("main:init")

    self:loadConfig()
end

function main:initLog()
    Lib.setDebugLog(EngineVersionSetting:canUseCmd())
end

function main:loadConfig()
    local JumpConfig = T(Config, "JumpConfig")
    JumpConfig:init()

    local RegionConfig = T(Config, "RegionConfig")
    RegionConfig:init(Lib.readGameCsv("config/region.csv"))

    local teamShopConfig = T(Config, "teamShopConfig")
    teamShopConfig:initConfig()

    local skillShopConfig = T(Config, "skillShopConfig")
    skillShopConfig:initConfig()

    local rechargeAwardConfig = T(Config, "rechargeAwardConfig")
    rechargeAwardConfig:initConfig()
end

main:init()