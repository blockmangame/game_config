
function Player:showDialogTip(tipType, event, args, context, dialogContinuedTime)
	local modName = "dialogTip" .. self.objID .. World.Now()
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