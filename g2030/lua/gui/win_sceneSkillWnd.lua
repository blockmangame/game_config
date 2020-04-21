-- 所以结论是：有个敏感范围，超出敏感范围一次，就视为滑动，如果没超过则不管按多久都是释放点击
M.NotDialogWnd = true
local ti = TouchManager:Instance()
local bm = Blockman.instance

local mmax = math.max
local mabs = math.abs
local msqrt = math.sqrt
local mceil = math.ceil
local LposAroundYaw = Lib.posAroundYaw
local Lv3AngleXZ = Lib.v3AngleXZ
local Lv3add = Lib.v3add
local Lv3cut = Lib.v3cut
local Ltov3 = Lib.tov3

local ISOPEN = false

local SLIP_SENSITIVITY = 3
local STATIC_SLIP_SENSITIVITY_AREA = {min = {x = 0, y = 0}, max = {x = 0, y = 0}}

local STATIC_BASE_AREA = {min = {x = 0, y = 0}, max = {x = 0, y = 0}}

local function castSceneSkill(self)
	if not self.isTouchPointMove then
		return
	end
	local targetPos = self.targetPos
	local imcV3 = Lib.v3cut(targetPos, Me:getPosition())
	Skill.Cast(self.curSkillCfg.fullName, {isTouchPointMove = self.isTouchPointMove, 
		startPos = targetPos, targetPos = targetPos, linePosValue = imcV3,needPre = true})
end

local function checkTouchInArea(touchPos,area)
	local min, max = area.min, area.max
	return touchPos.x >= min.x and touchPos.y >= min.y and touchPos.x < max.x and touchPos.y < max.y
end

local function initChildUIEvent(self)
	self:subscribe(self.touchBg, UIEvent.EventMotionRelease, function()
		local touch = ti:getTouch(ti:getActiveTouch())
		local touchPos = touch:getTouchPoint()
		if not checkTouchInArea(touchPos, self.touchBgArea) then
			UI:closeWnd(self)
		end
	end)
	self:subscribe(self.touchBg, UIEvent.EventWindowTouchUp, function()
		castSceneSkill(self)
		UI:closeWnd(self)
	end)

	self:subscribe(self.touchCell, UIEvent.EventWindowTouchUp, function()
		castSceneSkill(self)
		UI:closeWnd(self)
	end)

	self:subscribe(self.cancle, UIEvent.EventWindowTouchDown, function()
		self.touchCellRedMask:SetVisible(true)
		self.cancleRedMask:SetVisible(true)
		self.showPointRedMask:SetVisible(true)
	end)
	self:subscribe(self.cancle, UIEvent.EventMotionRelease, function()
		self.touchCellRedMask:SetVisible(false)
		self.cancleRedMask:SetVisible(false)
		self.showPointRedMask:SetVisible(false)
	end)
	self:subscribe(self.cancle, UIEvent.EventWindowTouchUp, function()
		UI:closeWnd(self)
	end)
end

local function resetProperty(self)
	self.curSkillCfg = nil

	self.curTouchCellBaseRealPos = {x = 0, y = 0}
	self.isTouchPointMove = false
	self.slipSensitivityArea = STATIC_SLIP_SENSITIVITY_AREA
	self.touchBgArea = STATIC_BASE_AREA

	self.targetPos = {x = 0, y = 0, z = 0}
end

local function initStaticBaseArea(self)
	local touchBgArea = self.touchBg:GetUnclippedOuterRect()
	STATIC_BASE_AREA.min.x = touchBgArea[1] + 5
	STATIC_BASE_AREA.min.y = touchBgArea[2] + 5
	STATIC_BASE_AREA.max.x = touchBgArea[3] - 5
	STATIC_BASE_AREA.max.y = touchBgArea[4] - 5
end

function M:init()
	WinBase.init(self, "widget_scene_skill_cell.json")
	self.touchBg = self:child("widget_scene_skill_cell-touch_bg")
	initStaticBaseArea(self)

	self.cellBase = self:child("widget_scene_skill_cell-base")
	self.touchCell = self:child("widget_scene_skill_cell-touch_cell")
	self.touchCellRedMask = self:child("widget_scene_skill_cell-red_mask")
	self.cancle = self:child("widget_scene_skill_cell-cancle")
	self.cancleRedMask = self:child("widget_scene_skill_cell-cancle_red_mask")
	self.cancleText = self:child("widget_scene_skill_cell-cancle_text")

	self.touchPointBase = self:child("widget_scene_skill_cell-touch_point_base")
	self.touchPoint = self:child("widget_scene_skill_cell-touch_point")
	self.showPointBase = self:child("widget_scene_skill_cell-show_point_base")
	self.showPoint = self:child("widget_scene_skill_cell-show_point")
	self.showPointRedMask = self:child("widget_scene_skill_cell-show_point_red_mask")

	resetProperty(self)
	initChildUIEvent(self)
end

------------------------------------------------------------------
local function updatePlayerTouch(self)
	local realNormalizeSizeX = {x = 0, y = 0, z = self.touchCell:GetPixelSize().x / 2}
	local sceneRatio = self.curSkillCfg.sceneSkillSceneRatio or 1
	
	local slipSensitivityArea = self.slipSensitivityArea
	local imcNormalizeV3 = {x = 0, y = 0, z = 0}
	local touchCellRedMask = self.touchCellRedMask

	local curTouchCellBaseRealPos = self.curTouchCellBaseRealPos
	local ccbrpX, ccbrpY = curTouchCellBaseRealPos.x, curTouchCellBaseRealPos.y

	local touch = ti:getTouch(ti:getActiveTouch())
	local meMap = Me.map
	local lastPos = {x = 0, y = 0, z = 0}
	self.touchMoveTimer = World.Timer(1,function()
		local touchPos = touch:getTouchPoint()
		if not touchPos or not ISOPEN then
			return false
		end
		if not self.isTouchPointMove and not checkTouchInArea(touchPos, slipSensitivityArea) then
			self.isTouchPointMove = true
		end
		-- todo ex
		self:updateTouchPointBasePosition(touchPos)
		local imcPos = {x = touchPos.x - ccbrpX,y = 0, z = touchPos.y - ccbrpY}
		if (imcPos.x * imcPos.x + imcPos.z * imcPos.z) <= realNormalizeSizeX.z * realNormalizeSizeX.z then
			imcNormalizeV3.x = imcPos.x
			imcNormalizeV3.z = imcPos.z
			self:updateShowPointBasePosition(touchPos)
		else
			local imcYaw = Lv3AngleXZ(imcPos)
			local tempV3 = LposAroundYaw(realNormalizeSizeX, imcYaw)
			imcNormalizeV3.x = tempV3.x
			imcNormalizeV3.z = tempV3.z
			self:updateShowPointBasePosition({x = ccbrpX + tempV3.x, y = ccbrpY + tempV3.z})
		end
		-- clac end pos
		local mePos = Me:getPosition()
		local targetPos
		if not self.isTouchPointMove then
			targetPos = mePos
		else
			local tempNorV3 = LposAroundYaw(imcNormalizeV3, bm:viewerRenderYaw())-- imcNormalizeV3 -- LposAroundYaw(imcNormalizeV3, Me:getRotationYaw())
			local cV3X, cV3Z = tempNorV3.x * sceneRatio, tempNorV3.z * sceneRatio
			local A, B, C = cV3Z, -cV3X, cV3X * mePos.z - cV3Z * mePos.x
			local function getDis(pos)
				return  (A * pos.x + B * pos.z + C) / msqrt(A*A+B*B)
			end
			local dirMaxXZ = mceil(msqrt(cV3X*cV3X+cV3Z*cV3Z))
			local imcV3X, imcV3Z = cV3X / dirMaxXZ, cV3Z / dirMaxXZ
			local endCount = 0
			for imcCount = 0, dirMaxXZ do -- clac is touch block ?
				endCount = imcCount
				for x = imcCount, imcCount + 1 do
					for z = imcCount, imcCount + 1 do
						local blockPos = Ltov3(Lv3cut(mePos, {x = x * imcV3X, y = 0, z = z * imcV3Z})):blockPos()
						local block = meMap:getBlock(blockPos)
						if block.fullName ~= "/air" then
							local lb, lt, rb, rt = blockPos, Lv3add(blockPos,{x = 1, y = 0, z = 0}), Lv3add(blockPos,{x = 0, y = 0, z = 1}), Lv3add(blockPos,{x = 1, y = 0, z = 1})
							if getDis(lb) * getDis(rt) <= 0 or getDis(lt) * getDis(rb) <= 0 then
								goto CONTINUE
							end
						end
					end
				end
			end
			::CONTINUE::
			-- targetPos = Lv3cut(mePos, {x = cV3X, y = 0, z = cV3Z})
			local cV3Y = 0
			for i = 0,endCount or 1 do
				if meMap:getBlock(Ltov3(Lv3cut(mePos, {x = endCount * imcV3X, y = cV3Y + 1, z = endCount * imcV3Z})):blockPos()).fullName == "/air" then
					cV3Y = cV3Y + 1
				else
					break
				end
			end
			targetPos = Lv3cut(mePos, {x = endCount * imcV3X, y = cV3Y, z = endCount * imcV3Z})
		end
		if lastPos.x ~= targetPos.x or lastPos.y ~= targetPos.y or lastPos.z ~= targetPos.z then
			lastPos = targetPos
			self.targetPos = targetPos
			Lib.emitEvent(Event.EVENT_SCENE_SKILL_TOUCH_MOVE, {targetPos = targetPos, isReclacTargetPos = self.isTouchPointMove, isActivion = touchCellRedMask:IsVisible()})
		end
		return true
	end)
end

local function updateProp(self, skillName, skillUnclippedOuterRect)
	local skillCfg = Skill.Cfg(skillName)
	self.curSkillCfg = skillCfg
	self:updateChildUI()

	local minXpos,minYpox,maxXpos,maxYpos = table.unpack(skillUnclippedOuterRect)
	local xPos = (maxXpos + minXpos) / 2
	local yPos = (maxYpos + minYpox) / 2
	self.cellBase:SetXPosition({0, xPos})
	self.cellBase:SetYPosition({0, yPos})

	self:updateSlipSensitivity()
	local realPos = {x = xPos, y = yPos}
	self.curTouchCellBaseRealPos = realPos
	self:updateShowPointBasePosition(realPos)
	self:updateTouchPointBasePosition(realPos)
end

local function resetTouchTimer(self)
	if self.touchMoveTimer then
		self.touchMoveTimer()
		self.touchMoveTimer = nil
	end
end

function M:onOpen(args)
	local skillName, skillUnclippedOuterRect = args.skillName, args.skillUnclippedOuterRect
	if not skillName or ISOPEN or not skillUnclippedOuterRect then
		print("open sceneSkillWnd error, cause not skillName or open repeat.")
		UI:closeWnd(self)
		return
	end
	ISOPEN = true
	resetProperty(self)
	resetTouchTimer(self)
	self.touchCellRedMask:SetVisible(false)
	self.cancleRedMask:SetVisible(false)
	self.showPointRedMask:SetVisible(false)
	self.cancleText:SetText(Lang:toText("cancle_cast_skill"))
	updateProp(self, skillName, skillUnclippedOuterRect)

	updatePlayerTouch(self)
	Lib.emitEvent(Event.EVENT_SCENE_SKILL_TOUCH_MOVE_BEGIN, {skillCfg = self.curSkillCfg})
end

function M:onClose(args)
	ISOPEN = false
	resetTouchTimer(self)
	resetProperty(self)
	Lib.emitEvent(Event.EVENT_SCENE_SKILL_TOUCH_MOVE_END)
end

------------------------------------------------------------------ 
function M:updateShowPointBasePosition(v2)
	if v2 then
		self.showPointBase:SetXPosition({0, v2.x})
		self.showPointBase:SetYPosition({0, v2.y})
	end
end

function M:updateTouchPointBasePosition(v2)
	if v2 then
		self.touchPointBase:SetXPosition({0, v2.x})
		self.touchPointBase:SetYPosition({0, v2.y})
	end
end

function M:updateSlipSensitivity()
	local slipSensitivity = self.curSkillCfg.sceneSkillSlipSensitivity or SLIP_SENSITIVITY
	local touch = ti:getTouch(ti:getActiveTouch())
	local realPos = touch:getTouchPoint()
	if realPos then
		self.slipSensitivityArea = {min = {x = realPos.x - slipSensitivity, y = realPos.y - slipSensitivity}
										,max = {x = realPos.x + slipSensitivity, y = realPos.y + slipSensitivity}}
	end
end

------------------------------------------------------------------ 
function M:updateChildUI()
	local wndProp = self.curSkillCfg.sceneSkillWndProp
	if not wndProp then
		return
	end
	local touchBgProp, touchCellProp, cancleCellProp, touchPointProp, showPointProp = 
		wndProp.touchBgProp,wndProp.touchCellProp,wndProp.cancleCellProp,wndProp.touchPointProp,wndProp.showPointProp
	if touchBgProp then
		self:updateTouchBgImage(touchBgProp.image)
		self:updateTouchBgSize(touchBgProp.size)
	end
	if touchCellProp then
		self:updateTouchCellImage(touchCellProp.image)
		self:updateTouchCellRedMaskImage(touchCellProp.redMaskImage)
		self:updateTouchCellSize(touchCellProp.size)
	end
	if cancleCellProp then
		self:updateCancleCellImage(cancleCellProp.image)
		self:updateCancleCellSize(cancleCellProp.size)
	end
	if touchPointProp then
		self:updateTouchPointImage(touchPointProp.image)
		self:updateTouchPointSize(touchPointProp.size)
	end
	if showPointProp then
		self:updateShowPointImage(showPointProp.image)
		self:updateShowPointSize(showPointProp.size)
	end
	-- todo ex
end

function M:updateTouchBgImage(image)
	if image then
		self.touchBg:SetImage(image)
	end
end

local function resetTouchBgArea(self)
	local touchBgArea = self.touchBg:GetUnclippedOuterRect()
	local ret = {min = {}, max = {}}
	ret.min.x = touchBgArea[1]
	ret.min.y = touchBgArea[2]
	ret.max.x = touchBgArea[3]
	ret.max.y = touchBgArea[4]
	return ret
end

function M:updateTouchBgSize(size)
	if size then
		self.touchBg:SetArea(self.touchBg:GetXPosition(), self.touchBg:GetYPosition(), {0, size.x}, {0, size.y})
		self.touchBgArea = resetTouchBgArea(self)
	end
end

function M:updateTouchCellImage(image)
	if image then
		self.touchCell:SetImage(image)
	end
end

function M:updateTouchCellRedMaskImage(image)
	if image then
		self.touchCellRedMask:SetImage(image)
	end
end

function M:updateTouchCellSize(size)
	if size then
		self.touchCell:SetArea(self.touchCell:GetXPosition(), self.touchCell:GetYPosition(), {0, size.x}, {0, size.y})
	end
end

function M:updateCancleCellImage(image)
	if image then
		self.cancle:SetImage(image)
	end
end

function M:updateCancleCellSize(size)
	if size then
		self.cancle:SetArea(self.cancle:GetXPosition(), self.cancle:GetYPosition(), {0, size.x}, {0, size.y})
	end
end

function M:updateTouchPointImage(image)
	if image then
		self.touchPoint:SetImage(image)
	end
end

function M:updateTouchPointSize(size)
	if size then
		self.touchPoint:SetArea(self.touchPoint:GetXPosition(), self.touchPoint:GetYPosition(), {0, size.x}, {0, size.y})
	end
end

function M:updateShowPointImage(image)
	if image then
		self.showPoint:SetImage(image)
	end
end

function M:updateShowPointSize(size)
	if size then
		self.showPoint:SetArea(self.showPoint:GetXPosition(), self.showPoint:GetYPosition(), {0, size.x}, {0, size.y})
	end
end

return M