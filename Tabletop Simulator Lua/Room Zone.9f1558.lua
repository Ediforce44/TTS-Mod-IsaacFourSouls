-- Written by Ediforce44
ROOM_DECK_ZONE = getObjectFromGUID(Global.getTable("ZONE_GUID_DECK").ROOM)
ROOM_TAGS = ROOM_DECK_ZONE.getTable("ROOM_TAGS")

altClickCounter = 0

room_attrs = {
    NAME    = ""
}

discardButtonBlocked = false

ROOM_BUTTON_STATES = {}
ROOM_BUTTON_COLORS = {}
ROOM_BUTTON_INDEX = nil

active = false

local function getRoomButton()
    if ROOM_BUTTON_INDEX == nil then
        return nil
    end
    return self.getButtons()[ROOM_BUTTON_INDEX + 1]
end

function onLoad(saved_data)
    ROOM_BUTTON_STATES = ROOM_DECK_ZONE.getTable("ROOM_BUTTON_STATES")
    ROOM_BUTTON_COLORS = ROOM_DECK_ZONE.getTable("ROOM_BUTTON_COLORS")
    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        if loaded_data[1] == true then
            active = true
        end
        if loaded_data[2] then
            activateRoomButton()
            for _ , state in pairs(ROOM_BUTTON_STATES) do
                if state == loaded_data[2] then
                    --self.editButton({index = ROOM_BUTTON_INDEX, label = state})
                    self.editButton({index = ROOM_BUTTON_INDEX, label = state
                                , tooltip = ROOM_DECK_ZONE.call("getRoomButtonTooltip", {newState = state})})
                end
            end
        end
        if loaded_data[3] then
            shop_item_attrs = loaded_data[3]
        end
    end
end

function onSave()
    local currentLabel = nil
    if getRoomButton() then
        currentLabel = getRoomButton().label
    end
    return JSON.encode({active, currentLabel, room_attrs})
end

function updateAttributes(params)
    room_attrs.NAME = params.NAME or "Unkown"
end

function containsDeckOrCard(params)
    for _ , obj in pairs(self.getObjects()) do
        if obj.tag == "Deck" or obj.tag == "Card" then
            if not obj.hasTag(ROOM_TAGS.DEAD) then
                return true
            end
        end
    end
    return false
end

local function getTopMostDeckOrCard()
    local zoneObjects = self.getObjects()
    for index = #zoneObjects, 1, -1 do
        local object = zoneObjects[index]
        if object.tag == "Deck" or object.tag == "Card" then
            return object
        end
    end
    return nil
end

function placeNewRoomIfEmpty()
    if not containsDeckOrCard() then
        discardButtonBlocked = true
        local newRoomCard = ROOM_DECK_ZONE.call("placeNewRoomCard", {zone = self})
        Timer.create({identifier = "RoomDiscardDelay" .. self.guid .. newRoomCard.getGUID(), function_name = "resetTempDiscardBlock", delay = 5})
    end
end

function resetTempDiscardBlock()
    discardButtonBlocked = false
end

function discardRoomObject(object)
    object.setPositionSmooth(Global.getTable("DISCARD_PILE_POSITION").ROOM, false)
    object.setRotationSmooth({0, 180, 180}, false)
    object.addTag(ROOM_TAGS.DEAD)
    Wait.condition(function() object.removeTag(ROOM_TAGS.DEAD) end, function() return not object.isSmoothMoving() end)
end

function discardRoom()
    local deckOrCard = getTopMostDeckOrCard()
    if deckOrCard then
        local card = nil
        if deckOrCard.type == "Deck" then
            card = deckOrCard.takeObject()
        elseif deckOrCard.type == "Card" then
            card = deckOrCard
        end
        discardRoomObject(card)

        placeNewRoomIfEmpty()
    else
        if not discardButtonBlocked then
            placeNewRoomIfEmpty()
        end
    end
end

function resetRoomZone()
    -- Nothing
end

function resetAltClickCounter()
    altClickCounter = 0
end

function activateZone()
    if ROOM_BUTTON_INDEX == nil then
        activateRoomButton()
    end
    if active then
        Global.call("printWarning", {text = "Can't activate Room Zone: " .. self.guid .. ". This Zone is already active."})
    else
        if not containsDeckOrCard() then
            if ROOM_DECK_ZONE.call("placeNewRoomCard", {zone = self}) == false then
                return
            end
        end
        self.editButton({index = ROOM_BUTTON_INDEX, label = ROOM_BUTTON_STATES.CHANGE
            , tooltip = ROOM_DECK_ZONE.call("getRoomButtonTooltip", {newState = ROOM_BUTTON_STATES.CHANGE})
            , color = ROOM_BUTTON_COLORS.ACTIVE})
        active = true
    end
end

function deactivateZone()
    if ROOM_BUTTON_INDEX == nil then
        activateRoomButton()
    end
    for _, obj in pairs(self.getObjects()) do
        if (obj.type == "Deck") or (obj.type == "Card") then
            discardRoomObject(obj)
        end
    end
    self.editButton({index = ROOM_BUTTON_INDEX, label = ROOM_BUTTON_STATES.INACTIVE
        , tooltip = ROOM_DECK_ZONE.call("getRoomButtonTooltip", {newState = ROOM_BUTTON_STATES.INACTIVE})
        , color = ROOM_BUTTON_COLORS.INACTIVE})
    active = false
end

function activateRoomButton()
    if ROOM_BUTTON_INDEX == nil then
        ROOM_BUTTON_INDEX = 0
        local state = active and ROOM_BUTTON_STATES.CHANGE or ROOM_BUTTON_STATES.INACTIVE
        local color = active and ROOM_BUTTON_COLORS.ACTIVE or ROOM_BUTTON_COLORS.INACTIVE
        self.createButton({
            click_function = "click_function_RoomButton",
            function_owner = getObjectFromGUID(Global.getTable("ZONE_GUID_DECK").ROOM),
            label          = state,
            position       = {-1.1, -0.5, 2.2},
            width          = 1000,
            height         = 300,
            font_size      = 200,
            color          = color,
            font_color     = {1, 1, 1},
            tooltip        = ROOM_DECK_ZONE.call("getRoomButtonTooltip", {newState = state})
        })
        self.createButton({
            click_function = "click_function_RoomButtonDiscard",
            function_owner = getObjectFromGUID(Global.getTable("ZONE_GUID_DECK").ROOM),
            label          = ROOM_BUTTON_STATES.DISCARD,
            position       = {1.1, -0.5, 2.2},
            width          = 1000,
            height         = 300,
            font_size      = 200,
            color          = ROOM_BUTTON_COLORS.INACTIVE,
            font_color     = {1, 1, 1},
            tooltip        = ROOM_DECK_ZONE.call("getRoomButtonTooltip", {newState = ROOM_BUTTON_STATES.DISCARD})
        })
    end

end

function deactivateRoomButton()
    if ROOM_BUTTON_INDEX then
        self.removeButton(ROOM_BUTTON_INDEX)
        ROOM_BUTTON_INDEX = nil
    end
end