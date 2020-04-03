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
    print("Handlers.SKILL_CAST " .. Lib.inspect(context, { depth = 1 }))
end

function Handlers.ENTITY_DIE(context)
    local target = context.obj1
    local from = context.obj2
    if not target or not from then
        return
    end
    if not target.isPlayer or not from.isPlayer then
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
    context.obj1:resetHp()
end