

function EntityClient:updateShowName()  -- 覆盖引擎的EntityClient:updateShowName()
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

	self:updateFamilyIdentity()
end

function EntityClient:updateFamilyIdentity()
	if self.isPlayer and self ~= Me then
		local teamId = self:getValue("teamId")
		if teamId and teamId ~= 0 then
			if teamId == Me:getValue("teamId") then
				UI:openHeadWnd(self.objID, "familyIdentity", 7, 7, "set:family_identity.json image:FamilySamePic", "ui_family_same_family")
			else
				UI:openHeadWnd(self.objID, "familyIdentity", 7, 7, "set:family_identity.json image:FamilyDiffPic", "ui_family_diff_family")
			end
		else
			UI:closeHeadWnd(self.objID)
		end
	end
end


function EntityClient:startAutoChangeSkin()

	local skin = self:cfg().skin
	local skinColors = self:cfg().skinColor
	local meshRandomBloom = self:cfg().meshRandomBloom
	if not skinColors or #skinColors <= 0 or not skin then
		return
	end
	for k, v in pairs(skin) do
		local key = tostring(k) .. "." .. tostring(v)
		local index = math.random(1, #skinColors)
		local color = skinColors[index]
		self:updateBodyPartsColor(key, {color[1] / 255.0 , color[2] / 255.0 , color[3] / 255.0 , 1.0})
		if meshRandomBloom then
			local bloom =  math.random() >= 0.5
			self:updateBodyPartsBloom(key, bloom)
		end
	end

end