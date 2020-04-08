---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by KH5C.
--- DateTime: 2020/4/7 11:29
---

local petType = T(Define, "petType");

Player.equipPetList = {}; --该表是存储创建的pet的entityIndex，在装备的情况下，可以通过宠物自身的index和创建的entityIndex进行互换

local function getPlusPetPluginFromID(id)
    return "myplugin/PlusPet1";
end

local function getPetPluginFromID(id)
    return "myplugin/Pet1";
end

local function turnID2Plugin(type, id)
    if type == petType.pet then
        return getPetPluginFromID(id);
    elseif type == petType.pulsPet then
        return getPlusPetPluginFromID(id);
    end
    Lib.log("=======Wrong pet type :" .. type .. "\nand id :" .. id .. "=======");
end

--[[相关数据(AllPetAttr)内容：
{id = 0,               --宠物or式神的pluginID
 petType = 0,         --是宠物还是式神
 petCoinTransRage = 0,--该宠物Entity当前的金币增益
 petChiTransRate = 0, --该宠物Entity当前的气增益
 plusPetATKRate = 0}, --该式神Entity当前的攻击倍率增益
--]]
local function getPet(player, type, petID)
    local allEntityNum = player:getValue("hadEntityNum") + 1;
    player:setValue("hadEntityNum", allEntityNum);
    local AllPetAttr = player:getValue("AllPetAttr");
    AllPetAttr[allEntityNum] = {
        ID = petID,
        petType = type
    };
    return AllPetAttr[allEntityNum];
end

function Player:getNewPet(ID, coinTransRatio, chiTransRatio)
    local otherAttributes = getPet(self, petType.pet, ID);
    local cfg = Entity.GetCfg(turnID2Plugin(petType.pet, ID));
    if ~coinTransRatio and ~chiTransRatio then
        goto init;
    end
    if coinTransRatio then
        otherAttributes.petCoinTransRage  = coinTransRatio;
    end
    if chiTransRatio then
        otherAttributes.chiTransRatio = chiTransRatio;
    end
    self:setValue("AllPetAttr", self:getValue("AllPetAttr"));
    do
        return;
    end
    ::init::
    otherAttributes.petCoinTransRage = cfg.coinTransRatio;
    otherAttributes.petChiTransRate = cfg.chiTransRatio;
    self:setValue("AllPetAttr", self:getValue("AllPetAttr"));
end

function Player:getNewPlusPet(ID, plusPetATKRate)
    local otherAttributes = getPet(self, petType.plusPet, ID);
    local cfg = Entity.GetCfg(turnID2Plugin(petType.plusPet, ID));
    if plusPetATKRate then
        otherAttributes.plusPetATKRate = plusPetATKRate;
    else
        otherAttributes.plusPetATKRate = cfg.atkBuffNum;
    end
    self:setValue("AllPetAttr", self:getValue("AllPetAttr"));
end

function Player:callPet(index, rideIndex)
    local petSetting = player:getValue("AllPetAttr")[index];
    local plugin = turnID2Plugin(petSetting.petType, petSetting.ID);
    local createIndex = self:createPet(plugin, true);
    if rideIndex > 2 or rideIndex < 1 then
        Lib.log("=======Wrong pet rideIndex :" .. rideIndex .. "=======");
        return;
    end
    if petSetting.petType == petType.pet then
        local equipPetList = self:getValue("PetEquippedList");
        equipPetList[createIndex] = index;
        self:setValue("PetEquippedList", equipPetList);
    else
        self:setValue("PlusPetEquippedIndex", index);
    end
    self.equipPetList[createIndex] = index;

    local petEntity = self:getPet(createIndex);
    petEntity:rideOn(self, false, rideIndex);
end

function Player:syncPet()
    local list = {}
    local packet = {
        pid = "PetList",
        list = list,
    }
    for index, entity in pairs(self:data("pet")) do
        list[index] = { objID = entity.objID, petIndex = self.equipPetList[index] };
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
