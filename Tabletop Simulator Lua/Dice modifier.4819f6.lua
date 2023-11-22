MIN_VALUE = -5
MAX_VALUE = 5

value = 0

local function createAll()
    local ttText = "[b]Dice Modifier[/b][i]\nLeft-Click: Increase\nRight-Click: Decrease[/i]"

    self.createButton({
      label=tostring(value),
      click_function="add_subtract",
      tooltip=ttText,
      function_owner=self,
      position={0,0.05,-0.2},
      height=600,
      width=1000,
      alignment = 3,
      scale={x=1, y=1, z=1},
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
        position = {0,0.05,0.75},
        width = 1200,
        height = 300,
        font_size = 200,
        scale={x=1, y=1, z=1},
        font_color= {1,1,1,95},
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
        value = new_value
        updateValue()
    end
end

function updateValue()
    self.editButton({
        index = 0,
        label = tostring(value),
        })
end

function dummy()
end