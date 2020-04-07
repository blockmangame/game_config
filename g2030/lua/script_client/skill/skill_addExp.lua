---锻炼增加
local SkillBase = Skill.GetType("Base")
local AddExp = Skill.GetType("AddExp")
function AddExp:cast(packet, from)
 --   Lib.emitEvent(Event.EVENT_EXP_CHANGE)
    SkillBase.cast(self, packet, from)
end