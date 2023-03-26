local CHALLENGE_MODULE = nil
local RULE_CARD_GUID = nil

local CONTENT_TABLE = {
    BOSS = "9be405",
    RULE = "2fd8aa",
    COUNTER = "b8c1e7",
    COUNTER_TWO = "e16f0d",
    --skip for better performance
    --MANUAL = "1a758e"
}

local DIF_TO_STATE = {
    BOSS = {
        DIF_NORMAL = 1,
        DIF_HARD = 2,
        DIF_ULTRA = 3,
        DIF_COMP = 3    --TODO it is 4
    },
    RULE = {
        DIF_NORMAL = 1,
        DIF_HARD = 1,
        DIF_ULTRA = 1,
        DIF_COMP = 1    --TODO it is 2
    }
}

HAS_SEP_COMP_MODE = true

local startTrickCounterBoss = {
    DIF_NORMAL = 12,
    DIF_HARD = 14,
    DIF_ULTRA = 14,
    DIF_COMP = 0
}

function onLoad(saved_data)
    CHALLENGE_MODULE = getObjectFromGUID(Global.getVar("CHALLENGE_MODULE"))

    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        if loaded_data.ruleCardGuid then
            RULE_CARD_GUID = loaded_data.ruleCardGuid
        end
    end
end

function onSave()
    return JSON.encode({ruleCardGuid = RULE_CARD_GUID})
end

local function extractContent(difficulty)
    local extractedContent = {}
    for id, guid in pairs(CONTENT_TABLE) do
        if (id ~= "COUNTER") or (difficulty ~= "DIF_COMP") then
            local object = self.takeObject({guid = guid})
            if object then
                if DIF_TO_STATE[id] then
                    local currentStateID = object.getStateId()
                    if (currentStateID > 0) and (currentStateID ~= DIF_TO_STATE[id][difficulty]) then
                        object = object.setState(DIF_TO_STATE[id][difficulty])
                    end
                end
                extractedContent[id] = object
            end
        end
    end
    return extractedContent
end

function presetupChallenge(params)
    local extractedContent = extractContent(params.difficulty)
    RULE_CARD_GUID = extractedContent.RULE.getGUID()
    CHALLENGE_MODULE.call("placeChallengeContent", extractedContent)
    self.setPositionSmooth(Global.getTable("CHALLENGE_LEFTOVERS_POSITION"), false)

    local counterBagGuids = Global.getTable("COUNTER_BAGS_GUID")
    if params.difficulty ~= "DIF_COMP" then
        counterBagGuids["TRICK"] = CONTENT_TABLE.COUNTER
    end
    counterBagGuids["FEAR"] = CONTENT_TABLE.COUNTER_TWO
    Global.setTable("COUNTER_BAGS_GUID", counterBagGuids)
end

function setupChallengeZones(params)
    local monsterGUIDs = params.preDeckGUIDs.MONSTER
    local noGoTags = params.filterTags

    for _, guid in pairs(monsterGUIDs) do
        local preDeck = getObjectFromGUID(guid)
        if preDeck then
            for _, infoTable in pairs(preDeck.getObjects()) do
                if string.match(infoTable.gm_notes, "the_haunt$") then
                    self.putObject(preDeck.takeObject({guid = infoTable.guid}))
                end
            end
        end
    end
end

function setupChallenge(params)
    if params.difficulty == "DIF_COMP" then
        Global.call("addTurnEvent", {atEnd = false, function_owner = self.getGUID()
            , call_function = "call_turnStartFunction_COMP", function_params = {difficulty = params.difficulty}})
    else
        local bossZone = CHALLENGE_MODULE.call("getBossZone")
        bossZone.call("placeCounterOnBoss", {type = "TRICK", amount = startTrickCounterBoss[params.difficulty]})
    end
end

------------------------------------------------------------------------------------------------------------------------
local voteColorsOwner = {}
local voteColorsVote = {}

local function getVisibilityString()
    local visibilityString = nil
    for owner, voteColors in pairs(voteColorsOwner) do
        for _, voteColor in pairs(voteColors) do
            if voteColorsVote[voteColor] == "WAIT_FOR_VOTE" then
                if visibilityString == nil then
                    visibilityString = owner
                else
                    visibilityString = visibilityString .. "|" .. owner
                end
                break
            end
        end
    end
    if visibilityString == nil then
        visibilityString = "Black"
    end
    return visibilityString
end

local function getRandomTrickOrTreat()
    local random = math.random()
    if random > 0.5 then
        return "TRICK"
    else
        return "TREAT"
    end
end

local function evaluateVote()
    local voteResult = nil
    local tempVotes = {TRICK = 0, TREAT = 0}
    for _, result in pairs(voteColorsVote) do
        if result == "WAIT_FOR_VOTE" then
            return nil
        else
            tempVotes[result] = tempVotes[result] + 1
        end
    end
    if tempVotes.TRICK > tempVotes.TREAT then
        return "TRICK"
    elseif tempVotes.TRICK < tempVotes.TREAT then
        return "TREAT"
    else
        return voteColorsVote[Global.getVar("activePlayerColor")]
    end
end

function call_turnStartFunction_COMP(params)
    voteColorsOwner = {}
    voteColorsVote = {}

    for color, guid in pairs(Global.getTable("ZONE_GUID_PLAYER")) do
        local zone = getObjectFromGUID(guid)
        if zone and zone.getVar("active") then
            local ownerColor = zone.getVar("owner_color")
            if Player[ownerColor].seated then
                if voteColorsOwner[ownerColor] == nil then
                    voteColorsOwner[ownerColor] = {}
                end
                table.insert(voteColorsOwner[ownerColor], color)
                voteColorsVote[color] = "WAIT_FOR_VOTE"
            end
        end
    end
    UI.setAttribute("voteTrickOrTreat", "visibility", getVisibilityString())
    UI.show("voteTrickOrTreat")

    for ownerColor, zoneColors in pairs(voteColorsOwner) do
        if #zoneColors > 1 then
            broadcastToColor("Trick or Treat - Vote for " .. Global.call("getPlayerString", {playerColor = zoneColors[1]}), ownerColor)
        end
    end
end

function UI_voted(player, _, voteID)
    if not voteColorsOwner[player.color] then
        return
    end

    local voteIdAssigned = false
    for _, zoneColor in ipairs(voteColorsOwner[player.color]) do
        if voteColorsVote[zoneColor] == "WAIT_FOR_VOTE" then
            if not voteIdAssigned then
                if voteID == "RANDOM" then
                    voteID = getRandomTrickOrTreat()
                    broadcastToColor("Trick or Treat - " .. Global.call("getPlayerString", {playerColor = zoneColor})
                        .. " voted for " .. voteID, player.color)
                end
                voteColorsVote[zoneColor] = voteID
                voteIdAssigned = true
            else
                broadcastToColor("Trick or Treat - Vote for " .. Global.call("getPlayerString", {playerColor = zoneColor}), player.color)
                return
            end
        end
    end
    UI.setAttribute("voteTrickOrTreat", "visibility", getVisibilityString())

    local result = evaluateVote()
    if result then
        broadcastToAll("Trick or Treat - Vote result is " .. result)
        UI.hide("voteTrickOrTreat")

        local ruleCard = getObjectFromGUID(RULE_CARD_GUID)
        if result == "TREAT" then
            local activePlayerColor = Global.getVar("activePlayerColor")
            for color, vote in pairs(voteColorsVote) do
                if (vote == "TREAT") and (color ~= activePlayerColor) then
                    local soulCounter = getObjectFromGUID(Global.getTable("SOUL_COUNTER_GUID")[activePlayerColor])
                    if soulCounter then
                        local soulAmount = soulCounter.getVar("val")
                        Global.call("dealLootToColor", {color = color, amount = soulAmount})
                    end
                end
            end
            if not ruleCard.is_face_down then
                ruleCard.flip()
            end
        else
            if ruleCard.is_face_down then
                ruleCard.flip()
            end
        end
    end
end