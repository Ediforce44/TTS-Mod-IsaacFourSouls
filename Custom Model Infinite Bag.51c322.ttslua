--Clicker Roller Universal      by: MrStump
setting = {print={}} --Don't edit this line

--To change the die that this tool rolls, right click it and hit reset
--Then drop the die you want onto the tool (it is an infinite bag)
--Die must have rotation values! (from the Gizmo Tool)

--Edit the below variables to modify the functionality of this device

--Disables the button, places indicator of roll locations (true or false)
setting.setup = false

--How far from the center of the device the dice are spawned
setting.radius = 4
--How wide of an arch the dice are placed on, in degrees (1-360)
setting.arc = 240
--Where center of the arc is around the tool is placed (0=bottom, 180=top)
setting.rotation = 180
--Height above tool die is spawned
setting.height = 3.0
--Scaling factor for die being spawned (1 is normal, 0.5 is 1/2 size, 2 is 2x)
setting.scale = 1

--Maximum dice that can be spawned by this tool (-1 is infinite)
setting.maxCount = 5
--Delay (seconds) after a click that the roll is done (0.5 or more)
setting.rollDelay = 1.2
--Time before dice are cleaned up (0 is instant, -1 won't clean them)
setting.cleanupDelay = 5

--If it dyes the die the color of the player clicking (true or false)
setting.colorDie = true

--Turn on/off printing of the player who rolled (true or false)
setting.print.player = true
--Turn on/off printing of individual results
setting.print.individual = true
--Turn on/off printing of "total" results (adding them together)
setting.print.total = false
--Use player color when printing roll results:
setting.print.playerColor = true

--If this tool will work with other copies of itself (true or false)
--Any roller clicked by the same color player will be treated as the same
setting.coop = true



--Edit beyond this point only if you have accepted Lua into your heart, amen



--Save function (triggered when adding a die or clearing the dice)
function onSave()
    local tableToSave = {}
    for _, die in ipairs(spawnedDice) do
        if die ~= nil then
            table.insert(tableToSave, die.getGUID())
        end
    end
    saved_data = JSON.encode(tableToSave)
    return saved_data
end

function onload(saved_data)
    if saved_data ~= "" then
        --Remove any old dice from the table
        local loaded_data = JSON.decode(saved_data)
        for _, dieGUID in ipairs(loaded_data) do
            local die = getObjectFromGUID(dieGUID)
            if die ~= nil then
                destroyObject(die)
            end
        end
        spawnedDice = {}
    else
        spawnedDice = {}
    end

    math.randomseed(os.time())
    createButtons()
end



--Spawn dice for rolling



function click_roll(_, color)
    --Dice spam protection check
    local denyRoll = false
    if setting.maxCount > 0 and #spawnedDice >= setting.maxCount then
        denyRoll = true
    end
    if rollInProgress==nil and denyRoll==false and anyRollInProgress(color)==false then
        --Find dice positions, moving previously spawned dice if needed
        --local angleStep = arcTotalLength / (#currentDice+1)
        for i, die in ipairs(spawnedDice) do
            local pos_local = getLocalPointOnArc(i, #spawnedDice+1)
            local pos = self.positionToWorld(pos_local)
            die.setPositionSmooth(pos)
        end

        --Spawns dice
        local pos_local = getLocalPointOnArc(#spawnedDice+1, #spawnedDice+1)
        local spawnedDie = self.takeObject({
            position = self.positionToWorld(pos_local),
            rotation = randomRotation(),
        })

        --Setup die that was just spawned
        spawnedDie.setScale({setting.scale,setting.scale,setting.scale})
        spawnedDie.setLock(true)
        if setting.colorDie == true then
            spawnedDie.setColorTint(stringColorToRGB(color))
        end
        --This line stops the die from re-entering the bag
        spawnedDie.script_state = " "

        rollTimerUpdate({color=color})

        --Update data
        table.insert(spawnedDice, spawnedDie)
        updateGlobalTable(color)
        updateRollTimers(color)

    elseif rollInProgress == false then
        --If after roll but before cleanup
        cleanupDice()
        click_roll(_, color)
    else
        --If button click is denied due to roll (or 2 many dice)
        Player[color].broadcast("Roll in progress.", {0.8, 0.2, 0.2})
    end
end

function rollTimerUpdate(param)
    --Timer starting
    Timer.destroy("clickRoller_"..self.getGUID())
    Timer.create({
        identifier="clickRoller_"..self.getGUID(), delay=setting.rollDelay,
        function_name="timer_rollDice", function_owner=self,
        parameters = param
    })
end



--Rolling activation and in-progress monitoring



--Rolls all the dice and then launches monitoring
function timer_rollDice(p)
    rollInProgress = true
    function coroutine_rollDice()
        for _, die in ipairs(spawnedDice) do
            die.setLock(false)
            die.randomize()
            wait(0.1)
        end

        monitorDice(p.color)

        return 1
    end
    startLuaCoroutine(self, "coroutine_rollDice")
end


--Monitors dice to come to rest
function monitorDice(color)
    function coroutine_monitorDice()
        repeat
            local allRest = true
            for _, die in ipairs(spawnedDice) do
                if die ~= nil and die.resting == false then
                    allRest = false
                end
            end
            coroutine.yield(0)
        until allRest == true

        if areOtherRollersRolling(color)==true and setting.coop==true then
            --If other coop rollers are rolling
            rollingHasStopped = true
            return 1
        else
            --If roll is complete and no further waiting is required
            if setting.print.individual==true or setting.print.total==true then
                displayResults(color)
            end
            finalizeRoll({color=color})
            if setting.coop == true then finalizeCoopRolls(color) end
        end

        return 1
    end
    startLuaCoroutine(self, "coroutine_monitorDice")
end

function finalizeRoll(p)
    local color = p.color
    rollingHasStopped = nil --Used for coop communication
    rollInProgress = false --Used for button lockout
    updateGlobalTable(nil)

    --Auto die removal
    if setting.cleanupDelay > -1 then
        --Timer starting
        Timer.destroy("clickRoller_cleanup_"..self.getGUID())
        Timer.create({
            identifier="clickRoller_cleanup_"..self.getGUID(),
            function_name="cleanupDice", function_owner=self,
            delay=setting.cleanupDelay,
        })
    end
end



--After roll actions (printing/cleanup)



--Removes the dice
function cleanupDice()
    for _, die in ipairs(spawnedDice) do
        if die ~= nil then
            destroyObject(die)
        end
    end

    rollInProgress = nil
    spawnedDice = {}

    Timer.destroy("clickRoller_cleanup_"..self.getGUID())
end

function displayResults(color)
    local s, valueTable = "", {}

    addAllSpawnedDice(color)

    --Player name
    if setting.print.player == true then
        s = Player[color].steam_name
        if setting.print.individual==true or setting.print.total==true then
            s = s .. "    " .. string.char(9679) .. "    "
        end
    end

    --Assemble values into table and order
    if setting.print.individual==true or setting.print.total==true then
        --Get values in table
        for _, die in ipairs(spawnedDice) do
            if die ~= nil then
                table.insert(valueTable, tostring(die.getRotationValue()))
            end
        end
        --Order them
        alphanumsort(valueTable)
    end

    --Individual values
    if setting.print.individual == true then
        --Add values to string
        for i, value in ipairs(valueTable) do
            s = s .. value
            if i < #valueTable then
                s = s .. ", "
            end
        end
        if setting.print.total==true then
            s = s .. "    " .. string.char(9679) .. "    "
        end
    end

    --Total (will be void if there are no numbers)
    if setting.print.total == true then
        local total, hadNumber = 0, false
        for _, value in ipairs(valueTable) do
            if tonumber(value) ~= nil then
                total = total + tonumber(value)
                hadNumber = true
            end
        end
        if hadNumber == true then
            s = s .. tostring(total)
        else
            s = s .. "---"
        end
    end

    --Establish color
    local stringColor = {1,1,1}
    if setting.print.playerColor == true then
        stringColor = stringColorToRGB(color)
    end
    --Broadcast result
    broadcastToAll(s, stringColor)
end



--Coop communication



--Updates global rolling table with its information
function updateGlobalTable(color)
    if setting.coop==true then
        local currentTable = Global.getTable("UCR_communication")
        if currentTable == nil then
            Global.setTable("UCR_communication", {[self]=color})
        else
            currentTable[self] = color
            Global.setTable("UCR_communication", currentTable)
        end
    end
end

--Updates roll timers for all devices currently rolling
function updateRollTimers(color)
    if setting.coop==true then
        local currentTable = Global.getTable("UCR_communication")
        if currentTable != nil then
            for who, c in pairs(currentTable) do
                if who~=self and c==color then
                    who.call("rollTimerUpdate", {color=color})
                end
            end
        end
    end
end

--Check if any other roller is rolling
function areOtherRollersRolling(color)
    if setting.coop==true then
        local currentTable = Global.getTable("UCR_communication")
        if currentTable == nil then
            --If there is no table in global
            return false
        else
            --If there is, check the contents
            for who, c in pairs(currentTable) do
                --Check if the entry is for this color (and not self)
                if who~=self and c==color then
                    --Check for if the other object is still rolling
                    if who.getVar("rollingHasStopped") ~= true then
                        return true
                    end
                end
            end
        end
        return false
    else
        return false
    end
end

--Check if any other roller is rolling
function anyRollInProgress(color)
    if setting.coop==true then
        local currentTable = Global.getTable("UCR_communication")
        if currentTable == nil then
            --If there is no table in global
            return false
        else
            --If there is, check the contents
            for who, c in pairs(currentTable) do
                --Check if the entry is for this color (and not self)
                if who~=self and c==color then
                    --Check for if the other object is still rolling
                    if who.getVar("rollInProgress") ~= nil then
                        return true
                    end
                end
            end
        end
        return false
    else
        return false
    end
end

--Activate the finalize step on all dice of this color
function finalizeCoopRolls(color)
    if setting.coop==true then
        local currentTable = Global.getTable("UCR_communication")
        if currentTable != nil then
            for who, c in pairs(currentTable) do
                if c==color then
                    who.call("finalizeRoll", {color=color})
                end
            end
        end
    end
end

--Combines all spawnedDice tables from all coop rollers
function addAllSpawnedDice(color)
    if setting.coop==true then
        local currentTable = Global.getTable("UCR_communication")
        if currentTable != nil then
            for who, c in pairs(currentTable) do
                if who~=self and c==color then
                    theirSpawnedDice = who.getTable("spawnedDice")
                    if theirSpawnedDice ~= nil then
                        for _, die in ipairs(theirSpawnedDice) do
                            table.insert(spawnedDice, die)
                        end
                    end
                end
            end
        end
    end
end



--Utility functions



--Finds a local point an an arc, given which point and the total # of points
function getLocalPointOnArc(i, points)
    --This evens it out
    i = i - 0.5
    --What the length of arc this points at (how far along an arc)
    local angle = setting.arc/(points)
    --How much to rotate the angle around the tool
    local offset = -setting.arc/2 + setting.rotation
    --Converting those 2 elements into a local position
    local x = math.sin( math.rad(angle*i+offset) ) * setting.radius
    local y = setting.height
    local z = math.cos( math.rad(angle*i+offset) ) * setting.radius
    return {x=x,y=y,z=z}
end

--Gets a random rotation vector
function randomRotation()
    --Credit for this function goes to Revinor (forums)
    --Get 3 random numbers
    local u1 = math.random();
    local u2 = math.random();
    local u3 = math.random();
    --Convert them into quats to avoid gimbal lock
    local u1sqrt = math.sqrt(u1);
    local u1m1sqrt = math.sqrt(1-u1);
    local qx = u1m1sqrt *math.sin(2*math.pi*u2);
    local qy = u1m1sqrt *math.cos(2*math.pi*u2);
    local qz = u1sqrt *math.sin(2*math.pi*u3);
    local qw = u1sqrt *math.cos(2*math.pi*u3);
    --Apply rotation
    local ysqr = qy * qy;
    local t0 = -2.0 * (ysqr + qz * qz) + 1.0;
    local t1 = 2.0 * (qx * qy - qw * qz);
    local t2 = -2.0 * (qx * qz + qw * qy);
    local t3 = 2.0 * (qy * qz - qw * qx);
    local t4 = -2.0 * (qx * qx + ysqr) + 1.0;
    --Correct
    if t2 > 1.0 then t2 = 1.0 end
    if t2 < -1.0 then ts = -1.0 end
    --Convert back to X/Y/Z
    local xr = math.asin(t2);
    local yr = math.atan2(t3, t4);
    local zr = math.atan2(t1, t0);

    return {math.deg(xr),math.deg(yr),math.deg(zr)}
end

--Coroutine delay, in seconds
function wait(time)
    local start = os.time()
    repeat coroutine.yield(0) until os.time() > start + time
end

--Sorts numbers/strings alphabeticall (does not handle decimals or leading 0s)
function alphanumsort(o)
    local function padnum(d) return ("%03d%s"):format(#d, d) end
    table.sort(o, function(a,b)
    return tostring(a):gsub("%d+",padnum) < tostring(b):gsub("%d+",padnum) end)
    return o
end



--Button creation



--Spawns the roll button or the "display roll locations" for setup mode
function createButtons()
    if setting.setup ~= true then
        self.createButton({
            click_function="click_roll", function_owner=self,
            position={0,0.05,0}, height=650, width=650, color={1,1,1,0}
        })
    else
        for i=1, math.ceil(setting.arc/30) do
            local pos_local = getLocalPointOnArc(i, math.ceil(setting.arc/30))
            self.createButton({
                click_function="none", function_owner=self,
                position=pos_local, height=0, width=0, label=string.char(9673),
                font_size=1000, font_color={0.5,0.5,0.5}
            })
        end
    end
end