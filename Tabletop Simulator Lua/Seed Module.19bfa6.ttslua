local CHARACTER_MANAGER_GUID = "bc6e13"

local startSearch = "Built Deck"
local endSearch = "Share this loadout"
local textSectionTable = {
    CHARACTER = "Starting Characters",
    LOOT = "Loot Cards",
    MONSTER = "Monster Cards",
    TREASURE = "Treasure Cards",
    BONUS_SOUL = "Soul Cards"
}

local function decryptHTML(request)
    if request.is_error then
        log(request.error)
    else
        local htmlText = request.text
        local sectionStartIndex = {}
        local sectionEndIndex = {}
        local startIndex = string.find(htmlText, startSearch)
        local endIndex = string.find(htmlText, endSearch)
        htmlText = string.sub(htmlText, startIndex, endIndex)
        for sectionType, keyword in pairs(textSectionTable) do
            local textIndex = string.find(htmlText, keyword)
            if textIndex ~= nil then
                sectionStartIndex[sectionType] = textIndex
            end
        end
        for sectionType, startIndex in pairs(sectionStartIndex) do
            local endIndex = nil
            for _, otherIndex in pairs(sectionStartIndex) do
                if otherIndex > startIndex then
                    if endIndex == nil then
                        endIndex = otherIndex
                    elseif otherIndex < endIndex then
                        endIndex = otherIndex
                    end
                end
            end
            sectionEndIndex[sectionType] = endIndex
        end

        local cardLookUpTable = {}

        for section, startIndex in pairs(sectionStartIndex) do
            cardLookUpTable[section] = {}
            local textPart = string.sub(htmlText, startIndex, sectionEndIndex[section])
            textPart = string.gsub(textPart, "<div", "~")
            local lookUpTable = {}
            for cardString in string.gmatch(textPart, "[^~]+") do
                local cardName = string.match(cardString, "href=\"[%w%p%s]+\"")
                if cardName ~= nil then
                    cardName = string.match(cardName, "cards/[%w%p%s]+/")
                    cardName = string.sub(cardName, 7, -2)
                    lookUpTable[cardName] = true
                end
            end
            cardLookUpTable[section] = lookUpTable
        end
        return cardLookUpTable
    end
end

local function getSeedFromHTML(request)
    if request.is_error then
        return Global.getTable("PRINT_COLOR_SPECIAL").RED .. "FAILURE!!"
    else
        local htmlText = request.text
        local startIndex = string.find(htmlText, endSearch)
        local tempSeedParts = string.match(htmlText, "<p>%w+</p>%s*<p>%w+</p>", startIndex)
        tempSeedParts = string.gsub(tempSeedParts, "<p>%w+</p>", function(part) return string.match(part, "%w%w%w%w")end)
        return string.gsub(tempSeedParts, "%s+", " ")
    end
end

local function getCharPacks(characterCards)
    local charPacks = {}
    local allObjects = Global.getObjects()
    for _, obj in pairs(allObjects) do
        if characterCards[obj.getGMNotes()] then
            table.insert(charPacks, obj)
            characterCards[obj.getGMNotes()] = false
        end
    end
    --For alt art characters
    local mainBoxes = {"b2", "r", "g2", "fsp2"}
    for cardID, notFound in pairs(characterCards) do
        if notFound and string.match(cardID, "aa[-].+") then
            for _, boxID in ipairs(mainBoxes) do
                local altCardID = string.gsub(cardID, "aa", boxID, 1)
                for _, obj in pairs(allObjects) do
                    if obj.getGMNotes() == altCardID then
                        table.insert(charPacks, obj)
                        characterCards[cardID] = false
                        break
                    end
                end
                if characterCards[cardID] == false then break end
            end
        end
    end
    return charPacks
end

local function distributeCharacters(characterCards)
    if characterCards == nil then
        return
    end

    local charPacks = getCharPacks(characterCards)

    for _, playerColor in pairs(Global.getTable("PLAYER")) do
        local playerOwner = Global.getTable("PLAYER_OWNER")
        if Player[playerOwner[playerColor]].seated then
            if #charPacks == 0 then
                return
            end
            getObjectFromGUID(CHARACTER_MANAGER_GUID).call("cleanupSpawnedObj", {playerColor = playerColor})
            getObjectFromGUID(CHARACTER_MANAGER_GUID).call("dealCharPackToPlayer", {charPack = charPacks[1], playerColor = playerColor})
            table.remove(charPacks, 1)
        end
    end

    if #charPacks > 0 then
        for _, charPack in pairs(charPacks) do
            getObjectFromGUID(CHARACTER_MANAGER_GUID).call("cleanupSpawnedObj", {playerColor = "Red"})
            getObjectFromGUID(CHARACTER_MANAGER_GUID).call("dealCharPackToPlayer", {charPack = charPack, playerColor = "Red"})
        end
    end
end

function startSeedAlgorithm(params)
    getObjectFromGUID("195d79").call("blockStartButton")
    broadcastToAll(Global.getTable("PRINT_COLOR_SPECIAL").GRAY_LIGHT .. "Start Seed calculation ...")
    WebRequest.post("https://foursouls.com/deckbuilder/", params.httpBody,
     function(request)
         local cardLookUpTable = decryptHTML(request)
         distributeCharacters(cardLookUpTable.CHARACTER)
         getObjectFromGUID("69a80e").call("activateSeedMode", {selectedCards = cardLookUpTable})
         getObjectFromGUID("195d79").call("unblockStartButton")
         broadcastToAll(Global.getTable("PRINT_COLOR_SPECIAL").GRAY_LIGHT .. "Seed calculation finished!")
         broadcastToAll(Global.getTable("PRINT_COLOR_SPECIAL").GRAY_LIGHT .. "Your Seed is: " .. getSeedFromHTML(request))
     end)
end