owner_color = "Green"

function onObjectEnterZone(zone, object)
    if zone == self then
        if (object.type == "Bag") or (object.type == "Infinite") then
            local counterModule = getObjectFromGUID(Global.getVar("COUNTER_MODULE_GUID"))
            if counterModule then
                Wait.condition(function() object.setLock(true) end, function() return object.resting end)
                
                local counterType = object.getVar("COUNTER_TYPE") or object.getGUID()
                local counterBagTable = counterModule.getTable("COUNTER_BAGS")[counterType]

                if counterBagTable then
                    for _, counterBag in pairs(counterBagTable) do
                        if object == counterBag then
                            return
                        end
                    end
                end

                object.setVar("COUNTER_TYPE", counterType)
                counterModule.call("counterBag_attach", {counterBag = object, type = counterType})
            end
        end
    end
end