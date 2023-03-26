local CHALLENGE_MODULE = nil
local TABLE_BASE_GUID = "f5c4fe"

local CONTENT_TABLE = {
    BOSS = "887544",
    RULE = "01128a",
    --skip for better performance
    --MANUAL = "d36102"
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

local DIF_TO_COUNTER_VALUES = {
    DIF_NORMAL = {CENT = 8, LOOT = 2, TREASURE = 3, SOUL = 3},
    DIF_HARD = {CENT = 12, LOOT = 4, TREASURE = 3, SOUL = 3},
    DIF_ULTRA = {CENT = 16, LOOT = 4, TREASURE = 3, SOUL = 3},
    DIF_COMP = {CENT = 6, LOOT = 2, TREASURE = 2, SOUL = 2,
        CENT_TWO = 6, LOOT_TWO = 2, TREASURE_TWO = 2, SOUL_TWO = 2}
}

local SLOT_BUTTON_PARAMS = {
    function_owner = self.getGUID(),
    call_function = "call_dealTreasure",
    call_function_inactive = "call_revealPresent"
}

TREASURE_SLOTS_PRESENT = {CENT = nil, LOOT = nil, TREASURE = nil, SOUL = nil}

HAS_CUSTOM_SETTINGS = true
HAS_SEP_COMP_MODE = true

function configureSettings()
    UI.setAttribute("DIF_WARNING", "text", "It is recommended to disable Auto-Rewarding for this challenge!")
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

    CHALLENGE_MODULE.call("allowEventMinions")
    CHALLENGE_MODULE.call("disableMinionRewards")

    TREASURE_SLOTS_PRESENT["CENT"] = CHALLENGE_MODULE.call("addTreasureSlot"
        , {name = "Present Cent", buttonParams = SLOT_BUTTON_PARAMS})
    TREASURE_SLOTS_PRESENT["LOOT"] = CHALLENGE_MODULE.call("addTreasureSlot"
        , {name = "Present Loot", buttonParams = SLOT_BUTTON_PARAMS})
    TREASURE_SLOTS_PRESENT["TREASURE"] = CHALLENGE_MODULE.call("addTreasureSlot"
        , {name = "Present Treasure", buttonParams = SLOT_BUTTON_PARAMS})
    TREASURE_SLOTS_PRESENT["SOUL"] = CHALLENGE_MODULE.call("addTreasureSlot"
        , {name = "Present Soul", buttonParams = SLOT_BUTTON_PARAMS})

    if params.difficulty == "DIF_COMP" then
        CHALLENGE_MODULE.call("activatePlayerMinionZones")
        TREASURE_SLOTS_PRESENT["CENT_TWO"] = CHALLENGE_MODULE.call("addTreasureSlot"
            , {name = "Present Cent 2", buttonParams = SLOT_BUTTON_PARAMS})
        TREASURE_SLOTS_PRESENT["LOOT_TWO"] = CHALLENGE_MODULE.call("addTreasureSlot"
            , {name = "Present Loot 2", buttonParams = SLOT_BUTTON_PARAMS})
        TREASURE_SLOTS_PRESENT["TREASURE_TWO"] = CHALLENGE_MODULE.call("addTreasureSlot"
            , {name = "Present Treasure 2", buttonParams = SLOT_BUTTON_PARAMS})
        TREASURE_SLOTS_PRESENT["SOUL_TWO"] = CHALLENGE_MODULE.call("addTreasureSlot"
            , {name = "Present Soul 2", buttonParams = SLOT_BUTTON_PARAMS})
    end
end

function setupChallengeZones(params)
    local monsterGUIDs = params.preDeckGUIDs.MONSTER
    local treasureGUIDs = params.preDeckGUIDs.TREASURE
    local noGoTags = params.filterTags

    for _, guid in pairs(monsterGUIDs) do
        local preDeck = getObjectFromGUID(guid)
        if preDeck then
            for _, infoTable in pairs(preDeck.getObjects()) do
                if string.match(infoTable.gm_notes, "krampus") then
                    self.putObject(preDeck.takeObject({guid = infoTable.guid}))
                end
            end
        end
    end

    for id, treasureSlot in pairs(TREASURE_SLOTS_PRESENT) do
        local selectedCards = getObjectFromGUID(TABLE_BASE_GUID).call("getRandomTreasure", {amount = 1})
        for _, card in pairs(selectedCards) do
            treasureSlot.call("addTreasure", {card = card})
        end
    end
end

function setupChallenge(params)
    local counterBag = getObjectFromGUID(Global.getTable("COUNTER_BAGS_GUID").NORMAL)
    if counterBag then
        for id, treasureSlot in pairs(TREASURE_SLOTS_PRESENT) do
            local counter = counterBag.takeObject({position = treasureSlot.getPosition():setAt('y', 5), rotation = treasureSlot.getRotation()})
            Wait.frames(function() counter.call("modifyCounter", {modifier = DIF_TO_COUNTER_VALUES[params.difficulty][id]}) end)
        end
    end
end

function call_revealPresent(params)
    if Player[params.playerColor].admin or (Global.getTable("PLAYER_OWNER")[Global.getVar("activePlayerColor")] == params.playerColor) then
        for _, obj in pairs(params.slotZone.getObjects()) do
            if (obj.type ~= "Card") and (obj.type ~= "Deck") and (obj.type ~= "Board") then
                destroyObject(obj)
            end
        end
        if params.deckOrCard and (params.deckOrCard.type == "Card") then
            if params.deckOrCard.is_face_down then
                params.deckOrCard.flip()
            end
        end
    end
end

function call_dealTreasure(params)
    if params.deckOrCard then
        local card = nil
        if params.deckOrCard.type == "Card" then
            card = params.deckOrCard
        elseif params.deckOrCard.type == "Deck" then
            card = params.deckOrCard.takeObject()
        end
        if card then
            Global.call("placeObjectsInPlayerZone", {objects = {card}, playerColor = params.playerColor})
        end
    end
end