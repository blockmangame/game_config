---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by KH5C.
--- DateTime: 2020/4/14 17:09
---

local petType = T(Define, "petType");

Player.equipPetList = {}; --该表是存储创建的pet的entityIndex，在装备的情况下，可以通过宠物自身的index和创建的entityIndex进行互换

function Player.getPlusPetPluginFromID(id, minorID)
    if minorID == 0 then
        return "myplugin/PlusPet" .. tostring(id)
    end
    return "myplugin/PlusPet" .. tostring(id) .. "_" .. tostring(minorID);
end

function Player.getPetPluginFromID(id)
    return "myplugin/Pet" .. id;
end

function Player.turnID2Plugin(type, id, minorID)
    minorID = minorID or 0
    if type == petType.pet then
        return Player.getPetPluginFromID(id);
    elseif type == petType.plusPet then
        return Player.getPlusPetPluginFromID(id, minorID);
    end
    print("=======Wrong pet type :" .. type .. "and id :" .. id .. "=======");
end

function Player.getPetCfg(type, id, minorID)
    return Entity.GetCfg(Player.turnID2Plugin(type, id, minorID))
end


function Player:getPetAttr(index)
    local targetPetInfo = self:getValue("allPetAttr")[index];
    local targetEntityCfg = Entity.GetCfg(Player.turnID2Plugin(targetPetInfo.petType, targetPetInfo.ID, targetPetInfo.minorID or 0));
    return {
        petType = targetPetInfo.petType,                        --宠物类型
        ID = targetPetInfo.ID,                                  --寵物ID
        multiLang = targetEntityCfg.multiLang,                  --多语言配置名
        level = targetPetInfo.level,                            --当前等级
        orderWeight = targetEntityCfg.orderWeight,              --同等状态下排序优先级
        actorName = targetEntityCfg.actorName,                  --宠物模型名
        rank = targetEntityCfg.rank,                            --稀有度
        --==================以下为宠物或式神特有的，没有的即为nil=======================================
        minorID = targetPetInfo.minorID,                        --式神副ID
        coinTransRatio = targetPetInfo.coinTransRatio,          --当前金币转换率
        chiTransRatio = targetPetInfo.chiTransRatio,            --当前气转换率
        exerciseRatio = targetEntityCfg.exerciseRatio,          --宠物锻炼倍数
        chiIntensifyRange = targetEntityCfg.chiIntensifyRange,  --气转换区间
        coinIntensifyRange = targetEntityCfg.coinIntensifyRange,--金币转换区间
        atkBuffNum = targetPetInfo.atkBuffNum,                  --当前攻击增益数值
        reductionInjury = targetEntityCfg.reductionInjury,      --减伤数值
        intensifyATK = targetEntityCfg.intensifyATK,            --强化攻击倍率
        intensifyValue = targetEntityCfg.intensifyValue,        --强化权重
        skillType = targetEntityCfg.skillType,                  --技能类型
        skillName = targetEntityCfg.skillName,                  --技能名称
        skillInfo = targetEntityCfg.skillInfo                   --技能多语言描述名
    }
end