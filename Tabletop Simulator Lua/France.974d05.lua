LANGUAGE_SYSTEM_GUID = "fd5c6d"

function onSave()
    return JSON.encode({self.getButtons()[1].label})
end

function onLoad(saved_data)
    local label = ""
    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        if loaded_data[1] then
            if loaded_data[1] ~= "" then
                label = "✓"
                --Bad but best solution to avoid redundance
                getObjectFromGUID(LANGUAGE_SYSTEM_GUID).call("setLanguage", {obj = self})
            end
        end
    end
    self.createButton({
      click_function = 'switchLanguageByObject',
      function_owner = getObjectFromGUID(LANGUAGE_SYSTEM_GUID),
      label = label,
      position = {0, 0, 2},
      width = 600,
      height = 600,
      font_size = 550,
    })
    
    --TODO delete this input
    self.createInput({
        value ="The French cards are temporary until the new french cards will be released.\n\nDisclaimer:\nThey wont work with the seed function and some other things.\n\nThanks to Tenebrosful for helping with the french decks.",
        input_function = "dummy",
        function_owner = self,
        alignment = 3,
        position = {0,0,8},
        width = 4000,
        height = 5000,
        font_size = 300,
        scale={x=1, y=1, z=1},
        font_color= {1, 0, 0, 100},
        color = {0,0,0,0}
    })
end

function dummy()
end