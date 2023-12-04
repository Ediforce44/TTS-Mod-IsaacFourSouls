hp = 4
atk = 1
dice = 4
type = "superboss"
harbingerAmount = 4
rewards = {CENTS = 0, LOOT = 0, TREASURES = 1, SOULS = 0}

function onReveal(params)
    if params.zone then
        local spawnPosition = {params.zone.getPosition().x, 3, params.zone.getPosition().z}
        local counter
                = getObjectFromGUID(Global.getTable("COUNTER_BAGS_GUID").NORMAL).takeObject({position = spawnPosition})
        counter.setRotationSmooth({0, 179, 0}, false)   -- 180 degree don't work?
    end
end

function onDie(params)
    if params.zone == nil then
        return
    end

    local zonePosition = {x = params.zone.getPosition().x, y = 3, z = params.zone.getPosition().z}
    self.setPositionSmooth(zonePosition)

    local counters = Global.call("getAllCountersOnCard", {card = self, type = "NUMBER"})
    if counters then 
        local counter = counters[1]
        counter.setPositionSmooth(zonePosition, false)
        counter.call("modifyCounter", {modifier = 1})
        if counter.getVar("value") == 4 then
            counter.destruct()
            self.setState(2).setPositionSmooth(zonePosition)    --activate The Beast!
        end
    end
    return false
end