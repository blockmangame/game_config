---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by KH5C.
--- DateTime: 2020/4/7 11:29
---

local petType = T(Define, "petType");

--[[相关数据(AllPetAttr)内容：
{ID = 0,              --宠物or式神的pluginID
 minorID = 0,         --式神的副ID
 petType = 0,         --是宠物还是式神
 level = 1,           --当前强化等级
 petCoinTransRage = 1,--该宠物Entity当前的金币增益
 petChiTransRate = 1, --该宠物Entity当前的气增益
 plusPetATKRate = 1}, --该式神Entity当前的攻击倍率增益
--]]
local function getPet(player, type, petID, minorID)
    local allEntityNum = player:getValue("hadEntityNum") + 1;
    player:setValue("hadEntityNum", allEntityNum);
    local AllPetAttr = player:getValue("allPetAttr");
    AllPetAttr[allEntityNum] = {
        ID = petID,
        petType = type,
        level = 1
    };
    return AllPetAttr, allEntityNum;
end

function Player:getNewPet(ID, coinTransRatio, chiTransRatio)
    local allAttribs, index = getPet(self, petType.pet, ID);
    local cfg = Entity.GetCfg(Player.turnID2Plugin(petType.pet, ID));
    if coinTransRatio then
        allAttribs[index].petCoinTransRage  = coinTransRatio;
    else
        allAttribs[index].petCoinTransRage = cfg.coinTransRatio;
    end
    if chiTransRatio then
        allAttribs[index].chiTransRatio = chiTransRatio;
    else
        allAttribs[index].chiTransRatio = cfg.chiTransRatio;
    end
    self:setValue("allPetAttr", allAttribs);
end

function Player:getNewPlusPet(ID, minorID, plusPetATKRate)
    minorID = minorID or 0
    local allAttribs, index = getPet(self, petType.plusPet, ID, minorID);
    print(Player.turnID2Plugin(petType.plusPet, ID, minorID))
    local cfg = Entity.GetCfg(Player.turnID2Plugin(petType.plusPet, ID, minorID));
    if plusPetATKRate then
        allAttribs[index].plusPetATKRate = plusPetATKRate;
    else
        allAttribs[index].plusPetATKRate = cfg.atkBuffNum;
    end
    self:setValue("allPetAttr", allAttribs);
end

function Player:callPet(index, rideIndex)
    local petSetting = self:getValue("allPetAttr")[index];
    local plugin = Player.turnID2Plugin(petSetting.petType, petSetting.ID);
    local createIndex = self:createPet(plugin, true);
    if rideIndex > 2 or rideIndex < 1 then
        print("=======Wrong pet rideIndex :" .. rideIndex .. "=======");
        return;
    end
    if petSetting.petType == petType.pet then
        local equipPetList = self:getValue("petEquippedList");
        equipPetList[rideIndex] = index;
        self:setValue("petEquippedList", equipPetList);
    else
        self:setValue("plusPetEquippedIndex", index);
    end
    self.equipPetList[index] =createIndex;

    local petEntity = self:getPet(createIndex);
    petEntity:rideOn(self, false, rideIndex);
end

function Player:initPetInfo()
    for rideIndex, index in pairs(self:getValue("petEquippedList")) do
        self:callPet(index, rideIndex)
    end
end

function Player:addPet(entity, index)
    assert(entity:getValue("ownerId")==0, entity.objID)
    local data = self:data("pet")
    index = index or #data + 1
    data[index] = entity
    entity:setValue("ownerId", self.objID)
    entity:setValue("petIndex", index)
    self:syncPet()
    return index
end
function Player:syncPet()
    local list = {}
    local packet = {
        pid = "PetList",
        list = list,
    }
    for index, entity in pairs(self.equipPetList) do
        list[index] = entity
    end
    self:sendPacket(packet)
end

function Player:recallPet(index)
    for entityIndex, i in pairs(self.equipPetList) do
        if index == i then
            self:removePet(entityIndex);
            return;
        end
    end
    Lib.log("=======Pet remove fail index :" .. index .. " could not find it=======");
end

function Player:deletePet(index)

end
