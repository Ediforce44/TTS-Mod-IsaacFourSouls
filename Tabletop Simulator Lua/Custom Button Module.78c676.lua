local BUTTON_RELEASE_TIME = 0.075
local BUTTON_BLOCK_TIME = 0.5
local BUTTON_HIGHT = 1.6
local blockedButtons = {}
local DECK_BUILDER_GUID = "69a80e"
local FLEX_TABLE_CONTROL_GUID = "bd69bd"

CUSTOM_BUTTONS = {
    ROOM = {Red = "9db50a", Blue = "7bd88f", Green = "a20779", Yellow = "262f7e"},
    LOOT = {Red = "95e43d", Blue = "b49d51", Green = "627744", Yellow = "e6381f"},
    TREASURE = {Red = "7e0fae", Blue = "3871f8", Green = "5dda66", Yellow = "d6f240"},
    MONSTER = {Red = "ec14c2", Blue = "ed7b2b", Green = "95994e", Yellow = "af1aec"},
    OPTION = {Red = "ef5484", Blue = "be3671", Green = "9cd565", Yellow = "50938c"}
}

local LINK_BUTTONS = {
    LINK_SLIM = "90a552",
    LINK_NORMAL = "ff5c12",
    LINK_XL = "68661c"
}

local GENERAL_BUTTONS = {
    MUTE = "d625a5",
    DECKBUILDING = "e16ce7",
    TABLE_CHANGE = "a58e57"
}

local KILL_BUTTONS = {
    ONE     = "27d7f6",
    TWO     = "5f7652",
    THREE   = "385933",
    FOUR    = "881682",
    FIVE    = "420306",
    SIX     = "f4a180",
    SEVEN   = "21399e",
}

local CUSTOM_BUTTON_THEME = {
    DARK = {state = 1, rotation = {Red = {0, 180, 180}, Blue = {0, 180, 180}, Green = {0, 0, 180}, Yellow = {0, 0, 180}}},
    LIGHT = {state = 2, rotation = {Red = {0, 180, 180}, Blue = {0, 180, 180}, Green = {0, 0, 180}, Yellow = {0, 0, 180}}},
    FANCY = {state = 2, rotation = {Red = {0, 180, 0}, Blue = {0, 180, 0}, Green = {0, 0, 0}, Yellow = {0, 0, 0}}}
}

local BUTTON_TOOLTIPS = {
    ROOM = "[b]Spy on Room Deck[/b][i]\nLeft-Click: Top Card\nRight-Click: Top 5 Cards[/i]",
    LOOT = "[b]Spy on Loot Deck[/b][i]\nLeft-Click: Top Card\nRight-Click: Top 5 Cards[/i]",
    TREASURE = "[b]Spy on Treasure Deck[/b][i]\nLeft-Click: Top Card\nRight-Click: Top 5 Cards[/i]",
    MONSTER = "[b]Spy on Monster Deck[/b][i]\nLeft-Click: Top Card\nRight-Click: Top 5 Cards[/i]",
    OPTION = "[b]Open Player-Options[/b]",
    LINK_SLIM = "[b]Workshop Link to the simple version of this Mod[/b]",
    LINK_NORMAL = "[b]Workshop Link to this Mod[/b]",
    LINK_XL = "[b]Workshop Link to the 6 Player version of this Mod[/b]",
    MUTE = "[b]Mute or unmute Sound Effects[/b]",
    DECKBUILDING = "[b]Manual Deckbuilding[/b][i]\nIf you press this button there is no way back!\nAll playable cards will be placed on the table and you can build your own decks.[/i]",
    TABLE_CHANGE = "[b]Change Table Mat[/b][i]\nYou can change the Table Mat or load custom images as Table Mat.[/i]",
    KILL_MONSTER = "[b]Kill[/b]",
}

local SPY_ZONE_GUIDS = {Red = nil, Blue = nil, Green = nil, Yellow = nil}

local cardsInSpyZones = {}

local BUTTON_FUNCTIONS = {
    ROOM = "click_SpyButton_Room",
    LOOT = "click_SpyButton_Loot",
    TREASURE = "click_SpyButton_Treasure",
    MONSTER = "click_SpyButton_Monster",
    OPTION = "click_ShowPlayerOptions",
    LINK_SLIM = "click_ShowLinkSlim",
    LINK_NORMAL = "click_ShowLinkNormal",
    LINK_XL = "click_ShowLinkXL",
    MUTE = "click_MuteSFX",
    DECKBUILDING = "click_ManualDeckbuilding",
    TABLE_CHANGE = "click_ChangeTableMat",
    KILL_MONSTER = "click_KillMonster"
}

local function buttonAnimation(buttonObj)
  local posUp = buttonObj.getPosition():setAt('y', BUTTON_HIGHT)
  local posDown = buttonObj.getPosition():setAt('y', BUTTON_HIGHT - 0.18)
  buttonObj.setPositionSmooth(posDown,false,true)
  Wait.time(function() buttonObj.setPositionSmooth(posUp,false,true) end, BUTTON_RELEASE_TIME)
end

local function tempBlockButton(buttonObj)
    blockedButtons[buttonObj.getGUID()] = true
    Timer.create({
        ["identifier"] = "SpyButtonBlockTimer" .. self.guid .. tostring(buttonObj.getGUID()),
        ["function_name"] = "unblockButton",
        ["parameters"] = {buttonObj = buttonObj},
        ["delay"] = BUTTON_BLOCK_TIME,
    })
end

function unblockButton(params)
    blockedButtons[params.buttonObj.getGUID()] = false
end

local function createButtonsOnCustomButton(buttonObj, buttonType, scaleX, scaleY)
    scaleX = scaleX or 1
    scaleY = scaleY or 1
    if buttonObj then
        buttonObj.setPosition(buttonObj.getPosition():setAt('y', BUTTON_HIGHT))
        buttonObj.setLock(true)

        buttonObj.createButton({
            label="",
            click_function=BUTTON_FUNCTIONS[buttonType] or "dummy",
            tooltip=BUTTON_TOOLTIPS[buttonType] or "",
            function_owner=self,
            position={0,0.07, 0},
            height=650*scaleY,
            width=650*scaleX,
            font_color={0, 0, 0, 0},
            color={0,0,0,0}
        })
        buttonObj.createButton({
            label="",
            click_function=BUTTON_FUNCTIONS[buttonType] or "dummy",
            tooltip=BUTTON_TOOLTIPS[buttonType] or "",
            function_owner=self,
            position={0, -0.07, 0},
            rotation={180, 0, 0},
            height=650*scaleY,
            width=650*scaleX,
            font_color={0, 0, 0, 0},
            color={0,0,0,0}
        })

        blockedButtons[buttonObj.getGUID()] = false
    end
end

function onLoad(saved_data)
    for color, infoTable in pairs(Global.call("getSpyInfo")) do
        SPY_ZONE_GUIDS[color] = infoTable.guid
    end

    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        if loaded_data.cardsInSpyZones then
            cardsInSpyZones = loaded_data.cardsInSpyZones
        end
        if loaded_data.customButtons then
            CUSTOM_BUTTONS = loaded_data.customButtons
        end
    end

    local playerOwner = Global.call("getHandInfo")
    for guid, infoTable in pairs(cardsInSpyZones) do
        local card = getObjectFromGUID(guid)
        if card then
            card.UI.setXml(getButtonXML(playerOwner[infoTable.owner].owner, card))
        end
    end

    for buttonType, buttonTables in pairs(CUSTOM_BUTTONS) do
        for _, buttonGUID in pairs(buttonTables) do
            local buttonObj = getObjectFromGUID(buttonGUID)
            createButtonsOnCustomButton(buttonObj, buttonType)
        end
    end

    for buttonType, buttonGUID in pairs(LINK_BUTTONS) do
        local buttonObj = getObjectFromGUID(buttonGUID)
        createButtonsOnCustomButton(buttonObj, buttonType)
    end

    for buttonType, buttonGUID in pairs(GENERAL_BUTTONS) do
        local buttonObj = getObjectFromGUID(buttonGUID)
        createButtonsOnCustomButton(buttonObj, buttonType)
    end

    for buttonType, buttonGUID in pairs(KILL_BUTTONS) do
        local buttonObj = getObjectFromGUID(buttonGUID)
        createButtonsOnCustomButton(buttonObj, "KILL_MONSTER", 2, 2)
    end
end

function onSave()
    return JSON.encode({cardsInSpyZones = cardsInSpyZones, customButtons = CUSTOM_BUTTONS})
end

local function click_SpyButton(buttonObj, playerColor, alt_click, deck, cardType)
    local buttonObjGuid = buttonObj.getGUID()
    local zoneColor = nil
    local spyInfo = Global.call("getSpyInfo")

    for ownerColor, guid in pairs(CUSTOM_BUTTONS[cardType]) do
        if guid == buttonObjGuid then
            if spyInfo[ownerColor].owner ~= playerColor then
                return
            else
                zoneColor = ownerColor
            end
            break
        end
    end
    if alt_click then
        if blockedButtons[buttonObj.getGUID()]  then
            return
        end
        tempBlockButton(buttonObj)
        buttonAnimation(buttonObj)
        if deck then
            for i = 1, 5 do
                local card = deck.takeObject()
                if card == nil then
                    card = deck
                end
                card.addTag("SPY")
                card.deal(1, spyInfo[zoneColor].owner, spyInfo[zoneColor].index)
                cardsInSpyZones[card.getGUID()] = {type = cardType, owner = zoneColor}
            end
        end
    else
        buttonAnimation(buttonObj)
        if deck then
            local card = deck.takeObject()
            if card == nil then
                card = deck
            end
            card.addTag("SPY")
            card.deal(1, spyInfo[zoneColor].owner, spyInfo[zoneColor].index)
            card.interactable = false
            Wait.time(function() card.interactable = true end, 0.5)
            cardsInSpyZones[card.getGUID()] = {type = cardType, owner = zoneColor}
        end
    end
end

function click_SpyButton_Room(buttonObj, playerColor, alt_click)
    click_SpyButton(buttonObj, playerColor, alt_click, Global.call("getRoomDeck"), "ROOM")
end

function click_SpyButton_Loot(buttonObj, playerColor, alt_click)
    click_SpyButton(buttonObj, playerColor, alt_click, Global.call("getLootDeck"), "LOOT")
end

function click_SpyButton_Treasure(buttonObj, playerColor, alt_click)
    click_SpyButton(buttonObj, playerColor, alt_click, Global.call("getTreasureDeck"), "TREASURE")
end

function click_SpyButton_Monster(buttonObj, playerColor, alt_click)
    click_SpyButton(buttonObj, playerColor, alt_click, Global.call("getMonsterDeck"), "MONSTER")
end

function dummy()
end

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------- Link Buttons ---------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local url_slim = "https://steamcommunity.com/sharedfiles/filedetails/?id=2545137892"
local url_normal = "https://steamcommunity.com/sharedfiles/filedetails/?id=2526757138"
local url_xl = "https://steamcommunity.com/sharedfiles/filedetails/?id=2908808487"

local function removeOtherLinkInputs(linkButton)
    for _, guid in pairs(LINK_BUTTONS) do
        if guid ~= linkButton.getGUID() then
            local otherLinkButton = getObjectFromGUID(guid)
            if otherLinkButton then
                otherLinkButton.clearInputs()
            end
        end
    end
end

local function createUrlInput(buttonObj, url)
    if buttonObj.getInputs() then
        buttonObj.clearInputs()
    else
        buttonObj.createInput({
            value = url,
            input_function = "dummy",
            function_owner = self,
            position = {0,0.2,-1.5},
            width = 4200,
            height = 180,
            font_size = 140,
            alignment = 3,
            scale={x=2, y=2, z=2},
            font_color= {1,1,1},
            tooltip="[b]Select and press:[/b]\n[i]CTRL + C[/i]",
            color = {0.1,0.1,0.1}
        })
    end
end

function click_ShowLinkSlim(buttonObj)
    buttonAnimation(buttonObj)
    removeOtherLinkInputs(buttonObj)
    createUrlInput(buttonObj, url_slim)
end

function click_ShowLinkNormal(buttonObj)
    buttonAnimation(buttonObj)
    removeOtherLinkInputs(buttonObj)
    createUrlInput(buttonObj, url_normal)
end

function click_ShowLinkXL(buttonObj)
    buttonAnimation(buttonObj)
    removeOtherLinkInputs(buttonObj)
    createUrlInput(buttonObj, url_xl)
end

------------------------------------------------------------------------------------------------------------------------
----------------------------------------------- General Buttons --------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function click_MuteSFX(buttonObj, playerColor)
    if Player[playerColor].admin then
        buttonObj.setRotation(buttonObj.getRotation() + Vector(0, 0, 180))
        buttonAnimation(buttonObj)
        local sfxCube = getObjectFromGUID(Global.getVar("SFX_CUBE_GUID"))
        if sfxCube then
            sfxCube.call("switchMute")
        end
    end
end

function click_ManualDeckbuilding(buttonObj, playerColor)
    if Player[playerColor].admin then
        local deckBuilder = getObjectFromGUID(DECK_BUILDER_GUID)
        if deckBuilder then
            if deckBuilder.call("prepareForManualDeckBuilding") then
                buttonObj.setRotation(buttonObj.getRotation():setAt('z', 0))
                buttonAnimation(buttonObj)
            end
        end
    end
end

function click_ChangeTableMat(buttonObj)
    buttonAnimation(buttonObj)
    local flexTable = getObjectFromGUID(FLEX_TABLE_CONTROL_GUID)
    if flexTable then
        flexTable.call("click_toggleControl")
    end
end

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------- Kill Buttons ---------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function click_KillMonster(buttonObj)
    local type = 0
    for buttonType, buttonGUID in pairs(KILL_BUTTONS) do
        if buttonObj.getGUID() == buttonGUID then
            type = buttonType
            break
        end
    end
    if type ~= 0 then
        buttonAnimation(buttonObj)
        local zone = getObjectFromGUID(Global.getTable("ZONE_GUID_MONSTER")[type])
        if zone then
            local monsterDeckZone = getObjectFromGUID(Global.getTable("ZONE_GUID_DECK").MONSTER)
            if monsterDeckZone then
                local attackButtonStates = monsterDeckZone.getTable("ATTACK_BUTTON_STATES")
                if zone.call("getState") == attackButtonStates.DIED then
                    zone.call("finishMonster")
                    monsterDeckZone.call("changeZoneState", {zone = zone, newState = attackButtonStates.ATTACK})
                    return
                end
            end
            zone.call("killMonster")
        end
    end
end

------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------- Spy Zone -----------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local SPY_ZONE_POSITIONS = {
    Red = {SIDE = {35.16, 4, -20.5}, FRONT = {18.5, 4, -12}},
    Blue = {SIDE = {-8.26, 4, -20.5}, FRONT = {-25, 4, -12}},
    Green = {SIDE = {-41.72, 4, 20.5}, FRONT = {-25, 4, 12}},
    Yellow = {SIDE = {1.71, 4, 20.5}, FRONT = {18.5, 4, 12}}
}

function getButtonXML(spyZoneOwnerColor, object)
    local selfGuid = self.getGUID()
    local objectGUID = object.getGUID()
    local height = 50
    local width = 50
    if object.getVar("type") == "room" then
return [[<Button visibility="]] .. spyZoneOwnerColor .. [["
    active="true"
    image="spy_bottom"
    height="79"
    width="52"
    offsetXY="80 -193"
    rotation="0 0 180"
    onClick="]] .. selfGuid .. [[/UI_bottom(]] .. objectGUID .. [[">
</Button>
<Button visibility="]] .. spyZoneOwnerColor .. [["
    active="true"
    image="spy_top"
    height="79"
    width="52"
    offsetXY="80 -270"
    rotation="0 0 180"
    onClick="]] .. selfGuid .. [[/UI_top(]] .. objectGUID .. [[">
</Button>
<Button visibility="]] .. spyZoneOwnerColor .. [["
    active="true"
    image="spy_delete"
    height="79"
    width="52"
    offsetXY="80 193"
    rotation="0 0 180"
    onClick="]] .. selfGuid .. [[/UI_discard(]] .. objectGUID .. [[">
 </Button>]]
    else
return [[<Button visibility="]] .. spyZoneOwnerColor .. [["
    active="true"
    image="spy_bottom"
    height="59"
    width="75"
    offsetXY="70 -183"
    rotation="0 0 180"
    onClick="]] .. selfGuid .. [[/UI_bottom(]] .. objectGUID .. [[">
</Button>
<Button visibility="]] .. spyZoneOwnerColor .. [["
    active="true"
    image="spy_top"
    height="59"
    width="75"
    offsetXY="70 -240"
    rotation="0 0 180"
    onClick="]] .. selfGuid .. [[/UI_top(]] .. objectGUID .. [[">
</Button>
<Button visibility="]] .. spyZoneOwnerColor .. [["
    active="true"
    image="spy_delete"
    height="59"
    width="75"
    offsetXY="70 183"
    rotation="0 0 180"
    onClick="]] .. selfGuid .. [[/UI_discard(]] .. objectGUID .. [[">
</Button>]]
     end
end

local function hideCard(card, playerColor)
    local playerColorTable = {}
    for _, color in pairs(Global.getTable("PLAYER")) do
        if color ~= playerColor then
            table.insert(playerColorTable, color)
        end
    end
    card.setHiddenFrom(playerColorTable)
end

local function unhideCard(card)
    card.setHiddenFrom({})
end

local function enableHandZoneForce(card)
    card.use_hands = true
end

local function disableHandZoneForce(card)
    card.use_hands = false
end

local function moveCardOutOfSpyZone(object, playerColor, position, rotation, noDelay)
    local delayTime = noDelay and 0 or 0.3

    object.setRotationSmooth(rotation, false, true)
    Wait.time(function()
        disableHandZoneForce(object)
        Wait.time(function() enableHandZoneForce(object) end, 0.5)
        hideCard(object, playerColor)
        Wait.time(function() unhideCard(object) end, 0.5)
        object.setPositionSmooth(position, false, false)
        cardsInSpyZones[object.getGUID()] = nil
    end, delayTime)
end

function onObjectEnterZone(zone, object)
    for _, guid in pairs(SPY_ZONE_GUIDS) do
        if zone.getGUID() == guid then
            object.UI.setXml(getButtonXML(zone.getValue(), object))
        end
    end
end

function onObjectLeaveZone(zone, object)
    for _, guid in pairs(SPY_ZONE_GUIDS) do
        if zone.getGUID() == guid then
            object.removeTag("SPY")
            object.UI.setXml("")
        end
    end
end

function UI_top(player, objectGUID)
    local object = getObjectFromGUID(objectGUID)
    local objectType = cardsInSpyZones[object.getGUID()].type
    if objectType then
        local deckZoneGuid = Global.getTable("ZONE_GUID_DECK")[objectType]
        if deckZoneGuid then
            local position = nil
            local deck = Global.call("getDeckFromZone", {zoneGUID = deckZoneGuid})
            if deck then
                position = deck.getPosition() + Vector(0, 3, 0)
            else
                position = getObjectFromGUID(deckZoneGuid).getPosition() + Vector(0, 5, 0)
            end
            moveCardOutOfSpyZone(object, player.color, position, {0, 180, 180})
        else
            Global.call("printWarning", {text = "No deck zone found for this object."})
        end
    else
        Global.call("printWarning", {text = "No deck zone found for this object."})
    end
end

function UI_bottom(player, objectGUID)
    local object = getObjectFromGUID(objectGUID)
    local objectType = cardsInSpyZones[object.getGUID()].type
    if objectType then
        local deckZoneGuid = Global.getTable("ZONE_GUID_DECK")[objectType]
        if deckZoneGuid then
            local position = nil
            local deck = Global.call("getDeckFromZone", {zoneGUID = deckZoneGuid})
            if deck then
                position = deck.getPosition():setAt('y', 1.55)
            else
                position = getObjectFromGUID(deckZoneGuid).getPosition()
            end
            moveCardOutOfSpyZone(object, player.color, position, {0, 180, 180})
        else
            Global.call("printWarning", {text = "No deck zone found for this object."})
        end
    else
        Global.call("printWarning", {text = "No deck zone found for this object."})
    end
end

function UI_discard(player, objectGUID)
    local object = getObjectFromGUID(objectGUID)
    local objectType = cardsInSpyZones[object.getGUID()].type
    if objectType then
        moveCardOutOfSpyZone(object, player.color, Global.getTable("DISCARD_PILE_POSITION")[objectType], {0, 180, 0}, true)
    else
        Global.call("printWarning", {text = "No discard pile for this object found."})
    end
end

------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------- Settings -----------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function click_ShowPlayerOptions(buttonObj, playerColor, _)
    if blockedButtons[buttonObj.getGUID()] then
        return
    end

    local buttonObjGuid = buttonObj.getGUID()
    local zoneColor = nil
    local handInfo = Global.call("getHandInfo")
    for ownerColor, guid in pairs(CUSTOM_BUTTONS.OPTION) do
        if guid == buttonObjGuid then
            if handInfo[ownerColor].owner ~= playerColor then
                return
            else
                zoneColor = ownerColor
            end
            break
        end
    end

    blockedButtons[buttonObj.getGUID()] = true
    buttonAnimation(buttonObj)
    UI.show("options_" .. zoneColor)
    UI.setAttribute("options_" .. zoneColor, "visibility", playerColor)
end

local OPTION_TABLE = {
    Red = {
        CAMERA_MOVEMENT = true,
        AUTO_LOOT = false,
        AUTO_ACTIVATION = true,
        AUTO_HEALING = true,
        AUTO_REWARDING = true,
        DEATH_DETECTION = false,
        BUTTON_THEME = "DARK",
        SPY_ZONE_POS = "SIDE"
    },
    Blue = {
        CAMERA_MOVEMENT = true,
        AUTO_LOOT = false,
        AUTO_ACTIVATION = true,
        AUTO_HEALING = true,
        AUTO_REWARDING = true,
        DEATH_DETECTION = false,
        BUTTON_THEME = "DARK",
        SPY_ZONE_POS = "SIDE"
    },
    Green = {
        CAMERA_MOVEMENT = true,
        AUTO_LOOT = false,
        AUTO_ACTIVATION = true,
        AUTO_HEALING = true,
        AUTO_REWARDING = true,
        DEATH_DETECTION = false,
        BUTTON_THEME = "DARK",
        SPY_ZONE_POS = "SIDE"
    },
    Yellow = {
        CAMERA_MOVEMENT = true,
        AUTO_LOOT = false,
        AUTO_ACTIVATION = true,
        AUTO_HEALING = true,
        AUTO_REWARDING = true,
        DEATH_DETECTION = false,
        BUTTON_THEME = "DARK",
        SPY_ZONE_POS = "SIDE"
    }
}

function UI_toggleCameraMovement(_, checked, id)
    local zoneColor = string.match(id, "%w+")
    OPTION_TABLE[zoneColor].CAMERA_MOVEMENT = (checked == "True")
end

function UI_toggleAutoLoot(_, checked, id)
    local zoneColor = string.match(id, "%w+")
    OPTION_TABLE[zoneColor].AUTO_LOOT = (checked == "True")
end

function UI_toggleAutoActivation(_, checked, id)
    local zoneColor = string.match(id, "%w+")
    OPTION_TABLE[zoneColor].AUTO_ACTIVATION = (checked == "True")
end

function UI_toggleAutoHealing(_, checked, id)
    local zoneColor = string.match(id, "%w+")
    OPTION_TABLE[zoneColor].AUTO_HEALING = (checked == "True")
end

function UI_toggleAutoRewarding(_, checked, id)
    local zoneColor = string.match(id, "%w+")
    OPTION_TABLE[zoneColor].AUTO_REWARDING = (checked == "True")
end

function UI_toggleDeathDetection(_, checked, id)
    local zoneColor = string.match(id, "%w+")
    OPTION_TABLE[zoneColor].DEATH_DETECTION = (checked == "True")
end

function UI_selectButtonTheme(_, checked, id)
    if checked == "True" then
        local zoneColor, themeID = string.match(id, "(%w+)_(%w+)")
        OPTION_TABLE[zoneColor].BUTTON_THEME = themeID
    end
end

function UI_selectSpyZonePosition(_, checked, id)
    if checked == "True" then
        local zoneColor, themeID = string.match(id, "(%w+)_(%w+)")
        OPTION_TABLE[zoneColor].SPY_ZONE_POS = themeID
    end
end

function UI_optionsDone(clickPlayer, _, id)
    local zoneColor = string.match(id, "%w+")
    unblockButton({buttonObj = getObjectFromGUID(CUSTOM_BUTTONS.OPTION[zoneColor])})
    UI.hide("options_" .. zoneColor)

    local playerOptionTable = OPTION_TABLE[zoneColor]
    local turnModule = getObjectFromGUID(Global.getVar("TURN_MODULE_GUID"))
    turnModule.call("changeTurnSettings", {color = zoneColor, setting = "camera", newValue = playerOptionTable.CAMERA_MOVEMENT})
    turnModule.call("changeTurnSettings", {color = zoneColor, setting = "looting", newValue = playerOptionTable.AUTO_LOOT})
    turnModule.call("changeTurnSettings", {color = zoneColor, setting = "itemActivation", newValue = playerOptionTable.AUTO_ACTIVATION})
    turnModule.call("changeTurnSettings", {color = zoneColor, setting = "playerHealing", newValue = playerOptionTable.AUTO_HEALING})
    Global.call("changeRewardingMode", {playerColor = zoneColor, active = playerOptionTable.AUTO_REWARDING})
    Global.call("changeDeathDetectionMode", {playerColor = zoneColor, active = playerOptionTable.DEATH_DETECTION})
    --TODO auto-loot zone
    --TODO shop payment

    local themeInfoTable = CUSTOM_BUTTON_THEME[playerOptionTable.BUTTON_THEME]
    for buttonType, buttonTable in pairs(CUSTOM_BUTTONS) do
        local button = getObjectFromGUID(buttonTable[zoneColor])
        if button then
            if button.getStateId() ~= themeInfoTable.state then
                button.clearButtons()
                local newButton = button.setState(themeInfoTable.state)
                createButtonsOnCustomButton(newButton, buttonType)
                CUSTOM_BUTTONS[buttonType][zoneColor] = newButton.getGUID()
                button = newButton
            end
            button.setRotation(themeInfoTable.rotation[zoneColor])
        end
    end

    local spyZone = getObjectFromGUID(SPY_ZONE_GUIDS[zoneColor])
    local newPosition = SPY_ZONE_POSITIONS[zoneColor][playerOptionTable.SPY_ZONE_POS]
    for _, obj in ipairs(spyZone.getObjects()) do
        disableHandZoneForce(obj)
        hideCard(obj, clickPlayer.color)
        Wait.frames(function()
            obj.addTag("SPY")
            enableHandZoneForce(obj)
            local spyInfo = Global.call("getSpyInfo")
            obj.deal(1, spyInfo[zoneColor].owner, spyInfo[zoneColor].index)
            Wait.time(function() unhideCard(obj) end, 1)
        end)
    end
    spyZone.setPosition(newPosition, false)
end