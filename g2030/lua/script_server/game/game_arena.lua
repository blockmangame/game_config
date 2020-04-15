---
---竞技场管理 20200414 zhuyayi
---
---state:
---CLOSE 尚未开启
---OPEN

local ArenaMgr  = T(Game, "ArenaMgr")
function ArenaMgr:init()
    self.state = "CLOSE"
    Lib.subscribeEvent(Event.EVENT_LEVEL_CHANGE, function ()
        if self.state == "CLOSE" and Me:getCurLevel()>1 then
            self.state = "OPEN"
        end
    end)
end
function ArenaMgr:checkIsOpen()
end
function ArenaMgr:enterArena()
    local map = World.CurWorld:createDynamicMap(stageCfg.map, true)
    Me:setMapPos(map, map.cfg.birthPos or stageCfg.birthPos, stageCfg.ry, stageCfg.yp)
end

ArenaMgr:init()
return ArenaMgr