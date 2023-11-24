
COUNTER_SUPTYPE = {
    NORMAL  = "NORMAL",
    GOLD    = "GOLD",
    EGG     = "EGG",
    POOP    = "POOP",
    SPIDER  = "SPIDER",
    GUT     = "GUT",
}

COUNTER_TYPE = {
    NORMAL      = "NORMAL",
    SOUL        = "SOUL",
    ITEM        = "ITEM",
    DEATH       = "DEATH",
    KILL        = "KILL",
    COIN        = "COIN",
    HANDCARD    = "HANDCARD",
    TREASURE_GAIN = "TREASURE_GAIN",
}

COUNTER_RANGE = {
    GLOBAL  = "GLOBAL", -- Counts everything that fits this counter type
    Red     = "Red",
    Blue    = "Blue",
    Green   = "Green",
    Yellow  = "Yellow"
}

COUNTER_MODE = {
    MOST    = "MOST",
    LEAST   = "LEAST",
    SUM     = "SUM",
}

local TYPE_TO_NAME = {
    NORMAL      = "Normal\nCounter",
    SOUL        = "Souls",
    ITEM        = "Items",
    DEATH       = "Deaths",
    KILL        = "Kills",
    COIN        = "Coins",
    HANDCARD    = "Handcards",
    TREASURE_GAIN = "Treasures gained",
}

local MODE_TO_NAME = {
    MOST    = "Most",
    LEAST   = "Least",
    SUM     = "Sum of"
}

local COUNTERS = {}

local current_values = {}

local function removeCounter(type, range, mode, guid)
    local newTable = {}
    for _, entry in pairs(COUNTERS[type][range][mode]) do
        if entry ~= guid then
            table.insert(newTable, entry)
        end
    end
    COUNTERS[type][range][mode] = newTable
end

local function initCounter(type, range, mode, counter)
    local initValue = 0
    if range == COUNTER_RANGE.GLOBAL then
        initValue = self.call("getG_" .. tostring(mode), {allValues = current_values[type]}) or 0
    else
        initValue = current_values[type][range] or 0
    end

    counter.call("setCounter", {value = initValue})
end

local function getCounterName(type, range, mode)
    local name = ""
    if type == COUNTER_TYPE.NORMAL then
        name = TYPE_TO_NAME.NORMAL
    else
        name = MODE_TO_NAME[mode] .. "\n" .. TYPE_TO_NAME[type]
        if range ~= COUNTER_RANGE.GLOBAL then
            name = name .. "\n" .. "of " .. range
        end
    end
    return name
end

function onLoad(saved_data)
    for _, type in pairs(COUNTER_TYPE) do
        COUNTERS[type] = {}
        for _, range in pairs(COUNTER_RANGE) do
            COUNTERS[type][range] = {}
            for _, mode in pairs(COUNTER_MODE) do
                COUNTERS[type][range][mode] = {}
            end
        end
    end

    for _, type in pairs(COUNTER_TYPE) do
        current_values[type] = {}
        for _, playerColor in pairs(Global.getTable("PLAYER")) do
            current_values[type][playerColor] = 0
        end
    end

    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        if loaded_data[1] then
            for keyType, rangeTable in pairs(loaded_data[1]) do
                for keyRange, modeTable in pairs(rangeTable) do
                    for keyMode, counterTable in pairs(modeTable) do
                        COUNTERS[keyType][keyRange][keyMode] = counterTable
                    end
                end
            end
        end
        if loaded_data[2] then
            for keyType, playerTable in pairs(loaded_data[2]) do
                for playerColor, value in pairs(playerTable) do
                    current_values[keyType][playerColor] = value
                end
            end
        end
    end
end

function onSave()
    return JSON.encode({COUNTERS, current_values})
end

------------------------------------------------------------------------------------------------------------------------
----------------------------------------------- Update Counters --------------------------------------------------------
------------------------------------- Don't call this! Call notify() instead. ------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function update(type, playerColor, value, dif)
    if (value == nil) and (dif == nil) then
        return
    end

    if type == COUNTER_TYPE.NORMAL then
        return
    end

    local oldValue = current_values[type][playerColor]
    local newValue = value
    if newValue == nil then
        newValue = current_values[type][playerColor] + dif
    end
    if newValue == oldValue then
        return
    end
    
    current_values[type][playerColor] = newValue

    for range, modeTable in pairs(COUNTERS[type]) do
        if range == COUNTER_RANGE.GLOBAL then
            for mode, counterTable in pairs(modeTable) do
                local newValue = self.call("getG_" .. tostring(mode), {allValues = current_values[type]})
                for _, guid in pairs(counterTable) do
                    if getObjectFromGUID(guid) then
                        getObjectFromGUID(guid).call("setCounter", {value = newValue})
                    end
                end
            end
        elseif range == playerColor then
            for mode, counterTable in pairs(modeTable) do
                self.call("update_" .. tostring(mode), {oldValue = oldValue, newValue = newValue, counterGUIDS = counterTable})
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
    for _, guid in pairs(params.counterGUIDS) do
        local counter = getObjectFromGUID(guid)
        if counter then
            if params.newValue > counter.getVar("value") then
                counter.call("setCounter", {value = params.newValue})
            end
        end
    end
end

function update_LEAST(params)
    for _, guid in pairs(params.counterGUIDS) do
        local counter = getObjectFromGUID(guid)
        if counter then
            if params.newValue < counter.getVar("value") then
                counter.call("setCounter", {value = params.newValue})
            end
        end
    end
end

function update_SUM(params)
    for _, guid in pairs(params.counterGUIDS) do
        if getObjectFromGUID(guid) then
            getObjectFromGUID(guid).call("setCounter", {value = params.newValue})
        end
    end
end

------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------- Counter API ---------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function getCounter(params)
    local type = params.type or COUNTER_TYPE.NORMAL
    local range = params.range or COUNTER_RANGE.GLOBAL
    local mode = params.mode or COUNTER_MODE.SUM

    local newCounter = self.takeObject()

    attach({type = type, range = range, mode = mode, object = newCounter})
    Wait.frames(function()
        initCounter(type, range, mode, newCounter)
        if params.name then
            newCounter.call("changeName", {name = params.name})
        else
            newCounter.call("changeName", {name = getCounterName(type, range, mode)})
        end
    end)
    return newCounter
end

function attach(params)
    if params.type == nil then
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

    local range = params.range or COUNTER_RANGE.GLOBAL
    local mode = params.mode or COUNTER_MODE.SUM
    table.insert(COUNTERS[params.type][range][mode], guid)
end

function detach(params)
    if (params.type == nil) or (params.range == nil) or (params.mode == nil) then
        Global.call("printWarning", {text = "Wrong parameter in Counter function 'detach()'."})
        return
    end
    if params.guid == nil then
        if params.object == nil then
            Global.call("printWarning", {text = "Wrong parameter in Counter function 'detach()'."})
            return
        else
            removeCounter(params.type, params.range, params.mode, params.object.getGUID())
        end
    else
        removeCounter(params.type, params.range, params.mode, params.guid)
    end
end

------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------- Notify -------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function notify(params)
    if (params.type == nil) or (COUNTER_TYPE[params.type] == nil) then
        Global.call("printWarning", {text = "Wrong parameter in Counter function 'notify()'."})
        return
    end
    self.call("notify" .. COUNTER_TYPE[params.type], params)
end

function notifySOUL(params)
    if params.player == nil then
        Global.call("printWarning", {text = "Wrong parameter in Counter function 'notifySOUL()'."})
        return
    end
    update(COUNTER_TYPE.SOUL, params.player, params.value, params.dif)
end

function notifyITEM(params)
    if params.player == nil then
        Global.call("printWarning", {text = "Wrong parameter in Counter function 'notifyITEM()'."})
        return
    end
    update(COUNTER_TYPE.ITEM, params.player, params.value, params.dif)
end

function notifyDEATH(params)
    if params.player == nil then
        Global.call("printWarning", {text = "Wrong parameter in Counter function 'notifyDEATH()'."})
        return
    end
    update(COUNTER_TYPE.DEATH, params.player, params.value, params.dif)
end

function notifyKILL(params)
    if params.player == nil then
        Global.call("printWarning", {text = "Wrong parameter in Counter function 'notifyKILL()'."})
        return
    end
    update(COUNTER_TYPE.KILL, params.player, params.value, params.dif)
end

function notifyCOIN(params)
    if params.player == nil then
        Global.call("printWarning", {text = "Wrong parameter in Counter function 'notifyCOIN()'."})
        return
    end
    update(COUNTER_TYPE.COIN, params.player, params.value, params.dif)
end

function notifyHANDCARD(params)
    if params.player == nil then
        Global.call("printWarning", {text = "Wrong parameter in Counter function 'notifyHANDCARD()'."})
        return
    end
    update(COUNTER_TYPE.HANDCARD, params.player, params.value, params.dif)
end

function notifyTREASURE_GAIN(params)
    if params.player == nil then
        Global.call("printWarning", {text = "Wrong parameter in Counter function 'notifyTREASURE_GAIN()'."})
        return
    end
    update(COUNTER_TYPE.TREASURE_GAIN, params.player, params.value, params.dif)
end