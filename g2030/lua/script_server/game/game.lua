local ProcessList = T(Game, "ProcessList")

local function canJoinTeam(id, oldId)
    --初始化情况
    if id == Define.Team.Neutrality or oldId == 0 then
        return true
    end

    --阵营未改变
    if id == oldId then
        return true
    end

    local black = Game.GetTeam(Define.Team.Black).playerCount
    local white = Game.GetTeam(Define.Team.White).playerCount

    --一方阵营人数为0
    if black == 0 or white == 0 then
        if black == 0 then
            return id == Define.Team.Black
        else
            return id == Define.Team.White
        end
    --均不为0
    else
        --阵营人数不等，比较
        if black > white then
            return not (black / white > 1.3 and id == Define.Team.Black)
        elseif white > black then
            return not (white / black > 1.3 and id == Define.Team.White)
        --阵营人数相等
        else
            --判断是否玩家切换阵营后，阵营人数为0
            if (oldId == Define.Team.Black and black == 1) or
                    (oldId == Define.Team.White and white == 1) then
                return false
            else
                return true
            end
        end
    end
end

function Game.TryJoinTeam(player, id)
    local oldId = player:getTeamId()
    local teamId = oldId
    if not id then
        if teamId == 0 then
            teamId = Define.Team.Neutrality
        end
    else
        teamId = id
    end

    local team = Game.GetTeam(teamId)
    if not team then
        return false
    end

    if not canJoinTeam(teamId, oldId) then
        return false
    end
    local oldTeam = Game.GetTeam(oldId)
    if oldTeam then
        oldTeam:leaveEntity(player, true)
    end
    team:joinEntity(player)

    return true
end

function Game.CreateProcess(key, type, config)
    if ProcessList[key] or not Game[type] then
        return
    end

    local time = World.Now()
    local process = {
        curState = 0,

        waitPlayerTime = 30,
        prepareTime = 30,
        gameTime = 200,
        gameOverTime = 10,
        waitCloseTime = 10,

        startPlayers = 1,
        maxPlayers = -1,

        needCloseServer = false,

        stateTimer = nil,

        createTime = time,
        EntityList = {},
        playerCount = 0,
    }

    if config then
        for k, v in pairs(config) do
            process[k] = v
        end
    end

    ProcessList[key] = setmetatable(process, Game[type])
    process:onWaiting()
    return process
end

local function initTeamConfig()
    local temp = Lib.readGameCsv("config/team_level.csv") or {}

    for _, cfg in pairs(temp) do
        for _, info in ipairs(World.cfg.team) do
            local team = Game.GetTeam(info.id, true)
            if info.id ~= Define.Team.Neutrality and
                    (tonumber(cfg.teamId) == 0 or info.id == tonumber(cfg.teamId)) then
                team:addLevelCfg(cfg)
            end
        end
    end
end

local function initTeam()
    local worldCfg = World.cfg
    if not worldCfg.team then
        return
    end
    initTeamConfig()
    for _, info in ipairs(World.cfg.team) do
        local team = Game.GetTeam(info.id)
        if team then
            team:initBuff()
            --获取阵营总击杀，初始化等级
        end
    end
end

initTeam()