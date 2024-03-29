local LANGUAGE = Global.getTable('GAME_LANGUAGE')

local LANGUAGE_FLAGS = {
    US = "5dd543",
    RU = "90e651",
    FR = "974d05",
    ES = "a796d3"
}

local GUID_TABLE_BASE = "f5c4fe"
local GUID_DECK_BUILDER = "69a80e"

LANGUAGES_GUIDS = {
  ["English"] = {
    -- Rulebook
    "54456f",
    -- Official cards box
    "cf0618",
    -- Eternal Piles
    "130b23",
    -- Box Expansions
    "dd6f16",
    "85b402",
    "29487d",
    "b3ed1e",
    "6b570f",
    "9e2b6c",
    "b7537f",
    "79f77f",
    "cd073d",
    -- Booster Expansions
    "25c0bc",
    "f16000",
    "31f975",
    "8ad698",
    "2a72bc",
    "e2ac3d",
    "711381",
    "999fa9",
    "e0e77c",
    -- Gamemodes
    "24d04a",
    "416011",
    "e9d4dd",
    "7bbdb4",
    "9a088b"
  },
  ["Russian"] = {
    -- Rulebook
    "6df828",
    -- Eternal Piles
    "c41988",
    -- Box Expansions
    "711262",
    "88dc4a",
    "65460b",
    "b48182",
    -- Official cards box
    "d91f32"
  },
  ["France"] = {
    -- Official cards box
    "8d0c2f",
    -- Rulebook
    "54456f"
  }
}

curLanguage = "English"
langChanging = false

local function switchLanguage(newLanguage)
    if newLanguage == nil then
        return
    end
    if (Global.getVar("gameLanguage") == newLanguage) or Global.call("hasGameStarted")
        or getObjectFromGUID(GUID_DECK_BUILDER).call("isDeckBuilderBlocked") then
        return
    end

    for lang, flagGUID in pairs(LANGUAGE_FLAGS) do
        getObjectFromGUID(flagGUID).editButton({index=0, label=""})
    end
    getObjectFromGUID(LANGUAGE_FLAGS[newLanguage]).editButton({index=0, label="✓", font_color={0, 0, 0}, font_size=450})
    getObjectFromGUID(GUID_TABLE_BASE).call("returnLanguageObjects", {language = newLanguage})
    getObjectFromGUID(GUID_TABLE_BASE).call("extractLanguageObjects", {language = newLanguage})
    Global.call("setGameLanguage", {language = newLanguage})
end

local function getLanguageFromObject(obj)
    for language, guid in pairs(LANGUAGE_FLAGS) do
        if obj.getGUID() == guid then
            return language
        end
    end
    return nil
end

function switchLanguageByObject(obj)
    local newLanguage = getLanguageFromObject(obj)
    switchLanguage(newLanguage)
end

--Only exist to set the game language at the beginning
function setLanguage(params)
    local language = nil
    if params.obj then
        language = getLanguageFromObject(params.obj)
    else
        return
    end
    getObjectFromGUID(GUID_TABLE_BASE).call("extractLanguageObjects", {language = language})
    Global.call("setGameLanguage", {language = language})
end




function selectLangDelayed(params)
  changeLangObjsVisibility(params.exLang, false)
  delayedCall("selectLangEnd", 0.3)
end

function selectLangEnd(params)
  langChanging = false
end

function changeLangObjsVisibility(lang, hide)
  yOffset = hide and -50 or 50
  for _, guid in pairs(LANGUAGES_GUIDS[lang]) do
    local obj = getObjectFromGUID(guid)
    if obj ~= nil then
      local curPos = obj.getPosition()
      curPos.y = curPos.y + yOffset
      obj.setPositionSmooth(curPos, false, true)
      obj.setLock(hide)
    end
  end
end

numTimers = 0
function delayedCall(funcName, delayTime, parameters)
    local uniqueID = 'timer'..numTimers
    numTimers = numTimers + 1
    Timer.create( {
        identifier = uniqueID,
        function_name = funcName,
        delay = delayTime,
        parameters = parameters } )
end