TABLE_BASE_GUID = "f5c4fe"
BOARD_MANAGER_GUID = "bd69bd"
CUSTOM_BUTTON_MODULE_GUID = "78c676"
MONSTER_DECK_ZONE_GUID = Global.getTable("ZONE_GUID_DECK").MONSTER

CHALLENGE_BOARD_URL = "http://cloud-3.steamusercontent.com/ugc/2063259124650479201/DF7365CC91884C5BEA13B2756FD6A727DFD86838/"
CHALLENGE_BOARD_EXPANDED_URL = "http://cloud-3.steamusercontent.com/ugc/2063259124650479326/E87EEC60F9054E0FF60B04806A38CF9FA48EF685/"

local isChallengeModeActive = false
local isBoardExpanded = false

local areaToDeleteEdges = {x1 =-45, z1 =18, x2 =38, z2 =5}

local yellowPlayerStuff = {
    ZONE_SOUL = "92610d",
    ZONE_PILL = "53dd4c",
    ZONE_PLAYER = "bb01dd",
    ZONE_LOOT = "a81bbf",
    DICE = "9069fa",
    DEATH = "6d1f5d",
    HEART_ONE = "c02908",
    HEART_TWO = "3f81b7",
    HEART_THREE = "f8e991",
    HEART_FOUR = "f825c2",
    HEART_FIVE = "2a9dfc",
    HEART_SIX = "443adb",
    MOD_DICE = "9f1f66",
    MOD_ATTACK = "a32133",
    COUNTER_SOUL = "d340e6",
    COUNTER_COIN = "9d76db",
    COUNTER_LOOT = "8ef4e4"
}

local greenPlayerStuff = {
    ZONE_SOUL = "f95f84",
    ZONE_PILL = "e3361a",
    ZONE_PLAYER = "19df91",
    ZONE_LOOT = "7831c7",
    DICE = "4dce5a",
    DEATH = "7023b1",
    HEART_ONE = "12326f",
    HEART_TWO = "c326f1",
    HEART_THREE = "f5d095",
    HEART_FOUR = "7e882b",
    HEART_FIVE = "66804c",
    HEART_SIX = "e24915",
    MOD_DICE = "0fb9b4",
    MOD_ATTACK = "2498af",
    COUNTER_SOUL = "4e958e",
    COUNTER_COIN = "c46653",
    COUNTER_LOOT = "48162b"
}

local handZones = {
    Yellow = "e2e2d1",
    Green = "489f26"
}

local spyZones = {
    Yellow = "ad4169",
    Green = "69a792"
}

local restStuff = {
    COUNTER_GOLD = "7098e7",
    COUNTER_GUT = "d4829c",
    COUNTER_SPIDER = "48a1c8",
    COUNTER_POO = "6a8317",
    COUNTER_EGG = "cb8d89"
}

local challengePropIDs = {
    HP_COUNTER = "c4bbf4"
}

local propTable = {
    HP_COUNTER_MINION = {},
    HP_COUNTER_BOSS = nil
}

local zoneTable = {
    MINION = {},
    CSLOT = {},
    BOSS = nil
}

local minionSlotGuids = {}
local treasureSlotGuids = {}
local nextFreeChallengeSlot = 1
local maxChallengeSlot = 4

local setupInfoTable = {}
local challengeBag = nil

local SCRIPT_MINION_ZONE =
[[--- Written by Ediforce44
HP_COUNTER_GUID = nil
COUNTER_MODULE = nil

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

LAST_STATE = nil

MONSTER_DECK_ZONE = getObjectFromGUID(Global.getTable("ZONE_GUID_DECK").MONSTER)
BOSS_ZONE = nil
ATTACK_BUTTON_STATES = {}
ATTACK_BUTTON_COLORS = {}
ATTACK_BUTTON_INDEX = nil

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

function containsDeckOrCard()
    for _ , obj in pairs(self.getObjects()) do
        if obj.tag == "Deck" or obj.tag == "Card" then
            return true
        end
    end
    return false
end

function onLoad(saved_data)
    COUNTER_MODULE = getObjectFromGUID(Global.getVar("COUNTER_MODULE_GUID"))
    BOSS_ZONE = getObjectFromGUID(Global.getVar("ZONE_GUID_BOSS"))

    ATTACK_BUTTON_STATES = BOSS_ZONE.getTable("ATTACK_BUTTON_STATES")
    ATTACK_BUTTON_COLORS = BOSS_ZONE.getTable("ATTACK_BUTTON_COLORS")
    LAST_STATE = ATTACK_BUTTON_STATES.ATTACK

    if saved_data == "" then
        return
    end

    local loaded_data = JSON.decode(saved_data)

    if loaded_data.active == true then
        active = true
    end
    if loaded_data.currentLabel then
        activateAttackButton()
        for _ , state in pairs(ATTACK_BUTTON_STATES) do
            if state == loaded_data.currentLabel then
                self.editButton({index = ATTACK_BUTTON_INDEX, label = state
                    , tooltip = BOSS_ZONE.call("getAttackButtonTooltip", {newState = state})})
            end
        end
    end
    if loaded_data.monsterAttrs then
        local attrs = loaded_data.monsterAttrs
        active_monster_attrs.GUID = attrs.GUID or ""
        active_monster_attrs.NAME = attrs.NAME or "Unkown"
        active_monster_attrs.HP = attrs.HP or 0
        active_monster_attrs.ATK = attrs.ATK or 0
        active_monster_attrs.DMG = attrs.DMG or 0
        active_monster_attrs.INDOMITABLE = attrs.INDOMITABLE or false
    end
    if loaded_data.monsterRewards then
        local reward = loaded_data.monsterRewards
        active_monster_reward.CENTS = reward.CENTS or 0
        active_monster_reward.LOOT = reward.LOOT or 0
        active_monster_reward.TREASURES = reward.TREASURES or 0
        active_monster_reward.SOULS = reward.SOULS or 0
    end
    if loaded_data.hpCounterGuid then
        HP_COUNTER_GUID = loaded_data.hpCounterGuid
        getObjectFromGUID(HP_COUNTER_GUID).call("setZone", {zoneGuid = self.getGUID()})
    end
    if loaded_data.lastState then
        LAST_STATE = loaded_data.lastState
    end
end

function onSave()
    local currentLabel = nil
    if getAttackButton() then
        currentLabel = getAttackButton().label
    end
    return JSON.encode({active = active, currentLabel = currentLabel, monsterAttrs = active_monster_attrs
        , monsterRewards = active_monster_reward, hpCounterGuid = HP_COUNTER_GUID, lastState = LAST_STATE})
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
                    local deadTag = MONSTER_DECK_ZONE.getTable("MONSTER_TAGS").DEAD
                    card.addTag(deadTag)
                    Global.call("placeObjectInPillZone", {playerColor = params.pickedColor, object = card})
                    Wait.condition(function() card.removeTag(deadTag) end
                        , function() return not card.isSmoothMoving() end)
                end
            end)
    end
end

function discardActiveMonster()
    local activeMonsterCard = getActiveMonsterCard()
    if activeMonsterCard then
        MONSTER_DECK_ZONE.call("discardMonsterObject", {object = activeMonsterCard})
    end
    return activeMonsterCard
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

function resetMinionZone()
    if ATTACK_BUTTON_INDEX == nil then
        if active then
            activateAttackButton()
        end
    else
        local state = active and ATTACK_BUTTON_STATES.ATTACK or ATTACK_BUTTON_STATES.INACTIVE
        self.editButton({index = ATTACK_BUTTON_INDEX, label = state
                , tooltip = BOSS_ZONE.call("getAttackButtonTooltip", {newState = state})})
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
            function_owner = BOSS_ZONE,
            label          = state,
            position       = {0, 0, 2.5},
            width          = 1000,
            height         = 300,
            font_size      = 200,
            color          = color,
            font_color     = {1, 1, 1},
            tooltip        = BOSS_ZONE.call("getAttackButtonTooltip", {newState = state})
        })
    end
end

function resetAttackButton()
    if active then
        if ATTACK_BUTTON_INDEX then
            self.editButton({index = ATTACK_BUTTON_INDEX, label = ATTACK_BUTTON_STATES.ATTACK
                , tooltip = MONSTER_DECK_ZONE.call("getAttackButtonTooltip", {newState = ATTACK_BUTTON_STATES.ATTACK})
                , color = ATTACK_BUTTON_COLORS.ACTIVE})
        else
            activateAttackButton()
        end
    else
        if ATTACK_BUTTON_INDEX then
            self.editButton({index = ATTACK_BUTTON_INDEX, label = ATTACK_BUTTON_STATES.INACTIVE
                , tooltip = MONSTER_DECK_ZONE.call("getAttackButtonTooltip", {newState = ATTACK_BUTTON_STATES.INACTIVE})
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
            LAST_STATE = attackButton.label
            broadcastToAll(Global.getTable("PRINT_COLOR_SPECIAL").MINION .. active_monster_attrs.NAME
                .. "[-] got killed !!!")
            BOSS_ZONE.call("changeMinionZoneState", {zone = self, newState = ATTACK_BUTTON_STATES.DIED})
        end
    end
end

function monsterReanimated()
    if active and active_monster_attrs.HP ~= 0 then
        broadcastToAll(Global.call("getActivePlayerString") .. " fucked up. "
            .. Global.getTable("PRINT_COLOR_SPECIAL").MINION .. active_monster_attrs.NAME .. "[-] is undead ???")
        if getState() == ATTACK_BUTTON_STATES.SELECT then
            LAST_STATE = ATTACK_BUTTON_STATES.ATTACKING
        elseif LAST_STATE == ATTACK_BUTTON_STATES.ATTACKING then
            BOSS_ZONE.call("changeMinionZoneState", {zone = self, newState = ATTACK_BUTTON_STATES.ATTACKING})
        else
            BOSS_ZONE.call("changeMinionZoneState", {zone = self, newState = ATTACK_BUTTON_STATES.ATTACK})
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

    local allowRewards = not params.noRewards

    local activePlayerColor = Global.getVar("activePlayerColor")
    local monsterCard = getActiveMonsterCard()
    if monsterCard == nil then
        return nil
    end

    COUNTER_MODULE.call("notifyKILL", {player = activePlayerColor, dif = 1})

    if allowRewards and Global.getTable("PLAYER_SETTINGS")[activePlayerColor].rewarding then
        local rewarded = MONSTER_DECK_ZONE.call("payOutRewards", {playerColor = activePlayerColor, rewardTable = active_monster_reward})
        if rewarded then
            broadcastToAll(Global.call("getActivePlayerString") .. " got rewards for killing "
                .. Global.getTable("PRINT_COLOR_SPECIAL").MINION .. active_monster_attrs.NAME .. "[-] !!!")
        end
    end
    -- OnDie
    Wait.frames(function ()
            if (not selected) then
                -- Place discard monster card
                if allowRewards and (active_monster_reward.SOULS ~= 0) then -- Monster becomes soul token
                    Global.call("placeObjectInSoulZone", {playerColor = activePlayerColor, object = monsterCard})
                else    -- Monster just get discarded
                    monsterCard.setPositionSmooth(Global.getTable("DISCARD_PILE_POSITION").MONSTER)
                end
            end
            --default: true, only false on false
            local died = not (monsterCard.call("onDie", {zone = self, selected = selected}) == false)
            if died then        --if monster died it will tagged as dead
                local deadTag = MONSTER_DECK_ZONE.getTable("MONSTER_TAGS").DEAD
                monsterCard.addTag(deadTag)
                Wait.condition(function() monsterCard.removeTag(deadTag) end
                    , function() return not monsterCard.isSmoothMoving() end)

                MONSTER_DECK_ZONE.call("callMonsterDieEvents", {guid = monsterCard.getGUID(), zone = self, isMinion = true})
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

function activateZone()
    if active then
        Global.call("printWarning", {text = "Can't activate Zone: " .. self.guid .. ". This Zone is already active."})
    else
        active = true

        if ATTACK_BUTTON_INDEX == nil then
            activateAttackButton()
        else
            self.editButton({index = ATTACK_BUTTON_INDEX, label = ATTACK_BUTTON_STATES.ATTACK
                , tooltip = BOSS_ZONE.call("getAttackButtonTooltip", {newState = ATTACK_BUTTON_STATES.ATTACK})
                , color = ATTACK_BUTTON_COLORS.ACTIVE})
        end
    end
end

function deactivateZone()
    for _ , obj in pairs(self.getObjects()) do
        if obj.type == "Deck" or obj.type == "Card" then
            MONSTER_DECK_ZONE.call("discardMonsterObject", {object = obj})
        end
    end
    updateAttributes({HP = 0, GUID = ""})

    active = false

    if ATTACK_BUTTON_INDEX ~= nil then
        self.editButton({index = ATTACK_BUTTON_INDEX, label = ATTACK_BUTTON_STATES.INACTIVE
            , tooltip = BOSS_ZONE.call("getAttackButtonTooltip", {newState = ATTACK_BUTTON_STATES.INACTIVE})
            , color = ATTACK_BUTTON_COLORS.INACTIVE})
        deactivateAttackButton()
    end
end

function changeButtonState(params)
    if ATTACK_BUTTON_INDEX == nil then
        return false
    end

    if params.newState == nil then
        Global.call("printWarning", {text = "Wrong parameters in Minion Zone function 'changeButtonState()'."})
    else
        for _ , state in pairs(ATTACK_BUTTON_STATES) do
            if params.newState == state then
                local buttonColor = (state == ATTACK_BUTTON_STATES.INACTIVE) and ATTACK_BUTTON_COLOR.INACTIVE
                    or ATTACK_BUTTON_COLORS.ACTIVE
                self.editButton({index = ATTACK_BUTTON_INDEX, label = state
                        , tooltip = BOSS_ZONE.call("getAttackButtonTooltip", {newState = state})
                        , color = buttonColor})
                return true
            end
        end
    end

    return false
end]]

local SCRIPT_BOSS_ZONE =
[[--- Written by Ediforce44
MINION_ZONE_INFO = {}
MINION_SLOT_GUIDS = {}
MONSTER_ZONE_GUIDS = Global.getTable("ZONE_GUID_MONSTER")
MONSTER_DECK_ZONE_GUID = Global.getTable("ZONE_GUID_DECK").MONSTER
MONSTER_DISCARD_ZONE_GUID = Global.getTable("ZONE_GUID_DISCARD").MONSTER
COUNTER_MODULE = nil

ONLY_MONSTER_MINIONS = true
NO_MINION_REWARDS = false

BOSS_COUNTER_POSITION = nil

STATE_PARAMS = {}

DISCARD_PILE_POSITION = {}

ATTACK_BUTTON_STATES = {}

ATTACK_BUTTON_COLORS = {
    INACTIVE    = {0.19, 0, 0.04},
    ACTIVE      = {0.28, 0, 0.05}
}

MINION_SLOT_BUTTON_STATES = {}
MINION_SLOT_BUTTON_COLORS = ATTACK_BUTTON_COLORS

HP_COUNTER_GUID = nil
altClickCounter = 0

tempBlockedMinionZones = {}

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

active = true

-- Don't use it. It is only used for monster reanimation
LAST_STATE = nil

BOSS_BUTTON_STATES = nil
BOSS_BUTTON_COLORS = ATTACK_BUTTON_COLORS
BOSS_BUTTON_INDEX = nil

RESURRECT_BUTTON_STATES = {
    ADD_MINION = "Add Minion",
    ADDING = "Cancel"
}
RESURRECT_BUTTON_INDEX = nil

PLAYER_RESURRECT_BUTTON_INDICES = {}

MONSTER_TAGS = getObjectFromGUID(MONSTER_DECK_ZONE_GUID).getTable("MONSTER_TAGS")

local function getTimerParameters(blockedIndex)
    local timerParameters = {
        ["identifier"] = "MinionBlockedIndexTimer" .. self.guid .. tostring(blockedIndex),
        ["function_name"] = "resetBlockedIndex",
        ["parameters"] = {index = blockedIndex},
        ["delay"] = 2,
    }
    return timerParameters
end

function resetBlockedIndex(params)
    tempBlockedMinionZones[params.index] = false
end

function activatePlayerMinionZones(params)
    if params and params.zoneIDs then
        for color, ids in pairs(params.zoneIDs) do
            for _, id in pairs(ids) do
                MINION_ZONE_INFO[id].owner = color
            end
        end
    end
    Global.setTable("ZONE_INFO_MINION", MINION_ZONE_INFO)
end

local function getDoubleAltClickParameters(zone)
    DOUBLE_CLICK_PARAMETERS = {
        ["identifier"] = "AltClickTimer" .. zone.guid,
        ["function_owner"] = zone,
        ["function_name"] = "resetAltClickCounter",
        ["delay"] = Global.getVar("CLICK_DELAY")
    }
    return DOUBLE_CLICK_PARAMETERS
end

local function printAttackPhrase(monsterName)
    local phrase = nil
    if monsterName ~= "" then
        phrase = Global.call("getActivePlayerString")
        phrase = phrase .. " attacks Minion " .. Global.getTable("PRINT_COLOR_SPECIAL").MINION .. monsterName .. "[-] !!!"
        broadcastToAll(phrase)
    end
    return phrase
end

local function objectContainsGUID(object, GUID)
    if object.getGUID() == GUID then
        return true
    elseif object.tag == "Deck" then
        for _ , jsonObj in pairs(object.getData().ContainedObjects) do
            if jsonObj["GUID"] == GUID then
                return true
            end
        end
    end
    return false
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

------------------------------------------------------------------------------------------------------------------------
--------------------------------------------- Button functions ---------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function getBossButton()
    if BOSS_BUTTON_INDEX == nil then
        return nil
    end

    return self.getButtons()[BOSS_BUTTON_INDEX + 1]
end

function getResurrectButton()
    if RESURRECT_BUTTON_INDEX == nil then
        return nil
    end

    return self.getButtons()[RESURRECT_BUTTON_INDEX + 1]
end

function getPlayerResurrectButton()
    local indexTable = {}
    local buttons = self.getButtons()
    for color, index in pairs(PLAYER_RESURRECT_BUTTON_INDICES) do
        indexTable[color] = buttons[index + 1]
    end
    return indexTable
end

function getState()
    local attackButton = getBossButton()
    if attackButton == nil then
        return nil
    end
    return attackButton.label
end

function getResurrectState(index)
    local resurrectButton = getResurrectButton()
    if index then
        resurrectButton = self.getButtons()[index + 1]
    end
    if resurrectButton == nil then
        return nil
    end
    return resurrectButton.label
end

function deactivateBossButton()
    if BOSS_BUTTON_INDEX then
        self.removeButton(BOSS_BUTTON_INDEX)
        BOSS_BUTTON_INDEX = nil
    end
end

function activateBossButton()
    if BOSS_BUTTON_INDEX == nil then
        local state = active and BOSS_BUTTON_STATES.ATTACK or BOSS_BUTTON_STATES.INACTIVE
        local color = active and BOSS_BUTTON_COLORS.ACTIVE or BOSS_BUTTON_COLORS.INACTIVE
        self.createButton({
            click_function = "click_function_BossButton",
            function_owner = self,
            label          = state,
            position       = {0, 0, 2.7},
            width          = 1000,
            height         = 300,
            font_size      = 200,
            color          = color,
            font_color     = {1, 1, 1},
            tooltip        = getBossButtonTooltip(state)
        })
        local bossButtonIndex = 1
        for _,_ in pairs(PLAYER_RESURRECT_BUTTON_INDICES) do
            bossButtonIndex = bossButtonIndex + 1
        end
        BOSS_BUTTON_INDEX = bossButtonIndex
    end
end

local function createResurrectButton()
    if RESURRECT_BUTTON_INDEX == nil then
        self.createButton({
            click_function = "click_function_ResurrectButton",
            function_owner = self,
            label          = RESURRECT_BUTTON_STATES.ADD_MINION,
            position       = {2.8, 0, 2.7},
            width          = 1100,
            height         = 300,
            font_size      = 200,
            color          = BOSS_BUTTON_COLORS.ACTIVE,
            font_color     = {1, 1, 1},
            tooltip        = "[i]Left-Click: Add monster to Minion Zone[/i]"
        })
        RESURRECT_BUTTON_INDEX = 0
    end
end

local function createPlayerResurrectButtons()
    if #PLAYER_RESURRECT_BUTTON_INDICES == 0 then
        local playerColor = Global.getTable("REAL_PLAYER_COLOR_RGB")
        self.createButton({
            click_function = "click_function_ResurrectButton_Red",
            function_owner = self,
            label          = RESURRECT_BUTTON_STATES.ADD_MINION,
            position       = {7, 0, -2.8},
            width          = 1400,
            height         = 360,
            font_size      = 240,
            color          = {0.6, 0, 0.1},
            font_color     = {1, 1, 1},
            tooltip        = "[i]Left-Click: Add monster to Red Minion Zone[/i]"
        })
        PLAYER_RESURRECT_BUTTON_INDICES["Red"] = 1
        self.createButton({
            click_function = "click_function_ResurrectButton_Blue",
            function_owner = self,
            label          = RESURRECT_BUTTON_STATES.ADD_MINION,
            position       = {-7, 0, -2.8},
            width          = 1400,
            height         = 360,
            font_size      = 240,
            color          = {0.1, 0, 0.6},
            font_color     = {1, 1, 1},
            tooltip        = "[i]Left-Click: Add monster to Blue Minion Zone[/i]"
        })
        PLAYER_RESURRECT_BUTTON_INDICES["Blue"] = 2
    end
end

function activateResurrectButton()
    local resurrectButton = getResurrectButton()
    if resurrectButton and (resurrectButton.position.y < -1) then
        self.editButton({index = RESURRECT_BUTTON_INDEX, position= resurrectButton.position + Vector(0, 2, 0)})
    end
    local playerResurrectButton = getPlayerResurrectButton()
    if playerResurrectButton then
        for color, index in pairs(PLAYER_RESURRECT_BUTTON_INDICES) do
            if playerResurrectButton[color].position.y < -1 then
                self.editButton({index = index, position = playerResurrectButton[color].position + Vector(0, 2, 0)})
            end
        end
    end
end

local function deactivateResurrectButton(exceptIndex)
    local resurrectButton = getResurrectButton()
    if resurrectButton and (resurrectButton.position.y > -1) and (RESURRECT_BUTTON_INDEX ~= exceptIndex) then
        self.editButton({index = RESURRECT_BUTTON_INDEX, position = resurrectButton.position + Vector(0, -2, 0)})
    end
    local playerResurrectButton = getPlayerResurrectButton()
    if playerResurrectButton then
        for color, index in pairs(PLAYER_RESURRECT_BUTTON_INDICES) do
            if (index ~= exceptIndex) and playerResurrectButton[color].position.y > -1 then
                self.editButton({index = index, position = playerResurrectButton[color].position + Vector(0, -2, 0)})
            end
        end
    end
end

local function resetResurrectButton(exceptIndex)
    if RESURRECT_BUTTON_INDEX and (RESURRECT_BUTTON_INDEX ~= exceptIndex) then
        self.editButton({index = RESURRECT_BUTTON_INDEX, label = RESURRECT_BUTTON_STATES.ADD_MINION})
    end
    for _, index in pairs(PLAYER_RESURRECT_BUTTON_INDICES) do
        if index ~= exceptIndex then
            self.editButton({index = index, label = RESURRECT_BUTTON_STATES.ADD_MINION})
        end
    end
end

function resetAltClickCounter()
    altClickCounter = 0
end

local function altClickAttackButton(zone, color)
    local clickCounter = zone.getVar("altClickCounter")
    if clickCounter > 0 then
        -- Reset all Monster-Zones
        local attackButtonState = zone.call("getAttackButton").label
        if attackButtonState == ATTACK_BUTTON_STATES.ATTACKING then
            click_function_AttackButton(zone, color, false)
        elseif attackButtonState == ATTACK_BUTTON_STATES.DIED then
            changeMinionZoneState({zone = zone, newState = ATTACK_BUTTON_STATES.ATTACK})
        end
        zone.call("deactivateZone")
    else
        zone.setVar("altClickCounter", clickCounter + 1)
        Timer.create(getDoubleAltClickParameters(zone))
    end
end

local function altClickBossButton(color)
    if altClickCounter > 0 then
        -- Reset all Monster-Zones
        local bossButtonState = getBossButton().label
        if bossButtonState == BOSS_BUTTON_STATES.INACTIVE then
            changeBossZoneState({newState = BOSS_BUTTON_STATES.ATTACK})
        elseif bossButtonState == BOSS_BUTTON_STATES.ATTACKING then
            click_function_BossButton(zone, color, false)
            deactivateZone()
        elseif bossButtonState == BOSS_BUTTON_STATES.DIED then
            changeBossZoneState({newState = BOSS_BUTTON_STATES.ATTACK})
            deactivateZone()
        else
            deactivateZone()
        end
    else
        altClickCounter = altClickCounter + 1
        Timer.create(getDoubleAltClickParameters(self))
    end
end

function deactivateAllAttackButtons(params)
    local ignoreOwnButton = false
    local zone = nil
    local exceptionStates = {}
    if params.ignoreOwnButton == true then
        ignoreOwnButton = true
        zone = params.zone
        if params.exceptionStates then
            exceptionStates = params.exceptionStates
        end
    end

    ignoreOwnButton = (ignoreOwnButton == true)
    exceptionStates = exceptionStates or {}
    for _ , guid in pairs(MONSTER_ZONE_GUIDS) do
        local monsterZone = getObjectFromGUID(guid)
        if (not ignoreOwnButton) or (monsterZone.getGUID() ~= zone.guid) then
            local zoneState = monsterZone.call("getState")
            for _ , state in pairs(exceptionStates) do
                if zoneState == state then
                    goto nextMonsterZone
                end
            end
            monsterZone.call("deactivateAttackButton")
        end
        ::nextMonsterZone::
    end
    for _ , zoneInfo in pairs(MINION_ZONE_INFO) do
        local minionZone = getObjectFromGUID(zoneInfo.guid)
        if (not ignoreOwnButton) or (zoneInfo.guid ~= zone.guid) then
            if minionZone then
                local zoneState = minionZone.call("getState")
                for _ , state in pairs(exceptionStates) do
                    if zoneState == state then
                        goto nextMinionZone
                    end
                end
                minionZone.call("deactivateAttackButton")
            end
        end
        ::nextMinionZone::
    end

    if (not ignoreOwnButton) or (self.getGUID() ~= zone.getGUID()) then
        local zoneState = getState()
        for _ , state in pairs(exceptionStates) do
            if zoneState == state then
                goto skip
            end
        end
        deactivateBossButton()
        ::skip::
    end

    getObjectFromGUID(MONSTER_DECK_ZONE_GUID).call("deactivateChooseButton")
end

function activateAllAttackButtons()
    for _ , guid in pairs(MONSTER_ZONE_GUIDS) do
        getObjectFromGUID(guid).call("activateAttackButton")
    end
    for _ , zoneInfo in pairs(MINION_ZONE_INFO) do
        local minionZone = getObjectFromGUID(zoneInfo.guid)
        if minionZone and minionZone.getVar("active") then
            minionZone.call("activateAttackButton")
        end
    end
    activateBossButton()
    activateResurrectButton()
    getObjectFromGUID(MONSTER_DECK_ZONE_GUID).call("activateChooseButton")
end

function resetAllAttackButtons()
    for _, guid in pairs(MONSTER_ZONE_GUIDS) do
        getObjectFromGUID(guid).call("resetAttackButton")
    end
    for _, zoneInfo in pairs(MINION_ZONE_INFO) do
        getObjectFromGUID(zoneInfo.guid).call("resetAttackButton")
    end
    for _, guid in pairs(MINION_SLOT_GUIDS) do
        getObjectFromGUID(guid).call("deactivateSlotButton")
    end
    activateBossButton()
    activateResurrectButton()
    getObjectFromGUID(MONSTER_DECK_ZONE_GUID).call("resetChooseButton")
    getObjectFromGUID(MONSTER_DISCARD_ZONE_GUID).call("resetDiscardButton")
end

function deactivateAllChallengeButtons()
    for _ , zoneInfo in pairs(MINION_ZONE_INFO) do
        local minionZone = getObjectFromGUID(zoneInfo.guid)
        minionZone.call("deactivateAttackButton")
    end
    deactivateBossButton()

    deactivateResurrectButton()
end

function activateAllChallengeButtons()
    for _ , zoneInfo in pairs(MINION_ZONE_INFO) do
        local minionZone = getObjectFromGUID(zoneInfo.guid)
        if minionZone.getVar("active") then
            minionZone.call("activateAttackButton")
        end
    end
    activateBossButton()

    activateResurrectButton()
end

function setupZone()
    createResurrectButton()
    for _, zoneInfo in pairs(MINION_ZONE_INFO) do
        if zoneInfo.owner then
            createPlayerResurrectButtons()
            break
        end
    end
    activateBossButton()
end

function killMonster()
    getObjectFromGUID(HP_COUNTER_GUID).call("updateHP", {HP = 0})
    monsterDied()
end

function monsterDied()
    if active then
        getObjectFromGUID(HP_COUNTER_GUID).call("updateHP", {HP = 0})
        local attackButton = getBossButton()
        if attackButton then
            LAST_STATE = attackButton.label
            broadcastToAll(Global.getTable("PRINT_COLOR_SPECIAL").MINION .. active_monster_attrs.NAME
                .. "[-] got killed !!!")
            changeBossZoneState({zone = self, newState = BOSS_BUTTON_STATES.DIED})
        end
    end
end

function monsterReanimated()
    if active and active_monster_attrs.HP ~= 0 then
        broadcastToAll(Global.call("getActivePlayerString") .. " fucked up. "
            .. Global.getTable("PRINT_COLOR_SPECIAL").MINION .. active_monster_attrs.NAME .. "[-] is undead ???")
        if getState() == BOSS_BUTTON_STATES.SELECT then
            LAST_STATE = BOSS_BUTTON_STATES.ATTACKING
        elseif LAST_STATE == BOSS_BUTTON_STATES.ATTACKING then
            changeBossZoneState({zone = self, newState = BOSS_BUTTON_STATES.ATTACKING})
        else
            changeBossZoneState({zone = self, newState = BOSS_BUTTON_STATES.ATTACK})
        end
    end
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

function finishMonster(params)
    local selected = false
    if params then
        selected = (params.selected == true)
    end
    local monsterDeckZone = getObjectFromGUID(MONSTER_DECK_ZONE_GUID)

    local activePlayerColor = Global.getVar("activePlayerColor")
    local monsterCard = getActiveMonsterCard()
    if monsterCard == nil then
        return nil
    end

    COUNTER_MODULE.call("notifyKILL", {player = activePlayerColor, dif = 1})

    if Global.getTable("PLAYER_SETTINGS")[activePlayerColor].rewarding then
        local rewarded = monsterDeckZone.call("payOutRewards", {playerColor = activePlayerColor, rewardTable = active_monster_reward})
        if rewarded then
            broadcastToAll(Global.call("getActivePlayerString") .. " got rewards for killing "
                .. Global.getTable("PRINT_COLOR_SPECIAL").MINION .. active_monster_attrs.NAME .. "[-] !!!")
        end
    end
    -- OnDie
    Wait.frames(function ()
            if not selected then
                -- Place discard monster card
                if active_monster_reward.SOULS ~= 0 then    -- Monster becomes soul token
                    Global.call("placeObjectInSoulZone", {playerColor = activePlayerColor, object = monsterCard})
                else
                    monsterCard.setPositionSmooth(Global.getTable("CHALLENGE_LEFTOVERS_POSITION") - Vector(0, 0, 5), false)
                end
            end
            --default: true, only false on false
            local died = not (monsterCard.call("onDie", {zone = self, selected = selected}) == false)
            if died then        --if monster died it will tagged as dead
                local deadTag = MONSTER_TAGS.DEAD
                monsterCard.addTag(deadTag)
                Wait.condition(function() monsterCard.removeTag(deadTag) end
                    , function() return not monsterCard.isSmoothMoving() end)
            end
        end)
    return monsterCard
end

------------------------------------------------------------------------------------------------------------------------

function onLoad(saved_data)
    COUNTER_MODULE = getObjectFromGUID(Global.getVar("COUNTER_MODULE_GUID"))
    MINION_ZONE_INFO = Global.getTable("ZONE_INFO_MINION")
    ATTACK_BUTTON_STATES = getObjectFromGUID(MONSTER_DECK_ZONE_GUID).getTable("ATTACK_BUTTON_STATES")
    BOSS_BUTTON_STATES = ATTACK_BUTTON_STATES
    MINION_SLOT_BUTTON_STATES = ATTACK_BUTTON_STATES
    DISCARD_PILE_POSITION = Global.getTable("DISCARD_PILE_POSITION").MONSTER
    for _, snapPoint in pairs(Global.getSnapPoints()) do
        if math.abs(snapPoint.position.x - self.getPosition().x) < 5 then
            if math.abs(snapPoint.position.z - self.getPosition().z) < 5 then
                for _, tag in pairs(snapPoint.tags) do
                    if tag == "COUNTER" then
                        BOSS_COUNTER_POSITION = snapPoint.position:setAt('y', 5)
                    end
                end
            end
        end
    end
    if Global.call("hasGameStarted") then
        createResurrectButton()
        for _, zoneInfo in pairs(MINION_ZONE_INFO) do
            if zoneInfo.owner then
                createPlayerResurrectButtons()
                break
            end
        end
    end

    if saved_data == "" then
        return
    end

    local loaded_data = JSON.decode(saved_data)
    if loaded_data.active == false then
        active = false
    end
    if loaded_data.currentLabel then
        activateBossButton()
        for _ , state in pairs(BOSS_BUTTON_STATES) do
            if state == loaded_data.currentLabel then
                self.editButton({index = BOSS_BUTTON_INDEX, label = state
                    , tooltip = getBossButtonTooltip(state)})
            end
        end
    end
    if loaded_data.monsterAttrs then
        local attrs = loaded_data.monsterAttrs
        active_monster_attrs.GUID = attrs.GUID or ""
        active_monster_attrs.NAME = attrs.NAME or "Unkown"
        active_monster_attrs.HP = attrs.HP or 0
        active_monster_attrs.ATK = attrs.ATK or 0
        active_monster_attrs.DMG = attrs.DMG or 0
        active_monster_attrs.INDOMITABLE = attrs.INDOMITABLE or false
    end
    if loaded_data.monsterRewards then
        local reward = loaded_data.monsterRewards
        active_monster_reward.CENTS = reward.CENTS or 0
        active_monster_reward.LOOT = reward.LOOT or 0
        active_monster_reward.TREASURES = reward.TREASURES or 0
        active_monster_reward.SOULS = reward.SOULS or 0
    end
    if loaded_data.hpCounterGuid then
        HP_COUNTER_GUID = loaded_data.hpCounterGuid
        getObjectFromGUID(HP_COUNTER_GUID).call("setZone", {zoneGuid = self.getGUID()})
    end
    if loaded_data.minionSlotGuids then
        MINION_SLOT_GUIDS = loaded_data.minionSlotGuids
    end
    if loaded_data.lastState then
        LAST_STATE = loaded_data.lastState
    end
    if loaded_data.onlyMonsterMinions then
        ONLY_MONSTER_MINIONS = loaded_data.onlyMonsterMinions
    end
    if loaded_data.noMinionRewards then
        NO_MINION_REWARDS = loaded_data.noMinionRewards
    end
end

function onSave()
    local currentLabel = nil
    if getBossButton() then
        currentLabel = getBossButton().label
    end
    return JSON.encode({active = active, currentLabel = currentLabel, monsterAttrs = active_monster_attrs
        , monsterRewards = active_monster_reward, hpCounterGuid = HP_COUNTER_GUID, minionSlotGuids = MINION_SLOT_GUIDS
        , lastState = LAST_STATE, onlyMonsterMinions = ONLY_MONSTER_MINIONS, noMinionRewards = NO_MINION_REWARDS})
end

function discardMonsterObject(params)
    if params.object == nil then
        Global.call("printWarning", {text = "Wrong parameters in 'boss' function 'discardMonsterObject()'."})
    end
    params.object.addTag(MONSTER_TAGS.DEAD)
    params.object.setPositionSmooth(DISCARD_PILE_POSITION)
    Wait.condition(function() params.object.removeTag(MONSTER_TAGS.DEAD) end
        , function() return not params.object.isSmoothMoving() end)
end

function resetBossZone()
    if BOSS_BUTTON_INDEX == nil then
        activateBossButton()
    else
        local state = active and BOSS_BUTTON_STATES.ATTACK or BOSS_BUTTON_STATES.INACTIVE
        self.editButton({index = BOSS_BUTTON_INDEX, label = state
                , tooltip = getBossButtonTooltip(state)})
    end
    getObjectFromGUID(HP_COUNTER_GUID).call("reset")
end

function resetAllMinionZones()
    for _ , zoneInfo in pairs(MINION_ZONE_INFO) do
        getObjectFromGUID(zoneInfo.guid).call("resetMinionZone")
    end
end

-- If you want state depending tooltips, there you go :D
function getAttackButtonTooltip(params)
    -- params.newState
    return "[i]Left-Click: Activate Zone[/i]\n[i]Double-Right-Click: Deactivate Zone[/i]"
end

-- If you want state depending tooltips, there you go :D
function getBossButtonTooltip(params)
    -- params.newState
    return "[i]Double-Right-Click: Activate Zone[/i]\n[i]Double-Right-Click: Deactivate Zone[/i]"
end

function changeMinionZoneState(params)
    local zone = params.zone
    local newState = params.newState or zone.getVar("LAST_STATE")
    if zone == nil or newState == nil then
        return
    end
    local currentState = zone.call("getState")
    if currentState ~= nil then
        zone.setVar("LAST_STATE", currentState)
    end
    if newState == ATTACK_BUTTON_STATES.INACTIVE then
        activateAllAttackButtons()
        if zone.getVar("active") then
            zone.call("deactivateZone")
        end
    elseif newState == ATTACK_BUTTON_STATES.ATTACK then
        activateAllAttackButtons()
        if not zone.getVar("active") then
            zone.call("activateZone", {})
        else
            zone.editButton({index = zone.getVar("ATTACK_BUTTON_INDEX"), label = ATTACK_BUTTON_STATES.ATTACK
                    , tooltip = getAttackButtonTooltip({newState = ATTACK_BUTTON_STATES.ATTACK})})
        end
    elseif newState == ATTACK_BUTTON_STATES.ATTACKING then
        if zone.getVar("active") then
            zone.call("activateAttackButton")
            zone.editButton({index = zone.getVar("ATTACK_BUTTON_INDEX"), label = ATTACK_BUTTON_STATES.ATTACKING
                    , tooltip = getAttackButtonTooltip({newState = ATTACK_BUTTON_STATES.ATTACKING})})
            deactivateAllAttackButtons({zone = zone, ignoreOwnButton = true})
        end
    elseif newState == ATTACK_BUTTON_STATES.DIED then
        if zone.getVar("active") then
            zone.call("activateAttackButton")
            if (zone.getVar("LAST_STATE") ~= ATTACK_BUTTON_STATES.SELECT) or params.force then
                zone.editButton({index = zone.getVar("ATTACK_BUTTON_INDEX"), label = ATTACK_BUTTON_STATES.DIED
                    , tooltip = getAttackButtonTooltip({newState = ATTACK_BUTTON_STATES.DIED})})
            else
                zone.setVar("LAST_STATE", ATTACK_BUTTON_STATES.DIED)
            end
            deactivateAllAttackButtons({zone = zone, ignoreOwnButton = true})
        end
    elseif newState == ATTACK_BUTTON_STATES.EVENT then
        if zone.getVar("active") then
            zone.call("activateAttackButton")
            zone.editButton({index = zone.getVar("ATTACK_BUTTON_INDEX"), label = ATTACK_BUTTON_STATES.EVENT
                , tooltip = getAttackButtonTooltip({newState = ATTACK_BUTTON_STATES.EVENT})})
            deactivateAllAttackButtons({zone = zone, ignoreOwnButton = true})
        end
    elseif newState == ATTACK_BUTTON_STATES.SELECT then
        if zone.getVar("active") then
            if zone.call("getAttackButton") ~= nil then
                if params.stateParams then
                    STATE_PARAMS = params.stateParams
                    zone.editButton({index = zone.getVar("ATTACK_BUTTON_INDEX"), label = ATTACK_BUTTON_STATES.SELECT
                        , tooltip = getAttackButtonTooltip({newState = ATTACK_BUTTON_STATES.SELECT})})
                end
            end
        else
            zone.call("deactivateAttackButton")
        end
    end
end

function onObjectEnterScriptingZone(zone, object)
    if self.getGUID() == zone.getGUID() and (not object.hasTag(MONSTER_TAGS.DEAD)) then
        if active then
            if object.type == "Card" then

                -- Attributes
                local newAttributes = {}
                newAttributes.GUID = object.getGUID()
                newAttributes.NAME = object.getName()
                newAttributes.HP = object.getVar("hp") or 0
                newAttributes.ATK = object.getVar("dice")
                newAttributes.DMG = object.getVar("atk")
                newAttributes.INDOMITABLE = object.hasTag(MONSTER_TAGS.INDOMITABLE)

                -- Rewards
                local rewards = object.getTable("rewards") or {}
                updateAttributes(newAttributes)
                updateRewards(rewards)

                object.call("onReveal", {zone = zone})
            end
        end
    else
        if not Global.call("hasGameStarted") or (object.hasTag(MONSTER_TAGS.DEAD)) then
            return
        end
        for i, zoneInfo in pairs(MINION_ZONE_INFO) do
            if zoneInfo.guid == zone.getGUID() then
                if (object.type == "Card") and (not zone.getVar("active")) then
                    Wait.frames(function()
                        if not object.hasTag(MONSTER_TAGS.DEAD) then
                            if (not zone.getVar("active")) then
                                zone.call("activateZone")
                            end

                            -- Attributes
                            local newAttributes = {}
                            newAttributes.GUID = object.getGUID()
                            newAttributes.NAME = object.getName()
                            newAttributes.HP = object.getVar("hp") or 0
                            newAttributes.ATK = object.getVar("dice")
                            newAttributes.DMG = object.getVar("atk")
                            newAttributes.INDOMITABLE = object.hasTag(MONSTER_TAGS.INDOMITABLE)
                            -- Rewards
                            local rewards = object.getTable("rewards") or {}

                            zone.call("updateAttributes", newAttributes)
                            zone.call("updateRewards", rewards)

                            getObjectFromGUID(MONSTER_DECK_ZONE_GUID).call("callNewMonsterEvents", {guid = object.getGUID(), zone = zone, isMinion = true})

                            local revealed = false
                            if object.hasTag(MONSTER_TAGS.NEW) then
                                revealed = not (object.call("onReveal", {zone = zone}) == false)    -- Standard is true
                                object.removeTag(MONSTER_TAGS.NEW)
                            end
                            if object.getVar("isEvent") and revealed then
                                changeMinionZoneState({zone = zone, newState = ATTACK_BUTTON_STATES.EVENT})
                                local eventType = object.getVar("eventType")
                                if eventType == getObjectFromGUID(MONSTER_DECK_ZONE_GUID).getTable("EVENT_TYPES").CURSE then
                                    local coloredCurseName = Global.getTable("PRINT_COLOR_SPECIAL").MONSTER_LIGHT
                                        .. object.getName()
                                    Global.call("colorPicker_attach", {afterPickFunction = "dealEventToPlayer"
                                        , functionOwner = zone, reason = coloredCurseName})
                                end
                            end
                        end
                    end)
                end
            end
        end
    end
end

function onObjectLeaveScriptingZone(zone, object)
    if self.getGUID() == zone.getGUID() and active then
        if object.hasTag(MONSTER_TAGS.DEAD) and (object.getGUID() == active_monster_attrs.GUID) then
            object.setScale({1, 1, 1})
        elseif objectContainsGUID(object, active_monster_attrs.GUID) then
            for _ , obj in pairs(self.getObjects()) do
                if obj.tag == "Card" then
                    -- Attributes
                    local newAttributes = {}
                    newAttributes.GUID = obj.getGUID()
                    newAttributes.NAME = obj.getName()
                    newAttributes.HP = obj.getVar("hp") or 0
                    newAttributes.ATK = obj.getVar("dice")
                    newAttributes.DMG = obj.getVar("atk")
                    newAttributes.INDOMITABLE = obj.hasTag(MONSTER_TAGS.INDOMITABLE)

                    -- Rewards
                    local rewards = obj.getTable("rewards") or {}
                    updateAttributes(newAttributes)
                    updateRewards(rewards)
                    break
                end
            end
        end
    else
        for i, zoneInfo in pairs(MINION_ZONE_INFO) do
            if zoneInfo.guid == zone.getGUID() and zone.getVar("active") then
                if objectContainsGUID(object, zone.getTable("active_monster_attrs").GUID) then
                    changeMinionZoneState({zone = zone, newState = ATTACK_BUTTON_STATES.INACTIVE})
                end
            end
        end
    end
end

function click_function_AttackButton(zone, color, alt_click)
    if Global.getVar("activePlayerColor") == color or Player[color].admin then
        if alt_click then
            altClickAttackButton(zone, color)
            return
        end
        local attackButtonState = zone.call("getState")
        if attackButtonState == ATTACK_BUTTON_STATES.INACTIVE then
            zone.call("activateZone", {})
        elseif attackButtonState == ATTACK_BUTTON_STATES.ATTACK then
            if printAttackPhrase(zone.getTable("active_monster_attrs").NAME) then
                changeMinionZoneState({zone = zone, newState = ATTACK_BUTTON_STATES.ATTACKING})
            end
        elseif attackButtonState == ATTACK_BUTTON_STATES.ATTACKING then
            local minionName = zone.getTable("active_monster_attrs").NAME
            if minionName == "" then
                Global.call("printWarning", {text = "There is no active minion to attack. The attribute 'NAME' is empty."})
            else
                broadcastToAll(Global.call("getActivePlayerString") .. " cancels the Attack on "
                                .. Global.getTable("PRINT_COLOR_SPECIAL").MINION .. minionName .. "[-] !!!")
            end
            changeMinionZoneState({zone = zone, newState = ATTACK_BUTTON_STATES.ATTACK})
        elseif attackButtonState == ATTACK_BUTTON_STATES.DIED then
            zone.call("finishMonster", {noRewards = NO_MINION_REWARDS})
            changeMinionZoneState({zone = zone, newState = ATTACK_BUTTON_STATES.ATTACK})
        elseif attackButtonState == ATTACK_BUTTON_STATES.EVENT then
            zone.call("discardActiveMonster")
        elseif attackButtonState == ATTACK_BUTTON_STATES.SELECT then
            local LAST_STATE = zone.getVar("LAST_STATE")
            local selectedCard = nil
            if LAST_STATE == ATTACK_BUTTON_STATES.DIED then
                selectedCard = zone.call("finishMonster", {selected = true, noRewards = NO_MINION_REWARDS})
            end
            if selectedCard == nil then
                selectedCard = zone.call("getActiveMonsterCard")
            end
            if selectedCard == nil then
                Global.call("printWarning", {text = "Can't find a real monster card in this minion zone: " .. zone.getGUID() .. "."})
            else
                STATE_PARAMS.function_owner.call(STATE_PARAMS.call_function, {card = selectedCard, isMinion = true})
            end
        else
            Global.call("printWarning", {text = "Unknown minion button state: " .. tostring(attackButtonState) .. "."})
        end
    end
end

function click_function_BossButton(_, color, alt_click)
    if Global.getVar("activePlayerColor") == color or Player[color].admin then
        if alt_click then
            altClickBossButton(color)
            return
        end
        local bossButtonState = getState()
        if bossButtonState == BOSS_BUTTON_STATES.INACTIVE then
            --nothing
        elseif bossButtonState == BOSS_BUTTON_STATES.ATTACK then
            if printAttackPhrase(active_monster_attrs.NAME) then
                changeBossZoneState({newState = BOSS_BUTTON_STATES.ATTACKING})
            end
        elseif bossButtonState == BOSS_BUTTON_STATES.ATTACKING then
            local bossName = active_monster_attrs.NAME
            if bossName == "" then
                Global.call("printWarning", {text = "There is no active minion to attack. The attribute 'NAME' is empty."})
            else
                broadcastToAll(Global.call("getActivePlayerString") .. " cancels the Attack on "
                                .. Global.getTable("PRINT_COLOR_SPECIAL").MINION .. bossName .. "[-] !!!")
            end
            changeBossZoneState({newState = BOSS_BUTTON_STATES.ATTACK})
        elseif bossButtonState == BOSS_BUTTON_STATES.DIED then
            finishMonster()
            changeBossZoneState({newState = BOSS_BUTTON_STATES.ATTACK})
        else
            Global.call("printWarning", {text = "Unknown minion button state: " .. tostring(bossButtonState) .. "."})
        end
    end
end

local function getNextFreeMinionZone(startIndex, zoneOwner)
    startIndex = startIndex or 1
    for index, zoneInfo in ipairs(MINION_ZONE_INFO) do
        if (not tempBlockedMinionZones[index]) and (zoneInfo.owner == zoneOwner) then
            if index >= startIndex then
                local minionZone = getObjectFromGUID(zoneInfo.guid)
                if not minionZone.getVar("active") then
                    tempBlockedMinionZones[index] = true
                    Timer.create(getTimerParameters(index))
                    return minionZone
                end
            end
        end
    end
    return nil
end

function placeMinion(params)
    local minionZone = nil
    if params.card == nil then
        Global.call("printWarning", {text = "Wrong parameters in 'boss' function 'placeMinion()'."})
        return
    end

    local isCardInRightZone = false
    if params.isMinion then
        for _, zoneInfo in pairs(MINION_ZONE_INFO) do
            if zoneInfo.owner == params.zoneOwner then
                local activeMonster = getObjectFromGUID(zoneInfo.guid).call("getActiveMonsterCard")
                if activeMonster and (activeMonster.getGUID() == params.card.getGUID()) then
                    isCardInRightZone = true
                    break
                end
            end
        end
    end
    if isCardInRightZone then
        params.card.setPositionSmooth(params.card.getPosition():setAt('y', 5), false)
        params.card.addTag(MONSTER_TAGS.DEAD)
        Wait.condition(function() params.card.addTag(MONSTER_TAGS.NEW); params.card.removeTag(MONSTER_TAGS.DEAD) end
            , function() return not params.card.isSmoothMoving() end)
    else
        if params.zone then
            minionZone = params.zone
        else
            minionZone = getNextFreeMinionZone(params.startIndex, params.zoneOwner)
            if minionZone == nil then
                local playerColor = params.zoneOwner
                if playerColor == nil then
                    playerColor = Global.getVar("activePlayerColor")
                end
                local handInfo = Global.call("getHandInfo")[playerColor]
                params.card.deal(1, handInfo.owner, handInfo.index)
                return
            end
        end

        params.card.addTag(MONSTER_TAGS.DEAD)
        Wait.condition(function() params.card.addTag(MONSTER_TAGS.NEW); params.card.removeTag(MONSTER_TAGS.DEAD) end
            , function() return not params.card.isSmoothMoving() end)

        params.card.setRotationSmooth(minionZone.getRotation():setAt('y', 180))
        params.card.setPositionSmooth(minionZone.getPosition():setAt('y', 5), false)
    end
    broadcastToAll(Global.getTable("PRINT_COLOR_SPECIAL").MINION .. params.card.getName() .. "[-] is now a Minion !!!")
end

local function callbackFunctionSelect(params)
    resetResurrectButton()
    resetAllAttackButtons()

    if params.card == nil then
        broadcastToAll("Couldn't find a " .. Global.getTable("PRINT_COLOR_SPECIAL").MINION .. "Minion[-] in this zone!!!")
    else
        placeMinion(params)
    end
end

function callbackFunctionSelect_Default(params)
    callbackFunctionSelect(params)
end

function callbackFunctionSelect_Red(params)
    params["zoneOwner"] = "Red"
    callbackFunctionSelect(params)
end

function callbackFunctionSelect_Blue(params)
    params["zoneOwner"] = "Blue"
    callbackFunctionSelect(params)
end

local function resurrectButtonClick(clickerColor, resurrectButtonIndex, resurrectButtonOwner)
    resurrectButtonOwner = resurrectButtonOwner or "Default"
    if Global.getVar("activePlayerColor") == clickerColor or Player[clickerColor].admin then
        local monsterDeckZone = getObjectFromGUID(MONSTER_DECK_ZONE_GUID)
        local monsterDiscardZone = getObjectFromGUID(MONSTER_DISCARD_ZONE_GUID)
        local resurrectButtonState = getResurrectState(resurrectButtonIndex)
        if resurrectButtonState == RESURRECT_BUTTON_STATES.ADD_MINION then
            local stateParams = {function_owner = self, call_function = "callbackFunctionSelect_" .. resurrectButtonOwner
                , onlyMonster = ONLY_MONSTER_MINIONS, random = true}

            for _ , guid in pairs(MONSTER_ZONE_GUIDS) do
                monsterDeckZone.call("changeZoneState", {zone = getObjectFromGUID(guid)
                    , newState = ATTACK_BUTTON_STATES.SELECT, stateParams = stateParams})
            end
            for _ , zoneInfo in pairs(MINION_ZONE_INFO) do
                local minionZone = getObjectFromGUID(zoneInfo.guid)
                changeMinionZoneState({zone = minionZone, newState = ATTACK_BUTTON_STATES.SELECT, stateParams = stateParams})
            end
            for _, guid in pairs(MINION_SLOT_GUIDS) do
                getObjectFromGUID(guid).call("changeZoneState", {newState = MINION_SLOT_BUTTON_STATES.SELECT, stateParams = stateParams})
            end
            monsterDeckZone.call("changeChooseZoneState", {newState = ATTACK_BUTTON_STATES.SELECT, stateParams = stateParams})
            monsterDiscardZone.call("changeZoneState", {newState = ATTACK_BUTTON_STATES.SELECT, stateParams = stateParams})
            self.editButton({index = resurrectButtonIndex, label = RESURRECT_BUTTON_STATES.ADDING})
            deactivateBossButton()
        elseif resurrectButtonState == RESURRECT_BUTTON_STATES.ADDING then
            for _, guid in pairs(MONSTER_ZONE_GUIDS) do
                local monsterZone = getObjectFromGUID(guid)
                if monsterZone.call("getState") then
                    monsterDeckZone.call("changeZoneState", {zone = monsterZone, force = true})
                end
            end
            for _, zoneInfo in pairs(MINION_ZONE_INFO) do
                local minionZone = getObjectFromGUID(zoneInfo.guid)
                if minionZone.call("getState") then
                    changeMinionZoneState({zone = minionZone, force = true})
                end
            end
            for _, guid in pairs(MINION_SLOT_GUIDS) do
                getObjectFromGUID(guid).call("deactivateSlotButton")
            end
            if monsterDeckZone.call("getState") then
                monsterDeckZone.call("changeChooseZoneState", {})
            end
            monsterDiscardZone.call("changeZoneState", {newState = ATTACK_BUTTON_STATES.INACTIVE})
            self.editButton({index = resurrectButtonIndex, label = RESURRECT_BUTTON_STATES.ADD_MINION})
            activateResurrectButton()
        end
    end
end

function click_function_ResurrectButton(_, color)
    resetResurrectButton(RESURRECT_BUTTON_INDEX)
    deactivateResurrectButton(RESURRECT_BUTTON_INDEX)
    resurrectButtonClick(color, RESURRECT_BUTTON_INDEX)
end

function click_function_ResurrectButton_Red(_, color)
    resetResurrectButton(PLAYER_RESURRECT_BUTTON_INDICES.Red)
    deactivateResurrectButton(PLAYER_RESURRECT_BUTTON_INDICES.Red)
    resurrectButtonClick(color, PLAYER_RESURRECT_BUTTON_INDICES.Red, "Red")
end

function click_function_ResurrectButton_Blue(_, color)
    resetResurrectButton(PLAYER_RESURRECT_BUTTON_INDICES.Blue)
    deactivateResurrectButton(PLAYER_RESURRECT_BUTTON_INDICES.Blue)
    resurrectButtonClick(color, PLAYER_RESURRECT_BUTTON_INDICES.Blue, "Blue")
end

------------------------------------------------ Boss Zone -------------------------------------------------------------
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

function activateZone()
    if active then
        Global.call("printWarning", {text = "Can't activate Zone: " .. self.guid .. ". This Zone is already active."})
    else
        local firstObjectInZone = self.getObjects()[2]
        if firstObjectInZone and (firstObjectInZone.tag == "Card") then
            firstObjectInZone.setPositionSmooth(self.getPosition():setAt('y', 2), false)
        end
        active = true

        if BOSS_BUTTON_INDEX == nil then
            activateBossButton()
        else
            self.editButton({index = BOSS_BUTTON_INDEX, label = BOSS_BUTTON_STATES.ATTACK
                , tooltip = getBossButtonTooltip(BOSS_BUTTON_STATES.ATTACK)
                , color = BOSS_BUTTON_COLORS.ACTIVE})
        end
    end
end

function deactivateZone()
    active = false

    if BOSS_BUTTON_INDEX == nil then
        activateBossButton()
    else
        self.editButton({index = BOSS_BUTTON_INDEX, label = BOSS_BUTTON_STATES.INACTIVE
            , tooltip = getBossButtonTooltip(BOSS_BUTTON_STATES.INACTIVE)
            , color = BOSS_BUTTON_COLORS.INACTIVE})
    end
end

function changeBossZoneState(params)
    if params.newState == nil then return end
    local newState = params.newState or LAST_STATE
    local currentState = getState()
    if currentState ~= nil then
        LAST_STATE = currentState
    end

    if newState == BOSS_BUTTON_STATES.INACTIVE then
        activateAllAttackButtons()
        activateResurrectButton()
        if active then
            deactivateZone()
        end
    elseif newState == BOSS_BUTTON_STATES.ATTACK then
        activateAllAttackButtons()
        activateResurrectButton()
        if not active then
            activateZone()
        else
            self.editButton({index = BOSS_BUTTON_INDEX, label = BOSS_BUTTON_STATES.ATTACK
                    , tooltip = getBossButtonTooltip({newState = BOSS_BUTTON_STATES.ATTACK})})
        end
    elseif newState == BOSS_BUTTON_STATES.ATTACKING then
        if active then
            activateBossButton()
            self.editButton({index = BOSS_BUTTON_INDEX, label = BOSS_BUTTON_STATES.ATTACKING
                    , tooltip = getBossButtonTooltip({newState = BOSS_BUTTON_STATES.ATTACKING})})
            deactivateAllAttackButtons({zone = self, ignoreOwnButton = true})
            deactivateResurrectButton()
        end
    elseif newState == BOSS_BUTTON_STATES.DIED then
        if active then
            activateBossButton()
            self.editButton({index = BOSS_BUTTON_INDEX, label = BOSS_BUTTON_STATES.DIED
                    , tooltip = getBossButtonTooltip({newState = BOSS_BUTTON_STATES.DIED})})
            deactivateAllAttackButtons({zone = self, ignoreOwnButton = true})
            deactivateResurrectButton()
        end
    end
end

function placeCounterOnBoss(params)
    if (params.type == nil) and (params.counter == nil) then
        Global.call("printWarning", {text = "Wrong parameters in boss zone function 'placeCounterOnBoss()'."})
        return
    end

    if params.counter then
        params.counter.setPositionSmooth(BOSS_COUNTER_POSITION, false)
        params.counter.setRotationSmooth(Vector(0, 180, 0))
    else
        local counterType = params.type
        local counterBag = getObjectFromGUID(Global.getTable("COUNTER_BAGS_GUID")[counterType])
        local amount = 1
        if params.amount then
            amount = params.amount
        end
        local position = BOSS_COUNTER_POSITION
        for i = 1, amount do
            local counter = counterBag.takeObject()
            counter.setPositionSmooth(position + Vector(0, 0.5 * i, 0), false)
            counter.setRotationSmooth(Vector(0, 180, 0))
        end
    end
end]]

local SCRIPT_MINION_SLOT =
[[--- Written by Ediforce44
active = true

LAST_STATE = nil

MONSTER_DECK_ZONE = getObjectFromGUID(Global.getTable("ZONE_GUID_DECK").MONSTER)
BOSS_ZONE = nil
MINION_SLOT_BUTTON_STATES = {}
MINION_SLOT_BUTTON_COLORS = {}
MINION_SLOT_BUTTON_INDEX = nil

TITLE_INDEX = nil

STATE_PARAMS = {}

local function containsDeckOrCard()
    for _ , obj in pairs(self.getObjects()) do
        if obj.tag == "Deck" or obj.tag == "Card" then
            return true
        end
    end
    return false
end

local function getTopMostDeckOrCard()
    local zoneObjects = self.getObjects()
    for index = #zoneObjects, 1, -1 do
        local object = zoneObjects[index]
        if object.type == "Deck" or object.type == "Card" then
            return object
        end
    end
    return nil
end

function getMinion()
    local object = getTopMostDeckOrCard()
    if object == nil then
        return nil
    elseif object.tag == "Deck" then
        return object.takeObject()
    elseif object.tag == "Card" then
        return object
    end
end

function getMinionSlotButton()
    if MINION_SLOT_BUTTON_INDEX == nil then
        return nil
    end

    return self.getButtons()[MINION_SLOT_BUTTON_INDEX + 1]
end

function getState()
    local slotButton = getMinionSlotButton()
    if slotButton == nil then
        return nil
    end
    return slotButton.label
end

function onLoad(saved_data)
    BOSS_ZONE = getObjectFromGUID(Global.getVar("ZONE_GUID_BOSS"))

    MINION_SLOT_BUTTON_STATES = BOSS_ZONE.getTable("MINION_SLOT_BUTTON_STATES")
    MINION_SLOT_BUTTON_COLORS = BOSS_ZONE.getTable("MINION_SLOT_BUTTON_COLORS")
    LAST_STATE = MINION_SLOT_BUTTON_STATES.SELECT

    if saved_data == "" then
        return
    end

    local loaded_data = JSON.decode(saved_data)

    if loaded_data.active == false then
        active = false
    end
    if loaded_data.currentLabel then
        LAST_STATE = loaded_data.currentLabel
    end
end

function onSave()
    local currentLabel = nil
    if getMinionSlotButton() then
        currentLabel = getMinionSlotButton().label
    end
    return JSON.encode({active = active, currentLabel = currentLabel})
end

function deactivateSlotButton()
    if MINION_SLOT_BUTTON_INDEX then
        self.removeButton(MINION_SLOT_BUTTON_INDEX)
        MINION_SLOT_BUTTON_INDEX = nil
    end
end

function activateSlotButton()
    if MINION_SLOT_BUTTON_INDEX == nil then
        MINION_SLOT_BUTTON_INDEX = 0
        local state = active and MINION_SLOT_BUTTON_STATES.SELECT or MINION_SLOT_BUTTON_STATES.INACTIVE
        local color = active and MINION_SLOT_BUTTON_COLORS.ACTIVE or MINION_SLOT_BUTTON_COLORS.INACTIVE
        self.createButton({
            click_function = "click_function_MinionSlotButton",
            function_owner = self,
            label          = state,
            position       = {0, 0, 2.5},
            width          = 1000,
            height         = 300,
            font_size      = 200,
            color          = color,
            font_color     = {1, 1, 1},
            tooltip        = BOSS_ZONE.call("getAttackButtonTooltip", {newState = state})
        })
    end
end

function activateZone()
    if active then
        Global.call("printWarning", {text = "Can't activate Zone: " .. self.guid .. ". This Zone is already active."})
    else
        active = true

        if MINION_SLOT_BUTTON_INDEX == nil then
            activateSlotButton()
        else
            self.editButton({index = MINION_SLOT_BUTTON_INDEX, label = MINION_SLOT_BUTTON_STATES.SELECT
                , tooltip = BOSS_ZONE.call("getAttackButtonTooltip", {newState = MINION_SLOT_BUTTON_STATES.SELECT})
                , color = MINION_SLOT_BUTTON_COLORS.ACTIVE})
        end
    end
end

function deactivateZone()
    active = false

    if MINION_SLOT_BUTTON_INDEX ~= nil then
        deactivateSlotButton()
    end
end

function changeZoneState(params)
    if params.newState == nil then return end
    local newState = params.newState or LAST_STATE
    local currentState = getState()
    if currentState ~= nil then
        LAST_STATE = currentState
    end

    if newState == MINION_SLOT_BUTTON_STATES.SELECT then
        if active and containsDeckOrCard() then
            if params.stateParams then
                STATE_PARAMS = params.stateParams
                if MINION_SLOT_BUTTON_INDEX == nil then
                    activateSlotButton()
                end
                self.editButton({index = MINION_SLOT_BUTTON_INDEX, label = MINION_SLOT_BUTTON_STATES.SELECT
                    , tooltip = BOSS_ZONE.call("getAttackButtonTooltip", {newState = MINION_SLOT_BUTTON_STATES.SELECT})})
            end
        end
    end
end

function click_function_MinionSlotButton(_, color)
    if Global.getVar("activePlayerColor") == color or Player[color].admin then
        local slotButtonState = getState()
        if slotButtonState == MINION_SLOT_BUTTON_STATES.SELECT then
            local selectedCard = getMinion()

            if selectedCard == nil then
                Global.call("printWarning", {text = "Can't find a real monster card in this minion zone: " .. zone.getGUID() .. "."})
            else
                STATE_PARAMS.function_owner.call(STATE_PARAMS.call_function, {card = selectedCard, isMinion = false})
            end
        else
            Global.call("printWarning", {text = "Unknown minion button state: " .. tostring(attackButtonState) .. "."})
        end
    end
end

function onObjectEnterScriptingZone(zone, object)
    if zone.getGUID() == self.getGUID() then
        if object.type == "Deck" then
            object.setName(self.getName())
        end
    end
end

function createTitle()
    local title = self.getName()
    if TITLE_INDEX then
        self.editInput({index = TITLE_INDEX, value = title})
    else
        local position = {0, 0.05, -2}
        if #title > 10 then
            position = {0, 0.05, -2.3}
        end
        self.createInput({
            value = title,
            input_function = "dummy",
            label = "Zone title",
            function_owner = self,
            alignment = 3,
            position = position,
            width = 1600,
            height = 1000,
            font_size = 300,
            scale={x=1, y=1, z=1},
            font_color= {1, 1, 1, 100},
            color = {0,0,0,0}
            })
    end
end

function dummy()
end

local tempMinionDeck = nil
function resetTempMinionDeck()
    tempMinionDeck = nil
end

function addMinionSmooth(params)
    local newMinion = params.card
    local deckOrCardInZone = getTopMostDeckOrCard()
    if deckOrCardInZone == nil then
        local rotation = self.getRotation():setAt('z', 180)
        if params.flip then
            rotation = rotation:setAt('z', 0)
        end
        newMinion.setRotationSmooth(rotation)
        newMinion.setPositionSmooth(self.getPosition():setAt('y', 5))
        return newMinion
    end

    newMinion.setRotationSmooth(deckOrCardInZone.getRotation())
    if params.bottom then
        deckOrCardInZone.setPositionSmooth(self.getPosition():setAt('y', 5))
        newMinion.setPositionSmooth(self.getPosition():setAt('y', 2))
    else
        newMinion.setPositionSmooth(self.getPosition():setAt('y', 5))
    end

    if params.shuffle then
        Wait.condition(function() Wait.frames(function() getTopMostDeckOrCard().shuffle() end) end
            , function() return
                (((deckOrCardInZone == nil) or deckOrCardInZone.resting) and (getObjectFromGUID(newMinion.getGUID()) == nil))
            end)
    end
    return nil
end

function addMinion(params)
    if params.card == nil then
        Global.call("printWarning", {text = "Wrong parameter in Minion Slot function 'addMinion()'."})
    end
    if params.smooth then
        return addMinionSmooth(params)
    end
    local newMinion = params.card
    local deckOrCardInZone = getTopMostDeckOrCard()
    if deckOrCardInZone == nil then
        if tempMinionDeck == nil then
            tempMinionDeck = newMinion
            Timer.create({identifier = "TempMinionDeckReset" .. self.guid, function_name = "resetTempMinionDeck", delay = 2})
            local rotation = self.getRotation():setAt('z', 180)
            if params.flip then
                rotation = rotation:setAt('z', 0)
            end
            newMinion.setRotation(rotation)
            newMinion.setPosition(self.getPosition())
            return newMinion
        else
            deckOrCardInZone = tempMinionDeck
        end
    end
    local minionDeck = nil
    if deckOrCardInZone.type == "Card" then
        local newMinionGuid = newMinion.getGUID()
        minionDeck = deckOrCardInZone.putObject(newMinion)
        if params.bottom then
            while(minionDeck.getObjects()[1].guid == newMinionGuid) do
                minionDeck.shuffle()
            end
        end
        tempMinionDeck = minionDeck
    elseif deckOrCardInZone.type == "Deck" then
        minionDeck = deckOrCardInZone
        if params.bottom then
            newMinion.setPosition(self.getPosition() + Vector(0, -2, 0))
        else
            newMinion.setPosition(self.getPosition() + Vector(0, 2, 0))
        end
        minionDeck.putObject(newMinion)
    end
    if params.shuffle then
        minionDeck.shuffle()
    end
    return minionDeck
end
]]

local SCRIPT_TREASURE_SLOT =
[[TITLE_INDEX = nil

local function getTopMostDeckOrCard()
    local zoneObjects = self.getObjects()
    for index = #zoneObjects, 1, -1 do
        local object = zoneObjects[index]
        if object.type == "Deck" or object.type == "Card" then
            return object
        end
    end
    return nil
end

function onObjectEnterScriptingZone(zone, object)
    if zone.getGUID() == self.getGUID() then
        if object.type == "Deck" then
            object.setName(self.getName())
        end
    end
end

function createTitle()
    local title = self.getName()
    if TITLE_INDEX then
        self.editInput({index = TITLE_INDEX, value = title})
    else
        local position = {0, 0.05, -2}
        if #title > 10 then
            position = {0, 0.05, -2.3}
        end
        self.createInput({
            value = title,
            input_function = "dummy",
            label = "Zone title",
            function_owner = self,
            alignment = 3,
            position = position,
            width = 1500,
            height = 1000,
            font_size = 300,
            scale={x=1, y=1, z=1},
            font_color= {1, 1, 1, 100},
            color = {0,0,0,0}
            })
        TITLE_INDEX = 0
    end
end

function dummy()
end

local tempTreasureDeck = nil
function resetTempTreasureDeck()
    tempTreasureDeck = nil
end

function addTreasureSmooth(params)
    local newTreasure = params.card
    local deckOrCardInZone = getTopMostDeckOrCard()
    if deckOrCardInZone == nil then
        local rotation = self.getRotation():setAt('z', 180)
        if params.flip then
            rotation = rotation:setAt('z', 0)
        end
        newTreasure.setRotationSmooth(rotation)
        newTreasure.setPositionSmooth(self.getPosition():setAt('y', 5))
        return newTreasure
    end

    newTreasure.setRotationSmooth(deckOrCardInZone.getRotation())
    if params.bottom then
        deckOrCardInZone.setPositionSmooth(self.getPosition():setAt('y', 5))
        newTreasure.setPositionSmooth(self.getPosition():setAt('y', 2))
    else
        newTreasure.setPositionSmooth(self.getPosition():setAt('y', 5))
    end

    if params.shuffle then
        Wait.condition(function() Wait.frames(function() getTopMostDeckOrCard().shuffle() end) end
            , function() return
                (((deckOrCardInZone == nil) or deckOrCardInZone.resting) and (getObjectFromGUID(newTreasure.getGUID()) == nil))
            end)
    end
    return nil
end

function addTreasure(params)
    if params.card == nil then
        Global.call("printWarning", {text = "Wrong parameter in Treasure Slot function 'addTreasure()'."})
    end
    if params.smooth then
        return addTreasureSmooth(params)
    end
    local newTreasure = params.card
    local deckOrCardInZone = getTopMostDeckOrCard()
    if deckOrCardInZone == nil then
        if tempTreasureDeck == nil then
            tempTreasureDeck = newTreasure
            Timer.create({identifier = "TempTreasureDeckReset" .. self.guid, function_name = "resetTempTreasureDeck", delay = 2})
            local rotation = self.getRotation():setAt('z', 180)
            if params.flip then
                rotation = rotation:setAt('z', 0)
            end
            newTreasure.setRotation(rotation)
            newTreasure.setPosition(self.getPosition())
            return newTreasure
        else
            deckOrCardInZone = tempTreasureDeck
        end
    end
    local treasureDeck = nil
    if deckOrCardInZone.type == "Card" then
        local newTreasureGuid = newTreasure.getGUID()
        treasureDeck = deckOrCardInZone.putObject(newTreasure)
        if params.bottom then
            while(treasureDeck.getObjects()[1].guid == newTreasureGuid) do
                treasureDeck.shuffle()
            end
        end
        tempTreasureDeck = treasureDeck
    elseif deckOrCardInZone.type == "Deck" then
        treasureDeck = deckOrCardInZone
        if params.bottom then
            newTreasure.setPosition(self.getPosition() + Vector(0, -2, 0))
        else
            newTreasure.setPosition(self.getPosition() + Vector(0, 2, 0))
        end
        treasureDeck.putObject(newTreasure)
    end
    if params.shuffle then
        treasureDeck.shuffle()
    end
    return treasureDeck
end

altClickCounter = 0

SLOT_BUTTON_STATES = {GAIN = "Gain", INACTIVE = "Inactive"}
SLOT_BUTTON_COLORS = {}
SLOT_BUTTON_INDEX = nil

USE_SLOT_BUTTON = false
slotButtonParams = nil

active = false

local function getSlotButton()
    if SLOT_BUTTON_INDEX == nil then
        return nil
    end
    return self.getButtons()[SLOT_BUTTON_INDEX + 1]
end

local function getDoubleAltClickParameters()
    DOUBLE_CLICK_PARAMETERS = {
        ["identifier"] = "AltClickTimer" .. self.guid,
        ["function_owner"] = self,
        ["function_name"] = "resetAltClickCounter",
        ["delay"] = Global.getVar("CLICK_DELAY")
    }
    return DOUBLE_CLICK_PARAMETERS
end

local function resetSlotButton()
    if altClickCounter > 0 then
        deactivateZone()
    else
        altClickCounter = altClickCounter + 1
        Timer.create(getDoubleAltClickParameters())
    end
end

local function getDeckOrCard()
    for _ , obj in pairs(self.getObjects()) do
        if obj.tag == "Deck" or obj.tag == "Card" then
            return obj
        end
    end
    return nil
end

function onLoad(saved_data)
    TREASURE_DECK_ZONE = getObjectFromGUID(Global.getTable("ZONE_GUID_DECK").TREASURE)
    SLOT_BUTTON_COLORS = TREASURE_DECK_ZONE.getTable("PURCHASE_BUTTON_COLORS")
    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        if loaded_data.useSlotButton then
            activateSlotButton()
            if loaded_data.currentLabel then
                for _ , state in pairs(SLOT_BUTTON_STATES) do
                    if state == loaded_data.currentLabel then
                        self.editButton({index = SLOT_BUTTON_INDEX, label = state})
                    end
                end
            end
        end
        if loaded_data.active == true then
            active = true
        end
        if loaded_data.buttonParams then
            slotButtonParams = loaded_data.buttonParams
        end
    end
end

function onSave()
    local currentLabel = nil
    if getSlotButton() then
        currentLabel = getSlotButton().label
    end
    return JSON.encode({active = active, currentLabel = currentLabel, buttonParams = slotButtonParams, useSlotButton = USE_SLOT_BUTTON})
end

function resetAltClickCounter()
    altClickCounter = 0
end

function activateZone()
    if SLOT_BUTTON_INDEX == nil then
        activateSlotButton()
    end
    self.editButton({index = SLOT_BUTTON_INDEX, label = SLOT_BUTTON_STATES.GAIN, color = SLOT_BUTTON_COLORS.ACTIVE})
    active = true
end

function deactivateZone()
    if SLOT_BUTTON_INDEX == nil then
        activatePurchaseButton()
    end
    self.editButton({index = SLOT_BUTTON_INDEX, label = SLOT_BUTTON_STATES.INACTIVE, color = SLOT_BUTTON_COLORS.INACTIVE})
    active = false
end

function activateSlotButton()
    if SLOT_BUTTON_INDEX == nil then
        SLOT_BUTTON_INDEX = 0
        local state = active and SLOT_BUTTON_STATES.GAIN or SLOT_BUTTON_STATES.INACTIVE
        local color = active and SLOT_BUTTON_COLORS.ACTIVE or SLOT_BUTTON_COLORS.INACTIVE
        self.createButton({
            click_function = "click_function_SlotButton",
            function_owner = self,
            label          = state,
            position       = {0, 0.05, 2.5},
            width          = 1000,
            height         = 300,
            font_size      = 200,
            color          = color,
            font_color     = {1, 1, 1},
            tooltip        = "[i]Left-Click: Activate this button[/i]\n[i]Double-Right-Click: Deactivate this button[/i]"
        })
    end
end

function click_function_SlotButton(_, color, alt_click)
    if slotButtonParams == nil then
        return
    end
    if alt_click then
        resetSlotButton()
        return
    end
    local slotButton = getSlotButton()
    if slotButton.label == SLOT_BUTTON_STATES.INACTIVE then
        activateZone()
        if slotButtonParams.call_function_inactive then
            local function_owner = getObjectFromGUID(slotButtonParams.function_owner)
            if function_owner then
                local function_params = slotButtonParams.function_params or {}
                function_params["deckOrCard"] = getDeckOrCard()
                function_params["playerColor"] = color
                function_params["slotZone"] = self
                function_owner.call(slotButtonParams.call_function_inactive, function_params)
            end
        end
    elseif slotButton.label == SLOT_BUTTON_STATES.GAIN then
        local function_owner = getObjectFromGUID(slotButtonParams.function_owner)
        if function_owner then
            local function_params = slotButtonParams.function_params or {}
            function_params["deckOrCard"] = getDeckOrCard()
            function_params["playerColor"] = color
            function_params["slotZone"] = self
            function_owner.call(slotButtonParams.call_function, function_params)
        end
    else
        Global.call("printWarning", {text = "Unknown treasure slot (challenge) button state: " .. tostring(slotButton.label) .. "."})
    end
end
]]

local BOSS_POS = Vector(-3.28, 1.5, 8.14)
local BOSS_COUNTER_OFFSET = 3.33
local BOSS_CUSTOM_COUNTER_OFFSET = Vector(-1.7, 0, 0.3)
local CRULE_POS = Vector(-3.28, 1.5, 14.8)
local CCOUNTER_ONE_POS = Vector(3.75, 1.5, 14.3)
local CCOUNTER_TWO_POS = Vector(-10.3, 1.5, 14.3)

local MINION_POS_START = Vector(15.64, 1.5, 7.95)
local MINION_POS_OFFSET_X = 3.33
local MINION_POS_OFFSET_Z = 6.32
local MINION_POS_AMOUNT_PER_ROW = 7
local MINION_COUNTER_OFFSET = 2.8
local MINIONE_POS_START = Vector(-22.19, 1.5, 7.95)

local CSLOT_POS_START = Vector(8.68, 1.5, 7.95)
local CSLOT_POS_OFFSET_X = MINION_POS_OFFSET_X
local CSLOT_POS_OFFSET_Z = MINION_POS_OFFSET_Z
local CSLOT_POS_AMOUNT_PER_ROW = 2
local CSLOTE_POS_START = Vector(-15.25, 1.5, 7.95)

local function getSnapPointsInArea(edgeTable)
    local snapPointsInArea = {}
    for _, snapPoint in pairs(Global.getSnapPoints()) do
        local snapPointPos = snapPoint.position
        if (snapPointPos.z > edgeTable.z2) and (snapPointPos.z < edgeTable.z1) then
            if (snapPointPos.x > edgeTable.x1) and (snapPointPos.x < edgeTable.x2) then
                table.insert(snapPointsInArea, snapPoint)
            end
        end
    end
    return snapPointsInArea
end

local function createSpecialSnapPoints()
    local newSnapPointList = Global.getSnapPoints()
    table.insert(newSnapPointList, {position = BOSS_POS, rotation = {0, 180, 0}, rotation_snap = true, tags = {}})
    table.insert(newSnapPointList, {position = BOSS_POS + BOSS_CUSTOM_COUNTER_OFFSET, rotation = {0, 180, 0}, rotation_snap = true, tags = {"COUNTER"}})
    table.insert(newSnapPointList, {position = CRULE_POS, rotation = {0, 180, 0}, rotation_snap = true, tags = {}})
    table.insert(newSnapPointList, {position = CCOUNTER_ONE_POS, rotation = {0, 0, 0}, rotation_snap = true, tags = {}})
    table.insert(newSnapPointList, {position = CCOUNTER_TWO_POS, rotation = {0, 0, 0}, rotation_snap = true, tags = {}})
    Global.setSnapPoints(newSnapPointList)
end

local function setupMinionProps(startPosition, rows, minionsPerRow, reversed)
    local challengeBag = getObjectFromGUID(getObjectFromGUID(TABLE_BASE_GUID).getTable("OBJECTS_UNDER_TABLE").CP_BAG)
    local hpCounter = challengeBag.takeObject({guid = challengePropIDs.HP_COUNTER})
    if hpCounter == nil then
        return
    end
    local offsetX = reversed and - MINION_POS_OFFSET_X or MINION_POS_OFFSET_X
    for row = 0, rows - 1 do
        for i = 0, minionsPerRow - 1 do
            local newHpCounter = hpCounter.clone()
            local position = startPosition + Vector(offsetX * i, 0, MINION_COUNTER_OFFSET + MINION_POS_OFFSET_Z * row)
            newHpCounter.setPosition(position:setAt('y', 1.54))
            newHpCounter.setLock(true)
            newHpCounter.setScale({0.35, 1, 0.35})
            table.insert(propTable.HP_COUNTER_MINION, newHpCounter.getGUID())
        end
    end
    challengeBag.putObject(hpCounter)
end

local function createMinionZones(startPosition, rows, minionsPerRow, reversed)
    local minionGuidTable = {}
    for _, zoneGuid in ipairs(zoneTable.MINION) do
        table.insert(minionGuidTable, {guid = zoneGuid, owner = nil})
    end

    local newSnapPointList = Global.getSnapPoints()

    local offsetX = reversed and - MINION_POS_OFFSET_X or MINION_POS_OFFSET_X
    for row = 0, rows - 1 do
        for i = 0, minionsPerRow - 1 do
            table.insert(newSnapPointList, {position = startPosition + Vector(offsetX * i, 0, MINION_POS_OFFSET_Z * row)
                , rotation = {0, 180, 0}, rotation_snap = true, tags = {}})

            local minionZone = spawnObject({
                type = "ScriptingTrigger",
                position = startPosition + Vector(offsetX * i, 0, MINION_POS_OFFSET_Z * row),
                rotation = {0, 180, 0},
                scale = {1, 0.9, 1}})
            minionZone.setLuaScript(SCRIPT_MINION_ZONE)
            minionZone.setName("Minion Zone")
            table.insert(zoneTable.MINION, minionZone.getGUID())
            table.insert(minionGuidTable, {guid = minionZone.getGUID(), owner = nil})
        end
    end
    Global.setSnapPoints(newSnapPointList)

    return minionGuidTable
end

local function createChallengeZones(startPosition, rows, zonesPerRow, reversed)
    local newSnapPointList = Global.getSnapPoints()
    local offsetX = reversed and - CSLOT_POS_OFFSET_X or CSLOT_POS_OFFSET_X
    for row = 0, rows - 1 do
        for i = 0, zonesPerRow - 1 do
            table.insert(newSnapPointList, {position = startPosition + Vector(offsetX * i, 0, CSLOT_POS_OFFSET_Z * row)
                , rotation = {0, 180, 0}, rotation_snap = true, tags = {}})

            local challengeZone = spawnObject({
                type = "ScriptingTrigger",
                position = startPosition + Vector(offsetX * i, 0, CSLOT_POS_OFFSET_Z * row),
                rotation = {0, 180, 0},
                scale = {1, 0.9, 1}})
            table.insert(zoneTable.CSLOT, challengeZone.getGUID())
        end
    end
    Global.setSnapPoints(newSnapPointList)
end

local function setupChallengeProps()
    setupMinionProps(MINION_POS_START, 2, MINION_POS_AMOUNT_PER_ROW)
    local challengeBag = getObjectFromGUID(getObjectFromGUID(TABLE_BASE_GUID).getTable("OBJECTS_UNDER_TABLE").CP_BAG)
    local hpCounter = challengeBag.takeObject({guid = challengePropIDs.HP_COUNTER})
    local bossHpCounter = hpCounter.clone()
    bossHpCounter.setScale({0.55, 1, 0.55})
    bossHpCounter.setPosition((BOSS_POS + Vector(0, 0, BOSS_COUNTER_OFFSET)):setAt('y', 1.54))
    bossHpCounter.setRotation({0, 180, 0})
    bossHpCounter.setLock(true)
    propTable.HP_COUNTER_BOSS = bossHpCounter.getGUID()
    challengeBag.putObject(hpCounter)
end

local function createZones()
    local bossZone = spawnObject({type = "ScriptingTrigger", position = BOSS_POS, rotation = {0, 180, 0}, scale = {1, 0.9, 1}})
    bossZone.setLuaScript(SCRIPT_BOSS_ZONE)
    bossZone.setName("Boss Zone")
    zoneTable.BOSS = bossZone.getGUID()
    Global.setVar("ZONE_GUID_BOSS", bossZone.getGUID())
    getObjectFromGUID(MONSTER_DECK_ZONE_GUID).setVar("BOSS_ZONE_GUID", bossZone.getGUID())


    local minionGuidTable = createMinionZones(MINION_POS_START, 2, MINION_POS_AMOUNT_PER_ROW)
    createChallengeZones(CSLOT_POS_START, 2, CSLOT_POS_AMOUNT_PER_ROW)

    Global.setTable("ZONE_INFO_MINION", minionGuidTable)
end

local function setupZoneScripts()
    local bossZone = getObjectFromGUID(zoneTable.BOSS)
    if bossZone then
        bossZone.setVar("HP_COUNTER_GUID", propTable.HP_COUNTER_BOSS)
        bossZone.setTable("MINION_ZONE_INFO", Global.getTable("ZONE_INFO_MINION"))
    end

    for index, minionZoneGuid in pairs(zoneTable.MINION) do
        local minionZone = getObjectFromGUID(minionZoneGuid)
        if minionZone then
            minionZone.setVar("HP_COUNTER_GUID", propTable.HP_COUNTER_MINION[index])
        end
    end
end

local function setupPropScripts()
    local hpCounterBoss = getObjectFromGUID(propTable.HP_COUNTER_BOSS)
    if hpCounterBoss then
        hpCounterBoss.call("setZone", {zoneGuid = zoneTable.BOSS})
    end

    for index, counterGuid in pairs(propTable.HP_COUNTER_MINION) do
        local hpCounter = getObjectFromGUID(counterGuid)
        if hpCounter then
            hpCounter.call("setZone", {zoneGuid = zoneTable.MINION[index]})
        end
    end
end

local function deletePlayerStuff()
    local customButtons = getObjectFromGUID(CUSTOM_BUTTON_MODULE_GUID).getTable("CUSTOM_BUTTONS")
    for _, guid in pairs(yellowPlayerStuff) do
        local playerObj = getObjectFromGUID(guid)
        if playerObj then
            destroyObject(playerObj)
        end
    end

    for _, guid in pairs(greenPlayerStuff) do
        local playerObj = getObjectFromGUID(guid)
        if playerObj then
            destroyObject(playerObj)
        end
    end

    for _, infoTable in pairs(customButtons) do
        local greenButton = getObjectFromGUID(infoTable.Green)
        if greenButton then
            destroyObject(greenButton)
        end
        local yellowButton = getObjectFromGUID(infoTable.Yellow)
        if yellowButton then
            destroyObject(yellowButton)
        end
    end
end

local function deleteObjectsAndSnappoints()
    deletePlayerStuff()

    local handInfos = Global.call("getHandInfo")
    for originalOwnerColor, guid in pairs(handZones) do
        local handZone = getObjectFromGUID(guid)
        if handZone then
            if handInfos[originalOwnerColor].owner == originalOwnerColor then
                destroyObject(handZone)
            else
                handZone.setPosition(handZone.getPosition() - Vector(0, 20, 0))
            end
        end
    end

    local spyInfos = Global.call("getSpyInfo")
    for originalOwnerColor, guid in pairs(spyZones) do
        local spyZone = getObjectFromGUID(guid)
        if spyZone then
            if spyInfos[originalOwnerColor].owner == originalOwnerColor then
                destroyObject(spyZone)
            else
                spyZone.setPosition(spyZone.getPosition() - Vector(0, 20, 0))
            end
        end
    end

    for _, guid in pairs(restStuff) do
        local playerObj = getObjectFromGUID(guid)
        if playerObj then
            destroyObject(playerObj)
        end
    end

    local newSnapPointList = {}
    for _, snapPoint in pairs(Global.getSnapPoints()) do
        local snapPointPos = snapPoint.position
        if (snapPointPos.z > areaToDeleteEdges.z2) and (snapPointPos.z < areaToDeleteEdges.z1) then
            if (snapPointPos.x > areaToDeleteEdges.x1) and (snapPointPos.x < areaToDeleteEdges.x2) then
                goto skipSnapPoint
            end
        end
        table.insert(newSnapPointList, snapPoint)
        ::skipSnapPoint::
    end

    getObjectFromGUID("69a80d").call("deactivateSecondTurnButtons")

    Global.setSnapPoints(newSnapPointList)
end

local function createExpansionButton()
    self.createButton({
        click_function = "click_function_expandChallengeZone",
        function_owner = self,
        label          = "Expand Challenge Zone",
        position       = {57, 2.4, -12},
        width          = 3200,
        height         = 500,
        font_size      = 300,
        color          = {0.50, 0.59, 0.6, 100},
        font_color     = {0, 0, 0},
        tooltip        = "[b]Click this to activate the inactive part of the Challenge Zone.[/b]\n[i]-- No way back --[/i]"
    })
end

local function createChallengeLayout()
    getObjectFromGUID(BOARD_MANAGER_GUID).call("changeBoard", {url = CHALLENGE_BOARD_URL, name = "Challenge Board (by Ediforce44)"})
    createSpecialSnapPoints()
    setupChallengeProps()
    createZones()
    Wait.frames(function()
        setupZoneScripts()
        setupPropScripts()
    end)
    createExpansionButton()
end

function setupTableForChallenge()
    deleteObjectsAndSnappoints()
    createChallengeLayout()
    isChallengeModeActive = true
end

function presetupChallenge(setupInfo)
    setupInfoTable = setupInfo
    for _, obj in pairs(Global.getObjects()) do
        if obj.getName() == setupInfoTable.challengeName then
            challengeBag = obj
            break
        end
    end
    if challengeBag then
        challengeBag.call("presetupChallenge", {difficulty = setupInfoTable.difficulty
            , compMode = setupInfoTable.compMode, automation = setupInfoTable.automation})
    end
end

function setupChallenge(params)
    if params and params.preDeckGUIDs then
        local filterTags = {}
        if setupInfoTable.filterTagsActive then
            filterTags = setupInfoTable.filterTags
        end
        local setupParams = {preDeckGUIDs = params.preDeckGUIDs, filterTags = filterTags
            , difficulty = setupInfoTable.difficulty, compMode = setupInfoTable.compMode, automation = setupInfoTable.automation}
        challengeBag.call("setupChallengeZones", setupParams)
        for _, zoneGuid in pairs(zoneTable.CSLOT) do
            local slotZone = getObjectFromGUID(zoneGuid)
            if slotZone and slotZone.getVar("USE_SLOT_BUTTON") then
                slotZone.call("activateSlotButton")
            end
        end
        if setupInfoTable.automation and (Global.getVar("gameLanguage") ~= "FR") then                    --TODO delete the france exclusion
            Wait.frames(function() challengeBag.call("setupChallenge", setupParams) end, 1)
        end
    end
end

function click_function_expandChallengeZone(_, playerColor)
    if (playerColor ~= "Black") and (not Player[playerColor].admin) then
        printToColor(Global.getTable("PRINT_COLOR_SPECIAL").WARNING .. "You need admin rights to expand the challenge zone!", playerColor)
        return
    end
    if isBoardExpanded then
        return
    end
    self.removeButton(0)
    isBoardExpanded = true
    getObjectFromGUID(BOARD_MANAGER_GUID).call("changeBoard", {url = CHALLENGE_BOARD_EXPANDED_URL, name = "Challenge Board Expanded (by Ediforce44)"})
    setupMinionProps(MINIONE_POS_START, 2, MINION_POS_AMOUNT_PER_ROW, true)
    local newMinionZoneTable = createMinionZones(MINIONE_POS_START, 2, MINION_POS_AMOUNT_PER_ROW, true)
    Global.setTable("ZONE_INFO_MINION", newMinionZoneTable)
    createChallengeZones(CSLOTE_POS_START, 2, CSLOT_POS_AMOUNT_PER_ROW, true)
    Wait.frames(function()
        setupZoneScripts()
        setupPropScripts()
    end)
end

function hasCompetitiveMode(params)
    if params.challengeName == nil then
        return true
    end
    for _, obj in pairs(Global.getObjects()) do
        if obj.getName() == params.challengeName then
            local hasCompMode = obj.getVar("HAS_SEP_COMP_MODE")
            if hasCompMode == nil then
                return true
            else
                return hasCompMode
            end
        end
    end
    return true
end

function onLoad(saved_data)
    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)

        if loaded_data.isChallengeModeActive then
            if loaded_data.isBoardExpanded == false then
                createExpansionButton()
            end
            if loaded_data.propTable then
                propTable = loaded_data.propTable
            end
            if loaded_data.zoneTable then
                zoneTable = loaded_data.zoneTable
            end
        end
    end
end

function onSave()
    return JSON.encode({isBoardExpanded = isBoardExpanded, isChallengeModeActive = isChallengeModeActive, propTable = propTable, zoneTable = zoneTable})
end
------------------------------------- Function for Challenge Packs -----------------------------------------------------
local MANUAL_POS = Vector(0.5, 5, 0)
local HUGE_CARD_SCALE = Vector(1.55, 1, 1.55)
local rule

function getBossZone()
    return getObjectFromGUID(zoneTable.BOSS)
end

function placeChallengeContent(params)
    if params.COUNTER then
        params.COUNTER.setPosition(CCOUNTER_ONE_POS)
        params.COUNTER.setRotation(Vector(0, 0, 0))
        params.COUNTER.setLock(true)
    end
    if params.COUNTER_TWO then
        params.COUNTER_TWO.setPosition(CCOUNTER_TWO_POS)
        params.COUNTER_TWO.setRotation(Vector(0, 0, 0))
        params.COUNTER_TWO.setLock(true)
    end
    params.BOSS.setPositionSmooth(BOSS_POS:setAt('y', 5), false)
    params.BOSS.setScale(HUGE_CARD_SCALE)
    params.RULE.setPositionSmooth(CRULE_POS:setAt('y', 5), false)
    params.RULE.setScale(HUGE_CARD_SCALE)
    if params.MANUAL then
        params.MANUAL.setPositionSmooth(MANUAL_POS, false)
    end
end

function allowEventMinions()
    local bossZone = getObjectFromGUID(zoneTable.BOSS)
    if bossZone then
        bossZone.setVar("ONLY_MONSTER_MINIONS", false)
    end
end

function disableMinionRewards()
    local bossZone = getObjectFromGUID(zoneTable.BOSS)
    if bossZone then
        bossZone.setVar("NO_MINION_REWARDS", true)
    end
end

function expandChallengeZone()
    click_function_expandChallengeZone(nil, "Black")
    maxChallengeSlot = 8
end

function activatePlayerMinionZones(params)
    local zonesPerPlayer = MINION_POS_AMOUNT_PER_ROW * 2
    if params and params.amountPerPlayer ~= nil then
        zonesPerPlayer = math.min(params.amountPerPlayer, zonesPerPlayer)
    end
    expandChallengeZone()

    local playerMinionZoneGuids = {Red = {}, Blue = {}}
    for i = (MINION_POS_AMOUNT_PER_ROW * 2) - (zonesPerPlayer - 1), MINION_POS_AMOUNT_PER_ROW * 2, 1 do
        table.insert(playerMinionZoneGuids.Red, i)
    end
    for i = (MINION_POS_AMOUNT_PER_ROW * 4) - (zonesPerPlayer - 1), (MINION_POS_AMOUNT_PER_ROW * 4), 1 do
        table.insert(playerMinionZoneGuids.Blue, i)
    end
    for _, indexID in pairs(playerMinionZoneGuids.Red) do
        local hpCounter = getObjectFromGUID(propTable.HP_COUNTER_MINION[indexID])
        if hpCounter then
            hpCounter.setColorTint({1, 0, 0})
        end
    end
    for _, indexID in pairs(playerMinionZoneGuids.Blue) do
        local hpCounter = getObjectFromGUID(propTable.HP_COUNTER_MINION[indexID])
        if hpCounter then
            hpCounter.setColorTint({0, 0, 1})
        end
    end

    Wait.frames(function()
        local bossZone = getObjectFromGUID(zoneTable.BOSS)
        if bossZone then
            bossZone.call("activatePlayerMinionZones", {zoneIDs = playerMinionZoneGuids})
        end
    end, 2)
end

function addMinionSlot(params)
    if nextFreeChallengeSlot > maxChallengeSlot then
        Global.call("printWarning", {text = "Not enough challenge slots for this challenge"})
        return
    end
    local zoneName = "Minions"
    if params and params.name then
        zoneName = params.name
    end
    local newSlotZone = getObjectFromGUID(zoneTable.CSLOT[nextFreeChallengeSlot])
    if newSlotZone then
        newSlotZone.setLuaScript(SCRIPT_MINION_SLOT)
        newSlotZone.setName(zoneName)
        Wait.frames(function() newSlotZone.call("createTitle") end)

        table.insert(minionSlotGuids, newSlotZone.getGUID())
        local bossZone = getObjectFromGUID(zoneTable.BOSS)
        if bossZone then
            bossZone.setTable("MINION_SLOT_GUIDS", minionSlotGuids)
        end
        nextFreeChallengeSlot = nextFreeChallengeSlot + 1
    end
    return newSlotZone
end

function addTreasureSlot(params)
    if nextFreeChallengeSlot > maxChallengeSlot then
        Global.call("printWarning", {text = "Not enough challenge slots for this challenge"})
        return
    end
    local zoneName = "Treasures"
    if params and params.name then
        zoneName = params.name
    end
    local newSlotZone = getObjectFromGUID(zoneTable.CSLOT[nextFreeChallengeSlot])
    if newSlotZone then
        newSlotZone.setLuaScript(SCRIPT_TREASURE_SLOT)
        newSlotZone.setName(zoneName)
        Wait.frames(function()
            newSlotZone.call("createTitle")
            if params.buttonParams then
                newSlotZone.setVar("USE_SLOT_BUTTON", true)
                newSlotZone.setTable("slotButtonParams", params.buttonParams)
            end
        end)

        table.insert(treasureSlotGuids, newSlotZone.getGUID())
        nextFreeChallengeSlot = nextFreeChallengeSlot + 1
    end
    return newSlotZone
end

function skipSlot()
    nextFreeChallengeSlot = nextFreeChallengeSlot + 1
    return nil
end