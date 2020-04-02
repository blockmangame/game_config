
local self = AsyncProcess
local gameName = World.GameName

--获取我的作品
function AsyncProcess.LoadWorks(callback)
    local url = string.format("%s/gameaide/api/v1/graffiti", self.ClientHttpHost)
    local args = {{"gameId", gameName}, {"userId", CGame.instance:getPlatformUserId()}}
    self.HttpRequest("GET", url, args, callback)
end

--删除我的作品
function AsyncProcess.DeleteWorks(worksId, callback)
    local url = string.format("%s/gameaide/api/v1/graffiti", self.ClientHttpHost)
    local args = {{"gameId", gameName}, {"userId", CGame.instance:getPlatformUserId()}, {"graffitiId", worksId}}
    self.HttpRequest("DELETE", url, args, callback, {})
end

--点赞
function AsyncProcess.PraiseWorks(worksId, callback)
    local url = string.format("%s/gameaide/api/v1/graffiti/user/praise", self.ClientHttpHost)
    local args = {{"gameId", gameName}, {"userId", CGame.instance:getPlatformUserId()}, {"graffitiId", worksId}}
    self.HttpRequest("POST", url, args, callback, {})
end

--获取收藏作品
function AsyncProcess.LoadCollectWorks(callback)
    local url = string.format("%s/gameaide/api/v1/graffiti/collect", self.ClientHttpHost)
    local args = {{"gameId", gameName}, {"userId", CGame.instance:getPlatformUserId()}}
    self.HttpRequest("GET", url, args, callback)
end

--获取作品评论
function AsyncProcess.LoadWorksComments(id, callback)
    local url = string.format("%s/gameaide/api/v1/graffiti/comment", self.ClientHttpHost)
    local args = {{"gameId", gameName}, {"graffitiId", id}}
    self.HttpRequest("GET", url, args, callback)
end

--获取某个作品的信息
function AsyncProcess.GetWorksInfo(worksId, callback)
    local url = string.format("%s/gameaide/api/v1/graffiti/detail", self.ClientHttpHost)
    local args = {{"gameId", gameName}, {"userId", CGame.instance:getPlatformUserId()}, {"graffitiId", worksId}}
    self.HttpRequest("GET", url, args, callback)
end

function AsyncProcess.LoadUsersInfo(userIds)
    local url = strfmt("%s/gameaide/api/v1/party/users/info/list", self.ClientHttpHost)
    local params = {
        {"userIds", table.concat(userIds, ",")},
        {"userId", tostring(Me.platformUserId)},
        {"gameId", World.GameName},
    }
    self.HttpRequest("GET", url, params, function (response, isSuccess)
        if not isSuccess then
            print("AsyncProcess.LoadUsersInfo response error", cjson.encode(params), cjson.encode(response))
            return
        end
        -- print("AsyncProcess.LoadUsersInfo>>>", cjson.encode(response))
        UserInfoCache.UpdateUserInfos(response.data)
    end)
end