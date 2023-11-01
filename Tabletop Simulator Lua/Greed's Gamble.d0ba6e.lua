local CHALLENGE_MODULE = nil

local CONTENT_TABLE = {
    BOSS = "fea589",
    RULE = "e47f0d",
    COUNTER = "356313"
    --skip for better performance
    --MANUAL = "8a1e79"
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

MINION_SLOT_HEAD = nil
TREASURE_SLOT_RAZOR = nil

local startCentCounterBoss = {
    DIF_NORMAL = 24,
    DIF_HARD = 28,
    DIF_ULTRA = 32,
    DIF_COMP = 0
}

function onLoad()
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

    local counterBagGuids = Global.getTable("COUNTER_BAGS_GUID")
    counterBagGuids["CENT"] = CONTENT_TABLE.COUNTER
    Global.setTable("COUNTER_BAGS_GUID", counterBagGuids)

    if params.difficulty == "DIF_COMP" then
        TREASURE_SLOT_RAZOR = CHALLENGE_MODULE.call("addTreasureSlot", {name = "Golden Razor"})
    end
    MINION_SLOT_HEAD = CHALLENGE_MODULE.call("addMinionSlot", {name = "Keeper Heads"})
end

function setupChallengeZones(params)
    local monsterGUIDs = params.preDeckGUIDs.MONSTER
    local noGoTags = params.filterTags

    for _, guid in pairs(monsterGUIDs) do
        local preDeck = getObjectFromGUID(guid)
        if preDeck then
            for _, infoTable in pairs(preDeck.getObjects()) do
                if string.match(infoTable.gm_notes, "b2[-]greed$") then
                    self.putObject(preDeck.takeObject({guid = infoTable.guid}))
                elseif string.match(infoTable.gm_notes, "keeper_head") then
                    local isCardGood = true
                    for _, tag in pairs(infoTable.tags) do
                        if noGoTags[tag] == false then
                            isCardGood = false
                            break
                        end
                    end
                    if isCardGood then
                        local newHeadMinion = preDeck.takeObject({guid = infoTable.guid})
                        MINION_SLOT_HEAD.call("addMinion", {card = newHeadMinion, shuffle = true})
                    end
                end
            end
        end
    end
    local treasurePayDeckGUID = params.preDeckGUIDs.TREASURE.T_PAID
    if treasurePayDeckGUID then
        local preDeck = getObjectFromGUID(treasurePayDeckGUID)
        if preDeck then
            for _, infoTable in pairs(preDeck.getObjects()) do
                if string.match(infoTable.gm_notes, "b2[-]golden_razor_blade$") then
                    local goldenRazor = preDeck.takeObject({guid = infoTable.guid})
                    if params.difficulty == "DIF_COMP" then
                        TREASURE_SLOT_RAZOR.call("addTreasure", {card = goldenRazor, flip = true})
                    else
                        Global.call("placeObjectsInPlayerZone", {playerColor = Global.getVar("startPlayerColor"), objects = {goldenRazor}})
                    end
                end
            end
        end
    end
end

function setupChallenge(params)
    local bossZone = CHALLENGE_MODULE.call("getBossZone")
    bossZone.call("placeCounterOnBoss", {type = "CENT", amount = startCentCounterBoss[params.difficulty]})

    if params.difficulty == "DIF_COMP" then
        for _, playerColor in pairs(Global.getTable("PLAYER")) do
            Global.call("placePlayerCounterInPlayerZone", {playerColor = playerColor, type = "CENT", amount = 24})
        end
    else
        local allCounterGuids = Global.getTable("COIN_COUNTER_GUID")
        local countersToSync = {Blue = allCounterGuids.Blue, Red = allCounterGuids.Red}
        for _, guid in pairs(allCounterGuids) do
            local counter = getObjectFromGUID(guid)
            if counter then
                counter.call("syncCounter", countersToSync)
            end
        end
    end
end