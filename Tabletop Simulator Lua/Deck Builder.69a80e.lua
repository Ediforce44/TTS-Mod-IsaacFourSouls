local TABLE_BASE_GUID = "f5c4fe"
local MAX_EMPTY_CARDS = 1500
local DECK_BUILDER_ON = true
local GAMEMODE_CHANGE_BLOCKED = false
local SELECTED_BUILD_MODE = nil
local SEED_MODE = false
local seed_selectedCards = nil

BUILD_MODE = {
    NORMAL  = 1,
    DRAFT   = 2,
    SEED    = 3,
    CUSTOM  = 4
}

-- Table base
ENTRY_POINT = {
    GUID            = "195d79",
    CALL_FUNCTION   = "decksBuilt"
}

local function changeBuildMode(newBuildMode)
    if newBuildMode == SELECTED_BUILD_MODE then
        return true
    end

    -- check if newBuildMode exists
    for modeName, buildMode in pairs(BUILD_MODE) do
        if buildMode == newBuildMode then
            SELECTED_BUILD_MODE = newBuildMode
            return true
        end
    end
    return false
end

function disableDeckBuilder()
    DECK_BUILDER_ON = false
end

function gmNormal()
    if Global.call("hasGameStarted") or GAMEMODE_CHANGE_BLOCKED then
        return
    end
    changeBuildMode(BUILD_MODE.NORMAL)
    unsetNoGo({nogo = NO_GO_TYPES.ONLY_MULTIPLAYER})
end

function gmDraft()
    if Global.call("hasGameStarted") or GAMEMODE_CHANGE_BLOCKED then
        return
    end
    changeBuildMode(BUILD_MODE.DRAFT)
    setNoGo({nogo = NO_GO_TYPES.ONLY_MULTIPLAYER})
end

function prepareForManualDeckBuilding()
    if Global.call("hasGameStarted") or GAMEMODE_CHANGE_BLOCKED then
        return false
    end

    disableDeckBuilder()
    GAMEMODE_CHANGE_BLOCKED = true

    local gameLanguage = Global.getVar("gameLanguage")
    local tableBase = getObjectFromGUID(TABLE_BASE_GUID)
    local preDeckGUIDs = tableBase.call("getPreDeckGUIDs", {language = gameLanguage})

    buildAllDecks({preDecks = preDeckGUIDs})
    return true
end

function isDeckBuilderON()
    return DECK_BUILDER_ON
end

-- returns true, if decks were put ontop of the table due to manual deck-building
function isDeckBuilderBlocked()
    return GAMEMODE_CHANGE_BLOCKED
end

function switchBuildMode(params)
    if params.buildMode == nil then
        Global.call("printWarning", {text = "Wrong parameter in function switchBuildMode()."})
        return false
    end
    return changeBuildMode(params.buildMode)
end

------------------------------------------------------------------------------------------------------------------------
----------------------------------------------      NO GOES       ------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local ACTIVE_NO_GOES = {}
local nogo_failure_counter = 0

local function isInTable(table, contentToCheck)
    for _, entry in pairs(table) do
        if entry == contentToCheck then
            return true
        end
    end
    return false
end

local function getIntFromScript(luaScript, varName)
    for line in string.gmatch(luaScript,"[^\r\n]+") do
        if string.sub(line,1,#varName) == varName then
            local value = string.match(line,"%d+",#varName)
            return tonumber(value)
        end
    end
    return -1
end

local function customNoGoScriptFunction(luaScript, varName)
    return getIntFromScript(luaScript, varName) > 10
end

NO_GO_TYPES = {
    ONLY_MULTIPLAYER    = "ONLY_MULTIPLAYER",
    WARP_ZONE           = "WARP_ZONE",
    ALT_ART             = "ALT_ART",
    TARGET              = "TARGET",
    GISH                = "GISH",
    TAPEWORM            = "TAPEWORM",
    DICK_KNOTS          = "DICK_KNOTS",
    UNBOXING_OF_ISAAC   = "UNBOXING_OF_ISAAC",
    PROMO               = "PROMO"
}

-- objTable needs the following fields:       name,  lua_script,  tags
NO_GO_FILTERS = {
    ONLY_MULTIPLAYER = function(objTable) return isInTable(objTable.tags, NO_GO_TYPES.ONLY_MULTIPLAYER) end,
    WARP_ZONE = function(objTable) return isInTable(objTable.tags, NO_GO_TYPES.WARP_ZONE) end,
    ALT_ART = function(objTable) return isInTable(objTable.tags, NO_GO_TYPES.ALT_ART) end,
    TARGET = function(objTable) return isInTable(objTable.tags, NO_GO_TYPES.TRAGET) end,
    GISH = function(objTable) return isInTable(objTable.tags, NO_GO_TYPES.GISH) end,
    TAPEWORM = function(objTable) return isInTable(objTable.tags, NO_GO_TYPES.TAPEWORM) end,
    DICK_KNOTS = function(objTable) return isInTable(objTable.tags, NO_GO_TYPES.DICK_KNOTS) end,
    UNBOXING_OF_ISAAC = function(objTable) return isInTable(objTable.tags, NO_GO_TYPES.UNBOXING_OF_ISAAC) end,
    PROMO = function(objTable) return isInTable(objTable.tags, NO_GO_TYPES.PROMO) end,
    Unkown = function(_) nogo_failure_counter = nogo_failure_counter + 1; return false end
}

------------------------------------------------------------------------------------------------------------------------
--------------------------------------------      Deck Builder        --------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local DECK_TREASURE_RATIOS = {
    {
        T_ACTIVE  = 40,
        T_PASSIVE = 44,
        T_PAID    = 10,
        T_ONE_USE = 5,
        T_SOUL    = 1
    },
    {
        T_ACTIVE  = 40,
        T_PASSIVE = 44,
        T_PAID    = 10,
        T_ONE_USE = 5,
        T_SOUL    = 1
    },
    { T_ACTIVE = 0, T_PASSIVE = 0, T_PAID = 0, T_ONE_USE = 0, T_SOUL = 0},
    { T_ACTIVE = 0, T_PASSIVE = 0, T_PAID = 0, T_ONE_USE = 0, T_SOUL = 0}
}

local DECK_LOOT_RATIOS = {
    {
        L_TAROT_MISC    = 23,
        L_TRINKET       = 11,
        L_PILL          = 3,
        L_RUNE          = 3,
        L_BUTTER_BEAN   = 5,
        L_BOMB          = 6,
        L_BATTERY       = 6,
        L_DICE_SHARD    = 3,
        L_SOUL_HEART    = 2,
        L_LOST_SOUL     = 1,
        L_NICKEL        = 6,
        L_FOUR_CENT     = 12,
        L_THREE_CENT    = 11,
        L_TWO_CENT      = 6,
        L_ONE_CENT      = 2
    },
    {
        L_TAROT_MISC    = 22,
        L_TRINKET       = 10,
        L_PILL          = 2,
        L_RUNE          = 3,
        L_BUTTER_BEAN   = 5,
        L_BOMB          = 5,
        L_BATTERY       = 5,
        L_DICE_SHARD    = 3,
        L_SOUL_HEART    = 2,
        L_LOST_SOUL     = 1,
        L_NICKEL        = 5,
        L_FOUR_CENT     = 10,
        L_THREE_CENT    = 10,
        L_TWO_CENT      = 5,
        L_ONE_CENT      = 2
    },
    {L_TAROT_MISC = 0, L_TRINKET = 0, L_PILL = 0, L_RUNE = 0, L_BUTTER_BEAN = 0, L_BOMB = 0, L_BATTERY = 0, L_DICE_SHARD = 0,
        L_SOUL_HEART = 0, L_LOST_SOUL = 0, L_NICKEL = 0, L_FOUR_CENT = 0, L_THREE_CENT = 0, L_TWO_CENT = 0, L_ONE_CENT = 0},
    {L_TAROT_MISC = 0, L_TRINKET = 0, L_PILL = 0, L_RUNE = 0, L_BUTTER_BEAN = 0, L_BOMB = 0, L_BATTERY = 0, L_DICE_SHARD = 0,
        L_SOUL_HEART = 0, L_LOST_SOUL = 0, L_NICKEL = 0, L_FOUR_CENT = 0, L_THREE_CENT = 0, L_TWO_CENT = 0, L_ONE_CENT = 0}
}

local DECK_MONSTER_RATIOS = {
    {
        M_BOSS        = 30,
        M_EPIC        = 1,
        M_BASIC       = 30,
        M_CURSED      = 9,
        M_HOLY_CHARMED= 9,
        M_GOOD        = 8,
        M_BAD         = 8,
        M_CURSE       = 5
    },
    {
        M_BOSS        = 30,
        M_EPIC        = 1,
        M_BASIC       = 30,
        M_CURSED      = 9,
        M_HOLY_CHARMED= 9,
        M_GOOD        = 8,
        M_BAD         = 8,
        M_CURSE       = 5
    },
    {M_BOSS = 0, M_EPIC = 0, M_BASIC = 0, M_CURSED = 0, M_HOLY_CHARMED= 0, M_GOOD = 0, M_BAD = 0, M_CURSE = 0},
    {M_BOSS = 0, M_EPIC = 0, M_BASIC = 0, M_CURSED = 0, M_HOLY_CHARMED= 0, M_GOOD = 0, M_BAD = 0, M_CURSE = 0}
}

local DECK_ROOM_RATIOS = {
    {R_ALL   = 200},
    {R_ALL   = 200},
    {R_ALL   = 0},
    {R_ALL   = 200}
}

local DECK_BONUS_SOUL_RATIOS = {
    {BS_ALL  = 100},
    {BS_ALL  = 100},
    {BS_ALL  = 0},
    {BS_ALL  = 100}
}

local DECK_MONSTER_SEP_RATIOS = {
    {MS_ALL  = 100},
    {MS_ALL  = 100},
    {MS_ALL  = 0},
    {MS_ALL  = 100}
}

local DECK_INFOS = {
    TREASURE = {
        ID                  = "TREASURE",
        DISABLED            = false,
        RATIOS              = DECK_TREASURE_RATIOS,
        DECK_POSITION       = nil,
        DECK_ROTATION       = Vector(180, 0, 0),
        DECK_NAME           = "Treasure Deck",
        LEFTOVERS_POSITION  = nil,
        LEFTOVERS_ROTATION  = Vector(0, 270, 180),
        LEFTOVERS_NAME      = "Leftover Treasure Cards"
    },
    LOOT = {
        ID                  = "LOOT",
        DISABLED            = false,
        RATIOS              = DECK_LOOT_RATIOS,
        DECK_POSITION       = nil,
        DECK_ROTATION       = Vector(180, 0, 0),
        DECK_NAME           = "Loot Deck",
        LEFTOVERS_POSITION  = nil,
        LEFTOVERS_ROTATION  = Vector(0, 270, 180),
        LEFTOVERS_NAME      = "Leftover Loot Cards"
    },
    MONSTER = {
        ID                  = "MONSTER",
        DISABLED            = false,
        RATIOS              = DECK_MONSTER_RATIOS,
        DECK_POSITION       = nil,
        DECK_ROTATION       = Vector(180, 0, 0),
        DECK_NAME           = "Monster Deck",
        LEFTOVERS_POSITION  = nil,
        LEFTOVERS_ROTATION  = Vector(0, 270, 180),
        LEFTOVERS_NAME      = "Leftover Monster Cards"
    },
    ROOM = {
        ID                  = "ROOM",
        DISABLED            = false,
        RATIOS              = DECK_ROOM_RATIOS,
        DECK_POSITION       = nil,
        DECK_ROTATION       = Vector(180, 0, 0),
        DECK_NAME           = "Room Deck",
        LEFTOVERS_POSITION  = nil,
        LEFTOVERS_ROTATION  = Vector(0, 270, 180),
        LEFTOVERS_NAME      = "Leftover Room Cards"
    },
    BONUS_SOUL = {
        ID                  = "BONUS_SOUL",
        DISABLED            = false,
        RATIOS              = DECK_BONUS_SOUL_RATIOS,
        DECK_POSITION       = nil,
        DECK_ROTATION       = Vector(0, 180, 180),
        DECK_NAME           = "Bonus Soul Deck",
        LEFTOVERS_POSITION  = nil,
        LEFTOVERS_ROTATION  = Vector(0, 270, 180),
        LEFTOVERS_NAME      = "Leftover Bonus Soul Cards"
    },
    MONSTER_SEP = {
        ID                  = "MONSTER_SEP",
        DISABLED            = false,
        RATIOS              = DECK_MONSTER_SEP_RATIOS,
        DECK_POSITION       = nil,
        DECK_ROTATION       = Vector(0, 270, 0),
        DECK_NAME           = "Separate Monster Deck",
        LEFTOVERS_POSITION  = nil,
        LEFTOVERS_ROTATION  = Vector(0, 270, 180),
        LEFTOVERS_NAME      = "Leftover Sep. Monster Cards"
    }
}

local TOTAL_DECK_COUNT = 0  --Will be set in onLoad() function

local function buildDeck(preDeckGUIDs, tagTable)
    local deckAndLeftover = nil
    if #ACTIVE_NO_GOES > 0 then
        deckAndLeftover = buildDeckFilter(preDeckGUIDs, tagTable)       -- If you want to use filter options (see NO GOES)

        if nogo_failure_counter > 0 then
            Global.call("printWarning", {text = "Deck Builder: No idea what NO-GO you try to check!? ("
                .. tostring(nogo_failure_counter) .. ")"})
        end
    else
        deckAndLeftover = buildDeckSpeed(preDeckGUIDs, tagTable)        -- If you want a fast and smooth deck builder
    end
    return deckAndLeftover
end

function getDeckInfos()
    return DECK_INFOS
end

function disableDeck(params)
    if params.deckID == nil then
        Global.call("printWarning", {text = "Wrong parameter in function disableDeckBuilding()."})
        return false
    end
    for deckType, deckInfoTable in pairs(DECK_INFOS) do
        if deckInfoTable.ID == params.deckID then
            DECK_INFOS[deckType].DISABLED = true
        end
    end
end

function enableDeck(params)
    if params.deckID == nil then
        Global.call("printWarning", {text = "Wrong parameter in function enableDeckBuilding()."})
        return false
    end
    for deckType, deckInfoTable in pairs(DECK_INFOS) do
        if deckInfoTable.ID == params.deckID then
            DECK_INFOS[deckType].DISABLED = false
        end
    end
end

function activateSeedMode(params)
    if Global.call("hasGameStarted") or GAMEMODE_CHANGE_BLOCKED then
        return
    end
    seed_selectedCards = params.selectedCards
    for deckType, infoTable in pairs(DECK_INFOS) do
        if not seed_selectedCards[deckType] then
            DECK_INFOS[deckType].RATIOS[BUILD_MODE.SEED] = infoTable.RATIOS[SELECTED_BUILD_MODE]
        end
    end
    SEED_MODE = true
end

function gmCustom(params)
    if Global.call("hasGameStarted") or GAMEMODE_CHANGE_BLOCKED then
        return
    end
    local newRatios = params.ratios or {}
    for deckType, infoTable in pairs(DECK_INFOS) do
        if newRatios[deckType] then
            for ratioID, newRatio in pairs(newRatios[deckType]) do
                DECK_INFOS[deckType].RATIOS[BUILD_MODE.CUSTOM][ratioID] = newRatio
            end
        else
            DECK_INFOS[deckType].RATIOS[BUILD_MODE.CUSTOM] = infoTable.RATIOS[BUILD_MODE.NORMAL]
        end
    end
    changeBuildMode(BUILD_MODE.CUSTOM)
    unsetNoGo({nogo = NO_GO_TYPES.ONLY_MULTIPLAYER})
end

-------------------------------------------------- Load and Save -------------------------------------------------------
function onLoad(saved_data)
    for deckType, _ in pairs(DECK_INFOS) do
        DECK_INFOS[deckType].DECK_POSITION = Global.getTable("DECK_POSITION")[deckType] or Vector(0, 5, 0)
        DECK_INFOS[deckType].LEFTOVERS_POSITION = Global.getTable("DECK_POSITION")["LO_" .. deckType] or Vector(0, 5, 0)
    end

    TOTAL_DECK_COUNT = 0
    for _, _ in pairs(DECK_INFOS) do
        TOTAL_DECK_COUNT = TOTAL_DECK_COUNT + 1
    end

    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        if loaded_data[1] == false then
            disableDeckBuilder()
        end
        if loaded_data[2] ~= nil then
            changeBuildMode(loaded_data[2])
        else
            changeBuildMode(BUILD_MODE.NORMAL)
        end
    end
end

function onSave()
    return JSON.encode({isDeckBuilderON(), SELECTED_BUILD_MODE})
end

------------------------------------------------------ No goes ---------------------------------------------------------
function setNoGo(params)
    if params.nogo == nil then
        return
    end
    for _, nogo in ipairs(ACTIVE_NO_GOES) do
        if nogo == tostring(params.nogo) then
            return
        end
    end
    table.insert(ACTIVE_NO_GOES, tostring(params.nogo))
end

function unsetNoGo(params)
    if params.nogo == nil then
        return
    end
    local newNoGoTable = {}
    for _, nogo in ipairs(ACTIVE_NO_GOES) do
        if nogo ~= tostring(params.nogo) then
            table.insert(newNoGoTable, nogo)
        end
    end
    ACTIVE_NO_GOES = newNoGoTable
end

function setNoGoForDeck(params)
    if params.nogo == nil or params.deckName == nil then
        return
    end
    if DECK_INFOS[params.deckName] == nil then
        return
    end
    local nogoList = DECK_INFOS[params.deckName].NO_GOES or {}
    for _, nogo in ipairs(nogoList) do
        if nogo == tostring(params.nogo) then
            return
        end
    end
    table.insert(nogoList, tostring(params.nogo))
    DECK_INFOS[params.deckName].NO_GOES = nogoList
end

function unsetNoGoForDeck(params)
    if params.nogo == nil or params.deckName == nil then
        return
    end
    if DECK_INFOS[params.deckName] == nil then
        return
    end
    local newNoGoTable = {}
    for _, nogo in ipairs(DECK_INFOS[params.deckName].NO_GOES) do
        if nogo ~= tostring(params.nogo) then
            table.insert(newNoGoTable, nogo)
        end
    end
    DECK_INFOS[params.deckName].NO_GOES = newNoGoTable
end

---------------------------------------------------- Deck builder ------------------------------------------------------
local B_waitingDecks = {}
local B_waitingDecksCount = 0

local function deckBuildBarrier(deckType, deck)
    B_waitingDecks[deckType] = deck
    B_waitingDecksCount = B_waitingDecksCount + 1
    if B_waitingDecksCount >= TOTAL_DECK_COUNT then
        getObjectFromGUID(ENTRY_POINT.GUID).call(ENTRY_POINT.CALL_FUNCTION, B_waitingDecks)
        B_waitingDecks = {}
    end
end

local function placeDeck(deck, position, rotation, name)
    if deck == nil then
        return
    end
    deck.setPositionSmooth(Vector(position), false)
    deck.setRotationSmooth(Vector(rotation) or Vector(180, 0, 0), false)
    deck.interactable = true
    if name ~= nil then deck.setName(name) end
end

local function setupDeck(buildMode, preDeckGUIDs, deckInfoTable)
    local _temp_currentNoGoes = ACTIVE_NO_GOES
    ACTIVE_NO_GOES = deckInfoTable.NO_GOES or _temp_currentNoGoes
    local createdDecks = {}
    if deckInfoTable.DISABLED then
        createdDecks = buildDeck(preDeckGUIDs, nil)
    else
        createdDecks = buildDeck(preDeckGUIDs, deckInfoTable.RATIOS[buildMode])
    end
    ACTIVE_NO_GOES = _temp_currentNoGoes

    local builtDeck = createdDecks[1]
    local leftoverDeck = createdDecks[2]
    placeDeck(builtDeck, deckInfoTable.DECK_POSITION, deckInfoTable.DECK_ROTATION, deckInfoTable.DECK_NAME)
    placeDeck(leftoverDeck, deckInfoTable.LEFTOVERS_POSITION, deckInfoTable.LEFTOVERS_ROTATION
        , deckInfoTable.LEFTOVERS_NAME)

    if SELECTED_BUILD_MODE == BUILD_MODE.SEED then
        if (not deckInfoTable.DISABLED) and (seed_selectedCards[deckInfoTable.ID]) then
            Wait.condition(
                function()
                    local seededDeck = buildDeckSeed(deckInfoTable, leftoverDeck)
                    if seededDeck ~= nil then
                        Wait.condition(function() deckBuildBarrier(deckInfoTable.ID, seededDeck) end, function() return seededDeck.resting end)
                    else
                        deckBuildBarrier(deckInfoTable.ID, seededDeck)
                    end
                end, function() return leftoverDeck.resting end)
        else
            Wait.condition(function() deckBuildBarrier(deckInfoTable.ID, builtDeck) end, function() return builtDeck.resting end)
        end
    else
        if builtDeck == nil then
            log("Can't build deck " .. tostring(deckInfoTable.DECK_NAME) .. ".")
            deckBuildBarrier(deckInfoTable.ID, nil)
            return
        end
        Wait.condition(function() deckBuildBarrier(deckInfoTable.ID, builtDeck) end, function() return builtDeck.resting end)
    end
end

function buildAllDecks(params)
    if params.preDecks == nil then
        Global.call("printWarning", {text = "Wrong parameters in Deck Builder function 'buildAllDecks()'."})
    end
    if SEED_MODE then
        changeBuildMode(BUILD_MODE.SEED)
    end
    for deckName, infoTable in pairs(DECK_INFOS) do
        setupDeck(SELECTED_BUILD_MODE, params.preDecks[deckName], infoTable)
    end
end

------------------------------------------------------------------------------------------------------------------------
------------------------------- Implementation of the two deck builders + Seeded version -------------------------------
------------------------------------------------------------------------------------------------------------------------
local function mergeCards(cards)
    local buildDeck = cards[1]
    if #cards > 1 then
        buildDeck = buildDeck.putObject(cards[2])
        for i = 3, #cards do
            buildDeck.putObject(cards[i])
            destroyObject(cards[i])                 -- Necessary for TTS (otherwise TTS would create card duplicates)
        end
    end
    return buildDeck
end

local function mergeDecks(decks, startDeck)
    local buildDeck = nil
    if (startDeck ~= nil) and (startDeck.type == "Deck") then
        buildDeck = startDeck
        for _, nextDeck in pairs(decks) do
            if nextDeck ~= nil then
                buildDeck.putObject(nextDeck)
                destroyObject(nextDeck)             -- Necessary for TTS (otherwise TTS would create card duplicates)
            end
        end
    else
        for index, nextDeck in pairs(decks) do
            if nextDeck.type == "Deck" then
                table.remove(decks, index)
                return mergeDecks(decks, nextDeck)
            end
        end

        if #decks > 0 then
            buildDeck = mergeCards(decks)
        end
    end

    return buildDeck
end

local function checkForNoGoes(objTable)
    for _, noGoType in pairs(ACTIVE_NO_GOES) do
        if (NO_GO_FILTERS[noGoType] or NO_GO_FILTERS.Unkown)(objTable) then
            return false
        end
    end
    return true
end

local function takeCardsFromDeck(deck, cardGUIDs, takenCardsTable)
    for _, guid in pairs(cardGUIDs) do
        table.insert(takenCardsTable, deck.takeObject({guid = guid}))
    end
    return takenCardsTable
end

function buildDeckSpeed(preDeckGUIDs, tagTable)
    local selectedDecks = {}
    local leftoverDecks = {}
    if tagTable == nil then
        for _, guid in pairs(preDeckGUIDs) do
            table.insert(leftoverDecks, getObjectFromGUID(guid))
        end
    else
        if isDeckBuilderON() then
            tagTable["EMPTY"] = MAX_EMPTY_CARDS
            for type, amountToTake in pairs(tagTable) do
                if preDeckGUIDs[type] ~= nil then
                    local preDeck = getObjectFromGUID(preDeckGUIDs[type])
                    if amountToTake > 0 then
                        if preDeck.tag == "Deck" then
                            -- For the edge case that only one card should be choosen
                            if amountToTake == 1 then
                                table.insert(selectedDecks, preDeck.takeObject())
                                local leftovers = preDeck.remainder
                                if leftovers == nil then
                                    leftovers = preDeck
                                end
                                table.insert(leftoverDecks, leftovers)
                            elseif amountToTake == (preDeck.getQuantity() - 1) then
                                local cardLeft = preDeck.takeObject()
                                table.insert(selectedDecks, preDeck)
                                table.insert(leftoverDecks, cardLeft)
                            else
                                local splitDecks = preDeck.cut(preDeck.getQuantity() - amountToTake)
                                if splitDecks ~= nil then
                                    table.insert(leftoverDecks, splitDecks[2])
                                end
                                table.insert(selectedDecks, preDeck)
                            end
                        else
                            table.insert(selectedDecks, preDeck)
                        end
                    else
                        table.insert(leftoverDecks, preDeck)
                    end
                end
            end
        else
            for _, guid in pairs(preDeckGUIDs) do
                table.insert(selectedDecks, getObjectFromGUID(guid))
            end
        end
    end

    return {mergeDecks(selectedDecks), mergeDecks(leftoverDecks)}
end

local function _dbf_determineGoodAndBadCards(preDeck, amountToTake)
    local cardsToRemove = {}
    local cardsToKeep = {}
    local goodCards = 0
    for _, objTable in pairs(preDeck.getObjects()) do
        if checkForNoGoes(objTable) then
            table.insert(cardsToKeep, objTable.guid)
            goodCards = goodCards + 1
            if goodCards == amountToTake then
                break
            end
        else
            table.insert(cardsToRemove, objTable.guid)
        end
    end
    return {GOOD = cardsToKeep, BAD = cardsToRemove, GOOD_AMOUNT = #cardsToKeep, BAD_AMOUNT = #cardsToRemove}
end

function buildDeckFilter(preDeckGUIDs, tagTable)
    local selectedDecks = {}
    local leftoverDecks = {}
    if tagTable == nil then
        for _, guid in pairs(preDeckGUIDs) do
            table.insert(leftoverDecks, getObjectFromGUID(guid))
        end
    else
        if isDeckBuilderON() then
            tagTable["EMPTY"] = MAX_EMPTY_CARDS
            for type, amountToTake in pairs(tagTable) do
                if preDeckGUIDs[type] ~= nil then
                    local preDeck = getObjectFromGUID(preDeckGUIDs[type])
                    if amountToTake > 0 then
                        if preDeck.tag == "Deck" then
                            -- For the edge case that only one card should be choosen
                            if amountToTake == 1 then
                                local leftovers = nil
                                for _, objTable in pairs(preDeck.getObjects())do
                                    if checkForNoGoes(objTable) then
                                        table.insert(selectedDecks, preDeck.takeObject({guid = objTable.guid}))
                                        leftovers = preDeck.remainder
                                        break
                                    end
                                end
                                if leftovers then
                                    table.insert(leftoverDecks, leftovers)
                                else
                                    table.insert(leftoverDecks, preDeck)
                                end
                            else
                                local goodAndBad = _dbf_determineGoodAndBadCards(preDeck, amountToTake)
                                if goodAndBad.GOOD_AMOUNT > 0 then
                                    if goodAndBad.GOOD_AMOUNT > goodAndBad.BAD_AMOUNT then
                                        -- More good than bad cards
                                        leftoverDecks = takeCardsFromDeck(preDeck, goodAndBad.BAD, leftoverDecks)
                                        if goodAndBad.GOOD_AMOUNT < preDeck.getQuantity() then
                                            -- There are more cards in the preDeck than the counted good and bad cards
                                                -- This appears if _dbf_determineGoodAndBadCards() found enough good cards to return
                                            if goodAndBad.GOOD_AMOUNT == (preDeck.getQuantity() - 1) then
                                                -- One needless card left
                                                local cardLeft = preDeck.takeObject({top = false})
                                                table.insert(leftoverDecks, cardLeft)
                                                table.insert(selectedDecks, preDeck)
                                            else
                                                -- More than one needless card left => cut()
                                                local splitDecks = preDeck.cut(preDeck.getQuantity() - goodAndBad.GOOD_AMOUNT)
                                                if splitDecks ~= nil then
                                                    table.insert(leftoverDecks, splitDecks[2])
                                                end
                                                table.insert(selectedDecks, preDeck)
                                            end
                                        else
                                            -- Whole deck is split into good and bad cards
                                            table.insert(selectedDecks, preDeck)
                                        end
                                    else
                                        -- More bad than good cards
                                        selectedDecks = takeCardsFromDeck(preDeck, goodAndBad.GOOD, selectedDecks)
                                        table.insert(leftoverDecks, preDeck)
                                    end
                                else
                                    -- No good cards found
                                    table.insert(leftoverDecks, preDeck)
                                end
                            end
                        else
                            -- preDeck is Card
                            if checkForNoGoes({name = preDeck.getName(), lua_script = preDeck.getLuaScript()
                                , tags = preDeck.getTags()}) then
                                table.insert(selectedDecks, preDeck)
                            else
                                table.insert(leftoverDecks, preDeck)
                            end
                        end
                    else
                        -- No cards needed from this preDeck
                        table.insert(leftoverDecks, preDeck)
                    end
                end
            end
        else
            for _, guid in pairs(preDeckGUIDs) do
                table.insert(selectedDecks, getObjectFromGUID(guid))
            end
        end
    end

    return {mergeDecks(selectedDecks), mergeDecks(leftoverDecks)}
end

function buildDeckSeed(deckInfoTable, baseDeck)
    for deckType, selectedCards in pairs(seed_selectedCards) do
        if deckInfoTable.ID == deckType then
            local zoneGUID = Global.getTable("ZONE_GUID_DECK")[deckType]
            local finalDeck = Global.call("getDeckFromZone", {zoneGUID = zoneGUID})
            local dummyCards = nil
            if (finalDeck == nil) or (finalDeck.type ~= "Deck") then
                local dummyDeck = getObjectFromGUID(TABLE_BASE_GUID).call("getDummyDeck", {deckID = deckType})
                if dummyDeck == nil then
                    Global.call("printWarning", {text = "Can't find dummy deck for " .. deckType})
                    return nil
                end
                dummyDeck.interactable = true
                dummyDeck.setPosition(getObjectFromGUID(zoneGUID).getPosition():setAt('y', 5))
                dummyDeck.setRotation(getObjectFromGUID(zoneGUID).getRotation():setAt('z', 180))
                dummyCards = dummyDeck.getObjects()
                finalDeck = dummyDeck
            end
            finalDeck.setName("")

            for _, cardInfoTable in pairs(baseDeck.getObjects()) do
                if selectedCards[cardInfoTable.gm_notes] then
                    finalDeck.putObject(baseDeck.takeObject({guid = cardInfoTable.guid}))
                end
            end

            if dummyCards then
                if finalDeck.getQuantity() == 2 then
                    destroyObject(finalDeck)
                    return finalDeck
                else
                    local remainder = nil
                    for _, infoTable in pairs(dummyCards) do
                        finalDeck.takeObject({guid = infoTable.guid, position = Global.getTable("DEAD_END_POSITION")})
                        remainder = finalDeck.remainder
                    end
                    finalDeck = remainder or finalDeck
                end
            end
            return finalDeck
        end
    end
end