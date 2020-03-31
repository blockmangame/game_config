---普通攻击/锻炼
local SkillMissile = Skill.GetType("Missile")
local NormalAtk = Skill.GetType("NormalAtk")
--[[
    @desc: 执行攻击
    author:zhuyayi
    time:2020-03-21 21:07:00
    @return:
]]
local function doAtk(self,target,from)
    local v = Lib.v3(0, 0, 0)
	if self.hurtDistance ~= 0 and target:isControl() then
		v = target:getPosition() - Lib.tov3(from:getPosition())
		v.y = 0
		v:normalize()
		v = v * self.hurtDistance
		v.y = self.hurtDistance
	end
	local cfg = target:cfg()
	target:doHurt(v)
	target:playSound(cfg.hurtSound)
end
--[[
    @desc: 执行锻炼
    author:zhuyayi
    time:2020-03-21 21:08:09
    @return:
]]
local function doExp()
    --print("Event.EVENT_EXP_CHANGE send")
end
function NormalAtk:canCast(packet, from)
	if not SkillMissile.canCast(self, packet, from) then
		return false
	end
	return true
end
function NormalAtk:preCast(packet, from)
	SkillMissile.preCast(self, packet, from)
end
function NormalAtk:cast(packet, from)
	print("client NormalAtk.cast")
	SkillMissile.cast(self, packet, from)
end