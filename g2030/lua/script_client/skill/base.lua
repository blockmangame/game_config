local SkillBase = Skill.GetType("Base")

local function playAction(from, action, time, isResetAction)
	if from and from.isEntity and action and action~="" then
		from:updateUpperAction(action, time, isResetAction)
	end
end

local function playEffect(from, cfg, effect)
	if effect and from and from.isEntity then
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
	if self.enableRadialBlur ~= nil then
		Blockman.instance.gameSettings:setEnableRadialBlur(self.enableRadialBlur)
	end
	playAction(from, self.castAction, self.castActionTime, self.isResetAction)
	playEffect(from, self, self.castEffect)
    playSound(from, self, self:getSoundCfg(packet,"castSound",from))
end