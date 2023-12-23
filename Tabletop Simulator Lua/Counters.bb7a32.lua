COUNTER_TYPE = {
    NUMBER  = "NUMBER",
    GOLD    = "GOLD",
    EGG     = "EGG",
    POOP    = "POOP",
    SPIDER  = "SPIDER",
    GUT     = "GUT",
}

COUNTER_BAGS = {
    NUMBER = {self}
}

COUNTER_SUBTYPE = {
    NORMAL      = "NORMAL",
    SOUL        = "SOUL",
    ITEM        = "ITEM",
    DEATH       = "DEATH",
    KILL        = "KILL",
    CENT        = "CENT",
    HANDCARD    = "HANDCARD",
    TREASURE_GAIN = "TREASURE_GAIN",
}

COUNTER_MODE = {
    MOST    = "MOST",
    LEAST   = "LEAST",
    SUM     = "SUM",
}

COUNTER_RANGE = {
    Red     = "Red",
    Blue    = "Blue",
    Green   = "Green",
    Yellow  = "Yellow"
}

local COUNTER_RANGES = 4

local SYNCED_COUNTER_RANGES = {}

local SUBTYPE_TO_NAME = {
    NORMAL      = "Normal\nCounter",
    SOUL        = "Souls",
    ITEM        = "Items",
    DEATH       = "Deaths",
    KILL        = "Kills",
    CENT        = "Cents",
    HANDCARD    = "Handcards",
    TREASURE_GAIN = "Treasures gained",
}

local MODE_TO_NAME = {
    MOST    = "Most",
    LEAST   = "Least",
    SUM     = "Sum of"
}

local COUNTERS = {}

local TRUE_COUNTER_RANGE = {}

local current_values = {}

local COUNTER_CREATION_INFO = {
    TYPE = "HANDCARD",
    MODE = "MOST",
    RANGE = {Red = true, Blue = true, Green = true, Yellow = true},
    RESET_ALL = false
}

local UNCLAIMED_COLOR = {r=0.44, g=0.44, b=0.44}

local function getTypeFromCounter(counter)
    local counterTags =  params.counter.getTags()
    for _, tag in pairs(counterTags) do
        if COUNTER_TYPE[tag] then
            return tag
        end
    end
end

local function getUniqueCurrentValues(counterGUID, subType, range)
    local values = {current_values[subType][range]}
    for _, counterRange in pairs(TRUE_COUNTER_RANGE[counterGUID]) do
        local skipThisRange = false
        for _, syncedRange in pairs(SYNCED_COUNTER_RANGES[subType][range]) do
            if counterRange == syncedRange then
                skipThisRange = true
                break
            end
        end
        if not skipThisRange then
            table.insert(values, current_values[subType][counterRange])
        end
    end
    return values
end

local function removeCounter(subType, range, mode, guid)
    local newTable = {}
    for _, entry in pairs(COUNTERS[subType][range][mode]) do
        if entry ~= guid then
            table.insert(newTable, entry)
        end
        COUNTERS[subType][range][mode] = newTable
    end
end

local function initCounter(subType, rangeTable, mode, counter)
    local initValue = 0
    if #rangeTable < 1 then
        return   
    elseif #rangeTable > 1 then
        local values = getUniqueCurrentValues(counter.getGUID(), subType, rangeTable[1])
        initValue = self.call("getG_" .. tostring(mode), {allValues = values}) or 0
    else
        initValue = current_values[subType][rangeTable[1]] or 0
    end

    counter.call("setCounter", {value = initValue})
end

local function getCounterName(subType, rangeTable, mode)
    local name = ""
    if subType == COUNTER_SUBTYPE.NORMAL then
        name = SUBTYPE_TO_NAME.NORMAL
    else
        name = MODE_TO_NAME[mode] .. "\n" .. SUBTYPE_TO_NAME[subType]
        if #rangeTable < COUNTER_RANGES then
            name = name .. "\n" .. "of"
            for _, range in pairs(rangeTable) do
                name = name .. " " .. range
            end
        end
    end
    return name
end

local function resetCounting_intern(subTypeToReset)
    if subTypeToReset then
        for playerColor, _ in pairs(current_values[subTypeToReset]) do
            current_values[subTypeToReset][playerColor] = 0
        end

        -- Can be optimized by simply iterating over TRUE_COUNTER_RANGE instead of COUNTERS
        for _, modeTable in pairs(COUNTERS[subTypeToReset]) do
            for _, counterTable in pairs(modeTable) do
                for _, guid in pairs(counterTable) do
                    if getObjectFromGUID(guid) then
                        getObjectFromGUID(guid).call("setCounter", {value = 0})
                    end
                end
            end
        end
    else
        for counterType, valueTable in pairs(current_values) do
            for playerColor, _ in pairs(valueTable) do
                current_values[counterType][playerColor] = 0
            end
        end

        -- Can be optimized by simply iterating over TRUE_COUNTER_RANGE instead of COUNTERS
        for _, rangeTable in pairs(COUNTERS) do
            for _, modeTable in pairs(rangeTable) do
                for _, counterTable in pairs(modeTable) do
                    for _, guid in pairs(counterTable) do
                        if getObjectFromGUID(guid) then
                            getObjectFromGUID(guid).call("setCounter", {value = 0})
                        end
                    end
                end
            end
        end
    end
end

function onLoad(saved_data)
    self.setColorTint(UNCLAIMED_COLOR)

    for _, subType in pairs(COUNTER_SUBTYPE) do
        COUNTERS[subType] = {}
        for _, range in pairs(COUNTER_RANGE) do
            COUNTERS[subType][range] = {}
            for _, mode in pairs(COUNTER_MODE) do
                COUNTERS[subType][range][mode] = {}
            end
        end
    end

    for _, subType in pairs(COUNTER_SUBTYPE) do
        current_values[subType] = {}
        for _, playerColor in pairs(Global.getTable("PLAYER")) do
            current_values[subType][playerColor] = 0
        end
    end

    for _, subType in pairs(COUNTER_SUBTYPE) do
        SYNCED_COUNTER_RANGES[subType] = {}
        for _, range in pairs(COUNTER_RANGE) do
            SYNCED_COUNTER_RANGES[subType][range] = {range}
        end
    end

    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        if loaded_data.counters then
            for keyType, rangeTable in pairs(loaded_data.counters) do
                for keyRange, modeTable in pairs(rangeTable) do
                    for keyMode, counterTable in pairs(modeTable) do
                        COUNTERS[keyType][keyRange][keyMode] = counterTable
                    end
                end
            end
        end
        if loaded_data.currentValues then
            for keyType, playerTable in pairs(loaded_data.currentValues) do
                for playerColor, value in pairs(playerTable) do
                    current_values[keyType][playerColor] = value
                end
            end
        end
        if loaded_data.trueCounterRange then
            for guid, colorTable in pairs(loaded_data.trueCounterRange) do
                TRUE_COUNTER_RANGE[guid] = colorTable
            end
        end

        if loaded_data.syncedCounterRanges then
            for subType, rangeTable in pairs(loaded_data.syncedCounterRanges) do
                for range, syncedRanges in pairs(rangeTable) do
                    SYNCED_COUNTER_RANGES[subType][range] = syncedRanges
                end
            end
        end
    end

    self.createButton({
        click_function = "counterCreationButton",
        function_owner = self,
        label          = "Counter",
        position       = {0, 0.02, -1.8},
        rotation       = {0, 180, 0},
        width          = 1000,
        height         = 300,
        font_size      = 200,
        color          = {0.15, 0.17, 0.18},
        font_color     = {1, 1, 1},
        tooltip        = "[b]Get Auto Counter[/b]"
    })
    self.createButton({
        click_function = "counterCreationButton",
        function_owner = self,
        label          = "Counter",
        position       = {0, 0.02, 1.8},
        width          = 1000,
        height         = 300,
        font_size      = 200,
        color          = {0.15, 0.17, 0.18},
        font_color     = {1, 1, 1},
        tooltip        = "[b]Get Auto Counter[/b]"
    })
    self.addContextMenuItem("Get Auto Counter", counterCreationContextMenu)
end

function counterCreationButton(_, playerColor)
    showWindow(playerColor)
end

function counterCreationContextMenu(playerColor)
    showWindow(playerColor)
end

function onSave()
    return JSON.encode({counters = COUNTERS, trueCounterRange = TRUE_COUNTER_RANGE, currentValues = current_values, syncedCounterRanges = SYNCED_COUNTER_RANGES})
end

------------------------------------------------------------------------------------------------------------------------
----------------------------------------------- Update Counters --------------------------------------------------------
------------------------------------- Don't call this! Call notify() instead. ------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function update(subType, playerColor, value, dif)
    if (value == nil) and (dif == nil) then
        return
    end

    if subType == COUNTER_SUBTYPE.NORMAL then
        return
    end

    local oldValue = current_values[subType][playerColor]
    local newValue = value
    if newValue == nil then
        newValue = current_values[subType][playerColor] + dif
    end
    if newValue == oldValue then
        return
    end
    
    for _, syncedRange in pairs(SYNCED_COUNTER_RANGES[subType][playerColor]) do
        current_values[subType][syncedRange] = newValue

        for mode, counterTable in pairs(COUNTERS[subType][syncedRange]) do
            for _, counterGUID in pairs(counterTable) do
                if getObjectFromGUID(counterGUID) then
                    if #TRUE_COUNTER_RANGE[counterGUID] > 1 then
                        local values = getUniqueCurrentValues(counterGUID, subType, syncedRange)
                        getObjectFromGUID(counterGUID).call("setCounter", {value = self.call("getG_" .. tostring(mode), {allValues = values})})
                    else
                        self.call("update_" .. tostring(mode), {oldValue = oldValue, newValue = newValue, counterGUID = counterGUID})
                    end
                end
            end
        end
    end
end


function getG_MOST(params)
    local highestValue = 0
    for _, value in pairs(params.allValues) do
        if value > highestValue then
            highestValue = value
        end
    end
    return highestValue
end

function getG_LEAST(params)
    local lowestValue = 9999
    for _, value in pairs(params.allValues) do
        if value < lowestValue then
            lowestValue = value
        end
    end
    return lowestValue
end

function getG_SUM(params)
    local sum = 0
    for _, value in pairs(params.allValues) do
        sum = sum + value
    end
    return sum
end

function update_MOST(params)
    local counter = getObjectFromGUID(params.counterGUID)
    if counter then
        if params.newValue > counter.getVar("value") then
            counter.call("setCounter", {value = params.newValue})
        end
    end
end

function update_LEAST(params)
    local counter = getObjectFromGUID(params.counterGUID)
    if counter then
        if params.newValue < counter.getVar("value") then
            counter.call("setCounter", {value = params.newValue})
        end
    end
end

function update_SUM(params)
    if getObjectFromGUID(params.counterGUID) then
        getObjectFromGUID(params.counterGUID).call("setCounter", {value = params.newValue})
    end
end

------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------- Notify -------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function notify(params)
    if (params.subType == nil) or (COUNTER_SUBTYPE[params.subType] == nil) then
        Global.call("printWarning", {text = "Wrong parameter in Counter function 'notify()'."})
        return
    end
    self.call("notify" .. COUNTER_SUBTYPE[params.subType], params)
end

function notifySOUL(params)
    if params.player == nil then
        Global.call("printWarning", {text = "Wrong parameter in Counter function 'notifySOUL()'."})
        return
    end
    update(COUNTER_SUBTYPE.SOUL, params.player, params.value, params.dif)
end

function notifyITEM(params)
    if params.player == nil then
        Global.call("printWarning", {text = "Wrong parameter in Counter function 'notifyITEM()'."})
        return
    end
    update(COUNTER_SUBTYPE.ITEM, params.player, params.value, params.dif)
end

function notifyDEATH(params)
    if params.player == nil then
        Global.call("printWarning", {text = "Wrong parameter in Counter function 'notifyDEATH()'."})
        return
    end
    update(COUNTER_SUBTYPE.DEATH, params.player, params.value, params.dif)
end

function notifyKILL(params)
    if params.player == nil then
        Global.call("printWarning", {text = "Wrong parameter in Counter function 'notifyKILL()'."})
        return
    end
    update(COUNTER_SUBTYPE.KILL, params.player, params.value, params.dif)
end

function notifyCENT(params)
    if params.player == nil then
        Global.call("printWarning", {text = "Wrong parameter in Counter function 'notifyCENT()'."})
        return
    end
    update(COUNTER_SUBTYPE.CENT, params.player, params.value, params.dif)
end

function notifyHANDCARD(params)
    if params.player == nil then
        Global.call("printWarning", {text = "Wrong parameter in Counter function 'notifyHANDCARD()'."})
        return
    end
    update(COUNTER_SUBTYPE.HANDCARD, params.player, params.value, params.dif)
end

function notifyTREASURE_GAIN(params)
    if params.player == nil then
        Global.call("printWarning", {text = "Wrong parameter in Counter function 'notifyTREASURE_GAIN()'."})
        return
    end
    update(COUNTER_SUBTYPE.TREASURE_GAIN, params.player, params.value, params.dif)
end

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------ UI functions ----------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function showWindow(playerColor)
    UI.show("counterCreation")
    UI.setAttribute("counterCreation", "visibility", playerColor .. "|Black")
end

function UI_selectCounterType(_, checked, id)
    if checked == "True" then
        COUNTER_CREATION_INFO.TYPE = string.match(id, "[%w-]+"):gsub("[-]", "_")
    end
end

function UI_selectCounterMode(_, checked, id)
    if checked == "True" then
        COUNTER_CREATION_INFO.MODE = string.match(id, "[%w]+")
    end
end

function UI_setCounterRange(_, checked, id)
    COUNTER_CREATION_INFO.RANGE[string.match(id, "[%w]+")] = (checked == "True")
    local selectedAmount = 0
    local selectedColor = nil
    for color, selected in pairs(COUNTER_CREATION_INFO.RANGE) do
        if selected then
            selectedAmount = selectedAmount + 1
            selectedColor = color
        end
    end
    if selectedAmount == 1 then
        Global.UI.setAttribute(selectedColor .. "_RANGE", "interactable", false)
    else
        for color, _ in pairs(COUNTER_CREATION_INFO.RANGE) do
            Global.UI.setAttribute(color .. "_RANGE", "interactable", true)
        end
    end
end

function UI_placeCounter(player)
    local functionParams = {}
    functionParams.type = COUNTER_TYPE.NUMBER
    functionParams.subType = COUNTER_CREATION_INFO.TYPE
    functionParams.mode = COUNTER_CREATION_INFO.MODE
    functionParams.range = {}
    functionParams.minValue = 0     -- Adjust this value to individual counter subTypes if you add more subTypes in the future
    for color, isInRange in pairs(COUNTER_CREATION_INFO.RANGE) do
        if isInRange then
            table.insert(functionParams.range, color)
        end
    end
    Global.call("pingEvent_attach", {playerColor=player.color, afterPingFunction="placeCounter", functionOwner=self, functionParams=functionParams})
end

function UI_toggleResetAll(_, checked)
    COUNTER_CREATION_INFO.RESET_ALL = (checked == "True")
end

function UI_resetCounter()
    if COUNTER_CREATION_INFO.RESET_ALL then
        resetCounting_intern()
    else
        resetCounting_intern(COUNTER_CREATION_INFO.TYPE)
    end
end

function UI_closeWindow()
    UI.hide("counterCreation")
    UI.setAttribute("counterCreation", "visibility", "Black")
end

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------ Custom Counter --------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function claimCounterBag(counterBag, playerColor)
    local activePlayerColor = Global.getVar("activePlayerColor")
    local realPlayerColor = playerColor
    if Global.call("getHandInfo")[activePlayerColor].owner == playerColor then
        realPlayerColor = activePlayerColor
    end

    counterBag.setColorTint(realPlayerColor)

    local functionParams = {type = counterBag.getVar("COUNTER_TYPE"), counterBag = counterBag}
    local placeCounterEventID = 
        Global.call("pingEvent_attach", {playerColor=realPlayerColor, afterPingFunction="placeCounter_Event", functionOwner=self, functionParams=functionParams})
    counterBag.setVar("placeCounterEventID", placeCounterEventID)
    counterBag.setVar("claimerColor", realPlayerColor)
    counterBag.setVar("claimed", true)
end

local function unclaimCounterBag(counterBag, playerColor)
    local placeCounterEventID = counterBag.getVar("placeCounterEventID")
    if placeCounterEventID then
        if Player[playerColor].admin or (Global.call("getHandInfo")[counterBag.getVar("claimerColor")].owner == playerColor) then
            counterBag.setColorTint(counterBag.getVar("UNCLAIMED_COLOR") or UNCLAIMED_COLOR)
            Global.call("pingEvent_detach", {eventID = placeCounterEventID})
            counterBag.setVar("claimed", false)
        end
    end
end

function claimCounterButton(counterBag, playerColor)
    if counterBag.getVar("claimed") then
        unclaimCounterBag(counterBag, playerColor)
    else
        claimCounterBag(counterBag, playerColor)
    end
end

function placeCounter_Event(params)
    local functionParams = {type = params.type, counterBag = params.counterBag}
    local placeCounterEventID = 
        Global.call("pingEvent_attach", {playerColor=params.playerColor, afterPingFunction="placeCounter_Event", functionOwner=self, functionParams=functionParams})
    params.counterBag.setVar("placeCounterEventID", placeCounterEventID)

    placeCounter(params)
end

------------------------------------------------------------------------------------------------------------------------
----------------------------------------------- AUTO Counter API -------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function ac_getCounter(params)
    params = params or {}
    local subType = params.subType or COUNTER_SUBTYPE.NORMAL
    local mode = params.mode or COUNTER_MODE.SUM
    local rangeTable = params.range
    if not rangeTable then
        rangeTable = {}
        for _, range in pairs(COUNTER_RANGE) do
            table.insert(rangeTable, range)
        end
    end

    local newCounter = self.takeObject()
    TRUE_COUNTER_RANGE[newCounter.getGUID()] = rangeTable

    for _, range in pairs(rangeTable) do
        ac_attach({subType = subType, range = range, mode = mode, object = newCounter})
    end
    Wait.frames(function()
        if params.minValue then
            newCounter.setVar("MIN_VALUE", params.minValue)
        end
        if params.maxValue then
            newCounter.setVar("MAX_VALUE", params.maxValue)
        end
        if params.name then
            newCounter.call("changeName", {name = params.name})
        else
            newCounter.call("changeName", {name = getCounterName(subType, rangeTable, mode)})
        end

        initCounter(subType, rangeTable, mode, newCounter)
    end)
    return newCounter
end

function ac_removeCounter(params)
    if not params.guid then
        Global.call("printWarning", {text = "Wrong parameter in Counter function 'ac_removeCounter()'."})
        return
    end
    
    local counterToRemove = params.guid

    for _, range in pairs(TRUE_COUNTER_RANGE[counterToRemove]) do
        for subType, rangeTable in pairs(COUNTERS) do
            for mode, counterTable in pairs(rangeTable[range]) do
                for _, counterGUID in pairs(counterTable) do
                    if counterGUID == counterToRemove then
                        ac_detach({subType = subType, range = range, mode = mode, guid = counterToRemove})
                    end
                end
            end
        end
    end
end

function ac_resetCounting(params)
    if params and params.subType then
        local counterType = COUNTER_SUBTYPE[params.subType]
        if counterType then
            resetCounting_intern(counterType)
        end
    else
        resetCounting_intern()
    end
end

function ac_attach(params)
    if (params.subType == nil) or (params.range == nil) then
        Global.call("printWarning", {text = "Wrong parameter in Counter function 'ac_attach()'."})
        return
    end

    local guid = nil
    if params.guid == nil then
        if params.object == nil then
            Global.call("printWarning", {text = "Wrong parameter in Counter function 'ac_attach()'."})
            return
        else
            guid = params.object.getGUID()
        end
    else
        guid = params.guid
    end

    local mode = params.mode or COUNTER_MODE.SUM
    table.insert(COUNTERS[params.subType][params.range][mode], guid)
end

function ac_detach(params)
    if (params.subType == nil) or (params.range == nil) or (params.mode == nil) then
        Global.call("printWarning", {text = "Wrong parameter in Counter function 'ac_detach()'."})
        return
    end
    if params.guid == nil then
        if params.object == nil then
            Global.call("printWarning", {text = "Wrong parameter in Counter function 'ac_detach()'."})
            return
        else
            removeCounter(params.subType, params.range, params.mode, params.object.getGUID())
        end
    else
        removeCounter(params.subType, params.range, params.mode, params.guid)
    end
end

-- Merge ranges to one type of counter. !!! No way back !!!
function ac_syncCounterRanges(params)
    if (not params) or (not params.rangesToSync) then
        Global.call("printWarning", {text = "Wrong parameter in Counter function 'ac_syncCounterRanges()'."})
        return
    end

    if params.subType then
        for _, rangeToSync in pairs(params.rangesToSync) do 
            SYNCED_COUNTER_RANGES[params.subType][rangeToSync] = params.rangesToSync
        end
    else
        for _, subType in pairs(COUNTER_SUBTYPE) do
            for _, rangeToSync in pairs(params.rangesToSync) do 
                SYNCED_COUNTER_RANGES[subType][rangeToSync] = params.rangesToSync
            end 
        end
    end
end

------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------- Counter API ---------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function counterBag_attach(params)
    if params and params.counterBag and params.type then
        local counterBag = params.counterBag
        local counterType = params.type

        if not COUNTER_TYPE[counterType] then
            COUNTER_TYPE[counterType] = counterType
        end
        if not COUNTER_BAGS[counterType] then
            COUNTER_BAGS[counterType] = {counterBag}
        else
            table.insert(COUNTER_BAGS, counterBag)
        end

        counterBag.setColorTint(counterBag.getVar("UNCLAIMED_COLOR") or UNCLAIMED_COLOR)

        local buttonPosition = {0, 1.7, -0.9}
        local buttonScale = {1, 1, 1}
        if (counterBag.type == "Bag") then
            buttonPosition = {0, 2.5, -1.4}
            buttonScale = {1.3, 1.3, 1.3}
        end

        counterBag.createButton({
            click_function = "claimCounterButton",
            function_owner = self,
            label          = "Claim",
            position       = params.position or buttonPosition,
            rotation       = params.rotation or {135, 0, 180},
            scale          = params.scale or buttonScale,
            width          = 800,
            height         = 300,
            font_size      = 200,
            color          = {0.1, 0.12, 0.12},
            font_color     = {1, 1, 1},
            tooltip        = "[b]Claim this counter[/b]"
        })
    end
end

function getAllCountersInZone(params)
    if params.zone == nil then
        Global.call("printWarning", {text = "Wrong parameters in Counter function 'getAllCountersInZone()'."})
        return {}
    else
        local counters = {}
        for _ , object in pairs(params.zone.getObjects()) do
            if object.hasTag("Counter") then
                table.insert(counters, object)
            end
        end
        return counters
    end
end

function getAllCountersOnCard(params)
    local card = params.card
    if card == nil then
        if params.guid then
            card = getObjectFromGUID(params.guid)
        else
            Global.call("printWarning", {text = "Wrong parameters in Counter function 'getAllCountersOnCard()'."})
            return {}
        end
    end
    local allCounters = params.type and getObjectsWithAllTags({"Counter", params.type}) or getObjectsWithTag("Counter")
    local cardPosition = card.getPosition()
    local modifiedAngle = card.getRotation().y % 180
    modifiedAngle = (modifiedAngle < 45) and (modifiedAngle) or (180 - modifiedAngle)
    local zThreshold = (modifiedAngle > -0.1 and modifiedAngle < 45.1) and (1.4 * card.getScale().z) or (1.1 * card.getScale().x)
    local xThreshold = (modifiedAngle > -0.1 and modifiedAngle < 45.1) and (1.1 * card.getScale().x) or (1.4 * card.getScale().z)

    local countersOnCard = {}
    for _, counter in pairs(allCounters) do
        if math.abs(counter.getPosition().x - cardPosition.x) < xThreshold then
            if math.abs(counter.getPosition().z - cardPosition.z) < zThreshold then
                if math.abs(counter.getPosition().y - cardPosition.y) < 2 then
                    table.insert(countersOnCard, counter)
                end
            end
        end
    end
    return countersOnCard
end

function placeCounter(params)
    if (params.counter == nil) and (params.type == nil) then
        Global.call("printWarning", {text = "Wrong parameters in Counter function 'placeCounter()'."})
        return
    end

    local position = nil
    local rotation = nil

    if (params.object) and ((params.object.type == "Card") or (params.object.type == "Deck")) then
        local object = params.object
        local countersOnCard = getAllCountersOnCard({card = object, type = (params.type or getTypeFromCounter(params.counter))})
        if #countersOnCard > 0 then
            object = countersOnCard[1]
        end

        position = object.getPosition() + Vector(0, 3, 0)
        rotation = object.getRotation():setAt('z', 0)
    else
        if params.position == nil then
            Global.call("printWarning", {text = "Wrong parameters in Counter function 'placeCounter()' [2]."})
            return
        else
            position = params.position
            rotation = params.rotation      -- Watch out! It can be nil
        end
    end

    local counter = nil

    if params.counter then
        counter = params.counter
        rotation = rotation or Vector(0, 180, 0)

        counter.setPositionSmooth(position, false)
        counter.setRotationSmooth(rotation)
    else
        local counterBag = params.counterBag
        if not counterBag then
            for _, bag in pairs(COUNTER_BAGS[params.type]) do
                if bag then
                    counterBag = bag
                    break
                end
            end
        end

        rotation = rotation or (counterBag.getRotation() + Vector(0, 180, 0))

        local amount = params.amount or 1
        for i = 1, amount do
            if params.type == "NUMBER" then
                counter = ac_getCounter(params)
            else
                if counterBag.getQuantity() == 0 then
                    break
                end
                counter = counterBag.takeObject()
            end
            
            counter.setPositionSmooth(position + Vector(0, 0.5 * i, 0), false)
            counter.setRotation(rotation, false)
        end
    end

    return counter
end

function placeCounterInZone(params)
    if (params.counter == nil) and (params.type == nil) or (params.zone == nil) then
        Global.call("printWarning", {text = "Wrong parameters in global function 'placeCounterInZone()'."})
        return nil
    end
    local amount = params.amount or 1
    local endAmount = amount
    local rotation = params.rotation or Vector(0, 180, 0)

    local typeTag = params.type or getTypeFromCounter(params.counter)
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