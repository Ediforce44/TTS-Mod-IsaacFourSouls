MIN_VALUE = -5
MAX_VALUE = 5

function onload(saved_data)
    light_mode = false
    val = 0

    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        light_mode = loaded_data[1]
        val = loaded_data[2]
    end

    createAll()
end

function updateSave()
    local data_to_save = {light_mode, val}
    saved_data = JSON.encode(data_to_save)
    self.script_state = saved_data
end

function createAll()
    s_color = {0.5, 0.5, 0.5, 95}

    if light_mode then
        f_color = {1,1,1,100}
    else
        f_color = {1,1,1,100}
    end

    if self.getName() == "" then
        ttText = val
    else
        ttText = val .. "\n" .. self.getName()
    end

    self.createButton({
      label=tostring(val),
      click_function="add_subtract",
      tooltip=ttText,
      function_owner=self,
      position={0,0.05,-0.2},
      height=600,
      width=1000,
      alignment = 3,
      scale={x=1, y=1, z=1},
      font_size=600,
      font_color=f_color,
      color={0,0,0,0}
      })

    self.createInput({
        value = self.getName(),
        input_function = "editName",
        tooltip=ttText,
        label = "Counter",
        function_owner = self,
        alignment = 3,
        position = {0,0.05,0.75},
        width = 1200,
        height = 300,
        font_size = 200,
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

function swap_fcolor(_obj, _color, alt_click)
    light_mode = not light_mode
    reloadAll()
end

function swap_align(_obj, _color, alt_click)
    center_mode = not center_mode
    reloadAll()
end

function editName(_obj, _string, value)
    self.setName(value)
    setTooltips()
end

function add_subtract(_obj, _color, alt_click)
    mod = alt_click and -1 or 1
    new_value = math.min(math.max(val + mod, MIN_VALUE), MAX_VALUE)
    if val ~= new_value then
        val = new_value
        updateVal()
        updateSave()
    end
end

function updateVal()
    if self.getName() == "" then
        ttText = val
    else
        ttText = val .. "\n" .. self.getName()
    end
    self.editButton({
        index = 0,
        label = tostring(val),
        tooltip = ttText
        })
end

function reset_val()
    val = 0
    updateVal()
    updateSave()
end

function setTooltips()
    self.editInput({
        index = 0,
        value = self.getName(),
        tooltip = ttText
        })
    self.editButton({
        index = 0,
        value = tostring(val),
        tooltip = ttText
        })
end

function null()
end

function keepSample(_obj, _string, value)
    reloadAll()
end