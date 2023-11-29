ROOM_BUTTON_STATES = {
    INACTIVE = "Inactive",
    CHANGE = "New Room",
    DISCARD = "Discard"
}
ROOM_BUTTON_COLORS = {
    INACTIVE = {53/255, 41/255, 33/255},
    ACTIVE = {94/255, 76/255, 63/255}
}
ROOM_TAGS = {
    NEW = "NEW",
    DEAD = "DEAD"
}

local function getDoubleAltClickParameters(zone)
    DOUBLE_CLICK_PARAMETERS = {
        ["identifier"] = "AltClickTimer" .. zone.guid,
        ["function_owner"] = zone,
        ["function_name"] = "resetAltClickCounter",
        ["delay"] = Global.getVar("CLICK_DELAY")
    }
    return DOUBLE_CLICK_PARAMETERS
end

local function resetRoomButton(zone)
    local clickCounter = zone.getVar("altClickCounter")
    if clickCounter > 0 then
        zone.call("deactivateZone")
    else
        zone.setVar("altClickCounter", clickCounter + 1)
        Timer.create(getDoubleAltClickParameters(zone))
    end
end

function getRoomButtonTooltip(params)
    --if params.newState == nil then
    --    Global.call("printWarning", {text = "Wrong parameter in room deck zone function 'getRoomButtonTooltip()'."})
    --end
    if params then
        if params.newState == ROOM_BUTTON_STATES.DISCARD then
            return "[i]Left-Click: Discard active Room[/i]\n[i]Double-Right-Click: Deactivate Zone[/i]"
        end
    end
    return "[i]Left-Click: Activate Zone[/i]\n[i]Double-Right-Click: Deactivate Zone[/i]"
end

function placeNewRoomCard(params)
    if params.zone == nil then
        return false
    end
    local newRoomCard = nil
    for _ , obj in pairs(self.getObjects()) do
        if obj.tag == "Deck" then
            newRoomCard = obj.takeObject({flip = true})
            break
        elseif obj.tag == "Card" then
            newRoomCard = obj
            newRoomCard.flip()
            break
        end
    end
    if newRoomCard == nil then
        return nil
    end
    newRoomCard.setPositionSmooth({params.zone.getPosition().x, 5, params.zone.getPosition().z}, false)
    return newRoomCard
end

function click_function_RoomButton(zone, color, alt_click)
    if alt_click then
        resetRoomButton(zone)
        return
    end
    local roomButton = zone.getButtons()[zone.getVar("ROOM_BUTTON_INDEX") + 1]
    if roomButton.label == ROOM_BUTTON_STATES.INACTIVE then
        zone.call("activateZone")
    elseif roomButton.label == ROOM_BUTTON_STATES.CHANGE then
        placeNewRoomCard({zone = zone})
    else
        Global.call("printWarning", {text = "Unknown shop button state: " .. tostring(attackButton.label) .. "."})
    end
end

function click_function_RoomButtonDiscard(zone, color, alt_click)
    if alt_click then
        resetRoomButton(zone)
        return
    end
    if zone.getVar("active") then
        zone.call("discardRoom")
    end
end