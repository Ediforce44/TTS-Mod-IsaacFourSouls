SWAP_I_BUTTON_INDEX = 5
SWAP_I_STATE = {
    NORMAL = "NORMAL",
    OPTIONAL = "OPTIONAL"
}
SWAP_I_NAME = {
    NORMAL = "Optional Setup",
    OPTIONAL = "Normal Setup"
}
SWAP_I_TITLE = {
    NORMAL = SWAP_I_NAME[SWAP_I_STATE.OPTIONAL],
    OPTIONAL = SWAP_I_NAME[SWAP_I_STATE.NORMAL]
}
SWAP_I_TOOLTIP = {
    NORMAL = "Click to see the optional setup instructions before you hit the Start button.",
    OPTIONAL = "Click to see the normal setup instructions again."
}
SWAP_I_TEXT = {
    NORMAL =
[[0) Every player selects a Player Color.

1) Select the language on the left side.

2) Press "Randomize to All" on the right side under the Character Randomizer.

3) When everyone has selected a character, press the 'Start' button."]],

    OPTIONAL =
[[- Select an expansions by dropping it (red bag) in the playing area.

- To place the characters from the selected expansions press the "Place Characters (Playing area)" button beneath the Character Placer.
    - OR: Take out the brown character bags from the expansions and use the Character Placer manually.

- Select the player, who should go first (for example with the "Who goes first" die on the left side).]]
}

function onload(saved_data)
    f_size = 200
    light_mode = false
    center_mode = false
    tooltip_show = true

    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        light_mode = loaded_data[1]
        center_mode = loaded_data[2]
        tooltip_show = loaded_data[3]
    end

    self.setName(SWAP_I_TITLE[SWAP_I_STATE.NORMAL])
    self.setDescription(SWAP_I_TEXT[SWAP_I_STATE.NORMAL])

    createAll()
end

function updateSave()
    local data_to_save = {light_mode, center_mode, tooltip_show}
    saved_data = JSON.encode(data_to_save)
    self.script_state = saved_data
end

function createAll()
    s_color = {0.5, 0.5, 0.5, 95}

    if light_mode then
        f_color = {1,1,1,95}
    else
        f_color = {0,0,0,95}
    end

    if center_mode then
        f_align = 3
    else
        f_align = 1
    end

    if tooltip_show then
        ttText = self.getName() .. "\n----------\n" .. self.getDescription()
    else
        ttText = ""
    end

    self.createInput({
        value = self.getName(),
        input_function = "editName",
        label = "Notecard",
        function_owner = self,
        alignment = 3,
        position = {0,0.05,-1},
        width = 1800,
        height = 300,
        font_size = 160,
        scale={x=1, y=1, z=1},
        font_color= {1,1,1,100},
        color = {0,0,0,0},
        tooltip = ttText
        })

    self.createInput({
        value = self.getDescription(),
        label = "\nClick and type here\n\nFlip for settings",
        input_function = "editDesc",
        function_owner = self,
        alignment = f_align,
        position = {0,0.05,0.28},
        width = 1800,
        height = 900,
        font_size = 80,
        scale={x=1, y=1, z=1},
        font_color={1,1,1,100},
        color = {0,0,0,0},
        tooltip = ttText
        })

    self.createButton({
        label="How to restart",
        tooltip="How to restart",
        click_function="null",
        function_owner=self,
        position={0,-0.05,-1.1},
        rotation={180,180,0},
        height=300,
        width=800,
        scale={x=1, y=1, z=1},
        font_size=140,
        font_color=s_color,
        color={0,0,0,0}
        })

    if light_mode then
        lightButtonText = "[ Set dark text ]"
    else
        lightButtonText = "[ Set light text ]"
    end
    self.createButton({
        label=lightButtonText,
        tooltip=lightButtonText,
        click_function="swap_fcolor",
        function_owner=self,
        position={0,-0.05,-0.5},
        rotation={180,180,0},
        height=250,
        width=800,
        scale={x=1, y=1, z=1},
        font_size=100,
        font_color=s_color,
        color={0,0,0,0}
        })

    if center_mode then
        centerButtonText = "[ Set left align ]"
    else
        centerButtonText = "[ Set center align ]"
    end
    self.createButton({
        label=centerButtonText,
        tooltip=centerButtonText,
        click_function="swap_align",
        function_owner=self,
        position={0,-0.05,0},
        rotation={180,180,0},
        height=250,
        width=800,
        scale={x=1, y=1, z=1},
        font_size=100,
        font_color=s_color,
        color={0,0,0,0}
        })

    if tooltip_show then
        tooltipShowText = "[ Hide description in tooltip ]"
    else
        tooltipShowText = "[ Show description in tooltip ]"
    end
    self.createButton({
        label=tooltipShowText,
        tooltip=tooltipShowText,
        click_function="swap_tooltip",
        function_owner=self,
        position={0,-0.05,0.5},
        rotation={180,180,0},
        height=250,
        width=800,
        scale={x=1, y=1, z=1},
        font_size=100,
        font_color=s_color,
        color={0,0,0,0}
        })

    self.createInput({
        value = "Sample Text",
        label = "...",
        input_function = "keepSample",
        function_owner = self,
        alignment = f_align,
        position={0,-0.05,1.1},
        rotation={180,180,0},
        width = 1800,
        height = 250,
        font_size = 120,
        scale={x=1, y=1, z=1},
        font_color=f_color,
        color = {0,0,0,0}
        })

    self.createButton({
        label= SWAP_I_NAME.NORMAL,
        tooltip= SWAP_I_TOOLTIP.NORMAL,
        click_function="swap_instructions",
        function_owner=self,
        position={1.6,0.05,1.3},
        height=150,
        width=600,
        scale={x=1, y=1, z=1},
        font_size=80,
        font_color= {1,1,1},
        color = {0.2,0.2,0.2}
        })

    setTooltips()
end

function removeAll()
    self.removeInput(0)
    self.removeInput(1)
    self.removeInput(2)
    self.removeButton(0)
    self.removeButton(1)
    self.removeButton(2)
    self.removeButton(3)
    self.removeButton(4)
end

function reloadAll()
    removeAll()
    createAll()
    setTooltips()
    updateSave()
end

function update_fcolor()
end

function swap_fcolor(_obj, _color, alt_click)
    light_mode = not light_mode
    reloadAll()
end

function swap_align(_obj, _color, alt_click)
    center_mode = not center_mode
    reloadAll()
end

function swap_tooltip(_obj, _color, alt_click)
    tooltip_show = not tooltip_show
    reloadAll()
    setTooltips()
end

function swap_instructions(_, _, _)
    local currentState = self.getButtons()[SWAP_I_BUTTON_INDEX].label
    local newState = SWAP_I_STATE.NORMAL

    if currentState == SWAP_I_NAME[SWAP_I_STATE.NORMAL] then
        newState = SWAP_I_STATE.OPTIONAL
    elseif currentState == SWAP_I_NAME[SWAP_I_STATE.OPTIONAL] then
        newState = SWAP_I_STATE.NORMAL
    else
        return
    end

    self.editButton({index = SWAP_I_BUTTON_INDEX - 1, label = SWAP_I_NAME[newState], tooltip = SWAP_I_TOOLTIP[newState]})

    self.setName(SWAP_I_TITLE[newState])
    self.setDescription(SWAP_I_TEXT[newState])
    setTooltips()
end

function editName(_obj, _string, value)
    self.setName(value)
    setTooltips()
end

function editDesc(_obj, _string, value)
    self.setDescription(value)
    setTooltips()
end

function setTooltips()
    title = self.getName()
    if title == "" then
        title = "Notecard"
    end
    desc = self.getDescription()

    if tooltip_show then
        ttText = title .. "\n----------\n" .. desc
    else
        ttText = ""
    end

    self.editInput({
        index = 0,
        value = title,
        tooltip = ttText
        })
    self.editInput({
        index = 1,
        value = desc,
        tooltip = ttText
        })
end

function null()
end

function keepSample(_obj, _string, value)
    reloadAll()
end