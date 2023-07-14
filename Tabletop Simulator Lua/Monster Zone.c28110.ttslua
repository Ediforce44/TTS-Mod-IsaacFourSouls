--- Written by Ediforce44
HP_COUNTER_GUID = Global.getTable("MONSTER_HP_COUNTER_GUID").SEVEN

altClickCounter = 0

active_monster_attrs = {
    GUID        = "",
    NAME        = "",
    HP          = 0,
    ATK         = 0,
    DMG         = 0,
    INDOMITABLE = false
}

active_monster_reward = {
    CENTS       = 0,
    LOOT        = 0,
    TREASURES   = 0,
    SOULS       = 0
}

active = false

-- It is used for states which vary their behavior depending on the previous state
LAST_STATE = nil

MONSTER_DECK_ZONE = getObjectFromGUID(Global.getTable("ZONE_GUID_DECK").MONSTER)
ATTACK_BUTTON_STATES = {}
ATTACK_BUTTON_COLORS = {}
ATTACK_BUTTON_INDEX = nil

EVENT_TYPES = {}

function getAttackButton()
    if ATTACK_BUTTON_INDEX == nil then
        return nil
    end

    return self.getButtons()[ATTACK_BUTTON_INDEX + 1]
end

function getState()
    local attackButton = getAttackButton()
    if attackButton == nil then
        return nil
    end
    return attackButton.label
end

function getLeftoverHP()
    return getObjectFromGUID(HP_COUNTER_GUID).getVar("value")
end

function editHP(params)
    local hpCounter = getObjectFromGUID(HP_COUNTER_GUID)
    if params and hpCounter then
        if params.hp then
            hpCounter.call("updateHP", {HP = params.hp})
        elseif params.modifier then
            hpCounter.call("modifyHP", {modifier = params.modifier})
        end
    end
end

function containsDeckOrCard()
    for _ , obj in pairs(self.getObjects()) do
        if obj.tag == "Deck" or obj.tag == "Card" then
            return true
        end
    end
    return false
end

function placeNewMonsterIfEmpty()
    Wait.frames(function ()
            if not containsDeckOrCard() then
                repeat
                    local placedZone =
                        MONSTER_DECK_ZONE.call("placeNewMonsterCard", {zone = self, isTargetOfAttack = false})
                until ((placedZone == self) or (placedZone == nil))
            end
        end, 60)
end

function onLoad(saved_data)
    ATTACK_BUTTON_STATES = MONSTER_DECK_ZONE.getTable("ATTACK_BUTTON_STATES")
    ATTACK_BUTTON_COLORS = MONSTER_DECK_ZONE.getTable("ATTACK_BUTTON_COLORS")
    EVENT_TYPES = MONSTER_DECK_ZONE.getTable("EVENT_TYPES")
    LAST_STATE = ATTACK_BUTTON_STATES.ATTACK
    if saved_data == "" then
        return
    end

    local loaded_data = JSON.decode(saved_data)
    if loaded_data[1] == true then
        active = true
    end
    if loaded_data[2] then
        activateAttackButton()
        for _ , state in pairs(ATTACK_BUTTON_STATES) do
            if state == loaded_data[2] then
                self.editButton({index = ATTACK_BUTTON_INDEX, label = state
                    , tooltip = MONSTER_DECK_ZONE.call("getAttackButtonTooltip", {newState = state})})
            end
        end
    end
    if loaded_data[3] then
        active_monster_attrs.GUID = loaded_data[3].GUID or ""
        active_monster_attrs.NAME = loaded_data[3].NAME or "Unkown"
        active_monster_attrs.HP = loaded_data[3].HP or 0
        active_monster_attrs.ATK = loaded_data[3].ATK or 0
        active_monster_attrs.DMG = loaded_data[3].DMG or 0
        active_monster_attrs.INDOMITABLE = loaded_data[3].INDOMITABLE or false
    end
    if loaded_data[4] then
        active_monster_reward.CENTS = loaded_data[4].CENTS or 0
        active_monster_reward.LOOT = loaded_data[4].LOOT or 0
        active_monster_reward.TREASURES = loaded_data[4].TREASURES or 0
        active_monster_reward.SOULS = loaded_data[4].SOULS or 0
    end
end

function onSave()
    local currentLabel = nil
    if getAttackButton() then
        currentLabel = getAttackButton().label
    end
    return JSON.encode({active, currentLabel, active_monster_attrs, active_monster_reward})
end

function getActiveMonsterCard()
    for _ , obj in pairs(self.getObjects()) do
        if obj.tag == "Deck" then
            local containedObjects = obj.getData().ContainedObjects
            if containedObjects[#containedObjects]["GUID"] == active_monster_attrs.GUID then
                return obj.takeObject()
            end
        elseif obj.tag == "Card" then
            if obj.getGUID() == active_monster_attrs.GUID then
                return obj
            end
        end
    end
    return nil
end

function dealEventToPlayer(params)
    if params.pickedColor then
        local card = getActiveMonsterCard()
        Wait.frames(function ()
                if (card ~= nil) and card.getVar("isEvent") then
                    Global.call("placeObjectInPillZone", {playerColor = params.pickedColor, object = card})
                    placeNewMonsterIfEmpty()
                end
            end)
    end
end

function resetMonsterZone()
    if ATTACK_BUTTON_INDEX == nil then
        activateAttackButton()
    else
        local state = active and ATTACK_BUTTON_STATES.ATTACK or ATTACK_BUTTON_STATES.INACTIVE
        self.editButton({index = ATTACK_BUTTON_INDEX, label = state
                , tooltip = MONSTER_DECK_ZONE.call("getAttackButtonTooltip", {newState = state})})
    end
    getObjectFromGUID(HP_COUNTER_GUID).call("reset")
end

function deactivateAttackButton()
    if ATTACK_BUTTON_INDEX then
        self.removeButton(ATTACK_BUTTON_INDEX)
        ATTACK_BUTTON_INDEX = nil
    end
end

function activateAttackButton()
    if ATTACK_BUTTON_INDEX == nil then
        ATTACK_BUTTON_INDEX = 0
        local state = active and ATTACK_BUTTON_STATES.ATTACK or ATTACK_BUTTON_STATES.INACTIVE
        local color = active and ATTACK_BUTTON_COLORS.ACTIVE or ATTACK_BUTTON_COLORS.INACTIVE
        self.createButton({
            click_function = "click_function_AttackButton",
            function_owner = getObjectFromGUID(Global.getTable("ZONE_GUID_DECK").MONSTER),
            label          = state,
            position       = {0, 0, 3},
            width          = 1000,
            height         = 300,
            font_size      = 200,
            color          = color,
            font_color     = {1, 1, 1},
            tooltip        = MONSTER_DECK_ZONE.call("getAttackButtonTooltip", {newState = state})
        })
    end
end

function resetAttackButton()
    if ATTACK_BUTTON_INDEX == nil then
        activateAttackButton()
    else
        if active then
            self.editButton({index = ATTACK_BUTTON_INDEX, label = ATTACK_BUTTON_STATES.ATTACK
                , tooltip = MONSTER_DECK_ZONE.call("getAttackButtonTooltip", {newState = ATTACK_BUTTON_STATES.ATTACK})
                , color = ATTACK_BUTTON_COLORS.ACTIVE})
        else
            self.editButton({index = ATTACK_BUTTON_INDEX, label = ATTACK_BUTTON_STATES.INATTACK
                , tooltip = MONSTER_DECK_ZONE.call("getAttackButtonTooltip", {newState = ATTACK_BUTTON_STATES.INATTACK})
                , color = ATTACK_BUTTON_COLORS.INACTIVE})
        end
    end
end

function killMonster()
    getObjectFromGUID(HP_COUNTER_GUID).call("updateHP", {HP = 0})
    monsterDied()
end

function monsterDied()
    if active then
        getObjectFromGUID(HP_COUNTER_GUID).call("updateHP", {HP = 0})
        local attackButton = getAttackButton()
        if attackButton then
            broadcastToAll(Global.getTable("PRINT_COLOR_SPECIAL").MONSTER_LIGHT .. active_monster_attrs.NAME
                .. "[-] got killed !!!")
            MONSTER_DECK_ZONE.call("changeZoneState", {zone = self, newState = ATTACK_BUTTON_STATES.DIED})
        end
    end
end

function monsterReanimated()
    if active and active_monster_attrs.HP ~= 0 then
        broadcastToAll(Global.call("getActivePlayerString") .. " fucked up. "
            .. Global.getTable("PRINT_COLOR_SPECIAL").MONSTER_LIGHT .. active_monster_attrs.NAME .. "[-] is undead ???")
        if getState() == ATTACK_BUTTON_STATES.SELECT then
            LAST_STATE = ATTACK_BUTTON_STATES.ATTACKING
        elseif LAST_STATE == ATTACK_BUTTON_STATES.ATTACKING then
            MONSTER_DECK_ZONE.call("changeZoneState", {zone = self, newState = ATTACK_BUTTON_STATES.ATTACKING})
        else
            MONSTER_DECK_ZONE.call("changeZoneState", {zone = self, newState = ATTACK_BUTTON_STATES.ATTACK})
        end
    end
end

-- Pays out the reward of the active monster to the active player if Auto-Rewarding for the active player is activated.
---   It discards the active monster card if the reward "SOULS" is 0.
---     Otherwise the card will be placed in the soul zone of the active player.
---   The `onDie()` function of the card will be executed and if it returns true or nothing,
---     the card will be taged as DEAD and a new monster card will be placed in this zone if it is empty.
function finishMonster(params)
    local selected = false
    if params then
        selected = (params.selected == true)
    end

    local activePlayerColor = Global.getVar("activePlayerColor")
    local monsterCard = getActiveMonsterCard()
    if monsterCard == nil then
        return nil
    end
    if Global.getTable("PLAYER_SETTINGS")[activePlayerColor].rewarding then
        local rewarded = MONSTER_DECK_ZONE.call("payOutRewards", {playerColor = activePlayerColor, rewardTable = active_monster_reward})
        if rewarded then
            broadcastToAll(Global.call("getActivePlayerString") .. " got rewards for killing "
                .. Global.getTable("PRINT_COLOR_SPECIAL").MONSTER_LIGHT .. active_monster_attrs.NAME .. "[-] !!!")
        end
    end
    -- OnDie
    Wait.frames(function ()
            if not selected then
                -- Place discard monster card
                if active_monster_reward.SOULS ~= 0 then    -- Monster becomes soul token
                    Global.call("placeObjectInSoulZone", {playerColor = activePlayerColor, object = monsterCard})
                else    -- Monster just get discarded
                    monsterCard.setPositionSmooth(Global.getTable("DISCARD_PILE_POSITION").MONSTER)
                end
            end
            --default: true, only false on false
            local died = not (monsterCard.call("onDie", {zone = self, selected = selected}) == false)

            if died or selected then        --if monster died it will tagged as dead
                local deadTag = MONSTER_DECK_ZONE.getTable("MONSTER_TAGS").DEAD
                monsterCard.addTag(deadTag)
                Wait.condition(function() monsterCard.removeTag(deadTag) end
                    , function() return not monsterCard.isSmoothMoving() end)

                MONSTER_DECK_ZONE.call("callMonsterDieEvents", {guid = monsterCard.getGUID(), zone = self})
                -- Place new monster card
                placeNewMonsterIfEmpty()
            end
        end)
    return monsterCard
end

function resetAltClickCounter()
    altClickCounter = 0
end

function updateAttributes(params)
    if params.HP == nil then
        Global.call("printWarning", {text = "Wrong parameters in monster zone function 'updateAttributes()'."
            .. " The parameter table should always contain a value for the key 'HP'"})
    else
        active_monster_attrs.GUID = params.GUID or active_monster_attrs.GUID
        active_monster_attrs.NAME = params.NAME or "Unkown"
        active_monster_attrs.HP = params.HP or 0
        active_monster_attrs.ATK = params.ATK or -1
        active_monster_attrs.DMG = params.DMG or -1
        active_monster_attrs.INDOMITABLE = params.INDOMITABLE or false
        getObjectFromGUID(HP_COUNTER_GUID).call("updateHP", {HP = active_monster_attrs.HP})
    end
end

function updateRewards(params)
    active_monster_reward.CENTS = params.CENTS or 0
    active_monster_reward.LOOT = params.LOOT or 0
    active_monster_reward.TREASURES = params.TREASURES or 0
    active_monster_reward.SOULS = params.SOULS or 0
end

function activateZone(params)
    if active then
        Global.call("printWarning", {text = "Can't activate Zone: " .. self.guid .. ". This Zone is already active."})
    else
        if containsDeckOrCard() then
            local firstObjectInZone = self.getObjects()[2]
            if firstObjectInZone.tag == "Card" then
                firstObjectInZone.setPositionSmooth(self.getPosition():setAt('y', 2), false)
            elseif firstObjectInZone.tag == "Deck" then
                firstObjectInZone.takeObject({position = self.getPosition():setAt('y', 2)})
            end
        elseif (params == nil) or (params.drawCard == nil) or (params.drawCard == true) then
            if MONSTER_DECK_ZONE.call("placeNewMonsterCard", {zone = self, isTargetOfAttack = false}) == nil then
                return
            end
        end
        active = true

        if ATTACK_BUTTON_INDEX == nil then
            activateAttackButton()
        else
            self.editButton({index = ATTACK_BUTTON_INDEX, label = ATTACK_BUTTON_STATES.ATTACK
                , tooltip = MONSTER_DECK_ZONE.call("getAttackButtonTooltip", {newState = ATTACK_BUTTON_STATES.ATTACK})
                , color = ATTACK_BUTTON_COLORS.ACTIVE})
        end
    end
end

function deactivateZone()
    for _ , obj in pairs(self.getObjects()) do
        if obj.tag == "Deck" or obj.tag == "Card" then
            MONSTER_DECK_ZONE.call("discardMonsterObject", {object = obj})
        end
    end
    updateAttributes({HP = 0, GUID = ""})

    active = false

    if ATTACK_BUTTON_INDEX == nil then
        activateAttackButton()
    else
        self.editButton({index = ATTACK_BUTTON_INDEX, label = ATTACK_BUTTON_STATES.INACTIVE
            , tooltip = MONSTER_DECK_ZONE.call("getAttackButtonTooltip", {newState = ATTACK_BUTTON_STATES.INACTIVE})
            , color = ATTACK_BUTTON_COLORS.INACTIVE})
    end
end

function changeButtonState(params)
    if ATTACK_BUTTON_INDEX == nil then
        return false
    end

    if params.newState == nil then
        Global.call("printWarning", {text = "Wrong parameters in global function 'changeButtonState()'."})
    else
        for _ , state in pairs(ATTACK_BUTTON_STATES) do
            if params.newState == state then
                LAST_STATE = getState()
                local buttonColor = (state == ATTACK_BUTTON_STATES.INACTIVE) and ATTACK_BUTTON_COLOR.INACTIVE
                    or ATTACK_BUTTON_COLORS.ACTIVE
                self.editButton({index = ATTACK_BUTTON_INDEX, label = state
                        , tooltip = MONSTER_DECK_ZONE.call("getAttackButtonTooltip", {newState = state})
                        , color = buttonColor})
                return true
            end
        end
    end

    return false
end