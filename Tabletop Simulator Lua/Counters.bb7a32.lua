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

local TYPE_TO_NAME = {
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
        name = TYPE_TO_NAME.NORMAL
    else
        name = MODE_TO_NAME[mode] .. "\n" .. TYPE_TO_NAME[subType]
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
        color          = {0.39, 0.46, 0.48},
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
        color          = {0.39, 0.46, 0.48},
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
    functionParams.type = Global.getTable("COUNTER_TYPE").NUMBER
    functionParams.subType = COUNTER_CREATION_INFO.TYPE
    functionParams.mode = COUNTER_CREATION_INFO.MODE
    functionParams.range = {}
    functionParams.minValue = 0     -- Adjust this value to individual counter subTypes if you add more subTypes in the future
    for color, isInRange in pairs(COUNTER_CREATION_INFO.RANGE) do
        if isInRange then
            table.insert(functionParams.range, color)
        end
    end
    Global.call("pingEvent_attach", {playerColor=player.color, afterPingFunction="placeCounter", functionParams=functionParams})
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
-------------------------------------------------- Counter API ---------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function getCounter(params)
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
        attach({subType = subType, range = range, mode = mode, object = newCounter})
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

function removeCounter(params)
    if not params.guid then
        Global.call("printWarning", {text = "Wrong parameter in Counter function 'removeCounter()'."})
        return
    end
    
    local counterToRemove = params.guid

    for _, range in pairs(TRUE_COUNTER_RANGE[counterToRemove]) do
        for subType, rangeTable in pairs(COUNTERS) do
            for mode, counterTable in pairs(rangeTable[range]) do
                for _, counterGUID in pairs(counterTable) do
                    if counterGUID == counterToRemove then
                        detach({subType = subType, range = range, mode = mode, guid = counterToRemove})
                    end
                end
            end
        end
    end
end

function resetCounting(params)
    if params and params.subType then
        local counterType = COUNTER_SUBTYPE[params.subType]
        if counterType then
            resetCounting_intern(counterType)
        end
    else
        resetCounting_intern()
    end
end

function attach(params)
    if (params.subType == nil) or (params.range == nil) then
        Global.call("printWarning", {text = "Wrong parameter in Counter function 'attach()'."})
        return
    end

    local guid = nil
    if params.guid == nil then
        if params.object == nil then
            Global.call("printWarning", {text = "Wrong parameter in Counter function 'attach()'."})
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

function detach(params)
    if (params.subType == nil) or (params.range == nil) or (params.mode == nil) then
        Global.call("printWarning", {text = "Wrong parameter in Counter function 'detach()'."})
        return
    end
    if params.guid == nil then
        if params.object == nil then
            Global.call("printWarning", {text = "Wrong parameter in Counter function 'detach()'."})
            return
        else
            removeCounter(params.subType, params.range, params.mode, params.object.getGUID())
        end
    else
        removeCounter(params.subType, params.range, params.mode, params.guid)
    end
end

-- Merge ranges to one type of counter. !!! No way back !!!
function syncCounterRanges(params)
    if (not params) or (not params.rangesToSync) then
        Global.call("printWarning", {text = "Wrong parameter in Counter function 'syncCounterRanges()'."})
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