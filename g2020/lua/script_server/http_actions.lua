local BehaviorTree = require("common.behaviortree")
local Actions = BehaviorTree.Actions
local gameName = World.GameName

--发表作品
function Actions.CreateWorks(data, params, context)
    local url = string.format("%s/gameaide/api/v1/inner/graffiti/create", AsyncProcess.ServerHttpHost)
    local userId = params.player.platformUserId
    local args = {
        {"picUrl", params.picUrl},
        {"gameId", gameName},
        {"userId", params.player.platformUserId},
        {"isPublish", params.isPublish and 1 or 0}
    }

    AsyncProcess.HttpRequest("POST", url, args, function (response)
        local player = Game.GetPlayerByUserId(userId)
        if player then
            Trigger.CheckTriggers(player:cfg(), params.event, { obj1 = player, response = response, isPublish = params.isPublish })
        end
    end, params.body)
end

--更新作品
function Actions.UpdateWorks(data, params, context)
    local url = string.format("%s/gameaide/api/v1/inner/graffiti/update", AsyncProcess.ServerHttpHost)
    local userId = params.player.platformUserId
    local isPublish = 0
    if params.isPublish ~= nil and params.isPublish  then
        isPublish = 1
    end

    local args = { {"picUrl", params.url},  {"gameId", gameName},
                   {"userId", params.player.platformUserId},  {"isPublish", isPublish},
                   {"graffitiId", params.worksId}
    }

    AsyncProcess.HttpRequest("POST", url, args, function (response)
        local player = Game.GetPlayerByUserId(userId)
        if player then
            Trigger.CheckTriggers(player:cfg(), params.event, { obj1 = player,
                                                                response = response,
                                                                isPublish = params.isPublish,
                                                                worksId = params.worksId,
                                                                isEdit = params.isEdit})
        end
    end, params.body)
end

--获取最新未发布的作品
function Actions.GetNewUnPublishWorks(data, params, context)
    local url = string.format("%s/gameaide/api/v1/inner/graffiti/not/publish", AsyncProcess.ServerHttpHost)
    local userId = params.player.platformUserId
    local args = {
        {"gameId", gameName},
        {"userId", params.player.platformUserId}
    }
    AsyncProcess.HttpRequest("GET", url, args, function (response)
        local player = Game.GetPlayerByUserId(userId)
        if player then
            Trigger.CheckTriggers(player:cfg(), params.event, { obj1 = player, response = response, url = params.url, isPublish = params.isPublish})
        end
    end, params.body)
end


--获取最佳作品数(上周前10名)
function Actions.GetTopWorks(data, params, context)
    local url = string.format("%s/gameaide/api/v1/inner/graffiti/top", AsyncProcess.ServerHttpHost)
    local args = {{"gameId", gameName}, {"count", params.count or 10}}
    AsyncProcess.HttpRequest("GET", url, args, function (response)
        Trigger.CheckTriggers(nil, params.event, { response = response })
    end, params.body)
end

--获取最新涂鸦墙作品
function Actions.GetNewWorks(data, params, context)
    local url = string.format("%s/gameaide/api/v1/inner/graffiti/new", AsyncProcess.ServerHttpHost)
    local args = {
        {"gameId", gameName},
        {"currentCount", params.currentCount},
        {"othersCount", params.othersCount},
        {"userIdList", table.concat(params.userIds, ",")}
    }
    AsyncProcess.HttpRequest("GET", url, args, function (response)
        Trigger.CheckTriggers(nil, params.event, { response = response })
    end, params.body)
end

--获取优秀作品
function Actions.GetExcellentWorks(data, params, context)
    local url = string.format("%s/gameaide/api/v1/inner/graffiti/high/quality", AsyncProcess.ServerHttpHost)
    local args = {
        {"gameId", gameName},
        {"praiseLimit", params.limit},
        {"count", params.count}
    }
    AsyncProcess.HttpRequest("GET", url, args, function (response)
        Trigger.CheckTriggers(nil, params.event, { response = response })
    end, params.body)
end

--评论作品
function Actions.CommentWorks(data, params, context)
    local url = string.format("%s/gameaide/api/v1/inner/graffiti/user/comment", AsyncProcess.ServerHttpHost)
    local userId = params.player.platformUserId
    local args = {
        {"gameId", gameName}, {"userId", userId},
        {"graffitiId", params.id}, {"comment", params.msg}
    }

    AsyncProcess.HttpRequest("POST", url, args, function (response)
        local player = Game.GetPlayerByUserId(userId)
        if player then
            Trigger.CheckTriggers(player:cfg(), params.event, { obj1 = player, response = response })
        end
    end, params.body)
end

--发布作品
function Actions.PublishWorks(data, params, context)
    local url = string.format("%s/gameaide/api/v1/inner/graffiti/publish-status", AsyncProcess.ServerHttpHost)
    local userId = params.player.platformUserId
    local args = {
        {"gameId", gameName},
        {"userId", params.player.platformUserId},
        {"graffitiId", params.id},
        {"isPublish", 1}
    }

    AsyncProcess.HttpRequest("POST", url, args, function (response)
        local player = Game.GetPlayerByUserId(userId)
        if player then
            Trigger.CheckTriggers(player:cfg(), params.event, { obj1 = player, response = response, worksId = params.id })
        end
    end, params.body)
end

function Actions.GetWorksCount(data, params, context)
    local url = string.format("%s/gameaide/api/v1/inner/graffiti/count", AsyncProcess.ServerHttpHost)
    local userId = params.player.platformUserId
    local args = { {"gameId", gameName},  {"userId", userId}}
    AsyncProcess.HttpRequest("GET", url, args, function (response)
        local player = Game.GetPlayerByUserId(userId)
        if player then
            local newParams = { obj1 = player, response = response, url = params.url, isPublish = params.isPublish }
            Trigger.CheckTriggers(player:cfg(), params.event, newParams)
        end
    end)
end

function Actions.WorksArchiveReport(data, params, context)
    local url = string.format("%s/gameaide/api/v1/inner/graffiti/count", AsyncProcess.ServerHttpHost)
    local userId = params.player.platformUserId
    local args = { {"gameId", gameName},  {"userId", userId}}
    AsyncProcess.HttpRequest("GET", url, args, function (response)
        local num = 0
        if response.code == 1 then
            num = response.data
        end
        GameAnalytics.Design(userId, 0,{"player:works:archive", num})
    end)
end
