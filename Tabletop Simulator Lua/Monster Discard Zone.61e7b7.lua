MONSTER_TAGS = {}

active = false

LAST_STATE = nil

STATE_PARAMS = {}

MONSTER_DECK_ZONE = getObjectFromGUID(Global.getTable("ZONE_GUID_DECK").MONSTER)
MONSTER_TAGS = MONSTER_DECK_ZONE.getTable("MONSTER_TAGS")

BOSS_ZONE = nil
DISCARD_BUTTON_STATES = MONSTER_DECK_ZONE.getTable("ATTACK_BUTTON_STATES")
DISCARD_BUTTON_COLORS = MONSTER_DECK_ZONE.getTable("ATTACK_BUTTON_COLORS")
DISCARD_BUTTON_INDEX = nil

local function getRandomDiscardCard(onlyMonster)
    for _, obj in ipairs(self.getObjects()) do
        if obj.type == "Card" then
            if onlyMonster then
                local isEvent = obj.getVar("isEvent")
                if not isEvent then
                    return obj
                end
            else
                return obj
            end
        elseif obj.type == "Deck" then
            local randomStart = math.random(obj.getQuantity())
            local cards = obj.getObjects()
            if onlyMonster then
                for i = randomStart, obj.getQuantity() do
                    if not Global.call("findBoolInScript", {scriptString = cards[i].lua_script, varName = "isEvent"}) then
                        return obj.takeObject({guid = cards[i].guid})
                    end
                end
                if selectedCard == nil then
                    for i = randomStart, 1, -1 do
                        if not Global.call("findBoolInScript", {scriptString = cards[i].lua_script, varName = "isEvent"}) then
                            return obj.takeObject({guid = cards[i].guid})
                        end
                    end
                end
            else
                return obj.takeObject({guid = cards[randomStart].guid})
            end
        end
    end
    return nil
end

local function getFirstMonsterDiscardCard()
    for _, obj in ipairs(self.getObjects()) do
        if obj.type == "Card" then
            local isEvent = obj.getVar("isEvent")
            if not isEvent then
                return obj
            end
        elseif obj.type == "Deck" then
            local cards = obj.getObjects()
            for i = obj.getQuantity(), 1, -1 do
                if not Global.call("findBoolInScript", {scriptString = cards[i].lua_script, varName = "isEvent"}) then
                    return obj.takeObject({guid = cards[i].guid})
                end
            end
        end
    end
end

local function getFirstDiscardCard()
    for _, obj in ipairs(self.getObjects()) do
        if obj.type == "Card" then
            return obj
        elseif obj.type == "Deck" then
            return obj.takeObject({guid = obj.getObjects()[obj.getQuantity()].guid})
        end
    end
end

function onLoad(saved_data)
    BOSS_ZONE = getObjectFromGUID(Global.getVar("ZONE_GUID_BOSS"))
    LAST_STATE = DISCARD_BUTTON_STATES.INACTIVE

    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        if loaded_data.active then
            active = loaded_data.active
        end
        if loaded_data.currentLabel then
            activateDiscardButton()
            for _ , state in pairs(DISCARD_BUTTON_STATES) do
                if state == loaded_data.currentLabel then
                    self.editButton({index = DISCARD_BUTTON_INDEX, label = state})
                end
            end
        end
        if loaded_data.lastState then
            LAST_STATE = loaded_data.lastState
        end
    end
end

function onSave()
    local currentLabel = nil
    if getDiscardButton() then
        currentLabel = getDiscardButton().label
    end
    return JSON.encode({active = active, lastState = LAST_STATE, currentState = currentState})
end

function onObjectEnterZone(zone, object)
    if zone == self then
        object.removeTag(MONSTER_TAGS.DEAD)
    end
end

function getDiscardButton()
    if DISCARD_BUTTON_INDEX == nil then
        return nil
    end

    return self.getButtons()[DISCARD_BUTTON_INDEX + 1]
end

function getState()
    local discardButton = getDiscardButton()
    if discardButton == nil then
        return nil
    end
    return discardButton.label
end

function deactivateDiscardButton()
    if DISCARD_BUTTON_INDEX then
        self.removeButton(DISCARD_BUTTON_INDEX)
        DISCARD_BUTTON_INDEX = nil
    end
end

function activateDiscardButton()
    if DISCARD_BUTTON_INDEX == nil then
        DISCARD_BUTTON_INDEX = 0
        local state = active and DISCARD_BUTTON_STATES.SELECT or DISCARD_BUTTON_STATES.INACTIVE
        local color = active and DISCARD_BUTTON_COLORS.ACTIVE or DISCARD_BUTTON_COLORS.INACTIVE
        self.createButton({
            click_function = "click_function_DiscardButton",
            function_owner = self,
            label          = state,
            position       = {0, -0.5, 3},
            width          = 1000,
            height         = 300,
            font_size      = 200,
            color          = color,
            font_color     = {1, 1, 1}
        })
    end
end

function resetDiscardButton()
    deactivateDiscardButton()
end

function activateDiscardZone()
    active = true
end

function deactivateDiscardZone()
    active = false

    if DISCARD_BUTTON_INDEX ~= nil then
        self.editButton({index = DISCARD_BUTTON_INDEX, label = DISCARD_BUTTON_STATES.INACTIVE, color = DISCARD_BUTTON_COLORS.INACTIVE})
        deactivateDiscardButton()
    end
end

function resetDiscardZone()
    if DISCARD_BUTTON_INDEX then
        deactivateDiscardButton()
    end
end

function changeButtonState(params)
    if DISCARD_BUTTON_INDEX == nil then
        return false
    end

    if params.newState == nil then
        Global.call("printWarning", {text = "Wrong parameters in Monster Discard Zone function 'changeButtonState()'."})
    else
        for _ , state in pairs(DISCARD_BUTTON_STATES) do
            if params.newState == state then
                local buttonColor = (state == DISCARD_BUTTON_STATES.INACTIVE) and DISCARD_BUTTON_COLOR.INACTIVE
                    or DISCARD_BUTTON_COLORS.ACTIVE
                self.editButton({index = DISCARD_BUTTON_INDEX, label = state, color = buttonColor})
                return true
            end
        end
    end

    return false
end

function changeZoneState(params)
    local newState = params.newState or LAST_STATE
    if newState == nil then
        return
    end
    local currentState = getState()
    if currentState ~= nil then
        LAST_STATE = currentState
    end
    if newState == DISCARD_BUTTON_STATES.INACTIVE then
        if active then
            deactivateDiscardButton()
        end
    elseif newState == DISCARD_BUTTON_STATES.SELECT then
        if active then
            activateDiscardButton()
            self.editButton({index = DISCARD_BUTTON_INDEX, label = newState})
            if params.stateParams then
                STATE_PARAMS = params.stateParams
            end
        end
    end
end

function click_function_DiscardButton(_, color)
    if Global.getVar("activePlayerColor") == color or Player[color].admin then
        local discardButton = getDiscardButton()
        if discardButton.label == DISCARD_BUTTON_STATES.SELECT then
            deactivateDiscardButton()
            local selectedCard = nil
            local onlyMonster = false
            if STATE_PARAMS.onlyMonster then
                onlyMonster = true
            end
            if STATE_PARAMS.random then
                selectedCard = getRandomDiscardCard(onlyMonster)
            else
                if onlyMonster then
                    selectedCard = getFirstMonsterDiscardCard()
                else
                    selectedCard = getFirstDiscardCard()
                end
            end
            STATE_PARAMS.function_owner.call(STATE_PARAMS.call_function, {card = selectedCard})
        end
    end
end