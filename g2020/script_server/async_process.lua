-- all logic async request should use interface define in this mode
-- requests will dispatch and callback by server in C++
-- environment maybe change in async callback, so must checkt it!!!

local cjson = require("cjson")
local strfmt = string.format
local tconcat = table.concat
local tostring = tostring
local type = type
local traceback = traceback
local debugPort = require "common.debugport"
local RedisHandler = require "redishandler"
local gameName = World.GameName

local self = AsyncProcess

function AsyncProcess.UploadPrivilege(userId)
	local url = strfmt("%s/gameaide/api/v1/inner/game/privilege/upload", self.ServerHttpHost)
	local params = {{"gameId", gameName}, {"userId", tostring(userId)}}
    self.HttpRequest("POST", url, params, function (response)
		 if response.code ~= 1 then
			print("AsyncProcess.UploadPrivilege response error", userId)
		 end
	end)
end