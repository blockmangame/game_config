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
 level = 0,           --当前强化等级
 petCoinTransRate = 1,--该宠物Entity当前的金币增益
 petChiTransRate = 1, --该宠物Entity当前的气增益
 plusPetATKRate = 1}, --该式神Entity当前的攻击倍率增益
--]]
local function getPet(player, type, petID, minorID)
    if type == petType.pet then                                 --检查页数是否满足
        local curPetNu = 0;
        for _, v in pairs(player:getAllPetAttr()) do
            if v.petType == petType.pet then
                curPetNu = curPetNu + 1
            end
        end
        if (curPetNu + 1) > (player:getPetPageNu() * 12) then
            return false
        end
    end
    local allEntityNum = player:getValue("hadEntityNum") + 1;
    player:setValue("hadEntityNum", allEntityNum);
    local AllPetAttr = player:getValue("allPetAttr");
    AllPetAttr[allEntityNum] = {
        ID = petID,
        minorID = minorID,
        petType = type,
        level = 0
    };
    return AllPetAttr, allEntityNum;
end

function Player:getNewPet(ID, coinTransRatio, chiTransRatio, level, isNotSync)
    local allAttribs, index = getPet(self, petType.pet, ID);
    if not index then
        return false                                                                --背包容量不足
    end
    local cfg = Entity.GetCfg(Player.turnID2Plugin(petType.pet, ID));
    if coinTransRatio then
        allAttribs[index].petCoinTransRate  = coinTransRatio;
    else
        allAttribs[index].petCoinTransRate = cfg.coinTransRatio;
    end
    if chiTransRatio then
        allAttribs[index].chiTransRatio = chiTransRatio;
    else
        allAttribs[index].chiTransRatio = cfg.chiTransRatio;
    end
    if level then
        allAttribs[index].level = level
    end
    self:setValue("allPetAttr", allAttribs, isNotSync ~= true);         --当强化时不主动发送同步包而是手动合并发送和处理
    return index
end

function Player:getNewPlusPet(ID, minorID, plusPetATKRate, level, isNotSync)
    minorID = minorID or 0
    local allAttribs, index = getPet(self, petType.plusPet, ID, minorID);
    print(Player.turnID2Plugin(petType.plusPet, ID, minorID))
    local cfg = Entity.GetCfg(Player.turnID2Plugin(petType.plusPet, ID, minorID));
    if plusPetATKRate then
        allAttribs[index].plusPetATKRate = plusPetATKRate;
    else
        allAttribs[index].plusPetATKRate = cfg.atkBuffNum;
    end
    if level then
        allAttribs[index].level = level
    end
    self:setValue("allPetAttr", allAttribs, isNotSync ~= true);
end

function Player:callPet(index, rideIndex)
    local petSetting = self:getValue("allPetAttr")[index];
    local plugin = Player.turnID2Plugin(petSetting.petType, petSetting.ID);
    local createIndex = self:createPet(plugin, true);
    if rideIndex > 3 or rideIndex < 1 then
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
    self.equipPetList[rideIndex] = {index = index, objID = createIndex}

    local petEntity = self:getPet(createIndex);
    petEntity:rideOn(self, false, rideIndex);
end

function Player:initPetInfo()
    for rideIndex, index in pairs(self:getValue("petEquippedList")) do
        self:callPet(index, rideIndex)
    end
end

function Player:addPet(entity, index)
    self:syncPet()
    return index
end

function Player:syncPet()
    local list = {}
    print(Lib.v2s(self.equipPetList))
    for index, entity in pairs(self.equipPetList) do
        list[index] = entity
    end
    local packet = {
        pid = "PetList",
        list = list,
    }
    self:sendPacket(packet)
end

function Player:recallPet(index)
    for ridePoint, V in pairs(self.equipPetList) do
        if index == V.index then
            self.equipPetList[ridePoint] = nil
            if self:getValue("plusPetEquippedIndex") == index then
                self:setValue("plusPetEquippedIndex", 0)
            end
            local tempPetEquipList = self:getValue("petEquippedList")
            for k, v in pairs(tempPetEquipList) do
                if v == index then
                    tempPetEquipList[k] = nil
                    self:setValue("petEquippedList", tempPetEquipList)
                end
            end
            self:removePet(V.objID);
            self:syncPet()
            print(Lib.v2s( self.equipPetList))
            return;
        end
    end
    Lib.log("=======Pet remove fail index :" .. index .. " could not find it=======");
end

function Player:deletePet(index)
    if self:getPetAttr(index) then
        local tempData = self:getValue("allPetAttr")
        tempData[index] = nil
        self:setValue("allPetAttr", tempData)
    end
end

function Player:sendEvolutionPackage(index)
    local def = Entity.ValueDef["allPetAttr"]
    local packet = {
        pid = "AttrValuePro",
        key = "allPetAttr",
        value = self:getAllPetAttr(),
        isBigInteger = type(value) == "table" and value.IsBigInteger,
        objID = self.objID,
        newIndex = index
    }
    local toSelf = def[3] and self.isPlayer
    if def[4] then
        self:sendPacketToTracking(packet, toSelf)
    elseif toSelf then
        self:sendPacket(packet)
    end
end

function Player:petEvolution(package)
    local target = package.target
    local materials = package.materials
    local evoCoinNu = {}
    local evoChiNu = {}
    local minCoin, maxCoin, minFu, maxFu = 0, 0, 0, 0
    for _, v in pairs(materials) do
        local tempData = self:getPetAttr(v)
        if tempData.petType == petType.plusPet then
            print("ERROR!!!!! WRONG PET TYPE!!!! Evolution terminate!!!!!!")
            self:closePetEvolution()
            return
        end
        local coinIntensifyRange = Lib.split(tempData.coinIntensifyRange, "#")
        local chiIntensifyRange = Lib.split(tempData.chiIntensifyRange, "#")
        minCoin = minCoin + tonumber(coinIntensifyRange[1])
        maxCoin = maxCoin + tonumber(coinIntensifyRange[2])
        minFu = minFu + tonumber(chiIntensifyRange[1])
        maxFu = maxFu + tonumber(chiIntensifyRange[2])
        table.insert(evoCoinNu, tempData.coinTransRatio)
        table.insert(evoChiNu, tempData.chiTransRatio)
    end
    local tempData = self:getPetAttr(target)
    local index = self:getNewPet(tempData.ID, tempData.coinTransRatio, tempData.chiTransRatio, tempData.level + 1, true)
    if not index then
        print("Error When Evolute Pet Cannot get correct index:", index)
    end
    self:sendEvolutionPackage(index)
end
