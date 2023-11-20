--- Edited by Ediforce44
owner_color = "Yellow"
HEARTS_GUID = Global.getTable("HEART_TOKENS_GUID")[owner_color]
INACTIVE_HEART_COLOR = {0.15, 0.15, 0.03}
ACTIVE_HEART_COLOR = Global.getTable("REAL_PLAYER_COLOR_RGB")[owner_color]
PLAYER_ZONE_GUID = Global.getTable("ZONE_GUID_PLAYER")[owner_color]

function getSelfIndex()
  for i, guid in pairs(HEARTS_GUID) do
    if self.guid == guid then return i end
  end
end

HEART_INDEX = getSelfIndex()

isActive = false

function onPickUp()
  isActive = true

  local playerZone = getObjectFromGUID(PLAYER_ZONE_GUID)
  if playerZone then
      playerZone.call("reanimatePlayer")
  end

  calcOtherHeartsState()
  changeColorByState()
  stopPickUp()
end

function calcOtherHeartsState()
  for i, guid in pairs(HEARTS_GUID) do
    local obj = getObjectFromGUID(guid)
    if i > HEART_INDEX then
      changeHeartState(guid, false)
    elseif i < HEART_INDEX then
      changeHeartState(guid, true)
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