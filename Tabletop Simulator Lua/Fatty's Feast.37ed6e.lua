local CHALLENGE_MODULE = nil

local CONTENT_TABLE = {
    BOSS = "4854ae",
    RULE = "d58cdb",
    COUNTER = "912491",
    --skip for better performance
    --MANUAL = "6a4886"
}

local DIF_TO_STATE = {
    BOSS = {
        DIF_NORMAL = 1,
        DIF_HARD = 2,
        DIF_ULTRA = 3,
        DIF_COMP = 3    --TODO it is 4
    },
    RULE = {
        DIF_NORMAL = 1,
        DIF_HARD = 2,
        DIF_ULTRA = 2,
        DIF_COMP = 2    --TODO it is 3
    }
}

HAS_SEP_COMP_MODE = true

local DIF_TO_TURN_END_FUNCTION = {
    DIF_NORMAL = "call_turnEndFunction_NORMAL",
    DIF_HARD = "call_turnEndFunction_HARD_ULTRA",
    DIF_ULTRA = "call_turnEndFunction_HARD_ULTRA",
    DIF_COMP = "call_turnEndFunction_COMP"
}

local DIF_TO_TURN_START_FUNCTION = {
    DIF_NORMAL = "call_turnStartFunction_NORMAL",
    DIF_HARD = "call_turnStartFunction_HARD",
    DIF_ULTRA = "call_turnStartFunction_ULTRA",
    DIF_COMP = "call_turnStartFunction_COMP"
}

local DIF_TO_NEW_MONSTER_FUNCTION = {
    DIF_NORMAL = "call_newMonsterFunction_NORMAL_HARD_ULTRA",
    DIF_HARD = "call_newMonsterFunction_NORMAL_HARD_ULTRA",
    DIF_ULTRA = "call_newMonsterFunction_NORMAL_HARD_ULTRA",
    DIF_COMP = "call_newMonsterFunction_COMP"
}

MINION_SLOT_FATTY = nil

local bossHP = 0
local bossMaxHP = 0

function onLoad(saved_data)
    CHALLENGE_MODULE = getObjectFromGUID(Global.getVar("CHALLENGE_MODULE"))

    if saved_data == "" then
        return
    end
    local loaded_data = JSON.decode(saved_data)
    if loaded_data.bossMaxHP then
        bossMaxHP = loaded_data.bossMaxHP
    end
    if loaded_data.bossHP then
        bossHP = loaded_data.bossHP
    end
end

function onSave()
    return JSON.encode({bossMaxHP = bossMaxHP, bossHP = bossHP})
end

local function extractContent(difficulty)
    local extractedContent = {}
    for id, guid in pairs(CONTENT_TABLE) do
        local object = self.takeObject({guid = guid})
        if object then
            if DIF_TO_STATE[id] then
                local currentStateID = object.getStateId()
                if (currentStateID > 0) and (currentStateID ~= DIF_TO_STATE[id][difficulty]) then
                    object = object.setState(DIF_TO_STATE[id][difficulty])
                end
            end
            extractedContent[id] = object
        end
    end
    return extractedContent
end

function presetupChallenge(params)
    local extractedContent = extractContent(params.difficulty)
    CHALLENGE_MODULE.call("placeChallengeContent", extractedContent)
    self.setPositionSmooth(Global.getTable("CHALLENGE_LEFTOVERS_POSITION"), false)

    Wait.frames(function()
        bossHP = extractedContent.BOSS.getVar("hp")
        bossMaxHP = bossHP
    end)

    local counterBagGuids = Global.getTable("COUNTER_BAGS_GUID")
    counterBagGuids["FEAST"] = CONTENT_TABLE.COUNTER
    Global.setTable("COUNTER_BAGS_GUID", counterBagGuids)

    MINION_SLOT_FATTY = CHALLENGE_MODULE.call("addMinionSlot", {name = "Fatties"})

    if (params.difficulty == "DIF_COMP") then
        CHALLENGE_MODULE.call("activatePlayerMinionZones")
    end
end

function setupChallengeZones(params)
    local monsterGUIDs = params.preDeckGUIDs.MONSTER
    local noGoTags = params.filterTags

    for _, guid in pairs(monsterGUIDs) do
        local preDeck = getObjectFromGUID(guid)
        if preDeck then
            for _, infoTable in pairs(preDeck.getObjects()) do
                if string.match(infoTable.gm_notes, "mega_fatty") then
                    self.putObject(preDeck.takeObject({guid = infoTable.guid}))
                elseif string.match(infoTable.gm_notes, "fatty") then
                    local isCardGood = true
                    for _, tag in pairs(infoTable.tags) do
                        if noGoTags[tag] == false then
                            isCardGood = false
                            break
                        end
                    end
                    if isCardGood then
                        local newFattyMinion = preDeck.takeObject({guid = infoTable.guid})
                        MINION_SLOT_FATTY.call("addMinion", {card = newFattyMinion, shuffle = true})
                    end
                end
            end
        end
    end
end

function setupChallenge(params)
    local bossZone = CHALLENGE_MODULE.call("getBossZone")
    if params.difficulty == "DIF_COMP" then
        for color, guid in pairs(Global.getTable("ZONE_GUID_PLAYER")) do
            local zone = getObjectFromGUID(guid)
            if zone and zone.getVar("active") then
                local minionCard = MINION_SLOT_FATTY.call("getMinion")
                if minionCard then
                    bossZone.call("placeMinion", {card = minionCard, zoneOwner = color})
                end
            end
        end
    else
        for i=1, 4 do
            local minionCard = MINION_SLOT_FATTY.call("getMinion")
            if minionCard then
                bossZone.call("placeMinion", {card = minionCard})
            end
        end
    end

    Global.call("addTurnEvent", {atEnd = false, function_owner = self.getGUID()
        , call_function = DIF_TO_TURN_START_FUNCTION[params.difficulty], function_params = {difficulty = params.difficulty}})
    Global.call("addTurnEvent", {atEnd = true, function_owner = self.getGUID()
        , call_function = DIF_TO_TURN_END_FUNCTION[params.difficulty], function_params = {difficulty = params.difficulty}})

    local monsterDeckZone = getObjectFromGUID(Global.getTable("ZONE_GUID_DECK").MONSTER)
    if monsterDeckZone then
        monsterDeckZone.call("addNewMonsterEvent", {function_owner = self.getGUID()
            , call_function = DIF_TO_NEW_MONSTER_FUNCTION[params.difficulty], function_params = {difficulty = params.difficulty}})
    end
end

------------------------------------------------------------------------------------------------------------------------
local function getRandomMonsterZone()
    local activeMonsterZones = {}
    for _, guid in pairs(Global.getTable("ZONE_GUID_MONSTER")) do
        local monsterZone = getObjectFromGUID(guid)
        if monsterZone and monsterZone.getVar("active") then
            table.insert(activeMonsterZones, monsterZone)
        end
    end

    if #activeMonsterZones == 0 then
        return nil
    end
    return activeMonsterZones[math.random(#activeMonsterZones)]
end

local function getRandomMinionZone()
    local activeMinionZones = {}
    for _, infoTable in pairs(Global.getTable("ZONE_INFO_MINION")) do
        local minionZone = getObjectFromGUID(infoTable.guid)
        if minionZone and minionZone.getVar("active") then
            table.insert(activeMinionZones, minionZone)
        end
    end

    if #activeMinionZones == 0 then
        return nil
    end
    return activeMinionZones[math.random(#activeMinionZones)]
end

local function getRandomMonsterOrMinionZone(exceptedZoneGuid)
    local activeMinionZones = {}
    for _, infoTable in pairs(Global.getTable("ZONE_INFO_MINION")) do
        if infoTable.guid ~= exceptedZoneGuid then
            local minionZone = getObjectFromGUID(infoTable.guid)
            if minionZone and minionZone.getVar("active") then
                table.insert(activeMinionZones, minionZone)
            end
        end
    end

    local activeMonsterZones = {}
    for _, guid in pairs(Global.getTable("ZONE_GUID_MONSTER")) do
        if guid ~= exceptedZoneGuid then
            local monsterZone = getObjectFromGUID(guid)
            if monsterZone and monsterZone.getVar("active") then
                table.insert(activeMonsterZones, monsterZone)
            end
        end
    end

    local randomIndex = math.random(#activeMinionZones + #activeMonsterZones)
    if (#activeMinionZones + #activeMonsterZones) == 0 then
        return nil
    end
    if randomIndex <= #activeMinionZones then
        return {zone = activeMinionZones[randomIndex], isMinion = true}
    else
        return {zone = activeMonsterZones[randomIndex - #activeMinionZones], isMinion = false}
    end
end

local realFeastCount = {}

local function getMinionZoneFeastCounterTable()
    local infoTable = {}
    for _, zoneInfo in pairs(Global.getTable("ZONE_INFO_MINION")) do
        local minionZone = getObjectFromGUID(zoneInfo.guid)
        if minionZone and minionZone.getVar("active") then
            local feastCount = realFeastCount[zoneInfo.guid]
            if feastCount == nil then
                feastCount = 0
                for _, obj in pairs(minionZone.getObjects()) do
                    if obj.hasTag("FEAST") then
                        if obj.getQuantity() == -1 then
                            feastCount = feastCount + 1
                        else
                            feastCount = feastCount + obj.getQuantity()
                        end
                    end
                end
            end
            table.insert(infoTable, {zone = minionZone, feast = feastCount})
        end
    end
    return infoTable
end

function call_turnEndFunction_NORMAL(_)
    local bossZone = CHALLENGE_MODULE.call("getBossZone")
    bossHP = bossZone.call("getLeftoverHP")

    local zoneInfo = getRandomMonsterOrMinionZone()
    local leftoverHP = zoneInfo.zone.call("getLeftoverHP")
    if zoneInfo.isMinion then
        zoneInfo.zone.call("discardActiveMonster")
    else
        local monsterDeckZone = getObjectFromGUID(Global.getTable("ZONE_GUID_DECK").MONSTER)
        monsterDeckZone.call("discardActiveMonsterCard", {zone = zoneInfo.zone})
    end
    local feastCount = Global.call("placeCounterInZone", {zone = bossZone, type = "FEAST", amount = leftoverHP})
    local bossCard = bossZone.call("getActiveMonsterCard")
    if bossCard then
        bossMaxHP = bossCard.getVar("hp") + feastCount
        bossHP = bossHP + leftoverHP
    end
end

function call_turnEndFunction_HARD_ULTRA(params)
    local bossZone = CHALLENGE_MODULE.call("getBossZone")
    bossHP = bossZone.call("getLeftoverHP")

    local monsterDeckZone = getObjectFromGUID(Global.getTable("ZONE_GUID_DECK").MONSTER)
    local selectedMinionZone = getRandomMinionZone()
    local selectedMonsterZone = nil
    if selectedMinionZone then
        selectedMonsterZone = getRandomMonsterZone()
    end

    local zoneInfo_BossFeast = nil
    if selectedMonsterZone == nil then
        zoneInfo_BossFeast = getRandomMonsterOrMinionZone()
    else
        zoneInfo_BossFeast = getRandomMonsterOrMinionZone(selectedMonsterZone.getGUID())
    end
    local leftoverHP_BossFeast = 0

    if selectedMinionZone then
        local leftoverHP = selectedMonsterZone.call("getLeftoverHP")
        monsterDeckZone.call("discardActiveMonsterCard", {zone = selectedMonsterZone})
        if zoneInfo_BossFeast and (zoneInfo_BossFeast.zone.getGUID() == selectedMinionZone.getGUID()) then
            leftoverHP_BossFeast = leftoverHP_BossFeast + leftoverHP
        else
            local feastCount = Global.call("placeCounterInZone", {zone = selectedMinionZone, type = "FEAST", amount = leftoverHP})
            realFeastCount = {}
            realFeastCount[selectedMinionZone.getGUID()] = feastCount
        end
    end

    if zoneInfo_BossFeast == nil then
        return
    end

    leftoverHP_BossFeast = leftoverHP_BossFeast + zoneInfo_BossFeast.zone.call("getLeftoverHP")

    if zoneInfo_BossFeast.isMinion then
        zoneInfo_BossFeast.zone.call("discardActiveMonster")
    else
        local monsterDeckZone = getObjectFromGUID(Global.getTable("ZONE_GUID_DECK").MONSTER)
        monsterDeckZone.call("discardActiveMonsterCard", {zone = zoneInfo_BossFeast.zone})
    end

    local feastCount_BossFeast = Global.call("placeCounterInZone", {zone = bossZone, type = "FEAST", amount = leftoverHP_BossFeast})
    local bossCard = bossZone.call("getActiveMonsterCard")
    if bossCard then
        bossMaxHP = bossCard.getVar("hp") + feastCount_BossFeast
        bossHP = bossHP + leftoverHP_BossFeast
    end
end

function call_turnStartFunction_NORMAL(_)
    local bossZone = CHALLENGE_MODULE.call("getBossZone")
    bossHP = bossZone.call("editHP", {hp = bossHP})

    for _, infoTable in pairs(Global.getTable("ZONE_INFO_MINION")) do
        local minionZone = getObjectFromGUID(infoTable.guid)
        if minionZone and minionZone.getVar("active") then
            minionZone.call("editHP", {modifier = 2})
        end
    end
end

function call_turnStartFunction_HARD(_)
    local bossZone = CHALLENGE_MODULE.call("getBossZone")
    bossHP = bossZone.call("editHP", {hp = bossHP})

    for _, infoTable in pairs(getMinionZoneFeastCounterTable()) do
        infoTable.zone.call("editHP", {modifier = math.floor(infoTable.feast / 2) + 2})
    end
end

function call_turnStartFunction_ULTRA(_)
    local bossZone = CHALLENGE_MODULE.call("getBossZone")
    bossHP = bossZone.call("editHP", {hp = math.min(bossHP + 2, bossMaxHP)})

    for _, infoTable in pairs(getMinionZoneFeastCounterTable()) do
        infoTable.zone.call("editHP", {modifier = infoTable.feast + 2})
    end
end

function call_newMonsterFunction_NORMAL_HARD_ULTRA(params)
    if params.isMinion then
        local minionZone = params.zone
        if minionZone.getVar("active") then
            minionZone.call("editHP", {modifier = 2})
        end
    end
end

local zoneGuidToMinionHP = nil

function call_turnEndFunction_COMP(params)
    zoneGuidToMinionHP = {}
    local minionZoneInfo = Global.getTable("ZONE_INFO_MINION")
    local monsterDeckZone = getObjectFromGUID(Global.getTable("ZONE_GUID_DECK").MONSTER)
    for zoneIndex, zoneInfo in pairs(minionZoneInfo) do
        local minionZone = getObjectFromGUID(zoneInfo.guid)
        if minionZone and minionZone.getVar("active") then
            leftoverMinionHP = minionZone.call("getLeftoverHP")

            local selectedZone = getRandomMonsterZone()
            local leftoverMonsterHP = selectedZone.call("getLeftoverHP")
            monsterDeckZone.call("discardActiveMonsterCard", {zone = selectedZone})
            local feastCount = Global.call("placeCounterInZone", {zone = minionZone, type = "FEAST", amount = leftoverMonsterHP})
            zoneGuidToMinionHP[zoneIndex] = math.min(leftoverMinionHP + leftoverMonsterHP, 7 + feastCount)
        end
    end
end

function call_turnStartFunction_COMP(_)
    local minionZoneInfo = Global.getTable("ZONE_INFO_MINION")
    if zoneGuidToMinionHP == nil then
        for zoneIndex, zoneInfo in pairs(minionZoneInfo) do
            local minionZone = getObjectFromGUID(zoneInfo.guid)
            if minionZone and minionZone.getVar("active") then
                minionZone.call("editHP", {hp = 7})
            end
        end
    else
        for zoneIndex, minionHp in pairs(zoneGuidToMinionHP) do
            local minionZone = getObjectFromGUID(minionZoneInfo[zoneIndex].guid)
            if minionZone then
                minionZone.call("editHP", {hp = minionHp})
            end
        end
    end
end

function call_newMonsterFunction_COMP(params)
    if params.isMinion then
        local minionZone = params.zone
        if minionZone.getVar("active") then
            minionZone.call("editHP", {hp = 7})
        end
    end
end