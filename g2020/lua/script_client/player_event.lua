
local playerEventEngineHandler = L("playerEventEngineHandler", player_event)
local events = {}

function player_event(player, event, ...)
	playerEventEngineHandler(player, event, ...)
	local func = events[event]
	if func then
		func(player, ...)
	end
end

function events:onGameActionTrigger(type, info)
	if type == 20 then
		local file, errmsg = io.open(info)
		if not file then
			print("[error]  events:onGameActionTrigger , error message :", errmsg)
			return
		end
		file:close()

		local fileName = tostring(Me.platformUserId) .. "_" .. tostring(os.time()) .. ".png"
		AsyncProcess.UploadFile(fileName, info, "image",function (response)
			if response.code == 1 then
				Me:sendTrigger(Me, "SAVE_PHOTO", Me, nil, {data = response.data})
			end
		end)
	end
end