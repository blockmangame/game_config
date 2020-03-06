
function Player:showDialogTip(tipType, event, args, context)
	local regId = event and self:regCallBack("dialogTip", {[tostring(tipType)] = event}, false, true, context)
	self:sendPacket({
		pid = "ShowDialogTip",
		tipType = tipType or 0,
		regId = regId,
		args = args
	})
end