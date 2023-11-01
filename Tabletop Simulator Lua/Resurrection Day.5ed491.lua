local CHALLENGE_MODULE = nil

local CONTENT_TABLE = {
    BOSS = "43da49",
    RULE = "80dc11"
    --skip for better performance
    --MANUAL = "cd02b4"
}

local DIF_TO_STATE = {
    BOSS = {
        DIF_NORMAL = 1,
        DIF_HARD = 2,
        DIF_ULTRA = 3,
        DIF_COMP = 1
    },
    RULE = {
        DIF_NORMAL = 1,
        DIF_HARD = 1,
        DIF_ULTRA = 2,
        DIF_COMP = 1
    }
}

HAS_CUSTOM_SETTINGS = true
HAS_SEP_COMP_MODE = false

function configureSettings()
    UI.setAttribute("DIF_WARNING", "text", "There is no seperate competitive version for this Challenge.\nYou can play this Challenge competitive in every difficulty Level!")
    UI.setAttribute("DIF_WARNING", "active", "true")
end

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

    getObjectFromGUID(Global.getTable("ZONE_GUID_DISCARD").MONSTER).call("activateDiscardZone")
end

function setupChallengeZones(params)
    local monsterGUIDs = params.preDeckGUIDs.MONSTER
    local noGoTags = params.filterTags

    for _, guid in pairs(monsterGUIDs) do
        local preDeck = getObjectFromGUID(guid)
        if preDeck then
            for _, infoTable in pairs(preDeck.getObjects()) do
                if string.match(infoTable.gm_notes, "rag_man$") then
                    self.putObject(preDeck.takeObject({guid = infoTable.guid}))
                end
            end
        end
    end
end

local ONE_TIME_USE_EVENT_ID = nil

function setupChallenge(params)
    ONE_TIME_USE_EVENT_ID = Global.call("addTurnEvent", {atEnd = false, function_owner = self.getGUID()
        , call_function = "call_turnFunction_ONE_TIME_USE"})
end

function call_turnFunction_ONE_TIME_USE()
    local discardCardGuids = {}
    local monsterDeck = Global.call("getMonsterDeck")
    for _, obj in ipairs(monsterDeck.getObjects()) do
        if not Global.call("findBoolInScript", {scriptString = obj.lua_script, varName = "isEvent"}) then
            table.insert(discardCardGuids, obj.guid)
        end
        if #discardCardGuids == 2 then
            break
        end
    end

    local monsterDeckZone = getObjectFromGUID(Global.getTable("ZONE_GUID_DECK").MONSTER)
    for _, guid in pairs(discardCardGuids) do
        monsterDeckZone.call("discardMonsterObject", {object = monsterDeck.takeObject({guid = guid})})
    end
    Global.call("deactivateTurnEvent", {eventID = ONE_TIME_USE_EVENT_ID})
end