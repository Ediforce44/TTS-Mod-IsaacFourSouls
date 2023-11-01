CHARACTER_MANAGER_GUID = "bc6e13"
CHALLENGE_MODULE_GUID = "b7ad0b"

PLAYER_COLORS = {'Red', 'Blue', 'Yellow', 'Green'}

START_BUTTON_INDEX = 1

--- Edited by Ediforce44
ZONE_GUIDS_DECK = Global.getTable("ZONE_GUID_DECK")
MONSTER_DECK_ZONE_GUID = ZONE_GUIDS_DECK.MONSTER
TREASURE_DECK_ZONE_GUID = ZONE_GUIDS_DECK.TREASURE
LOOT_DECK_ZONE_GUID = ZONE_GUIDS_DECK.LOOT
SOUL_DECK_ZONE_GUID = ZONE_GUIDS_DECK.BONUS_SOUL
ROOM_DECK_ZONE_GUID = ZONE_GUIDS_DECK.ROOM

BUILT_DECKS = {}

EXPANSION_LEFTOVERS_POSITION = {x = 46.8, y = 5, z = 0}
EXPANSION_LEFTOVERS_BAG_GUID = "3316b6"

DECK_BUILDER_GUID       = "69a80e"
SETTING_UP_NOTE_GUID    = "56a44e"
TABLE_BASE_GUID         = "f5c4fe"

ready_for_setup = false

local isButtonBlocked = false

local function topTwoCardsAreMonster(deck)
    if not deck or deck.getQuantity() < 2 then
        return true
    end
    local allCards = deck.getObjects()
    if (not Global.call("findBoolInScript", {scriptString = allCards[1].lua_script, varName = "isEvent"})) and
        (not Global.call("findBoolInScript", {scriptString = allCards[2].lua_script, varName = "isEvent"})) then
            return true
        end
    return false
end

local function setupPlayingArea()
    -- Edited by Ediforce44
    -- Init Monster Zones and Monster Buttons
    local allMonsterCards = BUILT_DECKS.MONSTER.getObjects()
    local emergenyExit = 0
    while not topTwoCardsAreMonster(BUILT_DECKS.MONSTER) do
        BUILT_DECKS.MONSTER.shuffle()
        emergenyExit = emergenyExit + 1
        if emergenyExit > 50 then
            break
        end
    end

    local monsterZoneGUIDs = Global.getTable("ZONE_GUID_MONSTER")
    getObjectFromGUID(monsterZoneGUIDs.ONE).call("activateZone")
    getObjectFromGUID(monsterZoneGUIDs.TWO).call("activateZone")
    getObjectFromGUID(monsterZoneGUIDs.THREE).call("deactivateZone")
    getObjectFromGUID(monsterZoneGUIDs.FOUR).call("deactivateZone")
    getObjectFromGUID(monsterZoneGUIDs.FIVE).call("deactivateZone")
    getObjectFromGUID(monsterZoneGUIDs.SIX).call("deactivateZone")
    getObjectFromGUID(monsterZoneGUIDs.SEVEN).call("deactivateZone")
    getObjectFromGUID(MONSTER_DECK_ZONE_GUID).call("activateChooseButton")

    local bossZoneGUID = Global.getVar("ZONE_GUID_BOSS")
    if bossZoneGUID then
        getObjectFromGUID(bossZoneGUID).call("setupZone")
    end

    -- Init Shop Zones and Shop Buttons
    local shopZoneGUIDs = Global.getTable("ZONE_GUID_SHOP")
    getObjectFromGUID(shopZoneGUIDs.ONE).call("activateZone")
    getObjectFromGUID(shopZoneGUIDs.TWO).call("activateZone")
    getObjectFromGUID(shopZoneGUIDs.THREE).call("deactivateZone")
    getObjectFromGUID(shopZoneGUIDs.FOUR).call("deactivateZone")
    getObjectFromGUID(shopZoneGUIDs.FIVE).call("deactivateZone")
    getObjectFromGUID(shopZoneGUIDs.SIX).call("deactivateZone")
    getObjectFromGUID(TREASURE_DECK_ZONE_GUID).call("activateShopButton")

    -- Init Loot Zone and Loot Button
    getObjectFromGUID(LOOT_DECK_ZONE_GUID).call("activateLootButton")

    -- Init Room Zones and Room Buttons
    if Global.getTable("confTable").ROOMS_ACTIVE then
        local roomZoneGUIDs = Global.getTable("ZONE_GUID_ROOM")
        getObjectFromGUID(roomZoneGUIDs.ONE).call("activateZone")
        getObjectFromGUID(roomZoneGUIDs.TWO).call("deactivateZone")
    end

    if Global.getTable("confTable").BONUS_SOULS_ACTIVE then
        local bonusSoulZones = Global.getTable("ZONE_GUID_BONUSSOUL")
        if BUILT_DECKS.BONUS_SOUL ~= nil then
            local remainder = nil
            if BUILT_DECKS.BONUS_SOUL.getQuantity() > 0 then
                for _, soulZone in pairs(bonusSoulZones) do
                    if remainder then
                        remainder.flip()
                        remainder.setPositionSmooth(getObjectFromGUID(soulZone).getPosition(), false)
                        break
                    end
                    BUILT_DECKS.BONUS_SOUL.takeObject({position=getObjectFromGUID(soulZone).getPosition(), flip=true})
                    remainder = BUILT_DECKS.BONUS_SOUL.remainder
                end
            else
                BUILT_DECKS.BONUS_SOUL.flip()
                BUILT_DECKS.BONUS_SOUL.setPositionSmooth(getObjectFromGUID(bonusSoulZones.ONE).getPosition(), false)
            end
        end
    end
end

local function extractDecksToDeckPositions(containerObj)
    local zoneGUIDs = Global.getTable('ZONE_GUID_DECK')
    local containerEmpty = true
    for type, infoTable in pairs(getObjectFromGUID(DECK_BUILDER_GUID).call("getDeckInfos")) do
        if infoTable.DISABLED then
            zoneGUIDs[type] = nil
        end
    end
    for _, deck in ipairs(containerObj.getObjects()) do
        if zoneGUIDs[deck.name] ~= nil then
            local deckInZone = nil
            local zone = getObjectFromGUID(zoneGUIDs[deck.name])
            for _, obj in pairs(zone.getObjects()) do
                if obj.type == "Deck" then
                    deckInZone = obj
                    break
                end
            end
            if deckInZone ~= nil then
                local extractedDeck = containerObj.takeObject({
                    guid = deck.guid
                })
                deckInZone.putObject(extractedDeck)
            else
                containerObj.takeObject({
                    guid = deck.guid,
                    position = zone.getPosition(),
                    smooth = false,
                    rotation = zone.getRotation():setAt(3, 180)
                })
            end
        else
            containerEmpty = false
        end
    end
    return containerEmpty
end

local function takeCareOfExpansionLeftovers(bagWithLeftovers, expansionName)
    bagWithLeftovers.setName(tostring(expansionName))
    getObjectFromGUID(EXPANSION_LEFTOVERS_BAG_GUID).putObject(bagWithLeftovers)
end

local function hasExpansionLanguage(expansionBox, language)
    for _, obj in pairs(expansionBox.getObjects()) do
        if obj.name == language then
            return true
        end
    end
    return false
end

local function extractExpansion(expansionBox, language)
    local objectsInBox = expansionBox.getObjects()
    if not hasExpansionLanguage(expansionBox, language) then
        language = Global.getTable("GAME_LANGUAGE").US
    end
    for _, obj in ipairs(objectsInBox) do
        if obj.name == language then
            expansionBox.takeObject({
                index = obj.index,
                position = expansionBox.getPosition():sub(Vector(0,0, 4)),
                smooth = false,
                callback_function =
                    function(languageBag)
                        if extractDecksToDeckPositions(languageBag) then
                            destroyObject(languageBag)
                        else
                            takeCareOfExpansionLeftovers(languageBag, expansionBox.getName())
                        end
                        destroyObject(expansionBox)
                    end})
            return
        end
    end
    destroyObject(expansionBox)
end

local function getPreDecksOnTable()
    local preDecksOnTable = {}
    local zoneGUIDs = Global.getTable('ZONE_GUID_DECK')
    for zoneType, zoneGUID in pairs(zoneGUIDs) do
        local zone = getObjectFromGUID(zoneGUID)
        for _, obj in pairs(zone.getObjects()) do
            if obj.tag == "Deck" then
                preDecksOnTable[zoneType] = {EMPTY = obj.getGUID()}
                break
            end
        end
    end
    return preDecksOnTable
end

-- deckTableTwo overwrites deckTableOne entries if there a any duplicates
local function mergePreDecks(deckTableOne, deckTableTwo)
    if deckTableOne == nil then
        if deckTableTwo == nil then
            return {}
        else
            return deckTableTwo
        end
    elseif deckTableTwo == nil then
        return deckTableOne
    end

    local resultingDeckTable = deckTableOne
    for deckType, guidTable in pairs(deckTableTwo) do
        local preDeckTableEntry = resultingDeckTable[deckType]
        if preDeckTableEntry == nil then
            preDeckTableEntry = {}
        end
        for cardType, GUID in pairs(guidTable) do
            preDeckTableEntry[cardType] = GUID
        end
        resultingDeckTable[deckType] = preDeckTableEntry
    end
    return resultingDeckTable
end

local function setupExpansions(gameLanguage)
    local expansions = Global.call("detectExpansions")
    for i, expansion in ipairs(expansions) do
        Wait.time(function() extractExpansion(expansion, gameLanguage) end, i - 1)
    end
    return #expansions
end

local function setupOfficialContent(gameLanguage, startPlayerColor)
    if not ready_for_setup then
        local tableBase = getObjectFromGUID(TABLE_BASE_GUID)

        local preDeckGUIDs = tableBase.call("getPreDeckGUIDs", {language = gameLanguage})
        local preExpansionDeckGUIDs = getPreDecksOnTable()
        preDeckGUIDs = mergePreDecks(preDeckGUIDs, preExpansionDeckGUIDs)

        tableBase.call("shufflePreDecks", {preDecks = preDeckGUIDs})
        Wait.frames(
            function()
                getObjectFromGUID(DECK_BUILDER_GUID).call("buildAllDecks", {preDecks = preDeckGUIDs})
            end)
    end

    local allCounterGuids = Global.getTable("COIN_COUNTER_GUID")
    for _, counterGuid in pairs(allCounterGuids) do
        local counter = getObjectFromGUID(counterGuid)
        if counter then
            counter.call("setCoins", {newValue = 0})
        end
    end
    local playerZones = Global.getTable("ZONE_GUID_PLAYER")
    for color, counterGuid in pairs(allCounterGuids) do
        local counter = getObjectFromGUID(counterGuid)
        if counter then
            local playerZone = getObjectFromGUID(playerZones[color])
            if playerZone and playerZone.getVar("active") then
                counter.call("modifyCoins", {modifier = 3})
            end
        end
    end

    Wait.condition(
        function()
            checkAndShuffleDecks()
            if BUILT_DECKS.LOOT ~= nil then
                for zoneColor, guid in pairs(Global.getTable("ZONE_GUID_PLAYER")) do
                    local zone = getObjectFromGUID(guid)
                    if zone and zone.getVar("active") then
                        zone.call("healPlayer")

                        local handInfo = Global.getTable("HAND_INFO")[zoneColor]
                        BUILT_DECKS.LOOT.deal(3, handInfo.owner, handInfo.index)
                    end
                end
            end
            setupPlayingArea()

            for zoneColor, zoneGuid in pairs(Global.getTable("ZONE_GUID_PLAYER")) do
                local playerZone =  getObjectFromGUID(zoneGuid)
                if playerZone and playerZone.getVar("active") then
                    if playerZone.getVar("zone_color") == startPlayerColor then
                        playerZone.call("activateCharacter")
                    else
                        playerZone.call("deactivateCharacter")
                    end
                end
            end

            -- INSERT other setup steps

            self.editButton({
                index = 0,
                click_function = "dummy",
                label = "",
                tooltip = "",
                width = 0,
                height = 0,
                font_size = 0
            })

            Global.call("startTurnSystem")

            local sfxCube = getObjectFromGUID(Global.getVar("SFX_CUBE_GUID"))
            if sfxCube then
                sfxCube.call("playLaugh")
            end

            self.destroy()
        end,
        function()
            return ready_for_setup
        end)
end

local function setupChallengeStart(gameLanguage)
    if not ready_for_setup then
        local tableBase = getObjectFromGUID(TABLE_BASE_GUID)

        local preDeckGUIDs = tableBase.call("getPreDeckGUIDs", {language = gameLanguage})
        local preExpansionDeckGUIDs = getPreDecksOnTable()
        preDeckGUIDs = mergePreDecks(preDeckGUIDs, preExpansionDeckGUIDs)

        getObjectFromGUID(CHALLENGE_MODULE_GUID).call("setupChallenge", {preDeckGUIDs = preDeckGUIDs})
    else
        local preDeckGUIDs = getPreDecksOnTable()
        getObjectFromGUID(CHALLENGE_MODULE_GUID).call("setupChallenge", {preDeckGUIDs = preDeckGUIDs})
    end
end

function onLoad()
    self.createButton({
    click_function = "onStart",
    label = "Start",
    tooltip = "Click here to start!",
    function_owner = self,
    position = {0, 0.11, -1},
    rotation = {0, 0, 0},
    width = 1100,
    height = 500,
    font_size = 400,
    font_color= {1,1,1},
    color = {0.1,0.1,0.1}
})
end

function blockStartButton()
    isButtonBlocked = true
end

function unblockStartButton()
    isButtonBlocked = false
end

function decksBuilt(createdDecks)
    for type, deck in pairs(createdDecks) do
        BUILT_DECKS[type] = deck
    end
    ready_for_setup = true
end

function fadeOutButton(timeToFade)
    local timeSlices = timeToFade * 30
    local sliceLength = timeToFade / timeSlices
    local startColor = self.getButtons()[START_BUTTON_INDEX].color
    local colorSub = {sliceLength * startColor[1], sliceLength * startColor[2], sliceLength * startColor[3]}
    for slice = 0, timeSlices do
        Wait.time(function ()
            local preColor = self.getButtons()[START_BUTTON_INDEX].color
            local newColor = {preColor[1] - colorSub[1], preColor[2] - colorSub[2], preColor[3] - colorSub[3]}
            self.editButton({index = START_BUTTON_INDEX - 1, color = newColor})
        end, slice * sliceLength)
    end
end

function onStart()
    if Global.call("hasGameStarted") then
        return
    end

    if isButtonBlocked then
        Global.call("printWarning", {text = "The Start button is blocked until all configuration calculations are done."})
        return
    end

    local isAllReady = isAllPlayersSelectCharacter()
    if isAllReady == false or isAllReady == nil then
        Global.call("printWarning", {text = "Each player must take a character before start."})
        return
    end

    local startPlayerColor = Global.getVar("startPlayerColor")
    if startPlayerColor == "None" then
        for _, color in pairs(getSeatedPlayers()) do
            if Global.getTable("PLAYER")[color] then
                startPlayerColor = color
                break
            end
        end

        if startPlayerColor == "None" then
            Global.call("printWarning", {text = "At least 1 player must select a player color: Red, Blue, Green or Yellow."})
            return
        end
        Global.call("setNewStartPlayer", {playerColor = startPlayerColor})
    end

    if getObjectFromGUID(SETTING_UP_NOTE_GUID) ~= nil then
        settingUpNote = getObjectFromGUID(SETTING_UP_NOTE_GUID)
        destroyObject(settingUpNote)
    end

    getObjectFromGUID(CHARACTER_MANAGER_GUID).call("returnAllCharPacks")

    local gameLanguage = Global.getVar("gameLanguage")

    local amountOfExpansionsInPlay = setupExpansions(gameLanguage)
    local officialSetupDelay = 0
    if amountOfExpansionsInPlay > 0 then
        broadcastToAll(Global.getTable("PRINT_COLOR_SPECIAL").GRAY_LIGHT .. "Loading Expansions")
        local elBag = getObjectFromGUID(EXPANSION_LEFTOVERS_BAG_GUID)
        elBag.setPosition(EXPANSION_LEFTOVERS_POSITION)
        elBag.setScale({1.5, 1.5, 1.5})
        Wait.condition(function()
            elBag.setLock(true)
            elBag.interactable = true
        end, function() return elBag.resting end)
        officialSetupDelay = amountOfExpansionsInPlay + 1
    end

    Wait.time(
        function()
            if Global.getTable("confTable").CHALLENGES_ACTIVE then
                broadcastToAll(Global.getTable("PRINT_COLOR_SPECIAL").GRAY_LIGHT .. "Loading Challenge")
                setupChallengeStart(gameLanguage)
                Wait.time(
                    function()
                        broadcastToAll(Global.getTable("PRINT_COLOR_SPECIAL").GRAY_LIGHT .. "Loading Official Content")
                        setupOfficialContent(gameLanguage, startPlayerColor)
                    end, 1)
            else
                broadcastToAll(Global.getTable("PRINT_COLOR_SPECIAL").GRAY_LIGHT .. "Loading Official Content")
                setupOfficialContent(gameLanguage, startPlayerColor)
            end
        end, officialSetupDelay)
end

function isAllPlayersSelectCharacter()
    local characterPlacerObj = getObjectFromGUID(CHARACTER_MANAGER_GUID)
    local playersSpawnedCharacterObj = characterPlacerObj.getTable("playersSpawnedCharacterObj")
    local selectedCharacterCount = 0
    for _, pObjs in pairs(playersSpawnedCharacterObj) do
        if #pObjs > 0 then
            selectedCharacterCount = selectedCharacterCount + 1
        end
    end

    return (selectedCharacterCount == getPlayersCount()) and (selectedCharacterCount ~= 0)
end

function getPlayersCount()
    local counter = 0
    for _, zoneGuid in pairs(Global.getTable("ZONE_GUID_PLAYER")) do
        local playerZone = getObjectFromGUID(zoneGuid)
        if playerZone then
            local ownerColor = playerZone.getVar("owner_color")
            for _, player in pairs(Player.getPlayers()) do
                if ownerColor == player.color then
                    counter = counter + 1
                end
            end
        end
    end
    return counter
end

function checkAndShuffleDecks()
    local decksToShuffle = {}
    for type, _ in pairs(BUILT_DECKS) do
        if (BUILT_DECKS[type] ~= nil) and (BUILT_DECKS[type].tag == "Deck") then
          table.insert(decksToShuffle, BUILT_DECKS[type])
        else
          log("Can't find the " .. tostring(type) .. " Deck.")
        end
    end

    for i = 1, #decksToShuffle, 1 do
        local obj = decksToShuffle[i]
        if obj ~= nil then
            obj.shuffle()
        end
    end
end

function dummy()
end