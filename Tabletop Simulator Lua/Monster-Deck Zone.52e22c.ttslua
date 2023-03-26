--- Written by Ediforce44
MONSTER_ZONE_GUIDS = Global.getTable("ZONE_GUID_MONSTER")
BOSS_ZONE_GUID = nil

CHALLENGE_MODE = false

ON_DIE_EVENTS = {}
NEW_MONSTER_EVENTS = {}

DISCARD_PILE_POSITION = {}

ATTACK_BUTTON_STATES = {
    INACTIVE    = "Inactive",
    ATTACK      = "Attack",
    CHOOSE      = "This Zone",
    ATTACKING   = "Cancel",
    DIED        = "Finish Him",
    EVENT       = "Done!",
    SELECT      = "Select"
}
ATTACK_BUTTON_COLORS = {
    INACTIVE    = {0.114, 0.063, 0.224},
    ACTIVE      = {0.2, 0.157, 0.325}
}

CHOOSE_BUTTON_STATES = {
    ATTACK      = "Attack",
    CHOOSE      = "Cancel",
    SELECT      = ATTACK_BUTTON_STATES.SELECT
}
CHOOSE_BUTTON_INDEX = nil

LAST_STATE = nil

MONSTER_TAGS = {
    --The onReveal() function of this object will be called if it enters a Monster Zone.
    --  (Used to call onReveal() only the first time an object enters the same Monster Zone)
    NEW         = "New",
    --Every Monster Zone will ignore this object (This Tag has the highest priority out of all Monster tags)
    DEAD        = "Dead",
    --The Monster Zone with this object will be made indomitable.
    --  (No other Monster can be placed in this zone until this object leaves the zone)
    INDOMITABLE = "Indomitable"
}

EVENT_TYPES = {
    CURSE   = "curse",
    GOOD    = "eventGood",
    BAD     = "eventBad"
}

-- Used for states which will call functions from other objects if the player presses the button
--  e.g. "SELECT" {function_owner : obj, call_function : string, onlyMonster : bool}
STATE_PARAMS = nil

local function getChooseButton()
    if CHOOSE_BUTTON_INDEX == nil then
        return nil
    end

    return self.getButtons()[CHOOSE_BUTTON_INDEX + 1]
end

function getState()
    local chooseButton = getChooseButton()
    if chooseButton == nil then
        return nil
    end
    return chooseButton.label
end

local function getDoubleAltClickParameters(zone)
    DOUBLE_CLICK_PARAMETERS = {
        ["identifier"] = "AltClickTimer" .. zone.guid,
        ["function_owner"] = zone,
        ["function_name"] = "resetAltClickCounter",
        ["delay"] = Global.getVar("CLICK_DELAY")
    }
    return DOUBLE_CLICK_PARAMETERS
end

local function printEventPhrase(eventName, eventType)
    local eventPhrase = ""
    local activePlayerString = Global.call("getActivePlayerString")
    if eventType == EVENT_TYPES.CURSE then
        eventPhrase = eventPhrase .. Global.getTable("PRINT_COLOR_SPECIAL").MONSTER_LIGHT .. "CURSE TIME !!!"
    elseif eventType == EVENT_TYPES.GOOD then
        eventPhrase = eventPhrase .. "Nice! " .. activePlayerString .. " got a "
            .. Global.getTable("PRINT_COLOR_SPECIAL").GRAY .. eventName .. "[-]."
    elseif eventType == EVENT_TYPES.BAD then
        eventPhrase = eventPhrase .. "Ohhhh! " .. activePlayerString .. " got a "
            .. Global.getTable("PRINT_COLOR_SPECIAL").GRAY .. eventName .. "[-]."
    else
        eventPhrase = "An " .. Global.getTable("PRINT_COLOR_SPECIAL").GRAY .. "Event[-] occurred."
    end
    broadcastToAll(eventPhrase)
end

local function printAttackPhrase(monsterName)
    local phrase = nil
    if monsterName ~= "" then
        phrase = Global.call("getActivePlayerString")
        phrase = phrase .. " attacks " .. Global.getTable("PRINT_COLOR_SPECIAL").MONSTER_LIGHT .. monsterName .. "[-] !!!"
        broadcastToAll(phrase)
    end
    return phrase
end

-- Determines if an object is leaving the zone or if it is just consumed by another object within the zone
local function isObjectReallyLeaving(object, zone)
    local distance = object.getPosition():distance(zone.getPosition())
    -- adjust sensitivity (important for manuel card moving)
    if distance > 0.62 then
        return true
    end
    return false
end

-- Determines if an object is entering the zone from outside the zone or if it is just created within the zone
--- Except: - Deck (= 2 Cards) enters the zone and is split into 2 seperate cards in the zone
---         - A card picked up from a deck inside the zone
local function isObjectReallyEntering(object, zone)
    local distance = object.getPosition():distance(zone.getPosition())
    if distance > 0.05 then
        return true
    end
    return false
end

local function onNewMonsterReveal(card, zone)
    local revealed = not (card.call("onReveal", {zone = zone}) == false)    -- Standard is true
    if card.getVar("isEvent") and revealed then
        changeZoneState({zone = zone, newState = ATTACK_BUTTON_STATES.EVENT})
    end
end

local function getTopMostDeckOrCard(zone, except)
    local except = except or {}
    local zoneObjects = zone.getObjects()
    for index = #zoneObjects, 1, -1 do
        local object = zoneObjects[index]
        if object.tag == "Deck" or object.tag == "Card" then
            if not except[object.getGUID()] then
                return object
            end
        end
    end
    return nil
end

local function getFirstMonsterInZone(zone)
    local monsterCard = nil
    local searchedObjects = {}
    local found = false
    while not found do
        local topMostObject = getTopMostDeckOrCard(zone, searchedObjects)
        if topMostObject == nil then
            break
        end
        if topMostObject.type == "Deck" then
            local objectsInDeck = topMostObject.getObjects()
            for i = #objectsInDeck, 1, -1 do
                local card = objectsInDeck[i]
                if not Global.call("findBoolInScript", {scriptString = card.lua_script, varName = "isEvent"}) then
                    monsterCard = topMostObject.takeObject({guid = card.guid})
                    found = true
                    break
                end
            end
        elseif topMostObject.type == "Card" then
            if not topMostObject.getVar("isEvent") then
                monsterCard = topMostObject
                found = true
            end
        end
        searchedObjects[topMostObject.getGUID()] = true
    end
    return monsterCard
end

local function objectContainsGUID(object, GUID)
    if object.getGUID() == GUID then
        return true
    elseif object.tag == "Deck" then
        for _ , jsonObj in pairs(object.getData().ContainedObjects) do
            if jsonObj["GUID"] == GUID then
                return true
            end
        end
    end
    return false
end

local function getNextInactiveZone()
    for _ , guid in pairs(MONSTER_ZONE_GUIDS) do
        if getObjectFromGUID(guid).getVar("active") == false then
            return getObjectFromGUID(guid)
        end
    end
    return nil
end

local function isZoneChooseable(zone)
    if zone.getVar("active") and (not zone.getTable("active_monster_attrs").INDOMITABLE) then
        return true
    end
    return false
end

local function deleteExtrasInZone(zone)
    for _, obj in pairs(zone.getObjects()) do
        if (obj.type ~= "Card") and (obj.type ~= "Deck") and (obj.type ~= "Board") then
            destroyObject(obj)
        end
    end
end

function callMonsterDieEvents(params)
    local eventFunctionParams = params or {}
    for _, eventTable in ipairs(ON_DIE_EVENTS) do
        if eventTable.valid then
            for id, param in pairs(eventTable.function_params) do
                eventFunctionParams[id] = param
            end
            if eventTable.function_owner == nil then
                Global.call(eventTable.call_function, eventFunctionParams)
            else
                local functionOwner = getObjectFromGUID(eventTable.function_owner)
                if functionOwner then
                    functionOwner.call(eventTable.call_function, eventFunctionParams)
                end
            end
        end
    end
end

function addDieEvent(params)
    if (params == nil) or (params.call_function == nil) then
        return
    end
    local functionParams = params.function_params or {}
    table.insert(ON_DIE_EVENTS, {call_function = params.call_function, function_params = functionParams
        , function_owner = params.function_owner, valid = true})
end

function deactivateDieEvent(params)
    if params.eventID then
        ON_DIE_EVENTS[params.eventID].valid = false
    end
end

function activateDieEvent(params)
    if params.eventID then
        ON_DIE_EVENTS[params.eventID].valid = true
    end
end

function callNewMonsterEvents(params)
    local eventFunctionParams = params or {}
    for _, eventTable in ipairs(NEW_MONSTER_EVENTS) do
        if eventTable.valid then
            for id, param in pairs(eventTable.function_params) do
                eventFunctionParams[id] = param
            end
            if eventTable.function_owner == nil then
                Global.call(eventTable.call_function, eventFunctionParams)
            else
                local functionOwner = getObjectFromGUID(eventTable.function_owner)
                if functionOwner then
                    functionOwner.call(eventTable.call_function, eventFunctionParams)
                end
            end
        end
    end
end

function addNewMonsterEvent(params)
    if (params == nil) or (params.call_function == nil) then
        return
    end
    local functionParams = params.function_params or {}
    table.insert(NEW_MONSTER_EVENTS, {call_function = params.call_function, function_params = functionParams
        , function_owner = params.function_owner, valid = true})
end

function deactivateNewMonsterEvent(params)
    if params.eventID then
        NEW_MONSTER_EVENTS[params.eventID].valid = false
    end
end

function activateNewMonsterEvent(params)
    if params.eventID then
        NEW_MONSTER_EVENTS[params.eventID].valid = true
    end
end

------------------------------------------------------------------------------------------------------------------------
--------------------------------------------- Button functions ---------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function hasMoreActiveEvents(zone)
    for _ , guid in pairs(MONSTER_ZONE_GUIDS) do
        local monsterZone = getObjectFromGUID(guid)
        if monsterZone.call("getState") == ATTACK_BUTTON_STATES.EVENT then
            if monsterZone ~= zone then
                return true
            end
        end
    end
    return false
end

local function altClickAttackButton(zone, color)
    local clickCounter = zone.getVar("altClickCounter")
    if clickCounter > 0 then
        -- Reset all Monster-Zones
        local attackButtonState = zone.call("getAttackButton").label
        if attackButtonState == ATTACK_BUTTON_STATES.ATTACKING then
            click_function_AttackButton(zone, color, false)
        elseif attackButtonState == ATTACK_BUTTON_STATES.CHOOSE then
            click_function_ChooseButton(_, color, false)
        elseif attackButtonState == ATTACK_BUTTON_STATES.DIED then
            changeZoneState({zone = zone, newState = ATTACK_BUTTON_STATES.ATTACK})
        elseif attackButtonState == ATTACK_BUTTON_STATES.EVENT then
            if hasMoreActiveEvents(zone) then
                zone.call("deactivateZone")
                zone.call("deactivateAttackButton")
                return
            else
                changeZoneState({zone = zone, newState = ATTACK_BUTTON_STATES.ATTACK})
            end
        elseif attackButtonState == ATTACK_BUTTON_STATES.SELECT then
            zone.call("deactivateZone")
            zone.call("deactivateAttackButton")
            return
        end
        zone.call("deactivateZone")
    else
        zone.setVar("altClickCounter", clickCounter + 1)
        Timer.create(getDoubleAltClickParameters(zone))
    end
end

local function deactivateAllAttackButtons(zone, ignoreOwnButton, exceptionStates)
    ignoreOwnButton = ignoreOwnButton == true
    exceptionStates = exceptionStates or {}
    if CHALLENGE_MODE then
        getObjectFromGUID(BOSS_ZONE_GUID).call("deactivateAllAttackButtons"
            , {zone = zone, ignoreOwnButton = ignoreOwnButton, exceptionStates = exceptionStates})
        return
    end

    for _ , guid in pairs(MONSTER_ZONE_GUIDS) do
        local monsterZone = getObjectFromGUID(guid)
        if (not ignoreOwnButton) or (monsterZone.getGUID() ~= zone.guid) then
            local zoneState = monsterZone.call("getState")
            for _ , state in pairs(exceptionStates) do
                if zoneState == state then
                    goto continue
                end
            end
            monsterZone.call("deactivateAttackButton")
        end
        ::continue::
    end
    deactivateChooseButton()
end

local function activateAllAttackButtons()
    if CHALLENGE_MODE then
        getObjectFromGUID(BOSS_ZONE_GUID).call("activateAllAttackButtons")
        return
    end

    for _ , guid in pairs(Global.getTable("ZONE_GUID_MONSTER")) do
        getObjectFromGUID(guid).call("activateAttackButton")
    end
    activateChooseButton()
end

local function resetAllAttackButtons()
    if CHALLENGE_MODE then
        getObjectFromGUID(BOSS_ZONE_GUID).call("resetAllAttackButtons")
        return
    end

    for _, guid in pairs(Global.getTable("ZONE_GUID_MONSTER")) do
        getObjectFromGUID(guid).call("resetAttackButton")
    end
    resetChooseButton()
end
------------------------------------------------------------------------------------------------------------------------

function onLoad(saved_data)
    BOSS_ZONE_GUID = Global.getVar("ZONE_GUID_BOSS")
    DISCARD_PILE_POSITION = Global.getTable("DISCARD_PILE_POSITION").MONSTER
    if saved_data == "" then
        return
    end

    local loaded_data = JSON.decode(saved_data)
    if loaded_data.currentLabel then
        activateChooseButton()
        for _ , state in pairs(CHOOSE_BUTTON_STATES) do
            if state == loaded_data[1] then
                --self.editButton({index = CHOOSE_BUTTON_INDEX, label = state})
                self.editButton({index = CHOOSE_BUTTON_INDEX, label = state, tooltip = getChooseButtonTooltip(state)})
            end
        end
    end
    if loaded_data.challengeMode == true then
        CHALLENGE_MODE = true
    end
    if loaded_data.dieEvents then
        ON_DIE_EVENTS = loaded_data.dieEvents
    end
    if loaded_data.newMonsterEvents then
        NEW_MONSTER_EVENTS = loaded_data.newMonsterEvents
    end
end

function onSave()
    local currentLabel = nil
    if getChooseButton() then
        currentLabel = getChooseButton().label
    end
    return JSON.encode({currentLabel = currentLabel, challengeMode = CHALLENGE_MODE, dieEvents = ON_DIE_EVENTS, newMonsterEvents = NEW_MONSTER_EVENTS})
end

-------------------------------------------------- Monster Zone API ----------------------------------------------------
local function payOutCents(playerColor, amount)
    getObjectFromGUID(Global.getTable("COIN_COUNTER_GUID")[playerColor]).call("modifyCoins", {modifier = amount})
end

local function payOutLoot(playerColor, amount)
    local lootDeck = Global.call("getLootDeck")
    if lootDeck == nil then
        Global.call("printWarning", {text = "Can't find the Loot deck."
            .. " Place the Loot deck on its starting position."})
    end
    local handInfo = Global.getTable("HAND_INFO")[playerColor]
    lootDeck.deal(amount, handInfo.owner, handInfo.index)
end

local function payOutTreasures(playerColor, amount)
    local treasureDeck = Global.call("getTreasureDeck")
    if treasureDeck == nil then
        Global.call("printWarning", {text = "Can't find the Treasure deck."
            .. " Place the Treasure deck on its starting position."})
        return
    end
    if amount > 1 then
        local cards = {}
        for n = 1, amount do
            cards[n] = treasureDeck.takeObject({flip = true})
        end
        Global.call("getActivePlayerZone").call("placeMultipleObjectsInZone", {objects = cards})
    elseif amount == 1 then
        Global.call("getActivePlayerZone").call("placeObjectInZone", {object = treasureDeck.takeObject({flip = true})})
    end
end

local function payOutSouls(playerColor, amount)
    for i = 1, amount do
        Global.call("placeSoulToken", {playerColor = playerColor})
    end
end


function payOutRewards(params)
    if (params.playerColor == nil) or (params.rewardTable == nil) then
        Global.call("printWarning", {text = "Wrong parameter in Monster-Deck Zone function 'payOutRewards()'."})
        return false
    end
    local rewardTable = params.rewardTable
    local playerColor = params.playerColor
    local rewarded = false
    if rewardTable.CENTS ~= 0 then
        payOutCents(playerColor, rewardTable.CENTS)
        rewarded = true
    end
    if rewardTable.LOOT ~= 0 then
        payOutLoot(playerColor, rewardTable.LOOT)
        rewarded = true
    end
    if rewardTable.TREASURES ~= 0 then
        payOutTreasures(playerColor, rewardTable.TREASURES)
        rewarded = true
    end
    return rewarded
end

function activateChallengeMode()
    CHALLENGE_MODE = true
end

------------------------------------------------------------------------------------------------------------------------

function containsDeckOrCard(params)
    if params.zone == nil then
        Global.call("printWarning", {text = "Wrong parameters in 'monster deck' function 'containsDeckOrCard()'."})
    else
        for _ , obj in pairs(params.zone.getObjects()) do
            if obj.tag == "Deck" or obj.tag == "Card" then
                return true
            end
        end
    end
    return false
end

function discardMonsterObject(params)
    if params.object == nil then
        Global.call("printWarning", {text = "Wrong parameters in 'monster deck' function 'discardMonsterObject()'."})
    end
    params.object.addTag(MONSTER_TAGS.DEAD)
    params.object.setPositionSmooth(DISCARD_PILE_POSITION)
    params.object.setRotationSmooth({0, 180, 0})
end

function resetAllMonsterZones()
    for _ , guid in pairs(MONSTER_ZONE_GUIDS) do
        getObjectFromGUID(guid).call("resetMonsterZone")
    end
    for _, zoneInfo in pairs(Global.getTable("ZONE_INFO_MINION")) do
        getObjectFromGUID(zoneInfo.guid).call("resetMinionZone")
    end
    if Global.getVar("ZONE_GUID_BOSS") then
        getObjectFromGUID(Global.getVar("ZONE_GUID_BOSS")).call("resetBossZone")
    end
    getObjectFromGUID(Global.getTable("ZONE_GUID_DISCARD").MONSTER).call("resetDiscardZone")
    resetMonsterZone()
end

function discardActiveMonsterCard(params)
    if params.zone == nil then
        return
    end
    local zone = params.zone
    local monsterCard = zone.call("getActiveMonsterCard")
    if monsterCard then
        Wait.frames(function ()
                discardMonsterObject({object = monsterCard})
                -- Place new monster card
                Wait.frames(function ()
                        if not zone.call("containsDeckOrCard") then
                            repeat
                                local placedZone = placeNewMonsterCard({zone = zone, isTargetOfAttack = false})
                            until ((placedZone == zone) or (placedZone == nil))
                        end
                    end, 60)
            end)
    end
end

function resetChooseButton()
    if CHOOSE_BUTTON_INDEX == nil then
        activateChooseButton()
    else
        self.editButton({index = CHOOSE_BUTTON_INDEX, label = CHOOSE_BUTTON_STATES.ATTACK
            , tooltip = getChooseButtonTooltip({newState = CHOOSE_BUTTON_STATES.ATTACK})})
    end
end

function resetMonsterZone()
    resetChooseButton()
end

function activateChooseButton()
    if CHOOSE_BUTTON_INDEX == nil then
        CHOOSE_BUTTON_INDEX = 0
        self.createButton({
            click_function = "click_function_ChooseButton",
            function_owner = self,
            label          = CHOOSE_BUTTON_STATES.ATTACK,
            position       = {0, -0.5, 3},
            width          = 1000,
            height         = 300,
            font_size      = 200,
            color          = ATTACK_BUTTON_COLORS.ACTIVE,
            font_color     = {1, 1, 1},
            tooltip        = getChooseButtonTooltip({newState = CHOOSE_BUTTON_STATES.ATTACK})
        })
    end
end

-- If you want state depending tooltips, there you go :D
function getAttackButtonTooltip(params)
    -- params.newState
    return " - Left-Click: Activate Zone\n - Double-Right-Click: Deactivate Zone"
end

function getChooseButtonTooltip(params)
    -- params.newState
    return ""
end

function deactivateChooseButton()
    if CHOOSE_BUTTON_INDEX then
        self.removeButton(CHOOSE_BUTTON_INDEX)
        CHOOSE_BUTTON_INDEX = nil
    end
end

function placeNewMonsterCard(params)
    if params.zone == nil then
        Global.call("printWarning", {text = "Wrong parameters in 'monster deck' function 'placeNewMonsterCard()'."})
    end
    if params.zone.getTable("active_monster_attrs").INDOMITABLE then
        Global.call("printWarning", {text = "Can't place a monster on an 'indomitable' monster."})
        return nil
    end
    local monsterDeck = Global.call("getMonsterDeck")
    local newMonsterCard = Global.call("getCardFromDeck", {deck = monsterDeck})
    local placingZone = params.zone
    if newMonsterCard ~= nil then
        newMonsterCard.flip()
        newMonsterCard.addTag(MONSTER_TAGS.DEAD)
        if newMonsterCard.hasTag("Indomitable") then
            local nextInactiveZone = getNextInactiveZone()
            if nextInactiveZone ~= nil then
                nextInactiveZone.call("activateZone", {drawCard = false})
                placingZone = nextInactiveZone
            end
        end
        deleteExtrasInZone(placingZone)
        newMonsterCard.setPositionSmooth(placingZone.getPosition():setAt('y', 5), false)
        Wait.frames(function ()
                if newMonsterCard.getVar("isEvent") then
                    local eventType = newMonsterCard.getVar("eventType")
                    if eventType == nil then
                        --Watch out: eventType is a FUNCTION if the card does not have the attribute 'type'
                        eventType = newMonsterCard.getVar("type")
                    end
                    printEventPhrase(newMonsterCard.getName(), eventType)
                    if eventType == EVENT_TYPES.CURSE then
                        local coloredCurseName = Global.getTable("PRINT_COLOR_SPECIAL").MONSTER_LIGHT
                            .. newMonsterCard.getName()
                            Global.call("colorPicker_attach", {afterPickFunction = "dealEventToPlayer"
                            , functionOwner = params.zone, reason = coloredCurseName})
                    else
                        return
                    end
                elseif params.isTargetOfAttack then
                    printAttackPhrase(newMonsterCard.getName())
                end
            end)
        Wait.condition(function() newMonsterCard.addTag(MONSTER_TAGS.NEW); newMonsterCard.removeTag(MONSTER_TAGS.DEAD) end
            , function() return not newMonsterCard.isSmoothMoving() end)
        return placingZone
    end
    return nil
end

function changeZoneState(params)
    local zone = params.zone
    local newState = params.newState or zone.getVar("LAST_STATE")
    if zone == nil or newState == nil then
        return
    end
    local currentState = zone.call("getState")
    if currentState ~= nil then
        zone.setVar("LAST_STATE", currentState)
    end
    if newState == ATTACK_BUTTON_STATES.INACTIVE then
        activateAllAttackButtons()
        if zone.getVar("active") then
            zone.call("deactivateZone")
        end
    elseif newState == ATTACK_BUTTON_STATES.ATTACK then
        activateAllAttackButtons()
        if not zone.getVar("active") then
            zone.call("activateZone", {})
        else
            zone.editButton({index = zone.getVar("ATTACK_BUTTON_INDEX"), label = ATTACK_BUTTON_STATES.ATTACK
                , tooltip = getAttackButtonTooltip({newState = ATTACK_BUTTON_STATES.ATTACK})})
        end
    elseif newState == ATTACK_BUTTON_STATES.CHOOSE then
        if isZoneChooseable(zone) then   --change button state
            zone.editButton({index = zone.getVar("ATTACK_BUTTON_INDEX"), label = ATTACK_BUTTON_STATES.CHOOSE
                , tooltip = getAttackButtonTooltip({newState = ATTACK_BUTTON_STATES.CHOOSE})})
        else    --deactivate buttons for inactive zones
            zone.call("deactivateAttackButton")
        end
    elseif newState == ATTACK_BUTTON_STATES.ATTACKING then
        if zone.getVar("active") then
            zone.call("activateAttackButton")
            zone.editButton({index = zone.getVar("ATTACK_BUTTON_INDEX"), label = ATTACK_BUTTON_STATES.ATTACKING
                , tooltip = getAttackButtonTooltip({newState = ATTACK_BUTTON_STATES.ATTACKING})})
            deactivateAllAttackButtons(zone, true)
        end
    elseif newState == ATTACK_BUTTON_STATES.DIED then
        if zone.getVar("active") then
            zone.call("activateAttackButton")
            if (currentState ~= ATTACK_BUTTON_STATES.SELECT) or params.force then
                zone.editButton({index = zone.getVar("ATTACK_BUTTON_INDEX"), label = ATTACK_BUTTON_STATES.DIED
                    , tooltip = getAttackButtonTooltip({newState = ATTACK_BUTTON_STATES.DIED})})
            else
                zone.setVar("LAST_STATE", ATTACK_BUTTON_STATES.DIED)
            end
            deactivateAllAttackButtons(zone, true)
        end
    elseif newState == ATTACK_BUTTON_STATES.EVENT then
        if zone.getVar("active") then
            zone.call("activateAttackButton")
            zone.editButton({index = zone.getVar("ATTACK_BUTTON_INDEX"), label = ATTACK_BUTTON_STATES.EVENT
                , tooltip = getAttackButtonTooltip({newState = ATTACK_BUTTON_STATES.EVENT})})
            deactivateAllAttackButtons(zone, true, {ATTACK_BUTTON_STATES.EVENT})
        end
    elseif newState == ATTACK_BUTTON_STATES.SELECT then
        if zone.getVar("active") then
            if zone.call("getAttackButton") ~= nil then
                if params.stateParams then
                    STATE_PARAMS = params.stateParams
                    zone.editButton({index = zone.getVar("ATTACK_BUTTON_INDEX"), label = ATTACK_BUTTON_STATES.SELECT
                        , tooltip = getAttackButtonTooltip({newState = ATTACK_BUTTON_STATES.SELECT})})
                end
            end
        else
            zone.call("deactivateAttackButton")
        end
    end
end

function changeChooseZoneState(params)
    local newState = params.newState or LAST_STATE
    if newState == nil then
        return
    end
    local currentState = getState()
    if currentState ~= nil then
        LAST_STATE = currentState
    end
    if newState == CHOOSE_BUTTON_STATES.ATTACK then
        self.editButton({index = CHOOSE_BUTTON_INDEX, label = CHOOSE_BUTTON_STATES.ATTACK
            , tooltip = getChooseButtonTooltip({newState = CHOOSE_BUTTON_STATES.ATTACK})})
    elseif newState == CHOOSE_BUTTON_STATES.CHOOSE then
        self.editButton({index = CHOOSE_BUTTON_INDEX, label = CHOOSE_BUTTON_STATES.CHOOSE
            , tooltip = getChooseButtonTooltip({newState = CHOOSE_BUTTON_STATES.CHOOSE})})
        for _ , guid in pairs(Global.getTable("ZONE_GUID_MONSTER")) do
            changeZoneState({zone = getObjectFromGUID(guid), newState = ATTACK_BUTTON_STATES.CHOOSE})
        end
        if CHALLENGE_MODE then
            getObjectFromGUID(BOSS_ZONE_GUID).call("deactivateAllChallengeButtons")
        end
    elseif newState == CHOOSE_BUTTON_STATES.SELECT then
        if CHOOSE_BUTTON_INDEX then
            if params.stateParams then
                STATE_PARAMS = params.stateParams
            end
            self.editButton({index = CHOOSE_BUTTON_INDEX, label = CHOOSE_BUTTON_STATES.SELECT
                , tooltip = getChooseButtonTooltip({newState = CHOOSE_BUTTON_STATES.SELECT})})
        end
    end
end

--Thank you Bone White in discord for this <3       --Edited by Ediforce44
function findAttrsInScript(scriptString)
    local attrs = {}
    local hpPattern = "([Hh][Pp]%s?=%s?%d+)"
    local atkPattern = "[Dd][Ii][Cc][Ee]%s?=%s?%d+"
    local dmgPattern = "[Aa][Tt][Kk]%s?=%s?%d+"
    local attrPatterns = {HP = hpPattern, ATK = atkPattern, DMG = dmgPattern}
    for line in string.gmatch(scriptString,"[^\r\n]+") do -- for each line in the script
        for attrName , pattern in pairs(attrPatterns) do
            local attrString = string.match(line, pattern)
            if attrString ~= nil then
                attrs[tostring(attrName)] = tonumber(string.match(attrString, "%d+"))
            end
        end
    end
    return attrs
end

--Thank you Bone White in discord for this <3       --Edited by Ediforce44
function findRewardsInScript(scriptString)
    local rewards = {}
    local varName = "rewards"
    for line in string.gmatch(scriptString,"[^\r\n]+") do -- for each line in the script
        if string.sub(line,1,#varName) == varName then -- if the beginning of the line matches var
            local tableString = string.match(line,"{.*}",#varName)
            if tableString ~= nil then
                local entryCents = string.match(tableString, "CENTS = %d+")
                local entryLoot = string.match(tableString, "LOOT = %d+")
                local entryTreasure = string.match(tableString, "TREASURES = %d+")
                local entrySouls = string.match(tableString, "SOULS = %d+")
                rewards.CENTS = tonumber(string.match(entryCents, "%d+"))
                rewards.LOOT = tonumber(string.match(entryLoot, "%d+"))
                rewards.TREASURES = tonumber(string.match(entryTreasure, "%d+"))
                rewards.SOULS = tonumber(string.match(entrySouls, "%d+"))
                return rewards
            end
        end
    end
    return rewards
end

function onObjectEnterScriptingZone(zone, object)
    for i, guid in pairs(MONSTER_ZONE_GUIDS) do
        if guid == zone.getGUID() and zone.getVar("active") then
            if (not object.hasTag(MONSTER_TAGS.DEAD)) and isObjectReallyEntering(object, zone) then
                if object.tag == "Deck" then
                    local containedObjects = object.getData().ContainedObjects
                    local firstCard = containedObjects[#containedObjects]
                    -- Test if topmost card is the active monster of this zone
                    if (zone.getTable("active_monster_attrs").GUID == firstCard["GUID"]) then
                        local script = firstCard["LuaScript"]
                        -- Attributes
                        local newAttributes = findAttrsInScript(script)
                        if firstCard["Tags"] then
                            newAttributes.INDOMITABLE = (firstCard["Tags"][MONSTER_TAGS.INDOMITABLE] == true)
                        end
                        if newAttributes.HP == nil then
                            newAttributes.HP = object.getVar("hp") or 0
                        end
                        newAttributes.GUID = firstCard["GUID"]
                        newAttributes.NAME = firstCard["Nickname"]
                        -- Rewards
                        rewards = findRewardsInScript(script)

                        zone.call("updateAttributes", newAttributes)
                        zone.call("updateRewards", rewards)
                    else
                        -- Take top most monster into the zone
                        local card = object.takeObject({position = zone.getPosition():setAt('y', 2)})
                        card.addTag(MONSTER_TAGS.NEW)
                    end
                elseif object.tag == "Card" then
                    Wait.frames(function()
                        if not object.hasTag(MONSTER_TAGS.DEAD) then
                            local isMonsterNew = false
                            -- Tests if this card is the active monster of this zone
                            if zone.getTable("active_monster_attrs").GUID ~= object.getGUID() then
                                -- If monster card is new call onReveal() and update attributes and rewards
                                if object.hasTag(MONSTER_TAGS.NEW) then
                                    isMonsterNew = true
                                else
                                    -- Ignore this card if there is a object in the zone, which is NEW
                                    for _ , obj in pairs(zone.getObjects()) do
                                        if obj.hasTag(MONSTER_TAGS.NEW) then
                                            return
                                        end
                                    end
                                end
                            end
                            -- Attributes
                            local newAttributes = {}
                            newAttributes.GUID = object.getGUID()
                            newAttributes.NAME = object.getName()
                            newAttributes.HP = object.getVar("hp") or 0
                            newAttributes.ATK = object.getVar("dice")
                            newAttributes.DMG = object.getVar("atk")
                            newAttributes.INDOMITABLE = object.hasTag(MONSTER_TAGS.INDOMITABLE)
                            -- Rewards
                            local rewards = object.getTable("rewards") or {}

                            zone.call("updateAttributes", newAttributes)
                            zone.call("updateRewards", rewards)

                            callNewMonsterEvents({guid = object.getGUID(), zone = zone, isMinion = false})

                            if isMonsterNew then
                                onNewMonsterReveal(object, zone)
                                -- The wait is need for other cards to check if there is an NEW card in the zone
                                Wait.frames(function () object.removeTag(MONSTER_TAGS.NEW) end)
                            end
                        end
                    end)
                else
                    return
                end
            end
        end
    end
end

function onObjectLeaveScriptingZone(zone, object)
    for i, guid in pairs(MONSTER_ZONE_GUIDS) do
        if guid == zone.getGUID() and zone.getVar("active") and isObjectReallyLeaving(object, zone) then
            if objectContainsGUID(object, zone.getTable("active_monster_attrs").GUID) then
                local newAttributes = {}
                local exceptionTable = {}
                exceptionTable[object.getGUID()] = true
                local topObjectInZone = getTopMostDeckOrCard(zone, exceptionTable)

                if topObjectInZone == nil then
                    newAttributes = {NAME = "", HP = 0}

                    zone.call("updateAttributes", newAttributes)
                elseif topObjectInZone.tag == "Deck" then
                    -- Take the topmost monster into the zone
                    local card = topObjectInZone.takeObject({position = zone.getPosition():setAt('y', 2)})
                    card.addTag(MONSTER_TAGS.NEW)
                elseif topObjectInZone.tag == "Card" then
                    -- Attributes
                    newAttributes.GUID = topObjectInZone.getGUID()
                    newAttributes.NAME = topObjectInZone.getName()
                    newAttributes.HP = topObjectInZone.getVar("hp") or 0
                    newAttributes.ATK = topObjectInZone.getVar("dice")
                    newAttributes.DMG = topObjectInZone.getVar("atk")
                    newAttributes.INDOMITABLE = object.hasTag(MONSTER_TAGS.INDOMITABLE)
                    -- Rewards
                    local rewards = topObjectInZone.getTable("rewards") or {}

                    zone.call("updateAttributes", newAttributes)
                    zone.call("updateRewards", rewards)

                    callNewMonsterEvents({guid = topObjectInZone.getGUID(), zone = zone, isMinion = false})
                else
                    return
                end
                local zoneState = zone.call("getState")
                if zoneState ~= nil then
                    local activePlayerColor = Global.getVar("activePlayerColor")
                    if zoneState == ATTACK_BUTTON_STATES.CHOOSE then
                        click_function_ChooseButton(_, activePlayerColor, false)
                    elseif zoneState == ATTACK_BUTTON_STATES.ATTACKING
                        or zoneState == ATTACK_BUTTON_STATES.DIED then
                            changeZoneState({zone = zone, newState = ATTACK_BUTTON_STATES.ATTACK})
                    elseif zoneState == ATTACK_BUTTON_STATES.EVENT then
                        if hasMoreActiveEvents(zone) then
                            zone.call("deactivateAttackButton")
                        else
                            changeZoneState({zone = zone, newState = ATTACK_BUTTON_STATES.ATTACK})
                        end
                    end
                end
            end
        end
    end
end

function click_function_ChooseButton(_, color, alt_click)
    if Global.getVar("activePlayerColor") == color or Player[color].admin then
        local chooseButton = getChooseButton()
        if chooseButton.label == CHOOSE_BUTTON_STATES.ATTACK then
            changeChooseZoneState({newState = CHOOSE_BUTTON_STATES.CHOOSE})
        elseif chooseButton.label == CHOOSE_BUTTON_STATES.CHOOSE then
            changeChooseZoneState({newState = CHOOSE_BUTTON_STATES.ATTACK})
            activateAllAttackButtons()
            for _ , guid in pairs(Global.getTable("ZONE_GUID_MONSTER")) do
                local zone = getObjectFromGUID(guid)
                if zone.getVar("active") then
                    zone.editButton({index = zone.getVar("ATTACK_BUTTON_INDEX"), label = ATTACK_BUTTON_STATES.ATTACK
                                , tooltip = getAttackButtonTooltip({newState = ATTACK_BUTTON_STATES.ATTACK})})
                end
            end
        elseif chooseButton.label == CHOOSE_BUTTON_STATES.SELECT then
            local selectedCard = nil
            local monsterDeck = Global.call("getMonsterDeck")
            if STATE_PARAMS.onlyMonster then
                for _, card in pairs(monsterDeck.getObjects()) do
                    if not Global.call("findBoolInScript", {scriptString = card.lua_script, varName = "isEvent"}) then
                        selectedCard = monsterDeck.takeObject({guid = card.guid})
                        break
                    end
                end
            else
                selectedCard = Global.call("getCardFromDeck", {deck = monsterDeck})
            end
            if selectedCard == nil then
                Global.call("printWarning", {text = "Can't find a real monster card in the Monster Deck: " .. zone.getGUID() .. "."})
            else
                STATE_PARAMS.function_owner.call(STATE_PARAMS.call_function, {card = selectedCard})
            end
        else
            Global.call("printWarning", {text = "Unknown monster button state: " .. tostring(attackButton.label) .. "."})
        end
    end
end

function click_function_AttackButton(zone, color, alt_click)
    if Global.getVar("activePlayerColor") == color or Player[color].admin then
        if alt_click then
            altClickAttackButton(zone, color)
            return
        end
        local attackButtonState = zone.call("getState")
        if attackButtonState == ATTACK_BUTTON_STATES.INACTIVE then
            zone.call("activateZone", {})
        elseif attackButtonState == ATTACK_BUTTON_STATES.ATTACK then
            if printAttackPhrase(zone.getTable("active_monster_attrs").NAME) then
                changeZoneState({zone = zone, newState = ATTACK_BUTTON_STATES.ATTACKING})
            end
        elseif attackButtonState == ATTACK_BUTTON_STATES.CHOOSE then
            local placedZone = placeNewMonsterCard({zone = zone, isTargetOfAttack = true})
            if placedZone ~= nil then
                changeZoneState({zone = placedZone, newState = ATTACK_BUTTON_STATES.ATTACKING})
            end
            if CHALLENGE_MODE then
                getObjectFromGUID(BOSS_ZONE_GUID).call("activateResurrectButton")
            end
        elseif attackButtonState == ATTACK_BUTTON_STATES.ATTACKING then
            local monsterName = zone.getTable("active_monster_attrs").NAME
            if monsterName == "" then
                Global.call("printWarning", {text = "There is no active monster to attack. The attribute 'NAME' is empty."})
            else
                broadcastToAll(Global.call("getActivePlayerString") .. " cancels the Attack on "
                                .. Global.getTable("PRINT_COLOR_SPECIAL").MONSTER_LIGHT .. monsterName .. "[-] !!!")
            end
            changeZoneState({zone = zone, newState = ATTACK_BUTTON_STATES.ATTACK})
        elseif attackButtonState == ATTACK_BUTTON_STATES.DIED then
            zone.call("finishMonster")
            changeZoneState({zone = zone, newState = ATTACK_BUTTON_STATES.ATTACK})
        elseif attackButtonState == ATTACK_BUTTON_STATES.EVENT then
            discardActiveMonsterCard({zone = zone})
        elseif attackButtonState == ATTACK_BUTTON_STATES.SELECT then
            local lastState = zone.getVar("LAST_STATE")
            local selectedCard = nil
            if lastState == ATTACK_BUTTON_STATES.DIED then
                selectedCard = zone.call("finishMonster", {selected = true})
            end
            if selectedCard ~= nil then
                STATE_PARAMS.function_owner.call(STATE_PARAMS.call_function, {card = selectedCard})
                resetAllAttackButtons()
            else
                if STATE_PARAMS.onlyMonster then
                    selectedCard = getFirstMonsterInZone(zone)
                else
                    selectedCard = zone.call("getActiveMonsterCard")
                end
                if selectedCard == nil then
                    Global.call("printWarning", {text = "Can't find a real monster card in this monster zone: " .. zone.getGUID() .. "."})
                else
                    STATE_PARAMS.function_owner.call(STATE_PARAMS.call_function, {card = selectedCard})
                    zone.call("placeNewMonsterIfEmpty")
                end
            end
        else
            Global.call("printWarning", {text = "Unknown monster button state: " .. tostring(attackButtonState) .. "."})
        end
    end
end