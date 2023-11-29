local ZONE_GUID_BONUSSOUL = Global.getTable("ZONE_GUID_BONUSSOUL")
local conditionTable = {}

function onLoad()
    for zoneType, _ in pairs(ZONE_GUID_BONUSSOUL) do
        conditionTable[zoneType] = {}
    end
end

local function getPlaceCounterParams(zone, counterInfo, object)
    local placeCounterParams = {type=counterInfo.type or Global.getTable("COUNTER_TYPE").NUMBER}
    if counterInfo.subType then
        placeCounterParams.subType = counterInfo.subType
    end
    if counterInfo.mode then
        placeCounterParams.mode = counterInfo.mode
    end
    if counterInfo.range then
        placeCounterParams.range = counterInfo.range
    end
    if object then
        placeCounterParams.object = object
    else
        placeCounterParams.position = zone.getPosition()
        placeCounterParams.rotation = zone.getRotation()
    end
    return placeCounterParams
end

function onObjectEnterZone(zone, object)
    if object.getVar("type") and object.getVar("type") == "bonusSoul" then
        for zoneType, zoneGUID in pairs(ZONE_GUID_BONUSSOUL) do
            if zone.getGUID() == zoneGUID then
                local counterInfo = object.getTable("counter")
                if counterInfo then
                    local zone = getObjectFromGUID(zoneGUID)
                    if zone then
                        local conditionID = Wait.condition(function()
                            conditionTable[zoneType][object.getGUID()] = nil
                            for _, objectInZone in pairs(zone.getObjects()) do
                                if objectInZone == object then
                                    object.setTable("counter", nil)
                                    Global.call("placeCounter", getPlaceCounterParams(zone, counterInfo, object))
                                end
                            end
                        end,
                        function() return object.resting end)

                        conditionTable[zoneType][object.getGUID()] = conditionID
                        return
                    end
                end
            end
        end
    end
end

function onObjectLeaveZone(zone, object)
    for zoneType, zoneGUID in pairs(ZONE_GUID_BONUSSOUL) do
        if zone.getGUID() == zoneGUID then
            if conditionTable[zoneType][object.getGUID()] then
                Wait.stop(conditionTable[zoneType][object.getGUID()])
                conditionTable[zoneType][object.getGUID()] = nil
            end
        end
    end
end