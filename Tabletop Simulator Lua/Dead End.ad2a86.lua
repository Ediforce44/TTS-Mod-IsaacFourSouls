function onObjectEnterScriptingZone(zone, enter_object)
    if zone == self then
        destroyObject(enter_object)
    end
end