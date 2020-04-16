
local self = AsyncProcess
local gameName = World.GameName
local GetDispatchApi = "/game/api/v1/inner/region/disp-cluster/{regionCode}"
local DispatchPartyApi = "/v1/dispatch-party"

--获取竞技场排行榜
function AsyncProcess.GetArenaRank(pageNo,callback)
    local url = string.format("%s/gameaide/api/v1/inner/segment/rank", self.ServerHttpHost)
    local args = {{"gameId", gameName}, {"segment",Me:getCurLevel()},{"pageNo",pageNo},{"pageSize",15}}
    self.HttpRequest("GET", url, args, callback)
end

--上报玩家阶数
function AsyncProcess.ReportCurLevel(player,callback)
    local url = string.format("%s/gameaide/api/v1/inner/segment/stage/report/"..gameName, self.ServerHttpHost)
    local req = {}
    table.insert(req, {
        userId = player.platformUserId,
        stage = player:getCurLevel()
    })
    self.HttpRequest("POST", url, {}, callback, req)

    
end

function AsyncProcess.enterArena(player, gameType, mapId, callback)
    -- local group = GameGroups[groupId]
    -- if not group then
    --     return
    -- end
    -- if Platform.isWindow() then
    --     testGroupStart(group, gameType)
    --     return
    -- end
    WebService:GetDispatchUrl(player, function(info)
        if not info then
            LogUtil.log("[GameGroupStart] get dispatch url failed.", LogUtil.LogLevel.Error)
            if callback then
                callback(false, group)
            end
            return
        end
        local data = {
            gtype = gameType,
            rid = info.region,
            ever = EngineVersionSetting.getEngineVersion(),
            prv = false,
            mem = {player},
            mapid = mapId
        }
        -- for _, userId in pairs(group) do
        --     local member = buildUserInfo(userId)
        --     if member then
        --         table.insert(data.mem, member)
        --     end
        -- end
        LogUtil.log("[GameGroupStart][Data]:" .. json.encode(data), LogUtil.LogLevel.Info)
        WebService:GetDispatchParty(info.dispUrl, data, function(data, code)
            if code ~= 1 then
                LogUtil.log("[GameGroupStart] get dispatch party failed. [code]:" .. code, LogUtil.LogLevel.Error)
                if callback then
                    callback(false, group)
                end
                return
            end
            if callback then
                callback(true, group)
            end
        end)
    end)
    GameGroups[groupId] = nil
end

--获取匹配发起者url
function AsyncProcess.GetDispatchUrl(player,callback)
    local retryTimes = 3
    local regionId =  player:data("mainInfo").regionId or 0
    print("GetDispatchUrl-regionCode:",regionId)
    local url = self.ServerHttpHost .. GetDispatchApi
    url = string.gsub(path, "{regionCode}", tostring(regionId))
    local params = {
        { "engineType", "v1" }
    }

    self.HttpRequest("GET", url, params,function(data, code)
        if not data then
            if retryTimes > 0 then
                self:GetDispatchUrl(regionId, callback, retryTimes - 1)
                return
            end
        end
        callback(data, code)
    end)
end
---匹配
function AsyncProcess.GetDispatchParty(dispatchUrl, info,callback,retryTimes)
    retryTimes = retryTimes or 3
    local url = dispatchUrl .. DispatchPartyApi
    local params = {
        { "engineType", "v1" }
    }
    self.HttpRequest("POST", url, {},function(data, code)
        if code ~= 1 and retryTimes > 0 then
            LuaTimer:schedule(function()
                self:GetDispatchParty(dispatchUrl, info, callback, retryTimes - 1)
            end, 3000)
            return
        end
        callback(data, code)
    end,json.encode(info))
end




-- --获取收藏作品
-- function AsyncProcess.LoadCollectWorks(callback)
--     local url = string.format("%s/gameaide/api/v1/graffiti/collect", self.ClientHttpHost)
--     local args = {{"gameId", gameName}, {"userId", CGame.instance:getPlatformUserId()}}
--     self.HttpRequest("GET", url, args, callback)
-- end

-- --获取作品评论
-- function AsyncProcess.LoadWorksComments(id, callback)
--     local url = string.format("%s/gameaide/api/v1/graffiti/comment", self.ClientHttpHost)
--     local args = {{"gameId", gameName}, {"graffitiId", id}}
--     self.HttpRequest("GET", url, args, callback)
-- end

-- --获取某个作品的信息
-- function AsyncProcess.GetWorksInfo(worksId, callback)
--     local url = string.format("%s/gameaide/api/v1/graffiti/detail", self.ClientHttpHost)
--     local args = {{"gameId", gameName}, {"userId", CGame.instance:getPlatformUserId()}, {"graffitiId", worksId}}
--     self.HttpRequest("GET", url, args, callback)
-- end
