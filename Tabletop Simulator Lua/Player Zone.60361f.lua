-- Written by Ediforce44
owner_color = "Blue"
zone_color = "Blue"
active = false

HP_GUIDS = Global.getTable("HEART_TOKENS_GUID")[zone_color]
COUNTER_MODULE = nil

ZONE_EDGES = {
    {x=0, z=0},       -- 1 = |""  ""| = 3
    {x=0, z=0},       -- 2 = |__  __| = 4
    {x=0, z=0},
    {x=0, z=0}
}

INDEX_MAX = 14
ROW_MAX = 2
INDICES_PER_ROW = INDEX_MAX / ROW_MAX

playerAlive = true
attachedObjects = {CARDS = {}, COUNTERS = {}}
indexTable = {}
indexTableCounter = {}

local timerCounterID = 1

local function calculateZoneEdges()
    local scale = self.getScale()
    local xOffset = scale.x / 2
    local zOffset = scale.z / 2
    local position = self.getPosition()
    ZONE_EDGES[1] = {x = position.x - xOffset, z = position.z + zOffset}
    ZONE_EDGES[2] = {x = position.x - xOffset, z = position.z - zOffset}
    ZONE_EDGES[3] = {x = position.x + xOffset, z = position.z + zOffset}
    ZONE_EDGES[4] = {x = position.x + xOffset, z = position.z - zOffset}
end

local function getTimerParameters(blockedIndex)
    local timerParameters = {
        ["identifier"] = "PlayerBlockedIndexTimer" .. self.guid .. tostring(blockedIndex),
        ["function_name"] = "resetBlockedIndex",
        ["parameters"] = {index = blockedIndex},
        ["delay"] = 2,
    }
    return timerParameters
end

local function getTimerParametersCounter(blockedIndex)
    timerCounterID = timerCounterID + 1
    local timerParameters = {
        ["identifier"] = "PlayerCounterBlockedIndexTimer" .. self.guid .. tostring(timerCounterID),
        ["function_name"] = "resetBlockedIndexCounter",
        ["parameters"] = {index = blockedIndex},
        ["delay"] = 2,
    }
    return timerParameters
end

local function getRowFromIndex(index)
    return math.floor(index/(INDICES_PER_ROW + 1)) + 1
end

local function getColumnFromIndex(index)
    --Start counting at 1 is shit
    local theoryColumn = index % INDICES_PER_ROW
    if theoryColumn == 0 then
        return INDICES_PER_ROW
    end
    return theoryColumn
end

function resetBlockedIndex(params)
    local row = getRowFromIndex(params.index)
    local column = getColumnFromIndex(params.index)
    indexTable[row][column].tempBlocked = false
end

function resetBlockedIndexCounter(params)
    indexTableCounter[params.index].tempBlocked = false
end

local function payDeathPenalty()
    --TODO
    return
end

local function attachCard(card)
    attachedObjects.CARDS[card.getGUID()] = {IsItem = card.hasTag("ITEM"), ActiveItem = card.hasTag("ACTIVE"), Ethernal = card.hasTag("ETHERNAL")}
end

local function attachCounter(counter)
    local counterType = "None"
    for _, tag in pairs(counter.getTags()) do
        if tag ~= "COUNTER" then
            counterType = tag
            break
        end
    end
    attachedObjects.COUNTERS[counter.getGUID()] = {Type = counterType}
end

local function detachCard(card)
    attachedObjects.CARDS[card.getGUID()] = nil
end

local function detachCounter(counter)
    attachedObjects.COUNTERS[counter.getGUID()] = nil
end

local function getRowAndColumnFromPosition(position)
    local marginOffset = 0.7
    local row = 0
    for r = 1, ROW_MAX do
        if math.abs(position.z - indexTable[r][1].position.z) < marginOffset then
            row = r
            break
        end
    end
    if row > 0 then
        for c = 1, INDICES_PER_ROW do
            if math.abs(position.x - indexTable[row][c].position.x) < marginOffset then
                column = c
                break
            end
        end
    end
    return {row = row, column = column}
end

local function insertIndexEntry(newEntry)
    local ROW_WIDTH = math.abs(((ZONE_EDGES[2].z - ZONE_EDGES[1].z) / 2))
    local row = 0
    for r = 1, ROW_MAX do
        if newEntry.position.z < (ZONE_EDGES[2].z + (ROW_WIDTH * r)) then
            row = r
            break
        end
    end
    local newIndex = #indexTable[row] + 1
    for index , entry in pairs(indexTable[row]) do
        if entry.position.x > newEntry.position.x then
            newIndex = index
            break
        end
    end
    table.insert(indexTable[row], newIndex, newEntry)
end

local function insertIndexEntryCounter(newEntry)
    local marginOffset = 0.7
    local newIndex = #indexTableCounter + 1
    for index , entry in ipairs(indexTableCounter) do
        if math.abs(entry.position.z - newEntry.position.z) < marginOffset then
            if entry.position.x > newEntry.position.x then
                newIndex = index
            else
                newIndex = index + 1
            end
            break
        elseif entry.position.z < newEntry.position.z then
            newIndex = 1
            break
        end
    end
    table.insert(indexTableCounter, newIndex, newEntry)
end

local function initIndexTables()
    indexTable = {}
    for row = 1, ROW_MAX do
        table.insert(indexTable, {})
    end

    local position = {}
    for _ , snapPoint in pairs(Global.getSnapPoints()) do
        position = snapPoint.position
        if position.x > ZONE_EDGES[1].x and position.z < ZONE_EDGES[1].z then
            if position.x < ZONE_EDGES[4].x and position.z > ZONE_EDGES[4].z then
                if #snapPoint.tags == 0 then
                    insertIndexEntry({free = true, position = position:setAt('y', 5), tempBlocked = false})
                elseif snapPoint.tags[1] == "COUNTER" then
                    insertIndexEntryCounter({free = true, position = position:setAt('y', 5), tempBlocked = false, type = nil})
                end
            end
        end
    end
end

local function resetIndexTable()
    for row = 1, ROW_MAX do
        for column = 1, INDICES_PER_ROW do
            indexTable[row][column].free = true
        end
    end
end

local function calculateIndexTable()
    resetIndexTable()
    for _ , object in pairs(self.getObjects()) do
        if object.tag == "Card" or object.tag == "Deck" then
            local rowColumnTable= getRowAndColumnFromPosition(object.getPosition())
            indexTable[rowColumnTable.row][rowColumnTable.column].free = false
        end
    end
end

local function getIndexFromPositionCounter(position)
    local marginOffset = 0.7
    for index , entry in ipairs(indexTableCounter) do
        if math.abs(entry.position.z - position.z) < marginOffset then
            if math.abs(entry.position.x - position.x) < marginOffset then
                return index
            end
        end
    end
    return nil
end

local function calculateIndexTableCounter()
    for i=1, #indexTableCounter do
        if not indexTableCounter[i].tempBlocked then
            indexTableCounter[i].free = true
            indexTableCounter[i].type = nil
        end
    end

    for _, object in pairs(self.getObjects()) do
        for _, tag in pairs(object.getTags()) do
            if tag == "COUNTER" then
                local index = getIndexFromPositionCounter(object.getPosition())
                if index then
                    indexTableCounter[index].free = false
                    local tags = object.getTags()
                    if tags[2] then
                        indexTableCounter[index].type = tags[2]
                    end
                end
            end
        end
    end
end

local function getPositionFromIndex(index)
    local row = getRowFromIndex(index)
    local column = getColumnFromIndex(index)
    if indexTable[row] == nil then
        return nil
    end
    return indexTable[row][column].position
end

local function getNextFreePosition(startingIndex)
    startingIndex = startingIndex or 1
    local startRow = getRowFromIndex(startingIndex)
    local startColumn = getColumnFromIndex(startingIndex)
    calculateIndexTable()
    for row = startRow, ROW_MAX do
        for column = startColumn, INDICES_PER_ROW do
            if indexTable[row][column].free and (not indexTable[row][column].tempBlocked) then
                indexTable[row][column].tempBlocked = true
                Timer.create(getTimerParameters((INDICES_PER_ROW * (row - 1)) + column))
                return indexTable[row][column].position
            end
        end
    end
    return nil
end

local function placeObject(object, position)
    object.setRotationSmooth({0, 180, 0}, false)
    object.setPositionSmooth(position, false)
end

local function getPositionForCounter(counterType)
    for _, entry in pairs(indexTableCounter) do
        if entry.type == counterType then
            return entry.position
        end
    end
    for index, entry in ipairs(indexTableCounter) do
        if entry.free and (not entry.tempBlocked) then
            indexTableCounter[index].tempBlocked = true
            indexTableCounter[index].type = counterType
            Timer.create(getTimerParametersCounter(index))
            return entry.position
        end
    end
    return nil
end

local function getHPs(zone)
    local hp = 0
    for _, obj in pairs(zone.getObjects()) do
        if obj.type == "Card" then
            hp = hp + (obj.call("getHP", {}) or 0)
        end
    end
    return hp
end

function onLoad(saved_data)
    COUNTER_MODULE = getObjectFromGUID(Global.getVar("COUNTER_MODULE_GUID"))

    calculateZoneEdges()
    initIndexTables()
    calculateIndexTable()

    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        if loaded_data.playerAlive then
            playerAlive = not (loaded_data.playerAlive == false)      --Standard: true, only false if loaded_data[1] is false
        end
        if loaded_data.owner then
            owner_color = loaded_data.owner
        end
        if loaded_data.active then
            active = true
        end
        if loaded_data.attachedObjects then
            attachedObjects = loaded_data.attachedObjects
            return
        end
    end
    for _ , obj in pairs(self.getObjects()) do
        if obj.type == "Card" then
            attachCard(obj)
        elseif obj.hasTag("Counter") then
            attachCounter(obj)
        end
    end
end

function onSave()
    return JSON.encode({playerAlive = playerAlive, attachedObjects = attachedObjects, owner = owner_color, active = active})
end

function onObjectEnterZone(zone, enteringObject)
    if zone.getGUID() == self.guid then
        if enteringObject.type == "Card" then
            attachCard(enteringObject)
            COUNTER_MODULE.call("notifyITEM", {player = zone_color, value = #getItems()})
        elseif enteringObject.hasTag("Counter") then
            attachCounter(enteringObject)
        end
    end
end

function onObjectLeaveZone(zone, leavingObject)
    if zone.getGUID() == self.guid then
        if leavingObject.type == "Card" then
            detachCard(leavingObject)
            COUNTER_MODULE.call("notifyITEM", {player = zone_color, value = #getItems()})
        elseif leavingObject.hasTag("Counter") then
            detachCounter(leavingObject)
        end
    end
end

function activateCharacter()
    for _ , obj in pairs(self.getObjects()) do
        if obj.hasTag("Character") then
            obj.setRotationSmooth({0, 180, 0}, false)
        end
    end
end

function deactivateCharacter()
    for _ , obj in pairs(self.getObjects()) do
        if obj.hasTag("Character") then
            obj.setRotationSmooth({0, 270, 0}, false)
        end
    end
end

function activateActiveItems()
    for cardGuid, cardInfo in pairs(attachedObjects.CARDS) do
        if cardInfo.ActiveItem then
            local card = getObjectFromGUID(cardGuid)
            if card then
                card.setRotationSmooth({0, 180, 0}, false)
            end
        end
    end
end

function deactivateActiveItems()
    for cardGuid, cardInfo in pairs(attachedObjects.CARDS) do
        if cardInfo.ActiveItem then
            local card = getObjectFromGUID(cardGuid)
            if card then
                card.setRotationSmooth({0, 270, 0}, false)
            end
        end
    end
end

function reanimatePlayer()
    playerAlive = true
end

function killPlayer()
    playerAlive = false
    deactivateCharacter()
    deactivateActiveItems()
    payDeathPenalty()
end

function getPlayerHP()
    for i = 1, i < #HP_GUIDS do
        local hpToken = getObjectFromGUID(HP_GUIDS[i + 1])
        if hpToken and not hpToken.getVar("isActive") then
            return (i - 1)
        end
    end
    return (#HP_GUIDS - 1)
end

function getItems(params)
    local cardGUIDS = {}
    if params and params.onlyDestroyable then
        for cardGUID, infoTable in pairs(attachedObjects.CARDS) do
            if infoTable.IsItem and not infoTable.Ethernal then
                table.insert(cardGUIDS, cardGUID)
            end
        end
    else
        for cardGUID, infoTable in pairs(attachedObjects.CARDS) do
            if infoTable.IsItem then
                table.insert(cardGUIDS, cardGUID)
            end
        end
    end
    return cardGUIDS
end

function healPlayer(params)
    local playerHP = 0

    if params and params.amount then
        playerHP = getPlayerHP() + params.amount
    else
        playerHP = getHPs(self)

        local soulZoneGuids = Global.getTable("ZONE_GUID_SOUL")
        local soulZone = getObjectFromGUID(soulZoneGuids[zone_color])
        if soulZone then
            playerHP = playerHP + getHPs(soulZone)
        end

        if playerHP == 0 then
            return
        end
    end

    if playerHP >= #HP_GUIDS then
        playerHP = #HP_GUIDS - 1
    end

    local hpToken = getObjectFromGUID(HP_GUIDS[playerHP + 1])
    if hpToken then
        hpToken.call("onPickUp")
    end
end

function getIndex(params)
    local position = nil
    if params.object == nil then
        if params.guid ~= nil then
            local object = getObjectFromGUID(params.guid)
            if object then
                position = object.getPosition()
            end
        else
            if params.position then
                position = params.position
            end
        end
    else
        position = params.object.getPosition()
    end
    if position == nil then
        Global.call("printWarning", {text = "Wrong parameters in player zone function 'getIndex()'."})
        return
    end

    local rowColumnTable = getRowAndColumnFromPosition(objPosition)
    return (rowColumnTable.row * INDICES_PER_ROW) + rowColumnTable.column
end

function placeObjectInZone(params)
    if params.object == nil then
        Global.call("printWarning", {text = "Wrong parameters in player zone function 'placeObjectInZone()'."})
        return
    end
    local position = nil
    if params.index ~= nil and params.index <= INDEX_MAX then
        if params.replacing then
            position = getPositionFromIndex(params.index)
        else
            position = getNextFreePosition(params.index)
        end
    else
        position = getNextFreePosition()
    end
    if position ~= nil then
        placeObject(params.object, position)
    elseif params.object.use_hands then
        local handInfo = Global.call("getHandInfo")[zone_color]
        params.object.deal(1, handInfo.owner, handInfo.index)
    else
        return false
    end

    return true
end

-- More efficent for multi card placing
function placeMultipleObjectsInZone(params)
    if (params.objects == nil) or (#params.objects == 0) then
        Global.call("printWarning", {text = "Wrong parameters in player zone function 'placeMultipleObjectsInZone()'."})
        return
    end

    local startRow = 1
    local startColumn = 1
    if params.index ~= nil and params.index <= INDEX_MAX then
        startRow = getRowFromIndex(params.index)
        startColumn = getColumnFromIndex(params.index)
    end

    calculateIndexTable()
    local maxObjectIndex = #params.objects
    local nextObjectIndex = 1
    for row = startRow, ROW_MAX do
        for column = startColumn, INDICES_PER_ROW do
            if params.replacing or indexTable[row][column].free then
                placeObject(params.objects[nextObjectIndex], indexTable[row][column].position)
                nextObjectIndex = nextObjectIndex + 1
                if nextObjectIndex > maxObjectIndex then
                    return true
                end
            end
        end
    end
    -- Not enough free fields for cards
    for index = nextObjectIndex , maxObjectIndex do
        if params.object.use_hands then
            local handInfo = Global.call("getHandInfo")[zone_color]
            params.objects[index].deal(1, handInfo.owner, handInfo.index)
        end
    end
    return false
end

function placeCounterInZone(params)
    if (params.type == nil) and (params.counter == nil) then
        Global.call("printWarning", {text = "Wrong parameters in player zone function 'placeCounterInZone()'."})
        return
    end
    local characterExist = false
    for _, obj in pairs(self.getObjects()) do
        if string.match(obj.getDescription(), "%w*_character$") then
            characterExist = true
        end
    end
    if characterExist then
        calculateIndexTableCounter()
        if params.counter then
            if params.counter.getTags() and params.counter.getTags()[2] then
                local position = getPositionForCounter(params.counter.getTags()[2])
                if position then
                    params.counter.setPositionSmooth(position, false)
                    params.counter.setRotationSmooth(Vector(0, 180, 0))
                end
            end
        else
            local counterType = params.type
            local counterBag = getObjectFromGUID(Global.getTable("COUNTER_BAGS_GUID")[counterType])
            local amount = 1
            if params.amount then
                amount = params.amount
            end
            local position = getPositionForCounter(counterType)
            for i = 1, amount do
                local counter = counterBag.takeObject()
                counter.setPositionSmooth(position + Vector(0, 0.5 * i, 0), false)
                counter.setRotationSmooth(Vector(0, 180, 0))
            end
        end
    end
end