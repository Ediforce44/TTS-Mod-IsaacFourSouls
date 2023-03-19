-- Edited by Ediforce44
owner_color = "Blue"
value = 0

MIN_VALUE = 0
MAX_VALUE = 999

SYNCED_COIN_COUNTER_GUIDS = {}

function onload(saved_data)
    value = 0

    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        if loaded_data.value then
            value = loaded_data.value
        end
        if loaded_data.syncedCounter then
            SYNCED_COIN_COUNTER_GUIDS = loaded_data.syncedCounter
        end
    end
    createAll()
end

function onSave()
    return JSON.encode({value = value, syncedCounter = SYNCED_COIN_COUNTER_GUIDS})
end

function syncCounter(syncedCounterGuids)
    for color, guid in pairs(syncedCounterGuids) do
        if getObjectFromGUID(guid) and (guid ~= self.getGUID()) then
            SYNCED_COIN_COUNTER_GUIDS[color] = guid
        end
    end
end

function setCoins(params)
    if params.newValue then
        new_value = math.min(math.max(params.newValue, MIN_VALUE), MAX_VALUE)
        if value ~= new_value then
            value = new_value
            updateVal()
        end
    end
end

function modifyCoins(params)            -- EbyE44
    if params.modifier == nil then
        Global.call("printWarning", {text = "Wrong parameters in coin counter function 'modifyCoins()'."})
    end
    setCoins({newValue = value + params.modifier})
end

function createAll()
    s_color = {0.5, 0.5, 0.5, 95}
    f_color = {1,1,1,95}

    if self.getName() == "" then
        ttText = value
    else
        ttText = value .. "\n" .. self.getName()
    end

    self.createButton({
      label=tostring(value),
      click_function="add_subtract",
      tooltip=ttText,
      function_owner=self,
      position={0,0.05,-0.2},
      height=650,
      width=1000,
      alignment = 3,
      scale={x=1, y=1, z=1},
      font_size=700,
      font_color=f_color,
      color={0,0,0,0}
      })

    self.createInput({
        value = self.getName(),
        input_function = "editName",
        tooltip = ttText,
        label = "Counter",
        function_owner = self,
        alignment = 3,
        position = {0,0.05,1},
        width = 1000,
        height = 320,
        font_size = 280,
        scale={x=1, y=1, z=1},
        font_color= f_color,
        color = {0,0,0,0}
        })

    setTooltips()
end

function removeAll()
    self.removeInput(0)
    self.removeInput(1)
    self.removeButton(0)
    self.removeButton(1)
    self.removeButton(2)
end

function reloadAll()
    removeAll()
    createAll()
    setTooltips()
    updateSave()
end

function editName(_obj, _string, editValue)
    self.setName(editValue)
    setTooltips()
end

function add_subtract(_obj, color, alt_click)
    if not Global.call("isPlayerAuthorized", {playerColor = color, ownerColor = owner_color}) then
        return
    end
    mod = alt_click and -1 or 1
    setCoins({newValue = value + mod})
end

function updateVal()
    if self.getName() == "" then
        ttText = value
    else
        ttText = value .. "\n" .. self.getName()
    end
    self.editButton({
        index = 0,
        label = tostring(value),
        tooltip = ttText
        })
    for _, guid in pairs(SYNCED_COIN_COUNTER_GUIDS) do
        local coinCounter = getObjectFromGUID(guid)
        if coinCounter then
            coinCounter.call("setCoins", {newValue = value})
        end
    end
end

function reset_val()
    value = 0
    updateVal()
end

function setTooltips()
    self.editInput({
        index = 0,
        value = self.getName(),
        tooltip = ttText
        })
    self.editButton({
        index = 0,
        value = tostring(value),
        tooltip = ttText
        })
end

function onScriptingButtonDown(index, playerColor)
    if Player[playerColor].getHoverObject() == self then

        if index == 1 then
            new_value = math.min(math.max(value - 5, MIN_VALUE), MAX_VALUE)
        end
        if index == 2 then
            new_value = math.min(math.max(value + 5, MIN_VALUE), MAX_VALUE)
        end
        if index == 4 then
            new_value = math.min(math.max(value - 10, MIN_VALUE), MAX_VALUE)
        end
        if index == 5 then
            new_value = math.min(math.max(value + 10, MIN_VALUE), MAX_VALUE)
        end
        if value ~= new_value then
            value = new_value
            updateVal()
        end
    end
end