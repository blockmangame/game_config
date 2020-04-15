
local self = AsyncProcess
local gameName = World.GameName

--获取竞技场排行榜
function AsyncProcess.GetArenaRank(pageNo,callback)
    local url = string.format("%s/gameaide/api/v1/inner/segment/rank", self.ClientHttpHost)
    local args = {{"gameId", gameName}, {"segment",Me:getCurLevel()},{"pageNo",pageNo},{"pageSize",15}}
    self.HttpRequest("GET", url, args, callback)
end

--上报玩家阶数
function AsyncProcess.ReportCurLevel(callback)
    local url = string.format("%s/gameaide/api/v1/inner/segment/stage/report", self.ClientHttpHost)
    
    local args = {{"gameId", gameName}, {"userId", CGame.instance:getPlatformUserId()}}
    self.HttpRequest("POST", url, args, callback, {})
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
