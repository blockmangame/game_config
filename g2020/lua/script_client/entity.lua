

function EntityClient:updateShowName()  -- 覆盖引擎的EntityClient:updateShowName()

    if self.isPlayer and self ~= Me then

        local cfg = self._cfg
        local x = cfg.familyIdentityX
        local y = cfg.familyIdentityY
        local sameFamilyPic = cfg.sameFamilyPic
        local diffFamilyPic = cfg.diffFamilyPic

        if self:data("headText").svrAry and self:data("headText").svrAry[y] and self:data("headText").svrAry[y][x] then
            local teamId = self:getValue("teamId")
            if teamId and teamId ~= 0 then
                if teamId == Me:getValue("teamId") then
                    self:data("headText").svrAry[y][x] = sameFamilyPic
                else
                    self:data("headText").svrAry[y][x] = diffFamilyPic
                end
            else
                self:data("headText").svrAry[y][x] = nil
            end
        end
    end

	local headText = self:data("headText")
	local clientLines = headText.ary or {}
	local serverLines = headText.svrAry or {}
	local list = {}
	for y = -3, 1 do		-- line: top to buttom
		local cline = clientLines[y] or {}
		local sline = serverLines[y] or {}
		local line = {}
		for x = -2, 2 do	-- column: left to right
			local t = cline[x] or sline[x]
			if t then
				t = Lang:toText(t)
			elseif y == 0 and x == 0 then
				t = self.name
			end
			line[#line + 1]	= t
		end
		if #line > 0 then
			list[#list + 1] = table.concat(line)
		end
	end

    local cfg = self._cfg
	local name = table.concat(list, "\n")

	if cfg.nameBorder then
		name = "[B=1]" .. name
	end
	
	if not cfg.hideName then
		self:setShowName(name)
	end

	if cfg.hideSelfName and self == Me then
		self:setShowName("\n")
	end
end