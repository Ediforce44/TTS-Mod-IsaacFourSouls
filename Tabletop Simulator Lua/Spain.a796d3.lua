LANGUAGE_SYSTEM_GUID = "fd5c6d"

function onSave()
    return JSON.encode({self.getButtons()[1].label})
end

function onLoad(saved_data)
    local label = ""
    if saved_data ~= "" then
        loaded_data = JSON.decode(saved_data)
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
end