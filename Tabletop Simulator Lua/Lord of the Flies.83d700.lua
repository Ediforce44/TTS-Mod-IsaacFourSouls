local CHALLENGE_MODULE = nil

local CONTENT_TABLE = {
    BOSS = "942e70",
    RULE = "d2957b",
    COUNTER = "0f34dc",
    COUNTER_TWO = "e0a468"
    --skip for better performance
    --MANUAL = "f8e9df"
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
    DIF_NORMAL = "call_turnEndFunction_NORMAL",
    DIF_HARD = "call_turnEndFunction_HARD_ULTRA",
    DIF_ULTRA = "call_turnEndFunction_HARD_ULTRA",
    DIF_COMP = "call_turnEndFunction_COMP"
}

MINION_SLOT_FLY = nil

local startFlyCounterBoss = {
    DIF_NORMAL = 18,
    DIF_HARD = 14,
    DIF_ULTRA = 18,
    DIF_COMP = 0
}

function onLoad(saved_data)
    CHALLENGE_MODULE = getObjectFromGUID(Global.getVar("CHALLENGE_MODULE"))

    if saved_data == "" then
        return
    end
    local loaded_data = JSON.decode(saved_data)
    if loaded_data.minionSlotGUID then
        MINION_SLOT_FLY = getObjectFromGUID(loaded_data.minionSlotGUID)
    end
end

function onSave()
    if MINION_SLOT_FLY then
        return JSON.encode({minionSlotGUID = MINION_SLOT_FLY.getGUID()})
    end
end

local function extractContent(difficulty)
    local extractedContent = {}
    for id, guid in pairs(CONTENT_TABLE) do
        if (id ~= "COUNTER_TWO") or (difficulty == "DIF_COMP") then
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
    end
    return extractedContent
end

function presetupChallenge(params)
    local extractedContent = extractContent(params.difficulty)
    CHALLENGE_MODULE.call("placeChallengeContent", extractedContent)
    self.setPositionSmooth(Global.getTable("CHALLENGE_LEFTOVERS_POSITION"), false)

    local counterBagGuids = Global.getTable("COUNTER_BAGS_GUID")
    counterBagGuids["FLY"] = CONTENT_TABLE.COUNTER
    counterBagGuids["SWARM"] = CONTENT_TABLE.COUNTER_TWO
    Global.setTable("COUNTER_BAGS_GUID", counterBagGuids)

    if (params.difficulty == "DIF_HARD") or (params.difficulty == "DIF_ULTRA") then
        MINION_SLOT_FLY = CHALLENGE_MODULE.call("addMinionSlot", {name = "Fly Swarm"})
    end
end

function setupChallengeZones(params)
    local monsterGUIDs = params.preDeckGUIDs.MONSTER
    local noGoTags = params.filterTags

    if (params.difficulty == "DIF_HARD") or (params.difficulty == "DIF_ULTRA") then
        for _, guid in pairs(monsterGUIDs) do
            local preDeck = getObjectFromGUID(guid)
            if preDeck then
                for _, infoTable in pairs(preDeck.getObjects()) do
                    if string.match(infoTable.gm_notes, "duke_of_flies") then
                        self.putObject(preDeck.takeObject({guid = infoTable.guid}))
                    elseif string.match(infoTable.gm_notes, "fly") or string.match(infoTable.gm_notes, "flies") then
                        local isCardGood = true
                        for _, tag in pairs(infoTable.tags) do
                            if noGoTags[tag] == false then
                                isCardGood = false
                                break
                            end
                        end
                        if isCardGood then
                            local newFlyMinion = preDeck.takeObject({guid = infoTable.guid})
                            MINION_SLOT_FLY.call("addMinion", {card = newFlyMinion, shuffle = true})
                        end
                    end
                end
            end
        end
    else
        for _, guid in pairs(monsterGUIDs) do
            local preDeck = getObjectFromGUID(guid)
            if preDeck then
                for _, infoTable in pairs(preDeck.getObjects()) do
                    if string.match(infoTable.gm_notes, "duke_of_flies") then
                        self.putObject(preDeck.takeObject({guid = infoTable.guid}))
                    end
                end
            end
        end
    end
end

function setupChallenge(params)
    local bossZone = CHALLENGE_MODULE.call("getBossZone")
    bossZone.call("placeCounterOnBoss", {type = "FLY", amount = startFlyCounterBoss[params.difficulty]})

    if params.difficulty == "DIF_COMP" then
        for _, playerColor in pairs(Global.getTable("PLAYER")) do
            Global.call("placePlayerCounterInPlayerZone", {playerColor = playerColor, type = "SWARM", amount = 12})
        end
    elseif (params.difficulty == "DIF_HARD") or (params.difficulty == "DIF_ULTRA") then
        Global.call("addTurnEvent", {atEnd = false, function_owner = self.getGUID()
            , call_function = "call_turnStartFunction_HARD_ULTRA", function_params = {difficulty = params.difficulty}})
    end
    Global.call("addTurnEvent", {atEnd = true, function_owner = self.getGUID()
        , call_function = DIF_TO_TURN_FUNCTION[params.difficulty], function_params = {difficulty = params.difficulty}})
end

------------------------------------------------------------------------------------------------------------------------

function call_turnEndFunction_NORMAL(_)
    local bossZone = CHALLENGE_MODULE.call("getBossZone")
    bossZone.call("placeCounterOnBoss", {type = "FLY"})
end

function call_turnEndFunction_HARD_ULTRA(_)
    local bossZone = CHALLENGE_MODULE.call("getBossZone")
    local minionHpLeft = 0
    for _, zoneInfo in pairs(Global.getTable("ZONE_INFO_MINION")) do
        local minionZone = getObjectFromGUID(zoneInfo.guid)
        minionHpLeft = minionHpLeft + minionZone.call("getLeftoverHP")
        minionZone.call("discardActiveMonster")
    end
    bossZone.call("placeCounterOnBoss", {type = "FLY", amount = minionHpLeft})
end

function call_turnEndFunction_COMP(params)
    Global.call("placePlayerCounterInPlayerZone", {playerColor = params.playerColorEnd, type = "SWARM"})
end

function call_turnStartFunction_HARD_ULTRA()
    if MINION_SLOT_FLY == nil then
        return
    end
    local bossZone = CHALLENGE_MODULE.call("getBossZone")
    local nextMinion = MINION_SLOT_FLY.call("getMinion")
    if nextMinion then
        bossZone.call("placeMinion", {card = nextMinion})
    end
end