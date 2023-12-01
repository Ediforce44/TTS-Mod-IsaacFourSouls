MIN_VALUE = -99
MAX_VALUE = 999

value = 0
manual_mod = 0

local function updateValue()
    self.editButton({
        index = 0,
        label = tostring(value),
        })
end

local function createAll()
    local ttText = "[b]Counter[/b]\n[i]Left click: Increase[/i]\n[i]Right click: Decrease[/i]"

    self.createButton({
      label=tostring(value),
      click_function="add_subtract",
      tooltip=ttText,
      function_owner=self,
      position={0,0.06,-0.4},
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
      input_function="dummy",
      function_owner=self,
      tooltip=ttText,
      label = "Counter",
      alignment = 3,
      position = {0,0.06,1.4},
      width = 1500,
      height = 1000,
      font_size = 200,
      scale={x=1, y=1, z=1},
      font_color= {1,1,1,95},
      color = {0,0,0,0}
      })
end

function add_subtract(_obj, _color, alt_click)
    mod = alt_click and -1 or 1
    manual_mod = manual_mod + mod
    new_value = math.min(math.max(value + mod, MIN_VALUE), MAX_VALUE)
    if value ~= new_value then
        value = new_value
        updateValue()
    end
end

function onLoad(saved_data)
    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        if loaded_data then
            if loaded_data.value then
                value = loaded_data.value
            end
            if loaded_data.manualMod then
                manual_mod = loaded_data.manualMod
            end
        end
    end

    createAll()
end

function onSave()
    return JSON.encode({value = value, manualMod = manual_mod})
end

function dummy()
end

-----------------------------------------------------------------------------------------------------------------------
------------------------------------------------- External functions --------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
function modifyCounter(params)
    if params.modifier == nil then
        Global.call("printWarning", {text = "Wrong parameters in coin counter function 'modifyCounter()'."})
    end
    new_value = math.min(math.max(value + params.modifier, MIN_VALUE), MAX_VALUE)
    if value ~= new_value then
        value = new_value
        updateValue()
    end
end

function setCounter(params)
    if params.value == nil then
        Global.call("printWarning", {text = "Wrong parameters in coin counter function 'setCounter()'."})
        return
    end
    new_value = math.min(math.max(params.value + manual_mod, MIN_VALUE), MAX_VALUE)
    if value ~= new_value then
        value = new_value
        updateValue()
    end
end

function changeName(params)
    if (not params) or (not params.name) then
        return
    end

    local newName = tostring(params.name)
    local ttText = "[b]" .. string.gsub(newName, "\n", " ") .. "[/b]\n[i]Left click - Increase[/i]\n[i]Right click - Decrease[/i]"
    self.setName(newName)

    self.editInput({
        index = 0,
        value = newName,
        tooltip = ttText
    })
    self.editButton({
        index = 0,
        tooltip = ttText
    })
end

function removeAll()
    self.removeInput(0)
    self.removeButton(0)
end

function reloadAll()
    removeAll()
    createAll()
end

function onDestroy()
    local counterModule = getObjectFromGUID(Global.getVar("COUNTER_MODULE_GUID"))
    if counterModule then
        counterModule.call("removeCounter", {guid = self.getGUID()})
    end
end