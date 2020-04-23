---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by wangpq.
--- DateTime: 2020/3/26 19:42
---
local Handlers = T(Trigger, "Handlers")

function Handlers.GAME_REWAIT(context)
    --TODO
end

function Handlers.ENTITY_BUFF_ADD(context)
    --{entity = self, cfg = buff.cfg}
    --Lib.log("Handlers.ENTITY_BUFF_ADD " .. Lib.inspect(context.cfg, { depth = 1 }))
    --Lib.log(Lib.inspect(context.entity.EntityProp, { depth = 1 }))
end

function Handlers.SKILL_CAST(context)
    --print("Handlers.SKILL_CAST " .. Lib.inspect(context, { depth = 1 }))
end

function Handlers.REGION_ENTER(context)
    --{obj1=entity, region=self, map=self.map, inRegionKey = self.key}

    if not context.obj1.isPlayer then
        return
    end

    Lib.emitEvent("EVENT_REGION_ENTER",
            {
                player = context.obj1,
                inRegionKey = context.inRegionKey,
                regionCfg = context.region.cfg,
            })

    --Lib.log(string.format("Handlers.REGION_ENTER objID:%s region:%s inRegionKey:%s", tostring(context.obj1.objID),
    --        Lib.inspect(context.region.cfg, { depth = 1, }), tostring(context.inRegionKey)))
end

function Handlers.REGION_LEAVE(context)
    --{obj1=entity, region=self, map=self.map, inRegionKey = self.key}

    if not context.obj1.isPlayer then
        return
    end

    Lib.emitEvent("EVENT_REGION_LEAVE",
            {
                player = context.obj1,
                inRegionKey = context.inRegionKey,
                regionCfg = context.region.cfg,
            })

    --Lib.log(string.format("Handlers.REGION_LEAVE objID:%s region:%s inRegionKey:%s", tostring(context.obj1.objID),
    --        Lib.inspect(context.region.cfg, { depth = 1, }), tostring(context.inRegionKey)))
end
---
---竞技场模式时的积分算法
---非竞技场玩家死亡会返回false
---
local function arenaScoreCalc(killer,killed)
    if not killer:IsArenaMode() or not killed:IsArenaMode() then
        return false
    end
    killer:addArenaScore(killed:getCurLevel()*10)--TODO 竞技场积分公式 
    return true
end
function Handlers.ENTITY_DIE(context)
    local target = context.obj1
    local from = context.obj2
    if not target or not from  then
        return
    end
    if not target.isPlayer or not from.isPlayer then
        return
    end
    if arenaScoreCalc(from,target) then
        return
    end

    if target:getTeamId() ~= from:getTeamId() and
            target:getTeamId() > Define.Team.Neutrality and
            from:getTeamId() > Define.Team.Neutrality then
        from:addTeamKills()
        --上报阵营击杀、阵营材料奖励
    end
   
end


function Handlers.ENTITY_REBIRTH(context)
    local player = context.obj1
    if not player  then
        return
    end
    if not player.isPlayer then
        return
    end
    player:resetHp()
    player:setMapPos(player.map,World.cfg.initPos)
end

function Handlers.ENTITY_DAMAGE(context)
    local beHurt = context.obj1
    local from = context.obj2
    if not beHurt.isPlayer then
        local setting = beHurt:cfg()
        if setting and setting.type == "WorldBoss" then
            from:addBossHits(1)
            WorldServer.BroadcastPacket({
                pid = "UpdateBossBlood",
                from = from.objID
            })
        end
    end
end

