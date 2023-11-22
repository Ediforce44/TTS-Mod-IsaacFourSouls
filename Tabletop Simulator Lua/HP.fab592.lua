--- Edited by Ediforce44
zone = getObjectFromGUID(Global.getTable("ZONE_GUID_MONSTER").THREE)

value = 0
MIN_VALUE = 0
MAX_VALUE = 99

function updateHP(params)
    local newValue = params.HP
    if newValue ~= nil and newValue >= MIN_VALUE and newValue <= MAX_VALUE then
        value = newValue
        updateValue()
    end
end

function modifyHP(params)            -- EbyE44
    if params.modifier == nil then
        Global.call("printWarning", {text = "Wrong parameters in HP counter function 'modifyHP()'."})
    end
    updateHP({HP = value + params.modifier})
end

function reset()
    --Only resets HP-Counter, if the active monster has a HP attribute
    if zone.getTable("active_monster_attrs").HP ~= 0 then
        value = zone.getTable("active_monster_attrs").HP
        updateValue()
    end
end

local function createAll()
    local ttText = "[b]HP Counter[/b][i]\nLeft-Click: Increase\nRight-Click: Decrease[/i]"

    self.createButton({
      label=tostring(value),
      click_function="add_subtract",
      tooltip=ttText,
      function_owner=self,
      position={0,0.05,-0.2},
      height=600,
      width=1000,
      alignment = 3,
      scale={x=1.5, y=1.5, z=1.5},
      font_size=600,
      font_color={1,1,1,95},
      color={0,0,0,0}
      })

    self.createInput({
        value = self.getName(),
        input_function = "dummy",
        tooltip=ttText,
        label = "Counter",
        function_owner = self,
        alignment = 3,
        position = {0,0.05,1.5},
        width = 1200,
        height = 1000,
        font_size = 400,
        scale={x=1, y=1, z=1},
        font_color={1,1,1,95},
        color = {0,0,0,0}
        })
end

function onLoad(saved_data)
    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        if loaded_data.value then
            value = loaded_data.value
        end
    end

    createAll()
end

function onSave()
    return JSON.encode({value = value})
end

function removeAll()
    self.removeInput(0)
    self.removeButton(0)
end

function reloadAll()
    removeAll()
    createAll()
end

function add_subtract(_obj, _color, alt_click)
    mod = alt_click and -1 or 1
    new_value = math.min(math.max(value + mod, MIN_VALUE), MAX_VALUE)
    if value ~= new_value then
        if value == 0 then
            zone.call("monsterReanimated")
        end

        value = new_value

        if new_value == 0 then
            zone.call("monsterDied")
        end
        updateValue()
    end
end

function updateValue()
    self.editButton({
        index = 0,
        label = tostring(value),
        })
end

function reset_val()
    value = 0
    updateValue()
end

function dummy()
end