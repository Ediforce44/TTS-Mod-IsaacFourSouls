-- Written by Ediforce44
SHOP_ZONE_GUIDS = Global.getTable("ZONE_GUID_SHOP")
PURCHASE_BUTTON_STATES = {
    INACTIVE    = "Inactive",
    PURCHASE    = "Purchase"
}
PURCHASE_BUTTON_COLORS = {
    INACTIVE    = {0.337, 0.27, 0.02},
    ACTIVE      = {0.6, 0.5, 0.149}
}

SHOP_BUTTON_STATES = {
    PURCHASE    = "Purchase"
}
SHOP_BUTTON_INDEX = nil

COUNTER_MODULE = nil

local function printBuyPhrase(itemName)
    local phrase = nil
    if itemName == "" then
        Global.call("printWarning", {text = "There is no item to purchase in this zone. The attribute 'NAME' is empty."})
    else
        phrase = Global.call("getActivePlayerString")
        phrase = phrase .. " got " .. Global.getTable("PRINT_COLOR_SPECIAL").TREASURE_LIGHT .. itemName .. "[-] !!!"
        broadcastToAll(phrase)
    end
    return phrase
end

local function getShopButton()
    if SHOP_BUTTON_INDEX == nil then
        return nil
    end
    return self.getButtons()[SHOP_BUTTON_INDEX + 1]
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

local function resetPurchaseButton(zone)
    local clickCounter = zone.getVar("altClickCounter")
    if clickCounter > 0 then
        zone.call("deactivateZone")
    else
        zone.setVar("altClickCounter", clickCounter + 1)
        Timer.create(getDoubleAltClickParameters(zone))
    end
end

local function purchaseShopItem(zone, playerColor)
    local itemName = zone.getTable("shop_item_attrs").NAME
    local boughtCard = nil
    for _ , obj in pairs(zone.getObjects()) do
        if obj.tag == "Deck" then
            boughtCard = obj.takeObject()
            break
        elseif obj.tag == "Card" then
            boughtCard = obj
            break
        end
    end
    if boughtCard ~= nil then
        if printBuyPhrase(itemName) then
            local playerZone = getObjectFromGUID(Global.getTable("ZONE_GUID_PLAYER")[playerColor])
            if playerZone then
                COUNTER_MODULE.call("notifyTREASURE_GAIN", {player = playerColor, dif = 1})
                playerZone.call("placeObjectInZone", {object = boughtCard})
            end
            return true
        end
    end
    return false
end

local function purchaseShopDeckItem(playerColor)
    local boughtCard = nil
    for _ , obj in pairs(self.getObjects()) do
        if obj.tag == "Deck" then
            boughtCard = obj.takeObject({flip = true})
            break
        elseif obj.tag == "Card" then
            boughtCard = obj
            boughtCard.flip()
            break
        end
    end
    if boughtCard ~= nil then
        Wait.frames(function () printBuyPhrase(boughtCard.getName()) end, 1)
        local playerZone = getObjectFromGUID(Global.getTable("ZONE_GUID_PLAYER")[playerColor])
        if playerZone then
            COUNTER_MODULE.call("notifyTREASURE_GAIN", {player = playerColor, dif = 1})
            playerZone.call("placeObjectInZone", {object = boughtCard})
        end
        return true
    end
    return false
end

function onLoad(saved_data)
    COUNTER_MODULE = getObjectFromGUID(Global.getVar("COUNTER_MODULE_GUID"))

    if saved_data == "" then
        return
    end

    local loaded_data = JSON.decode(saved_data)
    if loaded_data[1] then
        activateShopButton()
        for _ , state in pairs(SHOP_BUTTON_STATES) do
            if state == loaded_data[1] then
                --self.editButton({index = SHOP_BUTTON_INDEX, label = state})
                self.editButton({index = SHOP_BUTTON_INDEX, label = state
                        , tooltip = getShopButtonTooltip({newState = state})})
            end
        end
    end
end

function onSave()
    local currentLabel = nil
    if getShopButton() then
        currentLabel = getShopButton().label
    end
    return JSON.encode({currentLabel})
end

function resetAllShopZones()
    for _ , guid in pairs(SHOP_ZONE_GUIDS) do
        getObjectFromGUID(guid).call("resetShopZone")
    end
end

function onObjectEnterScriptingZone(zone, object)
    for i, guid in pairs(SHOP_ZONE_GUIDS) do
        if guid == zone.getGUID() then
            local newAttributes = {}
            if object.tag == "Deck" then
                local containedObjects = object.getData().ContainedObjects
                local firstCard = containedObjects[#containedObjects]
                newAttributes.NAME = firstCard["Nickname"]
            elseif object.tag == "Card" then
                newAttributes.NAME = object.getName()
            end
            zone.call("updateAttributes", newAttributes)
        end
    end
end

function onObjectLeaveScriptingZone(zone, object)
    for i, guid in pairs(SHOP_ZONE_GUIDS) do
        if guid == zone.getGUID() then
            local newAttributes = {}
            local firstObjectInZone = zone.getObjects()[1]
            if firstObjectInZone == nil then
                newAttributes = {NAME = ""}
            elseif firstObjectInZone.tag == "Card" then
                newAttributes.NAME = firstObjectInZone.getName()
            elseif firstObjectInZone.tag == "Deck" then
                for _ , card in pairs(firstObjectInZone.getObjects()) do
                    if card.guid == object.getGUID() then
                        return
                    end
                end
                local containedObjects = firstObjectInZone.getObjects()
                local firstCard = containedObjects[#containedObjects]
                newAttributes.NAME = firstCard["Nickname"]
            end
            zone.call("updateAttributes", newAttributes)
        end
    end
end

function activateShopButton()
    if SHOP_BUTTON_INDEX == nil then
        SHOP_BUTTON_INDEX = 0
        local state = SHOP_BUTTON_STATES.PURCHASE
        self.createButton({
            click_function = "click_function_ShopButton",
            function_owner = self,
            label          = state,
            position       = {0, -0.5, 3},
            width          = 1000,
            height         = 300,
            font_size      = 200,
            color          = PURCHASE_BUTTON_COLORS.ACTIVE,
            font_color     = {1, 1, 1},
            tooltip        = getShopButtonTooltip({newState = state})
        })
    end
end

-- If you want state depending tooltips, there you go :D
function getPurchaseButtonTooltip(params)
    -- params.newState
    return " - Left-Click: Activate Zone\n - Double-Right-Click: Deactivate Zone"
end

function getShopButtonTooltip(params)
    -- params.newState
    return ""
end

function deactivateShopButton()
    if SHOP_BUTTON_INDEX then
        self.removeButton(SHOP_BUTTON_INDEX)
        SHOP_BUTTON_INDEX = nil
    end
end

function changeZoneState(params)
    local zone = params.zone
    local newState = params.newState
    if zone == nil or newState == nil then
        return
    end
    if newState == PURCHASE_BUTTON_STATES.INACTIVE then
        if zone.getVar("active") then
            zone.call("deactivateZone")
        end
    elseif newState == PURCHASE_BUTTON_STATES.PURCHASE then
        if not zone.getVar("active") then
            zone.call("activateZone")
        else
            --zone.editButton({index = zone.getVar("PURCHASE_BUTTON_INDEX"), label = PURCHASE_BUTTON_STATES.PURCHASE})
            zone.editButton({index = zone.getVar("PURCHASE_BUTTON_INDEX"), label = PURCHASE_BUTTON_STATES.PURCHASE
                    , tooltip = getPurchaseButtonTooltip({newState = PURCHASE_BUTTON_STATES.PURCHASE})})
        end
    end
end

function placeNewTreasureCard(params)
    if params.zone == nil then
        return false
    end
    local newTreasureCard = nil
    for _ , obj in pairs(self.getObjects()) do
        if obj.tag == "Deck" then
            newTreasureCard = obj.takeObject({flip = true})
            break
        elseif obj.tag == "Card" then
            newTreasureCard = obj
            newTreasureCard.flip()
            break
        end
    end
    if newTreasureCard == nil then
        return false
    end
    newTreasureCard.setPositionSmooth({params.zone.getPosition().x, 5, params.zone.getPosition().z}, false)
    return true
end

function click_function_PurchaseButton(zone, color, alt_click)
    local activePlayerColor = Global.getVar("activePlayerColor")
    if alt_click then
        resetPurchaseButton(zone)
        return
    end
    local purchaseButton = zone.getButtons()[zone.getVar("PURCHASE_BUTTON_INDEX") + 1]
    if purchaseButton.label == PURCHASE_BUTTON_STATES.INACTIVE then
        zone.call("activateZone")
    elseif purchaseButton.label == PURCHASE_BUTTON_STATES.PURCHASE then
        local playerColor = color
        --If multi-char player uses button
        if Global.call("getHandInfo")[activePlayerColor].owner == color then
            playerColor = activePlayerColor
        end
        if purchaseShopItem(zone, playerColor) then
            Wait.frames(function ()
                    if not zone.call("containsDeckOrCard") then
                        placeNewTreasureCard({zone = zone})
                    end
                end, 60)
        end
    else
        Global.call("printWarning", {text = "Unknown shop button state: " .. tostring(purchaseButton.label) .. "."})
    end
end

function click_function_ShopButton(zone, color, alt_click)
    local activePlayerColor = Global.getVar("activePlayerColor")
    local shopButton = getShopButton()
    if shopButton.label == SHOP_BUTTON_STATES.PURCHASE then
        --If multi-char player uses button
        if Global.call("getHandInfo")[activePlayerColor].owner == color then
            purchaseShopDeckItem(activePlayerColor)
        else
            purchaseShopDeckItem(color)
        end
    else
        Global.call("printWarning", {text = "Unknown shop button state: " .. tostring(shopButton.label) .. "."})
    end
end