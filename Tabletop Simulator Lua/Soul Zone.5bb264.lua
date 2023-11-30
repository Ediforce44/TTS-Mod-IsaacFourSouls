-- Written by Ediforce44
owner_color = "White"

souls_in_this_zone = 0

COUNTER_MODULE = nil

ZONE_EDGES = {
    {x=0, z=0},       -- 1 = |""  ""| = 3
    {x=0, z=0},       -- 2 = |__  __| = 4
    {x=0, z=0},
    {x=0, z=0}
}

INDEX_MAX = 4

attachedObjects = {}
indexTable = {}

local function calculateZoneEdges()
    local scale = self.getScale()
    local xOffset = scale.z / 2
    local zOffset = scale.x / 2
    local position = self.getPosition()
    ZONE_EDGES[1] = {x = position.x - xOffset, z = position.z - zOffset}
    ZONE_EDGES[2] = {x = position.x + xOffset, z = position.z - zOffset}
    ZONE_EDGES[3] = {x = position.x - xOffset, z = position.z + zOffset}
    ZONE_EDGES[4] = {x = position.x + xOffset, z = position.z + zOffset}
end

local function getTimerParameters(blockedIndex)
    local timerParameters = {
        ["identifier"] = "SoulBlockedIndexTimer" .. self.guid .. tostring(blockedIndex),
        ["function_name"] = "resetBlockedIndex",
        ["parameters"] = {index = blockedIndex},
        ["delay"] = 2,
    }
    return timerParameters
end

function resetBlockedIndex(params)
    indexTable[params.index].tempBlocked = false
end

local function attachObject(object)
    attachedObjects[object.getGUID()] = 1
end

local function detachObject(object)
    attachedObjects[object.getGUID()] = nil
end

local function insertIndexEntry(newEntry)
    local newIndex = #indexTable + 1
    for index , entry in pairs(indexTable) do
        if entry.position.x > newEntry.position.x then
            newIndex = index
            break
        end
    end
    table.insert(indexTable, newIndex, newEntry)
end

local function initIndexTable()
    indexTable = {}

    local position = {}
    for _ , snapPoint in pairs(Global.getSnapPoints()) do
        position = snapPoint.position
        if position.x > ZONE_EDGES[1].x and position.z > ZONE_EDGES[1].z then
            if position.x < ZONE_EDGES[4].x and position.z < ZONE_EDGES[4].z then
                insertIndexEntry({free = true, position = position, tempBlocked = false})
            end
        end
    end
end

local function resetIndexTable()
    for index = 1, INDEX_MAX do
        indexTable[index].free = true
    end
end

local function calculateIndexTable()
    resetIndexTable()
    local marginOffset = 0.7
    for _ , object in pairs(self.getObjects()) do
        if object.tag == "Card" or object.tag == "Deck" then
            local objectPosition = object.getPosition()
            for index = 1, INDEX_MAX do
                if math.abs(objectPosition.x - indexTable[index].position.x) < marginOffset then
                    indexTable[index].free = false
                end
            end
        end
    end
end

local function getRealPosition(indexPosition)
    if indexPosition == nil then
        return nil
    end
    return {x = indexPosition.x, y = 5, z = indexPosition.z}
end

local function getPositionFromIndex(index)
    return getRealPosition(indexTable[index].position)
end

local function getNextFreePosition()
    calculateIndexTable()
    for index = 1, INDEX_MAX do
        if indexTable[index].free and (not indexTable[index].tempBlocked) then
            indexTable[index].tempBlocked = true
            Timer.create(getTimerParameters(index))
            return getRealPosition(indexTable[index].position)
        end
    end
    return nil
end

local function placeObject(object, position)
    object.setRotationSmooth({0, 180, 0}, false)
    object.setPositionSmooth(position, false)
end

function onLoad(saved_data)
    COUNTER_MODULE = getObjectFromGUID(Global.getVar("COUNTER_MODULE_GUID"))

    calculateZoneEdges()
    initIndexTable()
    calculateIndexTable()

    if saved_data ~= "" and false then
        local loaded_data = JSON.decode(saved_data)
        if loaded_data[1] then
            attachedObjects = loaded_data[1]
            return
        end
    end
    for _ , obj in pairs(self.getObjects()) do
        if obj.tag == "Card" then
            attachObject(obj)
        end
    end

    souls_in_this_zone = getSoulCount()
end

function onSave()
    return JSON.encode({attachedObjects})
end

function onObjectEnterZone(zone, enteringObject)
    if zone.getGUID() == self.guid then
        if enteringObject.tag == "Card" then

            attachObject(enteringObject)

            Wait.condition(function()
                if attachedObjects[enteringObject.guid] then
                    local soulAmountEarned = enteringObject.getVar("soul") or 0
                    if soulAmountEarned > 0 then
                        local newSoulCount = getSoulCount()
                        souls_in_this_zone = newSoulCount
                        COUNTER_MODULE.call("notifySOUL", {player = owner_color, value = souls_in_this_zone})

                        local soulAmount = "Souls"
                        if soulAmountEarned == 0 then
                            soulAmount = "no Soul"
                        elseif soulAmountEarned == 1 then
                            soulAmount = "1 Soul"
                        elseif soulAmountEarned > 1 then
                            soulAmount = tostring(soulAmountEarned) .. " Souls"
                        end
                        broadcastToAll(Global.call("getPlayerString", {playerColor = owner_color}) .. " earned "
                            .. Global.getTable("PRINT_COLOR_SPECIAL").SOUL .. soulAmount .. "[-]. Hurray !!!")

                        local sfxCube = getObjectFromGUID(Global.getVar("SFX_CUBE_GUID"))
                        if sfxCube then
                            sfxCube.call("playHoly")
                        end
                    end
                end
            end,
            function()
                return not enteringObject.isSmoothMoving()
            end,
            1)
        end
    end
end

function onObjectLeaveZone(zone, leavingObject)
    if zone.getGUID() == self.guid then
        if leavingObject.tag == "Card" then
            detachObject(leavingObject)
            local newSoulCount = getSoulCount()
            if newSoulCount ~= souls_in_this_zone then
                souls_in_this_zone = newSoulCount
                COUNTER_MODULE.call("notifySOUL", {player = owner_color, value = souls_in_this_zone})
            end
        end
    end
end

function getSoulCount()
    local counter = 0
    local objInZone = self.getObjects()
    for _, obj in pairs(objInZone) do
      if obj.getVar("soul") ~= nil then
        counter = counter + obj.getVar("soul")
      end
    end
    return counter
end

function placeObjectInZone(params)
    if params.object == nil then
        Global.call("printWarning", {text = "Wrong parameters in soul zone function 'placeObjectInZone()'."})
        return
    end
    local position = nil
    if params.index ~= nil and params.index <= INDEX_MAX then
        position = getPositionFromIndex(params.index)
    else
        position = getNextFreePosition()
    end
    if position ~= nil then
        placeObject(params.object, position)
    else
        local handInfo = Global.call("getHandInfo")[owner_color]
        params.object.deal(1, handInfo.owner, handInfo.index)
    end
end