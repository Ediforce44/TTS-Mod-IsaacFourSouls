CHARACTER_PLACER_GUID = "d2c68a"

inputCharCount = 2
characterPull = {}
waitForSelectCharacters = {
  Red = {},
  Blue = {},
  Green = {},
  Yellow = {}
}

playersSpawnedCharacterObj = {
  Red = {},
  Blue = {},
  Green = {},
  Yellow = {}
}

originalPositionTable = {}

STORE_BUTTON_INDEX = nil

STORE_BUTTON_LABEL = {
    STORE = "Store away",
    EXTRACT = "Extract"
}
math.randomseed(os.time())

local buttonsBlocked = false
local function tempBlockButtons()
    buttonsBlocked = true
    Timer.create({
        ["identifier"] = "CharRandomizerButtons" .. self.guid,
        ["function_name"] = "unblockButtons",
        ["delay"] = 0.2,
    })
end

function unblockButtons()
    buttonsBlocked = false
end

function onLoad(saved_data)
  loadCharPacksFromWorld()
  initButtons()
  if saved_data ~= "" then
      local loaded_data = JSON.decode(saved_data)
      if loaded_data[1] then
          originalPositionTable = loaded_data[1]
      end
  end
end

function onSave()
    return JSON.encode({originalPositionTable})
end

function loadCharPacksFromWorld(debug)
  characterPull = {}
  local allObj = getAllObjects()
  for i, obj in pairs(allObj) do
    if (obj.getDescription() == "character-pack") then
        if debug or ((obj.getPosition().y > 0) and not isCharUsedInWaitPull(obj.guid)) then
            table.insert(characterPull, obj.getGUID())
        end
    end
  end
end

function isCharUsedInWaitPull(charGuid)
  for _, player in pairs(waitForSelectCharacters) do
    for _, char in pairs(player) do
      if charGuid == char.guid then
        return true
      end
    end
  end
  return false
end

function cleanupSpawnedObj(params)
    if params.playerColor == nil then
        Global.call("printWarning", {text = "Wrong parameters in character manager function 'cleanupSpawnedObj()'."})
    end
    local playerCharacterObj = playersSpawnedCharacterObj[params.playerColor]
    if playerCharacterObj ~= nil then
        for _, guid in pairs(playerCharacterObj) do
            local obj = getObjectFromGUID(guid)
            if obj ~= nil then
                obj.destruct()
            end
        end
        playersSpawnedCharacterObj[params.playerColor] = {}
        local playerZone = getObjectFromGUID(Global.getTable("ZONE_GUID_PLAYER")[params.playerColor])
        if playerZone then
            playerZone.setVar("active", false)
        end
    end
end

function prepareCharPackForDealing(charPackGuid, playerColor)
    local charPack = getObjectFromGUID(charPackGuid)
    if charPack == nil then
        --Char Pack not found
        return
    end
    if charPack.resting then
        --Resting needed to don't set the position while pack is in the air (e.g. Returning and selecting immediately again)
        originalPositionTable[charPack.getGUID()] = charPack.getPosition()
    end

    --Just for the eden chars under the table
    charPack.interactable = true

    for index, waitingPackGuid in ipairs(characterPull) do
        if waitingPackGuid == charPackGuid then
            table.remove(characterPull, index)
        end
    end

    Wait.frames(function() makeCharPackToSelect(charPack, playerColor) end)

    return charPack
end

function dealCharPacksToPlayer(charPacks, playerColor)
    for _, charPack in pairs(charPacks) do
        table.insert(waitForSelectCharacters[playerColor], charPack)
    end

    Global.call("placeObjectsInPlayerZone", {playerColor = playerColor, objects = charPacks, index = 8, replacing = true})
end

function dealCharPackToPlayer(params)
    if (params.charPack == nil) or (params.playerColor == nil) then
        Global.call("printWarning", {text = "Wrong parameters in character manager function 'dealCharPackToPlayer()'."})
        return
    end

    prepareCharPackForDealing(params.charPack.getGUID(), params.playerColor)

    table.insert(waitForSelectCharacters[params.playerColor], params.charPack)

    Global.call("placeObjectsInPlayerZone", {playerColor = params.playerColor, objects = {params.charPack}, index = 8, replacing = false})
end

function initButtons()
    self.createInput({
        value = "Character Randomizer",
        input_function = "dummy",
        function_owner = self,
        position = {0, 1, -1.5},
        width = 2000,
        height = 230,
        font_size = 200,
        alignment = 3,
        scale={x=2.5, y=2.5, z=2.5},
        font_color= {1, 1, 1, 100},
        color = {0,0,0,0}
    })
  self.createButton({
    click_function = "nope",
    function_owner = self,
    label          = "Count:",
    position       = {-7.4, 1, 0},
    width          = 0,
    height         = 0,
    font_size      = 300,
    font_color     = {1, 1, 1}
  })
  self.createInput({
    input_function = "updateCharactersCount",
    function_owner = self,
    label          = "test",
    alignment      = 3,
    position       = {-6, 1, 0},
    width          = 300,
    height         = 340,
    font_size      = 300,
    value          = inputCharCount,
    validation     = 2,
    tab            = 1,
    font_color= {1,1,1},
    color = {0.1,0.1,0.1}
  })
  self.createButton({
    click_function = "randomizeToAll",
    function_owner = self,
    label          = "Randomize to [e57373]All",
    position       = {-2.9, 1, 0},
    width          = 2000,
    height         = 350,
    font_size      = 230,
    font_color= {1,1,1},
    color = {0.1,0.1,0.1}
  })
  self.createButton({
    click_function = "randomizeToMe",
    function_owner = self,
    label          = "Randomize to [7986cb]Me",
    position       = {1.4, 1, 0},
    width          = 2000,
    height         = 350,
    font_size      = 230,
    font_color= {1,1,1},
    color = {0.1,0.1,0.1}
  })
  self.createButton({
    click_function = "click_storeOrExtract",
    function_owner = self,
    label          = "Store away",
    position       = {5.7, 1, 0},
    width          = 1800,
    height         = 350,
    tooltip        = "[b]Store or extract surplus Character Packs[/b]",
    font_size      = 230,
    font_color= {1,1,1},
    color = {0.1,0.1,0.1}
  })
  STORE_BUTTON_INDEX = 3
end

function updateCharactersCount(obj, _, value)
  local newValue = nil
  if value ~= "" then
      if tonumber(value) then
          if tonumber(value) > 7 then
              print("Invalid input value. Set to max: 7")
              newValue = 7
          elseif tonumber(value) <= 0 then
              print("Invalid input value. Set to min: 1")
              newValue = 1
          else
              newValue = value
          end
      else
          newValue = inputCharCount
      end
      Wait.frames(function() obj.editInput({index=1, value=newValue}) end)
      inputCharCount = newValue
  end
end

local function returnAllCharPacksFromPlayer(playerColor)
    for _ = 1,  #waitForSelectCharacters[playerColor] do
        returnCharPack(waitForSelectCharacters[playerColor][1], playerColor)
    end
end

function returnAllCharPacks()
    for color, _ in pairs(waitForSelectCharacters) do
        returnAllCharPacksFromPlayer(color)
    end
end

function randomizeToAll(_, playerClickerColor)
  if buttonsBlocked then return end
  tempBlockButtons()

  loadCharPacksFromWorld()
  if #characterPull < 6 then
    Global.call("printWarningTP", {text = "Too few characters (min: 6). Maybe you forget  press \"Place characters\" button?", color =  playerClickerColor})
    return
  end

  local zoneColorTable = {}
  playerList = Player.getPlayers()
  for _, player in pairs(playerList) do
      for zoneColor, zoneGuid in pairs(Global.getTable("ZONE_GUID_PLAYER")) do
          local zone = getObjectFromGUID(zoneGuid)
          if zone and (zone.getVar("owner_color") == player.color) then
              table.insert(zoneColorTable, zoneColor)
          end
      end
  end
  randomizeToPlayers(zoneColorTable)
end

function randomizeToMe(_, playerClickerColor)
  if buttonsBlocked then return end
  tempBlockButtons()

  loadCharPacksFromWorld()
  if #characterPull < 2 then
    Global.call("printWarningTP", {text = "Too few characters (min: 2). Maybe you forget  press \"Place characters\" button?", color =  playerClickerColor})
    return
  end

  local zoneColorTable = {}
  for zoneColor, zoneGuid in pairs(Global.getTable("ZONE_GUID_PLAYER")) do
      local zone = getObjectFromGUID(zoneGuid)
      if zone and (zone.getVar("owner_color") == playerClickerColor) then
          table.insert(zoneColorTable, zoneColor)
      end
  end
  randomizeToPlayers(zoneColorTable)
end

function randomizeToPlayers(playerColors)
  for _, playerColor in pairs(playerColors) do
      if waitForSelectCharacters[playerColor] == nil then
          Global.call("printWarningTP", {text = "" .. playerColor .. " is invalid color. " .. playerColor .. " must change color to one of valid: [DA1917]Red[-], [1E87FF]Blue[-], [E6E42B]Yellow[-], [30B22A]Green[-]", color =  playerColor})
          return
      end
  end

  local selectedGuids = {}
  local packIndexLUT = {}
  for i = 1, inputCharCount * #playerColors do
      ::picking::
      local randomCharPackIndex = math.random(#characterPull)
      if packIndexLUT[randomCharPackIndex] then
          goto picking
      end
      table.insert(selectedGuids, characterPull[randomCharPackIndex])
      packIndexLUT[randomCharPackIndex] = true
      if i >= #characterPull then
          break
      end
  end

  local selectedCharPacks = {}

  for colorIndex, playerColor in pairs(playerColors) do
      selectedCharPacks[colorIndex] = {}
      for i = 1, inputCharCount do
          local selectedCharPack = prepareCharPackForDealing(selectedGuids[inputCharCount*(colorIndex-1) + i], playerColor)
          table.insert(selectedCharPacks[colorIndex], selectedCharPack)
      end
  end

  for index, playerColor in pairs(playerColors) do
      cleanupSpawnedObj({playerColor = playerColor})

      if #waitForSelectCharacters[playerColor] ~= 0 then
          printToAll("Reshuffle Characters")
          returnAllCharPacksFromPlayer(playerColor)
      end

      dealCharPacksToPlayer(selectedCharPacks[index], playerColor)
  end
end

function makeCharPackToSelect(obj, playerColor)
  obj.clearButtons()
  obj.interactable = false

  obj.createButton({
    click_function = "selectCharacter",
    function_owner = self,
    label = "Select",
    position = {0, 0.3, 1.7},
    width = 760,
    height = 260,
    font_size = 180,
    font_color = {1, 1, 1},
    color = {102/225, 187/255, 106/255}
  })
  obj.createButton({
    click_function = "returnCharPack",
    function_owner = self,
    label = "Return",
    position = {0, 0.3, -1.7},
    width = 480,
    height = 200,
    font_size = 100,
    font_color = {1, 1, 1},
    color = {239/225, 83/255, 80/255}
  })
end

function selectCharacter(obj, playerColor)
  obj.call("selectCharacterByCall", {obj=obj, playerColor=playerColor})
end

testTable = {}

function returnCharPack(obj, playerColor)
  removeCharPackFromSelecting(obj.guid, playerColor)
  -- getObjectFromGUID(CHARACTER_PLACER_GUID).call("setCharacterPackScriptByCall", {obj=obj})
  obj.call("initButtons")
  local originalPosition = originalPositionTable[obj.guid]
  obj.setPositionSmooth(originalPosition, false)
  obj.setRotation({0, 180, 0})
end

function removeCharPackFromSelecting(charGuid, playerColor)
  if not waitForSelectCharacters[playerColor] then
    printToColor("[ef5350][ERROR][-] You do not have characters for select", playerColor, stringColorToRGB("Red"))
    return
  end

  for i, char in pairs(waitForSelectCharacters[playerColor]) do
    if char.guid == charGuid then
      table.insert(characterPull, char.guid)
      table.remove(waitForSelectCharacters[playerColor], i)
    end
  end
end

function onAllCharsDeleted()
  characterPull = {}
  waitForSelectCharacters = {
    Red = {},
    Blue = {},
    Green = {},
    Yellow = {}
  }
end

function click_storeOrExtract()
    if buttonsBlocked then return end
    tempBlockButtons()

    local characterPlacer = getObjectFromGUID(CHARACTER_PLACER_GUID)
    if characterPlacer then
        local emcBag = getObjectFromGUID(characterPlacer.getVar("EVEN_MORE_CHARS_BAG_GUID"))
        if emcBag then
            if emcBag.getQuantity() == 0 then
                local surplusCharacterPacks = {}
                for i, obj in pairs(getAllObjects()) do
                    if obj.getDescription() == "character-pack" then
                        if originalPositionTable[obj.getGUID()] and (originalPositionTable[obj.getGUID()].y > 10) then
                            local objectGuid = obj.getGUID()
                            for color, objTable in pairs(waitForSelectCharacters) do
                                for index, object in pairs(objTable) do
                                    if object.getGUID() == objectGuid then
                                        table.remove(waitForSelectCharacters[color], index)
                                    end
                                end
                            end
                            originalPositionTable[objectGuid] = nil
                            table.insert(surplusCharacterPacks, obj)
                        elseif obj.getPosition().y > 10 then
                            table.insert(surplusCharacterPacks, obj)
                        end
                    end
                end
                if #surplusCharacterPacks > 0 then
                    self.editButton({index = STORE_BUTTON_INDEX, label = STORE_BUTTON_LABEL.EXTRACT})
                    characterPlacer.call("storeSurplusCharacterPacks", {charPacks = surplusCharacterPacks})
                else
                    Global.call("printWarning", {text = "There are no surplus Character Packs to store away."})
                end
            else
                self.editButton({index = STORE_BUTTON_INDEX, label = STORE_BUTTON_LABEL.STORE})
                characterPlacer.call("extractSurplusCharacterPacks")
            end
        end
    end
end


function _debug_characters(params)
    local languagePrefix = nil
    if params and params.language then
        languagePrefix = params.language
    end

    local charDeck = nil
    local itemDeck = nil

    loadCharPacksFromWorld(true)
    for _, charPackGuid in pairs(characterPull) do
        local charPack = getObjectFromGUID(charPackGuid)
        if charPack then
            if languagePrefix then
                for _, objectInfo in pairs(charPack.getObjects()) do
                    if objectInfo.description == languagePrefix .. "_character" then
                        local charCard = charPack.takeObject({guid = objectInfo.guid})
                        if charDeck then
                            charDeck = charDeck.putObject(charCard)
                        else
                            charCard.setPosition({0.5, 1.5, -15.24})
                            charDeck = charCard
                        end
                    elseif objectInfo.description == languagePrefix .. "_character-item" then
                        local itemCard = charPack.takeObject({guid = objectInfo.guid})
                        if itemDeck then
                            itemDeck = itemDeck.putObject(itemCard)
                        else
                            itemCard.setPosition({4.51, 1.5, -15.24})
                            itemDeck = itemCard
                        end
                    end
                end
            else
                for _, objectInfo in pairs(charPack.getObjects()) do
                    if string.match(objectInfo.description, "_character$") then
                        local charCard = charPack.takeObject({guid = objectInfo.guid})
                        if charDeck then
                            charDeck = charDeck.putObject(charCard)
                        else
                            charCard.setPosition({0.5, 1.5, -15.24})
                            charDeck = charCard
                        end
                    elseif string.match(objectInfo.description, "_character[-]item$") then
                        local itemCard = charPack.takeObject({guid = objectInfo.guid})
                        if itemDeck then
                            itemDeck = itemDeck.putObject(itemCard)
                        else
                            itemCard.setPosition({4.51, 1.5, -15.24})
                            itemDeck = itemCard
                        end
                    end
                end
            end
        end
    end
end

function dummy()
end