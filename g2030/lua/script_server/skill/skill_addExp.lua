local SkillBase = Skill.GetType("Base")
local AddExp = Skill.GetType("AddExp")
function AddExp:cast(packet, from)
    print("server AddExp.cast")
    if from then
        from:setCurExp(packet.val or 0)
    end


    SkillBase.cast(self, packet, from)
end