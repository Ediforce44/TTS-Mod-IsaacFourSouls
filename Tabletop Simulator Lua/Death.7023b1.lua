--- Edited by Ediforce44
owner_color = "Green"
HEARTS_GUID = Global.getTable("HEART_TOKENS_GUID")[owner_color]
INACTIVE_HEART_COLOR = {1, 1, 1}
ACTIVE_HEART_COLOR = Global.getTable("REAL_PLAYER_COLOR_RGB")[owner_color]
PLAYER_ZONE_GUID = Global.getTable("ZONE_GUID_PLAYER")[owner_color]

HEART_INDEX = 1

isActive = false

function onPickUp()
  if isActive then
    local sfxCube = getObjectFromGUID(Global.getVar("SFX_CUBE_GUID"))
    if sfxCube then
        sfxCube.call("playDeath")
    end

    isActive = false
  end

  calcOtherHeartsState()
  changeColorByState()

  if Global.getTable("PLAYER_SETTINGS")[owner_color].deathDetection then
      local playerZone = getObjectFromGUID(PLAYER_ZONE_GUID)
      if playerZone then
          playerZone.call("killPlayer")
      end
  end

  stopPickUp()
end

function calcOtherHeartsState()
  for i, guid in pairs(HEARTS_GUID) do
    local obj = getObjectFromGUID(guid)
    if i > HEART_INDEX then
      changeHeartState(guid, false)
    end
  end
end

function changeHeartState(guid, newState)
  local obj = getObjectFromGUID(guid)
  obj.setVar("isActive", newState)
  obj.call("changeColorByState")
end

function changeColorByState()
  if not isActive then
    self.setColorTint(INACTIVE_HEART_COLOR)
  elseif isActive then
    self.setColorTint(ACTIVE_HEART_COLOR)
  else
    self.setColorTint(SOUL_HEART_COLOR)
  end
end

function stopPickUp()
  self.drop()
  self.setVelocity({0, 0, 0})
end