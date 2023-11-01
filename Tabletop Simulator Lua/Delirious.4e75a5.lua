local CHALLENGE_MODULE = nil
local MONSTER_ZONE_GUIDS = Global.getTable("ZONE_GUID_MONSTER")
local MONSTER_DECK_ZONE_GUID = Global.getTable("ZONE_GUID_DECK").MONSTER
local MONSTER_TAGS = nil

local CONTENT_TABLE = {
    BOSS = "237729",
    RULE = "b6549a",
    --skip for better performance
    --MANUAL = "302913"
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
        DIF_ULTRA = 3,
        DIF_COMP = 3    --TODO it is 4
    }
}

local nonBossLUT = {}

HAS_SEP_COMP_MODE = true

local function createNonBossLUT(monsterPreDeckGUIDs)
    nonBossLUT = {}
    for type, guid in pairs(monsterPreDeckGUIDs) do
        if (type ~= "M_BOSS") and (type ~= "M_GOOD") and (type ~= "M_BAD") and (type ~= "M_CURSE") and (type ~= "M_EPIC") then
            local preDeck = getObjectFromGUID(guid)
            if preDeck then
                for _, objInfo in pairs(preDeck.getObjects()) do
                    nonBossLUT[objInfo.guid] = true
                end
            end
        end
    end
end

function onLoad(saved_data)
    CHALLENGE_MODULE = getObjectFromGUID(Global.getVar("CHALLENGE_MODULE"))
    MONSTER_TAGS = getObjectFromGUID(MONSTER_DECK_ZONE_GUID).getTable("MONSTER_TAGS")

    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        if loaded_data.lut then
            nonBossLUT = loaded_data.lut
        end
    end
end

function onSave()
    return JSON.encode({lut = nonBossLUT})
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

    if (params.difficulty == "DIF_COMP") then
        CHALLENGE_MODULE.call("activatePlayerMinionZones")
    end
end

function setupChallengeZones(params)
    local monsterGUIDs = params.preDeckGUIDs.MONSTER
    local noGoTags = params.filterTags

    createNonBossLUT(monsterGUIDs)

    for _, guid in pairs(monsterGUIDs) do
        local preDeck = getObjectFromGUID(guid)
        if preDeck then
            for _, infoTable in pairs(preDeck.getObjects()) do
                if string.match(infoTable.gm_notes, "delirium") then
                    self.putObject(preDeck.takeObject({guid = infoTable.guid}))
                end
            end
        end
    end
end

function setupChallenge(params)
    if params.difficulty == "DIF_COMP" then
        getObjectFromGUID(MONSTER_DECK_ZONE_GUID).call("addDieEvent", {function_owner = self.getGUID()
            , call_function = "call_dieFunction_COMP"})
    end
end

------------------------------------------------------------------------------------------------------------------------
function call_dieFunction_COMP(params)
    if nonBossLUT[params.guid] and (not params.isMinion) then
        local bossZone = CHALLENGE_MODULE.call("getBossZone")
        bossZone.call("placeMinion", {card = getObjectFromGUID(params.guid), zoneOwner = Global.getVar("activePlayerColor")})
    end
end