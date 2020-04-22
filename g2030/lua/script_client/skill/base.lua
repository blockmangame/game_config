local SkillBase = Skill.GetType("Base")

local function playAction(from, action, time, isResetAction)
	if from and from.isEntity and action and action~="" then
		from:updateUpperAction(action, time, isResetAction)
	end
end

local function playEffect(from, cfg, effect)
	if effect and from and from.isEntity then
		for _, eff in ipairs(effect) do
			from:showEffect(eff, cfg)
		end
		from:showEffect(effect, cfg)
	end
end

local function playSound(from, self, cfg, sound)
	if sound and from then
		from:data("soundId")[self.fullName] = from:playSound(sound, cfg)
	end
end

-- 技能起手动作
function SkillBase:preCast(packet, from)
	if self.cdTime and from then
		from:setCD("net_delay", 20)
	end
	if self.enableRadialBlur ~= nil and (from and from.objID == Me.objID) then
		Blockman.instance.gameSettings:setEnableRadialBlur(self.enableRadialBlur)
	end
	playAction(from, self.castAction, self.castActionTime, self.isResetAction)
	playEffect(from, self, self.castEffect)
    playSound(from, self, self:getSoundCfg(packet,"castSound",from))
end

-- 技能函数常见的参数为：
--	(self)	一个技能配置（config）
--	packet	一个技能协议包（一次技能释放的数据，包含技能目标等）
--	from	技能释放者，可选
--	...		其它
function SkillBase:canCast(packet, from)	-- C/S通用的基本释放条件检查
	if from.curHp<=0 then
		return false
	end

	--can not cast other skill when be attacked by roundup skill
	local beAttackByRoundupSkill = from:data("main").beAttackByRoundupSkill
	if beAttackByRoundupSkill then
		return false
	end

	return self:checkConsume(packet, from)
end