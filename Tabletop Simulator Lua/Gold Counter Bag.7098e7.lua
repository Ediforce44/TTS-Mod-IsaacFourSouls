COUNTER_TYPE = "GOLD"
claimed = false
placeCounterEventID = nil

function onLoad()
    local counterModuleGuid = Global.getVar("COUNTER_MODULE_GUID")
    if counterModuleGuid then
        local counterModule = getObjectFromGUID(counterModuleGuid)
        if counterModule then
            counterModule.call("counterBag_attach", {counterBag = self, type = COUNTER_TYPE})
        end
    end
end