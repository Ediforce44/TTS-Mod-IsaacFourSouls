local CHALLENGE_MODULE = nil

local CONTENT_TABLE = {
    BOSS = "18066a",
    RULE = "58257e",
    --skip for better performance
    --MANUAL = "9d3835"
}

local DIF_TO_STATE = {
    BOSS = {
        DIF_NORMAL = 1,
        DIF_HARD = 2,
        DIF_ULTRA = 3,
        DIF_COMP = 4
    },
    RULE = {
        DIF_NORMAL = 1,
        DIF_HARD = 2,
        DIF_ULTRA = 3,
        DIF_COMP = 4
    }
}

HAS_SEP_COMP_MODE = true

local DIF_TO_TURN_FUNCTION = {
    DIF_NORMAL = "call_turnStartFunction_NORMAL_HARD_ULTRA",
    DIF_HARD = "call_turnStartFunction_NORMAL_HARD_ULTRA",
    DIF_ULTRA = "call_turnStartFunction_NORMAL_HARD_ULTRA",
    DIF_COMP = "call_turnStartFunction_COMP"
}

local DIF_TO_NEW_MONSTER_FUNCTION = {
    DIF_NORMAL = "call_newMonsterFunction_NORMAL_HARD_ULTRA",
    DIF_HARD = "call_newMonsterFunction_NORMAL_HARD_ULTRA",
    DIF_ULTRA = "call_newMonsterFunction_NORMAL_HARD_ULTRA",
    DIF_COMP = "call_newMonsterFunction_COMP"
}

local DIF_TO_DIE_FUNCTION = {
    DIF_NORMAL = "call_dieFunction_NORMAL_HARD_ULTRA",
    DIF_HARD = "call_dieFunction_NORMAL_HARD_ULTRA",
    DIF_ULTRA = "call_dieFunction_NORMAL_HARD_ULTRA",
    DIF_COMP = "call_dieFunction_COMP"
}

function onLoad(saved_data)
    CHALLENGE_MODULE = getObjectFromGUID(Global.getVar("CHALLENGE_MODULE"))
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

    CHALLENGE_MODULE.call("allowEventMinions")

    if params.difficulty == "DIF_COMP" then
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
                if string.match(infoTable.gm_notes, "mask_of_infamy") then
                    self.putObject(preDeck.takeObject({guid = infoTable.guid}))
                end
            end
        end
    end
end

function setupChallenge(params)
    Global.call("addTurnEvent", {atEnd = false, function_owner = self.getGUID()
        , call_function = DIF_TO_TURN_FUNCTION[params.difficulty]})
    local monsterDeckZone = getObjectFromGUID(Global.getTable("ZONE_GUID_DECK").MONSTER)
    if monsterDeckZone then
        monsterDeckZone.call("addNewMonsterEvent", {function_owner = self.getGUID()
            , call_function = DIF_TO_NEW_MONSTER_FUNCTION[params.difficulty], function_params = {difficulty = params.difficulty}})
        monsterDeckZone.call("addDieEvent", {function_owner = self.getGUID()
            , call_function = DIF_TO_DIE_FUNCTION[params.difficulty], function_params = {difficulty = params.difficulty}})
    end
end

------------------------------------------------------------------------------------------------------------------------

function call_turnStartFunction_NORMAL_HARD_ULTRA(_)
    local bossZone = CHALLENGE_MODULE.call("getBossZone")

    local activeMinionSlots = 0
    for _, zoneInfo in pairs(Global.getTable("ZONE_INFO_MINION")) do
        if getObjectFromGUID(zoneInfo.guid).getVar("active") then
            activeMinionSlots = activeMinionSlots + 1
        end
    end

    bossZone.call("editHP", {modifier = activeMinionSlots})
end

function call_turnStartFunction_COMP(params)
    local bossZone = CHALLENGE_MODULE.call("getBossZone")

    local activeMinionSlots = 0
    for _, zoneInfo in pairs(Global.getTable("ZONE_INFO_MINION")) do
        if (zoneInfo.owner == params.playerColorStart) and getObjectFromGUID(zoneInfo.guid).getVar("active") then
            activeMinionSlots = activeMinionSlots + 1
        end
    end

    bossZone.call("editHP", {modifier = activeMinionSlots})
end

function call_newMonsterFunction_NORMAL_HARD_ULTRA(params)
    if params.isMinion then
        local minionZone = params.zone
        if minionZone.getVar("active") then
            local bossZone = CHALLENGE_MODULE.call("getBossZone")
            bossZone.call("editHP", {modifier = 1})
        end
    end
end

function call_newMonsterFunction_COMP(params)
    if params.isMinion then
        local minionZone = params.zone
        if minionZone.getVar("active") then
            for _, zoneInfo in pairs(Global.getTable("ZONE_INFO_MINION")) do
                if zoneInfo.guid == minionZone.getGUID() then
                    if Global.getVar("activePlayerColor") == zoneInfo.owner then
                        local bossZone = CHALLENGE_MODULE.call("getBossZone")
                        bossZone.call("editHP", {modifier = 1})
                    end
                end
            end
        end
    end
end

function call_dieFunction_NORMAL_HARD_ULTRA(params)
    if params.isMinion then
        local minionZone = params.zone
        if minionZone.getVar("active") then
            local bossZone = CHALLENGE_MODULE.call("getBossZone")
            if bossZone.call("getLeftoverHP") > bossZone.call("getActiveMonsterCard").getVar("hp") then
                bossZone.call("editHP", {modifier = -1})
            end
        end
    end
end

function call_dieFunction_COMP(params)
    if params.isMinion then
        local minionZone = params.zone
        if minionZone.getVar("active") then
            for _, zoneInfo in pairs(Global.getTable("ZONE_INFO_MINION")) do
                if zoneInfo.guid == minionZone.getGUID() then
                    if Global.getVar("activePlayerColor") == zoneInfo.owner then
                        local bossZone = CHALLENGE_MODULE.call("getBossZone")
                        if bossZone.call("getLeftoverHP") > bossZone.call("getActiveMonsterCard").getVar("hp") then
                            bossZone.call("editHP", {modifier = -1})
                        end
                    end
                end
            end
        end
    end
end