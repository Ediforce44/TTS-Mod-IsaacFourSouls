local CHALLENGE_MODULE = nil
local TABLE_BASE_GUID = "f5c4fe"

local CONTENT_TABLE = {
    BOSS = "1a00cf",
    RULE = "a6f3fc",
    --skip for better performance
    --MANUAL = "2db0bd"
}

local DIF_TO_STATE = {
    BOSS = {
        DIF_NORMAL = 1,
        DIF_HARD = 2,
        DIF_ULTRA = 3,
        DIF_COMP = 3
    },
    RULE = {
        DIF_NORMAL = 1,
        DIF_HARD = 1,
        DIF_ULTRA = 1,
        DIF_COMP = 1
    }
}

local DIF_TO_MOM_DECK_COUNT = {
    DIF_NORMAL = 8,
    DIF_HARD = 9,
    DIF_ULTRA = 10
}

local SLOT_BUTTON_PARAMS = {
    function_owner = self.getGUID(),
    call_function = "call_dealTreasure"
}

HAS_CUSTOM_SETTINGS = true
HAS_SEP_COMP_MODE = false

function configureSettings()
    UI.setAttribute("DIF_WARNING", "text", "You can play this Challenge competitive in every difficulty Level.\nFor competitive rules of this challenge look at its rulebook!")
    UI.setAttribute("DIF_WARNING", "active", "true")
end

MINION_SLOT_EYE = nil
MINION_SLOT_HAND = nil

MINION_EYE_SCRIPT =
[[function onDie(params)
    if not params.selected then
        getObjectFromGUID(MINION_SLOT_GUID).call("addMinion", {card = self, smooth = true, shuffle = true})
    end
    return true
end]]

MINION_HAND_SCRIPT =
[[function onDie(params)
    if not params.selected then
        getObjectFromGUID(MINION_SLOT_GUID).call("addMinion", {card = self, smooth = true, shuffle = true})
    end
    return true
end]]

local function setMinionSlotInMinionScript()
    MINION_EYE_SCRIPT =
[[

MINION_SLOT_GUID = "]] .. tostring(MINION_SLOT_EYE.getGUID()) .. [["

]] .. MINION_EYE_SCRIPT

    MINION_HAND_SCRIPT =
[[

MINION_SLOT_GUID = "]] .. tostring(MINION_SLOT_HAND.getGUID()) .. [["

]] .. MINION_HAND_SCRIPT
end

TREASURE_SLOT_MOM = nil
TREASURE_SLOT_BIBLE = nil
TREASURE_SLOT_PLAYER_MOM = {}
MOM_DECK = nil
PLAYER_MOM_DECKS = {}

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

    MINION_SLOT_HAND = CHALLENGE_MODULE.call("addMinionSlot", {name = "Mom's  Hand"})
    MINION_SLOT_EYE = CHALLENGE_MODULE.call("addMinionSlot", {name = "Mom's Eye"})
    setMinionSlotInMinionScript()

    if params.compMode then
        CHALLENGE_MODULE.call("expandChallengeZone")
        CHALLENGE_MODULE.call("skipSlot")
        TREASURE_SLOT_BIBLE = CHALLENGE_MODULE.call("addTreasureSlot", {name = "The Bible", buttonParams = SLOT_BUTTON_PARAMS})
        TREASURE_SLOT_PLAYER_MOM["Red"] = CHALLENGE_MODULE.call("addTreasureSlot"
            , {name = "Mom Deck Red", buttonParams = SLOT_BUTTON_PARAMS})
        TREASURE_SLOT_PLAYER_MOM["Blue"] = CHALLENGE_MODULE.call("addTreasureSlot"
            , {name = "Mom Deck Blue", buttonParams = SLOT_BUTTON_PARAMS})
        TREASURE_SLOT_MOM = CHALLENGE_MODULE.call("addTreasureSlot", {name = " "})
    else
        CHALLENGE_MODULE.call("skipSlot")
        TREASURE_SLOT_MOM = CHALLENGE_MODULE.call("addTreasureSlot"
            , {name = "Mom Deck", buttonParams = SLOT_BUTTON_PARAMS})
    end
end

function setupChallengeZones(params)
    local treasureGUIDs = params.preDeckGUIDs.TREASURE
    local monsterGUIDs = params.preDeckGUIDs.MONSTER
    local noGoTags = params.filterTags

    for _, guid in pairs(monsterGUIDs) do
        local preDeck = getObjectFromGUID(guid)
        if preDeck then
            for _, infoTable in pairs(preDeck.getObjects()) do
                if string.match(infoTable.gm_notes, "mom$") then
                    self.putObject(preDeck.takeObject({guid = infoTable.guid}))
                elseif string.match(infoTable.gm_notes, "mom.*hand") then
                    local isCardGood = true
                    for _, tag in pairs(infoTable.tags) do
                        if noGoTags[tag] == false then
                            isCardGood = false
                            break
                        end
                    end
                    if isCardGood then
                        local newHandMinion = preDeck.takeObject({guid = infoTable.guid})
                        newHandMinion.setLuaScript(newHandMinion.getLuaScript() .. MINION_HAND_SCRIPT)
                        MINION_SLOT_HAND.call("addMinion", {card = newHandMinion, shuffle = true})
                    end
                elseif string.match(infoTable.gm_notes, "mom.*eye") then
                    local isCardGood = true
                    for _, tag in pairs(infoTable.tags) do
                        if noGoTags[tag] == false then
                            isCardGood = false
                            break
                        end
                    end
                    if isCardGood then
                        local newEyeMinion = preDeck.takeObject({guid = infoTable.guid})
                        newEyeMinion.setLuaScript(newEyeMinion.getLuaScript() .. MINION_EYE_SCRIPT)
                        MINION_SLOT_EYE.call("addMinion", {card = newEyeMinion, shuffle = true})
                    end
                end
            end
        end
    end

    if params.compMode then
        for _, guid in pairs(treasureGUIDs) do
            local preDeck = getObjectFromGUID(guid)
            if preDeck then
                for _, infoTable in pairs(preDeck.getObjects()) do
                    if string.match(infoTable.gm_notes, "g2[-]the_bible") then
                        TREASURE_SLOT_BIBLE.call("addTreasure", {card = preDeck.takeObject({guid = infoTable.guid}), flip = true})
                    end
                end
            end
        end

        for _, guid in pairs(treasureGUIDs) do
            local preDeck = getObjectFromGUID(guid)
            if preDeck then
                for _, infoTable in pairs(preDeck.getObjects()) do
                    if string.match(infoTable.gm_notes, "mom") then
                        local isCardGood = true
                        for _, tag in pairs(infoTable.tags) do
                            if noGoTags[tag] == false then
                                isCardGood = false
                                break
                            end
                        end
                        if isCardGood then
                            local newMomTreasure = preDeck.takeObject({guid = infoTable.guid})
                            MOM_DECK = TREASURE_SLOT_MOM.call("addTreasure", {card = newMomTreasure, shuffle = true})
                        end
                    end
                end
            end
        end

        for color, treasureSlot in pairs(TREASURE_SLOT_PLAYER_MOM) do
            local selectedCards = getObjectFromGUID(TABLE_BASE_GUID).call("getRandomTreasure", {amount = 3})
            for _, card in pairs(selectedCards) do
                treasureSlot.call("addTreasure", {card = card, shuffle = true})
            end
            if MOM_DECK then
                treasureSlot.call("addTreasure", {card = MOM_DECK.takeObject(), shuffle = false, bottom = true})
            end
            treasureSlot.call("activateZone")
        end
    else
        for _, guid in pairs(treasureGUIDs) do
            local preDeck = getObjectFromGUID(guid)
            if preDeck then
                for _, infoTable in pairs(preDeck.getObjects()) do
                    if string.match(infoTable.gm_notes, "mom") then
                        local isCardGood = true
                        for _, tag in pairs(infoTable.tags) do
                            if noGoTags[tag] == false then
                                isCardGood = false
                                break
                            end
                        end
                        if isCardGood then
                            local newMomTreasure = preDeck.takeObject({guid = infoTable.guid})
                            MOM_DECK = TREASURE_SLOT_MOM.call("addTreasure", {card = newMomTreasure, shuffle = true})
                        end
                    end
                end
            end
            TREASURE_SLOT_MOM.call("activateZone")
        end

        for _, guid in pairs(treasureGUIDs) do
            local preDeck = getObjectFromGUID(guid)
            if preDeck then
                for _, infoTable in pairs(preDeck.getObjects()) do
                    if string.match(infoTable.gm_notes, "g2[-]the_bible") then
                        TREASURE_SLOT_MOM.call("addTreasure", {card = preDeck.takeObject({guid = infoTable.guid}), shuffle = true})
                    end
                end
            end
        end

        if MOM_DECK then
            local bibleOnWrongPos = true
            local momDeckCount = MOM_DECK.getQuantity()
            if momDeckCount >= 4 then
                while(bibleOnWrongPos) do
                    MOM_DECK.shuffle()
                    local deckContent = MOM_DECK.getObjects()
                    for i = momDeckCount - 3, momDeckCount do
                        if deckContent[i].gm_notes == "g2-the_bible" then
                            bibleOnWrongPos = false
                            break
                        end
                    end
                end
            end
        end
    end
end

function setupChallenge(params)
    if params.compMode then
        MOM_DECK.setPositionSmooth(Global.getTable("DECK_POSITION").LO_TREASURE, false)
        MOM_DECK.setRotationSmooth({0, 270, 180}, false)
    else
        local momDeckCount = MOM_DECK.getQuantity()
        local treasureLeftoverPos = Global.getTable("DECK_POSITION").LO_TREASURE
        while (momDeckCount > DIF_TO_MOM_DECK_COUNT[params.difficulty]) do
            MOM_DECK.takeObject({position = treasureLeftoverPos, rotation = {0, 270, 180}})
            momDeckCount = momDeckCount - 1
        end
    end

    if (params.difficulty == "DIF_HARD") or (params.difficulty == "DIF_ULTRA") then
        Global.call("addTurnEvent", {atEnd = false, function_owner = self.getGUID()
            , call_function = "call_turnStartFunction_HARD_ULTRA", function_params = {difficulty = params.difficulty}})
        local monsterDeckZone = getObjectFromGUID(Global.getTable("ZONE_GUID_DECK").MONSTER)
        if monsterDeckZone then
            monsterDeckZone.call("addNewMonsterEvent", {function_owner = self.getGUID()
                , call_function = "call_newMonsterFunction_HARD_ULTRA", function_params = {difficulty = params.difficulty}})
        end
    end
end

function call_turnStartFunction_HARD_ULTRA(params)
    for _, infoTable in pairs(Global.getTable("ZONE_INFO_MINION")) do
        local minionZone = getObjectFromGUID(infoTable.guid)
        if minionZone and minionZone.getVar("active") then
            minionZone.call("editHP", {modifier = 1})
        end
    end
end

function call_newMonsterFunction_HARD_ULTRA(params)
    if params.isMinion then
        local minionZone = params.zone
        if minionZone.getVar("active") then
            minionZone.call("editHP", {modifier = 1})
        end
    end
end

function call_dealTreasure(params)
    if Player[params.playerColor].admin or (Global.getTable("PLAYER_OWNER")[Global.getVar("activePlayerColor")] == params.playerColor) then
        if params.deckOrCard then
            local card = nil
            if params.deckOrCard.type == "Card" then
                card = params.deckOrCard
            elseif params.deckOrCard.type == "Deck" then
                card = params.deckOrCard.takeObject()
            end
            if card then
                Global.call("placeObjectsInPlayerZone", {objects = {card}, playerColor = Global.getVar("activePlayerColor")})
            end
        end
    end
end