--- Hand counter by Schokolabbi
owner_color = "Red"
value = 0
--- Edited by Ediforce44
LOOT_DECK_ZONE_GUID = Global.getTable("ZONE_GUID_DECK").LOOT
COUNTER_MODULE = nil

function onSave()
    return JSON.encode({ownerColor = owner_color, value = value})
end

function onLoad(saved_data)
    COUNTER_MODULE = getObjectFromGUID(Global.getVar("COUNTER_MODULE_GUID"))

    if saved_data then
        local loaded_data = JSON.decode(saved_data)
        if loaded_data.ownerColor then
            owner_color = loaded_data.ownerColor
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
    drawLootCard()
end

function onClick(object, color)
    findOwner(color)
end

function drawLootCard()    --EbyE44
    if owner_color == nil then
        Global.call("printWarning", {text = "Wrong color. Choose a player color and try it again."})
        return
    end
    getObjectFromGUID(LOOT_DECK_ZONE_GUID).call("dealLootCard", {playerColor = owner_color})
end

function dummy()
end