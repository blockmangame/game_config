local BehaviorTree = require("common.behaviortree")
local Actions = BehaviorTree.Actions

function Actions.ShowHomeGuide(data, params, context)
    local entity = params.entity
    local pos
    if entity then
        pos = entity:getPosition()
        pos.map = entity.map.name
    end
    local player = params.player
    player:sendPacket({
        pid = "ShowHomeGuide",
        pos = pos
    })
end

function Actions.ShowHomeGuide(data, params, context)
    local entity = params.entity
    local pos
    if entity then
        pos = entity:getPosition()
        pos.map = entity.map.name
    end
    local player = params.player
    player:sendPacket({
        pid = "ShowHomeGuide",
        pos = pos
    })
end

function Actions.ShowSingleTeamUI(data, params, context)
    local entity = params.entity
    if not entity then
        return
    end

    entity:sendPacket({
        pid = "ShowSingleTeamUI",
        info = params.info,
        show = params.show
    })

end

function Actions.ShowTeamUI(data, params, context)
    params.entity:sendPacket({
        pid = "ShowTeamUI",
        show = params.show == nil and true or params.show,
        info = params.info
    })
end

local _getObjVar = function(obj, key)
    return obj and key and obj.vars[key]
end

local _getSkillVar = function(skillName, key)
    local skill = Skill.Cfg(skillName)
    return (skill and {skill[key]} or {nil})[1]
end

local _getStateReleaseData = function(player, state)
    if not player or not player:isValid() or not player.isPlayer then
        return nil
    end
    if not _getObjVar(player, state.."got") then
        return nil
    end
    local isReleasing = _getObjVar(player, "releasing"..state) or false
    local sTime = _getObjVar(player, state.."STime")
    local usedTime = _getObjVar(player, state.."UsedTime") or 0
    if sTime and usedTime >= 0 then
        usedTime = os.time() - sTime + usedTime
    end
    return usedTime, isReleasing
end

function Actions.ShowProgressFollowObj(data, params, context)
    local player = params.entity
    if not player or not player:isValid() or not player.isPlayer then
        return
    end

    local playerList = {}
    playerList[player.objID] = player

    -- 找出和player有交互的玩家, 需要同步头顶条状态
    local pgName = params.pgName
    local isOpen = params.isOpen
    local teamId = player:getValue("teamId")
    if params.type and params.type == "state" then
        local skillPath = "myplugin/skill_state_"..pgName
        local stateBase = _getSkillVar(skillPath, "stateBase") or pgName
        local rewardCount = _getSkillVar(skillPath, "rewardCount")
        local rewardDis = _getSkillVar(skillPath, "rewardDis")
        local interactionList = params.interactionList or _getObjVar(player, stateBase.."InteractList") or {}
        for _, v in pairs(interactionList) do
            local obj = World.CurWorld:getObject(v)
            local objRewardCount = _getObjVar(obj, stateBase.."RewardCount") or 0
            if obj and obj:isValid() and obj.isPlayer and (not isOpen or (obj:getValue("teamId") == teamId
                    and player.map == obj.map and objRewardCount < rewardCount and player:distance(obj) < rewardDis)) then
                playerList[v] = obj
            end
        end
    end

    local packet = {
        pid = "ShowProgressFollowObj",
        objID = player.objID,
        pgName = pgName,
        isOpen = isOpen,
        pgImg = params.pgImg,
        pgBackImg = params.pgBackImg,
        usedTime = params.usedTime,
        totalTime = params.totalTime,
        pgText = params.pgText,
    }

    for _, entity in pairs(playerList) do
        entity:sendPacket(packet)
    end
end

function Actions.ShowDetails(data, params, content)
    local player = params.player
    if not player or not player:isValid() or not player.isPlayer then
        return
    end
    local detailsUI = _getObjVar(player, "detailsUI")
    local state = params.state or detailsUI
    if not state or detailsUI ~= state then
        return
    end
    local skillName = "myplugin/skill_state_"..state
    local duration = _getSkillVar(skillName, "duration") or 0
    local packet = {
        pid = "ShowDetails",
        isOpen = false
    }
    local shouldSyncPlayers = {player}
    local target = params.target
    if target and not params.isRemoveTarget then
        table.insert(shouldSyncPlayers, target)
    end
    local subtitle = {}
    for _, v in pairs(shouldSyncPlayers) do
        local usedTime, isReleasing = _getStateReleaseData(v, state)
        if usedTime ~= nil then
            packet.isOpen = true
            table.insert(subtitle, { objID = v.objID, usedTime = usedTime*20, duration = duration*20, isReleasing = isReleasing })
        end
    end
    if packet.isOpen then
        packet.fullName = "myplugin/"..state.."Detail"
        packet.contents = {
            subtitle = subtitle,
            commentsVal = _getSkillVar(skillName, "rewardSelf"),
            commentsCurrencyIcon = _getSkillVar(skillName, "rewardType")
        }
    end
    player:sendPacket(packet)
end

function Actions.SyncStatesData(data, params, context)
    local player = params.player
    local target = params.target
    for _, v in pairs({player, target}) do
        if not v or not v:isValid() or not v.isPlayer then
            return
        end
    end
    local states = {}
    local isAdd = params.isAdd
    local isWithoutCheck = params.isWithoutCheck or not params.states
    local tmpStates = params.states or _getObjVar(target, "curStates")
    --如果有声明isWithoutCheck为true或者为target.curStates则不需要再去检查states里的状态是否为target获得的了
    if not isWithoutCheck and isAdd then
        for _, v in pairs(states) do
            if _getObjVar(target, v.."got") then
                table.insert(states, v)
            end
        end
    end
    player:sendPacket({
        pid = "SyncStatesData",
        data = {
			isAdd = isAdd,
			states = (isWithoutCheck and {tmpStates} or {states})[1],
			targetID = target.objID
		},
    })
end

function Actions.UpdateUIData(data, params, content)
    params.player:sendPacket({pid = "UpdateUIData", ui = params.ui, data = params.data})
end

function Actions.ShowInviteTipByScript(data, params, context)
    local player = params.player
    local modName = "ShowInviteTip" .. (params.pic or "") .. (params.fullName or "") .. World.Now() .. os.time() .. math.random(0, 99999)
    local regId = player:regCallBack(modName, params.eventMap, true, true, params.context)
    player:sendPacket({
        pid = "ShowInviteTipByScript",
        regId = regId,
        pic = params.pic,
        titleText = params.titleText,
        content = params.content,
        buttonInfo = params.buttonInfo,
        fullName = params.fullName,
        time = params.showTime,
        modName = modName
    })
end

function Actions.ShowDialogTip(data, params, context)
    local arg = {}
    local num = 1
    while params["p" .. num] ~= nil do
        table.insert(arg, params["p" .. num])
        num = num + 1
    end
    params.entity:showDialogTip(params.tipType, params.event, arg, params.context, params.dialogContinuedTime)
end

function Actions.ShowRewardDialog(data, params, context)
    local player = params.player
    if not player then
        return
    end

    local regId = nil
    if params.event then
        regId = player:regCallBack("rewardTipDialog", { rewardTip = params.event}, true, true)
    end

    player:sendPacket({
        pid = "ShowRewardDialog",
        regId = regId,
    })
end

function Actions.ShowGuidePop(data, params, context)
    local player = params.player
    if not player then
        return
    end
    local regId = player:regCallBack("ShowGuidePop", {["sure"] = params.event or false}, true, true, params.context)
    player:sendPacket({
        pid = "ShowGuidePop",
        regId = regId,
        texts = params.texts,
        btnText = params.btnText
    })
end

function Actions.OpenMainExtension(data, params, context)
    local player = params.player
    if not player then
        return
    end
    local open = params.open
    if open == nil then
        open = true
    end
    player:sendPacket({
        pid = "OpenMainExtension",
        open = open
    })
end

function Actions.HideCloseGPS(data, params, context)
    params.player:sendPacket({
        pid = "HideCloseGPS",
        hide = params.hide
    })
end

function Actions.ShowWhiteScreen(data, params, context)
    params.player:sendPacket({
        pid = "ShowWhiteScreen",
    })
end

function Actions.ShowRewardCD(data, params, context)
    params.player:sendPacket({pid = "ShowRewardCD", time = params.time})
end

function Actions.ShowStateUI(data, params, context)
    params.player:sendPacket({pid = "ShowStateUI"})
end

function Actions.UseDressArchive(data, params, context)
    params.player:sendPacket({pid = "UseDressArchive", index = params.index})
end

function Actions.ShowBubbleMsg(data, params, context)
    local entity = params.entity
    if not entity then
        return
    end

    local hide = params.hide
    local contents = params.contents or {}
    local txt = contents.text or {}
    entity:sendPacketToTracking({
        pid = "ShowBubbleMsg",
        objID = entity.objID,
        hide = hide,
        contents = {
            text = {
                params.textKey or txt.textKey or "",
                params.textP1 or txt.textP1 or "",
                params.textP2 or txt.textP2 or "",
                params.textP3 or txt.textP3 or "",
                params.textP4 or txt.textP4 or "",
                params.textP5 or txt.text5P or ""
            },
            image1 = contents.image1 or {},
            image2 = contents.image2 or {},
        },
    }, true)
end
