--- Edited by Ediforce44
TURN_BUTTON_COUNT = 0
TURN_BUTTON_INDICES = {}
TURN_INPUT_INDICES = {}

local secondTurnButtonsDisabled = false

local startPositions = {Vector(-2, 1, 9.4), Vector(1.6, 1, -9.4)}

local function createTurnInputs()
    self.createInput({
        value = "Starting Turn",
        input_function = "dummy",
        function_owner = self,
        alignment = 3,
        position = startPositions[1] + Vector(2, 0, -0.7),
        rotation = {0, 0, 0},
        width = 1500,
        height = 320,
        font_size = 250,
        scale = {x=1, y=1, z=1},
        font_color = {1, 1, 1, 100},
        color = {0,0,0,0}
        })
    TURN_INPUT_INDICES[1] = 1
    self.createInput({
        value = "Starting Turn",
        input_function = "dummy",
        function_owner = self,
        alignment = 3,
        position = startPositions[2] + Vector(-2, 0, 0.7),
        rotation = {0, 180, 0},
        width = 1500,
        height = 320,
        font_size = 250,
        scale = {x=1, y=1, z=1},
        font_color = {1, 1, 1, 100},
        color = {0,0,0,0}
        })
    TURN_INPUT_INDICES[2] = 2
end

local function createTurnButtons()
    local buttonCount = 0
    for _, playerColor in pairs(Global.getTable("PLAYER")) do
        TURN_BUTTON_INDICES[playerColor] = {}
        self.createButton({
            click_function = "onClick" .. playerColor .. "Btn",
            function_owner = self,
            label          = "",
            position       = startPositions[1],
            width          = 300,
            height         = 300,
            color          = Global.getTable("REAL_PLAYER_COLOR_RGB")[playerColor],
            tooltip        = "[b]" .. playerColor .. "'s Turn[/b]"
        })
        buttonCount = buttonCount + 1
        TURN_BUTTON_INDICES[playerColor][1] = buttonCount
        self.createButton({
            click_function = "onClick" .. playerColor .. "Btn",
            function_owner = self,
            label          = "",
            position       = startPositions[2],
            rotation       = {0, 180, 0},
            width          = 300,
            height         = 300,
            color          = Global.getTable("REAL_PLAYER_COLOR_RGB")[playerColor],
            tooltip        = "[b]" .. playerColor .. "'s Turn[/b]"
        })
        buttonCount = buttonCount + 1
        TURN_BUTTON_INDICES[playerColor][2] = buttonCount
        startPositions[1][1] = startPositions[1][1] + 0.8
        startPositions[2][1] = startPositions[2][1] - 0.8
    end
    TOTAL_BUTTON_COUNT = buttonCount
end

function onLoad(saved_data)
  createTurnInputs()
  createTurnButtons()

  if saved_data ~= "" then
      local loaded_data = JSON.decode(saved_data)
      if loaded_data.selectedButtonIndices then
          for _ , index in ipairs(loaded_data.selectedButtonIndices) do
              self.editButton({index=index, label="✓", font_color={0, 0, 0}, font_size=200})
          end
      end
      if loaded_data.secondTurnButtonsDisabled then
          deactivateSecondTurnButtons()
      end
  end
end

function onSave()
    local selectedButtonIndices = {}
    local allButtons = self.getButtons()
    for index = 1, TURN_BUTTON_COUNT do
        if allButtons[index].label ~= "" then
            table.insert(selectedButtonIndices, index-1)
        end
    end
    return JSON.encode({selectedButtonIndices = selectedButtonIndices, secondTurnButtonsDisabled = secondTurnButtonsDisabled})
end

function deactivateSecondTurnButtons()
    local buttons = self.getButtons()
    for _, indexTable in pairs(TURN_BUTTON_INDICES) do
        self.editButton({index = indexTable[2] - 1, position = buttons[indexTable[2]].position:setAt('y', -2)})
    end
    local inputs = self.getInputs()
    self.editInput({index = TURN_INPUT_INDICES[2] - 1, position = inputs[TURN_INPUT_INDICES[2]].position:setAt('y', -2)})
    secondTurnButtonsDisabled = true
end

function onClickRedBtn()
  Global.call("setNewStartPlayer", {playerColor = "Red"})
end

function onClickBlueBtn()
  Global.call("setNewStartPlayer", {playerColor = "Blue"})
end

function onClickGreenBtn()
  Global.call("setNewStartPlayer", {playerColor = "Green"})
end

function onClickYellowBtn()
  Global.call("setNewStartPlayer", {playerColor = "Yellow"})
end

function onClickWhiteBtn()
  Global.call("setNewStartPlayer", {playerColor = "White"})
end

function onClickPurpleBtn()
  Global.call("setNewStartPlayer", {playerColor = "Purple"})
end

function onClickTealBtn()
  Global.call("setNewStartPlayer", {playerColor = "Teal"})
end

function onClickPinkBtn()
  Global.call("setNewStartPlayer", {playerColor = "Pink"})
end

function selectStartTurn(params)
  if params.playerColor == nil then
    Global.call("printWarning", {text = "Wrong parameters in starting turn function 'selectStartTurn()'."})
    return
  end

  -- Remove select marker btn if exist
  for indexColor, indices in pairs(TURN_BUTTON_INDICES) do
    if indexColor ~= params.playerColor then
      for _, index in ipairs(indices) do
        self.editButton({index=index-1, label=""})
      end
    end
  end

  -- Create select marker btn
  for _ , index in ipairs(TURN_BUTTON_INDICES[params.playerColor]) do
    self.editButton({index=index-1, label="✓", font_color={0, 0, 0}, font_size=200})
  end
end

function dummy() end