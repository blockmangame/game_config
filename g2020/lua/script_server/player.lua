
function Player:showDialogTip(tipType, event, args, context, dialogContinuedTime)
	local modName = "dialogTip" .. (tipType or "") .. (event or "") .. World.Now() .. os.time() .. math.random(0, 99999)
	local regId = event and self:regCallBack(modName, {[tostring(tipType)] = event}, true, true, context)
	-- if use "dialogTip" to get regId, then , if have more than twice request, this regId will wrong
	self:sendPacket({
		pid = "ShowDialogTip",
		tipType = tipType or 0,
		regId = regId,
		args = args,
		modName = modName,
		dialogContinuedTime = dialogContinuedTime
	})
end

function Player:sendTip(tipType, textKey, keepTime, vars, event, ...)
	if textKey == "game.init" then
		return
	end

	local regId
	if event then
		regId = self:regCallBack("SendTip"..tipType, {key = event}, 1, true)
	end
    self:sendPacket( {
        pid = "ShowTip",
        tipType = tipType,
		keepTime = keepTime,
        textKey = textKey,
		vars = vars,
		regId = regId,
        textArgs = {...},
    })
end