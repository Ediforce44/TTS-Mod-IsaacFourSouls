require("vscode/console")

------------------------------------------------------------------------------------------------------------------------
--------------------------------------------- Edited by Ediforce44 -----------------------------------------------------
------------------------------------------------ local functions -------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function getDeckOrCard(zoneGUID)
    local zone = getObjectFromGUID(zoneGUID)
    if zone == nil then
        printWarning({text = "Wrong Zone. Zone with GUID '" .. zoneGUID .. "' doesn't exist."})
        return nil
    end

    for _, obj in pairs(zone.getObjects()) do
      if obj.tag == "Deck" or obj.tag == "Card" then
          return obj
      end
    end

    return nil
end

local function setPositionTables()
    DISCARD_PILE_POSITION.TREASURE = getObjectFromGUID(ZONE_GUID_DISCARD.TREASURE).getPosition():setAt('y', 5)
    DISCARD_PILE_POSITION.LOOT = getObjectFromGUID(ZONE_GUID_DISCARD.LOOT).getPosition():setAt('y', 5)
    DISCARD_PILE_POSITION.MONSTER = getObjectFromGUID(ZONE_GUID_DISCARD.MONSTER).getPosition():setAt('y', 5)
    DISCARD_PILE_POSITION.ROOM = getObjectFromGUID(ZONE_GUID_DISCARD.ROOM).getPosition():setAt('y', 5)

    DECK_POSITION.TREASURE = getObjectFromGUID(ZONE_GUID_DECK.TREASURE).getPosition():setAt('y', 5)
    DECK_POSITION.ROOM = getObjectFromGUID(ZONE_GUID_DECK.ROOM).getPosition():setAt('y', 5)
    DECK_POSITION.LOOT = getObjectFromGUID(ZONE_GUID_DECK.LOOT).getPosition():setAt('y', 5)
    DECK_POSITION.MONSTER = getObjectFromGUID(ZONE_GUID_DECK.MONSTER).getPosition():setAt('y', 5)
    DECK_POSITION.BONUS_SOUL = getObjectFromGUID(ZONE_GUID_DECK.BONUS_SOUL).getPosition():setAt('y', 5)
    DECK_POSITION.MONSTER_SEP = Vector(41.73, 5, -11.51)
    DECK_POSITION.LO_TREASURE = Vector(41.73, 5, 15.06)
    DECK_POSITION.LO_LOOT = Vector(41.73, 5, 11.73)
    DECK_POSITION.LO_MONSTER = Vector(41.73, 5, -14.84)
    DECK_POSITION.LO_ROOM = Vector(47, 5, 6)
    DECK_POSITION.LO_BONUS_SOUL = Vector(47, 5, 12)

    DEAD_END_POSITION = getObjectFromGUID("ad2a86").getPosition()
end

local function enterDebugMode()
    UI.show("debug")
end
------------------------------------------------------------------------------------------------------------------------
local turn_module = nil


function onLoad(saved_data)         --EbyE44
    turn_module = getObjectFromGUID(TURN_MODULE_GUID)

    setPositionTables()

    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        if loaded_data.activePlayerColor then
            activePlayerColor = loaded_data.activePlayerColor
        else
            activePlayerColor = "Red"
        end
        if loaded_data.startPlayerColor then
            setNewStartPlayer({playerColor = loaded_data.startPlayerColor})
        end
        if loaded_data.playerSettings then
            PLAYER_SETTINGS = loaded_data.playerSettings
        end
        if loaded_data.minionZoneInfo then
            for i, infoTable in ipairs(loaded_data.minionZoneInfo) do
                table.insert(ZONE_INFO_MINION, i, infoTable)
            end
        end
        if loaded_data.bossZoneGuid then
            ZONE_GUID_BOSS = loaded_data.bossZoneGuid
        end
        if loaded_data.customCounterBagGuids then
            COUNTER_BAGS_GUID = loaded_data.customCounterBagGuids
        end
    end
    if not hasGameStarted() then
        UI.show("config")
        UI.setAttribute("config", "visibility", "Host")
    else
        UI.setAttribute("passButton", "image", "turn_" .. string.lower(activePlayerColor))
        UI.setAttribute("passButton", "textColor", PLAYER_COLOR_HEX[activePlayerColor])
        UI.show("turnInfo")
        UI.setAttribute("turnInfo", "visibility", activePlayerColor .. "|Black")
    end
    broadcastToAll("The Binding of Isaac: Four Souls - FULL loaded.", {1,1,1})
end

function onSave()                   --EbyE44
    return JSON.encode({activePlayerColor = activePlayerColor, startPlayerColor = startPlayerColor
        , playerSettings = PLAYER_SETTINGS, minionZoneInfo = ZONE_INFO_MINION, bossZoneGuid = ZONE_GUID_BOSS
        , customCounterBagGuids = COUNTER_BAGS_GUID})
end

HEART_TOKENS_GUID = {
    Yellow = {"6d1f5d", "c02908", "3f81b7", "f8e991", "f825c2", "2a9dfc", "443adb"},
    Green = {"7023b1", "12326f", "c326f1", "f5d095", "7e882b", "66804c", "e24915"},
    Blue = {"8c24ed", "78f8e7", "c9f7b2", "4b26ea", "098303", "9e8aa0", "dbcc87"},
    Red = {"975325", "bcabf3", "ca5135", "0a7171", "33bf0c", "159680", "c7837a"}
}

function startTurnSystem()
    if turn_module then
        turn_module.call("startTurnSystem", {startPlayerColor = startPlayerColor})
    end
end

----------------------------------------------- Deprecated ------------------------------------------------------------
-- USE SAME FUNCTIONS ON TURN MODULE DIRECTLY --
function addTurnEvent(params)
    if turn_module then
        return turn_module.call("addTurnEvent", params)
    end
end

function deactivateTurnEvent(params)
    if turn_module then
        turn_module.call("deactivateTurnEvent", params)
    end
end

function activateTurnEvent(params)
    if turn_module then
        turn_module.call("activateTurnEvent", params)
    end
end

------------------------------------------------------------------------------------------------------------------------
-------------------------------------------- Seed algorithm functions --------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local SEEDARGS_TO_WEBARGS = {
    WARP_ZONE = "deck_rwz",
    ALT_ART = "deck_aa",
    TARGET = "deck_t",
    GISH = "deck_gi",
    TAPEWORM = "deck_tw",
    DICK_KNOTS = "deck_dk",
    UNBOXING_OF_ISAAC = "deck_box",
    PROMO = "deck_p",
    BASE_GAME = "deck_b2",
    FOUR_SOULS_PLUS = "deck_fsp2",
    REQUIEM = "deck_r",
    GOLD_BOX = "deck_g2",
    CHARACTERS = "players",
    CHARACTERS_ACTIVE = "specplayers",
    RATIOS = "ratios",
    L_TAROT_MISC = "ld_c", L_TRINKET = "ld_t", L_PILL = "ld_p", L_RUNE = "ld_r", L_BUTTER_BEAN = "ld_bb", L_BOMB = "ld_bo",
    L_BATTERY = "ld_ba", L_DICE_SHARD = "ld_ds", L_SOUL_HEART = "ld_sh", L_LOST_SOUL = "ld_ls", L_NICKEL = "ld_5c",
    L_FOUR_CENT = "ld_4c", L_THREE_CENT = "ld_3c", L_TWO_CENT = "ld_2c", L_ONE_CENT = "ld_1c",
    M_BOSS = "md_bo", M_EPIC = "md_eb", M_BASIC = "md_b", M_CURSED = "md_ce", M_HOLY_CHARMED = "md_hce", M_GOOD = "md_be",
    M_BAD = "md_ge", M_CURSE = "md_c",
    T_ACTIVE = "td_a", T_PASSIVE = "td_pas", T_PAID = "td_pai", T_ONE_USE = "td_ou", T_SOUL = "td_s"
}

local function seedargsToWebargs(seed, seedArgs)
    local httpBody = {seed = seed, ratios = "o"}
    for seedArg, argValue in pairs(seedArgs) do
        if argValue then
            if argValue == true then
                httpBody[SEEDARGS_TO_WEBARGS[seedArg]] = "on"
            else
                httpBody[SEEDARGS_TO_WEBARGS[seedArg]] = tostring(argValue)
            end
        end
    end
    return httpBody
end

------------------------------------------------------------------------------------------------------------------------
---------------------------------------------- UI config functions -----------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
CHALLENGE_MODULE = "b7ad0b"
SEED_MODULE = "19bfa6"

local BUILDING_MODE_TO_RATIOS = {
    BM_NO = nil,
    BM_NORMAL = "o",
    BM_DRAFT = "d",
    BM_CUSTOM = "c"
}

local BUILDING_MODE_FUNCTIONS = {
    BM_NO       = "disableDeckBuilder",
    BM_NORMAL   = "gmNormal",
    BM_DRAFT    = "gmDraft",
    BM_CUSTOM   = "gmCustom"
}

local STD_RATIOS = {
    LOOT = {L_TAROT_MISC = 23, L_TRINKET = 11, L_PILL = 3, L_RUNE = 3, L_BUTTER_BEAN = 5, L_BOMB = 6, L_BATTERY = 6,
        L_DICE_SHARD = 3, L_SOUL_HEART = 2, L_LOST_SOUL = 1, L_NICKEL = 6, L_FOUR_CENT = 12, L_THREE_CENT = 11,
        L_TWO_CENT = 6, L_ONE_CENT = 2},
    MONSTER = {M_BOSS = 30, M_EPIC = 1, M_BASIC = 30, M_CURSED = 9, M_HOLY_CHARMED = 9, M_GOOD = 8, M_BAD = 8, M_CURSE = 5},
    TREASURE = {T_ACTIVE = 40, T_PASSIVE = 44, T_PAID = 10, T_ONE_USE = 5, T_SOUL = 1}
}

confTable = {
    EXPANSION_ACTIVE    = false,
    ADVANCED_MODE_ACTIVE= false,
    ROOMS_ACTIVE        = true,
    BONUS_SOULS_ACTIVE  = true,
    MULTI_CHAR_ACTIVE   = false,
    CHALLENGES_ACTIVE   = false,
    EXPANSIONS  = {},
    BUILDING_MODE = "BM_NORMAL",
    CHALLENGE   = nil,
    CHALLENGE_AUTO = true,
    CHALLENGE_DIF = "DIF_NORMAL",
    CHALLENGE_COMP = false,
    RANDOM_SEED = false,
    SEED        = nil,
    SEED_ARGS   = {
        WARP_ZONE = true,
        ALT_ART = true,
        TARGET = true,
        GISH = true,
        TAPEWORM = true,
        DICK_KNOTS = true,
        UNBOXING_OF_ISAAC = true,
        PROMO = true,
        BASE_GAME = true,
        FOUR_SOULS_PLUS = true,
        REQUIEM = true,
        GOLD_BOX = true,
        CHARACTERS_ACTIVE = false,
        CHARACTERS = 2,
        RATIOS = BUILDING_MODE_TO_RATIOS["BM_NORMAL"]
    },
    MULTI_CHAR = {Red = 1, Blue = 2, Green = 3, Yellow = 4},
    HOT_SEAT = {false, false, false, false},
    SPECIAL_DECKS = {},
    CUSTOM_RATIOS = STD_RATIOS
}

configurationFinished = true

local function getRatioType(ratioID)
    for type, idTable in pairs(STD_RATIOS) do
        if idTable[ratioID] then
            return type
        end
    end
    return nil
end

local function placeChallenge()
    local tempChallengeBag = getObjectFromGUID("e5a404").takeObject()
    Wait.frames(function()
        for _, challenge in pairs(tempChallengeBag.getObjects()) do
            if challenge.name == confTable.CHALLENGE then
                local challengeBag = tempChallengeBag.takeObject({guid = challenge.guid, position = DISCARD_PILE_POSITION.LOOT})

                if challengeBag.getVar("HAS_CUSTOM_SETTINGS") then
                    challengeBag.call("configureSettings")
                end
                break
            end
        end
        destroyObject(tempChallengeBag)
    end)
end

local function placeExpansions()
    local nextPosition = Vector(-42, 3, 4.5)
    local allObjects = Global.getObjects()
    for expansionName, selected in pairs(confTable.EXPANSIONS) do
        if selected then
            for _, obj in ipairs(allObjects) do
                if obj.getName() == expansionName then
                    obj.takeObject({position = nextPosition})
                    nextPosition:setAt('x', nextPosition.x + 3)
                    break
                end
            end
        end
    end
end

local function configurePlayerZoneOwners(ownerTable, hotSeat)
    local handZoneTable = {}
    local handZoneHotSeat = {}
    for playerID, colorTable in pairs(ownerTable) do
        local ownerColor = colorTable[1]
        handZoneHotSeat[ownerColor] = hotSeat[playerID]
        handZoneTable[ownerColor] = colorTable
    end

    for ownerColor, colorTable in pairs(handZoneTable) do
        for _, color in pairs(colorTable) do
            local playerZone = getObjectFromGUID(ZONE_GUID_PLAYER[color])
            if playerZone then
                playerZone.setVar("owner_color", ownerColor)
            end
        end
    end

    turn_module.call("joinHandZones", {combinedHandZones = handZoneTable, hotSeat = handZoneHotSeat})

    for ownerColor, colorTable  in pairs(handZoneTable) do
        local playerString = ""
        for _, color in pairs(colorTable) do
            playerString = playerString .. " - " .. getPlayerString({playerColor = color}) .. "[-]"
        end
        broadcastToAll(getPlayerString({playerColor = ownerColor}) .. "[-] plays " .. playerString .. " -")
    end
end

local function prepareSeedArgs()
    confTable.SEED_ARGS["RATIOS"] = BUILDING_MODE_TO_RATIOS[confTable.BUILDING_MODE]
    for specialDeckID, selected in pairs(confTable.SPECIAL_DECKS) do
        confTable.SEED_ARGS[specialDeckID] = selected
    end
    if confTable.CUSTOM_RATIOS then
        for _, ratioTable in pairs(confTable.CUSTOM_RATIOS) do
            for ratioID, ratioValue in pairs(ratioTable) do
                confTable.SEED_ARGS[ratioID] = ratioValue
            end
        end
    end
    if not confTable.SEED_ARGS["CHARACTERS_ACTIVE"] then
        confTable.SEED_ARGS["CHARACTERS"] = nil
    end
    if confTable.RANDOM_SEED then
        confTable.SEED = ""
    end
end

function UI_toggleExpansion(_, toggle, expansionID)
    if toggle == "True" then
        confTable.EXPANSIONS[expansionID] = true
    else
        confTable.EXPANSIONS[expansionID] = false
    end
end

function UI_selectChallenge(_, selected, challengeID)
    if selected == "True" then
        confTable.CHALLENGE = challengeID
    end
end

function UI_selectBuildingMode(_, selected, buildingModeID)
    if selected == "True" then
        confTable.BUILDING_MODE = buildingModeID
    end
end

function UI_toggleSpecialDeck(_, toggle, specialDeckID)
    if toggle == "True" then
        confTable.SPECIAL_DECKS[specialDeckID] = true
    else
        confTable.SPECIAL_DECKS[specialDeckID] = false
    end
end

function UI_setSeed(_, seed)
    confTable.SEED = seed
end

function UI_setSeededChars(_, playerCount)
    if playerCount and tonumber(playerCount) then
        if tonumber(playerCount) > 4 then
            confTable.SEED_ARGS["CHARACTERS"] = 4
            UI.setAttribute("confSeedPlayer", "text", "4")
        elseif tonumber(playerCount) < 2 then
            confTable.SEED_ARGS["CHARACTERS"] = 2
            UI.setAttribute("confSeedPlayer", "text", "2")
        else
            confTable.SEED_ARGS["CHARACTERS"] = tonumber(playerCount)
        end
    else
        confTable.SEED_ARGS["CHARACTERS"] = nil
        UI.setAttribute("confSeedPlayer", "text", "2")
    end
end

function UI_toggleRooms(_, checked)
    if checked == "True" then
        confTable.ROOMS_ACTIVE = true
    else
        confTable.ROOMS_ACTIVE = false
    end
end

function UI_toggleBonusSouls(_, checked)
    if checked == "True" then
        confTable.BONUS_SOULS_ACTIVE = true
    else
        confTable.BONUS_SOULS_ACTIVE = false
    end
end

function UI_toggleMultiChar(_, checked)
    if checked == "True" then
        confTable.MULTI_CHAR_ACTIVE = true
        UI.show("multiCharButton")
    else
        confTable.MULTI_CHAR_ACTIVE = false
        UI.hide("multiCharButton")
        UI_multiCharDone()
    end
end

function UI_openMultiCharSettings()
    if UI.getAttribute("multiCharSettings", "active") == "false" then
        UI.show("multiCharSettings")
    else
        UI_multiCharDone()
    end
end

function UI_multiCharChanged(_, checked, id)
    if checked == "True" then
        local multiCharID = {}
        local i = 1
        for key in string.gmatch(id, "[%w%d]+") do
            multiCharID[i] = key
            i = i + 1
        end
        confTable.MULTI_CHAR[multiCharID[1]] = tonumber(multiCharID[2])
    end
end

function UI_toggleHotSeat(_, _, id)
    local playerID = 0
    for key in string.gmatch(id, "[%d]+") do
        playerID = tonumber(key)
        break
    end
    local color = "#EAE5DE"
    if confTable.HOT_SEAT[playerID] then
        confTable.HOT_SEAT[playerID] = false
    else
        color = "#D43723"
        confTable.HOT_SEAT[playerID] = true
    end
    UI.setAttribute(id, "color", color)
    UI.setAttribute("Player_" .. playerID, "color", color)
end

function UI_multiCharDone()
    UI.setAttribute("multiCharSettings", "active", "false")
end

function UI_toggleChallenges(_, checked)
    if checked == "True" then
        UI.show("challenges")
        confTable.CHALLENGES_ACTIVE = true
    else
        UI.hide("challenges")
        confTable.CHALLENGES_ACTIVE = false
    end
end

function UI_toggleExpansionModule()
    if not confTable.EXPANSION_ACTIVE then
        UI.show("confExpansions")
        confTable.EXPANSION_ACTIVE = true
    else
        UI.hide("confExpansions")
        confTable.EXPANSION_ACTIVE = false
    end
end

function UI_toggleAdvancedModule()
    if not confTable.ADVANCED_MODE_ACTIVE then
        UI.show("confAdvanced")
        confTable.ADVANCED_MODE_ACTIVE = true
    else
        UI.hide("confAdvanced")
        confTable.ADVANCED_MODE_ACTIVE = false
    end
end

function UI_toggleRandomSeed(_, checked)
    if checked == "True" then
        UI.setAttribute("confSeedSeed", "interactable", "false")
        confTable.RANDOM_SEED = true
    else
        UI.setAttribute("confSeedSeed", "interactable", "true")
        confTable.RANDOM_SEED = false
    end
end

function UI_toggleSeededChars(_, checked)
    if checked == "True" then
        UI.setAttribute("confSeedPlayer", "interactable", "true")
        confTable.SEED_ARGS["CHARACTERS_ACTIVE"] = true
    else
        UI.setAttribute("confSeedPlayer", "interactable", "false")
        confTable.SEED_ARGS["CHARACTERS_ACTIVE"] = false
    end
end

function UI_toggleSeedDeck(_, checked, seedDeckID)
    if checked == "True" then
        confTable.SEED_ARGS[seedDeckID] = true
    else
        confTable.SEED_ARGS[seedDeckID] = false
    end
end

function UI_configurationDone(player)
    if not player.admin then
        return
    end
    UI_multiCharDone()

    UI.hide("config")

    local deckBuilder = getObjectFromGUID(DECK_BUILDER_MODULE_GUID)
    if not confTable.ROOMS_ACTIVE then
        deckBuilder.call("disableDeck", {deckID = "ROOM"})
    end
    if not confTable.BONUS_SOULS_ACTIVE then
        deckBuilder.call("disableDeck", {deckID = "BONUS_SOUL"})
    end
    if confTable.MULTI_CHAR_ACTIVE then
        local ownerTable = {}
        for color, playerID in pairs(confTable.MULTI_CHAR) do
            if ownerTable[playerID] then
                table.insert(ownerTable[playerID], color)
            else
                ownerTable[playerID] = {color}
            end
        end
        
        configurePlayerZoneOwners(ownerTable, confTable.HOT_SEAT)
    end
    if confTable.CHALLENGES_ACTIVE then
        getObjectFromGUID(ZONE_GUID_DECK.MONSTER).call("activateChallengeMode")
        getObjectFromGUID(CHALLENGE_MODULE).call("setupTableForChallenge")
        placeChallenge()
    end
    if confTable.EXPANSION_ACTIVE then
        placeExpansions()
    end

    if confTable.BUILDING_MODE == "BM_CUSTOM" then
        configurationFinished = false
        UI.show("customRatios")
    else
        confTable.CUSTOM_RATIOS = nil
        if confTable.CHALLENGES_ACTIVE then
            endconfigurationFinished = false
            UI.show("challengeSettings")
        end
    end

    Wait.condition(function()
        deckBuilder.call(BUILDING_MODE_FUNCTIONS[confTable.BUILDING_MODE], {ratios = confTable.CUSTOM_RATIOS})

        if (confTable.ADVANCED_MODE_ACTIVE) and (confTable.BUILDING_MODE ~= "BM_NO") then
            if confTable.SEED and not confTable.RANDOM_SEED then
                if #confTable.SEED ~= 8 then
                    printWarning({text="If you want to use a seed, make sure it is 8 characters long."})
                    confTable.SEED = nil
                end
            end
            if (confTable.SEED == nil) and not confTable.RANDOM_SEED then
                for specialDeckID, selected in pairs(confTable.SPECIAL_DECKS) do
                    if not selected then
                        deckBuilder.call("setNoGo", {nogo = specialDeckID})
                    end
                end
            else
                prepareSeedArgs()
                local webArgs = seedargsToWebargs(confTable.SEED, confTable.SEED_ARGS)
                getObjectFromGUID(SEED_MODULE).call("startSeedAlgorithm", {httpBody = webArgs})
            end
        end
    end, function() return configurationFinished end)
end

function UI_setRatio(_, ratio, ratioID)
    local ratioType = getRatioType(ratioID)
    if ratio and tonumber(ratio) then
        if tonumber(ratio) >= 0 then
            confTable.CUSTOM_RATIOS[ratioType][ratioID] = tonumber(ratio)
            return
        end
    end
    local stdRatio = STD_RATIOS[ratioType][ratioID]
    confTable.CUSTOM_RATIOS[ratioType][ratioID] = stdRatio
    UI.setAttribute(ratioID, "text", tostring(stdRatio))
end

function UI_ratiosDone(player)
    if not player.admin then
        return
    end
    UI.hide("customRatios")
    if confTable.CHALLENGES_ACTIVE then
        UI.show("challengeSettings")
    else
        configurationFinished = true
    end
end

function UI_toggleChallengeAuto(_, checked)
    if checked == "True" then
        confTable.CHALLENGE_AUTO = true
    else
        confTable.CHALLENGE_AUTO = false
    end
end

local CHALLENGE_DIFFICULTY = {
    DIF_NORMAL = "DIF_NORMAL",
    DIF_HARD = "DIF_HARD",
    DIF_ULTRA = "DIF_ULTRA",
    DIF_COMP = "DIF_COMP"
}
local hasSepCompMode = nil
function UI_selectChallengeDifficulty(_, _, difficultyID)
    if hasSepCompMode == nil then
        hasSepCompMode = getObjectFromGUID(CHALLENGE_MODULE).call("hasCompetitiveMode", {challengeName = confTable.CHALLENGE})
    end

    if not hasSepCompMode then
        if difficultyID == "DIF_COMP" then
            if UI.getAttribute(difficultyID .. "_IMAGE", "image") == (difficultyID) then
                UI.setAttribute(difficultyID .. "_IMAGE", "image", difficultyID .. "_SELECT")
                confTable.CHALLENGE_COMP = true
            else
                UI.setAttribute(difficultyID .. "_IMAGE", "image", difficultyID)
                confTable.CHALLENGE_COMP = false
            end
        else
            for _, difficulty in pairs(CHALLENGE_DIFFICULTY) do
                if difficulty == difficultyID then
                    UI.setAttribute(difficulty .. "_IMAGE", "image", difficulty .. "_SELECT")
                else
                    if difficulty ~= "DIF_COMP" then
                        UI.setAttribute(difficulty .. "_IMAGE", "image", difficulty)
                    end
                end
            end
            confTable.CHALLENGE_DIF = difficultyID
        end
    else
        for _, difficulty in pairs(CHALLENGE_DIFFICULTY) do
            if difficulty == difficultyID then
                UI.setAttribute(difficulty .. "_IMAGE", "image", difficulty .. "_SELECT")
            else
                UI.setAttribute(difficulty .. "_IMAGE", "image", difficulty)
            end
        end
        confTable.CHALLENGE_DIF = difficultyID
    end
end

function UI_challengeDone(player)
    if not player.admin then
        return
    end
    UI.hide("challengeSettings")
    local setupInfoTable = {}
    setupInfoTable["filterTagsActive"] = ((confTable.ADVANCED_MODE_ACTIVE) and (confTable.BUILDING_MODE ~= "BM_NO"))
    setupInfoTable["filterTags"] = confTable.SPECIAL_DECKS
    setupInfoTable["difficulty"] = confTable.CHALLENGE_DIF
    setupInfoTable["compMode"] = confTable.CHALLENGE_COMP
    setupInfoTable["automation"] = confTable.CHALLENGE_AUTO
    setupInfoTable["challengeName"] = confTable.CHALLENGE
    getObjectFromGUID(CHALLENGE_MODULE).call("presetupChallenge", setupInfoTable)
    configurationFinished = true
end

local clickCounterDebug = 0
function UI_hiddenButton()
    if clickCounterDebug < 0 then
        return
    end
    clickCounterDebug = clickCounterDebug + 1
    if clickCounterDebug >= 3 then
        enterDebugMode()
        clickCounterDebug = -100
    end
    Wait.time(function() clickCounterDebug = clickCounterDebug - 1 end, 0.5)
end

function UI_hideDebugPanel()
    UI.hide("debug")
end

function UI_debugBase()
    local newPosition = getObjectFromGUID("f5c4fe").call("prepareDebug")
    if newPosition.y > 0 then
        UI.setAttribute("debugBase", "text", "Lower Base")
    else
        UI.setAttribute("debugBase", "text", "Raise Base")
    end
end

function UI_extractChars(_, _, id)
    local characterManager = getObjectFromGUID("bc6e13")
    if characterManager then
        if id == "debugChars" then
            characterManager.call("_debug_characters")
        else
            characterManager.call("_debug_characters", {language = id:gsub("debugChars", "")})
        end
    else
        printWarning({text = "Character Manager not found (wrong GUID)!"})
    end
end

function UI_showReminder()
    UI.show("reminder")
end

function UI_hideReminder()
    UI.hide("reminder")
end

------------------------------------------------------------------------------------------------------------------------
--------------------------------------------- Edited by Ediforce44 -----------------------------------------------------
----------------------------------------------- global functions -------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
TABLE_BOUNDARIES = {x = 45, y = 0, z = 18}

function detectExpansions()
    local expansions = {}
    local allObjects = Global.getObjects()
    for _, obj in ipairs(allObjects) do
        local objPosition = obj.getPosition()
        if objPosition.y > TABLE_BOUNDARIES.y then
            if math.abs(objPosition.x) < TABLE_BOUNDARIES.x then
                if math.abs(objPosition.z) < TABLE_BOUNDARIES.z then
                    if obj.hasTag('EXPANSION') then
                        table.insert(expansions, obj)
                    end
                end
            end
        end
    end
    return expansions
end

function getRandomPlayerColor()
    local allPlayerColors = PLAYER
    local allActivePlayerColors = {}
    for _ , playerColor in pairs(allPlayerColors) do
        local zone = getObjectFromGUID(ZONE_GUID_PLAYER[playerColor])
        if zone and zone.getVar("active") then
            table.insert(allActivePlayerColors, playerColor)
        end
    end
    return allActivePlayerColors[math.random(#allActivePlayerColors)]
end

local pingEventAttachment = {}

function pingEvent_attach(params)
    if params.afterPingFunction then
        table.insert(pingEventAttachment, {playerColor = params.playerColor or getHandInfo()[activePlayerColor].owner
            , afterPingFunction = params.afterPingFunction, functionOwner = params.functionOwner
            , functionParams = params.functionParams or {}})
        return true
    end
    return false
end

function onPlayerPing(player, position, pingedObject)
    if #pingEventAttachment == 0 then
        return
    end

    local nextEntry = pingEventAttachment[1]
    if nextEntry.playerColor == player.color then
        table.remove(pingEventAttachment, 1)

        local functionParams = nextEntry.functionParams or {}
        functionParams.playerColor = nextEntry.playerColor
        functionParams.position = position
        functionParams.object = pingedObject
        if not nextEntry.functionOwner then
            Global.call(nextEntry.afterPingFunction, functionParams)
        else
            nextEntry.functionOwner.call(nextEntry.afterPingFunction, functionParams)
        end
    end
end

local colorPickerAttachment = {}

function pickColor(falseInput)
    if #colorPickerAttachment == 0 then
        return
    end

    local nextEntry = colorPickerAttachment[1]
    UI.show("colorPicker")
    UI.setAttribute("colorPicker", "visibility", nextEntry.picker)
    if (not falseInput) then
        broadcastToAll(getPlayerString({playerColor = nextEntry.picker}) .. " picks a Player Color for "
            .. nextEntry.reason .. ".")
        broadcastToColor("Please pick a Player Color for " .. nextEntry.reason .. ".", getHandInfo()[nextEntry.picker].owner)
    end
end

function colorPicker_attach(params)
    if params.afterPickFunction then
        table.insert(colorPickerAttachment, {picker = params.picker or getHandInfo()[activePlayerColor].owner
            , afterPickFunction = params.afterPickFunction, functionOwner = params.functionOwner
            , reason = params.reason or "Unknown", functionParams = params.functionParams or {}})
        if #colorPickerAttachment == 1 then
            pickColor(false)
        end
        return true
    end
    return false
end

function UI_colorPicked(player, _, idValue)
    local picker = getPlayerString({playerColor = player.color})
    local pickedColor = nil
    if idValue == "random" then
        pickedColor = getRandomPlayerColor()
        broadcastToAll(getPlayerString({playerColor = pickedColor}) .. " was picked at random!")
    else
        pickedColor = idValue
        local picked = getPlayerString({playerColor = pickedColor})
        local zone = getObjectFromGUID(ZONE_GUID_PLAYER[pickedColor])
        if not (zone and zone.getVar("active")) then
            broadcastToColor(picked .. " is not a active Player!", getHandInfo()[player.color].owner)
            pickColor(true)
            return
        end
        broadcastToAll(picker .. " picked " .. picked .. "!")
    end
    local nextEntry = colorPickerAttachment[1]
    local functionParams = nextEntry.functionParams or {}
    functionParams.pickedColor = pickedColor
    if not nextEntry.functionOwner then
        Global.call(nextEntry.afterPickFunction, functionParams)
    else
        nextEntry.functionOwner.call(nextEntry.afterPickFunction, functionParams)
    end
    table.remove(colorPickerAttachment, 1)
    UI.hide("colorPicker")
    if #colorPickerAttachment > 0 then
        pickColor(false)
    end
end

function UI_cancelPick(player, _, idValue)
    broadcastToAll(getPlayerString({playerColor = player.color}) .. " canceled the Color-Pick!", Table)
    table.remove(colorPickerAttachment, 1)
    UI.hide("colorPicker")
    if #colorPickerAttachment > 0 then
        pickColor(false)
    end
end

activePlayerColor   = "None"
startPlayerColor    = "None"
gameLanguage        = "None"

PLAYER_SETTINGS = {
    Yellow = {rewarding = true, deathDetection = false},
    Green = {rewarding = true, deathDetection = false},
    Blue = {rewarding = true, deathDetection = false},
    Red = {rewarding = true, deathDetection = false}
}

CLICK_DELAY = 0.3

function table.copy(t)
    local tableCopy = {}
    for key, value in pairs(t) do
        tableCopy[key] = value
    end
    return tableCopy
end

GAME_LANGUAGE = {
  US = "US",
  RU = "RU",
  FR = "FR",
  ES = "ES"
}

PLAYER = {
    Red = "Red",
    Blue = "Blue",
    Green = "Green",
    Yellow = "Yellow"
}

REAL_PLAYER_COLOR = {
    Yellow = "[E7E52C]",
    Green = "[2BB837]",
    Blue = "[1C79F8]",
    Red = "[C60A00]"
}

PLAYER_COLOR_HEX = {
    Red = "#C60A00",
    Blue = "#1C79F8",
    Green = "#33A92D",
    Yellow = "#D3D626"
}

REAL_PLAYER_COLOR_RGB = {
    Yellow = {231/255, 229/255, 44/255},
    Green = {43/255, 184/255, 55/255},
    Blue = {28/255, 121/255, 248/255},
    Red = {198/255, 10/255, 0/255}
}

PRINT_COLOR_PLAYER = {
    YELLOW = REAL_PLAYER_COLOR["Yellow"],
    GREEN = REAL_PLAYER_COLOR["Green"],
    BLUE = REAL_PLAYER_COLOR["Blue"],
    RED = REAL_PLAYER_COLOR["Red"]
}

PRINT_COLOR_SPECIAL = {
    WARNING = "[fdd835]",
    SOUL = "[C8EFF7]",
    MONSTER_LIGHT = "[67588B]",
    MONSTER = "[352853]",
    MINION = "[A10520]",
    COIN = "[AB9023]",
    LOOT = "[B9E9F0]",
    ROOM = "[5E4C3F]",
    TREASURE_LIGHT = "[D6BF5C]",
    TREASURE_DARK = "[998126]",
    HP = "[951312]",
    BLACK = "[010100]",
    GRAY = "[3B4449]",
    GRAY_LIGHT = "[7E8990]",
    RED = "[CE3522]",
    GOLD = "[E4BC2F]"
}

ZONE_GUID_DECK = {
    TREASURE = "190cda",
    ROOM = "096e94",
    LOOT = "c413a5",
    MONSTER = "52e22c",
    BONUS_SOUL = "979776",
    SOUL_TOKEN = "560abc"
}

ZONE_GUID_DISCARD = {
    TREASURE = "dae5d8",
    LOOT = "986a58",
    MONSTER = "61e7b7",
    ROOM = "8a48db"
}

ZONE_GUID_SHOP = {
    ONE = "fd849b",
    TWO = "15e210",
    THREE = "478a51",
    FOUR = "512193",
    FIVE = "5d1ed5",
    SIX = "094179"
}

ZONE_GUID_ROOM = {
    ONE = "8ccddb",
    TWO = "9f1558"
}

ZONE_GUID_MONSTER = {
    ONE = "329a95",
    TWO = "1a25c2",
    THREE = "27417f",
    FOUR = "f0d9fd",
    FIVE = "839d81",
    SIX = "6c1a32",
    SEVEN = "c28110"
}

ZONE_GUID_PLAYER = {
    Red = "b35919",
    Blue = "60361f",
    Green = "19df91",
    Yellow = "bb01dd"
}

ZONE_GUID_PILL = {
    Yellow = "53dd4c",
    Green = "e3361a",
    Blue = "9af794",
    Red = "d12e48"
}

ZONE_GUID_SOUL = {
    Yellow = "92610d",
    Green = "f95f84",
    Blue = "c0bd67",
    Red = "8515c8"
}

ZONE_GUID_BONUSSOUL = {
    ONE = "2046d8",
    TWO = "406a24",
    THREE = "5ffaca"
}

ZONE_INFO_MINION = {}

ZONE_GUID_BOSS = nil

COIN_COUNTER_GUID = {
    Yellow = "9d76db",
    Green = "c46653",
    Blue = "8edf63",
    Red = "965140"
}

SOUL_COUNTER_GUID = {
    Red = "98de07",
    Blue = "281235",
    Green = "4e958e",
    Yellow = "d340e6"
}

MONSTER_HP_COUNTER_GUID = {
    ONE = "9bb226",
    TWO = "a75691",
    THREE = "fab592",
    FOUR = "fb5299",
    FIVE = "b50db5",
    SIX = "bcac8d",
    SEVEN = "bc13f5"
}

COUNTER_BAGS_GUID = {
    NUMBER = "bb7a32",
    GOLD = "a0915e",
    EGG = "71e1f7",
    POOP = "9977a0",
    SPIDER = "abca4d",
    GUT = "8abd1b"
}

COUNTER_TYPE = {
    NUMBER  = "NUMBER",
    GOLD    = "GOLD",
    EGG     = "EGG",
    POOP    = "POOP",
    SPIDER  = "SPIDER",
    GUT     = "GUT",
}

SFX_CUBE_GUID = "ca024f"

TURN_MODULE_GUID = "87e737"
DECK_BUILDER_MODULE_GUID = "69a80e"
COUNTER_MODULE_GUID = COUNTER_BAGS_GUID.NUMBER

--Initialised in onLoad
DISCARD_PILE_POSITION = {
    TREASURE = {},
    LOOT = {},
    MONSTER = {},
    ROOM = {}
}

DECK_POSITION = {
    TREASURE = {},
    ROOM = {},
    BONUS_SOULS = {},
    LOOT = {},
    MONSTER = {},
    MONSTER_SEP = {},
    LO_TREASURE = {},
    LO_LOOT = {},
    LO_MONSTER = {},
    LO_ROOM = {},
    LO_BONUS_SOUL = {}
}

DEAD_END_POSITION = {}

CHALLENGE_LEFTOVERS_POSITION = Vector(46.8, 1.7, -6.5)
EVEN_MORE_CHARS_POSITION = Vector(86, 1.7, 0)

function printWarning(params)
    if params.text == nil then
        return
    end

    local sfxCube = getObjectFromGUID(Global.getVar("SFX_CUBE_GUID"))
    if sfxCube then
        sfxCube.call("playWrong")
    end
    printToAll(PRINT_COLOR_SPECIAL.GRAY_LIGHT .. PRINT_COLOR_SPECIAL.WARNING .. "[WARNING][-] " .. tostring(params.text) .. "[-]")
end

function printWarningTP(params)
    if params.text == nil then
        return
    end
    if params.color == nil then
        printWarning(params)
    else
        printToColor(PRINT_COLOR_SPECIAL.GRAY_LIGHT .. PRINT_COLOR_SPECIAL.WARNING .. "[WARNING][-] "
            .. tostring(params.text) .. "[-]", params.color)
    end
end

function setGameLanguage(params)
    if params.language == nil then
        printWarning({text = "Wrong parameter in Global function 'setGameLanguage()"})
        return
    end
    gameLanguage = params.language
end

function hasGameStarted()
    local setupNoteGUID = "56a44e"
    if getObjectFromGUID(setupNoteGUID) then
        return false
    end
    return true
end

function setNewStartPlayer(params)
    if params.playerColor == nil then
        printWarning({text = "Wrong parameters in global function 'setNewStartPlayer()'."})
        return false
    end
    if hasGameStarted() or (params.playerColor == startPlayerColor) then
        return false
    end
    local zone = getObjectFromGUID(ZONE_GUID_PLAYER[params.playerColor])
    if zone and Player[zone.getVar("owner_color")].seated then
        startPlayerColor = params.playerColor
        getObjectFromGUID("69a80d").call("selectStartTurn", {playerColor = params.playerColor})
        broadcastToAll(REAL_PLAYER_COLOR[params.playerColor] .. Player[zone.getVar("owner_color")].steam_name .. "[-] has the starting turn now!")
        return true
    else
        printWarning({text = "" .. getPlayerString(params) .. " is not an active Player."})
    end
    return false
end

function getHandInfo()
    return turn_module.getTable("HAND_INFO")
end

function getSpyInfo()
    return turn_module.getTable("SPY_INFO")
end

function getPlayerString(params)
    local playerString = "'Player not Found'"
    if params.playerColor ~= nil then
        playerString = REAL_PLAYER_COLOR[params.playerColor]
        if playerString == nil then
            playerString = ""
        end
        playerString = playerString .. params.playerColor .. "[-]"
    end
    return playerString
end

function getActivePlayerString()
    return getPlayerString({playerColor = activePlayerColor})
end

function isPlayerAuthorized(params)
    -- If there is no owner, all players have the permission to interact with something
    local ownerColor = params.ownerColor
    if ownerColor == nil then
        if params.owner == nil then
            return true
        else
            ownerColor = params.owner.color
        end
    end

    local playerColor = params.playerColor
    if playerColor == nil then
        if params.player == nil then
            return true
        else
            playerColor = params.player.color
        end
    end

    -- Interacting player has to be the owner or has to be an admin
    return (ownerColor == playerColor) or Player[playerColor].admin or (getHandInfo()[ownerColor].owner == playerColor)
end

function deactivateCharacter(params)
    if params.playerColor == nil then
        printWarning({text = "Wrong parameters in global function 'deactivateCharacter()'."})
        return
    end
    getObjectFromGUID(ZONE_GUID_PLAYER[params.playerColor]).call("deactivateCharacter")
end

function changeRewardingMode(params)
    local color = ""
    if params.playerColor == nil then
        if params.player == nil then
            printWarning({text = "Wrong parameters in global function 'changeRewardingMode()'."})
            return
        else
            color = params.player.color
        end
    else
        color = params.playerColor
    end
    local newValue = (params.active == true)
    if newValue ~= PLAYER_SETTINGS[color].rewarding then
        PLAYER_SETTINGS[color].rewarding = newValue
        getObjectFromGUID(ZONE_GUID_SOUL[color]).call("onSwitchingRewardingMode", {newState = newValue})
        local msg = "Your Auto Rewarding has been "
        if newValue == true then
            msg = msg .. "turned ON !!!"
        else
            msg = msg .."turned OFF !!!"
        end
        local ownerColor = getHandInfo()[color].owner
        if Player[ownerColor].seated then
            broadcastToColor(msg, ownerColor)
        end
    end
end

function changeDeathDetectionMode(params)
    local color = ""
    if params.playerColor == nil then
        if params.player == nil then
            printWarning({text = "Wrong parameters in global function 'changeDeathDetectionMode()'."})
            return
        else
            color = params.player.color
        end
    else
        color = params.playerColor
    end
    PLAYER_SETTINGS[color].deathDetection = (params.active == true)
end

function getCounterInZone(params)
    if params.zone == nil then
        printWarning({text = "Wrong parameters in global function 'getCounterInZone()'."})
    else
        for _ , object in pairs(params.zone.getObjects()) do
            if object.getName() == "Counter\n" or object.getName() == "Counter" then
                return object
            end
        end
    end
end

function getCounterOnCard(params)
    local card = params.card
    if card == nil then
        if params.guid then
            card = getObjectFromGUID(params.guid)
        else
            printWarning({text = "Wrong parameters in global function 'getCounterOnCard()'."})
        end
    end
    local allCounters = getObjectsWithAllTags({"Counter", "Number"})
    local cardPosition = card.getPosition()
    for _, counter in pairs(allCounters) do
        if math.abs(counter.getPosition().x - cardPosition.x) < 1.5 then
            if math.abs(counter.getPosition().z - cardPosition.z) < 2 then
                return counter
            end
        end
    end
end

--Thank you Bone White in discord for this <3       --Edited by Ediforce44
function findIntInScript(params)
    if params.scriptString == nil or params.varName == nil then
        printWarning({text = "Wrong parameters in global function 'findIntInScript()'."})
        return nil
    end
    for line in string.gmatch(params.scriptString,"[^\r\n]+") do -- for each line in the script
        if string.sub(line,1,#params.varName) == params.varName then -- if the beginning of the line matches var
            local value = string.match(line,"%d+",#params.varName) -- get the first number listed in that line after the var name
            return tonumber(value)
        end
    end
    return nil
end

function findBoolInScript(params)
    if params.scriptString == nil or params.varName == nil then
        printWarning({text = "Wrong parameters in global function 'findBoolInScript()'."})
        return nil
    end
    for line in string.gmatch(params.scriptString,"[^\r\n]+") do -- for each line in the script
        if string.sub(line,1,#params.varName) == params.varName then -- if the beginning of the line matches var
            local value = string.match(line,"true",#params.varName)
            if value == "true" then
                return true
            else
                return false
            end
        end
    end
    return nil
end

function getDeckFromZone(params)
    if params.zoneGUID == nil then
        printWarning({text = "Wrong parameters in global function 'getDeckFromZone()'."})
        return nil
    end
    return getDeckOrCard(params.zoneGUID)
end

function getMonsterDeck()
    local deck = getDeckOrCard(ZONE_GUID_DECK.MONSTER)
    if deck == nil then
        printWarning({text = "Can't find the deck or card in zone: Monster Zone."})
    end
    return deck
end

function getHappenDeck()
    local deck = getDeckOrCard(ZONE_GUID_DECK.HAPPEN)
    if deck == nil then
        printWarning({text = "Can't find the deck or card in zone: Happen Zone."})
    end
    return deck
end

function getTreasureDeck()
    local deck = getDeckOrCard(ZONE_GUID_DECK.TREASURE)
    if deck == nil then
        printWarning({text = "Can't find the deck or card in zone: Treasure Zone."})
    end
    return deck
end

function getLootDeck()
    local deck = getDeckOrCard(ZONE_GUID_DECK.LOOT)
    if deck == nil then
        printWarning({text = "Can't find the deck or card in zone: Loot Zone."})
    end
    return deck
end

function getBonusSoulDeck()
    local deck = getDeckOrCard(ZONE_GUID_DECK.BONUS_SOUL)
    if deck == nil then
        printWarning({text = "Can't find the deck or card in zone: Bonus Soul Zone."})
    end
    return deck
end

function getRoomDeck()
    local deck = getDeckOrCard(ZONE_GUID_DECK.ROOM)
    if deck == nil then
        printWarning({text = "Can't find the deck or card in zone: Room Zone."})
    end
    return deck
end

function getSoulTokenDeck()
    local deck = getDeckOrCard(ZONE_GUID_DECK.SOUL_TOKEN)
    if deck == nil then
        printWarning({text = "Can't find the deck or card in zone: Soul token zone."})
    end
    return deck
end

function getActivePlayerZone()
    return getObjectFromGUID(ZONE_GUID_PLAYER[activePlayerColor])
end

function getCardFromDeck(params)
    if params.deck == nil then
        printWarning({text = "Wrong parameters in global function 'getCardFromDeck()'."})
        return nil
    end
    local obj = params.deck
    local card = nil
    if obj.tag == "Deck" then
        card = obj.takeObject()
    elseif obj.tag == "Card" then
        card = obj
    end
    return card
end

function dealLootToColor(params)
    if params.color == nil then
        printWarning({text = "Wrong parameters in global function 'dealLootToColor()'."})
        return
    end
    local amount = params.amount or 1
    local lootDeck = getLootDeck()
    local handInfo = turn_module.getTable("HAND_INFO")[params.color]
    lootDeck.deal(amount, handInfo.owner, handInfo.index)
end

function placeSoulToken(params)
    if params.playerColor == nil then
        printWarning({text = "Wrong parameters in global function 'placeSoulToken()'."})
        return
    end
    local soulToken = getCardFromDeck({deck = getSoulTokenDeck()})
    if soulToken ~= nil then
        placeObjectInSoulZone({playerColor = params.playerColor, object = soulToken})
    else
        printWarning({text = "Can't find the Soul Token deck: Maybe the soul tokens are empty. " ..
                    "Place the soul tokens on its starting position."})
    end
end

function placeObjectInSoulZone(params)
    if (params.playerColor == nil) or (params.object == nil) then
        printWarning({text = "Wrong parameters in global function 'placeObjectInSoulZone()'."})
    else
        local index = nil
        if params.index ~= nil then
            index = params.index
        end
        getObjectFromGUID(ZONE_GUID_SOUL[params.playerColor]).call("placeObjectInZone", {object = params.object
            , index = index})
    end
end

function placeObjectInPillZone(params)
    if (params.playerColor == nil) or (params.object == nil) then
        printWarning({text = "Wrong parameters in global function 'placeObjectInPillZone()'."})
    else
        local index = nil
        if params.index ~= nil then
            index = params.index
        end
        getObjectFromGUID(ZONE_GUID_PILL[params.playerColor]).call("placeObjectInZone", {object = params.object
            , index = index})
    end
end

function placeObjectsInPlayerZone(params)
    if (params.playerColor == nil) or (params.objects == nil) then
        printWarning({text = "Wrong parameters in global function 'placeObjectsInPlayerZone()'."})
        return false
    end

    local objects = params.objects

    if #objects > 1 then
        return getObjectFromGUID(ZONE_GUID_PLAYER[params.playerColor]).call("placeMultipleObjectsInZone", params)
    elseif #objects == 1 then
        return getObjectFromGUID(ZONE_GUID_PLAYER[params.playerColor]).call("placeObjectInZone", {object = objects[1]
                , index = params.index, replacing = params.replacing})
    end
end

function placePlayerCounterInPlayerZone(params)
    if (params.playerColor == nil) or ((params.counter == nil) and (params.type == nil)) then
        printWarning({text = "Wrong parameters in global function 'placePlayerCounterInPlayerZone()'."})
    else
        local playerZone = getObjectFromGUID(ZONE_GUID_PLAYER[params.playerColor])
        if playerZone then
            playerZone.call("placeCounterInZone", params)
        end
    end
end

function placeCounter(params)
    if (params.counter == nil) and (params.type == nil) then
        printWarning({text = "Wrong parameters in global function 'placeCounter()'."})
        return
    end

    local position = nil
    local rotation = nil

    if params.position == nil then
        if params.object == nil then
            printWarning({text = "Wrong parameters in global function 'placeCounter()' [2]."})
            return
        else
            local object = params.object
            if (object.type == "Card") or (object.type == "Deck") then
                position = object.getPosition() + Vector(0, 3, 0)
                rotation = object.getRotation():setAt('z', 0)
            end
        end
    else
        position = params.position
        rotation = params.rotation or Vector(0, 180, 0)
    end

    if params.counter then
        params.counter.setPositionSmooth(position, false)
        params.counter.setRotationSmooth(rotation)
    else
        local counterBag = getObjectFromGUID(COUNTER_BAGS_GUID[params.type])
        local amount = params.amount or 1

        for i = 1, amount do
            local counter = nil
            if params.type == COUNTER_TYPE.NUMBER then
                counter = counterBag.call("getCounter", params)
            else
                counter = counterBag.takeObject()
            end

            counter.setPositionSmooth(position + Vector(0, 0.5 * i, 0), false)
            counter.setRotation(rotation, false)
        end
    end
end

function placeCounterInZone(params)
    if (params.counter == nil) and (params.type == nil) or (params.zone == nil) then
        printWarning({text = "Wrong parameters in global function 'placeCounterInZone()'."})
        return
    end
    local amount = params.amount or 1
    local endAmount = amount
    local rotation = params.rotation or Vector(0, 180, 0)

    local typeTag = params.type
    if typeTag == nil then
        local counterTags =  params.counter.getTags()
        if #counterTags >= 2 then
            typeTag = counterTags[2]
        end
    end
    if typeTag then
        for _, obj in pairs(params.zone.getObjects()) do
            if obj.hasTag(typeTag) then
                if obj.getQuantity() == -1 then
                    endAmount = endAmount + 1
                else
                    local counterObjectInZone = obj
                    if params.counter then
                        counterObjectInZone.putObject(params.counter)
                    else
                        local counterBag = getObjectFromGUID(COUNTER_BAGS_GUID[params.type])
                        for i = 1, amount do
                            local counter = counterBag.takeObject()
                            Wait.frames(function() counterObjectInZone.putObject(counter) end)
                        end
                    end
                    return obj.getQuantity() + amount
                end
            end
        end
    end

    params["position"] = params.zone.getPosition():setAt('y', 3)
    placeCounter(params)
    return endAmount
end
------------------------------------------------------------------------------------------------------------------------