owner_color = "Red"

function attachCounterBag(counterModule, counterBag)
    local counterBagStillInZone = false
    for _, obj in pairs(self.getObjects()) do
        if obj == counterBag then
            counterBagStillInZone = true
            break
        end
    end
    if not counterBagStillInZone then
        return
    end
    
    counterBag.setLock(true)

    local counterType = counterBag.getVar("COUNTER_TYPE") or counterBag.getGUID()
    local counterBagTable = counterModule.getTable("COUNTER_BAGS")[counterType]

    if counterBagTable then
        for _, bag in pairs(counterBagTable) do
            if counterBag == bag then
                return
            end
        end
    end

    counterBag.setVar("COUNTER_TYPE", counterType)
    counterModule.call("counterBag_attach", {counterBag = counterBag, type = counterType})
end

function onObjectEnterZone(zone, object)
    if zone == self then
        if (object.type == "Bag") or (object.type == "Infinite") then
            local counterModule = getObjectFromGUID(Global.getVar("COUNTER_MODULE_GUID"))
            if counterModule then
                Wait.condition(function() attachCounterBag(counterModule, object) end, function() return object.resting end)
            end
        end
    end
end