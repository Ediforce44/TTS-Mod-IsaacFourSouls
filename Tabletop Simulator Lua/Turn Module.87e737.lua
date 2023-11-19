ON_TURN_EVENTS = {
    END = {
        {call_function = "turnEvent_playerHealing", function_params = {}, function_owner=self.guid, valid = true},
        {call_function = "turnEvent_activation", function_params = {}, function_owner=self.guid, valid = true},
    },
    START = {
        {call_function = "turnEvent_resetZones", function_params = {}, function_owner=self.guid, valid = true},
        {call_function = "turnEvent_loot", function_params = {}, function_owner=self.guid, valid = true},
    }
}

TURN_SETTINGS = {
    Red = {camera = true, looting = false, playerHealing = true, itemActivation = true},
    Blue = {camera = true, looting = false, playerHealing = true, itemActivation = true},
    Green = {camera = true, looting = false, playerHealing = true, itemActivation = true},
    Yellow = {camera = true, looting = false, playerHealing = true, itemActivation = true}
}

TURN_ORDER = {
    Red = "Blue",
    Blue = "Green",
    Green = "Yellow",
    Yellow = "Red"
}

PLAYER_ZONE_OVERLAY_GUID = {
    Red = "956a87",
    Blue = "690e90",
    Green = "2d3a54",
    Yellow = "0342ed"
}

TURN_SYSTEM_STARTED = false

START_PLAYER_COLOR = "None"

HAND_INFO = {
    Red = {index = 1, owner = "Red", guid = "b000d8", hotseat = false},
    Blue = {index = 1, owner = "Blue", guid = "29f1f6", hotseat = false},
    Green = {index = 1, owner = "Green", guid = "489f26", hotseat = false},
    Yellow = {index = 1, owner = "Yellow", guid = "e2e2d1", hotseat = false}
}

SPY_INFO = {
    Red = {index = 2, owner = "Red", guid = "744c42"},
    Blue = {index = 2, owner = "Blue", guid = "32da79"},
    Green = {index = 2, owner = "Green", guid = "69a792"},
    Yellow = {index = 2, owner = "Yellow", guid = "ad4169"}
}

function onLoad(saved_data)
    for _, player in pairs(Player.getPlayers()) do
        if player.host then
            player.changeColor("Black")
        else
            player.changeColor("Grey")
        end
    end

    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        if loaded_data.onTurnEvents then
            ON_TURN_EVENTS = loaded_data.onTurnEvents
        end
        if loaded_data.turnSettings then
            TURN_SETTINGS = loaded_data.turnSettings
        end
        if loaded_data.turnSystemStarted then
            TURN_SYSTEM_STARTED = loaded_data.turnSystemStarted
        end
        if loaded_data.startPlayerColor then
            START_PLAYER_COLOR = loaded_data.startPlayerColor
        end
        if loaded_data.activePlayerColor then
            Global.setVar("activePlayerColor", loaded_data.activePlayerColor)
        else
            Global.setVar("activePlayerColor", "Red")
        end
    end
end

function onSave()
    return JSON.encode({onTurnEvents = ON_TURN_EVENTS, turnSettings = TURN_SETTINGS, turnSystemStarted = TURN_SYSTEM_STARTED
        , startPlayerColor = START_PLAYER_COLOR, activePlayerColor = Global.getVar("activePlayerColor")})
end

local function callTurnEndEvents(previousPlayerColor, newPlayerColor)
    local eventFunctionParams = {playerColorEnd = previousPlayerColor, playerColorStart = newPlayerColor}
    if previousPlayerColor then
        for _, eventTable in ipairs(ON_TURN_EVENTS.END) do
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
end

local function callTurnStartEvents(previousPlayerColor, newPlayerColor)
    local eventFunctionParams = {playerColorEnd = previousPlayerColor, playerColorStart = newPlayerColor}
    for _, eventTable in ipairs(ON_TURN_EVENTS.START) do
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

local function getCameraParamsForTurnPassing(nextPlayerColor)
    local handZone = getObjectFromGUID(HAND_INFO[nextPlayerColor].guid)
    local cameraParams = nil
    if handZone then
        cameraParams = {}
        local cameraPosition = handZone.getPosition()
        local translation = Vector(0, 0, 10):rotateOver('y', handZone.getRotation().y)
        cameraParams.position = cameraPosition + translation
        cameraParams.yaw = handZone.getRotation().y
        cameraParams.pitch = 65
        cameraParams.distance = 35
    end
    return cameraParams
end

local function transferTurn(previousPlayerColor, nextPlayerColor)
    --Play turn passing sound
    local sfxCube = getObjectFromGUID(Global.getVar("SFX_CUBE_GUID"))
    if sfxCube then
        sfxCube.call("playSwoosh")
    end

    local playerZoneOverlay_active = getObjectFromGUID(PLAYER_ZONE_OVERLAY_GUID[previousPlayerColor])
    if playerZoneOverlay_active then
        local playerOverlayPosition = playerZoneOverlay_active.getPosition():setAt('y', 0)
        playerZoneOverlay_active.setPosition(playerOverlayPosition)
    end

    local playerZoneOverlay_next = getObjectFromGUID(PLAYER_ZONE_OVERLAY_GUID[nextPlayerColor])
    if playerZoneOverlay_next then
        local playerOverlayPosition = playerZoneOverlay_next.getPosition():setAt('y', 1.49)
        playerZoneOverlay_next.setPosition(playerOverlayPosition)
    end

    callTurnEndEvents(previousPlayerColor, nextPlayerColor)

    Global.setVar("activePlayerColor", nextPlayerColor)

    print(Global.call("getPlayerString", {playerColor = previousPlayerColor}) .. "'s turn is over. It's now "
        .. Global.call("getPlayerString", {playerColor = nextPlayerColor}) .. "'s turn.")
    callTurnStartEvents(previousPlayerColor, nextPlayerColor)

    if TURN_SETTINGS[nextPlayerColor].camera then
        local cameraParams = getCameraParamsForTurnPassing(nextPlayerColor)
        if cameraParams then
            Player[HAND_INFO[nextPlayerColor].owner].lookAt(cameraParams)
        end
    end

    UI.setAttribute("passButton", "image", "turn_" .. string.lower(nextPlayerColor))
    UI.setAttribute("passButton", "textColor", Global.getTable("PLAYER_COLOR_HEX")[nextPlayerColor])
    UI.setAttribute("turnInfo", "visibility", HAND_INFO[nextPlayerColor].owner .. "|Black")
end

local function flipHand(playerColor, faceUp)
    local handInfo = HAND_INFO[playerColor]
    local handZone = getObjectFromGUID(handInfo.guid)
    if handZone then
        for _, obj in pairs(Player[handInfo.owner].getHandObjects(handInfo.index)) do
            if obj.is_face_down == faceUp then
                obj.flip()
            end
        end
    end
    local spyInfo = SPY_INFO[playerColor]
    local spyZone = getObjectFromGUID(spyInfo.guid)
    if spyZone then
        for _, obj in pairs(Player[spyInfo.owner].getHandObjects(spyInfo.index)) do
            if obj.is_face_down == faceUp then
                obj.flip()
            end
        end
    end
end

local function passTurn(nextPlayerColor)
    local previousPlayerColor = Global.getVar("activePlayerColor")

    local preHandInfo = HAND_INFO[previousPlayerColor]
    if preHandInfo.hotseat then

        local nextHotSeatColor = nextPlayerColor
        while (nextHotSeatColor ~= previousPlayerColor) do
            if HAND_INFO[nextHotSeatColor].owner == preHandInfo.owner then
                break
            end
            nextHotSeatColor = getNextPlayerColor({currentPlayerColor = nextHotSeatColor})
        end

        if nextHotSeatColor ~= previousPlayerColor then
            flipHand(previousPlayerColor, false)

            if HAND_INFO[nextPlayerColor].owner == preHandInfo.owner then
                UI.setAttribute("turnInfo", "visibility", "Black")
                for i = 3, 1, -1 do
                    Wait.time(function()
                        broadcastToColor(i, preHandInfo.owner, {r=1, g=0, b=0})
                        --Play count down sound
                        local sfxCube = getObjectFromGUID(Global.getVar("SFX_CUBE_GUID"))
                        sfxCube.call("playButton")
                    end, 3-i)
                end
                Wait.time(function() flipHand(nextHotSeatColor, true); transferTurn(previousPlayerColor, nextPlayerColor) end, 3)
                return
            end
        end
    end

    if HAND_INFO[nextPlayerColor].hotseat then
        flipHand(nextPlayerColor, true)
    end
    transferTurn(previousPlayerColor, nextPlayerColor)
end

local function showSkipTurn(activePlayerColor)
    local nextPlayerConditionID = Wait.condition(
        function()
            UI.setAttribute("skipButton", "text", "Skip Turn of " .. activePlayerColor)
            UI.setAttribute("skipButton", "textColor", "#EAE5DE")
            UI.show("skipTurn")
            UI.setAttribute("skipTurn", "visibility", "Host|Black")
        end, function()
            return HAND_INFO[activePlayerColor].owner ~= HAND_INFO[getNextPlayerColor({currentPlayerColor = activePlayerColor})].owner
        end)
    Wait.condition(
        function()
            UI.hide("skipTurn")
            Wait.stop(nextPlayerConditionID)
        end, function()
            return Player[HAND_INFO[activePlayerColor].owner].seated
        end, 60)
end

function UI_passTurn(clickerPlayer)
    if clickerPlayer == nil then
        return
    end

    if (HAND_INFO[Global.getVar("activePlayerColor")].owner == clickerPlayer.color) then
        passTurn(getNextPlayerColor())
    end
end

function UI_skipTurn()
    UI.hide("skipTurn")
    passTurn(getNextPlayerColor())
end

------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------- Events -----------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--TODO test this

--Player Events
function onPlayerChangeColor(playerColor)
    local activePlayerColor = Global.getVar("activePlayerColor")
    if TURN_SYSTEM_STARTED and Global.getTable("PLAYER")[activePlayerColor] then
        local activeZone = getObjectFromGUID(Global.getTable("ZONE_GUID_PLAYER")[activePlayerColor])
        if not Player[HAND_INFO[activePlayerColor].owner].seated or not activeZone or not activeZone.getVar("active") then
            showSkipTurn(activePlayerColor)
        end
    end
end

function onPlayerConnect(player)
    player.changeColor("Grey")
end

-- Hand Zone Events
function onObjectEnterZone(zone, object)
    local activePlayerColor = Global.getVar("activePlayerColor")
    if (zone.type == "Hand") and HAND_INFO[activePlayerColor] then
        if (zone.guid ~= HAND_INFO[activePlayerColor].guid) and (zone.guid ~= SPY_INFO[activePlayerColor].guid) then
            local handInfo = getHandInfoFromHandZone({handZone = zone})
            if handInfo and handInfo.hotseat then
                if not object.is_face_down then
                    object.flip()
                    return
                end
            end
        end
    end
end

------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------- Turn System ---------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function startTurnSystem(params)
    if not params or not params.startPlayerColor then
        return
    end

    if not Player[HAND_INFO[params.startPlayerColor].owner].seated then
        local nextActivePlayerColor = getNextPlayerColor({currentPlayerColor = params.startPlayerColor})
        if nextActivePlayerColor == params.startPlayerColor then
            Global.call("printWarning", {text = Global.getTable("PRINT_COLOR_SPECIAL").RED .. "Fatal Error: No Player selected a playable color. Please reload!!!" .. "[-]"})
            return
        else
            Global.call("printWarning", {text = "Start player missing?! Wtf are you guys doing?"})
            showSkipTurn(params.startPlayerColor)
        end
    end

    START_PLAYER_COLOR = params.startPlayerColor
    TURN_SYSTEM_STARTED = true
    Turns.enable = false
    Global.setVar("activePlayerColor", START_PLAYER_COLOR)

    callTurnStartEvents(nil, START_PLAYER_COLOR)

    --Play turn passing / game start sound
    local sfxCube = getObjectFromGUID(Global.getVar("SFX_CUBE_GUID"))
    if sfxCube then
        sfxCube.call("playSwoosh")
    end

    for playerZoneOverlayGuid in pairs(PLAYER_ZONE_OVERLAY_GUID) do
        local playerZoneOverlay = getObjectFromGUID(playerZoneOverlayGuid)
        if playerZoneOverlay then
            local playerOverlayPosition = playerZoneOverlay.getPosition():setAt('y', 0)
            playerZoneOverlay.setPosition(playerOverlayPosition)
        end
    end

    local playerZoneOverlay_start = getObjectFromGUID(PLAYER_ZONE_OVERLAY_GUID[START_PLAYER_COLOR])
    if playerZoneOverlay_start then
        local playerOverlayPosition = playerZoneOverlay_start.getPosition():setAt('y', 1.49)
        playerZoneOverlay_start.setPosition(playerOverlayPosition)
    end

    local cameraParams = getCameraParamsForTurnPassing(START_PLAYER_COLOR)
    if cameraParams then
        Player[HAND_INFO[START_PLAYER_COLOR].owner].lookAt(cameraParams)
    end

    UI.setAttribute("passButton", "image", "turn_" .. string.lower(START_PLAYER_COLOR))
    UI.setAttribute("passButton", "textColor", Global.getTable("PLAYER_COLOR_HEX")[START_PLAYER_COLOR])
    UI.show("turnInfo")
    UI.setAttribute("turnInfo", "visibility", HAND_INFO[START_PLAYER_COLOR].owner .. "|Black")
end

function changeTurnSettings(params)
    if params.color and params.setting then
        TURN_SETTINGS[params.color][params.setting] = params.newValue
    end
end

function addTurnEvent(params)
    if (params == nil) or (params.call_function == nil) then
        return
    end
    local functionParams = params.function_params or {}
    local turnID = nil
    if params.atEnd == true then
        table.insert(ON_TURN_EVENTS.END, {call_function = params.call_function, function_params = functionParams
            , function_owner = params.function_owner, valid = true})
        eventID = tostring(#ON_TURN_EVENTS.END) .. "0"
    else
        table.insert(ON_TURN_EVENTS.START, {call_function = params.call_function, function_params = functionParams
            , function_owner = params.function_owner, valid = true})
        eventID = tostring(#ON_TURN_EVENTS.START) .. "1"
    end
    return tonumber(eventID)
end

function deactivateTurnEvent(params)
    if params.eventID then
        local turnID = tonumber(params.eventID) % 10
        local functionID = math.floor(tonumber(params.eventID) / 10)
        if turnID == 0 then
            ON_TURN_EVENTS.END[functionID].valid = false
        elseif turnID == 1 then
            ON_TURN_EVENTS.START[functionID].valid = false
        end
    end
end

function activateTurnEvent(params)
    if params.eventID then
        local turnID = tonumber(params.eventID) % 10
        local functionID = math.floor(tonumber(params.eventID) / 10)
        if turnID == 0 then
            ON_TURN_EVENTS.END[functionID].valid = true
        elseif turnID == 1 then
            ON_TURN_EVENTS.START[functionID].valid = true
        end
    end
end

--If no player has selected a playable color, it returns the active player color
function getNextPlayerColor(params)
    local currentPlayerColor = Global.getVar("activePlayerColor")
    if params and params.currentPlayerColor then
        currentPlayerColor = params.currentPlayerColor
    end

    local nextColor = currentPlayerColor
    local nextPlayerFound = false

    while(not nextPlayerFound) do
        nextColor = TURN_ORDER[nextColor]
        local nextZone = getObjectFromGUID(Global.getTable("ZONE_GUID_PLAYER")[nextColor])
        if nextZone and nextZone.getVar("active") then
            local nextHandOwner = Player[HAND_INFO[nextColor].owner]
            if nextHandOwner and nextHandOwner.seated then
                nextPlayerFound = true
            end
        end
        if nextColor == currentPlayerColor then
            nextPlayerFound = true
        end
    end
    return nextColor
end

function getPlayerCount()
    local counter = 0
    for _, handInfo in pairs(HAND_INFO) do
        for _, player in pairs(Player.getPlayers()) do
            if handInfo.owner == player.color then
                counter = counter + 1
            end
        end
    end
    return counter
end

------------------------------------------------------------------------------------------------------------------------
---------------------------------------------- Hand Zone Management ----------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function getHandInfoFromHandZone(params)
    if params and params.handZone then
        local handZone = params.handZone

        for handOwner, handInfo in pairs(HAND_INFO) do
            if handZone.guid == handInfo.guid then
                return handInfo
            end
        end
        for handOwner, spyInfo in pairs(SPY_INFO) do
            if handZone.guid == spyInfo.guid then
                return HAND_INFO[handOwner]
            end
        end
    end
    return nil
end

function joinHandZones(params)
    if (not params) or (not params.combinedHandZones) then
        return
    end
    
    local combinedHandZones = params.combinedHandZones
    local hotSeat = {}
    if params.hotSeat then
        hotSeat = params.hotSeat
    end
    
    for ownerColor, colorTable  in pairs(combinedHandZones) do
        if #colorTable > 1 then
            for _, color in ipairs(colorTable) do
                HAND_INFO[color].hotseat = (hotSeat[ownerColor] and true)
            end
        end

        local nextHandIndex = HAND_INFO[ownerColor].index
        for _, color in ipairs(colorTable) do
            local handZone = getObjectFromGUID(HAND_INFO[color].guid)
            if handZone then
                handZone.setValue(ownerColor)
                HAND_INFO[color].index = nextHandIndex
                HAND_INFO[color].owner = ownerColor
                nextHandIndex = nextHandIndex + 1
            end
        end
        for _, color in ipairs(colorTable) do
            local spyZone = getObjectFromGUID(SPY_INFO[color].guid)
            spyZone.setValue(ownerColor)
            SPY_INFO[color].index = nextHandIndex
            SPY_INFO[color].owner = ownerColor
            nextHandIndex = nextHandIndex + 1
        end
        for _, color in ipairs(colorTable) do
            if color ~= ownerColor then
                Player[color].changeColor("Grey")
            end
        end
    end
end

------------------------------------------------------------------------------------------------------------------------
----------------------------------------------- Basic Turn Events ------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function turnEvent_activation(params)
    local playerZoneGuids = Global.getTable("ZONE_GUID_PLAYER")
    if TURN_SETTINGS[params.playerColorStart].itemActivation then
        local playerZone = getObjectFromGUID(playerZoneGuids[params.playerColorStart])
        if playerZone then
            playerZone.call("activateCharacter")
            playerZone.call("activateActiveItems")
        end
    end
end

function turnEvent_playerHealing()
    local playerZoneGuids = Global.getTable("ZONE_GUID_PLAYER")
    for color, settings in pairs(TURN_SETTINGS) do
        if settings.playerHealing then
            local playerZone = getObjectFromGUID(playerZoneGuids[color])
            if playerZone then
                playerZone.call("healPlayer")
            end
        end
    end
end

function turnEvent_resetZones(_)
    local deckZoneGuids = Global.getTable("ZONE_GUID_DECK")
    -- Reset Monster Zones (inclusive HP-Counter)
    getObjectFromGUID(deckZoneGuids.MONSTER).call("resetAllMonsterZones")
    -- Reset Shop Zones
    getObjectFromGUID(deckZoneGuids.TREASURE).call("resetAllShopZones")        -- In this version it does nothing :D
end

function turnEvent_loot(params)
    if TURN_SETTINGS[params.playerColorStart].looting then
        Global.call("dealLootToColor", {color = params.playerColorStart})
    end
end