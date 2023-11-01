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

function onLoad(saved_data)
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
    end
end

function onSave()
    return JSON.encode({onTurnEvents = ON_TURN_EVENTS, turnSettings = TURN_SETTINGS, turnSystemStarted = TURN_SYSTEM_STARTED})
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
    local handZone = getObjectFromGUID(Global.getTable("HAND_INFO")[nextPlayerColor].guid)
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
            Player[Global.getVar("PLAYER_OWNER")[nextPlayerColor]].lookAt(cameraParams)
        end
    end

    UI.setAttribute("passButton", "image", "turn_" .. string.lower(nextPlayerColor))
    UI.setAttribute("passButton", "textColor", Global.getTable("PLAYER_COLOR_HEX")[nextPlayerColor])
    UI.setAttribute("turnInfo", "visibility", Global.getTable("HAND_INFO")[nextPlayerColor].owner .. "|Black")
end

local function flipHand(playerColor, faceUp)
    local handInfo = Global.getTable("HAND_INFO")[playerColor]
    local handZone = getObjectFromGUID(handInfo.guid)
    if handZone then
        for _, obj in pairs(Player[handInfo.owner].getHandObjects(handInfo.index)) do
            if obj.is_face_down == faceUp then
                obj.flip()
            end
        end
    end
    local spyInfo = Global.getTable("SPY_INFO")[playerColor]
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

    local HAND_INFO = Global.getTable("HAND_INFO")

    local preHandInfo = HAND_INFO[previousPlayerColor]
    if preHandInfo.hotseat then

        local nextHotSeatColor = nextPlayerColor
        while (nextHotSeatColor ~= previousPlayerColor) do
            if HAND_INFO[nextHotSeatColor].owner == preHandInfo.owner then
                break
            end
            nextHotSeatColor = getNextPlayerColor(nextHotSeatColor)
        end

        if nextHotSeatColor ~= previousPlayerColor then
            flipHand(previousPlayerColor, false)

            if HAND_INFO[nextPlayerColor].owner == preHandInfo.owner then
                UI.setAttribute("turnInfo", "visibility", "Black")
                for i = 3, 1, -1 do
                    Wait.time(function()
                        broadcastToColor(i, preHandInfo.owner, {r=1, g=0, b=0})
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

function getNextPlayerColor(currentPlayerColor)
    if not TURN_SYSTEM_STARTED then
        return Global.getVar("startPlayerColor")
    end

    currentPlayerColor = currentPlayerColor or Global.getVar("activePlayerColor")
    local nextColor = currentPlayerColor
    local nextPlayerFound = false

    while(not nextPlayerFound) do
        nextColor = TURN_ORDER[nextColor]
        activeZone = getObjectFromGUID(Global.getTable("ZONE_GUID_PLAYER")[nextColor])
        if activeZone and activeZone.getVar("active") then
            local zoneOwner = Player[activeZone.getVar("owner_color")]
            if zoneOwner and zoneOwner.seated then
                nextPlayerFound = true
            end
        end
        if nextColor == currentPlayerColor then
            nextPlayerFound = true
        end
    end
    return nextColor
end

function startTurnSystem(params)
    if not params or not params.startPlayerColor then
        return
    end

    TURN_SYSTEM_STARTED = true

    local startPlayerColor = params.startPlayerColor

    callTurnStartEvents(nil, startPlayerColor)

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

    local playerZoneOverlay_start = getObjectFromGUID(PLAYER_ZONE_OVERLAY_GUID[startPlayerColor])
    if playerZoneOverlay_start then
        local playerOverlayPosition = playerZoneOverlay_start.getPosition():setAt('y', 1.49)
        playerZoneOverlay_start.setPosition(playerOverlayPosition)
    end

    local cameraParams = getCameraParamsForTurnPassing(startPlayerColor)
    if cameraParams then
        Player[Global.getVar("PLAYER_OWNER")[startPlayerColor]].lookAt(cameraParams)
    end

    UI.setAttribute("passButton", "image", "turn_" .. string.lower(startPlayerColor))
    UI.setAttribute("passButton", "textColor", Global.getTable("PLAYER_COLOR_HEX")[startPlayerColor])
    UI.show("turnInfo")
    UI.setAttribute("turnInfo", "visibility", Global.getVar("PLAYER_OWNER")[startPlayerColor] .. "|Black")
end

function UI_passTurn(clickerPlayer)
    if clickerPlayer == nil then
        return
    end
    local activePlayerColor = Global.getVar("activePlayerColor")
    local activeZone = getObjectFromGUID(Global.getTable("ZONE_GUID_PLAYER")[activePlayerColor])
    if (activeZone.getVar("owner_color") == clickerPlayer.color) then
        passTurn(getNextPlayerColor(activePlayerColor))
    end
end

function UI_skipTurn()
    UI.hide("skipTurn")
    local activePlayerColor = Global.getVar("activePlayerColor")
    passTurn(getNextPlayerColor(activePlayerColor))
end

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------- Turn Settings --------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function changeTurnSettings(params)
    if params.color and params.setting then
        TURN_SETTINGS[params.color][params.setting] = params.newValue
    end
end

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------- Player Events --------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--TODO test this

function onPlayerChangeColor(playerColor)
    local activePlayerColor = Global.getVar("activePlayerColor")
    if Global.call("hasGameStarted") and Global.getTable("PLAYER")[activePlayerColor] then
        local activeZone = getObjectFromGUID(Global.getTable("ZONE_GUID_PLAYER")[activePlayerColor])

        if not activeZone or not activeZone.getVar("active") or not Player[activeZone.getVar("owner_color")].seated then

            local nextPlayerConditionID = Wait.condition(
                function()
                    UI.setAttribute("skipButton", "text", "Skip Turn of " .. activePlayerColor)
                    UI.setAttribute("skipButton", "textColor", "#EAE5DE")
                    UI.show("skipTurn")
                    UI.setAttribute("skipTurn", "visibility", "Host")
                end, function()
                    return activePlayerColor ~= getNextPlayerColor(activePlayerColor)
                end)
            Wait.condition(
                function()
                    UI.hide("skipTurn")
                    Wait.stop(nextPlayerConditionID)
                end, function()
                    return Player[Global.getTable("PLAYER_OWNER")[activePlayerColor]].seated
                end, 60)
        end
    end
end

function onPlayerConnect(player)
    player.color = "Grey"
end

------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------- Turn Events ---------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

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