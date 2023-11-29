START_POS = Vector(50.38, 1.02, 14.24)
NEXT_BASE_POS = Vector(66.2, 20.75, -0.2)
BASE_SCALE = {1, 1, 4}

X_MARGIN = 3.21
Z_MARGIN = 4.91
MAX_ROW_SIZE = 11
MAX_Z_COORDINATE = -17
CHARACTER_MANAGER_GUID = "bc6e13"
TABLE_BASE_GUID = "f5c4fe"
EVEN_MORE_CHARS_BAG_GUID = nil

nextPosition = nil
curRowSize = nil

charObjs = {}
baseObjs = {}

characterBagJSON = [[{
    "Name": "Custom_Model_Bag",
    "Transform": {
            "posX": 0,
            "posY": 0,
            "posZ": 0,
            "rotX": 0,
            "rotY": 180,
            "rotZ": 0,
            "scaleX": 0.85,
            "scaleY": 0.85,
            "scaleZ": 0.85
        },
    "Nickname": "",
    "Description": "character-pack",
    "GMNotes": "",
    "AltLookAngle": {
        "x": 0.0,
        "y": 0.0,
        "z": 0.0
    },
    "ColorDiffuse": {
        "r": 1.0,
        "g": 1.0,
        "b": 1.0
    },
    "LayoutGroupSortIndex": 1,
    "Value": 0,
    "Locked": false,
    "Grid": true,
    "Snap": true,
    "IgnoreFoW": false,
    "MeasureMovement": false,
    "DragSelectable": true,
    "Autoraise": true,
    "Sticky": true,
    "Tooltip": true,
    "GridProjection": false,
    "HideWhenFaceDown": false,
    "Hands": false,
    "MaterialIndex": -1,
    "MeshIndex": -1,
    "CustomMesh": {
        "MeshURL": "http://pastebin.com/raw/PqfGKtKR",
        "DiffuseURL": "http://cloud-3.steamusercontent.com/ugc/2260305562237727127/C0EC7B56073FD9603994F4BC5B3732903E128F7A/",
        "NormalURL": "http://cloud-3.steamusercontent.com/ugc/861734852198391028/D75480247FA058266F0D423501D867407458666D/",
        "ColliderURL": "",
        "Convex": true,
        "MaterialIndex": 0,
        "TypeIndex": 6,
        "CustomShader": {
          "SpecularColor": {
            "r": 0.231,
            "g": 0.231,
            "b": 0.231
          },
          "SpecularIntensity": 0.5,
          "SpecularSharpness": 5.000001,
          "FresnelStrength": 0.4
        },
        "CastShadows": true
    },
    "Bag": {
        "Order": 0
    },
    "LuaScript": ""
}]]

-- Dirty stuff
function table.clone(org)
  return {table.unpack(org)}
end

function onLoad(saved_data)
  EVEN_MORE_CHARS_BAG_GUID = getObjectFromGUID(TABLE_BASE_GUID).getTable("OBJECTS_UNDER_TABLE").EMC_BAG
  resetNextPos()
  loadCharactersFromWorld()
  initButton()

  if saved_data ~= "" then
      local loaded_data = JSON.decode(saved_data)
      if loaded_data.nextBasePosition then
          NEXT_BASE_POS = Vector(loaded_data.nextBasePosition)
      end
      if loaded_data.baseObjGuids then
          for _, guid in pairs(loaded_data.baseObjGuids) do
              table.insert(baseObjs, getObjectFromGUID(guid))
          end
      end
  end
end

function onSave()
    local baseObjGuids = {}
    for _, baseObj in pairs(baseObjs) do
        table.insert(baseObjGuids, baseObj.getGUID())
    end
    return JSON.encode({nextBasePosition = NEXT_BASE_POS, baseObjGuids = baseObjGuids})
end

function initButton()
  self.createButton({
    click_function = "placeChestCharactersCallback",
    function_owner = self,
    label          = "Place characters (Chest)",
    tooltip        = "[b]Places every character put inside this chest.[/b]",
    position       = {0, 0.2, 2},
    width          = 2200,
    height         = 300,
    font_size      = 200,
    font_color     = {1, 1, 1},
    color          = {0.25, 0.78, 0.25}
  })
  self.createButton({
    click_function = "deleteExistCharacters",
    function_owner = self,
    label          = "Delete exist characters",
    position       = {0, 0.2, -2},
    width          = 2000,
    height         = 300,
    font_size      = 200,
    font_color     = {1, 1, 1},
    color          = {0.78, 0.25, 0.25}
  })
  self.createButton({
    click_function = "placePlayingAreaCharactersCallback",
    function_owner = self,
    label          = "Place characters (Playing area)",
    tooltip        = "[b]Places every character from every expansions you draged and dropped into the playing area.[/b]",
    position       = {0, 0.2, 2.8},
    width          = 2700,
    height         = 300,
    font_size      = 200,
    font_color     = {1, 1, 1},
    color          = {0.25, 0.78, 0.25}
  })
end

function placeChestCharactersCallback()
  placeCharactersFromBag(self, false)
end

function placePlayingAreaCharactersCallback()
    placeCharactersFromPlayingArea()
end

function loadCharactersFromWorld()
  charObjs = {}
  local allObj = getAllObjects()
  for i, obj in pairs(allObj) do
    if (obj.getDescription() == "character-pack") and (obj.getPosition().y > 0) then
      setCharacterPackScript(obj)
      calcNextPackPosition()
      table.insert(charObjs, obj)
    end
  end
end

function placeCharactersFromPlayingArea()
    local expansions = Global.call("detectExpansions")
    for i, expansion in ipairs(expansions) do
        Wait.frames(function()
            local objectsInExpansion = expansion.getObjects()
            for _, obj in ipairs(objectsInExpansion) do
                if obj.name == "Characters" then
                    expansion.takeObject({
                        index = obj.index,
                        position = expansion.getPosition():sub(Vector(0,0, 4)),
                        smooth = false,
                        callback_function =
                            function(characterBag)
                                placeCharactersFromBag(characterBag, false)
                                destroyObject(characterBag)
                            end
                    })
                end
            end
        end, i)
    end
end

local function placeEMCBag()
    local evenMoreCharsBag = getObjectFromGUID(EVEN_MORE_CHARS_BAG_GUID)
    if evenMoreCharsBag then
        if evenMoreCharsBag.getPosition().y < 0 then
            evenMoreCharsBag.interactable = true
            evenMoreCharsBag.setPosition(Global.getTable("EVEN_MORE_CHARS_POSITION"))
            evenMoreCharsBag.setScale({1.5, 1.5, 1.5})
            Wait.condition(function() evenMoreCharsBag.setLock(true) end
                , function() return evenMoreCharsBag.resting end)
        end
    end
end

local function deleteBaseObjs()
    for _, baseObj in pairs(baseObjs) do
        destroyObject(baseObj)
    end
    baseObjs = {}
end

local function placeCardsInNewCharBag(newCharacterBag, cards)
    if cards.tag == "Deck" then
        for _ = 1, cards.getQuantity() - 1 do
            placeCardsInNewCharBag(newCharacterBag, cards.takeObject())
            if cards.remainder then
                placeCardsInNewCharBag(newCharacterBag, cards.remainder)
                break
            end
        end
    elseif cards.tag == "Card" then
        newCharacterBag.putObject(cards)
        setCharacterPackScript(newCharacterBag)
        reloadWorldCharacterPacksInExternalObj()
    end
end

function placeCharactersFromBag(bagObj, deleteBag)
  local objInBagCount = bagObj.getQuantity()

  for i = 1, objInBagCount do
    if nextPosition == nil then
      placeEMCBag()
      local newBase = getObjectFromGUID(TABLE_BASE_GUID).clone({position = NEXT_BASE_POS})
      newBase.setLuaScript("")
      newBase.setScale(BASE_SCALE)
      table.insert(baseObjs, newBase)

      calcNextPackPosition()
      NEXT_BASE_POS = NEXT_BASE_POS + Vector(0, 20, 0)
    end
    local obj = bagObj.takeObject()

    if obj.getDescription() == "character-pack" then
      setCharacterPackScript(obj)
      table.insert(charObjs, obj)

      obj.setPosition(nextPosition, false)
      obj.setRotation({0, 180, 0})
      calcNextPackPosition()
    elseif (obj.tag == "Deck") or (obj.tag == "Card") then
        spawnObjectJSON({
            json = characterBagJSON,
            position = nextPosition,
            rotation = {0, 180, 0},
            scale = {0.85, 0.85, 0.85},
            callback_function =
                function(newCharBag)
                    placeCardsInNewCharBag(newCharBag, obj)
                    table.insert(charObjs, newCharBag)
                end
        })
        calcNextPackPosition()
    elseif obj.tag == "Bag" then
        placeCharactersFromBag(obj, true)
    end
  end

  reloadWorldCharacterPacksInExternalObj()

  if deleteBag then
    bagObj.destroy()
  end
end

function deleteExistCharacters()
  for i, obj in pairs(charObjs) do
    if obj ~= nil then
      obj.destroy()
    end
  end
  charObjs = {}
  resetNextPos()
  deleteBaseObjs()
  getObjectFromGUID(CHARACTER_MANAGER_GUID).call("onAllCharsDeleted")
end

function storeSurplusCharacterPacks(params)
    local emcBag = getObjectFromGUID(EVEN_MORE_CHARS_BAG_GUID)
    if emcBag then
        for _, charPack in pairs(params.charPacks) do
            emcBag.putObject(charPack)
        end

        NEXT_BASE_POS = NEXT_BASE_POS:setAt('y', 20.74)
        nextPosition = nil

        deleteBaseObjs()
    end
end

function extractSurplusCharacterPacks()
    local emcBag = getObjectFromGUID(EVEN_MORE_CHARS_BAG_GUID)
    if emcBag then
        placeCharactersFromBag(emcBag)
    end
end

function resetNextPos()
  nextPosition = Vector(START_POS)
  curRowSize = 0
end

function calcNextPackPosition()
  if nextPosition == nil then
      curRowSize = 0
      nextPosition = Vector(START_POS.x, NEXT_BASE_POS.y + 1, START_POS.z)
      return
  end
  curRowSize = curRowSize + 1
  nextPosition.x = nextPosition.x + X_MARGIN

  if curRowSize == MAX_ROW_SIZE then
      curRowSize = 0
      nextPosition.x = nextPosition.x - X_MARGIN * MAX_ROW_SIZE
      nextPosition.z = nextPosition.z - Z_MARGIN
      if nextPosition.z < MAX_Z_COORDINATE then
          nextPosition = nil
      end
  end
end

function reloadWorldCharacterPacksInExternalObj()
  Wait.frames(function() getObjectFromGUID(CHARACTER_MANAGER_GUID).call("loadCharPacksFromWorld") end, 60)
end

function setCharacterPackScript(obj)
  obj.setLuaScript([[
CHARACTER_MANAGER_GUID = "]] .. CHARACTER_MANAGER_GUID .. [["
PLAYER_COLORS = Global.getTable("PLAYER")

function onLoad()
  initButtons()
end

function initButtons()
  self.clearButtons()
  self.interactable = false

  self.createButton({
    click_function = "selectCharacter",
    function_owner = self,
    label          = "Select",
    position       = {0, 0.3, 1.7},
    width          = 760,
    height         = 260,
    font_size      = 180,
    font_color     = {1, 1, 1},
    color          = {84/225, 110/255, 122/255}
  })
  self.createButton({
    click_function = "unlock",
    function_owner = self,
    label          = "Unlock",
    position       = {0.4, 0.3, -1.7},
    width          = 400,
    height         = 110,
    font_size      = 80,
    color          = {102/225, 187/255, 106/255}
  })
  self.createButton({
    click_function = "lock",
    function_owner = self,
    label          = "Lock",
    position       = {-0.4, 0.3, -1.7},
    width          = 400,
    height         = 110,
    font_size      = 80,
    color          = {239/225, 83/255, 80/255}
  })
end

local function cloneByGUID(cloneGUID)
    local obj = self.takeObject({guid = cloneGUID})
    local objClone = obj.clone()
    Wait.frames(function() self.putObject(obj) end, 5)
    return objClone
end

local function cloneCharacterCards(zoneColorToPlace, languagePrefix)
    local spawnedObj = {}
    local characterPlaced = false
    local content = self.getObjects()
    local characterItemCounter = 0
    for index = 1, self.getQuantity() do
        local nextObj = content[index]
        local nextObjDescription = nextObj.description
        local objClone = nil

        if nextObjDescription == languagePrefix .. "_character" then
            objClone = cloneByGUID(nextObj.guid)
            Global.call("placeObjectsInPlayerZone", {playerColor = zoneColorToPlace, objects = {objClone}
                , index = 1, replacing = true})
            characterPlaced = true
        elseif nextObjDescription == languagePrefix .. "_character-item" then
            objClone = cloneByGUID(nextObj.guid)
            Global.call("placeObjectsInPlayerZone", {playerColor = zoneColorToPlace, objects = {objClone}
                , index = 2 + characterItemCounter, replacing = true})
            characterItemCounter = characterItemCounter + 1
        elseif nextObjDescription == "character-item-counter" then
            objClone = cloneByGUID(nextObj.guid)
            Global.call("placeObjectsInPlayerZone", {playerColor = zoneColorToPlace, objects = {objClone}
                , index = 2, replacing = true})
        elseif nextObjDescription == languagePrefix .. "_character-soul" then
            objClone = cloneByGUID(nextObj.guid)
            Global.call("placeObjectInSoulZone", {playerColor = zoneColorToPlace, object = objClone})
        else
            goto continue
        end

        if objClone.getStateId() != -1 then
            for _, state in pairs(objClone.getStates()) do
                table.insert(spawnedObj, state.guid)
            end
        end

        table.insert(spawnedObj, objClone.guid)
        ::continue::
    end
    if characterPlaced then
        updatePlayerSpawnedObj(zoneColorToPlace, spawnedObj)
        local playerZone = getObjectFromGUID(Global.getTable("ZONE_GUID_PLAYER")[zoneColorToPlace])
        if playerZone then
            playerZone.setVar("active", true)
        end
        return true
    else
        return false
    end
end

function selectCharacter(_, playerClickerColor)
  if PLAYER_COLORS[playerClickerColor] == nil then
    Global.call("printWarningTP", {text = "Invalid player color. No position points for this color. Available colors: [DA1917]Red[-], [1E87FF]Blue[-], [E6E42B]Yellow[-], [30B22A]Green[-]", color =  playerClickerColor})
    return
  end

  local characterManager = getObjectFromGUID(CHARACTER_MANAGER_GUID)
  local waitForSelectCharacters = characterManager.getTable("waitForSelectCharacters")
  if #waitForSelectCharacters[playerClickerColor] > 0 and not isCharacterInPullToSelect(waitForSelectCharacters) then
    Global.call("printWarningTP", {text = "You can't select character from global pull while you select from random.", color =  playerClickerColor})
    return
  end

  if isCharacterInAnotherPlayerPullToSelect(playerClickerColor, waitForSelectCharacters) then
    Global.call("printWarningTP", {text = "You can't select character from another player pull.", color =  playerClickerColor})
    return
  end

  local zoneColorForCharacter = nil
  for color, charPacks in pairs(waitForSelectCharacters) do
      for _, charPack in pairs(charPacks) do
          if charPack.getGUID() == self.getGUID() then
              zoneColorForCharacter = color
              break
          end
      end
  end
  if zoneColorForCharacter == nil then
      zoneColorForCharacter = playerClickerColor
  end

  getObjectFromGUID(CHARACTER_MANAGER_GUID).call("cleanupSpawnedObj", {playerColor = zoneColorForCharacter})

  local language = Global.getVar('gameLanguage')
  local characterFound = cloneCharacterCards(zoneColorForCharacter, language)

  if not characterFound then
    Global.call("printWarning", {text = "No character cards for the selected language found in this pack: " .. self.getName()})
    if not cloneCharacterCards(zoneColorForCharacter, Global.getTable('GAME_LANGUAGE').US) then
        Global.call("printWarning", {text = "No standard (English) character cards found in this pack: " .. self.getName()})
        return
    end
  end
end

function isCharacterInPlayerPullToSelect(playerColor, waitForSelectCharacters)
  local isInPull = false
  for _, obj in pairs(waitForSelectCharacters[playerColor]) do
    if obj.guid == self.guid then
      isInPull = true
    end
  end
  return isInPull
end

function isCharacterInPullToSelect(waitForSelectCharacters)
  for color, _ in pairs(waitForSelectCharacters) do
      if isCharacterInPlayerPullToSelect(color, waitForSelectCharacters) then
          return true
      end
  end
  return false
end

function isCharacterInAnotherPlayerPullToSelect(clickedPlayerColor, waitForSelectCharacters)
    for zoneColor, zoneGuid in pairs(Global.getTable("ZONE_GUID_PLAYER")) do
        if (zoneColor != clickedPlayerColor) then
            local playerZone = getObjectFromGUID(zoneGuid)
            if playerZone and (playerZone.getVar("owner_color") != clickedPlayerColor) then
                if isCharacterInPlayerPullToSelect(zoneColor, waitForSelectCharacters) then
                    return true
                end
            end
        end
    end
    return false
end

function updatePlayerSpawnedObj(playerColor, spawnedObj)
  characterManager = getObjectFromGUID(CHARACTER_MANAGER_GUID)
  local playersSpawnedCharacterObj = characterManager.getTable("playersSpawnedCharacterObj")
  playersSpawnedCharacterObj[playerColor] = spawnedObj
  characterManager.setTable("playersSpawnedCharacterObj", playersSpawnedCharacterObj)
end

function unlock(obj)
  obj.interactable = true
end

function lock(obj)
    obj.interactable = false
end

-- For extended calls
function selectCharacterByCall(params)
  selectCharacter(nil, params.playerColor)
end

function isCharacterInPullToSelectByCall(params)
  return isCharacterInPullToSelect(params.waitForSelectCharacters)
end]]);
end

-- For extended calls
function setCharacterPackScriptByCall(params)
  setCharacterPackScript(params.obj)
end