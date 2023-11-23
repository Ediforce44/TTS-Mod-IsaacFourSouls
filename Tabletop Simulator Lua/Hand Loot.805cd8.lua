--- Hand counter by Schokolabbi
owner_color = "Red"
value = 0
--- Edited by Ediforce44
LOOT_DECK_ZONE_GUID = Global.getTable("ZONE_GUID_DECK").LOOT
COUNTER_MODULE = nil

--- Click delay time in seconds
options = {["clickDelay"] = Global.getVar("CLICK_DELAY")}

clickCounter = 0

doubleClickParameters = {
    ["identifier"] = "ClickTimer" .. self.guid,
    ["function_name"] = "resetClickCounter",
    ["delay"] = options.clickDelay,
}

function onSave()
    return JSON.encode({ownerColor = owner_color, value = value})
end

function onLoad(saved_data)
    COUNTER_MODULE = getObjectFromGUID(Global.getVar("COUNTER_MODULE_GUID"))
    
    if saved_data == "" then
        setOwner(nil)
    else
        local loaded_data = JSON.decode(saved_data)
        if loaded_data.ownerColor then
            setOwner(loaded_data.ownerColor)
        end
        if loaded_data.value then
            value = loaded_data.value
        end
    end

    local ttText = "[b]Handcard Counter[/b][i]\nLeft-Click: Increase\nRight-Click: Decrease[/i]"

    self.createInput({
        value = "Loot",
        input_function = "dummy",
        label = "Counter",
        function_owner = self,
        tooltip = ttText,
        alignment = 3,
        position = {0,0.05,1},
        width = 1000,
        height = 320,
        font_size = 280,
        scale={x=1, y=1, z=1},
        font_color= {255,255,255,100},
        color = {0,0,0,0}
        })

    self.createButton({
        label=tostring(value),
        click_function="onClick",
        function_owner=self,
        tooltip=ttText,
        position={0,0.05,0},
        height=600,
        width=1000,
        font_size=700,
        font_color={1,1,1,95},
        scale={1,1,1},
        color={0,0,0,0}
    })
end

function onObjectEnterZone(zone)
    local handInfo = Global.call("getHandInfo")[owner_color]
    if zone.getGUID() == handInfo.guid then
        local newValue = #Player[handInfo.owner].getHandObjects(handInfo.index)
        if newValue ~= value then
            value = newValue
            COUNTER_MODULE.call("notifyHANDCARD", {player = owner_color, value = value})
            self.editButton({index=0, label=value})
        end
    end
end

function onObjectLeaveZone(zone)
    local handInfo = Global.call("getHandInfo")[owner_color]
    if zone.getGUID() == handInfo.guid then
        local newValue = #Player[handInfo.owner].getHandObjects(handInfo.index)
        if newValue ~= value then
            value = newValue
            COUNTER_MODULE.call("notifyHANDCARD", {player = owner_color, value = value})
            self.editButton({index=0, label=value})
        end
    end
end

function findOwner(color)
    if not Global.call("isPlayerAuthorized", {playerColor = color, ownerColor = owner_color}) then return end         --EbyE44
    --[[if clickCounter == 0 then
        Timer.create(doubleClickParameters)
    end
    if isDoubleClick() then
        setOwner(nil)
    elseif not owner_color and (color == "Red" or color == "Blue" or color == "Green" or color == "Yellow") then      --EbyE44
        setOwner(color)
    end]]
    --Delete this if you want to use the owner funtion
    drawLootCard()
end

function onPickedUp(color)
    findOwner(color)
end

function onClick(object, color)
    findOwner(color)
end

function resetClickCounter()
    if clickCounter == 1 then
        drawLootCard()    --EbyE44
    end
    clickCounter = 0
end

function drawLootCard()    --EbyE44
    if owner_color == nil then
        Global.call("printWarning", {text = "Wrong color. Choose a player color and try it again."})
        return
    end
    getObjectFromGUID(LOOT_DECK_ZONE_GUID).call("dealLootCard", {playerColor = owner_color})
end

-- This function is disabled
function isDoubleClick()
    clickCounter = clickCounter + 1
    return false --clickCounter > 1
end

function setOwner(color)
    if color then
        owner_color = color
        local handInfo = Global.call("getHandInfo")[owner_color]
        value = #Player[handInfo.owner].getHandObjects(handInfo.index)
        --self.setName(value)
    else
        owner_color = nil
        color = "Grey"
        value = 0
        --self.setName("Card Counter - Click to claim!")
    end
    local rgbColorTable = stringColorToRGB(color)
    self.setColorTint(rgbColorTable)
end

function dummy()
end