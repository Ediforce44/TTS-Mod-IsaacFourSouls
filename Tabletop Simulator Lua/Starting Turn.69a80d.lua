--- Edited by Ediforce44
TURN_BUTTON_COUNT = 8
TURN_BUTTON_INDICES = {
    Red = {1,5},
    Blue = {2,6},
    Green = {3,7},
    Yellow = {4,8}
}
TURN_INPUT_INDICES = {1, 2}

local secondTurnButtonsDisabled = false

local function createTurnButtons()
    self.createButton({
      click_function = "onClickRedBtn",
      function_owner = self,
      label          = "",
      position       = {-1.2, 1, 5},
      width          = 300,
      height         = 300,
      color          = {0.85, 0.1, 0.09},
      tooltip        = "[b]Red Turn[/b]"
    })
    self.createButton({
      click_function = "onClickBlueBtn",
      function_owner = self,
      label          = "",
      position       = {-0.4, 1, 5},
      width          = 300,
      height         = 300,
      color          = {0.12, 0.53, 1},
      tooltip        = "[b]Blue Turn[/b]"
    })
    self.createButton({
      click_function = "onClickGreenBtn",
      function_owner = self,
      label          = "",
      position       = {0.4, 1, 5},
      width          = 300,
      height         = 300,
      color          = {0.19, 0.7, 0.16},
      tooltip        = "[b]Green Turn[/b]"
    })
    self.createButton({
      click_function = "onClickYellowBtn",
      function_owner = self,
      label          = "",
      position       = {1.2, 1, 5},
      width          = 300,
      height         = 300,
      color          = {0.9, 0.89, 0.17},
      tooltip        = "[b]Yellow Turn[/b]"
    })

    self.createButton({
      click_function = "onClickRedBtn",
      function_owner = self,
      label          = "",
      position       = {1.2, 1, -5},
      rotation       = {0, 180, 0},
      width          = 300,
      height         = 300,
      color          = {0.85, 0.1, 0.09},
      tooltip        = "[b]Red Turn[/b]"
    })
    self.createButton({
      click_function = "onClickBlueBtn",
      function_owner = self,
      label          = "",
      position       = {0.4, 1, -5},
      rotation       = {0, 180, 0},
      width          = 300,
      height         = 300,
      color          = {0.12, 0.53, 1},
      tooltip        = "[b]Blue Turn[/b]"
    })
    self.createButton({
      click_function = "onClickGreenBtn",
      function_owner = self,
      label          = "",
      position       = {-0.4, 1, -5},
      rotation       = {0, 180, 0},
      width          = 300,
      height         = 300,
      color          = {0.19, 0.7, 0.16},
      tooltip        = "[b]Green Turn[/b]"
    })
    self.createButton({
      click_function = "onClickYellowBtn",
      function_owner = self,
      label          = "",
      position       = {-1.2, 1, -5},
      rotation       = {0, 180, 0},
      width          = 300,
      height         = 300,
      color          = {0.9, 0.89, 0.17},
      tooltip        = "[b]Yellow Turn[/b]"
    })
    self.createInput({
        input_function = "dummy",
        function_owner = self,
        value          = "Starting Turn",
        alignment      = 3,
        position       = {0, 1, 4.50},
        rotation       = {0, 0, 0},
        width          = 2000,
        height         = 400,
        font_size      = 250,
        color          = {0, 0, 0, 0},
        font_color     = {1, 1, 1, 100}
    })
    self.createInput({
        input_function = "dummy",
        function_owner = self,
        value          = "Starting Turn",
        alignment      = 3,
        position       = {0, 1, -4.50},
        rotation       = {0, 180, 0},
        width          = 2000,
        height         = 400,
        font_size      = 250,
        color          = {0, 0, 0, 0},
        font_color     = {1, 1, 1, 100}
    })
end

function onLoad(saved_data)
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