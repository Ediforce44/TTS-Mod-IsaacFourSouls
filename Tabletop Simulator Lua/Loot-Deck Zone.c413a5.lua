-- Written by Ediforce44
LOOT_BUTTON_STATES = {
    INACTIVE    = "Inactive",
    LOOT        = "Loot"
}

LOOT_BUTTON_COLORS = {
    INACTIVE    = {0.4, 0.57, 0.6},
    ACTIVE      = {0.4, 0.57, 0.6}
}

LOOT_BUTTON_INDEX = nil

local function getLootButton()
    if LOOT_BUTTON_INDEX == nil then
        return nil
    end
    return self.getButtons()[LOOT_BUTTON_INDEX + 1]
end

local function drawLootCard(playerColor)
    for _ , obj in pairs(self.getObjects()) do
        if obj.tag == "Deck" then
            obj.deal(1, playerColor)
            break
        elseif obj.tag == "Card" then
            --boughtCard = obj
            --boughtCard.flip()
            break
        else
            return false
        end
    end
    return true
end

function onLoad(saved_data)
    if saved_data == "" then
        return
    end

    local loaded_data = JSON.decode(saved_data)
    if loaded_data[1] then
        activateLootButton()

        for _ , state in pairs(LOOT_BUTTON_STATES) do
            if state == loaded_data[1] then
                --self.editButton({index = LOOT_BUTTON_INDEX, label = state})
                self.editButton({index = LOOT_BUTTON_INDEX, label = state
                        , tooltip = getLootButtonTooltip({newState = state})})
            end
        end
    end
end

function onSave()
    local currentLabel = nil
    if getLootButton() then
        currentLabel = getLootButton().label
    end
    return JSON.encode({currentLabel})
end

function activateLootButton()
    if LOOT_BUTTON_INDEX == nil then
        LOOT_BUTTON_INDEX = 0
        local state = LOOT_BUTTON_STATES.LOOT
        self.createButton({
            click_function = "click_function_LootButton",
            function_owner = self,
            label          = state,
            position       = {0, -0.5, 3.12},
            width          = 1000,
            height         = 300,
            font_size      = 200,
            color          = LOOT_BUTTON_COLORS.ACTIVE,
            font_color     = {1, 1, 1},
            tooltip        = getLootButtonTooltip({newState = state})
        })
    end
end

function getLootButtonTooltip(params)
    -- params.newState
    return ""
end

function deactivateLootButton()
    if LOOT_BUTTON_INDEX then
        self.removeButton(LOOT_BUTTON_INDEX)
        LOOT_BUTTON_INDEX = nil
    end
end

function click_function_LootButton(zone, color, alt_click)
    local lootButton = getLootButton()
    if lootButton.label == LOOT_BUTTON_STATES.LOOT then
        drawLootCard(color)
    else
        Global.call("printWarning", {text = "Unknown loot button state: " .. tostring(lootButton.label) .. "."})
    end
end