---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by bell.
--- DateTime: 2020/3/21 22:39
---
Lib.declare("RegionManager", {})
Lib.declare("RegionSell", {})
Lib.declare("RegionShop", {})
Lib.declare("RegionBlock", {})

require "script_server.entity.entity"
require "script_server.entity.entity_event"
require "script_server.async_process.async_process"
require "script_server.game.game"
require "script_server.game.game_team"
require "script_server.game.game_arena"
require "script_server.game.process_manager"
require "script_server.game.game_activity"

require "script_server.player.player"
require "script_server.player.player_event"
require "script_server.player.player_packet"
require "script_server.player.player_pet_manager"

require "script_server.shop.itemshop_manager"
require "script_server.shop.payshop_manager"

require "script_server.world.region.region_sell"
require "script_server.world.region.region_shop"
require "script_server.world.region.region_block"
require "script_server.world.region"
require "script_server.world.region_manager"

require "script_server.skill.skill_normal_atk"
require "script_server.skill.skill_addExp"
require "script_server.skill.multistage"
require "script_server.skill.scene_skill"
require "script_server.skill.recharge_skill"
require "script_server.skill.roundup_skill"
require "script_server.skill.control_skill"
require "script_server.trigger_handlers"

require "script_server.actions_custom"
require "script_server.actions_common"
require "script_server.reward.reward_manager"

local main = {}

function main:init()
    self:initLog()

    Lib.log("main:init")

    self:loadConfig()

    ---@type RegionManager
    RegionManager:init()
end

function main:initLog()
    Lib.setDebugLog(EngineVersionSetting:canUseCmd())
end

function main:loadConfig()
    local teamShopConfig = T(Config, "teamShopConfig")
    teamShopConfig:initConfig()

    local skillShopConfig = T(Config, "skillShopConfig")
    skillShopConfig:initConfig()

    local RegionConfig = T(Config, "RegionConfig")
    RegionConfig:init(Lib.readGameCsv("config/region.csv"))
end

main:init()