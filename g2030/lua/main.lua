---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by bell.
--- DateTime: 2020/3/20 22:52
---
require "script_common.util.logutil"
require "script_common.event_define"
require "script_common.lib"
require "script_common.ninjalegends_define"
require "script_common.trigger"
require "script_common.entity"
require "script_common.config.jumpConfig"
require "common.gm"

if World.isClient then
    require "script_client.main"
else
    require "script_server.main"
end