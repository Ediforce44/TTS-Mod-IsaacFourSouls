CHARACTER_MANAGER_GUID = "bc6e13"
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
end